module ProjectFunctions


using CSV, DataFrames, Dates

export OpenCSVFile, Date_only_count, Days_Of_Week, Time_only, Extract_News, Extract_Categories

#Opening CSV file:
function OpenCSVFile(path::String)

    if !isfile(path)
        throw(ArgumentError("Folder or file path not valid please check!"))
    end

    df = CSV.read(path, DataFrame)

    return df 

end

#extracting only dates and count:

function Date_only_count(df::DataFrame)

    #df_tag = select(df, :datetimepublished, :title)
    df_transformed = transform(df, :datetimepublished => ByRow(x -> Date(x)) => :date_only)
    df_combined = combine(groupby(df_transformed, :date_only), nrow => :count)
    
    return df_combined

end

#add the days of week:

function Days_Of_Week(df)

    df.dayofweek = dayname.(df.date_only)
    
    return df
end

function Time_Hour(df::DataFrame)

    timedf = transform(df, :datetimepublished=>(x -> hour.(x))=>:timepublished)
	gdf = groupby(timedf, :timepublished)

    return gdf
end

path1 = "tests/test1.csv"
df1 = OpenCSVFile(path1)
df_dates_only = Date_only_count(df1)


println(names(df_dates_only))

gdf = Time_Hour(df1)

#println(gdf.timepublished[1])
#println(names(gdf))

#first_group = gdf[1]
#first_group_time = first_group[1, :timepublished]
#println(first_group_time)


function Extract_News(df_nb::DataFrame)

    breaking_col_nb = :breakingNews
    date_col_nb = :datetimepublished
    category_col_nb = names(df_nb)[2]  

    # Add year column
    df_nb.year = year.(DateTime.(df_nb[!, date_col_nb]))

    # Filter: non-breaking, non-missing category, years 2022–2025
    years_nb = 2022:2025
    df_nb_filtered = filter(row -> !ismissing(row[category_col_nb]) && row[breaking_col_nb] == false && row.year in years_nb, df_nb)

    categories_nb = sort(unique(df_nb_filtered[!, category_col_nb]))
    years_vec_nb = collect(years_nb)

    return df_nb_filtered, categories_nb, years_vec_nb
end


function Extract_Categories(df::DataFrame)

    category_col = names(df)[2]  
    df = filter(row -> !ismissing(row[category_col]), df)
    category_counts = combine(groupby(df, category_col), nrow => :count)
    sort!(category_counts, :count, rev=true)

    category_list = join([string("**", row[category_col], "**: ", row[:count]) for row in eachrow(category_counts)], "  ")
	
    return category_counts, category_list

end

end # module