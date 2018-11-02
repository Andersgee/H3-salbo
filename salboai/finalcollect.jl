const go_home_margin = 15

function isgameending(turns_left, dropoff_distance)
	turns_left <= dropoff_distance + go_home_margin
end


function gameending(m, s::H.Ship, dropoff::Back2DropOffCost)
	target = dropoff.P[s.p]
	dir = cheapestmoves(m, s, target)

	next_p = wrap.((s.p,) .+ cmdΔ.(dir), (size(m),))
	on_dropoff = target == s.p
	dropoff_next = (target,) .== next_p
	checkcollision = .!(dropoff_next .| on_dropoff)

	return CandidateTarget.(dir, (target,), checkcollision)
end


function cheapestmoves(m, ship, target)
	moves = simplemoves(size(m), ship.p, target)
	hpt, cost1, direction1 = halite_per_turn(m, ship, target)
	dir1 = direction1[target]
	dir = [dir1; moves[moves .!= dir1]]
	return dir
end


function simplemoves(mapsize, source, target)
	# find alternate direction to take if preferred path is occupied
	dir = Δ(mapsize, source, target)
	moves = []
	if dir[1] > 0 push!(moves, H.SOUTH) end
	if dir[1] < 0 push!(moves, H.NORTH) end
	if dir[2] > 0 push!(moves, H.EAST) end
	if dir[2] < 0 push!(moves, H.WEST) end
	return moves
end
