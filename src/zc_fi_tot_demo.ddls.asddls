@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Reporte de Totales y Subtotales'
//@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true
@OData.applySupportedForAggregation: #FULL
define root view entity ZC_FI_TOT_DEMO
  provider contract transactional_query
  as projection on ZI_FI_TOT_DEMO
{

   key Uuid,

      @EndUserText.label: 'Sociedad'
      CompanyCode,

      @EndUserText.label: 'Clase'
      DocumentClass,

      @EndUserText.label: 'Año'
      FiscalYear,

      @EndUserText.label: 'Periodo'
      FiscalPeriod,

      @EndUserText.label: 'Región'
      Region,

      @EndUserText.label: 'Centro de costo'
      CostCenter,

      @EndUserText.label: 'Documento'
      DocumentNo,

      ----------------------------------------------------------
      -- MEDIDAS
      ----------------------------------------------------------

      @Aggregation.default: #SUM
      @EndUserText.label: 'Ingresos'
      @Semantics.amount.currencyCode: 'Currency'
      Revenue,

      @Aggregation.default: #SUM
      @EndUserText.label: 'Costos'
      @Semantics.amount.currencyCode: 'Currency'
      Cost,

      @Aggregation.default: #SUM
      @EndUserText.label: 'Margen'
      @Semantics.amount.currencyCode: 'Currency'
      Margin,

      @EndUserText.label: 'Moneda'
      Currency,

      @Aggregation.default: #SUM
      @EndUserText.label: 'Cantidad'
      @Semantics.quantity.unitOfMeasure: 'Unit'
      Quantity,

      @EndUserText.label: 'Unidad'
      Unit,

      @Aggregation.default: #SUM
      @EndUserText.label: 'Nº Registros'
      RecordCount
}
