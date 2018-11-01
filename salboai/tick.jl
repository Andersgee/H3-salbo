function warmup()
	s = GameState()
	g = dummyGameMap((32, 32))
	update_game_state!(s, g, 1)
	tick(s, g, 1)
	tick(s, g, max_turns(g) - 1)

	try
		1+"a"
	catch a
		bt = catch_backtrace()
		string(bt)
	end

	return GameState()
end


function tick(S::GameState, g::H.GameMap, turn::Int)
	update_game_state!(S, g, turn)

    start_t = now()

    me = H.me(g)
    ships = me.ships
    max_turns = Salboai.max_turns(g)
    no_more_ship_turn = max_turns * 1/2
    turns_left = max_turns - turn
    go_home_margin = div(length(ships), 5) + 1
    sz = size(g.halite)

	warn("turn ", turn)
	warn("n ships ", length(me.ships))

	dirs = Vector{Char}[]
    targets = Vector{CartesianIndex}[]
    targets_hpt = Vector{Float64}[]

	dropoffs_p = [me.shipyard; [d.p for d in me.dropoffs]]
	dropoff = cheapestdropoff(g.halite, dropoffs_p)
	oneways = [onewayhpt(g.halite, s.p, s.halite, turn - S.ship_dropoff_turn[s.id]) for s in me.ships]

	go_home_margin = div(length(me.ships), 2) + 1
	gameendings = turns_left .<= dropoff.T[[s.p for s in me.ships]] .+ go_home_margin

	for (i,s) in enumerate(me.ships)
		if !canmove(s, g.halite)
			# maybe create dropoff?
			push!(dirs, fill(H.STAY_STILL, 5))
			push!(targets, fill(s.p, 5))
			push!(targets_hpt, fill(0., 5))
		#elseif gameendings[i]
		#	dir, target = cheapestmoves(g.halite, s, me.shipyard)
		#	push!(dirs, [dir; fill(H.STAY_STILL, 5-length(dir))])
		#	push!(targets, [target; fill(s.p, 5-length(target))])
		#	push!(targets_hpt, fill(0.,5))
		else
			dir, target, target_hpt = candidate_targets(g.halite, s, me.shipyard, gameendings[i])
			push!(dirs, dir)
			push!(targets, target)
			push!(targets_hpt, target_hpt)

			#cands = pathfinding2(oneways[i], dropoff)
			#push!(dirs, [c.dir for c in cands])
			#push!(targets, [c.target for c in cands])
			#push!(targets_hpt, [c.hpt for c in cands])
		end
	end

    dirs, targets = exclusive_candidate1_targets!(dirs, targets, targets_hpt, me.shipyard)

    cmds = String[]
    #if (sum(gameendings)/length(gameendings)) > 0.5 # if more than half of the ships are on final return home, then start crashing on dropoff
	if 1 + go_home_margin >= turns_left # ignore collisions on dropoff during final collection
    	ships, dirs, targets, cmds = crash_on_dropoffs(sz, ships, dirs, targets, [me.shipyard])
    end

	pickedmove, occupied = avoidcollision(g.halite, ships, dirs)
    cangenerate = !occupied[me.shipyard]

    append!(cmds, H.move.(ships, pickedmove))

    if (me.halite ≥ 1000) && (cangenerate == true) && (turn < no_more_ship_turn)
        push!(cmds, H.make_ship())
    end

    warn("cmds: ", cmds)
    warn("turn ", turn, " took ", now() - start_t)

    return cmds
end
