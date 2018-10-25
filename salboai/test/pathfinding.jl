include("../../hlt/halite.jl")
include("../salboai.jl")

using Test
using Main.Salboai: splitview

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


C, D = Salboai.travelcost(10M, CartesianIndex(2,2))
C1, C2, C3, C4 = splitview(C, dims=3)

@test C1 == [6 1 3
             3 0 1
             7 3 4]

@test C2 == [3 1 4
             1 0 4
             4 3 6]

@test C3 == [4 2 5
             1 0 4
             2 1 4]

@test C4 == [7 2 4
             3 0 1
             5 1 2]

D1, D2, D3, D4 = splitview(D, dims=3)

@test D1 == ['n' 'n' 'n'
             'w' 'o' 'w'
             'n' 'n' 'n']

@test D2 == ['n' 'n' 'n'
             'e' 'o' 'e'
             'n' 'n' 'n']

@test D3 == ['s' 's' 's'
             'e' 'o' 'e'
             's' 's' 's']

@test D4 == ['s' 's' 's'
             'w' 'o' 'w'
             's' 's' 's']

C, D = Salboai.travelcost(10M, CartesianIndex(3,2))

min_C, min_i = findmin(C, dims=3)
@test min_C[:,:,1] == [3 1 3
                      2 1 2
                      1 0 1]

@test D[min_i][:,:,1] == ['s' 's' 's'
                          'n' 'n' 'n'
                          'e' 'o' 'w']

hpt, cost1, direction1 = Salboai.halite_per_turn(10M, H.Ship(0, 0, CartesianIndex(2,1), 0), CartesianIndex(2,2))

@test hpt ≈ [ -0.6875   0.125   -0.208333
               2.875   -2.5      0.125
              -0.125   -0.1875   0.125 ] atol=1e-6

@test cost1 == [ 3  3  5
                 0  5  3
                 3  3  4 ]

@test direction1 == [ 'n'  'w'  'w'
                      'o'  'e'  'w'
                      's'  'w'  'w' ]

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
@test d == 's'

M2 = [0 0 0 0
      0 0 0 0
      0 0 0 0
      0 0 10 0]

ship = H.Ship(0, 0, CartesianIndex(2,3), 3)
shipyard = CartesianIndex(2,2)
d = Salboai.select_direction(M2, ship, shipyard)
@test_broken d == 'w'
