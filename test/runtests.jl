using Test, HorizonsEphemeris

@testset "Fetch Vectors" begin
    @test ephemeris("moon", "2022-01-01", "2023-01-01", "1 month") isa HorizonsEphemeris.CartesianEphemeris
    @test ephemeris("moon", "2022-01-01", "2023-01-01", "1 month") isa HorizonsEphemeris.CartesianEphemeris
end
