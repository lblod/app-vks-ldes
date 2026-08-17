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

  ### Login
  post "/vendor/login/*path", @json do
    Proxy.forward conn, path, "http://vendor-login/sessions"
  end

  delete "/logout" do
    Proxy.forward conn, [], "http://vendor-login/sessions/current"
  end

  ### VKS
  get "/ar-designs/*path", @json do
    forward conn, path, "http://vks/ar-designs/"
  end

  get "/measure-concepts/*path", @json do
    forward conn, path, "http://vks/measure-concepts/"
  end

  ### 404
  match "/*_", %{ layer: :not_found } do
    send_resp( conn, 404, "Route not found.  See config/dispatcher.ex" )
  end
end
