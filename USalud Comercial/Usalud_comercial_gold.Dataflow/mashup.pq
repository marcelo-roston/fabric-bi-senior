[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "barras_usalud_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared barras_usalud = let
  Origen = Lakehouse.Contents([HierarchicalNavigation = null]),
  #"Navegación 1" = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  #"Navegación 3" = #"Navegación 2"{[Id = "U3_tablero_usalud_barras", ItemKind = "Table"]}[Data],

  #"Consultas combinadas" = Table.NestedJoin(#"Navegación 3", {"gui_numero"}, U3_tablero_usalud_DL, {"gui_numero"}, "U3_tablero_usalud_DL", JoinKind.LeftOuter),
  #"U3_tablero_usalud_DL expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "U3_tablero_usalud_DL", {"chk_fecha"}, {"chk_fecha"}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"U3_tablero_usalud_DL expandido", {{"chk_fecha", "Fecha DL"}}),

  #"Consultas combinadas 1" = Table.NestedJoin(#"Columnas con nombre cambiado", {"gui_numero"}, U3_tablero_usalud_RC, {"gui_numero"}, "U3_tablero_usalud_RC", JoinKind.LeftOuter),
  #"U3_tablero_usalud_RC expandido" = Table.ExpandTableColumn(#"Consultas combinadas 1", "U3_tablero_usalud_RC", {"fecha_rc", "fecha_as", "fecha_dv"}, {"fecha_rc", "fecha_as", "fecha_dv"}),
  #"Columnas con nombre cambiado 1" = Table.RenameColumns(#"U3_tablero_usalud_RC expandido", {{"fecha_rc", "Fecha RC"}, {"fecha_as", "Fecha AS"}, {"fecha_dv", "Fecha DV"}}),

  #"Columna condicional insertada" =
    Table.AddColumn(
      #"Columnas con nombre cambiado 1",
      "Fecha 1° Visita",
      each if [primer_visita] = null or [primer_visita] = #date(1900, 1, 1) then [Fecha DL] else [primer_visita],
      type date
    ),

  #"SLA primer visita" =
      Table.AddColumn(
          #"Columna condicional insertada",
          "SLA Salud 1° Visita",
          each 
              let 
                  fecha_base =
                      if [chk_primer_visita] = "NT" or [chk_primer_visita] = "ST"
                      then [Fecha DL]
                      else [#"Fecha 1° Visita"],
                  d = if fecha_base <> null and [vl_fecha_ge] <> null
                      then Duration.TotalDays(fecha_base - [vl_fecha_ge])
                      else null
              in
                  if d <> null and d >= 0 then d else null,
          Int64.Type
      ),

  /* ===== PI a AS (con calendario acumulado) ===== */
  #"Join Cal PI" = Table.NestedJoin(#"SLA primer visita", {"fecha_pi"}, Calendario, {"Fecha"}, "Cal_PI", JoinKind.LeftOuter),
  #"Cal PI exp" = Table.ExpandTableColumn(#"Join Cal PI", "Cal_PI", {"Habil_Acum"}, {"_HPI"}),

  #"Join Cal AS" = Table.NestedJoin(#"Cal PI exp", {"Fecha AS"}, Calendario, {"Fecha"}, "Cal_AS", JoinKind.LeftOuter),
  #"Cal AS exp" = Table.ExpandTableColumn(#"Join Cal AS", "Cal_AS", {"Habil_Acum"}, {"_HAS"}),

  #"PI a AS" =
    Table.AddColumn(
      #"Cal AS exp",
      "Días de PI a AS",
      each if [_HPI] <> null and [_HAS] <> null then
            let d = [_HAS] - [_HPI]
            in if d >= 0 then d else null
           else null,
      Int64.Type
    ),

  #"Personalizado agregado" =
    Table.AddColumn(
      #"PI a AS",
      "SLA Salud Entrega",
      each if [Fecha DL] = null or [vl_fecha_ge] = null then null
           else let d = Duration.TotalDays([Fecha DL] - [vl_fecha_ge])
                in if d < 0 then 0 else d,
      Int64.Type
    ),

  #"Columna combinada insertada" = Table.AddColumn(#"Personalizado agregado", "id barra", each Text.Combine({Text.From([shipper]), [cli_codigo]}, "-"), type text),
  #"Duplicados quitados" = Table.Distinct(#"Columna combinada insertada", {"id barra"}),
  #"Columnas con nombre cambiado 2" = Table.RenameColumns(#"Duplicados quitados", {{"vl_fecha_ge", "Fecha GE"}, {"sucursal", "Sucursal"}, {"cli_codigo", "Cli Código"}}),

  /* ===== Última Milla (con calendario acumulado) ===== */
  #"Join Cal AS LM" = Table.NestedJoin(#"Columnas con nombre cambiado 2", {"Fecha AS"}, Calendario, {"Fecha"}, "Cal_AS_LM", JoinKind.LeftOuter),
  #"Cal AS LM exp" = Table.ExpandTableColumn(#"Join Cal AS LM", "Cal_AS_LM", {"Habil_Acum"}, {"_HAS_LM"}),

  #"Join Cal DL LM" = Table.NestedJoin(#"Cal AS LM exp", {"Fecha DL"}, Calendario, {"Fecha"}, "Cal_DL_LM", JoinKind.LeftOuter),
  #"Cal DL LM exp" = Table.ExpandTableColumn(#"Join Cal DL LM", "Cal_DL_LM", {"Habil_Acum"}, {"_HDL_LM"}),

  #"Tiempo LM (Última Milla)" =
    Table.AddColumn(
      #"Cal DL LM exp",
      "Tiempo LM (Última Milla)",
      each if [_HAS_LM] <> null and [_HDL_LM] <> null then
            let d = [_HDL_LM] - [_HAS_LM]
            in if d >= 0 then d else null
           else null,
      Int64.Type
    ),

  /* ===== limpieza de columnas técnicas ===== */
  #"Columnas técnicas quitadas" =
    Table.RemoveColumns(
      #"Tiempo LM (Última Milla)",
      {"_HPI", "_HAS", "_HAS_LM", "_HDL_LM"}
    ),
  #"Personalizado agregado 1" = Table.AddColumn(#"Columnas técnicas quitadas", "Cumplimiento SLA Entrega", each if [sla] = null then "CP sin SLA" else if [Fecha DL] <> null and [SLA Salud Entrega] <= [sla]
then "CUMPLE SLA ENTREGA" else "NO CUMPLE SLA ENTREGA"),
  #"Personalizado agregado 2" = Table.AddColumn(#"Personalizado agregado 1", "Cumplimiento SLA 1° Visita", each if [sla] = null then "CP sin SLA" else if [#"SLA Salud 1° Visita"] <> null and [#"SLA Salud 1° Visita"] <= [sla]
then "CUMPLE SLA 1° VISITA" else "NO CUMPLE SLA 1° VISITA"),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Personalizado agregado 2", {{"Cumplimiento SLA Entrega", type text}, {"Cumplimiento SLA 1° Visita", type text}})

in
  #"Tipo de columna cambiado";
shared U3_tablero_usalud_DL = let
  Origen = Lakehouse.Contents([HierarchicalNavigation = null]),
  #"Navegación 1" = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  #"Navegación 3" = #"Navegación 2"{[Id = "U3_tablero_usalud_DL", ItemKind = "Table"]}[Data]
in
  #"Navegación 3";
shared U3_tablero_usalud_RC = let
  Origen = Lakehouse.Contents([HierarchicalNavigation = null]),
  #"Navegación 1" = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  #"Navegación 3" = #"Navegación 2"{[Id = "U3_tablero_usalud_RC", ItemKind = "Table"]}[Data]
in
  #"Navegación 3";
shared U3_tablero_usalud_shippers = let
  Origen = Lakehouse.Contents([HierarchicalNavigation = null]),
  #"Navegación 1" = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  #"Navegación 3" = #"Navegación 2"{[Id = "U3_tablero_usalud_shippers", ItemKind = "Table"]}[Data]
in
  #"Navegación 3";
shared U3_tablero_usalud_shippers_rend_fisica = let
  Origen = Lakehouse.Contents([HierarchicalNavigation = null]),
  #"Navegación 1" = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  #"Navegación 3" = #"Navegación 2"{[Id = "U3_tablero_usalud_shippers_rend_fisica", ItemKind = "Table"]}[Data]
in
  #"Navegación 3";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "SHIPPER_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared SHIPPER = let
  Origen = Lakehouse.Contents([HierarchicalNavigation = null]),
  #"Navegación 1" = Origen{[workspaceId = "5134ca31-6307-4e20-bd74-ad80ca764046"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[lakehouseId = "049ecaa5-eaaf-4849-a618-a273849a7de9"]}[Data],
  #"Navegación 3" = #"Navegación 2"{[Id = "SHIPPER", ItemKind = "Table"]}[Data],
  #"Elegir columnas" = Table.SelectColumns(#"Navegación 3", {"id_shipper", "shi_razon_social", "id_shipper_nombre"}),
  #"Consultas combinadas" = Table.NestedJoin(#"Elegir columnas", {"id_shipper"}, U3_tablero_usalud_shippers_rend_fisica, {"id_shipper"}, "U3_tablero_usalud_shippers_rend_fisica", JoinKind.LeftOuter),
  #"U3_tablero_usalud_shippers_rend_fisica expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "U3_tablero_usalud_shippers_rend_fisica", {"id_shipper"}, {"id_shipper.1"}),
  #"Valor reemplazado" = Table.ReplaceValue(#"U3_tablero_usalud_shippers_rend_fisica expandido", null, 0, Replacer.ReplaceValue, {"id_shipper.1"}),
  #"Columna condicional insertada" = Table.AddColumn(#"Valor reemplazado", "Rendición Física", each if [id_shipper.1] = 0 then "NO" else "SI"),
  #"Consultas combinadas 1" = Table.NestedJoin(#"Columna condicional insertada", {"id_shipper"}, Grupos, {"shipper"}, "Grupos", JoinKind.LeftOuter),
  #"Grupos expandido" = Table.ExpandTableColumn(#"Consultas combinadas 1", "Grupos", {"GRUPO"}, {"GRUPO"}),
  #"Valor reemplazado 1" = Table.ReplaceValue(#"Grupos expandido", null, "Sin Agrupar", Replacer.ReplaceValue, {"GRUPO"}),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Valor reemplazado 1", {{"Rendición Física", type text}}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"Tipo de columna cambiado", {{"shi_razon_social", "shi_representante"}})
in
  #"Columnas con nombre cambiado";
shared Grupos = let
  Origen = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("fZXBktsgDIZfhdnTdmabdYAm9lGxScKsA1mIM9vu7NP03ENfqX2xSsKOsePtSUF8vxCSTN7fH5QqyocnNuKraII/dCZYELCrRRcOxl0MbuPq4eOJ6SrR1R1t4gVcA2GCa8m4logTFAF/BOMaW1vvTMxgKRVlQgaZl9Y6W0Mr4gpW6N75k+0xrRjTao7huobGOBBSi2OcqDbfODiamYpF4QDi6tvuZJ2PkAtVIbd0BTQLx4ENorWvnW1yjV5LSpEMRfd7CCcQdQvR1h43es/A6sTqjB0rn7OqKFIuBeXSQLsDN9QnrRImtxSSzBTDVesPf3/++RUveIsorLuaECHO9KriY9BM9LjwZxOAOid2xpmrhZlys+aT0dydHE24UtOHu+EoXMFdpgH0Wqdq6DzAXNlFaLtmqpTbipRkeMIaezLhVpxAVXzuvX2qRcGpFsXI80gjKfpRvnymVTzWaLKzbuKxeUvaYstaNKjYmxM4K04IZLOevANeJrxcxseZb4zYB+unei25l2SQPODGxdTZKPaegS0TW2bseJucVbJQPGOFYjZeKKuU0eP5lQq4wnQFCGevphUO6tUXjpHIFESv+TVBkwd5FhbOPooz4Kj+hpZfianw24YnFA1XpRmmkr+V2nQ03uJxb3AN98eWKfeScz+a1tJhR/7w+g4kZ0+ns0o+q6d5AAW/FDkqNzxTaBA9wcH5gUxh2TU8pCo9pGoBpUulVo4KuSnTC1ZSd3Cc6pflARDfs54xN+irpK/u9fT+oQTL2E5Eai03lCYa5JzxCAng6NbdqpX8vYA/YJU+4F6wMKK5pJRrLrBcjxJ6wEOcglrqNJ+aKsANM29v9+kMO4OoSqLqcxHudLGeS1WVelRxj4JvfLv3wjQdhMbTRSIEk4Zg2ETnD3T2cpnk8v9yOvzWr6VAcrPlfzw09I7aA84ptE2w9ZEqend/JnplVbCyKm7KmXRhfMYQH/8A", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [shipper = _t, Shipper.1 = _t, GRUPO = _t]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(Origen, {{"shipper", Int64.Type}, {"Shipper.1", type text}, {"GRUPO", type text}}, "es")
in
  #"Tipo de columna cambiado";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Canalizadores_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Canalizadores = let
  Origen = Table.FromRows(Json.Document(Binary.Decompress(Binary.FromText("dZBNTsMwEEavMsqWBuHQ8rNMS8SmZVMiFlEXgz1KLZw4sh0Ex+EsXAzHCaRpxHbeZ883ryiiq2gRbYy2FoTmb7IuId2tU3hC1xqMDosiYr+JIRBn1mEt0IiAk3OcLOFoA7qev2yIS1SBLj3NLapWQG5Kqh2F8Woc+0XfX92mAG48eEFDR91aGpmvyqWuh09vT0PxRhuhX/sz7v4OzZWTFUIllcJ4uuPeh55JEdcVGOJtQ0b3EjpPe6wIBH72EzbpE6w9XLCeJTOr//RlnaPsg1PjWhTawn6bwqNBddnj1eyjtSxLMpC9e2NDt87MDqWCLTpZQ1qRkRzP9LGJGhgUj2UOPw==", BinaryEncoding.Base64), Compression.Deflate)), let _t = ((type nullable text) meta [Serialized.Text = true]) in type table [Servicio = _t, #"Descripcion Servicio" = _t]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(Origen, {{"Servicio", Int64.Type}, {"Descripcion Servicio", type text}}, "es")
in
  #"Tipo de columna cambiado";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Calendario_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Calendario = let
  Origen = Lakehouse.Contents([HierarchicalNavigation = null]),
  #"Navegación 1" = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  #"Navegación 3" = #"Navegación 2"{[Id = "U3_Calendario", ItemKind = "Table"]}[Data],
  #"Ordenado por Fecha" = Table.Sort(#"Navegación 3", {{"Fecha", Order.Ascending}}),
  #"Índice agregado" = Table.AddIndexColumn(#"Ordenado por Fecha", "Idx", 0, 1, Int64.Type),
  #"Hábil acumulado" = Table.AddColumn(#"Índice agregado", "Habil_Acum", each List.Sum(List.FirstN(#"Índice agregado"[Dia Habil], [Idx] + 1)), Int64.Type),
  #"Índice quitado" = Table.RemoveColumns(#"Hábil acumulado", {"Idx"})
in
  #"Índice quitado";
shared U3_sla_informe = let
  Origen = Lakehouse.Contents([HierarchicalNavigation = null]),
  #"Navegación 1" = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  #"Navegación 3" = #"Navegación 2"{[Id = "U3_sla_informe", ItemKind = "Table"]}[Data],
  #"Elegir columnas" = Table.SelectColumns(#"Navegación 3", {"servicio", "cp", "sla"}),
  #"Personalizado agregado" = Table.AddColumn(#"Elegir columnas", "id sla", each Text.From([servicio]) & " - " & Text.From([cp])),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Personalizado agregado", {{"id sla", type text}})
in
  #"Tipo de columna cambiado";
shared SHIPPER_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "shippers_usalud", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Canalizadores_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "canalizadores", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Calendario_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "calendario_usalud", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared barras_usalud_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "barras_usalud_comercial", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
