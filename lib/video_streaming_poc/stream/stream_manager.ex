defmodule VideoStreamingPoc.Stream.StreamManager do
  @moduledoc false

  def save_index(body, stream_key) do
    path = Path.join(["priv/static/streams", stream_key, "index.m3u8"])

    File.mkdir_p!(Path.dirname(path))
    File.write!(path, body)

    IO.puts("Index.m3u8 saved in /streams/#{stream_key}")
    {:ok, "Index saved"}
  end

  def save_ts(body, stream_key, file_name) do
    path = Path.join(["priv/static/streams", stream_key, file_name])

    File.mkdir_p!(Path.dirname(path))
    File.write!(path, body)

    IO.puts("#{file_name} file uploaded to /streams/#{stream_key}")
    {:ok, "TS saved"}
  end
end
