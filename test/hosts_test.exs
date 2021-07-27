defmodule CensysExHostTest do
  use ExUnit.Case, async: true
  doctest CensysEx.Hosts
  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  # --- view ---
  test "can view hosts" do
    CensysEx.ApiMock
    |> expect(:view, fn "hosts", "1.1.1.1", nil ->
      CensysEx.TestHelpers.load_response("1.1.1.1")
    end)

    {:ok, resp} = CensysEx.Hosts.view("1.1.1.1")

    assert Map.get(resp, "code") == 200
    assert Map.get(resp, "status") == "OK"

    res = resp["result"]
    assert Map.has_key?(res, "services")

    services = res["services"]
    assert length(services) == 3

    pairs = services |> Enum.map(fn service -> {service["service_name"], service["port"]} end)
    assert pairs == [{"DNS", 53}, {"HTTP", 80}, {"HTTP", 443}]
  end

  test "can view hosts at a time in the past" do
    CensysEx.ApiMock
    |> expect(:view, fn "hosts", "1.1.1.1", ~U[2021-06-07 12:53:27.450073Z] ->
      CensysEx.TestHelpers.load_response("1.1.1.1")
    end)

    {:ok, resp} = CensysEx.Hosts.view("1.1.1.1", ~U[2021-06-07 12:53:27.450073Z])

    res = resp["result"]
    services = res["services"]
    pairs = services |> Enum.map(fn service -> {service["service_name"], service["port"]} end)
    assert pairs == [{"DNS", 53}, {"HTTP", 80}, {"HTTP", 443}]
  end

  # --- aggregate ---
  test "can aggregate hosts" do
    CensysEx.ApiMock
    |> expect(:aggregate, fn "hosts", "service.port", nil, 50 ->
      CensysEx.TestHelpers.load_response("aggregate")
    end)

    {:ok, resp} = CensysEx.Hosts.aggregate("service.port")
    res = resp["result"]
    buckets = res["buckets"]
    assert length(buckets) == 200
  end

  # --- diff ---
  test "can diff hosts" do
    CensysEx.ApiMock
    |> expect(:get, fn "hosts", "8.8.8.8/diff", [], [params: [ip_b: "1.1.1.1"]] ->
      CensysEx.TestHelpers.load_response("diff-8.8.8.8-1.1.1.1")
    end)

    {:ok, resp} = CensysEx.Hosts.diff("8.8.8.8", "1.1.1.1")
    res = resp["result"]

    a = res["a"]
    assert a["ip"] == "8.8.8.8"
    assert a["last_updated_at"] == "2021-07-27T21:42:04.410Z"

    b = res["b"]
    assert b["ip"] == "1.1.1.1"
    assert b["last_updated_at"] == "2021-07-27T22:00:41.524Z"

    patch = res["patch"]
    assert is_list(patch)
  end

  test "can diff hosts at times" do
    CensysEx.ApiMock
    |> expect(:get, fn "hosts", "8.8.8.8/diff", [], [params: [at_time: "2021-08-27T12:53:27"]] ->
      # doesn't matter testing params
      CensysEx.TestHelpers.load_response("diff-8.8.8.8-1.1.1.1")
    end)

    assert {:ok, _} = CensysEx.Hosts.diff("8.8.8.8", nil, ~U[2021-08-27 12:53:27.450073Z])
  end

  # --- names ---
  test "can stream names on a host" do
    CensysEx.ApiMock
    |> expect(:get, 1, fn "hosts", "1.1.1.1/names", [], params: [] ->
      CensysEx.TestHelpers.load_response("1.1.1.1-names")
    end)

    hits =
      CensysEx.Hosts.names("1.1.1.1")
      |> Stream.take(100)
      |> Enum.to_list()

    assert length(hits) == 100
  end

  test "can stream names on a host getting multiple pages" do
    CensysEx.ApiMock
    |> expect(:get, 1, fn "hosts", "1.1.1.1/names", [], params: [] ->
      CensysEx.TestHelpers.load_response("1.1.1.1-names")
    end)
    |> expect(:get, 1, fn "hosts", "1.1.1.1/names", [], params: [cursor: "deadbeef"] ->
      CensysEx.TestHelpers.load_response("1.1.1.1-names")
    end)

    hits =
      CensysEx.Hosts.names("1.1.1.1")
      |> Stream.take(150)
      |> Enum.to_list()

    assert length(hits) == 150
  end

  # --- search ---
  test "can stream search results" do
    CensysEx.ApiMock
    |> expect(:get, 1, fn "hosts", "search", [], params: [q: "services.service_name: HTTP", per_page: 100] ->
      CensysEx.TestHelpers.load_response("search")
    end)
    |> expect(:get, 2, fn "hosts",
                          "search",
                          [],
                          params: [
                            cursor: "eyJBZnRlciI6WyIxOC4zNDg4ODMiLCIxNDcuNzguNjAuNDUiXSwiUmV2ZXJzZSI6ZmFsc2V9",
                            q: "services.service_name: HTTP",
                            per_page: 100
                          ] ->
      CensysEx.TestHelpers.load_response("search")
    end)

    hits =
      CensysEx.Hosts.search("services.service_name: HTTP")
      |> Stream.take(150)
      |> Enum.to_list()

    assert length(hits) == 150
  end

  test "can end early if no next in stream of search results" do
    CensysEx.ApiMock
    |> expect(:get, 1, fn "hosts", "search", [], params: [q: "services.service_name: SIP", per_page: 100] ->
      CensysEx.TestHelpers.load_response("search-cutoff")
    end)

    hits =
      CensysEx.Hosts.search("services.service_name: SIP")
      |> Stream.take(150)
      |> Enum.to_list()

    assert length(hits) == 1
  end

  test "can end early if take less than total in stream of search results" do
    CensysEx.ApiMock
    |> expect(:get, 1, fn "hosts", "search", [], params: [q: "services.service_name: SIP", per_page: 100] ->
      CensysEx.TestHelpers.load_response("search")
    end)

    hits =
      CensysEx.Hosts.search("services.service_name: SIP")
      |> Stream.take(20)
      |> Enum.to_list()

    assert length(hits) == 20
  end

  test "search raises when unauthorized" do
    CensysEx.ApiMock
    |> expect(:get, 1, fn "hosts", "search", [], params: [q: "services.service_name: SIP", per_page: 100] ->
      CensysEx.TestHelpers.load_response("unauthorized")
    end)

    assert_raise CensysEx.Exception, fn ->
      CensysEx.Hosts.search("services.service_name: SIP")
      |> Stream.take(150)
      |> Enum.to_list()
    end
  end
end
