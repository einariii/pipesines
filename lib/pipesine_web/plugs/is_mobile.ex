defmodule PipesineWeb.Plugs.IsMobile do
  import Plug.Conn
  import Phoenix.Controller

  def init(options), do: options

  def call(conn, _opts) do
    user_agent =
      get_req_header(conn, "user-agent")
      |> List.first()

    is_mobile = is_mobile?(user_agent)

    conn
    |> assign(:is_mobile, is_mobile)
    |> put_session(:is_mobile, is_mobile)
  end

  defp is_mobile?(user_agent) when is_nil(user_agent), do: false

  defp is_mobile?(user_agent) do
    lowered = String.downcase(user_agent)

    Regex.match?(~r/mobile|android|phone|ipad|tablet|ios/, lowered)
  end
end
