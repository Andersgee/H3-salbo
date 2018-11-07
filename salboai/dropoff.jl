localmaxima2(A) = findall((A .> circshift(A, (1,0))) .&
                          (A .> circshift(A, (0,1))) .&
                          (A .≥ circshift(A, (-1,0))) .&
                          (A .≥ circshift(A, (0,-1))))

function dropoffcands(A, dropoffs, r=30)
    if any(r .≥ size(A) .- 1)
        return CartesianIndex{2}[]
    end

    function cleardiamond(a, p)
        h, w = size(a)
        for x in -r:r
            y = -r+abs(x):r-abs(x)
            a[mod1.(p[1] .+ y, h), mod1(p[2] + x, w)] .= 0
        end
    end

    a = copy(A)
    for i in 1:r
        a .+= div.(diamondfilter(a, i), diamondelems(i))
    end
    cleardiamond.((a,), dropoffs)

    cands = CartesianIndex{2}[]
    for lm in localmaxima2(a)
        if a[lm] == 0 continue end
        push!(cands, lm)
        cleardiamond(a, lm)
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
