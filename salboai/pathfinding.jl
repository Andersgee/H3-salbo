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

q1d(d) = replace(d, 0 => H.NORTH, 1 => H.EAST, 4 => H.STAY_STILL)
q2d(d) = replace(d, 0 => H.NORTH, 1 => H.WEST, 4 => H.STAY_STILL)
q3d(d) = replace(d, 0 => H.SOUTH, 1 => H.WEST, 4 => H.STAY_STILL)
q4d(d) = replace(d, 0 => H.SOUTH, 1 => H.EAST, 4 => H.STAY_STILL)

shiftorigin(m, origin::CartesianIndex) = circshift(m, Tuple(CartesianIndex(1,1) - origin))
ishiftorigin(m, origin::CartesianIndex) = circshift(m, Tuple(origin - CartesianIndex(1,1)))

leavecost(m) = div(m, 10)
mineamount(m) = div(m + 3, 4)


function travelcost_3d(m, o)
    #Cheapest cost from some point to All Other points,
    #and what direction to go on First step to take that cheapest path.
    #south/east/north/west (in that order 0,1,2,3)
    m = shiftorigin(m, o)
    c1,d1 = m |> q1 |> quadrant_travelcost .|> q1
    c2,d2 = m |> q2 |> quadrant_travelcost .|> q2
    c3,d3 = m |> q3 |> quadrant_travelcost .|> q3
    c4,d4 = m |> q4 |> quadrant_travelcost .|> q4

    d1 = q1d(d1)
    d2 = q2d(d2)
    d3 = q3d(d3)
    d4 = q4d(d4)

    #3d
    D3 = cat(d1, d2, d3, d4, dims=3)
    C3 = cat(c1, c2, c3, c4, dims=3)
    MHD3 = manhattandistmatrices(m,o)
    return ishiftorigin(C3,o), ishiftorigin(D3,o), MHD3
end


function travelcost(m,o)
    C3, D3, MHD3 = travelcost_3d(m, o)

    #make sure to pick the one with shortest distance in case cheapest cost is same for several.
    _, i = findmin(C3 .+ 1e-6MHD3, dims=3)
    C = C3[i][:,:]
    D = D3[i][:,:]
    MHD = MHD3[i][:,:]

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
    m = copy(m)
    m[shipyard] = 0

    mining = mineamount.(m)
    max_mining = H.MAX_HALITE - ship.halite
    mining = min.(mining, max_mining) #means 0 mining if full.
    cost1, direction1, mhd1 = travelcost(m, ship.p)
    cost2, direction2, mhd2 = travelcost(m, shipyard)
    cost2 = cost2 + leavecost.(m - mining)

    cost = cost1 + cost2
    mhd = mhd1 .+ mhd2

    net_gain = mining - cost1
    hpt = net_gain ./ (mhd1.+1) #plus 1 since we mined one turn

    return hpt, cost1, direction1
end


canmove(ship::H.Ship, halite) = leavecost(halite[ship.p]) <= ship.halite

within_reach(hpt, cost1, ship_halite) = ifelse.(cost1 .<= ship_halite, hpt, -Inf)


function select_direction(m, ship, shipyard, turn=0)
    hpt, cost1, direction1 = halite_per_turn(m, ship, shipyard)
    hpt_within_reach = within_reach(hpt, cost1, ship.halite)
    dir = direction1[findmax(hpt_within_reach)[2]]
    return dir
end


function hpt2targets(hpt, dir)
	#should return all directons with best first and decending
	D =Char[]
    target = CartesianIndex[]
    target_hpt = Float64[]
	for _ = 1:5
		v, i = findmax(hpt)
		push!(D, dir[i])
        push!(target, i)
        push!(target_hpt, hpt[i])
		hpt[dir.==dir[i]] .= -Inf #set all values starting with that direction to very bad so its not picked again
	end
    return D, target, target_hpt
end


function sort_staystill_first!(ships, moves, targets)
    #probably useful to have the ones mining first in the aray
    #so they get priority in avoidcollisions() simply by iterating over them first.
    is_moving = [m[1] != H.STAY_STILL for m in moves]
    i = sortperm(is_moving)
    return ships[i], moves[i], targets[i]
end


function candidate_targets_inner(m, ship, shipyard)
    hpt, cost1, direction1 = halite_per_turn(m, ship, shipyard)
    hpt = within_reach(hpt, cost1, ship.halite)
    dir, target, target_hpt = hpt2targets(hpt, direction1)

    #make sure shipyard is candidate1 if full
    if ship.halite > 0.95*H.MAX_HALITE
        d = direction1[shipyard]

        #target = [shipyard; target[dir.!=d]] #priority 1 go to shipyard
        #target_hpt = [Inf; target_hpt[dir.!=d]]
        #dir = [d; dir[dir.!=d]] #priority 1 go to shipyard
        dir = [direction1[shipyard], H.STAY_STILL,H.STAY_STILL,H.STAY_STILL,H.STAY_STILL]
        target = [shipyard; shipyard;shipyard;shipyard;shipyard] #priority 1 go to shipyard
        target_hpt = [Inf; Inf;Inf;Inf;Inf]
    end


    return dir, target, target_hpt
end


function exclusive_candidate1_targets!(dirs, targets, targets_hpt, shipyard)
    #changes FIRST candidate target to be exclusive among the ships. (the others are not exclusive)
    #does not change order of targets_hpt
    targets_hpt_matrix=hcat(targets_hpt...)
    targets_matrix = hcat(targets...)
    for _ = 1:length(dirs)

        v, ind = findmax(targets_hpt_matrix)
        i = ind[1]
        shipnr = ind[2]
        bestsquare = targets_matrix[ind] #this square has best hpt (among all)

        if bestsquare != shipyard #dont mess with target if its the shipyard

            #put that direction as first candidate direction and target
            d = dirs[shipnr]
            dirs[shipnr] = [d[i]; d[d.!=d[i]]]

            t = targets[shipnr]
            targets[shipnr] = [t[i]; t[ t.!= (t[i],) ]]

            #remove the picked square and ship from being picked again
            targets_hpt_matrix[targets_matrix.==(bestsquare,)] .= -Inf
            targets_hpt_matrix[:,shipnr] .= -Inf
        end
    end




    return dirs, targets
end
