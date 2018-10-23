include("../salboai.jl")
travelcost(0.1*g.halite, [5,5])

M=g.halite


for i=0:length(g.players)-1
    println(g.players[i].shipyard.x, g.players[i].shipyard.y)
end

#g.halite[p.shipyard.y, p.shipyard.x] = 0
#g.halite[g.players[0].shipyard.x, g.players[0].shipyard.y]=0
end

g.halite[g.players[0].shipyard.x, g.players[0].shipyard.y]=0

ship = p2v(g.players[0].ships[1].p)
shipyard = p2v(g.players[0].shipyard)

threshold = 9 #

S, direction, cost1 = score(m, ship, shipyard, threshold)
m[5:11,12:18]

S[5:11,12:18]

cost1[5:11,12:18]

g.players[g.my_player_id].halite
g.players[0].shipyard.x
