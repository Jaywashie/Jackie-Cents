defmodule InsuranceWeb.UserRegistrationLive do
  use InsuranceWeb, :live_view

  alias Insurance.Accounts
  alias Insurance.Accounts.User

  def render(assigns) do
    ~H"""
    <div class="min-h-screen bg-gray-50 flex items-center justify-center py-10 px-4">
      <div class="w-full max-w-md">

        <!-- Header -->
        <div class="text-center mb-6">
          <div class="inline-flex items-center justify-center w-10 h-10 bg-green-100 rounded-xl mb-3">
            <svg class="w-5 h-5 text-green-600" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2"
                d="M18 9v3m0 0v3m0-3h3m-3 0h-3m-2-5a4 4 0 11-8 0 4 4 0 018 0zM3 20a6 6 0 0112 0v1H3v-1z"/>
            </svg>
          </div>
          <h1 class="text-xl font-bold text-gray-900" style="font-family: 'DM Serif Display', serif;">
            Create your account
          </h1>
          <p class="text-gray-400 text-xs mt-1">
            Already registered?
            <.link navigate={~p"/users/log_in"} class="text-green-600 font-semibold hover:underline">
              Log in
            </.link>
          </p>
        </div>

        <!-- Form Card -->
        <div class="bg-white rounded-2xl shadow-sm border border-gray-100 p-6">
          <.simple_form
            for={@form}
            id="registration_form"
            phx-submit="save"
            phx-change="validate"
            phx-trigger-action={@trigger_submit}
            action={~p"/users/log_in?_action=registered"}
            method="post"
          >
            <.error :if={@check_errors}>
              Oops, something went wrong! Please check the errors below.
            </.error>

            <div class="space-y-3">

              <!-- Phone Number — first field as requested -->
              <.input
                field={@form[:phone_number]}
                type="tel"
                label="Phone Number"
                placeholder="e.g. +254 712 345 678"
                required
              />

              <!-- Name row -->
              <div class="grid grid-cols-2 gap-3">
                <.input
                  field={@form[:first_name]}
                  type="text"
                  label="First Name"
                  placeholder="Jane"
                  required
                />
                <.input
                  field={@form[:last_name]}
                  type="text"
                  label="Last Name"
                  placeholder="Doe"
                  required
                />
              </div>

              <!-- Email & Password -->
              <.input field={@form[:email]}    type="email"    label="Email"    required />
              <.input field={@form[:password]} type="password" label="Password" required />

            </div>

            <:actions>
              <button
                type="submit"
                phx-disable-with="Creating account..."
                class="w-full bg-green-600 hover:bg-green-700 text-white text-sm font-semibold py-2.5 rounded-xl transition-all mt-2"
              >
                Create account →
              </button>
            </:actions>
          </.simple_form>
        </div>

      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    changeset = Accounts.change_user_registration(%User{})

    socket =
      socket
      |> assign(trigger_submit: false, check_errors: false)
      |> assign_form(changeset)

    {:ok, socket, temporary_assigns: [form: nil]}
  end

  def handle_event("save", %{"user" => user_params}, socket) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        {:ok, _} =
          Accounts.deliver_user_confirmation_instructions(
            user,
            &url(~p"/users/confirm/#{&1}")
          )

        changeset = Accounts.change_user_registration(user)
        {:noreply, socket |> assign(trigger_submit: true) |> assign_form(changeset)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, socket |> assign(check_errors: true) |> assign_form(changeset)}
    end
  end

  def handle_event("validate", %{"user" => user_params}, socket) do
    changeset = Accounts.change_user_registration(%User{}, user_params)
    {:noreply, assign_form(socket, Map.put(changeset, :action, :validate))}
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    form = to_form(changeset, as: "user")
    if changeset.valid? do
      assign(socket, form: form, check_errors: false)
    else
      assign(socket, form: form)
    end
  end
end
