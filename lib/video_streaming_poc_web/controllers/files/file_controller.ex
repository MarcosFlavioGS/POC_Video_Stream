defmodule VideoStreamingPocWeb.Files.FileController do
  use VideoStreamingPocWeb, :controller

  alias VideoStreamingPoc.Video

  def upload(conn, %{"video" => %Plug.Upload{} = file}) do
    with {:ok, response}  <- Video.store(file) do
      IO.inspect response, label: "Store response: "
    	conn
      |> put_status(:ok)
      |> json(%{message: "file uploaded", file: response})
    else
      {:error, message} ->
        IO.inspect(message)
        conn
        |> put_status(:bad_request)
        |> json(%{message: "error sending file to S3"})
    end
  end
end
