defmodule VideoStreamingPocWeb.Stream.StreamController do
  @moduledoc false

  use VideoStreamingPocWeb, :controller

  alias VideoStreamingPoc.File.Get
  alias Plug.Conn

  def stream(conn, %{"filename" => filename}) do
    # Get file from the S# Bucket
    {:ok, body} = Get.get_file(filename)
    total_size = byte_size(body)
    IO.inspect(total_size, label: "Total Size")

    case Conn.get_req_header(conn, "range") do
      ["bytes=" <> range] ->
        IO.inspect(range, label: "Range header")
        conn = handle_range_request(conn, range, body, total_size)
        conn

      _ ->
        # Default to sending the whole content if no Range header is present
        conn =
          conn
          |> Conn.put_resp_content_type("video/mp4")
          |> Conn.put_resp_header("content-disposition", "inline; filename=\"#{filename}\"")
          |> Conn.put_resp_header("accept-ranges", "bytes")
          |> Conn.send_chunked(200)

        stream_data(conn, body)
    end
  end

  defp handle_range_request(conn, range, body, total_size) do
    {start, finish} = parse_range(range, total_size)
    length = finish - start + 1
    partial_content = binary_part(body, start, length)

    conn
    |> Conn.put_resp_content_type("video/mp4")
    |> Conn.put_resp_header("content-disposition", "inline; filename=\"video.mp4\"")
    |> Conn.put_resp_header("accept-ranges", "bytes")
    |> Conn.put_resp_header("content-range", "bytes #{start}-#{finish}/#{total_size}")
    # send_resp for partial content
    |> Conn.send_resp(206, partial_content)
  end

  defp parse_range(range, total_size) do
    [start_str, finish_str] =
      range
      |> String.split("-")
      |> Enum.map(&String.trim/1)

    start = String.to_integer(start_str)

    finish =
      case finish_str do
        "" -> total_size - 1
        _ -> String.to_integer(finish_str)
      end

    {start, finish}
  end

  defp stream_data(conn, data) do
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

  defp chunk_binary(binary, chunk_size) do
    Stream.unfold(binary, fn
      <<chunk::binary-size(chunk_size), rest::binary>> -> {chunk, rest}
      <<rest::binary>> when byte_size(rest) > 0 -> {rest, <<>>}
      <<>> -> nil
    end)
  end
end
