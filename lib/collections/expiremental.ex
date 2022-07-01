defmodule CensysEx.Experimental do
  @moduledoc """
  CensysEx wrapper for the search.censys.io v2 "experimental" APIs.
  *_NOTE_*: these APIs are subject to change in the future and CensysEx may get out of sync with Censys
  """

  alias CensysEx.{Paginate, Util}

  @doc """
  Hits the Experimental Censys host events API

    - API docs: https://search.censys.io/api#/experimental/viewHostEvents

  ## Examples

  ```
  CensysEx.Experimental.host_events("127.0.0.1")
  |> Stream.take(25)
  |> Stream.map(&Map.get(&1, "_event"))
  |> Enum.to_list()
  ["service_observed", "location_updated", ...]
  ```
  """
  @spec host_events(String.t(), integer(), boolean(), DateTime.t() | nil, DateTime.t() | nil) ::
          CensysEx.result_stream(map())
  def host_events(ip, per_page \\ 50, reversed \\ false, start_time \\ nil, end_time \\ nil) do
    next = fn params -> CensysEx.API.get("experimental", "hosts/#{ip}/events", [], params) end
    extractor = fn client = %Paginate{} -> get_in(client.results, ["result", "events"]) end

    Paginate.stream(next, extractor, Util.build_experimental_get_host_events(per_page, reversed, start_time, end_time))
  end
end
