winds2cartesian(D) = replace(D, H.NORTH => CartesianIndex(-1,0), H.WEST => CartesianIndex(0,-1), H.SOUTH => CartesianIndex(1,0), H.EAST => CartesianIndex(0,1))

cmdΔ(move) = Dict(
        H.NORTH => CartesianIndex(-1, 0),
        H.SOUTH => CartesianIndex(1, 0),
        H.WEST => CartesianIndex(0, -1),
        H.EAST => CartesianIndex(0, 1),
        H.STAY_STILL => CartesianIndex(0, 0),
        H.CONSTRUCT => CartesianIndex(0, 0)
    )[move]


function avoidcollision(m, ships_p, moves)
    stays_still(m) = m ∈ (H.STAY_STILL, H.CONSTRUCT)
    # it's possible that some ships needs to stay still to avoid collisions, freeze those and start over
    @assert length(unique(ships_p)) == length(ships_p)

    freezed_something = true
    pickedmove = getindex.(moves, 1)

    while freezed_something
        occupied = H.WrappedMatrix(falses(size(m)))
        occupied[ships_p[stays_still.(pickedmove)]] .= true
        freezed_something = false

        for i=1:length(ships_p)
            if !stays_still(pickedmove[i])
                foundunoccupied=false
                for move in moves[i]
                    newp = ships_p[i] + cmdΔ(move)
                    if !occupied[newp]
                        occupied[newp] = true
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
        if freezed_something
            continue
        else
            return pickedmove, occupied
        end
    end
end


function avoidcollision2(m, ships_p, moves, gameendings, shipyard)
    stays_still(m) = m ∈ (H.STAY_STILL, H.CONSTRUCT)
    # it's possible that some ships needs to stay still to avoid collisions, freeze those and start over
    @assert length(unique(ships_p)) == length(ships_p)

    freezed_something = true
    pickedmove = getindex.(moves, 1)

    while freezed_something
        occupied = H.WrappedMatrix(falses(size(m)))
        occupied[ships_p[stays_still.(pickedmove)]] .= true
        freezed_something = false

        for i=1:length(ships_p)
            foundunoccupied=false
            if gameendings[i] #game ending behaviour
                for move in moves[i]
                    #if standing on shipyard
                    if ships_p[i] == shipyard
                        newp = ships_p[i]
                        occupied[newp] = false
                        pickedmove[i] = H.STAY_STILL
                        foundunoccupied = true
                        break
                    end

                    #if going to shipyard
                    newp = ships_p[i] + cmdΔ(move)
                    if !occupied[newp]
                        occupied[newp] = true
                        if newp == shipyard
                            occupied[newp] = false
                        end
                        pickedmove[i] = move
                        foundunoccupied = true
                        break
                    end

                    #loop again
                    if !foundunoccupied
                        pickedmove[i] = H.STAY_STILL
                        freezed_something = true
                    end
                end

            else #normal behaviour
                if !stays_still(pickedmove[i])
                    #foundunoccupied=false
                    for move in moves[i]
                        newp = ships_p[i] + cmdΔ(move)
                        if !occupied[newp]
                            occupied[newp] = true
                            pickedmove[i] = move
                            foundunoccupied = true
                            break
                        end
                    end

                    #loop again
                    if !foundunoccupied
                        pickedmove[i] = H.STAY_STILL
                        freezed_something = true
                    end
                end
            end
        end
        if freezed_something
            continue
        else
            return pickedmove, occupied
        end
    end
end


