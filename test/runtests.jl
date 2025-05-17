using SweepOperator, AnalysisOfVariance, DataFrames, CategoricalArrays, Stella

auto = CSV.read(download("https://vincentarelbundock.github.io/Rdatasets/csv/causaldata/auto.csv"), DataFrame);

# create a categorical variable based on mpg
auto.mpg3 = Stella.xtile(auto.mpg, nq=3);
Stella.values!(auto, :mpg3, Dict(1 => "MPG Tertile 1", 2 => "MPG Tertile 2", 3 => "MPG Tertile 3"));

# foreign is another categorical variable
Stella.values!(auto, :foreign, Dict(0 => "Domestic", 1 => "Foreign"));

@testset "One-Way ANOVA" begin

    aov = anova(auto,:price,:foreign)

    @test isapprox(aov.ss[1], 1507382.7, atol = 1e-1)
    @test isapprox(aov.pvalue[1], 0.6802, atol = 1e-3)
end

@testset "Two-Way ANOVA Type I SS with No Interaction" begin
    aov = anova(auto, :price, :foreign, :mpg3, type = 1)

    # compared against values reported in SAS GLM Type I SS
    @test isapprox(aov.ms[1], 51632353.8, atol = 1e-1)
    @test isapprox(aov.ms[2], 1507382.7, atol = 1e-1)
    @test isapprox(aov.ms[3], 76694839.4, atol = 1e-1)
    @test isapprox(aov.ms[4], 6859547.6, atol = 1e-1)
    @test isapprox(aov.F[1], 7.53, atol = 1e-2)
    @test isapprox(aov.F[2], 0.22, atol = 1e-2)
    @test isapprox(aov.F[3], 11.18, atol = 1e-2)
    @test isapprox(aov.pvalue[1], 0.0002, atol = 1e-4)
    @test isapprox(aov.pvalue[2], 0.6407, atol = 1e-4)
    @test isapprox(aov.pvalue[3], 0.0001, atol = 1e-4)
end

@testset "Two-Way ANOVA Type II SS with No Interaction" begin
    aov = anova(auto, :price, :foreign, :mpg3, type = 2)

    # compared against values reported in SAS GLM Type II SS
    @test isapprox(aov.ms[1], 51632353.8, atol=1e-1)
    @test isapprox(aov.ms[2], 18133366.6, atol=1e-1)
    @test isapprox(aov.ms[3], 76694839.4, atol=1e-1)
    @test isapprox(aov.ms[4], 6859547.6, atol=1e-1)
    @test isapprox(aov.F[1], 7.53, atol=1e-2)
    @test isapprox(aov.F[2], 2.64, atol=1e-2)
    @test isapprox(aov.F[3], 11.18, atol=1e-2)
    @test isapprox(aov.pvalue[1], 0.0002, atol=1e-4)
    @test isapprox(aov.pvalue[2], 0.1085, atol=1e-4)
    @test isapprox(aov.pvalue[3], 0.0001, atol=1e-4)
end

@testset "Two-Way ANOVA Type III SS with No Interaction" begin
    aov = anova(auto, :price, :foreign, :mpg3, type=3)

    # compared against values reported in SAS PROC GLM Type III SS
    @test isapprox(aov.ss[1], 154897061.5, atol=1e-1)
    @test isapprox(aov.ss[2], 18133366.6, atol=1e-1)
    @test isapprox(aov.ss[3], 153389678.9, atol=1e-1)
    @test isapprox(aov.ss[4], 480168334.6, atol=1e-1)
    @test isapprox(aov.F[1], 7.53, atol=1e-2)
    @test isapprox(aov.F[2], 2.64, atol=1e-2)
    @test isapprox(aov.F[3], 11.18, atol=1e-2)
    @test isapprox(aov.pvalue[1], 0.0002, atol=1e-4)
    @test isapprox(aov.pvalue[2], 0.1085, atol=1e-4)
    @test isapprox(aov.pvalue[3], 0.0001, atol=1e-4)
end

@testset "Two-Way ANOVA Type I SS with Interaction" begin
    aov = anova(auto, :price, :foreign, :mpg3, type=1, interaction = true)

    # compared against values reported in SAS GLM Type I SS
    @test isapprox(aov.ms[1], 31325034.1, atol=1e-1)
    @test isapprox(aov.ms[2], 1507382.7, atol=1e-1)
    @test isapprox(aov.ms[3], 76694839.4, atol=1e-1)
    @test isapprox(aov.ms[4], 864054.5, atol=1e-1)
    @test isapprox(aov.ms[5], 7035885.7, atol=1e-1)
    @test isapprox(aov.F[1], 4.45, atol=1e-2)
    @test isapprox(aov.F[2], 0.21, atol=1e-2)
    @test isapprox(aov.F[3], 10.90, atol=1e-2)
    @test isapprox(aov.F[4], 0.12, atol=1e-2)
    @test isapprox(aov.pvalue[1], 0.0014, atol=1e-4)
    @test isapprox(aov.pvalue[2], 0.6449, atol=1e-4)
    @test isapprox(aov.pvalue[3], 0.0001, atol=1e-4)
    @test isapprox(aov.pvalue[4], 0.8846, atol=1e-4)

end

@testset "Two-Way ANOVA Type II SS with Interaction" begin
    aov = anova(auto, :price, :foreign, :mpg3, type=2, interaction=true)

    # compared against values reported in SAS proc glm type II SS
    @test isapprox(aov.ms[1], 31325034.1, atol=1e-1)
    @test isapprox(aov.ms[2], 18133366.6, atol=1e-1)
    @test isapprox(aov.ms[3], 76694839.4, atol=1e-1)
    @test isapprox(aov.ms[4], 864054.5, atol=1e-1)
    @test isapprox(aov.ms[5], 7035885.7, atol=1e-1)
    @test isapprox(aov.F[1], 4.45, atol=1e-2)
    @test isapprox(aov.F[2], 2.58, atol=1e-2)
    @test isapprox(aov.F[3], 10.90, atol=1e-2)
    @test isapprox(aov.F[4], 0.12, atol=1e-2)
    @test isapprox(aov.pvalue[1], 0.0014, atol=1e-4)
    @test isapprox(aov.pvalue[2], 0.1130, atol=1e-4)
    @test isapprox(aov.pvalue[3], 0.0001, atol=1e-4)
    @test isapprox(aov.pvalue[4], 0.8846, atol=1e-4)

end

@testset "Two-Way ANOVA Type III SS with Interaction" begin
    aov = anova(auto, :price, :foreign, :mpg3, type=3, interaction=true)

    # compared against values reported in SAS proc glm type III SS
    @test isapprox(aov.ms[1], 31325034.1, atol=1e-1)
    @test isapprox(aov.ms[2], 19148362.3, atol=1e-1)
    @test isapprox(aov.ms[3], 64983911.5, atol=1e-1)
    @test isapprox(aov.ms[4], 864054.5, atol=1e-1)
    @test isapprox(aov.ms[5], 7035885.7, atol=1e-1)
    @test isapprox(aov.F[1], 4.45, atol=1e-2)
    @test isapprox(aov.F[2], 2.72, atol=1e-2)
    @test isapprox(aov.F[3], 9.24, atol=1e-2)
    @test isapprox(aov.F[4], 0.12, atol=1e-2)
    @test isapprox(aov.pvalue[1], 0.0014, atol=1e-4)
    @test isapprox(aov.pvalue[2], 0.1036, atol=1e-4)
    @test isapprox(aov.pvalue[3], 0.0003, atol=1e-4)
    @test isapprox(aov.pvalue[4], 0.8846, atol=1e-4)

end
