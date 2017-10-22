Pkg.clone("https://github.com/tpapp/DiscreteRanges.jl.git")
Pkg.clone(pwd())
Pkg.build("FlexDates")
Pkg.test("FlexDates"; coverage=true)
