include("../../hlt/halite.jl")
include("../salboai.jl")

using Test

H.setdefaultconstants()
g = Salboai.dummyGameMap((32, 32))

@test typeof(H.me(g)) == H.Player
