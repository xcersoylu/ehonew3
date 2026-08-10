class YEHO_JE_CO_JOURNAL_ENTRY_CREAT definition
  public
  inheriting from CL_PROXY_CLIENT
  create public .

public section.

  methods CONSTRUCTOR
    importing
      !DESTINATION type ref to IF_PROXY_DESTINATION optional
      !LOGICAL_PORT_NAME type PRX_LOGICAL_PORT_NAME optional
    preferred parameter LOGICAL_PORT_NAME
    raising
      CX_AI_SYSTEM_FAULT .
  methods JOURNAL_ENTRY_CREATE_REQUEST_C
    importing
      !INPUT type YEHO_JE_JOURNAL_ENTRY_BULK_CRE
    exporting
      !OUTPUT type YEHO_JE_JOURNAL_ENTRY_BULK_CR1
    raising
      CX_AI_SYSTEM_FAULT .