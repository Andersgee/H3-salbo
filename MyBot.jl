#!/usr/bin/env julia

include("hlt/halite.jl")
include("salboai/salboai.jl")

using Main.Salboai
using Dates

g = H.init()
me = H.me(g)
initwarn(string("warnlog-", now(), '_', me.id, ".txt"))

Salboai.warmup()

H.ready("salboai")

while true
	turn = H.update_frame!(g)
	cmds = tick(g, turn)
	H.sendcommands(cmds)
end
