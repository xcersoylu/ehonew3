  METHOD create_arbitrage_doc1.
    TYPES : BEGIN OF ty_currencyamount,
              currencyrole           TYPE string,
              journalentryitemamount TYPE yeho_e_wrbtr,
              currency               TYPE waers,
              taxamount              TYPE yeho_e_wrbtr,
              taxbaseamount          TYPE yeho_e_wrbtr,
            END OF ty_currencyamount.
    TYPES tt_currencyamount TYPE TABLE OF ty_currencyamount WITH EMPTY KEY.
    TYPES : BEGIN OF ty_glitem,
              glaccountlineitem             TYPE string,
              glaccount                     TYPE saknr,
              assignmentreference           TYPE dzuonr,
              reference1idbybusinesspartner TYPE xref1,
              reference2idbybusinesspartner TYPE xref2,
              reference3idbybusinesspartner TYPE xref3,
              costcenter                    TYPE kostl,
              profitcenter                  TYPE prctr,
              orderid                       TYPE aufnr,
              documentitemtext              TYPE sgtxt,
              specialglcode                 TYPE yeho_e_umskz,
              taxcode                       TYPE mwskz,
              _currencyamount               TYPE tt_currencyamount,
            END OF ty_glitem.
    DATA lt_je             TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post.
    DATA lt_glitem         TYPE TABLE OF ty_glitem.
    DATA lv_amount_usd TYPE yeho_e_wrbtr.
    DATA lv_amount_eur TYPE yeho_e_wrbtr.
    IF is_item-currency = 'USD'.
      lv_amount_eur = ( mv_usd / mv_eur ) * is_item-amount.
    ELSEIF is_item-currency = 'EUR'.
      lv_amount_usd = ( mv_eur / mv_usd ) * is_item-amount.
    ELSEIF is_item-currency = 'TRY'.
      IF is_item-arbitrage-arbitrage_currency = 'EUR'.
        lv_amount_usd = is_item-amount / mv_usd.
      ELSEIF is_item-arbitrage-arbitrage_currency = 'USD'.
        lv_amount_eur = is_item-amount / mv_eur.
      ENDIF.
    ENDIF.
    APPEND INITIAL LINE TO lt_je ASSIGNING FIELD-SYMBOL(<fs_je>).
    TRY.
        <fs_je>-%cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
        APPEND VALUE #( glaccountlineitem             = |001|
                        glaccount                     = is_item-glaccount
                        assignmentreference           = is_item-assignmentreference
                        reference1idbybusinesspartner = is_item-reference1idbybusinesspartner
                        reference2idbybusinesspartner = is_item-reference2idbybusinesspartner
                        reference3idbybusinesspartner = is_item-reference3idbybusinesspartner
                        documentitemtext              = is_item-documentitemtext102
*                        _currencyamount = VALUE #( ( currencyrole = '00'
*                                                    journalentryitemamount = is_item-amount
*                                                    currency = is_item-currency  )
*                                                    ( currencyrole = COND #( WHEN is_item-arbitrage-arbitrage_currency = 'USD' THEN ms_companycode_parameter-currency_type_usd
*                                                                             WHEN is_item-arbitrage-arbitrage_currency = 'EUR' THEN ms_companycode_parameter-currency_type_eur
*                                                                             ELSE '10' )
*                                                      journalentryitemamount = is_item-arbitrage-arbitrage_amount
*                                                      currency = is_item-arbitrage-arbitrage_currency  ) ) "arbitraj para birimine göre olan satır ekleniyor.
                        _currencyamount = VALUE #( ( currencyrole = '00'
                                                    journalentryitemamount = is_item-amount
                                                    currency = is_item-currency
                                                   )
                                                    ( currencyrole = COND #( WHEN is_item-arbitrage-arbitrage_currency = 'USD' THEN ms_companycode_parameter-currency_type_usd
                                                                             WHEN is_item-arbitrage-arbitrage_currency = 'EUR' THEN ms_companycode_parameter-currency_type_eur
                                                                             ELSE '10' )
                                                      journalentryitemamount = is_item-arbitrage-arbitrage_amount
                                                      currency = is_item-arbitrage-arbitrage_currency
                                                    ) "arbitraj para birimine göre olan satır ekleniyor.

                                                    ( currencyrole = COND #( WHEN is_item-currency = 'USD' THEN ms_companycode_parameter-currency_type_eur
                                                                             WHEN is_item-currency = 'EUR' THEN ms_companycode_parameter-currency_type_usd
                                                                             when is_item-currency = 'TRY' then cond #( when is_item-arbitrage-arbitrage_currency = 'USD' then ms_companycode_parameter-currency_type_eur
                                                                                                                        when is_item-arbitrage-arbitrage_currency = 'EUR' then ms_companycode_parameter-currency_type_usd ) )
                                                      journalentryitemamount = COND #( WHEN is_item-currency = 'USD' THEN lv_amount_eur
                                                                                       WHEN is_item-currency = 'EUR' THEN lv_amount_usd
                                                                                       when is_item-currency = 'TRY' then cond #( when is_item-arbitrage-arbitrage_currency = 'USD' then lv_amount_eur
                                                                                                                                  when is_item-arbitrage-arbitrage_currency = 'EUR' then lv_amount_usd )
                                                                                       )
                                                      currency = COND #( WHEN is_item-currency = 'USD' THEN 'EUR'
                                                                         WHEN is_item-currency = 'EUR' THEN 'USD'
                                                                         when is_item-currency = 'TRY' then cond #( when is_item-arbitrage-arbitrage_currency = 'USD' then 'EUR'
                                                                                                                        when is_item-arbitrage-arbitrage_currency = 'EUR' then 'USD' )  )
                                                    )
                                                    )
                                         ) TO lt_glitem.

        APPEND VALUE #( glaccountlineitem             = |002|
                        glaccount                     = is_item-arbitrage-arbitrage_account
                        assignmentreference           = is_item-arbitrage-arbitrage_assignmentreference
                        reference1idbybusinesspartner = is_item-arbitrage-arbitrage_reference1
                        reference2idbybusinesspartner = is_item-arbitrage-arbitrage_reference2
                        reference3idbybusinesspartner = is_item-arbitrage-arbitrage_reference3
                        documentitemtext              = is_item-arbitrage-arbitrage_item_text
                        _currencyamount = VALUE #( ( currencyrole = '00'
                                            journalentryitemamount = is_item-amount * -1
                                            currency = is_item-currency  )
                                                    ( currencyrole = COND #( WHEN is_item-arbitrage-arbitrage_currency = 'USD' THEN ms_companycode_parameter-currency_type_usd
                                                                             WHEN is_item-arbitrage-arbitrage_currency = 'EUR' THEN ms_companycode_parameter-currency_type_eur
                                                                             ELSE '10' )
                                                      journalentryitemamount = is_item-arbitrage-arbitrage_amount * -1
                                                      currency = is_item-arbitrage-arbitrage_currency  )  "arbitraj para birimine göre olan satır ekleniyor.
                                                    ( currencyrole = COND #( WHEN is_item-currency = 'USD' THEN ms_companycode_parameter-currency_type_eur
                                                                             WHEN is_item-currency = 'EUR' THEN ms_companycode_parameter-currency_type_usd
                                                                             when is_item-currency = 'TRY' then cond #( when is_item-arbitrage-arbitrage_currency = 'USD' then ms_companycode_parameter-currency_type_eur
                                                                                                                        when is_item-arbitrage-arbitrage_currency = 'EUR' then ms_companycode_parameter-currency_type_usd ) )
                                                      journalentryitemamount = COND #( WHEN is_item-currency = 'USD' THEN lv_amount_eur * -1
                                                                                       WHEN is_item-currency = 'EUR' THEN lv_amount_usd * -1
                                                                                       when is_item-currency = 'TRY' then cond #( when is_item-arbitrage-arbitrage_currency = 'USD' then lv_amount_eur * -1
                                                                                                                                  when is_item-arbitrage-arbitrage_currency = 'EUR' then lv_amount_usd * -1 )
                                                                                       )
                                                      currency = COND #( WHEN is_item-currency = 'USD' THEN 'EUR'
                                                                         WHEN is_item-currency = 'EUR' THEN 'USD'
                                                                         when is_item-currency = 'TRY' then cond #( when is_item-arbitrage-arbitrage_currency = 'USD' then 'EUR'
                                                                                                                        when is_item-arbitrage-arbitrage_currency = 'EUR' then 'USD' )  )
                                                    )
                                                    )
                                            ) TO lt_glitem.

        <fs_je>-%param = VALUE #( companycode                  = is_item-companycode
                                  documentreferenceid          = is_item-documentreferenceid
                                  createdbyuser                = sy-uname
                                  businesstransactiontype      = 'RFBU'
                                  accountingdocumenttype       = is_item-document_type
                                  documentdate                 = is_item-physical_operation_date
                                  postingdate                  = is_item-physical_operation_date
                                  accountingdocumentheadertext = is_item-accountingdocumentheadertext
*                                  taxdeterminationdate         = cl_abap_context_info=>get_system_date( )
                                  _glitems                     = VALUE #( FOR wa_glitem  IN lt_glitem  ( CORRESPONDING #( wa_glitem  MAPPING _currencyamount = _currencyamount ) ) )
                                ).
        MODIFY ENTITIES OF i_journalentrytp
         ENTITY journalentry
         EXECUTE post FROM lt_je
         FAILED DATA(ls_failed)
         REPORTED DATA(ls_reported)
         MAPPED DATA(ls_mapped).
        IF ls_failed IS NOT INITIAL.
          ms_response-messages = VALUE #( BASE ms_response-messages FOR wa IN ls_reported-journalentry ( message = wa-%msg->if_message~get_text( ) messagetype = mc_error ) ).
        ELSE.
          COMMIT ENTITIES BEGIN
           RESPONSE OF i_journalentrytp
           FAILED DATA(ls_commit_failed)
           REPORTED DATA(ls_commit_reported).
          COMMIT ENTITIES END.
          IF ls_commit_failed IS INITIAL.
            MESSAGE ID ycl_eho_utils=>mc_message_class
                    TYPE ycl_eho_utils=>mc_success
                    NUMBER 016
                    WITH VALUE #( ls_commit_reported-journalentry[ 1 ]-accountingdocument OPTIONAL )
                    INTO DATA(lv_message).
            APPEND VALUE #( message = lv_message messagetype =  ycl_eho_utils=>mc_success ) TO ms_response-messages.
            rs_fi_doc-accountingdocument = VALUE #( ls_commit_reported-journalentry[ 1 ]-accountingdocument OPTIONAL ).
            rs_fi_doc-fiscalyear = VALUE #( ls_commit_reported-journalentry[ 1 ]-fiscalyear OPTIONAL ).
          ELSE.
            ms_response-messages = VALUE #( BASE ms_response-messages FOR wa_commit IN ls_commit_reported-journalentry ( message = wa_commit-%msg->if_message~get_text( ) messagetype = mc_error ) ).
          ENDIF.
        ENDIF.
      CATCH cx_uuid_error INTO DATA(lx_error).
        APPEND VALUE #( message = lx_error->get_longtext(  ) messagetype = mc_error ) TO ms_response-messages.
    ENDTRY.
  ENDMETHOD.