  method JOURNAL_ENTRY_CREATE_REQUEST_C.

  data(lt_parmbind) = value abap_parmbind_tab(
    ( name = 'INPUT' kind = '0' value = ref #( INPUT ) )
    ( name = 'OUTPUT' kind = '1' value = ref #( OUTPUT ) )
  ).
  if_proxy_client~execute(
    exporting
      method_name = 'JOURNAL_ENTRY_CREATE_REQUEST_C'
    changing
      parmbind_tab = lt_parmbind
  ).

  endmethod.