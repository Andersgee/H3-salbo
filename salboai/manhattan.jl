manhattandist(a,b) = sum(abs.(b-a))

function manhattandistmatrices(m, origin)
    s = [x + y - 2 for y in 1:size(m,1), x in 1:size(m,2)]
    return ishiftorigin(cat(q1(s), q2(s), q3(s), q4(s), dims=3), origin)
end
