defmodule VideoStreamingPoc.Video do
  use Waffle.Definition

  # Include ecto support (requires package waffle_ecto installed):
  # use Waffle.Ecto.Definition

  # @versions [:original]

  # To add a thumbnail version:
  # @versions [:original, :thumb]

  # Override the bucket on a per definition basis:
  # def bucket do
  #   :custom_bucket_name
  # end

  # def bucket({_file, scope}) do
  #   scope.bucket || bucket()
  # end

  # Whitelist file extensions:
  @versions [:original, :thumb]
  @extension_whitelist ~w(.jpg .jpeg .gif .png .mp4)

  def acl(:thumb, _), do: :public_read

  def validate({file, _}) do
    file_extension = file.file_name |> Path.extname |> String.downcase
    Enum.member?(@extension_whitelist, file_extension)
  end

  # def transform(:thumb, _) do
  #   {:convert, "-thumbnail 100x100^ -gravity center -extent 100x100 -format png", :png}
  # end

  def filename(version, _) do
    version
  end

  # def storage_dir(_, {file, user}) do
  #   "uploads/video/#{user.id}"
  # end

  def default_url(:thumb) do
    "https://placehold.it/100x100"
  end
end
