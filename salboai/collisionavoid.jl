winds2cartesian(D) = replace(D, H.NORTH => CartesianIndex(-1,0), H.WEST => CartesianIndex(0,-1), H.SOUTH => CartesianIndex(1,0), H.EAST => CartesianIndex(0,1))

function avoidcollision!(m, ships, movestrings, shipyard, isgenerating)
    occupied=zeros(Int, size(m))
    if isgenerating
        occupied[shipyard]=1
    end

    moves = winds2cartesian(movestrings)
    for n = 1:length(ships)
        if occupied[ships[n].p+moves[n]] == 0
            occupied[ships[n].p + moves[n]] = 1 #move
            movestrings[n]=movestrings[n]
        else
            occupied[ships[n].p] = 1 #stay
            movestrings[n] = H.STAY_STILL #what if stay still on top of shipyard?.. not dealt with.
        end
    end
    return movestrings
end