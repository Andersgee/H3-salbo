function init(g::H.GameMap)
	warmup()
	me = H.me(g)
	S = GameState()
	S.dropoff_cands = dropoffcands(g.halite, [me.shipyard])
	warn("S.dropoff_cands: ", Tuple.(S.dropoff_cands))
	return S
end


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
end


function tick(S::GameState, g::H.GameMap, turn::Int)::Vector{String}
	update_game_state!(S, g, turn)
	warn("turn ", turn)

    start_t = now()
	me = H.me(g)

    no_more_ship_turn = div(max_turns(g), 2)
    no_more_dropoff_turn = div(2max_turns(g), 3)

	dropoffs = H.dropoffs_p(me)
	if turn < no_more_dropoff_turn
		append!(dropoffs, S.dropoff_cands)
	end

    inspired = inspiredsquares(g) #boolean matrix of size g.halite marking inspired squares

	dropoff = nearestdropoff(g.halite, dropoffs)
	shipcands = shipscandidatetargets(S, g, dropoff, turn, inspired)

	ships = [sc.ship for sc in shipcands]
	dirs = [[c.dir for c in sc.cands] for sc in shipcands]
	targets = [[c.target for c in sc.cands] for sc in shipcands]
	targets_hpt = [[c.hpt for c in sc.cands] for sc in shipcands]

    exclusive_candidate1_targets!(dirs, targets, targets_hpt, H.dropoffs_p(me))

	cmds = String[]

	checkcollision = [sc.cands[1].checkcollision for sc in shipcands]
	append!(cmds, H.move.(ships[.!checkcollision], getindex.(dirs[.!checkcollision], 1)))

	if turn < no_more_dropoff_turn
		dropoff_cost, ship2dropoff_i = prepare_for_dropoff(g.halite, ships, S.dropoff_cands)
		me.halite -= dropoff_cost
		if (ship2dropoff_i != nothing) && (0 ≤ me.halite)
			warn("Creating dropoff at ", ships[ship2dropoff_i].p)
			S.dropoff_cands = S.dropoff_cands[S.dropoff_cands .!= (ships[ship2dropoff_i].p,)]
			dirs[ship2dropoff_i] = [H.CONSTRUCT]
		end
    end

	forbidden = forbiddensquares(g) #completely AVOID enemy ships
	#forbidden = falses(size(g.halite)) #completely IGNORE enemy ships

    pickedmove, occupied = avoidcollision(g.halite, ships[checkcollision], dirs[checkcollision], forbidden)

	append!(cmds, H.move_or_make_dropoff.(ships[checkcollision], pickedmove))

    if (H.SHIP_COST ≤ me.halite) && (!occupied[me.shipyard]) && (turn < no_more_ship_turn)
        push!(cmds, H.make_ship())
    end

    warn("cmds: ", cmds)
    warn("turn ", turn, " took ", now() - start_t)

    return cmds
end
