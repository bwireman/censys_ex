defmodule CensysExUtilTest do
  use ExUnit.Case, async: true

  # this is kind of a dumb test but...
  test "get_client" do
    assert CensysEx.Util.get_client() == CensysEx.ApiMock
  end

  test "parse body: Success",
    do: assert(CensysEx.Util.parse_body(~s({"code": 200})) == {:ok, %{"code" => 200}})

  test "parse body: Known Error",
    do:
      assert(
        CensysEx.Util.parse_body(~s({"code": 400, "error": "some error"})) ==
          {:error, "some error"}
      )

  test "parse body: Unauthorized",
    do:
      assert(
        CensysEx.Util.parse_body(
          ~s({"code": 401, "status": "Unauthorized", "error": "You must authenticate with a valid API ID and secret."})
        ) ==
          {:error, "You must authenticate with a valid API ID and secret."}
      )

  test "parse body: Unknown error",
    do: assert(CensysEx.Util.parse_body(~s({"code": 400})) == {:error, "Unknown Error occurred"})

  test "test build_view_params: Empty", do: assert(CensysEx.Util.build_view_params(nil) == [])

  test "test build_view_params: At Time",
    do:
      assert(
        CensysEx.Util.build_view_params(~U[2021-06-07 12:53:27.450073Z]) == [
          at_time: "2021-06-07T12:53:27"
        ]
      )

  test "test build_aggregate_params: No Query",
    do:
      assert(
        CensysEx.Util.build_aggregate_params("some_field", nil, 20) == [
          field: "some_field",
          num_buckets: 20
        ]
      )

  test "test build_aggregate_params: With Query",
    do:
      assert(
        CensysEx.Util.build_aggregate_params("some_field", "some_query", 20) == [
          q: "some_query",
          field: "some_field",
          num_buckets: 20
        ]
      )
end
