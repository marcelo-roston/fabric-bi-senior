[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "PNR_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared PNR = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota", [ApiVersion = 15]),
  Navegación = Origen{[Name = "LOGISTICS_PNR_COMPLETO.xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/Carritos/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "Hoja1", Kind = "Sheet"]}[Data],
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Navegación 1", [PromoteAllScalars = true]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos", {{"ID DEL CASO", Int64.Type}, {"FECHA DEL CASO", type datetime}, {"TIPO DE PNR", type text}, {"ESTADO", type text}, {"PERIODO DE FACTURACION", type text}, {"FECHA PEDIDO DE REVISION", type datetime}, {"PEDIDO DE REVISION", type text}, {"FECHA DE CIERRE DE CASO", type datetime}, {"REP - ASISTENTE", Int64.Type}, {"COMENTARIO DE CIERRE", type text}, {"NÂº DE PREFACTURA", Int64.Type}, {"ID DE ENVIO", Int64.Type}, {"PRODUCTOS", type text}, {"VALOR DE LA COMPRA", type text}, {"REP TRANSPORTADORA", Int64.Type}, {"ID DE TRANSPORTADORA", Int64.Type}, {"TRANSPORTADORA", type text}, {"ESTACION DE ORIGEN", type text}, {"RUTA", Int64.Type}, {"ID DEL CONDUCTOR", Int64.Type}, {"FECHA DE ENTREGA", type datetime}, {"ID DE RECLAMO", Int64.Type}, {"FECHA DEL RECLAMO", type text}}, "es")
in
  #"Tipo de columna cambiado";
shared PNR_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "br_pnr_carritos", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "resumen volumen_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"resumen volumen" = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota", [ApiVersion = 15]),
  Navegación = Origen{[Name = "Resumen volumen.xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/Carritos/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "Export", Kind = "Sheet"]}[Data],
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Navegación 1", [PromoteAllScalars = true]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos", {{"Mes", type text}, {"Año", type text}, {"Sucursal", type text}, {"Total PQ", Int64.Type}, {"PQ Rodados", Int64.Type}, {"Q Sorting", Int64.Type}, {"Viajes", Int64.Type}, {"Prom PQ x Recorrido", type number}, {"Q de MM", Int64.Type}, {"Facturación Carga/Descarga", type number}, {"Facturación Ruedas", type number}, {"Facturación Media Milla", type number}, {"Precio Carga/Descarga y Sorting", type number}, {"Precio por Ruedas", type number}, {"Precio x Media Milla", type number}, {"Total Facturación", type number}})
in
  #"Tipo de columna cambiado";
shared #"resumen volumen_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "br_pnr_resumen_volumen", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "solucion de problemas_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"solucion de problemas" = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota", [ApiVersion = 15]),
  Navegación = Origen{[Name = "Solucion de problemas.xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/Carritos/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "report_logistics_problem_solvin", Kind = "Sheet"]}[Data],
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Navegación 1", [PromoteAllScalars = true]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos", {{"ID", type text}, {"ID de paquete", type text}, {"Problema", type text}, {"Estado", type text}, {"Problem Solver", type text}, {"Service Center", type text}, {"Fecha de creación", type text}, {"Fecha de cierre", type text}, {"Resolución", type text}, {"Estado de resolución", type text}, {"Analizado por", type text}, {"Fecha de análisis", type text}, {"Tiempo de resolución en minutos", type text}, {"Origen del daño", type text}, {"Motivo", type text}, {"Tipo de daño", type text}, {"Tipo de caso", type text}, {"Ruta sugerida", type text}, {"Motivo de la exclusión", type text}, {"Link detalle del caso", type text}})
in
  #"Tipo de columna cambiado";
shared #"solucion de problemas_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "br_pnr_solucion_problemas", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
