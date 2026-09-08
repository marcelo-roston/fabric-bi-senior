[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Barras_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Barras = let
  Origen = Odbc.Query("dsn=Informix_REP;Database=Estadistica", "SELECT #(lf)sla.shipper, sla.cli_codigo, bi.fecha_ge as vl_fecha_ge,#(lf)sh.id_servicio as servicio_urbano, bi.dld_chk_codigo as chk_primer_visita, bi.dld_chk_fecha as primer_visita, #(lf)sla.gui_numero, sla.sucursal, sla.fecha_pi, bi.estado, bi.region, sla.cp, sla.ult_check#(lf)FROM estadistica:sla_informe sla #(lf)inner join estadistica:shipper_servicio sh on sla.shipper = sh.id_shipper#(lf)left join informes_test_bi bi on bi.id_informes_test = sla.id_informes_test#(lf)where bi.fecha_ge >= today - 100 #(lf)and (sh.id_servicio in (4,5, 17)  or #(lf)sla.shipper in (#(lf)318,1879,2127,2434,2461,2462,2479,2665,2677,2775,2786,2836,2852,2874,2905,2914,2918,#(lf)2948,2954,2965,3015,3016,3017,3040,3047,3060,3106,3109,3117,3219,3223,3235,3310,3345,#(lf)3392,3414,3433,3440,3444,3522,3558,3565,3574,3599,3601,3609,3625,3637,3647,3648,3649,#(lf)3652,3675,3686,3688,3699,3785,3790,3792,3804,3811,3824,3825,3866,3880,3894,3898,3911,#(lf)3927,3944,3999,4017,4022,4047,4064,4083,4148,4176,4187,4194,4214,4233,4241,5010,5029,5068)#(lf))"),
  #"Consultas combinadas" = Table.NestedJoin(Origen, {"servicio_urbano", "cp"}, sla_informe, {"servicio", "cp"}, "sla_informe", JoinKind.LeftOuter),
  #"sla_informe expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "sla_informe", {"sla"}, {"sla"})
in
  #"sla_informe expandido";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "RC_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared RC = let
  Origen = Odbc.Query("dsn=Informix_REP;Database=www", "SELECT#(lf)    gui_numero,#(lf)    MAX(CASE WHEN chk_codigo = 'RC' THEN chk_fecha END) AS fecha_rc,#(lf)    MAX(CASE WHEN chk_codigo = 'AS' THEN chk_fecha END) AS fecha_as,#(lf)    MAX(CASE WHEN chk_codigo = 'DV' THEN chk_fecha END) AS fecha_dv#(lf)FROM www:movimiento#(lf)WHERE chk_codigo IN ('RC', 'AS', 'DV')#(lf)  AND chk_fecha >= TODAY - 100#(lf)GROUP BY gui_numero"),
  #"Duplicados quitados" = Table.Distinct(Origen, {"gui_numero"})
in
  #"Duplicados quitados";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "DL_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared DL = let
  Origen = Odbc.Query("dsn=Informix_REP;Database=www", "select #(lf)gui_numero,  chk_fecha #(lf)from www:movimiento#(lf)where chk_codigo in ('DL', 'EI') and chk_fecha >= today - 180"),
  #"Duplicados quitados" = Table.Distinct(Origen, {"gui_numero"})
in
  #"Duplicados quitados";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Shippers Usalud_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"Shippers Usalud" = let
  Origen = Odbc.Query("dsn=Informix_REP;Database=Estadistica", "select #(lf)id_shipper, shi_representante, shi_razon_social, shi_direccion, shi_cuit#(lf)from maestra:shipper#(lf)where id_shipper in (#(lf)    select id_shipper from shipper_usalud)"),
    #"Columna combinada insertada" = Table.AddColumn(Origen, "Shipper", each Text.Combine({Text.From([id_shipper], "es-AR"), [shi_razon_social]}, " - "), type text),
    #"Filas ordenadas" = Table.Sort(#"Columna combinada insertada",{{"shi_razon_social", Order.Ascending}}),
    #"Texto en mayúsculas" = Table.TransformColumns(#"Filas ordenadas",{{"shi_direccion", Text.Upper, type text}}),
    #"Valor reemplazado" = Table.ReplaceValue(#"Texto en mayúsculas","AV","",Replacer.ReplaceText,{"shi_direccion"}),
    #"Valor reemplazado1" = Table.ReplaceValue(#"Valor reemplazado",".","",Replacer.ReplaceText,{"shi_direccion"}),
    #"Texto recortado" = Table.TransformColumns(#"Valor reemplazado1",{{"shi_direccion", Text.Trim, type text}}),
  #"Consultas combinadas" = Table.NestedJoin(#"Texto recortado", {"id_shipper"}, #"Shippers físicos", {"id_shipper"}, "Shippers físicos", JoinKind.LeftOuter),
  #"Shippers físicos expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "Shippers físicos", {"id_shipper"}, {"id_shipper.1"}),
  #"Valor reemplazado 1" = Table.ReplaceValue(#"Shippers físicos expandido", null, 0, Replacer.ReplaceValue, {"id_shipper.1"}),
  #"Columna condicional insertada" = Table.AddColumn(#"Valor reemplazado 1", "Guia Fisica", each if [id_shipper.1] > 1 then "SI" else "NO"),
  #"Elegir columnas" = Table.SelectColumns(#"Columna condicional insertada", {"id_shipper", "shi_representante", "shi_razon_social", "shi_direccion", "Shipper", "Guia Fisica"}),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Elegir columnas", {{"Guia Fisica", type text}})
in
    #"Tipo de columna cambiado";
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Shippers físicos_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"Shippers físicos" = let
    Origen = #table(
        type table [id_shipper = Int64.Type],
        {
            {26},{253},{272},{318},{325},{671},{709},{771},{787},{967},{974},{1002},{1028},{1039},{1203},{1231},{1247},
            {1255},{1258},{1284},{1309},{1315},{1369},{1385},{1707},{1715},{1727},{1734},{1765},{1809},{1835},{1851},
            {1854},{1879},{1894},{1910},{1916},{1945},{1948},{1955},{2035},{2066},{2127},{2212},{2238},{2243},{2267},
            {2292},{2297},{2314},{2325},{2326},{2332},{2351},{2378},{2404},{2434},{2437},{2460},{2461},{2479},{2489},
            {2508},{2510},{2511},{2540},{2541},{2545},{2550},{2579},{2602},{2608},{2633},{2658},{2665},{2674},{2677},
            {2679},{2680},{2701},{2726},{2775},{2781},{2786},{2794},{2799},{2800},{2803},{2807},{2812},{2824},{2828},
            {2836},{2839},{2843},{2844},{2849},{2852},{2864},{2871},{2874},{2875},{2885},{2887},{2891},{2898},{2900},
            {2905},{2912},{2914},{2916},{2918},{2928},{2929},{2932},{2940},{2941},{2942},{2943},{2948},{2950},{2957},
            {2962},{2966},{2968},{2971},{2978},{2979},{2980},{2985},{2986},{2987},{2988},{2989},{2990},{2991},{2992},
            {2993},{2994},{2995},{2996},{2997},{2998},{2999},{3000},{3003},{3004},{3005},{3006},{3007},{3008},{3015},
            {3016},{3017},{3027},{3028},{3029},{3033},{3039},{3040},{3047},{3050},{3051},{3053},{3060},{3064},{3067},
            {3068},{3071},{3072},{3076},{3078},{3087},{3089},{3090},{3091},{3094},{3096},{3102},{3103},{3106},{3109},
            {3112},{3114},{3115},{3117},{3125},{3126},{3140},{3144},{3148},{3151},{3170},{3171},{3174},{3177},{3182},
            {3189},{3197},{3198},{3201},{3202},{3203},{3206},{3212},{3213},{3214},{3220},{3223},{3235},{3240},{3245},
            {3246},{3250},{3251},{3252},{3260},{3266},{3267},{3268},{3269},{3271},{3274},{3277},{3296},{3303},{3305},
            {3306},{3307},{3308},{3309},{3310},{3312},{3315},{3316},{3317},{3322},{3325},{3342},{3345},{3348},{3355},
            {3357},{3358},{3359},{3360},{3364},{3365},{3366},{3380},{3381},{3392},{3394},{3395},{3397},{3400},{3414},
            {3419},{3423},{3436},{3438},{3439},{3440},{3443},{3444},{3456},{3457},{3458},{3459},{3462},{3472},{3477},
            {3486},{3489},{3491},{3492},{3495},{3497},{3499},{3515},{3518},{3522},{3524},{3532},{3534},{3540},{3547},
            {3548},{3551},{3558},{3563},{3564},{3565},{3567},{3570},{3571},{3573},{3577},{3582},{3585},{3586},{3589},
            {3591},{3592},{3599},{3600},{3601},{3609},{3611},{3612},{3613},{3614},{3615},{3620},{3621},{3622},{3625},
            {3627},{3628},{3631},{3632},{3633},{3634},{3637},{3639},{3641},{3642},{3645},{3647},{3648},{3649},{3650},
            {3651},{3652},{3654},{3657},{3664},{3668},{3669},{3671},{3672},{3673},{3675},{3677},{3680},{3686},{3688},
            {3689},{3690},{3692},{3699},{3704},{3707},{3709},{3710},{3712},{3714},{3716},{3717},{3718},{3719},{3720},
            {3728},{3741},{3743},{3744},{3745},{3747},{3749},{3751},{3752},{3755},{3765},{3767},{3769},{3770},{3771},
            {3775},{3779},{3780},{3784},{3785},{3787},{3790},{3792},{3795},{3804},{3805},{3812},{3817},{3819},{3821},
            {3823},{3824},{3825},{3841},{3844},{3854},{3860},{3861},{3862},{3865},{3866},{3884},{3893},{3894},{3898},
            {3903},{3916},{3917},{3919},{3921},{3923},{3927},{3928},{3929},{3930},{3931},{3933},{3934},{3937},{3938},
            {3940},{3941},{3942},{3943},{3944},{3950},{3954},{3955},{3956},{3957},{3958},{3960},{3961},{3962},{3963},
            {3964},{3965},{3967},{3968},{3969},{3971},{3972},{3974},{3975},{3976},{3977},{3978},{3979},{3980},{3981},
            {3982},{3988},{3990},{3991},{3999},{4000},{4003},{4004},{4005},{4012},{4013},{4015},{4017},{4019},{4020},
            {4021},{4022},{4024},{4025},{4026},{4028},{4029},{4030},{4032},{4033},{4034},{4036},{4038},{4040},{4043},
            {4045},{4046},{4047},{4048},{4049},{4051},{4052},{4053},{4054},{4056},{4057},{4059},{4062},{4064},{4066},
            {4067},{4068},{4069},{4070},{4074},{4075},{4076},{4080},{4081},{4082},{4083},{4084},{4085},{4086},{4087},
            {4088},{4089},{4090},{4092},{4094},{4095},{4100},{4101},{4104},{4106},{4107},{4108},{4109},{4112},{4114},
            {4117},{4118},{4119},{4122},{4123},{4124},{4126},{4129},{4130},{4132},{4136},{4137},{4138},{4139},{4141},
            {4144},{4146},{4148},{4149},{4150},{4151},{4153},{4154},{4155},{4157},{4160},{4161},{4162},{4164},{4165},
            {4167},{4169},{4170},{4172},{4173},{4174},{4175},{4176},{4177},{4182},{4183},{4184},{4185},{4186},{4187},
            {4188},{4189},{4190},{4192},{4193},{4194},{4195},{4197},{4198},{4199},{4200},{4201},{4202},{4203},{4204},
            {4205},{4206},{4207},{4208},{4209},{4211},{4212},{4213},{4214},{4215},{4216},{4217},{4218},{4219},{4220},
            {4221},{4223},{4224},{4225},{4226},{4227},{4228},{4229},{4230},{4231},{4232},{4233},{4234},{4235},{4236},
            {4237},{4238},{4239},{4240},{4241},{4242},{4243},{4244},{4245},{4246},{4247},{4248},{4249},{4250},{4251},
            {4252},{4253},{4254},{4255},{4256},{4257},{4258},{4259},{4260},{4261},{4262},{4263},{4264},{4265},{4267},
            {4268},{4269},{4270},{4271},{4272},{4274},{4275},{4276},{4277},{4278},{4279},{4280},{4281},{4282},{4283},
            {4284},{4285},{4286},{4287},{4288},{4289},{4290},{4291},{4292},{4294},{4295},{4296},{4297},{4298},{4299},
            {4300},{4301},{4302},{4303},{4304},{4305},{4306},{4307},{4308},{4309},{4310},{4311},{4312},{4313},{4314},
            {4315},{4316},{4317},{4318},{4319},{4320},{4321},{4322},{4323},{4324},{4326},{4327},{4328},{4329},{4330},
            {4331},{4332},{4333},{4334},{4475},{4476},{5004},{5005},{5010},{5013},{5022},{5029},{5036},{5045},{5047},
            {5048},{5055},{5057},{5062},{5068},{5075},{5090},{222222}
        }
    ),
    #"Duplicados quitados" = Table.Distinct(Origen, {"id_shipper"})
in
    #"Duplicados quitados";
shared RC_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  TableNavigation = Navigation_2{[Id = "U3_tablero_usalud_RC", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared DL_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  TableNavigation = Navigation_2{[Id = "U3_tablero_usalud_DL", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared #"Shippers Usalud_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  TableNavigation = Navigation_2{[Id = "U3_tablero_usalud_shippers", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared Barras_DataDestination = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  TableNavigation = Navigation_2{[Id = "U3_tablero_usalud_barras", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared #"Shippers físicos_DataDestination" = let
  Pattern = Lakehouse.Contents([CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  TableNavigation = Navigation_2{[Id = "U3_tablero_usalud_shippers_rend_fisica", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared RangoFechas = let
    Origen = Barras,
    FechasValidas = Table.SelectRows(Origen, each [vl_fecha_ge] <> null),
    MinFecha = List.Min(FechasValidas[vl_fecha_ge]),
    MaxFecha = List.Max(FechasValidas[vl_fecha_ge]),
    Resultado = #table(
        {"MinFecha", "MaxFecha"},
        {{MinFecha, MaxFecha}}
    )
in
    Resultado;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Calendario_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared Calendario = let
    Rango = RangoFechas,
    MinFecha = Date.From(Rango{0}[MinFecha]),
    MaxFecha = Date.From(Rango{0}[MaxFecha]),

    Fechas =
        List.Dates(
            MinFecha,
            Duration.Days(MaxFecha - MinFecha) + 1,
            #duration(1, 0, 0, 0)
        ),

    Calendario =
        Table.FromList(
            Fechas,
            Splitter.SplitByNothing(),
            {"Fecha"}
        ),

    TipoFecha =
        Table.TransformColumnTypes(
            Calendario,
            {{"Fecha", type date}}
        ),
  #"Consultas combinadas" = Table.NestedJoin(TipoFecha, {"Fecha"}, U3_FERIADOS, {"fecha"}, "U3_FERIADOS", JoinKind.LeftOuter),
  #"U3_FERIADOS expandido" = Table.ExpandTableColumn(#"Consultas combinadas", "U3_FERIADOS", {"fecha"}, {"fecha.1"}),
  #"Columnas con nombre cambiado" = Table.RenameColumns(#"U3_FERIADOS expandido", {{"fecha.1", "Feriados"}}),
  #"Columna condicional insertada" =
        Table.AddColumn(
            #"Columnas con nombre cambiado",
            "Dia Habil",
            each
                if Date.DayOfWeek([Fecha], Day.Monday) >= 5 then 0   // sábado = 5, domingo = 6
                else if [Feriados] <> null then 0                    // existe en tabla de feriados
                else 1,
            Int64.Type
        ),
  #"Personalizado agregado" = Table.AddColumn(#"Columna condicional insertada", "Año", each Date.Year([Fecha])),
  #"Personalizado agregado 1" = Table.AddColumn(#"Personalizado agregado", "Nro Mes", each Date.Month([Fecha])),
  #"Personalizado agregado 2" = Table.AddColumn(#"Personalizado agregado 1", "Mes", each Date.MonthName([Fecha], "es-ES")),
  #"Personalizado agregado 3" = Table.AddColumn(#"Personalizado agregado 2", "Semana", each Date.WeekOfYear([Fecha], Day.Monday)),
  #"Personalizado agregado 4" = Table.AddColumn(#"Personalizado agregado 3", "Año y Semana", each Text.From([Año]) & " - " & Text.From([Semana])),
  #"Personalizado agregado 5" = Table.AddColumn(#"Personalizado agregado 4", "Trimestre", each "Tri" & Text.From(Date.QuarterOfYear([Fecha]))
& " - " & Text.From([Año])),
  #"Personalizado agregado 6" = Table.AddColumn(#"Personalizado agregado 5", "Semestre", each "Sem " &
Text.From(if [Nro Mes] > 6 then 2 else 1)
& " - " & Text.From([Año])),
  #"Personalizado agregado 7" = Table.AddColumn(#"Personalizado agregado 6", "Bimestre", each "Bi " 
& Text.From(Number.RoundUp([Nro Mes] / 2))
& " - " & Text.From([Año])),
  #"Personalizado agregado 8" = Table.AddColumn(#"Personalizado agregado 7", "Cuatrimestre", each "Cu "
& Text.From(Number.RoundUp([Nro Mes] / 4))
& " - " & Text.From([Año])),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Personalizado agregado 8", {{"Dia Habil", Int64.Type}, {"Semana", Int64.Type}, {"Año", Int64.Type}, {"Nro Mes", Int64.Type}, {"Mes", type text}, {"Año y Semana", type text}, {"Trimestre", type text}, {"Semestre", type text}, {"Bimestre", type text}, {"Cuatrimestre", type text}}),
  #"Elegir columnas" = Table.SelectColumns(#"Tipo de columna cambiado", {"Fecha", "Dia Habil", "Año", "Nro Mes", "Mes", "Semana", "Año y Semana", "Trimestre", "Semestre", "Bimestre", "Cuatrimestre"})
in
    #"Elegir columnas";
shared U3_FERIADOS = let
  Origen = Lakehouse.Contents([HierarchicalNavigation = null]),
  #"Navegación 1" = Origen{[workspaceId = "5134ca31-6307-4e20-bd74-ad80ca764046"]}[Data],
  #"Navegación 2" = #"Navegación 1"{[lakehouseId = "049ecaa5-eaaf-4849-a618-a273849a7de9"]}[Data],
  #"Navegación 3" = #"Navegación 2"{[Id = "U3_FERIADOS", ItemKind = "Table"]}[Data],
  #"Elegir columnas" = Table.SelectColumns(#"Navegación 3", {"fecha"}),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(#"Elegir columnas", {{"fecha", type date}}),
  #"Filas ordenadas" = Table.Sort(#"Tipo de columna cambiado", {{"fecha", Order.Descending}})
in
  #"Filas ordenadas";
shared Calendario_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  TableNavigation = Navigation_2{[Id = "U3_Calendario", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "sla_informe_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared sla_informe = let
  Origen = Odbc.Query("dsn=Informix_REP;Database=Estadistica", "select * from sla_servicio")
in
  Origen;
shared sla_informe_DataDestination = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "de58382b-a674-4669-a425-d536299ea5ea"]}[Data],
  TableNavigation = Navigation_2{[Id = "U3_sla_informe", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
shared NavigationQuery = let
  Origen = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false])
in
  Origen;
