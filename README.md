# CensysEx
Tiny Elixir ⚗️ wrapper for the Censys Search 2.0 [API](https://search.censys.io/api) 

[![](https://github.com/bwireman/censys_ex/actions/workflows/elixir.yml/badge.svg?branch=main)](https://github.com/bwireman/censys_ex/actions/workflows/elixir.yml)
[![](https://img.shields.io/github/license/bwireman/censys_ex?color=brightgreen)](https://github.com/bwireman/censys_ex/blob/main/LICENSE)
[![](https://img.shields.io/github/last-commit/bwireman/censys_ex)](https://github.com/bwireman/censys_ex/commit/main)
[![](https://img.shields.io/hexpm/v/censys_ex?color=brightgreen&style=flat)](https://hexdocs.pm/censys_ex/readme.html)
[![](https://img.shields.io/hexpm/dt/censys_ex?color=brightgreen)](https://hex.pm/packages/censys_ex/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen)](http://makeapullrequest.com)
![](https://img.shields.io/badge/Sick-as%20hell%20%F0%9F%A4%98-red)

_**Note**_: this is **_NOT_** an official Censys library, and is not supported by or affiliated with Censys at this time. I do not own Censys Trademarks or Copyrights

## Installation

Available in [Hex](https://hex.pm/packages/censys_ex), the package can be installed by adding `censys_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:censys_ex, "~> 0.2.0"}
  ]
end
```

# Setup
via environment variables
```bash
$ export CENSYS_API_ID="*****"
$ export CENSYS_API_SECRET="*****"
```

```elixir
iex(1)> CensysEx.API.start_link()
{:ok, #PID<0.253.0>}
```
or directly
```elixir
iex(1)> CensysEx.API.start_link("*****", "*****")
{:ok, #PID<0.252.0>}
```
API secrets can be found [here](https://search.censys.io/account/api)


# View

View all the data on an IP at a given time. 

```elixir
CensysEx.Hosts.view("127.0.0.1")

# Lookup the host as it was at a certain time
CensysEx.Hosts.view("127.0.0.1", ~U[2021-06-07 12:53:27.450073Z])
```

# Names

Returns a stream of names for that IP.

```elixir
iex(1)> CensysEx.Hosts.names("127.0.0.1") |>
...(1)> Stream.take(25) |>
...(1)> Enum.to_list()
["example.com", "foo.net", ...]
```

# Search
Search returns a stream of results using the cursors provided by the API.

```elixir
iex(1)>  CensysEx.Hosts.search("same_service(service_name: SSH and not port: 22)") |>
...(1)> Stream.take(25) |>
...(1)> Stream.map(&Map.get(&1, "ip")) |>
...(1)> Enum.to_list()
["10.0.0.6", "10.2.0.1", ...]
```

# Aggregate

Aggregate data about hosts on the internet.

```elixir
CensysEx.Hosts.aggregate("location.country_code", "services.service_name: MEMCACHED")

CensysEx.Hosts.aggregate("location.country_code", "services.service_name: MEMCACHED", 10)
```
---
## Docs
- [view](https://search.censys.io/api#/hosts/viewHost)
- [names](https://search.censys.io/api#/hosts/viewHostNames)
- [aggregate](https://search.censys.io/api#/hosts/aggregateHosts)
- [search](https://search.censys.io/api#/hosts/searchHosts)
- [search-syntax](https://search.censys.io/search/language?resource=hosts)

## Other Languages

### Official
- [Node](https://github.com/censys/censys-node-js)
- [Python](https://github.com/censys/censys-python)

### Unofficial
- [Ruby](https://github.com/ninoseki/censysx/)