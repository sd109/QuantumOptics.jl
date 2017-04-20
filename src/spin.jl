module spin

import Base.==

using ..bases, ..states, ..operators, ..operators_sparse

export SpinBasis, sigmax, sigmay, sigmaz, sigmap, sigmam, spinup, spindown


"""
    SpinBasis(n)

Basis for spin-n particles.

The basis can be created for arbitrary spinnumbers by using a rational number,
e.g. `SpinBasis(3//2)`. The Pauli operators are defined for all possible
spin numbers.
"""
type SpinBasis <: Basis
    shape::Vector{Int}
    spinnumber::Rational{Int}
    function SpinBasis(spinnumber::Rational{Int})
        @assert den(spinnumber) == 2 || den(spinnumber) == 1
        @assert num(spinnumber) > 0
        new([num(spinnumber*2 + 1)], spinnumber)
    end
end
SpinBasis(spinnumber::Int) = SpinBasis(convert(Rational{Int}, spinnumber))

==(b1::SpinBasis, b2::SpinBasis) = b1.spinnumber==b2.spinnumber

"""
    sigmax(b::SpinBasis)

Pauli ``σ_x`` operator for the given Spin basis.
"""
function sigmax(b::SpinBasis)
    N = num(b.spinnumber*2 + 1)
    diag = Complex128[complex(sqrt(real((b.spinnumber + 1)*2*a - a*(a+1)))) for a=1:num(2*b.spinnumber)]
    data = spdiagm(diag, 1, N, N) + spdiagm(diag, -1, N, N)
    SparseOperator(b, data)
end

"""
    sigmay(b::SpinBasis)

Pauli ``σ_y`` operator for the given Spin basis.
"""
function sigmay(b::SpinBasis)
    N = num(b.spinnumber*2 + 1)
    diag = Complex128[1im*complex(sqrt(real((b.spinnumber + 1)*2*a - a*(a+1)))) for a=1:num(2*b.spinnumber)]
    data = spdiagm(diag, -1, N, N) - spdiagm(diag, 1, N, N)
    SparseOperator(b, data)
end

"""
    sigmaz(b::SpinBasis)

Pauli ``σ_z`` operator for the given Spin basis.
"""
function sigmaz(b::SpinBasis)
    N = num(b.spinnumber*2 + 1)
    diag = Complex128[complex(2*m) for m=b.spinnumber:-1:-b.spinnumber]
    data = spdiagm(diag, 0, N, N)
    SparseOperator(b, data)
end

"""
    sigmap(b::SpinBasis)

Raising operator ``σ_+`` for the given Spin basis.
"""
function sigmap(b::SpinBasis)
    N = num(b.spinnumber*2 + 1)
    S = (b.spinnumber + 1)*b.spinnumber
    diag = Complex128[complex(sqrt(float(S - m*(m+1)))) for m=b.spinnumber-1:-1:-b.spinnumber]
    data = spdiagm(diag, 1, N, N)
    SparseOperator(b, data)
end

"""
    sigmam(b::SpinBasis)

Lowering operator ``σ_-`` for the given Spin basis.
"""
function sigmam(b::SpinBasis)
    N = num(b.spinnumber*2 + 1)
    S = (b.spinnumber + 1)*b.spinnumber
    diag = [complex(sqrt(float(S - m*(m-1)))) for m=b.spinnumber:-1:-b.spinnumber+1]
    data = spdiagm(diag, -1, N, N)
    SparseOperator(b, data)
end


"""
    spinup(b::SpinBasis)

Spin up state for the given Spin basis.
"""
spinup(b::SpinBasis) = basisstate(b, 1)

"""
    spindown(b::SpinBasis)

Spin down state for the given Spin basis.
"""
spindown(b::SpinBasis) = basisstate(b, b.shape[1])


end #module
