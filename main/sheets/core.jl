using LinearAlgebra

function Bsheet(sheet, r2)
    Bout = zeros(3)
    ra = sheet[1]; rb = sheet[2]; nn = sheet[3]

    alpha = 1
    Br = 1.47
        
    pp = alpha * cross(rb - ra, nn)
    delta_r = r2 - ra
    A = dot(delta_r, delta_r)
    B_val = dot(delta_r, rb - ra)
    C = dot(rb - ra, rb - ra)
    D = dot(delta_r, pp)        
    a1 = A * C - 2 * B_val * C + C^2
    b1 = -2 * C * D
    c1 = alpha^2 * C^2
    p1 = -(C - B_val)^2
        
    a2 = A * C
    b2 = -2 * C * D
    c2 = alpha^2 * C^2
    p2 = -B_val^2
        
    println(a1, b1, c1, p1)
    println(a2, b2, c2, p2)
    
end

function integral_GR2284(AA, BB, a, b, c, p)
    disc = p * (b^2 - 4 * (a + p) * c)
    Ru = a + b * 0.5 + c * 0.25
    Rl = a - b * 0.5 + c * 0.25
    
    # Compute I1
    if abs(p) < 1e-9
        I1 = 0.0
    elseif p > 0
        sqrt_p = sqrt(p)
        sqrt_Ru_p = sqrt(Ru / p)
        sqrt_Rl_p = sqrt(Rl / p)
        I1 = (atan(sqrt_Ru_p) - atan(sqrt_Rl_p)) / sqrt_p
    else
        sqrt_neg_p = sqrt(-p)
        sqrt_Ru = sqrt(Ru)
        sqrt_Rl = sqrt(Rl)
        tmpu = log(Complex((sqrt_neg_p - sqrt_Ru) / (sqrt_neg_p + sqrt_Ru)))
        tmpl = log(Complex((sqrt_neg_p - sqrt_Rl) / (sqrt_neg_p + sqrt_Rl)))
        I1 = 0.5 * (tmpu - tmpl) / sqrt_neg_p
    end
    
    # Compute I2
    if disc > 0
        sqrt_disc_part = sqrt(p / (b^2 - 4 * (a + p) * c))
        term1 = sqrt_disc_part * (b + c) / sqrt(Ru)
        term2 = sqrt_disc_part * (b - c) / sqrt(Rl)
        I2 = -atan(term1) + atan(term2)
    else
        if p > 0
            sqrt_part1 = sqrt(4 * (a + p) * c - b^2)
            tmp1u = sqrt_part1 * sqrt(Ru)
            tmp2u = sqrt(p) * (b + c)
            tmp1l = sqrt_part1 * sqrt(Rl)
            tmp2l = sqrt(p) * (b - c)
            logu = log(Complex((tmp1u + tmp2u) / (tmp1u - tmp2u)))
            logl = log(Complex((tmp1l + tmp2l) / (tmp1l - tmp2l)))
            I2 = (0.5 / im) * (logu - logl)
        else
            sqrt_part2 = sqrt(Complex(b^2 - 4 * (a + p) * c))
            tmp1u = sqrt_part2 * sqrt(Ru)
            tmp2u = sqrt(-p) * (b + c)
            tmp1l = sqrt_part2 * sqrt(Rl)
            tmp2l = sqrt(-p) * (b - c)
            logu = log(Complex((tmp1u - tmp2u) / (tmp1u + tmp2u)))
            logl = log(Complex((tmp1l - tmp2l) / (tmp1l + tmp2l)))
            I2 = (0.5 / im) * (logu - logl)
            if isnan(I2)
                I2 = 0.0
            end
        end
    end
    I2 = -I2
    
    # Compute output
    if abs(I2) < 1e-9
        out = AA * I1 / c
    else
        denominator = sqrt(c^2 * disc)
        out = (AA * I1 / c) + ((2 * BB * c - AA * b) * I2) / denominator
    end
    return real(out)
end