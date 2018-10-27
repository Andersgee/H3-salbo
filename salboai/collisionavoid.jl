winds2cartesian(D) = replace(D, H.NORTH => CartesianIndex(-1,0), H.WEST => CartesianIndex(0,-1), H.SOUTH => CartesianIndex(1,0), H.EAST => CartesianIndex(0,1))

function movep(shipp, move)
    d = Dict('n' => CartesianIndex(-1, 0),
             's' => CartesianIndex(1, 0),
             'w' => CartesianIndex(0, -1),
             'e' => CartesianIndex(0, 1),
             'o' => CartesianIndex(0, 0))
    return shipp + d[move]
end


function avoidcollision(m, ships_p, moves, shipyard, gameisendings)
    occupied = H.WrappedMatrix(falses(size(m)))



    pickedmove = Char[]
    for i=1:length(ships_p)

        #dont avoid collision on top of shipyard if game is ending (avoid traffic jams)
        if gameisendings[i]
            occupied[shipyard] = false
            if (ships_p[i] == shipyard)
                push!(pickedmove, H.STAY_STILL)
                continue
            end
        end

        foundunoccupied=false
        #newp = ships[i].p
        for move in moves[i]
            newp = movep(ships_p[i], move)
            if !occupied[newp]
                occupied[newp] = true
                push!(pickedmove, move)
                foundunoccupied = true
                break
            end
        end
        if !foundunoccupied
            warn("COULDNT FIND FREE SQUARE TO MOVE TO (inside avoicollision)")
            push!(pickedmove, 'o')
        end
    end

    cangenerate = true
    if occupied[shipyard] == true
        cangenerate = false
    end

    return pickedmove, cangenerate
end