defmodule Session04.ProjectExplorerTest do
  use ExUnit.Case, async: true
  @moduletag :pending

  alias Session04.ProjectExplorer

  describe "direct_dependencies/2" do
    test "returns direct dependencies for a module" do
      deps = %{A: [:B, :C], B: [:C], C: []}
      assert ProjectExplorer.direct_dependencies(deps, :A) == [:B, :C]
    end

    test "returns empty list for module with no dependencies" do
      deps = %{A: [:B], B: []}
      assert ProjectExplorer.direct_dependencies(deps, :B) == []
    end

    test "returns empty list for unknown module" do
      deps = %{A: [:B], B: []}
      assert ProjectExplorer.direct_dependencies(deps, :unknown) == []
    end

    test "handles complex module names" do
      deps = %{MyApp.Payments.Processor => [MyApp.Core.Money], MyApp.Core.Money => []}

      assert ProjectExplorer.direct_dependencies(deps, MyApp.Payments.Processor) == [
               MyApp.Core.Money
             ]
    end
  end

  describe "transitive_dependencies/2" do
    test "returns all transitive dependencies" do
      deps = %{A: [:B], B: [:C], C: [:D], D: []}
      assert ProjectExplorer.transitive_dependencies(deps, :A) == [:B, :C, :D]
    end

    test "handles diamond dependencies without duplicates" do
      deps = %{A: [:B, :C], B: [:D], C: [:D], D: []}
      result = ProjectExplorer.transitive_dependencies(deps, :A)
      assert Enum.sort(result) == [:B, :C, :D]
      assert length(result) == 3
    end

    test "returns empty list for module with no dependencies" do
      deps = %{A: [:B], B: []}
      assert ProjectExplorer.transitive_dependencies(deps, :B) == []
    end

    test "handles single level dependencies" do
      deps = %{A: [:B, :C], B: [], C: []}
      result = ProjectExplorer.transitive_dependencies(deps, :A)
      assert Enum.sort(result) == [:B, :C]
    end

    test "handles unknown module" do
      deps = %{A: [:B], B: []}
      assert ProjectExplorer.transitive_dependencies(deps, :unknown) == []
    end
  end

  describe "detect_cycles/1" do
    test "returns ok when no cycles exist" do
      deps = %{A: [:B], B: [:C], C: []}
      assert ProjectExplorer.detect_cycles(deps) == {:ok, []}
    end

    test "detects simple cycle" do
      deps = %{A: [:B], B: [:A]}
      assert {:error, cycle} = ProjectExplorer.detect_cycles(deps)
      assert length(cycle) >= 2
    end

    test "detects self-referential cycle" do
      deps = %{A: [:A]}
      assert {:error, cycle} = ProjectExplorer.detect_cycles(deps)
      assert :A in cycle
    end

    test "detects longer cycle" do
      deps = %{A: [:B], B: [:C], C: [:A]}
      assert {:error, cycle} = ProjectExplorer.detect_cycles(deps)
      assert length(cycle) >= 3
    end

    test "handles graph with multiple disconnected components" do
      deps = %{A: [:B], B: [], C: [:D], D: []}
      assert ProjectExplorer.detect_cycles(deps) == {:ok, []}
    end

    test "handles empty dependency map" do
      assert ProjectExplorer.detect_cycles(%{}) == {:ok, []}
    end
  end

  describe "get_context/1" do
    test "extracts context from nested module" do
      assert ProjectExplorer.get_context(MyApp.Payments.Processor) == :Payments
    end

    test "extracts context from deeply nested module" do
      assert ProjectExplorer.get_context(MyApp.Accounts.Users.Profile) == :Accounts
    end

    test "handles two-part module" do
      assert ProjectExplorer.get_context(MyApp.Core) == :Core
    end

    test "handles single atom module" do
      assert ProjectExplorer.get_context(:simple_module) == :simple_module
    end
  end

  describe "group_by_context/1" do
    test "groups modules by context" do
      modules = [MyApp.Payments.Processor, MyApp.Payments.Refund, MyApp.Accounts.User]
      result = ProjectExplorer.group_by_context(modules)

      assert Map.has_key?(result, :Payments)
      assert Map.has_key?(result, :Accounts)
      assert length(result[:Payments]) == 2
      assert length(result[:Accounts]) == 1
    end

    test "handles empty list" do
      assert ProjectExplorer.group_by_context([]) == %{}
    end

    test "handles single module" do
      modules = [MyApp.Payments.Processor]
      result = ProjectExplorer.group_by_context(modules)
      assert result == %{Payments: [MyApp.Payments.Processor]}
    end
  end

  describe "cross_context_dependencies/1" do
    test "finds all cross-context dependencies" do
      deps = %{
        MyApp.Payments.Processor => [MyApp.Accounts.Balance, MyApp.Core.Money],
        MyApp.Accounts.Balance => [MyApp.Core.Money],
        MyApp.Core.Money => []
      }

      result = ProjectExplorer.cross_context_dependencies(deps)

      assert {MyApp.Payments.Processor, MyApp.Accounts.Balance} in result
      assert {MyApp.Payments.Processor, MyApp.Core.Money} in result
      assert {MyApp.Accounts.Balance, MyApp.Core.Money} in result
    end

    test "excludes same-context dependencies" do
      deps = %{
        MyApp.Payments.Processor => [MyApp.Payments.Validator],
        MyApp.Payments.Validator => []
      }

      result = ProjectExplorer.cross_context_dependencies(deps)
      assert result == []
    end

    test "handles empty map" do
      assert ProjectExplorer.cross_context_dependencies(%{}) == []
    end
  end

  describe "validate_layer_dependencies/2" do
    test "validates correct layer dependencies" do
      layers = [:Core, :Domain, :Application, :Web]

      deps = %{
        MyApp.Web.Controller => [MyApp.Application.Service],
        MyApp.Application.Service => [MyApp.Domain.Entity],
        MyApp.Domain.Entity => [MyApp.Core.Types],
        MyApp.Core.Types => []
      }

      assert ProjectExplorer.validate_layer_dependencies(deps, layers) == {:ok, :valid}
    end

    test "detects layer violation" do
      layers = [:Core, :Domain, :Application, :Web]
      deps = %{MyApp.Core.Types => [MyApp.Web.Controller]}

      assert {:error, violations} = ProjectExplorer.validate_layer_dependencies(deps, layers)
      assert {MyApp.Core.Types, MyApp.Web.Controller} in violations
    end

    test "allows same-layer dependencies" do
      layers = [:Core, :Domain, :Application, :Web]
      deps = %{MyApp.Domain.Entity1 => [MyApp.Domain.Entity2], MyApp.Domain.Entity2 => []}

      assert ProjectExplorer.validate_layer_dependencies(deps, layers) == {:ok, :valid}
    end

    test "handles empty dependency map" do
      layers = [:Core, :Domain]
      assert ProjectExplorer.validate_layer_dependencies(%{}, layers) == {:ok, :valid}
    end
  end

  describe "calculate_instability/1" do
    test "calculates instability for all modules" do
      deps = %{A: [:B, :C], B: [:C], C: []}
      result = ProjectExplorer.calculate_instability(deps)

      # A: Ce=2, Ca=0 -> 2/(0+2) = 1.0
      assert result[:A] == 1.0
      # B: Ce=1, Ca=1 -> 1/(1+1) = 0.5
      assert result[:B] == 0.5
      # C: Ce=0, Ca=2 -> 0/(2+0) = 0.0
      assert result[:C] == 0.0
    end

    test "handles module with no connections" do
      deps = %{A: []}
      result = ProjectExplorer.calculate_instability(deps)
      # No connections means 0.0 instability (or could be undefined, we'll use 0.0)
      assert result[:A] == 0.0
    end

    test "handles empty map" do
      assert ProjectExplorer.calculate_instability(%{}) == %{}
    end
  end

  describe "dependency_graph_text/1" do
    test "generates text representation" do
      deps = %{A: [:B, :C], B: [:C], C: []}
      result = ProjectExplorer.dependency_graph_text(deps)

      assert result =~ "A"
      assert result =~ "-> B"
      assert result =~ "-> C"
      assert result =~ "(no dependencies)"
    end

    test "handles empty map" do
      result = ProjectExplorer.dependency_graph_text(%{})
      assert result == "" or result == "\n"
    end

    test "sorts modules alphabetically" do
      deps = %{C: [], B: [], A: []}
      result = ProjectExplorer.dependency_graph_text(deps)

      # A should appear before B which appears before C
      a_pos = :binary.match(result, "A") |> elem(0)
      b_pos = :binary.match(result, "B") |> elem(0)
      c_pos = :binary.match(result, "C") |> elem(0)

      assert a_pos < b_pos
      assert b_pos < c_pos
    end
  end

  describe "find_hubs/2" do
    test "finds modules with high connectivity" do
      deps = %{A: [:B, :C, :D], B: [:C], C: [], D: [:C]}
      result = ProjectExplorer.find_hubs(deps, 3)

      # C has 3 incoming (from A, B, D) + 0 outgoing = 3 connections
      # A has 0 incoming + 3 outgoing = 3 connections
      assert {:C, 3} in result or {:C, 4} in result
      assert {:A, 3} in result
    end

    test "returns empty list when no modules meet threshold" do
      deps = %{A: [:B], B: []}
      result = ProjectExplorer.find_hubs(deps, 10)
      assert result == []
    end

    test "sorts by connectivity descending" do
      deps = %{A: [:B, :C, :D, :E], B: [:C], C: [], D: [], E: []}
      result = ProjectExplorer.find_hubs(deps, 1)

      # A should be first (highest connectivity)
      [{first_module, _} | _] = result
      assert first_module == :A
    end

    test "handles empty map" do
      assert ProjectExplorer.find_hubs(%{}, 1) == []
    end
  end
end
