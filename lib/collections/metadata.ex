defmodule CensysEx.Metadata do
  @moduledoc """
  Functions related to the /metadata endpoints on search.censys.io
  """

  alias CensysEx.Util

  @doc """
  hits metadata/hosts returning the possible values for the services.service_name field in search queries.

  - API docs: https://search.censys.io/api#/hosts/getHostMetadata
  """
  @spec hosts_metadata :: {:error, any()} | {:ok, map()}
  def hosts_metadata, do: Util.get_client().get("metadata", "hosts", [], [])
end
