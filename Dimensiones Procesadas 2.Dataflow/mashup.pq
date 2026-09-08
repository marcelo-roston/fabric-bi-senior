[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Base Dimensiones_DataDestination", IsNewTarget = true], Settings = [Kind = "Manual", AllowCreation = true, ColumnSettings = [Mappings = {[SourceColumnName = "aud_fecha_proc", DestinationColumnName = "aud_fecha_proc"], [SourceColumnName = "id_shipper", DestinationColumnName = "id_shipper"], [SourceColumnName = "total_peso", DestinationColumnName = "total_peso"], [SourceColumnName = "peso_volumetrico_total", DestinationColumnName = "peso_volumetrico_total"], [SourceColumnName = "altura_total", DestinationColumnName = "altura_total"], [SourceColumnName = "largo_total", DestinationColumnName = "largo_total"], [SourceColumnName = "ancho_total", DestinationColumnName = "ancho_total"], [SourceColumnName = "equipo", DestinationColumnName = "equipo"], [SourceColumnName = "sucursal", DestinationColumnName = "sucursal"], [SourceColumnName = "codigo", DestinationColumnName = "codigo"]}], DynamicSchema = false, UpdateMethod = [Kind = "Replace"], TypeSettings = [Kind = "Table"]]]}]
shared #"Base Dimensiones" = let
  Fechas = ParametrosFechas,
  RangeStart = DateTime.From(Fechas{0}),
  RangeEnd   = DateTime.From(Fechas{1}),
  Origen = Odbc.Query("dsn=Informix_REP;Database=Estadistica", "#(lf)SELECT     t.aud_fecha_proc,     t.id_shipper,     t.peso_final_cubi  AS total_peso,     #(lf)t.aforado   AS peso_volumetrico_total,    #(lf) t.alto_cu     AS altura_total,     t.largo_cu   AS largo_total,     #(lf)t.ancho_cu  AS ancho_total, trim(t.equipo) as equipo, t.ciu_codigo as sucursal, t.codigo#(lf)FROM (     SELECT id_shipper, codigo, peso_final_cubi, aforado, alto_cu, largo_cu, ancho_cu, aud_fecha_proc, equipo, ciu_codigo    , codigo#(lf)FROM estadistica:informe_pesos_sorter     #(lf)WHERE aud_fecha_proc >= (TODAY - 365)       AND id_shipper NOT IN (3530, 5010)    #(lf)#(lf) UNION ALL    #(lf) SELECT id_shipper, codigo, peso_final_cubi, aforado, alto_cu, largo_cu, ancho_cu, aud_fecha_proc, equipo, ciu_codigo  , codigo   #(lf) FROM maestra:informe_pesos_cubiscan   #(lf)  WHERE aud_fecha_proc >= (TODAY - 365)    #(lf)#(lf) UNION ALL    #(lf) SELECT id_shipper, codigo, peso_final_cubi, aforado, alto_cu, largo_cu, ancho_cu, aud_fecha_proc, equipo, ciu_codigo   , codigo  #(lf) FROM estadistica:informe_pesos_sorter_bi    #(lf) WHERE aud_fecha_proc >= (TODAY - 365) ) t;#(lf) "),
  #"Duplicados quitados" = Table.Distinct(Origen, {"codigo", "sucursal"})
in
  #"Duplicados quitados";
shared ParametrosFechas = let

    Hoy = DateTime.LocalNow(),

    RangeStart = Date.AddDays(Date.From(Hoy), -365),

    RangeEnd   = Date.From(Hoy),

    ParamList  = { RangeStart, RangeEnd }

in

    ParamList;
shared #"Base Dimensiones_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  TableNavigation = Navigation_2{[Id = "U3_dimensiones_sorter_v2", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
