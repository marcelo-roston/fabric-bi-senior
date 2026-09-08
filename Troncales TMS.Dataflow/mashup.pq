[StagingDefinition = [Kind = "FastCopy"]]
section Section1;
[DataDestinations = {[Definition = [Kind = "Reference", QueryName = "Vista Troncales_DataDestination", IsNewTarget = true], Settings = [Kind = "Automatic", TypeSettings = [Kind = "Table"]]]}]
shared #"Vista Troncales" = let
  Origen = Sql.Database("181.30.37.12,10340", "SGLBI_URBANO_PROD", [Query = "with remitos as (#(lf)select DISTINCT #(lf)Estado , Operacion , Nro_Viaje , Fecha_Salida_Viaje #(lf)from VISTA_REMITOS_TRONCALES_GLOBAL vrtg #(lf)where CLIENTE = 'Troncales Urbano'#(lf))#(lf)select  #(lf)vi.Estado, Nro_Operacion, NIC_Operacion, vi.Operacion, vi.Nro_Viaje, Tipo_Viaje, TRANSPORTISTA, LEGAJO_TRANSPORTISTA, Camion, Chofer, vi.Fecha_Salida_Viaje, A_Pagar, Km, Descripcion_TipoVehiculo#(lf)from VISTA_VIAJES_TRONCALES_GLOBAL vi#(lf)inner join remitos re#(lf)on vi.Estado = re.Estado #(lf)and vi.Operacion = re.Operacion #(lf)and vi.Nro_Viaje = re.Nro_Viaje #(lf)and vi.Fecha_Salida_Viaje = re.Fecha_Salida_Viaje #(lf)where vi.Fecha_Salida_Viaje >= DATEADD(DAY, - 365, CAST(GETDATE() AS date))"]),
  #"Tipo de columna cambiado" = Table.TransformColumnTypes(Origen, {{"Fecha_Salida_Viaje", type date}})
in
  #"Tipo de columna cambiado";
shared #"Vista Troncales_DataDestination" = let
  Pattern = Lakehouse.Contents([HierarchicalNavigation = null, CreateNavigationProperties = false, EnableFolding = false]),
  Navigation_1 = Pattern{[workspaceId = "c1099798-9ed1-461f-b5d2-843e5a67ccfd"]}[Data],
  Navigation_2 = Navigation_1{[lakehouseId = "38153748-4605-4aa9-96d5-c848565db7d9"]}[Data],
  TableNavigation = Navigation_2{[Id = "TMS_Vista_Viajes_Troncales", ItemKind = "Table"]}?[Data]?
in
  TableNavigation;
