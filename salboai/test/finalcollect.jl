include("../../hlt/halite.jl")
include("../salboai.jl")

using Test

H.setdefaultconstants()
CI(x...) = CartesianIndex(x...)

@test ['w'] == Salboai.simplemoves((4,4), CI(1,1), CI(1,4))
@test ['n'] == Salboai.simplemoves((4,4), CI(1,1), CI(4,1))


M = [1 2 1
     1 1 2
     2 1 1]

makeship(pos, halite=0) = H.Ship(0, 0, pos, halite)
@test (['n'], [CI(3,1)]) == Salboai.cheapestmoves(M, makeship(CI(1,1), 10), CI(3,1))

ships = makeship.(CI.([(1,1), (2,2), (3,2), (3,3)]))
moves = [[H.EAST], [H.SOUTH], [H.SOUTH], [H.WEST]]
targets = fill([CI(1,2)], 4)
dropoffs = [CI(1,2)]
ships, moves, targets, cmds = Salboai.crash_on_dropoffs(size(M), ships, moves, targets, dropoffs)

@test getfield.(ships, :p) == CI.([(2,2), (3,3)])
@test moves == [[H.SOUTH], [H.WEST]]
@test targets == fill([CI(1,2)], 2)
@test cmds == ["m 0 e", "m 0 s"]
