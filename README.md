# InvasiveBodhi
Chapter 3 of Dissertation focusing on the introduction of the Bodhi tree on the Hawaiian Islands
## Project Objectives
•	Identify parentage in Kauaʻi results

•	Briefly describe Bodhi tree spread on the Big Island as neglible

•	Describe Oʻahu Bodhi tree spread as invasive

•	Compare Oʻahu invasive spread to Kauaʻi established tree situation

•	Create MaxEnt model to show potential habitat expansion



## Kauai Overtime Project
I am comparing the spread of Bodhi trees from 2023-2025 on Kaua'i.
[Here is the histogram](https://github.com/JazleeCrowley/InvasiveBodhi/edit/main/README.md#:~:text=Kauai_trees_5.png-,Kauai_trees_by_year,-.png)
showing Bodhi tree spread across three individual trees across the three years on Kaua'i.
## Island Comparisons
Compare all islands' Bodhi tree spread and density to eachother in 2025
### Kaua'i versus O'ahu
Kaua'i currently represents an established non-native situation, while O'ahu clearly shows an invasive level of Bodhi tree spread. 
[This figure](https://github.com/JazleeCrowley/InvasiveBodhi/edit/main/README.md#:~:text=Oahu_Kauai_PairwiseDistance)
helps visualize the different distribution types (very dense versus sparse distribution) that Bodhi tree occurences show across the two islands. This was made using a pairwise distribution method, subsequently analyzed with a Kolmogorov-Smirnov and permutation analysis, for which you may find the code 
[here.](https://github.com/JazleeCrowley/InvasiveBodhi/edit/main/README.md#:~:text=Pairwise_Distance_Analysis)


[This is the code that](https://github.com/JazleeCrowley/InvasiveBodhi/blob/main/code/Time_series_Oahu.R#:~:text=Island%20Comparison.docx-,Time_series_Oahu.R,-Trees.jl) shows how Bodhi trees have spread through time.
[Here is a figure](https://github.com/JazleeCrowley/InvasiveBodhi/blob/main/Figures/Trees_Ages_Oahu.png#:~:text=at%2011.50.46.png-,Trees_Ages_Oahu.png,-Presentations) that shows all tree ages in O'ahu simultaneously. 

### Big Island
Currently represents an early established non-native situation
## Maxent
Projection of Bodhi tree spread in the Hawaiian Islands using climate data
