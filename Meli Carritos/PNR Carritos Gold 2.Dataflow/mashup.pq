[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "gd_pnr_carritos_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared gd_pnr_carritos = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "gd_pnr_carritos", ItemKind = "Table"]}[Data],
  #"Consultas combinadas" = Table.NestedJoin(#"Navegación 2", {"ESTADO"}, #"orden de estados", {"ESTADO"}, "orden de estados", JoinKind.LeftOuter),
  #"orden de estados expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "orden de estados", {"ORDEN"}, {"ORDEN"}),
  #"Consultas combinadas 1" = Table.NestedJoin(#"orden de estados expandido", {"ID DEL CASO", "ORDEN"}, #"gd_pnr_carritos orden", {"ID DEL CASO", "Orden"}, "gd_pnr_carritos orden", JoinKind.Inner),
  #"gd_pnr_carritos orden expandido" = Table.ExpandTableColumn(#"Consultas combinadas 1", "gd_pnr_carritos orden", {}, {})
in
  #"gd_pnr_carritos orden expandido";
shared #"orden de estados" = let
  Origen = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("Tc0xDsIwDAXQq1iZuxS4AKrYEYxRB5MYZKk4kdP0/IS6Ujv6P/vbe3eVOmFMrnMXN3be3WThNgPCG8NcFQMn2bVkUpTmIX2zphfKTE37Ve8kkaklEAmUFi52e1p12C8goH7sq9mT5dh4cGt+bGVAba9q+ct5axXIJDhxxGjp+AM=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [ESTADO = _t, ORDEN = _t]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(Origen, {{"ESTADO", type text}, {"ORDEN", Int64.Type}}, "es")
in
  #"Tipo de columna cambiado";
shared #"gd_pnr_carritos orden" = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "gd_pnr_carritos", ItemKind = "Table"]}[Data],
  #"Consultas combinadas" = Table.NestedJoin(#"Navegación 2", {"ESTADO"}, #"orden de estados", {"ESTADO"}, "orden de estados", JoinKind.LeftOuter),
  #"orden de estados expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "orden de estados", {"ORDEN"}, {"ORDEN"}),
  #"Filas agrupadas" = Table.Group(#"orden de estados expandido", {"ID DEL CASO"}, {{"Orden", each List.Max([ORDEN]), type nullable Int64.Type}})
in
  #"Filas agrupadas";
shared gd_pnr_carritos_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "gd_pnr_carritos_final", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
