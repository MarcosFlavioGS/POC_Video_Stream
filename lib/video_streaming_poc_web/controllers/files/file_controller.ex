defmodule VideoStreamingPocWeb.Files.FileController do
  use VideoStreamingPocWeb, :controller

  alias VideoStreamingPoc.Video

  def upload(conn, %{"video" => %Plug.Upload{} = video}) do
    # Video.store(%Plug.Upload{})

    conn
    |> put_status(:ok)
    |> json(%{message: "file uploaded", filename: video.filename})
  end
end
