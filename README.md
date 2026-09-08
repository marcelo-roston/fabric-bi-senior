# Automatización del catálogo Fabric

1. Subí el contenido de este paquete a la raíz del repositorio `fabric-bi-senior`.
2. En GitHub: Settings > Actions > General > Workflow permissions > Read and write permissions.
3. Hacé commit de los archivos.
4. Entrá a Actions > Actualizar catálogo Fabric > Run workflow para la primera ejecución.

Desde entonces, cada sincronización de Fabric que actualice `main` regenerará `Documentacion/catalogo_fabric_linaje.xlsx`.

`Documentacion/objetos_fisicos.csv` es la fuente del inventario de tablas y vistas. Por ahora es una foto inicial. Luego se puede automatizar su extracción desde los SQL Endpoints.
