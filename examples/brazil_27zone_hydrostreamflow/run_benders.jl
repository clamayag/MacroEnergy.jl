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

planning_optimizer = Gurobi.Optimizer
subproblem_optimizer = Gurobi.Optimizer
planning_optimizer_attributes = ("BarConvTol" => 1e-3, "Crossover" => 0, "Method" => 2)
subproblem_optimizer_attributes = ("BarConvTol" => 1e-3, "Crossover" => 1, "Method" => 2)

optimizer = MacroEnergy.create_optimizer_benders(planning_optimizer, subproblem_optimizer,
    planning_optimizer_attributes, subproblem_optimizer_attributes)

if case.settings.BendersSettings[:Distributed]
    number_of_subproblems = sum(length(system.time_data[:Electricity].subperiods) for system in case.systems)
    start_distributed_processes!(number_of_subproblems, case_path)
end

(case, solution) = MacroEnergy.solve_case(case, optimizer);

results_path = "examples/brazil_27zone_hydrostreamflow/benders_results"
results_path = MacroEnergy.create_output_path(case.systems[1], results_path)
write_outputs(results_path, case, solution)

if case.settings.BendersSettings[:Distributed] && length(workers()) > 1
    rmprocs.(workers())
end     