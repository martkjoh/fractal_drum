using SparseArrays
using Arpack
using Plots

include("check_if_inside_bfs.jl")

# Returns vec of indecies of non-zero elements of grid
function grid_to_vec(grid)
    N = size(grid)[1]
    vec_indx = indx[]
    for i=1:N, j=1:N 
        if grid[i, j] == 1
            push!(vec_indx, indx(i, j))
    end end
    return vec_indx
end

function vec_to_grid(vec, vec_indx, N)
    grid = zeros((N, N))
    M = size(vec_indx)[1]
    for i = 1:M
        grid[vec_indx[i]] = vec[i]
    end
    return grid
end

function get_laplacian(grid)
    vec_indx = grid_to_vec(grid)
    num_points = size(vec_indx)[1]
    N = size(grid)[1]
    
    stencil = [[0, 1., 0] [1, -4., 1] [0, 1., 0]]
    n = Int((size(stencil)[1] - 1) / 2)
    I = Array{Int}(undef, (4*n+1)*num_points)
    J = Array{Int}(undef, (4*n+1)*num_points)
    V = Array{Float64}(undef, (4*n+1)*num_points)
    m = 0

    print("Making laplacian w/ $num_points points\n")
    for i=1:num_points
        a = vec_indx[i]
        for k=-n:n, l=-n:n
            p0 = indx(n+1+k, n+1+l) # where the point is in the stencil
            p1 = indx(k, l) # Where the point is in grid, relative point i
            if stencil[p0] != 0
                search_range = max(1, i-N):min(i+N, num_points)
                current = findfirst(isequal(a + p1), vec_indx[search_range])
                if current != nothing
                    m += 1
                    I[m] = current+search_range[1]-1
                    J[m] = i
                    V[m] = stencil[p0]
    end end end end
    return sparse(I[1:m], J[1:m], V[1:m]), vec_indx
end

function go()
    l = 3
    b = 5

    print("Making fractal\n")
    fractal_border = get_koch_curve(l)
    grid, range, N = get_grid(fractal_border, l, 2)
    laplacian, vec_indx = get_laplacian(grid)

    print("Finding eigenvals \n")
    l, a = eigs(laplacian, nev = b, which=:SM)

    print("Plotting \n")
    M = size(laplacian)[1]
    print(M)
    heatmap(1:M, 1:M, Matrix(laplacian))
    plot!(size = (4000, 3000))
    savefig("asgfasg")

    x = LinRange(range[1], range[2], N)
    for i=1:b
        c = vec_to_grid(a[:, i], vec_indx, N)
        heatmap(x, x, c)
        plot!(fractal_border[1, :], fractal_border[2, :], color="black")
        plot!(size = (4000, 3000))
        savefig("plot_$i")
    end
end

go()