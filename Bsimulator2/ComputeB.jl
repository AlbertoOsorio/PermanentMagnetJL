using CUDA
using LinearAlgebra
using Distributions, Random

function crossShift(a, b)
    ashift = circshift(a, [-1]); ashift2 = circshift(a, [-2])
    bshift = circshift(b, [-2]); bshift2 = circshift(b, [-1])
    return ashift.*bshift - ashift2.*bshift2;
end

function b(t, s, ra, rb, pp, r2)
    A = sum((r2 .- ra .- s .* pp).^2; dims=1)
    B = sum((r2 .- ra .- s .* pp) .* (rb - ra) ; dims=1)
    C = sum((rb .- ra).^2 ; dims=1)
    return crossShift((rb - ra), (r2 .- ra .- s .* pp)) ./ (A .- 2*B .* t .+ C .* t).^(3/2)
end

function mc(N, ra, rb, pp, r2)
    dist_t = Uniform(0, 1)     ; tr = rand(dist_t, N); t = cu(reshape(tr, 1, 1, 1, :))
    dist_s = Uniform(-1/2, 1/2); sr = rand(dist_s, N); s = cu(reshape(sr, 1, 1, 1, :))
    B = sum((b(t, s, ra, rb, pp, r2)); dims=4) ./ N
end

function computeB(mag, p)
    r_a=cu(mag.ra); r_b=cu(mag.rb); n_n=cu(mag.nn); r_2=cu(p)

    p_p = alpha .* crossShift(r_b - r_a, n_n)

    ra = reshape(r_a, 3, 1, :, 1) 
    rb = reshape(r_b, 3, 1, :, 1)
    nn = reshape(n_n, 3, 1, :, 1)
    pp = reshape(p_p, 3, 1, :, 1)
    r2 = reshape(r_2, 3, :, 1, 1)


    B = sum(mc(80, ra, rb, pp, r2); dims=3)
    return dropdims(dropdims(B; dims=4); dims=3)
end