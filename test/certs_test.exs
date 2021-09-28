defmodule CensysExCertsTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  @fp "fb444eb8e68437bae06232b9f5091bccff62a768ca09e92eb5c9c2cf9d17c426"
  @get_hosts_path @fp <> "/hosts"
  @cursor "AS-RtkeohWDBa9T6Jxztjot4qtflR5ZptVeEQ_uZWlhUlNcRvFvGZ4Wxj1iUMFy5qd6boAT0kA=="

  # view certs
  test "view cert" do
    CensysEx.ApiMock
    |> expect(:get_v1, fn "certificates/" <> @fp, "view", [], [] ->
      CensysEx.TestHelpers.load_response("certificate-view", 200)
    end)

    {:ok, resp} = CensysEx.Certs.view(@fp)

    assert get_in(resp, ["parent_spki_subject_fingerprint"]) ==
             "5ca030abfa05e5f26bee0f21774984145f8ddac6e4b5c0da590f537b3fd22367"

    assert get_in(resp, ["parsed", "serial_number"]) == "6684745550388409480013519646680411219"
  end

  # hosts showing certs
  test "can get hosts for a cert" do
    CensysEx.ApiMock
    |> expect(:get, 1, fn "certificates", @get_hosts_path, [], params: [] ->
      CensysEx.TestHelpers.load_response("certificate-hosts")
    end)
    |> expect(:get, 1, fn "certificates", @get_hosts_path, [], params: [cursor: @cursor] ->
      CensysEx.TestHelpers.load_response("certificate-hosts")
    end)

    hits =
      CensysEx.Certs.get_hosts_by_cert(@fp)
      |> Stream.take(150)
      |> Enum.to_list()

    assert length(hits) == 150
  end

  test "can get hosts for a cert: cutoff" do
    CensysEx.ApiMock
    |> expect(:get, 1, fn "certificates", @get_hosts_path, [], params: [] ->
      CensysEx.TestHelpers.load_response("certificate-hosts")
    end)

    hits =
      CensysEx.Certs.get_hosts_by_cert(@fp)
      |> Stream.take(10)
      |> Enum.to_list()

    assert length(hits) == 10
  end
end
