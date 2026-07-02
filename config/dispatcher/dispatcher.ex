defmodule Dispatcher do
  use Matcher
  define_accept_types [
    html: [ "text/html", "application/xhtml+html" ],
    json: [ "application/json", "application/vnd.api+json" ]
  ]

  # @any %{}
  @json %{ accept: %{ json: true } }
  # @html %{ accept: %{ html: true } }

  define_layers [ :static, :services, :fall_back, :not_found ]

  get "/ar-designs/*path", @json do
    forward conn, path, "http://vks/ar-designs/"
  end
  get "/measure-concepts/*path", @json do
    forward conn, path, "http://vks/measure-concepts/"
  end

  match "/*_", %{ layer: :not_found } do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end
end
