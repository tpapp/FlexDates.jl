using FlexDates
using Base.Test
using IntervalSets

E1 = Date(1980, 1, 1)
E2 = Date(1990, 1, 1)

D1 = Date(2001, 1, 8)
D2 = Date(2007, 2, 9)

F11 = FlexDate{E1, Int16}(D1)
F12 = FlexDate{E2, Int32}(D1)

F21 = FlexDate{E1, Int16}(D2)
F22 = FlexDate{E2, Int32}(D2)

F3 = FlexDate{E1}(0)
F4 = FlexDate{E1}(5)
F5 = FlexDate{E1}(-5)

@test F11 == F12
@test F21 == F22
@test F11 ≠ F22
@test F5 < F3 < F4
@test F5 < E1 < F4
@test F3 == E1

FI = F3..F4

@test length(FI) == 6

@testset "interval (Int16)" begin
    const FD = FlexDate{Date(2005,1,1), Int16}

    d1 = FD(2005, 1, 1)
    d2 = FD(2008, 3, 7)
    d3 = FD(2009, 8, 11)
    d4 = FD(2013, 12, 1)

    @test d2 ∈ d1..d3
    @test (d1..d3) ∩ (d2..d4) == d2..d3
    @test (d1..d3) ∪ (d2..d4) == d1..d4

    @test repr(d2) == "2008-03-07 [2005-01-01 + Int16 days]"

    @test repr(d1..d3) == "2005-01-01..2009-08-11 [2005-01-01 + Int16 days]"
end
