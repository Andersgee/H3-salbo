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

	moves = Vector{Char}[]
	targets = Vector{CartesianIndex}[]
	go_home_margin = div(length(me.ships), 3) + 1

	for (si,s) in enumerate(me.ships)
		if !canmove(s, g.halite)
			push!(moves, [H.STAY_STILL])
			push!(targets, [s.p])
		elseif manhattandist(sz, s.p, me.shipyard) + go_home_margin >= turns_left && s.halite > 0
			dir, target = cheapestmoves(g.halite, s, me.shipyard)
			push!(moves, dir)
			push!(targets, target)
		else
			dir, target = candidate_directions(g.halite, s, me.shipyard)
			push!(moves, dir)
			push!(targets, target)
		end
	end

	ships = me.ships


	cmds = String[]
	if 1 + go_home_margin >= turns_left # ignore collisions on dropoff during final collection
		ships, moves, targets, cmds = crash_on_dropoffs(sz, ships, moves, targets, [me.shipyard])
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
