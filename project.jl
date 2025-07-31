### A Pluto.jl notebook ###
# v0.20.6

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 053c2f95-3e3a-4553-b9dd-cbeaca5b1cf2
using CairoMakie, CodecZstd, CSV, DataFrames, Dates, PlutoUI, UUIDs, JSON, JSON3, Statistics, Test , ColorSchemes

# ╔═╡ c2f30e90-51fd-11f0-2863-5969556662c5
md"""
# Scientific Programming Project - Tageschau Mining G17


Hamburg University of Technology TUHH

* 👨‍🏫 Dhia Eddine Moula
* 👨‍🏫 Mohamed Ali Berriri
* 👨‍🏫 Arbi Zhabjaku
* 👨‍🏫 Besard Zhabjaku

"""

# ╔═╡ 25c33c93-9419-429c-8698-252af8c122b7
PlutoUI.TableOfContents()

# ╔═╡ 2b1a5731-bb66-4d99-88c1-2a39772e5ec4
md"""
## First Interaction with Data
### Tagesschau CSV File
"""

# ╔═╡ 28ff7e90-f8fa-43e9-8f06-24c252ad921f
begin

	#open tagesschau.csv
	df_tagsschau = CSV.read("tagesschau.csv/tagesschau.csv",DataFrame)
	#df_tagsschau
	
end


# ╔═╡ 4afa4a5f-49e4-48fd-a949-7dc195b6f5c4
describe(df_tagsschau)

# ╔═╡ ba7150f6-3471-45ae-a02d-0dddc4dad61a
@show size(df_tagsschau)

# ╔═╡ 43e9025a-bb84-4774-b4fc-1b48d29e909d
#extract column names:
names(df_tagsschau)

# ╔═╡ c154f08d-a24d-47fc-8470-fea125d0cc52
#extract dates
df_tagsschau_dates = df_tagsschau[!,:datetimepublished]

# ╔═╡ c3cd5678-0f4c-4b84-a2bb-b72ac6027d1f
df_tag_1 = select(df_tagsschau, :datetimepublished, :title)

# ╔═╡ 14ef35ff-1ed3-4e55-ace7-5649129d8ae0
@bind i PlutoUI.Slider(2:ncol(df_tagsschau))

# ╔═╡ d335e9b5-68e5-4df5-95d2-3e9d235ac9a8
#df_summary = combine(groupby(df_tag_1, :date_only), nrow => :count)

# ╔═╡ 0c61f375-8dc0-4dd7-a31c-5c026bb5c354
df_summary = begin
    df_tag_1_transformed = transform(df_tag_1, :datetimepublished => ByRow(x -> Date(x)) => :date_only)
    combine(groupby(df_tag_1_transformed, :date_only), nrow => :count)
end

# ╔═╡ ecefd7a7-a6fe-4381-af85-158c298e478a
md"""
* We can now test the coorctness of the dates extracted based on their format
"""

# ╔═╡ b97287af-2cc3-40a1-b645-057748db107b
@testset "Date Format and type" begin
	@test df_summary.date_only[1] == Date("2022-03-14")
	@test typeof(df_summary.date_only[1]) == Date
end

# ╔═╡ cc8191f4-8f1c-430f-85a0-149923971bab
length(df_summary.date_only)

# ╔═╡ 5a5cf68b-1f57-4147-89f4-d35b5e2d3c81
md"""
* Visualize the titles over date
"""

# ╔═╡ 60eb06e7-b29b-4d06-8329-1e30181a438d
@bind date_range PlutoUI.Slider(1:size(df_summary, 1); show_value=true)

# ╔═╡ 81df4744-af53-4b03-8d14-ea1a76630de3
let

	fig1 = Figure()
	
	#numdates = length(df_tagsschau_dates)
	
	df_tag_1.date_only = Date.(df_tag_1[:, 1])

	# Count articles per day
	df_summary = combine(groupby(df_tag_1, :date_only), nrow => :count)

	numdates = size(df_summary, 1)
	x_indices = 1:numdates

	#with Slider:
	xs = 1:date_range
	ys = df_summary.count[1:date_range]

	
	#df_tag_1[:, 1] = DateTime.(df_tag_1[:, 1], dateformat"yyyy-mm-ddTHH:MM:SS")
	
	ax1 = Axis(fig1[1,1]; xlabel="Date", ylabel="Count")

	#Standard Plot:
	#CairoMakie.scatterlines!(ax1, x_indices, df_summary.count)

	#With Slider:
	CairoMakie.scatterlines!(ax1, xs,ys)
	#Add xticks with date labels
	tick_step = max(1, length(xs) ÷ 10)
	xtick_pos = 1:tick_step:length(xs)
	xtick_labels = string.(df_summary.date_only[xtick_pos])
	ax1.xticks = (xtick_pos, xtick_labels)
	ax1.xticklabelrotation = π/4
	
	# X-Axis labels with rotation:
	
	#tick_step = max(1, numdates ÷ 10)
	#xtick_positions = 1:tick_step:numdates
	#xtick_labels = string.(df_summary.date_only[xtick_positions])
	#ax1.xticks = (xtick_positions, xtick_labels)
	#ax1.xticklabelrotation = π / 4

	fig1
	





end

# ╔═╡ 39652dd5-2877-41ca-b362-4641b344fe7f
@testset "Date conversion and grouping" begin
    df = DataFrame(datetimepublished = ["2024-01-01T12:00:00", "2024-01-01T13:00:00", "2024-01-02T09:00:00"])
    df.datetimepublished = DateTime.(df.datetimepublished, dateformat"yyyy-mm-ddTHH:MM:SS")
    df.date_only = Date.(df.datetimepublished)

    df_summary = combine(groupby(df, :date_only), nrow => :count)

    @test df_summary[1, :count] == 2
    @test df_summary[2, :count] == 1
    @test df_summary[1, :date_only] == Date("2024-01-01")
end

# ╔═╡ 719ca298-9e87-4974-8e83-f87e10afe720
df_summary

# ╔═╡ ffc1386c-8220-4df4-bcb2-04b6c81625b4
md"""
* Visualizing when the are nothing published:
  Here we can say that there is at least one title pulished everyday, because we didn't find any day with 0 titles
"""

# ╔═╡ a7a988ba-cee5-4044-88fc-3b092ddc3b5e
df_zerotitles = filter(:count => ==(0), df_summary)

# ╔═╡ 688f4992-987e-404c-be11-00c56f573d24
md"""
* we extract the number of titles published on the days of the week
"""

# ╔═╡ 0ed5bcdc-5750-4cbd-94bb-c553379c9463
df_tag_1_transformed.date_only[1,]

# ╔═╡ 1a5215ef-6d48-479c-8179-e846fe5570df
df_tag_1

# ╔═╡ ee80eb22-579f-454b-9d48-6566f0243bc3
begin

	df_tag_1.dayofweek = dayname.(df_tag_1_transformed.date_only)
	#test for the format of the date: yyyy-mm-dd

	@test df_tag_1_transformed.date_only[1,] == Date("2022-03-14")

	#explicit way: 

	if df_tag_1_transformed.date_only[1,] == Date("2022-03-14")
		println("Correct_Date_Format_Test passed ✅")
	else
		println("❌ Test failed")
	end

	###########################################################################
	
	df2 = combine(groupby(df_tag_1, :dayofweek), nrow => :count)
	#test the number of days: should equal to 7
	@test size(df2.dayofweek) == (7,)

	#explicit test:
	if size(df2.dayofweek) == (7,)
		println("Number_Of_Days_of_Week_Test passed ✅")
	else
		throw(ErrorException("❌ Test failed"))
	end
end

# ╔═╡ a60d543c-fac1-488a-85ea-ad38b3470bfc
df2

# ╔═╡ 46796755-758b-445e-92e1-273266a08abb
size(df2.dayofweek)

# ╔═╡ c0a88f7c-0c89-47c5-bb13-c839b97e12db
@testset "Dayofweek numbers" begin

	#

end

# ╔═╡ 5de7bbb3-d723-4207-907d-dcb6e2df363b
begin
	
	fig2 = Figure()
	ax2 = Axis(fig2[1,1]; xlabel="Weekdays", ylabel="Count")

	numdates2 = size(df2, 1)
	x_indices2 = 1:numdates2

	
	CairoMakie.scatterlines!(ax2, x_indices2, df2.count, marker=:star5, markersize=20)

	#tick_step = max(1, length() ÷ 10)
	xtick_pos2 = 1:1:length(x_indices2)
	xtick_labels2 = string.(df2.dayofweek[xtick_pos2])
	ax2.xticks = (xtick_pos2, xtick_labels2)
	ax2.xticklabelrotation = π/4

	fig2

end

# ╔═╡ 34924be8-11fe-40ce-9859-76d978f951bd
md"""
* from here we can see that most of the titles are published during the week and mostly at fridays. At the weekends the numbers drop significally

"""

# ╔═╡ c65dc97a-6d83-40a4-80ac-04d7e6fa5e51
md"""
* we can also look at the number of titles published during the hours of the day
"""

# ╔═╡ 0b350b42-60c6-4cba-85f9-b614f8cd409d
let 
	
	timedf = select(df_tagsschau,:datetimepublished=>(x -> hour.(x))=>:timepublished)
	gdf = groupby(timedf, :timepublished)
	cgdf = sort!(combine(gdf, nrow),:timepublished)

	xs = cgdf[!,:timepublished]
	ys = cgdf[!,:nrow]

	f = Figure()
	Axis(f[1, 1], 
		xlabel = "time of day", 
		ylabel = "totalnumber of articles published",
		xticks = 0:4:23)
	
	barplot!(xs, ys, fillto = 0, strokecolor = :black, strokewidth = 1)
	
	f
end

# ╔═╡ 321acd7e-811a-4505-acce-e9ee80746dd9
md"""
* here w can see the number of titles that were published at different hours of the day. They are mainly published between 11AM and 17AM and also in the early hours of the morning: between 4 and 7 AM
"""

# ╔═╡ 838bdf25-5111-451f-8279-4b9cf01ea668
let 
	daytimedf = select(df_tagsschau,:datetimepublished=>(x -> hour.(x))=>:timepublished, :datetimepublished=>(x -> dayofweek.(x))=>:daypublished)
	gdf = groupby(daytimedf, [:daypublished,:timepublished])
	cgdf = sort!(combine(gdf, nrow),[:daypublished,:timepublished])

	xs = cgdf[!,:timepublished]
	ys = cgdf[!,:daypublished]
	reductionfactor = 6

	f = Figure(size = (700, 300))
	ax = Axis(f[1, 1], 
		xlabel = "Time of day", 
		ylabel = "Day of week",
		xticks = 0:4:23,
		yticks = (1:7,["mon","tue","wed","thu","fri","sat","sun"]))
	CairoMakie.scatter!(ax, xs, ys, marker = :rect, markersize = cgdf[!,:nrow]/reductionfactor, strokewidth=1)

	
	colors = Makie.wong_colors()
	markersizes = [20, 50, 100, 200]./reductionfactor
	labels = ["20", "50", "100", "200"]
	elements = [MarkerElement(marker = :rect, color = colors[1], markersize = ms, strokewidth=1) for ms in markersizes]
	title = " Publications"

	Legend(f[1,2], elements, labels, title)
	
	f
end

# ╔═╡ bef7ff26-ece2-4427-b19d-87caab33d93b
md"""

### Tags CSV File


"""

# ╔═╡ ed4cd90a-f0ff-4dc8-a26f-84d673b7b645
begin

	#open tags.csv
	df_tags = CSV.read("tags.csv/tags.csv",DataFrame) 

end

# ╔═╡ e1409e55-4221-423b-b06e-158216d9496b
size(df_tags)

# ╔═╡ 27ff3362-d00a-4a47-b6ba-7794c7a6a8a7
#extract columns
names(df_tags)

# ╔═╡ c62de334-4a7b-4ba3-9bce-6eb6f1eb8fff
#extract tag column
df_tags[!,:tag]

# ╔═╡ d5f1ef02-650e-4243-9aff-5c2580123351
md"""

### Geotags CSV File


"""

# ╔═╡ 276930d5-d903-4e80-bad2-e23c07f30336
begin

	#open geotags.csv
	df_geotags = CSV.read("geotags.csv/geotags.csv",DataFrame) 


end

# ╔═╡ 1faaf5fb-d991-492e-b311-bfa74e7de880
size(df_geotags)

# ╔═╡ 5c19f985-5db1-45e5-a745-36788507d26a
#extract columns
names(df_geotags)

# ╔═╡ 30cf0460-f500-4e61-81bd-19757e61bcd5
@info df_geotags[!,:tag]

# ╔═╡ 204ede19-8f3f-4165-a9c2-b181a9f53b68
# enhanced-geotags-analysis
md"""

**Analysis Overview:**
This section provides comprehensive analysis of geographic location data from the Tagesschau dataset.
"""

# ╔═╡ e8d37e5d-b0fa-43c8-991d-c1f9f4031fc1
# geotags-quality-assessment
begin

	total_rows = nrow(df_geotags)
    # Enhanced geotags data loading with quality assessment
    invalid_entries = sum(df_geotags.tag .== "(Keine Auswahl)")
	@test invalid_entries < total_rows
	
    valid_entries = nrow(df_geotags) - invalid_entries
	@test valid_entries <= total_rows
	
    data_quality = round(valid_entries/nrow(df_geotags)*100, digits=1)
    
    md"""
    **📊 GEOTAGS DATA QUALITY ASSESSMENT**
    
    **Original Data Structure:**
    - Total rows: $(nrow(df_geotags))
    - Columns: $(names(df_geotags))
    - Data types: $(eltype.(eachcol(df_geotags)))
    
    **Data Quality Metrics:**
    - Invalid entries (Keine Auswahl): $invalid_entries
    - Valid entries: $valid_entries
    - Data quality: $data_quality%
    """
end


# ╔═╡ 55f7428c-ea18-4db7-9f70-ccadd057b4c1
# geotags-data-cleaning
begin
	original_entries = nrow(df_geotags)
    # Clean geotags data by removing invalid entries
    geotags_clean = filter(row -> row.tag != "(Keine Auswahl)", df_geotags)
    @test nrow(geotags_clean) <= original_entries
	
    removed_entries = nrow(df_geotags) - nrow(geotags_clean)
	
    retention_rate = round(nrow(geotags_clean)/nrow(df_geotags)*100, digits=1)
    
    md"""
    **🧹 DATA CLEANING COMPLETED**
    - Original dataset: $(nrow(df_geotags)) entries
    - Cleaned dataset: $(nrow(geotags_clean)) entries
    - Removed entries: $removed_entries
    - Retention rate: $retention_rate%
    """
end

# ╔═╡ 15622afa-6a7f-43a5-bcfc-ba2960639747
# geotags-frequency-analysis
begin
    # Calculate frequency of each geotag
    geo_counts = combine(groupby(geotags_clean, :tag), nrow => :count)
    sort!(geo_counts, :count, rev=true)
    
    # Display top locations
    top_locations = first(geo_counts, min(15, nrow(geo_counts)))
    
    location_list = join([string(i, ". ", row.tag, ": ", row.count, " mentions") 
                         for (i, row) in enumerate(eachrow(top_locations))], " ")
    
    md"""
    **📍 TOP 15 MOST FREQUENT GEOTAGS:**
    
    $location_list
    """
end


# ╔═╡ 8811e4b5-e6fc-498a-a7a7-c34bca563319
# statistical-analysis
begin
    # Calculate comprehensive statistics
    total_locations = nrow(geo_counts)
    total_mentions = sum(geo_counts.count)
    avg_frequency = round(mean(geo_counts.count), digits=2)
    median_frequency = median(geo_counts.count)
    max_frequency = maximum(geo_counts.count)
    most_common = geo_counts.tag[1]
    single_mentions = sum(geo_counts.count .== 1)
    top_10_coverage = sum(geo_counts.count[1:min(10, nrow(geo_counts))])
    coverage_percent = round(top_10_coverage/total_mentions*100, digits=1)
    single_percent = round(single_mentions/total_locations*100, digits=1)
    
    md"""
    **📊 COMPREHENSIVE STATISTICAL ANALYSIS**
    
    **📍 Geographic Coverage:**
    - Total unique locations: $total_locations
    - Total geotag mentions: $total_mentions
    - Locations mentioned once: $single_mentions ($single_percent%)
    
    **📈 Frequency Distribution:**
    - Average mentions per location: $avg_frequency
    - Median mentions per location: $median_frequency
    - Most mentioned location: $most_common ($max_frequency mentions)
    
    **🎯 Concentration Analysis:**
    - Top 10 locations cover: $coverage_percent% of all mentions
    """
end


# ╔═╡ 59fcf722-5e33-4e83-ad00-a737aa60a893
# primary-visualization-bar-chart
let
    # Create professional bar chart of top geotags
    top_n = min(15, nrow(geo_counts))
    top_geotags = first(geo_counts, top_n)
    
    xs = 1:top_n
    ys = top_geotags.count
    labels = top_geotags.tag
    
    # Normalize counts to [0,1] for viridis colormap
    min_y, max_y = minimum(ys), maximum(ys)
    range_y = max_y - min_y
    if range_y == 0
        norm_ys = fill(0.5, length(ys))
    else
        norm_ys = (ys .- min_y) ./ range_y
    end

    # Map to viridis colors
    colors = [get(ColorSchemes.viridis, n) for n in norm_ys]

    f = Figure(size = (1000, 700))
    ax = Axis(f[1, 1], 
        xlabel = "Geographic Location", 
        ylabel = "Number of Mentions",
        title = "Top $top_n Most Frequently Mentioned Geographic Locations",
        xticklabelrotation = π/3
    )
    
    # Use viridis colors
    barplot!(ax, xs, ys, 
        color = colors,
        strokecolor = :black, 
        strokewidth = 1.5
    )
    
    # Add value labels on top of bars
    for i in 1:top_n
        text!(ax, i, ys[i] + maximum(ys) * 0.01, text = string(ys[i]), 
              align = (:center, :bottom), fontsize = 10)
    end
    
    # X-axis labels and grid styling
    ax.xticks = (xs, labels)
    ax.xgridvisible = false
    ax.ygridvisible = true
    ax.ygridcolor = (:gray, 0.3)
    
    f
end


# ╔═╡ bca79309-83d6-4791-9081-ccd4ca389441
@bind min_frequency_threshold PlutoUI.Slider(1:maximum(geo_counts.count), default=1, show_value=true)

# ╔═╡ 04f8c95d-41a6-4f46-9952-6c528a929bc2

begin
    # Filter data based on slider selection
    filtered_geo = filter(row -> row.count >= min_frequency_threshold, geo_counts)
    filtered_coverage = sum(filtered_geo.count) / sum(geo_counts.count) * 100
    
    # Create filtered location list
    top_filtered = first(filtered_geo, min(10, nrow(filtered_geo)))
    filtered_list = join([string("• ", row.tag, " (", row.count, " mentions)") 
                         for row in eachrow(top_filtered)], "\n")
    
    additional_text = nrow(filtered_geo) > 10 ? "\n\n... and $(nrow(filtered_geo) - 10) more locations" : ""
    
    md"""
    **🔍 INTERACTIVE FILTER RESULTS**
    
    **Filter Settings:**
    - Minimum frequency threshold: $min_frequency_threshold
    - Locations meeting criteria: $(nrow(filtered_geo))
    - Coverage of total mentions: $(round(filtered_coverage, digits=1))%
    
    """
end


# ╔═╡ 57b47319-6fa4-48f4-81cd-8b086b6cfa1c
# country-city-analysis
begin
    # Function to detect country from city names
    function detect_country_from_city(city_name)
        city_lower = lowercase(string(city_name))
        
        # German cities
        if any(occursin.(["berlin", "münchen", "hamburg", "köln", "frankfurt", 
                         "stuttgart", "düsseldorf", "dortmund", "essen", "leipzig", 
                         "bremen", "dresden", "hannover", "nürnberg", "duisburg",
                         "bochum", "wuppertal", "bielefeld", "bonn", "münster"], 
                        [city_lower]))
            return "Germany"
            
        # Israeli cities
        elseif any(occursin.(["tel aviv", "jerusalem", "haifa", "beer sheva"], [city_lower]))
            return "Israel"
            
        # US cities
        elseif any(occursin.(["detroit", "new york", "los angeles", "chicago", "houston", 
                             "philadelphia", "phoenix", "san antonio", "washington"], [city_lower]))
            return "United States"
            
        # Spanish cities (including territories)
        elseif any(occursin.(["palma de mallorca", "madrid", "barcelona", "valencia", 
                             "sevilla", "bilbao", "mallorca", "palma"], [city_lower]))
            return "Spain"
            
        # French cities
        elseif any(occursin.(["paris", "lyon", "marseille", "toulouse", "nice", 
                             "strasbourg", "bordeaux", "lille", "nantes"], [city_lower]))
            return "France"
            
        # UK cities
        elseif any(occursin.(["london", "manchester", "birmingham", "glasgow", 
                             "liverpool", "edinburgh", "bristol", "leeds"], [city_lower]))
            return "United Kingdom"
            
        # Austrian cities
        elseif any(occursin.(["wien", "salzburg", "innsbruck", "graz", "linz"], [city_lower]))
            return "Austria"
            
        # Swiss cities  
        elseif any(occursin.(["zürich", "genf", "basel", "bern", "lausanne"], [city_lower]))
            return "Switzerland"
            
        # Italian cities
        elseif any(occursin.(["rom", "mailand", "neapel", "turin", "palermo", "roma", "milano"], [city_lower]))
            return "Italy"
            
        else
            return "Other/Unknown"
        end
    end
    
    # Apply country detection to existing cleaned geotags data
    geotags_with_countries = transform(geotags_clean, 
        :tag => ByRow(detect_country_from_city) => :country)
    
    # Filter out unknown countries for analysis
    geotags_known_countries = filter(row -> row.country != "Other/Unknown", geotags_with_countries)
    
    # Group by country and find most mentioned city per country
    country_city_analysis = combine(groupby(geotags_known_countries, :country)) do group
        # Sort cities by frequency within each country
        city_counts = combine(groupby(group, :tag), nrow => :city_mentions)
        sort!(city_counts, :city_mentions, rev=true)
        
        # Get the most mentioned city
        top_city = city_counts.tag[1]
        top_mentions = city_counts.city_mentions[1]
        total_cities = nrow(city_counts)
        total_country_mentions = sum(city_counts.city_mentions)
        city_dominance = round(top_mentions/total_country_mentions*100, digits=1)
        
        return (
            most_mentioned_city = top_city,
            city_mentions = top_mentions,
            total_cities_in_country = total_cities,
            total_country_mentions = total_country_mentions,
            city_dominance_percent = city_dominance
        )
    end
    
    # Sort by city mentions (descending)
    sort!(country_city_analysis, :city_mentions, rev=true)
    
    # Calculate summary statistics
    total_countries_detected = nrow(country_city_analysis)
    total_analyzed_mentions = sum(country_city_analysis.total_country_mentions)
    coverage_percentage = round(total_analyzed_mentions/sum(geo_counts.count)*100, digits=1)
    
    md"""
    # 🌍 Most Mentioned City per Country Analysis
    
    **Detection Summary:**
    - **Countries detected**: $total_countries_detected
    - **Total mentions analyzed**: $total_analyzed_mentions
    - **Coverage of total geotag data**: $coverage_percentage%
    
    **Results by Country (Ranked by City Mentions):**
    
    $(join([string("**", row.country, "**: ", row.most_mentioned_city, " (", 
                   row.city_mentions, " mentions, ", row.city_dominance_percent, 
                   "% dominance, ", row.total_cities_in_country, " cities total)") 
            for row in eachrow(country_city_analysis)], "\n\n"))
    """
end


# ╔═╡ 4cf0f186-d83d-40b4-b2a5-c1b9a8087d07
# country-city-visualization
let
    # Create visualization showing most mentioned cities per country
    countries = country_city_analysis.country
    cities = country_city_analysis.most_mentioned_city
    mentions = country_city_analysis.city_mentions

    # Normalize mentions for colormap
    min_m, max_m = minimum(mentions), maximum(mentions)
    range_m = max_m - min_m
    if range_m == 0
        norm_mentions = fill(0.5, length(mentions))
    else
        norm_mentions = (mentions .- min_m) ./ range_m
    end

    # Generate viridis colors
    colors = [get(ColorSchemes.viridis, n) for n in norm_mentions]

    f = Figure(size = (1000, 600))
    ax = Axis(f[1, 1], 
        xlabel = "Country", 
        ylabel = "Mentions of Top City",
        title = "Most Mentioned City per Country",
        xticklabelrotation = π/4
    )
    
    xs = 1:length(countries)
    barplot!(ax, xs, mentions, 
        color = colors,
        strokecolor = :black, 
        strokewidth = 1.5
    )
    
    # Add city names and mention counts as labels
    for i in 1:length(countries)
        text!(ax, i, mentions[i] + maximum(mentions) * 0.02, 
              text = string(cities[i], "\n(", mentions[i], ")"), 
              align = (:center, :bottom), fontsize = 9, fontweight = :bold)
    end
    
    ax.xticks = (xs, countries)
    ax.ygridvisible = true
    ax.ygridcolor = (:gray, 0.3)
    ax.xgridvisible = false
    
    f
end


# ╔═╡ 17787a33-ba73-465c-bc04-45482ae59d70
# germany-coordinates-setup
begin
    # Comprehensive German city coordinates mapping
    function get_german_coordinates(city_name)
        city_lower = lowercase(string(city_name))
        
        german_coords = Dict(
            "berlin" => (52.5200, 13.4050),
            "münchen" => (48.1351, 11.5820),
            "hamburg" => (53.5511, 9.9937),
            "köln" => (50.9375, 6.9603),
            "frankfurt" => (50.1109, 8.6821),
            "stuttgart" => (48.7758, 9.1829),
            "düsseldorf" => (51.2277, 6.7735),
            "hannover" => (52.3759, 9.7320),
            "bremen" => (53.0793, 8.8017),
            "dresden" => (51.0504, 13.7373),
            "leipzig" => (51.3397, 12.3731),
            "nürnberg" => (49.4521, 11.0767),
            "dortmund" => (51.5136, 7.4653),
            "essen" => (51.4508, 7.0131),
            "duisburg" => (51.4344, 6.7623),
            "bochum" => (51.4818, 7.2196),
            "wuppertal" => (51.2562, 7.1508),
            "bielefeld" => (52.0302, 8.5325),
            "bonn" => (50.7374, 7.0982),
            "münster" => (51.9607, 7.6261)
        )
        
        for (city, coords) in german_coords
            if occursin(city, city_lower)
                return coords
            end
        end
        
        return nothing
    end
    
    # Filter for German locations only using your existing country detection
    german_geotags = filter(row -> detect_country_from_city(row.tag) == "Germany", geo_counts)
    
    # Add coordinates
    german_coords = [get_german_coordinates(tag) for tag in german_geotags.tag]
    german_mask = .!isnothing.(german_coords)
    
    german_geotags_final = german_geotags[german_mask, :]
    german_coords_final = german_coords[german_mask]
    
    german_geotags_final.latitude = [coord[1] for coord in german_coords_final]
    german_geotags_final.longitude = [coord[2] for coord in german_coords_final]
    
    md"""
    # 🇩🇪 German Geographic Coverage Analysis
    
    **German Cities Identified**: $(nrow(german_geotags_final))
    **Total German Mentions**: $(sum(german_geotags_final.count))
    **Geographic Span**: $(round(maximum(german_geotags_final.latitude) - minimum(german_geotags_final.latitude), digits=1))° latitude
    """
end


# ╔═╡ 4acb37fb-2513-4e04-bdd6-c803d05a47a0
# germany-controls
begin
    md"""
    ### 🎛️ Germany Heatmap Controls
    
    **Customize German geographic visualization:**
    """
end


# ╔═╡ 5c67f591-f14b-4a4e-942d-26cb0d665c40
# germany-sliders
begin
    @bind germany_colormap PlutoUI.Select([
        :hot => "Hot (Red-Yellow)",
        :plasma => "Plasma (Purple-Pink-Yellow)",
        :viridis => "Viridis (Blue-Purple-Yellow)",
        :inferno => "Inferno (Black-Red-Yellow)"
    ], default=:hot)
    
    @bind germany_min_mentions PlutoUI.Slider(1:maximum(german_geotags_final.count), 
                                             default=1, show_value=true)
end


# ╔═╡ f24929fa-6c6e-4280-a2de-65c698e1f44f
# dynamic-germany-heatmap
let
    # Apply filtering based on controls
    filtered_german = filter(row -> row.count >= germany_min_mentions, german_geotags_final)
    
    if nrow(filtered_german) > 0
        f = Figure(size = (1000, 600))
        
        ax = Axis(f[1, 1],
            xlabel = "Longitude (°E)",
            ylabel = "Latitude (°N)",
            title = "Filtered Germany Coverage (≥$(germany_min_mentions) mentions)",
            aspect = DataAspect()
        )
        
        # German bounds
        xlims!(ax, 5.5, 15.5)
        ylims!(ax, 47, 55.5)
        
        # Extract filtered data
        lats_f = filtered_german.latitude
        lons_f = filtered_german.longitude
        freqs_f = filtered_german.count
        labels_f = filtered_german.tag
        
        # Enhanced scaling with safe fallback
        log_freqs_f = log10.(freqs_f .+ 1)
        min_f, max_f = minimum(log_freqs_f), maximum(log_freqs_f)
        range_f = max_f - min_f

        if range_f == 0
            norm_freqs_f = fill(0.5, length(log_freqs_f))
        else
            norm_freqs_f = (log_freqs_f .- min_f) ./ range_f
        end
        
        # Dynamic sizing with minimum
        marker_sizes_f = 20 .+ norm_freqs_f .* 60
        marker_sizes_f = max.(marker_sizes_f, 5)
        
        # 🌿 Viridis color mapping: most frequent → yellow-green, least → dark blue
        colors_f = [get(ColorSchemes.viridis, norm) for norm in norm_freqs_f]
        
        # Main scatter plot
        scatter!(ax, lons_f, lats_f,
            markersize = marker_sizes_f,
            color = colors_f,
            strokewidth = 2,
            strokecolor = :white,
            alpha = 0.85
        )
        
        # Labels with clear style
        for i in 1:length(labels_f)
            text!(ax, lons_f[i] + 0.1, lats_f[i] + 0.1,
                  text = string(labels_f[i], " (", freqs_f[i], ")"),
                  fontsize = 10,
                  fontweight = :bold,
                  color = :black,
                  strokecolor = :black,
                  strokewidth = 1.2)
        end
        
        # Grid & colorbar
        ax.xgridvisible = true
        ax.ygridvisible = true
        ax.xgridcolor = (:gray, 0.3)
        ax.ygridcolor = (:gray, 0.3)
        
        Colorbar(f[1, 2], 
            colormap = :viridis,
            colorrange = (0, 1),
            label = "Normalized Frequency",
            width = 20
        )
        
        f
    else
        f = Figure(size = (600, 300))
        ax = Axis(f[1, 1], title = "No German cities meet current threshold")
        text!(ax, 0.5, 0.5, text = "Lower the threshold to see results",
              align = (:center, :center))
        hidedecorations!(ax)
        f
    end
end


# ╔═╡ 9964624e-b5c6-47c5-9a50-34990f5ad3f0
begin
    df = CSV.read("tagesschau.csv/tagesschau.csv", DataFrame)
    category_col = names(df)[2]  
    df = filter(row -> !ismissing(row[category_col]), df)
    category_counts = combine(groupby(df, category_col), nrow => :count)
    sort!(category_counts, :count, rev=true)

    # Create a markdown list of categories and their counts, each on a new line
    category_list = join([string("**", row[category_col], "**: ", row[:count]) for row in eachrow(category_counts)], "  ")
	
	##############################################################################
	#@info typeof(category_list)
	#@info typeof(category_counts[!,2][1])
	
	@test category_list != []
	#@test "" in category_list
	@test typeof(category_counts[!,2][1]) == Int64
	@test category_counts[!,2][1] != 0

	if category_list != []
		println("Test_1...passed ✅")
	else 
		throw(Errorexception("Test_1...not passed"))
	end

	if typeof(category_counts[!,2][1]) == Int64
		println("Test_2...passed ✅")
	else 
		throw(Errorexception("Test_2...not passed"))
	end

	if category_counts[!,2][1] != 0
		println("Test_3...passed ✅")
	else 
		throw(Errorexception("Test_3...not passed"))
	end

    md"""
    # 📊 Category News Count Overview
    $category_list
    """
end

# ╔═╡ e1892185-0c75-423f-8401-d477669322c0
md"""
	## Bar chart for the number of news per category
	"""

# ╔═╡ a95c805d-d4e3-4707-907d-d45bd21dc7a7
begin
    categories = category_counts[!, category_col]
    counts = category_counts[!, :count]
    xs = 1:length(categories)  # Integer positions for bars
	
	@test typeof(counts) == Vector{Int64}
	
    f = Figure(size = (800, 500))
    ax = Axis(f[1, 1], xlabel = "Category", ylabel = "Number of Entries", title = "Entries per Category", xticklabelrotation = π/3)
    barplot!(ax, xs, counts, color = :dodgerblue)
    ax.xticks = (xs, categories)  # Set x-tick labels to category names
    f
end

# ╔═╡ 4bde08e2-cea4-489b-85e5-4ec9857846a9
begin
    # Data preparation
    df_news_plot = CSV.read("tagesschau.csv/tagesschau.csv", DataFrame)
    df_tags_plot = CSV.read("tags.csv/tags.csv", DataFrame)
    news_externalid_col_plot = :externalId
    tags_externalid_col_plot = :externalId
    region_col_plot = :tag  

    df_joined_plot = leftjoin(df_news_plot, df_tags_plot, on=Pair(news_externalid_col_plot, tags_externalid_col_plot))
    df_joined_plot = filter(row -> !ismissing(row[region_col_plot]), df_joined_plot)
    region_counts_plot = combine(groupby(df_joined_plot, region_col_plot), nrow => :count)
    sort!(region_counts_plot, :count, rev=true)
    regions_plot = region_counts_plot[!, region_col_plot]
    counts_plot = region_counts_plot[!, :count]
    clean_region = s -> replace(String(s), r"[^\x20-\x7E]" => "?")
    regions_plot_clean = clean_region.(regions_plot)

	md"""
	# 📊 Number of News per Tag
	"""
end

# ╔═╡ 16154c2a-621e-484d-a24e-c7ff35c192d8
@bind n_locations PlutoUI.Slider(10:min(100, length(regions_plot_clean)); default=10, show_value=true)

# ╔═╡ 9d58551c-9ab5-487b-ad08-f116cd7c23bd
begin
    max_count, max_idx = findmax(counts_plot)
    min_count, min_idx = findmin(counts_plot)
    region_most = regions_plot_clean[max_idx]
    region_least = regions_plot_clean[min_idx]

    md"""
    ## Data Description
    - Tag with the most news: **$region_most** ($max_count)
    - Tag with the least news: **$region_least** ($min_count)
    """
end

# ╔═╡ 4037cad2-b3d0-41f3-a621-2c282caf38c6
md"""
	## Bar chart showing top 100 tags
	"""

# ╔═╡ 43256546-cd8b-40c5-865d-8d99a13facc1
begin
	
    xs_plot = 1:n_locations
    f_plot = Figure(size = (1000, 500))
    ax_plot = Axis(
        f_plot[1, 1],
        xlabel = "Tag",
        ylabel = "Number of News",
        title = "Number of News per Tag",
        xticklabelrotation = π/3,         
        xticklabelsize = 10              
    )
    barplot!(ax_plot, xs_plot, counts_plot[1:n_locations], color = :seagreen)
    ax_plot.xticks = (xs_plot, regions_plot_clean[1:n_locations])
    f_plot
end

# ╔═╡ 3ae9e66c-f5a9-488d-bb79-3673bf0c955d
begin
    # Load the CSV file
    df_breaking_plot = CSV.read("tagesschau.csv/tagesschau.csv", DataFrame)
    breaking_col_plot = names(df_breaking_plot)[1]  # Should be "breakingNews"
    breaking_counts_plot = combine(groupby(df_breaking_plot, breaking_col_plot), nrow => :count)
    labels_breaking_plot = map(x -> x == true ? "Breaking News" : "Not Breaking News", breaking_counts_plot[!, breaking_col_plot])
    counts_breaking_plot = breaking_counts_plot[!, :count]

    # Get numbers
    num_breaking = get(counts_breaking_plot[labels_breaking_plot .== "Breaking News"], 1, 0)
	
	@test num_breaking != 0
	if num_breaking != 0
		println("Test_1...passed")
	else
		throw(Errorexeception("test_1...not passed: Breaking news number must be at least 1"))
	end
	
    num_nonbreaking = get(counts_breaking_plot[labels_breaking_plot .== "Not Breaking News"], 1, 0)

	@test num_nonbreaking != 0
	if num_nonbreaking != 0
		println("Test_2...passed")
	else
		throw(Errorexeception("test_1...not passed: non-Breaking news number must be at least 1"))
	end

    md"""
    # 📰 Breaking News Overview

    - **Breaking News:** $num_breaking
    - **Not Breaking News:** $num_nonbreaking
    """
end

# ╔═╡ eb9ba333-45d8-4add-a55f-96418c122e30
    md"""
    ## Difference between breaking and non breaking news
    """

# ╔═╡ 33cbc8c8-3503-444c-98c1-185a34b36358
begin
    xs_breaking_plot = 1:length(labels_breaking_plot)
    f_breaking_plot = Figure(size = (500, 400))
    ax_breaking_plot = Axis(f_breaking_plot[1, 1], xlabel = "Type", ylabel = "Number of News", title = "Breaking News vs Not Breaking News")
    barplot!(ax_breaking_plot, xs_breaking_plot, counts_breaking_plot, color = [:crimson, :dodgerblue][1:length(xs_breaking_plot)])
    ax_breaking_plot.xticks = (xs_breaking_plot, labels_breaking_plot)
    f_breaking_plot
end

# ╔═╡ 4507a6f9-9a17-47ad-a970-aaef70c946a6
    md"""
    ## Breaking News per Category per Year
    """

# ╔═╡ 31c598b5-cf80-4f07-bc6f-4f207c3f9dd1
begin
    df_breaking = CSV.read("tagesschau.csv/tagesschau.csv", DataFrame)
    breaking_col_br = :breakingNews
    category_col_br = names(df_breaking)[2]
    date_col_br = :datetimepublished

    df_breaking.year = year.(DateTime.(df_breaking[!, date_col_br]))

    df_breaking = filter(row -> !ismissing(row[category_col_br]), df_breaking)
    years_br = 2022:2025
    df_breaking_filtered = filter(row -> row[breaking_col_br] == true && row.year in years_br, df_breaking)

    categories_br = sort(unique(df_breaking_filtered[!, category_col_br]))
    years_vec_br = collect(years_br)

    # Create a matrix of counts: rows = years, cols = categories
    heat_data_br = [
        sum((df_breaking_filtered[!, category_col_br] .== cat) .& (df_breaking_filtered.year .== yr))
        for yr in years_vec_br, cat in categories_br
    ]

    nothing  # This line suppresses output
end

# ╔═╡ f53d6eca-823a-4bb6-95dc-0b45e5cecc19
begin
    fig_br = Figure(size = (max(600, 60*length(categories_br)), 400))
    ax_br = Axis(
        fig_br[1, 1],
        xlabel = "Category",
        ylabel = "Year",
        title = "Breaking News per Category per Year",
        yticks = (1:length(years_vec_br), string.(years_vec_br)),
        xticks = (1:length(categories_br), categories_br),
        xticklabelrotation = π/4
    )
    hm_br = heatmap!(ax_br, heat_data_br; colormap = :viridis)
    Colorbar(fig_br[1, 2], hm_br)
    fig_br
end


# ╔═╡ 6d6f746d-dd3d-411d-9e72-def1438f1aa1
md"""
    ## Non-Breaking News per Category per Year
    """

# ╔═╡ e64cf3cd-f304-4357-8b3f-aeda94007b51
begin
    df_nb = CSV.read("tagesschau.csv/tagesschau.csv", DataFrame)

    # Columns
    breaking_col_nb = :breakingNews
    date_col_nb = :datetimepublished
    category_col_nb = names(df_nb)[2]  # assume category is 2nd column

    # Add year column
    df_nb.year = year.(DateTime.(df_nb[!, date_col_nb]))

    # Filter relevant rows
    years_nb = 2022:2025
    df_nb_filtered = filter(row -> !ismissing(row[category_col_nb]) &&
                                   row[breaking_col_nb] == false &&
                                   row.year in years_nb, df_nb)

    # Get sorted unique categories and years
    categories_nb = sort(unique(df_nb_filtered[!, category_col_nb]))
    years_vec_nb = collect(years_nb)

    # Create heatmap data: rows = years, cols = categories
    heat_data_nb = [
        sum((df_nb_filtered[!, category_col_nb] .== cat) .& (df_nb_filtered.year .== yr))
        for yr in years_vec_nb, cat in categories_nb
    ]

    # Plot
    # Plot (match fig_br size and formatting)
    fig_nb = Figure(size = (max(600, 60 * length(categories_nb)), 400))
    ax_nb = Axis(
        fig_nb[1, 1],
        title = "Non-Breaking News per Year per Category",
        xlabel = "Category",
        ylabel = "Year",
        xticks = (1:length(categories_nb), categories_nb),
        yticks = (1:length(years_vec_nb), string.(years_vec_nb)),
        xticklabelrotation = π/4
    )

    # Use transposed heatmap so categories = x-axis, years = y-axis
    hm_nb = heatmap!(ax_nb, transpose(heat_data_nb); colormap = :viridis)

    Colorbar(fig_nb[1, 2], hm_nb)

    fig_nb
end


# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
CSV = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
CairoMakie = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
CodecZstd = "6b39b394-51ab-5f42-8807-6242bab2b4c2"
ColorSchemes = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
DataFrames = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
JSON = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
JSON3 = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
UUIDs = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[compat]
CSV = "~0.10.15"
CairoMakie = "~0.11.11"
CodecZstd = "~0.8.6"
ColorSchemes = "~3.29.0"
DataFrames = "~1.7.0"
JSON = "~0.21.4"
JSON3 = "~1.14.3"
PlutoUI = "~0.7.65"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.11.5"
manifest_format = "2.0"
project_hash = "dfcf1140f9a4c44d4ecc890f66a5fe6dca7ed59c"

[[deps.AbstractFFTs]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "d92ad398961a3ed262d8bf04a1a2b8340f915fef"
uuid = "621f4979-c628-5d54-868e-fcf4e3e8185c"
version = "1.5.0"
weakdeps = ["ChainRulesCore", "Test"]

    [deps.AbstractFFTs.extensions]
    AbstractFFTsChainRulesCoreExt = "ChainRulesCore"
    AbstractFFTsTestExt = "Test"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "6e1d2a35f2f90a4bc7c2ed98079b2ba09c35b83a"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.3.2"

[[deps.AbstractTrees]]
git-tree-sha1 = "2d9c9a55f9c93e8887ad391fbae72f8ef55e1177"
uuid = "1520ce14-60c1-5f80-bbc7-55ef81b5835c"
version = "0.4.5"

[[deps.Adapt]]
deps = ["LinearAlgebra", "Requires"]
git-tree-sha1 = "f7817e2e585aa6d924fd714df1e2a84be7896c60"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "4.3.0"
weakdeps = ["SparseArrays", "StaticArrays"]

    [deps.Adapt.extensions]
    AdaptSparseArraysExt = "SparseArrays"
    AdaptStaticArraysExt = "StaticArrays"

[[deps.AdaptivePredicates]]
git-tree-sha1 = "7e651ea8d262d2d74ce75fdf47c4d63c07dba7a6"
uuid = "35492f91-a3bd-45ad-95db-fcad7dcfedb7"
version = "1.2.0"

[[deps.AliasTables]]
deps = ["PtrArrays", "Random"]
git-tree-sha1 = "9876e1e164b144ca45e9e3198d0b689cadfed9ff"
uuid = "66dad0bd-aa9a-41b7-9441-69ab47430ed8"
version = "1.1.3"

[[deps.Animations]]
deps = ["Colors"]
git-tree-sha1 = "e092fa223bf66a3c41f9c022bd074d916dc303e7"
uuid = "27a7e980-b3e6-11e9-2bcd-0b925532e340"
version = "0.4.2"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Automa]]
deps = ["PrecompileTools", "SIMD", "TranscodingStreams"]
git-tree-sha1 = "a8f503e8e1a5f583fbef15a8440c8c7e32185df2"
uuid = "67c07d97-cdcb-5c2c-af73-a7f9c32a568b"
version = "1.1.0"

[[deps.AxisAlgorithms]]
deps = ["LinearAlgebra", "Random", "SparseArrays", "WoodburyMatrices"]
git-tree-sha1 = "01b8ccb13d68535d73d2b0c23e39bd23155fb712"
uuid = "13072b0f-2c55-5437-9ae7-d433b7a33950"
version = "1.1.0"

[[deps.AxisArrays]]
deps = ["Dates", "IntervalSets", "IterTools", "RangeArrays"]
git-tree-sha1 = "16351be62963a67ac4083f748fdb3cca58bfd52f"
uuid = "39de3d68-74b9-583c-8d2d-e117c070f3a9"
version = "0.4.7"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.BaseDirs]]
git-tree-sha1 = "03fea4a4efe25d2069c2d5685155005fc251c0a1"
uuid = "18cc8868-cbac-4acf-b575-c8ff214dc66f"
version = "1.3.0"

[[deps.Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1b96ea4a01afe0ea4090c5c8039690672dd13f2e"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.9+0"

[[deps.CEnum]]
git-tree-sha1 = "389ad5c84de1ae7cf0e28e381131c98ea87d54fc"
uuid = "fa961155-64e5-5f13-b03f-caf6b980ea82"
version = "0.5.0"

[[deps.CRC32c]]
uuid = "8bf52ea8-c179-5cab-976a-9e18b702a9bc"
version = "1.11.0"

[[deps.CRlibm]]
deps = ["CRlibm_jll"]
git-tree-sha1 = "66188d9d103b92b6cd705214242e27f5737a1e5e"
uuid = "96374032-68de-5a5b-8d9e-752f78720389"
version = "1.0.2"

[[deps.CRlibm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e329286945d0cfc04456972ea732551869af1cfc"
uuid = "4e9b3aee-d8a1-5a3d-ad8b-7d824db253f0"
version = "1.0.1+0"

[[deps.CSV]]
deps = ["CodecZlib", "Dates", "FilePathsBase", "InlineStrings", "Mmap", "Parsers", "PooledArrays", "PrecompileTools", "SentinelArrays", "Tables", "Unicode", "WeakRefStrings", "WorkerUtilities"]
git-tree-sha1 = "deddd8725e5e1cc49ee205a1964256043720a6c3"
uuid = "336ed68f-0bac-5ca0-87d4-7b16caf5d00b"
version = "0.10.15"

[[deps.Cairo]]
deps = ["Cairo_jll", "Colors", "Glib_jll", "Graphics", "Libdl", "Pango_jll"]
git-tree-sha1 = "71aa551c5c33f1a4415867fe06b7844faadb0ae9"
uuid = "159f3aea-2a34-519c-b102-8c37f9878175"
version = "1.1.1"

[[deps.CairoMakie]]
deps = ["CRC32c", "Cairo", "Colors", "FileIO", "FreeType", "GeometryBasics", "LinearAlgebra", "Makie", "PrecompileTools"]
git-tree-sha1 = "d69c7593fe9d7d617973adcbe4762028c6899b2c"
uuid = "13f3f980-e62b-5c42-98c6-ff1f3baf88f0"
version = "0.11.11"

[[deps.Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "CompilerSupportLibraries_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "fde3bf89aead2e723284a8ff9cdf5b551ed700e8"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.18.5+0"

[[deps.ChainRulesCore]]
deps = ["Compat", "LinearAlgebra"]
git-tree-sha1 = "1713c74e00545bfe14605d2a2be1712de8fbcb58"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.25.1"
weakdeps = ["SparseArrays"]

    [deps.ChainRulesCore.extensions]
    ChainRulesCoreSparseArraysExt = "SparseArrays"

[[deps.CodecZlib]]
deps = ["TranscodingStreams", "Zlib_jll"]
git-tree-sha1 = "962834c22b66e32aa10f7611c08c8ca4e20749a9"
uuid = "944b1d66-785c-5afd-91f1-9de20f533193"
version = "0.7.8"

[[deps.CodecZstd]]
deps = ["TranscodingStreams", "Zstd_jll"]
git-tree-sha1 = "d0073f473757f0d39ac9707f1eb03b431573cbd8"
uuid = "6b39b394-51ab-5f42-8807-6242bab2b4c2"
version = "0.8.6"

[[deps.ColorBrewer]]
deps = ["Colors", "JSON"]
git-tree-sha1 = "e771a63cc8b539eca78c85b0cabd9233d6c8f06f"
uuid = "a2cac450-b92f-5266-8821-25eda20663c8"
version = "0.4.1"

[[deps.ColorSchemes]]
deps = ["ColorTypes", "ColorVectorSpace", "Colors", "FixedPointNumbers", "PrecompileTools", "Random"]
git-tree-sha1 = "403f2d8e209681fcbd9468a8514efff3ea08452e"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.29.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.ColorVectorSpace]]
deps = ["ColorTypes", "FixedPointNumbers", "LinearAlgebra", "Requires", "Statistics", "TensorCore"]
git-tree-sha1 = "a1f44953f2382ebb937d60dafbe2deea4bd23249"
uuid = "c3611d14-8923-5661-9e6a-0046d554d3a4"
version = "0.10.0"
weakdeps = ["SpecialFunctions"]

    [deps.ColorVectorSpace.extensions]
    SpecialFunctionsExt = "SpecialFunctions"

[[deps.Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "362a287c3aa50601b0bc359053d5c2468f0e7ce0"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.11"

[[deps.Compat]]
deps = ["TOML", "UUIDs"]
git-tree-sha1 = "8ae8d32e09f0dcf42a36b90d4e17f5dd2e4c4215"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "4.16.0"
weakdeps = ["Dates", "LinearAlgebra"]

    [deps.Compat.extensions]
    CompatLinearAlgebraExt = "LinearAlgebra"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.1.1+0"

[[deps.ConstructionBase]]
git-tree-sha1 = "b4b092499347b18a015186eae3042f72267106cb"
uuid = "187b0558-2788-49d3-abe0-74a17ed4e7c9"
version = "1.6.0"
weakdeps = ["IntervalSets", "LinearAlgebra", "StaticArrays"]

    [deps.ConstructionBase.extensions]
    ConstructionBaseIntervalSetsExt = "IntervalSets"
    ConstructionBaseLinearAlgebraExt = "LinearAlgebra"
    ConstructionBaseStaticArraysExt = "StaticArrays"

[[deps.Contour]]
git-tree-sha1 = "439e35b0b36e2e5881738abc8857bd92ad6ff9a8"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.6.3"

[[deps.Crayons]]
git-tree-sha1 = "249fe38abf76d48563e2f4556bebd215aa317e15"
uuid = "a8cc5b0e-0ffa-5ad4-8c14-923d3ee1735f"
version = "4.1.1"

[[deps.DataAPI]]
git-tree-sha1 = "abe83f3a2f1b857aac70ef8b269080af17764bbe"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.16.0"

[[deps.DataFrames]]
deps = ["Compat", "DataAPI", "DataStructures", "Future", "InlineStrings", "InvertedIndices", "IteratorInterfaceExtensions", "LinearAlgebra", "Markdown", "Missings", "PooledArrays", "PrecompileTools", "PrettyTables", "Printf", "Random", "Reexport", "SentinelArrays", "SortingAlgorithms", "Statistics", "TableTraits", "Tables", "Unicode"]
git-tree-sha1 = "fb61b4812c49343d7ef0b533ba982c46021938a6"
uuid = "a93c6f00-e57d-5684-b7b6-d8193f3e46c0"
version = "1.7.0"

[[deps.DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "4e1fe97fdaed23e9dc21d4d664bea76b65fc50a0"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.22"

[[deps.DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.DelaunayTriangulation]]
deps = ["AdaptivePredicates", "EnumX", "ExactPredicates", "Random"]
git-tree-sha1 = "5620ff4ee0084a6ab7097a27ba0c19290200b037"
uuid = "927a84f5-c5f4-47a5-9785-b46e178433df"
version = "1.6.4"

[[deps.Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"
version = "1.11.0"

[[deps.Distributions]]
deps = ["AliasTables", "FillArrays", "LinearAlgebra", "PDMats", "Printf", "QuadGK", "Random", "SpecialFunctions", "Statistics", "StatsAPI", "StatsBase", "StatsFuns"]
git-tree-sha1 = "3e6d038b77f22791b8e3472b7c633acea1ecac06"
uuid = "31c24e10-a181-5473-b8eb-7969acd0382f"
version = "0.25.120"

    [deps.Distributions.extensions]
    DistributionsChainRulesCoreExt = "ChainRulesCore"
    DistributionsDensityInterfaceExt = "DensityInterface"
    DistributionsTestExt = "Test"

    [deps.Distributions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    DensityInterface = "b429d917-457f-4dbc-8f4c-0cc954292b1d"
    Test = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.DocStringExtensions]]
git-tree-sha1 = "7442a5dfe1ebb773c29cc2962a8980f47221d76c"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.9.5"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.6.0"

[[deps.EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e3290f2d49e661fbd94046d7e3726ffcb2d41053"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.4+0"

[[deps.EnumX]]
git-tree-sha1 = "bddad79635af6aec424f53ed8aad5d7555dc6f00"
uuid = "4e289a0a-7415-4d19-859d-a7e5c4648b56"
version = "1.0.5"

[[deps.ExactPredicates]]
deps = ["IntervalArithmetic", "Random", "StaticArrays"]
git-tree-sha1 = "b3f2ff58735b5f024c392fde763f29b057e4b025"
uuid = "429591f6-91af-11e9-00e2-59fbe8cec110"
version = "2.2.8"

[[deps.Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d55dffd9ae73ff72f1c0482454dcf2ec6c6c4a63"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.6.5+0"

[[deps.Extents]]
git-tree-sha1 = "b309b36a9e02fe7be71270dd8c0fd873625332b4"
uuid = "411431e0-e8b7-467b-b5e0-f676ba4f2910"
version = "0.1.6"

[[deps.FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "PCRE2_jll", "Zlib_jll", "libaom_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "8cc47f299902e13f90405ddb5bf87e5d474c0d38"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "6.1.2+0"

[[deps.FFTW]]
deps = ["AbstractFFTs", "FFTW_jll", "LinearAlgebra", "MKL_jll", "Preferences", "Reexport"]
git-tree-sha1 = "797762812ed063b9b94f6cc7742bc8883bb5e69e"
uuid = "7a1cc6ca-52ef-59f5-83cd-3a7055c09341"
version = "1.9.0"

[[deps.FFTW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6d6219a004b8cf1e0b4dbe27a2860b8e04eba0be"
uuid = "f5851436-0d7a-5f13-b9de-f02708fd171a"
version = "3.3.11+0"

[[deps.FileIO]]
deps = ["Pkg", "Requires", "UUIDs"]
git-tree-sha1 = "b66970a70db13f45b7e57fbda1736e1cf72174ea"
uuid = "5789e2e9-d7fb-5bc7-8068-2c6fae9b9549"
version = "1.17.0"

    [deps.FileIO.extensions]
    HTTPExt = "HTTP"

    [deps.FileIO.weakdeps]
    HTTP = "cd3eb016-35fb-5094-929b-558a96fad6f3"

[[deps.FilePaths]]
deps = ["FilePathsBase", "MacroTools", "Reexport", "Requires"]
git-tree-sha1 = "919d9412dbf53a2e6fe74af62a73ceed0bce0629"
uuid = "8fc22ac5-c921-52a6-82fd-178b2807b824"
version = "0.8.3"

[[deps.FilePathsBase]]
deps = ["Compat", "Dates"]
git-tree-sha1 = "3bab2c5aa25e7840a4b065805c0cdfc01f3068d2"
uuid = "48062228-2e41-5def-b9a4-89aafe57970f"
version = "0.9.24"
weakdeps = ["Mmap", "Test"]

    [deps.FilePathsBase.extensions]
    FilePathsBaseMmapExt = "Mmap"
    FilePathsBaseTestExt = "Test"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FillArrays]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "6a70198746448456524cb442b8af316927ff3e1a"
uuid = "1a297f60-69ca-5386-bcde-b61e274b549b"
version = "1.13.0"
weakdeps = ["PDMats", "SparseArrays", "Statistics"]

    [deps.FillArrays.extensions]
    FillArraysPDMatsExt = "PDMats"
    FillArraysSparseArraysExt = "SparseArrays"
    FillArraysStatisticsExt = "Statistics"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "05882d6995ae5c12bb5f36dd2ed3f61c98cbb172"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.5"

[[deps.Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Zlib_jll"]
git-tree-sha1 = "301b5d5d731a0654825f1f2e906990f7141a106b"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.16.0+0"

[[deps.Format]]
git-tree-sha1 = "9c68794ef81b08086aeb32eeaf33531668d5f5fc"
uuid = "1fa38f19-a742-5d3f-a2b9-30dd87b9d5f8"
version = "1.3.7"

[[deps.FreeType]]
deps = ["CEnum", "FreeType2_jll"]
git-tree-sha1 = "907369da0f8e80728ab49c1c7e09327bf0d6d999"
uuid = "b38be410-82b0-50bf-ab77-7b57e271db43"
version = "4.1.1"

[[deps.FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "2c5512e11c791d1baed2049c5652441b28fc6a31"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.13.4+0"

[[deps.FreeTypeAbstraction]]
deps = ["BaseDirs", "ColorVectorSpace", "Colors", "FreeType", "GeometryBasics", "Mmap"]
git-tree-sha1 = "4ebb930ef4a43817991ba35db6317a05e59abd11"
uuid = "663a7486-cb36-511b-a19d-713bb74d65c9"
version = "0.10.8"

[[deps.FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "7a214fdac5ed5f59a22c2d9a885a16da1c74bbc7"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.17+0"

[[deps.Future]]
deps = ["Random"]
uuid = "9fa8497b-333b-5362-9e8d-4d0656e87820"
version = "1.11.0"

[[deps.GeoFormatTypes]]
git-tree-sha1 = "8e233d5167e63d708d41f87597433f59a0f213fe"
uuid = "68eda718-8dee-11e9-39e7-89f7f65f511f"
version = "0.4.4"

[[deps.GeoInterface]]
deps = ["DataAPI", "Extents", "GeoFormatTypes"]
git-tree-sha1 = "294e99f19869d0b0cb71aef92f19d03649d028d5"
uuid = "cf35fbd7-0cd7-5166-be24-54bfbe79505f"
version = "1.4.1"

[[deps.GeometryBasics]]
deps = ["EarCut_jll", "Extents", "GeoInterface", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "b62f2b2d76cee0d61a2ef2b3118cd2a3215d3134"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.11"

[[deps.Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[deps.Giflib_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6570366d757b50fabae9f4315ad74d2e40c0560a"
uuid = "59f7168a-df46-5410-90c8-f2779963d0ec"
version = "5.2.3+0"

[[deps.Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE2_jll", "Zlib_jll"]
git-tree-sha1 = "fee60557e4f19d0fe5cd169211fdda80e494f4e8"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.84.0+0"

[[deps.Graphics]]
deps = ["Colors", "LinearAlgebra", "NaNMath"]
git-tree-sha1 = "a641238db938fff9b2f60d08ed9030387daf428c"
uuid = "a2bd30eb-e257-5431-a919-1863eab51364"
version = "1.1.3"

[[deps.Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a6dbda1fd736d60cc477d99f2e7a042acfa46e8"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.15+0"

[[deps.GridLayoutBase]]
deps = ["GeometryBasics", "InteractiveUtils", "Observables"]
git-tree-sha1 = "6f93a83ca11346771a93bbde2bdad2f65b61498f"
uuid = "3955a311-db13-416c-9275-1d80ed98e5e9"
version = "0.10.2"

[[deps.Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[deps.HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll"]
git-tree-sha1 = "f923f9a774fcf3f5cb761bfa43aeadd689714813"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "8.5.1+0"

[[deps.HypergeometricFunctions]]
deps = ["LinearAlgebra", "OpenLibm_jll", "SpecialFunctions"]
git-tree-sha1 = "68c173f4f449de5b438ee67ed0c9c748dc31a2ec"
uuid = "34004b35-14d8-5ef3-9330-4cdb6864b03a"
version = "0.3.28"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "7134810b1afce04bbc1045ca1985fbe81ce17653"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.5"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "b6d6bfdd7ce25b0f9b2f6b3dd56b2673a66c8770"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.5"

[[deps.ImageAxes]]
deps = ["AxisArrays", "ImageBase", "ImageCore", "Reexport", "SimpleTraits"]
git-tree-sha1 = "e12629406c6c4442539436581041d372d69c55ba"
uuid = "2803e5a7-5153-5ecf-9a86-9b4c37f5f5ac"
version = "0.6.12"

[[deps.ImageBase]]
deps = ["ImageCore", "Reexport"]
git-tree-sha1 = "eb49b82c172811fd2c86759fa0553a2221feb909"
uuid = "c817782e-172a-44cc-b673-b171935fbb9e"
version = "0.1.7"

[[deps.ImageCore]]
deps = ["ColorVectorSpace", "Colors", "FixedPointNumbers", "MappedArrays", "MosaicViews", "OffsetArrays", "PaddedViews", "PrecompileTools", "Reexport"]
git-tree-sha1 = "8c193230235bbcee22c8066b0374f63b5683c2d3"
uuid = "a09fc81d-aa75-5fe9-8630-4744c3626534"
version = "0.10.5"

[[deps.ImageIO]]
deps = ["FileIO", "IndirectArrays", "JpegTurbo", "LazyModules", "Netpbm", "OpenEXR", "PNGFiles", "QOI", "Sixel", "TiffImages", "UUIDs", "WebP"]
git-tree-sha1 = "696144904b76e1ca433b886b4e7edd067d76cbf7"
uuid = "82e4d734-157c-48bb-816b-45c225c6df19"
version = "0.6.9"

[[deps.ImageMetadata]]
deps = ["AxisArrays", "ImageAxes", "ImageBase", "ImageCore"]
git-tree-sha1 = "2a81c3897be6fbcde0802a0ebe6796d0562f63ec"
uuid = "bc367c6b-8a6b-528e-b4bd-a4b897500b49"
version = "0.9.10"

[[deps.Imath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "0936ba688c6d201805a83da835b55c61a180db52"
uuid = "905a6f67-0a94-5f89-b386-d35d92009cd1"
version = "3.1.11+0"

[[deps.IndirectArrays]]
git-tree-sha1 = "012e604e1c7458645cb8b436f8fba789a51b257f"
uuid = "9b13fd28-a010-5f03-acff-a1bbcff69959"
version = "1.0.0"

[[deps.Inflate]]
git-tree-sha1 = "d1b1b796e47d94588b3757fe84fbf65a5ec4a80d"
uuid = "d25df0c9-e2be-5dd7-82c8-3ad0b3e990b9"
version = "0.1.5"

[[deps.InlineStrings]]
git-tree-sha1 = "8594fac023c5ce1ef78260f24d1ad18b4327b420"
uuid = "842dd82b-1e85-43dc-bf29-5d0ee9dffc48"
version = "1.4.4"

    [deps.InlineStrings.extensions]
    ArrowTypesExt = "ArrowTypes"
    ParsersExt = "Parsers"

    [deps.InlineStrings.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"
    Parsers = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"

[[deps.IntelOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "LazyArtifacts", "Libdl"]
git-tree-sha1 = "0f14a5456bdc6b9731a5682f439a672750a09e48"
uuid = "1d5cc7b8-4909-519e-a0f8-d0f5ad9712d0"
version = "2025.0.4+0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.Interpolations]]
deps = ["Adapt", "AxisAlgorithms", "ChainRulesCore", "LinearAlgebra", "OffsetArrays", "Random", "Ratios", "Requires", "SharedArrays", "SparseArrays", "StaticArrays", "WoodburyMatrices"]
git-tree-sha1 = "88a101217d7cb38a7b481ccd50d21876e1d1b0e0"
uuid = "a98d9a8b-a2ab-59e6-89dd-64a1c18fca59"
version = "0.15.1"

    [deps.Interpolations.extensions]
    InterpolationsUnitfulExt = "Unitful"

    [deps.Interpolations.weakdeps]
    Unitful = "1986cc42-f94f-5a68-af5c-568840ba703d"

[[deps.IntervalArithmetic]]
deps = ["CRlibm", "MacroTools", "OpenBLASConsistentFPCSR_jll", "Random", "RoundingEmulator"]
git-tree-sha1 = "79342df41c3c24664e5bf29395cfdf2f2a599412"
uuid = "d1acc4aa-44c8-5952-acd4-ba5d80a2a253"
version = "0.22.36"

    [deps.IntervalArithmetic.extensions]
    IntervalArithmeticArblibExt = "Arblib"
    IntervalArithmeticDiffRulesExt = "DiffRules"
    IntervalArithmeticForwardDiffExt = "ForwardDiff"
    IntervalArithmeticIntervalSetsExt = "IntervalSets"
    IntervalArithmeticLinearAlgebraExt = "LinearAlgebra"
    IntervalArithmeticRecipesBaseExt = "RecipesBase"
    IntervalArithmeticSparseArraysExt = "SparseArrays"

    [deps.IntervalArithmetic.weakdeps]
    Arblib = "fb37089c-8514-4489-9461-98f9c8763369"
    DiffRules = "b552c78f-8df3-52c6-915a-8e097449b14b"
    ForwardDiff = "f6369f11-7733-5829-9624-2563aa707210"
    IntervalSets = "8197267c-284f-5f27-9208-e0e47529a953"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.IntervalSets]]
git-tree-sha1 = "5fbb102dcb8b1a858111ae81d56682376130517d"
uuid = "8197267c-284f-5f27-9208-e0e47529a953"
version = "0.7.11"

    [deps.IntervalSets.extensions]
    IntervalSetsRandomExt = "Random"
    IntervalSetsRecipesBaseExt = "RecipesBase"
    IntervalSetsStatisticsExt = "Statistics"

    [deps.IntervalSets.weakdeps]
    Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
    RecipesBase = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
    Statistics = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.InvertedIndices]]
git-tree-sha1 = "6da3c4316095de0f5ee2ebd875df8721e7e0bdbe"
uuid = "41ab1584-1d38-5bbf-9106-f11c6c58b48f"
version = "1.3.1"

[[deps.IrrationalConstants]]
git-tree-sha1 = "e2222959fbc6c19554dc15174c81bf7bf3aa691c"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.2.4"

[[deps.Isoband]]
deps = ["isoband_jll"]
git-tree-sha1 = "f9b6d97355599074dc867318950adaa6f9946137"
uuid = "f1662d9f-8043-43de-a69a-05efc1cc6ff4"
version = "0.1.1"

[[deps.IterTools]]
git-tree-sha1 = "42d5f897009e7ff2cf88db414a389e5ed1bdd023"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.10.0"

[[deps.IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[deps.JLLWrappers]]
deps = ["Artifacts", "Preferences"]
git-tree-sha1 = "a007feb38b422fbdab534406aeca1b86823cb4d6"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.7.0"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "31e996f0a15c7b280ba9f76636b3ff9e2ae58c9a"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.4"

[[deps.JSON3]]
deps = ["Dates", "Mmap", "Parsers", "PrecompileTools", "StructTypes", "UUIDs"]
git-tree-sha1 = "411eccfe8aba0814ffa0fdf4860913ed09c34975"
uuid = "0f8b85d8-7281-11e9-16c2-39a750bddbf1"
version = "1.14.3"

    [deps.JSON3.extensions]
    JSON3ArrowExt = ["ArrowTypes"]

    [deps.JSON3.weakdeps]
    ArrowTypes = "31f734f8-188a-4ce0-8406-c8a06bd891cd"

[[deps.JpegTurbo]]
deps = ["CEnum", "FileIO", "ImageCore", "JpegTurbo_jll", "TOML"]
git-tree-sha1 = "9496de8fb52c224a2e3f9ff403947674517317d9"
uuid = "b835a17e-a41a-41e7-81f0-2f016b05efe0"
version = "0.1.6"

[[deps.JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "eac1206917768cb54957c65a615460d87b455fc1"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "3.1.1+0"

[[deps.KernelDensity]]
deps = ["Distributions", "DocStringExtensions", "FFTW", "Interpolations", "StatsBase"]
git-tree-sha1 = "7d703202e65efa1369de1279c162b915e245eed1"
uuid = "5ab0869b-81aa-558d-bb23-cbf5423bbe9b"
version = "0.6.9"

[[deps.LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "170b660facf5df5de098d866564877e119141cbd"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.2+0"

[[deps.LERC_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aaafe88dccbd957a8d82f7d05be9b69172e0cee3"
uuid = "88015f11-f218-50d7-93a8-a6af411a945d"
version = "4.0.1+0"

[[deps.LLVMOpenMP_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "eb62a3deb62fc6d8822c0c4bef73e4412419c5d8"
uuid = "1d63c593-3942-5779-bab2-d838dc0a180e"
version = "18.1.8+0"

[[deps.LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1c602b1127f4751facb671441ca72715cc95938a"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.3+0"

[[deps.LaTeXStrings]]
git-tree-sha1 = "dda21b8cbd6a6c40d9d02a73230f9d70fed6918c"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.4.0"

[[deps.LazyArtifacts]]
deps = ["Artifacts", "Pkg"]
uuid = "4af54fe1-eca0-43a8-85a7-787d91b784e3"
version = "1.11.0"

[[deps.LazyModules]]
git-tree-sha1 = "a560dd966b386ac9ae60bdd3a3d3a326062d3c3e"
uuid = "8cdb02fc-e678-4876-92c5-9defec4f444e"
version = "0.3.1"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.6.0+0"

[[deps.LibGit2]]
deps = ["Base64", "LibGit2_jll", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"
version = "1.11.0"

[[deps.LibGit2_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll"]
uuid = "e37daf67-58a4-590a-8e99-b0245dd2ffc5"
version = "1.7.2+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.0+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "c8da7e6a91781c41a863611c7e966098d783c57a"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.4.7+0"

[[deps.Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "d36c21b9e7c172a44a10484125024495e2625ac0"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.7.1+1"

[[deps.Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "be484f5c92fad0bd8acfef35fe017900b0b73809"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.18.0+0"

[[deps.Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a31572773ac1b745e0343fe5e2c8ddda7a37e997"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.41.0+0"

[[deps.Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "LERC_jll", "Libdl", "XZ_jll", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "4ab7581296671007fc33f07a721631b8855f4b1d"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.7.1+0"

[[deps.Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "321ccef73a96ba828cd51f2ab5b9f917fa73945a"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.41.0+0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.11.0"

[[deps.LogExpFunctions]]
deps = ["DocStringExtensions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "13ca9e2586b89836fd20cccf56e57e2b9ae7f38f"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.29"

    [deps.LogExpFunctions.extensions]
    LogExpFunctionsChainRulesCoreExt = "ChainRulesCore"
    LogExpFunctionsChangesOfVariablesExt = "ChangesOfVariables"
    LogExpFunctionsInverseFunctionsExt = "InverseFunctions"

    [deps.LogExpFunctions.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    ChangesOfVariables = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.MKL_jll]]
deps = ["Artifacts", "IntelOpenMP_jll", "JLLWrappers", "LazyArtifacts", "Libdl", "oneTBB_jll"]
git-tree-sha1 = "5de60bc6cb3899cd318d80d627560fae2e2d99ae"
uuid = "856f044c-d86e-5d09-b602-aeab76dc8ba7"
version = "2025.0.1+1"

[[deps.MacroTools]]
git-tree-sha1 = "1e0228a030642014fe5cfe68c2c0a818f9e3f522"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.16"

[[deps.Makie]]
deps = ["Animations", "Base64", "CRC32c", "ColorBrewer", "ColorSchemes", "ColorTypes", "Colors", "Contour", "DelaunayTriangulation", "Distributions", "DocStringExtensions", "Downloads", "FFMPEG_jll", "FileIO", "FilePaths", "FixedPointNumbers", "Format", "FreeType", "FreeTypeAbstraction", "GeometryBasics", "GridLayoutBase", "ImageIO", "InteractiveUtils", "IntervalSets", "Isoband", "KernelDensity", "LaTeXStrings", "LinearAlgebra", "MacroTools", "MakieCore", "Markdown", "MathTeXEngine", "Observables", "OffsetArrays", "Packing", "PlotUtils", "PolygonOps", "PrecompileTools", "Printf", "REPL", "Random", "RelocatableFolders", "Scratch", "ShaderAbstractions", "Showoff", "SignedDistanceFields", "SparseArrays", "Statistics", "StatsBase", "StatsFuns", "StructArrays", "TriplotBase", "UnicodeFun"]
git-tree-sha1 = "4d49c9ee830eec99d3e8de2425ff433ece7cc1bc"
uuid = "ee78f7c6-11fb-53f2-987a-cfe4a2b5a57a"
version = "0.20.10"

[[deps.MakieCore]]
deps = ["Observables", "REPL"]
git-tree-sha1 = "248b7a4be0f92b497f7a331aed02c1e9a878f46b"
uuid = "20f20a25-4f0e-4fdf-b5d1-57303727442b"
version = "0.7.3"

[[deps.MappedArrays]]
git-tree-sha1 = "2dab0221fe2b0f2cb6754eaa743cc266339f527e"
uuid = "dbb5928d-eab1-5f90-85c2-b9b0edb7c900"
version = "0.4.2"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MathTeXEngine]]
deps = ["AbstractTrees", "Automa", "DataStructures", "FreeTypeAbstraction", "GeometryBasics", "LaTeXStrings", "REPL", "RelocatableFolders", "UnicodeFun"]
git-tree-sha1 = "96ca8a313eb6437db5ffe946c457a401bbb8ce1d"
uuid = "0a4f8689-d25c-4efe-a92b-7142dfc1aa53"
version = "0.5.7"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"
version = "2.28.6+0"

[[deps.Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "ec4f7fbeab05d7747bdf98eb74d130a2a2ed298d"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.2.0"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"
version = "1.11.0"

[[deps.MosaicViews]]
deps = ["MappedArrays", "OffsetArrays", "PaddedViews", "StackViews"]
git-tree-sha1 = "7b86a5d4d70a9f5cdf2dacb3cbe6d251d1a61dbe"
uuid = "e94cdb99-869f-56ef-bcf0-1ae2bcbe0389"
version = "0.3.4"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2023.12.12"

[[deps.NaNMath]]
deps = ["OpenLibm_jll"]
git-tree-sha1 = "9b8215b1ee9e78a293f99797cd31375471b2bcae"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "1.1.3"

[[deps.Netpbm]]
deps = ["FileIO", "ImageCore", "ImageMetadata"]
git-tree-sha1 = "d92b107dbb887293622df7697a2223f9f8176fcd"
uuid = "f09324ee-3d7c-5217-9330-fc30815ba969"
version = "1.1.1"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.2.0"

[[deps.Observables]]
git-tree-sha1 = "7438a59546cf62428fc9d1bc94729146d37a7225"
uuid = "510215fc-4207-5dde-b226-833fc4488ee2"
version = "0.5.5"

[[deps.OffsetArrays]]
git-tree-sha1 = "117432e406b5c023f665fa73dc26e79ec3630151"
uuid = "6fe1bfb0-de20-5000-8ca7-80f57d26f881"
version = "1.17.0"
weakdeps = ["Adapt"]

    [deps.OffsetArrays.extensions]
    OffsetArraysAdaptExt = "Adapt"

[[deps.Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "887579a3eb005446d514ab7aeac5d1d027658b8f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+1"

[[deps.OpenBLASConsistentFPCSR_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "567515ca155d0020a45b05175449b499c63e7015"
uuid = "6cdc7f73-28fd-5e50-80fb-958a8875b1af"
version = "0.3.29+0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.27+1"

[[deps.OpenEXR]]
deps = ["Colors", "FileIO", "OpenEXR_jll"]
git-tree-sha1 = "97db9e07fe2091882c765380ef58ec553074e9c7"
uuid = "52e1d378-f018-4a11-a4be-720524705ac7"
version = "0.3.3"

[[deps.OpenEXR_jll]]
deps = ["Artifacts", "Imath_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "8292dd5c8a38257111ada2174000a33745b06d4e"
uuid = "18a262bb-aa17-5467-a713-aee519bc75cb"
version = "3.2.4+0"

[[deps.OpenLibm_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "05823500-19ac-5b8b-9628-191a04bc5112"
version = "0.8.5+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "9216a80ff3682833ac4b733caa8c00390620ba5d"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.0+0"

[[deps.OpenSpecFun_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "1346c9208249809840c91b26703912dff463d335"
uuid = "efe28fd5-8261-553b-a9e1-b2916fc3738e"
version = "0.5.6+0"

[[deps.Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "6703a85cb3781bd5909d48730a67205f3f31a575"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.3+0"

[[deps.OrderedCollections]]
git-tree-sha1 = "05868e21324cede2207c6f0f466b4bfef6d5e7ee"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.8.1"

[[deps.PCRE2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "efcefdf7-47ab-520b-bdef-62a2eaa19f15"
version = "10.42.0+1"

[[deps.PDMats]]
deps = ["LinearAlgebra", "SparseArrays", "SuiteSparse"]
git-tree-sha1 = "f07c06228a1c670ae4c87d1276b92c7c597fdda0"
uuid = "90014a1f-27ba-587c-ab20-58faa44d9150"
version = "0.11.35"

[[deps.PNGFiles]]
deps = ["Base64", "CEnum", "ImageCore", "IndirectArrays", "OffsetArrays", "libpng_jll"]
git-tree-sha1 = "cf181f0b1e6a18dfeb0ee8acc4a9d1672499626c"
uuid = "f57f5aa1-a3ce-4bc8-8ab9-96f992907883"
version = "0.4.4"

[[deps.Packing]]
deps = ["GeometryBasics"]
git-tree-sha1 = "bc5bf2ea3d5351edf285a06b0016788a121ce92c"
uuid = "19eb6ba3-879d-56ad-ad62-d5c202156566"
version = "0.5.1"

[[deps.PaddedViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "0fac6313486baae819364c52b4f483450a9d793f"
uuid = "5432bcbf-9aad-5242-b902-cca2824c8663"
version = "0.5.12"

[[deps.Pango_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "FriBidi_jll", "Glib_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl"]
git-tree-sha1 = "275a9a6d85dc86c24d03d1837a0010226a96f540"
uuid = "36c8627f-9965-5494-a995-c6b170f724f3"
version = "1.56.3+0"

[[deps.Parsers]]
deps = ["Dates", "PrecompileTools", "UUIDs"]
git-tree-sha1 = "7d2f8f21da5db6a806faf7b9b292296da42b2810"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.8.3"

[[deps.Pixman_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "LLVMOpenMP_jll", "Libdl"]
git-tree-sha1 = "db76b1ecd5e9715f3d043cec13b2ec93ce015d53"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.44.2+0"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "FileWatching", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "Random", "SHA", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"
version = "1.11.0"
weakdeps = ["REPL"]

    [deps.Pkg.extensions]
    REPLExt = "REPL"

[[deps.PkgVersion]]
deps = ["Pkg"]
git-tree-sha1 = "f9501cc0430a26bc3d156ae1b5b0c1b47af4d6da"
uuid = "eebad327-c553-4316-9ea0-9fa01ccd7688"
version = "0.3.3"

[[deps.PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "PrecompileTools", "Printf", "Random", "Reexport", "StableRNGs", "Statistics"]
git-tree-sha1 = "3ca9a356cd2e113c420f2c13bea19f8d3fb1cb18"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.4.3"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "3151a0c8061cc3f887019beebf359e6c4b3daa08"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.65"

[[deps.PolygonOps]]
git-tree-sha1 = "77b3d3605fc1cd0b42d95eba87dfcd2bf67d5ff6"
uuid = "647866c9-e3ac-4575-94e7-e3d426903924"
version = "0.1.2"

[[deps.PooledArrays]]
deps = ["DataAPI", "Future"]
git-tree-sha1 = "36d8b4b899628fb92c2749eb488d884a926614d3"
uuid = "2dfb63ee-cc39-5dd5-95bd-886bf059d720"
version = "1.4.3"

[[deps.PrecompileTools]]
deps = ["Preferences"]
git-tree-sha1 = "5aa36f7049a63a1528fe8f7c3f2113413ffd4e1f"
uuid = "aea7be01-6a6a-4083-8856-8a6e6704d82a"
version = "1.2.1"

[[deps.Preferences]]
deps = ["TOML"]
git-tree-sha1 = "9306f6085165d270f7e3db02af26a400d580f5c6"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.4.3"

[[deps.PrettyTables]]
deps = ["Crayons", "LaTeXStrings", "Markdown", "PrecompileTools", "Printf", "Reexport", "StringManipulation", "Tables"]
git-tree-sha1 = "1101cd475833706e4d0e7b122218257178f48f34"
uuid = "08abe8d2-0d0c-5749-adfa-8a2ac140af0d"
version = "2.4.0"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.ProgressMeter]]
deps = ["Distributed", "Printf"]
git-tree-sha1 = "13c5103482a8ed1536a54c08d0e742ae3dca2d42"
uuid = "92933f4c-e287-5a05-a399-4b506db050ca"
version = "1.10.4"

[[deps.PtrArrays]]
git-tree-sha1 = "1d36ef11a9aaf1e8b74dacc6a731dd1de8fd493d"
uuid = "43287f4e-b6f4-7ad1-bb20-aadabca52c3d"
version = "1.3.0"

[[deps.QOI]]
deps = ["ColorTypes", "FileIO", "FixedPointNumbers"]
git-tree-sha1 = "8b3fc30bc0390abdce15f8822c889f669baed73d"
uuid = "4b34888f-f399-49d4-9bb3-47ed5cae4e65"
version = "1.0.1"

[[deps.QuadGK]]
deps = ["DataStructures", "LinearAlgebra"]
git-tree-sha1 = "9da16da70037ba9d701192e27befedefb91ec284"
uuid = "1fd47b50-473d-5c70-9696-f719f8f3bcdc"
version = "2.11.2"

    [deps.QuadGK.extensions]
    QuadGKEnzymeExt = "Enzyme"

    [deps.QuadGK.weakdeps]
    Enzyme = "7da242da-08ed-463a-9acd-ee780be4f1d9"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "StyledStrings", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.RangeArrays]]
git-tree-sha1 = "b9039e93773ddcfc828f12aadf7115b4b4d225f5"
uuid = "b3c3ace0-ae52-54e7-9d0b-2c1406fd6b9d"
version = "0.3.2"

[[deps.Ratios]]
deps = ["Requires"]
git-tree-sha1 = "1342a47bf3260ee108163042310d26f2be5ec90b"
uuid = "c84ed2f1-dad5-54f0-aa8e-dbefe2724439"
version = "0.4.5"
weakdeps = ["FixedPointNumbers"]

    [deps.Ratios.extensions]
    RatiosFixedPointNumbersExt = "FixedPointNumbers"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.RelocatableFolders]]
deps = ["SHA", "Scratch"]
git-tree-sha1 = "ffdaf70d81cf6ff22c2b6e733c900c3321cab864"
uuid = "05181044-ff0b-4ac5-8273-598c1e38db00"
version = "1.0.1"

[[deps.Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "62389eeff14780bfe55195b7204c0d8738436d64"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.3.1"

[[deps.Rmath]]
deps = ["Random", "Rmath_jll"]
git-tree-sha1 = "852bd0f55565a9e973fcfee83a84413270224dc4"
uuid = "79098fc4-a85e-5d69-aa6a-4863f24498fa"
version = "0.8.0"

[[deps.Rmath_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "58cdd8fb2201a6267e1db87ff148dd6c1dbd8ad8"
uuid = "f50d1b31-88e8-58de-be2c-1cc44531875f"
version = "0.5.1+0"

[[deps.RoundingEmulator]]
git-tree-sha1 = "40b9edad2e5287e05bd413a38f61a8ff55b9557b"
uuid = "5eaf0fd0-dfba-4ccb-bf02-d820a40db705"
version = "0.2.1"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.SIMD]]
deps = ["PrecompileTools"]
git-tree-sha1 = "fea870727142270bdf7624ad675901a1ee3b4c87"
uuid = "fdea26ae-647d-5447-a871-4b548cad5224"
version = "3.7.1"

[[deps.Scratch]]
deps = ["Dates"]
git-tree-sha1 = "3bac05bc7e74a75fd9cba4295cde4045d9fe2386"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.2.1"

[[deps.SentinelArrays]]
deps = ["Dates", "Random"]
git-tree-sha1 = "712fb0231ee6f9120e005ccd56297abbc053e7e0"
uuid = "91c51154-3ec4-41a3-a24f-3f23e20d615c"
version = "1.4.8"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.ShaderAbstractions]]
deps = ["ColorTypes", "FixedPointNumbers", "GeometryBasics", "LinearAlgebra", "Observables", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "79123bc60c5507f035e6d1d9e563bb2971954ec8"
uuid = "65257c39-d410-5151-9873-9b3e5be5013e"
version = "0.4.1"

[[deps.SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"
version = "1.11.0"

[[deps.Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[deps.SignedDistanceFields]]
deps = ["Random", "Statistics", "Test"]
git-tree-sha1 = "d263a08ec505853a5ff1c1ebde2070419e3f28e9"
uuid = "73760f76-fbc4-59ce-8f25-708e95d2df96"
version = "0.4.0"

[[deps.SimpleTraits]]
deps = ["InteractiveUtils", "MacroTools"]
git-tree-sha1 = "5d7e3f4e11935503d3ecaf7186eac40602e7d231"
uuid = "699a6c99-e7fa-54fc-8d76-47d257e15c1d"
version = "0.9.4"

[[deps.Sixel]]
deps = ["Dates", "FileIO", "ImageCore", "IndirectArrays", "OffsetArrays", "REPL", "libsixel_jll"]
git-tree-sha1 = "2da10356e31327c7096832eb9cd86307a50b1eb6"
uuid = "45858cf5-a6b0-47a3-bbea-62219f50df47"
version = "0.1.3"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"
version = "1.11.0"

[[deps.SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "66e0a8e672a0bdfca2c3f5937efb8538b9ddc085"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.2.1"

[[deps.SparseArrays]]
deps = ["Libdl", "LinearAlgebra", "Random", "Serialization", "SuiteSparse_jll"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
version = "1.11.0"

[[deps.SpecialFunctions]]
deps = ["IrrationalConstants", "LogExpFunctions", "OpenLibm_jll", "OpenSpecFun_jll"]
git-tree-sha1 = "41852b8679f78c8d8961eeadc8f62cef861a52e3"
uuid = "276daf66-3868-5448-9aa4-cd146d93841b"
version = "2.5.1"
weakdeps = ["ChainRulesCore"]

    [deps.SpecialFunctions.extensions]
    SpecialFunctionsChainRulesCoreExt = "ChainRulesCore"

[[deps.StableRNGs]]
deps = ["Random"]
git-tree-sha1 = "95af145932c2ed859b63329952ce8d633719f091"
uuid = "860ef19b-820b-49d6-a774-d7a799459cd3"
version = "1.0.3"

[[deps.StackViews]]
deps = ["OffsetArrays"]
git-tree-sha1 = "be1cf4eb0ac528d96f5115b4ed80c26a8d8ae621"
uuid = "cae243ae-269e-4f55-b966-ac2d0dc13c15"
version = "0.1.2"

[[deps.StaticArrays]]
deps = ["LinearAlgebra", "PrecompileTools", "Random", "StaticArraysCore"]
git-tree-sha1 = "0feb6b9031bd5c51f9072393eb5ab3efd31bf9e4"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.9.13"
weakdeps = ["ChainRulesCore", "Statistics"]

    [deps.StaticArrays.extensions]
    StaticArraysChainRulesCoreExt = "ChainRulesCore"
    StaticArraysStatisticsExt = "Statistics"

[[deps.StaticArraysCore]]
git-tree-sha1 = "192954ef1208c7019899fbf8049e717f92959682"
uuid = "1e83bf80-4336-4d27-bf5d-d5a4f845583c"
version = "1.4.3"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "ae3bb1eb3bba077cd276bc5cfc337cc65c3075c0"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.1"
weakdeps = ["SparseArrays"]

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

[[deps.StatsAPI]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "9d72a13a3f4dd3795a195ac5a44d7d6ff5f552ff"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.7.1"

[[deps.StatsBase]]
deps = ["AliasTables", "DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "b81c5035922cc89c2d9523afc6c54be512411466"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.34.5"

[[deps.StatsFuns]]
deps = ["HypergeometricFunctions", "IrrationalConstants", "LogExpFunctions", "Reexport", "Rmath", "SpecialFunctions"]
git-tree-sha1 = "8e45cecc66f3b42633b8ce14d431e8e57a3e242e"
uuid = "4c63d2b9-4356-54db-8cca-17b64c39e42c"
version = "1.5.0"

    [deps.StatsFuns.extensions]
    StatsFunsChainRulesCoreExt = "ChainRulesCore"
    StatsFunsInverseFunctionsExt = "InverseFunctions"

    [deps.StatsFuns.weakdeps]
    ChainRulesCore = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
    InverseFunctions = "3587e190-3f89-42d0-90ee-14403ec27112"

[[deps.StringManipulation]]
deps = ["PrecompileTools"]
git-tree-sha1 = "725421ae8e530ec29bcbdddbe91ff8053421d023"
uuid = "892a3eda-7b42-436c-8928-eab12a02cf0e"
version = "0.4.1"

[[deps.StructArrays]]
deps = ["ConstructionBase", "DataAPI", "Tables"]
git-tree-sha1 = "9537ef82c42cdd8c5d443cbc359110cbb36bae10"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.21"

    [deps.StructArrays.extensions]
    StructArraysAdaptExt = "Adapt"
    StructArraysGPUArraysCoreExt = ["GPUArraysCore", "KernelAbstractions"]
    StructArraysLinearAlgebraExt = "LinearAlgebra"
    StructArraysSparseArraysExt = "SparseArrays"
    StructArraysStaticArraysExt = "StaticArrays"

    [deps.StructArrays.weakdeps]
    Adapt = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
    GPUArraysCore = "46192b85-c4d5-4398-a991-12ede77f4527"
    KernelAbstractions = "63c18a36-062a-441e-b654-da1e3ab1ce7c"
    LinearAlgebra = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"
    StaticArrays = "90137ffa-7385-5640-81b9-e52037218182"

[[deps.StructTypes]]
deps = ["Dates", "UUIDs"]
git-tree-sha1 = "159331b30e94d7b11379037feeb9b690950cace8"
uuid = "856f2bd8-1eba-4b0a-8007-ebc267875bd4"
version = "1.11.0"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.SuiteSparse]]
deps = ["Libdl", "LinearAlgebra", "Serialization", "SparseArrays"]
uuid = "4607b0f0-06f3-5cda-b6b1-a6196a1729e9"

[[deps.SuiteSparse_jll]]
deps = ["Artifacts", "Libdl", "libblastrampoline_jll"]
uuid = "bea87d4a-7f5b-5778-9afe-8cc45184846c"
version = "7.7.0+0"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"
version = "1.0.3"

[[deps.TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[deps.Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "OrderedCollections", "TableTraits"]
git-tree-sha1 = "f2c1efbc8f3a609aadf318094f8fc5204bdaf344"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.12.1"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"
version = "1.10.0"

[[deps.TensorCore]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "1feb45f88d133a655e001435632f019a9a1bcdb6"
uuid = "62fd8b95-f654-4bbd-a8a5-9c27f68ccd50"
version = "0.1.1"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.TiffImages]]
deps = ["ColorTypes", "DataStructures", "DocStringExtensions", "FileIO", "FixedPointNumbers", "IndirectArrays", "Inflate", "Mmap", "OffsetArrays", "PkgVersion", "PrecompileTools", "ProgressMeter", "SIMD", "UUIDs"]
git-tree-sha1 = "02aca429c9885d1109e58f400c333521c13d48a0"
uuid = "731e570b-9d59-4bfa-96dc-6df516fadf69"
version = "0.11.4"

[[deps.TranscodingStreams]]
git-tree-sha1 = "0c45878dcfdcfa8480052b6ab162cdd138781742"
uuid = "3bb67fe8-82b1-5028-8e26-92a6c54297fa"
version = "0.11.3"

[[deps.Tricks]]
git-tree-sha1 = "6cae795a5a9313bbb4f60683f7263318fc7d1505"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.10"

[[deps.TriplotBase]]
git-tree-sha1 = "4d4ed7f294cda19382ff7de4c137d24d16adc89b"
uuid = "981d1d27-644d-49a2-9326-4793e63143c3"
version = "0.1.0"

[[deps.URIs]]
git-tree-sha1 = "24c1c558881564e2217dcf7840a8b2e10caeb0f9"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.6.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[deps.WeakRefStrings]]
deps = ["DataAPI", "InlineStrings", "Parsers"]
git-tree-sha1 = "b1be2855ed9ed8eac54e5caff2afcdb442d52c23"
uuid = "ea10d353-3f73-51f8-a26c-33c1cb351aa5"
version = "1.4.2"

[[deps.WebP]]
deps = ["CEnum", "ColorTypes", "FileIO", "FixedPointNumbers", "ImageCore", "libwebp_jll"]
git-tree-sha1 = "aa1ca3c47f119fbdae8770c29820e5e6119b83f2"
uuid = "e3aaa7dc-3e4b-44e0-be63-ffb868ccd7c1"
version = "0.1.3"

[[deps.WoodburyMatrices]]
deps = ["LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "c1a7aa6219628fcd757dede0ca95e245c5cd9511"
uuid = "efce3f68-66dc-5838-9240-27a6d6f5f9b6"
version = "1.0.0"

[[deps.WorkerUtilities]]
git-tree-sha1 = "cd1659ba0d57b71a464a29e64dbc67cfe83d54e7"
uuid = "76eceee3-57b5-4d4a-8e66-0e911cebbf60"
version = "1.6.1"

[[deps.XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Zlib_jll"]
git-tree-sha1 = "b8b243e47228b4a3877f1dd6aee0c5d56db7fcf4"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.13.6+1"

[[deps.XZ_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "fee71455b0aaa3440dfdd54a9a36ccef829be7d4"
uuid = "ffd25f8a-64ca-5728-b0f7-c24cf3aae800"
version = "5.8.1+0"

[[deps.Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "b5899b25d17bf1889d25906fb9deed5da0c15b3b"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.8.12+0"

[[deps.Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "aa1261ebbac3ccc8d16558ae6799524c450ed16b"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.13+0"

[[deps.Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "52858d64353db33a56e13c341d7bf44cd0d7b309"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.6+0"

[[deps.Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "a4c0ee07ad36bf8bbce1c3bb52d21fb1e0b987fb"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.7+0"

[[deps.Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libX11_jll"]
git-tree-sha1 = "7ed9347888fac59a618302ee38216dd0379c480d"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.12+0"

[[deps.Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Xorg_libXau_jll", "Xorg_libXdmcp_jll"]
git-tree-sha1 = "bfcaf7ec088eaba362093393fe11aa141fa15422"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.17.1+0"

[[deps.Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "a63799ff68005991f9d9491b6e95bd3478d783cb"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.6.0+0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.2.13+1"

[[deps.Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "446b23e73536f84e8037f5dce465e92275f6a308"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.7+1"

[[deps.isoband_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51b5eeb3f98367157a7a12a1fb0aa5328946c03c"
uuid = "9a68df92-36a6-505f-a73e-abb412b6bfb4"
version = "0.2.3+0"

[[deps.libaom_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "522c1df09d05a71785765d19c9524661234738e9"
uuid = "a4ae2306-e953-59d6-aa16-d00cac43593b"
version = "3.11.0+0"

[[deps.libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "e17c115d55c5fbb7e52ebedb427a0dca79d4484e"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.2+0"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.11.0+0"

[[deps.libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "8a22cf860a7d27e4f3498a0fe0811a7957badb38"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.3+0"

[[deps.libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Zlib_jll"]
git-tree-sha1 = "cd155272a3738da6db765745b89e466fa64d0830"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.49+0"

[[deps.libsixel_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "libpng_jll"]
git-tree-sha1 = "c1733e347283df07689d71d61e14be986e49e47a"
uuid = "075b6546-f08a-558a-be8f-8157d0f608a5"
version = "1.10.5+0"

[[deps.libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "490376214c4721cdaca654041f635213c6165cb3"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+2"

[[deps.libwebp_jll]]
deps = ["Artifacts", "Giflib_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libglvnd_jll", "Libtiff_jll", "libpng_jll"]
git-tree-sha1 = "d2408cac540942921e7bd77272c32e58c33d8a77"
uuid = "c5f90fcd-3b7e-5836-afba-fc50a0988cb2"
version = "1.5.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.59.0+0"

[[deps.oneTBB_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "d5a767a3bb77135a99e433afe0eb14cd7f6914c3"
uuid = "1317d2d5-d96f-522e-a858-c73665f53c3e"
version = "2022.0.0+0"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
version = "17.4.0+2"

[[deps.x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "14cc7083fc6dff3cc44f2bc435ee96d06ed79aa7"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "10164.0.1+0"

[[deps.x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl"]
git-tree-sha1 = "dcc541bb19ed5b0ede95581fb2e41ecf179527d2"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.6.0+0"
"""

# ╔═╡ Cell order:
# ╟─c2f30e90-51fd-11f0-2863-5969556662c5
# ╟─053c2f95-3e3a-4553-b9dd-cbeaca5b1cf2
# ╟─25c33c93-9419-429c-8698-252af8c122b7
# ╟─2b1a5731-bb66-4d99-88c1-2a39772e5ec4
# ╟─28ff7e90-f8fa-43e9-8f06-24c252ad921f
# ╟─4afa4a5f-49e4-48fd-a949-7dc195b6f5c4
# ╟─ba7150f6-3471-45ae-a02d-0dddc4dad61a
# ╟─43e9025a-bb84-4774-b4fc-1b48d29e909d
# ╟─c154f08d-a24d-47fc-8470-fea125d0cc52
# ╟─c3cd5678-0f4c-4b84-a2bb-b72ac6027d1f
# ╟─14ef35ff-1ed3-4e55-ace7-5649129d8ae0
# ╟─d335e9b5-68e5-4df5-95d2-3e9d235ac9a8
# ╟─0c61f375-8dc0-4dd7-a31c-5c026bb5c354
# ╟─ecefd7a7-a6fe-4381-af85-158c298e478a
# ╟─b97287af-2cc3-40a1-b645-057748db107b
# ╟─cc8191f4-8f1c-430f-85a0-149923971bab
# ╟─5a5cf68b-1f57-4147-89f4-d35b5e2d3c81
# ╟─60eb06e7-b29b-4d06-8329-1e30181a438d
# ╟─81df4744-af53-4b03-8d14-ea1a76630de3
# ╟─39652dd5-2877-41ca-b362-4641b344fe7f
# ╟─719ca298-9e87-4974-8e83-f87e10afe720
# ╟─ffc1386c-8220-4df4-bcb2-04b6c81625b4
# ╟─a7a988ba-cee5-4044-88fc-3b092ddc3b5e
# ╟─688f4992-987e-404c-be11-00c56f573d24
# ╟─0ed5bcdc-5750-4cbd-94bb-c553379c9463
# ╟─1a5215ef-6d48-479c-8179-e846fe5570df
# ╟─ee80eb22-579f-454b-9d48-6566f0243bc3
# ╟─a60d543c-fac1-488a-85ea-ad38b3470bfc
# ╟─46796755-758b-445e-92e1-273266a08abb
# ╟─c0a88f7c-0c89-47c5-bb13-c839b97e12db
# ╟─5de7bbb3-d723-4207-907d-dcb6e2df363b
# ╟─34924be8-11fe-40ce-9859-76d978f951bd
# ╟─c65dc97a-6d83-40a4-80ac-04d7e6fa5e51
# ╟─0b350b42-60c6-4cba-85f9-b614f8cd409d
# ╟─321acd7e-811a-4505-acce-e9ee80746dd9
# ╟─838bdf25-5111-451f-8279-4b9cf01ea668
# ╟─bef7ff26-ece2-4427-b19d-87caab33d93b
# ╟─ed4cd90a-f0ff-4dc8-a26f-84d673b7b645
# ╟─e1409e55-4221-423b-b06e-158216d9496b
# ╟─27ff3362-d00a-4a47-b6ba-7794c7a6a8a7
# ╟─c62de334-4a7b-4ba3-9bce-6eb6f1eb8fff
# ╟─d5f1ef02-650e-4243-9aff-5c2580123351
# ╟─276930d5-d903-4e80-bad2-e23c07f30336
# ╟─1faaf5fb-d991-492e-b311-bfa74e7de880
# ╟─5c19f985-5db1-45e5-a745-36788507d26a
# ╟─30cf0460-f500-4e61-81bd-19757e61bcd5
# ╟─204ede19-8f3f-4165-a9c2-b181a9f53b68
# ╟─e8d37e5d-b0fa-43c8-991d-c1f9f4031fc1
# ╟─55f7428c-ea18-4db7-9f70-ccadd057b4c1
# ╟─15622afa-6a7f-43a5-bcfc-ba2960639747
# ╟─8811e4b5-e6fc-498a-a7a7-c34bca563319
# ╟─59fcf722-5e33-4e83-ad00-a737aa60a893
# ╟─bca79309-83d6-4791-9081-ccd4ca389441
# ╟─04f8c95d-41a6-4f46-9952-6c528a929bc2
# ╟─57b47319-6fa4-48f4-81cd-8b086b6cfa1c
# ╟─4cf0f186-d83d-40b4-b2a5-c1b9a8087d07
# ╟─17787a33-ba73-465c-bc04-45482ae59d70
# ╟─4acb37fb-2513-4e04-bdd6-c803d05a47a0
# ╟─5c67f591-f14b-4a4e-942d-26cb0d665c40
# ╟─f24929fa-6c6e-4280-a2de-65c698e1f44f
# ╟─9964624e-b5c6-47c5-9a50-34990f5ad3f0
# ╟─e1892185-0c75-423f-8401-d477669322c0
# ╟─a95c805d-d4e3-4707-907d-d45bd21dc7a7
# ╟─4bde08e2-cea4-489b-85e5-4ec9857846a9
# ╟─16154c2a-621e-484d-a24e-c7ff35c192d8
# ╟─9d58551c-9ab5-487b-ad08-f116cd7c23bd
# ╟─4037cad2-b3d0-41f3-a621-2c282caf38c6
# ╟─43256546-cd8b-40c5-865d-8d99a13facc1
# ╟─3ae9e66c-f5a9-488d-bb79-3673bf0c955d
# ╟─eb9ba333-45d8-4add-a55f-96418c122e30
# ╟─33cbc8c8-3503-444c-98c1-185a34b36358
# ╟─4507a6f9-9a17-47ad-a970-aaef70c946a6
# ╟─31c598b5-cf80-4f07-bc6f-4f207c3f9dd1
# ╟─f53d6eca-823a-4bb6-95dc-0b45e5cecc19
# ╟─6d6f746d-dd3d-411d-9e72-def1438f1aa1
# ╟─e64cf3cd-f304-4357-8b3f-aeda94007b51
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
