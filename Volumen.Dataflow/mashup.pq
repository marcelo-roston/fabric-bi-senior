[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
shared #"sla logistica" = let
  Origen = Odbc.Query("dsn=Informix_REP;Database=Estadistica", "SELECT#(lf)    sla.shipper,#(lf)    sla.cp,#(lf)    bi.sucursal,#(lf)    sla.vto_sla_servicio,#(lf)    case when bi.peso_tomado = 0 then 1 else bi.peso_tomado end as peso,#(lf)    'Paquetería' as Descripcion#(lf)FROM estadistica:sla_logistica_servicio sla#(lf)LEFT JOIN estadistica:informes_test_bi bi ON bi.id_informes_test = sla.id_informes_test#(lf)LEFT JOIN estadistica:servicio_logistica_det det ON det.id_servicio = sla.servicio_urbano#(lf)WHERE sla.vl_fecha_ge <> '01011900'"),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(Origen, {{"cp", type text}})
in
  #"Tipo de columna cambiado";
shared #"sla postal" = let
  Origen = Odbc.Query("dsn=Informix_REP;Database=Estadistica", "SELECT #(lf)bi.id_shipper as shipper, #(lf)bi.cp, #(lf)bi.id_ciudad_destino, #(lf)bi.vto_sla_servicio, 1 as peso, #(lf)'Postal' as Descripcion#(lf)FROM estadistica:informes_postal_bi bi#(lf)WHERE bi.aud_fecha_proc >= '01122025';"),
  #"Consultas combinadas" = Table.NestedJoin(Origen, {"id_ciudad_destino"}, gd_sucursales_maestra, {"id_ciudad"}, "gd_sucursales_maestra", JoinKind.LeftOuter),
  #"gd_sucursales_maestra expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "gd_sucursales_maestra", {"prov_codigo"}, {"prov_codigo"}),
  #"Elegir columnas" = Table.SelectColumns(#"gd_sucursales_maestra expandido", {"shipper", "cp", "vto_sla_servicio", "peso", "descripcion", "prov_codigo"}),
  #"Columnas reordenadas" = Table.ReorderColumns(#"Elegir columnas", {"shipper", "cp", "prov_codigo", "vto_sla_servicio", "peso", "descripcion"}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Columnas reordenadas", {{"prov_codigo", "sucursal"}}),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Columnas con nombre cambiado", {{"peso", type number}})
in
  #"Tipo de columna cambiado 1";
shared gd_sucursales_maestra = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "gd_sucursales_maestra", ItemKind = "Table"]}[Data]
in
  #"Navegación 2";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Anexar_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Anexar = let
  Origen = Table.Combine({#"sla logistica", #"sla postal"})
in
  Origen;
shared Anexar_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null, PreserveOrder = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "gd_volumen_sla", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
