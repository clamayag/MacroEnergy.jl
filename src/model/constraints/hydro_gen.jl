Base.@kwdef mutable struct HydroGenConstraint <: OperationConstraint
    gen_edge::AbstractEdge
    discharge_edge::AbstractEdge
    hydrostor::AbstractStorage
    constraint_ref::Union{Missing,JuMPConstraint} = missing
end

function add_model_constraint!(ct::HydroGenConstraint, tr::Transformation, model::Model)
    H = head(tr)
    p = specific_prod(tr)
    ct.constraint_ref = @constraint(
        model,
        [t in time_interval(tr)],
        flow(ct.gen_edge, t) == p * H * flow(ct.discharge_edge, t)
    )
    return nothing
end
