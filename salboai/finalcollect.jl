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


function cheapestmoves(m, ship, target)
	moves = simplemoves(size(m), ship.p, target)
	hpt, cost1, direction1 = halite_per_turn(m, ship, target)
	dir1 = direction1[target]
	dir = [dir1; moves[moves .!= dir1]]
	return dir, fill(target, length(dir))
end


function crash_on_dropoffs(mapsize, ships, moves, targets, dropoffs)
	firstmove = getindex.(moves, 1)
	ships_p = [s.p for s in ships]
	next_p = wrap.(ships_p .+ cmdΔ.(firstmove), (mapsize,))
	on_dropoff = ships_p .∈ (dropoffs,)
	dropoff_next = next_p .∈ (dropoffs,)

    go_dropoff = getindex.(moves[dropoff_next], 1)
    cmds = H.move.(ships[dropoff_next], go_dropoff)

    collisioncheck = .!(dropoff_next .| on_dropoff)
    moves = moves[collisioncheck]
    ships = ships[collisioncheck]
    targets = targets[collisioncheck]

    return ships, moves, targets, cmds
end
