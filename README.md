# One-Way or Two-Way Analysis of Variance

A Julia package for conducting one-way or two-way analysis of variance.
It can produce Type I, II, III sums of squares (SS). It can also prodcue
an ANOVA table for a linear or GLM model.

## Installation

`] add AnalysisOfVariance`

## Syntax

```
anova(::DataFrame, depvar::Symbol, groupvar::Symbol)
anova(::DataFrame, depvar::Symbol, groupvar1::Symbol, groupvar2::Symbol; 
        type = 1, interaction = false)
anova(::DataFrame, fm::FormulaTerm; type=1)
anova(::StatsModels.TableRegressionModel)
```

## Options
```
* type: Type of sums of squares to request. Available types are 1, 2, and 3 (default = 1)
* interaction: set to `true` to include an interaction between two independent variables
```

## Return Struct
Anova returns a struct whose elements are:

* type - Type of sums of squares
* title - Row titles in the ANOVA table
* ss - Sums of squares
* df - Degress of freedom
* ms - Mean sums of squares
* F - F-statistic
* pvalue - P-values

## Examples

We will use the auto dataset from https://vincentarelbundock.github.io/Rdatasets/csv/causaldata/auto.csv.

```
julia> auto = CSV.read(download("https://vincentarelbundock.github.io/Rdatasets/csv/causaldata/auto.csv"), DataFrame);

julia> auto.mpg3 = Stella.xtile(auto.mpg, nq = 3);

julia> values!(auto,:mpg3, Dict(1 => "MPG Tertile 1", 2 => "MPG Tertile 2", 3 => "MPG Tertile 3"));

julia> tab(auto, :mpg3)
───────────────┬───────────────────────────
          mpg3 │ Counts   Percent  Cum Pct 
───────────────┼───────────────────────────
 MPG Tertile 1 │     27   36.4865  36.4865
 MPG Tertile 2 │     24   32.4324  68.9189
 MPG Tertile 3 │     23   31.0811    100.0
───────────────┼───────────────────────────
         Total │     74     100.0    100.0
───────────────┴───────────────────────────

julia> values!(auto,:foreign, Dict(0 => "Domestic", 1 => "Foreign"));

julia> tab(auto, :foreign)
──────────┬───────────────────────────
  foreign │ Counts   Percent  Cum Pct 
──────────┼───────────────────────────
 Domestic │     52   70.2703  70.2703
  Foreign │     22   29.7297    100.0
──────────┼───────────────────────────
    Total │     74     100.0    100.0
──────────┴───────────────────────────

```

### 1. Oneway ANOVA

```
julia> aov = anova(auto, :price, :mpg3)

Analysis of Variance (One-Way)

   Source │            SS  DF            MS      F       P 
──────────┼────────────────────────────────────────────────
    Model │ 136763694.954   2  68381847.477  9.743  0.0002
     mpg3 │ 136763694.954   2  68381847.477  9.743  0.0002
 Residual │ 498301701.168  71   7018333.819
──────────┼────────────────────────────────────────────────
    Total │ 635065396.122  73   8699525.974

julia> aov.pvalue[1]
0.00018235773127089433
```
### 2. Twoway ANOVA

#### 2.1. Type I Sums of Squares, No interaction
```
julia> aov = anova(auto, :price, :foreign, :mpg3, type = 1)

Analysis of Variance (Type I)

   Source │            SS  DF            MS       F         P 
──────────┼───────────────────────────────────────────────────
    Model │ 154897061.512   3  51632353.837   7.527    0.0002
  foreign │   1507382.657   1   1507382.657   0.220    0.6407
     mpg3 │ 153389678.855   2  76694839.428  11.181  < 0.0001
 Residual │ 480168334.610  70   6859547.637
──────────┼───────────────────────────────────────────────────
    Total │ 635065396.122  73   8699525.974

julia> aov.pvalue[3] # P-value for mpg3
6.112930853953449e-5
```

#### 2.2. Type II Sums of Squares, No interaction
```
julia> aov = anova(auto, :price, :foreign, :mpg3, type = 2)

Analysis of Variance (Type II)

   Source │            SS  DF            MS       F         P 
──────────┼───────────────────────────────────────────────────
    Model │ 154897061.512   3  51632353.837   7.527    0.0002
  foreign │  18133366.558   1  18133366.558   2.644    0.1085
     mpg3 │ 153389678.855   2  76694839.428  11.181  < 0.0001
 Residual │ 480168334.610  70   6859547.637
──────────┼───────────────────────────────────────────────────
    Total │ 635065396.122  73   8699525.974

julia> aov.pvalue[3] # P-value for mpg3
6.112930853953449e-5
```

#### 2.3. Type I Sums of Squares, With Interaction
```
julia> aov = anova(auto, :price, :foreign, :mpg3, type = 1, interaction = true)

Analysis of Variance (Type I)

         Source │            SS  DF            MS       F         P 
────────────────┼───────────────────────────────────────────────────
          Model │ 156625170.566   5  31325034.113   4.452    0.0014
        foreign │   1507382.657   1   1507382.657   0.214    0.6449
           mpg3 │ 153389678.855   2  76694839.428  10.901  < 0.0001
 foreign & mpg3 │   1728109.054   2    864054.527   0.123    0.8846
       Residual │ 478440225.555  68   7035885.670
────────────────┼───────────────────────────────────────────────────
          Total │ 635065396.122  73   8699525.974

julia> aov.pvalue[3] # P-value for mpg3
7.829523220630382e-5
```

#### 2.4. Type II Sums of Squares, With Interaction
```
julia> aov = anova(auto, :price, :foreign, :mpg3, type = 2, interaction = true)

Analysis of Variance (Type II)

         Source │            SS  DF            MS       F         P 
────────────────┼───────────────────────────────────────────────────
          Model │ 156625170.566   5  31325034.113   4.452    0.0014
        foreign │  18133366.558   1  18133366.558   2.577    0.1130
           mpg3 │ 153389678.855   2  76694839.428  10.901  < 0.0001
 foreign & mpg3 │   1728109.054   2    864054.527   0.123    0.8846
       Residual │ 478440225.555  68   7035885.670
────────────────┼───────────────────────────────────────────────────
          Total │ 635065396.122  73   8699525.974

julia> aov.pvalue[3] # P-value for mpg3
7.829523220630382e-5
```

#### 2.5. Type III Sums of Squares, With Interaction
```
julia> aov = anova(auto, :price, :foreign, :mpg3, type = 3, interaction = true)

Analysis of Variance (Type III)

         Source │            SS  DF            MS      F       P 
────────────────┼────────────────────────────────────────────────
          Model │ 156625170.566   5  31325034.113  4.452  0.0014
        foreign │  19148362.309   1  19148362.309  2.722  0.1036
           mpg3 │ 129967822.960   2  64983911.480  9.236  0.0003
 foreign & mpg3 │   1728109.054   2    864054.527  0.123  0.8846
       Residual │ 478440225.555  68   7035885.670
────────────────┼────────────────────────────────────────────────
          Total │ 635065396.122  73   8699525.974

julia> aov.pvalue[3] # P-value for mpg3
0.0002828218888318445
```

#### 2.6. Type III Sums of Squares, With Interaction using Formula
```
julia> aov = anova(auto, @formula(price ~ foreign + mpg3 + foreign & mpg3), type=3)

Analysis of Variance (Type III)

         Source │            SS  DF            MS      F       P 
────────────────┼────────────────────────────────────────────────
          Model │ 156625170.566   5  31325034.113  4.452  0.0014
        foreign │  19148362.309   1  19148362.309  2.722  0.1036
           mpg3 │ 129967822.960   2  64983911.480  9.236  0.0003
 foreign & mpg3 │   1728109.054   2    864054.527  0.123  0.8846
       Residual │ 478440225.555  68   7035885.670
────────────────┼────────────────────────────────────────────────
          Total │ 635065396.122  73   8699525.974

julia> aov.pvalue[3] # P-value for mpg3
0.0002828218888318445
```





