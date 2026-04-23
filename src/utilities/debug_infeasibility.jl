using JuMP, Gurobi, MathOptInterface
const MOI = MathOptInterface

function debug_infeasibility!(case)

    println("--------------------------------------------------")
    println("Debugging infeasibility...")
    println("--------------------------------------------------")

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

    backend_model = backend(model)

    println("\n================ IIS REPORT ================\n")

    # -------------------------------------------------
    # 1. Constraint conflicts
    # -------------------------------------------------
    println("Constraints in conflict:\n")

    for (F, S) in JuMP.list_of_constraint_types(model)
        for c in JuMP.all_constraints(model, F, S)

            status = MOI.get(
                backend_model.optimizer,
                MOI.ConstraintConflictStatus(),
                JuMP.index(c)
            )

            if status == MOI.IN_CONFLICT
                cname = JuMP.name(c)

                if isempty(cname)
                    println("Unnamed constraint:")
                else
                    println("Constraint: ", cname)
                end

                println("Expression: ", c)
                println("------------------------------------------")
            end
        end
    end

    # -------------------------------------------------
    # 2. Variable bound conflicts
    # -------------------------------------------------
    println("\nVariable bounds in conflict:\n")

    for v in JuMP.all_variables(model)

        # Lower bound
        if JuMP.has_lower_bound(v)
            ci = JuMP.LowerBoundRef(v)

            status = MOI.get(
                backend_model.optimizer,
                MOI.ConstraintConflictStatus(),
                JuMP.index(ci)
            )

            if status == MOI.IN_CONFLICT
                println("Lower bound conflict:")
                println("Variable: ", JuMP.name(v))
                println("Bound: ", v, " >= ", JuMP.lower_bound(v))
                println("------------------------------------------")
            end
        end

        # Upper bound
        if JuMP.has_upper_bound(v)
            ci = JuMP.UpperBoundRef(v)

            status = MOI.get(
                backend_model.optimizer,
                MOI.ConstraintConflictStatus(),
                JuMP.index(ci)
            )

            if status == MOI.IN_CONFLICT
                println("Upper bound conflict:")
                println("Variable: ", JuMP.name(v))
                println("Bound: ", v, " <= ", JuMP.upper_bound(v))
                println("------------------------------------------")
            end
        end
    end

    println("\n============= END IIS REPORT =============\n")

end