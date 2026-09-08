[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "u3 caratulas_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"u3 caratulas" = let
  Origen = Odbc.Query("dsn=Informix_REP;Database=Estadistica", "select #(lf)ca.fecha_caratula as Fecha,#(lf)ca.prov_codigo as Sucursal, #(lf)le.legajo_nro as Legajo, #(lf)le.apellido_y_nombre as Chofer, #(lf)'URBANO' as Modalidad#(lf)#(lf)from urbano21:caratula ca#(lf)inner join rrhh:legajo le on ca.id_legajo_distribuidor = le.id_legajo#(lf)inner join urbano21:tipo_vehiculo tv#(lf)on ca.id_tipo_vehiculo = tv.id_tipo_vehiculo#(lf)where fecha_caratula >= today - 60#(lf)and le.empresa not in ('URBANO', 'GESTION', '', 'EMPLEADO', 'COLABORADOR', 'SUMINISTRA', 'GLD', 'MMG', 'A-TEMPO')"),
  #"Personalizado agregado" = Table.AddColumn(Origen, "ID", each [legajo] & "_" & Date.ToText([fecha], "yyyyMMdd") & "_" & [modalidad] & "_" & [sucursal]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Personalizado agregado", {{"ID", type text}})
in
  #"Tipo de columna cambiado";
shared #"u3 caratulas_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  TableNavigation = Navigation_2{[Id = "br_presentes_u3", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
