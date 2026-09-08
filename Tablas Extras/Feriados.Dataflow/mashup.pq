[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Consulta_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Feriados = let
  Origen = Odbc.Query("dsn=Informix_REP;Database=maestra", "select fecha from feriados where year(fecha) > 2024")
in
  Origen;
shared Consulta_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "gd_feriados", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Sucursales_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Sucursales = let
  Origen = Odbc.Query("dsn=Informix_REP;Database=maestra", "select id_ciudad, prov_codigo, usa_sugu#(lf)from sucursal"),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(Origen, {{"id_ciudad", Int64.Type}})
in
  #"Tipo de columna cambiado";
shared Sucursales_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null, PreserveOrder = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "gd_sucursales_maestra", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
