defmodule Session09.Account do
  @moduledoc """
  Solution for Session 09: Account Schema
  """

  use Ecto.Schema
  import Ecto.Changeset

  schema "accounts" do
    field :account_number, :string
    field :holder_name, :string
    field :email, :string
    field :balance, :integer, default: 0
    field :status, :string, default: "active"
    field :account_type, :string
    field :daily_limit, :integer

    timestamps()
  end

  def changeset(account, attrs) do
    account
    |> cast(attrs, [:account_number, :holder_name, :email, :balance, :status, :account_type, :daily_limit])
    |> validate_required([:account_number, :holder_name, :email, :account_type])
    |> validate_format(:email, ~r/@/)
    |> validate_format(:account_number, ~r/^ACC-\d{6}$/)
    |> validate_length(:holder_name, min: 2, max: 100)
    |> validate_number(:balance, greater_than_or_equal_to: 0)
    |> validate_inclusion(:status, ["active", "frozen", "closed"])
    |> validate_inclusion(:account_type, ["checking", "savings", "business"])
    |> validate_number(:daily_limit, greater_than: 0)
    |> unique_constraint(:account_number)
  end

  def update_changeset(account, attrs) do
    account
    |> cast(attrs, [:holder_name, :email, :status, :daily_limit])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:holder_name, min: 2, max: 100)
    |> validate_inclusion(:status, ["active", "frozen", "closed"])
    |> validate_number(:daily_limit, greater_than: 0)
  end

  def balance_changeset(account, attrs) do
    account
    |> cast(attrs, [:balance])
    |> validate_number(:balance, greater_than_or_equal_to: 0)
  end

  def freeze_changeset(account) do
    change(account, status: "frozen")
  end
end
