using Documenter, AnalysisOfVariance

makedocs(
    modules = [],
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    sitename = "AnalysisOfVariance.jl",
    authors = "Min-Woong Sohn",
    pages = [
        "Home" => "index.md",
        "Examples" => "examples.md"
    ]
)

deploydocs(
    repo = "github.com/mwsohn/AnalysisOfVariance.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
    push_preview = true
)