module ModelingAndSimulation
using DataFrames
using ReusePatterns
using Plots
using Statistics

struct State <: AbstractDataFrame
    df::DataFrame
end

@forward((State, :df), DataFrame)

function Base.getproperty(state::State, key::Symbol)
    val = state[!, key]
    if isa(val, AbstractVector) && length(val) == 1
        return val[1]
    end
    return val
end

function Base.setproperty!(state::State, key::Symbol, x)
    if !isa(x, AbstractVector)
        val = [x]
    end
    state[!, key] = val
end

function Base.setindex!(state::State, x, key::Symbol)
    val = x
    if !isa(x, AbstractVector)
        val = [x]
    end
    state[!, key] = val
end

State(; args...) = State(DataFrame(; args...))

# Alias TimeSeries to State
const TimeSeries = State

function plot(ts::TimeSeries; plotter=Plots.plot, kwargs...)
    x = try
        [parse(Int, s) for s in names(ts)]
    catch
        [parse(Float64, s) for s in names(ts)]
    end
    y = vec(Matrix(values(ts)))
    plotter(x, y; kwargs...)
end

plot!(ts::TimeSeries; kwargs...) = plot(ts; plotter=Plots.plot!, kwargs...)

function yticks(tss::TimeSeries...)
    ys = [vec(Matrix(values(ts))) for ts in tss]
    max_ys = [maximum(y) for y in ys]
    min_ys = [minimum(y) for y in ys]
    return minimum(min_ys):2:maximum(max_ys)
end

function mean(ts::TimeSeries)
    return Statistics.mean(Matrix(ts))
end

flip(p=0.5) = rand() < p
end
