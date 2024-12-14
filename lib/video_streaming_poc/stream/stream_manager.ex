defmodule VideoStreamingPoc.Stream.StreamManager do
  @moduledoc false

  require Logger

  def end_stream(stream_id) do
    # Your logic to finalize the stream goes here

    # Determine the directory path
    stream_path = Path.join(["priv", "static", "streams", stream_id])

    # Call cleanup
    cleanup_stream_files(stream_path)
  end

  defp cleanup_stream_files(stream_path) do
    if File.exists?(stream_path) do
      File.rm_rf!(stream_path)
      Logger.info("Deleted stream files and folder at #{stream_path}")
    else
      Logger.warning("Stream path not found: #{stream_path}")
    end
  end
end
