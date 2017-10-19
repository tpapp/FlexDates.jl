module FlexDates

import IntervalSets: ClosedInterval

import Base:
    convert, eltype, show,
    isless, typemin, typemax,
    ==, +, -, zero, oneunit,
    hash, promote, length

export FlexDate, FlexDay

struct FlexDate{E, T <: Integer}
    Δ::T
    function FlexDate{E}(Δ::T) where {E, T <: Integer}
        @assert E isa Date
        new{E, T}(Δ)
    end
end

FlexDate{E, T}(year, month, day) where {E, T} =
    FlexDate{E, T}(Date(year, month, day))

struct FlexDay{T <: Integer}
    d::T
end

_print_ET(io, E, T) = print(io, " [$(E) + $(T) days]")

function show(io::IO, flexdate::FlexDate{E, T}) where {E, T}
    print(io, convert(Date, flexdate))
    _print_ET(io, E, T)
end

function promote(x::FlexDate{Ex}, y::FlexDate{Ey}) where {Ex, Ey}
    xΔ, yΔ = promote(x.Δ, y.Δ)
    FlexDate{Ex}(xΔ), FlexDate{Ex}(yΔ, Dates.days(Ey-Ex))
end

function promote(x::FlexDate{E}, y::FlexDate{E}) where E
    xΔ, yΔ = promote(x.Δ, y.Δ)
    FlexDate{E}(xΔ), FlexDate{E}(yΔ)
end

function convert(::Type{Date}, flexdate::FlexDate{E}) where E
    E + Dates.Day(flexdate.Δ)
end

function convert(::Type{FlexDate{E,T}}, date::Date) where {E, T}
    FlexDate{E}(T(Dates.days(date - E)))
end

isless(x::FlexDate{E}, y::FlexDate{E}) where E = isless(x.Δ, y.Δ)

isless(x::FlexDate{E1}, y::FlexDate{E2}) where {E1, E2} =
    isless(convert(Date, x), convert(Date, y))

isless(x::FlexDate{E}, y::Date) where E = isless(convert(Date, x), y)

isless(x::Date, y::FlexDate{E}) where E = isless(x, convert(Date, y))

isless(x::FlexDay, y::FlexDay) = isless(x.d, y.d)

zero(::Type{FlexDay{T}}) where T = FlexDay(zero(T))

zero(x::T) where {T <: FlexDay} = zero(T)

oneunit(::Type{FlexDay{T}}) where T = FlexDay(one(T))

oneunit(x::T) where {T <: FlexDay} = oneunit(T)

typemin(::Type{FlexDate{E, T}}) where {E, T} = FlexDate{E, T}(typemin(T))

typemax(::Type{FlexDate{E, T}}) where {E, T} = FlexDate{E, T}(typemax(T))

(==)(x::FlexDate{E}, y::FlexDate{E}) where E = x.Δ == y.Δ

(==)(x::FlexDate{E1}, y::FlexDate{E2}) where {E1, E2} =
    convert(Date, x) == convert(Date, y)

(==)(x::FlexDate{E}, y::Date) where E = convert(Date, x) == y

(==)(x::Date, y::FlexDate{E}) where E = x == convert(Date, y)

eltype(x::FlexDate{E, T}) where {E, T} = T

hash(x::FlexDate, h::UInt) = hash(convert(Date, x), u)

(-)(x::FlexDate{E,T}, y::FlexDate{E,T}) where {E, T} = FlexDay{T}(x.Δ - y.Δ)

(+)(x::FlexDate{E}, y::FlexDay) where E = FlexDate{E}(x.Δ + y.d)

(-)(x::FlexDate{E}, y::FlexDay) where E = FlexDate{E}(x.Δ - y.d)

(+)(x::FlexDay, y::FlexDay) = FlexDay(x.d + y.d)

(-)(x::FlexDay, y::FlexDay) = FlexDay(x.d - y.d)

convert(::Type{FlexDay{T}}, x::S) where {T, S <: Integer} = FlexDay(T(x))

function show(io::IO, A::ClosedInterval{FlexDate{E,T}}) where {E,T}
    print(io, convert(Date, A.left))
    print(io, "..")
    print(io, convert(Date, A.right))
    _print_ET(io, E, T)
end

length(A::ClosedInterval{<:FlexDate}) = max(0, A.right.Δ - A.left.Δ + 1)

end # module
