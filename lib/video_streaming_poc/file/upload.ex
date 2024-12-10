defmodule VideoStreamingPoc.File.Upload do
  @moduledoc false

  def upload %Plug.Upload{} = _file do
    true
  end
end
