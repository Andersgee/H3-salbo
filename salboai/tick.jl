function warmup()
	g = dummyGameMap((32, 32))
	tick(g, 10)
	tick(g, max_turns(g) - 10)
end


function tick(g::H.GameMap, turn::Int)
	start_t = now()

	me = H.me(g)
	max_turns = Salboai.max_turns(g)
	no_more_ship_turn = max_turns * 1/2
	turns_left = max_turns - turn
	sz = size(g.halite)

	warn("turn ", turn)
	warn("n ships ", length(me.ships))

	moves = Vector{Char}[]
	targets = Vector{CartesianIndex}[]
	for s in me.ships
		if !canmove(s, g.halite)
			push!(moves, [H.STAY_STILL])
		else
			dir, target = Salboai.candidate_directions(g.halite, s, me.shipyard)
			push!(moves, dir)
			push!(targets, target)
		end
		#push!(cmds, H.move(s, dir[1]))
		#=
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
		=#
	end

	is_moving = [m[1] != H.STAY_STILL for m in moves]
	i = sortperm(is_moving)
	moves = moves[i]
	me.ships = me.ships[i]

	ships_p = [s.p for s in me.ships]

	pickedmove, occupied = Salboai.avoidcollision(g.halite, ships_p, moves)
	cangenerate = !occupied[me.shipyard]

	cmds = String[]

	if (me.halite > 1000) && (cangenerate == true) && (turn < no_more_ship_turn)
		push!(cmds, H.make_ship())
	end

	cmds = [cmds; H.move.(me.ships, pickedmove)]

	warn("cmds: ", cmds)
	warn("turn ", turn, " took ", now() - start_t)

	return cmds
end
