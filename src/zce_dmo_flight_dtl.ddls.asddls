@EndUserText.label: 'Detalle vuelos DMO'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_DMO_FLIGHT_DTL_Q'
@Metadata.allowExtensions: true
define custom entity ZCE_DMO_FLIGHT_DTL
 
{
  key AirlineID               : /dmo/carrier_id;
  key ConnectionID            : /dmo/connection_id;
  key FlightDate              : /dmo/flight_date;

      AirlineName             : abap.char( 80 );

      DepartureAirport        : /dmo/airport_id;
      DepartureAirportName    : abap.char( 80 );
      DepartureCity           : abap.char( 80 );

      DestinationAirport      : /dmo/airport_id;
      DestinationAirportName  : abap.char( 80 );
      DestinationCity         : abap.char( 80 );

      PlaneType               : /dmo/plane_type_id;

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Price                   : /dmo/flight_price;

      @Semantics.currencyCode: true
      CurrencyCode            : /dmo/currency_code;

      MaximumSeats            : abap.int4;
      OccupiedSeats           : abap.int4;
      AvailableSeats          : abap.int4;

      OccupancyRate           : abap.dec( 5, 2 );
  
}
