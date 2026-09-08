[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Cabecera_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Cabecera = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "vw_fletero_cabecera", ItemKind = "View"]}[Data],
  #"Filas filtradas" = Table.SelectRows(#"Navegación 2", each ([legajo_nro] <> "P20978")),
  #"Personalizado agregado" = Table.AddColumn(#"Filas filtradas", "ID Viaje", each [legajo_nro] & [prov_codigo] & Date.ToText([fecha_caratula], "yyyyMMdd")),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Personalizado agregado", {{"ID Viaje", type text}}),
  #"Valor reemplazado" = Table.ReplaceValue(#"Tipo de columna cambiado", "NO APLICA", "CAMIONETA CHICA", Replacer.ReplaceText, {"tipo_vehiculo"})
in

  #"Valor reemplazado";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Detalle_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Detalle = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "vw_fletero_detalle", ItemKind = "View"]}[Data],
  #"Filas filtradas" = Table.SelectRows(#"Navegación 2", each ([legajo_nro] <> "P20978")),
  #"Personalizado agregado" = Table.AddColumn(#"Filas filtradas", "ID Viaje", each [legajo_nro] & [prov_codigo] & Date.ToText([fecha_caratula], "yyyyMMdd")),
  #"Tipo de columna cambiado 1" = Table.TransformColumnTypes(#"Personalizado agregado", {{"ID Viaje", type text}}),

    #"Merge Cabecera" =
        Table.NestedJoin(#"Tipo de columna cambiado 1", {"ID Viaje"}, Cabecera, {"ID Viaje"}, "Cab", JoinKind.LeftOuter),

    #"Expand Cabecera" =
        Table.ExpandTableColumn(
            #"Merge Cabecera", "Cab",
            {"entregadas", "devueltas", "tot_zona", "tipo_vehiculo", "cal_min", "tot_liqui", "peaje", "tot_pagado", "tot_a_pagar", "productividad"},
            {"entregadas", "devueltas", "tot_zona", "tipo_vehiculo", "cal_min", "tot_liqui", "peaje", "tot_pagado", "tot_a_pagar", "productividad"}
        ),

    #"Zona FAR ajustada" =
        Table.AddColumn(
            #"Expand Cabecera",
            "zona_nueva",
            each if [prov_codigo] = "FAR" 
                    and ([chk_codigo] = "DL" or [chk_codigo] = "DV")
                then 1
                else [zona],
            type number
        ),

    #"Eliminar zona original" =
        Table.RemoveColumns(#"Zona FAR ajustada", {"zona"}),

    #"Renombrar zona" =
        Table.RenameColumns(#"Eliminar zona original", {{"zona_nueva", "zona"}}),

    #"Piezas" =
        Table.AddColumn(
            #"Renombrar zona", "Piezas",
            each (if [entregadas] = null then 0 else [entregadas]) +
                (if [devueltas] = null then 0 else [devueltas]),
            type number
        ),

    #"Merge Adicional Zona" =
    Table.NestedJoin(
        #"Piezas",
        {"prov_codigo", "zona"},
        vw_adicional_zona_historico,
        {"prov_codigo", "zona_max"},
        "Adicional",
        JoinKind.LeftOuter
    ),

    #"Expand Adicional Zona" =
        Table.ExpandTableColumn(
            #"Merge Adicional Zona",
            "Adicional",
            {"tot_zona", "vigencia_desde", "vigencia_hasta"},
            {"tot_zona_adicional", "vigencia_desde", "vigencia_hasta"}
        ),

    #"Marca Adicional Zona" =
        Table.AddColumn(
            #"Expand Adicional Zona",
            "Marca Adicional Zona",
            each
                if [tot_zona_adicional] <> null
                    and [fecha_caratula] >= [vigencia_desde]
                    and ([vigencia_hasta] = null or [fecha_caratula] <= [vigencia_hasta])
                then 1
                else 0,
            Int64.Type
        ),

    #"Cantidad Piezas Adicional Zona" =
        Table.Group(
            #"Marca Adicional Zona",
            {"ID Viaje"},
            {
                {"Piezas Adicional Zona", each List.Sum([Marca Adicional Zona]), type number}
            }
        ),

    #"Merge Cantidad Piezas Adicional Zona" =
        Table.NestedJoin(
            #"Marca Adicional Zona",
            {"ID Viaje"},
            #"Cantidad Piezas Adicional Zona",
            {"ID Viaje"},
            "CantidadAdicional",
            JoinKind.LeftOuter
        ),

    #"Expand Cantidad Piezas Adicional Zona" =
        Table.ExpandTableColumn(
            #"Merge Cantidad Piezas Adicional Zona",
            "CantidadAdicional",
            {"Piezas Adicional Zona"},
            {"Piezas Adicional Zona"}
        ),

    #"Proporcional Adicional Zona" =
        Table.AddColumn(
            #"Expand Cantidad Piezas Adicional Zona", "Proporcional Adicional Zona",
            each
                if [Marca Adicional Zona] = 1 
                    and ([chk_codigo] = "DL" or [chk_codigo] = "DV") then
                        if [Piezas Adicional Zona] = 0 then 0 
                        else [tot_zona] / [Piezas Adicional Zona]
                else 0,
            type number
        ),

    #"Paga Minimo Logica" =
        Table.AddColumn(
            #"Proporcional Adicional Zona", "Paga Minimo",
            each let veh = [tipo_vehiculo]
                 in if veh <> null and veh <> "CAMIONETA GRANDE" and veh <> "CHASIS" then [cal_min]
                    else if veh = "CAMIONETA GRANDE" and [cal_min] = "NO" then "NO"
                    else "SE",
            type text
        ),

    #"Paga Minimo Proporcional" =
        Table.AddColumn(
            #"Paga Minimo Logica", "Proporcional Paga Minimo",
            each
                if [chk_codigo] = "DL" or [chk_codigo] = "DV" then
                    if [Piezas] = 0 then null
                    else if [Paga Minimo] = "NO" then 0
                    else if [Paga Minimo] = "SE" then 0
                    else
                        (
                            (if [tot_a_pagar] = null then 0 else [tot_a_pagar]) -
                            (if [tot_pagado] = null then 0 else [tot_pagado])
                        ) / [Piezas]
                else 0,
            type number
        ),


    #"adic pami" =
        Table.AddColumn(
            #"Paga Minimo Proporcional", "Adic Pami",
            each if [id_shipper] <> null and [id_shipper] = 4290 and [costo_paq] > 0
                 then if [chk_codigo] = "CA" then [costo_paq] * 0.2 else [tarifa_base] * 0.2
                 else 0,
            type number
        ),

    #"adic pq grande" =
        Table.AddColumn(
            #"adic pami", "Adic PQ Grande",
            each if [peso_utiliza] <> null and [peso_utiliza] >= 35 and [costo_paq] > 0
                 then if [chk_codigo] = "CA" then [tarifa_base] * 0.3 * 0.35 else [tarifa_base] * 0.35
                 else 0,
            type number
        ),

    #"adic agencia" =
        Table.AddColumn(
            #"adic pq grande", "Adic Agencia",
            each if [legajo_nro] <> null and Text.StartsWith([legajo_nro], "P1") and [costo_paq] > 0
                 then [costo_paq] * 0.1 * (if [p_pagado] = null then 0 else [p_pagado])
                 else 0,
            type number
        ),

    #"adic ca" =
        Table.AddColumn(
            #"adic agencia", "Adic CA",
            each if [chk_codigo] = "CA" and [costo_paq] > 0
                 then if [id_producto] = 148 then [tarifa_base] * 0.3 * (if [p_pagado] = null then 0 else [p_pagado])
                 else ([tarifa_base] * 0.8) * 0.3 * (if [p_pagado] = null then 0 else [p_pagado])
                 else 0,
            type number
        ),

    #"adic farma" =
        Table.AddColumn(
            #"adic ca", "Adic Farma",
            each if [farma] = "SI" and [costo_paq] > 0
                 then if [chk_codigo] = "CA" then [tarifa_base] * 0.3 * 0.25 * (if [p_pagado] = null then 0 else [p_pagado])
                 else [tarifa_base] * 0.25 * (if [p_pagado] = null then 0 else [p_pagado])
                 else 0,
            type number
        ),

    #"Descuento Postal" =
        Table.AddColumn(
            #"adic farma", "Descuento Postal",
            each if [costo_paq] <> null and [costo_paq] > 0 and ([chk_codigo] = "DL" or [chk_codigo] = "DV") and [id_producto] <> 148
                 then -([tarifa_base] * 0.2)
                 else 0,
            type number
        ),

    #"Paga Jornada" =
        Table.TransformColumnTypes(
            Table.AddColumn(
                #"adic farma", "Paga Jornada",
                each
                    let
                        veh = [tipo_vehiculo],
                        esChasis = if veh = null then false else Text.StartsWith(veh, "CHASIS"),
                        totPagado =
                            if esChasis
                            then (if [tot_liqui] = null then 0 else [tot_liqui]) +
                                 (if [peaje] = null then 0 else [peaje]) +
                                 (if [tot_zona] = null then 0 else [tot_zona])
                            else (if [tot_pagado] = null then 0 else [tot_pagado])
                    in
                        if (esChasis or veh = "CAMIONETA GRANDE") and [cal_min] <> "NO"
                        then (if [tot_a_pagar] = null then 0 else [tot_a_pagar]) - totPagado
                        else null
            ),
            {{"Paga Jornada", type number}}
        ),

    #"Proporcional Paga Jornada" =
        Table.AddColumn(
            #"Paga Jornada", "Proporcional Paga Jornada",
            each
                if [chk_codigo] = "DL" or [chk_codigo] = "DV" then
                    if [Piezas] = 0 then null else [Paga Jornada] / [Piezas]
                else 0,
            type number
        ),


    #"Proporcional Productividad" =
        Table.AddColumn(
            #"Proporcional Paga Jornada", "Proporcional Productividad",
            each
                if [chk_codigo] <> "DL" and [chk_codigo] <> "DV" then
                    0
                else
                    let
                        veh = [tipo_vehiculo],
                        esChasis = if veh = null then false else Text.StartsWith(veh, "CHASIS"),
                        calMin = [cal_min],
                        aplicaExclusion =
                            esChasis or (calMin = "SI" and veh <> "CAMIONETA GRANDE"),

                        fec = [fecha_caratula],
                        suc = if [prov_codigo] = null then null else Text.Upper([prov_codigo]),
                        prod_raw = try [productividad] otherwise null,
                        prod_num = try Number.From(prod_raw) otherwise null,
                        prod =
                            if prod_num = null then null
                            else if prod_num > 1 then prod_num / 100
                            else prod_num,

                        piezas = [Piezas],
                        total = if [tot_a_pagar] = null then 0 else [tot_a_pagar],

                        sucEspecial = List.Contains({"CDO","MZA","RSO","MDP"}, suc),
                        desdeNuevaRegla = if fec = null then false else fec >= #date(2025, 11, 1),

                        umbralAlta = if sucEspecial then 0.95 else if desdeNuevaRegla then 0.90 else 0.95,
                        umbralBaja = if sucEspecial then 0.85 else if desdeNuevaRegla then 0.80 else 0.85,

                        valor =
                            if aplicaExclusion then
                                0
                            else if piezas = null or piezas = 0 or prod = null then
                                null
                            else if prod >= umbralAlta then
                                ( ( total * (0.10 / 1.10) ) / piezas )
                            else if prod < umbralBaja then
                                -(( total * (0.10 / 0.90) ) / piezas )
                            else
                                0
                    in
                        if valor = null then null
                        else valor * (if [p_pagado] = null then 0 else [p_pagado]),
            type number
        ),


    #"Tipo de columna cambiado" =
        Table.TransformColumnTypes(
            #"Proporcional Productividad",
            {
                {"Adic Pami", type number}, {"Adic PQ Grande", type number}, {"Adic Agencia", type number},
                {"Adic CA", type number}, {"Adic Farma", type number}, {"nro_caratula", type text},
                {"id_shipper", type text}, {"productividad", type number}
            }
        ),

    #"Elegir columnas" =
        Table.SelectColumns(#"Tipo de columna cambiado", {"prov_codigo", "nro_caratula", "id_producto", "id_shipper", "farma", "codigo_postal", "zona", "chk_codigo", "tarifa_base", "peso_utiliza", "costo_paq", "p_pagado", "peso_total", "ID Viaje", "tipo_vehiculo", "cal_min", "productividad", "Piezas", "Proporcional Adicional Zona", "Paga Minimo", "Proporcional Paga Minimo", "Adic Pami", "Adic PQ Grande", "Adic Agencia", "Adic CA", "Adic Farma", "Paga Jornada", "Proporcional Paga Jornada", "Proporcional Productividad"}),

    #"BA a DV con costo" =
        Table.TransformColumns(
            #"otros cálculos",
            {
                {
                    "chk_codigo",
                    each if _ = "BA" and [costo_paq] > 0 then "DV" else _,
                    type text
                }
            }
        ),

    #"Columna condicional insertada1" =
        Table.AddColumn(
            #"Elegir columnas", "Tipo PQ",
            each if [id_producto] <> null and [id_producto] <> 148 then "Postal"
                 else if [id_shipper] <> null and [id_shipper] = "4290" then "Pami"
                 else if [farma] <> null and [farma] = "SI" then "Farma"                 
                 else if [peso_utiliza] <> null and [peso_utiliza] >= 35 then "PQ Grande"
                 else "PQ Chico",
            type text
        ),

    #"Columna condicional insertada" =
    Table.AddColumn(
        #"Columna condicional insertada1", "Envío",
        each 
            if [id_producto] <> null and [id_producto] <> 148 then "Postal"
            else if [id_shipper] <> null and [id_shipper] = "4290" then "Pami"
            else if [id_shipper] <> null and [id_shipper] = "2273" then "Mercado Libre"
            else if [id_shipper] <> null and List.Contains({"1039","4316","4410","2212","4003","4448"}, [id_shipper]) then "CrossBorder"    
            else if [farma] <> null and [farma] = "SI" then "Salud"
            else if [id_shipper] <> null and List.Contains({"2035","2325","2510","3518","4185"}, [id_shipper]) then "Bigger"
            else "Logística",
        type text
    ),
  #"Personalizado agregado 1" = Table.AddColumn(#"Columna condicional insertada", "Costo Real", each [costo_paq] * [p_pagado]),
  #"Tipo de columna cambiado 2" = Table.TransformColumnTypes(#"Personalizado agregado 1", {{"Costo Real", type number}})
in
    #"Tipo de columna cambiado 2";
shared Cabecera_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "U3_Liq_Fleteros_Cabecera", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Detalle_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false, HierarchicalNavigation = null, EnableVorder = true, OutputMetadataRefresh = true]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "gd_fleteros_detalle_comp_costo", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared vw_adicional_zona_historico = let
  Origen = Lakehouse.Contents(null),
  Navegación = Origen{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  #"Navegación 1" = Navegación{[lakehouseId = "5f494725-23eb-48a8-8688-a8040411bb33"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[Id = "vw_adicional_zona_historico", ItemKind = "View"]}[Data]
in
  #"Navegación 2";
