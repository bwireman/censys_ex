defmodule CensysExCertsTest do
  use ExUnit.Case, async: true
  import Mox

  setup :verify_on_exit!

  @fp "fb444eb8e68437bae06232b9f5091bccff62a768ca09e92eb5c9c2cf9d17c426"
  @path @fp <> "/hosts"
  @cursor "AS-RtkeohWDBa9T6Jxztjot4qtflR5ZptVeEQ_uZWlhUlNcRvFvGZ4Wxj1iUMFy5qd6boAT0kA=="

  # hosts showing certs
  test "can get hosts for a cert" do
    CensysEx.ApiMock
    |> expect(:get, 1, fn "certificates", @path, [], params: [] ->
      CensysEx.TestHelpers.load_response("certificate-hosts")
    end)
    |> expect(:get, 1, fn "certificates", @path, [], params: [cursor: @cursor] ->
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
    |> expect(:get, 1, fn "certificates", @path, [], params: [] ->
      CensysEx.TestHelpers.load_response("certificate-hosts")
    end)

    hits =
      CensysEx.Certs.get_hosts_by_cert(@fp)
      |> Stream.take(10)
      |> Enum.to_list()

    assert length(hits) == 10
  end
end
