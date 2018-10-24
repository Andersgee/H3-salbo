include("hlt/halite.jl")
include("salboai/salboai.jl")

warn(s...) = println(Base.stderr, s...)

using Main.Salboai
using Dates

g = H.init()
me = H.me(g)

# warmup
select_direction(g.halite, H.Ship(0, 0, CartesianIndex(1,1), 0), me.shipyard)
cmds = String[]
warn("cmds0: ", cmds)
warn("me: ", me)
warn("me.ships: ", me.ships)
H.make_ship()

H.ready("salboai")

function gonorthandmine(cmds)
	for s in me.ships
		if turn == 2
			push!(cmds, H.move(s, H.NORTH))
		else
			push!(cmds, H.move(s, H.STAY_STILL))
		end
	end
end

while true
	start_t = now()
	cmds = String[]
	turn = H.update_frame!(g)
	warn("turn ", turn)

	if turn == 1
		push!(cmds, H.make_ship())
	end

	#gonorthandmine(cmds)
	#H.sendcommands(cmds)
	#continue

	#if me.halite > 1000
	#	push!(cmds, H.make_ship())
	#end

	#calculate where ships want to move
	
	warn("n ships ", length(me.ships))

	for s in me.ships
		warn("ship ", s.id, " pos=", Tuple(s.p), " halite=", s.halite)
		if !canmove(s, g.halite)
			push!(cmds, H.move(s, H.STAY_STILL))
			warn("can't move ", Salboai.leavecost(g.halite[s.p]), " > ", s.halite)
		else
			dir = select_direction(g.halite, s, me.shipyard)
			warn(g.halite[s.p[1] .+ (-1:1), s.p[2] .+ (-1:1)])

			#need to add a manhattan distance cost from ship to all map and from shipyard to all map. sum them
			#and multiply by something to not just walk away.
			push!(cmds, H.move(s, dir))
		end
	end

	warn("cmds: ", cmds)
	warn("turn ", turn, " took ", now() - start_t)
	H.sendcommands(cmds)
end
