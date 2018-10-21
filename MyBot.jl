include("hlt/halite.jl")

g = H.init(Base.stdin)

H.ready("salboai")

while true
	cmds=String[]
	H.update_frame!(g, Base.stdin)
	push!(cmds, H.make_ship())
	for s in g.players[g.my_player_id].ships
		push!(cmds, H.move(s, H.NORTH))
	end
	H.sendcommands(cmds)
end
