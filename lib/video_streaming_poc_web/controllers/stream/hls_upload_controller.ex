defmodule VideoStreamingPocWeb.Stream.HlsUploadController do
  @moduledoc false

  use VideoStreamingPocWeb, :controller

  def m3u8_upload(conn, %{"key" => stream_key}) do
	{:ok, body, _} = Plug.Conn.read_body(conn)

	path = Path.join(["priv/static/streams", stream_key, "index.m3u8"])
	File.mkdir_p!(Path.dirname(path))
	File.write!(path, body)

	send_resp(conn, 200, "m3u8 file uploaded")
  end

  def ts_upload(conn, %{"key" => stream_key, "file_name" => file_name}) do
  {:ok, body, _} = Plug.Conn.read_body(conn)

  path = Path.join(["priv/static/streams", stream_key, file_name])
  File.mkdir_p!(Path.dirname(path))
  File.write!(path, body)

  send_resp(conn, 200, "TS file uploaded")
  end
end
