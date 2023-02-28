using ModelingAndSimulation
using Documenter

DocMeta.setdocmeta!(ModelingAndSimulation, :DocTestSetup, :(using ModelingAndSimulation); recursive=true)

makedocs(;
    modules=[ModelingAndSimulation],
    authors="Abdulrhmn Ghanem <abdoghanem160@gmail.com> and contributors",
    repo="https://github.com/AbdulrhmnGhanem/ModelingAndSimulation.jl/blob/{commit}{path}#{line}",
    sitename="ModelingAndSimulation.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://AbdulrhmnGhanem.github.io/ModelingAndSimulation.jl",
        edit_link="main",
        assets=String[]
    ),
    pages=[
        "Home" => "index.md",
    ]
)

deploydocs(;
    repo="github.com/AbdulrhmnGhanem/ModelingAndSimulation.jl",
    devbranch="main"
)
