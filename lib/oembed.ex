defmodule OEmbed do
  use GenServer
  require Logger

  @oembed_source "https://oembed.com/providers.json"

  @impl GenServer
  def init([url: url]) do
    initial_config = load_config(url)
    {:ok, %{url: url, config: initial_config}}
  end

  @impl GenServer
  def handle_call(:get_config, _from, state) do
    {:reply, state.config, state}
  end

  @impl GenServer
  def handle_call({:get_config, service}, _from, state) when is_atom(service) do
    service = Atom.to_string(service)
    found = Enum.find(state.config, fn item ->
      String.downcase(item["provider_name"]) == service
    end)
    {:reply, found, state}
  end

  defp load_config(url) do
  	resp = Tesla.get!(url)
    Jason.decode!(resp.body)
  end
end