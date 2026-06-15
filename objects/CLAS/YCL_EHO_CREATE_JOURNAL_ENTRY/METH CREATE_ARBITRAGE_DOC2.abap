  METHOD create_arbitrage_doc2.
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
            END OF ty_glitem,
            BEGIN OF ty_aritems, "kunnr
              glaccountlineitem             TYPE string,
              customer                      TYPE kunnr,
              glaccount                     TYPE hkont,
              paymentmethod                 TYPE dzlsch,
              paymentterms                  TYPE dzterm,
              assignmentreference           TYPE dzuonr,
              profitcenter                  TYPE prctr,
              creditcontrolarea             TYPE kkber,
              reference1idbybusinesspartner TYPE xref1,
              reference2idbybusinesspartner TYPE xref2,
              reference3idbybusinesspartner TYPE xref3,
              documentitemtext              TYPE sgtxt,
              specialglcode                 TYPE yeho_e_umskz,
              _currencyamount               TYPE tt_currencyamount,
            END OF ty_aritems,
            BEGIN OF ty_apitems, "lifnr
              glaccountlineitem             TYPE string,
              supplier                      TYPE lifnr,
              glaccount                     TYPE hkont,
              paymentmethod                 TYPE dzlsch,
              paymentterms                  TYPE dzterm,
              assignmentreference           TYPE dzuonr,
              profitcenter                  TYPE prctr,
              creditcontrolarea             TYPE kkber,
              reference1idbybusinesspartner TYPE xref1,
              reference2idbybusinesspartner TYPE xref2,
              reference3idbybusinesspartner TYPE xref3,
              documentitemtext              TYPE sgtxt,
              specialglcode                 TYPE yeho_e_umskz,
              _currencyamount               TYPE tt_currencyamount,
            END OF ty_apitems,
            BEGIN OF ty_taxitems,
              glaccountlineitem     TYPE string,
              taxcode               TYPE mwskz,
              taxitemclassification TYPE ktosl,
              conditiontype         TYPE kschl,
              taxcountry            TYPE fot_tax_country,
              taxrate               TYPE yeho_e_tax_ratio,
              _currencyamount       TYPE tt_currencyamount,
            END OF ty_taxitems.

    DATA lt_je             TYPE TABLE FOR ACTION IMPORT i_journalentrytp~post.
    DATA lt_glitem         TYPE TABLE OF ty_glitem.
    DATA lt_apitem         TYPE TABLE OF ty_apitems.
    DATA lt_aritem         TYPE TABLE OF ty_aritems.
    DATA lt_taxitem        TYPE TABLE OF ty_taxitems.
    DATA lv_amount_usd TYPE yeho_e_wrbtr.
    DATA lv_amount_eur TYPE yeho_e_wrbtr.
    IF is_item-currency = 'USD'.
      lv_amount_eur = ( mv_usd / mv_eur ) * is_item-amount.
    ELSEIF is_item-currency = 'EUR'.
      lv_amount_usd = ( mv_eur / mv_usd ) * is_item-amount.
    ENDIF.
    APPEND INITIAL LINE TO lt_je ASSIGNING FIELD-SYMBOL(<fs_je>).
    TRY.
        <fs_je>-%cid = to_upper( cl_uuid_factory=>create_system_uuid( )->create_uuid_x16( ) ).
        APPEND VALUE #( glaccountlineitem             = |001|
                        glaccount                     = is_item-arbitrage-arbitrage_account
                        assignmentreference           = is_item-arbitrage-arbitrage_assignmentreference
                        reference1idbybusinesspartner = is_item-arbitrage-arbitrage_reference1
                        reference2idbybusinesspartner = is_item-arbitrage-arbitrage_reference2
                        reference3idbybusinesspartner = is_item-arbitrage-arbitrage_reference3
                        documentitemtext              = is_item-arbitrage-arbitrage_item_text
                        _currencyamount = VALUE #( ( currencyrole = '00'
                                                    journalentryitemamount = is_item-arbitrage-arbitrage_amount
                                                    currency = is_item-arbitrage-arbitrage_currency  )
                                                    ( currencyrole = COND #( WHEN is_item-currency = 'USD' THEN ms_companycode_parameter-currency_type_usd
                                                                             WHEN is_item-currency = 'EUR' THEN ms_companycode_parameter-currency_type_eur
                                                                             ELSE '10' )
                                                      journalentryitemamount = is_item-amount
                                                      currency = is_item-currency  )  "ilk belgenin para birimine göre olan ekleniyor.
                                                    ( currencyrole = COND #( WHEN is_item-currency = 'USD' THEN ms_companycode_parameter-currency_type_eur
                                                                             WHEN is_item-currency = 'EUR' THEN ms_companycode_parameter-currency_type_usd )
                                                      journalentryitemamount = COND #( WHEN is_item-currency = 'USD' THEN lv_amount_eur
                                                                                       WHEN is_item-currency = 'EUR' THEN lv_amount_usd  )
                                                      currency = COND #( WHEN is_item-currency = 'USD' THEN 'EUR'
                                                                         WHEN is_item-currency = 'EUR' THEN 'USD'  )
                                                    )
                                               )
                                         ) TO lt_glitem.

        IF is_item-supplier IS NOT INITIAL.
          APPEND VALUE #( glaccountlineitem             = |002|
                          supplier                      = is_item-supplier
                          glaccount                     = is_item-reconciliationaccount
                          paymentmethod                 = is_item-paymentmethod
                          paymentterms                  = is_item-paymentterms
                          assignmentreference           = is_item-assignmentreference
                          profitcenter                  = is_item-profitcenter
                          creditcontrolarea             = is_item-creditcontrolarea
                          reference1idbybusinesspartner = is_item-reference1idbybusinesspartner
                          reference2idbybusinesspartner = is_item-reference2idbybusinesspartner
                          reference3idbybusinesspartner = is_item-reference3idbybusinesspartner
                          documentitemtext              = is_item-documentitemtext
                          specialglcode                 = is_item-specialglcode
                        _currencyamount = VALUE #( ( currencyrole = '00'
                                                    journalentryitemamount = is_item-arbitrage-arbitrage_amount * -1
                                                    currency = is_item-arbitrage-arbitrage_currency  )
                                                    ( currencyrole = COND #( WHEN is_item-currency = 'USD' THEN ms_companycode_parameter-currency_type_usd
                                                                             WHEN is_item-currency = 'EUR' THEN ms_companycode_parameter-currency_type_eur
                                                                             ELSE '10' )
                                                      journalentryitemamount = is_item-amount * -1
                                                      currency = is_item-currency  ) "ilk belgenin para birimine göre olan ekleniyor.

                                                    ( currencyrole = COND #( WHEN is_item-currency = 'USD' THEN ms_companycode_parameter-currency_type_eur
                                                                             WHEN is_item-currency = 'EUR' THEN ms_companycode_parameter-currency_type_usd )
                                                      journalentryitemamount = COND #( WHEN is_item-currency = 'USD' THEN lv_amount_eur * -1
                                                                                       WHEN is_item-currency = 'EUR' THEN lv_amount_usd * -1 )
                                                      currency = COND #( WHEN is_item-currency = 'USD' THEN 'EUR'
                                                                         WHEN is_item-currency = 'EUR' THEN 'USD'  )
                                                    )

                                                    )
                                                    ) TO lt_apitem.
        ELSEIF is_item-customer IS NOT INITIAL.
          APPEND VALUE #( glaccountlineitem              = |002|
                          customer                       = is_item-customer
                           glaccount                     = is_item-reconciliationaccount
                           paymentmethod                 = is_item-paymentmethod
                           paymentterms                  = is_item-paymentterms
                           assignmentreference           = is_item-assignmentreference
                           profitcenter                  = is_item-profitcenter
                           creditcontrolarea             = is_item-creditcontrolarea
                           reference1idbybusinesspartner = is_item-reference1idbybusinesspartner
                           reference2idbybusinesspartner = is_item-reference2idbybusinesspartner
                           reference3idbybusinesspartner = is_item-reference3idbybusinesspartner
                           documentitemtext              = is_item-documentitemtext
                           specialglcode                 = is_item-specialglcode
                        _currencyamount = VALUE #( ( currencyrole = '00'
                                                    journalentryitemamount = is_item-arbitrage-arbitrage_amount * -1
                                                    currency = is_item-arbitrage-arbitrage_currency  )
                                                    ( currencyrole = COND #( WHEN is_item-currency = 'USD' THEN ms_companycode_parameter-currency_type_usd
                                                                             WHEN is_item-currency = 'EUR' THEN ms_companycode_parameter-currency_type_eur
                                                                             ELSE '10' )
                                                      journalentryitemamount = is_item-amount * -1
                                                      currency = is_item-currency  )  "ilk belgenin para birimine göre olan ekleniyor.
                                                    ( currencyrole = COND #( WHEN is_item-currency = 'USD' THEN ms_companycode_parameter-currency_type_eur
                                                                             WHEN is_item-currency = 'EUR' THEN ms_companycode_parameter-currency_type_usd )
                                                      journalentryitemamount = COND #( WHEN is_item-currency = 'USD' THEN lv_amount_eur * -1
                                                                                       WHEN is_item-currency = 'EUR' THEN lv_amount_usd * -1 )
                                                      currency = COND #( WHEN is_item-currency = 'USD' THEN 'EUR'
                                                                         WHEN is_item-currency = 'EUR' THEN 'USD'  )

                                                   ) )
                                                    ) TO lt_aritem.
        ELSEIF is_item-operationalglaccount IS NOT INITIAL.
          APPEND VALUE #( glaccountlineitem             = |002|
                          glaccount                     = is_item-operationalglaccount
                          assignmentreference           = is_item-assignmentreference
                          reference1idbybusinesspartner = is_item-reference1idbybusinesspartner
                          reference2idbybusinesspartner = is_item-reference2idbybusinesspartner
                          reference3idbybusinesspartner = is_item-reference3idbybusinesspartner
                          costcenter                    = is_item-costcenter
                          profitcenter                  = is_item-profitcenter
                          orderid                       = is_item-orderid
                          documentitemtext              = is_item-documentitemtext
                          specialglcode                 = is_item-specialglcode
                          taxcode                       = is_item-taxcode
                        _currencyamount = VALUE #( ( currencyrole = '00'
                                                    journalentryitemamount = is_item-arbitrage-arbitrage_amount * -1
                                                    currency = is_item-arbitrage-arbitrage_currency  )
                                                    ( currencyrole = COND #( WHEN is_item-currency = 'USD' THEN ms_companycode_parameter-currency_type_usd
                                                                             WHEN is_item-currency = 'EUR' THEN ms_companycode_parameter-currency_type_eur
                                                                             ELSE '10' )
                                                      journalentryitemamount = is_item-amount * -1
                                                      currency = is_item-currency  )  "ilk belgenin para birimine göre olan ekleniyor.
                                                    ( currencyrole = COND #( WHEN is_item-currency = 'USD' THEN ms_companycode_parameter-currency_type_eur
                                                                             WHEN is_item-currency = 'EUR' THEN ms_companycode_parameter-currency_type_usd )
                                                      journalentryitemamount = COND #( WHEN is_item-currency = 'USD' THEN lv_amount_eur * -1
                                                                                       WHEN is_item-currency = 'EUR' THEN lv_amount_usd * -1 )
                                                      currency = COND #( WHEN is_item-currency = 'USD' THEN 'EUR'
                                                                         WHEN is_item-currency = 'EUR' THEN 'USD'  )

                                                    )
                                                    ) ) TO lt_glitem.
        ENDIF.
        <fs_je>-%param = VALUE #( companycode                  = is_item-companycode
                                  documentreferenceid          = is_item-documentreferenceid
                                  createdbyuser                = sy-uname
                                  businesstransactiontype      = 'RFBU'
                                  accountingdocumenttype       = is_item-document_type
                                  documentdate                 = is_item-physical_operation_date
                                  postingdate                  = is_item-physical_operation_date
                                  accountingdocumentheadertext = is_item-accountingdocumentheadertext
                                  taxdeterminationdate         = cl_abap_context_info=>get_system_date( )
                                  _apitems                     = VALUE #( FOR wa_apitem  IN lt_apitem  ( CORRESPONDING #( wa_apitem  MAPPING _currencyamount = _currencyamount ) ) )
                                  _aritems                     = VALUE #( FOR wa_aritem  IN lt_aritem  ( CORRESPONDING #( wa_aritem  MAPPING _currencyamount = _currencyamount ) ) )
                                  _glitems                     = VALUE #( FOR wa_glitem  IN lt_glitem  ( CORRESPONDING #( wa_glitem  MAPPING _currencyamount = _currencyamount ) ) )
*                                    _taxitems                    = VALUE #( FOR wa_taxitem  IN lt_taxitem  ( CORRESPONDING #( wa_taxitem  MAPPING _currencyamount = _currencyamount ) ) )
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
        CLEAR : lt_je, lt_glitem , lt_apitem , lt_aritem , ls_failed ,
                ls_reported , ls_commit_failed , ls_commit_reported .
      CATCH cx_uuid_error INTO DATA(lx_error).
        APPEND VALUE #( message = lx_error->get_longtext(  ) messagetype = mc_error ) TO ms_response-messages.
    ENDTRY.

  ENDMETHOD.