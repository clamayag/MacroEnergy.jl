Base.@kwdef mutable struct PHSConstraint <: PlanningConstraint
    load_edge::AbstractEdge
    electricity_consumption::Union{Missing,Float64} = missing
    constraint_ref::Union{Missing,JuMP.Containers.DenseAxisArray} = missing
end

function add_model_constraint!(ct::PHSConstraint, e::Edge, model::Model)
    if !ismissing(ct.electricity_consumption) && !isnothing(ct.electricity_consumption)
        ct.constraint_ref = @constraint(
            model,
            [t in time_interval(e)],
            capacity(e) * ct.electricity_consumption == capacity(ct.load_edge)
        )

    else
        @warn "PHS constraint skipped: electricity consumption not provided"
    end
    return nothing
end