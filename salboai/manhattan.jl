manhattandist(a,b) = sum(abs.(b-a))
manhattandist(a::CartesianIndex{2},b::CartesianIndex{2}) = abs(b[1]-a[1]) + abs(b[2]-a[2])

function manhattandistmatrices(m, origin)
    s = [x + y - 2 for y in 1:size(m,1), x in 1:size(m,2)]
    return ishiftorigin(cat(q1(s), q2(s), q3(s), q4(s), dims=3), origin)
end
