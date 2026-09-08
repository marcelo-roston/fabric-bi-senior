[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "sl_pnr_carritos_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared sl_pnr_carritos = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "sl_pnr_carritos", ItemKind = "Table"]}[Data],
  #"Consultas combinadas" = Table.NestedJoin(#"Navegación 2", {"ESTACION DE ORIGEN"}, br_sucursales_carritos, {"SVC"}, "br_sucursales_carritos", JoinKind.LeftOuter),
  #"br_sucursales_carritos expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "br_sucursales_carritos", {"SUCURSAL"}, {"SUCURSAL"}),
  #"Consultas combinadas 1" = Table.NestedJoin(#"br_sucursales_carritos expandido", {"ID DEL CONDUCTOR"}, br_meli_reporte_operaciones, {"Id del transportista"}, "br_meli_reporte_operaciones", JoinKind.LeftOuter),
  #"br_meli_reporte_operaciones expandido" = Table.ExpandTableColumn(#"Consultas combinadas 1", "br_meli_reporte_operaciones", {"Nombre del transportista"}, {"Nombre del transportista"})
in
  #"br_meli_reporte_operaciones expandido";
shared br_meli_reporte_operaciones = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "br_meli_reporte_operaciones", ItemKind = "Table"]}[Data],
  #"Se han quitado otras columnas." = Table.SelectColumns(#"Navegación 2", {"Id del transportista", "Nombre del transportista"}),
  #"Duplicados quitados" = Table.Distinct(#"Se han quitado otras columnas.", {"Id del transportista", "Nombre del transportista"})
in
  #"Duplicados quitados";
shared br_sucursales_carritos = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "br_sucursales_carritos", ItemKind = "Table"]}[Data]
in
  #"Navegación 2";
shared sl_pnr_carritos_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "gd_pnr_carritos", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "sl_resolucion_problemas_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared sl_resolucion_problemas = let
  Origen = Lakehouse.Contents(null),
  #"Navegación 1" = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  #"Navegación 3" = #"Navegación 2"{[Id = "sl_pnr_soluciones_problemas", ItemKind = "Table"]}[Data],
  #"Filas filtradas" = Table.SelectRows(#"Navegación 3", each
    [Problema] = "Paquete dañado" and [Estado] = "Cerrado" and
    ([Origen del daño] = "Service Center" or ([Origen del daño] = "Linehaul XP" and [Service Center] = "SSR1"))),
  #"Consultas combinadas" = Table.NestedJoin(#"Filas filtradas", {"Service Center"}, SVC, {"SVC"}, "SVC", JoinKind.LeftOuter),
  #"SVC expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "SVC", {"SVP"}, {"SVP"}),
  #"Elegir columnas" = Table.SelectColumns(#"SVC expandido", {"ID", "ID de paquete", "Problema", "Estado", "Fecha de creación", "Fecha de cierre", "Service Center", "Resolución", "Estado de resolución", "Fecha de análisis", "Tiempo de resolución en minutos", "Origen del daño", "Motivo", "Tipo de daño", "SVP"})
in
  #"Elegir columnas";
shared SVC = let
  Origen = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("i45WCvbyM1TSUQoOC1DwCvXz9FOK1QEK+gUaQQX9XEMDQ12hwk6hZlBhHx9/iFBwEEx7sKNfiKNCkH+wo1JsLAA=", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [SVC = _t, SVP = _t])
in
  Origen;
shared sl_resolucion_problemas_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "gd_resolucion_problemas", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
