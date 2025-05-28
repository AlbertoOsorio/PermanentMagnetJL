using CUDA
using LinearAlgebra

const alpha = 1
const Br = 1.47


@inline function gpu_cross(a::NTuple{3, Float32}, b::NTuple{3, Float32})::NTuple{3, Float32}
    ax, ay, az = a
    bx, by, bz = b
    return cu(
        ay * bz - az * by,
        az * bx - ax * bz,
        ax * by - ay * bx,
    )
end



function BsheetGPU(sheet, r2)
    ra = cu(sheet[1]); rb = cu(sheet[2]); nn = cu(sheet[3])

    pp = alpha .* gpu_cross.(rb.-ra, nn)
    delta_r = r2 .- ra
    A = sum(delta_r.^2; dims=1)
    B_val = sum(delta_r .* rb-ra ; dims=1)
    C = sum((rb.-ra).^2 ; dims=1)
    D = sum(delta_r .* pp ; dims=1)

    a1 = A .* C .- 2 .* B_val .* C .+ C.^2
    b1 = -2 .* C .* D
    c1 = alpha^2 .* C.^2
    p1 = -(C .- B_val).^2
    
    a2 = A .* C
    b2 = -2 .* C .* D
    c2 = alpha^2 .* C.^2
    p2 = -B_val.^2

    println(a1, b1, c1, p1)
    println(a2, b2, c2, p2)

end


