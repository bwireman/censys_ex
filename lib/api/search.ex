defmodule CensysEx.Search do
  @moduledoc false

  # Client for Search API
  @enforce_keys [:query, :per_page, :index]
  defstruct [:query, :per_page, :index, cursor: "", results: %{}, page: 0]

  @type t :: %CensysEx.Search{
          query: String.t(),
          per_page: integer(),
          index: String.t(),
          cursor: String.t(),
          results: map(),
          page: integer()
        }

  def start(index, query \\ "", per_page \\ 100),
    do:
      build(index, query, per_page)
      |> search()

  @spec build(String.t(), String.t(), integer()) :: t()
  defp build(index, query, per_page),
    do: %CensysEx.Search{
      index: index,
      query: query,
      per_page: per_page
    }

  defp search(%CensysEx.Search{} = client),
    do:
      Stream.resource(
        fn -> client end,
        fn resource -> stream_next(resource) end,
        fn _ -> :ok end
      )
      |> Stream.flat_map(& &1)

  defp stream_next(resource) do
    acc = search_internal!(resource)

    case {acc.cursor, acc.results, acc.page} do
      {cursor, _, page} when cursor != "" or page == 1 -> {[get_hits(acc)], acc}
      {"", _, _} -> {:halt, acc}
      {_, %{}, _} -> {:halt, acc}
    end
  end

  @spec get_hits(t()) :: list(map())
  defp get_hits(%CensysEx.Search{} = client),
    do: Map.get(Map.get(client.results, "result", %{}), "hits", [])

  defp iterate_client(%CensysEx.Search{} = client, body \\ %{}, cursor \\ ""),
    do: %{client | results: body, cursor: cursor, page: client.page + 1}

  @spec search_internal!(t()) :: t()
  defp search_internal!(%CensysEx.Search{} = client) do
    opts =
      case client.cursor do
        "" -> [q: client.query, per_page: client.per_page]
        cursor -> [q: client.query, per_page: client.per_page, cursor: cursor]
      end

    if client.page > 0 and client.cursor == "" do
      iterate_client(client)
    else
      case CensysEx.Util.get_client().get(client.index, "search", [], params: opts) do
        {:ok, body} ->
          %{"result" => %{"links" => %{"next" => next_cursor}}} = body
          iterate_client(client, body, next_cursor)

        {:error, err} ->
          raise CensysEx.Exception, message: "CensysEx: " <> err
      end
    end
  end
end
