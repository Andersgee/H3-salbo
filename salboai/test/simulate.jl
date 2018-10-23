include("../../hlt/halite.jl")
include("../salboai.jl")

using Test

M2 = [10 0 0 0
      0  0 0 0
      0  0 0 0
      0  0 0 0]
ship = H.Ship(0, 0, CartesianIndex(2,1), 0)
shipyard = CartesianIndex(2,2)
C, Ms, S = Salboai.simulate(M2, ship, shipyard, 3)

@test C == ['n', 'o', 'n']
@test [m[1,1] for m in Ms] == [10, 7, 7]
@test [s.p for s in S] == CartesianIndex.([(1, 1),
                                           (1, 1),
                                           (4, 1)])
@test [s.halite for s in S] == [0, 3, 3]
