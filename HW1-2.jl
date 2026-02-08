using Plots
using LaTeXStrings

rect(x) = abs(x) >= 4 && abs(x) ≤ 5 ? 0.0 : 1.0

function dfdx(x, f, dx)
    (f(x+dx) - f(x-dx))/(2*dx)
end

function df2dx2(x, f, dx)
    (f(x+dx) - 2*f(x) + f(x-dx))/(dx^2)
end

N=100


sin_dxdy(x) = dfdx(x,sin, 2*pi/N)

sin_dx2dy2(x) = df2dx2(x,sin, 2*pi/N)

x1 = range(0, 2*pi, length=N)

x2 = range(0, 2*pi, length=1000)

plot(x1, rect.(x1))

# First derivative plot
p1 = plot(
    x1,
    [(x -> dfdx(x, x-> sin(x)*rect(x), 2*pi/N)).(x1)],
    title = string("First Derivative(N=",N,")"),
    label = L"\frac{d}{dx}(sin(x)*rect(x))")

plot!(
x2,
[(x-> sin(x)*rect(x)).(x2)];
title = string("First Derivative(N=",N,")"),
label = L"sin(x)*rect(x)")

# Second derivative plot
p2 = plot(
    x1,
    [(x -> df2dx2(x, x-> sin(x)*rect(x), 2*pi/N)).(x1)],
    title = string("Second Derivative(N=",N,")"),
    label = L"\frac{d^2}{dx^2}(sin(x)*rect(x))")

plot!(
x2,
[(x-> sin(x)*rect(x)).(x2)];
title = string("Second Derivative(N=",N,")"),
label = L"sin(x)*rect(x)")

display(p1)
display(p2)

    

