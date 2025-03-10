using GLMakie
include("core_qwq.jl")

function tester(sheet, fig, ax)
    w = 10
    limit = 0.5
    gridpoints = -w:(w/5):w
    gx=gridpoints; gz=gx; x = gx; z = gz
    XX = repeat(x', length(z), 1)
    ZZ = repeat(z, 1, length(x))    
    YY = zeros(size(ZZ))
    BX = zeros(Float64, size(XX))  
    BY = zeros(Float64, size(XX))  
    BZ = zeros(Float64, size(ZZ))  


    for kx in 1:length(gx)
        for kz in 1:length(gz)
            xx=XX[kx,kz]; yy=0; zz=ZZ[kx,kz]
            r2=[xx,yy,zz]
            B=Bsheet(sheet,r2)
            BX[kx,kz]=B[1]; BY[kx,kz]=B[2]; BZ[kx,kz]=B[3]
            
            xs = [0,xx]; ys = [0,yy]; zs = [0,zz]
            xd = [0,B[1]]; yd = [0,B[2]]; zd = [0,B[3]]

            arrows!(ax,xs,ys,zs,xd,yd,zd,color=:red, arrowsize=0.03)
            #println(B)
        end
    end
    
    BX[abs.(BX) .> limit] .= NaN
    BY[abs.(BY) .> limit] .= NaN
    BZ[abs.(BZ) .> limit] .= NaN

    #arrows!(XX[1],YY[1],ZZ[1],BX[1],BY[1],BZ[1],color=:red, arrowsize=0.03)
    fig
end
