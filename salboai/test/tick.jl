include("../../hlt/halite.jl")
include("../salboai.jl")

using Test

H.setdefaultconstants()

Salboai.initwarn(IOBuffer())

# warmup
warmuptime = @elapsed Salboai.warmup()

# time
g = Salboai.dummyGameMap((32, 32))
ticktime = @elapsed Salboai.tick(g, div(Salboai.max_turns(g), 2))

@show warmuptime
@show ticktime

@test warmuptime > 1
@test ticktime < 0.2

g = Salboai.dummyGameMap((64, 64))
ticktime64 = @elapsed Salboai.tick(g, div(Salboai.max_turns(g), 2))
@test 0.5 < ticktime64 < 1.5
