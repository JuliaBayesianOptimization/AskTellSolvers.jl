using AskTellSolvers
using Test

@testset "BoxConstrainedSpec" begin
    @test_throws ArgumentError BoxConstrainedSpec(Min, [1, 23], [4,1])
    @test_throws ArgumentError BoxConstrainedSpec(Min, [1,2,3], [3,4])
    @test_throws ArgumentError BoxConstrainedSpec(Max, [13], [50,3])
    @test_throws ArgumentError BoxConstrainedSpec(Max, [], [])
    BoxConstrainedSpec(Min, [1.2, 2.3], [4.5, 5.6])
    Objective(x -> x^2)
end
