using Test
include("../halite.jl")

r = [1 2 3 4
     5 6 7 8
     9 10 11 12]
w = H.WrappedMatrix(r)

@test w[0, 0] == 12
@test w[0, 1] == 9
@test w[1, 0] == 4
@test w[-1:1, -1:1] == [7 8 5; 11 12 9; 3 4 1]
@test w[-3:3, 2] == [10, 2, 6, 10, 2, 6, 10]

w[0, 0:1] = 13
@test w[0, 0:1] == [13, 13]
@test w[3, 1:4] == [13, 10, 11, 13]
@test w[6, 1:4] == [13, 10, 11, 13]
@test w[-6, 1:4] == [13, 10, 11, 13]

@test w[:,2] == [2, 6, 10]
@test w[:,-5] == [3, 7, 11]
@test w[5,:] == [5, 6, 7, 8]

@test w[CartesianIndex(2,3)] == 7
@test w[[CartesianIndex(2,3), CartesianIndex(3,2)]] == [7, 10]
