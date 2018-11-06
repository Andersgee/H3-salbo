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

ready(botname, io::IO=Base.stdout) = sendcommands([botname], io)

make_ship() = "$GENERATE"
move(s::Ship, dir::Char) = "$MOVE $(s.id) $dir"
make_dropoff(s::Ship) = "$CONSTRUCT $(s.id)"
stay_still(s::Ship) = move(s, STAY_STILL)

move_or_make_dropoff(s::Ship, cmd::Char) = (cmd == CONSTRUCT ? make_dropoff(s) : move(s, cmd))
