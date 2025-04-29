using LinearAlgebra
using GLMakie
using GeometryBasics: Point3f, GLTriangleFace
include("main/util.jl")

function drawSheet(ra,rb,ele) #drawSheet([0,-5,0],[0,5,0], 3pi/2) Sheet plana en xy con vector normal apuntando hacia +z
    middle = [(ra[i]+rb[i])/2 for i in 1:length(ra)]
    ra -= middle
    rb -= middle
    
    r_hat = rb/(norm(rb))
    if abs(r_hat[1]) < abs(r_hat[2]) && abs(r_hat[1]) < abs(r_hat[3])
        non_parallel = [1,0,0]
    elseif abs(r_hat[2]) < abs(r_hat[3])
        non_parallel = [0,1,0]
    else
        non_parallel = [0,0,1]
    end
    u1 = cross(r_hat, non_parallel); u1 /= norm(u1)
    u2 = cross(r_hat, u1); u2 /= norm(u2)
    nn = cos.(ele)*u1 + sin.(ele)*u2
    p_hat = cross(r_hat, nn); p_hat /= norm(p_hat)
    p = p_hat*norm(rb-ra)/2
    sp_dir = -2*p
    sheet = [ra, rb, nn, sp_dir]

    point1 = ra+p; p1 = Point3f(point1[1], point1[2], point1[3])
    point2 = ra-p; p2 = Point3f(point2[1], point2[2], point2[3])
    point3 = rb+p; p3 = Point3f(point3[1], point3[2], point3[3])
    point4 = rb-p; p4 = Point3f(point4[1], point4[2], point4[3])
    vertices = [p1, p2, p3, p4]
    faces = [
        GLTriangleFace(1, 2, 3),  
        GLTriangleFace(2, 4, 3)   
    ]

    x = [ra[1], rb[1]]; y = [ra[2], rb[2]]; z = [ra[3], rb[3]]
    xn = [0,nn[1]]; yn = [0,nn[2]]; zn = [0,nn[3]]
    xp = [0,p[1]]; yp = [0,p[2]]; zp = [0,p[3]]
    xe = [0,sp_dir[1]]; ye = [0,sp_dir[2]]; ze = [0,sp_dir[3]]

    fig = Figure()
    ax = Axis3(fig[1, 1], aspect=(1,1,1)) 
    lines!(ax, x, y, z, color=:lightgreen)                              #Line of current. From ra to rb
    lines!(ax, xn, yn, zn, color=:magenta)                              #Normal to the plane
    mesh!(ax, vertices, faces, color = :blue, transparency = true)      #Plane sheet
    scatter!(ax, ra[1], ra[2], ra[3], color=:red)                       #Ball point in ra
    arrows!(ax, xp, yp, zp, xe, ye, ze, color=:lightyellow, arrowsize=0.03)  #EasyAxis

    xlims!(ax, -10, 10)
    ylims!(ax, -10, 10)
    zlims!(ax, -10, 10)

    tester(sheet, fig, ax)

end

function drawSheetInteractive(ra, rb, ele)
   middle = [(ra[i] + rb[i]) / 2 for i in 1:length(ra)]
   ra -= middle
   rb -= middle

   r_hat = rb/norm(rb)
   if abs(r_hat[1]) < abs(r_hat[2]) && abs(r_hat[1]) < abs(r_hat[3])
       non_parallel = [1,0,0]
   elseif abs(r_hat[2]) < abs(r_hat[3])
       non_parallel = [0,1,0]
   else
       non_parallel = [0,0,1]
   end
   u1 = cross(r_hat, non_parallel); u1 /= norm(u1)
   u2 = cross(r_hat, u1); u2 /= norm(u2)

   ele_obs = Observable(ele)
   nn = @lift cos.($ele_obs)*u1 + sin.($ele_obs)*u2
   p_hat = @lift cross(r_hat, $nn); p_hat = @lift $p_hat/(norm($p_hat))
   p = @lift $p_hat*norm(rb-ra)/2
   sp_dir = @lift -2*$p

   point1 = @lift ra+$p; p1 = @lift Point3f($point1[1], $point1[2], $point1[3])
   point2 = @lift ra-$p; p2 = @lift Point3f($point2[1], $point2[2], $point2[3])
   point3 = @lift rb+$p; p3 = @lift Point3f($point3[1], $point3[2], $point3[3])
   point4 = @lift rb-$p; p4 = @lift Point3f($point4[1], $point4[2], $point4[3])
   vertices = @lift [$p1, $p2, $p3, $p4]
   faces = [
       GLTriangleFace(1, 2, 3),  
       GLTriangleFace(2, 4, 3)   
   ]

   x = [ra[1], rb[1]]; y = [ra[2], rb[2]]; z = [ra[3], rb[3]]
   xn = @lift [0, $nn[1]]; yn = @lift [0, $nn[2]]; zn = @lift [0, $nn[3]]
   xp = @lift [0, $p[1]]; yp = @lift [0, $p[2]]; zp = @lift [0, $p[3]]
   xe = @lift [0, $sp_dir[1]]; ye = @lift [0, $sp_dir[2]]; ze = @lift [0, $sp_dir[3]]

   fig = Figure()
   ax = Axis3(fig[1, 1], aspect = (1, 1, 1))
   lines!(ax, x, y, z, color = :lightgreen)
   lines!(ax, xn, yn, zn, color = :magenta)
   mesh!(ax, vertices, faces, color = :blue, transparency = true)
   scatter!(ax, ra[1], ra[2], ra[3], color=:red)
   arrows!(ax, xp, yp, zp, xe, ye, ze, color=:yellow, arrowsize=0.03)

   xlims!(ax, -10, 10)
   ylims!(ax, -10, 10)
   zlims!(ax, -10, 10)

   # Add a slider for ele
   slider = Slider(fig[2, 1], range = 0:0.01:2π, startvalue = ele)
   connect!(ele_obs, slider.value)
   title_obs = @lift "Angle (ele) = $(round($ele_obs, digits=2)) rad"
   ax.title[] = title_obs[]  
   fig

end