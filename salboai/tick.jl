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
	ships = me.ships
	max_turns = Salboai.max_turns(g)
	no_more_ship_turn = max_turns * 1/2
	turns_left = max_turns - turn
	sz = size(g.halite)

	warn("turn ", turn)
	warn("n ships ", length(me.ships))

	dirs = Vector{Char}[]
	targets = Vector{CartesianIndex}[]
	targets_hpt = Vector{Float64}[]
	for ship in ships
	    dir, target, target_hpt = Salboai.candidate_targets(g.halite, ship, me.shipyard)
	    push!(dirs, dir)
	    push!(targets, target)
	    push!(targets_hpt, target_hpt)
	end

	dirs, targets = Salboai.exclusive_candidate1_targets!(dirs, targets, targets_hpt, me.shipyard)
	ships, dirs, targets = Salboai.sort_staystill_first!(ships, dirs, targets)

	pickedmove, occupied = Salboai.avoidcollision(g.halite, [s.p for s in ships], dirs)
	cangenerate = !occupied[me.shipyard]

	cmds = String[]
	append!(cmds, H.move.(ships, pickedmove))

	if (me.halite ≥ 1000) && (cangenerate == true) && (turn < no_more_ship_turn)
		push!(cmds, H.make_ship())
	end

	warn("cmds: ", cmds)
	warn("turn ", turn, " took ", now() - start_t)

	return cmds
end
