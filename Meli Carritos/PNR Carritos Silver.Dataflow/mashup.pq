[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "br_pnr_carritos_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared br_pnr_carritos = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "br_pnr_carritos", ItemKind = "Table"]}[Data],
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Navegación 2", {{"ID DEL CASO", type text}, {"FECHA DEL CASO", type date}, {"FECHA PEDIDO DE REVISION", type date}, {"FECHA DE CIERRE DE CASO", type date}}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Tipo de columna cambiado", {{"NÂº DE PREFACTURA", "NRO DE PREFACTURA"}}),
  #"Valor reemplazado" = Table.ReplaceValue(#"Columnas con nombre cambiado", "$", "", Replacer.ReplaceText, {"VALOR DE LA COMPRA"}),
  #"Valor reemplazado 1" = Table.ReplaceValue(#"Valor reemplazado", ".", ",", Replacer.ReplaceText, {"VALOR DE LA COMPRA"}),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Valor reemplazado 1", {{"VALOR DE LA COMPRA", type number}, {"FECHA DE ENTREGA", type date}, {"ID DE RECLAMO", type text}})
in
  #"Tipo de columna cambiado 1";
shared br_pnr_carritos_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "sl_pnr_carritos", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared br_pnr_resumen_volumen = let
    Origen = Lakehouse.Contents(null),
    Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
    #"Navegación 1" = Navegación{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
    #"Navegación 2" = #"Navegación 1"{[Id = "br_pnr_resumen_volumen", ItemKind = "Table"]}[Data],
    #"Mes Nro" = Table.AddColumn(#"Navegación 2", "Mes Nro", each Text.PadStart(Text.From(List.PositionOf({"Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"}, [Mes]) + 1), 2, "0"), type text),
    #"Inicio Mes" = Table.AddColumn(#"Mes Nro", "Inicio Mes", each #date(Number.From([Año]), List.PositionOf({"Enero","Febrero","Marzo","Abril","Mayo","Junio","Julio","Agosto","Septiembre","Octubre","Noviembre","Diciembre"}, [Mes]) + 1, 1), type date),
  #"Personalizado agregado" = Table.AddColumn(#"Inicio Mes", "AñoMes", each [Año] & [Mes Nro]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Personalizado agregado", {{"AñoMes", type text}})

in
    #"Tipo de columna cambiado";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "br_soluciones problemas_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"br_soluciones problemas" = let
    Origen = Lakehouse.Contents(null),
    Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
    #"Navegación 1" = Navegación{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
    #"Navegación 2" = #"Navegación 1"{[Id = "br_pnr_solucion_problemas", ItemKind = "Table"]}[Data],
  #"Dividir columna por delimitador" = Table.SplitColumn(#"Navegación 2", "Fecha de creación", Splitter.SplitTextByDelimiter("| "), {"Fecha de creación.1", "Fecha de creación.2"}),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Dividir columna por delimitador", {{"Fecha de creación.1", type time}, {"Fecha de creación.2", type text}}, "es"),
  #"Dividir columna por delimitador 1" = Table.SplitColumn(#"Tipo de columna cambiado", "Fecha de cierre", Splitter.SplitTextByDelimiter("| "), {"Fecha de cierre.1", "Fecha de cierre.2"}),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Dividir columna por delimitador 1", {{"Fecha de cierre.1", type time}, {"Fecha de cierre.2", type text}}, "es"),
  #"Elegir columnas" = Table.SelectColumns(#"Tipo de columna cambiado 1", {"ID", "ID de paquete", "Problema", "Estado", "Problem Solver", "Fecha de creación.2", "Fecha de cierre.2", "Service Center", "Resolución", "Estado de resolución", "Analizado por", "Fecha de análisis", "Tiempo de resolución en minutos", "Origen del daño", "Motivo", "Tipo de daño", "Tipo de caso", "Ruta sugerida", "Motivo de la exclusión", "Link detalle del caso"}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Elegir columnas", {{"Fecha de creación.2", "Fecha de creación"}, {"Fecha de cierre.2", "Fecha de cierre"}})

in
    #"Columnas con nombre cambiado";
shared #"br_soluciones problemas_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "sl_pnr_soluciones_problemas", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
