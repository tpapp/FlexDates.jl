# FlexDates

[![Build Status](https://travis-ci.org/tpapp/ParametricFunctions.jl.svg?branch=master)](https://travis-ci.org/tpapp/ParametricFunctions.jl)
[![Build Status](https://travis-ci.org/tpapp/FlexDates.jl.svg?branch=master)](https://travis-ci.org/tpapp/FlexDates.jl)
[![Coverage Status](https://coveralls.io/repos/github/tpapp/FlexDates.jl/badge.svg?branch=master)](https://coveralls.io/github/tpapp/FlexDates.jl?branch=master)
[![codecov.io](http://codecov.io/github/tpapp/FlexDates.jl/coverage.svg?branch=master)](http://codecov.io/github/tpapp/FlexDates.jl?branch=master)


## Motivation

Julia `Date`s in `Base` represent a particular day counting from
`0001-01-01` as the first day, using `Int64`. This allows the user to
use dates in the interval of ±2.5e16 years, starting well before the
Big Bang, and continuing way after the sun dies.

For the modest needs of social science data, a more limited range is
often sufficient. For example, `Int16` can represent days spanning a
bit more than 179 years (`2^16/365`), while `Int32` works for a bit
more than 10 million years.

This package helps with the management of dates, relying on `Base.Dates` to do most of the tricky bits of date calculations. The main type in this package, `FlexDate`, is intended primarily as a *storage* format: using more compact dates, you can economize on memory and disk consumption.

## Installation

The package is not (yet) registered. Install with

```julia
Pkg.clone("https://github.com/tpapp/FlexDates.jl")
```

## Usage

You need to choose an *epoch*, a particular date we count from. This is incorporated into the type: Julia's zero cost abstraction ensures that there is no storage overhead when values are unboxed (eg arrays). The second type parameter for `FlexDate` is the integer type for internal representation. Constructors accept dates, `year, month, day`, or a single integer counting the number of days.

The following constructors are equivalent:
```julia
using FlexDates

julia> FlexDate{Date(2000,1,1), Int16}(Date(1980, 1, 1))
1980-01-01 [2000-01-01 + Int16 days]

julia> FlexDate{Date(2000,1,1), Int16}(1980, 1, 1)
1980-01-01 [2000-01-01 + Int16 days]

julia> FlexDate{Date(2000,1,1)}(Int16(-7305))
1980-01-01 [2000-01-01 + Int16 days]
```

When working with a dataset, it is recommended that you define a type constant:
```julia
const MyDate = FlexDate{Date(2000,1,1), Int16}

MyDate(1980, 1, 1)
```

Limited arithmetic and comparisons are supported. Keep in mind that these operations will be fast when you use dates with the *same epoch*, otherwise dates will be converted back to `Date` for calculations. A single dataset should use a single epoch unless there is a compelling reason to do otherwise.

For sophisticated arithmetic and date calculations, convert to `Date`, since `FlexDate` is meant primarily as a storage format.

For timespans, it is recommended that you use
[DiscreteRanges.jl](https://github.com/tpapp/DiscreteRanges.jl):

```julia
julia> using DiscreteRanges

julia> MyDate(2003, 4, 8) ∈ MyDate(2001, 1, 1)..MyDate(2010, 1, 1)
true
```
