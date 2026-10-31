CLASS zcl_fi_tot_summary DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_rap_query_provider.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_fi_tot_summary IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
    "------------------------------------------------------------
    " FILTER
    "------------------------------------------------------------
    DATA(lv_filter) =
      io_request->get_filter( )->get_as_sql_string( ).


    "------------------------------------------------------------
    " PAGING
    "------------------------------------------------------------
    DATA(lv_offset) =
      io_request->get_paging( )->get_offset( ).

    DATA(lv_page_size) =
      io_request->get_paging( )->get_page_size( ).

    DATA(lv_max_rows) =
      COND int8(
        WHEN lv_page_size =
             if_rap_query_paging=>page_size_unlimited
          THEN 2147483647
        ELSE lv_page_size
      ).


    "------------------------------------------------------------
    " SORT
    "------------------------------------------------------------
    DATA(lt_sort_elements) =
      io_request->get_sort_elements( ).

    DATA lt_order TYPE STANDARD TABLE OF string
      WITH EMPTY KEY.


    LOOP AT lt_sort_elements
      INTO DATA(ls_sort).

      DATA(lv_field) =
        to_upper( ls_sort-element_name ).


      "Solo permitimos campos conocidos.
      CASE lv_field.

        WHEN 'COMPANYCODE'
          OR 'DOCUMENTCLASS'
          OR 'FISCALYEAR'
          OR 'CURRENCY'
          OR 'UNIT'
          OR 'REVENUE'
          OR 'COST'
          OR 'MARGIN'
          OR 'QUANTITY'
          OR 'RECORDCOUNT'.

          APPEND
            |{ ls_sort-element_name }{
                COND string(
                  WHEN ls_sort-descending = abap_true
                    THEN ` DESCENDING`
                  ELSE ` ASCENDING`
                )
             }|
            TO lt_order.

      ENDCASE.

    ENDLOOP.


    DATA(lv_order_by) =
      COND string(
        WHEN lt_order IS NOT INITIAL
          THEN concat_lines_of(
                 table = lt_order
                 sep   = `, `
               )
        ELSE
          `CompanyCode, DocumentClass, FiscalYear, Currency, Unit`
      ).


    "============================================================
    " DATA
    "============================================================
    IF io_request->is_data_requested( ).

      DATA lt_result
        TYPE STANDARD TABLE OF zce_fi_tot_summary
        WITH EMPTY KEY.


      "----------------------------------------------------------
      " SIN FILTROS
      "----------------------------------------------------------
      IF lv_filter IS INITIAL.

        SELECT
          CompanyCode,
          DocumentClass,
          FiscalYear,
          Currency,
          Unit,

          SUM( Revenue )     AS Revenue,
          SUM( Cost )        AS Cost,
          SUM( Margin )      AS Margin,
          SUM( Quantity )    AS Quantity,
          SUM( RecordCount ) AS RecordCount

          FROM zi_fi_tot_demo

          GROUP BY
            CompanyCode,
            DocumentClass,
            FiscalYear,
            Currency,
            Unit

          ORDER BY (lv_order_by)

          INTO CORRESPONDING FIELDS OF TABLE @lt_result

          OFFSET @lv_offset
          UP TO @lv_max_rows ROWS.


        "----------------------------------------------------------
        " CON FILTROS
        "----------------------------------------------------------
      ELSE.

        SELECT
          CompanyCode,
          DocumentClass,
          FiscalYear,
          Currency,
          Unit,

          SUM( Revenue )     AS Revenue,
          SUM( Cost )        AS Cost,
          SUM( Margin )      AS Margin,
          SUM( Quantity )    AS Quantity,
          SUM( RecordCount ) AS RecordCount

          FROM zi_fi_tot_demo

          WHERE (lv_filter)

          GROUP BY
            CompanyCode,
            DocumentClass,
            FiscalYear,
            Currency,
            Unit

          ORDER BY (lv_order_by)

          INTO CORRESPONDING FIELDS OF TABLE @lt_result

          OFFSET @lv_offset
          UP TO @lv_max_rows ROWS.

      ENDIF.


      io_response->set_data(
        lt_result
      ).

    ENDIF.


    "============================================================
    " COUNT
    "============================================================
    IF io_request->is_total_numb_of_rec_requested( ).

      IF lv_filter IS INITIAL.

        SELECT
          CompanyCode,
          DocumentClass,
          FiscalYear,
          Currency,
          Unit

          FROM zi_fi_tot_demo

          GROUP BY
            CompanyCode,
            DocumentClass,
            FiscalYear,
            Currency,
            Unit

          INTO TABLE @DATA(lt_count).

      ELSE.

        SELECT
          CompanyCode,
          DocumentClass,
          FiscalYear,
          Currency,
          Unit

          FROM zi_fi_tot_demo

          WHERE (lv_filter)

          GROUP BY
            CompanyCode,
            DocumentClass,
            FiscalYear,
            Currency,
            Unit

          INTO TABLE @lt_count.

      ENDIF.


      io_response->set_total_number_of_records(
        lines( lt_count )
      ).

    ENDIF.

  ENDMETHOD.

ENDCLASS.
