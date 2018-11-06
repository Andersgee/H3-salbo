include("../../hlt/halite.jl")
include("../salboai.jl")

using Test

using Random
Random.seed!(0)

CI(x...) = CartesianIndex(x...)

m = zeros(Int, 5,5)
m[3,3] = 1
m[4,5] = 1
@test Salboai.localmaxima2(m) == [CI(3,3), CI(4,5)]

a = Salboai.diamondfilter(m, 1)
@test Salboai.localmaxima2(a) == [CI(3,2), CI(2,3)]

cands = Salboai.dropoffcands(H.WrappedMatrix(m), [CI(3,3)], 1)
@test cands == [CI(4,5)]


m = fill(50, 32, 32)
for i in 1:100
    m[rand(1:32), rand(1:32)] = rand(100:1000)
end
k = 5
n = 2k+1
m = DSP.conv2(ones(n)/n, ones(n)/n, collect(Float64, m))[1+k:end-k, 1+k:end-k]
m = H.WrappedMatrix(round.(Int, m))
m

dropoff_current = [CI(16,8)]
dropoff_radius = 20
dropoff_cands = Salboai.dropoffcands(m, dropoff_current, dropoff_radius)
@test dropoff_cands == [CI(1,2), CI(22,23)]
@test dropoff_radius < Salboai.manhattandist(size(m), cands...)
