### A Pluto.jl notebook ###
# v0.20.21

using Markdown
using InteractiveUtils

# ╔═╡ 48706b3a-b446-11f0-263e-efa02e2f00be
begin
	using CSV, 
	      DataFrames,
	      PyPlot,
		  ScikitLearn, # machine learning package
		  StatsBase,
		  Random,
		  Statistics,
			PyCall,
			KernelDensity,
			Seaborn,
	HypothesisTests
	using Pkg
	Pkg.add("NearestNeighbors")
	Pkg.add("Distances")
			
end

# ╔═╡ 2d0d97ad-582d-4caf-a10b-9f696833bd1a
cd("/Users/jazleecrowley/Desktop/Kauai_Julia/")

# ╔═╡ b8d4de68-90a5-49fa-9587-699406b4d9d2
begin
	df_trees = CSV.read("alltrees_2025.csv", DataFrame)
	df_2024 = CSV.read("alltrees_2024.csv", DataFrame)
	df_2023 = CSV.read("alltrees_2023.csv", DataFrame)
	"reading in dfs"

	df_2024[88,6]
end

# ╔═╡ 026c47f9-a8f8-48b9-acf4-94365d27aa77
begin
	function get_distance(child_ind, mama_ind, df)
		#child and mama as indices
		#df should be all trees for one island
		
		child_lat = df.latitude[child_ind]
		child_long = df.longitude[child_ind]
		mama_lat = df.latitude[mama_ind]
		mama_long = df.longitude[mama_ind]
	
		dist = sqrt(abs(child_lat - mama_lat)^2 + abs(child_long - mama_long)^2)
		#convert into meters
			#system is in decimal degrees
			#1 DD = 111 km
		
		return dist
	end
		
	function get_distance(tree1, tree2)
		dist = sqrt(abs(tree1.latitude - tree2.latitude)^2 + abs(tree1.longitude - tree2.longitude)^2)
		return dist
	end
end

# ╔═╡ 76c7835c-8386-4a45-9f9d-80a735f01a09
function plot_circle(x, y, r, axnum)
	axnum.add_patch(plt.Circle((x,y), r, edgecolor="grey", facecolor="none"))
end

# ╔═╡ 73524a92-aecb-46b7-8a5a-8a099f6c4e3b
begin

	#split of df_trees based on island
	bigisland_inds = findall([occursin("BI", i) for i in df_trees.name])
	BI_alltrees = DataFrame(
		:latitude => [df_trees.latitude[i] for i in bigisland_inds],
		:longitude => [df_trees.longitude[i] for i in bigisland_inds], 
		:name => [df_trees.name[i] for i in bigisland_inds])
	
	BI_kidtrees = copy(BI_alltrees)
	deleteat!(BI_kidtrees, findall([!occursin("Offspring", i) for i in BI_alltrees.name]))
	BI_adulttrees = copy(BI_alltrees)
	deleteat!(BI_adulttrees, findall([occursin("Offspring", i) for i in BI_alltrees.name]))
	
	O_alltrees = DataFrame(
		:latitude => [df_trees.latitude[j] for j in findall([occursin("O", i) for i in df_trees.name])],
		:longitude => [df_trees.longitude[j] for j in findall([occursin("O", i) for i in df_trees.name])],
		:name => [df_trees.name[j] for j in findall([occursin("O", i) for i in df_trees.name]) ]
	)

	deleteat!(O_alltrees, findall([occursin("BI", i) for i in O_alltrees.name]))
	deleteat!(O_alltrees, findall([occursin("K", i) for i in O_alltrees.name]))
	
	O_kidtrees = copy(O_alltrees)
	O_adulttrees = copy(O_alltrees)

	deleteat!(O_kidtrees, findall([!occursin("Offspring", i) for i in O_alltrees.name]))
	deleteat!(O_adulttrees, findall([occursin("Offspring", i) for i in O_alltrees.name]))
	
########################### Kaua'i trees ################################
	K_alltrees = DataFrame(
		:latitude => [df_trees.latitude[j] for j in findall([occursin("K", i) for i in df_trees.name])],
		:longitude => [df_trees.longitude[j] for j in findall([occursin("K", i) for i in df_trees.name])],
		:name => [df_trees.name[j] for j in findall([occursin("K", i) for i in df_trees.name])]
	)
	K_alltrees[!, :dists] = [Float64(0) for i in 1:length(K_alltrees.latitude)]

	K2_kid_ind = findall([i == "K2 Offspring" for i in K_alltrees.name])
	K5_kid_ind = findall([i == "K5 Offspring" for i in K_alltrees.name])
	K21_kid_ind = findall([occursin("K21 Offspring", i) for i in K_alltrees.name])
	
	K2_dists = [get_distance(i, findfirst(["K2" == j for j in K_alltrees.name]), K_alltrees) for i in K2_kid_ind]
	K5_dists = [get_distance(i, findfirst(["K5" == j for j in K_alltrees.name]), K_alltrees) for i in K5_kid_ind]
	K21_dists = [get_distance(i, findfirst(["K21" == j for j in K_alltrees.name]), K_alltrees) for i in K21_kid_ind]
	
	[K_alltrees.dists[j] = K2_dists[i] for (i,j) in enumerate(K2_kid_ind)]
	[K_alltrees.dists[j] = K5_dists[i] for (i,j) in enumerate(K5_kid_ind)]
	[K_alltrees.dists[j] = K21_dists[i] for (i,j) in enumerate(K21_kid_ind)]

	K_alltrees[!, :dists_m] = [i*111*1000 for i in K_alltrees.dists]
	
	K_kidtrees = copy(K_alltrees)
	K_adulttrees = copy(K_alltrees)
	
	deleteat!(K_kidtrees, findall([!occursin("Offspring", i) for i in K_alltrees.name]))
	deleteat!(K_kidtrees, findall([occursin("K3", i ) for i in K_kidtrees.name]))
		
	deleteat!(K_adulttrees, findall([occursin("Offspring", i) for i in K_alltrees.name]))

	deleteat!(K_adulttrees, findall([occursin("K3", i) for i in K_adulttrees.name]))
	deleteat!(K_adulttrees, findall([occursin("K4", i) for i in K_adulttrees.name]))
	deleteat!(K_adulttrees, findall([occursin("K80", i) for i in K_adulttrees.name]))

	K_adulttrees[!, :trees_in_circle] = [length(findall([i == "K21 Offspring" for i in K_alltrees.name])), length(findall([i == "K2 Offspring" for i in K_alltrees.name])), length(findall([i == "K5 Offspring" for i in K_alltrees.name]))]

#=	K_adulttrees[!, :num_kids] = vcat(
		length(findall([occursin("K21 Offspring", i) for i in K_kidtrees.name])),
		length(findall([occursin("K2 Offspring", i) for i in K_kidtrees.name])),
		length(findall([occursin("K5 Offspring", i) for i in K_kidtrees.name])))

	select!(K_adulttrees, Not(:dists))
	select!(K_adulttrees, Not(:dists_m))=#
	#########################
	"splitting up dataframes into island and adult/kid trees"
end

# ╔═╡ c98fd90d-179b-43be-a272-373e16652579
O_adulttrees[!, 2][6]

# ╔═╡ 27025ecc-9afd-4c33-ace6-9d90773b4187
length(O_kidtrees.latitude)

# ╔═╡ 38fdab57-cc18-47a5-bcac-1f6c40882374
	circle_trees = 0
	for kid_tree in eachrow(df_kidtrees)
		d = get_distance(parent_tree, kid_tree)
		if d <= R
			circle_trees += 1
		end
	end
	return circle_trees
end

# ╔═╡ 0e79c7fd-a60c-492e-9b9b-a1598f586959
begin
########################## Kaua'i Trees - 2023 #################
	K_alltrees_2023 = DataFrame(
		:latitude => [df_2023.latitude[j] for j in findall([occursin("K", i) for i in df_2023.name])],
		:longitude => [df_2023.longitude[j] for j in findall([occursin("K", i) for i in df_2023.name])],
		:name => [df_2023.name[j] for j in findall([occursin("K", i) for i in df_2023.name])]
	)
	K_alltrees_2023[!, :dists] = [Float64(0) for i in 1:length(K_alltrees_2023.latitude)]

	K2_kid_ind_2023 = findall([i == "K2 Offspring" for i in K_alltrees_2023.name])
	K5_kid_ind_2023 = findall([i == "K5 Offspring" for i in K_alltrees_2023.name])
	K21_kid_ind_2023 = findall([occursin("K21 Offspring", i) for i in K_alltrees_2023.name])
	
	K2_dists_2023 = [get_distance(i, findfirst(["K2" == j for j in K_alltrees_2023.name]), K_alltrees_2023) for i in K2_kid_ind_2023]
	K5_dists_2023 = [get_distance(i, findfirst(["K5" == j for j in K_alltrees_2023.name]), K_alltrees_2023) for i in K5_kid_ind_2023]
	K21_dists_2023 = [get_distance(i, findfirst(["K21" == j for j in K_alltrees_2023.name]), K_alltrees_2023) for i in K21_kid_ind_2023]
	
	[K_alltrees_2023.dists[j] = K2_dists_2023[i] for (i,j) in enumerate(K2_kid_ind_2023)]
	[K_alltrees_2023.dists[j] = K5_dists_2023[i] for (i,j) in enumerate(K5_kid_ind_2023)]
	[K_alltrees_2023.dists[j] = K21_dists_2023[i] for (i,j) in enumerate(K21_kid_ind_2023)]

	K_alltrees_2023[!, :dists_m] = [i*111*1000 for i in K_alltrees_2023.dists]
	
	K_kidtrees_2023 = copy(K_alltrees_2023)
	K_adulttrees_2023 = copy(K_alltrees_2023)
	
	deleteat!(K_kidtrees_2023, findall([!occursin("Offspring", i) for i in K_alltrees_2023.name]))
	deleteat!(K_kidtrees_2023, findall([occursin("K3", i ) for i in K_kidtrees_2023.name]))
		
	deleteat!(K_adulttrees_2023, findall([occursin("Offspring", i) for i in K_alltrees_2023.name]))

	deleteat!(K_adulttrees_2023, findall([occursin("K3", i) for i in K_adulttrees_2023.name]))
	deleteat!(K_adulttrees_2023, findall([occursin("K4", i) for i in K_adulttrees_2023.name]))
	deleteat!(K_adulttrees_2023, findall([occursin("K80", i) for i in K_adulttrees_2023.name]))

########################## Kaua'i Trees - 2024 #################

	K_alltrees_2024 = DataFrame(
		:latitude => [df_2024.latitude[j] for j in findall([occursin("K", i) for i in df_2024.name])],
		:longitude => [df_2024.longitude[j] for j in findall([occursin("K", i) for i in df_2024.name])],
		:name => [df_2024.name[j] for j in findall([occursin("K", i) for i in df_2024.name])]
	)
	K_alltrees_2024[!, :dists] = [Float64(0) for i in 1:length(K_alltrees_2024.latitude)]

	K2_kid_ind_2024 = findall([i == "K2 Offspring" for i in K_alltrees_2024.name])
	K5_kid_ind_2024 = findall([i == "K5 Offspring" for i in K_alltrees_2024.name])
	K21_kid_ind_2024 = findall([occursin("K21 Offspring", i) for i in K_alltrees_2024.name])
	
	K2_dists_2024 = [get_distance(i, findfirst(["K2" == j for j in K_alltrees_2024.name]), K_alltrees_2023) for i in K2_kid_ind_2024]
	K5_dists_2024 = [get_distance(i, findfirst(["K5" == j for j in K_alltrees_2024.name]), K_alltrees_2024) for i in K5_kid_ind_2024]
	K21_dists_2024 = [get_distance(i, findfirst(["K21" == j for j in K_alltrees_2024.name]), K_alltrees_2024) for i in K21_kid_ind_2024]
	
	[K_alltrees_2024.dists[j] = K2_dists_2024[i] for (i,j) in enumerate(K2_kid_ind_2024)]
	[K_alltrees_2024.dists[j] = K5_dists_2024[i] for (i,j) in enumerate(K5_kid_ind_2024)]
	[K_alltrees_2024.dists[j] = K21_dists_2024[i] for (i,j) in enumerate(K21_kid_ind_2024)]

	K_alltrees_2024[!, :dists_m] = [i*111*1000 for i in K_alltrees_2024.dists]
	
	K_kidtrees_2024 = copy(K_alltrees_2024)
	K_adulttrees_2024 = copy(K_alltrees_2024)
	
	deleteat!(K_kidtrees_2024, findall([!occursin("Offspring", i) for i in K_alltrees_2024.name]))
	deleteat!(K_kidtrees_2024, findall([occursin("K3", i ) for i in K_kidtrees_2024.name]))
		
	deleteat!(K_adulttrees_2024, findall([occursin("Offspring", i) for i in K_alltrees_2024.name]))

	deleteat!(K_adulttrees_2024, findall([occursin("K3", i) for i in K_adulttrees_2024.name]))
	deleteat!(K_adulttrees_2024, findall([occursin("K4", i) for i in K_adulttrees_2024.name]))
	deleteat!(K_adulttrees_2024, findall([occursin("K80", i) for i in K_adulttrees_2024.name]))


	"K trees - making dataframes for 2023 and 2024 sampling years"
end

# ╔═╡ 54724e2f-4d2c-493d-9684-24d475eed18a
begin
	md"fun with for loops"
	MT = []
	#push!(MT, 1)
#	for i in 1:10
#		push!(MT, O_adulttrees.latitude[i])
#	end
#	MT

	
	for i in K_kidtrees_2023.name
		#occursin("K5 Offspring", i)
		push!(MT, i == "K5 Offspring")
	end
	#[K_kidtrees_2023.dists_m[i] for i in findall([occursin("K5 Offspring", i) for i in K_kidtrees_2023.name])]
	findall(MT)
	MT2 =[]
	for i in findall(MT)
		push!(MT2, K_kidtrees_2023.dists_m[i])
	end
	MT2
end

# ╔═╡ 84da0ed1-4a17-4556-ad4c-20603e371123
K_kidtrees_2023

# ╔═╡ 1f0cad71-bad1-41ac-ab99-43ad9188a42f
begin
	J3, (Jax1,Jax2,Jax3,Jax4)= subplots(2,2)
	Jax1.scatter(K_kidtrees_2024.dists_m, K_kidtrees_2024.longitude)
	
	ylabel("count")
	
	J3.suptitle("Sup")
	gcf()
end


# ╔═╡ b513b08a-e041-4fa3-8e4d-21a2c79d9fda
begin
	R = maximum(K_kidtrees.dists)
	R_m = maximum(K_kidtrees.dists_m)
end

# ╔═╡ bbecb116-bf11-4d95-a78c-95fd6e0e2b39
begin
	adult_trees = O_adulttrees
	kid_trees = O_kidtrees
	toast = []
	ind_check = []
	
	for (i, tree) in enumerate(eachrow(adult_trees))
		tree_group = []
		lorp = 0
		for kid in eachrow(kid_trees)
			d = get_distance(tree, kid)
			
			if d <= R
		#just looking at the kid trees within the circle of this one adult tree
				push!(tree_group, kid)
			end
		end
		for (j, tree2) in enumerate(eachrow(adult_trees))
			if i <j && i != j
				for kid in tree_group
					if get_distance(tree2, kid) <= R
						lorp += 1 
						#push!()
					end
				end
			end
		end
		push!(toast, lorp)
	end
	#=end
				for (j, adult_tree2) in enumerate(eachrow(adult_trees))
					#push!(ind_check, (i,j))
		#checking all other adult trees
					if i < j 
		#skipping duplicates of adult trees
						push!(ind_check, i)
						if get_distance(kid, adult_tree2) < R
		#is another adult tree within a radius of this kid tree?
							lorp += 1
						#	push!(toast, (get_distance(kid, adult_tree2)))
						end
					end
				end
		#	elseif d>R
		#		lorp = 0
			end
			
		end
		push!(toast, lorp)
	end=#
	
end
			

# ╔═╡ b2380c03-6ad8-4011-8e12-1dcf0fd8027c
toast

# ╔═╡ 92bcaa09-0777-4365-b09f-82f5d137baba
function kid_trees_in_shared_space(offspring_trees, adult_trees)
	tree_count= []
	for tree in eachrow(offspring_trees)
		count_overlaps = 0
		for adulttree in eachrow(adult_trees)
			if get_distance(tree, adulttree) < R
				count_overlaps += 1
			end
			
		end
		push!(tree_count, count_overlaps)
	end
	return tree_count
	#will return number of overlapping adult tree circles that that kid tree is hanging out in
end

# ╔═╡ 52ff9693-f2c2-42e3-9211-02b66df20202
begin
	f2, (axi2) = subplots(figsize=(8,8))
	axi2.scatter( K_kidtrees.longitude, K_kidtrees.latitude, label="offspring", color="orange")
	axi2.scatter(K_adulttrees.longitude,  K_adulttrees.latitude, label="adult", color="blue", s=120)
	[plot_circle(K_adulttrees.longitude[i], K_adulttrees.latitude[i], R, axi2) for i in 1:3]

	[axi2.text(K_adulttrees.longitude[i], K_adulttrees.latitude[i],  K_adulttrees.name[i]) for i in 1:3]
	axi2.set_xlabel("Longitude (degrees)", fontsize=15)
	axi2.set_ylabel("Latitude (degrees)", fontsize=15)
	title("Kaua'i Trees and Offspring ", fontsize=20)

	ylim(21.9555, 21.983)
	xlim(-159.725, -159.7)
	
#=	K5
	ylim(22.208,22.216)
	xlim(-159.3875, -159.38)

	#K21
	ylim(21.964,21.972)
	xlim(-159.716, -159.708)

	#K2
	ylim(21.972,21.98)
	xlim(-159.363, -159.371) =#

	gcf()
	# savefig("Kauai_trees_5.png", dpi=500)

	# "Lat Long Kaua'i trees graph"
end

# ╔═╡ 32a4f1f2-cc4f-4c95-902f-f08056373046
begin
	figure()
	hist(K_kidtrees.dists_m, bins=20)
	axvline(median([K_kidtrees.dists_m[j] for j in findall([i <400 for i in K_kidtrees.dists_m])]), color="red", label="median (disregarding points > 400 m)")
	axvline(median(K_kidtrees.dists_m), color="pink", label="median (all points)")
	ylabel("Number of Trees")
	xlabel("Distance to Parent Tree (m)")
	title("Kaua'i Offspring-Parent Distances", fontsize=20)
	legend()
	gcf()
	"Kaua'i Offspring-Parent Distances histogram"
	
end

# ╔═╡ 60cb902c-6648-4708-b070-12622d868fea
begin
	figure()
	bar(1, count(isequal("K2 Offspring"), K_kidtrees.name), label="K2 Offspring")
	bar(2, length(findall([occursin("K3 Offspring", i) for i in K_kidtrees.name])), label = "K3 Offspring")
	bar(3, count(isequal("K4 Offspring"), K_kidtrees.name), label="K4 Offspring")
	bar(4, count(isequal("K5 Offspring"), K_kidtrees.name), label= "K5 Offspring")
	bar(5, count(isequal("K20 Offspring"), K_kidtrees.name), label="K20 Offspring")
	bar(6, length(findall([occursin("K21 Offspring", i) for i in K_kidtrees.name])), label="K21 Offspring")
	bar(7, count(isequal("K73 Offspring"), K_kidtrees.name), label="K73 Offspring")
	bar(8, count(isequal("K80 Offspring"), K_kidtrees.name), label="K80 Offspring")
	xticks([i for i in 1:8], ["K2", "K3", "K4", "K5", "K20", "K21", "K73","K80"])
	xlabel("Parent Tree")
	ylabel("Offspring Count")
	title("Offspring Trees per Parent Tree - Kaua'i")
	gcf()
	"Offspring Trees per Parent Tree - Kaua'i bar graph"
end

# ╔═╡ 3b3162b8-46c7-47da-88e3-e103197436ae
begin
	@pyimport matplotlib as mpl
	@pyimport matplotlib.patches as ptc
	#@pyimport geopandas as gpd
#	@pyimport cartopy.crs as ccrs
end

# ╔═╡ 5c147595-ec5d-4b82-8b52-e129e8ce75dc
begin
	function too_close(tree_i, tree_j)
       		hypotenuse = sqrt((tree_i.latitude - tree_j.latitude)^2 + (tree_i.longitude - tree_j.longitude)^2)
        return hypotenuse < 2*R
    end

   function overlapping_trees(proposed_tree, planted_trees::DataFrame)
		overlapping_circles = 0
        for i in eachrow(planted_trees)
			#check to make sure proposed tree isn't i
			if i != proposed_tree
	            if too_close(proposed_tree, i)
					overlapping_circles += 1
	           end
			end
        end
        return overlapping_circles
	
  end


end

# ╔═╡ 33ec2d3e-a87e-4b3e-9874-19f6d07722f0
begin
	figure()
	scatter(O_adulttrees.num_overlaps, O_adulttrees.area_overlaps, s=5*O_adulttrees.trees_in_circle, alpha=0.3)
	xlabel("Number of Overlapping Circles")
	ylabel(L"Summed \;Area \;of\; Overlap \;(DD^2)")
	axhline(π*R^2, color="r", label="area of one tree circle (R=$R DD)")
	legend()
	title("Adult Tree Circle Analysis - Oahu")
	gcf()
end

# ╔═╡ 36cc6736-725c-4a6e-bcd0-ffde8dc88371
md"To do 
- how will we bring in statistics, KNN?
- Find difference between number of trees *expected* to see within the circle (K) and trees on O, is it significant?	
- what is a better predictor of number of trees within circle, overlap area or number of overlaps? Compared to K?
- number of trees in overlapping circles

"


# ╔═╡ 68be6656-06b8-43a7-b4de-d43fea819214
begin
	figure()
	scatter(O_adulttrees.num_overlaps, O_adulttrees.trees_in_circle,s = 2e6*O_adulttrees.area_overlaps, alpha=0.3)
	xlabel("Number of Overlapping Circles")
	ylabel("Number of Trees in the Circle")
	title("Adult Tree Circle Analysis - Oahu")
	gcf()
end

# ╔═╡ c04ec5c0-fd1c-4eb5-a232-4dc9f04feb04
function get_trees_in_circle(parent_tree, df_kidtrees)
	circle_trees = 0
	for kid_tree in eachrow(df_kidtrees)
		d = get_distance(parent_tree, kid_tree)
		if d <= R
			circle_trees += 1
		end
	end
	return circle_trees
end

# ╔═╡ 5ea415db-4073-4b70-9180-332b7579ada0
begin#=
f3, (ax1, ax2, ax3, ax4, ax5, ax6, ax7, ax8, ax9) = subplots(3,3, figsize=(8,8), sharex=true, sharey=true)
#=	ax1.set_yticks([])
	ax2.set_yticks([])
	ax3.set_yticks([])
	ax4.set_yticks([])
	ax5.set_yticks([])
	ax6.set_yticks([])
	ax7.set_yticks([])
	ax8.set_yticks([])
	ax9.set_yticks([])=#

	
	ax1.set_title("K5", size=15)
	ax4.set_title("K21", size=15)
	ax7.set_title("K2", size=15)
	ax1.set_ylabel("2023", size=15)
	ax2.set_ylabel("2024", size=15)
	ax3.set_ylabel("2025", size=15)

	ax1.hist([K_kidtrees_2023.dists_m[i] for i in findall([occursin("K5 Offspring", i) for i in K_kidtrees_2023.name])])
	ax1.axvline(median([K_kidtrees_2023.dists_m[i] for i in findall([occursin("K5 Offspring", i) for i in K_kidtrees_2023.name])]), color="purple", linestyle="--")
	ax2.hist([K_kidtrees_2024.dists_m[i] for i in findall([occursin("K5 Offspring", i) for i in K_kidtrees_2024.name])])
	ax2.axvline(median([K_kidtrees_2024.dists_m[i] for i in findall([occursin("K5 Offspring", i) for i in K_kidtrees_2024.name])]), color="purple", linestyle="--")
	ax3.hist([K_kidtrees.dists_m[i] for i in findall([occursin("K5 Offspring", i) for i in K_kidtrees.name])])
	ax3.axvline(median([K_kidtrees.dists_m[i] for i in findall([occursin("K5 Offspring", i) for i in K_kidtrees.name])]), color="purple", linestyle="--")
	
	ax4.hist([K_kidtrees_2023.dists_m[i] for i in findall([occursin("K21 Offspring", i) for i in K_kidtrees_2023.name])])
	ax4.axvline(median([K_kidtrees_2023.dists_m[i] for i in findall([occursin("K21 Offspring", i) for i in K_kidtrees_2023.name])]), color="purple", linestyle="--")
	ax5.hist([K_kidtrees_2024.dists_m[i] for i in findall([occursin("K21 Offspring", i) for i in K_kidtrees_2024.name])])
	ax5.axvline(median([K_kidtrees_2024.dists_m[i] for i in findall([occursin("K21 Offspring", i) for i in K_kidtrees_2024.name])]), color="purple", linestyle="--")
	ax6.hist([K_kidtrees.dists_m[i] for i in findall([occursin("K21 Offspring", i) for i in K_kidtrees.name])])
	ax6.axvline(median([K_kidtrees.dists_m[i] for i in findall([occursin("K21 Offspring", i) for i in K_kidtrees.name])]), color="purple", linestyle="--")

	ax7.hist([K_kidtrees_2023.dists_m[i] for i in findall([occursin("K2 Offspring", i) for i in K_kidtrees_2023.name])])
	ax7.axvline(median([K_kidtrees_2023.dists_m[i] for i in findall([occursin("K2 Offspring", i) for i in K_kidtrees_2023.name])]), color="purple", linestyle="--")
	ax8.hist([K_kidtrees_2024.dists_m[i] for i in findall([occursin("K2 Offspring", i) for i in K_kidtrees_2024.name])])
	ax8.axvline(median([K_kidtrees_2024.dists_m[i] for i in findall([occursin("K2 Offspring", i) for i in K_kidtrees_2024.name])]), color="purple", linestyle="--")
	ax9.hist([K_kidtrees.dists_m[i] for i in findall([occursin("K2 Offspring", i) for i in K_kidtrees.name])])
	ax9.axvline(median([K_kidtrees.dists_m[i] for i in findall([occursin("K2 Offspring", i) for i in K_kidtrees.name])]), color="purple", linestyle="--")
	
	ax6.set_xlabel("Distance from Parent Tree (m)",size=20)
	gcf()
#	"Kauai trees by time"
	savefig("Kauai_trees_by_year.png", dpi=500)=#
end
	

# ╔═╡ 82c2344c-6a07-4187-bb30-6ac7918080cc
begin
	figure()
	plot((1,2,3), (
		length(findall([occursin("K5 Offspring", i) for i in K_kidtrees_2023.name])),
		length(findall([occursin("K5 Offspring", i) for i in K_kidtrees_2024.name])),
		length(findall([occursin("K5 Offspring", i) for i in K_kidtrees.name]))),
		color="blue", marker="o", label="K5")
	plot((1,2,3), (
		length(findall([occursin("K21 Offspring", i) for i in K_kidtrees_2023.name])),
		length(findall([occursin("K21 Offspring", i) for i in K_kidtrees_2024.name])),
		length(findall([occursin("K21 Offspring", i) for i in K_kidtrees.name]))),
		color="red", marker="o", label="K21")
	plot((1,2,3), (
		length(findall([occursin("K2 Offspring", i) for i in K_kidtrees_2023.name])),
		length(findall([occursin("K2 Offspring", i) for i in K_kidtrees_2024.name])),
		length(findall([occursin("K2 Offspring", i) for i in K_kidtrees.name]))),
		color="lightgreen", marker="o", label="K2")
	ylabel("Number of Offspring Trees", size=14)
	xticks((1,2,3), ("2023", "2024", "2025"))
	xlabel("Sampling Years", size=14)
	title("Kaua'i Tree Offspring over Time", size=18)
	legend()
	gcf()
	savefig("Kauai_trees_over_time.png", dpi=500)
	"Scatter plot with lines all trees"
end

# ╔═╡ 2374a2a9-97ce-4bd7-8501-1c2fa4cb6b2e
begin
	
	#= f3, (ax1, ax2, ax3, ax4, ax5, ax6, ax7, ax8, ax9) = subplots(3,3, figsize=(8,8), sharey=true)
		ax1.set_yticks([])
		ax2.set_yticks([])
		ax3.set_yticks([])
		ax4.set_yticks([])
		ax5.set_yticks([])
		ax6.set_yticks([])
		ax7.set_yticks([])
		ax8.set_yticks([])
		ax9.set_yticks([])
	
		f3.supxlabel("Distance from Parent Tree (m)", size=20)
		
		ax1.set_title("K5", size=15)
		ax4.set_title("K21", size=15)
		ax7.set_title("K2", size=15)
		ax1.set_ylabel("2023", size=15)
		ax2.set_ylabel("2024", size=15)
		ax3.set_ylabel("2025", size=15)
	
		ax1.boxplot([K_kidtrees_2023.dists_m[i] for i in findall([occursin("K5 Offspring", i) for i in K_kidtrees_2023.name])])
		ax2.boxplot([K_kidtrees_2024.dists_m[i] for i in findall([occursin("K5 Offspring", i) for i in K_kidtrees_2024.name])])
		ax3.boxplot([K_kidtrees.dists_m[i] for i in findall([occursin("K5 Offspring", i) for i in K_kidtrees.name])])
		
		ax4.boxplot([K_kidtrees_2023.dists_m[i] for i in findall([occursin("K21 Offspring", i) for i in K_kidtrees_2023.name])])
		ax5.boxplot([K_kidtrees_2024.dists_m[i] for i in findall([occursin("K21 Offspring", i) for i in K_kidtrees_2024.name])])
		ax6.boxplot([K_kidtrees.dists_m[i] for i in findall([occursin("K21 Offspring", i) for i in K_kidtrees.name])])
	
		ax7.boxplot([K_kidtrees_2023.dists_m[i] for i in findall([occursin("K2 Offspring", i) for i in K_kidtrees_2023.name])])
		ax8.boxplot([K_kidtrees_2024.dists_m[i] for i in findall([occursin("K2 Offspring", i) for i in K_kidtrees_2024.name])])
		ax9.boxplot([K_kidtrees.dists_m[i] for i in findall([occursin("K2 Offspring", i) for i in K_kidtrees.name])])
		
		# ax6.set_xlabel("Distance from Parent Tree (m)", size=20)
		gcf() =#
		"3 x 3 Kauai time graph box and whisker"
	
end

# ╔═╡ 11ed63d2-7d87-4562-973b-d15717ea1d40
begin
	
	f3, (ax1, ax2, ax3, ax4, ax5, ax6, ax7, ax8, ax9) = subplots(3,3, figsize=(8,8), sharey=true, sharex=true)
		ax1.set_yticks([])
		ax2.set_yticks([])
		ax3.set_yticks([])
		ax4.set_yticks([])
		ax5.set_yticks([])
		ax6.set_yticks([])
		ax7.set_yticks([])
		ax8.set_yticks([])
		ax9.set_yticks([])

	ax1.set_yticks(0:5:100)

	#labels
	
		f3.supxlabel("Distance from Parent Tree (m)", size=15)
		
		ax1.set_ylabel("K5\n", size=15)
		ax2.set_ylabel("K21\n\nNumber of Offspring", size=15)
		 ax3.set_ylabel("K2\n", size=15) 
		ax1.set_title("2023", size=15)
		ax4.set_title("2024", size=15)
		ax7.set_title("2025", size=15) 

	#makes histograms
	
		ax1.hist([K_kidtrees_2023.dists_m[i] for i in findall([occursin("K5 Offspring", i) for i in K_kidtrees_2023.name])])
		ax4.hist([K_kidtrees_2024.dists_m[i] for i in findall([occursin("K5 Offspring", i) for i in K_kidtrees_2024.name])])
		ax7.hist([K_kidtrees.dists_m[i] for i in findall([occursin("K5 Offspring", i) for i in K_kidtrees.name])])
		ax2.hist([K_kidtrees_2023.dists_m[i] for i in findall([occursin("K21 Offspring", i) for i in K_kidtrees_2023.name])])
		ax5.hist([K_kidtrees_2024.dists_m[i] for i in findall([occursin("K21 Offspring", i) for i in K_kidtrees_2024.name])])
		ax8.hist([K_kidtrees.dists_m[i] for i in findall([occursin("K21 Offspring", i) for i in K_kidtrees.name])])
		ax3.hist([K_kidtrees_2023.dists_m[i] for i in findall([occursin("K2 Offspring", i) for i in K_kidtrees_2023.name])])
		ax6.hist([K_kidtrees_2024.dists_m[i] for i in findall([occursin("K2 Offspring", i) for i in K_kidtrees_2024.name])])
		ax9.hist([K_kidtrees.dists_m[i] for i in findall([occursin("K2 Offspring", i) for i in K_kidtrees.name])])

	#adding median line
	
		ax1.axvline(median([K_kidtrees_2023.dists_m[i] for i in findall([occursin("K5 Offspring", i) for i in K_kidtrees_2023.name])]), color="red")
		ax4.axvline(median([K_kidtrees_2024.dists_m[i] for i in findall([occursin("K5 Offspring", i) for i in K_kidtrees_2024.name])]), color="red")
		ax7.axvline(median([K_kidtrees.dists_m[i] for i in findall([occursin("K5 Offspring", i) for i in K_kidtrees.name])]), color="red")
		ax2.axvline(median([K_kidtrees_2023.dists_m[i] for i in findall([occursin("K21 Offspring", i) for i in K_kidtrees_2023.name])]), color="red")
		ax5.axvline(median([K_kidtrees_2024.dists_m[i] for i in findall([occursin("K21 Offspring", i) for i in K_kidtrees_2024.name])]), color="red")
		ax8.axvline(median([K_kidtrees.dists_m[i] for i in findall([occursin("K21 Offspring", i) for i in K_kidtrees.name])]), color="red")
		ax3.axvline(median([K_kidtrees_2023.dists_m[i] for i in findall([occursin("K2 Offspring", i) for i in K_kidtrees_2023.name])]), color="red")
		ax6.axvline(median([K_kidtrees_2024.dists_m[i] for i in findall([occursin("K2 Offspring", i) for i in K_kidtrees_2024.name])]), color="red")
		ax9.axvline(median([K_kidtrees.dists_m[i] for i in findall([occursin("K2 Offspring", i) for i in K_kidtrees.name])]), color="red")

		# ax6.set_xlabel("Distance from Parent Tree (m)", size=20)
		gcf()
	#	"3 x 3 Kauai time graph Histogram"
	
end

# ╔═╡ c8fd89d8-a771-4a72-94f7-4cf7c04c31bf
begin
	f, (ax) = subplots(1,1, figsize=(10,8))

	scatter(O_kidtrees.longitude, O_kidtrees.latitude, alpha=0.3, color="red", label="Offspring")
	
	scatter(O_adulttrees.longitude, O_adulttrees.latitude, label="Adult", color="blue")
	#scatter(O_adulttrees.longitude[1], O_adulttrees.latitude[1], label="Adult", color="red")
	# [plot_circle(O_adulttrees.longitude[i], O_adulttrees.latitude[i], R, ax) for i in 1:length(O_adulttrees.latitude)]

#	[ax.text(O_adulttrees.latitude[i], O_adulttrees.longitude[i], O_adulttrees.name[i]) for i in 1:length(O_adulttrees.name)]
	ylabel("Latitude (degrees)", fontsize=14)
	xlabel("Longitude (degrees)", fontsize=14)
	ylim(21.27, 21.33)
	xlim(-157.88, -157.8)

#Zoom into Foster tree
#		ylim(21.316, 21.32)
#		xlim(-157.865, -157.82)

begin 
	legend()
	title("Honolulu Trees and Offspring", fontsize=20)
	

end 
	gcf()
#	savefig("Hono_trees.png", dpi=500)
#	"Honolulu/Oahu"
end

# ╔═╡ 087e57ab-aaea-48d6-b3ad-703d97d41b17
function overlap_area(tree_1, df)
	areaofoverlap = 0
	for eachtree in eachrow(df)
		if tree_1 != eachtree
			d = get_distance(tree_1, eachtree)
			if 0 < d < 2*R
				#meaning that there is some overlap but not complete
			#	θ = 2*acos(d/(2*R))
				#probably double check this equation
			#	A = R^2*(θ-sin(θ))
				A = 2*(R^2*acos(d/(2*R))-d/4*sqrt(4*R^2-d^2))
			elseif d == 0
				A = π*R^2
			elseif d >= 2*R
				A = 0
			end
			areaofoverlap += A
		end
		
	end
	return areaofoverlap
end

# ╔═╡ c4df8f67-ca37-4c12-bd01-5927c90a5fab
begin
	O_adulttrees[!, :num_overlaps] = [overlapping_trees(O_adulttrees[i, :], O_adulttrees) for i in 1:29]
	O_adulttrees[!, :area_overlaps] = [overlap_area(i, O_adulttrees) for i in eachrow(O_adulttrees)]
	O_adulttrees[!, :trees_in_circle] = [get_trees_in_circle(i, O_kidtrees) for i in eachrow(O_adulttrees)]

	O_kidtrees[!, :num_near_adults] = kid_trees_in_shared_space(O_kidtrees, O_adulttrees)
"Adding columns to O_adulttrees and O_kidtrees"
end

# ╔═╡ 4a3352b3-e602-4c60-a79b-73204d6abe3b
begin
	function bootstrap_t_test(data1, data2, n_boot = 1000)
		n1 = length(data1)
		n2 = length(data2)
		t_stat = n_boot
		ps = []
		for i in 1:n_boot
			sample1 = sample(data1, n1, replace= true)
			sample2 = sample(data2, n2, replace = true)
			test = MannWhitneyUTest(sample1, sample2)
			push!(ps, pvalue(test))
		end
		return ps
	end
end
			

# ╔═╡ f21bebb5-ed9d-467e-bfaf-c8933faa5c3f
pvalue(ExactMannWhitneyUTest(O_adulttrees.trees_in_circle, K_adulttrees.trees_in_circle))

# ╔═╡ Cell order:
# ╠═48706b3a-b446-11f0-263e-efa02e2f00be
# ╠═2d0d97ad-582d-4caf-a10b-9f696833bd1a
# ╠═b8d4de68-90a5-49fa-9587-699406b4d9d2
# ╠═54724e2f-4d2c-493d-9684-24d475eed18a
# ╠═84da0ed1-4a17-4556-ad4c-20603e371123
# ╟─026c47f9-a8f8-48b9-acf4-94365d27aa77
# ╟─76c7835c-8386-4a45-9f9d-80a735f01a09
# ╟─73524a92-aecb-46b7-8a5a-8a099f6c4e3b
# ╟─c4df8f67-ca37-4c12-bd01-5927c90a5fab
# ╟─bbecb116-bf11-4d95-a78c-95fd6e0e2b39
# ╠═c98fd90d-179b-43be-a272-373e16652579
# ╠═b2380c03-6ad8-4011-8e12-1dcf0fd8027c
# ╟─1f0cad71-bad1-41ac-ab99-43ad9188a42f
# ╠═27025ecc-9afd-4c33-ace6-9d90773b4187
# ╠═38fdab57-cc18-47a5-bcac-1f6c40882374
# ╠═92bcaa09-0777-4365-b09f-82f5d137baba
# ╟─0e79c7fd-a60c-492e-9b9b-a1598f586959
# ╟─b513b08a-e041-4fa3-8e4d-21a2c79d9fda
# ╠═52ff9693-f2c2-42e3-9211-02b66df20202
# ╟─32a4f1f2-cc4f-4c95-902f-f08056373046
# ╟─60cb902c-6648-4708-b070-12622d868fea
# ╟─3b3162b8-46c7-47da-88e3-e103197436ae
# ╟─5c147595-ec5d-4b82-8b52-e129e8ce75dc
# ╠═33ec2d3e-a87e-4b3e-9874-19f6d07722f0
# ╠═36cc6736-725c-4a6e-bcd0-ffde8dc88371
# ╠═68be6656-06b8-43a7-b4de-d43fea819214
# ╟─c04ec5c0-fd1c-4eb5-a232-4dc9f04feb04
# ╟─5ea415db-4073-4b70-9180-332b7579ada0
# ╟─82c2344c-6a07-4187-bb30-6ac7918080cc
# ╠═2374a2a9-97ce-4bd7-8501-1c2fa4cb6b2e
# ╠═11ed63d2-7d87-4562-973b-d15717ea1d40
# ╠═c8fd89d8-a771-4a72-94f7-4cf7c04c31bf
# ╟─087e57ab-aaea-48d6-b3ad-703d97d41b17
# ╠═4a3352b3-e602-4c60-a79b-73204d6abe3b
# ╠═f21bebb5-ed9d-467e-bfaf-c8933faa5c3f
