using GLMakie
include("core_dipole.jl")

function drawDipole(u, val)
    w = 3
    limit = 0.5
    gx= -w:(w/3):w; gy=gx; gz=gx; x = gx; z = gz 
    y = gy #zeros(size(z))

    xp = [0, u[1]]; yp = [0, u[2]]; zp = [0, u[3]]

    lines!(ax, xp, yp, zp, color=:green)

    p = [[x[kx], y[ky], z[kz]] for kx in 1:length(gx) for ky in 1:length(gy) for kz in 1:length(gz)]
    B = [Bevaluate(u, p[i], val) for i in 1:length(p)]
    
    for k in 1:length(B)
        xs = [0,p[k][1]]; ys = [0,p[k][2]]; zs = [0,p[k][3]]
        xd = [0,B[k][1]]; yd = [0,B[k][2]]; zd = [0,B[k][3]]

        arrows!(ax,xs,ys,zs,xd,yd,zd,color=:red, arrowsize=0.03)
    end

    xlims!(ax, -10, 10)
    ylims!(ax, -10, 10)
    zlims!(ax, -10, 10)
     
end