include("fractal_border.jl")
using Plots

# takes to lines in form of 2x2 matrices, where rows are start/end-points
# the lines will ALLWAYS be horizontal or vertical. We thus only need to check if:
# 1: they are parallel, and 2: the coordinate that changes DOES not change value
# is in the interval of the coresponding coordinate for the other line

const l_MAX = 2

function is_vertical(line)
    return Bool((line[2, 1] - line[2, 2]) == 0)
end

# Checks if a vertical and horizontal line cross
function orthogonal_lines_cross(vertical, horizontal)
    vertical_cross = (vertical[1, 1] - horizontal[1, 1]) * (vertical[1, 2] - horizontal[1, 1]) < 0
    horizontal_cross = (horizontal[2, 1] - vertical[2, 1]) * (horizontal[2, 2] - vertical[2, 1]) < 0 
    return vertical_cross && horizontal_cross
end

function lines_cross(line1, line2)
    vert1 = is_vertical(line1)
    vert2 = is_vertical(line2)
    # if the lines are parallel, they do not cross
    if !xor(vert1, vert2) return false end
    if vert1 return orthogonal_lines_cross(line1, line2) 
    else return orthogonal_lines_cross(line2, line1) 
    end
end

function lines_cross_fractal(line, fractal_border)
    old_point_fractal = fractal_border[:, 1]
    has_crossed = false
    for i in 2:size(fractal_border)[2]
        new_point_fractal = fractal_border[:, i]
        if lines_cross(line, [old_point_fractal new_point_fractal])
            has_crossed = true
            break
        end
        old_point_fractal = new_point_fractal
    end
    return has_crossed
end

function get_grid()
    # lattice constant
    a = 1 / 4^l_MAX
    fractal_border = get_koch_curve(l_MAX)
    # fractral is sym. => no need to check y-vals
    range = [min(fractal_border[1,:]...) - a/2, max(fractal_border[1,:]...) + a/2]
    N = Int(ceil((range[2] - range[1]) / a))
    grid = reshape([false for i=1:(N + 1)^2], (N + 1, N + 1))

    # Going trough the entier grid, from top left, row by row
    for i=1:N
        old_point_grid = [range[1], range[2]-(i-1)*a]
        grid[1, i] = false # Know first grid_point is outside
        for j=2:N
            new_point_grid = [range[1]+(j-1)*a, range[2]-(i-1)*a]            
            if lines_cross_fractal([old_point_grid new_point_grid], fractal_border)
                grid[j, i] = !grid[j - 1, i]
            else 
                grid[j, i] = grid[j - 1, i]
            end           
            old_point_grid = new_point_grid
        end
    end
    x = LinRange(range[1], range[2], N + 1)
    y = LinRange(range[1], range[2], N + 1)
    heatmap(x, y, grid)
    plot!(show = true)
end

get_grid()