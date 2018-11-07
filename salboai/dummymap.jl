randpos(sz) = CartesianIndex(rand(1:sz[1]), rand(1:sz[2]))

dummyShip(owner, sz, id, p, halite=rand(1:H.MAX_HALITE)) = H.Ship(owner, id, p, halite)

dummyDropOff(owner, sz, id, p) = H.DropOff(owner, id, p)

function dummyPlayer(id, sz)
    shipyard = randpos(sz)
    ship_p = unique([randpos(sz) for i in 1:10])
    dropoff_p = unique([randpos(sz) for i in 1:10])
    return H.Player(
        id,
        shipyard,
        1234,
        dummyShip.(id, (sz,), 1:length(ship_p), ship_p),
        dummyDropOff.(id, (sz,), 1:length(dropoff_p), dropoff_p))
end

function dummyGameMap(sz = (32, 32), n_players = 4)
    halite = rand(1:1000, sz)
    player_ids = 100*(1:n_players)
    return H.GameMap(
        rand(player_ids),
        halite,
        [dummyPlayer(id, sz) for id in player_ids])
end
