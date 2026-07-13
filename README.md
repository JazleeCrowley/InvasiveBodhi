# Invasive Bodhi
Chapter 3 of Dissertation focusing on the introduction of the Bodhi tree on the Hawaiian Islands. [Here is a table](./Figures/Total_Hawaii_trees.png) with all Bodhi tree occurrences on all three islands, with a total of 714 occurrences.
## Project Objectives
•	Identify parentage in Kauaʻi results

•	Briefly describe Bodhi tree spread on the Big Island as neglible

•	Describe Oʻahu Bodhi tree spread as invasive

•	Compare Oʻahu invasive spread to Kauaʻi established tree situation

•	Create MaxEnt model to show potential habitat expansion



## Kauai Overtime Project
I am comparing the spread of Bodhi trees from 2023-2025 on Kaua'i.
[Here is the histogram](./Figures/Kauai_trees_by_year.png)
showing Bodhi tree spread across three individual trees across the three years on Kaua'i. [This is a simple table](./Figures/Kauai_Averages.png) of basic statistics for Kaua'i offspring distances.
## Island Comparisons
Compare all islands' Bodhi tree spread and density to eachother in 2025
### Kaua'i versus O'ahu
Kaua'i currently represents an established non-native situation, while O'ahu clearly shows an invasive level of Bodhi tree spread. 

[This figure](./Figures/Oahu_Kauai_PairwiseDistance.pdf)
helps visualize the different distribution types (very dense versus sparse distribution) that Bodhi tree occurences show across the two islands, with the permutation test simulated figure with comparison to real distances [here](./Figures/Histogram_ks_perm.png). This was made using a pairwise distribution method, subsequently analyzed with a Kolmogorov-Smirnov and permutation analysis, for which you may find the code 
[here.](./code/Pairwise_Distance_Analysis.R)


[This is the code that](./code/Time_series_Oahu.R) shows how Bodhi trees have spread through time on O'ahu.
[Here is a figure](./Figures/Trees_Ages_Oahu.png) that shows all tree ages in O'ahu simultaneously. 

### Big Island
Currently represents an early established non-native situation. Subsequent analysis required.
## Maxent
Projection of Bodhi tree spread in the Hawaiian Islands using climate data. While this is still in process, below is the current up to date figure showing potential habitat range for the Bodhi tree. In the future, to support this result, I will be doing the same projection in MaxENT on each island separately, to compare to this aggregate figure.
<img width="652" height="506" alt="Screenshot 2026-06-02 at 12 16 05" src="https://github.com/user-attachments/assets/4d243495-5cee-46e7-9936-4fcc7ceaee9a" />

