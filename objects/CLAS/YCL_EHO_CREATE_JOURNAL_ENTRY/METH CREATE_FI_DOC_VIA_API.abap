  METHOD create_fi_doc_via_api.
    TRY.
        DATA(destination) = cl_soap_destination_provider=>create_by_comm_arrangement( comm_scenario  = 'YCS_EHO_JE' ).
        DATA(lo_proxy) = NEW yeho_je_co_journal_entry_creat( destination = destination ).
        DATA(ls_request) = VALUE yeho_je_journal_entry_bulk_cre( ).
        DATA(ls_local_time_info) = ycl_eho_utils=>get_local_time( ).
        IF is_item-customer IS NOT INITIAL.
          ls_request-journal_entry_bulk_create_requ-message_header = VALUE #( id = VALUE #( content = 'EHO' )
                                                                              creation_date_time = ls_local_time_info-timestamp ).

          APPEND VALUE #( message_header = VALUE #( id = VALUE #( content = 'EHO' )
                                                    creation_date_time = ls_local_time_info-timestamp )
                          journal_entry = VALUE #( original_reference_document_ty = 'BKPFF'
                                                   business_transaction_type      = 'RFBU'
                                                   accounting_document_type       = is_item-document_type
                                                   document_reference_id          = is_item-documentreferenceid
                                                   document_header_text           = is_item-accountingdocumentheadertext
                                                   created_by_user                = sy-uname
                                                   company_code                   = is_item-companycode
                                                   document_date                  = is_item-physical_operation_date
                                                   posting_date                   = is_item-physical_operation_date
                                                   item = VALUE #( ( reference_document_item = '001'
                                                                     glaccount = VALUE #( content = is_item-glaccount )
                                                                     amount_in_transaction_currency = VALUE #( currency_code = is_item-currency content = abs( is_item-amount ) )
                                                                     document_item_text = is_item-documentitemtext102
                                                                     debit_credit_code = 'S'
                                                                  ) )
                                                  debtor_item = VALUE #( ( reference_document_item = '002'
                                                                             debtor = is_item-customer
                                                                             amount_in_transaction_currency = VALUE #( currency_code = is_item-currency content = abs( is_item-amount ) * -1 )
                                                                             document_item_text = is_item-documentitemtext
                                                                             debit_credit_code = 'H'
                                                                             altv_recncln_accts = VALUE #( content = is_item-alt_recon_account )
                                                                          ) )
                                                  )
          ) TO ls_request-journal_entry_bulk_create_requ-journal_entry_create_request.
        ELSEIF is_item-supplier IS NOT INITIAL.
          ls_request-journal_entry_bulk_create_requ-message_header = VALUE #( id = VALUE #( content = 'EHO' )
                                                                              creation_date_time = ls_local_time_info-timestamp ).

          APPEND VALUE #( message_header = VALUE #( id = VALUE #( content = 'EHO' )
                                                    creation_date_time = ls_local_time_info-timestamp )
                          journal_entry = VALUE #( original_reference_document_ty = 'BKPFF'
                                                   business_transaction_type      = 'RFBU'
                                                   accounting_document_type       = is_item-document_type
                                                   document_reference_id          = is_item-documentreferenceid
                                                   document_header_text           = is_item-accountingdocumentheadertext
                                                   created_by_user                = sy-uname
                                                   company_code                   = is_item-companycode
                                                   document_date                  = is_item-physical_operation_date
                                                   posting_date                   = is_item-physical_operation_date
                                                   item = VALUE #( ( reference_document_item = '001'
                                                                     glaccount = VALUE #( content = is_item-glaccount )
                                                                     amount_in_transaction_currency = VALUE #( currency_code = is_item-currency content = abs( is_item-amount ) * -1 )
                                                                     document_item_text = is_item-documentitemtext102
                                                                     debit_credit_code = 'H'
                                                                  ) )
                                                  creditor_item = VALUE #( ( reference_document_item = '002'
                                                                             creditor = is_item-supplier
                                                                             amount_in_transaction_currency = VALUE #( currency_code = is_item-currency content = abs( is_item-amount ) )
                                                                             document_item_text = is_item-documentitemtext
                                                                             debit_credit_code = 'S'
                                                                             altv_recncln_accts = VALUE #( content = is_item-alt_recon_account )
                                                                          ) )
                                                  )
          ) TO ls_request-journal_entry_bulk_create_requ-journal_entry_create_request.
        ENDIF.
        lo_proxy->journal_entry_create_request_c(
          EXPORTING
            input = ls_request
          IMPORTING
            output = DATA(ls_response)
        ).
        LOOP AT ls_response-journal_entry_bulk_create_conf-log-item INTO DATA(ls_log) WHERE severity_code = '3'.
          APPEND VALUE #( messagetype = 'E' message = ls_log-note ) TO ms_response-messages.
        ENDLOOP.
        IF sy-subrc <> 0.
          READ TABLE ls_response-journal_entry_bulk_create_conf-journal_entry_create_confirmat INTO DATA(ls_create_confirmat) INDEX 1.
          IF ls_create_confirmat-journal_entry_create_confirmat-accounting_document IS NOT INITIAL AND
             ls_create_confirmat-journal_entry_create_confirmat-accounting_document <> '0000000000'.
            APPEND VALUE #( companycode     = is_item-companycode
                    glaccount               = is_item-glaccount
                    receipt_no              = is_item-receipt_no
                    physical_operation_date = is_item-physical_operation_date
                    accountingdocument      = ls_create_confirmat-journal_entry_create_confirmat-accounting_document
                    fiscal_year             = ls_create_confirmat-journal_entry_create_confirmat-fiscal_year ) TO ct_saved_receipts.
            MESSAGE ID ycl_eho_utils=>mc_message_class
                    TYPE ycl_eho_utils=>mc_success
                    NUMBER 016
                    WITH ls_create_confirmat-journal_entry_create_confirmat-accounting_document
                    INTO DATA(lv_message).
            APPEND VALUE #( message = lv_message messagetype =  ycl_eho_utils=>mc_success ) TO ms_response-messages.
          ELSE.
            LOOP AT ls_create_confirmat-log-item INTO DATA(ls_error_item) WHERE severity_code = '3'.
              APPEND VALUE #( messagetype = 'E' message = ls_error_item-note ) TO ms_response-messages.
            ENDLOOP.
          ENDIF.
        ENDIF.
      CATCH cx_ai_system_fault.
      CATCH cx_soap_destination_error.
    ENDTRY.
  ENDMETHOD.