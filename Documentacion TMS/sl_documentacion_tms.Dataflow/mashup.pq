[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "br_camiones_tms_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared br_camiones_tms = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "br_camiones_tms", ItemKind = "Table"]}[Data],
  #"Personalizado agregado" = Table.AddColumn(#"Navegación 2", "id", each "Camiones - " & Text.From([Nro_Camion])),
  #"Elegir columnas" = Table.SelectColumns(#"Personalizado agregado", {"Nro_Camion", "Patente", "Marca", "Modelo", "Ano", "Cod_tipo_Vehiculo", "Nro_Semi", "Cod_Chofer", "Inhabilitado", "Fecha_Inhabilitacion", "Fecha_Vto_Inhabilitacion", "Observaciones", "Registro_Activo", "Fecha_Alta", "Cod_Satelital", "Cod_Transp", "Fecha_Certificado", "Cod_Tipo_Combustible", "Legajo", "Segmento_Operativo", "id"}),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Elegir columnas", {{"id", type text}, {"Fecha_Alta", type date}, {"Fecha_Vto_Inhabilitacion", type date}, {"Fecha_Inhabilitacion", type date}, {"Inhabilitado", type text}, {"Registro_Activo", type text}}),
  #"Texto en mayúsculas" = Table.TransformColumns(#"Tipo de columna cambiado", {{"Inhabilitado", each Text.Upper(_), type nullable text}}),
  #"Texto en mayúsculas 1" = Table.TransformColumns(#"Texto en mayúsculas", {{"Registro_Activo", each Text.Upper(_), type nullable text}}),
  #"Consultas combinadas" = Table.NestedJoin(#"Texto en mayúsculas 1", {"Observaciones"}, #"Sucursales Corregidas", {"Observaciones"}, "Sucursales Corregidas", JoinKind.LeftOuter),
  #"Sucursales Corregidas expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "Sucursales Corregidas", {"Sucursal"}, {"Sucursal"}),
  #"Consultas combinadas 1" = Table.NestedJoin(#"Sucursales Corregidas expandido", {"Cod_Chofer"}, br_choferes_tms, {"Cod_Chofer"}, "br_choferes_tms", JoinKind.LeftOuter),
  #"br_choferes_tms expandido 1" = Table.ExpandTableColumn(#"Consultas combinadas 1", "br_choferes_tms", {"Nombre", "Inhabilitado", "Observaciones", "Tipo Empleado"}, {"Nombre", "Inhabilitado.1", "Observaciones.1", "Tipo Empleado"}),
  #"Columnas con nombre cambiado 1" = Table.RenameColumns(#"br_choferes_tms expandido 1", {{"Nombre", "Chofer"}, {"Inhabilitado.1", "Chofer Habilitado"}}),
  #"Personalizado agregado 1" = Table.AddColumn(#"Columnas con nombre cambiado 1", "Obs", each if [Observaciones] = null then [Observaciones.1] else [Observaciones]),
  #"Tipo de columna cambiado 2" = Table.TransformColumnTypes(#"Personalizado agregado 1", {{"Obs", type text}}),
  #"Columna condicional insertada" = Table.AddColumn(#"Tipo de columna cambiado 2", "Suc", each if [Sucursal] = null then [Obs] else [Sucursal]),
  #"Elegir columnas 1" = Table.SelectColumns(#"Columna condicional insertada", {"Nro_Camion", "Patente", "Marca", "Modelo", "Ano", "Cod_tipo_Vehiculo", "Nro_Semi", "Cod_Chofer", "Inhabilitado", "Fecha_Inhabilitacion", "Fecha_Vto_Inhabilitacion", "Registro_Activo", "Fecha_Alta", "Cod_Satelital", "Cod_Transp", "Fecha_Certificado", "Cod_Tipo_Combustible", "Legajo", "Segmento_Operativo", "id", "Chofer", "Chofer Habilitado", "Tipo Empleado", "Suc"}),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Elegir columnas 1", {{"Suc", type text}}),
  #"Columnas reordenadas" = Table.ReorderColumns(#"Tipo de columna cambiado 1", {"Nro_Camion", "Patente", "Marca", "Modelo", "Ano", "Cod_tipo_Vehiculo", "Nro_Semi", "Cod_Chofer", "Inhabilitado", "Suc", "Fecha_Inhabilitacion", "Fecha_Vto_Inhabilitacion", "Registro_Activo", "Fecha_Alta", "Cod_Satelital", "Cod_Transp", "Fecha_Certificado", "Cod_Tipo_Combustible", "Legajo", "Segmento_Operativo", "id", "Chofer"})
in
  #"Columnas reordenadas";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "br_choferes_tms_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared br_choferes_tms = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "br_choferes_tms", ItemKind = "Table"]}[Data],
  #"Personalizado agregado" = Table.AddColumn(#"Navegación 2", "id", each "Choferes - " & Text.From([Cod_Chofer])),
  #"Elegir columnas" = Table.SelectColumns(#"Personalizado agregado", {"Cod_Chofer", "Nombre", "Inhabilitado", "Fecha_Inhabilitacion", "Fecha_Vto_Inhabilitacion", "Observaciones", "Registro_Activo", "Fecha_Alta", "Cod_Transp", "LEGAJO", "Segmento_Operativo", "id"}),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Elegir columnas", {{"Inhabilitado", type text}, {"Registro_Activo", type text}, {"Fecha_Alta", type date}}),
  #"Texto en mayúsculas" = Table.TransformColumns(#"Tipo de columna cambiado", {{"Inhabilitado", each Text.Upper(_), type nullable text}, {"Registro_Activo", each Text.Upper(_), type nullable text}}),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Texto en mayúsculas", {{"id", type text}}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Tipo de columna cambiado 1", {{"Observaciones", "Obs"}}),
  #"Consultas combinadas" = Table.NestedJoin(#"Columnas con nombre cambiado", {"Obs"}, #"Sucursales Corregidas", {"Observaciones"}, "Sucursales Corregidas", JoinKind.LeftOuter),
  #"Sucursales Corregidas expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "Sucursales Corregidas", {"Sucursal"}, {"Sucursal"}),
  #"Columna condicional insertada" = Table.AddColumn(#"Sucursales Corregidas expandido", "Observaciones", each if [Sucursal] = null then [Obs] else [Sucursal]),
  #"Tipo de columna cambiado 2" = Table.TransformColumnTypes(#"Columna condicional insertada", {{"Observaciones", type text}}),
  #"Columnas reordenadas" = Table.ReorderColumns(#"Tipo de columna cambiado 2", {"Cod_Chofer", "Nombre", "Inhabilitado", "Fecha_Inhabilitacion", "Fecha_Vto_Inhabilitacion", "Obs", "Observaciones", "Registro_Activo", "Fecha_Alta", "Cod_Transp", "LEGAJO", "Segmento_Operativo", "id", "Sucursal"}),
  #"Elegir columnas 1" = Table.SelectColumns(#"Columnas reordenadas", {"Cod_Chofer", "Nombre", "Inhabilitado", "Fecha_Inhabilitacion", "Fecha_Vto_Inhabilitacion", "Observaciones", "Registro_Activo", "Fecha_Alta", "Cod_Transp", "LEGAJO", "Segmento_Operativo", "id"}),
  #"Duplicados quitados" = Table.Distinct(#"Elegir columnas 1", {"id"}),
  #"Personalizado agregado 1" = Table.AddColumn(#"Duplicados quitados", "Tipo Empleado", each if [LEGAJO] <> null and Text.StartsWith(Text.From([LEGAJO]), "P2") then "P20"
else "P10"),
  #"Tipo de columna cambiado 3" = Table.TransformColumnTypes(#"Personalizado agregado 1", {{"Tipo Empleado", type text}})
in
  #"Tipo de columna cambiado 3";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "br_semirremolques_tms_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared br_semirremolques_tms = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "br_semirremolques_tms", ItemKind = "Table"]}[Data],
  #"Personalizado agregado" = Table.AddColumn(#"Navegación 2", "id", each "Semis - " & Text.From([Nro_Semi])),
  #"Elegir columnas" = Table.SelectColumns(#"Personalizado agregado", {"Nro_Semi", "Patente", "Marca", "Modelo", "Inhabilitado", "Fecha", "Segmento_Operativo", "id"}),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Elegir columnas", {{"Inhabilitado", type text}}),
  #"Texto en mayúsculas" = Table.TransformColumns(#"Tipo de columna cambiado", {{"Inhabilitado", each Text.Upper(_), type nullable text}}),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Texto en mayúsculas", {{"id", type text}}),
  #"Columnas reordenadas" = Table.ReorderColumns(#"Tipo de columna cambiado 1", {"id", "Nro_Semi", "Patente", "Marca", "Modelo", "Inhabilitado", "Fecha", "Segmento_Operativo"})
in
  #"Columnas reordenadas";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "br_tansportistas_tms_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared br_tansportistas_tms = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "br_tansportistas_tms", ItemKind = "Table"]}[Data],
  #"Personalizado agregado" = Table.AddColumn(#"Navegación 2", "id", each "Transportistas - " & Text.From([Cod_Transp])),
  #"Elegir columnas" = Table.SelectColumns(#"Personalizado agregado", {"Cod_Transp", "Razon_Soc", "Inhabilitado", "Fecha_Inhabilitacion", "Registro_Activo", "Segmento_Operativo", "id"}),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Elegir columnas", {{"Inhabilitado", type text}, {"Registro_Activo", type text}}),
  #"Texto en mayúsculas" = Table.TransformColumns(#"Tipo de columna cambiado", {{"Inhabilitado", each Text.Upper(_), type nullable text}, {"Registro_Activo", each Text.Upper(_), type nullable text}}),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Texto en mayúsculas", {{"Fecha_Inhabilitacion", type date}, {"id", type text}}),
  #"Columnas reordenadas" = Table.ReorderColumns(#"Tipo de columna cambiado 1", {"id", "Cod_Transp", "Razon_Soc", "Inhabilitado", "Fecha_Inhabilitacion", "Registro_Activo", "Segmento_Operativo"})
in
  #"Columnas reordenadas";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "br_documentacion_tms_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared br_documentacion_tms = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "br_documentacion_tms", ItemKind = "Table"]}[Data],
  #"Personalizado agregado" = Table.AddColumn(#"Navegación 2", "id", each [Entidad] & " - " & Text.From([Id_tabla])),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Personalizado agregado", {{"id", type text}}),
  #"Elegir columnas" = Table.SelectColumns(#"Tipo de columna cambiado", {"Entidad", "Descripcion_Documentacion", "Identificador", "Id_tabla", "Observaciones", "Fecha_Vto", "Obligatorio", "Tipo_Vehiculo", "id"}),
  #"Columnas reordenadas" = Table.ReorderColumns(#"Elegir columnas", {"id", "Entidad", "Id_tabla", "Descripcion_Documentacion", "Identificador", "Observaciones", "Fecha_Vto", "Obligatorio", "Tipo_Vehiculo"}),
  #"Consultas combinadas" = Table.NestedJoin(#"Columnas reordenadas", {"id"}, br_camiones_tms, {"id"}, "br_camiones_tms", JoinKind.LeftOuter),
  #"br_camiones_tms expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "br_camiones_tms", {"Cod_tipo_Vehiculo", "Suc"}, {"Cod_tipo_Vehiculo", "Suc"}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"br_camiones_tms expandido", {{"Obligatorio", "Obligatorio2"}}),
  #"Personalizado agregado 1" = Table.AddColumn(#"Columnas con nombre cambiado", "Obligatorio", each if [Descripcion_Documentacion] = "Ruta" then "FALSE"
else if 
[Descripcion_Documentacion] = "ART/AP" then "TRUE"
else if
[Descripcion_Documentacion] = "Certificado Satelital " and [Suc] <> null
and not List.Contains({"AMN", "BNZ", "CAP", "FAR", "USALUD", "HUD", "LLO", "LLS", "LLB", "LLC", "OE2", "TRONCALES", "TRA", "CTC", "TRAFICO", "TRON"}, [Suc]) then "FALSE"
else if [Descripcion_Documentacion] =
"Form 005 (DDJJ)" then "TRUE"
else [Obligatorio2]),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Personalizado agregado 1", {{"Obligatorio", type text}}),
  #"Columnas reordenadas 1" = Table.ReorderColumns(#"Tipo de columna cambiado 1", {"id", "Entidad", "Id_tabla", "Descripcion_Documentacion", "Identificador", "Observaciones", "Fecha_Vto", "Obligatorio2", "Obligatorio", "Tipo_Vehiculo", "Cod_tipo_Vehiculo", "Suc"}),
  #"Elegir columnas 1" = Table.SelectColumns(#"Columnas reordenadas 1", {"id", "Entidad", "Id_tabla", "Descripcion_Documentacion", "Identificador", "Observaciones", "Fecha_Vto", "Obligatorio", "Tipo_Vehiculo", "Cod_tipo_Vehiculo", "Suc"})
in
  #"Elegir columnas 1";
shared br_documentacion_tms_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  TableNavigation = Navigation_2{[Id = "sl_documentacion_tms", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared br_tansportistas_tms_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  TableNavigation = Navigation_2{[Id = "sl_tansportistas_tms", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared br_semirremolques_tms_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  TableNavigation = Navigation_2{[Id = "sl_semirremolques_tms", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared #"Sucursales Corregidas" = let
  Origen = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("fZZRT+MwDMe/SsTTkICT7j6Bl2ZdRpr0knaCIR64iQckDiRA9/nPdlLmbIUXr7+/nSy1naR3d2e/IJ5dsL2/YJIIToPXBpXpSahKN0Fdqmi3X/svXdwce5/3Dy/7R9VDVJfLcDL44P7GG1P44k+HaHBROnTf+WfcnScFLZFawhqRLOExRaY4EQi86VXtzwI0JoZa1ZhqO4TTcOE4HrbUvBCdF5JGTUHWBb02Ql/6HRFaJk4iWSLK+uLP679zoWnokchmGpiGiaCDqEFqDVMTCoWaMP2Wq/6prS0R2mnV+Ly1TodboeeakM3kmfxhTPA6xMaC0FFgimWtOXHaG6fSCNFQHnQasxd/D9SORi10DIfQc+GNo2kgnc6x4lqtSjUSuLERvOLVrMpqgGvVlpq0NfWUEbKF1E0vBHrdNoJTvdVhRr86drQjZYVseTem3Nkt17MdhynyGCPk9jlodcSgFqIrP0dgmV3fn4tQRBTnpiTPj1kPas6guWXttmiS1pxjsjyTWwrajNRnZDN5Jj+RleyYyBbSwVWKo/4jmykwhc/E14pziSllSpJy9IkSWpsGq0E5bH7wgO0V5RyOWgAzNVGFFfF0gEdk14MMAjyMw4almFOSj9+JyriTIKxOBxorwynCR5bpV1BDM5HN1DP1hWiTdLvcfp3xTdiBVCoSzXQa6g3tUrLTgvH592i8UMerDrtJTFMPCuYnEtly4CH105bFCfEZsz8rqnUSem9oz5LNxBMZMcbEFjrrg9D7wDOEXNMIKySyTIYSSjZTYiqRLe0KspkCU+61fMOSZeJ/oAuwEN4AQSpJUooVgUMim8kPFtqgGjwETRryXZOavAb6FWQaQZj7/cPb29PHK274o8AV06pQW03p6dgjy7ShqpEti1FutPRuyRXJjZIwADMJhl8hQnk9EDQ01CZkmdg3TD4cmw/Ng2KY8treH/8+vauPt9eX/cPz4zt78MbB0ymV6DCn+VlRc55nda76kWekviBLtOX7dFvuTjy91GJrGjpn8SdHcC0E8Z34yZZei+zUpzv60iILA7l2pb13vDMmSrz3p9rgh5BaXJvrQP87fRXp0wuxri9/XOBXhfy4SAOouiXoLq++GUgRu+H+Pw==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [Observaciones = _t, Sucursal = _t])
in
  Origen;
shared br_camiones_tms_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  TableNavigation = Navigation_2{[Id = "sl_camiones_tms", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared br_choferes_tms_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  TableNavigation = Navigation_2{[Id = "sl_choferes_tms", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
