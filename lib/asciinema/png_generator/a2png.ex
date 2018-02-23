defmodule Asciinema.PngGenerator.A2png do
  @behaviour Asciinema.PngGenerator
  use GenServer
  alias Asciinema.Asciicasts.Asciicast
  alias Asciinema.PngGenerator.PngParams

  @pool_name :worker
  @acquire_timeout 5000
  @a2png_timeout 30_000
  @result_timeout 35_000

  def generate(%Asciicast{} = asciicast, %PngParams{} = png_params) do
    {:ok, tmp_dir_path} = Briefly.create(directory: true)

    try do
      :poolboy.transaction(
        @pool_name,
        (fn pid ->
          try do
            GenServer.call(pid, {:generate, asciicast, png_params, tmp_dir_path}, @result_timeout)
          catch
            :exit, {:timeout, _} ->
              {:error, :timeout}
          end
        end),
        @acquire_timeout
      )
    catch
      :exit, {:timeout, _} ->
        {:error, :busy}
    end
  end

  # GenServer API

  def start_link(_) do
    GenServer.start_link(__MODULE__, nil, [])
  end

  def init(_) do
    {:ok, nil}
  end

  def handle_call({:generate, asciicast, png_params, tmp_dir_path}, _from, state) do
    {:reply, do_generate(asciicast, png_params, tmp_dir_path), state}
  end

  def poolboy_config do
    [{:name, {:local, @pool_name}},
     {:worker_module, __MODULE__},
     {:size, pool_size()},
     {:max_overflow, 0}]
  end

  defp do_generate(asciicast, png_params, tmp_dir_path) do
    path = Asciicast.json_store_path(asciicast)
    json_path = Path.join(tmp_dir_path, "tmp.json")
    png_path = Path.join(tmp_dir_path, "tmp.png")

    args = [
      json_path,
      png_path,
      Float.to_string(png_params.snapshot_at),
      png_params.theme,
      Integer.to_string(png_params.scale)
    ]

    :ok = file_store().download_file(path, json_path)
    process = Porcelain.spawn(bin_path(), args, err: :string)

    case Porcelain.Process.await(process, @a2png_timeout) do
      {:ok, %{status: 0}} ->
        {:ok, png_path}
      {:ok, %Porcelain.Result{} = result} ->
        {:error, result}
      otherwise ->
        otherwise
    end
  end

  defp bin_path do
    Keyword.get(Application.get_env(:asciinema, __MODULE__), :bin_path)
  end

  defp pool_size do
    Keyword.get(Application.get_env(:asciinema, __MODULE__), :pool_size)
  end

  defp file_store do
    Application.get_env(:asciinema, :file_store)
  end
end
