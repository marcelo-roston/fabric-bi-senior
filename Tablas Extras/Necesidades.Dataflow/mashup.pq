[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Consulta_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Consulta = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/flota/", [ApiVersion = 15]),
  #"Filas filtradas 1" = Table.SelectRows(Origen, each Text.Contains([Folder Path], "Marcelo")),
  Navegación = #"Filas filtradas 1"{[Name = "NECESIDADES.xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/flota/Documentos compartidos/Marcelo/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "Tabla1", Kind = "Table"]}[Data],
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Navegación 1", {{"SUCURSALES", type text}, {"NECESIDAD NORMAL CHICOS", Int64.Type}, {"NECESIDAD NORMAL GRANDES", Int64.Type}, {"NECESIDAD TOTAL", Int64.Type}, {"SEMANA", Int64.Type}, {"AÑO", Int64.Type}}),
  #"Personalizado agregado" = Table.AddColumn(#"Tipo de columna cambiado", "Año - Semana", each Text.From([AÑO]) & Text.PadStart(Text.From([SEMANA]), 2, "0")),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Personalizado agregado", {{"Año - Semana", type text}})
in
  #"Tipo de columna cambiado 1";
shared Consulta_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null, PreserveOrder = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "gd_necesidades_moviles", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
