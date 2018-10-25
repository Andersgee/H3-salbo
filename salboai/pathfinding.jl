max_turns(g::H.GameMap) = 451 * (size(g.halite, 1) - 48)*25/8

function quadrant_travelcost(M)
    # cost: cheapest cost from top left corner to every other square restricted to only South/East moves. (quadrant 4)
    # and
    # dir: correct FIRST direction to go in order to take that cheapest path
    m = leavecost.(M)
    Y = size(m, 1)
    X = size(m, 2)
    dir = ones(Int, (Y,X))
    cost = zeros(eltype(m), (Y,X))
    for x=1:X, y=1:Y
        if x>1
            cost[y,x] = cost[y,x-1] + m[y,x-1]
            dir[y,x] = y==1 ? 1 : dir[y,x-1]
        end
        if y>1
            t_cost = cost[y-1,x] + m[y-1,x]
            if t_cost<cost[y,x] || x==1
                cost[y,x] = t_cost
                dir[y,x] = x==1 ? 0 : dir[y-1,x]
            end
        end
    end
    dir[1,1]=4
    return cost, dir
end

q1(m) = reverse(circshift(m, (-1,0)), dims=1)
q2(m) = q1(q3(m))
q3(m) = reverse(circshift(m, (0,-1)), dims=2)
q4(m) = m

#=
iq1(m,d) = q1(m), replace(d, 0 => H.NORTH, 1 => H.EAST, 4 => H.STAY_STILL)
iq2(m,d) = q2(m), replace(d, 0 => H.NORTH, 1 => H.WEST, 4 => H.STAY_STILL)
iq3(m,d) = q3(m), replace(d, 0 => H.SOUTH, 1 => H.WEST, 4 => H.STAY_STILL)
iq4(m,d) = q4(m), replace(d, 0 => H.SOUTH, 1 => H.EAST, 4 => H.STAY_STILL)
=#

iq1(m,d) = q1(m), q1(replace(d, 0 => H.NORTH, 1 => H.EAST, 4 => H.STAY_STILL))
iq2(m,d) = q2(m), q2(replace(d, 0 => H.NORTH, 1 => H.WEST, 4 => H.STAY_STILL))
iq3(m,d) = q3(m), q3(replace(d, 0 => H.SOUTH, 1 => H.WEST, 4 => H.STAY_STILL))
iq4(m,d) = q4(m), q4(replace(d, 0 => H.SOUTH, 1 => H.EAST, 4 => H.STAY_STILL))

shiftorigin(m, origin::CartesianIndex) = circshift(m, Tuple(CartesianIndex(1,1) - origin))
ishiftorigin(m, origin::CartesianIndex) = circshift(m, Tuple(origin - CartesianIndex(1,1)))

leavecost(M) = floor(Int, 0.1M)


function travelcost_3d(m, o)
    #Cheapest cost from some point to All Other points,
    #and what direction to go on First step to take that cheapest path.
    #south/east/north/west (in that order 0,1,2,3)
    m = shiftorigin(m, o)
    expand(f) = x -> f(x...)
    c1,d1 = m |> q1 |> quadrant_travelcost |> expand(iq1)
    c2,d2 = m |> q2 |> quadrant_travelcost |> expand(iq2)
    c3,d3 = m |> q3 |> quadrant_travelcost |> expand(iq3)
    c4,d4 = m |> q4 |> quadrant_travelcost |> expand(iq4)
    
    #3d
    D3 = cat(d1, d2, d3, d4, dims=3)
    C3 = cat(c1, c2, c3, c4, dims=3)
    MHD3 = manhattandistmatrices(m,o)
    return ishiftorigin(C3,o), ishiftorigin(D3,o), MHD3
end


function travelcost(m,o)
    C3, D3, MHD3 = travelcost_3d(m, o)
    
    #make sure to pick the one with shortest distance in case cheapest cost is same for several.
    C = findmin(C3, dims=3)[1][:,:,1]
    MHD = zeros(Int, size(C))
    D = fill('ö', size(C))
    q = collect(1:4) #quartile number
    for x=1:size(C,2), y=1:size(C,1)
        i = q[C3[y,x,:] .== C[y,x]] #indexes with same minimum cost
        MHD[y,x], index = findmin(MHD3[y,x,i]) #pick minimum dist amongst the ones with least cost
        D[y,x] = D3[y,x,i][index] #pick the direction corresponding to that picked index
    end
    return C, D, MHD
end


function halite_per_turn(m, ship, shipyard)
    #mined halite amount (at some point)
    #minus
    #cost (from ship, to some point, and then to shipyard)
    #divided by
    #nr turns to travel there and then to shipyard
    #equals
    #net halite gained per turn
    
    mining = ceil.(m .* 0.25)
    cost1, direction1, mhd1 = travelcost(m, ship.p)
    cost2, direction2, mhd2 = travelcost(m, shipyard)
    cost2 = cost2 + floor.(Int, (m - mining)*0.1)
    
    cost = cost1 + cost2
    net_gain = (mining - cost) .+ ship.halite
    net_gain[shipyard] = ship.halite - cost1[shipyard]
    
    mhd = mhd1 .+ mhd2
    #hpt = net_gain./mhd
    
    hpt = net_gain ./ (mhd.+1) #plus 1 since we mined one turn
    hpt[shipyard] = net_gain[shipyard] ./ mhd[shipyard]
    
    if ship.p == shipyard
        hpt[shipyard] = 0
    end
    
    return hpt, cost1, direction1
end

#=
function travelcost(m, origin)
    #Cheapest cost from some point to All Other points,
    #and what direction to go on First step to take that cheapest path.
    #south/east/north/west (or stay still)
    m = shiftorigin(m, origin)
    expand(f) = x -> f(x...)
    c1,d1 = m |> q1 |> quadrant_travelcost |> expand(iq1)
    c2,d2 = m |> q2 |> quadrant_travelcost |> expand(iq2)
    c3,d3 = m |> q3 |> quadrant_travelcost |> expand(iq3)
    c4,d4 = m |> q4 |> quadrant_travelcost |> expand(iq4)

    D = cat(d1, d2, d3, d4, dims=3)
    C = cat(c1, c2, c3, c4, dims=3)

    C = ishiftorigin(C, origin)
    D = ishiftorigin(D, origin)

    return C, D
end


function halite_per_turn(m, ship, shipyard)
    #mined halite amount (at some point)
    #minus
    #cost (from ship, to some point, and then to shipyard)
    #divided by
    #nr turns to travel there and then to shipyard
    #equals
    #net halite gained per turn

    m = copy(m)
    m[shipyard] = 0

    mining = ceil.(Int, m .* 0.25)
    cost1, direction1 = travelcost(m, ship.p)
    cost2, direction2 = travelcost(m, shipyard)
    cost2 = cost2 .+ floor.(Int, (m - mining)*0.1)

    cost = cost1 + cost2
    net_gain = ship.halite .+ mining .- cost

    mhd1 = manhattandistmatrices(m, ship.p)
    mhd2 = manhattandistmatrices(m, shipyard)
    mhd = mhd1 .+ mhd2
    #hpt = net_gain./mhd

    hpt = net_gain ./ (mhd.+1) #plus 1 since we mined one turn
    hpt[shipyard, :] = net_gain[shipyard, :] ./ mhd[shipyard, :]

    if ship.p == shipyard
        hpt[shipyard, :] .= 0.0
    end

    hpt, i = findmax(hpt, dims=3)

    hpt = hpt[:,:,1]
    cost1 = cost1[i][:,:,1]
    cost2 = cost2[i][:,:,1]
    direction1 = direction1[i][:,:,1]

    return hpt, cost1, direction1, cost2
end
=#

canmove(ship::H.Ship, halite) = leavecost(halite[ship.p]) <= ship.halite


within_reach(hpt, cost1, ship_halite) = hpt.*(cost1 .<= ship_halite)


function select_direction(m, ship, shipyard)
    hpt, cost1, direction1 = halite_per_turn(m, ship, shipyard)
    hpt_within_reach = within_reach(hpt, cost1, ship.halite)
    dir = direction1[findmax(hpt_within_reach)[2]]
    return dir
end
