include("../../hlt/halite.jl")
include("../salboai.jl")

using Test

H.setdefaultconstants()

M = [0 70 0 0
     0 0 90 0
     0 50 0 0
     0 0 0 0]

newship(y,x) = H.Ship(0, 0, CartesianIndex(y,x), 0)

ships = [newship(2,2),newship(3,3),newship(4,4)]
shipyard = CartesianIndex(4,4)

moves = Vector{Char}[]
targets = Vector{CartesianIndex}[]
for s in ships
    dir, target = Salboai.candidate_directions(M, s, shipyard)
    push!(moves, dir)
    push!(targets, target)
end
moves


ships_p = [s.p for s in ships]
pickedmove, occupied = Salboai.avoidcollision(M, ships_p, moves)

@test pickedmove == ['e', 'w', 'n']
@test occupied[shipyard] == false


shipyard = CartesianIndex(3,4)
pickedmove, occupied = Salboai.avoidcollision(M, ships_p, moves)

@test occupied[shipyard] == true
