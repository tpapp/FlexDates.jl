using FlexDates
using Base.Test

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
