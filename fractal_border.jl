# Code for creating the fractal border of the drum
# The fractal is saved as a 2:N matrix, where the columnvectors
# are the endpoints of the lines making up the fractal

# Number of points in a fractal corner
const KOCH_POINTS = 8
# The seed for the fractal
const X = [[0, 0.] [1, 0] [1, 1] [0, 1] [0, 0]]

# Applies the quadratic koch generator to a line
function koch_generator(x)
    forward = (x[:,2] - x[:,1]) / 4
    left = [0. -1; 1 0] * forward
    right = [0. 1; -1 0] * forward
    steps = [forward, left, forward, right, right, forward, left]
    
    points = Matrix{Float64}(undef, (2, KOCH_POINTS))
    points[:,1] = x[:,1]
    for i=1:KOCH_POINTS-1 points[:,i+1] = points[:,i] + steps[i] end
    
    return points
end

# Creates one level of the fracrtal, and calls itself
# recursively till it has reached leve 0
# ! Some of-by-one error in the fractal, last points are equal
function get_koch_curve(l, x0 = X)
    if l == 0 return x0 end

    n = size(x0)[2]
    x = Matrix{Float64}(undef, (2, KOCH_POINTS*n))
    for i in 1:n - 1
        x[:, (i-1)*KOCH_POINTS+1:i*KOCH_POINTS] = koch_generator([x0[:, i] x0[:, i+1]])
    end
    x[:, (n-1)*KOCH_POINTS+1:end] = koch_generator([x0[:, n] x0[:, 1]])
    
    return get_koch_curve(l - 1, x)
end
