include("../../hlt/halite.jl")
include("../salboai.jl")

using Main.H
using Test

CI(x...) = CartesianIndex(x...)

H.setdefaultconstants()

m = [5 1 2
     0 5 1
     7 0 3]

dropoff = Salboai.cheapestdropoff(10m, [CI(2,1)])
@test dropoff.C == [0 3 1
                    0 0 0
                    0 4 1]
@test dropoff.T == [1 3 2
                    0 1 1
                    1 3 2]
@test dropoff.P == fill(CI(2,1), size(m))

dropoff = Salboai.cheapestdropoff(10m, [CI(2,1), CI(3,2)])
@test dropoff.C == [0 0 1
                    0 0 0
                    0 0 0]
@test dropoff.T == [1 1 2
                    0 1 1
                    1 0 1]
@test dropoff.P == [CI(2,1)  CI(3,2)  CI(2,1)
                    CI(2,1)  CI(2,1)  CI(2,1)
                    CI(2,1)  CI(3,2)  CI(3,2)]


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

oneway = Salboai.onewayhpt(M, CI(3,3), 0, 0)

@test oneway.M == [ 235  178  204  245  139
                    275  482  177  173  160
                    231  213    0  141  218
                    237  232  135  198  116
                    131  254  204  117  152]

@test oneway.H == [ 42  65  22   1  43
                     0   2  42  25   9
                    27  50   0  33  12
                     4  27  32  14  42
                    35   2  12  43  28 ]

@test oneway.T == [ 7  6  4  5  7
                    5  4  3  4  5
                    4  3  1  3  4
                    5  4  3  4  6
                    7  5  4  6  7 ]

@test oneway.D == [ 'n'  'n'  'n'  'n'  'n'
                    'w'  'w'  'n'  'n'  'n'
                    'w'  'w'  'o'  'e'  'e'
                    'w'  'w'  's'  'e'  'e'
                    'w'  'w'  's'  'e'  'e' ]

dropoff = Salboai.cheapestdropoff(M, [CI(3,3)])
cand = Salboai.twowayhpt(oneway, dropoff)

@test cand[1] == Salboai.MoveCandidate(H.WEST,       22,   CI(3,2))
@test length(cand) == 5
@test cand[2] == Salboai.MoveCandidate(H.NORTH,      18.2, CI(2,3))
@test cand[3] == Salboai.MoveCandidate(H.EAST,       14.6, CI(3,4))
@test cand[4] == Salboai.MoveCandidate(H.SOUTH,      13.8, CI(4,3))
@test cand[5] == Salboai.MoveCandidate(H.STAY_STILL, 0,    CI(3,3))


function simf(M, ship, shipyard, turn)
    if !Salboai.canmove(ship, M)
        return H.STAY_STILL
    end
    oneway = Salboai.onewayhpt(M, ship.p, ship.halite, turn)
    cands = Salboai.pathfinding2(oneway, dropoff)
    return cands[1].dir
end


simC, simM, simS, simD = Salboai.simulate(simf, M, H.Ship(0,0,CI(3,3),0), CI(3,3), 12)

@test simD == [0, 0, 0, 0, 0, 0, 212, 0, 0, 0, 0, 0]
@test [s.halite for s in simS] == [0, 71, 125, 165, 195, 218, 0, 0, 59, 42, 163, 254]
