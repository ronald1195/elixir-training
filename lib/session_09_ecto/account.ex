defmodule Session09.Account do
  @moduledoc """
  An Ecto schema representing a bank account.

  ## Background for OOP Developers

  In a typical ORM (ActiveRecord, Hibernate), the model class contains:
  - Schema definition
  - Validations
  - Business logic
  - Query methods

  In Ecto, we separate these concerns:
  - Schema: Data structure and types (this module)
  - Changeset: Validation and casting (this module)
  - Context: Business logic and queries (accounts.ex)

  ## Schema Definition

  The accounts table has:
  - id: Primary key (auto-generated)
  - account_number: Unique identifier string
  - holder_name: Account holder's name
  - email: Contact email
  - balance: Balance in cents (integer, not float!)
  - status: Account status (active, frozen, closed)
  - account_type: Type of account (checking, savings, business)
  - daily_limit: Maximum daily transaction amount
  - inserted_at/updated_at: Timestamps

  ## Your Task

  Implement the changeset functions. The schema is provided.
  """

  use Ecto.Schema
  import Ecto.Changeset

  # Schema is provided - implement the changesets below
  schema "accounts" do
    field(:account_number, :string)
    field(:holder_name, :string)
    field(:email, :string)
    field(:balance, :integer, default: 0)
    field(:status, :string, default: "active")
    field(:account_type, :string)
    field(:daily_limit, :integer)

    timestamps()
  end

  @doc """
  Creates a changeset for creating a new account.

  Validations:
  - account_number: required, unique, format "ACC-XXXXXX"
  - holder_name: required, length 2-100
  - email: required, valid email format
  - balance: must be >= 0
  - status: must be one of ["active", "frozen", "closed"]
  - account_type: required, one of ["checking", "savings", "business"]
  - daily_limit: must be > 0 if provided

  ## Examples

      iex> changeset = Session09.Account.changeset(%Session09.Account{}, %{
      ...>   account_number: "ACC-123456",
      ...>   holder_name: "John Doe",
      ...>   email: "john@example.com",
      ...>   account_type: "checking"
      ...> })
      iex> changeset.valid?
      true
  """
  def changeset(_account, _attrs) do
    # TODO: Implement the changeset
    # 1. Cast allowed fields
    # 2. Validate required fields
    # 3. Validate formats and constraints
    # 4. Add unique constraint for account_number
    #
    # Hint: Start with something like:
    # account
    # |> cast(attrs, [:account_number, :holder_name, :email, :balance, :status, :account_type, :daily_limit])
    # |> validate_required([:account_number, :holder_name, :email, :account_type])
    # |> validate_format(:email, ~r/@/)
    # ... more validations
    raise "TODO: Implement changeset/2"
  end

  @doc """
  Creates a changeset for updating an existing account.

  Only allows updating: holder_name, email, status, daily_limit
  Does NOT allow changing: account_number, account_type, balance

  ## Examples

      iex> account = %Session09.Account{holder_name: "Old Name"}
      iex> changeset = Session09.Account.update_changeset(account, %{holder_name: "New Name"})
      iex> changeset.valid?
      true
  """
  def update_changeset(_account, _attrs) do
    # TODO: Implement update changeset
    # Only allow specific fields to be updated
    raise "TODO: Implement update_changeset/2"
  end

  @doc """
  Creates a changeset for balance adjustments.

  This is used by the context when processing transactions.
  Only validates that balance >= 0.

  ## Examples

      iex> account = %Session09.Account{balance: 1000}
      iex> changeset = Session09.Account.balance_changeset(account, %{balance: 1500})
      iex> changeset.valid?
      true

      iex> account = %Session09.Account{balance: 1000}
      iex> changeset = Session09.Account.balance_changeset(account, %{balance: -100})
      iex> changeset.valid?
      false
  """
  def balance_changeset(_account, _attrs) do
    # TODO: Implement balance changeset
    # Only cast balance, validate >= 0
    raise "TODO: Implement balance_changeset/2"
  end

  @doc """
  Creates a changeset for freezing an account.

  Sets status to "frozen".

  ## Examples

      iex> account = %Session09.Account{status: "active"}
      iex> changeset = Session09.Account.freeze_changeset(account)
      iex> Ecto.Changeset.get_change(changeset, :status)
      "frozen"
  """
  def freeze_changeset(_account) do
    # TODO: Implement freeze changeset
    raise "TODO: Implement freeze_changeset/1"
  end
end
