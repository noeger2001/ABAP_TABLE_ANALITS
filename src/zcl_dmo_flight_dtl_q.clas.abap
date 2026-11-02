CLASS zcl_dmo_flight_dtl_q DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_dmo_flight_dtl_q IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    "---------------------------------------------------------
    " Filtros
    "---------------------------------------------------------

    DATA(ls_filter) =
      zcl_dmo_flight_data=>get_filters(
        io_request
      ).


    "---------------------------------------------------------
    " Dataset completo
    "---------------------------------------------------------

    DATA(lt_data) =
      zcl_dmo_flight_data=>get_detail(
        ls_filter
      ).


    "---------------------------------------------------------
    " COUNT ANTES DEL PAGING
    "---------------------------------------------------------

    IF io_request->is_total_numb_of_rec_requested( ).

      io_response->set_total_number_of_records(
        lines( lt_data )
      ).

    ENDIF.


    IF io_request->is_data_requested( ) = abap_false.
      RETURN.
    ENDIF.


    "---------------------------------------------------------
    " SORTING
    "---------------------------------------------------------

    DATA(lt_sort_elements) =
      io_request->get_sort_elements( ).

    DATA lt_sort_order
      TYPE abap_sortorder_tab.


    LOOP AT lt_sort_elements
      INTO DATA(ls_sort).

      APPEND VALUE #(

        name =
          to_upper(
            ls_sort-element_name
          )

        descending =
          ls_sort-descending

      ) TO lt_sort_order.

    ENDLOOP.


    "Orden estable por defecto
    IF lt_sort_order IS INITIAL.

      lt_sort_order = VALUE #(

        ( name = 'AIRLINEID' )

        ( name = 'CONNECTIONID' )

        ( name = 'FLIGHTDATE' )

      ).

    ENDIF.


    SORT lt_data
      STABLE
      BY (lt_sort_order).


    "---------------------------------------------------------
    " PAGING
    "---------------------------------------------------------

    DATA(lv_top) =
      io_request->get_paging( )->get_page_size( ).

    DATA(lv_skip) =
      io_request->get_paging( )->get_offset( ).


    DATA lt_page
      TYPE STANDARD TABLE OF zce_dmo_flight_dtl
      WITH EMPTY KEY.


    DATA(lv_from) =
      CONV i( lv_skip + 1 ).


    IF lv_top =
       if_rap_query_paging=>page_size_unlimited.

      LOOP AT lt_data
        INTO DATA(ls_data)
        FROM lv_from.

        APPEND ls_data
          TO lt_page.

      ENDLOOP.


    ELSE.

      DATA(lv_to) =
        CONV i(
          lv_skip +
          lv_top
        ).


      LOOP AT lt_data
        INTO ls_data
        FROM lv_from
        TO lv_to.

        APPEND ls_data
          TO lt_page.

      ENDLOOP.

    ENDIF.


    io_response->set_data(
      lt_page
    ).


  ENDMETHOD.

ENDCLASS.
