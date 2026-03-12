defmodule InsuranceWeb.UserForgotPasswordLive do
  use InsuranceWeb, :live_view

  alias Insurance.Accounts

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 flex items-center justify-center py-8 px-4">
      <div class="w-full max-w-md">

        <!-- Header -->
        <div class="text-center mb-6">
          <div class="inline-flex items-center justify-center w-10 h-10 bg-green-100 rounded-xl mb-3">
            <svg class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M15 7a2 2 0 012 2m4 0a6 6 0 01-7.743 5.743L11 17H9v2H7v2H4a1 1 0 01-1-1v-2.586a1 1 0 01.293-.707l5.964-5.964A6 6 0 1121 9z"/>
            </svg>
          </div>
          <h1 class="text-xl font-bold text-gray-900" style="font-family: 'DM Serif Display', serif;">
            Reset your password
          </h1>
          <p class="text-gray-400 text-xs mt-1">We'll send a reset link to your inbox</p>
        </div>

        <!-- Form Card -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
          <.simple_form for={@form} id="reset_password_form" phx-submit="send_email">
            <div class="space-y-3">
              <.input field={@form[:email]} type="email" label="Email" placeholder="you@example.com" required />
            </div>
            <:actions>
              <button
                type="submit"
                phx-disable-with="Sending..."
                class="w-full bg-green-600 hover:bg-green-700 text-white text-sm font-semibold py-2.5 rounded-xl transition-all mt-1"
              >
                Send reset instructions →
              </button>
            </:actions>
          </.simple_form>
        </div>

        <!-- Footer links -->
        <p class="text-center text-xs text-gray-400 mt-4">
          <.link href={~p"/users/register"} class="text-green-600 font-semibold hover:underline">Register</.link>
          <span class="mx-2">·</span>
          <.link href={~p"/users/log_in"} class="text-green-600 font-semibold hover:underline">Log in</.link>
        </p>

      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}, as: "user"))}
  end

  def handle_event("send_email", %{"user" => %{"email" => email}}, socket) do
    if user = Accounts.get_user_by_email(email) do
      Accounts.deliver_user_reset_password_instructions(
        user,
        &url(~p"/users/reset_password/#{&1}")
      )
    end

    info = "If your email is in our system, you will receive instructions to reset your password shortly."
    {:noreply, socket |> put_flash(:info, info) |> redirect(to: ~p"/")}
  end
end
