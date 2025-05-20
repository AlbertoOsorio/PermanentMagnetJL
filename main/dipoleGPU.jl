using CUDA
using PlotlyJS
using BenchmarkTools
using GPUArrays: @allowscalar

const μ0 = 4π * 1e-7  # ≈ 1.25663706e-6 T·m/A

function Bevaluate(u::CuArray, p::CuArray)
    p_hat = p ./ sqrt.(sum(p.^2; dims=1))
    B = μ0 .* (3 .* sum(u .* p_hat; dims=1) .* p_hat .- u) ./ (sqrt.(sum(p.^2; dims=1)).^3)
end

function drawDipole(u)
    w = 10
    gx = -w:w/10:w; gy = gx; gz = gx
    
    points_cpu = hcat([[x, y, z] for x in gx, y in gy, z in gz]...)
    points = cu(points_cpu)
    u_gpu = cu(u)

    B = Bevaluate(u_gpu, points)

    #@allowscalar begin
    #    plot(cone(x=points[1,:], y=points[2,:], z=points[3,:], u=B[1,:], v=B[2,:], w=B[3,:]))
    #end
end

@benchmark drawDipole([0,-5,0])