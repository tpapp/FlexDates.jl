__precompile__()
module FlexDates

using Compat.Dates: Date, Day, value

using DiscreteRanges: DiscreteRange
import DiscreteRanges: isdiscrete, discrete_gap, discrete_next

import Base:
    convert, eltype, show,
    isless, typemin, typemax,
    ==, +, -, zero, oneunit,
    hash, promote, length

export FlexDate

"""
    FlexDate{epoch, T}(date::Date)
    FlexDate{epoch, T}(year, month, day)
    FlexDate{epoch}(days::T)

Construct an object representing a given date as the number of days (stored in
type `T`) since `epoch`, which is a `Date` object.

When `T` is to narrow to represent a particular date, an `InexactError` is
thrown.

For working with a particular dataset, it is convenient to define a type
constant and work with that instead:

```julia
const MyDate = FlexDate{Date(2001, 1, 1), Int16}

MyDate(2010, 4, 31)
```

Limited arithmetic and comparisons are supported, but are fastest when using the
same epoch (unless conversion to `Date` may occur). For timespans, use `..`
(DiscreteRange) from `DiscreteRanges`.
"""
struct FlexDate{E, T <: Integer}
    Δ::T
    function FlexDate{E}(Δ::T) where {E, T <: Integer}
        @assert E isa Date
        new{E, T}(Δ)
    end
end

FlexDate{E, T}(year, month, day) where {E, T} =
    FlexDate{E, T}(Date(year, month, day))

_print_ET(io, E, T) = print(io, " [$(E) + $(T) days]")

function show(io::IO, flexdate::FlexDate{E, T}) where {E, T}
    print(io, convert(Date, flexdate))
    _print_ET(io, E, T)
end

function promote(x::FlexDate{Ex, <: Integer},
                 y::FlexDate{Ey, <: Integer }) where {Ex, Ey}
    xΔ, yΔ = promote(x.Δ, y.Δ)
    FlexDate{Ex}(xΔ), FlexDate{Ex}(oftype(yΔ, yΔ + Dates.days(Ey-Ex)))
end

function promote(x::FlexDate{E, <: Integer}, y::FlexDate{E, <: Integer}) where E
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

typemin(::Type{FlexDate{E, T}}) where {E, T} = FlexDate{E, T}(typemin(T))

typemax(::Type{FlexDate{E, T}}) where {E, T} = FlexDate{E, T}(typemax(T))

(==)(x::FlexDate{E}, y::FlexDate{E}) where E = x.Δ == y.Δ

(==)(x::FlexDate{E1}, y::FlexDate{E2}) where {E1, E2} =
    convert(Date, x) == convert(Date, y)

(==)(x::FlexDate{E}, y::Date) where E = convert(Date, x) == y

(==)(x::Date, y::FlexDate{E}) where E = x == convert(Date, y)

eltype(x::FlexDate{E, T}) where {E, T} = T

hash(x::FlexDate, h::UInt) = hash(convert(Date, x), h)

(-)(x::FlexDate{E, T}, y::FlexDate{E, T}) where {E, T} = Day(x.Δ - y.Δ)

# NOTE: arithmetic remains in the given type T, over/underflow is an error
# convert to `Date` for calculations with large spans, FlexDate is a storage
# format.
(+)(x::FlexDate{E, T}, y::Day) where {E, T} = FlexDate{E}(T(x.Δ + value(y)))

(-)(x::FlexDate{E, T}, y::Day) where {E, T} = FlexDate{E}(T(x.Δ - value(y)))

# support for DiscreteRanges

function show(io::IO, D::DiscreteRange{FlexDate{E,T}}) where {E,T}
    print(io, convert(Date, D.left))
    print(io, "..")
    print(io, convert(Date, D.right))
    _print_ET(io, E, T)
end

isdiscrete(::Type{<:FlexDate}) = true
discrete_gap(x::FlexDate{E,T}, y::FlexDate{E,T}) where {E,T} = x.Δ - y.Δ
discrete_next(x::FlexDate{E,T}, Δ) where {E,T} = FlexDate{E}(T(x.Δ + Δ))

end # module
