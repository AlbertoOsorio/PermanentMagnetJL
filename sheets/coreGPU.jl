using CUDA
using LinearAlgebra
using Distributions, Random

const alpha = 1
const Br = 1.47

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

function mc(N::Int, ra::CuArray, rb::CuArray, pp::CuArray, r2::CuArray; batch_size=2^18)
    C = sum((rb .- ra).^2; dims=1)
    # Initialize B_sum as CuArray (GPU memory)
    B_sum = zeros(eltype(C), 3, size(r2,2), size(ra,3), 1) 
    T = eltype(ra)
    total_samples = N

    while N > 0
        current_batch = min(batch_size, N)
        N -= current_batch

        # Generate random numbers directly on GPU
        t = CUDA.rand(T, 1, 1, 1, current_batch)          # t ∈ [0,1)
        s = (CUDA.rand(T, 1, 1, 1, current_batch) .- T(0.5))  # s ∈ [-0.5,0.5)

        # Compute and accumulate on GPU
        B_sum .+= sum(b(t, s, ra, rb, pp, r2); dims=4)
    end

    return (B_sum .* sqrt.(C)) ./ total_samples
end

function BfSheet(ra_cpu, rb_cpu, nn_cpu, r2_cpu)
    r_a=cu(ra_cpu); r_b=cu(rb_cpu); n_n=cu(nn_cpu); r_2=cu(r2_cpu)
    p_p = alpha .* crossShift(r_b - r_a, n_n)

    ra = reshape(r_a, 3, 1, :, 1) 
    rb = reshape(r_b, 3, 1, :, 1)
    nn = reshape(n_n, 3, 1, :, 1)
    pp = reshape(p_p, 3, 1, :, 1)
    r2 = reshape(r_2, 3, :, 1, 1)

    B = sum(mc(100, ra, rb, pp, r2); dims=3)
    return dropdims(dropdims(B; dims=4); dims=3)
end