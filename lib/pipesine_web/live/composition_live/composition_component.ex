defmodule PipesineWeb.CompositionLive.CompositionComponent do
  use PipesineWeb, :live_component

  def render(assigns) do
    ~H"""
    <div id="" class="composition">
      <div class="row">
        <div class="column column-10">
          <div class="composer-avatar"></div>
        </div>
        <div class="column column-90 composition-score dotgothic16">
          <b>composition by: <%= @composition.username %></b>
          <br/>
          <%= @composition.score %>
        </div>
      </div>
    </div>
    """
  end
end
