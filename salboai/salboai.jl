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
            cost[y,x]=cost[y,x-1] + round(Int, m[y,x-1], RoundDown)
            dir[y,x]  = y==1 ? 1 : dir[y,x-1]
        end
        if y>1
            #t_cost=cost[y-1,x]+m[y-1,x]
            t_cost = cost[y-1,x] + round(Int, m[y-1,x], RoundDown)
            if t_cost<cost[y,x] || x==1
                cost[y,x]=t_cost
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

iq1(m,d) = q1(m), replace(d, 0 => 2)
iq2(m,d) = q2(m), replace(d, 0 => 2, 1 => 3)
iq3(m,d) = q3(m), replace(d, 1 => 3)
iq4(m,d) = q4(m), d

shiftorigin(m, origin) = circshift(m, (1-origin[1], 1-origin[2]))
ishiftorigin(m, origin) = circshift(m, (origin[1]-1, origin[2]-1))

function travelcost(m, origin)
    #Cheapest cost from some point to All Other points,
    #and what direction to go on First step to take that cheapest path.
    #south/east/north/west (in that order 0,1,2,3)
    m = shiftorigin(m, origin)*0.1
    expand(f) = x -> f(x...)
    c1,d1 = m |> q1 |> quadrant_travelcost |> expand(iq1)
    c2,d2 = m |> q2 |> quadrant_travelcost |> expand(iq2)
    c3,d3 = m |> q3 |> quadrant_travelcost |> expand(iq3)
    c4,d4 = m |> q4 |> quadrant_travelcost |> expand(iq4)

    D = cat(d1,d2,d3,d4, dims=3)
    C = cat(c1,c2,c3,c4, dims=3)
    v, i = findmin(C, dims=3)

    cost = ishiftorigin(C[i][:,:,1], origin)
    first_direction = ishiftorigin(D[i][:,:,1], origin)
    return cost, first_direction
end

function mapscore(M, ship, shipyard, threshold)
    #reward
    #minus
    #cost (from ship, to some point, and then to shipyard)

    reward = max.(M .- threshold, 0)
    #mining = max.(0, M .- threshold)
    #leftovers = min.(mining, threshold)
    #ignoreshipyard = M[shipyard...]
    cost1, direction1 = travelcost(M, ship)
    cost2, direction2 = travelcost(M, shipyard)

    #distcost = manhattandist()

    #cost = cost1 + cost2 + 0.1*leftovers .- 0.1*ignoreshipyard
    cost = cost1 + cost2 - M

    s = reward - cost
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
