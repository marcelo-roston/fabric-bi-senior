# Fabric notebook source

# METADATA ********************

# META {
# META   "kernel_info": {
# META     "name": "synapse_pyspark"
# META   },
# META   "dependencies": {
# META     "warehouse": {
# META       "default_warehouse": "21b7d94b-28d6-4d7c-8d9c-82c796af2a7a",
# META       "known_warehouses": [
# META         {
# META           "id": "21b7d94b-28d6-4d7c-8d9c-82c796af2a7a",
# META           "type": "Lakewarehouse"
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

dias_reproceso = 30

tabla_bronze_cab = "br_liq_fleteros_cabecera"
tabla_bronze_det = "br_liq_fleteros_detalle"

tabla_silver_cab = "sl_liq_fleteros_cabecera_hist"
tabla_silver_det = "sl_liq_fleteros_detalle_hist"

campo_fecha = "fecha_liquidacion"

# =====================================================
# FUNCIONES
# =====================================================

def existe(tabla):
    return spark.catalog.tableExists(tabla)

def log(msg):
    print(f"{datetime.now()} - {msg}")

def primera_carga(origen, destino):
    
    if not existe(destino):
        log(f"Creando {destino} desde Bronze...")

        df = spark.table(origen)\
            .withColumn("fecha_carga_fabric", current_timestamp())

        df.write.format("delta")\
            .mode("overwrite")\
            .saveAsTable(destino)

        log(f"{destino} creada correctamente.")

def reproceso_30dias(origen, destino):

    fecha_desde = date_sub(current_date(), dias_reproceso)

    log(f"Reprocesando últimos {dias_reproceso} días en {destino}")

    df = spark.table(origen)\
        .filter(col(campo_fecha) >= fecha_desde)\
        .withColumn("fecha_carga_fabric", current_timestamp())

    cantidad = df.count()

    if cantidad == 0:
        raise Exception(f"No hay registros recientes en {origen}")

    log(f"Filas a insertar: {cantidad}")

    spark.sql(f"""
        DELETE FROM {destino}
        WHERE {campo_fecha} >= date_sub(current_date(), {dias_reproceso})
    """)

    df.write.format("delta")\
        .mode("append")\
        .saveAsTable(destino)

    spark.sql(f"OPTIMIZE {destino}")

    log(f"{destino} actualizada OK.")

# =====================================================
# PROCESO CABECERA
# =====================================================

primera_carga(tabla_bronze_cab, tabla_silver_cab)
reproceso_30dias(tabla_bronze_cab, tabla_silver_cab)

# =====================================================
# PROCESO DETALLE
# =====================================================

primera_carga(tabla_bronze_det, tabla_silver_det)
reproceso_30dias(tabla_bronze_det, tabla_silver_det)

log("PROCESO FINALIZADO")

# METADATA ********************

# META {
# META   "language": "python",
# META   "language_group": "synapse_pyspark"
# META }
