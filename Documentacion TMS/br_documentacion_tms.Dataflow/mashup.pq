[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Choferes_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Choferes = let
  Origen = Sql.Database("181.30.37.12,10340", "SGLBI_URBANO_PROD", [Query = "select * from SGL_Vista_Choferes"]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(Origen, {{"Fecha_Inhabilitacion", type date}, {"Fecha_Vto_Inhabilitacion", type date}})
in
  #"Tipo de columna cambiado";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Camiones_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Camiones = let
  Origen = Sql.Database("181.30.37.12,10340", "SGLBI_URBANO_PROD", [Query = "select * from SGL_Vista_Camiones"])
in
  Origen;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Semirremolques_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Semirremolques = let
  Origen = Sql.Database("181.30.37.12,10340", "SGLBI_URBANO_PROD", [Query = "select * from SGL_Vista_Semirremolques"])
in
  Origen;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Transportistas_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Transportistas = let
  Origen = Sql.Database("181.30.37.12,10340", "SGLBI_URBANO_PROD", [Query = "select * from SGL_Vista_Transportistas"])
in
  Origen;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Tipo_Vehiculos_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Tipo_Vehiculos = let
  Origen = Sql.Database("181.30.37.12,10340", "SGLBI_URBANO_PROD", [Query = "select distinct ""Cod_Tipo_Vehiculo"", ""Tipo_Vehiculo"" from SGL_SPDOCUMENTACION_RESULT where ""Cod_Tipo_Vehiculo"" is not null#(lf)#(lf)"])
in
  Origen;
shared Tipo_Vehiculos_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "TMS_Tipo_Vehiculos", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Documentacion_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Documentacion = let
  Origen = Sql.Database("181.30.37.12,10340", "SGLBI_URBANO_PROD", [Query = "select * from SGL_SPDOCUMENTACION_RESULT"]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(Origen, {{"Obligatorio", type text}}),
  #"Texto en mayúsculas" = Table.TransformColumns(#"Tipo de columna cambiado", {{"Obligatorio", each Text.Upper(_), type nullable text}}),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Texto en mayúsculas", {{"Fecha_Vto", type date}})
in
  #"Tipo de columna cambiado 1";
shared Documentacion_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  TableNavigation = Navigation_2{[Id = "br_documentacion_tms", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Choferes_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  TableNavigation = Navigation_2{[Id = "br_choferes_tms", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Camiones_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  TableNavigation = Navigation_2{[Id = "br_camiones_tms", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Semirremolques_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  TableNavigation = Navigation_2{[Id = "br_semirremolques_tms", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Transportistas_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  TableNavigation = Navigation_2{[Id = "br_tansportistas_tms", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
