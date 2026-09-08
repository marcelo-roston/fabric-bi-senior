# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "lakehouse": {
# META       "default_lakehouse": "5f494725-23eb-48a8-8688-a8040411bb33",
# META       "default_lakehouse_name": "Tablas_Bronze",
# META       "default_lakehouse_workspace_id": "c1099798-9ed1-461f-b5d2-843e5a67ccfd",
# META       "known_lakehouses": [
# META         {
# META           "id": "5f494725-23eb-48a8-8688-a8040411bb33"
# META         }
# META       ]
# META     }
# META   }
# META }

# CELL ********************

from pyspark.sql.functions import current_date, date_sub, current_timestamp, col
from datetime import datetime

# =====================================================
# PARAMETROS
# =====================================================

# Se recomienda 35 para cubrir corridas tardías
dias_reproceso = 35

tabla_bronze_cab = "br_liq_fleteros_cabecera"
tabla_bronze_det = "br_liq_fleteros_detalle"

tabla_silver_cab = "sl_liq_fleteros_cabecera_hist"
tabla_silver_det = "sl_liq_fleteros_detalle_hist"

# Fecha real de negocio
campo_fecha_cab = "fecha_caratula"
campo_fecha_det = "fecha_caratula"

# =====================================================
# FUNCIONES
# =====================================================

def existe(tabla):
    return spark.catalog.tableExists(tabla)

def log(msg):
    print(f"{datetime.now()} - {msg}")

def primera_carga(origen, destino):
    
    log(f"Validando existencia de {destino}...")

    if not existe(destino):

        log(f"No existe {destino}. Creando carga histórica inicial...")

        df = (
            spark.table(origen)
            .withColumn("fecha_carga_fabric", current_timestamp())
        )

        cantidad = df.count()

        log(f"Filas históricas a copiar: {cantidad}")

        (
            df.write
            .format("delta")
            .mode("overwrite")
            .option("mergeSchema", "true")
            .saveAsTable(destino)
        )

        log(f"{destino} creada correctamente.")
        return True

    log(f"{destino} ya existe.")
    return False


def reproceso_ventana(origen, destino, campo_fecha):

    log(f"Iniciando reproceso últimos {dias_reproceso} días en {destino}")

    fecha_desde = date_sub(current_date(), dias_reproceso)

    df = (
        spark.table(origen)
        .filter(col(campo_fecha) >= fecha_desde)
        .withColumn("fecha_carga_fabric", current_timestamp())
    )

    cantidad = df.count()

    if cantidad == 0:
        raise Exception(
            f"No se encontraron registros recientes en {origen}. "
            f"Se cancela para evitar borrar datos sin recarga."
        )

    log(f"Filas a refrescar: {cantidad}")

    spark.sql(f"""
        DELETE FROM {destino}
        WHERE {campo_fecha} >= date_sub(current_date(), {dias_reproceso})
    """)

    log("Ventana anterior eliminada.")

    (
        df.write
        .format("delta")
        .mode("append")
        .option("mergeSchema", "true")
        .saveAsTable(destino)
    )

    log("Nuevos registros insertados.")

    spark.sql(f"OPTIMIZE {destino}")

    log(f"{destino} optimizada y actualizada OK.")


# =====================================================
# PROCESO CABECERA
# =====================================================

log("======================================")
log("INICIO PROCESO CABECERA")
log("======================================")

creada = primera_carga(tabla_bronze_cab, tabla_silver_cab)

if not creada:
    reproceso_ventana(
        tabla_bronze_cab,
        tabla_silver_cab,
        campo_fecha_cab
    )

# =====================================================
# PROCESO DETALLE
# =====================================================

log("======================================")
log("INICIO PROCESO DETALLE")
log("======================================")

creada = primera_carga(tabla_bronze_det, tabla_silver_det)

if not creada:
    reproceso_ventana(
        tabla_bronze_det,
        tabla_silver_det,
        campo_fecha_det
    )

# =====================================================
# FIN
# =====================================================

log("======================================")
log("PROCESO FINALIZADO CORRECTAMENTE")
log("======================================")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
