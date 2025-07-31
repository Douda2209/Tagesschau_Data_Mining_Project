# Tagesschau Data Mining Project – Group 17

## Overview

This project analyzes news data from the German broadcaster **Tagesschau** to uncover patterns in publication timing, topics, and geographic focus. Using Julia and interactive visualizations, we explore when, what, and where news is published, providing insights into media coverage trends and answering key questions about news distribution patterns.

---

## Table of Contents

- [Project Goals](#project-goals)
- [Dataset Description](#dataset-description)
- [Key Research Questions & Findings](#key-research-questions--findings)
- [Analysis Workflow](#analysis-workflow)
  - [1. Data Quality & Cleaning](#1-data-quality--cleaning)
  - [2. Temporal Analysis](#2-temporal-analysis)
  - [3. Topical Analysis](#3-topical-analysis)
  - [4. Geographic Analysis](#4-geographic-analysis)
  - [5. Interactive Visualizations](#5-interactive-visualizations)
- [How to Run](#how-to-run)
- [Dependencies](#dependencies)
- [Contributors](#contributors)

---

## Project Goals

- **Understand** when news is published (daily, weekly, hourly patterns)
- **Identify** the most common news topics and their trends
- **Analyze** the geographic focus of news coverage
- **Investigate** the distribution of breaking vs. non-breaking news
- **Provide** interactive tools for further exploration

---

## Dataset Description

- **tagesschau.csv**: Main news articles with metadata (date, title, category, breaking news status, etc.)
- **tags.csv**: Tags associated with each news article
- **geotags.csv**: Geographic locations mentioned in the news
- **jsons_2024.jsonl**: Additional data (not directly analyzed in this notebook)

---

## Key Research Questions & Findings

### 📍 **Geographic Coverage Analysis**

**Q: Which geographic locations were mentioned most frequently in the dataset?**
> **A:** Berlin was the most frequently mentioned location by a wide margin (1614 mentions), followed by Frankfurt am Main and Kiew, indicating a strong focus on German cities in the news coverage.

**Q: What is the most frequently mentioned city in each of the most covered countries?**
> **A:** Berlin leads as the most mentioned city in Germany, with over 1600 mentions, far exceeding top cities in other countries like Washington D.C., London, and Paris, highlighting Germany's central role in the dataset's geographic coverage.

**Q: How are cities in Germany distributed in terms of news coverage frequency?**
> **A:** Berlin and Frankfurt am Main dominate the map in terms of mentions, while many other cities receive far less attention, indicating highly concentrated media coverage within Germany.

### 📊 **Content Category Analysis**

**Q: How are news entries distributed across different categories?**
> **A:** The majority of entries fall into the "ausland" (foreign news) and "inland" (domestic news) categories, with significantly fewer entries in areas like sport, science ("wissen"), and investigative reporting.

**Q: Which tags are most commonly associated with the news entries?**
> **A:** Tags like "Berlin", "Niedersachsen", and "Hessen" appear most frequently, indicating these topics or regions receive the most consistent coverage in the dataset.

### 🚨 **Breaking News Analysis**

**Q: How often is a news entry labeled as "breaking news"?**
> **A:** A vast majority of news entries are not labeled as breaking news, showing that routine reporting dominates over urgent news events.

**Q: How has the frequency of breaking news varied by category and year?**
> **A:** Breaking news is sparse overall, with a few notable spikes in categories like "inland" and "wirtschaft" in 2022 and 2023, suggesting only occasional classification of news as urgent across different categories.

**Q: How has non-breaking news coverage evolved across categories over time?**
> **A:** There is a consistent volume of non-breaking news in categories like "ausland" and "inland" across all years, with other categories such as "sport" and "wissen" receiving moderate but steady attention.

---

## Analysis Workflow

### 1. Data Quality & Cleaning

- Loaded all CSV files into Julia DataFrames
- Assessed and cleaned data (e.g., removed invalid geotags, handled missing values)
- Evaluated data retention and quality metrics
- Identified and filtered out "(Keine Auswahl)" entries in geotags

### 2. Temporal Analysis

- Analyzed publication frequency by day, week, and hour
- Identified patterns in breaking vs. non-breaking news
- Visualized trends over time with interactive sliders
- Discovered weekday vs. weekend publication patterns

### 3. Topical Analysis

- Grouped news by category and counted entries
- Compared breaking news frequency across categories and years
- Visualized category trends with bar charts and heatmaps
- Analyzed tag frequency and distribution

### 4. Geographic Analysis

- Assessed the quality and frequency of geotags
- Identified the most mentioned locations and their coverage concentration
- Mapped German cities with frequency-based heatmaps
- Analyzed city/country dominance in news coverage
- Created interactive geographic visualizations

### 5. Interactive Visualizations

- Provided sliders and filters for users to explore data by frequency, time, and region
- Enabled dynamic exploration of key patterns
- Created customizable heatmaps for geographic and temporal analysis

---

## Key Findings Summary

- **Temporal Patterns:** Most news is published on weekdays, peaking on Fridays; weekends see significantly fewer articles
- **Geographic Focus:** Coverage is heavily concentrated in major German cities, particularly Berlin and Frankfurt am Main
- **Content Distribution:** Foreign and domestic news dominate, with sports and science receiving less coverage
- **Breaking News:** Only a small fraction of news is classified as breaking, with occasional spikes in specific categories
- **Data Quality:** After cleaning, the dataset provides reliable insights with comprehensive geographic and temporal coverage

---

## How to Run

1. **Install Julia** (version 1.11 or later recommended)
2. **Clone this repository** and navigate to the project folder
3. **Install dependencies** (see below)
4. **Open `project.jl`** in [Pluto.jl](https://github.com/fonsp/Pluto.jl) or run as a standard Julia script
5. **Interact** with the notebook to explore the data and visualizations

---

## Dependencies

All dependencies are listed in the `PLUTO_PROJECT_TOML_CONTENTS` cell of the notebook. Key packages include:

- `DataFrames`
- `CSV`
- `CairoMakie`
- `PlutoUI`
- `Statistics`
- `ColorSchemes`
- `Dates`
- `Test`

To install all dependencies, use Julia's package manager:

```julia
import Pkg
Pkg.activate(".")
Pkg.instantiate()
```

---

## Contributors

- Dhia Eddine Moula
- Mohamed Ali Berriri
- Arbi Zhabjaku
- Besard Zhabjaku

---

## License

This project is for educational purposes at Hamburg University of Technology (TUHH).

---

*This analysis provides comprehensive insights into Tagesschau's news coverage patterns, revealing both expected trends (like weekday publication patterns) and surprising findings (such as the extreme concentration of geographic coverage in Berlin). The interactive visualizations allow for further exploration of these patterns and can serve as a foundation for more detailed media analysis studies.*
**After we clean the data, manipulate it with dataframes and visulaize it, we can 
start by questioning it. These questions come from in depth 
overlooking at the data and making theories about it**












