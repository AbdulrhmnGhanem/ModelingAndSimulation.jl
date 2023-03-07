### A Pluto.jl notebook ###
# v0.19.22

using Markdown
using InteractiveUtils

# ╔═╡ 528a6641-089c-4daf-baea-a7fa94dfc797
begin
	import Pkg
	Pkg.activate("../..")
end

# ╔═╡ 49ee2e76-e168-420a-b171-1d72df8e2aad
using CSV, DataFrames, Plots, Statistics, Formatting

# ╔═╡ d27ba71c-bd0a-11ed-1c67-fbe69e11ad2a
md"""# Chapter 5 - World Popultation
"""

# ╔═╡ 36450353-d508-4c33-b6e7-4b8e7f69cc9d
begin
	f = open("../../ModSimPy/data/World_population_estimates.csv")
	populiation_estimates = CSV.read(f, DataFrames.DataFrame)
	populiation_estimates.un /=  1e9
	populiation_estimates.census /= 1e9
	populiation_estimates
end

# ╔═╡ 6f81fa77-a417-454f-8389-7ecee7b443b1
md"## Plot the world population estimates"

# ╔═╡ ad63d6c1-9d5d-4dcb-9f20-d830577d3bc1
begin
Plots.plot(populiation_estimates.Year, populiation_estimates.census;
	label="US",
	xlabel="Year",
	ylabel="World population (billion)",
	linestyle=:dot,
)
Plots.plot!(populiation_estimates.Year, populiation_estimates.un;
	label="UN",
	linestyle=:dash
)
end

# ╔═╡ 389e8882-7416-497c-9153-17bf49413351
md"## Modeling estimates errors"

# ╔═╡ e0b08315-2feb-4761-befd-3b07a302c818
begin
	abs_error = abs.(populiation_estimates.census - populiation_estimates.un)

	mean_abs_error = trunc(
		Int,
		# If you are wondering about the `skipmissing` function, please read [https://julialang.org/blog/2018/06/missing/]
		Statistics.mean(Statistics.skipmissing(abs_error)) * 1e9
	)
	max_abs_error = trunc(
		Int,
		maximum(Statistics.skipmissing(abs_error)) * 1e9
	)
	
	formatted1(e)  = Formatting.format(e; commas=true)
	
	md"""
	### The absolute error between US Census and UN DESA
	The mean absolute error is **$(formatted1(mean_abs_error))** million.

	The maximum absolute error is **$(formatted1(max_abs_error))** million."""
end

# ╔═╡ a5b5e11a-f487-49c2-a37f-b2afc84b5e49
begin
	relative_error = 100 * abs_error ./ populiation_estimates.census
	mean_relative_error = 		Statistics.mean(Statistics.skipmissing(relative_error))
	max_relative_error = maximum(Statistics.skipmissing(relative_error))

	formatted2(e) = Formatting.sprintf1("%.3f", e)
	
	md"""### The relative error between US Census and UN DESA

	The mean relative error is **$(formatted2(mean_relative_error))%**.
	
	The maximum relative error is **$(formatted2(max_relative_error))%**.
	
	Why did we divide by `census`? The author of the book explains:
	> You might wonder why I divided by census rather than un. In general, if you think one estimate is better than the other, you put the better one in the denominator. In this case, I don't know which is better, so I put the smaller one in the denominator, which makes the computed errors a little bigger.

	.
	"""
end

# ╔═╡ 9ac1283e-6f70-4f24-84ac-2dcf7b6a708e
md"## Modeling population growth"

# ╔═╡ dfd021c3-345d-4b9f-ba36-0517e0d1f70d
function linear_model(estimate, beginnig=1)
	estimate_data = estimate[beginnig:end]
	total_growth = estimate_data[end] - estimate_data[1]
	# assuming constant growth over the years
	annual_growth = total_growth / length(estimate_data)
	p1 = estimate_data[1]
	model = zeros(length(estimate_data))
	model = [p1 + annual_growth * i for (i, _) in zip(Iterators.countfrom(0), model)]
	@assert length(model) == length(estimate_data) "The model should have the same size of the original data. The model is $(length(model)) point while the data is $(length(estimate_data))"
	@assert p1 == estimate_data[1] "The model should have the initial condition of the original data"
	model
end

# ╔═╡ 8f74597c-8e60-4050-ad39-3e1bbead223b
Plots.plot!(populiation_estimates.Year, linear_model(populiation_estimates.census);
	label="Linear model"
)

# ╔═╡ bcd35668-3bdb-4b3f-8759-d2cfcc61c5b3
md"""
## Exercise 5.1
"""

# ╔═╡ f57d00be-6540-45cc-8a35-fb08b0bd6246
begin
	skip_years = 21
	timeline = populiation_estimates.Year[skip_years:end]
	Plots.plot(timeline, populiation_estimates.census[skip_years:end];
	label="US",
	xlabel="Year",
	ylabel="World population (billion)",
	linestyle=:dot,
	)
	m1950 = linear_model(populiation_estimates.census)[skip_years:end]
	m1970 = linear_model(populiation_estimates.census, skip_years)

	Plots.plot!(timeline, m1970;
		label="Linear model (t₀=1970)"
	)
	Plots.plot!(timeline, m1950;
		label="Linear model (t₀=1950)"
	)
end

# ╔═╡ e8416399-9716-4e91-a18d-bd1ccb04270d
md"""### Plot the relative error between the two models and original data
The 1970 model performs better, its error doesn't exceed 2%, while the 1950 model exceeds 1970.
"""

# ╔═╡ 499207e9-1b76-4f32-a006-5628fc2da46f
begin
	estimate_data = populiation_estimates.census[skip_years:end]
	d_m1950 = 100 * abs.(estimate_data - m1950) ./ estimate_data
	d_m1970 = 100 * abs.(estimate_data - m1970) ./ estimate_data
		
	Plots.plot(timeline, d_m1950;
		ylabel="Relative error (%)",
		xlabel="year",
		label="Linear model (t₀=1950)",
	)
	
	Plots.plot!(timeline, d_m1970;
		label="Linear model (t₀=1970)",
	)
end

# ╔═╡ Cell order:
# ╟─d27ba71c-bd0a-11ed-1c67-fbe69e11ad2a
# ╟─528a6641-089c-4daf-baea-a7fa94dfc797
# ╠═49ee2e76-e168-420a-b171-1d72df8e2aad
# ╠═36450353-d508-4c33-b6e7-4b8e7f69cc9d
# ╟─6f81fa77-a417-454f-8389-7ecee7b443b1
# ╠═ad63d6c1-9d5d-4dcb-9f20-d830577d3bc1
# ╟─389e8882-7416-497c-9153-17bf49413351
# ╠═e0b08315-2feb-4761-befd-3b07a302c818
# ╠═a5b5e11a-f487-49c2-a37f-b2afc84b5e49
# ╠═9ac1283e-6f70-4f24-84ac-2dcf7b6a708e
# ╠═dfd021c3-345d-4b9f-ba36-0517e0d1f70d
# ╠═8f74597c-8e60-4050-ad39-3e1bbead223b
# ╠═bcd35668-3bdb-4b3f-8759-d2cfcc61c5b3
# ╠═f57d00be-6540-45cc-8a35-fb08b0bd6246
# ╟─e8416399-9716-4e91-a18d-bd1ccb04270d
# ╟─499207e9-1b76-4f32-a006-5628fc2da46f
