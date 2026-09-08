[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Reporte de Operaciones_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"Reporte de Operaciones" = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota/", [ApiVersion = 15]),
  #"Filas filtradas" = Table.SelectRows(Origen, each ([Extension] = ".xlsx" or [Extension] = ".xslx")),
  #"Filas ordenadas" = Table.Sort(#"Filas filtradas", {{"Name", Order.Descending}}),
  #"Filas filtradas 1" = Table.SelectRows(#"Filas ordenadas", each ([Name] = "Reporte de Operaciones.xlsx")),
  Navegación = #"Filas filtradas 1"{[Name = "Reporte de Operaciones.xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "Tabla1", Kind = "Table"]}[Data],
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Navegación 1", {{"Fecha", type date}, {"Id de la ruta", Int64.Type}, {"Id del transportista", Int64.Type}, {"Nombre del transportista", type text}, {"Vehículo", type text}, {"Patente", type text}, {"Kilómetros recorridos", type number}, {"Service Center", type text}, {"Ciclo", type text}, {"Envíos despachados", Int64.Type}, {"Envíos entregados", Int64.Type}, {"Entrega exitosa", type number}, {"No visitado", type number}, {"ORH (Horas en ruta)", type number}, {"SPORH (Número de paquetes despachados por hora)", type number}, {"DPPH (Número de paquetes entregados por hora)", type number}}, "es"),
  #"Consultas combinadas" = Table.NestedJoin(#"Tipo de columna cambiado", {"Id de la ruta"}, #"Reporte Op nexus", {"ROUTE_ID"}, "Reporte Op nexus", JoinKind.LeftOuter),
  #"Reporte Op nexus expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "Reporte Op nexus", {"TURNO_DESPACHO", "AMBULANCIA"}, {"TURNO_DESPACHO", "AMBULANCIA"}),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Reporte Op nexus expandido", {{"TURNO_DESPACHO", type text}, {"AMBULANCIA", type text}}),
  #"Valor reemplazado" = Table.ReplaceValue(#"Tipo de columna cambiado 1", "SDD-", "", Replacer.ReplaceText, {"Patente"})
in
  #"Valor reemplazado";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Tarifario_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Tarifario = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota/", [ApiVersion = 15]),
  #"Filas filtradas" = Table.SelectRows(Origen, each ([Extension] = ".xlsx" or [Extension] = ".xslx")),
  #"Filas ordenadas" = Table.Sort(#"Filas filtradas", {{"Name", Order.Descending}}),
  #"Filas filtradas 1" = Table.SelectRows(#"Filas ordenadas", each ([Name] = "MELI CHOFERES.xlsx")),
  Navegación = #"Filas filtradas 1"{[Name = "MELI CHOFERES.xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "TARIFARIO", Kind = "Sheet"]}[Data],
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Navegación 1", [PromoteAllScalars = true]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos", {{"ta", type text}, {"Distancia", Int64.Type}, {"CORTA", type text}, {"LARGA ", type text}, {"Moto", type text}, {"Vigencia", type date}, {"Fin", type date}, {"Chasis 8 Pos.", type text}, {"Chasis 10 Pos.", type text}}, "es"),
  #"Valor reemplazado" = Table.ReplaceValue(#"Tipo de columna cambiado", null, 0, Replacer.ReplaceValue, {"Distancia"}),
  #"Texto recortado" = Table.TransformColumns(#"Valor reemplazado", {{"ta", each Text.Trim(_), type nullable text}}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Texto recortado", {{"ta", "Sucursal"}, {"Distancia", "Zona"}}),
  #"Filas ordenadas 1" = Table.Sort(#"Columnas con nombre cambiado", {{"Chasis 8 Pos.", Order.Descending}}),
  #"Valor reemplazado 1" = Table.ReplaceValue(#"Filas ordenadas 1", "$", "", Replacer.ReplaceText, {"CORTA", "LARGA ", "Moto"}),
  #"Valor reemplazado 2" = Table.ReplaceValue(#"Valor reemplazado 1", "$", "", Replacer.ReplaceValue, {"Sucursal", "Zona", "CORTA", "LARGA ", "Moto", "Vigencia", "Fin", "Chasis 8 Pos."}),
  #"Valor reemplazado 3" = Table.ReplaceValue(#"Valor reemplazado 2", "$", "", Replacer.ReplaceText, {"Chasis 10 Pos."}),
  #"Valor reemplazado 4" = Table.ReplaceValue(#"Valor reemplazado 3", "$", "", Replacer.ReplaceText, {"Chasis 8 Pos."}),
  #"Filas ordenadas 2" = Table.Sort(#"Valor reemplazado 4", {{"Auto", Order.Descending}}),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Filas ordenadas 2", {{"CORTA", type number}, {"LARGA ", type number}, {"Moto", type number}, {"Chasis 10 Pos.", type number}, {"Chasis 8 Pos.", type number}}),
  #"Columnas con nombre cambiado 1" = Table.RenameColumns(#"Tipo de columna cambiado 1", {{"Moto", "MOTO"}, {"LARGA ", "LARGA"}}),
  #"Tipo de columna cambiado 3" = Table.TransformColumnTypes(#"Columnas con nombre cambiado 1", {{"Auto", type text}}),
  #"Valor reemplazado 5" = Table.ReplaceValue(#"Tipo de columna cambiado 3", "$", "", Replacer.ReplaceText, {"Auto"}),
  #"Tipo de columna cambiado 2" = Table.TransformColumnTypes(#"Valor reemplazado 5", {{"Vigencia", type date}, {"Fin", type date}, {"Zona", Int64.Type}, {"Auto", type number}})
in
  #"Tipo de columna cambiado 2";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Reporte Treggo_DataDestination", IsNewTarget = false], Settings = [Kind = "Manual", AllowCreation = false, ColumnSettings = [Mappings = {[SourceColumnName = "FECHA", DestinationColumnName = "FECHA"], [SourceColumnName = "SUBCA", DestinationColumnName = "SUBCA"], [SourceColumnName = "PATENTE", DestinationColumnName = "PATENTE"], [SourceColumnName = "Location", DestinationColumnName = "Location"], [SourceColumnName = "TURNO_DESPACHO", DestinationColumnName = "TURNO_DESPACHO"], [SourceColumnName = "TIPO_VEHICULO", DestinationColumnName = "TIPO_VEHICULO"], [SourceColumnName = "SPR_PLAN", DestinationColumnName = "SPR_PLAN"], [SourceColumnName = "Q SHP", DestinationColumnName = "Q SHP"], [SourceColumnName = "Ambulancias", DestinationColumnName = "Ambulancias"], [SourceColumnName = "route_id", DestinationColumnName = "route_id"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared #"Reporte Treggo" = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota/", [ApiVersion = 15]),
  #"Filas filtradas" = Table.SelectRows(Origen, each ([Extension] = ".xlsx")),
  #"Filas ordenadas" = Table.Sort(#"Filas filtradas", {{"Date modified", Order.Descending}}),
  Navegación = #"Filas ordenadas"{[Name = "Treggo Report_Looker MLPs_Tabla.xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/Descarga PBI/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "Tabla1", Kind = "Table"]}[Data],
  #"Filas filtradas 1" = Table.SelectRows(#"Navegación 1", each ([Q SHP] <> "Fiorino")),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Filas filtradas 1", {{"Delivery Success", type text}, {"% Visitados", type text}}),
  #"Valor reemplazado" = Table.ReplaceValue(#"Tipo de columna cambiado", ".", ",", Replacer.ReplaceText, {"Delivery Success"}),
  #"Valor reemplazado 1" = Table.ReplaceValue(#"Valor reemplazado", ".", ",", Replacer.ReplaceText, {"Delivery Success", "% Visitados"}),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Valor reemplazado 1", {{"Delivery Success", Percentage.Type}, {"% Visitados", Percentage.Type}, {"FECHA", type date}, {"SUBCA", type text}, {"PATENTE", type text}, {"Location", type text}, {"TURNO_DESPACHO", type text}, {"SPR_PLAN", type text}, {"TIPO_VEHICULO", type text}, {"Q SHP", Int64.Type}, {"Ambulancias", Int64.Type}}),
  #"Filas filtradas 2" = Table.SelectRows(#"Tipo de columna cambiado 1", each [FECHA] > #date(2026, 1, 1)),
  #"Tipo de columna cambiado 2" = Table.TransformColumnTypes(#"Filas filtradas 2", {{"route_id", Int64.Type}}),
  #"Valor reemplazado 2" = Table.ReplaceValue(#"Tipo de columna cambiado 2", "SDD-", "", Replacer.ReplaceText, {"PATENTE"})
in
  #"Valor reemplazado 2";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Sucursales_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Sucursales = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota/", [ApiVersion = 15]),
  #"Filas filtradas" = Table.SelectRows(Origen, each ([Extension] = ".xlsx" or [Extension] = ".xslx")),
  #"Filas ordenadas" = Table.Sort(#"Filas filtradas", {{"Name", Order.Descending}}),
  #"Filas filtradas 1" = Table.SelectRows(#"Filas ordenadas", each ([Name] = "MELI CHOFERES.xlsx")),
  Navegación = #"Filas filtradas 1"{[Name = "MELI CHOFERES.xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "SUCURSALES", Kind = "Sheet"]}[Data],
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Navegación 1", {{"Column1", type text}, {"Column2", type text}}, "es"),
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Tipo de columna cambiado", [PromoteAllScalars = true])
in
  #"Encabezados promovidos";
shared #"Reporte de Operaciones_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  TableNavigation = Navigation_2{[Id = "br_meli_reporte_operaciones", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Sucursales_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  TableNavigation = Navigation_2{[Id = "br_sucursales_carritos", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared #"Reporte Op nexus" = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota/", [ApiVersion = 15]),
  #"Filas filtradas" = Table.SelectRows(Origen, each ([Extension] = ".xlsx")),
  #"Filas filtradas 1" = Table.SelectRows(#"Filas filtradas", each ([Name] = "URBANO.xlsx")),
  Navegación = #"Filas filtradas 1"{[Name = "URBANO.xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/Descarga PBI/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "Urbano", Kind = "Sheet"]}[Data],
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Navegación 1", [PromoteAllScalars = true]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos", {{"ROUTE_ID", Int64.Type}})
in
  #"Tipo de columna cambiado";
shared #"Reporte Treggo_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  TableNavigation = Navigation_2{[Id = "br_nexus_treggo", ItemKind = "Table"]}[Data]
in
  TableNavigation;
shared Tarifario_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  TableNavigation = Navigation_2{[Id = "br_tarifario_carritos", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "PNU_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared PNU = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota/", [ApiVersion = 15]),
  #"Filas filtradas" = Table.SelectRows(Origen, each ([Extension] = ".xlsx" or [Extension] = ".xslx")),
  #"Filas ordenadas" = Table.Sort(#"Filas filtradas", {{"Name", Order.Descending}}),
  #"Filas filtradas 1" = Table.SelectRows(#"Filas ordenadas", each ([Name] = "PNU.xlsx")),
  Navegación = #"Filas filtradas 1"{[Name = "PNU.xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "Tabla1", Kind = "Table"]}[Data],
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Navegación 1", {{"MLP", type text}, {"Excepción", type text}, {"Patente", type text}, {"Tipo de unidad", type text}, {"SVC/XP", type text}, {"Motivos", type text}, {"Comentarios adicionales", type text}, {"Aprobado", type date}, {"Fecha", type text}, {"N° Ruta", type text}, {"Jornada", type text}, {"id", type text}}, "es"),
  #"Duplicados quitados" = Table.Distinct(#"Tipo de columna cambiado", {"id"}),
  #"Elegir columnas" = Table.SelectColumns(#"Duplicados quitados", {"Fecha", "MLP", "Excepción", "Patente", "Tipo de unidad", "N° Ruta", "SVC/XP", "Motivos", "Jornada", "Comentarios adicionales", "Aprobado"})
in
  #"Elegir columnas";
shared PNU_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "br_pnu_carritos", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Reconocimiento PNU_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"Reconocimiento PNU" = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota/", [ApiVersion = 15]),
  #"Filas filtradas" = Table.SelectRows(Origen, each ([Extension] = ".xlsx" or [Extension] = ".xslx")),
  #"Filas ordenadas" = Table.Sort(#"Filas filtradas", {{"Name", Order.Descending}}),
  #"Filas filtradas 1" = Table.SelectRows(#"Filas ordenadas", each ([Name] = "PNU.xlsx")),
  Navegación = #"Filas filtradas 1"{[Name = "PNU.xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "Meli", Kind = "Sheet"]}[Data],
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Navegación 1", [PromoteAllScalars = true]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos", {{"PERIODO", type text}, {"ENTITY ID (shipment, route etc)", Int64.Type}, {"PROVIDER ID", Int64.Type}, {"CONCEPTO BILLING", type text}, {"ENTITY TYPE", type text}, {"DECISION FINAL", type text}, {"COMENTARIO", type text}, {"MLP ", type text}, {"VEHICULO", type text}, {"Sucursal", type text}, {"SVC", type text}, {"DEFINICION", type text}, {"TOTAL A PAGAR", type text}}, "es"),
  #"Valor reemplazado" = Table.ReplaceValue(#"Tipo de columna cambiado", "$", "", Replacer.ReplaceText, {"TOTAL A PAGAR"}),
  #"Valor reemplazado 1" = Table.ReplaceValue(#"Valor reemplazado", " ", "", Replacer.ReplaceText, {"TOTAL A PAGAR"}),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Valor reemplazado 1", {{"TOTAL A PAGAR", type number}, {"FECHA", type date}}),
  #"Errores reemplazados" = Table.ReplaceErrorValues(#"Tipo de columna cambiado 1", {{"FECHA", null}})
in
  #"Errores reemplazados";
shared #"Reconocimiento PNU_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "br_reconocimiento_pnu", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
