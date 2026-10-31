CLASS zcl_fi_tot_custom_qry DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_fi_tot_custom_qry IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    "------------------------------------------------------------
    " 1. FILTER
    "------------------------------------------------------------
    DATA(lv_sql_filter) =
      io_request->get_filter( )->get_as_sql_string( ).


    "------------------------------------------------------------
    " 2. AGGREGATION REQUEST
    "
    " Ejemplo:
    "
    " grouped:
    "   COMPANYCODE
    "   DOCUMENTCLASS
    "
    " aggregated:
    "   REVENUE -> SUM
    "   COST    -> SUM
    "   MARGIN  -> SUM
    "------------------------------------------------------------
    DATA(lo_aggregation) =
      io_request->get_aggregation( ).

    DATA(lt_aggregated_elements) =
      lo_aggregation->get_aggregated_elements( ).

    DATA(lt_grouped_elements) =
      lo_aggregation->get_grouped_elements( ).


    DATA(lv_grouping) =
      concat_lines_of(
        table = lt_grouped_elements
        sep   = `, `
      ).


    "------------------------------------------------------------
    " 3. PAGING
    "------------------------------------------------------------
    DATA(lv_offset) =
      io_request->get_paging( )->get_offset( ).

    DATA(lv_page_size) =
      io_request->get_paging( )->get_page_size( ).

    DATA(lv_max_rows) =
      COND int8(
        WHEN lv_page_size =
             if_rap_query_paging=>page_size_unlimited
          THEN 0
        ELSE lv_page_size
      ).


    "------------------------------------------------------------
    " 4. SORT
    "------------------------------------------------------------
    DATA(lt_sort_elements) =
      io_request->get_sort_elements( ).

    DATA lt_sort_criteria TYPE string_table.

    LOOP AT lt_sort_elements
      ASSIGNING FIELD-SYMBOL(<ls_sort>).

      APPEND
        |{ <ls_sort>-element_name }{
           COND string(
             WHEN <ls_sort>-descending = abap_true
               THEN ` descending`
             ELSE ` ascending`
           )
         }|
        TO lt_sort_criteria.

    ENDLOOP.


    DATA(lv_sort_string) =
      COND string(

        WHEN lt_sort_criteria IS NOT INITIAL

          THEN concat_lines_of(
                 table = lt_sort_criteria
                 sep   = `, `
               )

        WHEN lt_grouped_elements IS NOT INITIAL

          THEN lv_grouping

        ELSE

          `UUID`

      ).


    "------------------------------------------------------------
    " 5. DATA
    "------------------------------------------------------------
    IF io_request->is_data_requested( ).

      DATA(lt_requested_elements) =
        io_request->get_requested_elements( ).


      "----------------------------------------------------------
      " Convertimos:
      "
      " REVENUE
      "
      " en:
      "
      " SUM( REVENUE ) AS REVENUE
      "
      " según lo solicitado por Fiori/OData.
      "----------------------------------------------------------
      LOOP AT lt_aggregated_elements
        ASSIGNING FIELD-SYMBOL(<ls_aggregate>).

        "Evitar:
        "
        "REVENUE,
        "SUM( REVENUE ) AS REVENUE
        "
        DELETE lt_requested_elements
          WHERE table_line =
                <ls_aggregate>-result_element.


        DATA(lv_aggregation_expression) =
          |{ <ls_aggregate>-aggregation_method }( | &&
          |{ <ls_aggregate>-input_element } ) AS | &&
          |{ <ls_aggregate>-result_element }|.


        APPEND lv_aggregation_expression
          TO lt_requested_elements.

      ENDLOOP.


      DATA(lv_select_list) =
        concat_lines_of(
          table = lt_requested_elements
          sep   = `, `
        ).


      DATA lt_result
        TYPE STANDARD TABLE OF zce_fi_tot_custom
        WITH EMPTY KEY.


      "----------------------------------------------------------
      " A) CONSULTA ANALÍTICA
      "
      " Fiori pidió GROUP BY
      "----------------------------------------------------------
      IF lt_grouped_elements IS NOT INITIAL.


        SELECT (lv_select_list)
          FROM zi_fi_tot_demo
          WHERE (lv_sql_filter)
          GROUP BY (lv_grouping)
          ORDER BY (lv_sort_string)
          INTO CORRESPONDING FIELDS OF TABLE @lt_result
          OFFSET @lv_offset
          UP TO @lv_max_rows ROWS.


        "----------------------------------------------------------
        " B) GRAND TOTAL
        "
        " Hay agregaciones pero no dimensiones.
        "
        " SELECT SUM(...)
        "
        " El resultado es una única fila, por lo que no aplicamos
        " OFFSET / ORDER BY de base de datos.
        "----------------------------------------------------------
      ELSEIF lt_aggregated_elements IS NOT INITIAL.

        IF lv_offset = 0
           AND
           ( lv_page_size = if_rap_query_paging=>page_size_unlimited
             OR lv_page_size > 0 ).

          SELECT (lv_select_list)
            FROM zi_fi_tot_demo
            WHERE (lv_sql_filter)
            INTO CORRESPONDING FIELDS OF TABLE @lt_result.

        ENDIF.


        "----------------------------------------------------------
        " C) LISTADO NORMAL
        "----------------------------------------------------------
      ELSE.


        SELECT (lv_select_list)
          FROM zi_fi_tot_demo
          WHERE (lv_sql_filter)
          ORDER BY (lv_sort_string)
          INTO CORRESPONDING FIELDS OF TABLE @lt_result
          OFFSET @lv_offset
          UP TO @lv_max_rows ROWS.


      ENDIF.


      io_response->set_data( lt_result ).

    ENDIF.


    "------------------------------------------------------------
    " 6. COUNT
    "
    " Fiori Elements siempre suele pedir $count.
    "------------------------------------------------------------
    IF io_request->is_total_numb_of_rec_requested( ).


      "----------------------------------------------------------
      " Si estamos agrupando:
      "
      " CompanyCode
      "
      " 1000
      " 2000
      " 3000
      "
      " count = 3
      "
      " NO 108
      "----------------------------------------------------------
      IF lt_grouped_elements IS NOT INITIAL.

        DATA lt_count_result
          TYPE STANDARD TABLE OF zce_fi_tot_custom
          WITH EMPTY KEY.


        SELECT (lv_grouping)
          FROM zi_fi_tot_demo
          WHERE (lv_sql_filter)
          GROUP BY (lv_grouping)
          INTO CORRESPONDING FIELDS OF TABLE @lt_count_result.


        io_response->set_total_number_of_records(
          lines( lt_count_result )
        ).


        "----------------------------------------------------------
        " Grand total solamente
        "----------------------------------------------------------
      ELSEIF lt_aggregated_elements IS NOT INITIAL.


        io_response->set_total_number_of_records( 1 ).


        "----------------------------------------------------------
        " Consulta normal
        "----------------------------------------------------------
      ELSE.


        SELECT COUNT( * )
          FROM zi_fi_tot_demo
          WHERE (lv_sql_filter)
          INTO @DATA(lv_count).


        io_response->set_total_number_of_records(
          lv_count
        ).


      ENDIF.

    ENDIF.

  ENDMETHOD.

ENDCLASS.
