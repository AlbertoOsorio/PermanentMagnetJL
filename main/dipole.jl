using PlotlyJS
using LinearAlgebra
using BenchmarkTools

const μ0 = 4π * 1e-7  # ≈ 1.25663706e-6 T·m/A

function Bevaluate(u, p) # donde u es un vector en z y p el punto donde evaluamos el cambo magnetico
    p_hat = p/(norm(p))
    B = ((dot(u, p_hat)*p_hat*3)-u)*(μ0/(4* pi *(norm(p)^3)))
    return B
end

function drawDipole(u)
    w = 10
    limit = 0.5
    gx= -w:w/10:w; gy=gx; gz=gx; x = gx; z = gz 
    y = gy #zeros(size(z))

    p = [[x[kx], y[ky], z[kz]] for kx in 1:length(gx) for ky in 1:length(gy) for kz in 1:length(gz)]
    B = [Bevaluate(u, p[i]) for i in 1:length(p)]

    #plot(cone(x=[k[1] for k in p], y=[k[2] for k in p], z=[k[3] for k in p],
    #            u=[k[1] for k in B], v=[k[2] for k in B], w=[k[3] for k in B]))
end

@benchmark drawDipole([0,-5,0])