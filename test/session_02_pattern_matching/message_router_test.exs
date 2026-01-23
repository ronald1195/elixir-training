defmodule Session02.MessageRouterTest do
  use ExUnit.Case, async: true

  alias Session02.MessageRouter

  describe "route_event/1" do
    test "routes payment.created event" do
      event = %{
        "type" => "payment.created",
        "payload" => %{"amount" => 100},
        "metadata" => %{"correlation_id" => "abc-123"}
      }

      assert MessageRouter.route_event(event) ==
               {:payment, :created, %{"amount" => 100}, "abc-123"}
    end

    test "routes payment.completed event" do
      event = %{
        "type" => "payment.completed",
        "payload" => %{"transaction_id" => "TXN-1"},
        "metadata" => %{"correlation_id" => "xyz"}
      }

      assert MessageRouter.route_event(event) ==
               {:payment, :completed, %{"transaction_id" => "TXN-1"}, "xyz"}
    end

    test "routes payment.failed event" do
      event = %{
        "type" => "payment.failed",
        "payload" => %{"reason" => "declined"},
        "metadata" => %{}
      }

      assert MessageRouter.route_event(event) ==
               {:payment, :failed, %{"reason" => "declined"}, nil}
    end

    test "routes account.opened event" do
      event = %{
        "type" => "account.opened",
        "payload" => %{"id" => "ACC-1"},
        "metadata" => %{"correlation_id" => "cor-1"}
      }

      assert MessageRouter.route_event(event) ==
               {:account, :opened, %{"id" => "ACC-1"}, "cor-1"}
    end

    test "routes account.closed event" do
      event = %{
        "type" => "account.closed",
        "payload" => %{"id" => "ACC-1"},
        "metadata" => %{}
      }

      assert MessageRouter.route_event(event) ==
               {:account, :closed, %{"id" => "ACC-1"}, nil}
    end

    test "routes account.updated event" do
      event = %{
        "type" => "account.updated",
        "payload" => %{"changes" => %{}},
        "metadata" => %{}
      }

      assert MessageRouter.route_event(event) ==
               {:account, :updated, %{"changes" => %{}}, nil}
    end

    test "handles unknown event type" do
      event = %{
        "type" => "unknown.event",
        "payload" => %{"data" => "test"},
        "metadata" => %{}
      }

      assert MessageRouter.route_event(event) ==
               {:unknown, "unknown.event", %{"data" => "test"}, nil}
    end
  end

  describe "route_webhook/1" do
    test "routes invoice.paid webhook" do
      webhook = %{"event" => "invoice.paid", "data" => %{"invoice_id" => "INV-1"}}

      assert MessageRouter.route_webhook(webhook) ==
               {:invoice, :paid, %{"invoice_id" => "INV-1"}}
    end

    test "routes invoice.created webhook" do
      webhook = %{"event" => "invoice.created", "data" => %{"amount" => 1000}}

      assert MessageRouter.route_webhook(webhook) ==
               {:invoice, :created, %{"amount" => 1000}}
    end

    test "routes invoice.overdue webhook" do
      webhook = %{"event" => "invoice.overdue", "data" => %{"days_overdue" => 30}}

      assert MessageRouter.route_webhook(webhook) ==
               {:invoice, :overdue, %{"days_overdue" => 30}}
    end

    test "routes customer.created webhook" do
      webhook = %{"event" => "customer.created", "data" => %{"customer_id" => "CUST-1"}}

      assert MessageRouter.route_webhook(webhook) ==
               {:customer, :created, %{"customer_id" => "CUST-1"}}
    end

    test "routes customer.updated webhook" do
      webhook = %{"event" => "customer.updated", "data" => %{"changes" => ["email"]}}

      assert MessageRouter.route_webhook(webhook) ==
               {:customer, :updated, %{"changes" => ["email"]}}
    end

    test "handles unknown webhook event" do
      webhook = %{"event" => "subscription.cancelled", "data" => %{}}

      assert MessageRouter.route_webhook(webhook) ==
               {:unknown, "subscription.cancelled", %{}}
    end
  end

  describe "should_process?/2" do
    test "ignores test events in production" do
      event = %{"type" => "payment.created", "metadata" => %{"test" => true}}

      assert MessageRouter.should_process?(event, :production) == {:ignore, :test_event}
    end

    test "processes test events in development" do
      event = %{"type" => "payment.created", "metadata" => %{"test" => true}}

      assert MessageRouter.should_process?(event, :development) == {:process, event}
    end

    test "ignores duplicate events" do
      event = %{"type" => "payment.created", "metadata" => %{"duplicate" => true}}

      assert MessageRouter.should_process?(event, :production) == {:ignore, :duplicate}
    end

    test "ignores duplicate events even in development" do
      event = %{"type" => "payment.created", "metadata" => %{"duplicate" => true}}

      assert MessageRouter.should_process?(event, :development) == {:ignore, :duplicate}
    end

    test "processes normal events in production" do
      event = %{"type" => "payment.created", "metadata" => %{}}

      assert MessageRouter.should_process?(event, :production) == {:process, event}
    end

    test "processes normal events in development" do
      event = %{"type" => "payment.created", "metadata" => %{}}

      assert MessageRouter.should_process?(event, :development) == {:process, event}
    end

    test "processes events without metadata" do
      event = %{"type" => "payment.created"}

      assert MessageRouter.should_process?(event, :production) == {:process, event}
    end
  end

  describe "extract_account_ids/1" do
    test "extracts single account_id" do
      event = %{"payload" => %{"account_id" => "ACC-1"}}

      assert MessageRouter.extract_account_ids(event) == ["ACC-1"]
    end

    test "extracts from_account and to_account" do
      event = %{"payload" => %{"from_account" => "ACC-1", "to_account" => "ACC-2"}}

      result = MessageRouter.extract_account_ids(event)
      assert "ACC-1" in result
      assert "ACC-2" in result
      assert length(result) == 2
    end

    test "extracts affected_accounts list" do
      event = %{"payload" => %{"affected_accounts" => ["ACC-1", "ACC-2", "ACC-3"]}}

      assert MessageRouter.extract_account_ids(event) == ["ACC-1", "ACC-2", "ACC-3"]
    end

    test "extracts nested account id" do
      event = %{"payload" => %{"data" => %{"account" => %{"id" => "ACC-1"}}}}

      assert MessageRouter.extract_account_ids(event) == ["ACC-1"]
    end

    test "returns empty list when no accounts found" do
      event = %{"payload" => %{"something_else" => "value"}}

      assert MessageRouter.extract_account_ids(event) == []
    end

    test "deduplicates account ids" do
      event = %{
        "payload" => %{
          "account_id" => "ACC-1",
          "affected_accounts" => ["ACC-1", "ACC-2"]
        }
      }

      result = MessageRouter.extract_account_ids(event)
      assert length(result) == length(Enum.uniq(result))
    end
  end

  describe "group_by_domain/1" do
    test "groups events by domain" do
      events = [
        %{"type" => "payment.created", "payload" => %{"id" => 1}},
        %{"type" => "account.opened", "payload" => %{"id" => 2}},
        %{"type" => "payment.failed", "payload" => %{"id" => 3}}
      ]

      result = MessageRouter.group_by_domain(events)

      assert Map.has_key?(result, :payment)
      assert Map.has_key?(result, :account)
      assert length(result.payment) == 2
      assert length(result.account) == 1
    end

    test "handles empty list" do
      assert MessageRouter.group_by_domain([]) == %{}
    end

    test "handles single domain" do
      events = [
        %{"type" => "payment.created", "payload" => %{}},
        %{"type" => "payment.completed", "payload" => %{}}
      ]

      result = MessageRouter.group_by_domain(events)

      assert Map.keys(result) == [:payment]
      assert length(result.payment) == 2
    end

    test "handles unknown domain" do
      events = [
        %{"type" => "custom.event", "payload" => %{}}
      ]

      result = MessageRouter.group_by_domain(events)

      assert Map.has_key?(result, :custom)
    end
  end
end
