defmodule Session14.CreditLimitService do
  @moduledoc """
  Solution for Session 14: Credit Limit gRPC Service
  """

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

  # Simulated data store
  @accounts %{
    "ACC-001" => %{limit: 10000, utilized: 3000},
    "ACC-002" => %{limit: 25000, utilized: 12000}
  }

  def check_limit(%CheckLimitRequest{account_id: account_id}) do
    case get_account_credit(account_id) do
      {:ok, credit} ->
        %CheckLimitResponse{
          account_id: account_id,
          limit: credit.limit,
          available: calculate_available(credit.limit, credit.utilized),
          utilized: credit.utilized
        }

      {:error, _} = error ->
        error
    end
  end

  def update_limit(%UpdateLimitRequest{account_id: account_id, new_limit: new_limit} = request) do
    with :ok <- validate_update(request),
         {:ok, credit} <- get_account_credit(account_id) do
      %LimitUpdate{
        account_id: account_id,
        previous_limit: credit.limit,
        new_limit: new_limit,
        timestamp: DateTime.utc_now()
      }
    end
  end

  def validate_update(%UpdateLimitRequest{new_limit: new_limit}) when new_limit <= 0 do
    {:error, :invalid_limit}
  end

  def validate_update(%UpdateLimitRequest{account_id: nil}) do
    {:error, :missing_account_id}
  end

  def validate_update(_request), do: :ok

  def calculate_available(limit, utilized) do
    max(limit - utilized, 0)
  end

  def get_account_credit(account_id) do
    case Map.get(@accounts, account_id) do
      nil -> {:error, :not_found}
      credit -> {:ok, credit}
    end
  end

  def stream_updates(account_id, callback) do
    # In a real implementation, this would subscribe to PubSub
    spawn(fn ->
      Process.sleep(1000)
      callback.(%LimitUpdate{
        account_id: account_id,
        previous_limit: 10000,
        new_limit: 15000,
        timestamp: DateTime.utc_now()
      })
    end)

    :ok
  end
end
