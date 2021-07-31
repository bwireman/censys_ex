defmodule CensysEx.Search do
  @moduledoc """
  Search API V2 Specific wrapper around CensysEx.Paginate
  """

  alias CensysEx.{Paginate, Util}

  @spec search(String.t(), String.t(), integer()) :: Enumerable.t()
  def search(index, query \\ "", per_page \\ 100),
    do: Paginate.stream(gen_search_fn(index), &get_hits/1, q: query, per_page: per_page)

  defp get_hits(%Paginate{} = client),
    do: get_in(client.results, ["result", "hits"])

  defp gen_search_fn(index),
    do: fn params -> Util.get_client().get(index, "search", [], params) end
end
