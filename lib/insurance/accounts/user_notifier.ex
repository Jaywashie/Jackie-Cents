defmodule Insurance.Accounts.UserNotifier do
  import Swoosh.Email
  alias Insurance.Mailer

  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"JackieCents Insurance", "jaywashie5735@gmail.com"})
      |> subject(subject)
      |> text_body(body)
      |> html_body("""
        <div style="font-family: sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background: #16a34a; padding: 20px; text-align: center;">
            <h1 style="color: white; margin: 0;">JackieCents Insurance</h1>
          </div>
          <div style="padding: 30px; background: #f9fafb;">
            <pre style="font-family: sans-serif; white-space: pre-wrap;">#{body}</pre>
          </div>
        </div>
      """)

    # Deliver asynchronously to prevent timeouts during registration/reset
    Task.start(fn ->
      case Mailer.deliver(email) do
        {:ok, _metadata} -> :ok
        {:error, reason} ->
          # Log failure but don't crash the user's flow
          require Logger
          Logger.error("Failed to deliver email to #{email.to}: #{inspect(reason)}")
      end
    end)

    {:ok, email}
  end

  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirm your JackieCents account", """
    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.
    """)
  end

  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset your JackieCents password", """
    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.
    """)
  end

  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update your JackieCents email", """
    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.
    """)
  end
end
