defmodule VideoStreamingPocWeb.Router do
  use VideoStreamingPocWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", VideoStreamingPocWeb do
    pipe_through :api

    post "/upload", Files.FileController, :upload

    get "/stream/:filename", Stream.StreamController, :stream
    post "/stream/start/:key", Stream.LiveStreamController, :start

    get "/stream/:key/index.m3u8", Stream.LiveStreamController, :playlist
    get "/stream/:key/:file_name", Stream.LiveStreamController, :serve_ts_file

    put "/stream/m3u8/:key/:file_name", Stream.HlsUploadController, :m3u8_upload
    put "/stream/ts/:key/:file_name", Stream.HlsUploadController, :ts_upload
  end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:video_streaming_poc, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through [:fetch_session, :protect_from_forgery]

      live_dashboard "/dashboard", metrics: VideoStreamingPocWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
