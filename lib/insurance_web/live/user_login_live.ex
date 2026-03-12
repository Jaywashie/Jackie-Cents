defmodule InsuranceWeb.UserLoginLive do
  use InsuranceWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 flex items-center justify-center py-8 px-4">
      <div class="w-full max-w-md">

        <!-- Header -->
        <div class="text-center mb-6">
          <div class="inline-flex items-center justify-center w-10 h-10 bg-green-100 rounded-xl mb-3">
            <svg class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M16 7a4 4 0 11-8 0 4 4 0 018 0zM12 14a7 7 0 00-7 7h14a7 7 0 00-7-7z"/>
            </svg>
          </div>
          <h1 class="text-xl font-bold text-gray-900" style="font-family: 'DM Serif Display', serif;">
            Welcome back
          </h1>
          <p class="text-gray-400 text-xs mt-1">
            Don't have an account?
            <.link navigate={~p"/users/register"} class="text-green-600 font-semibold hover:underline">
              Sign up
            </.link>
          </p>
        </div>

        <!-- Form Card -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-5">
          <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
            <div class="space-y-3">
              <.input field={@form[:email]} type="email" label="Email" required />
              <.input field={@form[:password]} type="password" label="Password" required />
            </div>
            <:actions>
              <div class="flex items-center justify-between mt-1">
                <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
                <.link href={~p"/users/reset_password"} class="text-xs text-green-600 font-semibold hover:underline">
                  Forgot password?
                </.link>
              </div>
            </:actions>
            <:actions>
              <button
                type="submit"
                phx-disable-with="Logging in..."
                class="w-full bg-green-600 hover:bg-green-700 text-white text-sm font-semibold py-2.5 rounded-xl transition-all mt-1"
              >
                Log in →
              </button>
            </:actions>
          </.simple_form>
        </div>

      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form  = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
