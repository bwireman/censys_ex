defmodule CensysEx.API do
  @moduledoc """
  Base Wrapper for search.censys.io v2 APIs
  """

  @behaviour CensysEx.APIBehavior
  use GenServer

  alias CensysEx.Util

  @id_var "CENSYS_API_ID"
  @secret_var "CENSYS_API_SECRET"
  @creds "CENSYS_API_CREDS"

  # api

  @doc """
  Starts the CensysEx.API. Pulls in API ID & secret from the env variables `CENSYS_API_ID` & `CENSYS_API_SECRET`

  ## Examples
  ```
  iex(1)> # CENSYS_API_ID environment var not set
  iex(2)> CensysEx.API.start_link
  {:error, "CENSYS_API_ID missing!"}
  ```
  """
  @spec start_link() :: GenServer.on_start()
  def start_link do
    id = System.get_env(@id_var, "")
    secret = System.get_env(@secret_var, "")

    CensysEx.API.start_link(id, secret)
  end

  @doc """
  Starts the CensysEx.API process

  ## Examples
  ```
  {:ok, _} = CensysEx.API.start_link([id: "***********", secret: "***********"])
  ```
  """
  @spec start_link(keyword(String.t())) :: GenServer.on_start()
  def start_link(creds) do
    id = Access.get(creds, :id, "")
    secret = Access.get(creds, :secret, "")

    CensysEx.API.start_link(id, secret)
  end

  @doc """
  Starts the CensysEx.API process

  ## Examples
  ```
  {:ok, _} = CensysEx.API.start_link("***********", "***********")
  ```
  """
  @spec start_link(String.t(), String.t()) :: GenServer.on_start()
  def start_link(id, secret) do
    case {id, secret} do
      {"", _} -> {:error, @id_var <> " missing!"}
      {_, ""} -> {:error, @secret_var <> " missing!"}
      _ -> GenServer.start_link(__MODULE__, {id, secret}, name: __MODULE__)
    end
  end

  @spec view(String.t(), String.t(), DateTime.t() | nil) :: CensysEx.result()
  @impl CensysEx.APIBehavior
  def view(resource, id, at_time \\ nil),
    do: get(resource, id, [], params: Util.build_view_params(at_time))

  @spec aggregate(String.t(), String.t(), String.t() | nil, integer()) ::
          CensysEx.result()
  @impl CensysEx.APIBehavior
  def aggregate(resource, field, query \\ nil, num_buckets \\ 50),
    do: get(resource, "aggregate", [], params: Util.build_aggregate_params(field, query, num_buckets))

  @spec get(String.t(), String.t(), list(), keyword()) :: CensysEx.result()
  @impl CensysEx.APIBehavior
  def get(resource, action, headers \\ [], options \\ []),
    do: GenServer.call(__MODULE__, {:get, {resource, action, headers, options}}, 10_000)

  # util
  @spec build_path(String.t(), String.t()) :: String.t()
  defp build_path(resource, action),
    do: "https://search.censys.io/api/v2/" <> resource <> "/" <> action

  @spec get_creds() :: tuple()
  defp get_creds do
    case :ets.lookup(__MODULE__, @creds) do
      [head | _] -> head |> elem(1)
    end
  end

  # impl

  @doc false
  @impl GenServer
  def init({id, secret}) do
    __MODULE__ = :ets.new(__MODULE__, [:set, :named_table, :private])
    :ets.insert(__MODULE__, {@creds, {id, secret}})
    {:ok, nil}
  end

  @doc false
  @impl GenServer
  def handle_call({:get, {resource, action, headers, options}}, _from, nil) do
    path = build_path(resource, action)
    basic_auth = get_creds()

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
          Util.parse_body(body)

        {:error, %HTTPoison.Error{reason: reason}} ->
          {:error, reason}
      end

    {:reply, resp, nil}
  end

  @impl GenServer
  def handle_info(_, state) do
    {:noreply, state}
  end
end
