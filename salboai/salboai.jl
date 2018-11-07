module Salboai

export canmove,
       initwarn,
       select_direction,
       tick,
       warn

using Main.H
using Dates

include("structs.jl")
include("dummymap.jl")
include("manhattan.jl")
include("pathfinding.jl")
include("pathfinding2.jl")
include("gamestate.jl")
include("simulate.jl")
include("common.jl")
include("collisionavoid.jl")
include("tick.jl")
include("finalcollect.jl")
include("candidatetarget.jl")
include("diamondfilter.jl")
include("dropoff.jl")
include("inspiration.jl")

end
