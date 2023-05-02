defmodule Pipesine.ComposersTest do
  use Pipesine.DataCase

  alias Pipesine.Composers

  import Pipesine.ComposersFixtures
  alias Pipesine.Composers.{Composer, ComposerToken}

  describe "get_composer_by_email/1" do
    test "does not return the composer if the email does not exist" do
      refute Composers.get_composer_by_email("unknown@example.com")
    end

    test "returns the composer if the email exists" do
      %{id: id} = composer = composer_fixture()
      assert %Composer{id: ^id} = Composers.get_composer_by_email(composer.email)
    end
  end

  describe "get_composer_by_email_and_password/2" do
    test "does not return the composer if the email does not exist" do
      refute Composers.get_composer_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the composer if the password is not valid" do
      composer = composer_fixture()
      refute Composers.get_composer_by_email_and_password(composer.email, "invalid")
    end

    test "returns the composer if the email and password are valid" do
      %{id: id} = composer = composer_fixture()

      assert %Composer{id: ^id} =
               Composers.get_composer_by_email_and_password(composer.email, valid_composer_password())
    end
  end

  describe "get_composer!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Composers.get_composer!(-1)
      end
    end

    test "returns the composer with the given id" do
      %{id: id} = composer = composer_fixture()
      assert %Composer{id: ^id} = Composers.get_composer!(composer.id)
    end
  end

  describe "register_composer/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Composers.register_composer(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Composers.register_composer(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Composers.register_composer(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = composer_fixture()
      {:error, changeset} = Composers.register_composer(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Composers.register_composer(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers composers with a hashed password" do
      email = unique_composer_email()
      {:ok, composer} = Composers.register_composer(valid_composer_attributes(email: email))
      assert composer.email == email
      assert is_binary(composer.hashed_password)
      assert is_nil(composer.confirmed_at)
      assert is_nil(composer.password)
    end
  end

  describe "change_composer_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Composers.change_composer_registration(%Composer{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_composer_email()
      password = valid_composer_password()

      changeset =
        Composers.change_composer_registration(
          %Composer{},
          valid_composer_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_composer_email/2" do
    test "returns a composer changeset" do
      assert %Ecto.Changeset{} = changeset = Composers.change_composer_email(%Composer{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_composer_email/3" do
    setup do
      %{composer: composer_fixture()}
    end

    test "requires email to change", %{composer: composer} do
      {:error, changeset} = Composers.apply_composer_email(composer, valid_composer_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{composer: composer} do
      {:error, changeset} =
        Composers.apply_composer_email(composer, valid_composer_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{composer: composer} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Composers.apply_composer_email(composer, valid_composer_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{composer: composer} do
      %{email: email} = composer_fixture()

      {:error, changeset} =
        Composers.apply_composer_email(composer, valid_composer_password(), %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{composer: composer} do
      {:error, changeset} =
        Composers.apply_composer_email(composer, "invalid", %{email: unique_composer_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{composer: composer} do
      email = unique_composer_email()
      {:ok, composer} = Composers.apply_composer_email(composer, valid_composer_password(), %{email: email})
      assert composer.email == email
      assert Composers.get_composer!(composer.id).email != email
    end
  end

  describe "deliver_update_email_instructions/3" do
    setup do
      %{composer: composer_fixture()}
    end

    test "sends token through notification", %{composer: composer} do
      token =
        extract_composer_token(fn url ->
          Composers.deliver_update_email_instructions(composer, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert composer_token = Repo.get_by(ComposerToken, token: :crypto.hash(:sha256, token))
      assert composer_token.composer_id == composer.id
      assert composer_token.sent_to == composer.email
      assert composer_token.context == "change:current@example.com"
    end
  end

  describe "update_composer_email/2" do
    setup do
      composer = composer_fixture()
      email = unique_composer_email()

      token =
        extract_composer_token(fn url ->
          Composers.deliver_update_email_instructions(%{composer | email: email}, composer.email, url)
        end)

      %{composer: composer, token: token, email: email}
    end

    test "updates the email with a valid token", %{composer: composer, token: token, email: email} do
      assert Composers.update_composer_email(composer, token) == :ok
      changed_composer = Repo.get!(Composer, composer.id)
      assert changed_composer.email != composer.email
      assert changed_composer.email == email
      assert changed_composer.confirmed_at
      assert changed_composer.confirmed_at != composer.confirmed_at
      refute Repo.get_by(ComposerToken, composer_id: composer.id)
    end

    test "does not update email with invalid token", %{composer: composer} do
      assert Composers.update_composer_email(composer, "oops") == :error
      assert Repo.get!(Composer, composer.id).email == composer.email
      assert Repo.get_by(ComposerToken, composer_id: composer.id)
    end

    test "does not update email if composer email changed", %{composer: composer, token: token} do
      assert Composers.update_composer_email(%{composer | email: "current@example.com"}, token) == :error
      assert Repo.get!(Composer, composer.id).email == composer.email
      assert Repo.get_by(ComposerToken, composer_id: composer.id)
    end

    test "does not update email if token expired", %{composer: composer, token: token} do
      {1, nil} = Repo.update_all(ComposerToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Composers.update_composer_email(composer, token) == :error
      assert Repo.get!(Composer, composer.id).email == composer.email
      assert Repo.get_by(ComposerToken, composer_id: composer.id)
    end
  end

  describe "change_composer_password/2" do
    test "returns a composer changeset" do
      assert %Ecto.Changeset{} = changeset = Composers.change_composer_password(%Composer{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Composers.change_composer_password(%Composer{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_composer_password/3" do
    setup do
      %{composer: composer_fixture()}
    end

    test "validates password", %{composer: composer} do
      {:error, changeset} =
        Composers.update_composer_password(composer, valid_composer_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{composer: composer} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Composers.update_composer_password(composer, valid_composer_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{composer: composer} do
      {:error, changeset} =
        Composers.update_composer_password(composer, "invalid", %{password: valid_composer_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{composer: composer} do
      {:ok, composer} =
        Composers.update_composer_password(composer, valid_composer_password(), %{
          password: "new valid password"
        })

      assert is_nil(composer.password)
      assert Composers.get_composer_by_email_and_password(composer.email, "new valid password")
    end

    test "deletes all tokens for the given composer", %{composer: composer} do
      _ = Composers.generate_composer_session_token(composer)

      {:ok, _} =
        Composers.update_composer_password(composer, valid_composer_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(ComposerToken, composer_id: composer.id)
    end
  end

  describe "generate_composer_session_token/1" do
    setup do
      %{composer: composer_fixture()}
    end

    test "generates a token", %{composer: composer} do
      token = Composers.generate_composer_session_token(composer)
      assert composer_token = Repo.get_by(ComposerToken, token: token)
      assert composer_token.context == "session"

      # Creating the same token for another composer should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%ComposerToken{
          token: composer_token.token,
          composer_id: composer_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_composer_by_session_token/1" do
    setup do
      composer = composer_fixture()
      token = Composers.generate_composer_session_token(composer)
      %{composer: composer, token: token}
    end

    test "returns composer by token", %{composer: composer, token: token} do
      assert session_composer = Composers.get_composer_by_session_token(token)
      assert session_composer.id == composer.id
    end

    test "does not return composer for invalid token" do
      refute Composers.get_composer_by_session_token("oops")
    end

    test "does not return composer for expired token", %{token: token} do
      {1, nil} = Repo.update_all(ComposerToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Composers.get_composer_by_session_token(token)
    end
  end

  describe "delete_session_token/1" do
    test "deletes the token" do
      composer = composer_fixture()
      token = Composers.generate_composer_session_token(composer)
      assert Composers.delete_session_token(token) == :ok
      refute Composers.get_composer_by_session_token(token)
    end
  end

  describe "deliver_composer_confirmation_instructions/2" do
    setup do
      %{composer: composer_fixture()}
    end

    test "sends token through notification", %{composer: composer} do
      token =
        extract_composer_token(fn url ->
          Composers.deliver_composer_confirmation_instructions(composer, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert composer_token = Repo.get_by(ComposerToken, token: :crypto.hash(:sha256, token))
      assert composer_token.composer_id == composer.id
      assert composer_token.sent_to == composer.email
      assert composer_token.context == "confirm"
    end
  end

  describe "confirm_composer/1" do
    setup do
      composer = composer_fixture()

      token =
        extract_composer_token(fn url ->
          Composers.deliver_composer_confirmation_instructions(composer, url)
        end)

      %{composer: composer, token: token}
    end

    test "confirms the email with a valid token", %{composer: composer, token: token} do
      assert {:ok, confirmed_composer} = Composers.confirm_composer(token)
      assert confirmed_composer.confirmed_at
      assert confirmed_composer.confirmed_at != composer.confirmed_at
      assert Repo.get!(Composer, composer.id).confirmed_at
      refute Repo.get_by(ComposerToken, composer_id: composer.id)
    end

    test "does not confirm with invalid token", %{composer: composer} do
      assert Composers.confirm_composer("oops") == :error
      refute Repo.get!(Composer, composer.id).confirmed_at
      assert Repo.get_by(ComposerToken, composer_id: composer.id)
    end

    test "does not confirm email if token expired", %{composer: composer, token: token} do
      {1, nil} = Repo.update_all(ComposerToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Composers.confirm_composer(token) == :error
      refute Repo.get!(Composer, composer.id).confirmed_at
      assert Repo.get_by(ComposerToken, composer_id: composer.id)
    end
  end

  describe "deliver_composer_reset_password_instructions/2" do
    setup do
      %{composer: composer_fixture()}
    end

    test "sends token through notification", %{composer: composer} do
      token =
        extract_composer_token(fn url ->
          Composers.deliver_composer_reset_password_instructions(composer, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert composer_token = Repo.get_by(ComposerToken, token: :crypto.hash(:sha256, token))
      assert composer_token.composer_id == composer.id
      assert composer_token.sent_to == composer.email
      assert composer_token.context == "reset_password"
    end
  end

  describe "get_composer_by_reset_password_token/1" do
    setup do
      composer = composer_fixture()

      token =
        extract_composer_token(fn url ->
          Composers.deliver_composer_reset_password_instructions(composer, url)
        end)

      %{composer: composer, token: token}
    end

    test "returns the composer with valid token", %{composer: %{id: id}, token: token} do
      assert %Composer{id: ^id} = Composers.get_composer_by_reset_password_token(token)
      assert Repo.get_by(ComposerToken, composer_id: id)
    end

    test "does not return the composer with invalid token", %{composer: composer} do
      refute Composers.get_composer_by_reset_password_token("oops")
      assert Repo.get_by(ComposerToken, composer_id: composer.id)
    end

    test "does not return the composer if token expired", %{composer: composer, token: token} do
      {1, nil} = Repo.update_all(ComposerToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Composers.get_composer_by_reset_password_token(token)
      assert Repo.get_by(ComposerToken, composer_id: composer.id)
    end
  end

  describe "reset_composer_password/2" do
    setup do
      %{composer: composer_fixture()}
    end

    test "validates password", %{composer: composer} do
      {:error, changeset} =
        Composers.reset_composer_password(composer, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{composer: composer} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Composers.reset_composer_password(composer, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{composer: composer} do
      {:ok, updated_composer} = Composers.reset_composer_password(composer, %{password: "new valid password"})
      assert is_nil(updated_composer.password)
      assert Composers.get_composer_by_email_and_password(composer.email, "new valid password")
    end

    test "deletes all tokens for the given composer", %{composer: composer} do
      _ = Composers.generate_composer_session_token(composer)
      {:ok, _} = Composers.reset_composer_password(composer, %{password: "new valid password"})
      refute Repo.get_by(ComposerToken, composer_id: composer.id)
    end
  end

  describe "inspect/2" do
    test "does not include password" do
      refute inspect(%Composer{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
