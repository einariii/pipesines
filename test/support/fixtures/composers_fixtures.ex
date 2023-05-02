defmodule Pipesine.ComposersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Pipesine.Composers` context.
  """

  def unique_composer_email, do: "composer#{System.unique_integer()}@example.com"
  def valid_composer_password, do: "hello world!"

  def valid_composer_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_composer_email(),
      password: valid_composer_password()
    })
  end

  def composer_fixture(attrs \\ %{}) do
    {:ok, composer} =
      attrs
      |> valid_composer_attributes()
      |> Pipesine.Composers.register_composer()

    composer
  end

  def extract_composer_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
