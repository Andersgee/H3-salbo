include("hlt/halite.jl")
include("salboai.jl")


g = H.init(Base.stdin)

H.ready("salboai")

miningthreshold = 9 #free to move after that. dont bother mining more?

while true
	cmds=String[]
	turn = H.update_frame!(g, Base.stdin)

	p_shipyard = p2v(g.players[g.my_player_id].shipyard)

	if turn == 1
		push!(cmds, H.make_ship())
	end
	#if g.players[g.my_player_id].halite > 1000
	#	push!(cmds, H.make_ship())
	#end

	#calculate where ships want to move
	for s in g.players[g.my_player_id].ships
		p_ship = p2v(s.p)
		ms, dir, cost_here2there = mapscore(g.halite, p_ship, p_shipyard, miningthreshold)
		ms_within_reach = filterscores(ms, cost_here2there, s.halite)
		yx = pickbestsquare(ms_within_reach)

		#need to add a manhattan distance cost from ship to all map and from shipyard to all map. sum them
		#and multiply by something to not just walk away.
		push!(cmds, H.move(s, dir[yx]))
		#push!(cmds, H.move(s, 1))
	end

	H.sendcommands(cmds)
end
