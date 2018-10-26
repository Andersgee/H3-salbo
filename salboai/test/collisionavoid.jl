include("../../hlt/halite.jl")
include("../salboai.jl")

using Test
using Main.Salboai

M = [0 70 0 0
     0 0 90 0
     0 50 0 0
     0 0 0 0]

newship(y,x) = H.Ship(0, 0, CartesianIndex(y,x), 0)

ships = [newship(2,2),newship(3,3),newship(4,4)]
shipyard = CartesianIndex(4,4)

moves = Vector{Char}[]
for s in ships
    dir = Salboai.candidate_directions(M, s, shipyard)
    push!(moves, dir)
end
moves


ships_p = [s.p for s in ships]
pickedmove, cangenerate = Salboai.avoidcollision(M, ships_p, moves, shipyard)

@test pickedmove == ['e', 'w', 'n']
@test cangenerate == true



shipyard = CartesianIndex(3,4)
pickedmove, cangenerate = Salboai.avoidcollision(M, ships_p, moves, shipyard)

@test cangenerate == false