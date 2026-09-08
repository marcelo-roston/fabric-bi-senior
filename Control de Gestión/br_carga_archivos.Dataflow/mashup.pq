[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared #"Base Metros" = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota", [ApiVersion = 15]),
  #"Filas filtradas" = Table.SelectRows(Origen, each ([Folder Path] = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/Archivos para tableros/Control de Gestion/")),
  Navegación = #"Filas filtradas"{[Name = "Base Metros.xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/Archivos para tableros/Control de Gestion/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "Tabla_Mts", Kind = "Table"]}[Data],
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Navegación 1", {{"MES", type date}, {"REGION", type text}, {"SUCURSAL", type text}, {"METROS", type number}}, "es"),
  #"Personalizado agregado" = Table.AddColumn(#"Tipo de columna cambiado", "ID", each [SUCURSAL] & " - " & Text.From([MES])),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Personalizado agregado", {{"ID", type text}})
in
  #"Tipo de columna cambiado 1";
shared #"Base Eventuales" = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota", [ApiVersion = 15]),
  #"Filas filtradas" = Table.SelectRows(Origen, each ([Folder Path] = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/Archivos para tableros/Control de Gestion/")),
  Navegación = #"Filas filtradas"{[Name = "Base Eventuales Bi.xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/Archivos para tableros/Control de Gestion/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "Tabla1", Kind = "Table"]}[Data],
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Navegación 1", {{"mes", type date}, {"region", type text}, {"suc", type text}, {"Jornadas", Int64.Type}}, "es"),
  #"Personalizado agregado" = Table.AddColumn(#"Tipo de columna cambiado", "ID", each [suc] & " - " & Text.From([mes])),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Personalizado agregado", {{"ID", type text}}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Tipo de columna cambiado 1", {{"mes", "MES"}, {"suc", "SUCURSAL"}, {"region", "REGION"}})
in
  #"Columnas con nombre cambiado";
shared #"Base Nomina" = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota", [ApiVersion = 15]),
  Navegación = Origen{[Name = "Base Nomina Bi.xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/Archivos para tableros/Control de Gestion/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "Tabla22", Kind = "Table"]}[Data],
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Navegación 1", {{"Mes", type date}, {"REGION", type text}, {"Sucursal", type text}, {"Si / INTERNOS", type text}, {"Q Personas", Int64.Type}}, "es"),
  #"Personalizado agregado" = Table.AddColumn(#"Tipo de columna cambiado", "ID", each [Sucursal] & " - " & Text.From([Mes])),
  #"Duplicados quitados" = Table.Distinct(#"Personalizado agregado", {"Mes", "Sucursal", "Si / INTERNOS", "Q Personas"}),
  #"Columna dinamizada" = Table.Pivot(Table.TransformColumnTypes(#"Duplicados quitados", {{"Si / INTERNOS", type text}}), List.Distinct(Table.TransformColumnTypes(#"Duplicados quitados", {{"Si / INTERNOS", type text}})[#"Si / INTERNOS"]), "Si / INTERNOS", "Q Personas"),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Columna dinamizada", {{"ID", type text}}),
  #"Filas ordenadas" = Table.Sort(#"Tipo de columna cambiado 1", {{"ID", Order.Ascending}}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Filas ordenadas", {{"Mes", "MES"}, {"Sucursal", "SUCURSAL"}})
in
  #"Columnas con nombre cambiado";
shared #"Base Sucursales" = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota", [ApiVersion = 15]),
  #"Filas filtradas" = Table.SelectRows(Origen, each ([Folder Path] = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/Archivos para tableros/Control de Gestion/")),
  Navegación = #"Filas filtradas"{[Name = "Base Sucursales.xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/Archivos para tableros/Control de Gestion/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "Tabla_Sucursal", Kind = "Table"]}[Data],
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Navegación 1", {{"MES", type date}, {"REGION", type text}, {"SUCURSAL", type text}}, "es")
in
  #"Tipo de columna cambiado";
shared #"Base Volumen" = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota", [ApiVersion = 15]),
  Navegación = Origen{[Name = "Base Volumen Bi.xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/Archivos para tableros/Control de Gestion/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "Tabla_Volumen3", Kind = "Table"]}[Data],
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Navegación 1", {{"MES", type date}, {"REGION", type text}, {"SUCURSAL", type text}, {"SERVICIO", type text}, {"PAQ", type number}}, "es"),
  #"Personalizado agregado" = Table.AddColumn(#"Tipo de columna cambiado", "ID", each [SUCURSAL] & " - " & Text.From([MES])),
  #"Columna dinamizada" = Table.Pivot(Table.TransformColumnTypes(#"Personalizado agregado", {{"SERVICIO", type text}}), List.Distinct(Table.TransformColumnTypes(#"Personalizado agregado", {{"SERVICIO", type text}})[SERVICIO]), "SERVICIO", "PAQ"),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Columna dinamizada", {{"ID", type text}})
in
  #"Tipo de columna cambiado 1";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Sucursales Gral_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"Sucursales Gral" = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota", [ApiVersion = 15]),
  #"Filas filtradas" = Table.SelectRows(Origen, each ([Folder Path] = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/Archivos para tableros/Control de Gestion/")),
  Navegación = #"Filas filtradas"{[Name = "Base Sucursales.xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/Archivos para tableros/Control de Gestion/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "SUCURSALES", Kind = "Table"]}[Data],
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Navegación 1", {{"SUCURSAL", type text}, {"ABV", type text}}, "es")
in
  #"Tipo de columna cambiado";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Bases Completas_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"Bases Completas" = let
  Origen = Table.Combine({#"Base Metros", #"Base Eventuales", #"Base Nomina", #"Base Sucursales", #"Base Volumen"}),
  #"Se han quitado otras columnas." = Table.SelectColumns(Origen, {"MES", "REGION", "SUCURSAL", "ID"}),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Se han quitado otras columnas.", {{"ID", type text}}),
  #"Consultas combinadas" = Table.NestedJoin(#"Tipo de columna cambiado", {"ID"}, #"Base Eventuales", {"ID"}, "Base Eventuales", JoinKind.LeftOuter),
  #"Base Eventuales expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "Base Eventuales", {"Jornadas"}, {"Jornadas"}),
  #"Consultas combinadas 1" = Table.NestedJoin(#"Base Eventuales expandido", {"ID"}, #"Base Metros", {"ID"}, "Base Metros", JoinKind.LeftOuter),
  #"Base Metros expandido" = Table.ExpandTableColumn(#"Consultas combinadas 1", "Base Metros", {"METROS"}, {"METROS"}),
  #"Consultas combinadas 2" = Table.NestedJoin(#"Base Metros expandido", {"ID"}, #"Base Nomina", {"ID"}, "Base Nomina", JoinKind.LeftOuter),
  #"Base Nomina expandido" = Table.ExpandTableColumn(#"Consultas combinadas 2", "Base Nomina", {"INTERNOS", "CHOFERES", "JEFES", "SUPERVISORES"}, {"INTERNOS", "CHOFERES", "JEFES", "SUPERVISORES"}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Base Nomina expandido", {{"Jornadas", "Jornadas Eventuales"}}),
  #"Consultas combinadas 3" = Table.NestedJoin(#"Columnas con nombre cambiado", {"ID"}, #"Base Volumen", {"ID"}, "Base Volumen", JoinKind.LeftOuter),
  #"Base Volumen expandido" = Table.ExpandTableColumn(#"Consultas combinadas 3", "Base Volumen", {"DL VALORADOS", "MULTICLIENTE", "TRANSPORTE RUEDAS", "FULFILLMENT CROSS"}, {"DL VALORADOS", "MULTICLIENTE", "TRANSPORTE RUEDAS", "FULFILLMENT CROSS"}),
  #"Consultas combinadas 4" = Table.NestedJoin(#"Base Volumen expandido", {"SUCURSAL"}, #"Sucursales Gral", {"SUCURSAL"}, "Sucursales Gral", JoinKind.LeftOuter),
  #"Sucursales Gral expandido" = Table.ExpandTableColumn(#"Consultas combinadas 4", "Sucursales Gral", {"ABV"}, {"ABV"}),
  #"Columnas con nombre cambiado 1" = Table.RenameColumns(#"Sucursales Gral expandido", {{"ABV", "Suc"}})
in
  #"Columnas con nombre cambiado 1";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Acumulado_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Acumulado = let
    Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota", [ApiVersion = 15]),
    #"Filas filtradas" = Table.SelectRows(Origen, each ([Folder Path] = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/Archivos para tableros/Control de Gestion/")),
    #"Solo mensuales" = Table.SelectRows(#"Filas filtradas", each Text.EndsWith([Name], ".xlsx") and Text.Length(Text.BeforeDelimiter([Name], ".xlsx")) = 7 and Text.Middle(Text.BeforeDelimiter([Name], ".xlsx"), 4, 1) = "-" and (try Number.FromText(Text.Start(Text.BeforeDelimiter([Name], ".xlsx"), 4)) otherwise null) <> null and (try Number.FromText(Text.End(Text.BeforeDelimiter([Name], ".xlsx"), 2)) otherwise null) <> null),
    #"Fecha Periodo" = Table.AddColumn(#"Solo mensuales", "FechaPeriodo", each try Date.FromText(Text.BeforeDelimiter([Name], ".xlsx") & "-01", [Format="yyyy-MM-dd"]) otherwise null, type date),
  #"Personalizado agregado" = Table.AddColumn(#"Fecha Periodo", "Datos", each fxLeerExcel([Content])),
  #"Datos expandido" = Table.ExpandTableColumn(#"Personalizado agregado", "Datos", {"Fecha", "Tipo Asiento", "Asiento", "Referencia", "Auxiliar", "Ceco", "Sucursal", "Cod Cuenta", "Cuenta", "Saldo", "Origen", "Saldo Original", "Coeficiente", "Auxiliar Original", "Base Distribución", "Cod Cuenta Original", "Desc Cuenta Original", "SERIE", "NEGOCIO", "TIPO DE COSTO", "CC ORIGINAL 2", "CC IMPACTA 2", "°", "RUBRO AGR.", "ORDEN", "RUBRO CIERRE", "ORDEN 2", "Detalle", "Región"}, {"Fecha", "Tipo Asiento", "Asiento", "Referencia", "Auxiliar", "Ceco", "Sucursal", "Cod Cuenta", "Cuenta", "Saldo", "Origen", "Saldo Original", "Coeficiente", "Auxiliar Original", "Base Distribución", "Cod Cuenta Original", "Desc Cuenta Original", "SERIE", "NEGOCIO", "TIPO DE COSTO", "CC ORIGINAL 2", "CC IMPACTA 2", "°", "RUBRO AGR.", "ORDEN", "RUBRO CIERRE", "ORDEN 2", "Detalle", "Región"}),
  #"Elegir columnas" = Table.SelectColumns(#"Datos expandido", {"Name", "Date modified", "FechaPeriodo", "Fecha", "Tipo Asiento", "Asiento", "Referencia", "Auxiliar", "Ceco", "Sucursal", "Cod Cuenta", "Cuenta", "Saldo", "Origen", "Saldo Original", "Coeficiente", "Auxiliar Original", "Base Distribución", "Cod Cuenta Original", "Desc Cuenta Original", "SERIE", "NEGOCIO", "TIPO DE COSTO", "CC ORIGINAL 2", "CC IMPACTA 2", "°", "RUBRO AGR.", "ORDEN", "RUBRO CIERRE", "ORDEN 2", "Detalle", "Región"}),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Elegir columnas", {{"Fecha", type date}, {"Tipo Asiento", type text}, {"Asiento", type text}, {"Referencia", type text}, {"Auxiliar", type text}, {"Ceco", type text}, {"Sucursal", type text}, {"Cod Cuenta", type text}, {"Cuenta", type text}, {"Saldo", type number}, {"Origen", type text}, {"Saldo Original", type number}, {"Coeficiente", type number}, {"Auxiliar Original", type text}, {"Base Distribución", type text}, {"Cod Cuenta Original", type text}, {"Desc Cuenta Original", type text}, {"SERIE", type text}, {"NEGOCIO", type text}, {"TIPO DE COSTO", type text}, {"CC ORIGINAL 2", type text}, {"CC IMPACTA 2", type text}, {"°", Int64.Type}, {"RUBRO AGR.", type text}, {"ORDEN", Int64.Type}, {"RUBRO CIERRE", type text}, {"ORDEN 2", Int64.Type}, {"Detalle", type text}, {"Región", type text}})
in
    #"Tipo de columna cambiado";
shared #"Bases Completas_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "br_control_gestion_bases", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared fxLeerExcel = (Content as binary) as table =>
let
    Excel = Excel.Workbook(Content, null, true),
    Tablas = Table.SelectRows(Excel, each [Kind] = "Table"),
    ColumnasRequeridas = {"Fecha", "Tipo Asiento", "Asiento", "Referencia", "Auxiliar", "Ceco"},
    TablasValidas = Table.SelectRows(Tablas, each List.IsEmpty(List.Difference(ColumnasRequeridas, Table.ColumnNames([Data])))),
    Datos = if Table.RowCount(TablasValidas) = 1 then TablasValidas{0}[Data] else if Table.RowCount(TablasValidas) = 0 then error "No se encontró ninguna tabla con las columnas requeridas." else error "Se encontraron varias tablas que cumplen con las columnas requeridas."
in
    Datos;
shared Acumulado_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "br_control_gestion_acumulado", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared #"Sucursales Gral_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "br_control_gestion_equivalencias_sucursales", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
