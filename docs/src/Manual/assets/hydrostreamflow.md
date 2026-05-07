# Hydro Streamflow

## Contents

[Overview](@ref hydrostreamflow_overview) | [Asset Structure](@ref hydrostreamflow_asset_structure) | [Flow Equations](@ref hydrostreamflow_flow_equations) | [Input File (Standard Format)](@ref hydrostreamflow_input_file) | [Types - Asset Structure](@ref hydrostreamflow_type_definition) | [Constructors](@ref hydrostreamflow_constructors) | [Examples](@ref hydrostreamflow_examples) | [Best Practices](@ref hydrostreamflow_best_practices) | [Input File (Advanced Format)](@ref hydrostreamflow_advanced_json_csv_input_format)

## [Overview](@id hydrostreamflow_overview)

Hydro Streamflow assets in Macro represent hydroelectric power generation systems that convert water flow from streams/rivers into electricity. These assets include storage reservoirs, turbines, spillways, and pumped hydro storage capabilities. They are defined using either JSON or CSV input files placed in the `assets` directory, typically named `hydro_streamflow.json` or `hydro_streamflow.csv`.

## [Asset Structure](@id hydrostreamflow_asset_structure)

A Hydro Streamflow asset consists of one transformation component, one storage component, and thirteen edge components:

1. **Storage Component**: Water storage reservoir
2. **Transformation Component**: Converts water flow to electricity
3. **Discharge Edge**: Water flow from storage to transformation (turbine discharge)
4. **Inflow Edge**: Water inflow to storage
5. **Natural Inflow Edge**: Natural streamflow/river inflow to storage
6. **Spill Edge**: Water spill from storage (bypassing turbine)
7. **Generation Edge**: Electricity output from transformation
8. **Tailrace Edge**: Water outflow from transformation back to river
9. **Diversion Edge**: Water diversion from storage for other uses
10. **Evaporation Edge**: Water loss due to evaporation (bidirectional)
11. **PHS Edge**: Water flow for pumped hydro storage operations
12. **Load Edge**: Electricity consumption for pumping
13. **Slack Edge**: Slack water flow for operational flexibility
14. **Reverse Edge**: Reverse water flow for pumped hydro operations

Here is a graphical representation of the Hydro Streamflow asset:

```mermaid
%%{init: {'theme': 'base', 'themeVariables': { 'background': '#D1EBDE' }}}%%
flowchart TD
  subgraph HydroStreamflow
  direction BT
    S((Storage))
    T{{..}}
    I((Natural Inflow)) --> S
    IF((Inflow)) --> S
    S --> D((Discharge))
    D --> T
    T --> G((Electricity))
    T --> TR((Tailrace))
    S --> SP((Spill))
    S --> DV((Diversion))
    S <--> EV((Evaporation))
    T --> PHS((PHS))
    PHS --> S
    L((Load)) --> T
    SL((Slack)) --> S
    RV((Reverse)) --> T
    style T fill:black,stroke:black,color:black;
    style S r:55px,fill:#87CEEB,stroke:black,color:black, stroke-dasharray: 3,5;
    style I r:45px,fill:#87CEEB,stroke:black,color:black, stroke-dasharray: 3,5;
    style IF r:45px,fill:#87CEEB,stroke:black,color:black, stroke-dasharray: 3,5;
    style D r:45px,fill:#87CEEB,stroke:black,color:black, stroke-dasharray: 3,5;
    style G font-size:19px,r:55px,fill:#FFD700,stroke:black,color:black, stroke-dasharray: 3,5;
    style TR r:45px,fill:#87CEEB,stroke:black,color:black, stroke-dasharray: 3,5;
    style SP r:45px,fill:#87CEEB,stroke:black,color:black, stroke-dasharray: 3,5;
    style DV r:45px,fill:#87CEEB,stroke:black,color:black, stroke-dasharray: 3,5;
    style EV r:45px,fill:#87CEEB,stroke:black,color:black, stroke-dasharray: 3,5;
    style PHS r:45px,fill:#87CEEB,stroke:black,color:black, stroke-dasharray: 3,5;
    style L r:45px,fill:#FFD700,stroke:black,color:black, stroke-dasharray: 3,5;
    style SL r:45px,fill:#87CEEB,stroke:black,color:black, stroke-dasharray: 3,5;
    style RV r:45px,fill:#87CEEB,stroke:black,color:black, stroke-dasharray: 3,5;

    linkStyle 0,1,2,3,4,5,6,7,8,9,10,11,12 stroke:#87CEEB, stroke-width: 2px;
    linkStyle 13 stroke:#FFD700, stroke-width: 2px;
```

## [Flow Equations](@id hydrostreamflow_flow_equations)
The Hydro Streamflow asset follows these key relationships:

### Electricity Generation
```math
\begin{aligned}
\phi_{electricity} &= p \cdot h \cdot \phi_{discharge}
\end{aligned}
```

Where:
- ``\phi_{electricity}`` is the electricity generation flow (MWh/hr)
- ``\phi_{discharge}`` is the turbine discharge flow (Mm³/hr)
- ``p`` is the specific production coefficient (``specific\_prod``, MWh/Mm³)
- ``h`` is the hydraulic head (``head``, m)

### Storage Balance
The storage component maintains water balance:
```math
\begin{aligned}
\frac{dS}{dt} &= \phi_{inflow} + \phi_{natural\_inflow} - \phi_{discharge} - \phi_{spill} - \phi_{diversion} - \phi_{evaporation} + \phi_{phs} - \phi_{slack}
\end{aligned}
```

Where:
- ``S`` is the storage level (Mm³)
- ``\phi`` represents the flow of water for each edge (Mm³/hr)

### Minimum Flow Requirements
```math
\begin{aligned}
\phi_{spill} + \phi_{discharge} + \phi_{slack} &\geq \phi_{min\_flow}
\end{aligned}
```

Where:
- ``\phi_{min\_flow}`` is the minimum environmental flow requirement (Mm³/hr)

### Pumped Hydro Storage (PHS)
```math
\begin{aligned}
capacity_{phs} \cdot c_{electricity} &= capacity_{load}
\end{aligned}
```

Where:
- ``capacity_{phs}`` is the PHS pumping capacity (Mm³/hr)
- ``capacity_{load}`` is the electricity load capacity for pumping (MW)
- ``c_{electricity}`` is the electricity consumption per unit pumped water (MWh/Mm³)

## [Input File (Standard Format)](@id hydrostreamflow_input_file)

The easiest way to include a Hydro Streamflow asset in a model is to create a new file (either JSON or CSV) and place it in the `assets` directory together with the other assets.

```
your_case/
├── assets/
│   ├── hydro_streamflow.json    # or hydro_streamflow.csv
│   ├── other_assets.json
│   └── ...
├── system/
├── settings/
└── ...
```

This file can either be created manually, or using the `template_asset` function, as shown in the [Adding an Asset to a System](@ref) section of the User Guide. The file will be automatically loaded when you run your Macro model.

The following is an example of a Hydro Streamflow asset input file:

```json
{
    "Hydro_Streamflow": [
        {
            "type": "HydroStreamflow",
            "global_data": {
                "storage": {
                    "existing_capacity": 1000.0,
                    "max_storage_level": 100.0,
                    "min_storage_level": 10.0,
                    "initial_storage_level": 50.0
                },
                "transforms": {
                    "specific_prod": 8.5,
                    "head": 150.0,
                    "discharge_coeff": 0.9,
                    "intercept": 0.0
                },
                "discharge_edge": {
                    "capacity": 500.0,
                    "investment_cost": 50000.0,
                    "fixed_om_cost": 10000.0
                },
                "gen_edge": {
                    "capacity": 4250.0,
                    "investment_cost": 100000.0,
                    "fixed_om_cost": 20000.0
                },
                "phs_edge": {
                    "capacity": 100.0,
                    "electricity_consumption": 2.5
                }
            },
            "instance_data": [
                {
                    "id": "Hydro_Plant_SE",
                    "location": "SE",
                    "hydro_source": "river_SE",
                    "natural_inflow": {
                        "timeseries": {
                            "path": "system/streamflow.csv",
                            "header": "SE_river_flow"
                        }
                    }
                }
            ]
        }
    ]
}

!!! tip "Global Data vs Instance Data"
    When working with JSON input files, the `global_data` field can be used to group data that is common to all instances of the same asset type. This is useful for setting constraints that are common to all instances of the same asset type and avoid repeating the same data for each instance. See the [Examples](@ref "hydrostreamflow_examples") section below for an example.

The following tables outline the attributes that can be set for a Hydro Streamflow asset.

### Essential Attributes
| Field | Type | Description |
|--------------|---------|------------|
| `type` | String | Asset type identifier: "HydroStreamflow" |
| `id` | String | Unique identifier for the Hydro Streamflow instance |
| `location` | String | Geographic location/node identifier |
| `hydro_source` | String | Identifier for the water source (river/stream) |

### [Storage Parameters](@id hydrostreamflow_storage_parameters)
The storage component represents the water reservoir:

| Field | Type | Description | Units | Default |
|--------------|---------|------------|----------------|----------|
| `existing_capacity` | Float64 | Initial storage capacity | $Mm^3$ | 0.0 |
| `max_storage_level` | Float64 | Maximum storage level | $m$ | Inf |
| `min_storage_level` | Float64 | Minimum storage level | $m$ | 0.0 |
| `initial_storage_level` | Float64 | Initial storage level | $m$ | 0.0 |
| `long_duration` | Boolean | Whether storage is long-duration | - | false |
| `spill_thresh` | Float64 | Spill threshold level | $m$ | 0.0 |

### [Transformation Process Parameters](@id hydrostreamflow_transformation_parameters)
The transformation component converts water flow to electricity:

| Field | Type | Description | Units | Default |
|--------------|---------|------------|----------------|----------|
| `specific_prod` | Float64 | Specific production coefficient | $MWh/Mm^3$ | 0.0 |
| `head` | Float64 | Hydraulic head | $m$ | 0.0 |
| `discharge_coeff` | Float64 | Discharge efficiency coefficient | - | 0.0 |
| `storage_coeff` | Float64 | Storage efficiency coefficient | - | 0.0 |
| `intercept` | Float64 | Intercept coefficient | - | 0.0 |

### [Edge Parameters](@id hydrostreamflow_edge_parameters)
The following parameters apply to various edges:

#### Discharge Edge
| Field | Type | Description | Units | Default |
|--------------|---------|------------|----------------|----------|
| `capacity` | Float64 | Maximum discharge capacity | $Mm^3/hr$ | 0.0 |
| `fd` | Float64 | Fixed demand | $Mm^3/hr$ | 0.0 |
| `pd` | Float64 | Proportional demand | - | 0.0 |
| `consumption` | Float64 | Consumption rate | - | 0.0 |

#### Generation Edge
| Field | Type | Description | Units | Default |
|--------------|---------|------------|----------------|----------|
| `capacity` | Float64 | Maximum generation capacity | $MW$ | 0.0 |

#### Spill Edge
| Field | Type | Description | Units | Default |
|--------------|---------|------------|----------------|----------|
| `min_flow` | Float64 | Minimum environmental flow | $Mm^3/hr$ | 0.0 |

#### PHS Edge
| Field | Type | Description | Units | Default |
|--------------|---------|------------|----------------|----------|
| `capacity` | Float64 | Maximum pumping capacity | $Mm^3/hr$ | 0.0 |
| `electricity_consumption` | Float64 | Electricity consumption per unit pumped water | $MWh/Mm^3$ | 1.0 |

#### Diversion Edge
| Field | Type | Description | Units | Default |
|--------------|---------|------------|----------------|----------|
| `capacity` | Float64 | Maximum diversion capacity | $Mm^3/hr$ | 0.0 |

### [Constraints Configuration](@id "hydrostreamflow_constraints")
Hydro Streamflow assets have various constraints applied to their components:

| Field | Type | Description |
|--------------|---------|------------|
| `storage_constraints` | Dict{String,Bool} | List of constraints applied to the storage component |
| `transform_constraints` | Dict{String,Bool} | List of constraints applied to the transformation component |
| `discharge_constraints` | Dict{String,Bool} | List of constraints applied to the discharge edge |
| `gen_constraints` | Dict{String,Bool} | List of constraints applied to the generation edge |
| `spill_constraints` | Dict{String,Bool} | List of constraints applied to the spill edge |
| `phs_constraints` | Dict{String,Bool} | List of constraints applied to the PHS edge |

Default constraints include:
- Balance constraints on storage and transformation
- Capacity constraints on discharge and generation edges
- Hydro generation constraint linking electricity to water discharge
- Minimum flow constraint on spill edge
- PHS constraint linking pumping capacity to electricity consumption

### Investment Parameters
| Field | Type | Description | Units | Default |
|--------------|---------|------------|----------------|----------|
| `can_retire` | Boolean | Whether components can be retired | - | true |
| `can_expand` | Boolean | Whether components can be expanded | - | true |
| `existing_capacity` | Float64 | Initial installed capacity | $Mm^3/hr$ or $MW$ | 0.0 |
| `capacity_size` | Float64 | Unit size for capacity decisions | - | 1.0 |

#### Additional Investment Parameters

**Edge capacity constraints**

| Field | Type | Description | Units | Default |
|--------------|---------|------------|----------------|----------|
| `max_capacity` | Float64 | Maximum allowed capacity | $Mm^3/hr$ or $MW$ | Inf |
| `min_capacity` | Float64 | Minimum allowed capacity | $Mm^3/hr$ or $MW$ | 0.0 |

### Economic Parameters
| Field | Type | Description | Units | Default |
|--------------|---------|------------|----------------|----------|
| `investment_cost` | Float64 | CAPEX per unit capacity | ``\$/(Mm^3/hr)`` or ``\$/MW`` | 0.0 |
| `annualized_investment_cost` | Union{Nothing,Float64} | Annualized CAPEX | ``\$/(Mm^3/hr/yr)`` or ``\$/MW/yr`` | calculated |
| `fixed_om_cost` | Float64 | Fixed O&M costs | ``\$/(Mm^3/hr/yr)`` or ``\$/MW/yr`` | 0.0 |
| `variable_om_cost` | Float64 | Variable O&M costs | ``\$/Mm^3`` or ``\$/MWh`` | 0.0 |

### Operational Parameters
| Field | Type | Description | Units | Default |
|--------------|---------|------------|----------------|----------|
| `natural_inflow` | Dict | Path to natural inflow time series | - | Empty |
| `availability` | Dict | Path to availability time series | - | Empty |
| `travel_time` | Float64 | Water travel time | $hr$ | 0.0 |

#### Additional Operational Parameters

**Minimum flow constraint**

| Field | Type | Description | Units | Default |
|--------------|---------|------------|----------------|----------|
| `min_flow` | Float64 | Minimum flow for spill edge | $Mm^3/hr$ | 0.0 |

**PHS parameters**

| Field | Type | Description | Units | Default |
|--------------|---------|------------|----------------|----------|
| `electricity_consumption` | Float64 | Electricity consumption per unit pumped water | $MWh/Mm^3$ | 1.0 |

## [Types - Asset Structure](@id hydrostreamflow_type_definition)

The `HydroStreamflow` asset is defined as follows:

```julia
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
    rev_edge::Edge{<:Water}
end
```

## [Constructors](@id hydrostreamflow_constructors)

### Default constructor

```julia
HydroStreamflow(id::AssetId, elec_transform::Transformation, hydrostor::AbstractStorage{<:Water}, discharge_edge::Edge{<:Water}, inflow_edge::Edge{<:Water}, natural_inflow_edge::Edge{<:Water}, spill_edge::Edge{<:Water}, gen_edge::Edge{<:Electricity}, tailrace_edge::Edge{<:Water}, div_edge::Edge{<:Water}, evap_edge::BidirectionalEdge{<:Water}, phs_edge::Edge{<:Water}, load_edge::Edge{<:Electricity}, slack_edge::Edge{<:Water}, rev_edge::Edge{<:Water})
```

### Factory constructor
```julia
make(asset_type::Type{HydroStreamflow}, data::AbstractDict{Symbol,Any}, system::System)
```

| Field | Type | Description |
|--------------|---------|------------|
| `asset_type` | `Type{HydroStreamflow}` | Macro type of the asset |
| `data` | `AbstractDict{Symbol,Any}` | Dictionary containing the input data for the asset |
| `system` | `System` | System to which the asset belongs |

## [Examples](@id hydrostreamflow_examples)
This section contains examples of how to use the Hydro Streamflow asset in a Macro model.

### Simple Hydro Streamflow Asset
This example shows a single Hydro Streamflow asset with existing capacity.

**JSON Format:**
```json
{
    "Hydro_Streamflow": [
        {
            "type": "HydroStreamflow",
            "instance_data": [
                {
                    "id": "Hydro_SE",
                    "location": "SE",
                    "hydro_source": "river_SE",
                    "storage": {
                        "existing_capacity": 1000.0,
                        "max_storage_level": 100.0,
                        "min_storage_level": 10.0,
                        "initial_storage_level": 50.0
                    },
                    "transforms": {
                        "specific_prod": 8.5,
                        "head": 150.0
                    },
                    "discharge_edge": {
                        "capacity": 500.0
                    },
                    "gen_edge": {
                        "capacity": 4250.0
                    },
                    "natural_inflow": {
                        "timeseries": {
                            "path": "system/streamflow.csv",
                            "header": "SE_river_flow"
                        }
                    }
                }
            ]
        }
    ]
}
```

**CSV Format:**

| Type | id | location | hydro_source | storage--existing_capacity | storage--max_storage_level | storage--min_storage_level | storage--initial_storage_level | transforms--specific_prod | transforms--head | discharge_edge--capacity | gen_edge--capacity | natural_inflow--timeseries--path | natural_inflow--timeseries--header |
|------|----|----------|--------------|----------------------------|---------------------------|---------------------------|------------------------------|---------------------------|------------------|--------------------------|-------------------|--------------------------------|--------------------------------|
| HydroStreamflow | Hydro_SE | SE | river_SE | 1000.0 | 100.0 | 10.0 | 50.0 | 8.5 | 150.0 | 500.0 | 4250.0 | system/streamflow.csv | SE_river_flow |

### Hydro Streamflow with PHS
This example shows a Hydro Streamflow asset with pumped hydro storage capabilities.

**JSON Format:**
```json
{
    "Hydro_Streamflow": [
        {
            "type": "HydroStreamflow",
            "global_data": {
                "storage": {
                    "existing_capacity": 1000.0,
                    "max_storage_level": 100.0,
                    "min_storage_level": 10.0,
                    "initial_storage_level": 50.0
                },
                "transforms": {
                    "specific_prod": 8.5,
                    "head": 150.0
                },
                "discharge_edge": {
                    "capacity": 500.0,
                    "investment_cost": 50000.0,
                    "fixed_om_cost": 10000.0
                },
                "gen_edge": {
                    "capacity": 4250.0,
                    "investment_cost": 100000.0,
                    "fixed_om_cost": 20000.0
                },
                "phs_edge": {
                    "capacity": 100.0,
                    "electricity_consumption": 2.5,
                    "investment_cost": 20000.0,
                    "fixed_om_cost": 5000.0
                },
                "spill_edge": {
                    "min_flow": 10.0
                }
            },
            "instance_data": [
                {
                    "id": "Hydro_PHS_SE",
                    "location": "SE",
                    "hydro_source": "river_SE",
                    "natural_inflow": {
                        "timeseries": {
                            "path": "system/streamflow.csv",
                            "header": "SE_river_flow"
                        }
                    }
                }
            ]
        }
    ]
}
```

**CSV Format:**

| Type | id | location | hydro_source | storage--existing_capacity | storage--max_storage_level | storage--min_storage_level | storage--initial_storage_level | transforms--specific_prod | transforms--head | discharge_edge--capacity | discharge_edge--investment_cost | discharge_edge--fixed_om_cost | gen_edge--capacity | gen_edge--investment_cost | gen_edge--fixed_om_cost | phs_edge--capacity | phs_edge--electricity_consumption | phs_edge--investment_cost | phs_edge--fixed_om_cost | spill_edge--min_flow | natural_inflow--timeseries--path | natural_inflow--timeseries--header |
|------|----|----------|--------------|----------------------------|---------------------------|---------------------------|------------------------------|---------------------------|------------------|--------------------------|-------------------------------|-----------------------------|-------------------|-----------------------------|---------------------------|-------------------|----------------------------------|---------------------------|-------------------------|---------------------|--------------------------------|--------------------------------|
| HydroStreamflow | Hydro_PHS_SE | SE | river_SE | 1000.0 | 100.0 | 10.0 | 50.0 | 8.5 | 150.0 | 500.0 | 50000.0 | 10000.0 | 4250.0 | 100000.0 | 20000.0 | 100.0 | 2.5 | 20000.0 | 5000.0 | 10.0 | system/streamflow.csv | SE_river_flow |

## [Best Practices](@id hydrostreamflow_best_practices)

1. **Set realistic hydraulic parameters**: Ensure `specific_prod` and `head` values reflect actual hydropower plant characteristics based on turbine efficiency and hydraulic design
2. **Configure storage levels appropriately**: Set `max_storage_level`, `min_storage_level`, and `initial_storage_level` based on actual reservoir characteristics and operating rules
3. **Use time series for inflows**: Provide natural inflow time series to model seasonal and inter-annual streamflow variations accurately
4. **Consider PHS for flexibility**: Include pumped hydro storage for energy storage and grid balancing capabilities, especially in systems with high renewable penetration
5. **Validate capacities**: Ensure discharge and generation capacities are consistent with hydraulic parameters and physical constraints
6. **Monitor water balance**: Ensure inflow, storage, and outflow relationships maintain water balance across all time periods
7. **Set appropriate minimum flows**: Configure `min_flow` constraints to meet environmental requirements and downstream water needs
8. **Consider evaporation losses**: Include evaporation edges for reservoirs in arid climates or with significant surface area
9. **Test with different scenarios**: Validate performance under various inflow conditions, including drought and flood scenarios
10. **Use global data for common parameters**: Leverage `global_data` to efficiently set parameters that are common across multiple hydro assets

## [Input File (Advanced Format)](@id hydrostreamflow_advanced_json_csv_input_format)

Macro provides an advanced format for defining Hydro Streamflow assets, offering users detailed control over asset specifications. This format builds upon the standard format and is ideal for those who need more comprehensive customization.

To understand the advanced format, consider the [graph representation](@ref hydrostreamflow_asset_structure) and the [type definition](@ref hydrostreamflow_type_definition) of a Hydro Streamflow asset. The input file mirrors this hierarchical structure.

A Hydro Streamflow asset in Macro is composed of a transformation component, a storage component, and thirteen edges. The input file for a Hydro Streamflow asset is therefore organized as follows:

```json
{
    "storage": {
        // ... storage-specific attributes ...
    },
    "transforms": {
        // ... transformation-specific attributes ...
    },
    "edges": {
        "discharge_edge": {
            // ... discharge_edge-specific attributes ...
        },
        "inflow_edge": {
            // ... inflow_edge-specific attributes ...
        },
        "natural_inflow_edge": {
            // ... natural_inflow_edge-specific attributes ...
        },
        "spill_edge": {
            // ... spill_edge-specific attributes ...
        },
        "gen_edge": {
            // ... gen_edge-specific attributes ...
        },
        "tailrace_edge": {
            // ... tailrace_edge-specific attributes ...
        },
        "div_edge": {
            // ... div_edge-specific attributes ...
        },
        "evap_edge": {
            // ... evap_edge-specific attributes ...
        },
        "phs_edge": {
            // ... phs_edge-specific attributes ...
        },
        "load_edge": {
            // ... load_edge-specific attributes ...
        },
        "slack_edge": {
            // ... slack_edge-specific attributes ...
        },
        "rev_edge": {
            // ... rev_edge-specific attributes ...
        }
    }
}
```

Each top-level key denotes a component type. The input structure allows for detailed specification of each component's attributes, constraints, and operational parameters.

Below is an example of an input file for a Hydro Streamflow asset that sets up a comprehensive hydropower system with storage, generation, and pumped hydro capabilities.

```json
{
    "Hydro_Streamflow": [
        {
            "type": "HydroStreamflow",
            "global_data": {
                "storage": {
                    "commodity": "Water",
                    "can_expand": false,
                    "can_retire": false,
                    "has_capacity": true,
                    "constraints": {
                        "BalanceConstraint": true,
                        "MaxStorageLevelConstraint": true,
                        "MinStorageLevelConstraint": true
                    },
                    "existing_capacity": 1000.0,
                    "max_storage_level": 100.0,
                    "min_storage_level": 10.0,
                    "initial_storage_level": 50.0
                },
                "transforms": {
                    "timedata": "Electricity",
                    "constraints": {
                        "BalanceConstraint": true,
                        "CapacityConstraint": true
                    },
                    "specific_prod": 8.5,
                    "head": 150.0,
                    "discharge_coeff": 0.9,
                    "intercept": 0.0
                },
                "edges": {
                    "discharge_edge": {
                        "type": "Water",
                        "has_capacity": true,
                        "can_expand": true,
                        "can_retire": true,
                        "unidirectional": true,
                        "constraints": {
                            "CapacityConstraint": true
                        },
                        "capacity": 500.0,
                        "investment_cost": 50000.0,
                        "fixed_om_cost": 10000.0
                    },
                    "natural_inflow_edge": {
                        "type": "Water",
                        "has_capacity": false,
                        "unidirectional": true,
                        "constraints": {
                            "MustRunConstraint": true
                        }
                    },
                    "spill_edge": {
                        "type": "Water",
                        "has_capacity": false,
                        "unidirectional": true,
                        "min_flow": 10.0
                    },
                    "gen_edge": {
                        "type": "Electricity",
                        "has_capacity": true,
                        "can_expand": true,
                        "can_retire": true,
                        "unidirectional": true,
                        "constraints": {
                            "CapacityConstraint": true
                        },
                        "capacity": 4250.0,
                        "investment_cost": 100000.0,
                        "fixed_om_cost": 20000.0
                    },
                    "phs_edge": {
                        "type": "Water",
                        "has_capacity": true,
                        "can_expand": true,
                        "unidirectional": true,
                        "constraints": {
                            "CapacityConstraint": true
                        },
                        "electricity_consumption": 2.5,
                        "capacity": 100.0,
                        "investment_cost": 20000.0,
                        "fixed_om_cost": 5000.0
                    },
                    "evap_edge": {
                        "type": "Water",
                        "has_capacity": false,
                        "unidirectional": true,
                        "constraints": {
                            "MustRunConstraint": true
                        }
                    }
                }
            },
            "instance_data": [
                {
                    "id": "Hydro_Advanced_SE",
                    "storage": {
                        "initial_storage_level": 60.0
                    },
                    "edges": {
                        "natural_inflow_edge": {
                            "start_vertex": "river_SE"
                        },
                        "gen_edge": {
                            "end_vertex": "elec_SE"
                        },
                        "spill_edge": {
                            "end_vertex": "river_SE"
                        },
                        "tailrace_edge": {
                            "end_vertex": "river_SE"
                        },
                        "div_edge": {
                            "end_vertex": "river_SE"
                        },
                        "evap_edge": {
                            "end_vertex": "atmosphere"
                        },
                        "load_edge": {
                            "start_vertex": "elec_SE"
                        },
                        "slack_edge": {
                            "start_vertex": "river_SE"
                        },
                        "rev_edge": {
                            "start_vertex": "river_SE"
                        }
                    }
                }
            ]
        }
    ]
}
```

### Key Points
- The `global_data` field is utilized to define attributes and constraints that apply universally to all instances of a particular asset type.
- The `start_vertex` and `end_vertex` fields indicate the nodes to which the edges are connected. These nodes must be defined in the `nodes.json` file.
- Storage and transformation components have specific attributes for modeling water balance and electricity generation.
- Edge capacities and constraints control the flow of water and electricity through the system.
- Time series data for natural inflows should be provided to model realistic streamflow variations.

!!! note "Storage Component"
    The storage component represents the water reservoir and includes constraints for maximum and minimum storage levels, which are crucial for operational feasibility.

!!! tip "Prefixes"
    Users can apply prefixes to adjust parameters for the components of a Hydro Streamflow asset, even when using the standard format. For instance, `storage_max_capacity` will adjust the `max_capacity` parameter for the storage component, and `discharge_investment_cost` will adjust the `investment_cost` parameter for the discharge edge.
    Below are the prefixes available for modifying parameters for the components of a Hydro Streamflow asset:
    - `storage_` for the storage component
    - `transform_` for the transformation component
    - `discharge_` for the discharge edge
    - `inflow_` for the inflow edge
    - `natural_inflow_` for the natural inflow edge
    - `spill_` for the spill edge
    - `gen_` for the generation edge
    - `tailrace_` for the tailrace edge
    - `div_` for the diversion edge
    - `evap_` for the evaporation edge
    - `phs_` for the PHS edge
    - `load_` for the load edge
    - `slack_` for the slack edge
    - `rev_` for the reverse edge