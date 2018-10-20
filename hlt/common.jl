str2ints(s) = parse.(Int, split(s))

readnlines(io::IO, n::Int) = (readline(io) for _ in 1:n)
