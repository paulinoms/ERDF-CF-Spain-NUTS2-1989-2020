-------------------
GENERAL INFORMATION
-------------------

Title of Dataset:
  ERDF and Cohesion Fund Certified Expenditure in Spain by NUTS2 Region,
  Programming Axis and Thematic Area, 1989-2020


Author/Principal Investigator Information

  Name:        Paulino Montes-Solla
  ORCID:       https://orcid.org/0000-0002-5608-6080
  Institution: ECOBAS & GCD, Department of Applied Economics,
               Faculty of Economics and Business,
               Universidade da Coruña (UDC), Spain
  Address:     Campus de Elviña, s/n, 15071, A Coruña, Spain
  Email:       paulino.montes.solla@udc.es


Date of data collection:
  First version of the underlying Excel database: March 2017
  Current version of the database: March 2026
  Source data coverage: 1989-2021 (execution years)
  Final dataset coverage: 1989-2020

Geographic location of data collection:
  Spain — 17 Autonomous Communities (Comunidades Autónomas, CCAA)
  + national/multi-regional programmes
  Geographic scope: national (NUTS-1 and NUTS-2 level)

  Approximate bounding coordinates:
    Iberian Peninsula:
      Latitude : 36° 00' 0.3" N  to  43° 47' 28.6" N
      Longitude: 9° 17' 46" W    to  3° 19' 05" E
    Balearic Islands:
      Latitude : 38° 40' 30" N   to  40° 05' 48" N
      Longitude: 1° 12' 47" E    to  4° 19' 29" E
    Canary Islands:
      Latitude : 27° 37' 50" N   to  29° 25' 06" N
      Longitude: 18° 09' 38" W   to  13° 19' 35" W

Information about funding sources or sponsorship:
  No specific project funding is associated with this dataset.
  The original database was compiled during the author's doctoral dissertation
  (Universidade da Coruña, 2017). It has been updated and expanded for research
  purposes in the framework of the author's academic activity at UDC.

General description:
  This dataset compiles certified expenditure data from the European Regional
  Development Fund (ERDF) and the Cohesion Fund (CF) in Spain, covering six
  programming periods from 1989 to 2020. A script has been created in RStudio
  to perform the necessary transformations to generate the output, where the
  data is disaggregated by Autonomous Community (CCAA / NUTS2 region),
  execution year, programming axis (Eje), and thematic area (Area).
  All monetary values are expressed in thousands of euros at constant 2000 prices
  (Gasto_m_eur00) and at constant 2020 prices (Gasto_m_eur2020),
  using the Spanish CPI (INE) as the deflator.

  To the author's knowledge, this is the only publicly available dataset
  providing a continuous longitudinal series of EU Structural and Cohesion
  Fund expenditure in Spain broken down simultaneously by:
    (1) all programming periods since 1989,
    (2) all 17 Autonomous Communities,
    (3) programming axis and harmonised thematic area.

  For the period 1989-2006, the data were compiled manually from the Annual
  Reports of the Directorate-General for Community Funds (DGFC), Ministry of
  Economy and Finance, Spain. For the periods 2007-2013 and 2014-2020, data
  were collected from the EU Cohesion Open Data Platform
  (cohesiondata.ec.europa.eu), which provides figures at current prices but
  does not offer a unified longitudinal structure across programming periods.

Keywords:
  European Structural Funds; ERDF; Cohesion Fund; Spain; regional policy;
  EU cohesion policy; regional development; certified expenditure;
  programming periods; Autonomous Communities; NUTS2; panel data;
  constant prices; Fondos Estructurales; FEDER; Fondo de Cohesion;
  Espana; politica regional


--------------------------
SHARING/ACCESS INFORMATION
--------------------------

Open Access to data: Open

Licenses/restrictions placed on the data, or limitations of reuse:
  Creative Commons Attribution 4.0 International (CC BY 4.0)
  https://creativecommons.org/licenses/by/4.0/

  You are free to share and adapt the material for any purpose, including
  commercial use, provided that appropriate credit is given, a link to the
  licence is provided, and any changes made are indicated.

  Data sources used in the construction of this dataset are public
  institutional sources:
    - Informes Anuales de la DG de Fondos Comunitarios (DGFC), Ministerio de
      Hacienda, España (1989-2010). Available at:
      https://www.fondoseuropeos.hacienda.gob.es/sitios/dgfc/es-ES/ei/er/paginas/iadgfe.aspx
    - EU Cohesion Open Data Platform, European Commission (2007-2021).
      Available at: https://cohesiondata.ec.europa.eu/
    - EUROSTAT, table [ert_bil_conv_a] — ECU/EUR annual exchange rates.
    - INE — CPI Spain, interannual rates (December), base 2000.
      Available at: https://ine.es/

Citation for and links to publications that cite or use the data:
  Faina, A., Lopez-Rodriguez, J., & Montes-Solla, P. (2020). European Union
  regional policy and development in Spain: capital widening and productivity
  stagnation over 1989-2010. Regional Studies, 54(1), 106-119.
  https://doi.org/10.1080/00343404.2018.1543701

Links to other publicly accessible locations of the data:
  GitHub : https://github.com/paulinoms/ERDF-CF-Spain-NUTS2-1989-2020
  Zenodo : https://doi.org/10.5281/zenodo.19171054

Was data derived from another source?
  Yes. See sources listed above under "Licenses/restrictions".
  The original data have been recompiled, harmonised, classified by thematic
  area, and deflated by the dataset author. The resulting database constitutes
  an original scholarly contribution.

Recommended citation for this dataset:
  Montes-Solla, P. (2026). ERDF and Cohesion Fund Certified Expenditure in
  Spain by NUTS2 Region, Programming Axis and Thematic Area, 1989-2020
  [Dataset and R code]. Universidade da Coruna.
  https://doi.org/10.5281/zenodo.19171054


--------------------
DATA & FILE OVERVIEW
--------------------

File list:

  ERDF_CF_Spain_NUTS2_1989_2020_build.R
    R script (English version) that fully reproduces the dataset from the
    source Excel file. Reads raw data, applies monetary conversions,
    classifies observations by thematic area, deflates to constant prices,
    and exports all outputs. No internet connection required.
    Run time: < 2 minutes on a standard PC.

  FEDER_FC_Espana_NUTS2_1989_2020_construccion.R
    Spanish version of the above R script (identical logic, Spanish comments
    and messages). Provided for accessibility to Spanish-speaking users.

  data/
    ERDF_CF_Spain_NUTS2_1989_2020_source.xlsx
      Source Excel workbook with raw data in 7 sheets:
        Reg.89-93  : ERDF Regional 1989-1994 (MECUs)
        Reg.94-99  : ERDF Regional 1994-2003 (MECUs / M euros)
        Reg.00-06  : ERDF Regional 2001-2009 (M euros current)
        FC.89-06   : Cohesion Fund 1989-2007 (MECUs / M euros)
        07-13      : ERDF + CF 2007-2016 (M euros current, EU Open Data)
        14-20      : ERDF 2014-2021 (M euros current, EU Open Data)
        IPC-Ptas   : Monetary conversion factors (EUR/ECU, CPI deflator)

  output/  [generated automatically by the R scripts]

    ERDF_CF_Spain_NUTS2_1989_2020.rda
      R serialised object. Load with:
        load("ERDF_CF_Spain_NUTS2_1989_2020.rda")
      Contains the full dataset as a data.frame (BD_FE_1989_2020).

    ERDF_CF_Spain_NUTS2_1989_2020.csv
      CSV file (UTF-8 encoding), same content as the .rda file.

    ERDF_CF_Spain_NUTS2_1989_2020.xlsx
      Excel workbook with 7 sheets:
        Main_dataset   : full dataset (all records, EUR2000 and EUR2020)
        Pivot_EUR2000  : NUTS2 x Year x Area matrix (euros constant 2000)
        Pivot_EUR2020  : NUTS2 x Year x Area matrix (euros constant 2020)
        Summary_areas  : totals by thematic area
        Summary_period : totals by thematic area and programming period
        Metadata       : dataset description and references
        Refunds_log    : log of negative values set to zero

    ERDF_CF_Spain_NUTS2_1989_2020_codebook.xlsx
      Fully documented Excel workbook (7 sheets) including source tables,
      conversion factor tables, full dataset, pivot tables, and metadata.

    ERDF_CF_Spain_NUTS2_pivot_EUR2000.rda
      R object: pivot table NUTS2 x Year x Thematic Area (constant 2000 euros).

    ERDF_CF_Spain_NUTS2_pivot_EUR2020.rda
      R object: pivot table NUTS2 x Year x Thematic Area (constant 2020 euros).

Type of version:
  Final processed dataset (v2.0). Values represent certified expenditure
  (not committed or planned amounts), expressed in thousands of euros at
  constant prices.

Total size: < 30 MB (all files combined)

Are there multiple versions of the dataset?
  Yes. The first version (v1.0) was created in March 2017 as part of the
  author's doctoral dissertation at UDC and covered periods up to 2013.
  Version 2.0 (March 2026) extends coverage to 2020, adds constant 2020
  prices, and improves methodological documentation.


--------------------------
METHODOLOGICAL INFORMATION
--------------------------

Description of methods used for collection/generation of data:

  For periods 1989-2006, data were manually compiled from the Annual Reports
  of the Direccion General de Fondos Comunitarios (DGFC), Ministerio de
  Economia y Hacienda, Spain. Specific page references for each year and
  report are documented in the R script (section headers and doc_sources
  table in Section 13). The original compilation was carried out in 2017 for
  the author's doctoral research and has subsequently been extended and revised.

  For periods 2007-2013 and 2014-2020, data were downloaded from the EU
  Cohesion Open Data Platform on 09/09/2021 and cross-verified against the
  source (842 rows for 2007-2013 and 729 rows for 2014-2020, 100% match in
  both cases).

Methods for processing the data:

  (1) Monetary conversion to thousands of euros at constant 2000 prices:
      - Pre-2000 data (MECUs): value x EUR/ECU(year) x 1000
        EUR/ECU factors: EUROSTAT table [ert_bil_conv_a]
      - Post-1999 data (M euros current): value x CPI_factor(year) x 1000
        CPI factors: INE Spain, interannual December rate, base 2000 = 1.0

  (2) Deflation to constant 2020 prices:
      Gasto_m_eur2020 = Gasto_m_eur00 x CPI_DEFLATOR_2000_2020
      CPI_DEFLATOR_2000_2020 = 1.50644811 (product of CPI rates 2001-2020)
      The same CPI source is used in both conversion steps, ensuring full
      methodological consistency.

  (3) Thematic classification into 7 areas:
      For 1989-2006: direct correspondence table (axis name -> thematic area)
      For 2007-2020: thematic area codes sourced directly from EU Open Data
      The 7 thematic areas are:
        1 = Infraestructuras          (Transport infrastructure)
        2 = Actividades productivas   (Productive activities)
        3 = Desarrollo local y urbano (Local and urban development)
        4 = Energia y medio ambiente  (Energy and environment)
        5 = Conocimiento              (Knowledge economy, R&D, ICT)
        6 = Comunicaciones y digitalizacion (Telecommunications and ICT)
        7 = Asistencia tecnica        (Technical assistance)

  (4) Negative values: certification refunds (values < 0) are set to zero
      before conversion. A complete log of all such records is included in
      the output Excel workbook (sheet "Refunds_log") for full traceability.

  (5) All monetary output columns are rounded to 2 decimal places.

Instrument- or software-specific information needed to interpret the data:
  Language        : R (version >= 4.1.0 recommended)
  Required packages: readxl, dplyr, tidyr, writexl, stringr, tibble
  All packages available on CRAN. Installed automatically by the script if
  not present. No additional system dependencies required.
  Platform        : Windows, macOS, Linux (tested on Windows 10/11, R 4.3.x)

Quality-assurance procedures:
  - Cross-validation of computed totals against the original source Excel
    (tolerance: < 0.1% difference; result displayed at runtime).
  - Verification that no negative values remain after truncation.
  - Check for unclassified programming axes (NA in Narea column).
  - Structural check: one row per NUTS2 region x Year in pivot tables.
  - CPI deflator chain verified against INE published series.
  - EUR/ECU annual exchange rates verified against EUROSTAT [ert_bil_conv_a].

People involved with data collection, processing, analysis and submission:
  Paulino Montes-Solla, Universidade da Coruna (UDC), 2017 and 2026.


-----------------------------------------
DATA-SPECIFIC INFORMATION FOR:
  ERDF_CF_Spain_NUTS2_1989_2020 (main dataset)
-----------------------------------------

Number of variables: 11
Number of cases/rows: generated at runtime (approx. 16,000-18,000)

Variable list:

  Marco          : Character. Programme framework or fund name.
  CCAA           : Character. Name of the Autonomous Community (NUTS2 region).
  Periodo        : Character. Programming period.
                   Values: "1989-1993", "1994-1999", "2000-2006",
                           "2007-2013", "2014-2020".
                   Note: Cohesion Fund (1989-2006) has its own Periodo label.
  Anio           : Integer. Year of certified expenditure execution (1989-2020).
  Neje           : Integer. Numerical code of the programming axis.
  Eje            : Character. Name of the programming axis (Spanish).
  Narea          : Integer. Thematic area code (1-7; see classification above).
  Area           : Character. Thematic area name (normalised, in Spanish).
  Fuente         : Character. Source sheet identifier.
                   Values: "Reg.89-93", "Reg.94-99", "Reg.00-06",
                           "FC.89-06", "07-13", "14-20".
  Gasto_m_eur00  : Double. Certified expenditure in thousands of euros
                   at constant 2000 prices. 2 decimal places.
  Gasto_m_eur2020: Double. Certified expenditure in thousands of euros
                   at constant 2020 prices. 2 decimal places.
                   Computed as: Gasto_m_eur00 x 1.50644811

Missing data codes:
  NA in Narea        : programming axis not found in the classification table
                       (see Section 3 of the R script).
  NA in Gasto_m_eur00: record excluded from final dataset
                       (filter applied in Section 10 of the R script).

Specialised formats or abbreviations:
  MECUs     : Millions of ECU (pre-euro European Currency Unit)
  m_eur00   : Thousands of euros at constant 2000 prices
  m_eur2020 : Thousands of euros at constant 2020 prices
  ERDF      : European Regional Development Fund (FEDER in Spanish)
  CF        : Cohesion Fund (Fondo de Cohesion in Spanish)
  CCAA      : Comunidades Autonomas (Autonomous Communities of Spain)
  NUTS2     : Nomenclature of Territorial Units for Statistics, level 2
  DGFC      : Direccion General de Fondos Comunitarios, Spain
  INE       : Instituto Nacional de Estadistica (Spanish Statistics Office)
  CPI/IPC   : Consumer Price Index (Indice de Precios al Consumo)


-----------------------------------------
DATA-SPECIFIC INFORMATION FOR:
  ERDF_CF_Spain_NUTS2_pivot_EUR2000 and _EUR2020 (pivot tables)
-----------------------------------------

Number of variables: 9 (CCAA + Anio + 7 thematic area columns)
Number of cases/rows: 1 per NUTS2 region x Year combination

Variable list:
  CCAA                           : Character. NUTS2 region name.
  Anio                           : Integer. Execution year.
  Infraestructuras               : Double. Thousands of euros.
  Actividades productivas        : Double. Thousands of euros.
  Desarrollo local y urbano      : Double. Thousands of euros.
  Energia y medio ambiente       : Double. Thousands of euros.
  Conocimiento                   : Double. Thousands of euros.
  Comunicaciones y digitalizacion: Double. Thousands of euros.
  Asistencia tecnica             : Double. Thousands of euros.

  Note: pivot_EUR2000 contains constant 2000 euro values.
        pivot_EUR2020 contains constant 2020 euro values.
        Cells with value 0 indicate no certified expenditure recorded
        for that NUTS2-year-area combination.

Missing data codes:
  0 (zero-fill applied across all area columns; no NA values in pivot tables).
