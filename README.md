# CensysEx

Tiny Elixir ⚗️ wrapper for the Censys Search 2.0 [API](https://search.censys.io/api)

[![ci](https://github.com/bwireman/censys_ex/actions/workflows/elixir.yml/badge.svg?branch=main)](https://github.com/bwireman/censys_ex/actions/workflows/elixir.yml)
[![mit](https://img.shields.io/github/license/bwireman/censys_ex?color=brightgreen)](https://github.com/bwireman/censys_ex/blob/main/LICENSE)
[![commits](https://img.shields.io/github/last-commit/bwireman/censys_ex)](https://github.com/bwireman/censys_ex/commit/main)
[![2.0.1](https://img.shields.io/hexpm/v/censys_ex?color=brightgreen&style=flat)](https://hexdocs.pm/censys_ex/readme.html)
[![downloads](https://img.shields.io/hexpm/dt/censys_ex?color=brightgreen)](https://hex.pm/packages/censys_ex/)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen)](http://makeapullrequest.com)
![Sick as hell](https://img.shields.io/badge/Sick-as%20hell%20%F0%9F%A4%98-red)

_**Note**_: this is **_NOT_** an official Censys library, and is not supported by or affiliated with Censys at this time. I do not own Censys Trademarks or Copyrights

## Installation

Available in [Hex](https://hex.pm/packages/censys_ex), the package can be installed by adding `censys_ex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:censys_ex, "~> 2.0.1"}
  ]
end
```

## Setup

via Application variables

```elixir
config :censys_ex,
  api_id: "*****",
  api_key: "*****"

# ...

CensysEx.API.client()
```

or directly

```elixir
CensysEx.API.client("*****", "*****")
```

API secrets can be found [here](https://search.censys.io/account/api)

## Hosts

### View a host

View all the data on an IP at a given time.

```elixir
CensysEx.Hosts.view(client, "127.0.0.1")

# Lookup the host as it was at a certain time
CensysEx.Hosts.view(client, "127.0.0.1", ~U[2021-06-07 12:53:27.450073Z])
```

### Get host names

Returns a stream of names for that IP.

```elixir
iex(1)> CensysEx.Hosts.names(client, "127.0.0.1") |>
...(1)> Stream.take(25) |>
...(1)> Enum.to_list()
["example.com", "foo.net", ...]
```

### Search hosts

Search returns a stream of results using the cursors provided by the API.

```elixir
iex(1)> CensysEx.Hosts.search(client, "same_service(service_name: SSH and not port: 22)") |>
...(1)> Stream.take(25) |>
...(1)> Stream.map(&Map.get(&1, "ip")) |>
...(1)> Enum.to_list()
["10.0.0.6", "10.2.0.1", ...]
```

### Aggregate hosts

Aggregate data about hosts on the internet.

```elixir
CensysEx.Hosts.aggregate(client, "location.country_code", "services.service_name: MEMCACHED")

CensysEx.Hosts.aggregate(client, "location.country_code", "services.service_name: MEMCACHED", 10)
```

### Diff hosts

Diff hosts at given times

```elixir
# diff the current host with it self 🤷
CensysEx.Hosts.diff(client, "8.8.8.8")

# diff two hosts
CensysEx.Hosts.diff(client, "8.8.8.8", "1.1.1.1")

# diff a host with itself at a time in the past
CensysEx.Hosts.diff(client, "8.8.8.8", nil, ~U[2021-06-07 12:53:27.450073Z])

# diff two hosts in the past
CensysEx.Hosts.diff(client, "8.8.8.8", "8.8.4.4" ~U[2021-06-07 12:53:27.450073Z], ~U[2021-06-07 12:53:27.450073Z])
```

### Hosts API Docs

- [view](https://search.censys.io/api#/hosts/viewHost)
- [names](https://search.censys.io/api#/hosts/viewHostNames)
- [aggregate](https://search.censys.io/api#/hosts/aggregateHosts)
- [diff](https://search.censys.io/api#/hosts/viewHostDiff)
- [search](https://search.censys.io/api#/hosts/searchHosts)
- [search-syntax](https://search.censys.io/search/language?resource=hosts)

## Certs

### View a cert by fingerprint

```elixir
# NOTE this actually a V1 API
CensysEx.Certs.view(client, "fb444eb8e68437bae06232b9f5091bccff62a768ca09e92eb5c9c2cf9d17c426")
```

### Get hosts that present a cert

```elixir
CensysEx.Certs.get_hosts_by_cert(client, "fb444eb8e68437bae06232b9f5091bccff62a768ca09e92eb5c9c2cf9d17c426")
|> Stream.take(25)
|> Stream.map(&Map.get(&1, "ip"))
|> Enum.to_list()
["10.0.0.6", "10.2.0.1", ...]
```

### Certs API Docs

- [View](https://search.censys.io/api#/certificates/viewCertificate)
- [hosts](https://search.censys.io/api#/certs/getHostsByCert)

### Experimental

```elixir
CensysEx.Experimental.host_events(client, "127.0.0.1")
|> Stream.take(25)
|> Stream.map(&Map.get(&1, "_event"))
|> Enum.to_list()
["service_observed", "location_updated", ...]
```

### Experimental V2 API Docs

- [events](https://search.censys.io/api#/experimental/viewHostEvents)

## Metadata

```elixir
CensysEX.Metadata.host_metadata()
{:ok, %{
  "code": 200,
  "status": "OK",
  "result": {
    "services": [
      "HTTP",
      "IMAP",
      "MQTT",
      "SSH",
      "..."
    ]
  }
}}
```

### Metadata API Docs

- [hosts metadata](https://search.censys.io/api#/metadata/getHostMetadata)

---

## Other Languages

### Official

- [Node](https://github.com/censys/censys-node-js)
- [Python](https://github.com/censys/censys-python)

### Unofficial

- [Ruby](https://github.com/ninoseki/censysx/)
