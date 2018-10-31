winds2cartesian(D) = replace(D, H.NORTH => CartesianIndex(-1,0), H.WEST => CartesianIndex(0,-1), H.SOUTH => CartesianIndex(1,0), H.EAST => CartesianIndex(0,1))

cmd2delta(move) = Dict(
        H.NORTH => CartesianIndex(-1, 0),
        H.SOUTH => CartesianIndex(1, 0),
        H.WEST => CartesianIndex(0, -1),
        H.EAST => CartesianIndex(0, 1),
        H.STAY_STILL => CartesianIndex(0, 0),
        H.CONSTRUCT => CartesianIndex(0, 0)
    )[move]


function avoidcollision(m, ships_p, moves)
    # it's possible that some ships needs to stay still to avoid collisions, freeze those and start over
    @assert length(unique(ships_p)) == length(ships_p)

    freezed_something = true
    stays_still = getindex.(moves, 1) .∈ ((H.STAY_STILL, H.CONSTRUCT),)

    while freezed_something
        occupied = H.WrappedMatrix(falses(size(m)))
        occupied[ships_p[stays_still]] .= true
        pickedmove = getindex.(moves, 1)
        freezed_something = false

        for i=1:length(ships_p)
            if stays_still[i]
                continue
            end
            foundunoccupied=false
            for move in moves[i]
                newp = ships_p[i] + cmd2delta(move)
                if !occupied[newp]
                    occupied[newp] = true
                    pickedmove[i] = move
                    foundunoccupied = true
                    break
                end
            end
            if !foundunoccupied
                stays_still[i] = true
                freezed_something = true
            end
        end
        if freezed_something
            continue
        else
            return pickedmove, occupied
        end
    end

end
