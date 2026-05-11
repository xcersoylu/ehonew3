  PRIVATE SECTION.
    DATA mt_automatic_items TYPE yeho_tt_bank_automatic_items.
    DATA mv_companycode TYPE bukrs.
    DATA mt_glaccount_range TYPE RANGE OF hkont.
    DATA mv_date TYPE datum.
    DATA mo_log TYPE REF TO if_bali_log.
    DATA ms_companycode_parameters TYPE yeho_t_company.
    METHODS get_items.
    METHODS get_rule CHANGING ct_items TYPE yeho_tt_bank_automatic_items.
    METHODS get_rule_data
      IMPORTING
        iv_rule_no       TYPE posnr
      RETURNING
        VALUE(rs_result) TYPE yeho_s_rule_data.
    METHODS create_journal_entry.
    METHODS get_tax_ratio IMPORTING iv_taxcode      TYPE mwskz
                                    iv_companycode  TYPE bukrs
                          RETURNING VALUE(rv_ratio) TYPE yeho_e_tax_ratio.
    METHODS find_bp IMPORTING is_item                   TYPE yeho_s_bank_automatic_items
                    RETURNING VALUE(rv_businesspartner) TYPE i_businesspartner-businesspartner.
    METHODS check_bp IMPORTING iv_businesspartner TYPE i_businesspartner-businesspartner
                     RETURNING VALUE(rv_usable)   TYPE abap_boolean.