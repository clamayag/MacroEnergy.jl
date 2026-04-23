Base.@kwdef mutable struct MinHydroFlowConstraint <: OperationConstraint
    discharge_edge::AbstractEdge
    slack_edge::AbstractEdge
    constraint_ref::Union{Missing,JuMP.Containers.DenseAxisArray} = missing
end

function add_model_constraint!(ct::MinHydroFlowConstraint, e::Edge, model::Model)
    if !ismissing(e.min_flow) && !isnothing(e.min_flow)
        ct.constraint_ref = @constraint(
            model,
            [t in time_interval(e)],
            flow(e, t) + flow(ct.discharge_edge, t) + flow(ct.slack_edge, t) >= min_flow(e)  # or min_flow(e,t)
        )

    else
        @warn "Min flow constraint skipped: min_flow not provided"
    end
    return nothing
end