defmodule PipesineWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use PipesineWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import PipesineWeb.ConnCase

      alias PipesineWeb.Router.Helpers, as: Routes

      # The default endpoint for testing
      @endpoint PipesineWeb.Endpoint
    end
  end

  setup tags do
    Pipesine.DataCase.setup_sandbox(tags)
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end

  @doc """
  Setup helper that registers and logs in composers.

      setup :register_and_log_in_composer

  It stores an updated connection and a registered composer in the
  test context.
  """
  def register_and_log_in_composer(%{conn: conn}) do
    composer = Pipesine.ComposersFixtures.composer_fixture()
    %{conn: log_in_composer(conn, composer), composer: composer}
  end

  @doc """
  Logs the given `composer` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_composer(conn, composer) do
    token = Pipesine.Composers.generate_composer_session_token(composer)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:composer_token, token)
  end
end
