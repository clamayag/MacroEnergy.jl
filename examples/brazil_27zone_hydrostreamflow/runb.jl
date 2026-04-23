using MacroEnergy
using Gurobi

(systems, solution) = run_case(
    @__DIR__;
    planning_optimizer=Gurobi.Optimizer,
    subproblem_optimizer=Gurobi.Optimizer,
    planning_optimizer_attributes=(
        "Method" => 2,
        "Crossover" => 0,
        "BarConvTol" => 1e-3,
        "Threads" => 4,
    ),
    subproblem_optimizer_attributes=(
        "Method" => 2,
        "Crossover" => 0,
        "BarConvTol" => 1e-3,
        "Threads" => 1,
    ),
);