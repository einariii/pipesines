defmodule Pipesine.Composers.ComposerNotifier do
  import Swoosh.Email

  alias Pipesine.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Pipesine", "contact@example.com"})
      |> subject(subject)
      |> text_body(body)

    with {:ok, _metadata} <- Mailer.deliver(email) do
      {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(composer, url) do
    deliver(composer.email, "Confirmation instructions", """

    ==============================

    Hi #{composer.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a composer password.
  """
  def deliver_reset_password_instructions(composer, url) do
    deliver(composer.email, "Reset password instructions", """

    ==============================

    Hi #{composer.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a composer email.
  """
  def deliver_update_email_instructions(composer, url) do
    deliver(composer.email, "Update email instructions", """

    ==============================

    Hi #{composer.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
