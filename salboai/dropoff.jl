localmaxima2(A) = findall((A .> circshift(A, (1,0))) .&
                          (A .> circshift(A, (0,1))) .&
                          (A .≥ circshift(A, (-1,0))) .&
                          (A .≥ circshift(A, (0,-1))))

function dropoffcands(A, dropoffs, r=30)
    if any(r .≥ size(A) .- 1)
        return CartesianIndex{2}[]
    end

    function cleardiamond(w, p)
        for x in -r:r
            for y in -r:r
                if abs(x) + abs(y) ≤ r
                    w[p[1] + y, p[2] + x] = 0
                end
            end
        end
    end

    a = copy(A.a)
    for i in 1:r
        a .+= div.(diamondfilter(a, i), diamondelems(i))
    end
    w = H.WrappedMatrix(a)
    cleardiamond.((w,), dropoffs)

    cands = CartesianIndex{2}[]
    for lm in localmaxima2(w.a)
        if w.a[lm] == 0 continue end
        push!(cands, lm)
        cleardiamond(w, lm)
    end

    return cands
end


function prepare_for_dropoff(halite, ships, dropoff_cands)
    reserve_halite_for_dropoff_per_tick = 800

    if isempty(dropoff_cands) || isempty(ships)
        return 0, nothing
    end

    cand_dist, I = findmin([manhattandist(size(halite), s.p, d) for d in dropoff_cands, s in ships])
    dropoff_cand = dropoff_cands[I[1]]
    ship2dropoff_i = I[2]
    ship = ships[ship2dropoff_i]

    dropoff_cost = H.DROPOFF_COST - halite[dropoff_cand] - ship.halite

    dropoff_cost -= reserve_halite_for_dropoff_per_tick*cand_dist

    if dropoff_cost < 0
        dropoff_cost = 0
    end
    if cand_dist > 0
        ship2dropoff_i = nothing
    end

    return dropoff_cost, ship2dropoff_i
end
