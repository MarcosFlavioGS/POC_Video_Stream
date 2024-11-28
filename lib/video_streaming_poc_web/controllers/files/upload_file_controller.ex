defmodule VideoStreamingPocWeb.Files.UploadFileController do

  use VideoStreamingPocWeb, :controller

  def upload(conn, %{"video" => video}) do
  	#TODO: gets a video file and uploads it to S3
	upload_path = Path.join("priv/static/uploads", video.filename)
	File.cp!(video.path, upload_path)

	conn
	|> put_status(:ok)
	|> json(%{message: "file uploaded", path: upload_path})
  end

end
