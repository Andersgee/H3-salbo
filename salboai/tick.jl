function warmup()
	g = dummyGameMap((32, 32))
	tick(g, 1)
	tick(g, max_turns(g) - 1)
	
	try
		1+"a"
	catch a
		bt = catch_backtrace()
		string(bt)
	end
end


function tick(g::H.GameMap, turn::Int)
	start_t = now()

	if turn == 100
		1 + ""
	end

	me = H.me(g)
	max_turns = Salboai.max_turns(g)
	no_more_ship_turn = max_turns * 1/2
	turns_left = max_turns - turn
	sz = size(g.halite)

	warn("turn ", turn)
	warn("n ships ", length(me.ships))

	moves = Vector{Char}[]
	targets = Vector{CartesianIndex}[]

	for (si,s) in enumerate(me.ships)
		if !canmove(s, g.halite)
			push!(moves, [H.STAY_STILL])
			push!(targets, [s.p])
		elseif manhattandist(s.p, me.shipyard) + div(length(me.ships), 3) + 1 >= turns_left && s.halite > 0
			# find alternate direction to take if preferred path is occupied
			shipyarddir = mod.(Tuple(s.p - me.shipyard) .+ sz, sz) .- div.(sz, 2)
			shipyardmoves = []
			if shipyarddir[1] > 0 push!(shipyardmoves, H.EAST) end
			if shipyarddir[1] < 0 push!(shipyardmoves, H.WEST) end
			if shipyarddir[2] > 0 push!(shipyardmoves, H.NORTH) end
			if shipyarddir[2] < 0 push!(shipyardmoves, H.SOUTH) end
			push!(shipyardmoves, H.STAY_STILL)
			hpt, cost1, direction1 = halite_per_turn(g.halite, s, me.shipyard)
			dir1 = direction1[me.shipyard]
			dir = [dir1; shipyardmoves[shipyardmoves .!= dir1]]
			push!(moves, dir)
			push!(targets, fill(me.shipyard, length(dir)))
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
	ships = me.ships[i]
	targets = targets[i]

	cmds = String[]
	if turns_left <= length(ships) + 1 # ignore collisions on dropoff during final collection
		on_dropoff = [s.p == me.shipyard for s in ships]
		dropoff_next = [manhattandist(s.p, me.shipyard) == 1 for s in ships]
		go_dropoff = [m[1] for m in moves[dropoff_next]]
		append!(cmds, H.move.(ships[dropoff_next], go_dropoff))

		collisioncheck = .!(dropoff_next .| on_dropoff)
		moves = moves[collisioncheck]
		ships = ships[collisioncheck]
		targets = targets[collisioncheck]
	end

	pickedmove, occupied = Salboai.avoidcollision(g.halite, [s.p for s in ships], moves)
	cangenerate = !occupied[me.shipyard]

	append!(cmds, H.move.(ships, pickedmove))

	if (me.halite ≥ 1000) && (cangenerate == true) && (turn < no_more_ship_turn)
		push!(cmds, H.make_ship())
	end

	warn("cmds: ", cmds)
	warn("turn ", turn, " took ", now() - start_t)

	return cmds
end
