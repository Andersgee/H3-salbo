include("../../hlt/halite.jl")
include("../salboai.jl")

H.setdefaultconstants()

using Test

M2 = [10 0 0 0
      0  0 0 0
      0  0 0 0
      0  0 0 0]
ship = H.Ship(0, 0, CartesianIndex(2,1), 0)
shipyard = CartesianIndex(2,2)
C, Ms, S, D = Salboai.simulate(select_direction, M2, ship, shipyard, 5)


@test C == ['n', 'o', 'o', 'o', 'o']
@test [m[1,1] for m in Ms] == [10, 7, 5, 3, 2]


@test [s.p for s in S] == CartesianIndex.([(1, 1),
                                           (1, 1),
                                           (1, 1),
                                           (1, 1),
                                           (1, 1)])
@test [s.halite for s in S] == [0, 3, 5, 7, 8]


# 1: 3/4
# 2: 5/5

M2 = [0 0 0 0
      0 0 0 0
      0 0 0 0
      0 0 10 0]

ship = H.Ship(0, 0, CartesianIndex(2,3), 3)
shipyard = CartesianIndex(2,2)
C, Ms, S, D = Salboai.simulate(select_direction, M2, ship, shipyard, 15)

@test [s.halite for s in S] == [3, 3, 6, 8, 10, 11, 12, 13, 13, 13, 13, 13, 13, 13, 13]
