[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "detalle_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared detalle = let
  Origen = Odbc.Query("dsn=Informix_REP;Database=Estadistica", "select #(lf)*#(lf)from liq_fletero_detalle where fecha_caratula >= '01-01-2026'")
in
  Origen;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "cabecera_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared cabecera = let
  Origen = Odbc.Query("dsn=Informix_REP;Database=Estadistica", "select #(lf)*#(lf)from liq_fletero_cabecera where fecha_caratula >= '01-01-2026'")
in
  Origen;
shared detalle_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "br_liq_fletero_detalle", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared cabecera_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "br_liq_fletero_cabecera", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
