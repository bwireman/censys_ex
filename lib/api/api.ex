defmodule CensysEx.API do
  @behaviour CensysEx.APIBehavior
  use GenServer

  @moduledoc """
  Base Wrapper for search.censys.io v2 APIs
  """

  # api

  @doc """
  Starts the CensysEx.API. Pulls in API ID & secret from the env variables `CENSYS_API_ID` & `CENSYS_API_SECRET`

  ## Examples
  ```
  iex(1)> # CENSYS_API_ID not set
  iex(2)> CensysEx.API.start_link
  {:error, "Censys API ID missing!"}
  ```
  """
  def start_link do
    id = System.get_env("CENSYS_API_ID", "")
    secret = System.get_env("CENSYS_API_SECRET", "")

    CensysEx.API.start_link(id, secret)
  end

  @doc """
  Starts the CensysEx.API process

  ## Examples
  ```
  {:ok, _} = CensysEx.API.start_link("***********", "***********")
  ```
  """
  def start_link(id, secret) do
    case {id, secret} do
      {"", _} -> {:error, "Censys API ID missing!"}
      {_, ""} -> {:error, "Censys API SECRET missing!"}
      _ -> GenServer.start_link(__MODULE__, {id, secret}, name: __MODULE__)
    end
  end

  @doc false
  @spec view(String.t(), String.t(), DateTime.t()) :: {:error, any()} | {:ok, map()}
  @impl true
  def view(resource, id, at_time \\ nil) do
    opts =
      case at_time do
        nil -> []
        _ -> [params: [at_time: Timex.format(at_time, "%Y-%m-%dT%H:%M:%S", :strftime)]]
      end

    get(resource, "#{id}", [], opts)
  end

  @doc false
  @spec aggregate(String.t(), String.t(), String.t(), integer()) :: {:error, any()} | {:ok, map()}
  @impl true
  def aggregate(resource, field, query \\ nil, num_buckets \\ 50) do
    params = [field: field, num_buckets: num_buckets]
    params = if(query != nil, do: [{:q, query} | params], else: params)

    get(resource, "aggregate", [], params: params)
  end

  @doc false
  @spec get(String.t(), String.t(), List, List) :: {:error, any()} | {:ok, map()}
  @impl true
  def get(resource, action, headers \\ [], options \\ []),
    do: GenServer.call(__MODULE__, {:get, {resource, action, headers, options}}, 10_000)

  # util
  defp build_path(resource, action),
    do: "https://search.censys.io/api/v2/" <> resource <> "/" <> action

  # impl

  @doc false
  @impl true
  def init({id, secret}) do
    {:ok, {id, secret}}
  end

  @doc false
  @impl true
  def handle_call({:get, {resource, action, headers, options}}, _from, {id, secret}) do
    path = build_path(resource, action)
    basic_auth = {id, secret}

    options =
      Keyword.update(
        options,
        :hackney,
        Keyword.new(basic_auth: basic_auth),
        &Keyword.put_new(&1, :basic_auth, basic_auth)
      )

    headers = [{"Content-Type", "application/json"} | headers]

    resp =
      case HTTPoison.get(path, headers, options) do
        {:ok, %HTTPoison.Response{body: body}} ->
          CensysEx.Util.parse_body(body)

        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, reason}
      end

    {:reply, resp, {id, secret}}
  end
end
