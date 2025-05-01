using PlotlyJS
include("core_dipole.jl")

function drawDipole(u, val)
    w = 3
    limit = 0.5
    gx= -w:(w/3):w; gy=gx; gz=gx; x = gx; z = gz 
    y = gy #zeros(size(z))

    p = [[x[kx], y[ky], z[kz]] for kx in 1:length(gx) for ky in 1:length(gy) for kz in 1:length(gz)]
    B = [Bevaluate(u, p[i], val) for i in 1:length(p)]

    plot(cone(x=[k[1] for k in p], y=[k[2] for k in p], z=[k[3] for k in p],
                u=[k[1] for k in B], v=[k[2] for k in B], w=[k[3] for k in B]))
end