using Pkg
Pkg.add("https://github.com/tpapp/DiscreteRanges.jl")
Pkg.activate(".")
Pkg.build()
Pkg.test(; coverage=true)
