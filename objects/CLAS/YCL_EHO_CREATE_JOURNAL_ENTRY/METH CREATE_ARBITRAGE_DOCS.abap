  METHOD create_arbitrage_docs.
*arbitraj alalarını tabloya yaz.
    UPDATE yeho_t_offlinedt
      SET arbitrage_account             = @is_item-arbitrage-arbitrage_account,
          arbitrage_currency            = @is_item-arbitrage-arbitrage_currency,
          arbitrage_exchange_type       = @is_item-arbitrage-arbitrage_exchange_type,
          arbitrage_exchangerate        = @is_item-arbitrage-arbitrage_exchangerate,
          arbitrage_amount              = @is_item-arbitrage-arbitrage_amount,
          arbitrage_assignmentreference = @is_item-arbitrage-arbitrage_assignmentreference,
          arbitrage_item_text           = @is_item-arbitrage-arbitrage_item_text,
          arbitrage_documentreferenceid = @is_item-arbitrage-arbitrage_documentreferenceid,
          arbitrage_reference1          = @is_item-arbitrage-arbitrage_reference1,
          arbitrage_reference2          = @is_item-arbitrage-arbitrage_reference2,
          arbitrage_reference3          = @is_item-arbitrage-arbitrage_reference3
      WHERE companycode                 = @is_item-companycode
        AND glaccount                   = @is_item-glaccount
        AND receipt_no                  = @is_item-receipt_no
        AND physical_operation_date     = @is_item-physical_operation_date
        AND currency                    = @is_item-currency.
    IF sy-subrc = 0.
      COMMIT WORK AND WAIT.
    ENDIF.
    DATA(ls_fi_doc1) = create_arbitrage_doc1( is_item = is_item ).
    IF ls_fi_doc1-accountingdocument IS NOT INITIAL.
      DATA(ls_fi_doc2) = create_arbitrage_doc2( is_item = is_item ).
      APPEND VALUE #( companycode             = is_item-companycode
                      glaccount               = is_item-glaccount
                      receipt_no              = is_item-receipt_no
                      physical_operation_date = is_item-physical_operation_date
                      accountingdocument      = ls_fi_doc1-accountingdocument
                      fiscal_year             = ls_fi_doc1-fiscalyear
                      arbitrage_document      = ls_fi_doc2-accountingdocument
                      arbitrage_fiscal_year   = ls_fi_doc2-fiscalyear
                     ) TO ms_response-journal_entry.
      APPEND VALUE #( companycode             = is_item-companycode
                      glaccount               = is_item-glaccount
                      receipt_no              = is_item-receipt_no
                      physical_operation_date = is_item-physical_operation_date
                      accountingdocument      = ls_fi_doc1-accountingdocument
                      fiscal_year             = ls_fi_doc1-fiscalyear
                      arbitrage_document      = ls_fi_doc2-accountingdocument
                      arbitrage_fiscal_year   = ls_fi_doc2-fiscalyear
                      ) TO ct_saved_receipts.
    ENDIF.
  ENDMETHOD.