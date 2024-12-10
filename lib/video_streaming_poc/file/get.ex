defmodule VideoStreamingPoc.File.Get do
  @moduledoc false

  alias VideoStreamingPoc.Video
  alias ExAws.S3

  def get_url(file) do
    file = Video.url(file, :original)
    IO.inspect(file)
  end

  def get_file(file_key) do
    case S3.get_object(System.get_env("BUCKET"), "uploads/#{file_key}") |> ExAws.request() do
      {:ok, %{body: body}} ->
        {:ok, body}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
