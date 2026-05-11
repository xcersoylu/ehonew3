  METHOD check_bp.
    SELECT SINGLE businesspartnergrouping
            FROM i_businesspartner
            WHERE businesspartner = @iv_businesspartner
            INTO @DATA(lv_businesspartnergrouping).
    IF sy-subrc = 0.
      SELECT SINGLE * FROM yeho_t_otoexc WHERE companycode = @ms_companycode_parameters-companycode
                                           AND businesspartnergrouping = @lv_businesspartnergrouping
      INTO @DATA(ls_otoexc).
      IF sy-subrc <> 0.
        rv_usable = abap_true.
      ENDIF.
    ENDIF.
  ENDMETHOD.