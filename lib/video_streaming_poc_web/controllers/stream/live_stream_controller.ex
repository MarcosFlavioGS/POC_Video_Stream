defmodule VideoStreamingPocWeb.Stream.LiveStreamController do
  @moduledoc """
  Module to receive and stream video chunks.
  """

  use VideoStreamingPocWeb, :controller

  alias VideoStreamingPoc.StreamProcessor
  alias VideoStreamingPoc.File.Get

  @doc """
  Streams local or S3 file.

  Receives the stream_key = name of the stream and the file_key to the S3 object.
  """
  def start(conn, %{"key" => stream_key, "file_key" => file_key}) do
    with {:ok, file_content} <- Get.get_file(file_key),
         temp_file_path <- "/tmp/#{stream_key}.mp4",
         :ok <- File.write(temp_file_path, file_content) do
      IO.puts("Stream started")
      StreamProcessor.start_stream(temp_file_path, stream_key)
      send_resp(conn, 200, "Stream started")
    else
      {:error, reason} ->
        IO.puts("Error retrieving file: #{inspect(reason)}")
        send_resp(conn, 500, "Error retrieving file")

      error ->
        IO.puts("Unexpected error: #{inspect(error)}")
        send_resp(conn, 500, "Unexpected error")
    end
  end

  @doc """
  Serves the playlist file of a livestream or video on demand.
  """
  def playlist(conn, %{"key" => stream_key}) do
    playlist_path = Path.join(["priv/static/streams", stream_key, "index.m3u8"])

    if File.exists?(playlist_path) do
      send_file(conn, 200, playlist_path)
    else
      send_resp(conn, 400, "Playlist not found")
    end
  end

  @doc """
  Serve the .ts files of livestreams or on demand videos.
  """
  def serve_ts_file(conn, %{"key" => key, "file_name" => file_name}) do
    stream_path = Path.join(["priv/static/streams", key, file_name])

    if File.exists?(stream_path) do
      send_file(conn, 200, stream_path)
    else
      conn
      |> put_status(:not_found)
      |> json(%{error: "File not found"})
    end
  end
end
