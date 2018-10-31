include("../../hlt/halite.jl")
include("../salboai.jl")

using Main.H
using Test

CI(x...) = CartesianIndex(x...)

m = [5 1 2
     0 5 1
     7 0 3]

dropoff_c, dropoff_t, dropoff_d = Salboai.cheapestdropoff(10m, [CI(2,1)])
@test dropoff_c == [0 3 1
                    0 0 0
                    0 4 1]
@test dropoff_t == [1 3 2
                    0 1 1
                    1 3 2]
@test dropoff_d == ['s'  'e'  'e'
                    'o'  'w'  'e'
                    'n'  'e'  'e']

dropoff_c, dropoff_t, dropoff_d = Salboai.cheapestdropoff(10m, [CI(2,1), CI(3,2)])
@test dropoff_c == [0 0 1
                    0 0 0
                    0 0 0]
@test dropoff_t == [1 1 2
                    0 1 1
                    1 0 1]
@test dropoff_d == ['s'  'n'  'e'
                    'o'  'w'  'e'
                    'n'  'o'  'w']


m,h,t,d = Salboai.quadrant_hpt(10m, 10)

@test m == [50 10 20
            0 50 10
            52 0 22]

@test h == [ 5   4   2
             5  0  1
            18  0  7 ]

@test t == [ 1  2  3
             2  3  4
             4  4  6 ]

@test d == [4 1 1
            0 0 1
            0 0 1]

# seed 1540994495
M = [235 238 204 245 186
     275 482 236 173 160
     231 284 0 188 218
     237 232 180 198 155
     175 254 204 157 152]

m,h,t,d = Salboai.onewayhpt(M, CI(3,3), 0)

@test m == [ 235  178  204  245  139
             275  482  177  173  160
             231  213    0  141  218
             237  232  135  198  116
             131  254  204  117  152]

@test h == [ 42  65  22   1  43
              0   2  42  25   9
             27  50   0  33  12
              4  27  32  14  42
             35   2  12  43  28 ]

@test t == [ 7  6  4  5  7
             5  4  3  4  5
             4  3  1  3  4
             5  4  3  4  6
             7  5  4  6  7 ]

@test d == [ 'n'  'n'  'n'  'n'  'n'
             'w'  'w'  'n'  'n'  'n'
             'w'  'w'  'o'  'e'  'e'
             'w'  'w'  's'  'e'  'e'
             'w'  'w'  's'  'e'  'e' ]

dropoff_c, dropoff_t, dropoff_d = Salboai.cheapestdropoff(M, [CI(3,3)])
dir, hpt, target = Salboai.twowayhpt(m, h, t, d, dropoff_c, dropoff_t)

@test dir == H.WEST
@test hpt == 35
@test target == CI(2,2)


function simf(M, ship, shipyard, turn)
    return Salboai.pathfinding2(M, ship.p, ship.halite, turn, dropoff_c, dropoff_t, dropoff_d)[1]
end

Salboai.simulate(simf, M, H.Ship(0,0,CI(3,3),0), CI(3,3), 20)
