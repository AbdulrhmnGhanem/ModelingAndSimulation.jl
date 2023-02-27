module ModelingAndSimulation
using DataFrames
using ReusePatterns

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

# Alias TimeSeries to DataFrame
const TimeSeries = DataFrame

flip(p=0.5) = rand() < p
end
