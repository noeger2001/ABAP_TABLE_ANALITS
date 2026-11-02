@EndUserText.label: 'Resumen vuelos DMO'
@ObjectModel.query.implementedBy: 'ABAP:ZCL_DMO_FLIGHT_SUM_Q'
@Metadata.allowExtensions: true

define root custom entity ZCE_DMO_FLIGHT_SUM
{
  key AirlineID          : /dmo/carrier_id;
  key CurrencyCode       : /dmo/currency_code;

      AirlineName        : abap.char( 80 );

  

      // Campos comunes con Detail para recibir filtros
      ConnectionID       : /dmo/connection_id;
      FlightDate         : /dmo/flight_date;
      DepartureAirport   : /dmo/airport_id;
      DepartureCity      : abap.char( 80 );
      DestinationAirport : /dmo/airport_id;
      DestinationCity    : abap.char( 80 );
      PlaneType          : /dmo/plane_type_id;

      TotalFlights       : abap.int8;

      @Semantics.amount.currencyCode: 'CurrencyCode'
      TotalPrice         : abap.dec( 23, 2 );

      TotalMaximumSeats  : abap.int8;
      TotalOccupiedSeats : abap.int8;
      TotalAvailableSeats: abap.int8;

      OccupancyRate      : abap.dec( 5, 2 );
}
