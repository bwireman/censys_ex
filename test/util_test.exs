defmodule CensysEx.UtilTest do
  use CensysEx.ClientCase
  alias CensysEx.Util

  describe "parse body" do
    test "Success",
      do: assert(Util.parse_body(~s({"code": 200}) |> Jason.decode!(), 200) == {:ok, %{"code" => 200}})

    test "Known Error",
      do:
        assert(
          Util.parse_body(~s({"code": 400, "error": "some error"}) |> Jason.decode!(), 400) ==
            {:error, "some error"}
        )

    test "Unauthorized",
      do:
        assert(
          Util.parse_body(
            ~s({"code": 401, "status": "Unauthorized", "error": "You must authenticate with a valid API ID and secret."})
            |> Jason.decode!(),
            401
          ) ==
            {:error, "You must authenticate with a valid API ID and secret."}
        )

    test "Unknown error",
      do:
        assert(
          Util.parse_body(~s({"code": 400}) |> Jason.decode!(), 400) ==
            {:error, "Unknown Error occurred with status code: 400"}
        )
  end

  describe "build_view_params" do
    test "Empty", do: assert(Util.build_view_params(nil) == [])

    test "At Time",
      do:
        assert(
          Util.build_view_params(~U[2021-06-07 12:53:27.450073Z]) == [
            at_time: "2021-06-07T12:53:27"
          ]
        )
  end

  describe "build_aggregate_params" do
    test "No Query",
      do:
        assert(
          Util.build_aggregate_params("some_field", nil, 20) == [
            field: "some_field",
            num_buckets: 20
          ]
        )

    test "With Query",
      do:
        assert(
          Util.build_aggregate_params("some_field", "some_query", 20) == [
            q: "some_query",
            field: "some_field",
            num_buckets: 20
          ]
        )
  end

  describe "build_diff_params" do
    test "same ip",
      do: assert(Util.build_diff_params(nil, nil, nil) == [])

    test "diff ip",
      do: assert(Util.build_diff_params("1.1.1.1", nil, nil) == [ip_b: "1.1.1.1"])

    test "at_time",
      do:
        assert(
          Util.build_diff_params(nil, ~U[2021-08-27 12:53:27.450073Z], nil) == [
            at_time: "2021-08-27T12:53:27"
          ]
        )

    test "diff ips in the past",
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
  end

  describe "build_experimental_get_host_events" do
    test "",
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
end
