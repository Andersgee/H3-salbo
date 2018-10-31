module Salboai

export canmove,
       initwarn,
       select_direction,
       tick,
       warn

using Main.H
using Dates

include("dummymap.jl")
include("manhattan.jl")
include("pathfinding.jl")
include("simulate.jl")
include("common.jl")
include("collisionavoid.jl")
include("tick.jl")
include("finalcollect.jl")

end
