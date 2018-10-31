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
    go_home_margin = div(length(ships), 5) + 1
    sz = size(g.halite)

    warn("turn ", turn)
    warn("n ships ", length(me.ships))

    dirs = Vector{Char}[]
    targets = Vector{CartesianIndex}[]
    targets_hpt = Vector{Float64}[]
    gameendings = Bool[]
    for ship in ships
        gameending = turns_left <= (Salboai.manhattandist(sz, ship.p, me.shipyard) + go_home_margin)
        warn("gameending", gameending)
        #gameending = true
        dir, target, target_hpt = Salboai.candidate_targets(g.halite, ship, me.shipyard, gameending)
        push!(dirs, dir)
        push!(targets, target)
        push!(targets_hpt, target_hpt)
        push!(gameendings, gameending)
    end

    dirs, targets = Salboai.exclusive_candidate1_targets!(dirs, targets, targets_hpt, me.shipyard)

    #ships, dirs, targets = Salboai.sort_staystill_first!(ships, dirs, targets)
    #pickedmove, occupied = Salboai.avoidcollision(g.halite, [s.p for s in ships], dirs)
    pickedmove, occupied = Salboai.avoidcollision2(g.halite, [s.p for s in ships], dirs, gameendings, me.shipyard)
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


#=
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
=#