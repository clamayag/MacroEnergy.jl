Base.@kwdef mutable struct SpillConstraint <: OperationConstraint
    value::Union{Missing,Vector{Float64}} = missing
    constraint_dual::Union{Missing,Vector{Float64}} = missing
    hydrostor::AbstractStorage
    constraint_ref::Union{Missing,JuMPConstraint} = missing
end

function add_model_constraint!(ct::SpillConstraint, e::Edge, model::Model)

    ct.constraint_ref = @constraint(
        model,
        [t in time_interval(e)],
        flow(e, t) <= spill_vol(ct.hydrostor, t)
    )

    return nothing

end