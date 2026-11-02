@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Flight Analytics - Interface'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_DMO_FLIGHT_ALP
  as select from    /DMO/I_Flight  as Flight

    left outer join /DMO/I_Carrier as Carrier on Flight.AirlineID = Carrier.AirlineID
{
  key Flight.AirlineID         as AirlineID,
  key Flight.ConnectionID      as ConnectionID,
  key Flight.FlightDate        as FlightDate,

      Carrier.Name             as AirlineName,

      Flight.PlaneType         as PlaneType,

      @Semantics.amount.currencyCode: 'CurrencyCode'
      Flight.Price             as Price,

      //      @Semantics.currencyCode: true
      Flight.CurrencyCode      as CurrencyCode,

      Flight.MaximumSeats      as MaximumSeats,

      Flight.OccupiedSeats     as OccupiedSeats,

      Flight.MaximumSeats
        - Flight.OccupiedSeats as AvailableSeats,

      cast(
        1 as abap.int4
      )                        as NumberOfFlights
}
