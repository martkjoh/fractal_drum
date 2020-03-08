using SparseArrays
using Arpack
using Plots

include("check_if_inside_bfs.jl")

function get_laplacian()

    grid, r = get_grid()
    N = size(grid)[1]
    u_indecies = indx[]
    for i=1:N, j=1:N if grid[j, i] != 0 push!(u_indecies, indx(i, j)) end end
    num_points = size(u_indecies)[1]
    I = Array{Int}(undef, 5*num_points)
    J = Array{Int}(undef, 5*num_points)
    V = Array{Float32}(undef, 5*num_points)
    stencil = [[0, 1., 0] [1, -4., 1] [0, 1., 0]]
    n = Int((size(stencil)[1] - 1) / 2)
    
    print("Making laplacian\n")
    print("points: ", num_points, "\n")
    m = 0
    for i=1:num_points
        a = u_indecies[i]
        for k=-n:n, l=-n:n
            p0 = indx(n+1+k, n+1+l) # where the point is in the stencil
            p1 = indx(k, l) # Where the point is in grid, relative point i
            if stencil[p0] != 0
                current = findfirst(isequal(a + p1), u_indecies)
                if current != nothing
                    m += 1
                    I[m] = current
                    J[m] = i
                    V[m] = stencil[p0]
    end end end end

    print("making sparse\n")
    return sparse(I[1:m], J[1:m], V[1:m], m, m), u_indecies, r
end

function recreate_grid(u, u_indecies)
    N = maximum([i[1] for i in u_indecies])
    M = size(u_indecies)[1]
    grid = zeros((N, N))
    for i = 1:M
        grid[u_indecies[i]] = u[i]
    end
    return grid
end

laplacian, u_indecies, r = get_laplacian()

print("Finding eigenvals \n")
b = 5
l, a = eigs(laplacian, nev = b)

print("Plotting \n")
N = size(recreate_grid(a[:, 1], u_indecies))[1]
x = LinRange(r[1], r[2], N)
y = LinRange(r[1], r[2], N)

for i=1:b
    c = recreate_grid(a[:, i], u_indecies)
    heatmap(x, y, c)
    savefig("plot_$i")
end
