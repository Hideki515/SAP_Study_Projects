DATA: lt_fieldcat TYPE lvc_t_fcat.
DATA: lw_layout   TYPE lvc_s_layo.
DATA: lw_saida TYPE zcds_bm_sflight.

lw_layout-zebra = abap_true.
lw_layout-cwidth_opt = abap_true.

* Criação da tabela de fieldcat
CALL FUNCTION 'STRALAN_FIELDCAT_CREATE'
  EXPORTING
    is_structure = lw_saida
  IMPORTING
    et_fieldcat  = lt_fieldcat.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
  EXPORTING
    i_callback_user_command = 'USER_COMMAND'
    i_callback_program      = sy-repid
    is_layout_lvc           = lw_layout
    it_fieldcat_lvc         = lt_fieldcat
  TABLES
    t_outtab                = it_sflight
  EXCEPTIONS
    program_error           = 1
    OTHERS                  = 2.
IF sy-subrc NE 0.
  MESSAGE s208(00) DISPLAY LIKE sy-abcde+4(1) WITH TEXT-e02.
ENDIF.

FORM user_command USING r_ucomm LIKE sy-ucomm rs_selfield TYPE slis_selfield.

  CASE r_ucomm.
    WHEN '&IC1'. "Verifica se o valor da r_ucomm está com o valor '&IC1' por default.
      CASE rs_selfield-fieldname.
        WHEN 'campo'. "Verifica qual o nome da coluna selecionada.
          "Lógica

        WHEN OTHERS.
          " Nenhuma ação específica necessária para outros casos
      ENDCASE.
  ENDCASE.
ENDFORM.