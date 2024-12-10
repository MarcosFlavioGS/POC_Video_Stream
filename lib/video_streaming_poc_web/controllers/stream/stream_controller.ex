defmodule VideoStreamingPocWeb.Stream.StreamController do
  @moduledoc false

  use VideoStreamingPocWeb, :controller

  alias VideoStreamingPoc.File.Get
  alias Plug.Conn

  def stream(conn, %{"filename" => filename}) do
    {:ok, body} = Get.get_file(filename)

    conn =
      conn
      |> Conn.put_resp_content_type("video/mp4")
      |> Conn.put_resp_header("content-disposition", "inline; filename=\"#{filename}\"")
      |> Conn.put_resp_header("accept-ranges", "bytes")
      |> Conn.send_chunked(200)

    # Stream the video file to the client
    stream_data(conn, body)
  end

  defp stream_data(conn, data) do
    # 64 KB chunks
    chunk_size = 65_536

    data
    |> chunk_binary(chunk_size)
    |> Enum.reduce_while(conn, fn chunk, conn ->
      case Conn.chunk(conn, chunk) do
        {:ok, conn} -> {:cont, conn}
        {:error, _reason} -> {:halt, conn}
      end
    end)
  end

  # This function chunks the binary data
  defp chunk_binary(binary, chunk_size) do
    Stream.unfold(binary, fn
      <<chunk::binary-size(chunk_size), rest::binary>> -> {chunk, rest}
      <<rest::binary>> when byte_size(rest) > 0 -> {rest, <<>>}
      <<>> -> nil
    end)
  end
end
