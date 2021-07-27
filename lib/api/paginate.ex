defmodule CensysEx.Paginate do
  @moduledoc """
  CensysEx.Paginate implements a wrapper for cursor paginated APIs
  """

  @enforce_keys [:next_fn, :results_fn]
  defstruct [:next_fn, :results_fn, cursor: "", params: Keyword.new(), results: %{}, page: 0]

  @typedoc """
  struct to maintain the state of a paginated api call
  """
  @type t :: %CensysEx.Paginate{
          next_fn: next_page_fn(),
          results_fn: result_extractor(),
          params: Keyword.t(),
          cursor: String.t(),
          results: map(),
          page: integer()
        }

  @typedoc """
  function that takes in the internal results of paginated API calls, returning a [any]
  """
  @type result_extractor :: (t() -> [any])

  @typedoc """
  function that takes in a keyword list of query params and returns either a map of results or an error
  """
  @type next_page_fn :: (Keyword.t() -> {:ok, map()} | {:error, any})

  def stream(next_fn, results_fn, params \\ Keyword.new()) do
    client = %CensysEx.Paginate{
      next_fn: next_fn,
      results_fn: results_fn,
      params: params
    }

    Stream.resource(
      fn -> client end,
      fn resource -> stream_next(resource) end,
      fn _ -> :ok end
    )
    |> Stream.flat_map(& &1)
  end

  # accumulator used in Stream.resource calls
  # client.next_fn and client.results_fn
  defp stream_next(%CensysEx.Paginate{} = client) do
    acc = search_internal!(client)

    case {acc.cursor, acc.results, acc.page} do
      {cursor, _, page} when cursor != "" or page == 1 -> {[client.results_fn.(acc)], acc}
      {"", _, _} -> {:halt, acc}
      {_, %{}, _} -> {:halt, acc}
    end
  end

  # updates Paginate struct with results cursor and page index from next request
  defp iterate_page(%CensysEx.Paginate{} = client, body \\ %{}, cursor \\ ""),
    do: %{client | results: body, cursor: cursor, page: client.page + 1}

  # build query params and calls client.next_fn and paginates to the next page
  defp search_internal!(%CensysEx.Paginate{} = client) do
    if client.page > 0 and client.cursor == "" do
      iterate_page(client)
    else
      params =
        case client.cursor do
          "" -> [] ++ client.params
          cursor -> [cursor: cursor] ++ client.params
        end

      case client.next_fn.(params) do
        {:ok, body} ->
          next_cursor = get_in(body, ["result", "links", "next"])
          iterate_page(client, body, next_cursor)

        {:error, err} ->
          raise CensysEx.Exception, message: "CensysEx: " <> err
      end
    end
  end
end
