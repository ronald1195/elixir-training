defmodule Session14.CreditLimitServiceTest do
  use ExUnit.Case, async: true
  @moduletag :pending

  alias Session14.CreditLimitService
  alias Session14.CreditLimitService.{CheckLimitRequest, CheckLimitResponse}

  describe "check_limit/1" do
    test "returns limit info for valid account" do
      request = %CheckLimitRequest{account_id: "ACC-001"}
      response = CreditLimitService.check_limit(request)

      assert %CheckLimitResponse{} = response
      assert response.account_id == "ACC-001"
      assert response.limit > 0
    end

    test "returns error for unknown account" do
      request = %CheckLimitRequest{account_id: "UNKNOWN"}
      {:error, :not_found} = CreditLimitService.check_limit(request)
    end
  end

  describe "calculate_available/2" do
    test "returns limit minus utilized" do
      assert CreditLimitService.calculate_available(10000, 3000) == 7000
    end

    test "returns zero when fully utilized" do
      assert CreditLimitService.calculate_available(10000, 10000) == 0
    end
  end

  describe "validate_update/1" do
    test "accepts valid update request" do
      request = %Session14.CreditLimitService.UpdateLimitRequest{
        account_id: "ACC-001",
        new_limit: 15000
      }

      assert :ok = CreditLimitService.validate_update(request)
    end

    test "rejects negative limit" do
      request = %Session14.CreditLimitService.UpdateLimitRequest{
        account_id: "ACC-001",
        new_limit: -1000
      }

      {:error, :invalid_limit} = CreditLimitService.validate_update(request)
    end
  end
end
