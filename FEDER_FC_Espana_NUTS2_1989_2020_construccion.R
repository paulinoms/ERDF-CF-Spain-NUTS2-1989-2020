# ==============================================================================
#
#  FEDER_FC_Espana_NUTS2_1989_2020 — Fondos Estructurales y de Cohesión en España por CCAA, Eje y Área, 1989-2020
#  Período de cobertura: 1989-2020 | 6 períodos de programación | 17 CCAA
#
#  Autor   : Paulino Montes-Solla
#  ORCID   : https://orcid.org/0000-0002-5608-6080
#  Afil.   : ECOBAS & GCD, Departamento de Economía, Universidade da Coruña (UDC), España
#  Email   : paulino.montes.solla@udc.es
#  Repo    : https://github.com/paulinoms/ERDF-CF-Spain-NUTS2-1989-2020
#  Versión : 2.0 (optimizada y robustecida)
#  Fecha   : 2026-04-19
#  Licencia: Creative Commons Attribution 4.0 International (CC BY 4.0)
#             https://creativecommons.org/licenses/by/4.0/
#
# ------------------------------------------------------------------------------
#  DESCRIPCIÓN
#  Este script reproduce íntegramente la base de datos de gasto certificado
#  de los Fondos Estructurales y de Cohesión europeos en España (FEDER + FC),
#  desagregado por CCAA, año de ejecución, eje y área temática, para los
#  períodos de programación 1989-1993, 1994-1999, 2000-2006, 2007-2013 y
#  2014-2020. Las cifras se expresan en miles de euros constantes de 2000
#  (m_eur00) y en miles de euros constantes de 2020 (m_eur2020).
#
# ------------------------------------------------------------------------------
#  REPRODUCIBILIDAD
#  El script es autocontenido: lee un único archivo Excel fuente y genera
#  todos los outputs de forma determinista. Los factores de conversión
#  monetaria están hardcodeados y documentados con sus fuentes primarias
#  (EUROSTAT, INE), por lo que los resultados son reproducibles sin
#  conexión a internet.
#
# ------------------------------------------------------------------------------
#  CÓMO CITAR ESTE TRABAJO
#  Si utilizas esta base de datos o este script en una publicación académica,
#  por favor cita:
#
#    Montes-Solla, P. (2026). ERDF and Cohesion Fund Certified Expenditure in
#    Spain by NUTS2 Region, Programming Axis and Thematic Area,
#    1989-2020 [Dataset and R code]. University of A Coruña.
#    https://doi.org/10.5281/zenodo.19171054
#
# ------------------------------------------------------------------------------
#  ARCHIVOS DEL REPOSITORIO
#  ├── FEDER_FC_Espana_NUTS2_1989_2020_construccion.R   <- Este script
#  ├── data/
#  │   └── ERDF_CF_Spain_NUTS2_1989_2020_source.xlsx    <- Datos fuente
#  ├── output/                                           <- Generado automáticamente
#  │   ├── ERDF_CF_Spain_NUTS2_1989_2020.rda
#  │   ├── ERDF_CF_Spain_NUTS2_1989_2020.xlsx
#  │   ├── ERDF_CF_Spain_NUTS2_1989_2020.csv
#  │   ├── ERDF_CF_Spain_NUTS2_pivot_EUR2000.rda
#  │   └── ERDF_CF_Spain_NUTS2_pivot_EUR2020.rda
#  ├── README.md
#  └── LICENSE
#
# ==============================================================================

# ============================================================
# LIMPIAR ENTORNO Y CONFIGURAR OPCIONES
# ============================================================
rm(list = ls())
if (.Platform$OS.type == "windows") {
  options(encoding = "UTF-8")
  tryCatch(Sys.setlocale("LC_ALL", "Spanish_Spain.UTF-8"),
           error = function(e) Sys.setlocale("LC_ALL", "Spanish"))
}
options(OutDec = ",", big.mark = ".")  # Para evitar warnings de formato

# ------------------------------------------------------------------------------
# SECCIÓN 1 · CONFIGURACIÓN: DIRECTORIO DE TRABAJO Y PAQUETES
# ------------------------------------------------------------------------------
# AJUSTA esta ruta al directorio donde se encuentra el archivo fuente
setwd("G:/Mi unidad/- LINO DOCS -/00. LINO/- ACADEMIA -/Zenodo/2026 BD Fondos Europeos (1989-2020)")

# Paquetes necesarios (mínimos)
paquetes <- c("readxl", "writexl", "stringr")
nuevos   <- paquetes[!paquetes %in% installed.packages()[, "Package"]]
if (length(nuevos)) install.packages(nuevos)
invisible(lapply(paquetes, library, character.only = TRUE))

ARCHIVO  <- "ERDF_CF_Spain_NUTS2_1989_2020_source.xlsx"
ARCHIVO2 <- "ERDF_CF_Spain_NUTS2_1989_2020_codebook.xlsx"

if (!file.exists(ARCHIVO))
  stop("ERROR: No se encuentra '", ARCHIVO, "'\nDir: ", getwd())

cat("\n========================================================\n")
cat("  RECONSTRUCCION BD FEDER DESDE HOJAS REG.*\n")
cat("  Fuente :", ARCHIVO, "\n")
cat("  Dir    :", getwd(), "\n")
cat("========================================================\n\n")

# Detectar la hoja IPC de forma robusta
hojas    <- excel_sheets(ARCHIVO)
hoja_ipc <- hojas[str_detect(hojas, "(?i)IPC|Ptas")][1]
cat("Hoja IPC detectada:", hoja_ipc, "\n\n")

# Helper: fuerza exactamente 2 decimales en todas las columnas numéricas
forzar_2dec <- function(df) {
  df[] <- lapply(df, function(col) {
    if (is.numeric(col)) round(col, 2) else col
  })
  return(df)
}

# ------------------------------------------------------------------------------
# DEFLACTOR IPC €constantes2000 → €constantes2020
# ------------------------------------------------------------------------------
ipc_tasas_2000_2020 <- c(
  "2001" = 0.040, "2002" = 0.027, "2003" = 0.040, "2004" = 0.026,
  "2005" = 0.032, "2006" = 0.037, "2007" = 0.027, "2008" = 0.042,
  "2009" = 0.014, "2010" = 0.008, "2011" = 0.030, "2012" = 0.024,
  "2013" = 0.029, "2014" = 0.003, "2015" = -0.010, "2016" = 0.000,
  "2017" = 0.016, "2018" = 0.011, "2019" = 0.012, "2020" = 0.008
)
DEFLACTOR_IPC_2000_2020 <- Reduce(function(acc, r) acc * (1 + r),
                                  ipc_tasas_2000_2020,
                                  accumulate = FALSE)
cat(sprintf("Deflactor IPC \u20ac2000 -> \u20ac2020 : %.10f\n", DEFLACTOR_IPC_2000_2020))
cat(sprintf("  (1 \u20ac de 2000 = %.4f \u20ac de 2020)\n\n", DEFLACTOR_IPC_2000_2020))

# ------------------------------------------------------------------------------
# SECCIÓN 2 · TABLAS DE CONVERSIÓN MONETARIA
# ------------------------------------------------------------------------------
cat("-- Cargando factores de conversion monetaria ...\n")

raw_ipc <- read_excel(ARCHIVO, sheet = hoja_ipc, col_names = FALSE)

# Factores EUR/ECU: filas 2-35, columnas 9 y 10 del Excel
tasa_ecu_eur <- raw_ipc[2:35, 9:10] |>
  setNames(c("Anio", "eur_por_ecu")) |>
  mutate(across(everything(), as.numeric)) |>
  filter(!is.na(Anio)) |>
  distinct(Anio, .keep_all = TRUE)

# Factor IPC acumulado: filas 13-35, columnas 9-12
ipc_deflactor <- raw_ipc[13:35, 9:12] |>
  setNames(c("Anio", "Factor_IPC_acum", "m", "d")) |>
  mutate(across(c(Anio, Factor_IPC_acum), as.numeric)) |>
  filter(!is.na(Anio))

# Tabla maestra de conversión
conv_master <- tasa_ecu_eur |>
  full_join(ipc_deflactor |> select(Anio, Factor_IPC_acum), by = "Anio") |>
  arrange(Anio) |>
  distinct(Anio, .keep_all = TRUE)

stopifnot("conv_master vacía" = nrow(conv_master) > 0,
          "Año 2000 ausente"  = 2000 %in% conv_master$Anio)

cat("  conv_master:", min(conv_master$Anio), "-",
    max(conv_master$Anio, na.rm = TRUE), "| filas:", nrow(conv_master), "\n")

# Función de conversión escalar
convertir <- function(valor, anio, unidad, conv) {
  if (is.na(valor) | is.na(anio)) return(NA_real_)
  if (valor == 0) return(0)
  f <- conv[conv$Anio == anio, ]
  if (nrow(f) == 0) { warning("Sin factor año ", anio); return(NA_real_) }
  f <- f[1, ]
  switch(as.character(unidad),
         "MEcus"  = as.numeric(valor * f$eur_por_ecu     * 1000),
         "MEuros" = if (anio < 2000) {
           as.numeric(valor * f$eur_por_ecu     * 1000)
         } else {
           as.numeric(valor * f$Factor_IPC_acum * 1000)
         },
         { warning("Unidad desconocida: ", unidad); NA_real_ }
  )
}

# Wrapper vectorizado (solo para unidad constante)
conv_vec <- function(v, a, u, conv) {
  as.numeric(mapply(convertir, valor = v, anio = a,
                    MoreArgs = list(unidad = u, conv = conv),
                    SIMPLIFY = TRUE))
}
cat("  Funcion convertir() definida\n\n")

# ------------------------------------------------------------------------------
# SECCIÓN 3 · TABLA CLASIFICACIÓN EJE → ÁREA (períodos 1989-2006)
# ------------------------------------------------------------------------------
cat("-- Construyendo tabla clasificacion Eje -> Area ...\n")

tabla_areas <- tribble(
  ~Eje,                                                                            ~Narea, ~Area,
  
  # ÁREA 1: INFRAESTRUCTURAS
  "Integración y articulación territorial",                                            1L, "Infraestructuras",
  "Mejora de la Red de Comunicaciones",                                               1L, "Infraestructuras",
  "Desarrollo de la Red de Transportes",                                              1L, "Infraestructuras",
  "Redes de Transporte y Energía",                                                    1L, "Infraestructuras",
  "Infraestructuras",                                                                  1L, "Infraestructuras",
  
  # ÁREA 2: ACTIVIDADES PRODUCTIVAS
  "Industria, servicios y artesanía",                                                  2L, "Actividades productivas",
  "Turismo",                                                                           2L, "Actividades productivas",
  "Creación y desarrollo de Activ. Productivas",                                      2L, "Actividades productivas",
  "Desarrollo del tejido económico",                                                   2L, "Actividades productivas",
  "Apoyo al empleo y a la Compititividad de las Empresas",                            2L, "Actividades productivas",
  "Mejora de la Competitividad y Desarrollo del Tejido Productivo",                   2L, "Actividades productivas",
  "Mejora de la Competitividad, el Empleo y Desarrollo",                              2L, "Actividades productivas",
  
  # ÁREA 3: DESARROLLO LOCAL Y URBANO
  "Infraestructura de apoyo a la actividad económica",                                3L, "Desarrollo local y urbano",
  "Desarrollo Local y Urbano",                                                        3L, "Desarrollo local y urbano",
  
  # ÁREA 4: ENERGÍA Y MEDIO AMBIENTE
  "Protección y mejora del Medio Ambiente",                                           4L, "Energía y medio ambiente",
  "Protección del Medio Ambiente",                                                    4L, "Energía y medio ambiente",
  "Medio Ambiente, Entorno Natural y Recurso Hídrico",                               4L, "Energía y medio ambiente",
  "Infraestructuras / Medio Ambiente",                                                4L, "Energía y medio ambiente",
  
  # ÁREA 5: CONOCIMIENTO
  "Apoyo a I+D y equipamientos para formación",                                       5L, "Conocimiento",
  "Desarrollo de la Investigación de la Tecnología e Innovación",                     5L, "Conocimiento",
  "Sociedad Conocimiento (Innovación, I+D, Soc. Info) y Telec.",                      5L, "Conocimiento",
  "Sociedad del Conocimiento (Innovación, I+D,...)",                                  5L, "Conocimiento",
  
  # ÁREA 6: COMUNICACIONES Y DIGITALIZACIÓN
  "Desarrollo de Redes de Comunicaciones",                                            6L, "Comunicaciones y digitalización",
  
  # ÁREA 7: ASISTENCIA TÉCNICA
  "Asistencia técnica",                                                               7L, "Asistencia técnica",
  "Asistencia técnica, Seguimiento e Información",                                    7L, "Asistencia técnica",
  "Medidas para Preparación, Evaluación y Seguimiento",                              7L, "Asistencia técnica"
)
cat("  Ejes clasificados:", nrow(tabla_areas), "\n\n")

# ------------------------------------------------------------------------------
# SECCIÓN 4 · REG.89-93 — FEDER Regional 1989-1994
# ------------------------------------------------------------------------------
cat("-- Procesando Reg.89-93 (DGFC 1989-1993) ...\n")

raw_reg89 <- read_excel(ARCHIVO, sheet = "Reg.89-93", col_names = TRUE)
names(raw_reg89)[c(3, 5, 12)] <- c("Periodo_col", "Anio", "Inv_MEcus_col")

db_reg89 <- raw_reg89 |>
  select(Marco, CCAA, Periodo = Periodo_col, Anio, Neje,
         Eje, Inv_MEcus = Inv_MEcus_col) |>
  mutate(Anio      = as.integer(Anio),
         Neje      = as.integer(Neje),
         Inv_MEcus = as.numeric(Inv_MEcus)) |>
  filter(!is.na(CCAA), !is.na(Anio), !is.na(Inv_MEcus)) |>
  mutate(Gasto_m_eur00 = round(conv_vec(Inv_MEcus, Anio, "MEcus", conv_master), 2)) |>
  left_join(tabla_areas, by = "Eje") |>
  select(Marco, CCAA, Periodo, Anio, Neje, Eje, Narea, Area, Gasto_m_eur00)

cat("  Reg.89-93 ->", nrow(db_reg89), "reg | años",
    min(db_reg89$Anio), "-", max(db_reg89$Anio), "\n")

# ------------------------------------------------------------------------------
# SECCIÓN 5 · REG.94-99 — FEDER Regional 1994-2003
# ------------------------------------------------------------------------------
cat("-- Procesando Reg.94-99 (DGFC 1995-2003) ...\n")

raw_reg94 <- read_excel(ARCHIVO, sheet = "Reg.94-99", col_names = TRUE)
names(raw_reg94)[c(3, 5, 12, 14)] <- c("Periodo_col", "Anio", "Inv_MEcus_col", "GastoMeur_col")

db_reg94 <- raw_reg94 |>
  select(Marco, CCAA, Periodo = Periodo_col, Anio, Neje, Eje,
         Inv_MEcus = Inv_MEcus_col, Gasto_Meur = GastoMeur_col) |>
  mutate(Anio       = as.integer(Anio),
         Neje       = as.integer(Neje),
         Inv_MEcus  = as.numeric(Inv_MEcus),
         Gasto_Meur = as.numeric(Gasto_Meur)) |>
  filter(!is.na(CCAA), !is.na(Anio)) |>
  mutate(Gasto_m_eur00 = round(case_when(
    !is.na(Inv_MEcus)  ~ conv_vec(Inv_MEcus,  Anio, "MEcus",  conv_master),
    !is.na(Gasto_Meur) ~ conv_vec(Gasto_Meur, Anio, "MEuros", conv_master),
    TRUE ~ NA_real_
  ), 2)) |>
  filter(!is.na(Gasto_m_eur00)) |>
  left_join(tabla_areas, by = "Eje") |>
  select(Marco, CCAA, Periodo, Anio, Neje, Eje, Narea, Area, Gasto_m_eur00)

cat("  Reg.94-99 ->", nrow(db_reg94), "reg | años",
    min(db_reg94$Anio), "-", max(db_reg94$Anio), "\n")

# ------------------------------------------------------------------------------
# SECCIÓN 6 · REG.00-06 — FEDER Regional 2001-2009
# ------------------------------------------------------------------------------
cat("-- Procesando Reg.00-06 (DGFC 2001-2009) ...\n")

raw_reg00 <- read_excel(ARCHIVO, sheet = "Reg.00-06", col_names = TRUE)
names(raw_reg00)[c(3, 5, 14)] <- c("Periodo_col", "Anio", "GastoMeur_col")

db_reg00 <- raw_reg00 |>
  select(Marco, CCAA, Periodo = Periodo_col, Anio, Neje, Eje,
         Gasto_Meur = GastoMeur_col) |>
  mutate(Anio       = as.integer(Anio),
         Neje       = as.integer(Neje),
         Gasto_Meur = as.numeric(Gasto_Meur)) |>
  filter(!is.na(CCAA), !is.na(Anio), !is.na(Gasto_Meur)) |>
  mutate(Gasto_m_eur00 = round(conv_vec(Gasto_Meur, Anio, "MEuros", conv_master), 2)) |>
  left_join(tabla_areas, by = "Eje") |>
  select(Marco, CCAA, Periodo, Anio, Neje, Eje, Narea, Area, Gasto_m_eur00)

cat("  Reg.00-06 ->", nrow(db_reg00), "reg | años",
    min(db_reg00$Anio), "-", max(db_reg00$Anio), "\n")

# ------------------------------------------------------------------------------
# SECCIÓN 7 · FC.89-06 — Fondo de Cohesión 1989-2007
# ------------------------------------------------------------------------------
cat("-- Procesando FC.89-06 (Fondo de Cohesion, DGFC) ...\n")

raw_fc <- read_excel(ARCHIVO, sheet = "FC.89-06", col_names = TRUE)
names(raw_fc)[c(3, 5, 12)] <- c("Periodo_col", "Anio", "GastoMecus_col")

db_fc <- raw_fc |>
  select(Marco, CCAA, Periodo = Periodo_col, Anio, Neje, Eje,
         Gasto_Mecus = GastoMecus_col) |>
  mutate(Anio        = as.integer(Anio),
         Neje        = as.integer(Neje),
         Gasto_Mecus = as.numeric(Gasto_Mecus)) |>
  filter(!is.na(CCAA), !is.na(Anio), !is.na(Gasto_Mecus)) |>
  mutate(
    unidad        = if_else(Anio < 2000, "MEcus", "MEuros"),
    Gasto_m_eur00 = round(as.numeric(mapply(
      function(v, a, u) convertir(v, a, u, conv_master),
      v = Gasto_Mecus, a = Anio, u = unidad
    )), 2)
  ) |>
  left_join(tabla_areas, by = "Eje") |>
  select(Marco, CCAA, Periodo, Anio, Neje, Eje, Narea, Area, Gasto_m_eur00)

cat("  FC.89-06  ->", nrow(db_fc), "reg | años",
    min(db_fc$Anio), "-", max(db_fc$Anio), "\n")

# ------------------------------------------------------------------------------
# SECCIÓN 8 · HOJA 07-13 — FEDER + FC 2007-2016
# ------------------------------------------------------------------------------
cat("-- Procesando hoja 07-13 (EU Cohesion Open Data 2007-2013) ...\n")

raw_0713_src <- read_excel(ARCHIVO, sheet = "07-13", col_names = TRUE)
raw_0713 <- raw_0713_src
names(raw_0713)[c(5, 6, 7, 10, 11, 12, 13, 14, 15)] <-
  c("Anio_col", "Cod_Eje", "Nom_Eje",
    "Cod_Area", "Nom_Area", "Cod_CCAA", "Nom_CCAA",
    "Gasto_EUR", "GastoMeur")

# Log de devoluciones
neg_log_07 <- raw_0713 |>
  filter(as.numeric(Gasto_EUR) < 0) |>
  transmute(Marco      = as.character(Fondo),
            CCAA       = Nom_CCAA,
            Anio       = as.integer(Anio_col),
            Eje        = Nom_Eje,
            Gasto_Euros = as.numeric(Gasto_EUR),
            Nota       = "DEVOLUCION certificacion -> asignado 0")

cat("  Devoluciones 07-13:", nrow(neg_log_07),
    "| total:", round(sum(neg_log_07$Gasto_Euros) / 1e6, 2), "M EUR\n")

db_0713 <- raw_0713 |>
  transmute(
    Marco   = as.character(Fondo),
    CCAA    = Nom_CCAA,
    Periodo = "2007-2013",
    Anio    = as.integer(Anio_col),
    Neje    = as.integer(Cod_Eje),
    Eje     = Nom_Eje,
    Narea   = as.integer(Cod_Area),
    Area    = Nom_Area,
    G       = pmax(as.numeric(GastoMeur), 0)
  ) |>
  filter(!is.na(CCAA), !is.na(Anio)) |>
  mutate(
    Gasto_m_eur00 = round(conv_vec(G, Anio, "MEuros", conv_master), 2),
    Area = str_replace(Area, "(?i)^asistencia\\s+t.cnica$", "Asistencia t\u00e9cnica")
  ) |>
  select(Marco, CCAA, Periodo, Anio, Neje, Eje, Narea, Area, Gasto_m_eur00)

cat("  07-13     ->", nrow(db_0713), "reg | años",
    min(db_0713$Anio), "-", max(db_0713$Anio), "\n")

# ------------------------------------------------------------------------------
# SECCIÓN 9 · HOJA 14-20 — FEDER 2014-2021
# ------------------------------------------------------------------------------
cat("-- Procesando hoja 14-20 (EU Cohesion Open Data 2014-2020) ...\n")

raw_1420_src <- read_excel(ARCHIVO, sheet = "14-20", col_names = TRUE)
raw_1420 <- raw_1420_src
names(raw_1420)[c(1, 2, 3, 4, 5, 6, 8, 9, 10, 11)] <-
  c("Marco_col", "Cod_CCAA", "Nom_CCAA", "Anio_col", "Cod_Eje",
    "Nom_Eje", "Nom_PIV", "Cod_Area", "Nom_Area", "Gasto_EUR")
names(raw_1420)[12] <- "GastoMeur"

neg_log_14 <- raw_1420 |>
  filter(as.numeric(Gasto_EUR) < 0) |>
  transmute(Marco      = Marco_col,
            CCAA       = Nom_CCAA,
            Anio       = as.integer(Anio_col),
            Eje        = Nom_Eje,
            Gasto_Euros = as.numeric(Gasto_EUR),
            Nota       = "DEVOLUCION certificacion -> asignado 0")

if (nrow(neg_log_14) > 0) {
  cat("  Devoluciones 14-20:", nrow(neg_log_14),
      "| total:", round(sum(neg_log_14$Gasto_Euros) / 1e6, 2), "M EUR\n")
} else {
  cat("  Sin valores negativos en 14-20\n")
}

db_1420 <- raw_1420 |>
  transmute(
    Marco   = as.character(Marco_col),
    CCAA    = Nom_CCAA,
    Periodo = "2014-2020",
    Anio    = as.integer(Anio_col),
    Neje    = as.integer(Cod_Eje),
    Eje     = Nom_Eje,
    Narea   = as.integer(Cod_Area),
    Area    = Nom_Area,
    G       = pmax(as.numeric(GastoMeur), 0)
  ) |>
  filter(!is.na(CCAA), !is.na(Anio)) |>
  mutate(
    Gasto_m_eur00 = round(conv_vec(G, Anio, "MEuros", conv_master), 2),
    Area = if_else(str_detect(Area, "(?i)^comunicaci"),
                   "Comunicaciones y digitalizaci\u00f3n", Area),
    Area = str_replace(Area, "(?i)^asistencia\\s+t.cnica$", "Asistencia t\u00e9cnica")
  ) |>
  select(Marco, CCAA, Periodo, Anio, Neje, Eje, Narea, Area, Gasto_m_eur00)

cat("  14-20     ->", nrow(db_1420), "reg | años",
    min(db_1420$Anio), "-", max(db_1420$Anio), "\n\n")

neg_log_total <- bind_rows(neg_log_07, neg_log_14)

# ------------------------------------------------------------------------------
# SECCIÓN 10 · BASE DE DATOS FINAL: BD_FE_1989_2020
# ------------------------------------------------------------------------------
cat("-- Construyendo BD_FE_1989_2020 ...\n")

BD_FE_1989_2020 <- bind_rows(
  db_reg89 |> mutate(Fuente = "Reg.89-93"),
  db_reg94 |> mutate(Fuente = "Reg.94-99"),
  db_reg00 |> mutate(Fuente = "Reg.00-06"),
  db_fc    |> mutate(Fuente = "FC.89-06"),
  db_0713  |> mutate(Fuente = "07-13"),
  db_1420  |> mutate(Fuente = "14-20")
) |>
  mutate(
    Gasto_m_eur00 = round(as.numeric(Gasto_m_eur00), 2),
    Anio          = as.integer(Anio),
    Narea         = as.integer(Narea),
    Area          = str_trim(Area),
    Area = if_else(str_detect(Area, "(?i)^comunicaci"),
                   "Comunicaciones y digitalizaci\u00f3n", Area),
    Area = if_else(str_to_lower(Area) == "asistencia t\u00e9cnica",
                   "Asistencia t\u00e9cnica", Area)
  ) |>
  filter(!is.na(Gasto_m_eur00), Anio >= 1989, Anio <= 2020) |>
  mutate(Gasto_m_eur2020 = round(Gasto_m_eur00 * DEFLACTOR_IPC_2000_2020, 2)) |>
  select(Marco, CCAA, Periodo, Anio, Neje, Eje, Narea, Area,
         Gasto_m_eur00, Gasto_m_eur2020) |>
  arrange(Marco, CCAA, Periodo, Anio, Eje)

cat("  Registros   :", nrow(BD_FE_1989_2020), "\n")
cat("  Años        :", min(BD_FE_1989_2020$Anio), "-",
    max(BD_FE_1989_2020$Anio), "\n")
cat("  CCAA (n)    :", n_distinct(BD_FE_1989_2020$CCAA), "\n")
cat("  Total m€00  :",
    formatC(round(sum(BD_FE_1989_2020$Gasto_m_eur00)),
            format = "f", digits = 0, big.mark = ".", big.interval = 3L), "\n")
cat("  Total m€20  :",
    formatC(round(sum(BD_FE_1989_2020$Gasto_m_eur2020)),
            format = "f", digits = 0, big.mark = ".", big.interval = 3L), "\n")

# Verificación cruzada opcional
hojas_disponibles <- excel_sheets(ARCHIVO)
if ("DB" %in% hojas_disponibles) {
  DB_orig  <- read_excel(ARCHIVO, sheet = "DB")
  col_orig <- grep("m.*00|m.00", names(DB_orig), value = TRUE, ignore.case = TRUE)[1]
  if (!is.na(col_orig)) {
    anio_col_orig <- grep("a.o.ejec|a\u00f1o.ejec", names(DB_orig),
                          ignore.case = TRUE, value = TRUE)[1]
    if (!is.na(anio_col_orig)) {
      mask_orig <- as.integer(DB_orig[[anio_col_orig]]) >= 1989 &
        as.integer(DB_orig[[anio_col_orig]]) <= 2020
      tot_orig  <- sum(as.numeric(DB_orig[[col_orig]][mask_orig]), na.rm = TRUE)
    } else {
      tot_orig <- sum(as.numeric(DB_orig[[col_orig]]), na.rm = TRUE)
    }
    tot_calc <- sum(BD_FE_1989_2020$Gasto_m_eur00, na.rm = TRUE)
    dif_pct  <- abs(tot_orig - tot_calc) / abs(tot_orig) * 100
    cat("  Total DB original:", format(round(tot_orig), big.mark = "."), "\n")
    cat("  Diferencia (%)   :", sprintf("%.4f%%\n", dif_pct))
    cat("  ->", if_else(dif_pct < 0.1, "COINCIDENCIA EXCELENTE", "REVISAR"), "\n")
  }
} else {
  cat("  [INFO] Hoja 'DB' no encontrada. Verificación cruzada omitida.\n")
}
cat("\n")

# ------------------------------------------------------------------------------
# SECCIÓN 11 · VALIDACIONES
# ------------------------------------------------------------------------------
cat("-- Validaciones ...\n")
n_neg <- sum(BD_FE_1989_2020$Gasto_m_eur00 < 0, na.rm = TRUE)
cat("  Negativos tras tratamiento:", n_neg,
    if_else(n_neg == 0, "(OK)", "(REVISAR)"), "\n")
cat("  Nulos en Gasto_m_eur00    :", sum(is.na(BD_FE_1989_2020$Gasto_m_eur00)), "\n")
cat("  Sin Narea                 :", sum(is.na(BD_FE_1989_2020$Narea)), "\n")
fuera_n2 <- BD_FE_1989_2020 |>
  mutate(Fin = as.integer(str_extract(Periodo, "\\d{4}$")),
         ok  = Anio <= (Fin + 2)) |>
  filter(!ok)
cat("  Fuera rango n+2           :", nrow(fuera_n2), "(normal, regla UE)\n\n")

# ------------------------------------------------------------------------------
# SECCIÓN 12 · TABLAS RESUMEN (versión robusta con R base)
# ------------------------------------------------------------------------------
cat("-- Construyendo tablas resumen ...\n")

# 12.1 Resumen por área temática (total 1989-2020)
resumen_areas <- aggregate(
  Gasto_m_eur00 ~ Narea + Area,
  data = BD_FE_1989_2020,
  FUN = function(x) round(sum(x, na.rm = TRUE), 2)
)
resumen_areas <- resumen_areas[order(resumen_areas$Narea), ]
rownames(resumen_areas) <- NULL

cat("\n  GASTO FEDER 1989-2020 POR AREA (miles eur00, 2 decimales):\n")
cat(sprintf("  %2s  %-36s  %22s\n", "N", "Area", "Gasto (m_eur00)"))
cat("  ", strrep("-", 64), "\n", sep = "")
for (i in seq_len(nrow(resumen_areas))) {
  cat(sprintf("  %2d  %-36s  %22.2f\n",
              resumen_areas$Narea[i], resumen_areas$Area[i],
              resumen_areas$Gasto_m_eur00[i]))
}
cat("  ", strrep("-", 64), "\n", sep = "")
cat(sprintf("  %2s  %-36s  %22.2f\n", "", "TOTAL",
            sum(resumen_areas$Gasto_m_eur00)))

# 12.2 Resumen por área y período
resumen_areas_periodo <- aggregate(
  Gasto_m_eur00 ~ Narea + Area + Periodo,
  data = BD_FE_1989_2020,
  FUN = function(x) round(sum(x, na.rm = TRUE), 2)
)
resumen_areas_periodo <- resumen_areas_periodo[order(resumen_areas_periodo$Narea, resumen_areas_periodo$Periodo), ]
rownames(resumen_areas_periodo) <- NULL

# 12.3 Tabla pivotada: CCAA × Año → columnas = áreas (€2000)
areas_esperadas <- c("Infraestructuras", "Actividades productivas",
                     "Desarrollo local y urbano", "Energía y medio ambiente",
                     "Conocimiento", "Comunicaciones y digitalización",
                     "Asistencia técnica")

temp_agg_00 <- aggregate(
  Gasto_m_eur00 ~ CCAA + Anio + Area,
  data = BD_FE_1989_2020,
  FUN = function(x) round(sum(x, na.rm = TRUE), 2)
)

pivot_ccaa_anio <- reshape(
  temp_agg_00,
  idvar = c("CCAA", "Anio"),
  timevar = "Area",
  direction = "wide"
)
names(pivot_ccaa_anio) <- gsub("Gasto_m_eur00\\.", "", names(pivot_ccaa_anio))
for (a in areas_esperadas) {
  if (!a %in% names(pivot_ccaa_anio)) pivot_ccaa_anio[[a]] <- 0
}
pivot_ccaa_anio <- pivot_ccaa_anio[, c("CCAA", "Anio", areas_esperadas)]
pivot_ccaa_anio <- pivot_ccaa_anio[order(pivot_ccaa_anio$CCAA, pivot_ccaa_anio$Anio), ]
rownames(pivot_ccaa_anio) <- NULL

cat("\n  Pivot CCAA x Anio x Area:", nrow(pivot_ccaa_anio), "filas x",
    ncol(pivot_ccaa_anio), "columnas\n\n")

# 12.4 Tabla pivotada en € constantes 2020
temp_agg_2020 <- aggregate(
  Gasto_m_eur2020 ~ CCAA + Anio + Area,
  data = BD_FE_1989_2020,
  FUN = function(x) round(sum(x, na.rm = TRUE), 2)
)

pivot_ccaa_anio_2020 <- reshape(
  temp_agg_2020,
  idvar = c("CCAA", "Anio"),
  timevar = "Area",
  direction = "wide"
)
names(pivot_ccaa_anio_2020) <- gsub("Gasto_m_eur2020\\.", "", names(pivot_ccaa_anio_2020))
for (a in areas_esperadas) {
  if (!a %in% names(pivot_ccaa_anio_2020)) pivot_ccaa_anio_2020[[a]] <- 0
}
pivot_ccaa_anio_2020 <- pivot_ccaa_anio_2020[, c("CCAA", "Anio", areas_esperadas)]
pivot_ccaa_anio_2020 <- pivot_ccaa_anio_2020[order(pivot_ccaa_anio_2020$CCAA, pivot_ccaa_anio_2020$Anio), ]
rownames(pivot_ccaa_anio_2020) <- NULL

cat("  Pivot CCAA x Anio x Area (EUR2020):", nrow(pivot_ccaa_anio_2020), "filas x",
    ncol(pivot_ccaa_anio_2020), "columnas\n\n")

# ------------------------------------------------------------------------------
# SECCIÓN 13 · METADATOS Y TABLA DE FUENTES
# ------------------------------------------------------------------------------
cat("-- Construyendo tablas de metadatos y fuentes ...\n")

doc_fuentes <- tribble(
  ~Periodo_programacion,       ~Hoja_fuente, ~Anos_datos, ~Tipo_gasto,      ~Fuente_institucional,                               ~Referencia_paginas,                                                                                    ~URL_datos,
  "1989-1993 (Regional)",      "Reg.89-93",  "1989-1994",      "MEcus",          "Informes Anuales DGFC, Min. Economía y Hacienda",   "Informe 1992: Obj.1 p.148, Obj.2 p.181",                                                               "DGFC/MINHAC (impreso)",
  "1994-1999 (Regional)",      "Reg.94-99",  "1994-2003",      "MEcus/M€uros",   "Informes Anuales DGFC, Min. Economía y Hacienda",   "Inf.1995 p.282/310 | Inf.1996 p.238 | Inf.1997 p.177 | Inf.1998 p.144 | Inf.1999 p.80 | Inf.2000-2003", "DGFC/MINHAC (impreso)",
  "2000-2006 (Regional)",      "Reg.00-06",  "2001-2009",      "M€ corr.",       "Informes Anuales DGFC, Min. Economía y Hacienda",   "Inf.2001 p.145 | Inf.2002 p.85 | Inf.2003 p.160 | Inf.2004 p.146 | Inf.2006 p.145 | n+2: 2007-2009",   "DGFC/MINHAC (impreso)",
  "1989-2006 (F.Cohesión)",    "FC.89-06",   "1989-2007",      "MEcus/M€",       "Informes Anuales DGFC, caps. Fondo de Cohesión",    "Informes anuales DGFC (capítulos específicos FC)",                                                      "DGFC/MINHAC (impreso)",
  "2007-2013 (FEDER+FC)",      "07-13",      "2007-2016",      "M€ corr.",       "EU Cohesion Open Data Platform",                    "20210909_2007_2013_ejec_dec_anual.xlsx (9 sept. 2021). 842 filas, 100% verificado",                     "https://cohesiondata.ec.europa.eu/",
  "2014-2020 (FEDER)",         "14-20",      "2014-2021",      "M€ corr.",       "EU Cohesion Open Data Platform",                    "20210909_2014_2020_ejec_dec_anual.xlsx (9 sept. 2021). 729 filas, 100% verificado",                     "https://cohesiondata.ec.europa.eu/"
)

doc_transform <- tribble(
  ~Periodo,       ~Unidad_origen,  ~Formula_m_eur00,                      ~Fuente_factor,
  "1989-1999",    "MEcus",         "MEcus x EUR/ECU(anio) x 1000",        "EUROSTAT [ert_bil_conv_a]",
  "1998-1999",    "M€uros",        "M€uros x EUR/ECU(anio) x 1000",       "EUROSTAT (EUR/ECU98=1.00480; 99=1.00000)",
  "2000",         "M€ corrientes", "M€ x 1.0 x 1000  [IPC base=1.0]",    "Año base 2000",
  "2001-2021",    "M€ corrientes", "M€ x Factor_IPC_acum(anio) x 1000",  "INE IPC armonizado (base 2000=1.0)"
)

metadatos <- tribble(
  ~Campo,                    ~Descripcion,
  "Dataset",                 "BD_FE_1989_2020 - Gasto FEDER España 1989-2020 por CCAA, año, eje y área",
  "Objeto R",                "BD_FE_1989_2020",
  "Archivo RDA",             "ERDF_CF_Spain_NUTS2_1989_2020.rda",
  "Archivo Excel",           "ERDF_CF_Spain_NUTS2_1989_2020.xlsx",
  "Fecha construccion",      format(Sys.Date(), "%Y-%m-%d"),
  "Script",                  "FEDER_FC_Espana_NUTS2_1989_2020_construccion.R",
  "Cobertura temporal",      paste(min(BD_FE_1989_2020$Anio), "-", max(BD_FE_1989_2020$Anio)),
  "Periodos programacion",   "1989-1993 | 1994-1999 | 2000-2006 | 2007-2013 | 2014-2020",
  "Registros totales",       as.character(nrow(BD_FE_1989_2020)),
  "CCAA incluidas",          paste(sort(unique(BD_FE_1989_2020$CCAA)), collapse = "; "),
  "Variables",               "Marco, CCAA, Periodo, Año, Neje, Eje, Narea, Area, Gasto_m_eur00, Gasto_m_eur2020",
  "Unidad monetaria",        "Miles de euros constantes del año 2000 (m_eur00) y 2020 (m_eur2020)",
  "Decimales",               "2 decimales forzados en todas las salidas numéricas",
  "Total gasto (m_eur00)",   format(round(sum(BD_FE_1989_2020$Gasto_m_eur00)), big.mark = "."),
  "Fuente 1989-2006",        "Informes Anuales DGFC, Ministerio de Economía y Hacienda",
  "Fuente 2007-2013",        "EU Cohesion Open Data https://cohesiondata.ec.europa.eu/",
  "Fuente 2014-2020",        "EU Cohesion Open Data https://cohesiondata.ec.europa.eu/",
  "Fuente EUR/ECU",          "EUROSTAT [ert_bil_conv_a]",
  "Fuente IPC España",       "INE https://ine.es/dynt3/inebase/es/index.htm?padre=1368",
  "NOTA clasificacion",      "Área 4=Energía y M.A., Área 5=Conocimiento (orden inverso a v4-regex)",
  "NOTA eje 'Infr.apoyo'",   "Infraestructura de apoyo a la act. económica → Área 3 (no Área 1 como en v4)"
)

cat("  Metadatos y tablas de fuentes: OK\n\n")

# ------------------------------------------------------------------------------
# SECCIÓN 14 · EXPORTACIÓN
# ------------------------------------------------------------------------------
cat("-- Exportando archivos ...\n")

# Forzar 2 decimales en todas las tablas
BD_export          <- forzar_2dec(BD_FE_1989_2020)
pivot_export       <- forzar_2dec(pivot_ccaa_anio)
pivot_export_2020  <- forzar_2dec(pivot_ccaa_anio_2020)
resumen_export     <- forzar_2dec(resumen_areas)
resumen_p_exp      <- forzar_2dec(resumen_areas_periodo)

# Renombrar columna "Anio" -> "Año" (R base, sin conflictos)
names(BD_export)[names(BD_export) == "Anio"] <- "Año"
names(pivot_export)[names(pivot_export) == "Anio"] <- "Año"
names(pivot_export_2020)[names(pivot_export_2020) == "Anio"] <- "Año"

# A) .rda — objeto R serializado
save(BD_FE_1989_2020, file = "ERDF_CF_Spain_NUTS2_1989_2020.rda")
cat("  ERDF_CF_Spain_NUTS2_1989_2020.rda\n")

# B) Pivot €2000 como objeto .rda
save(pivot_ccaa_anio, file = "ERDF_CF_Spain_NUTS2_pivot_EUR2000.rda")
cat("  ERDF_CF_Spain_NUTS2_pivot_EUR2000.rda\n")

# C) Pivot €2020 como objeto .rda
save(pivot_ccaa_anio_2020, file = "ERDF_CF_Spain_NUTS2_pivot_EUR2020.rda")
cat("  ERDF_CF_Spain_NUTS2_pivot_EUR2020.rda\n")

# D) Excel principal (7 pestañas)
write_xlsx(
  list(
    "BD_FE_1989_2020"            = BD_export,
    "Pivot_CCAA_Anno"            = pivot_export,
    "Pivot_CCAA_Anno_Area_2020"  = pivot_export_2020,
    "Resumen_Areas"              = resumen_export,
    "Resumen_Areas_Per"          = resumen_p_exp,
    "Metadatos"                  = metadatos,
    "Devoluciones"               = neg_log_total
  ),
  "ERDF_CF_Spain_NUTS2_1989_2020.xlsx"
)
cat("  ERDF_CF_Spain_NUTS2_1989_2020.xlsx  (7 pestañas)\n")

# E) CSV auxiliar UTF-8
write.csv(BD_FE_1989_2020, "ERDF_CF_Spain_NUTS2_1989_2020.csv",
          row.names = FALSE, fileEncoding = "UTF-8")
cat("  ERDF_CF_Spain_NUTS2_1989_2020.csv\n")

# F) Excel documentado (ARCHIVO2)
write_xlsx(
  list(
    "Fuentes_Periodos"           = doc_fuentes,
    "Transform_Moneda"           = doc_transform,
    "DB"                         = BD_export,
    "Pivot_CCAA_Anno_Area"       = pivot_export,
    "Pivot_CCAA_Anno_Area_2020"  = pivot_export_2020,
    "Resumen_Areas"              = resumen_export,
    "Metadatos"                  = metadatos
  ),
  ARCHIVO2
)
cat("  ", ARCHIVO2, "(7 pestañas)\n\n")

# ------------------------------------------------------------------------------
# SECCIÓN 15 · RESUMEN FINAL
# ------------------------------------------------------------------------------
cat("========================================================\n")
cat("  PROCESO COMPLETADO CON EXITO\n")
cat("========================================================\n")
cat("  Registros       :", nrow(BD_FE_1989_2020), "\n")
cat("  Columnas        :", paste(names(BD_FE_1989_2020), collapse = ", "), "\n")
cat("  Años            :", min(BD_FE_1989_2020$Anio), "-",
    max(BD_FE_1989_2020$Anio), "\n")
cat("  Periodos        :", paste(unique(BD_FE_1989_2020$Periodo), collapse = " | "), "\n")
cat("  CCAA (n)        :", n_distinct(BD_FE_1989_2020$CCAA), "\n")
cat("  Total (m€00)    :",
    formatC(round(sum(BD_FE_1989_2020$Gasto_m_eur00)),
            format = "f", digits = 0, big.mark = ".", big.interval = 3L), "\n")
cat("\n  ARCHIVOS GENERADOS:\n")
cat("    ERDF_CF_Spain_NUTS2_1989_2020.rda\n")
cat("    ERDF_CF_Spain_NUTS2_pivot_EUR2000.rda\n")
cat("    ERDF_CF_Spain_NUTS2_pivot_EUR2020.rda\n")
cat("    ERDF_CF_Spain_NUTS2_1989_2020.xlsx\n")
cat("    ERDF_CF_Spain_NUTS2_1989_2020.csv\n")
cat("   ", ARCHIVO2, "\n")
cat("\n  NOTAS:\n")
cat("  - Área 4 = Energía y M.A. | Área 5 = Conocimiento (orden inverso a v4)\n")
cat("  - 'Infraestructura de apoyo...' → Área 3 en este script (Área 1 en v4)\n")
cat("========================================================\n")