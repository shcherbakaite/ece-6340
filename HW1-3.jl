struct V
    id::Int
end

M =
[100  100   100   0    100  100  100;
 0    V(1)  100   0    100  V(9)  0;
 0    V(2)  100   100  100  V(8)  0;
 0    V(3)  V(4)  V(5) V(6) V(7)  0;
 0    0     0     0    0    0     0;];

function node_equation(i,j)
    R = zeros(10)

    v = M[i, j]
    R[v.id] = -4

    v_t = M[i+1, j]
    v_d = M[i-1, j]
    v_l = M[i, j-1]
    v_r = M[i, j+1]

    for v in [v_t, v_d, v_l, v_r] 
        if typeof(v) == V
            R[v.id] = 1
        else
            R[10] -= v
        end
    end

    return R
end

A = [node_equation(2,2)';
     node_equation(3,2)';
     node_equation(4,2)';
     node_equation(4,3)';
     node_equation(4,4)';
     node_equation(4,5)';
     node_equation(4,6)';
     node_equation(3,6)';
     node_equation(2,6)';]

b = A[:,10]
A = A[:,1:9]

x = A \ b

println(repr("text/plain", A))

println(A)

map(v ->
    if typeof(v) == V
        x[v.id]
    else
        v
    end
, M)

