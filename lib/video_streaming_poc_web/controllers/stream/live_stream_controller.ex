defmodule VideoStreamingPocWeb.Stream.LiveStreamController do
  @moduledoc false

  use VideoStreamingPocWeb, :controller

  alias VideoStreamingPoc.StreamProcessor

  def start(conn, %{"key" => stream_key}) do
    input_url = conn.body_params["input_url"]

    if input_url do
      StreamProcessor.start_stream(input_url, stream_key)
      send_resp(conn, 200, "Stream started")
    else
      send_resp(conn, 400, "Missing input_url")
    end
  end

  def playlist(conn, %{"key" => stream_key}) do
    playlist_path = Path.join(["priv/static/streams", stream_key, "index.m3u8"])

    if File.exists?(playlist_path) do
      send_file(conn, 200, playlist_path)
    else
      send_resp(conn, 400, "Playlist not found")
    end
  end
end
