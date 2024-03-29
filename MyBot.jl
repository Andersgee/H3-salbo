#!/usr/bin/env julia

include("hlt/halite.jl")
include("salboai/salboai.jl")

botname = length(ARGS) == 1 ? ARGS[1] : "salboai"

using Main.Salboai
using Dates

g = H.init()
me = H.me(g)
initwarn(string("warnlog-", now(), '_', me.id, ".txt"))

S = Salboai.init(g)

H.ready(botname)

while true
	turn = H.update_frame!(g)
	cmds = tick(S, g, turn)
	H.sendcommands(cmds)
end
