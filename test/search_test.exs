defmodule CensysEx.SearchTest do
  use CensysEx.ClientCase

  test "rejects invalid indices", %{client: client} do
    assert_raise CensysEx.Exception, fn ->
      CensysEx.Search.search(client, "blah")
    end
  end
end
