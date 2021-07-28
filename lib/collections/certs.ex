defmodule CensysEx.Certs do
  @moduledoc """
  CensysEx wrapper for the search.censys.io v2 API for the "certs" resource
  """

  alias CensysEx.{Paginate, Util}

  @index "certificates"

  @doc """
  Hits the Censys Certs hosts API. Returns a stream of results

    - API docs: https://search.censys.io/api#/certs/getHostsByCert

  ## Examples

  ```
  CensysEx.Certs.get_hosts_by_cert("fb444eb8e68437bae06232b9f5091bccff62a768ca09e92eb5c9c2cf9d17c426")
  |> Stream.take(25)
  |> Stream.map(&Map.get(&1, "ip"))
  |> Enum.to_list()
  ["10.0.0.6", "10.2.0.1", ...]
  ```
  """
  def get_hosts_by_cert(fp) do
    next = fn params -> Util.get_client().get(@index, fp <> "/hosts", [], params) end
    extractor = fn client = %Paginate{} -> get_in(client.results, ["result", "hosts"]) end

    Paginate.stream(next, extractor)
  end
end
