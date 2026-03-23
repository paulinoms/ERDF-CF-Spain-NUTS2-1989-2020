# ERDF-CF-Spain-NUTS2-1989-2020

This dataset compiles certified information on expenditure from the European Regional Development Fund (ERDF) and the Cohesion Fund (CF) in Spain, covering six programming periods from 1989 to 2020. A script has been created in RStudio to perform the necessary transformations to generate the output, where the data is disaggregated by autonomous community (CCAA / NUTS 2 region), year of implementation, programming axis (Axis) and thematic area (Area). All monetary values are expressed in thousands of euros at constant 2000 prices (Gasto_m_eur00) and at constant 2020 prices (Gasto_m_eur2020), using the Spanish CPI (INE) as the deflator.

Data sources used in the construction of this dataset are public institutional sources:
    - Informes Anuales de la DG de Fondos Comunitarios (DGFC), Ministerio de Hacienda, España (1989-2010). Available at: https://www.fondoseuropeos.hacienda.gob.es/sitios/dgfc/es-ES/ei/er/paginas/iadgfe.aspx
    - EU Cohesion Open Data Platform, European Commission (2007-2021). Available at: https://cohesiondata.ec.europa.eu/
    - EUROSTAT, table [ert_bil_conv_a] — ECU/EUR annual exchange rates.
    - INE/CPI Spain, interannual rates (December), base 2000. Available at: https://ine.es/

For the period 1989-2006, the data were compiled manually from the Annual Reports of the Directorate-General for Community Funds (DGFC), Ministry of Economy and Finance, Spain. For the periods 2007-2013 and 2014-2020, data were collected from the EU Cohesion Open Data Platform (cohesiondata.ec.europa.eu), which provides figures at current prices but does not offer a unified longitudinal structure across programming periods.

What this database provides that is not available on the platform?
* Coverage 1989–2006: the EU platform only covers the period from 2007 onwards. Your database covers the first three financial frameworks (1989–2006), with data sourced from the DGFC Annual Reports, which are difficult to access.
* A single longitudinal table enabling analysis of regional convergence without having to combine 6 different sources.
* Breakdown by programming axis for the entire period, not just by thematic objective.
* Breakdown by autonomous community since 1989, standardising the 17 autonomous communities over 32 years.
* Series in constant euros (2000 and 2020): the platform only provides current values.
* A proprietary, standardised thematic classification across 7 areas comparable across all periods.

Thematic classification into 7 areas:
* 1 = Infraestructuras (Transport infrastructure)
* 2 = Actividades productivas (Productive activities)
* 3 = Desarrollo local y urbano (Local and urban development)
* 4 = Energia y medio ambiente (Energy and environment)
* 5 = Conocimiento (Knowledge economy, R&D, ICT)
* 6 = Comunicaciones y digitalizacion (Telecommunications and ICT)
* 7 = Asistencia tecnica (Technical assistance)
