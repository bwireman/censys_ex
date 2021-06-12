defmodule CensysEx.Search do
  @moduledoc false

  # Client for Censys Search 2.0 APIs
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

  @spec build(String.t(), String.t(), integer()) :: t()
  def build(index, query \\ "", per_page \\ 100) do
    %CensysEx.Search{
      index: index,
      query: query,
      per_page: per_page
    }
  end

  def search(%CensysEx.Search{} = client) do
    stream(client) |> Stream.flat_map(& &1)
  end

  defp stream(%CensysEx.Search{} = client) do
    Stream.resource(
      fn -> client end,
      fn resource -> stream_next(resource) end,
      fn _ -> :ok end
    )
  end

  defp stream_next(resource) do
    case search_internal(resource) do
      {:ok, acc} ->
        # if acc.cursor != "" do
        # {[get_hits(acc)], acc}
        # else
        # {:halt, acc}
        # end

        case {acc.cursor, acc.results, acc.page} do
          {cursor, _, page} when cursor != "" or page == 1 -> {[get_hits(acc)], acc}
          {"", _, _} -> {:halt, acc}
          {_, %{}, _} -> {:halt, acc}
        end

      error ->
        {:halt, error}
    end
  end

  @spec get_hits(t()) :: list(map())
  defp get_hits(%CensysEx.Search{} = client),
    do: Map.get(Map.get(client.results, "result", %{}), "hits", [])

  defp iterate_client(%CensysEx.Search{} = client, body \\ %{}, cursor \\ ""),
    do: %{client | results: body, cursor: cursor, page: client.page + 1}

  @spec search_internal(t()) :: {:ok, t()} | {:error, any()}
  defp search_internal(%CensysEx.Search{} = client) do
    opts =
      case client.cursor do
        "" -> [q: client.query, per_page: client.per_page]
        cursor -> [q: client.query, per_page: client.per_page, cursor: cursor]
      end

    if client.page > 0 and client.cursor == "" do
      {:ok, iterate_client(client)}
    else
      case CensysEx.Util.get_client().get(client.index, "search", [], params: opts) do
        {:ok, body} ->
          %{"result" => %{"links" => %{"next" => next_cursor}}} = body
          {:ok, iterate_client(client, body, next_cursor)}

        {:error, err} ->
          raise CensysEx.Exception, message: "CensysEx: " <> err
      end
    end
  end
end
