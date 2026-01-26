defmodule Session09.Accounts do
  @moduledoc """
  Solution for Session 09: Accounts Context
  """

  import Ecto.Query
  alias Session09.Account
  alias ElixirTraining.Repo
  alias Ecto.Multi

  # CRUD Operations

  def create_account(attrs) do
    %Account{}
    |> Account.changeset(attrs)
    |> Repo.insert()
  end

  def get_account(id) do
    Repo.get(Account, id)
  end

  def get_account!(id) do
    Repo.get!(Account, id)
  end

  def get_by_account_number(account_number) do
    Repo.get_by(Account, account_number: account_number)
  end

  def update_account(account, attrs) do
    account
    |> Account.update_changeset(attrs)
    |> Repo.update()
  end

  def delete_account(account) do
    Repo.delete(account)
  end

  # Query Operations

  def list_accounts do
    Repo.all(Account)
  end

  def list_accounts_by_status(status) do
    Account
    |> where([a], a.status == ^status)
    |> Repo.all()
  end

  def list_accounts_above_balance(min_balance) do
    Account
    |> where([a], a.balance > ^min_balance)
    |> order_by([a], desc: a.balance)
    |> Repo.all()
  end

  def search_by_name(query) do
    search_term = "%#{query}%"

    Account
    |> where([a], ilike(a.holder_name, ^search_term))
    |> Repo.all()
  end

  def get_statistics do
    query =
      from a in Account,
        select: %{
          total_accounts: count(a.id),
          total_balance: sum(a.balance),
          average_balance: avg(a.balance)
        }

    active_query =
      from a in Account,
        where: a.status == "active",
        select: count(a.id)

    stats = Repo.one(query) || %{total_accounts: 0, total_balance: 0, average_balance: 0}
    active_count = Repo.one(active_query) || 0

    Map.put(stats, :active_accounts, active_count)
  end

  # Business Logic

  def deposit(account, amount) when amount <= 0 do
    {:error, :invalid_amount}
  end

  def deposit(%{status: status}, _amount) when status != "active" do
    {:error, :account_not_active}
  end

  def deposit(account, amount) do
    new_balance = account.balance + amount

    account
    |> Account.balance_changeset(%{balance: new_balance})
    |> Repo.update()
  end

  def withdraw(account, amount) when amount <= 0 do
    {:error, :invalid_amount}
  end

  def withdraw(%{status: status}, _amount) when status != "active" do
    {:error, :account_not_active}
  end

  def withdraw(%{balance: balance}, amount) when amount > balance do
    {:error, :insufficient_funds}
  end

  def withdraw(%{daily_limit: limit}, amount) when not is_nil(limit) and amount > limit do
    {:error, :exceeds_daily_limit}
  end

  def withdraw(account, amount) do
    new_balance = account.balance - amount

    account
    |> Account.balance_changeset(%{balance: new_balance})
    |> Repo.update()
  end

  def transfer(%{status: status}, _to, _amount) when status != "active" do
    {:error, :account_not_active}
  end

  def transfer(_from, %{status: status}, _amount) when status != "active" do
    {:error, :recipient_not_active}
  end

  def transfer(from, to, amount) do
    Multi.new()
    |> Multi.run(:validate, fn _repo, _changes ->
      cond do
        amount <= 0 -> {:error, :invalid_amount}
        from.balance < amount -> {:error, :insufficient_funds}
        true -> {:ok, :valid}
      end
    end)
    |> Multi.update(:from, Account.balance_changeset(from, %{balance: from.balance - amount}))
    |> Multi.update(:to, Account.balance_changeset(to, %{balance: to.balance + amount}))
    |> Repo.transaction()
    |> case do
      {:ok, %{from: from, to: to}} -> {:ok, %{from: from, to: to}}
      {:error, :validate, reason, _} -> {:error, reason}
      {:error, step, changeset, _} -> {:error, {step, changeset}}
    end
  end

  def freeze_account(account) do
    account
    |> Account.freeze_changeset()
    |> Repo.update()
  end

  def activate_account(account) do
    account
    |> Ecto.Changeset.change(status: "active")
    |> Repo.update()
  end
end
