[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "sl_meli_reporte_operaciones_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared sl_meli_reporte_operaciones = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "sl_meli_reporte_operaciones", ItemKind = "Table"]}[Data],

  #"Consultas combinadas Zona Max" = Table.NestedJoin(#"Navegación 2", {"SUCURSAL"}, br_tarifario_carritos_zonamax, {"Sucursal"}, "ZonaMax", JoinKind.LeftOuter),
  #"Zona Max expandido" = Table.ExpandTableColumn(#"Consultas combinadas Zona Max", "ZonaMax", {"ZonaMax"}, {"ZonaMax"}),
  #"Zona Aplicada" = Table.AddColumn(#"Zona Max expandido", "Zona Aplicada", each if [ZonaMax] <> null and [Zona] > [ZonaMax] then [ZonaMax] else [Zona]),

  #"Consultas combinadas" = Table.NestedJoin(#"Zona Aplicada", {"SUCURSAL"}, br_tarifario_carritos, {"Sucursal"}, "br_tarifario_carritos", JoinKind.LeftOuter),
  #"br_tarifario_carritos expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "br_tarifario_carritos", {"Zona", "CORTA", "Vigencia", "Fin", "LARGA", "MOTO", "Auto", "Turno Despacho", "Chasis 8 Pos_", "Chasis 10 Pos_"}, {"Zona.1", "CORTA", "Vigencia", "Fin", "LARGA", "MOTO", "Auto", "Turno Despacho", "Chasis 8 Pos_", "Chasis 10 Pos_"}),
  #"Personalizado agregado" = Table.AddColumn(#"br_tarifario_carritos expandido", "ValidaZona", each [Zona.1] = [Zona Aplicada] or [Zona.1] = 0),
  #"Filas filtradas" = Table.SelectRows(#"Personalizado agregado", each ([ValidaZona] = true)),
  #"Personalizado agregado 1" = Table.AddColumn(#"Filas filtradas", "ValidaFecha", each [Fecha] >= [Vigencia] and
([Fin] = null or [Fecha] <= [Fin])),
  #"Filas filtradas 1" = Table.SelectRows(#"Personalizado agregado 1", each ([ValidaFecha] = true)),
  #"Personalizado agregado 2" = Table.AddColumn(#"Filas filtradas 1", "ValidaTurno", each [Turno Despacho] = null or [Turno Despacho] = [TURNO_DESPACHO]),
  #"Filas filtradas 2" = Table.SelectRows(#"Personalizado agregado 2", each ([ValidaTurno] = true)),
  #"Personalizado agregado 4" = Table.AddColumn(#"Filas filtradas 2", "Baja Performance", each if [No visitado] = null then 0 else
if [No visitado] > 10 then 1 else 0),
  #"Tipo de columna cambiado 2" = Table.TransformColumnTypes(#"Personalizado agregado 4", {{"Baja Performance", Int64.Type}}),
  #"Personalizado agregado 3" = Table.AddColumn(#"Tipo de columna cambiado 2", "Pagable", 
  each if [AMBULANCIA] = "AMBULANCIA" then if [Fecha] >= #date(2026, 7, 1) then "AMBULANCIA" else "NO"
else if [Baja Performance] = 1 then "NO" else "SI"),
  #"Filas ordenadas" = Table.Sort(#"Personalizado agregado 3", {{"AMBULANCIA", Order.Ascending}}),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Filas ordenadas", {{"Pagable", type text}}),
#"Columna condicional insertada" =
    Table.AddColumn(
        #"Tipo de columna cambiado 1",
        "Valida_Tarifa",
        each
            if [Pagable] = "NO" then 0

            else if [descripcion] = null then [CORTA]

            else if [descripcion] = "MOTO" then
                if [MOTO] = null then [CORTA] else [MOTO]

            else if [descripcion] = "CHASIS 6/8 PALLETS" then
                if [Chasis 8 Pos_] = null then [CORTA] else [Chasis 8 Pos_]

            else if [descripcion] = "CHASIS 10/12 PALLETS" then
                if [Chasis 10 Pos_] = null then [CORTA] else [Chasis 10 Pos_]

            else if [descripcion] = "CAMIONETA GRANDE" then
                if [LARGA] = null then [CORTA] else [LARGA]

            else if [descripcion] = "IDEM CHASIS CON PALA" then
                if [Chasis 8 Pos_] = null then [CORTA] else [Chasis 8 Pos_]

            else if [descripcion] = "AUTO" then
                if [Auto] = null then [CORTA] else [Auto]

            else [CORTA]
    ),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Columna condicional insertada", {{"Valida_Tarifa", type number}}),
  #"Elegir columnas" = Table.SelectColumns(#"Tipo de columna cambiado", {"Fecha", "Id de la ruta", "Nombre del transportista", "Vehículo", "Patente", "Kilómetros recorridos", "Ciclo", "Envíos despachados", "Envíos entregados", "Entrega exitosa", "No visitado", "TURNO_DESPACHO", "AMBULANCIA", "SUCURSAL", "Zona", "empresa", "legajo", "Baja Performance", "Pagable", "Valida_Tarifa"}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Elegir columnas", {{"Nombre del transportista", "Chofer"}, {"TURNO_DESPACHO", "Turno"}, {"SUCURSAL", "Sucursal"}, {"empresa", "Empresa"}, {"Valida_Tarifa", "Importe3"}, {"Envíos despachados", "PQ"}, {"Envíos entregados", "Entregas"}}),
  #"Personalizado agregado 7" = Table.AddColumn(#"Columnas con nombre cambiado", "Importe2", each if [Pagable] <> "AMBULANCIA" then [Importe3] else
if [No visitado] <= 10 then [Importe3]
else if [No visitado] <= 20 then [Importe3] * 0.5 else 0),
  #"Tipo de columna cambiado 5" = Table.TransformColumnTypes(#"Personalizado agregado 7", {{"Importe2", type number}}),
  #"Personalizado agregado 5" = Table.AddColumn(#"Tipo de columna cambiado 5", "No Visitados", each Number.Round([No visitado] * [PQ] / 100)),
  #"Tipo de columna cambiado 3" = Table.TransformColumnTypes(#"Personalizado agregado 5", {{"No Visitados", Int64.Type}}),
  #"Elegir columnas 1" = Table.SelectColumns(#"Tipo de columna cambiado 3", {"Fecha", "Id de la ruta", "Chofer", "Vehículo", "Patente", "Kilómetros recorridos", "Ciclo", "PQ", "Entregas", "Sucursal", "Zona", "Empresa", "AMBULANCIA", "Turno", "legajo", "Baja Performance", "Pagable", "Importe2", "No Visitados"}),
  #"Columnas reordenadas" = Table.ReorderColumns(#"Elegir columnas 1", {"Fecha", "Id de la ruta", "Chofer", "Vehículo", "Patente", "Kilómetros recorridos", "Ciclo", "PQ", "Entregas", "No Visitados", "Sucursal", "Zona", "Empresa", "AMBULANCIA", "Turno", "Baja Performance", "Pagable", "Importe2"}),
  #"Duplicados quitados" = Table.Distinct(#"Columnas reordenadas", {"Id de la ruta", "Chofer", "Entregas"}),
  #"Personalizado agregado 6" = Table.AddColumn(#"Duplicados quitados", "Importe", each if [Empresa] = "EMPLEADO" then [Importe2] * 0.53 else [Importe2]),
  #"Tipo de columna cambiado 4" = Table.TransformColumnTypes(#"Personalizado agregado 6", {{"Importe", type number}}),
  #"Elegir columnas 2" = Table.SelectColumns(#"Tipo de columna cambiado 4", {"Fecha", "Id de la ruta", "Chofer", "Vehículo", "Patente", "Kilómetros recorridos", "Ciclo", "PQ", "Entregas", "No Visitados", "Sucursal", "Zona", "Empresa", "AMBULANCIA", "legajo", "Turno", "Baja Performance", "Pagable", "Importe"})
in
  #"Elegir columnas 2";
shared br_tarifario_carritos = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "br_tarifario_carritos", ItemKind = "Table"]}[Data],
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Navegación 2", {{"Zona", Int64.Type}}),
  #"Columna duplicada" = Table.DuplicateColumn(#"Tipo de columna cambiado", "Sucursal", "Sucursal - Copia"),
  #"Columnas con nombre cambiado 1" = Table.RenameColumns(#"Columna duplicada", {{"Sucursal - Copia", "Turno Despacho"}}),
  #"Texto entre delimitadores extraído" = Table.TransformColumns(#"Columnas con nombre cambiado 1", {{"Turno Despacho", each Text.BetweenDelimiters(_, "(", ")", 0, 0), type text}}),
  #"Texto recortado" = Table.TransformColumns(#"Texto entre delimitadores extraído", {{"Turno Despacho", each Text.Trim(_), type text}}),
  #"Valor reemplazado" = Table.ReplaceValue(#"Texto recortado", "", null, Replacer.ReplaceValue, {"Turno Despacho"}),
  #"Texto recortado 1" = Table.TransformColumns(#"Valor reemplazado", {{"Sucursal", each Text.Trim(_), type nullable text}}),
  #"Primeros caracteres extraídos" = Table.TransformColumns(#"Texto recortado 1", {{"Sucursal", each Text.Start(_, 3), type text}}),
  #"Filas ordenadas" = Table.Sort(#"Primeros caracteres extraídos", {{"Vigencia", Order.Descending}})
in
  #"Filas ordenadas";
shared sl_meli_reporte_operaciones_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "gd_carritos_liquidacion", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared br_tarifario_carritos_zonamax = let
    Origen = br_tarifario_carritos,
    #"Filas filtradas" = Table.SelectRows(Origen, each [Zona] > 0),
    #"Agrupado" =
        Table.Group(
            #"Filas filtradas",
            {"Sucursal","Vigencia","Fin"},
            {{"ZonaMax", each List.Max([Zona]), Int64.Type}}
        ),
  #"Filas ordenadas" = Table.Sort(Agrupado, {{"Vigencia", Order.Descending}})
in
    #"Filas ordenadas";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "br_pnu_carritos_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared br_pnu_carritos = let
    Origen = Lakehouse.Contents(null),
    Navegación = Origen{[workspaceId="c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
    #"Navegación 1" = Navegación{[lakehouseId="5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
    #"Navegación 2" = #"Navegación 1"{[Id="br_pnu_carritos", ItemKind="Table"]}[Data],
    #"Elegir columnas" = Table.SelectColumns(#"Navegación 2", {"Fecha","Excepción","Patente","Tipo de unidad","SVC/XP","Motivos","Comentarios adicionales","Aprobado"}),
    #"Texto en minúsculas" = Table.TransformColumns(#"Elegir columnas", {{"Tipo de unidad", each Text.Lower(_), type nullable text}}),
    #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Texto en minúsculas", {{"Fecha", type date}}),
  #"Errores reemplazados" = Table.ReplaceErrorValues(#"Tipo de columna cambiado", {{"Fecha", null}}),
    #"Consultas combinadas" = Table.NestedJoin(#"Errores reemplazados", {"Patente"}, sl_meli_reporte_operaciones, {"Patente"}, "Operacion", JoinKind.LeftOuter),
    #"Operacion expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "Operacion", {"Chofer","Sucursal","Empresa","legajo"}, {"Chofer","Sucursal","Empresa","legajo"}),
    #"Tarifario combinado" = Table.NestedJoin(#"Operacion expandido", {"Sucursal"}, br_tarifario_carritos, {"Sucursal"}, "Tarifario", JoinKind.LeftOuter),
    #"Tarifario expandido" = Table.ExpandTableColumn(#"Tarifario combinado", "Tarifario", {"Zona","Vigencia","Fin","CORTA"}, {"ZonaTarifa","Vigencia","Fin","CORTA"}),
    #"ValidaFecha" = Table.AddColumn(#"Tarifario expandido", "ValidaFecha", each [Fecha] >= [Vigencia] and ([Fin] = null or [Fecha] <= [Fin]), type logical),
    #"Filtra vigencia" = Table.SelectRows(#"ValidaFecha", each [ValidaFecha]),
    #"Agrupa zonas" = Table.Group(#"Filtra vigencia", {"Sucursal"}, {{"ZonaMax", each List.Max(List.RemoveNulls([ZonaTarifa])), type nullable number}}),
    #"Cruza zonas" = Table.NestedJoin(#"Filtra vigencia", {"Sucursal"}, #"Agrupa zonas", {"Sucursal"}, "ZonaInfo", JoinKind.LeftOuter),
    #"Expande zonas" = Table.ExpandTableColumn(#"Cruza zonas", "ZonaInfo", {"ZonaMax"}, {"ZonaMax"}),
    #"Zona objetivo" = Table.AddColumn(#"Expande zonas", "ZonaObjetivo", each if [ZonaMax] <> null and [ZonaMax] > 0 then 1 else 0, Int64.Type),
    #"Filtra zona" = Table.SelectRows(#"Zona objetivo", each [ZonaTarifa] = [ZonaObjetivo]),
    #"Quita duplicados" = Table.Distinct(#"Filtra zona", {"Fecha","Patente","Sucursal"}),
    #"Importe PNU" = Table.AddColumn(#"Quita duplicados", "Importe", each [CORTA] * 0.4, type number),
  #"Elegir columnas 1" = Table.SelectColumns(#"Importe PNU", {"Fecha", "Excepción", "Patente", "Tipo de unidad", "SVC/XP", "Motivos", "Comentarios adicionales", "Aprobado", "Chofer", "Sucursal", "Empresa", "legajo", "Importe"}),
  #"Personalizado agregado" = Table.AddColumn(#"Elegir columnas 1", "AñoMes", each Text.From(Date.Year([Fecha])) & Text.PadStart(Text.From(Date.Month([Fecha])), 2, "0")),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Personalizado agregado", {{"AñoMes", type text}})
in
    #"Tipo de columna cambiado 1";
shared br_pnu_carritos_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "gd_pnu_carritos", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "br_reconocimiento_pnu_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared br_reconocimiento_pnu = let
    Origen = Lakehouse.Contents(null),
    Navegación = Origen{[workspaceId="c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
    #"Navegación 1" = Navegación{[lakehouseId="5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
    #"Navegación 2" = #"Navegación 1"{[Id="br_reconocimiento_pnu", ItemKind="Table"]}[Data],
  #"Filas filtradas" = Table.SelectRows(#"Navegación 2", each ([CONCEPTO BILLING] = "unused_vehicles (+)")),
  #"Elegir columnas" = Table.SelectColumns(#"Filas filtradas", {"PERIODO", "ENTITY ID _shipment_ route etc_", "TOTAL A PAGAR", "VEHICULO", "Sucursal", "SVC"}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Elegir columnas", {{"ENTITY ID _shipment_ route etc_", "Q PNU"}}),
  #"Primeros caracteres insertados" = Table.AddColumn(#"Columnas con nombre cambiado", "Año", each Text.Start([PERIODO], 4), type text),
  #"Rango de texto insertado" = Table.AddColumn(#"Primeros caracteres insertados", "Mes", each Text.Middle([PERIODO], 4, 2), type text),
  #"Personalizado agregado" = Table.AddColumn(#"Rango de texto insertado", "AñoMes", each [Año] & [Mes]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Personalizado agregado", {{"AñoMes", type text}})
in
    #"Tipo de columna cambiado";
shared br_reconocimiento_pnu_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = true, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  Navigation_3 = Navigation_2{[Id = "dbo", ItemKind = "Schema"]}[Data],
  TableNavigation = Navigation_3{[Id = "gd_reconocimiento_pnu", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
