struct V
id::Int
end
# Hollow conductor diagram
M =
[100 100 100 0 100 100 100;
0 V(1) 100 0 100 V(9) 0;
0 V(2) 100 100 100 V(8) 0;
0 V(3) V(4) V(5) V(6) V(7) 0;
0 0 0 0 0 0 0;];
# Construct equation for a node
function node_equation(i,j)
R = zeros(10)