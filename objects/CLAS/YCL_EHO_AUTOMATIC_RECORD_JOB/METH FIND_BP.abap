  METHOD find_bp.
    ycl_eho_utils=>find_bp_from_iban(
      EXPORTING
        iv_iban            = CONV #( is_item-sender_iban )
      RECEIVING
        rv_businesspartner = rv_businesspartner
    ).
    IF rv_businesspartner IS INITIAL.
      IF is_item-payee_vkn = ms_companycode_parameters-tax_number.
        IF is_item-payee_vkn <> is_item-debtor_vkn.
          IF is_item-amount > 0. "102 borç çalışıcak ise müşteridir.
            ycl_eho_utils=>find_customer_from_tax_number(
            EXPORTING
              iv_tax_number = CONV #( is_item-debtor_vkn )
            RECEIVING
              rv_customer   = rv_businesspartner
          ).
          ELSE.
            ycl_eho_utils=>find_supplier_from_tax_number(
            EXPORTING
              iv_tax_number = CONV #( is_item-debtor_vkn )
            RECEIVING
              rv_supplier   = rv_businesspartner
             ).
          ENDIF.
        ELSEIF is_item-debtor_vkn = ms_companycode_parameters-tax_number.
          IF is_item-payee_vkn <> is_item-debtor_vkn.
            IF is_item-amount > 0. "102 borç çalışıcak ise müşteridir.
              ycl_eho_utils=>find_customer_from_tax_number(
              EXPORTING
                iv_tax_number = CONV #( is_item-payee_vkn )
              RECEIVING
                rv_customer   = rv_businesspartner
            ).
            ELSE.
              ycl_eho_utils=>find_supplier_from_tax_number(
              EXPORTING
                iv_tax_number = CONV #( is_item-payee_vkn )
              RECEIVING
                rv_supplier   = rv_businesspartner
               ).
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDMETHOD.