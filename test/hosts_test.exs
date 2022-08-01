defmodule CensysEx.HostTest do
  use CensysEx.ClientCase
  doctest CensysEx.Hosts
  import Mimic

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  # --- view ---
  test "can view hosts", %{client: client} do
    CensysEx.API
    |> expect(:view, fn _, "hosts", "1.1.1.1", nil ->
      CensysEx.TestHelpers.load_response("1.1.1.1")
    end)

    {:ok, resp} = CensysEx.Hosts.view(client, "1.1.1.1")

    assert Map.get(resp, "code") == 200
    assert Map.get(resp, "status") == "OK"

    res = resp["result"]
    assert Map.has_key?(res, "services")

    services = res["services"]
    assert length(services) == 3

    pairs = services |> Enum.map(fn service -> {service["service_name"], service["port"]} end)
    assert pairs == [{"DNS", 53}, {"HTTP", 80}, {"HTTP", 443}]
  end

  test "can view hosts at a time in the past", %{client: client} do
    CensysEx.API
    |> expect(:view, fn _, "hosts", "1.1.1.1", ~U[2021-06-07 12:53:27.450073Z] ->
      CensysEx.TestHelpers.load_response("1.1.1.1")
    end)

    {:ok, resp} = CensysEx.Hosts.view(client, "1.1.1.1", ~U[2021-06-07 12:53:27.450073Z])

    res = resp["result"]
    services = res["services"]
    pairs = services |> Enum.map(fn service -> {service["service_name"], service["port"]} end)
    assert pairs == [{"DNS", 53}, {"HTTP", 80}, {"HTTP", 443}]
  end

  # --- aggregate ---
  test "can aggregate hosts", %{client: client} do
    CensysEx.API
    |> expect(:aggregate, fn _, "hosts", "service.port", nil, 50, [virtual_hosts: "EXCLUDE"] ->
      CensysEx.TestHelpers.load_response("aggregate")
    end)

    {:ok, resp} = CensysEx.Hosts.aggregate(client, "service.port")
    res = resp["result"]
    buckets = res["buckets"]
    assert length(buckets) == 200
  end

  # --- diff ---
  test "can diff hosts", %{client: client} do
    CensysEx.API
    |> expect(:get, fn _, "hosts", "8.8.8.8/diff", [params: [ip_b: "1.1.1.1"]] ->
      CensysEx.TestHelpers.load_response("diff-8.8.8.8-1.1.1.1")
    end)

    {:ok, resp} = CensysEx.Hosts.diff(client, "8.8.8.8", "1.1.1.1")
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

  test "can diff hosts at times", %{client: client} do
    CensysEx.API
    |> expect(:get, fn _, "hosts", "8.8.8.8/diff", [params: [at_time: "2021-08-27T12:53:27"]] ->
      # doesn't matter testing params
      CensysEx.TestHelpers.load_response("diff-8.8.8.8-1.1.1.1")
    end)

    assert {:ok, _} = CensysEx.Hosts.diff(client, "8.8.8.8", nil, ~U[2021-08-27 12:53:27.450073Z])
  end

  # --- names ---
  test "can stream names on a host", %{client: client} do
    CensysEx.API
    |> expect(:get, 1, fn _, "hosts", "1.1.1.1/names", params: [] ->
      CensysEx.TestHelpers.load_response("1.1.1.1-names")
    end)

    hits =
      CensysEx.Hosts.names(client, "1.1.1.1")
      |> Stream.take(100)
      |> Enum.to_list()

    assert length(hits) == 100
  end

  test "can stream names on a host getting multiple pages", %{client: client} do
    CensysEx.API
    |> expect(:get, 1, fn _, "hosts", "1.1.1.1/names", params: [] ->
      CensysEx.TestHelpers.load_response("1.1.1.1-names")
    end)
    |> expect(:get, 1, fn _, "hosts", "1.1.1.1/names", params: [cursor: "deadbeef"] ->
      CensysEx.TestHelpers.load_response("1.1.1.1-names")
    end)

    hits =
      CensysEx.Hosts.names(client, "1.1.1.1")
      |> Stream.take(150)
      |> Enum.to_list()

    assert length(hits) == 150
  end

  # --- search ---
  test "can stream search results", %{client: client} do
    CensysEx.API
    |> expect(:get, 1, fn _,
                          "hosts",
                          "search",
                          params: [q: "services.service_name: HTTP", per_page: 100, virtual_hosts: "EXCLUDE"] ->
      CensysEx.TestHelpers.load_response("search")
    end)
    |> expect(:get, 2, fn _,
                          "hosts",
                          "search",
                          params: [
                            cursor: "eyJBZnRlciI6WyIxOC4zNDg4ODMiLCIxNDcuNzguNjAuNDUiXSwiUmV2ZXJzZSI6ZmFsc2V9",
                            q: "services.service_name: HTTP",
                            per_page: 100,
                            virtual_hosts: "EXCLUDE"
                          ] ->
      CensysEx.TestHelpers.load_response("search")
    end)

    hits =
      CensysEx.Hosts.search(client, "services.service_name: HTTP")
      |> Stream.take(150)
      |> Enum.to_list()

    assert length(hits) == 150
  end

  test "can end early if no next in stream of search results", %{client: client} do
    CensysEx.API
    |> expect(:get, 1, fn _,
                          "hosts",
                          "search",
                          params: [q: "services.service_name: SIP", per_page: 100, virtual_hosts: "EXCLUDE"] ->
      CensysEx.TestHelpers.load_response("search-cutoff")
    end)

    hits =
      CensysEx.Hosts.search(client, "services.service_name: SIP")
      |> Stream.take(150)
      |> Enum.to_list()

    assert length(hits) == 1
  end

  test "can end early if take less than total in stream of search results", %{client: client} do
    CensysEx.API
    |> expect(:get, 1, fn _,
                          "hosts",
                          "search",
                          params: [q: "services.service_name: SIP", per_page: 100, virtual_hosts: "EXCLUDE"] ->
      CensysEx.TestHelpers.load_response("search")
    end)

    hits =
      CensysEx.Hosts.search(client, "services.service_name: SIP")
      |> Stream.take(20)
      |> Enum.to_list()

    assert length(hits) == 20
  end

  test "search raises when unauthorized", %{client: client} do
    CensysEx.API
    |> expect(:get, 1, fn _,
                          "hosts",
                          "search",
                          params: [q: "services.service_name: SIP", per_page: 100, virtual_hosts: "EXCLUDE"] ->
      CensysEx.TestHelpers.load_response("unauthorized")
    end)

    assert_raise CensysEx.Exception, fn ->
      CensysEx.Hosts.search(client, "services.service_name: SIP")
      |> Stream.take(150)
      |> Enum.to_list()
    end
  end

  test "can specify vhosts in search", %{client: client} do
    CensysEx.API
    |> expect(:get, 1, fn _,
                          "hosts",
                          "search",
                          params: [q: "services.service_name: SIP", per_page: 100, virtual_hosts: "INCLUDE"] ->
      CensysEx.TestHelpers.load_response("search")
    end)

    hits =
      CensysEx.Hosts.search(client, "services.service_name: SIP", 100, :include)
      |> Stream.take(20)
      |> Enum.to_list()

    assert length(hits) == 20
  end
end
