winds2cartesian(D) = replace(D, H.NORTH => CartesianIndex(-1,0), H.WEST => CartesianIndex(0,-1), H.SOUTH => CartesianIndex(1,0), H.EAST => CartesianIndex(0,1))

cmdΔ(move) = Dict(
        H.NORTH => CartesianIndex(-1, 0),
        H.SOUTH => CartesianIndex(1, 0),
        H.WEST => CartesianIndex(0, -1),
        H.EAST => CartesianIndex(0, 1),
        H.STAY_STILL => CartesianIndex(0, 0),
        H.CONSTRUCT => CartesianIndex(0, 0)
    )[move]


function avoidcollision(m, ships, moves, forbidden)
    stays_still(m) = m ∈ (H.STAY_STILL, H.CONSTRUCT)
    # it's possible that some ships needs to stay still to avoid collisions, freeze those and start over
    orderbyhalite = sortperm(ships, by = s-> s.halite)
    ships_p = [s.p for s in ships]
    @assert length(unique(ships_p)) == length(ships_p)

    freezed_something = true
    pickedmove = getindex.(moves, 1)
    occupied = BitArray(undef, size(m))
    sz = size(m)

    while freezed_something
        occupied[:] = forbidden
        occupied[ships_p[stays_still.(pickedmove)]] .= true
        freezed_something = false

        for i in orderbyhalite
            if !stays_still(pickedmove[i])
                foundunoccupied=false
                for move in moves[i]
                    newp = ships_p[i] + cmdΔ(move)
                    newpw = CartesianIndex(mod1.(Tuple(newp), sz))
                    if !occupied[newpw]
                        occupied[newpw] = true
                        pickedmove[i] = move
                        foundunoccupied = true
                        break
                    end
                end
                if !foundunoccupied
                    pickedmove[i] = H.STAY_STILL
                    freezed_something = true
                end
            end
        end
    end

    return pickedmove, occupied
end
