[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "dsn=Informix_REP;database=Estadistica_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared cabecera = let
  Origen = Odbc.Query("dsn=Informix_REP;Database=Estadistica", "select * from liq_fletero_cabecera")
in
  Origen;
shared #"dsn=Informix_REP;database=Estadistica_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  TableNavigation = Navigation_2{[Id = "br_liq_fleteros_cabecera", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "detalle_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared detalle = let
  Origen = Odbc.Query("dsn=Informix_REP;Database=Estadistica", "select * from liq_fletero_detalle")
in
  Origen;
shared detalle_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  TableNavigation = Navigation_2{[Id = "br_liq_fleteros_detalle", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
