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
isgenerating = true


moves = ['e','n','n']

moves = Salboai.avoidcollision!(M, ships, moves, shipyard, isgenerating)

@test moves ==['e', 'o', 'n']




moves = []
for s in ships
    push!(moves, Salboai.select_direction(M, s, shipyard))
end

moves

moves = Salboai.avoidcollision!(M, ships, moves, shipyard, isgenerating)
