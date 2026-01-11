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

sin_dxdy(x) = dfdx(x,sin, 2*pi/N)

sin_dx2dy2(x) = df2dx2(x,sin, 2*pi/N)

x = range(0, 2*pi, length=N)

p1 = plot(
    x,
    [sin_dxdy.(x), cos.(x)];
    title = "First Derivative",
    label = [L"d/dx(sin(x))" L"cos(x)"]
)

p2 = plot(
    x,
    [sin_dx2dy2.(x), -sin.(x)];
    title = "Second Derivative",
    label = [L"d^2/d^2x(sin(x))" L"-sin(x)"]
)

plot(p1, p2, layout = (2, 1))

plot(
    x,
    [sin_dxdy.(x)];
    title = "First Derivative",
    label = [L"d/dx(sin(x))"])

x = range(0, 2*pi, length=1000)

plot!(
x,
[cos.(x)];
title = "First Derivative",
label = [L"d/dx(sin(x))"])