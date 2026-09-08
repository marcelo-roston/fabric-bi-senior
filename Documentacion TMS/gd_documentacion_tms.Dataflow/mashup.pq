[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "sl_camiones_tms_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared sl_camiones_tms = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "sl_camiones_tms", ItemKind = "Table"]}[Data],
  #"Personalizado agregado" = Table.AddColumn(#"Navegación 2", "id choferes", each if [Cod_Chofer] = null then "Sin Chofer Asignado"
else 
"Choferes - " & Text.From([Cod_Chofer])),
  #"Personalizado agregado 1" = Table.AddColumn(#"Personalizado agregado", "id semis", each if [Nro_Semi] = null then "Sin Semi"
else
"Semis - " & Text.From([Nro_Semi])),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Personalizado agregado 1", {{"id choferes", type text}, {"id semis", type text}}),
  #"Consultas combinadas" = Table.NestedJoin(#"Tipo de columna cambiado", {"id choferes"}, #"Estado Entidad", {"id"}, "Estado Entidad", JoinKind.LeftOuter),
  #"Estado Entidad expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "Estado Entidad", {"Estado"}, {"Estado"}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Estado Entidad expandido", {{"Estado", "Estado Chofer"}}),
  #"Consultas combinadas 1" = Table.NestedJoin(#"Columnas con nombre cambiado", {"id"}, #"Estado Entidad", {"id"}, "Estado Entidad", JoinKind.LeftOuter),
  #"Estado Entidad expandido 1" = Table.ExpandTableColumn(#"Consultas combinadas 1", "Estado Entidad", {"Estado"}, {"Estado"}),
  #"Columnas con nombre cambiado 1" = Table.RenameColumns(#"Estado Entidad expandido 1", {{"Estado", "Estado Camiones"}}),
  #"Consultas combinadas 2" = Table.NestedJoin(#"Columnas con nombre cambiado 1", {"id semis"}, #"Estado Entidad", {"id"}, "Estado Entidad", JoinKind.LeftOuter),
  #"Estado Entidad expandido 2" = Table.ExpandTableColumn(#"Consultas combinadas 2", "Estado Entidad", {"Estado"}, {"Estado"}),
  #"Columnas con nombre cambiado 2" = Table.RenameColumns(#"Estado Entidad expandido 2", {{"Estado", "Estado Semis"}}),
  #"Personalizado agregado 2" = Table.AddColumn(#"Columnas con nombre cambiado 2", "Chofer + Camion", each if [Estado Chofer] = "OK" and [Estado Camiones] = "OK" then "OK" else "NO OK"),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Personalizado agregado 2", {{"Chofer + Camion", type text}}),
  #"Columnas reordenadas" = Table.ReorderColumns(#"Tipo de columna cambiado 1", {"id", "Nro_Camion", "Patente", "Marca", "Modelo", "Ano", "Cod_tipo_Vehiculo", "Nro_Semi", "Cod_Chofer", "Inhabilitado", "Suc", "Fecha_Inhabilitacion", "Fecha_Vto_Inhabilitacion", "Registro_Activo", "Fecha_Alta", "Cod_Satelital", "Cod_Transp", "Fecha_Certificado", "Cod_Tipo_Combustible", "Legajo", "Segmento_Operativo", "Chofer", "id choferes", "id semis", "Estado Chofer", "Estado Camiones", "Estado Semis", "Chofer + Camion"}),
  #"Consultas combinadas 3" = Table.NestedJoin(#"Columnas reordenadas", {"Cod_Transp"}, sl_tansportistas_tms, {"Cod_Transp"}, "sl_tansportistas_tms", JoinKind.LeftOuter),
  #"sl_tansportistas_tms expandido" = Table.ExpandTableColumn(#"Consultas combinadas 3", "sl_tansportistas_tms", {"Razon_Soc"}, {"Razon_Soc"}),
  #"Columnas con nombre cambiado 3" = Table.RenameColumns(#"sl_tansportistas_tms expandido", {{"Razon_Soc", "Transportista"}, {"id", "id camion"}}),
  #"Elegir columnas" = Table.SelectColumns(#"Columnas con nombre cambiado 3", {"id camion", "Nro_Camion", "Patente", "Marca", "Modelo", "Ano", "Cod_tipo_Vehiculo", "Nro_Semi", "Cod_Chofer", "Inhabilitado", "Suc", "Fecha_Inhabilitacion", "Fecha_Vto_Inhabilitacion", "Registro_Activo", "Fecha_Alta", "Cod_Satelital", "Cod_Transp", "Cod_Tipo_Combustible", "Legajo", "Segmento_Operativo", "Chofer Habilitado", "Chofer", "id choferes", "id semis", "Estado Chofer", "Estado Camiones", "Estado Semis", "Chofer + Camion", "Transportista"}),
  #"Filas filtradas" = Table.SelectRows(#"Elegir columnas", each ([Inhabilitado] = "FALSE")),
  #"Columnas con nombre cambiado 4" = Table.RenameColumns(#"Filas filtradas", {{"Chofer Habilitado", "Chofer Inhabilitado"}})
in
  #"Columnas con nombre cambiado 4";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "sl_choferes_tms_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared sl_choferes_tms = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "sl_choferes_tms", ItemKind = "Table"]}[Data],
  CamionesProcesados = Table.Group(sl_camiones_tms, {"id choferes"}, {{"Camiones", each 
      let
        habilitados = Table.SelectRows(_, each [Inhabilitado] = "NO"),
        resultado = if Table.RowCount(habilitados) > 0 then habilitados else Table.FirstN(_,1)
      in
        resultado
    , type table}}),
  #"Expandir camiones" = Table.ExpandTableColumn(CamionesProcesados, "Camiones", {"id"}, {"id camion"}),
  #"Consultas combinadas" = Table.NestedJoin(#"Navegación 2", {"id"}, #"Expandir camiones", {"id choferes"}, "camion", JoinKind.LeftOuter),
  #"Expandido camion" = Table.ExpandTableColumn(#"Consultas combinadas", "camion", {"id camion"}, {"id camion"}),
  #"Personalizado agregado" = Table.AddColumn(#"Expandido camion", "Camion Asignado", each if [id camion] = null then "SIN CAMION ASIGNADO" else Text.From([id camion])),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Personalizado agregado", {{"Camion Asignado", type text}}),
  #"Columnas reordenadas" = Table.ReorderColumns(#"Tipo de columna cambiado", {"id", "Cod_Chofer", "Nombre", "Inhabilitado", "Fecha_Inhabilitacion", "Fecha_Vto_Inhabilitacion", "Observaciones", "Registro_Activo", "Fecha_Alta", "Cod_Transp", "LEGAJO", "Segmento_Operativo", "id camion", "Camion Asignado"}),
  #"Elegir columnas" = Table.SelectColumns(#"Columnas reordenadas", {"id", "Cod_Chofer", "Nombre", "Inhabilitado", "Fecha_Inhabilitacion", "Fecha_Vto_Inhabilitacion", "Observaciones", "Registro_Activo", "Fecha_Alta", "Cod_Transp", "LEGAJO", "Segmento_Operativo", "Camion Asignado"}),
  #"Filas filtradas" = Table.SelectRows(#"Elegir columnas", each ([Inhabilitado] = "FALSE"))
in
  #"Filas filtradas";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "sl_documentacion_tms_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared sl_documentacion_tms = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "sl_documentacion_tms", ItemKind = "Table"]}[Data],
  #"Personalizado agregado" = Table.AddColumn(#"Navegación 2", "Estado", each if [Obligatorio] = "FALSE" then "NO OBLIGATORIO"
else if [Fecha_Vto] = null then "NO CARGADO"
else if [Fecha_Vto] < Date.From(DateTime.LocalNow()) then "VENCIDO"
else if [Fecha_Vto] <= Date.AddDays(Date.From(DateTime.LocalNow()), 10) then "POR_VENCER"
else "OK"),
  #"Personalizado agregado 1" = Table.AddColumn(#"Personalizado agregado", "Criticidad", each if [Obligatorio] = "FALSE" then "OK"
else if [Fecha_Vto] = null then "ALTA"
else if [Fecha_Vto] < Date.From(DateTime.LocalNow()) then "ALTA"
else if [Fecha_Vto] <= Date.AddDays(Date.From(DateTime.LocalNow()), 10) then "MEDIA"
else "OK"),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Personalizado agregado 1", {{"Estado", type text}, {"Criticidad", type text}}),
  #"Personalizado agregado 2" = Table.AddColumn(#"Tipo de columna cambiado", "Severidad", each if [Criticidad] = "OK" then 1
else if [Criticidad] = "MEDIA" then 2
else if [Criticidad] = "ALTA" then 3
else null),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Personalizado agregado 2", {{"Severidad", Int64.Type}})
in
  #"Tipo de columna cambiado 1";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "sl_semirremolques_tms_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared sl_semirremolques_tms = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "sl_semirremolques_tms", ItemKind = "Table"]}[Data],
  #"Filas filtradas" = Table.SelectRows(#"Navegación 2", each ([Inhabilitado] = "FALSE"))
in
  #"Filas filtradas";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "sl_tansportistas_tms_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared sl_tansportistas_tms = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "sl_tansportistas_tms", ItemKind = "Table"]}[Data],
  #"Consultas combinadas" = Table.NestedJoin(#"Navegación 2", {"id"}, #"Estado Entidad", {"id"}, "Estado Entidad", JoinKind.LeftOuter),
  #"Estado Entidad expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "Estado Entidad", {"Estado"}, {"Estado"}),
  #"Filas filtradas" = Table.SelectRows(#"Estado Entidad expandido", each ([Inhabilitado] = "FALSE"))
in
  #"Filas filtradas";
shared #"Estado Entidad" = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "sl_documentacion_tms", ItemKind = "Table"]}[Data],
  #"Personalizado agregado" = Table.AddColumn(#"Navegación 2", "Estado", each if [Obligatorio] = "FALSE" then "NO OBLIGATORIO"
else if [Fecha_Vto] = null then "NO CARGADO"
else if [Fecha_Vto] < Date.From(DateTime.LocalNow()) then "VENCIDO"
else if [Fecha_Vto] <= Date.AddDays(Date.From(DateTime.LocalNow()), 10) then "POR_VENCER"
else "OK"),
  #"Personalizado agregado 1" = Table.AddColumn(#"Personalizado agregado", "Criticidad", each if [Obligatorio] = "NO" then "OK"
else if [Fecha_Vto] = null then "ALTA"
else if [Fecha_Vto] < Date.From(DateTime.LocalNow()) then "ALTA"
else if [Fecha_Vto] <= Date.AddDays(Date.From(DateTime.LocalNow()), 10) then "MEDIA"
else "OK"),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Personalizado agregado 1", {{"Estado", type text}, {"Criticidad", type text}}),
  #"Personalizado agregado 2" = Table.AddColumn(#"Tipo de columna cambiado", "Severidad", each if [Criticidad] = "OK" then 1
else if [Criticidad] = "MEDIA" then 2
else if [Criticidad] = "ALTA" then 3
else null),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Personalizado agregado 2", {{"Severidad", Int64.Type}}),
  #"Filas filtradas" = Table.SelectRows(#"Tipo de columna cambiado 1", each ([Obligatorio] = "TRUE")),
  #"Filas agrupadas" = Table.Group(#"Filas filtradas", {"id"}, {{"MaxSeveridad", each List.Max([Severidad]), type nullable Int64.Type}}),
  #"Personalizado agregado 3" = Table.AddColumn(#"Filas agrupadas", "Estado", each if [MaxSeveridad] = 3 then "NO OK" else "OK"),
  #"Tipo de columna cambiado 2" = Table.TransformColumnTypes(#"Personalizado agregado 3", {{"Estado", type text}})
in
  #"Tipo de columna cambiado 2";
shared sl_choferes_tms_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "gd_choferes_tms", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared sl_documentacion_tms_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "gd_documentacion_tms", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared sl_semirremolques_tms_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "gd_semirremolques_tms", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared sl_tansportistas_tms_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "gd_tansportistas_tms", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared sl_camiones_tms_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "gd_camiones_tms", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
