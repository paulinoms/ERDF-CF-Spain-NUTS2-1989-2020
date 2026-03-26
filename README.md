# Certified expenditure from the ERDF and Cohesion Fund for Spain, by NUTS 2 region, programming axis and thematic area, 1989–2020 (ERDF–CF–Spain–NUTS2–1989–2020)

This dataset compiles certified information on expenditure from the European Regional Development Fund (ERDF) and the Cohesion Fund (CF) in Spain, covering six programming periods from 1989 to 2020. A script has been created in RStudio to perform the necessary transformations to generate the results, where the data is broken down by autonomous community (CCAA / NUTS 2 region), year of implementation, programming axis (Eje) and thematic area (Area). All monetary values are expressed in thousands of euros at constant 2000 prices (Gasto_m_eur00) and 2020 prices (Gasto_m_eur2020), using the Spanish CPI (INE) as the deflator
<br><br>

## Getting Started 🚀
---
*These instructions will enable you to obtain a working copy of the project on your local machine for development and testing purposes.*

See **Deployment** to find out how to deploy the project.
<br><br>

## Prerequisites  📋
---
* R (version 4.0 or later)
* RStudio
* Required packages (dplyr, tidyr, readr, stringr, lubridate, ggplot2)
* Git (to clone the repository)
<br>

## Installation 🔧
---
```r
git clone https://github.com/paulinoms/ERDF-CF-Spain-NUTS2-1989-2020.git
cd ERDF-CF-Spain-NUTS2-1989-2020
```
<br>

## Open the project in RStudio <img src="https://icons.iconarchive.com/icons/blackvariant/button-ui-requests-5/16/RStudio-icon.png" width="16" height="16">

---

Run the 01_data_processing.R script to generate the consolidated database  
Run the 02_analysis_example.R script to reproduce the example analyses

*Example of how to retrieve data from the system (DEMO)*
```r
library(readr)
datos <- read_csv("output/datos_finales.csv")
head(datos)
```
```r
###  Example: total expenditure by autonomous community
library(dplyr)
datos %>%
group_by(ccaa) %>%
summarise(gasto_total = sum(Gasto_m_eur2020, na.rm = TRUE)) %>%
arrange(desc(gasto_total))
```
<br>

## Running the tests ⚙️
---
### Analyse the end-to-end tests 🔩
```
Algo
```
The checks verify that:
* there are no negative values in the expenditure columns
* all years fall within the range 1989–2020
* the 17 autonomous communities are correctly coded
* the sum of expenditure per autonomous community matches the national totals

### And the coding style tests ⌨️
```
Check code style with lintr
lintr::lint_package()
```
Style checks verify:
* Line length (maximum 80 characters)
* Consistent use of spaces and tabs
* Variable names in snake_case
* Presence of documentation in functions
<br>

## Deployment 📦
---
The data generated can be exported in CSV or Excel format for use in analysis or visualisation tools.

To deploy this project in a production environment:

1. **Export final data:**
```r
  write.csv(datos_finales, "output/ERDF_CF_Spain_1989_2020.csv", row.names = FALSE)
```
2. **Publish on the open data platform:**
```r
  * Publish on GitHub Releases with a semantic version tag
```
3. **Generate automatic documentation:**
```r
  # Generate a website using pkgdown (if it becomes a package)
  pkgdown::build_site()
```
4. **Share on institutional repositories:**
```r
   The research centre’s digital repository
   The funding body’s open data platform
```
5. **Generated files**
```r
   * ERDF_CF_Spain_NUTS2_1989_2020.rda
   * ERDF_CF_Spain_NUTS2_1989_2020.csv
   * ERDF_CF_Spain_NUTS2_1989_2020.xlsx (with its 7 leaves)
   * ERDF_CF_Spain_NUTS2_1989_2020_codebook.xlsx
   * ERDF_CF_Spain_NUTS2_pivot_EUR2000.rda
   * ERDF_CF_Spain_NUTS2_pivot_EUR2020.rda
```
<br>

## Built with 🛠️
---

* [R](https://www.r-project.org/) - Statistical analysis language
* [RStudio](https://posit.co/) - Integrated development environment
* [dplyr](https://dplyr.tidyverse.org/) - Data manipulation
* [tidyr](https://tidyr.tidyverse.org/) - Data cleaning and transformation
* [readr](https://readr.tidyverse.org/) - Data reading
* [lubridate](https://lubridate.tidyverse.org/) - Date handling
* [ggplot2](https://ggplot2.tidyverse.org/) - Data visualisation
* [testthat](https://testthat.r-lib.org/) - Automated testing
<br>

## Variable dictionary 📚
---

| Variable | Type | Description |
|----------|------|-------------|
| Framework | Character | Framework programme or fund name |
| Autonomous Region | Character | Name of the autonomous region (NUTS2) |
| Period | Character | Programming period |
| Year | Integer | Year of implementation (1989–2020) |
| NAxis | Integer | Numerical code of the programming axis |
| Axis | Character | Name of the programming axis |
| NArea | Integer | Thematic area code (1–7) |
| Area | Character | Name of the thematic area |
| Source | Character | Source sheet identifier |
| Expenditure_m_eur00 | Double | Thousands of euros (constant 2000) |
| Expenditure_m_eur2020 | Double | Thousands of euros (constant 2020) |

**Missing value codes (NA):**
- `NA` in `Narea`: unclassified programme axis
- `NA` in `Gasto_m_eur00`: record excluded from the final dataset

**Abbreviations:**
- MECUs: Million ECUs
- m_eur00: Thousands of euros (2000 constant prices)
- m_eur2020: Thousands of euros (2020 constant prices)
- ERDF: European Regional Development Fund (FEDER)
- CF: Cohesion Fund (Fondo de Cohesión)
- CCAA: Autonomous Communities
- NUTS2: Nomenclature of Territorial Units for Statistics, Level 2
- DGFC: Directorate-General for Community Funds
- INE: National Institute of Statistics
- CPI: Consumer Price Index

**Note:** Cells with a value of 0 indicate that there is no certified expenditure for that combination.
<br><br>

## Contributing 🖇️

Please read [CONTRIBUTING.md](https://gist.github.com/paulinoms/ERDF-CF-Spain-NUTS2-1989-2020) for details on the code of conduct and the process for submitting pull requests.

**Areas where help is needed:**

* Extend time coverage with new time periods.
* Improve the documentation and usage examples.
* Develop interactive visualisations using Shiny.
* Translate the documentation into other languages (Catalan, Galician, Basque, French, German).

**To contribute:**

1. Fork the project.
2. Create a branch for your feature (`git checkout -b feature/new-feature`).
3. Make your changes and commit them (`git commit -m “Add new feature”`).
4. Push to the branch (`git push origin feature/new-feature`).
5. Open a Pull Request.
<br>

##  Wiki 📖

You can find much more information on how to use this project on the [Wiki](https://github.com/paulinoms/ERDF-CF-Spain-NUTS2-1989-2020/wiki)
---
**Content available on the Wiki:**

* [Detailed guide to data sources](https://github.com/tu/proyecto/wiki/Fuentes-de-datos)
* [Data transformation and cleaning methodology](https://github.com/tu/proyecto/wiki/Metodología)
* [Frequently asked questions (FAQ)](https://github.com/tu/proyecto/wiki/FAQ)
* [R analysis tutorials](https://github.com/tu/proyecto/wiki/Tutoriales)
* [Complete data dictionary](https://github.com/tu/proyecto/wiki/Diccionario-de-datos)

**Open access repositories:**
* [Zenodo](https://zenodo.org/records/19171054)
<br>

## Versioning 📌

[SemVer](http://semver.org/) is used for versioning. For all available versions, see the [tags in this repository](https://github.com/paulinoms/ERDF-CF-Spain-NUTS2-1989-2020/tags)

| Version | Date | Main changes |
|---------|-------|---------------------|
| 1.0.0 | 22 March 2026 | Initial release. Coverage 1989–2020. |

<br>

## Authors ✒️
---

| Author(s) | GitHub username | Work carried out |  
|-----------|-----------------|------------------|
| **Paulino Montes-Solla** | [paulinoms](https://github.com/paulinoms) | Initial launch and coverage period 1989–2020. |


You can also view the list of all [contributors](https://github.com/paulinoms/ERDF-CF-Spain-NUTS2-1989-2020/contributors) who have contributed to this project.

**Paulino Montes-Solla**, Senior Researcher at the ECOBAS Inter-University Center and the GCD Group, Department of Economics, Faculty of Economics and Business, University of A Coruña (UDC), Campus de Elviña, s/n, 15008, A Coruña (Spain), Email: [paulino.montes.solla@udc.es](mailto:paulino.montes.solla@udc.es). ORCID: [0000-0002-5608-6080](https://orcid.org/0000-0002-5608-6080)
<br></br>

## Recommended citation: ⚠️

**Montes-Solla, P.** (2026). ERDF and Cohesion Fund Certified Expenditure in Spain by NUTS2 Region, Programming Axis and Thematic Area, 1989-2020 \[Dataset and R code]. Universidade da Coruña. [https://doi.org/10.5281/zenodo.19171054](https://doi.org/10.5281/zenodo.19171054)
<br><br>

## Data Sources 📊

**Keywords**
European Structural Funds; ERDF; Cohesion Fund; Spain; Regional Policy; EU cohesion policy; regional development; certified expenditure; programming periods; Autonomous Communities; NUTS2; panel data; constant prices; Fondos Estructurales; FEDER; Fondo de Cohesion; España; Política Regional

**Geographical scope**
Geographical scope: Spain – 17 Spanish regions or Autonomous Communities (CCAA) + national/multi-regional programmes


**Approximate coordinates:**
```r
Iberian Peninsula:
  Latitude : 36° 00' 0.3" N  to  43° 47' 28.6" N
  Longitude: 9° 17' 46"   W  to   3° 19' 05"   E

Balearic Islands:
  Latitude : 38° 40' 30" N   to  40° 05' 48" N
  Longitude: 1° 12' 47"  E   to   4° 19' 29" E

Canary Islands:
  Latitude : 27° 37' 50" N   to  29° 25' 06" N
  Longitude: 18° 09' 38" W   to  13° 19' 35" W
```


**Time periods:**
The data sources used to compile this dataset are public institutional sources:

**Period 1989–2006:**
* Annual Reports of the Directorate-General for Community Funds (DGFC), Ministry of Finance, Spain. Available at: [https://www.fondoseuropeos.hacienda.gob.es/sitios/dgfc/es-ES/ei/er/paginas/iadgfe.aspx](https://www.fondoseuropeos.hacienda.gob.es/sitios/dgfc/es-ES/ei/er/paginas/iadgfe.aspx)

**Period 2007–2020:**
* EU Cohesion Open Data Platform, European Commission. Available at: [https://cohesiondata.ec.europa.eu/](https://cohesiondata.ec.europa.eu/)


**Additional data:**
* EUROSTAT, table [ert_bil_conv_a] — Annual ECU/EUR exchange rates. Available at: [ert_bil_conv_a](https://ec.europa.eu/eurostat/databrowser/view/ert_bil_conv_a$defaultview/default/table?lang=en)
* INE/IPC Spain, year-on-year rates (December), base 2000. Available at: [https://ine.es/](https://ine.es/)
* Nomenclature of Territorial Units for Statistics (NUTS): EUROSTAT
<br>

## Compilation dates 📅
---

* **First version of the Excel database:** March 2017
* **Current version:** March 2026
* **Coverage of original sources:** 1989–2021 (years of implementation)
* **Coverage of the final dataset:** 1989–2020
<br>


## What does this database provide? 📌
---
* It is the **only public dataset** that provides a continuous longitudinal series with simultaneous breakdowns by: (1) all periods since 1989, (2) the 17 Spanish autonomous communities, (3) programming axis and harmonised thematic area.
* **Coverage 1989–2006:** the EU platform only covers the period from 2007 onwards. This database covers the first three financial frameworks (1989–2006), with data sourced from the DGFC Annual Reports, which are difficult to access.
* **A single longitudinal table:** allows for the analysis of regional convergence without having to combine six different sources.
* **Breakdown by programming axis:** for the entire period, not just by thematic objective.
* **Breakdown by autonomous community:** from 1989, standardising the 17 autonomous communities over 32 years.
* **Series in constant euros (2000 and 2020):** the platform only provides current values.
* **Custom thematic classification:** standardised into 7 comparable areas across all periods.
* **Reproducibility:** complete R script documenting all transformations performed.
* **Open data:** available under an open licence for use in research and public policy.

<br>

**Thematic classification into 7 areas:**

|Code|Area|Description|
|-|-|-|
|1|Infrastructure|Transport infrastructure (roads, railways, ports, airports, others)|
|2|Productive activities|Productive activities (business support, industrial R&D)|
|3|Local and urban development|Local and urban development (urban regeneration, social services)|
|4|Energy and environment|Energy and environment (renewable energy, waste management, water)|
|5|Knowledge|Knowledge economy (research, technological development, innovation)|
|6|Telecommunications and ICT|Telecommunications and ICT (broadband, digital infrastructure)|
|7|Technical assistance|Technical assistance (management, monitoring, evaluation of funds)|

<br>

## Publications that cite or use this dataset: 📝
---

**Faina, A., Lopez-Rodriguez, J., & Montes-Solla, P.** (2020). European Union regional policy and development in Spain: capital widening and productivity stagnation over 1989–2010. *Regional Studies*, 54(1), 106–119. [https://doi.org/10.1080/00343404.2018.1542127](https://doi.org/10.1080/00343404.2018.1542127)

<br>

## License 📄
---

This project is licensed under the Creative Commons Attribution 4.0 International (CC BY 4.0) licence – see the [LICENSE.md](LICENSE.md) file for details.

**You are free to:**

* Share — copy and redistribute the material in any medium or format
* Adapt — remix, transform and build upon the material for any purpose, including commercially

**Under the following conditions:**

* Attribution — you must give appropriate credit, provide a link to the licence, and indicate if changes have been made.

For more information: [https://creativecommons.org/licenses/by/4.0/](https://creativecommons.org/licenses/by/4.0/)

<br>

## Acknowledgments 🎁
---

* **Institutional acknowledgements:**

  * The Spanish Ministry of Finance for providing access to the annual reports
  * The European Commission for the Cohesion Open Data Platform
  * The National Statistics Institute (INE) for the CPI data
  * The autonomous communities for their collaboration in the implementation of the funds

* **Funding:**

  * There is no specific project funding, but this work has been made possible thanks to internal funding from the [GCD research group] [https://gcd.udc.es] (S.U.G. reference group)
