# Utilities for graphing
# Creation: Nov 2024
# Author: Pablo Irarrazaval
#
# Version 3 (Mar 2025)
# Version 4 (May 2025, using Makie)

function draw3Dmagnet(mag)
    vertices = [
                Point3f(mag.c .- mag.rw1 .- mag.rw2),
                Point3f(mag.c .- mag.rw1 .+ mag.rw2),
                Point3f(mag.c .+ mag.rw1 .+ mag.rw2),
                Point3f(mag.c .+ mag.rw1 .- mag.rw2),
                Point3f(mag.c .+ mag.rh .- mag.rw1 .- mag.rw2),
                Point3f(mag.c .+ mag.rh .- mag.rw1 .+ mag.rw2),
                Point3f(mag.c .+ mag.rh .+ mag.rw1 .+ mag.rw2),
                Point3f(mag.c .+ mag.rh .+ mag.rw1 .- mag.rw2),
                Point3f(mag.c .- mag.rw1 .- mag.rw2),
                Point3f(mag.c .- mag.rw1 .+ mag.rw2),
                Point3f(mag.c .+ mag.rw1 .+ mag.rw2),
                Point3f(mag.c .+ mag.rw1 .- mag.rw2),
                Point3f(mag.c .- mag.rh .- mag.rw1 .- mag.rw2),
                Point3f(mag.c .- mag.rh .- mag.rw1 .+ mag.rw2),
                Point3f(mag.c .- mag.rh .+ mag.rw1 .+ mag.rw2),
                Point3f(mag.c .- mag.rh .+ mag.rw1 .- mag.rw2)
                ]

    faces = [5 8 7; 7 6 5] # z=1
    faces = [faces; 2 6 3; 6 7 3] # y=1
    faces = [faces; 4 8 5; 4 5 1] # y=0
    faces = [faces; 1 5 6; 1 6 2] # x=0
    faces = [faces; 7 8 4; 4 3 7] # x=1
    faces = [faces; faces .+ 8]

    reds = [:red for i in 1:8]
    blues = [:blue for i in 1:8]
    cs = [reds;blues]

    return vertices,faces,cs
end

function draw3DmagnetOld(mag)

    # The 12 points: ABCD will be the z=0, abcd the z<0, and αβγδ the z>0
    A = 0
    B = 1
    C = 2
    D = 3
    a = 4
    b = 5
    c = 6
    d = 7
    α = 8
    β = 9
    γ = 10
    δ = 11
    coord = hcat(reshape(mag.c .- mag.rw1 .- mag.rw2,(3,1)),
            reshape(mag.c .- mag.rw1 .+ mag.rw2,(3,1)),
            reshape(mag.c .+ mag.rw1 .+ mag.rw2,(3,1)),
            reshape(mag.c .+ mag.rw1 .- mag.rw2,(3,1)),
            reshape(mag.c .- mag.rh .- mag.rw1 .- mag.rw2,(3,1)),
            reshape(mag.c .- mag.rh .- mag.rw1 .+ mag.rw2,(3,1)),
            reshape(mag.c .- mag.rh .+ mag.rw1 .+ mag.rw2,(3,1)),
            reshape(mag.c .- mag.rh .+ mag.rw1 .- mag.rw2,(3,1)),
            reshape(mag.c .+ mag.rh .- mag.rw1 .- mag.rw2,(3,1)),
            reshape(mag.c .+ mag.rh .- mag.rw1 .+ mag.rw2,(3,1)),
            reshape(mag.c .+ mag.rh .+ mag.rw1 .+ mag.rw2,(3,1)),
            reshape(mag.c .+ mag.rh .+ mag.rw1 .- mag.rw2,(3,1))
            )
    xx = coord[1,:]
    yy = coord[2,:]
    zz = coord[3,:]
    # sides ABab BCbc CDcd DAda abcd ABαβ BCβγ CDγδ DAδα αβγδ
    ii =   [A,b, B,c, C,d, D,a, a,c, A,A, B,B, C,C, D,D, α,α]
    jj =   [B,a, C,b, D,c, A,d, b,d, β,α, γ,β, δ,γ, α,δ, γ,δ]
    kk =   [b,A, c,B, d,C, a,D, c,a, B,β, C,γ, D,δ, A,α, β,γ]
    
    facecolors = repeat(["rgb(200, 0, 0)", "rgb(0, 0, 200)"],inner=[10])
    
    t = mesh3d(x=xx,y=yy,z=zz,i=ii,j=jj,k=kk,facecolor=facecolors)
    
    return t
    
end