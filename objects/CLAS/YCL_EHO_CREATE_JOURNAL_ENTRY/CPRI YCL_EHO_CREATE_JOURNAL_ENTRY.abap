  PRIVATE SECTION.
    TYPES : BEGIN OF ty_fi_doc,
              accountingdocument TYPE belnr_d,
              fiscalyear         TYPE gjahr,
            END OF ty_fi_doc,
            tt_saved_receipts TYPE TABLE OF yeho_t_savedrcpt.
    METHODS get_rule_data IMPORTING it_items TYPE yeho_tt_create_journal_items RETURNING VALUE(rt_rule_data) TYPE yeho_tt_rule_data.
    METHODS get_tax_ratio IMPORTING iv_taxcode      TYPE mwskz
                                    iv_companycode  TYPE bukrs
                          RETURNING VALUE(rv_ratio) TYPE yeho_e_tax_ratio.
    METHODS create_arbitrage_docs IMPORTING is_item TYPE yeho_s_create_journal_items CHANGING ct_saved_receipts TYPE tt_saved_receipts.
    METHODS create_arbitrage_doc1 IMPORTING is_item TYPE yeho_s_create_journal_items RETURNING VALUE(rs_fi_doc) TYPE ty_fi_doc.
    METHODS create_arbitrage_doc2 IMPORTING is_item TYPE yeho_s_create_journal_items RETURNING VALUE(rs_fi_doc) TYPE ty_fi_doc.
    DATA: ms_request               TYPE yeho_s_create_journal_req,
          ms_response              TYPE yeho_s_create_journal_res,
          ms_companycode_parameter TYPE yeho_t_company.
    CONSTANTS: mc_header_content TYPE string VALUE 'content-type',
               mc_content_type   TYPE string VALUE 'text/json',
               mc_error          TYPE messagetyp VALUE 'E'.