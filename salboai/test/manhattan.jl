include("../../hlt/halite.jl")
include("../salboai.jl")

using Test

r = zeros(4,4)
d = Salboai.manhattandistmatrix(r, CartesianIndex(3,2))

@test d == [3 2 3 4
            2 1 2 3
            1 0 1 2
            2 1 2 3]
