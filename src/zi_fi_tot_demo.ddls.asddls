@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface - Totales Demo'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_FI_TOT_DEMO
  as select from zfi_tot_demo
{

  key uuid                   as Uuid,

      company_code           as CompanyCode,
      document_class         as DocumentClass,
      fiscal_year            as FiscalYear,
      fiscal_period          as FiscalPeriod,

      region                 as Region,
      cost_center            as CostCenter,
      document_no            as DocumentNo,

      @Semantics.amount.currencyCode: 'Currency'
      revenue                as Revenue,

      @Semantics.amount.currencyCode: 'Currency'
      cost                   as Cost,

      @Semantics.amount.currencyCode: 'Currency'
      revenue - cost         as Margin,

      //      @Semantics.currencyCode: true
      currency               as Currency,

      @Semantics.quantity.unitOfMeasure: 'Unit'
      quantity               as Quantity,

      //      @Semantics.unitOfMeasure: true
      unit                   as Unit,

      cast( 1 as abap.int4 ) as RecordCount
}
