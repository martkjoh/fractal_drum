using SparseArrays
using Arpack
using Plots

include("check_if_inside_bfs.jl")

# Returns vec of indecies of non-zero elements of grid
function grid_to_vec(grid)
    N = size(grid)[1]
    M = sum(1 for i in grid if i > 0)
    vec_indx = Array{indx}(undef, M)
    for i=1:N, j=1:N 
        if grid[i, j] > 0
            vec_indx[grid[i, j]] = indx(i, j)
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
    
    stencil = [[0, 1., 0] [1, -4., 1] [0, 1., 0]]
    n = Int((size(stencil)[1] - 1) / 2)

    I = Array{Int}(undef, (4*n+1)*num_points)
    J = Array{Int}(undef, (4*n+1)*num_points)
    V = Array{Float64}(undef, (4*n+1)*num_points)

    print("Making laplacian w/ $num_points points\n")
    m = 0
    for i=1:num_points
        a = vec_indx[i] # Center point 
        for k=-n:n, l=-n:n
            p0 = indx(n+1+k, n+1+l) # where the point is in the stencil
            p1 = indx(k, l) # Where the point is in grid, relative point i
            if stencil[p0] != 0
                current = grid[a + p1] # Contribution to point a, from a+p1
                if current > 0
                    m += 1
                    I[m] = current
                    J[m] = i
                    V[m] = stencil[p0]
    end end end end

    return sparse(I[1:m], J[1:m], V[1:m]), vec_indx
end

function go()
    l = 4
    r = 2
    num_eigenvals = 8

    print("Making fractal\n")
    fractal_border = get_koch_curve(l)
    grid, range, N = get_grid(fractal_border, l, r)
    M = size(grid)[1]
    laplacian, vec_indx = get_laplacian(grid)

    M = size(laplacian)[1]

    print("Finding eigenvals \n")
    l, a = eigs(laplacian, nev = num_eigenvals, which=:SM)
    print("Plotting \n")
    k = Int(floor(N/200))
    M = Int(ceil(N/k))
    x = LinRange(range[1], range[2], M)
    for i=1:num_eigenvals
        c = vec_to_grid(a[:, i], vec_indx, N)
        heatmap(x, x, c[1:k:end, 1:k:end], color=:viridis)
        plot!(fractal_border[1, :], fractal_border[2, :], color=:black)
        
        savefig("figs/plot_$i.pdf")
    end
end

go()