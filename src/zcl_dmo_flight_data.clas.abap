CLASS zcl_dmo_flight_data DEFINITION
 PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.

    TYPES ty_r_airline
      TYPE RANGE OF /dmo/carrier_id.

    TYPES ty_r_connection
      TYPE RANGE OF /dmo/connection_id.

    TYPES ty_r_date
      TYPE RANGE OF /dmo/flight_date.

    TYPES ty_r_plane
      TYPE RANGE OF /dmo/plane_type_id.

    TYPES ty_r_airport
      TYPE RANGE OF /dmo/airport_id.

    TYPES ty_r_airline_name
      TYPE RANGE OF /dmo/i_carrier-Name.

    TYPES ty_r_city
      TYPE RANGE OF /dmo/i_airport-City.


    TYPES:
      BEGIN OF ty_filter,
        airline_id          TYPE ty_r_airline,
        airline_name        TYPE ty_r_airline_name,
        connection_id       TYPE ty_r_connection,
        flight_date         TYPE ty_r_date,
        plane_type          TYPE ty_r_plane,
        departure_airport   TYPE ty_r_airport,
        departure_city      TYPE ty_r_city,
        destination_airport TYPE ty_r_airport,
        destination_city    TYPE ty_r_city,
      END OF ty_filter.


    TYPES tt_detail
      TYPE STANDARD TABLE OF zce_dmo_flight_dtl
      WITH EMPTY KEY.

    TYPES tt_summary
      TYPE STANDARD TABLE OF zce_dmo_flight_sum
      WITH EMPTY KEY.


    CLASS-METHODS get_filters
      IMPORTING
        io_request       TYPE REF TO if_rap_query_request
      RETURNING
        VALUE(rs_filter) TYPE ty_filter.


    CLASS-METHODS get_detail
      IMPORTING
        is_filter      TYPE ty_filter
      RETURNING
        VALUE(rt_data) TYPE tt_detail.


    CLASS-METHODS get_summary
      IMPORTING
        it_detail      TYPE tt_detail
      RETURNING
        VALUE(rt_data) TYPE tt_summary.
ENDCLASS.



CLASS zcl_dmo_flight_data IMPLEMENTATION.
  METHOD get_detail.

    "=========================================================
    " 1. AEROLÍNEAS
    "
    " AirlineID / AirlineName vienen de I_Carrier
    "=========================================================

    SELECT
      AirlineID,
      Name,
      CurrencyCode

      FROM /DMO/I_Carrier

      WHERE AirlineID IN @is_filter-airline_id
        AND Name      IN @is_filter-airline_name

      INTO TABLE @DATA(lt_carrier).


    IF lt_carrier IS INITIAL.
      RETURN.
    ENDIF.


    DATA(lr_airlines) =
      VALUE ty_r_airline(
        FOR ls_carrier IN lt_carrier
        (
          sign   = 'I'
          option = 'EQ'
          low    = ls_carrier-AirlineID
        )
      ).


    "=========================================================
    " 2. AEROPUERTOS DE ORIGEN
    "
    " DepartureCity viene de I_Airport
    "=========================================================

    SELECT
      AirportID,
      Name,
      City,
      CountryCode

      FROM /DMO/I_Airport

      WHERE AirportID IN @is_filter-departure_airport
        AND City      IN @is_filter-departure_city

      INTO TABLE @DATA(lt_airport_from).


    IF lt_airport_from IS INITIAL.
      RETURN.
    ENDIF.


    DATA(lr_airport_from) =
      VALUE ty_r_airport(
        FOR ls_airport_from IN lt_airport_from
        (
          sign   = 'I'
          option = 'EQ'
          low    = ls_airport_from-AirportID
        )
      ).


    "=========================================================
    " 3. AEROPUERTOS DE DESTINO
    "=========================================================

    SELECT
      AirportID,
      Name,
      City,
      CountryCode

      FROM /DMO/I_Airport

      WHERE AirportID IN @is_filter-destination_airport
        AND City      IN @is_filter-destination_city

      INTO TABLE @DATA(lt_airport_to).


    IF lt_airport_to IS INITIAL.
      RETURN.
    ENDIF.


    DATA(lr_airport_to) =
      VALUE ty_r_airport(
        FOR ls_airport_to IN lt_airport_to
        (
          sign   = 'I'
          option = 'EQ'
          low    = ls_airport_to-AirportID
        )
      ).


    "=========================================================
    " 4. CONEXIONES
    "
    " ConnectionID / origen / destino vienen de I_Connection
    "=========================================================

    SELECT
      AirlineID,
      ConnectionID,
      DepartureAirport,
      DestinationAirport,
      DepartureTime,
      ArrivalTime,
      Distance,
      DistanceUnit

      FROM /DMO/I_Connection

      WHERE AirlineID          IN @lr_airlines
        AND ConnectionID       IN @is_filter-connection_id
        AND DepartureAirport   IN @lr_airport_from
        AND DestinationAirport IN @lr_airport_to

      INTO TABLE @DATA(lt_connection).


    IF lt_connection IS INITIAL.
      RETURN.
    ENDIF.


    "=========================================================
    " 5. VUELOS
    "
    " Fecha / avión / precio / asientos vienen de I_Flight
    "=========================================================

    SELECT
      AirlineID,
      ConnectionID,
      FlightDate,
      Price,
      CurrencyCode,
      PlaneType,
      MaximumSeats,
      OccupiedSeats

      FROM /DMO/I_Flight

      FOR ALL ENTRIES IN @lt_connection

      WHERE AirlineID    = @lt_connection-AirlineID
        AND ConnectionID = @lt_connection-ConnectionID
        AND FlightDate   IN @is_filter-flight_date
        AND PlaneType    IN @is_filter-plane_type

      INTO TABLE @DATA(lt_flight).


    IF lt_flight IS INITIAL.
      RETURN.
    ENDIF.


    "=========================================================
    " 6. Preparar búsquedas rápidas para el LOOP final
    "=========================================================

    SORT lt_carrier
      BY AirlineID.

    SORT lt_connection
      BY AirlineID
         ConnectionID.

    SORT lt_airport_from
      BY AirportID.

    SORT lt_airport_to
      BY AirportID.


    "=========================================================
    " 7. Crear dataset canónico
    "=========================================================

    LOOP AT lt_flight INTO DATA(ls_flight).

      READ TABLE lt_carrier
        INTO DATA(ls_carrier_data)
        WITH KEY
          AirlineID = ls_flight-AirlineID
        BINARY SEARCH.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.


      READ TABLE lt_connection
        INTO DATA(ls_connection_data)
        WITH KEY
          AirlineID    = ls_flight-AirlineID
          ConnectionID = ls_flight-ConnectionID
        BINARY SEARCH.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.


      READ TABLE lt_airport_from
        INTO DATA(ls_from_data)
        WITH KEY
          AirportID = ls_connection_data-DepartureAirport
        BINARY SEARCH.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.


      READ TABLE lt_airport_to
        INTO DATA(ls_to_data)
        WITH KEY
          AirportID = ls_connection_data-DestinationAirport
        BINARY SEARCH.

      IF sy-subrc <> 0.
        CONTINUE.
      ENDIF.


      DATA(lv_available_seats) =
        CONV i(
          ls_flight-MaximumSeats -
          ls_flight-OccupiedSeats
        ).


      DATA(lv_occupancy_rate) =
        COND decfloat34(
          WHEN ls_flight-MaximumSeats > 0

          THEN
            CONV decfloat34(
              ls_flight-OccupiedSeats
            )
            *
            100
            /
            CONV decfloat34(
              ls_flight-MaximumSeats
            )

          ELSE 0
        ).


      APPEND VALUE #(

        AirlineID =
          ls_flight-AirlineID

        ConnectionID =
          ls_flight-ConnectionID

        FlightDate =
          ls_flight-FlightDate

        AirlineName =
          ls_carrier_data-Name


        DepartureAirport =
          ls_connection_data-DepartureAirport

        DepartureAirportName =
          ls_from_data-Name

        DepartureCity =
          ls_from_data-City


        DestinationAirport =
          ls_connection_data-DestinationAirport

        DestinationAirportName =
          ls_to_data-Name

        DestinationCity =
          ls_to_data-City


        PlaneType =
          ls_flight-PlaneType


        Price =
          ls_flight-Price

        CurrencyCode =
          ls_flight-CurrencyCode


        MaximumSeats =
          ls_flight-MaximumSeats

        OccupiedSeats =
          ls_flight-OccupiedSeats

        AvailableSeats =
          lv_available_seats

        OccupancyRate =
          lv_occupancy_rate

      ) TO rt_data.

    ENDLOOP.

  ENDMETHOD.

  METHOD get_filters.

    TRY.

        DATA(lt_filters) =
          io_request->get_filter( )->get_as_ranges( ).

        LOOP AT lt_filters INTO DATA(ls_filter).

          DATA(lv_name) =
            to_upper( ls_filter-name ).

          CASE lv_name.

            WHEN 'AIRLINEID'.

              LOOP AT ls_filter-range INTO DATA(ls_range_airline).

                APPEND VALUE #(
                  sign   = ls_range_airline-sign
                  option = ls_range_airline-option
                  low    = CONV #( ls_range_airline-low )
                  high   = CONV #( ls_range_airline-high )
                ) TO rs_filter-airline_id.

              ENDLOOP.


            WHEN 'AIRLINENAME'.

              LOOP AT ls_filter-range INTO DATA(ls_range_airline_name).

                APPEND VALUE #(
                  sign   = ls_range_airline_name-sign
                  option = ls_range_airline_name-option
                  low    = CONV #( ls_range_airline_name-low )
                  high   = CONV #( ls_range_airline_name-high )
                ) TO rs_filter-airline_name.

              ENDLOOP.


            WHEN 'CONNECTIONID'.

              LOOP AT ls_filter-range INTO DATA(ls_range_connection).

                APPEND VALUE #(
                  sign   = ls_range_connection-sign
                  option = ls_range_connection-option
                  low    = CONV #( ls_range_connection-low )
                  high   = CONV #( ls_range_connection-high )
                ) TO rs_filter-connection_id.

              ENDLOOP.


            WHEN 'FLIGHTDATE'.

              LOOP AT ls_filter-range INTO DATA(ls_range_date).

                APPEND VALUE #(
                  sign   = ls_range_date-sign
                  option = ls_range_date-option
                  low    = CONV #( ls_range_date-low )
                  high   = CONV #( ls_range_date-high )
                ) TO rs_filter-flight_date.

              ENDLOOP.


            WHEN 'PLANETYPE'.

              LOOP AT ls_filter-range INTO DATA(ls_range_plane).

                APPEND VALUE #(
                  sign   = ls_range_plane-sign
                  option = ls_range_plane-option
                  low    = CONV #( ls_range_plane-low )
                  high   = CONV #( ls_range_plane-high )
                ) TO rs_filter-plane_type.

              ENDLOOP.


            WHEN 'DEPARTUREAIRPORT'.

              LOOP AT ls_filter-range INTO DATA(ls_range_dep_airport).

                APPEND VALUE #(
                  sign   = ls_range_dep_airport-sign
                  option = ls_range_dep_airport-option
                  low    = CONV #( ls_range_dep_airport-low )
                  high   = CONV #( ls_range_dep_airport-high )
                ) TO rs_filter-departure_airport.

              ENDLOOP.


            WHEN 'DEPARTURECITY'.

              LOOP AT ls_filter-range INTO DATA(ls_range_dep_city).

                APPEND VALUE #(
                  sign   = ls_range_dep_city-sign
                  option = ls_range_dep_city-option
                  low    = CONV #( ls_range_dep_city-low )
                  high   = CONV #( ls_range_dep_city-high )
                ) TO rs_filter-departure_city.

              ENDLOOP.


            WHEN 'DESTINATIONAIRPORT'.

              LOOP AT ls_filter-range INTO DATA(ls_range_dst_airport).

                APPEND VALUE #(
                  sign   = ls_range_dst_airport-sign
                  option = ls_range_dst_airport-option
                  low    = CONV #( ls_range_dst_airport-low )
                  high   = CONV #( ls_range_dst_airport-high )
                ) TO rs_filter-destination_airport.

              ENDLOOP.


            WHEN 'DESTINATIONCITY'.

              LOOP AT ls_filter-range INTO DATA(ls_range_dst_city).

                APPEND VALUE #(
                  sign   = ls_range_dst_city-sign
                  option = ls_range_dst_city-option
                  low    = CONV #( ls_range_dst_city-low )
                  high   = CONV #( ls_range_dst_city-high )
                ) TO rs_filter-destination_city.

              ENDLOOP.

          ENDCASE.

        ENDLOOP.

      CATCH cx_rap_query_filter_no_range.

        "Para filtros complejos OR/AND que no puedan expresarse
        "como ranges, usar io_request->get_filter( )->get_as_tree( ).
        CLEAR rs_filter.

    ENDTRY.


  ENDMETHOD.

  METHOD get_summary.

    DATA lt_summary
        TYPE HASHED TABLE OF zce_dmo_flight_sum
        WITH UNIQUE KEY
          AirlineID
          CurrencyCode.


    LOOP AT it_detail
      ASSIGNING FIELD-SYMBOL(<detail>).


      READ TABLE lt_summary
        ASSIGNING FIELD-SYMBOL(<summary>)
        WITH TABLE KEY

          AirlineID =
            <detail>-AirlineID

          CurrencyCode =
            <detail>-CurrencyCode.


      IF sy-subrc <> 0.

        INSERT VALUE #(

          AirlineID =
            <detail>-AirlineID

          AirlineName =
            <detail>-AirlineName

          CurrencyCode =
            <detail>-CurrencyCode

        )
        INTO TABLE lt_summary
        ASSIGNING <summary>.

      ENDIF.


      <summary>-TotalFlights += 1.

      <summary>-TotalPrice +=
        <detail>-Price.

      <summary>-TotalMaximumSeats +=
        <detail>-MaximumSeats.

      <summary>-TotalOccupiedSeats +=
        <detail>-OccupiedSeats.

      <summary>-TotalAvailableSeats +=
        <detail>-AvailableSeats.

    ENDLOOP.


    LOOP AT lt_summary
      ASSIGNING <summary>.

      IF <summary>-TotalMaximumSeats > 0.

        <summary>-OccupancyRate =

          CONV decfloat34(
            <summary>-TotalOccupiedSeats
          )
          *
          100
          /
          CONV decfloat34(
            <summary>-TotalMaximumSeats
          ).

      ENDIF.

    ENDLOOP.


    rt_data =
      CORRESPONDING #( lt_summary ).

  ENDMETHOD.

ENDCLASS.
