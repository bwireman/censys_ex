defmodule CensysExHostTest do
  use ExUnit.Case, async: true
  doctest CensysEx.Hosts
  import Mox

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  # --- view ---
  test "can view hosts" do
    CensysEx.ApiMock
    |> expect(:view, fn _, _, _ -> CensysEx.TestHelpers.load_response("1.1.1.1") end)

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
    |> expect(:view, fn _, _, _ -> CensysEx.TestHelpers.load_response("1.1.1.1") end)

    {:ok, resp} = CensysEx.Hosts.view("1.1.1.1", ~U[2021-06-07 12:53:27.450073Z])

    res = resp["result"]
    services = res["services"]
    pairs = services |> Enum.map(fn service -> {service["service_name"], service["port"]} end)
    assert pairs == [{"DNS", 53}, {"HTTP", 80}, {"HTTP", 443}]
  end

  # --- aggregate ---
  test "can aggregate hosts" do
    CensysEx.ApiMock
    |> expect(:aggregate, fn _, _, _, _ -> CensysEx.TestHelpers.load_response("aggregate") end)

    {:ok, resp} = CensysEx.Hosts.aggregate("service.port")
    res = resp["result"]
    buckets = res["buckets"]
    assert length(buckets) == 200
  end

  # --- names ---
  test "can stream names on a host" do
    CensysEx.ApiMock
    |> expect(:get, 1, fn _, _, _, _ ->
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
    |> expect(:get, 2, fn _, _, _, _ ->
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
    |> expect(:get, 3, fn _, _, _, _ ->
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
    |> expect(:get, 1, fn _, _, _, _ ->
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
    |> expect(:get, 1, fn _, _, _, _ ->
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
    |> expect(:get, 1, fn _, _, _, _ ->
      CensysEx.TestHelpers.load_response("unauthorized")
    end)

    assert_raise CensysEx.Exception, fn ->
      CensysEx.Hosts.search("services.service_name: SIP")
      |> Stream.take(150)
      |> Enum.to_list()
    end
  end
end
