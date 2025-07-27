module AskTellSolvers

# Problem Specs
export Min, Max, BoxConstrainedSpec
# Evaluation Oracles
export Objective
# Ask-Tell Solver Interface
export AskTellSolver, ask!, tell!, result, optimize!

#--------------
# Problem Specs
#--------------

# idea from https://github.com/jbrea/BayesianOptimization.jl
"""
    @enum Sense Min=-1 Max=1

Optimization sense, either minimization or maximization.
"""
@enum Sense Min=-1 Max=1
"""
    BoxConstrainedSpec{S,T}

Search specification for a box constrained optimization problem.
"""
struct BoxConstrainedSpec{S,T}
    sense::Sense
    lower_bounds::Vector{S}
    upper_bounds::Vector{T}
    @doc """
        function BoxConstrainedSpec(
            sense::Sense, lower_bounds::Vector{S}, upper_bounds::Vector{T}
        ) where {S,T}
    
    Construct a `BoxConstrainedSpec`.

    # Throws

    - `ArgumentError` if `lower_bounds` and `upper_bounds` have different lengths
    - `ArgumentError` if `lower_bounds` or `upper_bounds` is empty
    - `ArgumentError` if `lower_bounds[i] > upper_bounds[i]` for some `i`
    """
    function BoxConstrainedSpec(
        sense::Sense, lower_bounds::Vector{S}, upper_bounds::Vector{T}
    ) where {S,T}
        length(lower_bounds) == length(upper_bounds) || throw(
            ArgumentError("`lower_bounds` and `upper_bounds` must have the same length")
        )
        isempty(lower_bounds) && throw(ArgumentError("bounds must not be empty"))
        all(lower_bounds .<= upper_bounds) || throw(ArgumentError("`lower_bounds` must be pointwise less or equal to `upper_bounds`"))
        new{S,T}(sense, lower_bounds, upper_bounds)
    end
end

#-------------
# Oracle Types
#-------------

"""
    Objective{F<:Function}

Represents an oracle that evaluates a single-objective function.
"""
struct Objective{F<:Function}
    f::F
end

# struct MultiFidelity{H <: Function, L <: Function}
#     high_fidelity::H
#     low_fidelity::L
# end
# struct MultiObjective
#     objectives
# end

#--------------------------
# Ask-Tell Solver Interface
#--------------------------

"""
    abstract type AskTellSolver end 

Interface for ask-tell optimization solvers.

To define a custom solver, subtype `AskTellSolver` and implement the following methods:
- `ask!(::Solver, args...; kwargs...)`: generate queries
- `tell!(::Solver, args...; kwargs...)`: update the solver with new data
- `result(::Solver, args...; kwargs...)`: return the current best solution

Optionally, implement a method `optimize!(::Oracle, ::Solver, args...; kwargs...)`
providing a complete optimization loop.

## Intended Usage

If you do not need to control the optimization loop manually, use `optimize!`.

```julia
solver = BayesOptGPs(problem_spec::BoxConstrainedProblem, args...; kwargs...)
# pass initial evaluations
tell!(solver, start_xs, start_ys; run_hyperparam_opt=true)
solution = optimize!(Objective(f), solver; max_iterations=100)
```

```julia
solver = MultiFidelityBayesOptGPs(problem_spec; args...; kwargs...)
# pass initial evaluations
tell!(solver, start_xs_f, start_ys_f, start_xs_g, start_ys_g; run_hyperparam_opt=true)
solution = optimize!(MultiFidelity(f, g), solver; max_iterations=100)
```

Alternatively, manually control the optimization loop: iteratively call `ask!` to obtain queries, 
and pass the results back with `tell!`. Call `result` to retrieve the current solution.
"""
abstract type AskTellSolver end
"""
    ask!(::Solver, args...; kwargs...)

Generate queries for oracle evaluation.
"""
function ask! end
"""
    tell!(::Solver, args...; kwargs...)

Process oracle evaluations.
"""
function tell! end
"""
    result(::Solver, args...; kwargs...)

Return the current result, typically the current best solution found.
"""
function result end
"""
    optimize!(::Oracle, ::Solver, args...; kwargs...)

Run optimization loop.
"""
function optimize! end

end
