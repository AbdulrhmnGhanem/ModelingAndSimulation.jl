include("ModelingAndSimulation.jl")
using .ModelingAndSimulation: State, TimeSeries, flip, plot, plot!, yticks, mean
##

# Exercise 4.3/4.4
function bike_to_wellesley(state::State)
    if state.olin > 0
        state.wellesley += 1
        state.olin -= 1
    else
        state.olin_empty += 1
    end
end

function bike_to_olin(state::State)
    if state.wellesley > 0
        state.wellesley -= 1
        state.olin += 1
    else
        state.wellesley_empty += 1
    end
end

function step(state::State, w_to_o_prabability, o_to_w_probability)
    if flip(w_to_o_prabability)
        bike_to_olin(state)
    end
    if flip(o_to_w_probability)
        bike_to_wellesley(state)
    end
end

function run_simulation(w_to_o_prabability, o_to_w_probability, num_steps)
    state = State(
        olin=10,
        wellesley=2,
        olin_empty=0,
        wellesley_empty=0
    )

    for _ = 1:num_steps
        step(state, w_to_o_prabability, o_to_w_probability)
    end

    return state
end

function sweep_w_to_o_prabability(w_to_o_prababiliies)
    o_to_w_probability = 0.2
    num_steps = 60
    sweep = TimeSeries()

    for p in w_to_o_prababiliies
        state = run_simulation(p, o_to_w_probability, num_steps)
        sweep[Symbol(p)] = state.olin_empty
    end
    return sweep
end

function sweep_o_to_w_prabability(o_to_w_prababiliies)
    w_to_o_probability = 0.5
    num_steps = 60
    sweep = TimeSeries()

    for p in o_to_w_prababiliies
        state = run_simulation(w_to_o_probability, p, num_steps)
        sweep[Symbol(p)] = state.wellesley_empty
    end
    return sweep
end

sweep_range = 0:0.01:1
##
sweep = sweep_w_to_o_prabability(sweep_range)
plot(sweep; label="Olin", xlabel="w_to_o_prabability", ylabel="olin_empty", seriestype=:scatter)

##
swep = sweep_o_to_w_prabability(sweep_range)
plot(swep; label="Wellesley", xlabel="o_to_w_prabability", ylabel="olin_empty", seriestype=:scatter)
##

# Exercise 4.5/4.6
w_to_o_prababilities = 0:0.01:1
o_to_w_probability = 0.3
num_steps = 60
num_runs = 20

function run_multiple_simulations(w_to_o_prabability, o_to_w_probability, num_steps, num_runs)
    unhappy = TimeSeries()

    for i = 1:num_runs
        state = run_simulation(w_to_o_prabability, o_to_w_probability, num_steps)
        unhappy[Symbol(i)] = state.olin_empty + state.wellesley_empty
    end
    return unhappy
end

sweep = TimeSeries()

for p in w_to_o_prababilities
    unhappy = run_multiple_simulations(p, o_to_w_probability, num_steps, num_runs)
    sweep[Symbol(p)] = mean(unhappy)
end

plot(sweep;
    label="Olin",
    xlabel="Arrival at Olin",
    ylabel="Unhappy customers at Olin and Wellesley",
    seriestype=:scatter
)
