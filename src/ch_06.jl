include("ModelingAndSimulation.jl")

using CSV, DataFrames, Plots
using .ModelingAndSimulation: State, TimeSeries, flip, plot, plot!, yticks, mean

##
f = open("ModSimPy/data/World_population_estimates.csv")
populiation_estimates = CSV.read(f, DataFrames.DataFrame)
populiation_estimates.un /= 1e9
populiation_estimates.census /= 1e9
populiation_estimates
##

t₀ = populiation_estimates.Year[1]
tₜ = populiation_estimates.Year[end]
p₀ = populiation_estimates.census[1]
pₜ = populiation_estimates.census[end]
annual_growth = (pₜ - p₀) / (tₜ - t₀)
system = ModelingAndSimulation.System(
    :t₀ => t₀,
    :tₜ => tₜ,
    :p₀ => p₀,
    :pₜ => pₜ,
    :ag => annual_growth,
)
##
function run_simulation1(system::ModelingAndSimulation.System)
    results = TimeSeries()
    results[Symbol(system[:t₀])] = system[:p₀]

    for t = system[:t₀]:system[:tₜ]
        results[Symbol(t + 1)] = results[Symbol(t)] + system[:ag]
    end
    return results
end
##
simulation1 = run_simulation1(system)
##
timeline = system[:t₀]:system[:tₜ]
Plots.plot(timeline, populiation_estimates.census;
    label="US",
    xlabel="Year",
    ylabel="Population (billions)",
    linestyle=:dot
)
Plots.plot!(timeline, populiation_estimates.un, label="UN", linestyle=:dash)
plot!(simulation1; label="Model")
##
function run_simulation2(system)
    results = TimeSeries()
    results[Symbol(system[:t₀])] = system[:p₀]

    for t = system[:t₀]:system[:tₜ]
        births = results[Symbol(t)] * system[:br]
        deaths = results[Symbol(t)] * system[:dr]
        results[Symbol(t + 1)] = results[Symbol(t)] + births - deaths
    end
    return results
end
##
system[:dr] = 7.7 / 1000
system[:br] = 25 / 1000
##
simulation2 = run_simulation2(system)
Plots.plot(timeline, populiation_estimates.census;
    title="Proportional growth model",
    label="US",
    xlabel="Year",
    ylabel="Population (billions)",
    linestyle=:dot
)
Plots.plot!(timeline, populiation_estimates.un, label="UN", linestyle=:dash)
plot!(simulation2; label="Model")
##
function growth(population, system, t)
    births = population * system[:br]
    deaths = population * system[:dr]
    return births - deaths
end

function run_simulation3(system, growth_function)
    results = TimeSeries()
    results[Symbol(system[:t₀])] = system[:p₀]

    for t = system[:t₀]:system[:tₜ]
        results[Symbol(t + 1)] = results[Symbol(t)] + growth_function(results[Symbol(t)], system, t)
    end
    return results
end
##
simulation3 = run_simulation3(system, growth)
simulation2 = run_simulation2(system)
Plots.plot(timeline, populiation_estimates.census;
    title="Proportional growth model",
    label="US",
    xlabel="Year",
    ylabel="Population (billions)",
    linestyle=:dot
)
Plots.plot!(timeline, populiation_estimates.un, label="UN", linestyle=:dash)
plot!(simulation3; label="Model")
##
system = ModelingAndSimulation.System(
    :t₀ => t₀,
    :tₜ => tₜ,
    :p₀ => p₀,
    :pₜ => pₜ,
    :ag => annual_growth,
    :α => 25 / 1000 - 7.7 / 1000,
)
##
growthα(population, system, t) = population * system[:α]
##
simulation4 = run_simulation3(system, growthα)
Plots.plot(timeline, populiation_estimates.census;
    title="Proportional growth model",
    label="US",
    xlabel="Year",
    ylabel="Population (billions)",
    linestyle=:dot
)
Plots.plot!(timeline, populiation_estimates.un, label="UN", linestyle=:dash)
plot!(simulation3; label="Model")
##
system = ModelingAndSimulation.System(
    :t₀ => t₀,
    :tₜ => tₜ,
    :p₀ => p₀,
    :pₜ => pₜ,
    :ag => annual_growth,
    :α1 => 26.5 / 1000 - 8 / 1000,
    :α2 => 23.5 / 1000 - 6.0 / 1000,
)
##
function growthα2(population, system, t)
    if t > 1980
        return population * system[:α1]
    else
        return population * system[:α2]
    end
end
##

simulation5 = run_simulation3(system, growthα2)
Plots.plot(timeline, populiation_estimates.census;
    title="Variable growth model",
    label="US",
    xlabel="Year",
    ylabel="Population (billions)",
    linestyle=:dot
)
Plots.plot!(timeline, populiation_estimates.un, label="UN", linestyle=:dash)
plot!(simulation5; label="Model")