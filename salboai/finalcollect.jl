const go_home_margin = 1

function isgameending(turns_left, dropoff_distance)
	turns_left <= dropoff_distance + go_home_margin
end


function go2dropoff(m, s::H.Ship, dropoff::Back2DropOffCost, crash_on_dropoff::Bool=false)
	target = dropoff.P[s.p]
	dir = cheapestmoves(m, s, target)

	if crash_on_dropoff
		next_p = [wrap(s.p + cmdΔ(d), size(m)) for d in dir]
		on_dropoff = target == s.p
		dropoff_next = (target,) .== next_p
		checkcollision = .!(dropoff_next .| on_dropoff)
		return CandidateTarget.(dir, (target,), checkcollision)
	else
		return CandidateTarget.(dir, (target,))
	end
end


function cheapestmoves(m, ship, target)
	moves = simplemoves(size(m), ship.p, target)
    _, direction1, _ = travelcost(m, ship.p)
	dir1 = direction1[target]
	dir = [dir1; moves[moves .!= dir1]]
	return dir
end


function simplemoves(mapsize, source, target)
	# find alternate direction to take if preferred path is occupied
	if source == target return [H.STAY_STILL] end

	dir = Δ(mapsize, source, target)
	moves = []
	if dir[1] > 0 push!(moves, H.SOUTH) end
	if dir[1] < 0 push!(moves, H.NORTH) end
	if dir[2] > 0 push!(moves, H.EAST) end
	if dir[2] < 0 push!(moves, H.WEST) end
	return moves
end
