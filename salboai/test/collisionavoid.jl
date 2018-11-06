include("../../hlt/halite.jl")
include("../salboai.jl")

using Test

CI(x...) = CartesianIndex(x...)

H.setdefaultconstants()

M = [0 70 0 0
     0 0 90 0
     0 50 0 0
     0 0 0 0]

newship(y,x) = H.Ship(0, 0, CI(y,x), 0)

ships = [newship(2,2), newship(3,3), newship(4,4)]
shipyard = CI(4,4)

moves = Vector{Char}[]
targets = Vector{CartesianIndex}[]
for s in ships
    dir, target = Salboai.candidate_targets_inner(M, s, shipyard)
    push!(moves, dir)
    push!(targets, target)
end

pickedmove, occupied = Salboai.avoidcollision(M, ships, moves)

@test pickedmove == ['e', 'w', 'n']
@test occupied[shipyard] == false


shipyard = CI(3,4)
pickedmove, occupied = Salboai.avoidcollision(M, ships, moves)
@test occupied[shipyard] == true

ships = [newship(1,3), newship(2,2), newship(1,1), newship(4,2)]
moves = [[H.WEST], [H.NORTH], [H.EAST], [H.SOUTH]]
pickedmove, occupied = Salboai.avoidcollision(M, ships, moves)
@test pickedmove == [H.WEST, H.STAY_STILL, H.STAY_STILL, H.STAY_STILL]
@test occupied == ([1 1 0 0
                   0 1 0 0
                   0 0 0 0
                   0 1 0 0] .> 0)
