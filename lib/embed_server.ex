defmodule EmbedServer do
  use GenServer
  require Logger

  @impl GenServer
  def init([provider_path: path]) do
    loaded_providers = load_providers(path)
    {:ok, %{provider_path: path, providers: loaded_providers}}
  end

  @impl GenServer
  def handle_call({:format, type, payload}, _from, state) do
    type = Atom.to_string(type)
    {:reply, state.providers[type], state}
  end

  def handle_call({:get_info, type}, _from, state) do
    type = Atom.to_string(type)
    {:reply, state.providers[type], state}
  end

  @impl GenServer
  def handle_cast(:reload_config, state) do
    new_providers = load_providers(state.provider_path)
    {:noreply, %{provider_path: state.provider_path, providers: new_providers}}
  end

  # Utility Functions

  def default_start do
    GenServer.start_link(EmbedServer, provider_path: "./providers")
  end

  defp load_providers(path) do
    files = File.ls!(path)
    Enum.reduce(files, %{}, fn file_name, acc ->
      full_path = Path.join(path, file_name)
      Logger.info("Compiling and loading provider file: #{full_path}")
      try do
        {compiled, _binding} = Code.eval_file(full_path)
        key = String.replace(file_name, ".exs", "")
        Map.put_new(acc, key, compiled)
      rescue
        error ->
          Logger.error("Failed to compile: #{error}")
          acc
      end
    end)
  end
end
