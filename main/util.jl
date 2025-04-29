using GLMakie
include("core.jl")

function tester(sheets)
    w = 10
    limit = 0.5
    gx=-w:(w/5):w; gy=gx; gz=gx; x = gx; z = gz;
    y = zeros(size(z))

    p = [[x[kx], y[ky], z[kz]] for kx in 1:length(gx) for ky in 1:length(gy) for kz in 1:length(gz)]
    
    B = repeat(zeros(3), 1, length(p))
    for sheet in sheets
        B += reshape(reduce(vcat,[Bsheet(sheet, p[i]) for i in 1:length(p)]), 3, length(p))
    end

    for k in 1:length(p)
        xs = [0,p[k][1]]; ys = [0,p[k][2]]; zs = [0,p[k][3]]
        xd = [0,B[1,k]]; yd = [0,B[2,k]]; zd = [0,B[3,k]]

        arrows!(ax,xs,ys,zs,xd,yd,zd,color=:red, arrowsize=0.03)
    end
    
    xlims!(ax, -10, 10)
    ylims!(ax, -10, 10)
    zlims!(ax, -10, 10)
 
end
