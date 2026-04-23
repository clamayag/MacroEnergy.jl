struct HydroStreamflow <: AbstractAsset
    id::AssetId
    elec_transform::Transformation
    hydrostor::AbstractStorage{<:Water}
    discharge_edge::Edge{<:Water}
    inflow_edge::Edge{<:Water}
    natural_inflow_edge::Edge{<:Water}
    spill_edge::Edge{<:Water}
    gen_edge::Edge{<:Electricity}
    tailrace_edge::Edge{<:Water}
    div_edge::Edge{<:Water}
    evap_edge::BidirectionalEdge{<:Water}
    phs_edge::Edge{<:Water}
    load_edge::Edge{<:Electricity}
    slack_edge::Edge{<:Water}
end

function default_data(t::Type{HydroStreamflow}, id=missing, style="full")
    if style == "full"
        return full_default_data(t, id)
    else
        return simple_default_data(t, id)
    end
end

function full_default_data(::Type{HydroStreamflow}, id=missing)
    return OrderedDict{Symbol,Any}(
        :id => id,
        :storage => @storage_data(
            :commodity => Water,
            :can_expand => false,
            :can_retire => false,
            :has_capacity => true,
            :constraints => Dict{Symbol, Bool}(
                :BalanceConstraint => true,
                :MaxStorageLevelConstraint => true,
                :MinStorageLevelConstraint => true,
            ),
            :existing_capacity => 0.0,
            :min_storage_level => 0.0,
            :max_storage_level => 0.0,
            :initial_storage_level => 0.0,
            :spill_thresh => 0.0,
        ),
        :transforms => @transform_data(
            :timedata => "Electricity",
            :constraints => Dict{Symbol, Bool}(
                :BalanceConstraint => true,
                :CapacityConstraint => true,
            ),
            :specific_prod => 0.0,
            :intercept => 0.0,
            :discharge_coeff => 0.0,
            :storage_coeff => 0.0,
            :head => 0.0,
        ),
        :edges => Dict{Symbol,Any}(
            :discharge_edge => @edge_data(
                :commodity => "Water",
                :has_capacity => true,
                :can_expand => true,
                :can_retire => true,
                :unidirectional => true,
                :constraints => Dict{Symbol, Bool}(
                    :CapacityConstraint => true,
                ),
                :capacity => 0.0,
                :fd => 0.0,
                :pd => 0.0,
                :consumption => 0.0,
            ),
            :inflow_edge => @edge_data(
                :commodity => "Water",
                :has_capacity => false,
                :unidirectional => true,
                :travel_time => 0.0,
            ),
            :natural_inflow_edge => @edge_data(
                :commodity => "Water",
                :has_capacity => false,
                :unidirectional => true,
                :constraints => Dict{Symbol, Bool}(
                    :MustRunConstraint => true,
                ),
            ),
            :spill_edge => @edge_data(
                :commodity => "Water",
                :has_capacity => false,
                :unidirectional => true,
                :constraints => Dict{Symbol, Bool}(
                ),
                :min_flow => 0.0,
            ),
            :gen_edge => @edge_data(
                :commodity => "Electricity",
                :has_capacity => true,
                :can_expand => true,
                :can_retire => true,
                :unidirectional => true,
                :constraints => Dict{Symbol, Bool}(
                    :CapacityConstraint => true,
                ),
                :capacity => 0.0,
            ),
            :tailrace_edge => @edge_data(
                :commodity => "Water",
                :has_capacity => false,
                :unidirectional => true,
            ),
            :div_edge => @edge_data(
                :commodity => "Water",
                :has_capacity => false,
                :unidirectional => true,
                :constraints => Dict{Symbol, Bool}(
                    :CapacityConstraint => true,
                ),
                :capacity => 0.0,
            ),
            :evap_edge => @edge_data(
                :commodity => "Water",
                :has_capacity => false,
                :unidirectional => true,
                :constraints => Dict{Symbol, Bool}(
                    :MustRunConstraint => true,
                ),
            ),
            :phs_edge => @edge_data(
                :commodity => "Water",
                :has_capacity => true,
                :can_expand => true,
                :unidirectional => true,
                :constraints => Dict{Symbol, Bool}(
                    :CapacityConstraint => true,
                ),
                :electricity_consumption => 1.0,
            ),
            :load_edge => @edge_data(
                :commodity => "Electricity",
                :has_capacity => false,
                :unidirectional => true,
            ),
            :slack_edge => @edge_data(
                :commodity => "Water",
                :has_capacity => false,
                :unidirectional => true,
            ),
        ),
    )
end

function simple_default_data(::Type{HydroStreamflow}, id=missing)
    return OrderedDict{Symbol,Any}(
        :id => id,
        :location => missing,
        :storage_can_expand => false,
        :storage_can_retire => false,
        :discharge_can_expand => true,
        :discharge_can_retire => true,
        :discharge_unidirectional => true,
        :spill_can_expand => false,
        :spill_can_retire => true,
        :spill_unidirectional => true,
        :inflow_can_expand => false,
        :inflow_can_retire => false,
        :inflow_unidirectional => true,
        :natural_inflow_can_expand => false,
        :natural_inflow_can_retire => false,
        :natural_inflow_unidirectional => true,
        :gen_can_expand => true,
        :gen_can_retire => true,
        :gen_unidirectional => true,
        :tailrace_can_expand => false,
        :tailrace_can_retire => false,
        :tailrace_unidirectional => true,
        :div_can_expand => false,
        :div_can_retire => false,
        :div_unidirectional => true,
        :evap_can_expand => false,
        :evap_can_retire => false,
        :evap_unidirectional => true,
        :phs_can_expand => true,
        :phs_can_retire => false,
        :phs_unidirectional => true,
        :load_can_expand => false,
        :load_can_retire => false,
        :load_unidirectional => true,
        :slack_can_expand => false,
        :slack_can_retire => false,
        :hydro_source => missing,
        :storage_long_duration => false,
        :storage_existing_capacity => 0.0,
        :discharge_existing_capacity => 0.0,
        :spill_existing_capacity => 0.0,
        :gen_existing_capacity => 0.0,
        :tailrace_existing_capacity => 0.0,
        :div_existing_capacity => 0.0,
        :inflow_existing_capacity => 0.0,
        :phs_existing_capacity => 0.0,
        :storage_charge_discharge_ratio => 1.0,
        :discharge_investment_cost => 0.0,
        :discharge_fixed_om_cost => 0.0,
        :discharge_variable_om_cost => 0.0,
        :gen_investment_cost => 0.0,
        :gen_fixed_om_cost => 0.0,
        :gen_variable_om_comst => 0.0,
        :phs_investment_cost => 0.0,
        :phs_fixed_om_cost => 0.0,
        :phs_variable_om_cost => 0.0,
        :slack_variable_om_cost => 0.0,
        :discharge_efficiency => 1.0,
        :inflow_efficiency => 1.0,
    )
end

function make(asset_type::Type{HydroStreamflow}, data::AbstractDict{Symbol,Any}, system::System)
    id = AssetId(data[:id])

    @setup_data(asset_type, data, id)

    ## Transformation
    transform_key = :transforms
    @process_data(
        transform_data,
        data[transform_key],
        [
            (data[transform_key], key),
            (data[transform_key], Symbol("transform_", key)),
            (data, Symbol("transform_", key)),
            (data, key),
        ]
    )
    elec_transform = Transformation(
        Symbol(id, "_", transform_key),
        transform_data,
        system.time_data[Symbol(transform_data[:timedata])],
    )
            
    ## Storage component of the hydro reservoir
    storage_key = :storage
    @process_data(
        storage_data,
        data[storage_key],
        [
            (data[storage_key], key),
            (data[storage_key], Symbol("storage_", key)),
            (data, Symbol("storage_", key)),
        ]
    )
    # check if the storage is a long duration storage
    long_duration = get(storage_data, :long_duration, false)
    StorageType = long_duration ? LongDurationStorage : Storage
    # create the storage component of the hydro reservoir
    hydrostor = StorageType(
        Symbol(id, "_", storage_key),
        storage_data,
        system.time_data[:Water],
        Water,
    )
    if long_duration
        lds_constraints = [LongDurationStorageImplicitMinMaxConstraint()]
        for c in lds_constraints
            if !(c in hydrostor.constraints)
                push!(hydrostor.constraints, c)
            end
        end
    end

    discharge_edge_key = :discharge_edge
    @process_data(
        discharge_edge_data,
        data[:edges][discharge_edge_key],
        [
            (data[:edges][discharge_edge_key], key),
            (data[:edges][discharge_edge_key], Symbol("discharge_", key)),
            (data, Symbol("discharge_", key)),
        ]
    )
    discharge_start_node = hydrostor
    discharge_end_node = elec_transform
    discharge_edge = Edge(
        Symbol(id, "_", discharge_edge_key),
        discharge_edge_data,
        system.time_data[:Water],
        Water,
        discharge_start_node,
        discharge_end_node,
    )

    gen_edge_key = :gen_edge
    @process_data(
        gen_edge_data,
        data[:edges][gen_edge_key],
        [
            (data[:edges][gen_edge_key], key),
            (data[:edges][gen_edge_key], Symbol("gen_", key)),
            (data, Symbol("gen_", key)),
        ]
    )
    gen_start_node = elec_transform
    @end_vertex(
        gen_end_node,
        gen_edge_data,
        Electricity,
        [(gen_edge_data, :end_vertex), (data, :location)],
    )
    gen_edge = Edge(
        Symbol(id, "_", gen_edge_key),
        gen_edge_data,
        system.time_data[:Electricity],
        Electricity,
        gen_start_node,
        gen_end_node,
    )

    tailrace_edge_key = :tailrace_edge
    @process_data(
        tailrace_edge_data,
        data[:edges][tailrace_edge_key],
        [
            (data[:edges][tailrace_edge_key], key),
            (data[:edges][tailrace_edge_key], Symbol("tailrace_", key)),
            (data, Symbol("tailrace_", key)),
        ]
    )
    tailrace_start_node = elec_transform
    @end_vertex(
        tailrace_end_node,
        tailrace_edge_data,
        Water,
        [(tailrace_edge_data, :end_vertex), (data, :hydro_source), (data, :location)],
    )
    tailrace_edge = Edge(
        Symbol(id, "_", tailrace_edge_key),
        tailrace_edge_data,
        system.time_data[:Water],
        Water,
        tailrace_start_node,
        tailrace_end_node,
    )

    div_edge_key = :div_edge
    @process_data(
        div_edge_data,
        data[:edges][div_edge_key],
        [
            (data[:edges][div_edge_key], key),
            (data[:edges][div_edge_key], Symbol("div_", key)),
            (data, Symbol("div_", key)),
        ]
    )
    div_start_node = hydrostor
    @end_vertex(
        div_end_node,
        div_edge_data,
        Water,
        [(div_edge_data, :end_vertex), (data, :hydro_source), (data, :location)],
    )
    div_edge = Edge(
        Symbol(id, "_", div_edge_key),
        div_edge_data,
        system.time_data[:Water],
        Water,
        div_start_node,
        div_end_node,
    )

    evap_edge_key = :evap_edge
    @process_data(
        evap_edge_data,
        data[:edges][evap_edge_key],
        [
            (data[:edges][evap_edge_key], key),
            (data[:edges][evap_edge_key], Symbol("evap_", key)),
            (data, Symbol("evap_", key)),
        ]
    )
    evap_start_node = hydrostor
    @end_vertex(
        evap_end_node,
        evap_edge_data,
        Water,
        [(evap_edge_data, :end_vertex), (data, :hydro_source), (data, :location),],
    )
    evap_edge = BidirectionalEdge(
        Symbol(id, "_", evap_edge_key),
        evap_edge_data,
        system.time_data[:Water],
        Water,
        evap_start_node,
        evap_end_node,
    )

    inflow_edge_key = :inflow_edge
    @process_data(
        inflow_edge_data,
        data[:edges][inflow_edge_key],
        [
            (data[:edges][inflow_edge_key], key),
            (data[:edges][inflow_edge_key], Symbol("inflow_", key)),
            (data, Symbol("inflow_", key)),
        ]
    )
    @start_vertex(
        inflow_start_node,
        inflow_edge_data,
        Water,
        [(inflow_edge_data, :start_vertex), (data, :hydro_source), (data, :location),],
    )
    inflow_end_node = hydrostor
    inflow_edge = Edge(
        Symbol(id, "_", inflow_edge_key),
        inflow_edge_data,
        system.time_data[:Water],
        Water,
        inflow_start_node,
        inflow_end_node,
    )

    natural_inflow_edge_key = :natural_inflow_edge
    @process_data(
        natural_inflow_edge_data,
        data[:edges][natural_inflow_edge_key],
        [
            (data[:edges][natural_inflow_edge_key], key),
            (data[:edges][natural_inflow_edge_key], Symbol("natural_inflow_", key)),
            (data, Symbol("natural_inflow_", key)),
        ]
    )
    @start_vertex(
        natural_inflow_start_node,
        natural_inflow_edge_data,
        Water,
        [(natural_inflow_edge_data, :start_vertex), (data, :hydro_source), (data, :location),],
    )
    natural_inflow_end_node = hydrostor
    natural_inflow_edge = Edge(
        Symbol(id, "_natural_inflow"),
        natural_inflow_edge_data,
        system.time_data[:Water],
        Water,
        natural_inflow_start_node,
        natural_inflow_end_node,
    )

    spill_edge_key = :spill_edge
    @process_data(
        spill_edge_data,
        data[:edges][spill_edge_key],
        [
            (data[:edges][spill_edge_key], key),
            (data[:edges][spill_edge_key], Symbol("spill_", key)),
            (data, Symbol("spill_", key)),
        ]
    )
    spill_start_node = hydrostor
    @end_vertex(
        spill_end_node,
        spill_edge_data,
        Water,
        [(spill_edge_data, :end_vertex), (data, :hydro_source), (data, :location),],
    )
    spill_edge = Edge(
        Symbol(id, "_", spill_edge_key),
        spill_edge_data,
        system.time_data[:Water],
        Water,
        spill_start_node,
        spill_end_node,
    )

    phs_edge_key = :phs_edge
    @process_data(
        phs_edge_data,
        data[:edges][phs_edge_key],
        [
            (data[:edges][phs_edge_key], key),
            (data[:edges][phs_edge_key], Symbol("phs_", key)),
            (data, Symbol("phs_", key)),
        ]
    )
    phs_start_node = elec_transform
    phs_end_node = hydrostor
    phs_edge = Edge(
        Symbol(id, "_", phs_edge_key),
        phs_edge_data,
        system.time_data[:Water],
        Water,
        phs_start_node,
        phs_end_node,
    )

    load_edge_key = :load_edge
    @process_data(
        load_edge_data,
        data[:edges][load_edge_key],
        [
            (data[:edges][load_edge_key], key),
            (data[:edges][load_edge_key], Symbol("load_", key)),
            (data, Symbol("load_", key)),
        ]
    )
    @start_vertex(
        load_start_node,
        load_edge_data,
        Electricity,
        [(load_edge_data, :start_vertex), (data, :hydro_source), (data, :location),],
    )
    load_end_node = elec_transform
    load_edge = Edge(
        Symbol(id, "_", load_edge_key),
        load_edge_data,
        system.time_data[:Electricity],
        Electricity,
        load_start_node,
        load_end_node,
    )

    slack_edge_key = :slack_edge
    @process_data(
        slack_edge_data,
        data[:edges][slack_edge_key],
        [
            (data[:edges][slack_edge_key], key),
            (data[:edges][slack_edge_key], Symbol("slack_", key)),
            (data, Symbol("slack_", key)),
        ]
    )
    @start_vertex(
        slack_start_node,
        slack_edge_data,
        Water,
        [(slack_edge_data, :start_vertex), (data, :hydro_source), (data, :location),],
    )
    @end_vertex(
        slack_end_node,
        slack_edge_data,
        Water,
        [(slack_edge_data, :end_vertex), (data, :hydro_source), (data, :location)],
    )
    slack_edge = Edge(
        Symbol(id, "_", slack_edge_key),
        slack_edge_data,
        system.time_data[:Water],
        Water,
        slack_start_node,
        slack_end_node,
    )

    hydrostor.balance_data = Dict(
        :storage => Dict(
            discharge_edge.id => 1.0,
            inflow_edge.id => 1.0,
            natural_inflow_edge.id => 1.0,
            spill_edge.id => 1.0,
            div_edge.id => 1.0,
            evap_edge.id => 1.0,
            phs_edge.id => 1.0,
        )
    )

    electricity_consumption = get_from([(phs_edge_data, :electricity_consumption)], 1.0)

    elec_transform.balance_data = Dict(
        :water => Dict(
            discharge_edge.id => 1.0,
            tailrace_edge.id  => 1.0,
        ),
        :pump => Dict(
            phs_edge.id => electricity_consumption,
            load_edge.id => 1.0,
        )
    )

    push!(spill_edge.constraints, MinHydroFlowConstraint(discharge_edge=discharge_edge, slack_edge=slack_edge))
    push!(elec_transform.constraints,HydroGenConstraint(gen_edge=gen_edge,discharge_edge=discharge_edge,hydrostor=hydrostor))

    return HydroStreamflow(id,elec_transform,hydrostor,discharge_edge,inflow_edge,natural_inflow_edge,spill_edge,gen_edge,tailrace_edge,div_edge,evap_edge,phs_edge,load_edge,slack_edge)
end
