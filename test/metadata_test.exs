defmodule CensysEx.MetadataTest do
  use CensysEx.ClientCase
  import Mimic

  setup :verify_on_exit!

  # hosts
  test "can get hosts metadata", %{client: client} do
    CensysEx.API
    |> expect(:get, fn _, "metadata", "hosts", [] ->
      CensysEx.TestHelpers.load_response("hosts-metadata")
    end)

    {:ok, resp} = CensysEx.Metadata.hosts_metadata(client)
    services = get_in(resp, ["result", "services"])
    assert is_list(services)
  end
end
