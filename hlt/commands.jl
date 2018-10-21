"""
All viable commands that can be sent to the engine
"""

const NORTH = 'n'
const SOUTH = 's'
const EAST = 'e'
const WEST = 'w'
const STAY_STILL = 'o'

const GENERATE = 'g'
const CONSTRUCT = 'c'
const MOVE = 'm'


#make_ship() = "$GENERATE"
#move(s::Ship, dir::Char) = "$MOVE $(s.id) $dir"
make_dropoff(s::Ship, command::Char) = "$CONSTRUCT $(s.id)"
#stay_still(s::Ship) = move(s, STAY_STILL)

make_ship() = "g"

function move(s::Ship, dir::Int)
	a=['s','e','n','w','o']
	return "m $(s.id) $(a[dir+1])"
end
