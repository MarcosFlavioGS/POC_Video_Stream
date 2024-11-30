defmodule VideoStreamingPocWeb.Files.FileController do
  use VideoStreamingPocWeb, :controller

  # alias VideoStreamingPoc.Video

  def upload(conn, %{"video" => %Plug.Upload{} = file}) do
    # Video.store(file)
    IO.inspect file

    conn
    |> put_status(:ok)
    |> json(%{message: "file uploaded", filename: file.filename})
  end
end
