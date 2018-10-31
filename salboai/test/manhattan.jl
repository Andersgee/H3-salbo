include("../../hlt/halite.jl")
include("../salboai.jl")

using Test
using Main.Salboai: splitview

r = zeros(4,4)
d = Salboai.manhattandistmatrices(r, CartesianIndex(3,2))

d1, d2, d3, d4 = splitview(d, dims=3)

@test d1 == [5 2 3 4
             4 1 2 3
             3 0 1 2
             6 3 4 5]

@test d2 == [3 2 5 4
             2 1 4 3
             1 0 3 2
             4 3 6 5]

@test d3 == [3 2 5 4
             4 3 6 5
             1 0 3 2
             2 1 4 3]

@test d4 == [5 2 3 4
             6 3 4 5
             3 0 1 2
             4 1 2 3]

@test 3 == Salboai.manhattandist((4,4), (1,1), (3,4))
