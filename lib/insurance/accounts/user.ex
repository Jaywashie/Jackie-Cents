defmodule Insurance.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email,            :string
    field :password,         :string, virtual: true, redact: true
    field :hashed_password,  :string, redact: true
    field :current_password, :string, virtual: true, redact: true
    field :confirmed_at,     :naive_datetime
    field :role,             :string, default: "user"

    # ── NEW profile fields ────────────────────────────────────────────
    field :first_name,   :string
    field :last_name,    :string
    field :phone_number, :string
    # ─────────────────────────────────────────────────────────────────

    has_many :quotes,   Insurance.Quotes.Quote
    has_many :policies, Insurance.Policies.Policy

    timestamps()
  end

  @valid_roles ~w(user admin)

  # ── Registration changeset — now includes profile fields ─────────────
  def registration_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :password, :first_name, :last_name, :phone_number])
    |> validate_required([:first_name, :last_name, :phone_number])
    |> validate_length(:first_name,   min: 2, max: 100)
    |> validate_length(:last_name,    min: 2, max: 100)
    |> validate_length(:phone_number, min: 9, max: 20)
    |> validate_format(:phone_number, ~r/^\+?[0-9\s\-]+$/,
        message: "must contain only digits, spaces, hyphens, or a leading +")
    |> validate_email(opts)
    |> validate_password(opts)
  end

  @doc "Changeset for admin to update a user's role."
  def role_changeset(user, attrs) do
    user
    |> cast(attrs, [:role])
    |> validate_required([:role])
    |> validate_inclusion(:role, @valid_roles)
  end

  defp validate_email(changeset, opts) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/,
        message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> maybe_validate_unique_email(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 72)
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> put_change(:hashed_password, Pbkdf2.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> unsafe_validate_unique(:email, Insurance.Repo)
      |> unique_constraint(:email)
    else
      changeset
    end
  end

  def email_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email])
    |> validate_email(opts)
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  def password_changeset(user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  def confirm_changeset(user) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(user, confirmed_at: now)
  end

  def valid_password?(%Insurance.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Pbkdf2.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Pbkdf2.no_user_verify()
    false
  end

  def validate_current_password(changeset, password) do
    changeset = cast(changeset, %{current_password: password}, [:current_password])

    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  @doc "Returns true if the user has the admin role."
  def admin?(%__MODULE__{role: "admin"}), do: true
  def admin?(_), do: false

  @doc "Returns the user's full name, falling back to email."
  def full_name(%__MODULE__{first_name: f, last_name: l})
      when is_binary(f) and is_binary(l), do: "#{f} #{l}"
  def full_name(%__MODULE__{email: email}), do: email
end
