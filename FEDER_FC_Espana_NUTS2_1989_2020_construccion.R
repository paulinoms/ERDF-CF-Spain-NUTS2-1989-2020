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
#  Versión : 1.0
#  Fecha   : 2026-03-22
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
#  Si el repositorio tiene DOI de Zenodo (recomendado), sustitúyelo aquí.
#
# ------------------------------------------------------------------------------
#  ARCHIVOS DEL REPOSITORIO
#  ├── FEDER_FC_Espana_NUTS2_1989_2020_construccion.R             <- Este script (único archivo necesario)
#  ├── data/
#  │   └── ERDF_CF_Spain_NUTS2_1989_2020_source.xlsx  <- Datos fuente (ver nota abajo)
#  ├── output/                        <- Generado automáticamente por el script
#  │   ├── ERDF_CF_Spain_NUTS2_1989_2020.rda
#  │   ├── ERDF_CF_Spain_NUTS2_1989_2020.xlsx
#  │   ├── ERDF_CF_Spain_NUTS2_1989_2020.csv
#  │   ├── ERDF_CF_Spain_NUTS2_pivot_EUR2000.rda
#  │   └── ERDF_CF_Spain_NUTS2_pivot_EUR2020.rda
#  ├── README.md
#  └── LICENSE
#
#  NOTA SOBRE EL ARCHIVO FUENTE:
#  El archivo 'ERDF_CF_Spain_NUTS2_1989_2020_source.xlsx' contiene los datos de ejecución
#  certificada procedentes de los Informes Anuales de la DGFC (Min. Hacienda,
#  España, 1989-2009) y de la EU Cohesion Open Data Platform (2007-2021).
#  Ambas fuentes son públicas; el Excel es una recopilación original del autor.
#  Se recomienda incluirlo en el repositorio bajo la misma licencia CC BY 4.0.
#  Tamaño estimado: < 5 MB — compatible con los límites de GitHub (100 MB).
#
# ==============================================================================

# ============================================================
# LIMPIAR ENTORNO
# ============================================================

rm(list = ls())

if (.Platform$OS.type == "windows") {
  options(encoding = "UTF-8")
  tryCatch(Sys.setlocale("LC_ALL", "Spanish_Spain.UTF-8"),
           error = function(e) Sys.setlocale("LC_ALL", "Spanish"))
}


## ████████████████████████████████████████████████████████████████████████████
##
##  FONDOS EUROPEOS ESPAÑOLES — RECONSTRUCCIÓN COMPLETA DE LA BASE DE DATOS
##  Períodos de programación: 1989-1993 | 1994-1999 | 2000-2006 |
##                            Fondo de Cohesión 1989-2006 | 2007-2013 | 2014-2020
##
##  Versión : v2.0
##  Fecha   : 2026-03-22
##
##  FUENTE PRINCIPAL
##  ─────────────────────────────────────────────────────────────────────────
##  Archivo Excel : 20260321 Nueva Base FEDER.xlsx
##  Hojas fuente  : Reg.89-93 | Reg.94-99 | Reg.00-06 | FC.89-06 |
##                  07-13 | 14-20 | IPC/Ptas (factores de conversión)
##
##  OUTPUTS GENERADOS
##  ─────────────────────────────────────────────────────────────────────────
##  BD_FE_1989_2020            : data.frame R con todos los registros (1 fila
##                               por observación: CCAA × Año × Eje × Área)
##                               Columnas monetarias:
##                                 · Gasto_m_eur00   (miles de € ctes. 2000)
##                                 · Gasto_m_eur2020 (miles de € ctes. 2020)
##  BD_FE_1989_2020.rda        : objeto R serializado (cargar con load())
##  pivot_CCAA_Anno_Area       : tabla pivotada CCAA × Año × Área en €2000
##  pivot_CCAA_Anno_Area.rda   : ídem, objeto R serializado
##  pivot_CCAA_Anno_Area_2020  : tabla pivotada CCAA × Año × Área en €2020
##  pivot_CCAA_Anno_Area_2020.rda : ídem, objeto R serializado
##  BD_FE_1989_2020.xlsx       : Excel con 7 pestañas:
##                                 BD_FE_1989_2020 | Pivot_CCAA_Anno |
##                                 Pivot_CCAA_Anno_Area_2020 |
##                                 Resumen_Areas | Resumen_Areas_Per |
##                                 Metadatos | Devoluciones
##  BD_FE_1989_2020.csv        : CSV UTF-8 (mismo contenido que el .rda)
##
## ████████████████████████████████████████████████████████████████████████████
##
##  ══════════════════════════════════════════════════════════════════════════
##  PARTE I — FUENTES DOCUMENTALES POR PERÍODO DE PROGRAMACIÓN
##  ══════════════════════════════════════════════════════════════════════════
##
##  ┌──────────────────────────────────────────────────────────────────────┐
##  │  PERÍODO 1989-1993  (Hoja: Reg.89-93 | 585 filas × 12 cols)         │
##  ├──────────────────────────────────────────────────────────────────────┤
##  │  Tipo gasto original : Millones de ECU (MEcus)                       │
##  │  Fuente institucional: Informes Anuales DGFC, Min. Economía y        │
##  │                        Hacienda                                      │
##  │  Referencias de página:                                              │
##  │    Informe 1992 — Obj.1: pág. 148 / Obj.2: pág. 181                 │
##  │  Columna clave      : R[12] = 'Inversión MEcus'                      │
##  │  Conversión aplicada: Gasto_m_eur00 = MEcus × EUR/ECU(año) × 1000   │
##  └──────────────────────────────────────────────────────────────────────┘
##
##  ┌──────────────────────────────────────────────────────────────────────┐
##  │  PERÍODO 1994-1999  (Hoja: Reg.94-99 | 1081 filas × 14 cols)        │
##  ├──────────────────────────────────────────────────────────────────────┤
##  │  Tipo gasto original : MEcus (1994-1997) ó M€uros (1998-2003)        │
##  │  Fuente institucional: Informes Anuales DGFC, Min. Economía y        │
##  │                        Hacienda                                      │
##  │  Referencias de página:                                              │
##  │    1993-1995 → Inf.1995 p.282 (Obj.1) / p.310 (Obj.2)               │
##  │    1996      → Inf.1996 p.238 (Obj.1) / p.265 (Obj.2)               │
##  │    1997      → Inf.1997 p.177 (Obj.1) / p.203 (Obj.2)               │
##  │    1998      → Inf.1998 p.144 (Obj.1) / p.170 (Obj.2)               │
##  │    1999      → Inf.1999 p.80  (Obj.1) / p.106 (Obj.2)               │
##  │    2000-2003 → Informes 2000-2003                                    │
##  │  Columnas clave:                                                     │
##  │    R[12] = 'Inv_MEcus' (1994-1997, cuando disponible)                │
##  │    R[14] = 'Gasto M€uros' (1998-2003, euros corrientes)              │
##  │  Conversión aplicada:                                                │
##  │    Si !is.na(Inv_MEcus)  → MEcus  × EUR/ECU(año) × 1000             │
##  │    Si !is.na(Gasto_Meur) → M€uros × EUR/ECU(año) × 1000 (pre-2000)  │
##  │                          → M€uros × Factor_IPC(año) × 1000 (2000+)  │
##  │  NOTA: Para 1998-1999, los datos están en M€uros pero se aplica      │
##  │  EUR/ECU y NO el IPC, porque la moneda de referencia era el ECU;     │
##  │  EUR/ECU(1998)=1.00480 y EUR/ECU(1999)=1.00000 (prácticamente        │
##  │  sin efecto, pero metodológicamente correcto).                       │
##  └──────────────────────────────────────────────────────────────────────┘
##
##  ┌──────────────────────────────────────────────────────────────────────┐
##  │  PERÍODO 2000-2006  (Hoja: Reg.00-06 | 858 filas × 14 cols)         │
##  ├──────────────────────────────────────────────────────────────────────┤
##  │  Tipo gasto original : M€ corrientes                                 │
##  │  Fuente institucional: Informes Anuales DGFC, Min. Economía y        │
##  │                        Hacienda                                      │
##  │  Referencias de página:                                              │
##  │    2000 → Inf.2000 p.113 (Obj.1) / p.127 (Obj.2)                    │
##  │    2001 → Inf.2001 p.145 (Obj.1) / p.169 (Obj.2)                    │
##  │    2002 → Inf.2002 p.85  (Obj.1) / p.107 (Obj.2)                    │
##  │    2003 → Inf.2003 p.160 (Obj.1) / p.182 (Obj.2)                    │
##  │    2004 → Inf.2004 p.146 (Obj.1) / p.164 (Obj.2)                    │
##  │    2006 → Inf.2006 p.145 (Obj.1) / p.163 (Obj.2) — fuente principal │
##  │    n+2  → Inf.2007 p.247/265 | Inf.2008 p.128/147 | Inf.2009        │
##  │           p.102/121                                                  │
##  │  Columna clave      : R[14] = 'Gasto M€uros'                         │
##  │  Conversión aplicada: M€uros × Factor_IPC_acum(año) × 1000           │
##  └──────────────────────────────────────────────────────────────────────┘
##
##  ┌──────────────────────────────────────────────────────────────────────┐
##  │  FONDO DE COHESIÓN 1989-2006  (Hoja: FC.89-06 | 285 filas × 12 col) │
##  ├──────────────────────────────────────────────────────────────────────┤
##  │  Tipo gasto original : MEcus (pre-2000) ó M€ corrientes (2000+)      │
##  │  Fuente institucional: Informes Anuales DGFC, capítulos específicos  │
##  │                        del Fondo de Cohesión                         │
##  │  Columna clave      : R[12] = 'Gasto Mecus' (nombre genérico;        │
##  │                       contiene MEcus o M€ según el año)              │
##  │  Conversión aplicada:                                                │
##  │    Año < 2000 → MEcus  × EUR/ECU(año) × 1000                        │
##  │    Año ≥ 2000 → M€uros × Factor_IPC_acum(año) × 1000                │
##  │  NOTA: La variable 'unidad' se vectoriza (if_else por fila) antes    │
##  │  de pasarla a mapply(), no como constante. Esto es necesario porque  │
##  │  una misma hoja contiene tanto MEcus (pre-2000) como M€ (2000+).     │
##  └──────────────────────────────────────────────────────────────────────┘
##
##  ┌──────────────────────────────────────────────────────────────────────┐
##  │  PERÍODO 2007-2013  (Hoja: 07-13 | 8338 filas × 15 cols)            │
##  ├──────────────────────────────────────────────────────────────────────┤
##  │  Tipo gasto original : M€ corrientes                                 │
##  │  Fuente institucional: EU Cohesion Open Data Platform                │
##  │  URL: https://cohesiondata.ec.europa.eu/                             │
##  │  Archivo descargado  : 20210909_2007_2013_ejec_dec_anual.xlsx        │
##  │  Fecha de descarga   : 09/09/2021                                    │
##  │  Verificación        : 842 filas, coincidencia 100% con hoja 07-13   │
##  │  Columna clave       : R[15] = 'GastoMeur'                           │
##  │  Valores negativos   : devoluciones de certificaciones → forzado a 0 │
##  │  Conversión aplicada : M€uros × Factor_IPC_acum(año) × 1000          │
##  │  Columnas Área       : R[10] = Cód Área / R[11] = Nom Área           │
##  │  (El Área viene directamente en la fuente; no se reclasifica por eje) │
##  └──────────────────────────────────────────────────────────────────────┘
##
##  ┌──────────────────────────────────────────────────────────────────────┐
##  │  PERÍODO 2014-2020  (Hoja: 14-20 | 5832 filas × 12 cols)            │
##  ├──────────────────────────────────────────────────────────────────────┤
##  │  Tipo gasto original : M€ corrientes                                 │
##  │  Fuente institucional: EU Cohesion Open Data Platform                │
##  │  URL: https://cohesiondata.ec.europa.eu/                             │
##  │  Archivo descargado  : 20210909_2014_2020_ejec_dec_anual.xlsx        │
##  │  Fecha de descarga   : 09/09/2021                                    │
##  │  Verificación        : 729 filas, coincidencia 100% con hoja 14-20   │
##  │  Columna clave       : R[12] = 'GastoMeur'                           │
##  │  Valores negativos   : devoluciones de certificaciones → forzado a 0 │
##  │  Conversión aplicada : M€uros × Factor_IPC_acum(año) × 1000          │
##  │  Tipos de región     : 1=Menos Desarrolladas | 2=Transición |        │
##  │                        3=Más Desarrolladas                           │
##  └──────────────────────────────────────────────────────────────────────┘
##
##
##  ══════════════════════════════════════════════════════════════════════════
##  PARTE II — METODOLOGÍA DE CONVERSIÓN MONETARIA A € CONSTANTES 2000
##  ══════════════════════════════════════════════════════════════════════════
##
##  Todos los valores monetarios se expresan en miles de euros constantes
##  del año 2000 (m_eur00), independientemente de la moneda original.
##  La conversión sigue dos rutas según el período:
##
##  RUTA A — Pre-2000 (datos en MEcus o M€uros ligados al ECU):
##  ─────────────────────────────────────────────────────────────────────────
##  Fórmula:
##    m€00_t = M_orig_t × EUR/ECU_t × 1000
##
##  Fuente de los factores EUR/ECU:
##    EUROSTAT, tabla [ert_bil_conv_a] — tipo de cambio ECU/euro anual
##
##  Factores EUR/ECU verificados (reproducibles contra el Excel fuente):
##    ┌──────┬────────────┐
##    │  Año │  EUR/ECU   │
##    ├──────┼────────────┤
##    │ 1989 │ 0.78375500 │
##    │ 1990 │ 0.77777800 │
##    │ 1991 │ 0.77211200 │
##    │ 1992 │ 0.79649500 │
##    │ 1993 │ 0.89625400 │
##    │ 1994 │ 0.95511900 │
##    │ 1995 │ 0.97965000 │
##    │ 1996 │ 0.96611200 │
##    │ 1997 │ 0.99699900 │
##    │ 1998 │ 1.00479700 │
##    │ 1999 │ 1.00000000 │  ← 1 ECU = 1 € por def. del Consejo UE
##    └──────┴────────────┘
##
##  Ejemplo de verificación (Reg.89-93, Aragón, Eje 1, 1989):
##    472.973 Mptas × 0.007668 ECU/Pta = 3.627 MECU
##    3.627 MECU × 0.783755 EUR/ECU   = 2.843 M€00 × 1000 = 2.843 m€00
##
##  RUTA B — Post-1999 (datos en M€ corrientes):
##  ─────────────────────────────────────────────────────────────────────────
##  Fórmula:
##    m€00_t = M€_corrientes_t × Factor_IPC_acum_t × 1000
##
##  Fuente del deflactor IPC:
##    INE — IPC España, tasa de variación interanual de diciembre
##    URL: https://ine.es/dynt3/inebase/es/index.htm?padre=1368&capsel=3466
##
##  Cadena IPC (base 2000 = 1.0), Factor acumulado = Π(1 + ΔIPCt/100):
##    ┌──────┬─────────────┬───────────┐
##    │  Año │ ΔIPC (dic.) │ Factor    │
##    ├──────┼─────────────┼───────────┤
##    │ 2000 │ base        │ 1.000000  │
##    │ 2001 │  +4.0%      │ 1.040000  │
##    │ 2002 │  +2.7%      │ 1.068080  │
##    │ 2003 │  +4.0%      │ 1.110803  │
##    │ 2004 │  +2.6%      │ 1.139684  │
##    │ 2005 │  +3.2%      │ 1.176154  │
##    │ 2006 │  +3.7%      │ 1.219672  │
##    │ 2007 │  +2.7%      │ 1.252603  │
##    │ 2008 │  +4.2%      │ 1.305212  │
##    │ 2009 │  +1.4%      │ 1.323485  │
##    │ 2010 │  +0.8%      │ 1.334073  │
##    │ 2011 │  +3.0%      │ 1.374095  │
##    │ 2012 │  +2.4%      │ 1.407073  │
##    │ 2013 │  +2.9%      │ 1.447879  │
##    │ 2014 │  +0.3%      │ 1.452222  │
##    │ 2015 │  -1.0%      │ 1.437700  │
##    │ 2016 │   0.0%      │ 1.437700  │
##    │ 2017 │  +1.6%      │ 1.460703  │
##    │ 2018 │  +1.1%      │ 1.476771  │
##    │ 2019 │  +1.2%      │ 1.494492  │
##    │ 2020 │  +0.8%      │ 1.506448  │
##    │ 2021 │  -0.5%      │ 1.498916  │  ← solo para n+2 de 2014-2020
##    └──────┴─────────────┴───────────┘
##
##  NOTA sobre 2021: el factor 1.498916 (ΔIPC -0.5%) recoge el efecto
##  deflacionario de la pandemia. Solo se usa para las certificaciones
##  n+2 del período 2014-2020 que tienen fecha de pago en 2021.
##
##  FUNCIÓN convertir():
##  ─────────────────────────────────────────────────────────────────────────
##  La función principal de conversión implementa ambas rutas:
##
##    convertir(valor, anio, unidad, conv) {
##      busca en conv_master el registro con Anio == anio
##      si unidad == "MEcus"  → valor × eur_por_ecu  × 1000
##      si unidad == "MEuros" y anio < 2000 → valor × eur_por_ecu  × 1000
##      si unidad == "MEuros" y anio ≥ 2000 → valor × Factor_IPC_acum × 1000
##    }
##
##  La vectorización sobre filas se realiza mediante mapply():
##    conv_vec(v, a, u, conv) = mapply(convertir, valor=v, anio=a,
##                                    MoreArgs=list(unidad=u, conv=conv))
##
##  ATENCIÓN: conv_vec() solo funciona cuando 'u' (unidad) es CONSTANTE
##  para todas las filas del lote. Cuando la unidad varía por fila (caso
##  FC.89-06, donde unas filas son MEcus y otras M€uros), se usa directamente
##  mapply() con el parámetro 'u' como vector (no como MoreArgs).
##
##
##  ══════════════════════════════════════════════════════════════════════════
##  PARTE III — TABLA DE CLASIFICACIÓN TEMÁTICA (EJE → ÁREA, 1989-2006)
##  ══════════════════════════════════════════════════════════════════════════
##
##  Para los períodos 1989-2006 el Área temática no está codificada en la
##  fuente; se infiere del nombre del eje (Nom_Eje) mediante una tabla de
##  correspondencia directa (tabla_areas). Este enfoque es más robusto que
##  la clasificación por regex cuando los nombres de los ejes son estables
##  y conocidos a priori.
##
##  Para 2007-2020, el Área viene directamente en las hojas fuente (columnas
##  Cód Área y Nom Área) y no requiere reclasificación.
##
##  Las 7 áreas temáticas son:
##
##  ┌──────────────────────────────────────────────────────────────────────┐
##  │  ÁREA 1 — INFRAESTRUCTURAS  (Narea = 1)                              │
##  ├──────────────────────────────────────────────────────────────────────┤
##  │  Ejes asignados (1989-2006):                                         │
##  │    - "Integración y articulación territorial"                        │
##  │    - "Mejora de la Red de Comunicaciones"                            │
##  │    - "Desarrollo de la Red de Transportes"                           │
##  │    - "Redes de Transporte y Energía"                                 │
##  │    - "Infraestructuras"  (nombre exacto del eje)                     │
##  │                                                                      │
##  │  NOTA CRÍTICA — DISCREPANCIA CON CLASIFICACIÓN POR REGEX:            │
##  │  En la versión v4 (script de clasificación por regex), el eje        │
##  │  "Infraestructura de apoyo [a la actividad económica]" se asigna a   │
##  │  Infraestructuras. En este script, ese mismo eje está asignado a     │
##  │  Área 3 (Desarrollo local y urbano). Revisar la clasificación         │
##  │  correcta antes de combinar resultados de ambas versiones.           │
##  └──────────────────────────────────────────────────────────────────────┘
##
##  ┌──────────────────────────────────────────────────────────────────────┐
##  │  ÁREA 2 — ACTIVIDADES PRODUCTIVAS  (Narea = 2)                       │
##  ├──────────────────────────────────────────────────────────────────────┤
##  │  Ejes asignados (1989-2006):                                         │
##  │    - "Industria, servicios y artesanía"                              │
##  │    - "Turismo"                                                       │
##  │    - "Creación y desarrollo de Activ. Productivas"                   │
##  │    - "Desarrollo del tejido económico"                               │
##  │    - "Apoyo al empleo y a la Compititividad de las Empresas"         │
##  │      [Nota ortográfica: "Compititividad" es errata del Excel fuente] │
##  │    - "Mejora de la Competitividad y Desarrollo del Tejido Productivo"│
##  │    - "Mejora de la Competitividad, el Empleo y Desarrollo"           │
##  └──────────────────────────────────────────────────────────────────────┘
##
##  ┌──────────────────────────────────────────────────────────────────────┐
##  │  ÁREA 3 — DESARROLLO LOCAL Y URBANO  (Narea = 3)                     │
##  ├──────────────────────────────────────────────────────────────────────┤
##  │  Ejes asignados (1989-2006):                                         │
##  │    - "Infraestructura de apoyo a la actividad económica"             │
##  │      [VER NOTA CRÍTICA en Área 1 sobre posible reclasificación]      │
##  │    - "Desarrollo Local y Urbano"                                     │
##  └──────────────────────────────────────────────────────────────────────┘
##
##  ┌──────────────────────────────────────────────────────────────────────┐
##  │  ÁREA 4 — ENERGÍA Y MEDIO AMBIENTE  (Narea = 4)                      │
##  ├──────────────────────────────────────────────────────────────────────┤
##  │  Ejes asignados (1989-2006):                                         │
##  │    - "Protección y mejora del Medio Ambiente"                        │
##  │    - "Protección del Medio Ambiente"                                 │
##  │    - "Medio Ambiente, Entorno Natural y Recurso Hídrico"             │
##  │    - "Infraestructuras / Medio Ambiente"  (eje mixto FC)             │
##  │                                                                      │
##  │  NOTA — NUMERACIÓN DE ÁREAS EN ESTE SCRIPT:                          │
##  │  En este script, Área 4 = Energía y Medio Ambiente y Área 5 =        │
##  │  Conocimiento. En la versión v4 (script de regex), el orden es       │
##  │  inverso: categoría 4 = Economía del Conocimiento y categoría 5 =    │
##  │  Energía y Medio Ambiente. Verificar la coherencia antes de cruzar   │
##  │  resultados entre ambos scripts.                                     │
##  └──────────────────────────────────────────────────────────────────────┘
##
##  ┌──────────────────────────────────────────────────────────────────────┐
##  │  ÁREA 5 — CONOCIMIENTO  (Narea = 5)                                  │
##  ├──────────────────────────────────────────────────────────────────────┤
##  │  Ejes asignados (1989-2006):                                         │
##  │    - "Apoyo a I+D y equipamientos para formación"                    │
##  │    - "Desarrollo de la Investigación de la Tecnología e Innovación"   │
##  │    - "Sociedad Conocimiento (Innovación, I+D, Soc. Info) y Telec."   │
##  │    - "Sociedad del Conocimiento (Innovación, I+D,...)"               │
##  └──────────────────────────────────────────────────────────────────────┘
##
##  ┌──────────────────────────────────────────────────────────────────────┐
##  │  ÁREA 6 — COMUNICACIONES Y DIGITALIZACIÓN  (Narea = 6)               │
##  ├──────────────────────────────────────────────────────────────────────┤
##  │  Ejes asignados (1989-2006):                                         │
##  │    - "Desarrollo de Redes de Comunicaciones"                         │
##  │                                                                      │
##  │  ATENCIÓN: distinto de "Mejora de la Red de Comunicaciones" (→ Área 1)│
##  │  El eje de infraestructuras hace referencia a redes físicas de        │
##  │  transporte, mientras que éste se refiere a telecomunicaciones.       │
##  │                                                                      │
##  │  Normalización aplicada en 2014-2020:                                │
##  │  Las variantes "Comunicación y digitalización" / "Comunicaciones..."  │
##  │  se unifican a "Comunicaciones y digitalización" mediante str_detect  │
##  │  con el patrón (?i)^comunicaci                                       │
##  └──────────────────────────────────────────────────────────────────────┘
##
##  ┌──────────────────────────────────────────────────────────────────────┐
##  │  ÁREA 7 — ASISTENCIA TÉCNICA  (Narea = 7)                            │
##  ├──────────────────────────────────────────────────────────────────────┤
##  │  Ejes asignados (1989-2006):                                         │
##  │    - "Asistencia técnica"                                            │
##  │    - "Asistencia técnica, Seguimiento e Información"                 │
##  │    - "Medidas para Preparación, Evaluación y Seguimiento"            │
##  │                                                                      │
##  │  Normalización aplicada en 2007-2020:                                │
##  │  Las variantes "Asistencia Técnica" / "asistencia técnica" se        │
##  │  unifican a "Asistencia técnica" mediante str_replace con el patrón  │
##  │  (?i)^asistencia\s+t.cnica$                                         │
##  └──────────────────────────────────────────────────────────────────────┘
##
##
##  ══════════════════════════════════════════════════════════════════════════
##  PARTE IV — TRATAMIENTO DE VALORES NEGATIVOS
##  ══════════════════════════════════════════════════════════════════════════
##
##  En los períodos 2007-2013 y 2014-2020, la fuente EU Cohesion Open Data
##  Platform puede incluir valores negativos de gasto. Estos corresponden a
##  devoluciones de certificaciones previamente declaradas (correcciones
##  financieras, reintegros, etc.).
##
##  Tratamiento aplicado en este script:
##    pmax(as.numeric(GastoMeur), 0)
##
##  Es decir, todo valor negativo se reemplaza por 0 ANTES de aplicar la
##  conversión monetaria. Los registros negativos se registran en un log
##  (neg_log_07 y neg_log_14) que se exporta como hoja "Devoluciones" en
##  el Excel de salida, para trazabilidad y auditabilidad.
##
##  Este tratamiento es idéntico al aplicado en la versión v4.
##
##
##  ══════════════════════════════════════════════════════════════════════════
##  PARTE V — NORMALIZACIÓN GLOBAL DE NOMBRES DE ÁREA
##  ══════════════════════════════════════════════════════════════════════════
##
##  Antes de exportar la base final, se aplican dos normalizaciones globales
##  sobre la columna 'Area' para garantizar consistencia entre períodos:
##
##  1. Área 6 — Comunicaciones:
##     str_detect(Area, "(?i)^comunicaci")
##     → "Comunicaciones y digitalización"
##     Unifica variantes tipográficas presentes en 2014-2020
##
##  2. Área 7 — Asistencia técnica:
##     str_to_lower(Area) == "asistencia técnica"
##     → "Asistencia técnica"
##     Unifica mayúsculas/minúsculas presentes en 2007-2013
##
##  Estas normalizaciones se aplican también en las secciones individuales
##  de cada período (Secciones 8 y 9) para consistencia interna.
##
##
##  ══════════════════════════════════════════════════════════════════════════
##  PARTE VI — DEFLACTOR IPC PARA CONVERSIÓN A € CONSTANTES 2020
##  ══════════════════════════════════════════════════════════════════════════
##
##  La columna 'Gasto_m_eur2020' se obtiene multiplicando 'Gasto_m_eur00'
##  por el factor IPC acumulado entre 2000 y 2020:
##
##    Gasto_m_eur2020 = Gasto_m_eur00 × DEFLACTOR_IPC_2000_2020
##
##  El deflactor se calcula encadenando las tasas de variación interanual
##  del IPC de diciembre (INE), con base 2000 = 1.0:
##
##    DEFLACTOR_IPC_2000_2020 = Π_{t=2001}^{2020} (1 + ΔIPC_t / 100)
##                            = 1.50644811  (factor verificado)
##
##  Esto implica que 1 € de 2000 equivale a ~1.5064 € de 2020.
##
##  Fuente: INE — IPC España, variación interanual de diciembre.
##  URL: https://ine.es/dynt3/inebase/es/index.htm?padre=1368&capsel=3466
##
##  NOTA METODOLÓGICA — Coherencia con la conversión original:
##  Los datos post-1999 ya fueron deflactados con el IPC al construir
##  'm_eur00'. Aplicar el mismo deflactor IPC en sentido inverso
##  (×DEFLACTOR_IPC_2000_2020) garantiza consistencia metodológica.
##  Usar el deflactor del PIB en lugar del IPC generaría una inconsistencia
##  que subestimaría los valores en €2020 en aproximadamente un 15%.
##
##  Unidad de 'Gasto_m_eur2020': miles de € constantes 2020, 2 decimales.
##
## ████████████████████████████████████████████████████████████████████████████


# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN 1 · CONFIGURACIÓN: directorio de trabajo y paquetes
# ─────────────────────────────────────────────────────────────────────────────

# AJUSTA esta ruta al directorio donde se encuentra el archivo fuente
setwd("G:/Mi unidad/- LINO DOCS -/00. LINO/- ACADEMIA -/Zenodo/2026 BD Fondos Europeos (1989-2020)")

paquetes <- c("readxl", "dplyr", "tidyr", "writexl", "stringr", "tibble")
nuevos   <- paquetes[!paquetes %in% installed.packages()[, "Package"]]
if (length(nuevos)) install.packages(nuevos)
invisible(lapply(paquetes, library, character.only = TRUE))

ARCHIVO  <- "ERDF_CF_Spain_NUTS2_1989_2020_source.xlsx"   # Excel fuente
ARCHIVO2 <- "ERDF_CF_Spain_NUTS2_1989_2020_codebook.xlsx"             # Excel de salida documentado

if (!file.exists(ARCHIVO))
  stop("ERROR: No se encuentra '", ARCHIVO, "'\nDir: ", getwd())

cat("\n========================================================\n")
cat("  RECONSTRUCCION BD FEDER DESDE HOJAS REG.*\n")
cat("  Fuente :", ARCHIVO, "\n")
cat("  Dir    :", getwd(), "\n")
cat("========================================================\n\n")

# Detectar la hoja IPC de forma robusta (tolera variantes Unicode
# de la letra £/₤ y otras: U+00A3, U+20A3, U+20A4, etc.)
hojas    <- excel_sheets(ARCHIVO)
hoja_ipc <- hojas[str_detect(hojas, "(?i)IPC|Ptas")][1]
cat("Hoja IPC detectada:", hoja_ipc, "\n\n")

# Helper: fuerza exactamente 2 decimales en todas las columnas numéricas
# de tipo double. Se aplica antes de exportar para evitar decimales espurios
# producidos por la aritmética en coma flotante de R.
forzar_2dec <- function(df) {
  df |> mutate(across(where(is.double), ~round(., 2)))
}


# ── Deflactor IPC €constantes2000 → €constantes2020 ──────────────────────────
# Cadena de factores IPC (INE, variación interanual diciembre, base 2000 = 1):
#   DEFLACTOR = Π_{t=2001}^{2020} (1 + ΔIPC_t)
# Tasas aplicadas (mismas que en la conversión original de €corrientes a €2000):
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
# Resultado verificable: 1.50644811456...
cat(sprintf("Deflactor IPC \u20ac2000 -> \u20ac2020 : %.10f\n", DEFLACTOR_IPC_2000_2020))
cat(sprintf("  (1 \u20ac de 2000 = %.4f \u20ac de 2020)\n\n", DEFLACTOR_IPC_2000_2020))

# DEFLACTOR_IPC_2000_2020 queda definido arriba (ipc_tasas_2000_2020).
# La verificación numérica espera: 1.50644811456...


# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN 2 · TABLAS DE CONVERSIÓN MONETARIA
# ─────────────────────────────────────────────────────────────────────────────
# Lee de la hoja IPC/Ptas del Excel fuente los dos conjuntos de factores:
#   (a) Tipos de cambio EUR/ECU anuales (EUROSTAT [ert_bil_conv_a])
#   (b) Factor IPC acumulado (INE, base 2000 = 1.0)
# Ambos se fusionan en conv_master, que es la única tabla de conversión
# usada a lo largo de todo el script.
# ─────────────────────────────────────────────────────────────────────────────

cat("-- Cargando factores de conversion monetaria ...\n")

raw_ipc <- read_excel(ARCHIVO, sheet = hoja_ipc, col_names = FALSE)

# Factores EUR/ECU: filas 2-35, columnas 9 y 10 del Excel
# (posicionamiento fijo según layout de la hoja IPC/Ptas)
tasa_ecu_eur <- raw_ipc[2:35, 9:10] |>
  setNames(c("Anio", "eur_por_ecu")) |>
  mutate(across(everything(), as.numeric)) |>
  filter(!is.na(Anio)) |>
  distinct(Anio, .keep_all = TRUE)  # elimina duplicados si los hay

# Factor IPC acumulado: filas 13-35, columnas 9-12
# La columna 10 ('Factor_IPC_acum') contiene el factor encadenado base 2000=1
# Las columnas 11-12 ('m','d') son auxiliares y no se usan
ipc_deflactor <- raw_ipc[13:35, 9:12] |>
  setNames(c("Anio", "Factor_IPC_acum", "m", "d")) |>
  mutate(across(c(Anio, Factor_IPC_acum), as.numeric)) |>
  filter(!is.na(Anio))

# Tabla maestra de conversión: unión de EUR/ECU e IPC por año
conv_master <- tasa_ecu_eur |>
  full_join(ipc_deflactor |> select(Anio, Factor_IPC_acum), by = "Anio") |>
  arrange(Anio) |>
  distinct(Anio, .keep_all = TRUE)

# Controles mínimos de integridad
stopifnot("conv_master vacía" = nrow(conv_master) > 0,
          "Año 2000 ausente"  = 2000 %in% conv_master$Anio)

cat("  conv_master:", min(conv_master$Anio), "-",
    max(conv_master$Anio, na.rm = TRUE), "| filas:", nrow(conv_master), "\n")


# ── Función de conversión escalar ─────────────────────────────────────────────
# Convierte un único valor de la moneda original a miles de € constantes 2000.
# Implementa las dos rutas descritas en la PARTE II:
#   · "MEcus"  → siempre usa EUR/ECU (independientemente del año)
#   · "MEuros" → usa EUR/ECU si el año es < 2000 (datos ligados al ECU)
#              → usa Factor_IPC si el año es ≥ 2000 (euros corrientes reales)
# Devuelve NA con un warning si el año no existe en conv_master.
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

# ── Wrapper vectorizado ────────────────────────────────────────────────────────
# Aplica convertir() fila a fila mediante mapply().
# IMPORTANTE: 'u' debe ser un ESCALAR constante para todo el lote de filas.
# Si la unidad varía por fila (caso FC.89-06), NO usar esta función;
# usar mapply() directamente con 'u' como vector (ver Sección 7).
conv_vec <- function(v, a, u, conv) {
  as.numeric(mapply(convertir, valor = v, anio = a,
                    MoreArgs = list(unidad = u, conv = conv),
                    SIMPLIFY = TRUE))
}
cat("  Funcion convertir() definida\n\n")


# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN 3 · TABLA CLASIFICACIÓN EJE → ÁREA (períodos 1989-2006)
# ─────────────────────────────────────────────────────────────────────────────
# Cada fila de tabla_areas define la correspondencia entre un nombre de eje
# (Nom_Eje, tal y como aparece en el Excel fuente) y el número y nombre de
# área temática. El join se hace en las Secciones 4-7 como:
#   left_join(tabla_areas, by = "Eje")
#
# Para detectar ejes del Excel fuente que no están en esta tabla (quedan con
# Narea = NA), revisar la columna Narea en la base final (Sección 11).
# ─────────────────────────────────────────────────────────────────────────────

cat("-- Construyendo tabla clasificacion Eje -> Area ...\n")

tabla_areas <- tribble(
  ~Eje,                                                                            ~Narea, ~Area,

  # ── ÁREA 1: INFRAESTRUCTURAS ──────────────────────────────────────────
  "Integración y articulación territorial",                                            1L, "Infraestructuras",
  "Mejora de la Red de Comunicaciones",                                               1L, "Infraestructuras",
  "Desarrollo de la Red de Transportes",                                              1L, "Infraestructuras",
  "Redes de Transporte y Energía",                                                    1L, "Infraestructuras",
  "Infraestructuras",                                                                  1L, "Infraestructuras",

  # ── ÁREA 2: ACTIVIDADES PRODUCTIVAS ──────────────────────────────────
  "Industria, servicios y artesanía",                                                  2L, "Actividades productivas",
  "Turismo",                                                                           2L, "Actividades productivas",
  "Creación y desarrollo de Activ. Productivas",                                      2L, "Actividades productivas",
  "Desarrollo del tejido económico",                                                   2L, "Actividades productivas",
  "Apoyo al empleo y a la Compititividad de las Empresas",                            2L, "Actividades productivas",   # errata "Compititividad" del fuente
  "Mejora de la Competitividad y Desarrollo del Tejido Productivo",                   2L, "Actividades productivas",
  "Mejora de la Competitividad, el Empleo y Desarrollo",                              2L, "Actividades productivas",

  # ── ÁREA 3: DESARROLLO LOCAL Y URBANO ────────────────────────────────
  # NOTA: "Infraestructura de apoyo a la actividad económica" se asigna
  # aquí al Área 3. En la v4 (clasificación regex) ese eje pertenece al
  # Área 1 (Infraestructuras). Revisar antes de cruzar ambas versiones.
  "Infraestructura de apoyo a la actividad económica",                                3L, "Desarrollo local y urbano",
  "Desarrollo Local y Urbano",                                                        3L, "Desarrollo local y urbano",

  # ── ÁREA 4: ENERGÍA Y MEDIO AMBIENTE ─────────────────────────────────
  # NOTA: En la v4, Energía y Medio Ambiente es la categoría 5.
  # En este script es la categoría 4. Revisar coherencia entre versiones.
  "Protección y mejora del Medio Ambiente",                                           4L, "Energía y medio ambiente",
  "Protección del Medio Ambiente",                                                    4L, "Energía y medio ambiente",
  "Medio Ambiente, Entorno Natural y Recurso Hídrico",                               4L, "Energía y medio ambiente",
  "Infraestructuras / Medio Ambiente",                                                4L, "Energía y medio ambiente",  # eje mixto FC

  # ── ÁREA 5: CONOCIMIENTO ──────────────────────────────────────────────
  # NOTA: En la v4, Conocimiento es la categoría 4.
  # En este script es la categoría 5.
  "Apoyo a I+D y equipamientos para formación",                                       5L, "Conocimiento",
  "Desarrollo de la Investigación de la Tecnología e Innovación",                     5L, "Conocimiento",
  "Sociedad Conocimiento (Innovación, I+D, Soc. Info) y Telec.",                      5L, "Conocimiento",
  "Sociedad del Conocimiento (Innovación, I+D,...)",                                  5L, "Conocimiento",

  # ── ÁREA 6: COMUNICACIONES Y DIGITALIZACIÓN ───────────────────────────
  "Desarrollo de Redes de Comunicaciones",                                            6L, "Comunicaciones y digitalización",

  # ── ÁREA 7: ASISTENCIA TÉCNICA ────────────────────────────────────────
  "Asistencia técnica",                                                               7L, "Asistencia técnica",
  "Asistencia técnica, Seguimiento e Información",                                    7L, "Asistencia técnica",
  "Medidas para Preparación, Evaluación y Seguimiento",                              7L, "Asistencia técnica"
)
cat("  Ejes clasificados:", nrow(tabla_areas), "\n\n")


# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN 4 · REG.89-93 — FEDER Regional 1989-1994
# ─────────────────────────────────────────────────────────────────────────────
# Fuente: Informes Anuales DGFC. Informe 1992 p.148 (Obj.1) y p.181 (Obj.2)
# Columna R[12]: 'Inversión MEcus'
# Conversión:   Gasto_m_eur00 = Inv_MEcus × EUR/ECU(año) × 1000
#
# Renombrado por posición (no por nombre), para robustez ante encoding:
#   R[3]  = Periodo  (nombre original varía; se estandariza como Periodo_col)
#   R[5]  = Anio     (año de ejecución)
#   R[12] = Inv_MEcus (inversión en millones de ECU)
# ─────────────────────────────────────────────────────────────────────────────

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
  # Conversión: MEcus × EUR/ECU × 1000 → miles de € constantes 2000
  mutate(Gasto_m_eur00 = round(conv_vec(Inv_MEcus, Anio, "MEcus", conv_master), 2)) |>
  left_join(tabla_areas, by = "Eje") |>  # asigna Narea y Area
  select(Marco, CCAA, Periodo, Anio, Neje, Eje, Narea, Area, Gasto_m_eur00)

cat("  Reg.89-93 ->", nrow(db_reg89), "reg | años",
    min(db_reg89$Anio), "-", max(db_reg89$Anio), "\n")


# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN 5 · REG.94-99 — FEDER Regional 1994-2003
# ─────────────────────────────────────────────────────────────────────────────
# Fuente: Informes Anuales DGFC 1995-2003 (ver tabla de páginas en PARTE I)
#
# Renombrado por posición:
#   R[3]  = Periodo_col
#   R[5]  = Anio
#   R[12] = Inv_MEcus_col   (disponible solo para 1994-1997)
#   R[14] = GastoMeur_col   (disponible para 1998-2003 en M€uros)
#
# Lógica de conversión (por fila):
#   Si Inv_MEcus no es NA → MEcus  × EUR/ECU × 1000
#   Si Gasto_Meur no es NA y año < 2000 → M€uros × EUR/ECU × 1000
#   Si Gasto_Meur no es NA y año ≥ 2000 → M€uros × IPC    × 1000
#
# Implementado con case_when() sobre las dos columnas de gasto.
# ─────────────────────────────────────────────────────────────────────────────

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


# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN 6 · REG.00-06 — FEDER Regional 2001-2009
# ─────────────────────────────────────────────────────────────────────────────
# Fuente: Informes Anuales DGFC 2001-2009 (ver tabla de páginas en PARTE I)
#
# Renombrado por posición:
#   R[3]  = Periodo_col
#   R[5]  = Anio
#   R[14] = GastoMeur_col (M€ corrientes)
#
# Conversión: M€uros × Factor_IPC_acum(año) × 1000
# (año siempre ≥ 2000 en esta hoja, por lo que conv_vec con "MEuros"
#  aplica siempre la ruta IPC)
# ─────────────────────────────────────────────────────────────────────────────

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


# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN 7 · FC.89-06 — Fondo de Cohesión 1989-2007
# ─────────────────────────────────────────────────────────────────────────────
# Fuente: Informes Anuales DGFC, capítulos específicos del Fondo de Cohesión
#
# Renombrado por posición:
#   R[3]  = Periodo_col
#   R[5]  = Anio
#   R[12] = GastoMecus_col (MEcus antes de 2000, M€ corrientes desde 2000)
#
# Conversión por fila (la unidad cambia según el año):
#   Año < 2000 → unidad = "MEcus"  → MEcus  × EUR/ECU × 1000
#   Año ≥ 2000 → unidad = "MEuros" → M€     × IPC     × 1000
#
# IMPLEMENTACIÓN: se usa mapply() directamente (NO conv_vec) porque 'unidad'
# es un vector (varía por fila). conv_vec solo admite 'unidad' escalar.
# ─────────────────────────────────────────────────────────────────────────────

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
    # 'unidad' es un vector: cada fila tiene su propia unidad
    unidad        = if_else(Anio < 2000, "MEcus", "MEuros"),
    # mapply() itera sobre valor, anio y unidad simultáneamente
    Gasto_m_eur00 = round(as.numeric(mapply(
      function(v, a, u) convertir(v, a, u, conv_master),
      v = Gasto_Mecus, a = Anio, u = unidad
    )), 2)
  ) |>
  left_join(tabla_areas, by = "Eje") |>
  select(Marco, CCAA, Periodo, Anio, Neje, Eje, Narea, Area, Gasto_m_eur00)

cat("  FC.89-06  ->", nrow(db_fc), "reg | años",
    min(db_fc$Anio), "-", max(db_fc$Anio), "\n")


# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN 8 · HOJA 07-13 — FEDER + FC 2007-2016
# ─────────────────────────────────────────────────────────────────────────────
# Fuente: EU Cohesion Open Data Platform
#   Archivo: 20210909_2007_2013_ejec_dec_anual.xlsx (descarga 09/09/2021)
#   Verificado: 842 filas, coincidencia 100% con hoja 07-13
#
# El Área temática viene directamente en las columnas R[10] y R[11];
# no se aplica tabla_areas (no hay reclasificación por eje).
#
# Renombrado por posición:
#   R[5]  = Anio_col
#   R[6]  = Cod_Eje
#   R[7]  = Nom_Eje
#   R[10] = Cod_Area
#   R[11] = Nom_Area
#   R[12] = Cod_CCAA
#   R[13] = Nom_CCAA
#   R[14] = Gasto_EUR  (euros corrientes, para el log de negativos)
#   R[15] = GastoMeur  (millones de euros corrientes; columna de trabajo)
#
# Valores negativos: devoluciones → pmax(., 0) antes de convertir
# Normalización: "Asistencia Técnica" → "Asistencia técnica" (str_replace)
# ─────────────────────────────────────────────────────────────────────────────

cat("-- Procesando hoja 07-13 (EU Cohesion Open Data 2007-2013) ...\n")

raw_0713_src <- read_excel(ARCHIVO, sheet = "07-13", col_names = TRUE)
raw_0713 <- raw_0713_src
names(raw_0713)[c(5, 6, 7, 10, 11, 12, 13, 14, 15)] <-
  c("Anio_col", "Cod_Eje", "Nom_Eje",
    "Cod_Area", "Nom_Area", "Cod_CCAA", "Nom_CCAA",
    "Gasto_EUR", "GastoMeur")

# Log de devoluciones (valores negativos antes del truncamiento)
# La columna 'Fondo' es la primera columna del Excel y no se renombra;
# se accede por su nombre original.
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
    G       = pmax(as.numeric(GastoMeur), 0)  # trunca negativos a 0
  ) |>
  filter(!is.na(CCAA), !is.na(Anio)) |>
  mutate(
    Gasto_m_eur00 = round(conv_vec(G, Anio, "MEuros", conv_master), 2),
    # Normaliza la capitalización de "Asistencia técnica"
    Area = str_replace(Area, "(?i)^asistencia\\s+t.cnica$", "Asistencia t\u00e9cnica")
  ) |>
  select(Marco, CCAA, Periodo, Anio, Neje, Eje, Narea, Area, Gasto_m_eur00)

cat("  07-13     ->", nrow(db_0713), "reg | años",
    min(db_0713$Anio), "-", max(db_0713$Anio), "\n")


# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN 9 · HOJA 14-20 — FEDER 2014-2021
# ─────────────────────────────────────────────────────────────────────────────
# Fuente: EU Cohesion Open Data Platform
#   Archivo: 20210909_2014_2020_ejec_dec_anual.xlsx (descarga 09/09/2021)
#   Verificado: 729 filas, coincidencia 100% con hoja 14-20
#   Tipos de región: 1=Menos Desarrolladas | 2=Transición | 3=Más Desarro.
#
# Renombrado por posición (columna 7 queda con su nombre original):
#   R[1]  = Marco_col
#   R[2]  = Cod_CCAA
#   R[3]  = Nom_CCAA
#   R[4]  = Anio_col
#   R[5]  = Cod_Eje
#   R[6]  = Nom_Eje
#   R[8]  = Nom_PIV  (nombre del programa operativo / eje pivote)
#   R[9]  = Cod_Area
#   R[10] = Nom_Area
#   R[11] = Gasto_EUR
#   R[12] = GastoMeur
#
# Valores negativos: log + pmax(., 0)
# Normalización: "Comunicación y digitalización" → "Comunicaciones y digitalización"
#                "Asistencia Técnica" → "Asistencia técnica"
# ─────────────────────────────────────────────────────────────────────────────

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
    # Unifica variantes de Área 6
    Area = if_else(str_detect(Area, "(?i)^comunicaci"),
                  "Comunicaciones y digitalizaci\u00f3n", Area),
    # Normaliza capitalización de Área 7
    Area = str_replace(Area, "(?i)^asistencia\\s+t.cnica$", "Asistencia t\u00e9cnica")
  ) |>
  select(Marco, CCAA, Periodo, Anio, Neje, Eje, Narea, Area, Gasto_m_eur00)

cat("  14-20     ->", nrow(db_1420), "reg | años",
    min(db_1420$Anio), "-", max(db_1420$Anio), "\n\n")

# Log consolidado de devoluciones
neg_log_total <- bind_rows(neg_log_07, neg_log_14)


# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN 10 · BASE DE DATOS FINAL: BD_FE_1989_2020
# ─────────────────────────────────────────────────────────────────────────────
# Se unen los 6 data frames (uno por fuente), se aplican las normalizaciones
# globales de Area (ver PARTE V), se fuerzan 2 decimales en Gasto_m_eur00,
# y se filtran los registros fuera del rango 1989-2020.
#
# Columnas del data frame final:
#   Marco         : código/nombre del programa operativo o fondo
#   CCAA          : nombre de la comunidad autónoma
#   Periodo       : período de programación ("1989-1993", …, "2014-2020")
#   Año           : año de ejecución (integer)
#   Neje          : número/código del eje
#   Eje           : nombre del eje de gasto
#   Narea         : código numérico del área temática (1-7)
#   Area          : nombre normalizado del área temática
#   Gasto_m_eur00 : gasto en miles de € constantes 2000 (double, 2 dec.)
# ─────────────────────────────────────────────────────────────────────────────

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
    # Normalización global Área 6: unifica variantes ortográficas
    Area = if_else(str_detect(Area, "(?i)^comunicaci"),
                  "Comunicaciones y digitalizaci\u00f3n", Area),
    # Normalización global Área 7: unifica mayúsculas/minúsculas
    Area = if_else(str_to_lower(Area) == "asistencia t\u00e9cnica",
                  "Asistencia t\u00e9cnica", Area)
  ) |>
  filter(!is.na(Gasto_m_eur00), Anio >= 1989, Anio <= 2020) |>
  # Deflactar a euros constantes 2020
  # Fórmula: Gasto_m_eur2020 = Gasto_m_eur00 × DEFLACTOR_IPC_2000_2020
  # (ver constante definida en Sección 1; coherencia con deflactor IPC original)
  mutate(Gasto_m_eur2020 = round(Gasto_m_eur00 * DEFLACTOR_IPC_2000_2020, 2)) |>
  # NOTA: la columna se mantiene como 'Anio' (sin tilde) durante todo el
  # procesamiento en R. El rename a 'Año' se aplica SOLO en la Sección 14,
  # justo antes de exportar, usando rename("Año" = Anio) dentro de una cadena
  # de texto (donde \u00f1 sí es válido). Fuera de strings, \u00f1 NO funciona
  # como parte de un identificador/nombre de variable en R.
  select(Marco, CCAA, Periodo, Anio, Neje, Eje, Narea, Area,
         Gasto_m_eur00, Gasto_m_eur2020) |>
  arrange(Marco, CCAA, Periodo, Anio, Eje)

cat("  Registros   :", nrow(BD_FE_1989_2020), "\n")
cat("  A\u00f1os        :", min(BD_FE_1989_2020$Anio), "-",
    max(BD_FE_1989_2020$Anio), "\n")
cat("  CCAA (n)    :", n_distinct(BD_FE_1989_2020$CCAA), "\n")
cat("  Total m\u20ac00  :",
    formatC(round(sum(BD_FE_1989_2020$Gasto_m_eur00)),
            format = "f", digits = 0, big.mark = ".", big.interval = 3L), "\n")
cat("  Total m\u20ac20  :",
    formatC(round(sum(BD_FE_1989_2020$Gasto_m_eur2020)),
            format = "f", digits = 0, big.mark = ".", big.interval = 3L), "\n")

# Verificación cruzada contra la hoja "DB" del Excel original (opcional)
# Esta hoja solo existe en versiones anteriores del Excel fuente.
# Si no se encuentra, el script continúa sin error.
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
  cat("  [INFO] Hoja 'DB' no encontrada en el Excel fuente.\n")
  cat("         Verificacion cruzada omitida (normal si se usa el Excel actualizado).\n")
  cat("         Total calculado: ",
      format(round(sum(BD_FE_1989_2020$Gasto_m_eur00, na.rm = TRUE)),
             big.mark = "."), "miles EUR2000\n")
}
cat("\n")


# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN 11 · VALIDACIONES
# ─────────────────────────────────────────────────────────────────────────────

cat("-- Validaciones ...\n")

n_neg <- sum(BD_FE_1989_2020$Gasto_m_eur00 < 0, na.rm = TRUE)
cat("  Negativos tras tratamiento:", n_neg,
    if_else(n_neg == 0, "(OK)", "(REVISAR)"), "\n")

cat("  Nulos en Gasto_m_eur00    :", sum(is.na(BD_FE_1989_2020$Gasto_m_eur00)), "\n")
cat("  Sin Narea                 :", sum(is.na(BD_FE_1989_2020$Narea)), "\n")

# Registros fuera del rango n+2 (normal por la regla UE; solo informativo)
fuera_n2 <- BD_FE_1989_2020 |>
  mutate(Fin = as.integer(str_extract(Periodo, "\\d{4}$")),
         ok  = Anio <= (Fin + 2)) |>
  filter(!ok)
cat("  Fuera rango n+2           :", nrow(fuera_n2), "(normal, regla UE)\n\n")


# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN 12 · TABLAS RESUMEN
# ─────────────────────────────────────────────────────────────────────────────

cat("-- Construyendo tablas resumen ...\n")

# ------------------------------------------------------------
# 12.1 Resumen por área temática (ya hecho con aggregate)
# ------------------------------------------------------------
resumen_areas <- aggregate(
  Gasto_m_eur00 ~ Narea + Area,
  data = BD_FE_1989_2020,
  FUN = function(x) round(sum(x, na.rm = TRUE), 2)
)
resumen_areas <- resumen_areas[order(resumen_areas$Narea), ]
rownames(resumen_areas) <- NULL

cat("\nResumen por área (miles de €2000):\n")
print(resumen_areas)

# ------------------------------------------------------------
# 12.3 Tabla pivotada: CCAA × Año → columnas = áreas (R base)
# ------------------------------------------------------------

# Primero, inspeccionamos los nombres reales de las columnas
cat("\nColumnas disponibles en BD_FE_1989_2020:\n")
print(names(BD_FE_1989_2020))

# Identificamos los nombres exactos (pueden diferir en mayúsculas/minúsculas)
nombre_area <- names(BD_FE_1989_2020)[grep("^Area$|^area$", names(BD_FE_1989_2020), ignore.case = TRUE)][1]
nombre_ccaa <- names(BD_FE_1989_2020)[grep("^CCAA$|^ccaa$", names(BD_FE_1989_2020), ignore.case = TRUE)][1]
nombre_anio <- names(BD_FE_1989_2020)[grep("^Anio$|^Año$|^year$", names(BD_FE_1989_2020), ignore.case = TRUE)][1]
nombre_gasto <- names(BD_FE_1989_2020)[grep("Gasto_m_eur", names(BD_FE_1989_2020))][1]

if (any(is.na(c(nombre_area, nombre_ccaa, nombre_anio, nombre_gasto)))) {
  stop("No se encontraron todas las columnas necesarias. Revisa los nombres manualmente.")
}

cat("Usando columnas:", nombre_ccaa, nombre_anio, nombre_area, nombre_gasto, "\n")

# Agregación con aggregate (suma por CCAA, Año, Área)
temp_agg <- aggregate(
  as.formula(paste(nombre_gasto, "~", nombre_ccaa, "+", nombre_anio, "+", nombre_area)),
  data = BD_FE_1989_2020,
  FUN = function(x) round(sum(x, na.rm = TRUE), 2)
)

# Pivotar a formato ancho con reshape()
pivot_ccaa_anio <- reshape(
  temp_agg,
  idvar = c(nombre_ccaa, nombre_anio),
  timevar = nombre_area,
  direction = "wide"
)

# Limpiar nombres de columnas (quitar el prefijo "Gasto_m_eur00.")
names(pivot_ccaa_anio) <- gsub(paste0(nombre_gasto, "\\."), "", names(pivot_ccaa_anio))

# Asegurar que están todas las áreas (rellenar con 0 si faltan)
areas_esperadas <- c("Infraestructuras", "Actividades productivas",
                     "Desarrollo local y urbano", "Energía y medio ambiente",
                     "Conocimiento", "Comunicaciones y digitalización",
                     "Asistencia técnica")
for (a in areas_esperadas) {
  if (!a %in% names(pivot_ccaa_anio)) {
    pivot_ccaa_anio[[a]] <- 0
  }
}

# Reordenar columnas
pivot_ccaa_anio <- pivot_ccaa_anio[, c(nombre_ccaa, nombre_anio, areas_esperadas)]

# Ordenar filas
pivot_ccaa_anio <- pivot_ccaa_anio[order(pivot_ccaa_anio[[nombre_ccaa]], pivot_ccaa_anio[[nombre_anio]]), ]
rownames(pivot_ccaa_anio) <- NULL

cat("\nPivot CCAA x Anio x Area (primeras filas):\n")
print(head(pivot_ccaa_anio))


# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN 13 · METADATOS Y TABLA DE FUENTES
# ─────────────────────────────────────────────────────────────────────────────

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
  "2001-2021",    "M€ corrientes", "M€ x Factor_IPC_acum(anio) x 1000",  "INE IPC armonizado (base 2000=1.0)",
  "EUR/ECU 1989", "0.783755",      "-",                                    "EUROSTAT",
  "EUR/ECU 1990", "0.777778",      "-",                                    "EUROSTAT",
  "EUR/ECU 1991", "0.772112",      "-",                                    "EUROSTAT",
  "EUR/ECU 1992", "0.796495",      "-",                                    "EUROSTAT",
  "EUR/ECU 1993", "0.896254",      "-",                                    "EUROSTAT",
  "EUR/ECU 1994", "0.955119",      "-",                                    "EUROSTAT",
  "EUR/ECU 1995", "0.979650",      "-",                                    "EUROSTAT",
  "EUR/ECU 1996", "0.966112",      "-",                                    "EUROSTAT",
  "EUR/ECU 1997", "0.996999",      "-",                                    "EUROSTAT",
  "EUR/ECU 1998", "1.004797",      "-",                                    "EUROSTAT",
  "EUR/ECU 1999", "1.000000",      "-",                                    "EUROSTAT",
  "IPC 2001",     "1.040000",      "-",                                    "INE",
  "IPC 2002",     "1.068080",      "-",                                    "INE",
  "IPC 2003",     "1.110803",      "-",                                    "INE",
  "IPC 2004",     "1.139684",      "-",                                    "INE",
  "IPC 2005",     "1.176154",      "-",                                    "INE",
  "IPC 2006",     "1.219672",      "-",                                    "INE",
  "IPC 2007",     "1.252603",      "-",                                    "INE",
  "IPC 2008",     "1.305212",      "-",                                    "INE",
  "IPC 2009",     "1.323485",      "-",                                    "INE",
  "IPC 2010",     "1.334073",      "-",                                    "INE",
  "IPC 2011",     "1.374095",      "-",                                    "INE",
  "IPC 2012",     "1.407073",      "-",                                    "INE",
  "IPC 2013",     "1.447879",      "-",                                    "INE",
  "IPC 2014",     "1.452222",      "-",                                    "INE",
  "IPC 2015",     "1.437700",      "-",                                    "INE",
  "IPC 2016",     "1.437700",      "-",                                    "INE",
  "IPC 2017",     "1.460703",      "-",                                    "INE",
  "IPC 2018",     "1.476771",      "-",                                    "INE",
  "IPC 2019",     "1.494492",      "-",                                    "INE",
  "IPC 2020",     "1.506448",      "-",                                    "INE",
  "IPC 2021",     "1.498916",      "-",                                    "INE  (solo para n+2 de 2014-2020)"
)

metadatos <- tribble(
  ~Campo,                    ~Descripcion,
  "Dataset",                 "BD_FE_1989_2020 - Gasto FEDER España 1989-2020 por CCAA, año, eje y área",
  "Objeto R",                "BD_FE_1989_2020",
  "Archivo RDA",             "BD_FE_1989_2020.rda",
  "Archivo Excel",           "ERDF_CF_Spain_NUTS2_1989_2020.xlsx",
  "Fecha construccion",      format(Sys.Date(), "%Y-%m-%d"),
  "Script",                  "FEDER_FC_Espana_NUTS2_1989_2020_construccion.R",
  "Cobertura temporal",      paste(min(BD_FE_1989_2020$Anio), "-", max(BD_FE_1989_2020$Anio)),
  "Periodos programacion",   "1989-1993 | 1994-1999 | 2000-2006 | 2007-2013 | 2014-2020",
  "Registros totales",       as.character(nrow(BD_FE_1989_2020)),
  "CCAA incluidas",          paste(sort(unique(BD_FE_1989_2020$CCAA)), collapse = "; "),
  "Variables",               "Marco, CCAA, Periodo, Año, Neje, Eje, Narea, Area, Gasto_m_eur00",
  "Unidad monetaria",        "Miles de euros constantes del año 2000 (m_eur00)",
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


# ------------------------------------------------------------
# Creación de objetos faltantes para exportación (R base)
# ------------------------------------------------------------

# Verificar columnas necesarias
if (!"Periodo" %in% names(BD_FE_1989_2020)) stop("Falta columna 'Periodo'")
if (!"Gasto_m_eur2020" %in% names(BD_FE_1989_2020)) stop("Falta columna 'Gasto_m_eur2020'")

# 1. Resumen por área y período (12.2)
resumen_areas_periodo <- aggregate(
  Gasto_m_eur00 ~ Narea + Area + Periodo,
  data = BD_FE_1989_2020,
  FUN = function(x) round(sum(x, na.rm = TRUE), 2)
)
resumen_areas_periodo <- resumen_areas_periodo[order(resumen_areas_periodo$Narea, resumen_areas_periodo$Periodo), ]
rownames(resumen_areas_periodo) <- NULL

# 2. Pivot CCAA × Año × Área en euros 2020
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

# Limpiar nombres de columna
names(pivot_ccaa_anio_2020) <- gsub("Gasto_m_eur2020\\.", "", names(pivot_ccaa_anio_2020))

# Asegurar que están todas las áreas esperadas
areas_esperadas <- c("Infraestructuras", "Actividades productivas",
                     "Desarrollo local y urbano", "Energía y medio ambiente",
                     "Conocimiento", "Comunicaciones y digitalización",
                     "Asistencia técnica")
for (a in areas_esperadas) {
  if (!a %in% names(pivot_ccaa_anio_2020)) {
    pivot_ccaa_anio_2020[[a]] <- 0
  }
}
pivot_ccaa_anio_2020 <- pivot_ccaa_anio_2020[, c("CCAA", "Anio", areas_esperadas)]
pivot_ccaa_anio_2020 <- pivot_ccaa_anio_2020[order(pivot_ccaa_anio_2020$CCAA, pivot_ccaa_anio_2020$Anio), ]
rownames(pivot_ccaa_anio_2020) <- NULL

cat("Objetos 'resumen_areas_periodo' y 'pivot_ccaa_anio_2020' creados.\n")

# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN 14 · EXPORTACIÓN
# ─────────────────────────────────────────────────────────────────────────────

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

# D) Excel principal (7 pestañas):
#   BD_FE_1989_2020          : todos los registros (€2000 y €2020), 2 decimales
#   Pivot_CCAA_Anno          : CCAA × Año × Área pivotada en €2000, 2 decimales
#   Pivot_CCAA_Anno_Area_2020: CCAA × Año × Área pivotada en €2020, 2 decimales
#   Resumen_Areas            : totales por área, 2 decimales
#   Resumen_Areas_Per        : totales por área y período, 2 decimales
#   Metadatos                : descripción del dataset y referencias
#   Devoluciones             : log de valores negativos asignados a 0

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

# F) Excel documentado (ARCHIVO2) — 7 pestañas con fuentes y transformaciones:
#   Fuentes_Periodos          : tabla de fuentes por período (ver PARTE I)
#   Transform_Moneda          : factores EUR/ECU e IPC completos (ver PARTE II)
#   DB                        : base de datos completa (con Gasto_m_eur00 y _2020)
#   Pivot_CCAA_Anno_Area      : tabla CCAA × Año × Área en €2000 (2 decimales)
#   Pivot_CCAA_Anno_Area_2020 : tabla CCAA × Año × Área en €2020 (2 decimales)
#   Resumen_Areas             : totales por área temática (2 decimales)
#   Metadatos                 : descripción, referencias y notas de clasificación

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


# ─────────────────────────────────────────────────────────────────────────────
# SECCIÓN 15 · RESUMEN FINAL
# ─────────────────────────────────────────────────────────────────────────────

cat("========================================================\n")
cat("  PROCESO COMPLETADO CON EXITO\n")
cat("========================================================\n")
cat("  Registros       :", nrow(BD_FE_1989_2020), "\n")
cat("  Columnas        :", paste(names(BD_FE_1989_2020), collapse = ", "), "\n")
cat("  A\u00f1os            :", min(BD_FE_1989_2020$Anio), "-",
    max(BD_FE_1989_2020$Anio), "\n")
cat("  Periodos        :", paste(unique(BD_FE_1989_2020$Periodo), collapse = " | "), "\n")
cat("  CCAA (n)        :", n_distinct(BD_FE_1989_2020$CCAA), "\n")
cat("  Total (m\u20ac00)    :",
    formatC(round(sum(BD_FE_1989_2020$Gasto_m_eur00)),
            format = "f", digits = 0, big.mark = ".", big.interval = 3L), "\n")
cat("\n  ARCHIVOS GENERADOS:\n")
cat("    ERDF_CF_Spain_NUTS2_1989_2020.rda             <- load('ERDF_CF_Spain_NUTS2_1989_2020.rda')\n")
cat("    ERDF_CF_Spain_NUTS2_pivot_EUR2000.rda        <- load('ERDF_CF_Spain_NUTS2_pivot_EUR2000.rda')\n")
cat("    ERDF_CF_Spain_NUTS2_pivot_EUR2020.rda   <- load('ERDF_CF_Spain_NUTS2_pivot_EUR2020.rda')\n")
cat("    ERDF_CF_Spain_NUTS2_1989_2020.xlsx            <- 7 pestañas\n")
cat("    ERDF_CF_Spain_NUTS2_1989_2020.csv             <- CSV UTF-8\n")
cat("   ", ARCHIVO2, "           <- reconstruccion documentada\n")
cat("\n  DIFERENCIAS CLAVE RESPECTO A LA VERSION v4 (script de clasificación regex):\n")
cat("  1. Fuente: hojas Reg.*/FC.*/07-13/14-20 (vs datos_*/fc_*)\n")
cat("  2. Clasificación 1989-2006: tabla de correspondencia directa (vs regex)\n")
cat("  3. Área 4 = Energía y M.A. | Área 5 = Conocimiento (orden inverso en v4)\n")
cat("  4. 'Infraestructura de apoyo...' → Área 3 en este script (Área 1 en v4)\n")
cat("  5. IPC incluye 2021 (factor 1.498916) para n+2 de 2014-2020\n")
cat("  6. Genera columna Gasto_m_eur2020 y pivot en EUR2020 (deflactor IPC 2000->2020)\n")
cat("========================================================\n")
