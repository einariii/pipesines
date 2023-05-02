defmodule Pipesine.Composers do
  @moduledoc """
  The Composers context.
  """

  import Ecto.Query, warn: false
  alias Pipesine.Repo

  alias Pipesine.Composers.{Composer, ComposerToken, ComposerNotifier}

  ## Database getters

  @doc """
  Gets a composer by email.

  ## Examples

      iex> get_composer_by_email("foo@example.com")
      %Composer{}

      iex> get_composer_by_email("unknown@example.com")
      nil

  """
  def get_composer_by_email(email) when is_binary(email) do
    Repo.get_by(Composer, email: email)
  end

  @doc """
  Gets a composer by email and password.

  ## Examples

      iex> get_composer_by_email_and_password("foo@example.com", "correct_password")
      %Composer{}

      iex> get_composer_by_email_and_password("foo@example.com", "invalid_password")
      nil

  """
  def get_composer_by_email_and_password(email, password)
      when is_binary(email) and is_binary(password) do
    composer = Repo.get_by(Composer, email: email)
    if Composer.valid_password?(composer, password), do: composer
  end

  @doc """
  Gets a single composer.

  Raises `Ecto.NoResultsError` if the Composer does not exist.

  ## Examples

      iex> get_composer!(123)
      %Composer{}

      iex> get_composer!(456)
      ** (Ecto.NoResultsError)

  """
  def get_composer!(id), do: Repo.get!(Composer, id)

  ## Composer registration

  @doc """
  Registers a composer.

  ## Examples

      iex> register_composer(%{field: value})
      {:ok, %Composer{}}

      iex> register_composer(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def register_composer(attrs) do
    %Composer{}
    |> Composer.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking composer changes.

  ## Examples

      iex> change_composer_registration(composer)
      %Ecto.Changeset{data: %Composer{}}

  """
  def change_composer_registration(%Composer{} = composer, attrs \\ %{}) do
    Composer.registration_changeset(composer, attrs, hash_password: false)
  end

  ## Settings

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the composer email.

  ## Examples

      iex> change_composer_email(composer)
      %Ecto.Changeset{data: %Composer{}}

  """
  def change_composer_email(composer, attrs \\ %{}) do
    Composer.email_changeset(composer, attrs)
  end

  @doc """
  Emulates that the email will change without actually changing
  it in the database.

  ## Examples

      iex> apply_composer_email(composer, "valid password", %{email: ...})
      {:ok, %Composer{}}

      iex> apply_composer_email(composer, "invalid password", %{email: ...})
      {:error, %Ecto.Changeset{}}

  """
  def apply_composer_email(composer, password, attrs) do
    composer
    |> Composer.email_changeset(attrs)
    |> Composer.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the composer email using the given token.

  If the token matches, the composer email is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_composer_email(composer, token) do
    context = "change:#{composer.email}"

    with {:ok, query} <- ComposerToken.verify_change_email_token_query(token, context),
         %ComposerToken{sent_to: email} <- Repo.one(query),
         {:ok, _} <- Repo.transaction(composer_email_multi(composer, email, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp composer_email_multi(composer, email, context) do
    changeset =
      composer
      |> Composer.email_changeset(%{email: email})
      |> Composer.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:composer, changeset)
    |> Ecto.Multi.delete_all(:tokens, ComposerToken.composer_and_contexts_query(composer, [context]))
  end

  @doc """
  Delivers the update email instructions to the given composer.

  ## Examples

      iex> deliver_update_email_instructions(composer, current_email, &Routes.composer_update_email_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_update_email_instructions(%Composer{} = composer, current_email, update_email_url_fun)
      when is_function(update_email_url_fun, 1) do
    {encoded_token, composer_token} = ComposerToken.build_email_token(composer, "change:#{current_email}")

    Repo.insert!(composer_token)
    ComposerNotifier.deliver_update_email_instructions(composer, update_email_url_fun.(encoded_token))
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the composer password.

  ## Examples

      iex> change_composer_password(composer)
      %Ecto.Changeset{data: %Composer{}}

  """
  def change_composer_password(composer, attrs \\ %{}) do
    Composer.password_changeset(composer, attrs, hash_password: false)
  end

  @doc """
  Updates the composer password.

  ## Examples

      iex> update_composer_password(composer, "valid password", %{password: ...})
      {:ok, %Composer{}}

      iex> update_composer_password(composer, "invalid password", %{password: ...})
      {:error, %Ecto.Changeset{}}

  """
  def update_composer_password(composer, password, attrs) do
    changeset =
      composer
      |> Composer.password_changeset(attrs)
      |> Composer.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:composer, changeset)
    |> Ecto.Multi.delete_all(:tokens, ComposerToken.composer_and_contexts_query(composer, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{composer: composer}} -> {:ok, composer}
      {:error, :composer, changeset, _} -> {:error, changeset}
    end
  end

  ## Session

  @doc """
  Generates a session token.
  """
  def generate_composer_session_token(composer) do
    {token, composer_token} = ComposerToken.build_session_token(composer)
    Repo.insert!(composer_token)
    token
  end

  @doc """
  Gets the composer with the given signed token.
  """
  def get_composer_by_session_token(token) do
    {:ok, query} = ComposerToken.verify_session_token_query(token)
    Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_session_token(token) do
    Repo.delete_all(ComposerToken.token_and_context_query(token, "session"))
    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given composer.

  ## Examples

      iex> deliver_composer_confirmation_instructions(composer, &Routes.composer_confirmation_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

      iex> deliver_composer_confirmation_instructions(confirmed_composer, &Routes.composer_confirmation_url(conn, :edit, &1))
      {:error, :already_confirmed}

  """
  def deliver_composer_confirmation_instructions(%Composer{} = composer, confirmation_url_fun)
      when is_function(confirmation_url_fun, 1) do
    if composer.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, composer_token} = ComposerToken.build_email_token(composer, "confirm")
      Repo.insert!(composer_token)
      ComposerNotifier.deliver_confirmation_instructions(composer, confirmation_url_fun.(encoded_token))
    end
  end

  @doc """
  Confirms a composer by the given token.

  If the token matches, the composer account is marked as confirmed
  and the token is deleted.
  """
  def confirm_composer(token) do
    with {:ok, query} <- ComposerToken.verify_email_token_query(token, "confirm"),
         %Composer{} = composer <- Repo.one(query),
         {:ok, %{composer: composer}} <- Repo.transaction(confirm_composer_multi(composer)) do
      {:ok, composer}
    else
      _ -> :error
    end
  end

  defp confirm_composer_multi(composer) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:composer, Composer.confirm_changeset(composer))
    |> Ecto.Multi.delete_all(:tokens, ComposerToken.composer_and_contexts_query(composer, ["confirm"]))
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given composer.

  ## Examples

      iex> deliver_composer_reset_password_instructions(composer, &Routes.composer_reset_password_url(conn, :edit, &1))
      {:ok, %{to: ..., body: ...}}

  """
  def deliver_composer_reset_password_instructions(%Composer{} = composer, reset_password_url_fun)
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, composer_token} = ComposerToken.build_email_token(composer, "reset_password")
    Repo.insert!(composer_token)
    ComposerNotifier.deliver_reset_password_instructions(composer, reset_password_url_fun.(encoded_token))
  end

  @doc """
  Gets the composer by reset password token.

  ## Examples

      iex> get_composer_by_reset_password_token("validtoken")
      %Composer{}

      iex> get_composer_by_reset_password_token("invalidtoken")
      nil

  """
  def get_composer_by_reset_password_token(token) do
    with {:ok, query} <- ComposerToken.verify_email_token_query(token, "reset_password"),
         %Composer{} = composer <- Repo.one(query) do
      composer
    else
      _ -> nil
    end
  end

  @doc """
  Resets the composer password.

  ## Examples

      iex> reset_composer_password(composer, %{password: "new long password", password_confirmation: "new long password"})
      {:ok, %Composer{}}

      iex> reset_composer_password(composer, %{password: "valid", password_confirmation: "not the same"})
      {:error, %Ecto.Changeset{}}

  """
  def reset_composer_password(composer, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:composer, Composer.password_changeset(composer, attrs))
    |> Ecto.Multi.delete_all(:tokens, ComposerToken.composer_and_contexts_query(composer, :all))
    |> Repo.transaction()
    |> case do
      {:ok, %{composer: composer}} -> {:ok, composer}
      {:error, :composer, changeset, _} -> {:error, changeset}
    end
  end
end
