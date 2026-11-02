@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Analytics'
@Metadata.allowExtensions: true
@OData.applySupportedForAggregation: #FULL
define root view entity ZC_DMO_FLIGHT_ALP
  provider contract transactional_query
  as projection on ZI_DMO_FLIGHT_ALP
{

      @ObjectModel.text.element: [ 'AirlineName' ]
  key AirlineID,

  key ConnectionID,

  key FlightDate,
      AirlineName,
      PlaneType,

      CurrencyCode,


      @Aggregation.default: #AVG
      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price,


      @Aggregation.default: #SUM
      MaximumSeats,


      @Aggregation.default: #SUM
      OccupiedSeats,


      @Aggregation.default: #SUM
      AvailableSeats,


      @Aggregation.default: #SUM
      NumberOfFlights
}
