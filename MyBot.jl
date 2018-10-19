import JSON
#include("hlt/halite.jl")

function mylogger(s, id)
	if id==0
		f = open("logfile.log", "a")
		println(f, string(s))
		close(f)
	end
end

#game_constants
#= 
CAPTURE_ENABLED
CAPTURE_RADIUS
DEFAULT_MAP_HEIGHT
DEFAULT_MAP_WIDTH
DROPOFF_COST
DROPOFF_PENALTY_RATIO
EXTRACT_RATIO
FACTOR_EXP_1
FACTOR_EXP_2
INITIAL_ENERGY
INSPIRATION_ENABLED
INSPIRATION_RADIUS
INSPIRATION_SHIP_COUNT
INSPIRED_BONUS_MULTIPLIER
INSPIRED_EXTRACT_RATIO
INSPIRED_MOVE_COST_RATIO
MAX_CELL_PRODUCTION
MAX_ENERGY
MAX_PLAYERS
MAX_TURNS
MAX_TURN_THRESHOLD
MIN_CELL_PRODUCTION
MIN_TURNS
MIN_TURN_THRESHOLD
MOVE_COST_RATIO
NEW_ENTITY_ENERGY_COST
PERSISTENCE
SHIPS_ABOVE_FOR_CAPTURE
STRICT_ERRORS
game_seed
=#

game_constants = JSON.parse(readline())
num_players, id = parse.(Int, split(readline()))

mylogger(game_constants["CAPTURE_ENABLED"], id)
mylogger(num_players, id)
mylogger(id, id)

shipyard_positions = zeros(Int, num_players, 2)
for n=1:num_players
	player, x, y = parse.(Int, split(readline()))
	shipyard_positions[n, 1:2] = [y, x]
end

mylogger(shipyard_positions, id)

X, Y = parse.(Int, split(readline()))



mapdata = zeros(Int, Y,X)
xdata = zeros(Int, X)
#mylogger(mapdata, id)

#should return a matrix
for y=1:Y
	xdata = parse.(Int, split(readline()))
	mylogger(size(xdata), id)
	for x=1:X
		mapdata[y,x] = xdata[x]
	end
end

#mylogger(mapdata, id)


println("andybot",string(my_id))