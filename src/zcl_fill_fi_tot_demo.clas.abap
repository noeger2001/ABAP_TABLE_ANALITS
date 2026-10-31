CLASS zcl_fill_fi_tot_demo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_fill_fi_tot_demo IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA lt_data TYPE STANDARD TABLE OF zfi_tot_demo WITH EMPTY KEY.
    DATA ls_data TYPE zfi_tot_demo.

    TRY.

        DO 108 TIMES.

          DATA(lv_idx) = sy-index - 1.

          CLEAR ls_data.

          ls_data-client = sy-mandt.

          ls_data-uuid =
            cl_system_uuid=>create_uuid_x16_static( ).

          "----------------------------------------------------
          " Sociedad
          "----------------------------------------------------
          ls_data-company_code =
            SWITCH #(
              lv_idx MOD 3
              WHEN 0 THEN '1000'
              WHEN 1 THEN '2000'
              ELSE        '3000'
            ).

          "----------------------------------------------------
          " Clase de documento
          "----------------------------------------------------
          ls_data-document_class =
            SWITCH #(
              ( lv_idx DIV 3 ) MOD 3
              WHEN 0 THEN 'SA'
              WHEN 1 THEN 'KR'
              ELSE        'DR'
            ).

          "----------------------------------------------------
          " Año fiscal
          "----------------------------------------------------
          ls_data-fiscal_year =
            SWITCH #(
              ( lv_idx DIV 9 ) MOD 3
              WHEN 0 THEN '2024'
              WHEN 1 THEN '2025'
              ELSE        '2026'
            ).

          "----------------------------------------------------
          " Periodo
          "----------------------------------------------------
          ls_data-fiscal_period =
            SWITCH #(
              ( lv_idx DIV 27 ) MOD 4
              WHEN 0 THEN '01'
              WHEN 1 THEN '04'
              WHEN 2 THEN '07'
              ELSE        '10'
            ).

          "----------------------------------------------------
          " Región
          "----------------------------------------------------
          ls_data-region =
            SWITCH #(
              ( lv_idx DIV 2 ) MOD 3
              WHEN 0 THEN 'NORTE'
              WHEN 1 THEN 'CENTRO'
              ELSE        'SUR'
            ).

          "----------------------------------------------------
          " Centro de costo
          "----------------------------------------------------
          ls_data-cost_center =
            SWITCH #(
              ( lv_idx DIV 4 ) MOD 4
              WHEN 0 THEN 'CC1000'
              WHEN 1 THEN 'CC2000'
              WHEN 2 THEN 'CC3000'
              ELSE        'CC4000'
            ).

          ls_data-document_no =
            |{ sy-index WIDTH = 10 ALIGN = RIGHT PAD = '0' }|.

          "Una moneda para que el total general sea sencillo
          ls_data-currency = 'USD'.

          "----------------------------------------------------
          " Medidas
          "----------------------------------------------------
          ls_data-revenue =
              10000
            + ( sy-index * 175 )
            + ( ( lv_idx MOD 5 ) * 250 ).

          ls_data-cost =
              6000
            + ( sy-index * 110 )
            + ( ( lv_idx MOD 7 ) * 125 ).

          ls_data-unit = 'EA'.

          ls_data-quantity =
              10
            + ( lv_idx MOD 25 ).

          APPEND ls_data TO lt_data.

        ENDDO.

      CATCH cx_uuid_error INTO DATA(lx_uuid).

        out->write(
          |Error creando UUID: { lx_uuid->get_text( ) }|
        ).

        RETURN.

    ENDTRY.

    DELETE FROM zfi_tot_demo.

    INSERT zfi_tot_demo
      FROM TABLE @lt_data.

    out->write(
      |Registros insertados: { sy-dbcnt }|
    ).


  ENDMETHOD.

ENDCLASS.
