Base.@kwdef mutable struct MustRunConstraint <: OperationConstraint
    value::Union{Missing,Vector{Float64}} = missing
    constraint_dual::Union{Missing,Vector{Float64}} = missing
    constraint_ref::Union{Missing,JuMPConstraint} = missing
end

@doc raw"""
    add_model_constraint!(ct::MustRunConstraint, e::AbstractEdge, model::Model)

Add a must run constraint to the edge `e`. The functional form of the constraint is:

```math
\begin{aligned}
    \text{flow(e, t)} = \text{availability(e, t)} \times \text{capacity(e)}
\end{aligned}
```
for each time `t` in `time_interval(e)` for the edge `e`.

!!! note "Must run constraint"
    This constraint is available only for unidirectional edges with capacity.
"""
function add_model_constraint!(ct::MustRunConstraint, e::Edge, model::Model)

    if e.natural_inflow !== nothing
        @info "Adding MustRunConstraint with natural inflow for edge $(e.id)"
        ct.constraint_ref = @constraint(
            model,
            [t in time_interval(e)],
            flow(e, t) == natural_inflow(e, t)
        )
    else
        # LEGACY CASE (thermal generators etc.)
        ct.constraint_ref = @constraint(
            model,
            [t in time_interval(e)],
            flow(e, t) == availability(e, t) * capacity(e)
        )
    end
    return nothing
end

function add_model_constraint!(ct::MustRunConstraint, e::BidirectionalEdge, model::Model)
    if e.evap !== nothing
        ct.constraint_ref = @constraint(
            model,
            [t in time_interval(e)],
            flow(e, t) == evap(e, t)
        )
    else
        error("MustRunConstraint is not supported for bidirectional edges other than evap. Please use unidirectional edges for this constraint.")
    end
    return nothing
end

