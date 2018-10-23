include("../../hlt/halite.jl")
include("../salboai.jl")

using Test

M = [1 2 3
     3 1 2
     2 1 3]

C, D = Salboai.quadrant_travelcost(M);
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


C, D, S = Salboai.travelcost(10M, CartesianIndex(2,2))

@test C == [3 1 3
            1 0 1
            2 1 2]

@test D == ['n' 'n' 'n'
            'e' 'o' 'w'
            's' 's' 's']

@test S == [2 1 2
            1 0 1
            2 1 2]


C, D, S = Salboai.travelcost(10M, CartesianIndex(3,2))

@test C == [3 1 3
            2 1 2
            1 0 1]

@test D == ['s' 's' 's'
            'n' 'n' 'n'
            'e' 'o' 'w']

@test S == [2 1 2
            2 1 2
            1 0 1]
