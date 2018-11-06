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
@test ['n'] == Salboai.cheapestmoves(M, makeship(CI(1,1), 10), CI(3,1))

ships = makeship.(CI.([(1,1), (2,2), (3,2), (3,3)]))
dropoff = Salboai.nearestdropoff(M, [CI(1,2)])
cands = Salboai.go2dropoff.((M,), ships, (dropoff,), true)
CT = Salboai.CandidateTarget
@test [[CT('e', CI(1, 2), false)],
       [CT('n', CI(1, 2), false)],
       [CT('s', CI(1, 2), false)],
       [CT('s', CI(1, 2), true), CT('w', CI(1, 2), true)]] == cands
