using PlotlyJS
include("core.jl")

function drawB(sheets)
    w = 10
    limit = 0.5
    gx=-w:(w/4):w; gy=gx; gz=gx; x = gx; z = gz;
    y = gy #zeros(size(z))
    p = reshape(reduce(vcat,[[x[kx], y[ky], z[kz]] for kx in 1:length(gx) for ky in 1:length(gy) for kz in 1:length(gz)]), 3, length(gx)^3)

    B = repeat(zeros(3), 1, length(p[1,:]))
    B = sum([reshape(reduce(vcat,[Bsheet(sheet, p[:,i]) for i in 1:length(p[1,:])]), 3, length(p[1,:])) for sheet in sheets])

    return cone(x=p[1,:], y=p[2,:], z=p[3,:], u=B[1,:], v=B[2,:], w=B[3,:])
end
