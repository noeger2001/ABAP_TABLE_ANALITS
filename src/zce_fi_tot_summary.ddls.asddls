@EndUserText.label: 'ZCE_FI_TOT_SUMMARY'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_FI_TOT_SUMMARY'
@Metadata.allowExtensions: true
define root custom entity ZCE_FI_TOT_SUMMARY

{
      @EndUserText.label: 'Sociedad'
  key CompanyCode   : abap.char( 4 );

      @EndUserText.label: 'Clase'
  key DocumentClass : abap.char( 2 );

      @EndUserText.label: 'Año'
  key FiscalYear    : abap.numc( 4 );

      @Semantics.currencyCode: true
      @EndUserText.label: 'Moneda'
  key Currency      : abap.cuky;

      @Semantics.unitOfMeasure: true
      @EndUserText.label: 'Unidad'
  key Unit          : abap.unit( 3 );


      /*
       * Estos campos existen para que los filtros del
       * List Report principal puedan aplicarse también
       * al tab Resumen.
       *
       * NO forman parte del GROUP BY.
       */
      @EndUserText.label: 'Periodo'
      FiscalPeriod  : abap.numc( 2 );

      @EndUserText.label: 'Región'
      Region        : abap.char( 10 );

      @EndUserText.label: 'Centro de costo'
      CostCenter    : abap.char( 10 );


      /*
       * Medidas YA AGREGADAS.
       *
       * Importante:
       * NO poner @Aggregation.default aquí.
       */
      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label: 'Ingresos'
      Revenue       : abap.dec( 15, 2 );

      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label: 'Costos'
      Cost          : abap.dec( 15, 2 );

      @Semantics.amount.currencyCode: 'Currency'
      @EndUserText.label: 'Margen'
      Margin        : abap.dec( 15, 2 );

      @Semantics.quantity.unitOfMeasure: 'Unit'
      @EndUserText.label: 'Cantidad'
      Quantity      : abap.dec( 13, 3 );

      @EndUserText.label: 'Nº Registros'
      RecordCount   : abap.int8;

}
