using Test
using CSV
using DataFrames
using Dates

include("../functions/functions.jl")

using .ProjectFunctions

@testset "OpenCSVFile_tests" begin 
    # test the open CSV file:

    path1 = "tests/test1.csv"
    path2 = "tests/test2.csv"
    path3 = "tests/test3.csv"
    path4 = ""  
    path5 = "tests/test5.csv" #empty csv file
    path0 = 123

    # test OpenCSVFile with the paths provided

    df1 = OpenCSVFile(path1)
    df2 = OpenCSVFile(path2)
    df3 = OpenCSVFile(path3)
    @test_throws ArgumentError OpenCSVFile(path4)
    #@test_throws ArgumentError OpenCSVFile(path0)
    df5 = OpenCSVFile(path5)

    @test isa(df1, DataFrame)
    @test isa(df2, DataFrame)
    @test isa(df3, DataFrame)
    #@test isa(df4, DataFrame)

    @test nrow(df1) == 1
    @test df1[1, :breakingNews] == false
    @test eltype(df1.breakingNews) == Bool
    @test df1[1, :type] == "story"
    @test "type" in names(df1)
    @test df2[1, :externalId] == "94047a6b-befa-42e4-9404-62c343e090f7"
    @test ncol(df1) == 8
    @test ncol(df2) == 2
    @test ncol(df3) == 2
    @test isempty(df5)

end


@testset "Extract_Date_Only" begin
    
    path1 = "tests/test1.csv"
    df = OpenCSVFile(path1)


    df_dates_only = Date_only_count(df)

    @test typeof(df_dates_only.date_only[1]) == Date
    @test df_dates_only.date_only[1] == Date("2022-03-14")
    #@test "count" in names(df_dates_only)
    #@test df_dates_only[1, :count] == 1


    #test for the days of week:

    df_week_days = Days_Of_Week(df_dates_only)
    df_week_days_count = combine(groupby(df_week_days, :dayofweek), nrow => :count)
    @test df_week_days[1, :dayofweek] == "Monday"
    @test size(df_week_days_count.dayofweek) == (1,)

end


@testset "Extract_Time_Hour" begin
    
    path1 = "tests/test1.csv"
    df = OpenCSVFile(path1)
    gdf = ProjectFunctions.Time_Hour(df)
    first_group = gdf[1]
    first_group_time = first_group[1, :timepublished]
    @test first_group_time == 5
    @test "timepublished" in names(gdf)


end

@testset "Extract_News_Type" begin
    
    path_exter = "../tagesschau.csv/tagesschau.csv"
    df_nb = OpenCSVFile(path_exter)

    df_nb_filtered, categories_nb, years_vec_nb = Extract_News(df_nb)

    @test !isempty(df_nb_filtered[!,1])
    @test !isempty(categories_nb)
    @test 2023 in years_vec_nb

end


@testset "Extract_Categories" begin

    path_exter = "../tagesschau.csv/tagesschau.csv"
    df = OpenCSVFile(path_exter) #i think i should've used my OpenCSV function when testing, maybe use built in function better
   
    category_counts, category_list = Extract_Categories(df)

    @test category_list != []
    @test typeof(category_counts[!,2][1]) == Int64
    @test category_counts[!,2][1] != 0


end