max_turns(g::H.GameMap) = 451 * (size(g.halite, 1) - 48)*25/8

function quadrant_travelcost(m)
    # cost: cheapest cost from top left corner to every other square restricted to only South/East moves. (quadrant 4)
    # and
    # dir: correct FIRST direction to go in order to take that cheapest path
    Y=size(m,1)
    X=size(m,2)
    dir=ones(Int,(Y,X))
    cost=zeros(Int,(Y,X))
    for x=1:X,y=1:Y
        if x>1
            #cost[y,x]=cost[y,x-1]+m[y,x-1]
            cost[y,x] = cost[y,x-1] + m[y,x-1]
            dir[y,x] = y==1 ? 1 : dir[y,x-1]
        end
        if y>1
            #t_cost=cost[y-1,x]+m[y-1,x]
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

iq1(m,d) = q1(m), replace(d, 0 => 'n', 1 => 'w', 4 => 'o')
iq2(m,d) = q2(m), replace(d, 0 => 'n', 1 => 'e', 4 => 'o')
iq3(m,d) = q3(m), replace(d, 0 => 's', 1 => 'e', 4 => 'o')
iq4(m,d) = q4(m), replace(d, 0 => 's', 1 => 'w', 4 => 'o')

shiftorigin(m, origin) = circshift(m, (1-origin[1], 1-origin[2]))
ishiftorigin(m, origin) = circshift(m, (origin[1]-1, origin[2]-1))

leavecost(M) = floor(Int, 0.1M)

function travelcost(M, origin)
    #Cheapest cost from some point to All Other points,
    #and what direction to go on First step to take that cheapest path.
    #south/east/north/west (in that order 0,1,2,3)
    m = leavecost.(M)
    m = shiftorigin(m, origin)
    expand(f) = x -> f(x...)
    c1,d1 = m |> q1 |> quadrant_travelcost |> expand(iq1)
    c2,d2 = m |> q2 |> quadrant_travelcost |> expand(iq2)
    c3,d3 = m |> q3 |> quadrant_travelcost |> expand(iq3)
    c4,d4 = m |> q4 |> quadrant_travelcost |> expand(iq4)

    D = cat(d1,d2,d3,d4, dims=3)
    C = cat(c1,c2,c3,c4, dims=3)

    S = [x + y for y in 1:size(m,1), x in 1:size(m,2)]

    v, i = findmin(C, dims=3)

    cost = ishiftorigin(C[i][:,:,1], origin)
    first_direction = ishiftorigin(D[i][:,:,1], origin)
    steps = ishiftorigin(S, origin)
    return cost, first_direction, steps
end

function mapscore(M, ship, shipyard, threshold)
    #reward
    #minus
    #cost (from ship, to some point, and then to shipyard)

    reward = max.(M .- threshold, 0)
    #leftovers = min.(mining, threshold)
    M = copy(M)
    cost2, direction2, steps2 = travelcost(M, p2v(shipyard))

    M[shipyard] = ship.halite
    cost1, direction1, steps1 = travelcost(M, p2v(ship.p))

    #distcost = manhattandist()

    #cost = cost1 + cost2 + 0.1*leftovers
    cost = cost1 + cost2
    steps = steps1 + steps2

    s = (reward - cost) ./ steps
    return s, direction1, cost1
end

function filterscores(S, cost_here2there, ship_available_halite)
    #score of unreachable are zero
    S = S.*(cost_here2there .< ship_available_halite)
    return S
end



p2v(p) = [p[1], p[2]]

function pickbestsquare(S)
    v,i = findmax(S)
    return i
end
