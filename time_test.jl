# Place to check the speed of operations

const N = 10000

vec_vec = Array{Array{Float64}}(undef, N)
for i in 1:N vec_vec[i] = zeros(N) end
matrix = Matrix{Float64}(undef, (N, N))

function vecTest()
    for i=1:N
        vec_vec[i] .+= 1
    end
end

function matTest()
    matrix .+= 1
end

@time matTest()