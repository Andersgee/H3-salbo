# given the distance 'd' and cost 'c' to the cheapest dropoff for each point on the map
# calculate the best possible halite per tick of moving to a square and then back to a dropoff
# pick path that yields most halite per tick considering (cost to dropoff can get cheaper after mining but ignore that)
function quadrant_hpt(M, ship_halite)
	# forced mining is not interesting, assert that's not the case
	@assert leavecost(M[1,1]) ≤ ship_halite

	t = ones(Int, size(M)) # minimum number of ticks to leave each square
	d = ones(Int, size(M)) # direction
	d[1,1] = 4
	d[2:end,1] .= 0
	d[1,2:end] .= 1
	m = copy(M)
	h = similar(M, size(M)) # accumulated halite after leaving square

	h[1,1] = ship_halite - leavecost(M[1,1])
	t[1,1] = 1

	for x=1:size(M,2), y=1:size(M,1)
		v = vy = vx = M[y,x]
		A = mineamount(vx) # only relevant when a ship can barely afford to move
		if x>1
			tx = t[y,x-1]
			hx = h[y,x-1]
			if leavecost(vx) > hx # can't afford to pass-through, must stop and mine
				tx += 1
				hx += A
				vx -= A
			end
			h[y,x] = hx - leavecost(vx)
			t[y,x] = tx + 1
			if y > 1
				d[y,x] = d[y,x-1]
			end
			v = vx
		end
		if y>1
			ty = t[y-1,x]
			hy = h[y-1,x]
			if leavecost(vy) > hy # can't afford to pass-through, must stop and mine
				ty += 1
				hy += A
				vy -= A
			end
			hy = hy - leavecost(vy)
			ty = ty + 1

			xhpt = h[y,x] / t[y,x]
			yhpt = hy / ty
			if x == 1 || ty < t[y,x] || (ty == t[y,x] && yhpt > xhpt)
				h[y,x] = hy
				t[y,x] = ty
				if x > 1
					d[y,x] = d[y-1,x]
				end
				v = vy
			end
		end
		m[y,x] = v
	end

	return m, h, t, d
end


function onewayhpt(m, ship_pos, ship_halite)
    #Cheapest cost from some point to All Other points,
    #and what direction to go on First step to take that cheapest path.
    #south/east/north/west (in that order 0,1,2,3)
    m = shiftorigin(m, ship_pos)
	quadrant_hpt2(m) = quadrant_hpt(m, ship_halite)
    m1, h1, t1, d1 = m |> q1 |> quadrant_hpt2 .|> q1
    m2, h2, t2, d2 = m |> q2 |> quadrant_hpt2 .|> q2
    m3, h3, t3, d3 = m |> q3 |> quadrant_hpt2 .|> q3
    m4, h4, t4, d4 = m |> q4 |> quadrant_hpt2 .|> q4

    d1 = q1d(d1)
    d2 = q2d(d2)
    d3 = q3d(d3)
    d4 = q4d(d4)

	M3 = cat(m1, m2, m3, m4, dims=3)
	H3 = cat(h1, h2, h3, h4, dims=3)
	T3 = cat(t1, t2, t3, t4, dims=3)
	D3 = cat(d1, d2, d3, d4, dims=3)
	_, i = findmin(T3 - 1e-6H3, dims=3)
	M = M3[i][:,:]
	H = H3[i][:,:]
	T = T3[i][:,:]
	D = D3[i][:,:]
	return ishiftorigin.((M, H, T, D), (ship_pos,))
end


function cheapestdropoff(m, dropoffs)
	T = travelcost.((m,), dropoffs) # C, D, MHD
	C3 = cat(getindex.(T, 1)..., dims=3)
	T3 = cat(getindex.(T, 3)..., dims=3)
	D3 = cat(getindex.(T, 2)..., dims=3)
	_, i = findmin(C3, dims=3)
	C = C3[i][:,:]
	T = T3[i][:,:]
	D = D3[i][:,:]
	return C, T, reversedir(D)
end


reversedir(d) = replace(d,
		H.EAST => H.WEST,
	    H.WEST => H.EAST,
		H.NORTH => H.SOUTH,
		H.SOUTH => H.NORTH)


function twowayhpt(M, h, T, D, dropoff_c, dropoff_t)
	# H includes ship_halite
	# T includes ship_ticks
	hpt2way = (h .- dropoff_c) ./ (T .+ dropoff_t)
	h = h .+ leavecost.(M) # the original leave cost is already deduced from H, remove it
	for extra_mining_ticks in 1:10 # try mining up to 10 ticks to see if hpt can be increased
		A = mineamount.(M)
		A = min.(A, H.MAX_HALITE .- h)
		h = h .+ A
		M = M .- A
		L = leavecost.(M)
		hpttest = (h .- L .- dropoff_c) ./ (extra_mining_ticks .+ T .+ dropoff_t)
		j = hpt2way .< hpttest
		if any(j)
			hpt2way[j] .= hpttest[j]
		else
			break
		end
	end

	z = [begin
		hpt2way_max, hpt2way_maxi = findmax(hpt2way)
		D[hpt2way_maxi], hpt2way_max, hpt2way_maxi
	end for i in 1:4]
	dirs, hpts, targets = zip(z...)
end

function dropoffhpt(ship_pos, ship_halite, ship_ticks, dropoff_c, dropoff_t, dropoff_d)
	hpt2dropoff = (ship_halite - dropoff_c[ship_pos]) ./ (ship_ticks + dropoff_t[ship_pos])
	if dropoff_t[ship_pos] == 0
		hpt2dropoff = -Inf # don't go to dropoff if on a dropoff
	end
	return dropoff_d[ship_pos], hpt2dropoff
end

# dropoff_c, dropoff_t, dropoff_d = cheapestdropoff(m, dropoffs)
function pathfinding2(m, ship_pos, ship_halite, ship_ticks, dropoff_c, dropoff_t, dropoff_d)
	if ship_halite < leavecost(m[ship_pos])
	    return H.STAY_STILL
	end

	M, h, T, D = onewayhpt(m, ship_pos, ship_halite)
	adventure_dirs, adventure_hpts, adventure_targets = twowayhpt(M, h, T .+ ship_ticks, D, dropoff_c, dropoff_t)
	dropoff_dir, dropoff_hpt = dropoffhpt(ship_pos, ship_halite, ship_ticks, dropoff_c, dropoff_t, dropoff_d)

	warn("adventure_hpts ", adventure_hpts, " ", adventure_dirs, " ", adventure_targets)
	warn("dropoff_hpt ", dropoff_hpt, " ", dropoff_dir)

	hpts = [adventure_hpts..., dropoff_hpt]
	dirs = [adventure_dirs..., dropoff_dir]
	targets = [adventure_targets..., CartesianIndex(-1,-1)]
	p = sortperm(hpts, rev=true)
	return dirs[p], targets[p]
end
