function shipscandidatetargets(S::GameState, g::H.GameMap, turn::Int, inspired)
	me = H.me(g)
    ships = me.ships
	warn("n ships ", length(ships))

	dropoff = cheapestdropoff(g.halite, H.dropoffs_p(me))
	gameend = any(isgameending.(turns_left(g, turn), dropoff.T[[s.p for s in ships]]))
	ct = candidatetargets.((S,), (g,), (dropoff,), ships, turn, gameend, (inspired,))

	return ShipCandidateTargets.(ships, ct)
end




function candidatetargets(S::GameState, g::H.GameMap, dropoff::Back2DropOffCost, s::H.Ship, turn::Int, gameend, inspired)
	if s.halite > 0.98*H.MAX_HALITE
		push!(S.ships_to_dropoff, s.id)
	end

	if !canmove(s, g.halite)
		# maybe create dropoff?
		return [CandidateTarget(H.STAY_STILL, s.p)]
	elseif gameend
		return go2dropoff(g.halite, s, dropoff, true)
	elseif s.id in S.ships_to_dropoff
		return go2dropoff(g.halite, s, dropoff, false)
	else
		dir, target, target_hpt = candidate_targets_inner(g.halite, s, H.me(g).shipyard, inspired)
		return CandidateTarget.(dir, target, target_hpt)

		#oneway = onewayhpt(g.halite, s.p, s.halite, turn - S.ship_dropoff_turn[s.id])
		#return pathfinding2(oneway, dropoff)
	end
end
