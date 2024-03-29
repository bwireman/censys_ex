defmodule CensysEx.Search do
  @moduledoc """
  Search API V2 Specific wrapper around CensysEx.Paginate
  """

  alias CensysEx.Paginate

  @spec search(CensysEx.API.t(), String.t(), String.t(), integer(), Keyword.t()) :: CensysEx.result_stream(map())
  def search(client, index, query \\ "", per_page \\ 100, other_params \\ Keyword.new())

  def search(client, index, query, per_page, other_params)
      when index in ["hosts", "certificates"],
      do: Paginate.stream(client, gen_search_fn(index), &get_hits/1, [q: query, per_page: per_page] ++ other_params)

  def search(_, index, _, _, _), do: raise(CensysEx.Exception, message: "CensysEx: invalid index: #{index}")

  defp get_hits(%Paginate{} = client),
    do: get_in(client.results, ["result", "hits"])

  defp gen_search_fn(index),
    do: fn client, params -> CensysEx.API.get(client, index, "search", params) end
end
