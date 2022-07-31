defmodule CensysEx.Hosts do
  @moduledoc """
  CensysEx wrapper for the search.censys.io v2 API for the "hosts" resource
  """
  alias CensysEx.{API, Paginate, Search, Util}

  @typedoc """
  Values that determine how to query Virtual Hosts. `:exclude` will ignore any virtual hosts
  entries, `:include` virtual hosts will be present in the returned list of hits, `:only` will
  return only virtual hosts
  """
  @type v_hosts :: :exclude | :include | :only

  @index "hosts"

  @doc """
  Hits the Censys Hosts search API. Returns a stream of results for your query

    - API docs: https://search.censys.io/api#/hosts/searchHosts
    - Syntax: https://search.censys.io/search/language?resource=hosts

  ## Examples

  ```
  CensysEx.Hosts.search("same_service(service_name: SSH and not port: 22)")
  |> Stream.take(25)
  |> Stream.map(&Map.get(&1, "ip"))
  |> Enum.to_list()
  ["10.0.0.6", "10.2.0.1", ...]
  ```
  """
  @spec search(API.t(), String.t(), integer(), v_hosts()) :: CensysEx.result_stream(map())
  def search(client, query \\ "", per_page \\ 100, virtual_hosts \\ :exclude),
    do: Search.search(client, @index, query, per_page, virtual_hosts: vhost_to_string(virtual_hosts))

  @doc """
  Hits the Censys Hosts view API. Returning full
  information about an IP at a given time

  - API docs: https://search.censys.io/api#/hosts/viewHost

  ## Examples

  ```
  CensysEx.Hosts.view("127.0.0.1")

  # View "127.0.0.1" at a certain time
  CensysEx.Hosts.view("127.0.0.1", ~U[2021-06-07 12:53:27.450073Z])
  ```
  """
  @spec view(API.t(), String.t(), DateTime.t() | nil) :: CensysEx.result()
  def view(client, ip, at_time \\ nil),
    do: CensysEx.API.view(client, @index, ip, at_time)

  @doc """
  Hits the Censys Hosts view names API. Returning a stream of names for that IP.

  - API docs: https://search.censys.io/api#/hosts/viewHostNames

  ## Examples

  ```
  CensysEx.Hosts.names("127.0.0.1")
  ```
  """
  @spec names(API.t(), String.t()) :: CensysEx.result_stream(String.t())
  def names(client, ip) do
    next = fn client, params -> CensysEx.API.get(client, @index, ip <> "/names", params) end
    extractor = fn client = %Paginate{} -> get_in(client.results, ["result", "names"]) end

    Paginate.stream(client, next, extractor)
  end

  @doc """
  Hits the Censys Hosts diff API.

  - API docs: https://search.censys.io/api#/hosts/viewHostDiff

  ## Examples

  ```
  # diff the current host with it self 🤷
  CensysEx.Hosts.diff("8.8.8.8")

  # diff two hosts
  CensysEx.Hosts.diff("8.8.8.8", "1.1.1.1")

  # diff a host with itself at a time in the past
  CensysEx.Hosts.diff("8.8.8.8", nil, ~U[2021-06-07 12:53:27.450073Z])

  # diff two hosts in the past
  CensysEx.Hosts.diff("8.8.8.8", "8.8.4.4" ~U[2021-06-07 12:53:27.450073Z], ~U[2021-06-07 12:53:27.450073Z])
  ```
  """
  @spec diff(API.t(), String.t(), String.t() | nil, DateTime.t() | nil, DateTime.t() | nil) ::
          CensysEx.result()
  def diff(client, ip, ip_b \\ nil, at_time \\ nil, at_time_b \\ nil),
    do: CensysEx.API.get(client, @index, ip <> "/diff", params: Util.build_diff_params(ip_b, at_time, at_time_b))

  @doc """
  Hits the Censys Hosts aggregate API. Optionally control number of buckets returned

  - API docs: https://search.censys.io/api#/hosts/aggregateHosts

  ## Examples

  ```
  CensysEx.Hosts.aggregate("location.country_code", "services.service_name: MEMCACHED")

  CensysEx.Hosts.aggregate("location.country_code", "services.service_name: MEMCACHED", 1000)
  ```
  """
  @spec aggregate(API.t(), String.t(), String.t() | nil, integer(), v_hosts()) :: CensysEx.result()
  def aggregate(client, field, query \\ nil, num_buckets \\ 50, virtual_hosts \\ :exclude),
    do: CensysEx.API.aggregate(client, @index, field, query, num_buckets, virtual_hosts: vhost_to_string(virtual_hosts))

  @spec vhost_to_string(v_hosts) :: String.t()
  defp vhost_to_string(v_host) do
    case v_host do
      :include -> "INCLUDE"
      :only -> "ONLY"
      _ -> "EXCLUDE"
    end
  end
end
