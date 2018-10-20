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


move(s::Ship, dir::Char) = "$MOVE $(s.id) $dir"
make_dropoff(s::Ship, command::Char) = "$CONSTRUCT $(s.id)"
make_ship() = "$GENERATE"
stay_still(s::Ship) = move(s, STAY_STILL)


