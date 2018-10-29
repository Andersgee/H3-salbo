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
warmuptime = @elapsed Salboai.warmup()
@show warmuptime
@test warmuptime > 1

# time
println("ticktime 32")
@btime Salboai.tick(g32, div(Salboai.max_turns(g32), 2))

println("ticktime 64")
@btime Salboai.tick(g64, div(Salboai.max_turns(g64), 2))

#=
using Profile
@profile Salboai.tick(g64, div(Salboai.max_turns(g64), 2))
using ProfileView
ProfileView.view()
=#
