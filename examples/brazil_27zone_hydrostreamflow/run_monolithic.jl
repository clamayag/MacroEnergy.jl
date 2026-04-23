#cd Documents/Github/MacroEnergy.jl
#julia --project=.

using MacroEnergy
using Gurobi
using Logging
using JuMP

case_path = "examples/brazil_27zone_hydrostreamflow"
lazy_load = true

# Logging
log_level = Logging.Info
log_to_console = true
log_to_file = true
log_file_path = joinpath(case_path, "$(basename(case_path)).log")
log_file_attribution = true

optimizer = Gurobi.Optimizer
optimizer_env = nothing
optimizer_attributes = ("BarConvTol" => 1e-3, "Crossover" => 0, "Method" => 2, "OutputFlag" => 1, "BarHomogeneous" => 1, "NumericFocus" => 3)

MacroEnergy.set_logger(log_to_console, log_to_file, log_level, log_file_path, log_file_attribution)

case = MacroEnergy.load_case(case_path; lazy_load=lazy_load);

optim = MacroEnergy.create_optimizer(optimizer, optimizer_env, optimizer_attributes)
       
(case, solution) = MacroEnergy.solve_case(case, optim);

results_path = "examples/brazil_27zone_hydrostreamflow/monolithic_results"

results_path = MacroEnergy.create_output_path(case.systems[1], results_path)
MacroEnergy.write_outputs(results_path, case, solution)


# Debugging infeasibility
using JuMP, Gurobi, MathOptInterface
const MOI = MathOptInterface

function debug_infeasibility!(case)

    println("--------------------------------------------------")
    println("Building model with Presolve ON")
    println("--------------------------------------------------")

    optim_iis = MacroEnergy.create_optimizer(
        Gurobi.Optimizer,
        nothing,
        ("Presolve" => 2, "OutputFlag" => 1)
    )

    model = MacroEnergy.generate_model(case, optim_iis)

    println("Computing conflict...")

    optimize!(model)   # Attach optimizer

    MOI.compute_conflict!(backend(model))



end


debug_infeasibility!(case)

