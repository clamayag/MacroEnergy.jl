macro AbstractTransformationBaseAttributes()
    # if you have transform_default_data(), use it like the others:
    # defaults = transform_default_data()
    esc(quote
        # Parameters you want to access in constraints:
        intercept::Float64 = 0.0
        discharge_coeff::Float64 = 0.0
        storage_coeff::Float64 = 0.0
        specific_prod::Float64 = 0.0
        head::Float64 = 0.0
    end)
end

"""
    Transformation <: AbstractVertex

    A mutable struct representing a transformation vertex in a network model, which models a conversion process between different commodities or energy forms.

    # Inherited Attributes
    - id::Symbol: Unique identifier for the transformation
    - timedata::TimeData: Time-related data for the transformation
    - location::Union{Missing, Symbol}: Geographic location of the transformation (inherited from AbstractVertex)
    - balance_data::Dict{Symbol,Dict{Symbol,Float64}}: Dictionary mapping stoichiometric equation IDs to coefficients
    - constraints::Vector{AbstractTypeConstraint}: List of constraints applied to the transformation
    - operation_expr::Dict: Dictionary storing operational JuMP expressions for the transformation

    Transformations are used to model conversion processes between different commodities, such as power plants 
    converting fuel to electricity or electrolyzers converting electricity to hydrogen. The `balance_data` field 
    typically contains conversion efficiencies and other relationships between input and output flows.
"""
Base.@kwdef mutable struct Transformation <: AbstractVertex
    @AbstractVertexBaseAttributes()
    @AbstractTransformationBaseAttributes()
end

function make_transformation(
    id::Symbol,
    data::AbstractDict{Symbol,Any},
    time_data::TimeData,
)
    tr_kwargs = Base.fieldnames(Transformation)

    filtered_data = Dict{Symbol,Any}(k => v for (k,v) in data if k in tr_kwargs)

    # remove keys you always pass explicitly
    for key in [:id, :timedata]
        if haskey(filtered_data, key)
            delete!(filtered_data, key)
        end
    end

    tr = Transformation(;
        id = id,
        timedata = time_data,
        filtered_data...,
    )

    return tr
end
Transformation(id::Symbol, data::AbstractDict{Symbol,Any}, time_data::TimeData) =
    make_transformation(id, data, time_data)

######### Transformation interface #########

max_power(g::Transformation) = g.max_power
intercept(g::Transformation) = g.intercept
discharge_coeff(g::Transformation) = g.discharge_coeff
storage_coeff(g::Transformation) = g.storage_coeff
specific_prod(g::Transformation) = g.specific_prod
head(g::Transformation) = g.head

######### End Transformation interface #########

function add_linking_variables!(g::Transformation, model::Model)
    return nothing
end

function planning_model!(g::Transformation, model::Model)

    return nothing
end

function define_available_capacity!(g::Transformation, model::Model)
    return nothing
end

function operation_model!(g::Transformation, model::Model)
    if !isempty(balance_ids(g))
        for i in balance_ids(g)
            g.operation_expr[i] =
                @expression(model, [t in time_interval(g)], 0 * model[:vREF])
        end
    end
    return nothing
end
