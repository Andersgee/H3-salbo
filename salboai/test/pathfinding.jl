include("../../hlt/halite.jl")
include("../salboai.jl")

using Test
using Main.Salboai: splitview

H.setdefaultconstants()

M = [1 2 3
     3 1 2
     2 1 3]

C, D = Salboai.quadrant_travelcost(10M);
@test C == [0 1 3
            1 3 4
            4 4 5]
@test D == [4 1 1
            0 1 1
            0 1 1]

Mo = Salboai.shiftorigin(M, CartesianIndex(3,2))
@test Mo == [1 3 2
             2 3 1
             1 2 3]

@test Salboai.q1(M) == [1 2 3
                        2 1 3
                        3 1 2]

@test Salboai.q2(M) == [1 3 2
                        2 3 1
                        3 2 1]

@test Salboai.q3(M) == [1 3 2
                        3 2 1
                        2 3 1]

@test Salboai.q4(M) == M


C, D, MHD = Salboai.travelcost(10M, CartesianIndex(2,2))

@test C == [3 1 3
 1 0 1
 2 1 2]

@test D == ['n'  'n'  'n'
 'w'  'o'  'e'
 's'  's'  's']

C, D = Salboai.travelcost(10M, CartesianIndex(3,2))


@test C == [3 1 3
          2 1 2
          1 0 1]

@test D == ['s' 's' 's'
              'n' 'n' 'n'
              'w' 'o' 'e']

M2=10*M; M2[2,2]=0
hpt, cost1, direction1 = Salboai.halite_per_turn(M2, H.Ship(0, 0, CartesianIndex(2,1), 0), CartesianIndex(2,2))

M2

@test hpt[2,1]==8
#@test hpt[3,1]==(-3 + 20*0.25 - 1 -1)/4

hpt

@test hpt ≈ [0.0   0.666667  1.33333
    8.0  -1.5       1.0
    1.0   0.0       1.0] atol=1e-4

@test cost1 == [3  3  4
 0  3  3
 3  3  4]

@test direction1 == ['n'  'e'  'n'
 'o'  'e'  'w'
 's'  'e'  'e']

M2 = [10 0 0 0
      0 0 0 0
      0 0 0 0
      0 0 0 0]

d = Salboai.select_direction(M2, H.Ship(0, 0, CartesianIndex(2,1), 0), CartesianIndex(2,2))
@test d == 'n'


M2 = [7 0 0 0
      0 0 0 0
      0 0 0 0
      0 0 0 0]

d = Salboai.select_direction(M2, H.Ship(0, 0, CartesianIndex(1,1), 3), CartesianIndex(2,2))
@test d == 'o'

M2 = [0 0 0 0
      0 0 0 0
      0 0 0 0
      0 0 10 0]

ship = H.Ship(0, 0, CartesianIndex(2,3), 3)
shipyard = CartesianIndex(2,2)
d = Salboai.select_direction(M2, ship, shipyard)
@test d == 'n'

M2 = [0 70 0 0
      0 0 90 0
      0 50 0 0
      0 0 0 0]
ship = H.Ship(0, 0, CartesianIndex(2,2), 3)
shipyard = CartesianIndex(4,4)
d = Salboai.select_direction(M2, ship, shipyard)
@test d == 'e'

hpt, cost1, direction1 = Salboai.halite_per_turn(M2,ship,shipyard)
@test cost1 == [0  0  0  0
 0  0  0  0
 0  0  0  0
 0  5  0  0]
