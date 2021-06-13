defmodule CensysEx.Hosts do
  @moduledoc """
  CensysEx wrapper for the search.censys.io v2 API for the "hosts" resource
  """

  @index "hosts"

  @doc """
  Hits the Censys Hosts search API. Returns a stream of results for you query

    - API docs: https://search.censys.io/api/docs/v2/search

  ## Examples

  ```
  CensysEx.Hosts.search("services.service_name: HTTP")
  |> Stream.take(500)
  |> Enum.to_list()
  ```
  """
  def search(query \\ "", per_page \\ 100),
    do:
      CensysEx.Search.build(@index, query, per_page)
      |> CensysEx.Search.search()

  @doc """
  Hits the Censys Hosts view API. Returning full
  information about an IP at a given time

  - API docs: https://search.censys.io/api/docs/v2/hosts/view

  ## Examples

  ```
  CensysEx.Hosts.view("127.0.0.1")

  CensysEx.Hosts.view("127.0.0.1", ~U[2021-06-07 12:53:27.450073Z])
  ```
  """
  @spec view(String.t(), DateTime.t()) :: {:error, any()} | {:ok, map()}
  def view(ip, at_time \\ nil),
    do: CensysEx.Util.get_client().view(@index, ip, at_time)

  @doc """
  Hits the Censys Hosts aggregate API. Optionally control number of buckets returned

  - API docs: https://search.censys.io/api/docs/v2/hosts/aggregate

  ## Examples

  ```
  CensysEx.Hosts.aggregate("location.country_code", "services.service_name: MEMCACHED")

  CensysEx.Hosts.aggregate("location.country_code", "services.service_name: MEMCACHED", 1000)
  ```
  """
  @spec aggregate(String.t(), String.t(), integer()) :: {:error, any()} | {:ok, map()}
  def aggregate(field, query \\ nil, num_buckets \\ 50),
    do: CensysEx.Util.get_client().aggregate(@index, field, query, num_buckets)
end
