defmodule CensysExExperimentalTest do
  use ExUnit.Case, async: true
  import Mimic

  setup :verify_on_exit!

  @cursor "AS-RtkdTRUHZmiJoIbUXCmByfp5GDTnJrysJOelGDxWupIvXPZMzaCItyOiH7Xb9gGd08iAmuZS3ygcwxz0GuifzAD4AyUGjJ-bAb4XAar4YsRqJnjY2ByzdPB1rSaCvRx8O7nyWzbX-wyv3VyAg_PUDbg=="

  test "can get events for a host" do
    CensysEx.API
    |> expect(:get, 1, fn "experimental", "hosts/1.1.1.1/events", [], params: [per_page: 25, reversed: false] ->
      CensysEx.TestHelpers.load_response("1.1.1.1-events")
    end)
    |> expect(:get, 1, fn "experimental",
                          "hosts/1.1.1.1/events",
                          [],
                          params: [cursor: @cursor, per_page: 25, reversed: false] ->
      CensysEx.TestHelpers.load_response("1.1.1.1-events")
    end)

    hits =
      CensysEx.Experimental.host_events("1.1.1.1", 25)
      |> Stream.take(50)
      |> Enum.to_list()

    assert length(hits) == 50
  end

  test "can get events for a host: cutoff" do
    CensysEx.API
    |> expect(:get, 1, fn "experimental",
                          "hosts/1.1.1.1/events",
                          [],
                          params: [
                            per_page: 25,
                            reversed: true,
                            start_time: "2021-09-02T01:01:01",
                            end_time: "2021-09-03T01:01:01"
                          ] ->
      CensysEx.TestHelpers.load_response("1.1.1.1-events")
    end)

    hits =
      CensysEx.Experimental.host_events(
        "1.1.1.1",
        25,
        true,
        ~U[2021-09-02 01:01:01.123456Z],
        ~U[2021-09-03 01:01:01.123456Z]
      )
      |> Stream.take(10)
      |> Enum.to_list()

    assert length(hits) == 10
  end
end
