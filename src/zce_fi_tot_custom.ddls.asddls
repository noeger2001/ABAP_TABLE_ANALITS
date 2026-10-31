@EndUserText.label: 'Totales - Custom Entity'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_FI_TOT_CUSTOM_QRY'
@Metadata.allowExtensions: true

define root custom entity ZCE_FI_TOT_CUSTOM
 
{
  @EndUserText.label: 'UUID'
  key Uuid          : sysuuid_x16;


      @EndUserText.label: 'Sociedad'
      CompanyCode   : abap.char( 4 );


      @EndUserText.label: 'Clase'
      DocumentClass : abap.char( 2 );


      @EndUserText.label: 'Año'
      FiscalYear    : abap.numc( 4 );


      @EndUserText.label: 'Periodo'
      FiscalPeriod  : abap.numc( 2 );


      @EndUserText.label: 'Región'
      Region        : abap.char( 10 );


      @EndUserText.label: 'Centro de costo'
      CostCenter    : abap.char( 10 );


      @EndUserText.label: 'Documento'
      DocumentNo    : abap.numc( 10 );


      @Aggregation.default: #SUM
//      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label: 'Ingresos'
      Revenue       : abap.dec( 15, 2 );


      @Aggregation.default: #SUM
//      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label: 'Costos'
      Cost          : abap.dec( 15, 2 );


      @Aggregation.default: #SUM
//      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label: 'Margen'
      Margin        : abap.dec( 15, 2 );


      @Semantics.currencyCode: true
      @EndUserText.label: 'Moneda'
      Currency      : abap.cuky;


      @Aggregation.default: #SUM
//      @Semantics.quantity.unitOfMeasure: 'Unit'
      @EndUserText.label: 'Cantidad'
      Quantity      : abap.dec( 13, 3 );


      @Semantics.unitOfMeasure: true
      @EndUserText.label: 'Unidad'
      Unit          : abap.unit( 3 );


      @Aggregation.default: #SUM
      @EndUserText.label: 'Nº Registros'
      RecordCount   : abap.int4;
      
}
