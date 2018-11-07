enemyshipspos(g) = [s.p for (id,p) in g.players if id != g.my_player_id for s in p.ships]
inspiredsquares(g) = 1 .< entitiesinradius(size(g.halite), enemyshipspos(g), 4)

function forbiddensquares(g)
    return (0 .< entitiesinradius(size(g.halite), enemyshipspos(g), 1)) .&
           (0 .== entitiesinradius(size(g.halite), H.dropoffs_p(H.me(g)), 1))
end

function entitiesinradius(sz, p, r)
    m = zeros(Int, sz)
    m[p] .= 1
    return diamondfilter(m, r)
end
