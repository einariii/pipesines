defmodule PipesineWeb.Components do
  use Phoenix.Component

  def link(assigns) do
    ~H"""
      <a href={@href} class="sm:px-24 rounded-full menu"><%= render_slot(@inner_block) %></a>
    """
  end
end
