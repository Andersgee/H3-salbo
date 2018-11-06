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

    no_more_ship_turn = max_turns(g) * 1/2

    inspired = inspiredsquares(g) #boolean matrix of size g.halite marking inspired squares

	shipcands = shipscandidatetargets(S, g, turn, inspired)

	ships = [sc.ship for sc in shipcands]
	dirs = [[c.dir for c in sc.cands] for sc in shipcands]
	targets = [[c.target for c in sc.cands] for sc in shipcands]
	targets_hpt = [[c.hpt for c in sc.cands] for sc in shipcands]

    dirs, targets = exclusive_candidate1_targets!(dirs, targets, targets_hpt, me.shipyard)

	cmds = String[]

	checkcollision = [sc.cands[1].checkcollision for sc in shipcands]
	append!(cmds, H.move.(ships[.!checkcollision], getindex.(dirs[.!checkcollision], 1)))


	forbidden = forbiddensquares(g) #completely AVOID enemy ships
	#forbidden = H.WrappedMatrix(falses(size(g.halite))) #completely IGNORE enemy ships
	pickedmove, occupied = avoidcollision(g.halite, ships[checkcollision], dirs[checkcollision], forbidden)
    cangenerate = !occupied[me.shipyard]

    append!(cmds, H.move.(ships[checkcollision], pickedmove))

    if (me.halite ≥ 1000) && (cangenerate == true) && (turn < no_more_ship_turn)
        push!(cmds, H.make_ship())
    end

    warn("cmds: ", cmds)
    warn("turn ", turn, " took ", now() - start_t)

    return cmds
end
