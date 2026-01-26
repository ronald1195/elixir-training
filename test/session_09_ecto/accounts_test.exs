defmodule Session09.AccountsTest do
  use ExUnit.Case, async: false
  @moduletag :pending

  alias Session09.{Account, Accounts}

  # Note: These tests are designed to work without a real database.
  # In a real project, you'd use Ecto.Adapters.SQL.Sandbox.
  # For this training exercise, tests verify the logic structure.

  describe "Account schema and changesets" do
    test "changeset with valid data is valid" do
      attrs = %{
        account_number: "ACC-123456",
        holder_name: "John Doe",
        email: "john@example.com",
        account_type: "checking"
      }

      changeset = Account.changeset(%Account{}, attrs)
      assert changeset.valid?
    end

    test "changeset requires account_number" do
      attrs = %{holder_name: "John", email: "john@example.com", account_type: "checking"}
      changeset = Account.changeset(%Account{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).account_number
    end

    test "changeset requires holder_name" do
      attrs = %{account_number: "ACC-123456", email: "john@example.com", account_type: "checking"}
      changeset = Account.changeset(%Account{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).holder_name
    end

    test "changeset requires email" do
      attrs = %{account_number: "ACC-123456", holder_name: "John", account_type: "checking"}
      changeset = Account.changeset(%Account{}, attrs)
      refute changeset.valid?
      assert "can't be blank" in errors_on(changeset).email
    end

    test "changeset validates email format" do
      attrs = %{
        account_number: "ACC-123456",
        holder_name: "John",
        email: "invalid-email",
        account_type: "checking"
      }

      changeset = Account.changeset(%Account{}, attrs)
      refute changeset.valid?
    end

    test "changeset validates account_type inclusion" do
      attrs = %{
        account_number: "ACC-123456",
        holder_name: "John",
        email: "john@example.com",
        account_type: "invalid"
      }

      changeset = Account.changeset(%Account{}, attrs)
      refute changeset.valid?
    end

    test "changeset validates balance >= 0" do
      attrs = %{
        account_number: "ACC-123456",
        holder_name: "John",
        email: "john@example.com",
        account_type: "checking",
        balance: -100
      }

      changeset = Account.changeset(%Account{}, attrs)
      refute changeset.valid?
    end

    test "update_changeset only allows specific fields" do
      account = %Account{
        account_number: "ACC-123456",
        holder_name: "Old Name",
        email: "old@example.com",
        account_type: "checking"
      }

      changeset =
        Account.update_changeset(account, %{
          holder_name: "New Name",
          # Should not change
          account_number: "ACC-999999"
        })

      assert Ecto.Changeset.get_change(changeset, :holder_name) == "New Name"
      assert Ecto.Changeset.get_change(changeset, :account_number) == nil
    end

    test "balance_changeset validates balance >= 0" do
      account = %Account{balance: 1000}

      valid_changeset = Account.balance_changeset(account, %{balance: 500})
      assert valid_changeset.valid?

      invalid_changeset = Account.balance_changeset(account, %{balance: -100})
      refute invalid_changeset.valid?
    end

    test "freeze_changeset sets status to frozen" do
      account = %Account{status: "active"}
      changeset = Account.freeze_changeset(account)

      assert Ecto.Changeset.get_change(changeset, :status) == "frozen"
    end
  end

  describe "Accounts context - basic operations" do
    # Note: These tests assume mocked Repo operations
    # In a real test setup, you'd use Ecto.Adapters.SQL.Sandbox

    test "deposit increases balance" do
      account = %Account{balance: 1000, status: "active"}

      {:ok, updated} = Accounts.deposit(account, 500)

      assert updated.balance == 1500
    end

    test "deposit fails for inactive account" do
      account = %Account{balance: 1000, status: "frozen"}

      assert {:error, :account_not_active} = Accounts.deposit(account, 500)
    end

    test "deposit fails for non-positive amount" do
      account = %Account{balance: 1000, status: "active"}

      assert {:error, :invalid_amount} = Accounts.deposit(account, 0)
      assert {:error, :invalid_amount} = Accounts.deposit(account, -100)
    end

    test "withdraw decreases balance" do
      account = %Account{balance: 1000, status: "active"}

      {:ok, updated} = Accounts.withdraw(account, 300)

      assert updated.balance == 700
    end

    test "withdraw fails for insufficient balance" do
      account = %Account{balance: 1000, status: "active"}

      assert {:error, :insufficient_funds} = Accounts.withdraw(account, 1500)
    end

    test "withdraw fails for frozen account" do
      account = %Account{balance: 1000, status: "frozen"}

      assert {:error, :account_not_active} = Accounts.withdraw(account, 100)
    end

    test "withdraw respects daily_limit" do
      account = %Account{balance: 10000, status: "active", daily_limit: 500}

      assert {:error, :exceeds_daily_limit} = Accounts.withdraw(account, 600)
      assert {:ok, _} = Accounts.withdraw(account, 400)
    end
  end

  describe "Accounts context - transfer" do
    test "transfer moves funds between accounts" do
      from = %Account{id: 1, balance: 1000, status: "active"}
      to = %Account{id: 2, balance: 500, status: "active"}

      {:ok, result} = Accounts.transfer(from, to, 300)

      assert result.from.balance == 700
      assert result.to.balance == 800
    end

    test "transfer fails if sender has insufficient funds" do
      from = %Account{id: 1, balance: 100, status: "active"}
      to = %Account{id: 2, balance: 500, status: "active"}

      assert {:error, _} = Accounts.transfer(from, to, 300)
    end

    test "transfer fails if sender is frozen" do
      from = %Account{id: 1, balance: 1000, status: "frozen"}
      to = %Account{id: 2, balance: 500, status: "active"}

      assert {:error, :account_not_active} = Accounts.transfer(from, to, 300)
    end
  end

  # Helper to extract errors from changeset
  defp errors_on(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
        opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
      end)
    end)
  end
end
