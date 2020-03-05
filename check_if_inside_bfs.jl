include("fractal_border.jl")
using Plots
using DataStructures

# Tired of writing
const indx = CartesianIndex

function get_grid()
    l = 4
    # int: extra resolution
    r = 2
    # lattice constant
    a = 1 / 4^l / r

    print("Start \n")
    fractal_border = get_koch_curve(l)
    # fractral is sym. => no need to check y-vals
    range = [min(fractal_border[1,:]...), max(fractal_border[1,:]...)]
    N = Int(ceil((range[2] - range[1]) / a)) + 1
    grid = reshape([0 for i=1:N^2], (N, N))

    function get_index(point)
        return indx(
            round(Int, (point[2] - range[1])/a + 1),
            round(Int, (point[1] - range[1])/a + 1))
    end
    
    function divide_index(index, r)
        return indx(round(Int, index[1] / r), round(Int, index[2] / r))
    end

    function fill_fractal_border!(grid, fractal_border)
        old_corner = get_index(fractal_border[:, 1])
        for i=2:size(fractal_border)[2]
            new_corner = get_index(fractal_border[:, i])
            step = divide_index(new_corner - old_corner, r)
            for j=1:r
                index = old_corner + step * (j - 1)
                grid[index] = 1
            end
            old_corner = new_corner
        end
    end

    function flood_fill!(grid)
        middle = indx(ceil(Int, N / 2), ceil(Int, N / 2))
        queue = Queue{indx}()
        index_around = [indx(1, 0), indx(0, 1), indx(-1, 0), indx(0, -1)]
        enqueue!(queue, middle)
        while !isempty(queue)
            current = dequeue!(queue)
            if grid[current] == 0
                grid[current] = 1
                for i in index_around
                    enqueue!(queue, current + indx(i))
        end end end end

    fill_fractal_border!(grid, fractal_border)
    flood_fill!(grid)

    x = LinRange(range[1], range[2], N)
    y = LinRange(range[1], range[2], N)
    plot!(fractal_border[1, :], fractal_border[2, :])
    heatmap!(x, y, grid)
    plot!(show = true)  
end

get_grid()