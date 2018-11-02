function shipscandidatetargets(S::GameState, g::H.GameMap, turn::Int)
	me = H.me(g)
    ships = me.ships
	warn("n ships ", length(me.ships))

	dropoff = cheapestdropoff(g.halite, H.dropoffs_p(me))
	gameend = any(isgameending.(turns_left(g, turn), dropoff.T[[s.p for s in ships]]))
	ct = candidatetargets.((S,), (g,), (dropoff,), me.ships, turn, gameend)

	return ShipCandidateTargets.(me.ships, ct)
end




function candidatetargets(S::GameState, g::H.GameMap, dropoff::Back2DropOffCost, s::H.Ship, turn::Int, gameend)
	sz = size(g.halite)
	
	if !canmove(s, g.halite)
		# maybe create dropoff?
		return [CandidateTarget(H.STAY_STILL, s.p)]
	elseif gameend
		return go2dropoff(g.halite, s, dropoff, true)
	else
		dir, target, target_hpt = candidate_targets_inner(g.halite, s, H.me(g).shipyard)
		return CandidateTarget.(dir, target, target_hpt)

		#oneway = onewayhpt(g.halite, s.p, s.halite, turn - S.ship_dropoff_turn[s.id])
		#return pathfinding2(oneway, dropoff)
	end
end
