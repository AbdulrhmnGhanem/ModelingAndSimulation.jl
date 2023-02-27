include("ModelingAndSimulation.jl")
using .ModelingAndSimulation: State, TimeSeries, flip, plot, plot!, yticks
##
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


function run_simulation(state::State, w_to_o_prabability, o_to_w_probability, num_steps)
    olin = TimeSeries()
    wellesly = TimeSeries()

    for i = 1:num_steps
        step(state, w_to_o_prabability, o_to_w_probability)
        iₛ = Symbol(i)
        olin[iₛ] = state.olin
        wellesly[iₛ] = state.wellesley
    end
    plot(olin;
        label="Olin",
        title="Bike Share Simulation",
        xlabel="Time Stamp",
        ylabel="Number of Bikes",
        yticks=yticks(olin, wellesly)
    )
    plot!(wellesly; label="Wellesley")
end
##
bikeshare1 = State(
    olin=0,
    wellesley=2,
    olin_empty=0,
    wellesley_empty=0,
)
for i = 1:10
    bike_to_wellesley(bikeshare1)
end
@assert bikeshare1.olin == 0 "Olin shouldn't be negative"
@assert bikeshare1.olin_empty == 10 "Olin empty should be 10"
##

bikeshare2 = State(
    olin=10,
    wellesley=2,
    olin_empty=0,
    wellesley_empty=0
)

run_simulation(bikeshare2, 0.3, 0.2, 60)
