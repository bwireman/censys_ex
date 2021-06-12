# CensysEx

Tiny Elixir ⚗️ wrapper for the [Censys Search 2.0 API](https://search.censys.io/api) 

_**Note**_: this is **_NOT_** an official Censys library, and is not supported or affiliated with Censys at this time. 

# [View](https://search.censys.io/api/docs/v2/host/view)

View all the data on an IP at a given time. 

```elixir
CensysEx.Hosts.view("127.0.0.1")

# Lookup the host as it was at a certain time
CensysEx.Hosts.view("127.0.0.1", ~U[2021-06-07 12:53:27.450073Z])
```

# [Search](https://search.censys.io/api/docs/v2/search)
Search returns a stream of results using the cursors provided by the API.

```elixir
CensysEx.Hosts.search("services.service_name: HTTP")
|> Stream.take(500)
|> Enum.to_list()
```

# [Aggregate](https://search.censys.io/api/docs/v2/host/aggregate)

Aggregate data about hosts on the internet.

```elixir
CensysEx.Hosts.aggregate("location.country_code", "services.service_name: MEMCACHED")

CensysEx.Hosts.aggregate("location.country_code", "services.service_name: MEMCACHED", 10)
```

# Configuration
via environment variables
```bash
$ export CENSYS_API_ID="*****"
$ export CENSYS_API_SECRET="*****"
```
```elixir
{:ok, _} = CensysEx.API.start_link
```
or directly
```elixir
{:ok, _} = CensysEx.API.start_link("*****", "*****")
```
- API secrets can be found [here](https://search.censys.io/account/api)
