using Pkg
using Test

@testset "Test that the UUID is unchanged" begin 
    project_filename = joinpath(dirname(@__DIR__), "Project.toml")
    project = Pkg.TOML.parsefile(project_filename)
    uuid = project["uuid"]
    correct_uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
    @test uuid == correct_uuid
end
