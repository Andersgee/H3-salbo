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

	me = H.me(g)
	max_turns = Salboai.max_turns(g)
	no_more_ship_turn = max_turns * 1/2
	turns_left = max_turns - turn
	sz = size(g.halite)

	warn("turn ", turn)
	warn("n ships ", length(me.ships))

	dirs = Vector{Char}[]
	targets = Vector{CartesianIndex}[]

	for (si,s) in enumerate(me.ships)
		if !canmove(s, g.halite)
			push!(dirs, [H.STAY_STILL])
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
			push!(dirs, dir)
			push!(targets, fill(me.shipyard, length(dir)))
		else
			dir, target = Salboai.candidate_directions(g.halite, s, me.shipyard)
			push!(dirs, dir)
			push!(targets, target)
		end
	end

	#dirs, targets = exclusive_candidate1_targets!(dirs, targets, targets_hpt)
	ships, dirs, targets = Salboai.sort_staystill_first!(ships, dirs, targets)

	cmds = String[]
	if turns_left <= length(ships) + 1 # ignore collisions on dropoff during final collection
		on_dropoff = [s.p == me.shipyard for s in ships]
		dropoff_next = [manhattandist(s.p, me.shipyard) == 1 for s in ships]
		go_dropoff = [m[1] for m in dirs[dropoff_next]]
		append!(cmds, H.move.(ships[dropoff_next], go_dropoff))

		collisioncheck = .!(dropoff_next .| on_dropoff)
		dirs = dirs[collisioncheck]
		ships = ships[collisioncheck]
		targets = targets[collisioncheck]
	end

	pickedmove, occupied = Salboai.avoidcollision(g.halite, [s.p for s in ships], dirs)
	cangenerate = !occupied[me.shipyard]

	append!(cmds, H.move.(ships, pickedmove))

	if (me.halite ≥ 1000) && (cangenerate == true) && (turn < no_more_ship_turn)
		push!(cmds, H.make_ship())
	end

	warn("cmds: ", cmds)
	warn("turn ", turn, " took ", now() - start_t)

	return cmds
end
