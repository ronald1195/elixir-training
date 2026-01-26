defmodule Session09.Accounts do
  @moduledoc """
  The Accounts context - business logic for account operations.

  ## Background for OOP Developers

  In Java/C#, this would be a Service class:

      @Service
      public class AccountService {
          @Autowired
          private AccountRepository accountRepository;

          public Account create(CreateAccountDTO dto) { ... }
          public Account deposit(Long accountId, BigDecimal amount) { ... }
      }

  In Elixir, the context module provides a clean public API
  for all account-related operations.

  ## Your Task

  Implement the context functions for CRUD operations and business logic.
  """

  import Ecto.Query
  alias Session09.Account
  alias ElixirTraining.Repo

  # ============================================================================
  # CRUD Operations
  # ============================================================================

  @doc """
  Creates a new account.

  Returns `{:ok, account}` or `{:error, changeset}`.

  ## Examples

      iex> {:ok, account} = Session09.Accounts.create_account(%{
      ...>   account_number: "ACC-123456",
      ...>   holder_name: "John Doe",
      ...>   email: "john@example.com",
      ...>   account_type: "checking"
      ...> })
      iex> account.holder_name
      "John Doe"
  """
  def create_account(_attrs) do
    # TODO: Create an account using Account.changeset and Repo.insert
    raise "TODO: Implement create_account/1"
  end

  @doc """
  Gets an account by ID.

  Returns `nil` if not found.

  ## Examples

      iex> Session09.Accounts.get_account(123)
      %Session09.Account{}

      iex> Session09.Accounts.get_account(999)
      nil
  """
  def get_account(_id) do
    # TODO: Fetch account by ID using Repo.get
    raise "TODO: Implement get_account/1"
  end

  @doc """
  Gets an account by ID, raising if not found.

  ## Examples

      iex> Session09.Accounts.get_account!(123)
      %Session09.Account{}
  """
  def get_account!(_id) do
    # TODO: Fetch account by ID using Repo.get!
    raise "TODO: Implement get_account!/1"
  end

  @doc """
  Gets an account by account number.

  ## Examples

      iex> Session09.Accounts.get_by_account_number("ACC-123456")
      %Session09.Account{}
  """
  def get_by_account_number(_account_number) do
    # TODO: Fetch account by account_number using Repo.get_by
    raise "TODO: Implement get_by_account_number/1"
  end

  @doc """
  Updates an account.

  Returns `{:ok, account}` or `{:error, changeset}`.

  ## Examples

      iex> {:ok, updated} = Session09.Accounts.update_account(account, %{holder_name: "New Name"})
      iex> updated.holder_name
      "New Name"
  """
  def update_account(_account, _attrs) do
    # TODO: Update account using Account.update_changeset and Repo.update
    raise "TODO: Implement update_account/2"
  end

  @doc """
  Deletes an account.

  Returns `{:ok, account}` or `{:error, changeset}`.
  """
  def delete_account(_account) do
    # TODO: Delete account using Repo.delete
    raise "TODO: Implement delete_account/1"
  end

  # ============================================================================
  # Query Operations
  # ============================================================================

  @doc """
  Lists all accounts.

  ## Examples

      iex> Session09.Accounts.list_accounts()
      [%Session09.Account{}, ...]
  """
  def list_accounts do
    # TODO: Fetch all accounts using Repo.all
    raise "TODO: Implement list_accounts/0"
  end

  @doc """
  Lists accounts with the given status.

  ## Examples

      iex> Session09.Accounts.list_accounts_by_status("active")
      [%Session09.Account{status: "active"}, ...]
  """
  def list_accounts_by_status(_status) do
    # TODO: Query accounts by status
    # Hint: Account |> where([a], a.status == ^status) |> Repo.all()
    raise "TODO: Implement list_accounts_by_status/1"
  end

  @doc """
  Lists accounts with balance above the given amount.

  Results are ordered by balance descending.

  ## Examples

      iex> Session09.Accounts.list_accounts_above_balance(10000)
      [%Session09.Account{balance: 50000}, %Session09.Account{balance: 25000}]
  """
  def list_accounts_above_balance(_min_balance) do
    # TODO: Query accounts with balance > min_balance, ordered by balance desc
    raise "TODO: Implement list_accounts_above_balance/1"
  end

  @doc """
  Searches accounts by holder name (case-insensitive partial match).

  ## Examples

      iex> Session09.Accounts.search_by_name("john")
      [%Session09.Account{holder_name: "John Doe"}, %Session09.Account{holder_name: "Johnny Smith"}]
  """
  def search_by_name(_query) do
    # TODO: Search accounts using ilike
    # Hint: where([a], ilike(a.holder_name, ^"%#{query}%"))
    raise "TODO: Implement search_by_name/1"
  end

  @doc """
  Returns aggregate statistics for all accounts.

  ## Examples

      iex> Session09.Accounts.get_statistics()
      %{
        total_accounts: 100,
        total_balance: 5_000_000,
        average_balance: 50_000,
        active_accounts: 85
      }
  """
  def get_statistics do
    # TODO: Use aggregate queries to calculate statistics
    # Hint: select([a], %{total: count(a.id), sum: sum(a.balance)})
    raise "TODO: Implement get_statistics/0"
  end

  # ============================================================================
  # Business Logic
  # ============================================================================

  @doc """
  Deposits amount into an account.

  Amount is in cents. Returns `{:ok, account}` or `{:error, reason}`.

  Rules:
  - Account must be active
  - Amount must be positive

  ## Examples

      iex> {:ok, account} = Session09.Accounts.deposit(account, 10000)
      iex> account.balance
      11000  # Previous balance was 1000
  """
  def deposit(_account, _amount) do
    # TODO: Implement deposit
    # 1. Check account is active
    # 2. Validate amount > 0
    # 3. Update balance using Account.balance_changeset
    raise "TODO: Implement deposit/2"
  end

  @doc """
  Withdraws amount from an account.

  Amount is in cents. Returns `{:ok, account}` or `{:error, reason}`.

  Rules:
  - Account must be active
  - Amount must be positive
  - Amount must not exceed balance
  - Amount must not exceed daily_limit (if set)

  ## Examples

      iex> {:ok, account} = Session09.Accounts.withdraw(account, 5000)
      iex> account.balance
      5000  # Previous balance was 10000
  """
  def withdraw(_account, _amount) do
    # TODO: Implement withdraw
    # 1. Check account is active
    # 2. Validate amount > 0
    # 3. Validate amount <= balance
    # 4. Validate amount <= daily_limit (if daily_limit is set)
    # 5. Update balance
    raise "TODO: Implement withdraw/2"
  end

  @doc """
  Transfers amount between two accounts.

  Uses a database transaction to ensure atomicity.

  Returns `{:ok, %{from: account, to: account}}` or `{:error, reason}`.

  ## Examples

      iex> {:ok, result} = Session09.Accounts.transfer(from_account, to_account, 5000)
      iex> result.from.balance
      5000  # Decreased by 5000
      iex> result.to.balance
      15000  # Increased by 5000
  """
  def transfer(_from_account, _to_account, _amount) do
    # TODO: Implement transfer using Ecto.Multi
    # 1. Create Multi
    # 2. Add withdrawal from sender
    # 3. Add deposit to receiver
    # 4. Execute transaction
    raise "TODO: Implement transfer/3"
  end

  @doc """
  Freezes an account, preventing all transactions.

  ## Examples

      iex> {:ok, frozen} = Session09.Accounts.freeze_account(account)
      iex> frozen.status
      "frozen"
  """
  def freeze_account(_account) do
    # TODO: Implement freeze using Account.freeze_changeset
    raise "TODO: Implement freeze_account/1"
  end

  @doc """
  Activates a frozen account.

  ## Examples

      iex> {:ok, active} = Session09.Accounts.activate_account(frozen_account)
      iex> active.status
      "active"
  """
  def activate_account(_account) do
    # TODO: Change status to "active"
    raise "TODO: Implement activate_account/1"
  end
end
