include("../../hlt/halite.jl")
include("../salboai.jl")

using Test
using BenchmarkTools
using Random

H.setdefaultconstants()

Salboai.initwarn(IOBuffer())

Random.seed!(0)
g32 = Salboai.dummyGameMap((32, 32))
g64 = Salboai.dummyGameMap((64, 64))

# warmup
warmuptime = @elapsed state32 = Salboai.init(g32)
state64 = Salboai.init(g64)
@show warmuptime
@test warmuptime > 1

# time
println("ticktime 32")
@btime Salboai.tick(state32, g32, div(Salboai.max_turns(g32), 2))

println("ticktime 64")
@btime Salboai.tick(state64, g64, div(Salboai.max_turns(g64), 2))

#=
using Profile
@profile Salboai.tick(g64, div(Salboai.max_turns(g64), 2))
using ProfileView
ProfileView.view()
=#
