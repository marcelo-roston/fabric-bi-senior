[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared #"Presentes U3 Productividad" = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "Presentes U3 Productividad", ItemKind = "View"]}[Data],
  #"Personalizado agregado" = Table.AddColumn(#"Navegación 2", "ID", each [legajo_nro] & "_" &
Date.ToText([fecha_caratula], "yyyyMMdd") & "_URBANO_" & [prov_codigo]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Personalizado agregado", {{"ID", type text}})
in
  #"Tipo de columna cambiado";
shared sl_presentes_carritos = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "sl_presentes_carritos", ItemKind = "Table"]}[Data],
  #"Elegir columnas" = Table.SelectColumns(#"Navegación 2", {"FECHA", "PATENTE", "Q SHP", "legajo_nro", "apellido_y_nombre", "SUCURSAL", "Modalidad", "id_presente", "Delivery Success"}),
  #"Valor reemplazado" = Table.ReplaceValue(#"Elegir columnas", null, "SIN LEGAJO", Replacer.ReplaceValue, {"legajo_nro"}),
  #"Columna condicional insertada" = Table.AddColumn(#"Valor reemplazado", "chofer", each if [apellido_y_nombre] = null then "PATENTE: " &[PATENTE] else [apellido_y_nombre]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Columna condicional insertada", {{"chofer", type text}}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Tipo de columna cambiado", {{"id_presente", "ID"}, {"Modalidad", "modalidad"}, {"SUCURSAL", "sucursal"}, {"legajo_nro", "legajo"}, {"FECHA", "fecha"}}),
  #"Elegir columnas 1" = Table.SelectColumns(#"Columnas con nombre cambiado", {"fecha", "Q SHP", "legajo", "sucursal", "modalidad", "ID", "Delivery Success", "chofer"}),
  #"Columnas reordenadas" = Table.ReorderColumns(#"Elegir columnas 1", {"fecha", "sucursal", "legajo", "chofer", "modalidad", "Q SHP", "Delivery Success", "ID"}),
  #"Columnas con nombre cambiado 1" = Table.RenameColumns(#"Columnas reordenadas", {{"Q SHP", "piezas"}, {"Delivery Success", "productividad"}})
  
in
  #"Columnas con nombre cambiado 1";
shared br_presentes_u3 = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "br_presentes_u3", ItemKind = "Table"]}[Data],
  #"Consultas combinadas" = Table.NestedJoin(#"Navegación 2", {"ID"}, #"Presentes U3 Productividad", {"ID"}, "Presentes U3 Productividad", JoinKind.LeftOuter),
  #"Presentes U3 Productividad expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "Presentes U3 Productividad", {"cant_piezas", "productividad"}, {"cant_piezas", "productividad"}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Presentes U3 Productividad expandido", {{"cant_piezas", "piezas"}})
in
  #"Columnas con nombre cambiado";
shared FLETERO_CABECERA = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "5134ca31-6307-4e20-bd74-ad80ca764046"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "049ecaa5-eaaf-4849-a618-a273849a7de9"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "FLETERO_CABECERA", ItemKind = "Table"]}[Data],
  #"Elegir columnas" = Table.SelectColumns(#"Navegación 2", {"createdAt", "alias", "nombre_completo", "legajo_nro"}),
  #"Filas filtradas" = Table.SelectRows(#"Elegir columnas", each [createdAt] > #date(2026, 1, 1)),
  #"Personalizado agregado" = Table.AddColumn(#"Filas filtradas", "ID", each [legajo_nro] & "_" & Date.ToText([createdAt], "yyyyMMdd") & "_URBANO_" & [alias]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Personalizado agregado", {{"ID", type text}}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Tipo de columna cambiado", {{"createdAt", "fecha"}, {"alias", "sucursal"}, {"nombre_completo", "chofer"}, {"legajo_nro", "legajo"}}),
  #"Personalizado agregado 1" = Table.AddColumn(#"Columnas con nombre cambiado", "modalidad", each "URBANO"),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Personalizado agregado 1", {{"modalidad", type text}}),
  #"Columnas reordenadas" = Table.ReorderColumns(#"Tipo de columna cambiado 1", {"fecha", "sucursal", "legajo", "chofer", "modalidad", "ID"}),
  #"Filas filtradas 1" = Table.SelectRows(#"Columnas reordenadas", each Text.StartsWith([legajo], "P"))
in
  #"Filas filtradas 1";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Presentismo unificado_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"Presentismo unificado" = let
  Origen = Table.Combine({br_presentes_u3, sl_presentes_carritos, FLETERO_CABECERA}),

  #"Personalizado agregado" = Table.AddColumn(Origen, "Puntos", each 
    (if [piezas] = null then 0
      else if [piezas] >= 70 then 3
      else if [piezas] >= 50 then 2
      else 1)
    +
    (if [productividad] = null then 0
      else if [productividad] >= 0.95 then 5
      else if [productividad] >= 0.9 then 4
      else if [productividad] >= 0.8 then 3
      else if [productividad] >= 0.7 then 2
      else 1) + 5),

  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Personalizado agregado", {{"Puntos", Int64.Type}, {"piezas", Int64.Type}}),

  #"Ordenado" = Table.Sort(#"Tipo de columna cambiado", {{"Puntos", Order.Descending}}),

  #"Duplicados quitados" = Table.Distinct(#"Ordenado", {"ID"})
in
  #"Duplicados quitados";
shared #"Presentismo unificado_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "gd_presentismo_ranking_urbano_carritos", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
