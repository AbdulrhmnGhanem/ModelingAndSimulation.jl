include("ModelingAndSimulation.jl")
using .ModelingAndSimulation: State, TimeSeries, flip, plot, plot!, yticks
##

# Exercise 2.3
bikeshare = State(
    wellesley=20,
    olin=10,
)

function bike_to_wellesly()
    println("Moving bike from Olin to Wellesley!")
    bikeshare.wellesley += 1
    bikeshare.olin -= 1
end
function bike_to_olin()
    println("Moving bike from Wellesley to Olin!")
    bikeshare.wellesley -= 1
    bikeshare.olin += 1
end

function step(w_to_o_prabability, o_to_w_probability)
    if flip(w_to_o_prabability)
        bike_to_olin()
    end
    if flip(o_to_w_probability)
        bike_to_wellesly()
    end
end

function run_simulation(w_to_o_prabability, o_to_w_probability, num_steps)
    olin = TimeSeries()
    wellesly = TimeSeries()

    for i = 1:num_steps
        step(w_to_o_prabability, o_to_w_probability)
        iₛ = Symbol(i)
        olin[iₛ] = bikeshare.olin
        wellesly[iₛ] = bikeshare.wellesley
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

run_simulation(0.6, 0.4, 60)