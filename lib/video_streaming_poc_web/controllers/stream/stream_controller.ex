defmodule VideoStreamingPocWeb.Stream.StreamController do
  @moduledoc false

  use VideoStreamingPocWeb, :controller

  alias ExAws.S3
  alias Plug.Conn

  def stream(conn, %{"filename" => filename}) do
    bucket = "your-s3-bucket"
    path = "videos/#{filename}"

    # Retrieve the video file from S3
    {:ok, response} = S3.get_object(bucket, path) |> ExAws.request()

    # Set the appropriate headers
    conn =
      conn
      |> Conn.put_resp_content_type("video/mp4")
      |> Conn.put_resp_header("content-disposition", "inline; filename=\"#{filename}\"")
      |> Conn.put_resp_header("accept-ranges", "bytes")
      |> Conn.send_chunked(200)

    # Stream the video file to the client
    stream_data(conn, response.body)
  end

  defp stream_data(conn, data) do
    chunk_size = 65_536 # 64 KB chunks

    # Chunk the binary data and send each chunk
    data
    |> chunk_binary(chunk_size)
    |> Enum.reduce_while(conn, fn chunk, conn ->
      case Conn.chunk(conn, chunk) do
        :ok -> {:cont, conn}
        {:error, _reason} -> {:halt, conn}
      end
    end)
  end

  # This function chunks the binary data
  defp chunk_binary(binary, chunk_size) do
    binary
    |> Stream.chunk_every(chunk_size, chunk_size, :discard)
  end
end
