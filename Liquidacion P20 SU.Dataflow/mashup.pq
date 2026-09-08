[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "vw_fleteros_p20sinUnidad_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared vw_fleteros_p20sinUnidad = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "vw_fleteros_p20sinUnidad", ItemKind = "View"]}[Data],
  #"Consulta anexada" = Table.Combine({#"Navegación 2", vw_fleteros_p20sinUnidad_carritos}),
  #"Tarifa agregada" = Table.AddColumn(#"Consulta anexada", "Registro", each Table.SelectRows(vw_fleteros_p20sinUnidad_detalle, (x) => [fecha_caratula] >= x[ID Viaje] and [fecha_caratula] <= x[Vigencia Hasta])),
  #"Monto expandido" = Table.ExpandTableColumn(#"Tarifa agregada", "Registro", {"Monto", "Monto Minimo"}, {"Monto", "Monto Minimo"}),
  #"Personalizado agregado" = Table.AddColumn(#"Monto expandido", "Extra", each if [entregadas] > 64 then ([entregadas] - 64) * [Monto] else 0),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Personalizado agregado", {{"Extra", type number}}),
  #"Personalizado agregado 1" = Table.AddColumn(#"Tipo de columna cambiado", "Total a Pagar", each [Monto Minimo] + [Extra]),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Personalizado agregado 1", {{"Total a Pagar", type number}, {"Monto", type number}, {"Monto Minimo", type number}}),
  #"Filas filtradas" = Table.SelectRows(#"Tipo de columna cambiado 1", each [fecha_caratula] > #date(2026, 7, 15))
in
  #"Filas filtradas";
shared vw_fleteros_p20sinUnidad_detalle = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "vw_fleteros_p20sinUnidad_detalle", ItemKind = "View"]}[Data],
  #"Últimos caracteres extraídos" = Table.TransformColumns(#"Navegación 2", {{"ID Viaje", each Text.End(_, 8), type text}}),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Últimos caracteres extraídos", {{"ID Viaje", type date}}),
  #"Filas filtradas" = Table.SelectRows(#"Tipo de columna cambiado", each [ID Viaje] > #date(2026, 7, 1)),
  #"Duplicados quitados" = Table.Distinct(#"Filas filtradas", {"tarifa_base", "ID Viaje"}),
  #"Personalizado agregado" = Table.AddColumn(#"Duplicados quitados", "Monto", each [tarifa_base] * 0.51),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Personalizado agregado", {{"Monto", type number}}),
  #"Personalizado agregado 1" = Table.AddColumn(#"Tipo de columna cambiado 1", "Monto Minimo", each 64 * [Monto]),
  #"Tipo de columna cambiado 2" = Table.TransformColumnTypes(#"Personalizado agregado 1", {{"Monto Minimo", type number}}),
  #"Filas ordenadas" = Table.Sort(#"Tipo de columna cambiado 2", {{"ID Viaje", Order.Ascending}}),
  #"Índice agregado" = Table.AddIndexColumn(#"Filas ordenadas", "Indice", 0, 1, Int64.Type),
  #"Tarifa anterior" = Table.AddColumn(#"Índice agregado", "Tarifa Anterior", each try #"Índice agregado"[tarifa_base]{[Indice] - 1} otherwise null),
  #"Cambios de tarifa" = Table.SelectRows(#"Tarifa anterior", each [Tarifa Anterior] = null or [tarifa_base] <> [Tarifa Anterior]),
  #"Índice agregado 2" = Table.AddIndexColumn(#"Cambios de tarifa", "Indice2", 0, 1, Int64.Type),
  #"Vigencia hasta" = Table.AddColumn(#"Índice agregado 2", "Vigencia Hasta", each try #"Índice agregado 2"[ID Viaje]{[Indice2] + 1} - #duration(1, 0, 0, 0) otherwise #date(9999, 12, 31), type date),
  #"Columnas quitadas" = Table.RemoveColumns(#"Vigencia hasta", {"Indice", "Indice2", "Tarifa Anterior"})
in
  #"Columnas quitadas";
shared vw_fleteros_p20sinUnidad_carritos = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "vw_fleteros_p20sinUnidad_carritos", ItemKind = "View"]}[Data],
  #"Elegir columnas" = Table.SelectColumns(#"Navegación 2", {"prov_codigo", "fecha_caratula", "legajo_nro", "apellido_y_nombre", "cant_piezas", "entregadas", "productividad"})
in
  #"Elegir columnas";
shared vw_fleteros_p20sinUnidad_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "gd_liq_fleteros_p20su", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
