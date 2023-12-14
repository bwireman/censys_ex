defmodule CensysEx.API do
  @moduledoc """
  Base Wrapper for search.censys.io v2 APIs
  """
  use Dreamy

  alias CensysEx.Util

  @opaque t() :: Tesla.Client.t()

  @spec client :: t()
  def client, do: client(Application.get_env(:censys_ex, :api_id), Application.get_env(:censys_ex, :api_key))

  # api
  @spec client(String.t(), String.t()) :: t()
  def client(api_key, api_secret) do
    middleware = [
      {Tesla.Middleware.BaseUrl, "https://search.censys.io/api/"},
      Tesla.Middleware.JSON,
      {Tesla.Middleware.BasicAuth, username: api_key, password: api_secret},
      {Tesla.Middleware.Headers, [{"Content-Type", "application/json"}]}
    ]

    adapter = {Tesla.Adapter.Finch, [name: CensysExFinch]}
    Tesla.client(middleware, adapter)
  end

  @spec view(t(), String.t(), String.t(), DateTime.t() | nil) :: CensysEx.result()
  def view(client, resource, id, at_time \\ nil),
    do: get(client, resource, id, params: Util.build_view_params(at_time))

  @spec aggregate(t(), String.t(), String.t(), String.t() | nil, integer(), Keyword.t()) ::
          CensysEx.result()
  def aggregate(
        client,
        resource,
        field,
        query \\ nil,
        num_buckets \\ 50,
        other_params \\ Keyword.new()
      ),
      do:
        get(client, resource, "aggregate",
          params: Util.build_aggregate_params(field, query, num_buckets) ++ other_params
        )

  @spec get(t(), String.t(), String.t(), keyword()) :: CensysEx.result()
  def get(client, resource, action, options \\ []),
    do: request(client, build_v2_path(resource, action), options)

  @spec get_v1(t(), String.t(), String.t(), keyword()) :: CensysEx.result()
  def get_v1(client, resource, action, options \\ []),
    do: request(client, build_v1_path(resource, action), options)

  # util
  @spec build_v1_path(String.t(), String.t()) :: String.t()
  defp build_v1_path(resource, action),
    do: "v1/" <> action <> "/" <> resource

  @spec build_v2_path(String.t(), String.t()) :: String.t()
  defp build_v2_path(resource, action),
    do: "v2/" <> resource <> "/" <> action

  defp request(client, path, options) do
    Tesla.get(client, path, opts: options)
    ~>> fn %Tesla.Env{body: body, status: status_code} -> Util.parse_body(body, status_code) end
  end
end
