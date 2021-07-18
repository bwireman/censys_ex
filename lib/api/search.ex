defmodule CensysEx.Search do
  @moduledoc """
  Search API V2 Specific wrapper around CensysEx.Paginate
  """

  def search(index, query \\ "", per_page \\ 100),
    do:
      CensysEx.Paginate.stream(gen_search_fn(index), &get_hits/1, %{
        params: [q: query, per_page: per_page]
      })

  defp get_hits(%CensysEx.Paginate{} = client),
    do: Map.get(Map.get(client.results, "result", %{}), "hits", [])

  defp gen_search_fn(index),
    do: fn params -> CensysEx.Util.get_client().get(index, "search", [], params: params) end
end
