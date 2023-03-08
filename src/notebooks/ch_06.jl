### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 206da3e8-bd7f-11ed-1748-233225fd6852
begin
	import Pkg
	Pkg.activate("../..")
end

# ╔═╡ 36d6fdb2-1531-4d62-8d8b-b1cee9cd747d
using CSV, DataFrames, Plots, PlutoUI

# ╔═╡ 75a49dbb-0852-46ec-98f0-5018b71063b4
md"# Chapter 6 - Modeling Growth"

# ╔═╡ 0a725bfc-dcef-45cc-a75d-8ac7e280ab2d
begin
	f = open("../../ModSimPy/data/World_population_estimates.csv")
	populiation_estimates = CSV.read(f, DataFrames.DataFrame)
	populiation_estimates.un /= 1e9
	populiation_estimates.census /= 1e9
	populiation_estimates
	##
end

# ╔═╡ e74479fe-71b3-4d3e-853c-a2b42cfa6035
begin
	t₀ = populiation_estimates.Year[1]
	tₜ = populiation_estimates.Year[end]
	p₀ = populiation_estimates.census[1]
	pₜ = populiation_estimates.census[end]
	annual_growth = (pₜ - p₀) / (tₜ - t₀)
	system = Dict(
	    :t₀ => t₀,
	    :tₜ => tₜ,
	    :p₀ => p₀,
	    :pₜ => pₜ,
	    :ag => annual_growth,
	)
end

# ╔═╡ d26c716f-51bd-49f6-bbe6-203c007f43d9
begin
	function run_simulation1(system::Dict)
	    results = DataFrame()
	    results[!, Symbol(system[:t₀])] = [system[:p₀]]
	
	    for t = system[:t₀]:system[:tₜ]-1
	        results[!, Symbol(t + 1)] = results[!, Symbol(t)] .+ system[:ag]
	    end
	    return results
	end
	
	YSeries(df::DataFrame) = vec(Matrix(values(df)))
end

# ╔═╡ f14a3b26-52a2-42b3-a4ca-1cbdab728e37
simulation1 = run_simulation1(system)

# ╔═╡ 42f7fa64-bdbe-4447-b6d5-5f80a159c6a8
begin
	timeline = system[:t₀]:system[:tₜ]
	Plots.plot(timeline, populiation_estimates.census;
	    label="US",
	    xlabel="Year",
	    ylabel="Population (billions)",
	    linestyle=:dot
	)
	Plots.plot!(timeline, populiation_estimates.un, label="UN", linestyle=:dash)
	plot!(timeline, YSeries(simulation1); label="Model")
end

# ╔═╡ da4b3006-5ec0-4a89-8843-b00de23dce0e
md"## Proportional growth model"

# ╔═╡ be754a8f-8d4e-44d8-a90f-d457493db7a1
begin

	function run_simulation2(system::Dict)
	    results = DataFrame()
	    results[!, Symbol(system[:t₀])] = [system[:p₀]]
	
	    for t = system[:t₀]:system[:tₜ]-1
			births = results[!, Symbol(t)] * system[:br]
	        deaths = results[!, Symbol(t)] * system[:dr]
	        results[!, Symbol(t + 1)] = results[!, Symbol(t)] .+ system[:ag]
	    end
	    return results
	end
	system[:dr] = 7.7 / 1000
	system[:br] = 25 / 1000
end

# ╔═╡ f247fe46-cd03-4a91-ae6c-53d15ec9c651
simulation2 = run_simulation2(system)


# ╔═╡ 7db5266b-507a-4aef-a903-11de11267a67
begin
	Plots.plot(timeline, populiation_estimates.census;
	    title="Proportional growth model",
	    label="US",
	    xlabel="Year",
	    ylabel="Population (billions)",
	    linestyle=:dot
	)
	Plots.plot!(timeline, populiation_estimates.un, label="UN", linestyle=:dash)
	plot!(timeline, YSeries(simulation2); label="Model")
end

# ╔═╡ ee529087-517c-4d98-825f-1771dad0b55e
function growth(population, system, t)
    births = population * system[:br]
    deaths = population * system[:dr]
    return births - deaths
end

# ╔═╡ 160f8640-ae8b-4baa-b80f-76dbc4fb34fb
function run_simulation3(system, growth_function)
    results = DataFrame()
	results[!, Symbol(system[:t₀])] = [system[:p₀]]
    for t = system[:t₀]:system[:tₜ]-1
        results[!, Symbol(t + 1)] = results[!, Symbol(t)] + growth_function(results[!, Symbol(t)], system, t)
    end
    return results
end

# ╔═╡ 7d46aaf4-dc92-4b43-ba80-016eb9108397
simulation3 = run_simulation3(system, growth)


# ╔═╡ bcfe6cab-9934-4a0e-b9ea-201d45df3e99
begin
	Plots.plot(timeline, populiation_estimates.census;
	    title="Proportional growth model",
	    label="US",
	    xlabel="Year",
	    ylabel="Population (billions)",
	    linestyle=:dot
	)
	Plots.plot!(timeline, populiation_estimates.un, label="UN", linestyle=:dash)
	plot!(timeline, YSeries(simulation3); label="Model")
end

# ╔═╡ 20584956-4b6c-4989-ba2e-5ce167962e1a
begin
	system2 = Dict(
	    :t₀ => t₀,
	    :tₜ => tₜ,
	    :p₀ => p₀,
	    :pₜ => pₜ,
	    :ag => annual_growth,
	    :α => 25 / 1000 - 7.7 / 1000,
	)
	growthα(population, system, t) = population * system[:α]
end

# ╔═╡ 0d516810-9c13-42b2-8178-59421b04a997
simulation4 = run_simulation3(system2, growthα)

# ╔═╡ a3cacf8f-9b68-449e-aecc-d0e6ced62c28
begin
	Plots.plot(timeline, populiation_estimates.census;
	    title="Proportional growth model",
	    label="US",
	    xlabel="Year",
	    ylabel="Population (billions)",
	    linestyle=:dot
	)
	Plots.plot!(timeline, populiation_estimates.un, label="UN", linestyle=:dash)
	plot!(timeline, YSeries(simulation3); label="Model")
end

# ╔═╡ f0adb562-f048-4ae1-918e-e2636f5b3806

function growthα3(population, system, t)
	if t > 1980
		return population * system[:α1]
	else
		return population * system[:α2]
	end
end


# ╔═╡ 79f4798a-3369-4c02-93b2-a06727a81563
@bind α1 Slider(0.010:0.001:0.020)

# ╔═╡ 325e1924-a4fe-4cbf-8d0d-9dab58b349c7
@bind α2 Slider(0.015:0.001:0.020)

# ╔═╡ 5ed4637b-5f56-40bf-9c83-ce1eb041b16b
begin
	system3 = Dict(
	    :t₀ => t₀,
	    :tₜ => tₜ,
	    :p₀ => p₀,
	    :pₜ => pₜ,
	    :ag => annual_growth,
	    :α1 => α1,
	    :α2 => α2,
	)
	simulation5 = run_simulation3(system3, growthα3)
	Plots.plot(timeline, populiation_estimates.census;
	    title="Variable Growth Model (α1 = $α1, α2 = $α2)",
	    label="US",
	    xlabel="Year",
	    ylabel="Population (billions)",
	    linestyle=:dot
	)
	Plots.plot!(timeline, populiation_estimates.un, label="UN", linestyle=:dash)
	plot!(timeline, YSeries(simulation5); label="Model")
end

# ╔═╡ Cell order:
# ╟─75a49dbb-0852-46ec-98f0-5018b71063b4
# ╟─206da3e8-bd7f-11ed-1748-233225fd6852
# ╠═36d6fdb2-1531-4d62-8d8b-b1cee9cd747d
# ╠═0a725bfc-dcef-45cc-a75d-8ac7e280ab2d
# ╠═e74479fe-71b3-4d3e-853c-a2b42cfa6035
# ╠═d26c716f-51bd-49f6-bbe6-203c007f43d9
# ╠═f14a3b26-52a2-42b3-a4ca-1cbdab728e37
# ╠═42f7fa64-bdbe-4447-b6d5-5f80a159c6a8
# ╟─da4b3006-5ec0-4a89-8843-b00de23dce0e
# ╠═be754a8f-8d4e-44d8-a90f-d457493db7a1
# ╠═f247fe46-cd03-4a91-ae6c-53d15ec9c651
# ╠═7db5266b-507a-4aef-a903-11de11267a67
# ╠═ee529087-517c-4d98-825f-1771dad0b55e
# ╠═160f8640-ae8b-4baa-b80f-76dbc4fb34fb
# ╠═7d46aaf4-dc92-4b43-ba80-016eb9108397
# ╠═bcfe6cab-9934-4a0e-b9ea-201d45df3e99
# ╠═20584956-4b6c-4989-ba2e-5ce167962e1a
# ╠═0d516810-9c13-42b2-8178-59421b04a997
# ╠═a3cacf8f-9b68-449e-aecc-d0e6ced62c28
# ╠═f0adb562-f048-4ae1-918e-e2636f5b3806
# ╠═79f4798a-3369-4c02-93b2-a06727a81563
# ╠═325e1924-a4fe-4cbf-8d0d-9dab58b349c7
# ╠═5ed4637b-5f56-40bf-9c83-ce1eb041b16b
