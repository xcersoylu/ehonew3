  METHOD find_supplier_from_tax_number.
    IF iv_tax_number IS NOT INITIAL.
      SELECT SINGLE supplier
                FROM i_supplier
                WHERE taxnumber1 = @iv_tax_number
                INTO @rv_supplier.
      IF sy-subrc <> 0.
        SELECT SINGLE supplier
                  FROM i_supplier
                  WHERE taxnumber2 = @iv_tax_number
                  INTO @rv_supplier.
      ENDIF.
    ENDIF.
  ENDMETHOD.