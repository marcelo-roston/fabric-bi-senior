[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Consulta_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Consulta = let
  Origen = SharePoint.Files("https://urbexpress.sharepoint.com/sites/GRANDESCLIENTES", [ApiVersion = 15]),
  Navegación = Origen{[Name = "ESQUELETO OK - MELI hasta feb (4).xlsx", #"Folder Path" = "https://urbexpress.sharepoint.com/sites/GRANDESCLIENTES/Documentos compartidos/ESQUELETO OK MELI MLP/"]}[Content],
  #"Libro de Excel importado" = Excel.Workbook(Navegación, null, true),
  #"Navegación 1" = #"Libro de Excel importado"{[Item = "Hoja1", Kind = "Sheet"]}[Data],
  #"Encabezados promovidos" = Table.PromoteHeaders(#"Navegación 1", [PromoteAllScalars = true]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Encabezados promovidos", {{"Mes", type text}, {"Año", Int64.Type}, {"Sucursal", type text}, {"Líder regional", type text}, {"TOTAL Q de paquetes  que pasan por la sucu", Int64.Type}, {"Q de paquetes rodados desde la sucursal", Int64.Type}, {"q sorting", Int64.Type}, {"Q  viajes", Int64.Type}, {"Promedio PQ x Recorrido", type number}, {"Q de MM", Int64.Type}, {"Facturación CARGA/DESCARGA", type number}, {"Facturación RUEDAS", type number}, {"Facturación MEDIA MILLA", type number}, {"Precio CARGA/DESCARGA y SORTING", type number}, {"Precio por RUEDAS", type number}, {"Precio x MEDIA MILLA", type number}, {"TOTAL FAC", type number}, {"Column20", type number}}, "es"),
  #"Elegir columnas" = Table.SelectColumns(#"Tipo de columna cambiado", {"Mes", "Año", "Sucursal", "Líder regional", "TOTAL Q de paquetes  que pasan por la sucu", "Q de paquetes rodados desde la sucursal", "q sorting", "Q  viajes", "Promedio PQ x Recorrido", "Q de MM", "Facturación CARGA/DESCARGA", "Facturación RUEDAS", "Facturación MEDIA MILLA", "Precio CARGA/DESCARGA y SORTING", "Precio por RUEDAS", "Precio x MEDIA MILLA", "TOTAL FAC"}),
  #"Filas filtradas" = Table.SelectRows(#"Elegir columnas", each ([Mes] <> null)),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Filas filtradas", {{"Promedio PQ x Recorrido", "Promedio PQ x Recorrido NO"}, {"Precio CARGA/DESCARGA y SORTING", "Precio CARGA/DESCARGA y SORTING NO"}, {"Precio por RUEDAS", "Precio por RUEDAS NO"}, {"TOTAL FAC", "TOTAL FAC NO"}, {"Precio x MEDIA MILLA", "Precio x MEDIA MILLA NO"}}),
  #"Personalizado agregado" = Table.AddColumn(#"Columnas con nombre cambiado", "Promedio PQ x Recorrido", each if [Q  viajes] = 0 or  [Q  viajes] = null then null else [Q de paquetes rodados desde la sucursal] / [Q  viajes]),
  #"Personalizado agregado 1" = Table.AddColumn(#"Personalizado agregado", "Precio CARGA/DESCARGA y SORTING", each if [TOTAL Q de paquetes  que pasan por la sucu] = 0 or [TOTAL Q de paquetes  que pasan por la sucu] = null then null else
[#"Facturación CARGA/DESCARGA"] / [TOTAL Q de paquetes  que pasan por la sucu]),
  #"Personalizado agregado 2" = Table.AddColumn(#"Personalizado agregado 1", "Precio por RUEDAS", each if [Q  viajes] = 0 or [Q  viajes] = null then null else
[Facturación RUEDAS] / [Q  viajes]),
  #"Personalizado agregado 3" = Table.AddColumn(#"Personalizado agregado 2", "Precio x MEDIA MILLA", each if [Q de MM] = 0 or [Q de MM] = null then null else
[Facturación MEDIA MILLA] / [Q de MM]),
  #"Personalizado agregado 4" = Table.AddColumn(
    #"Personalizado agregado 3",
    "TOTAL FAC",
    each 
        (if [#"Facturación CARGA/DESCARGA"] = null then 0 else [#"Facturación CARGA/DESCARGA"]) +
        (if [Facturación RUEDAS] = null then 0 else [Facturación RUEDAS]) +
        (if [Facturación MEDIA MILLA] = null then 0 else [Facturación MEDIA MILLA])
),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Personalizado agregado 4", {{"TOTAL FAC", type number}, {"Precio x MEDIA MILLA", type number}, {"Precio por RUEDAS", type number}, {"Precio CARGA/DESCARGA y SORTING", type number}, {"Promedio PQ x Recorrido", type number}}),
  #"Elegir columnas 1" = Table.SelectColumns(#"Tipo de columna cambiado 1", {"Mes", "Año", "Sucursal", "Líder regional", "TOTAL Q de paquetes  que pasan por la sucu", "Q de paquetes rodados desde la sucursal", "q sorting", "Q  viajes", "Q de MM", "Facturación CARGA/DESCARGA", "Facturación RUEDAS", "Facturación MEDIA MILLA", "Promedio PQ x Recorrido", "Precio CARGA/DESCARGA y SORTING", "Precio por RUEDAS", "Precio x MEDIA MILLA", "TOTAL FAC"}),
  #"Columnas reordenadas" = Table.ReorderColumns(#"Elegir columnas 1", {"Mes", "Año", "Sucursal", "Líder regional", "TOTAL Q de paquetes  que pasan por la sucu", "Q de paquetes rodados desde la sucursal", "q sorting", "Q  viajes", "Promedio PQ x Recorrido", "Q de MM", "Facturación CARGA/DESCARGA", "Facturación RUEDAS", "Facturación MEDIA MILLA", "Precio CARGA/DESCARGA y SORTING", "Precio por RUEDAS", "Precio x MEDIA MILLA", "TOTAL FAC"})
in
  #"Columnas reordenadas";
shared Consulta_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null, PreserveOrder = null]),
  Navigation_1 = Pattern{[workspaceId = "5134ca31-6307-4e20-bd74-ad80ca764046"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "049ecaa5-eaaf-4849-a618-a273849a7de9"]}[Data],
  TableNavigation = Navigation_2{[Id = "MLP", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
