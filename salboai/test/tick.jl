include("../../hlt/halite.jl")
include("../salboai.jl")

using Test

H.setdefaultconstants()

g = Salboai.dummyGameMap((32, 32))

Salboai.initwarn(IOBuffer())

# warmup
warmuptime = @elapsed Salboai.warmup()

# time
ticktime = @elapsed Salboai.tick(g, div(Salboai.max_turns(g), 2))

@show warmuptime
@show ticktime

@test warmuptime > 1
@test ticktime < 0.2
