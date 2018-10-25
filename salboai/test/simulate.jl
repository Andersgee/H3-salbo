include("../../hlt/halite.jl")
include("../salboai.jl")

using Test

M2 = [10 0 0 0
      0  0 0 0
      0  0 0 0
      0  0 0 0]
ship = H.Ship(0, 0, CartesianIndex(2,1), 0)
shipyard = CartesianIndex(2,2)
C, Ms, S, D = Salboai.simulate(M2, ship, shipyard, 5)

@test C == ['n', 'o', 's', 'e', 'n']
@test [m[1,1] for m in Ms] == [10, 7, 7, 7, 7]
@test [s.p for s in S] == CartesianIndex.([(1, 1),
                                           (1, 1),
                                           (2, 1),
                                           (2, 2),
                                           (1, 2)])
@test [s.halite for s in S] == [0, 3, 3, 0, 0]


M2 = [0 0 0 0
      0 0 0 0
      0 0 0 0
      0 0 10 0]

ship = H.Ship(0, 0, CartesianIndex(2,3), 3)
shipyard = CartesianIndex(2,2)
C, Ms, S, D = Salboai.simulate(M2, ship, shipyard, 15)

@test C == ['w', 'n', 'n', 'e', 'o', 'o', 'n', 'n', 'w', 'n', 'n', 'e', 'o', 'o', 'n']
@test [s.halite for s in S] == [0, 0, 0, 0, 3, 5, 5, 5, 0, 0, 0, 0, 2, 3, 3]
