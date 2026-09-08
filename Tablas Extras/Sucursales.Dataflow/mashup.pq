[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Consulta_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Consulta = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota/", [ApiVersion = 15]),
  #"Filas filtradas 1" = Table.SelectRows(Origen, each Text.Contains([Folder Path], "Marcelo")),
  Navegación = #"Filas filtradas 1"{[Name = "CÓDIGO Y DETALLE SUCURSALES.xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "Tabla1", Kind = "Table"]}[Data],
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Navegación 1", {{"Cod_Suc", type text}, {"NOMBRE", type text}, {"PARTE", type text}, {"lat y long", type text}, {"Columna1", type text}, {"Gerente", type text}, {"REGIÓN", type text}}, "es"),
  #"Dividir columna por delimitador" = Table.SplitColumn(#"Tipo de columna cambiado", "lat y long", Splitter.SplitTextByDelimiter(", "), {"lat y long.1", "lat y long.2"}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Dividir columna por delimitador", {{"lat y long.1", "Latitud"}}),
  #"Columnas con nombre cambiado 1" = Table.RenameColumns(#"Columnas con nombre cambiado", {{"lat y long.2", "Longitud"}}),
  #"Elegir columnas" = Table.SelectColumns(#"Columnas con nombre cambiado 1", {"Cod_Suc", "NOMBRE", "Latitud", "Longitud", "REGIÓN"}),
  #"Valor reemplazado" = Table.ReplaceValue(#"Elegir columnas", ".", ",", Replacer.ReplaceText, {"Latitud", "Longitud"}),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Valor reemplazado", {{"Latitud", type number}, {"Longitud", type number}}),
  #"Columnas con nombre cambiado 2" = Table.RenameColumns(#"Tipo de columna cambiado 1", {{"Cod_Suc", "Sucursal"}, {"NOMBRE", "Nombre"}, {"REGIÓN", "Region"}})
in
  #"Columnas con nombre cambiado 2";
shared Consulta_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "gd_sucursales", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
