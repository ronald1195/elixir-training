defmodule Session14.CreditLimitService do
  @moduledoc """
  gRPC service for credit limit checking.

  ## Your Task
  Implement a gRPC service that:
  1. Checks credit limits for accounts
  2. Returns available credit
  3. Supports streaming updates
  """

  # Simulated protobuf messages
  defmodule CheckLimitRequest do
    defstruct [:account_id]
  end

  defmodule CheckLimitResponse do
    defstruct [:account_id, :limit, :available, :utilized]
  end

  defmodule UpdateLimitRequest do
    defstruct [:account_id, :new_limit]
  end

  defmodule LimitUpdate do
    defstruct [:account_id, :previous_limit, :new_limit, :timestamp]
  end

  @doc """
  Checks the credit limit for an account.

  Returns the current limit and available credit.
  """
  def check_limit(_request) do
    # TODO: Look up account and return limit info
    raise "TODO: Implement check_limit/1"
  end

  @doc """
  Updates the credit limit for an account.
  """
  def update_limit(_request) do
    # TODO: Validate and update limit
    raise "TODO: Implement update_limit/1"
  end

  @doc """
  Validates a limit update request.
  """
  def validate_update(_request) do
    # TODO: Ensure new_limit is positive, account exists
    raise "TODO: Implement validate_update/1"
  end

  @doc """
  Calculates available credit.
  """
  def calculate_available(_limit, _utilized) do
    # TODO: Return limit - utilized
    raise "TODO: Implement calculate_available/2"
  end

  @doc """
  Gets account credit info from storage.
  """
  def get_account_credit(_account_id) do
    # TODO: Fetch from database/cache
    raise "TODO: Implement get_account_credit/1"
  end

  @doc """
  Streams limit updates for an account.
  """
  def stream_updates(_account_id, _callback) do
    # TODO: Subscribe to limit changes and stream
    raise "TODO: Implement stream_updates/2"
  end
end
