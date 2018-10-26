winds2cartesian(D) = replace(D, H.NORTH => CartesianIndex(-1,0), H.WEST => CartesianIndex(0,-1), H.SOUTH => CartesianIndex(1,0), H.EAST => CartesianIndex(0,1))

function movep(shipp, move)
    d = Dict('n' => CartesianIndex(-1, 0),
             's' => CartesianIndex(1, 0),
             'w' => CartesianIndex(0, -1),
             'e' => CartesianIndex(0, 1),
             'o' => CartesianIndex(0, 0))
    return shipp + d[move]
end


function avoidcollision(m, ships_p, moves, shipyard)
    occupied = H.WrappedMatrix(falses(size(m)))

    pickedmove = Char[]
    for i=1:length(ships_p)
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
            warn("!foundunoccupied !foundunoccupied !foundunoccupied")
            push!(pickedmove, 'o')
        end
    end

    cangenerate = true
    if occupied[shipyard] == true
        cangenerate = false
    end

    return pickedmove, cangenerate
end