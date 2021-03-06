defmodule CensysExUtilTest do
  use ExUnit.Case, async: true

  alias CensysEx.Util

  test "parse body: Success",
    do: assert(Util.parse_body(~s({"code": 200}), 200) == {:ok, %{"code" => 200}})

  test "parse body: Known Error",
    do:
      assert(
        Util.parse_body(~s({"code": 400, "error": "some error"}), 400) ==
          {:error, "some error"}
      )

  test "parse body: Unauthorized",
    do:
      assert(
        Util.parse_body(
          ~s({"code": 401, "status": "Unauthorized", "error": "You must authenticate with a valid API ID and secret."}),
          401
        ) ==
          {:error, "You must authenticate with a valid API ID and secret."}
      )

  test "parse body: Unknown error",
    do: assert(Util.parse_body(~s({"code": 400}), 400) == {:error, "Unknown Error occurred with status code: 400"})

  test "parse body: Invalid body",
    do:
      assert(
        Util.parse_body("I'M NOT JSON", 400) ==
          {:error, "Invalid API response. Failed to parse JSON response: unexpected byte at position 0: 0x49 (\"I\")"}
      )

  test "test build_view_params: Empty", do: assert(Util.build_view_params(nil) == [])

  test "test build_view_params: At Time",
    do:
      assert(
        Util.build_view_params(~U[2021-06-07 12:53:27.450073Z]) == [
          at_time: "2021-06-07T12:53:27"
        ]
      )

  test "test build_aggregate_params: No Query",
    do:
      assert(
        Util.build_aggregate_params("some_field", nil, 20) == [
          field: "some_field",
          num_buckets: 20
        ]
      )

  test "test build_aggregate_params: With Query",
    do:
      assert(
        Util.build_aggregate_params("some_field", "some_query", 20) == [
          q: "some_query",
          field: "some_field",
          num_buckets: 20
        ]
      )

  test "test build_diff_params: same ip",
    do: assert(Util.build_diff_params(nil, nil, nil) == [])

  test "test build_diff_params: diff ip",
    do: assert(Util.build_diff_params("1.1.1.1", nil, nil) == [ip_b: "1.1.1.1"])

  test "test build_diff_params: at_time",
    do:
      assert(
        Util.build_diff_params(nil, ~U[2021-08-27 12:53:27.450073Z], nil) == [
          at_time: "2021-08-27T12:53:27"
        ]
      )

  test "test build_diff_params: diff ips in the past",
    do:
      assert(
        Util.build_diff_params(
          "1.1.1.1",
          ~U[2021-08-27 12:53:27.450073Z],
          ~U[2021-08-26 12:53:27.450073Z]
        ) == [
          ip_b: "1.1.1.1",
          at_time: "2021-08-27T12:53:27",
          at_time_b: "2021-08-26T12:53:27"
        ]
      )

  test "test build_experimental_get_host_events",
    do:
      assert(
        Util.build_experimental_get_host_events(
          56,
          true,
          ~U[2021-08-27 12:53:27.450073Z],
          ~U[2021-08-26 12:53:27.450073Z]
        ) == [
          per_page: 56,
          reversed: true,
          start_time: "2021-08-27T12:53:27",
          end_time: "2021-08-26T12:53:27"
        ]
      )
end
