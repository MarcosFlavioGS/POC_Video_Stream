defmodule VideoStreamingPocWeb.Stream.LiveStreamController do
  @moduledoc """
  Module to receive and stream video chuncks

  """

  use VideoStreamingPocWeb, :controller

  alias VideoStreamingPoc.StreamProcessor

  @doc """
  Streams local or S3 file.

  Receives the stream_key = name of the stream and the url or filepath to the video.
  """
  def start(conn, %{"key" => stream_key, "input_url" => input_url}) do
    if input_url do
      IO.puts("Stream started")
      StreamProcessor.start_stream(input_url, stream_key)
      send_resp(conn, 200, "Stream started")
    else
      IO.puts("Missing input_url")
      send_resp(conn, 400, "Missing input_url")
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
