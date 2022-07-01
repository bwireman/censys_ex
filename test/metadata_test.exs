defmodule CensysExMetadataTest do
  use ExUnit.Case, async: true
  import Mimic

  setup :verify_on_exit!

  # hosts
  test "can get hosts metadata" do
    CensysEx.API
    |> expect(:get, fn "metadata", "hosts", [], [] ->
      CensysEx.TestHelpers.load_response("hosts-metadata")
    end)

    {:ok, resp} = CensysEx.Metadata.hosts_metadata()
    services = get_in(resp, ["result", "services"])
    assert is_list(services)
  end
end
