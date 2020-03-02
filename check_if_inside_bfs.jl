include("fractal_border.jl")
using Plots

function get_grid()
    l = 3
    # int: extra resolution
    r = 4
    # lattice constant
    a = 1 / 4^l / r
    fractal_border = get_koch_curve(l)
    # fractral is sym. => no need to check y-vals
    range = [min(fractal_border[1,:]...), max(fractal_border[1,:]...)]
    N = Int(ceil((range[2] - range[1]) / a)) + 1
    grid = reshape([false for i=1:N^2], (N, N))

    function get_index(point)
        return CartesianIndex(
            round(Int, (point[2] - range[1])/a + 1),
            round(Int, (point[1] - range[1])/a + 1))
    end
    
    function divide_index(index, r)
        return CartesianIndex(round(Int, index[1] / r), round(Int, index[2] / r))
    end

    function fill_fractal_border!(grid, fractal_border)
        old_corner = get_index(fractal_border[:, 1])
        for i=2:size(fractal_border)[2]
            new_corner = get_index(fractal_border[:, i])
            step = divide_index(new_corner - old_corner, r)
            for j=1:r
                index = old_corner + step * (j - 1)
                grid[index] = true
            end
            old_corner = new_corner
        end
    end

    fill_fractal_border!(grid, fractal_border)
    index = CartesianIndex(ceil(Int, N / 2), ceil(Int, N / 2))
    # TODO: breadth-first search, which colors all points inside fractal true

    x = LinRange(range[1], range[2], N)
    y = LinRange(range[1], range[2], N)
    heatmap(x, y, grid)
    plot!(fractal_border[1, :], fractal_border[2, :])
    plot!(show = true)
end

get_grid()