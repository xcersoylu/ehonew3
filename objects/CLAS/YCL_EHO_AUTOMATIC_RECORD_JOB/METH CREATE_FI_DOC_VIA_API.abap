  METHOD create_fi_doc_via_api.
    TRY.
        DATA(destination) = cl_soap_destination_provider=>create_by_comm_arrangement( comm_scenario  = 'YCS_EHO_JE' ).
        DATA(lo_proxy) = NEW yeho_je_co_journal_entry_creat( destination = destination ).
        DATA(ls_request) = VALUE yeho_je_journal_entry_bulk_cre( ).
        DATA(ls_local_time_info) = ycl_eho_utils=>get_local_time( ).
        IF is_item-rule_data-customer IS NOT INITIAL.
          ls_request-journal_entry_bulk_create_requ-message_header = VALUE #( id = VALUE #( content = 'EHO' )
                                                                              creation_date_time = ls_local_time_info-timestamp ).

          APPEND VALUE #( message_header = VALUE #( id = VALUE #( content = 'EHO' )
                                                    creation_date_time = ls_local_time_info-timestamp )
                          journal_entry = VALUE #( original_reference_document_ty = 'BKPFF'
                                                   business_transaction_type      = 'RFBU'
                                                   accounting_document_type       = is_item-rule_data-document_type
                                                   document_reference_id          = is_item-rule_data-documentreferenceid
                                                   document_header_text           = is_item-rule_data-accountingdocumentheadertext
                                                   created_by_user                = sy-uname
                                                   company_code                   = is_item-rule_data-companycode
                                                   document_date                  = is_item-physical_operation_date
                                                   posting_date                   = is_item-physical_operation_date
                                                   item = VALUE #( ( reference_document_item = '001'
                                                                     glaccount = VALUE #( content = is_item-rule_data-account_no_102 )
                                                                     amount_in_transaction_currency = VALUE #( currency_code = is_item-currency content = abs( is_item-amount ) )
                                                                     document_item_text = is_item-rule_data-documentitemtext_1
                                                                     debit_credit_code = 'S'
                                                                  ) )
                                                  debtor_item = VALUE #( ( reference_document_item = '002'
                                                                             debtor = is_item-rule_data-customer
                                                                             amount_in_transaction_currency = VALUE #( currency_code = is_item-currency content = abs( is_item-amount ) * -1 )
                                                                             document_item_text = is_item-rule_data-documentitemtext_2
                                                                             debit_credit_code = 'H'
                                                                             altv_recncln_accts = VALUE #( content = is_item-rule_data-alt_recon_account )
                                                                          ) )
                                                  )
          ) TO ls_request-journal_entry_bulk_create_requ-journal_entry_create_request.
        ELSEIF is_item-rule_data-supplier IS NOT INITIAL.
          ls_request-journal_entry_bulk_create_requ-message_header = VALUE #( id = VALUE #( content = 'EHO' )
                                                                              creation_date_time = ls_local_time_info-timestamp ).

          APPEND VALUE #( message_header = VALUE #( id = VALUE #( content = 'EHO' )
                                                    creation_date_time = ls_local_time_info-timestamp )
                          journal_entry = VALUE #( original_reference_document_ty = 'BKPFF'
                                                   business_transaction_type      = 'RFBU'
                                                   accounting_document_type       = is_item-rule_data-document_type
                                                   document_reference_id          = is_item-rule_data-documentreferenceid
                                                   document_header_text           = is_item-rule_data-accountingdocumentheadertext
                                                   created_by_user                = sy-uname
                                                   company_code                   = is_item-companycode
                                                   document_date                  = is_item-physical_operation_date
                                                   posting_date                   = is_item-physical_operation_date
                                                   item = VALUE #( ( reference_document_item = '001'
                                                                     glaccount = VALUE #( content = is_item-rule_data-account_no_102 )
                                                                     amount_in_transaction_currency = VALUE #( currency_code = is_item-currency content = abs( is_item-amount ) * -1 )
                                                                     document_item_text = is_item-rule_data-documentitemtext_1
                                                                     debit_credit_code = 'H'
                                                                  ) )
                                                  creditor_item = VALUE #( ( reference_document_item = '002'
                                                                             creditor = is_item-rule_data-supplier
                                                                             amount_in_transaction_currency = VALUE #( currency_code = is_item-currency content = abs( is_item-amount ) )
                                                                             document_item_text = is_item-rule_data-documentitemtext_2
                                                                             debit_credit_code = 'S'
                                                                             altv_recncln_accts = VALUE #( content = is_item-rule_data-alt_recon_account )
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
          DATA(lo_free) = cl_bali_free_text_setter=>create( severity = if_bali_constants=>c_severity_warning
                                                            text     = CONV #( ls_log-note ) ).
          mo_log->add_item( lo_free ).
        ENDLOOP.
        IF sy-subrc <> 0.
          READ TABLE ls_response-journal_entry_bulk_create_conf-journal_entry_create_confirmat INTO DATA(ls_create_confirmat) INDEX 1.
          IF ls_create_confirmat-journal_entry_create_confirmat-accounting_document IS NOT INITIAL AND
             ls_create_confirmat-journal_entry_create_confirmat-accounting_document <> '0000000000'.
            APPEND VALUE #( companycode             = is_item-companycode
                            glaccount               = is_item-glaccount
                            receipt_no              = is_item-receipt_no
                            physical_operation_date = is_item-physical_operation_date
                            accountingdocument      = ls_create_confirmat-journal_entry_create_confirmat-accounting_document
                            fiscal_year             = ls_create_confirmat-journal_entry_create_confirmat-fiscal_year
                            internal_transfer       = '' ) TO et_saved_receipts.
            MESSAGE ID ycl_eho_utils=>mc_message_class
                    TYPE ycl_eho_utils=>mc_success
                    NUMBER 016
                    WITH ls_create_confirmat-journal_entry_create_confirmat-accounting_document
                    INTO DATA(lv_message).
            DATA(lo_message) = cl_bali_message_setter=>create( severity = if_bali_constants=>c_severity_information
                                                               id = ycl_eho_utils=>mc_message_class
                                                               number = 016
                                                               variable_1 =  CONV #( ls_create_confirmat-journal_entry_create_confirmat-accounting_document ) ).
            mo_log->add_item( lo_message ).
          ELSE.
            LOOP AT ls_create_confirmat-log-item INTO DATA(ls_error_item) WHERE severity_code = '3'.
              lo_free = cl_bali_free_text_setter=>create( severity = if_bali_constants=>c_severity_warning
                                                                text     = CONV #( ls_error_item-note ) ).
              mo_log->add_item( lo_free ).
            ENDLOOP.
          ENDIF.
        ENDIF.
      CATCH cx_ai_system_fault INTO DATA(lx_fault).
        DATA(lv_longtext) = lx_fault->get_longtext(  ).
      CATCH cx_soap_destination_error INTO DATA(lx_soap).
        lv_longtext = lx_soap->get_longtext(  ).
      CATCH cx_bali_runtime INTO DATA(lx_bali_runtime).
        lv_longtext = lx_bali_runtime->get_longtext(  ).
        IF lv_longtext IS NOT INITIAL.
          lo_free = cl_bali_free_text_setter=>create( severity = if_bali_constants=>c_severity_warning
                                                            text     = CONV #( lv_longtext ) ).
          TRY.
              mo_log->add_item( lo_free ).
            CATCH cx_bali_runtime INTO lx_bali_runtime.
          ENDTRY.
        ENDIF.
    ENDTRY.
  ENDMETHOD.