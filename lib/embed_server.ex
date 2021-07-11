defmodule EmbedServer do
  use GenServer
  require Logger

  @regex_payload_match Regex.compile!("(?<=\\{\\{)(.*)(?=\\}\\})")

  @impl GenServer
  def init([config_path: path]) do
    initial_config = load_config(path)
    {:ok, %{config_path: path, config: initial_config}}
  end

  @impl GenServer
  def handle_call({:format, type, payload}, _from, state) do
    type = Atom.to_string(type)
    services = state.config["services"]

    if Map.has_key?(services, type) do
      definition = services[type]
      case do_format(definition, payload) do
        {:ok, code} -> {:reply, {:ok, code}, state}
        :error -> {:reply, {:error, payload, type}, state}
      end
    else
      Logger.error("Service #{type} does not exist in service definitions!")
      {:reply, {:error, payload, type}, state}
    end
  end

  def handle_call({:get_info, type}, _from, state) do
    type = Atom.to_string(type)
    services = state.config["services"]

    if Map.has_key?(services, type) do
      definition = services[type]
      {:reply, {:ok, definition}, state}
    else
      Logger.error("Service #{type} does not exist in service definitions!")
      {:reply, :error, state}
    end
  end

  @impl GenServer
  def handle_cast(:reload_config, state) do
    new_config = load_config(state.config_path)
    {:noreply, %{config_path: state.config_path, config: new_config}}
  end

  # Utility Functions

  def default_start do
    GenServer.start_link(EmbedServer, config_path: "./default_config.json")
  end

  defp load_config(path) do
    Logger.info("Loading config from JSON file: #{path}")
    content = File.read!(path)
    Jason.decode!(content)
  end

  defp do_format(service, payload) when is_binary(payload) do
    if is_nil(service["deps"]) || is_nil(service["regex"]) || is_nil(service["code"]) do
      :error
    else
      code = service["code"]
      expression = Regex.compile!(service["regex"])
      groups = Regex.run(expression, payload)
      lookups = get_code_lookups(code)
      code = do_lookup_replacements(code, lookups, groups)
      {:ok, code}
    end
  end

  defp get_code_lookups(code) when is_binary(code) do
    Regex.run(@regex_payload_match, code)
    |> Enum.map(fn s ->
      case Integer.parse(s) do
        {int, _} -> int
        _ -> 0
      end
    end)
  end

  defp do_lookup_replacements(code, lookups, groups) when is_binary(code) and is_list(lookups) and is_list(groups) do
    Enum.reduce(lookups, code, fn int_lookup, acc ->
      String.replace(acc, "{{#{int_lookup}}}", Enum.at(groups, int_lookup))
    end)
  end

  defp do_lookup_replacements(_, _, _), do: "INVALID_EMBED"
end
