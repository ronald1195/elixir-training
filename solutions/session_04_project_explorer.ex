defmodule Session04.ProjectExplorer do
  @moduledoc """
  Solution for Session 4: Project Explorer

  This module provides functions for analyzing Elixir project structure and dependencies.
  """

  @doc """
  Returns all direct dependencies for a given module.
  """
  def direct_dependencies(dependency_map, module) do
    Map.get(dependency_map, module, [])
  end

  @doc """
  Returns all transitive dependencies for a module (direct + indirect).
  """
  def transitive_dependencies(dependency_map, module) do
    do_transitive_dependencies(dependency_map, module, MapSet.new())
    |> MapSet.to_list()
  end

  defp do_transitive_dependencies(dependency_map, module, visited) do
    direct = Map.get(dependency_map, module, [])

    Enum.reduce(direct, MapSet.new(direct), fn dep, acc ->
      if MapSet.member?(visited, dep) do
        acc
      else
        transitive = do_transitive_dependencies(dependency_map, dep, MapSet.put(visited, dep))
        MapSet.union(acc, transitive)
      end
    end)
  end

  @doc """
  Detects if there are any circular dependencies in the project.
  """
  def detect_cycles(dependency_map) do
    modules = Map.keys(dependency_map)

    result =
      Enum.reduce_while(modules, {:ok, MapSet.new(), MapSet.new()}, fn module, {:ok, visited, _} ->
        case detect_cycle_from(dependency_map, module, [], MapSet.new(), visited) do
          {:cycle, path} -> {:halt, {:error, path}}
          {:ok, new_visited} -> {:cont, {:ok, new_visited, MapSet.new()}}
        end
      end)

    case result do
      {:error, cycle} -> {:error, cycle}
      {:ok, _, _} -> {:ok, []}
    end
  end

  defp detect_cycle_from(dependency_map, module, path, in_path, visited) do
    cond do
      MapSet.member?(in_path, module) ->
        cycle_start = Enum.find_index(path, &(&1 == module))
        cycle = Enum.drop(path, cycle_start) ++ [module]
        {:cycle, cycle}

      MapSet.member?(visited, module) ->
        {:ok, visited}

      true ->
        new_path = path ++ [module]
        new_in_path = MapSet.put(in_path, module)
        deps = Map.get(dependency_map, module, [])

        result =
          Enum.reduce_while(deps, {:ok, visited}, fn dep, {:ok, acc_visited} ->
            case detect_cycle_from(dependency_map, dep, new_path, new_in_path, acc_visited) do
              {:cycle, _} = cycle -> {:halt, cycle}
              {:ok, new_visited} -> {:cont, {:ok, new_visited}}
            end
          end)

        case result do
          {:cycle, _} = cycle -> cycle
          {:ok, final_visited} -> {:ok, MapSet.put(final_visited, module)}
        end
    end
  end

  @doc """
  Extracts the context (top-level namespace) from a module name.
  """
  def get_context(module) when is_atom(module) do
    parts = Module.split(module)

    case parts do
      [single] -> String.to_atom(single)
      [_app, context | _] -> String.to_atom(context)
      _ -> module
    end
  end

  @doc """
  Groups modules by their context.
  """
  def group_by_context(modules) do
    Enum.group_by(modules, &get_context/1)
  end

  @doc """
  Finds all cross-context dependencies.
  """
  def cross_context_dependencies(dependency_map) do
    dependency_map
    |> Enum.flat_map(fn {from_module, deps} ->
      from_context = get_context(from_module)

      deps
      |> Enum.filter(fn to_module ->
        get_context(to_module) != from_context
      end)
      |> Enum.map(fn to_module -> {from_module, to_module} end)
    end)
  end

  @doc """
  Validates that dependencies follow the allowed layer ordering.
  """
  def validate_layer_dependencies(dependency_map, layer_order) do
    layer_index =
      layer_order
      |> Enum.with_index()
      |> Map.new()

    violations =
      dependency_map
      |> Enum.flat_map(fn {from_module, deps} ->
        from_context = get_context(from_module)
        from_index = Map.get(layer_index, from_context, -1)

        deps
        |> Enum.filter(fn to_module ->
          to_context = get_context(to_module)
          to_index = Map.get(layer_index, to_context, -1)
          # Violation: depending on a higher layer
          from_index >= 0 and to_index >= 0 and from_index < to_index
        end)
        |> Enum.map(fn to_module -> {from_module, to_module} end)
      end)

    if violations == [] do
      {:ok, :valid}
    else
      {:error, violations}
    end
  end

  @doc """
  Calculates the "instability" metric for each module.
  """
  def calculate_instability(dependency_map) do
    modules = Map.keys(dependency_map)

    # Calculate incoming dependencies (afferent coupling)
    incoming =
      modules
      |> Enum.reduce(%{}, fn module, acc ->
        Map.put(acc, module, count_incoming(dependency_map, module))
      end)

    # Calculate instability for each module
    modules
    |> Enum.map(fn module ->
      outgoing = length(Map.get(dependency_map, module, []))
      afferent = Map.get(incoming, module, 0)
      total = afferent + outgoing

      instability = if total == 0, do: 0.0, else: outgoing / total
      {module, instability}
    end)
    |> Map.new()
  end

  defp count_incoming(dependency_map, target) do
    dependency_map
    |> Enum.count(fn {_module, deps} -> target in deps end)
  end

  @doc """
  Generates a simple text representation of the dependency graph.
  """
  def dependency_graph_text(dependency_map) do
    if map_size(dependency_map) == 0 do
      ""
    else
      dependency_map
      |> Enum.sort_by(fn {module, _} -> Atom.to_string(module) end)
      |> Enum.map(fn {module, deps} ->
        module_line = "#{module}"

        dep_lines =
          if deps == [] do
            ["  (no dependencies)"]
          else
            Enum.map(deps, fn dep -> "  -> #{dep}" end)
          end

        [module_line | dep_lines] |> Enum.join("\n")
      end)
      |> Enum.join("\n")
      |> Kernel.<>("\n")
    end
  end

  @doc """
  Finds "hub" modules that have high connectivity.
  """
  def find_hubs(dependency_map, threshold) do
    if map_size(dependency_map) == 0 do
      []
    else
      modules = Map.keys(dependency_map)

      modules
      |> Enum.map(fn module ->
        outgoing = length(Map.get(dependency_map, module, []))
        incoming = count_incoming(dependency_map, module)
        connectivity = incoming + outgoing
        {module, connectivity}
      end)
      |> Enum.filter(fn {_module, connectivity} -> connectivity >= threshold end)
      |> Enum.sort_by(fn {_module, connectivity} -> -connectivity end)
    end
  end
end
