include("../../hlt/halite.jl")
include("../salboai.jl")

using Test
using Random

H.setdefaultconstants()

Random.seed!(0)
g = Salboai.dummyGameMap((32, 32))
sz = size(g.halite)
dist(a, b) = Salboai.manhattandist(sz, a, b)
nvicinity(p0, P, r) = sum(dist(p, p0) ≤ r for p in P)

enemyshipspos(g) = [s.p for (id,p) in g.players if id != g.my_player_id for s in p.ships]

P = enemyshipspos(g)
D = H.dropoffs_p(H.me(g))


# it should find which squares that gives inspired mining
I = Salboai.inspiredsquares(g)
@test findlast(I) == CartesianIndex(7,32)

inspired_pos = CartesianIndex(6,2)
not_inspired_pos = CartesianIndex(11,2)
@test I[inspired_pos]
@test !I[not_inspired_pos]

@test 2 ≤ nvicinity(inspired_pos, P, 4)
@test 2 > nvicinity(not_inspired_pos, P, 4)

inspired2 = [2 ≤ nvicinity(CartesianIndex(y,x), P, 4) for y in 1:sz[1], x in 1:sz[2]]
@test I == inspired2


# it should find which squares an opponent can be on the next frame
F = Salboai.forbiddensquares(g)
@test findfirst(F) == CartesianIndex(8,1)
@test CartesianIndex(8,1) ∈ enemyshipspos(g)
@test CartesianIndex(7,32) ∈ D

# but avoid the vicinity around our dropoffs
dropoffs = [1 ≤ nvicinity(CartesianIndex(y,x), D, 1) for y in 1:sz[1], x in 1:sz[2]]
forbidden2 = [1 ≤ nvicinity(CartesianIndex(y,x), P, 1) for y in 1:sz[1], x in 1:sz[2]]
forbidden2[dropoffs] .= false
@test F == forbidden2
