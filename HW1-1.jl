using Plots
using LaTeXStrings

function dfdx(x, f, dx)
    (f(x+dx) - f(x-dx))/(2*dx)
end

# function dfdx(x, f, dx)
#     (f(x+dx) - f(x))/(dx)
# end

function df2dx2(x, f, dx)
    (f(x+dx) - 2*f(x) + f(x-dx))/(dx^2)
end

N=10

for N in [5,10,20,1000] 
    
    sin_dxdy(x) = dfdx(x,sin, 2*pi/N)

    sin_dx2dy2(x) = df2dx2(x,sin, 2*pi/N)

    x1 = range(0, 2*pi, length=N)

    x2 = range(0, 2*pi, length=1000)

    # First derivative plot
    p1 = plot(
        x1,
        [sin_dxdy.(x1)],
        title = string("First Derivative(N=",N,")"),
        label = L"\frac{d}{dx}(sin(x))",
        seriestype = :scatter,
        marker = :circle,
        markercolor = RGBA(1,1,1,0),   # or :none
        markerstrokecolor = :blue,
        markerstrokewidth = 1.5)

    plot!(
    x2,
    [cos.(x2)];
    title = string("First Derivative(N=",N,")"),
    label = L"cos(x)")

    # Second derivative plot
    p2 = plot(
        x1,
        [sin_dx2dy2.(x1)];
        title = string("Second Derivative(N=",N,")"),
        label = L"\frac{d^2}{dx^2}(sin(x))",
        seriestype = :scatter,
        marker = :circle,
        markercolor = RGBA(1,1,1,0),   # or :none
        markerstrokecolor = :blue,
        markerstrokewidth = 1.5)

    plot!(
    x2,
    [-sin.(x2)];
    title = string("Second Derivative(N=",N,")"),
    label = L"-sin(x)")

    display(p1)
    display(p2)

end
    