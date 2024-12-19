defmodule VideoStreamingPocWeb.Files.FileController do
  @moduledoc false

  use VideoStreamingPocWeb, :controller

  alias VideoStreamingPoc.Video

  def upload(conn, %{"video" => %Plug.Upload{} = file}) do
    case Video.store(file) do
      {:ok, response} ->
        conn
        |> put_status(:ok)
        |> json(%{message: "file uploaded", file: response})

      {:error, message} ->
        conn
        |> put_status(:bad_request)
        |> json(%{message: "error sending file to S3: #{message}"})
    end
  end
end
