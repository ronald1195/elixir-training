defmodule Session04.ProjectExplorer do
  @moduledoc """
  A module for analyzing Elixir project structure and dependencies.

  ## Background for OOP Developers

  In Java/C# enterprise projects, you might use tools like:
  - NDepend for .NET dependency analysis
  - JDepend for Java package dependencies
  - Architecture Decision Records (ADRs)

  In Elixir, we can analyze module dependencies to ensure:
  - Clean bounded context boundaries
  - No circular dependencies
  - Proper layered architecture

  ## Representing Dependencies

  We represent a project's dependencies as a map where:
  - Keys are module names (atoms)
  - Values are lists of modules that key depends on

  Example:
      %{
        MyApp.Web.PaymentController => [MyApp.Payments, MyApp.Accounts],
        MyApp.Payments => [MyApp.Core.Money],
        MyApp.Accounts => [MyApp.Core.Money],
        MyApp.Core.Money => []
      }

  ## Your Task

  Implement functions to analyze project structure and detect architectural issues.
  These functions work with the dependency map representation described above.
  """

  @doc """
  Returns all direct dependencies for a given module.

  ## Examples

      iex> deps = %{A: [:B, :C], B: [:C], C: []}
      iex> Session04.ProjectExplorer.direct_dependencies(deps, :A)
      [:B, :C]

      iex> deps = %{A: [:B], B: []}
      iex> Session04.ProjectExplorer.direct_dependencies(deps, :unknown)
      []
  """
  def direct_dependencies(_dependency_map, _module) do
    # TODO: Return the list of direct dependencies for the module
    # Return empty list if module is not in the map
    raise "TODO: Implement direct_dependencies/2"
  end

  @doc """
  Returns all transitive dependencies for a module (direct + indirect).

  If A depends on B and B depends on C, then A transitively depends on both B and C.

  ## Examples

      iex> deps = %{A: [:B], B: [:C], C: [:D], D: []}
      iex> Session04.ProjectExplorer.transitive_dependencies(deps, :A)
      [:B, :C, :D]

      iex> deps = %{A: [:B, :C], B: [:D], C: [:D], D: []}
      iex> Session04.ProjectExplorer.transitive_dependencies(deps, :A) |> Enum.sort()
      [:B, :C, :D]
  """
  def transitive_dependencies(_dependency_map, _module) do
    # TODO: Return all dependencies (direct and transitive)
    # Hint: Use recursion or a worklist algorithm
    # Hint: Be careful not to include duplicates
    raise "TODO: Implement transitive_dependencies/2"
  end

  @doc """
  Detects if there are any circular dependencies in the project.

  Returns `{:ok, []}` if no cycles found, or `{:error, cycle}` with
  one of the cycles found (as a list of modules forming the cycle).

  ## Examples

      iex> deps = %{A: [:B], B: [:C], C: []}
      iex> Session04.ProjectExplorer.detect_cycles(deps)
      {:ok, []}

      iex> deps = %{A: [:B], B: [:C], C: [:A]}
      iex> Session04.ProjectExplorer.detect_cycles(deps)
      {:error, [:A, :B, :C, :A]}

      iex> deps = %{A: [:A]}
      iex> Session04.ProjectExplorer.detect_cycles(deps)
      {:error, [:A, :A]}
  """
  def detect_cycles(_dependency_map) do
    # TODO: Detect circular dependencies using DFS
    # Hint: Track "visiting" (in current path) and "visited" (fully explored) nodes
    # Return the cycle path if found
    raise "TODO: Implement detect_cycles/1"
  end

  @doc """
  Extracts the context (top-level namespace) from a module name.

  We define a context as the first part of a module name after the app prefix.

  ## Examples

      iex> Session04.ProjectExplorer.get_context(MyApp.Payments.Processor)
      :Payments

      iex> Session04.ProjectExplorer.get_context(MyApp.Accounts.User)
      :Accounts

      iex> Session04.ProjectExplorer.get_context(MyApp.Core)
      :Core

      iex> Session04.ProjectExplorer.get_context(:simple_module)
      :simple_module
  """
  def get_context(_module) do
    # TODO: Extract the context (second part of the module path)
    # Hint: Use Module.split/1 to get the parts of a module name
    # If module has only one part, return that part as the context
    raise "TODO: Implement get_context/1"
  end

  @doc """
  Groups modules by their context.

  ## Examples

      iex> modules = [MyApp.Payments.Processor, MyApp.Payments.Refund, MyApp.Accounts.User]
      iex> Session04.ProjectExplorer.group_by_context(modules)
      %{Payments: [MyApp.Payments.Processor, MyApp.Payments.Refund], Accounts: [MyApp.Accounts.User]}
  """
  def group_by_context(_modules) do
    # TODO: Group the modules by their context
    # Hint: Use Enum.group_by/2 with get_context/1
    raise "TODO: Implement group_by_context/1"
  end

  @doc """
  Finds all cross-context dependencies.

  Returns a list of tuples `{from_module, to_module}` where the modules
  belong to different contexts.

  ## Examples

      iex> deps = %{
      ...>   MyApp.Payments.Processor => [MyApp.Accounts.Balance, MyApp.Core.Money],
      ...>   MyApp.Accounts.Balance => [MyApp.Core.Money],
      ...>   MyApp.Core.Money => []
      ...> }
      iex> Session04.ProjectExplorer.cross_context_dependencies(deps) |> Enum.sort()
      [
        {MyApp.Accounts.Balance, MyApp.Core.Money},
        {MyApp.Payments.Processor, MyApp.Accounts.Balance},
        {MyApp.Payments.Processor, MyApp.Core.Money}
      ]
  """
  def cross_context_dependencies(_dependency_map) do
    # TODO: Find all dependencies where contexts differ
    # Return list of {from, to} tuples
    raise "TODO: Implement cross_context_dependencies/1"
  end

  @doc """
  Validates that dependencies follow the allowed layer ordering.

  Given a layer ordering (list from lowest to highest), verifies that
  dependencies only flow from higher layers to lower layers.

  Returns `{:ok, :valid}` or `{:error, violations}` with list of violations.

  ## Examples

      iex> layers = [:Core, :Domain, :Application, :Web]
      iex> deps = %{
      ...>   MyApp.Web.Controller => [MyApp.Application.Service],
      ...>   MyApp.Application.Service => [MyApp.Domain.Entity],
      ...>   MyApp.Domain.Entity => [MyApp.Core.Types]
      ...> }
      iex> Session04.ProjectExplorer.validate_layer_dependencies(deps, layers)
      {:ok, :valid}

      iex> layers = [:Core, :Domain, :Application, :Web]
      iex> deps = %{MyApp.Core.Types => [MyApp.Web.Controller]}
      iex> Session04.ProjectExplorer.validate_layer_dependencies(deps, layers)
      {:error, [{MyApp.Core.Types, MyApp.Web.Controller}]}
  """
  def validate_layer_dependencies(_dependency_map, _layer_order) do
    # TODO: Validate that dependencies respect layer ordering
    # Higher layers can depend on lower layers, but not vice versa
    # Hint: Create a map of context -> layer index for quick lookup
    raise "TODO: Implement validate_layer_dependencies/2"
  end

  @doc """
  Calculates the "instability" metric for each module.

  Instability = Ce / (Ca + Ce) where:
  - Ce (Efferent coupling) = number of modules this module depends on
  - Ca (Afferent coupling) = number of modules that depend on this module

  Instability ranges from 0 (completely stable) to 1 (completely unstable).
  Stable modules should be depended upon; unstable modules should depend on others.

  ## Examples

      iex> deps = %{A: [:B, :C], B: [:C], C: []}
      iex> Session04.ProjectExplorer.calculate_instability(deps)
      %{A: 1.0, B: 0.5, C: 0.0}
  """
  def calculate_instability(_dependency_map) do
    # TODO: Calculate instability metric for each module
    # Ce = count of outgoing dependencies
    # Ca = count of incoming dependencies
    # Instability = Ce / (Ca + Ce), or 0.0 if both are 0
    raise "TODO: Implement calculate_instability/1"
  end

  @doc """
  Generates a simple text representation of the dependency graph.

  Useful for visualizing project structure in documentation or logs.

  ## Examples

      iex> deps = %{A: [:B, :C], B: [:C], C: []}
      iex> Session04.ProjectExplorer.dependency_graph_text(deps)
      \"\"\"
      A
        -> B
        -> C
      B
        -> C
      C
        (no dependencies)
      \"\"\"
  """
  def dependency_graph_text(_dependency_map) do
    # TODO: Generate a text representation of the dependency graph
    # Sort modules alphabetically for consistent output
    # Show "(no dependencies)" for modules with empty dependency list
    raise "TODO: Implement dependency_graph_text/1"
  end

  @doc """
  Finds "hub" modules that have high connectivity (many incoming + outgoing dependencies).

  Returns modules where (incoming + outgoing) >= threshold, sorted by connectivity descending.

  ## Examples

      iex> deps = %{A: [:B, :C, :D], B: [:C], C: [], D: [:C]}
      iex> Session04.ProjectExplorer.find_hubs(deps, 3)
      [{:C, 4}, {:A, 3}]
  """
  def find_hubs(_dependency_map, _threshold) do
    # TODO: Find highly connected modules
    # Connectivity = incoming + outgoing dependencies
    # Return list of {module, connectivity} tuples for modules >= threshold
    raise "TODO: Implement find_hubs/2"
  end
end
