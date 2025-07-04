# Create magnets and array of magnets
# Creation: Nov 2024
# Author: Pablo Irarrazaval
#
# Version 3 (Mar 2025)

# Makes one ring (return list of magnets)
function makeRing(Ncubes,r,wz,wx,z) # not passing Br yet
    Magnet = Array{MagnetT, 1}(undef, 0)
    for n in 0:Ncubes-1
        # Position and directions
        pos_angle = 2*π*n/Ncubes+π/2
        dir_angle = 4*π*n/Ncubes+π/2
        c = [r*cos(pos_angle); r*sin(pos_angle); z]
        rh = [cos(dir_angle); sin(dir_angle); 0.].*wz/2.
        rw1 = [-sin(dir_angle); cos(dir_angle); 0.].*wx/2.
        rw2 = cross(rh./sqrt(sum(rh.^2)),rw1)
        # Computes the four sheets
        nrw1 = rw1./sqrt(sum(rw1.^2))
        nrw2 = rw2./sqrt(sum(rw2.^2))
        alpha = norm(rh)/norm(rw1)
        # The 4 sheets
        ra1 = c .+ rw1 .- rw2
        rb1 = c .+ rw1 .+ rw2
        nn1 = nrw1           # not sure if direction is correct
        ra2 = rb1
        rb2 = c .- rw1 .+ rw2
        nn2 = nrw2           # not sure if direction is correct
        ra3 = rb2
        rb3 = c .- rw1 .- rw2
        nn3 = -nrw1           # not sure if direction is correct
        ra4 = rb3
        rb4 = ra1
        nn4 = -nrw2           # not sure if direction is correct

        ra = stack([ra1, ra2, ra3, ra4])
        rb = stack([rb1, rb2, rb3, rb4])
        nn = stack([nn1, nn2, nn3, nn4])
        misc = [alpha, Br]

        #sh = [ra1' rb1' nn1' alpha Br;
        #ra2' rb2' nn2' alpha Br;
        #ra3' rb3' nn3' alpha Br;
        #ra4' rb4' nn4' alpha Br]

        push!(Magnet,MagnetT(c,rh,rw1,rw2,ra,rb,nn,misc))
    end
    return Magnet
end

# logic value indicating whether r is inside any of the magnets (less than tol away)
function inMagnets(mag, r, tol)

    out = false
    for n in eachindex(mag)
        out = out || belongsto(mag[n], r, tol)
    end

    return out

end

# logic value indicating whether r2 is inside the magnet mag (less than tol away)
function belongsto(mag, r2, tol)

    out = true
    r = r2 .- mag.c
    nn = norm(mag.rh)
    out *= abs(dot(r,mag.rh)/nn) < nn + tol
    nn = norm(mag.rw1)
    out *= abs(dot(r,mag.rw1)/nn) < nn + tol
    nn = norm(mag.rw2)
    out *= abs(dot(r,mag.rw2)/nn) < nn + tol

    return out

end