  METHOD find_bp_from_iban.
    IF iv_iban IS NOT INITIAL.
      SELECT SINGLE businesspartner
              FROM i_businesspartnerbank
              WHERE iban = @iv_iban
              INTO @rv_businesspartner.
    ENDIF.
  ENDMETHOD.