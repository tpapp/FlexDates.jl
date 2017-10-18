module FlexDates

import Base: convert, isless, typemin, typemax, ==, eltype, show, hash

export FlexDate

struct FlexDate{E, T <: Integer}
    Δ::T
    function FlexDate{E}(Δ::T) where {E, T <: Integer}
        @assert E isa Date
        new{E, T}(Δ)
    end
end

show(io::IO, flexdate::FlexDate{E, T}) where {E, T} = 
    print(io, "$(convert(Date, flexdate)) [$(E) + $(T)($(flexdate.Δ)) days]")

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

(==)(x::FlexDate{E}, y::FlexDate{E}) where E = x.value == y.value

(==)(x::FlexDate{E1}, y::FlexDate{E2}) where {E1, E2} =
    convert(Date, x) == convert(Date, y)

(==)(x::FlexDate{E}, y::Date) where E = convert(Date, x) == y

(==)(x::Date, y::FlexDate{E}) where E = x == convert(Date, y)

eltype(x::FlexDate{E, T}) where {E, T} = T

hash(x::FlexDate, h::UInt) = hash(convert(Date, x), u)

end # module
