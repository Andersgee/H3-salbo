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

    while freezed_something
        #occupied = H.WrappedMatrix(falses(size(m)))
        occupied = H.WrappedMatrix(copy(forbidden))
        occupied[ships_p[stays_still.(pickedmove)]] .= true
        freezed_something = false

        for i=orderbyhalite
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


function forbiddensquares(g)
    #return boolean wrappedmatrix with all squares with enemy ships on them plus/minus one marked as true
    NPlayers=length(g.players)
    myplayerid = g.my_player_id
    allplayerids = [g.players[i].id for i=0:length(g.players)-1]
    otherplayersids=allplayerids[allplayerids.!=myplayerid]

    forbidden = H.WrappedMatrix(falses(size(g.halite)))

    for id = otherplayersids
        Nships = length(g.players[id].ships)
        enemyshippositions = [g.players[id].ships[i].p for i=1:Nships]

        for i = 1:length(enemyshippositions)
            forbidden[enemyshippositions[i] + CartesianIndex(0,0)] = true
            forbidden[enemyshippositions[i] + CartesianIndex(1,0)] = true
            forbidden[enemyshippositions[i] + CartesianIndex(0,1)] = true
            forbidden[enemyshippositions[i] + CartesianIndex(-1,0)] = true
            forbidden[enemyshippositions[i] + CartesianIndex(0,-1)] = true
        end
    end

    #Dont forbid our dropoffs even if enemy is near it
    p_dropoffs = H.dropoffs_p(H.me(g))
    for i =1:length(p_dropoffs)
        forbidden[p_dropoffs[i] + CartesianIndex(0,0)] .= false
        forbidden[p_dropoffs[i] + CartesianIndex(1,0)] .= false
        forbidden[p_dropoffs[i] + CartesianIndex(0,1)] .= false
        forbidden[p_dropoffs[i] + CartesianIndex(-1,0)] .= false
        forbidden[p_dropoffs[i] + CartesianIndex(0,-1)] .= false
    end
    return forbidden
end


function inspiredsquares(g)
    NPlayers=length(g.players)
    myplayerid = g.my_player_id
    allplayerids = [g.players[i].id for i=0:length(g.players)-1]
    otherplayersids=allplayerids[allplayerids.!=myplayerid]
    
    counter = H.WrappedMatrix(zeros(Int, size(g.halite)))
    
    for id = otherplayersids
        Nships = length(g.players[id].ships)
        enemyshippositions = [g.players[id].ships[i].p for i=1:Nships]
    
        for i = 1:length(enemyshippositions)
            p = enemyshippositions[i]
            #fill a shape of ones around the ship
            a = H.WrappedMatrix(zeros(Int, size(g.halite)))
            a[p[1]-2:p[1]+2, p[2]-2:p[2]+2]=1
            a[p[1]-1:p[1]+1, p[2]-3:p[2]+3]=1
            a[p[1]-0:p[1]+0, p[2]-4:p[2]+4]=1
            a[p[1]-3:p[1]+3, p[2]-1:p[2]+1]=1
            a[p[1]-4:p[1]+4, p[2]-0:p[2]+0]=1
            
            counter += a
        end
    end
    inspired = counter.>=2 #must be 2 enemy ships within radius
    return inspired
end