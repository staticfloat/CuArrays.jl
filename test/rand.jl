@testset "CURAND" begin

if !isdefined(CuArrays, :CURAND)
@warn "Not testing CURAND"
else
using CuArrays.CURAND
@info "Testing CURAND $(CURAND.version())"

CURAND.seed!()

# in-place
for (f,T) in ((rand!,Float32),
              (randn!,Float32),
              (rand_logn!,Float32),
              (rand_poisson!,Cuint)),
    d in (2, (2,2), (2,2,2))
    A = CuArray{T}(undef, d)
    f(A)
end

# out-of-place, with implicit type
for (f,T) in ((curand,Float32), (curandn,Float32), (curand_logn,Float32),
              (curand_poisson,Cuint),(rand,Float64), (randn,Float64)),
    args in ((2,), (2, 2))
    A = f(args...)
    @test eltype(A) == T
end

# out-of-place, with type specified
for (f,T) in ((curand,Float32), (curandn,Float32), (curand_logn,Float32),
              (curand,Float64), (curandn,Float64), (curand_logn,Float64),
              (curand_poisson,Cuint), (rand,Float32), (randn,Float32),
              (rand_logn,Float32), (rand,Float64), (randn,Float64),
              (rand_logn,Float64), (rand_poisson,Cuint)),
    args in ((T, 2), (T, 2, 2), (T, (2, 2)))
    A = f(args...)
    @test eltype(A) == T
end

# unsupported types that fall back to GPUArrays
for (f,T) in ((curand,Int64),),
    args in ((T, 2), (T, 2, 2), (T, (2, 2)))
    A = f(args...)
    @test eltype(A) == T
end
for (f,T) in ((rand!,Int64),),
    d in (2, (2,2), (2,2,2))
    A = CuArray{T}(undef, d)
    f(A)
end

@test_throws ErrorException randn!(CuArray{Cuint}(undef, 10)) 
@test_throws ErrorException rand_logn!(CuArray{Cuint}(undef, 10)) 
@test_throws ErrorException rand_poisson!(CuArray{Float64}(undef, 10)) 

end

end
