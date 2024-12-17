*&---------------------------------------------------------------------*
*& Report ZR_ASSNETOS_OCUPADOS
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr_assentos_ocupados.

*&---------------------------------------------------------------------*
*& TYPES
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_scarr,
         carrid TYPE scarr-carrid,
       END OF ty_scarr.

TYPES: BEGIN OF ty_sflight,
         carrid   TYPE sflight-carrid,
         connid   TYPE sflight-connid,
         fldate   TYPE sflight-fldate,
         seatsocc TYPE sflight-seatsocc,
       END OF ty_sflight.

*&---------------------------------------------------------------------*
*& INTERNAL TABLES
*&---------------------------------------------------------------------*
DATA: ti_sflight TYPE TABLE OF ty_sflight,
      ti_scarr   TYPE TABLE OF ty_scarr.

"Conif FieldCat
DATA: ti_fieldcat_alv TYPE TABLE OF slis_fieldcat_alv.

*&---------------------------------------------------------------------*
*& WORK AREA
*&---------------------------------------------------------------------*
DATA: wa_sflight TYPE ty_sflight,
      wa_scarr   TYPE ty_scarr.

"Config FieldCat
DATA: wa_layout_alv   TYPE slis_layout_alv,
      wa_fieldcat_alv TYPE slis_fieldcat_alv.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM zf_selecao_dados.

*&---------------------------------------------------------------------*
*& END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
  PERFORM zf_monsta_fieldcat.
  PERFORM zf_layout_alv.
  PERFORM zf_mostra_alv.

*&---------------------------------------------------------------------*
*& Form ZF_SELECAO_DADOS
*&---------------------------------------------------------------------*
*& Seleção dos dados.
*&---------------------------------------------------------------------*
FORM zf_selecao_dados.

  SELECT carrid
    FROM scarr
    INTO TABLE ti_scarr.

  SELECT carrid
         connid
         fldate
         seatsocc
    FROM sflight
    INTO TABLE ti_sflight
    FOR ALL ENTRIES IN ti_scarr
    WHERE
    carrid = ti_scarr-carrid.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ZF_MONSTA_FIELDCAT
*&---------------------------------------------------------------------*
*& Monta tabela fieldcat
*&---------------------------------------------------------------------*
FORM zf_monsta_fieldcat .

  PERFORM zf_preenche_fieldcat USING:
        'TI_SFLIGHT' 'CARRID'   'SFLIGHT' 'CARRID',
        'TI_SFLIGHT' 'CONNID'   'SFLIGHT' 'CONNID',
        'TI_SFLIGHT' 'FLDATE'   'SFLIGHT' 'FLDATE',
        'TI_SFLIGHT' 'SEATSOCC' 'SFLIGHT' 'SEATSOCC'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ZF_PREENCHE_FIELDCAT
*&---------------------------------------------------------------------*
*& Faz o preenchimento da tabela de fieldcat
*&---------------------------------------------------------------------*
FORM zf_preenche_fieldcat USING p_tabname
                                p_fieldname
                                p_reftab
                                p_reffield.

  CLEAR wa_fieldcat_alv.
  wa_fieldcat_alv-tabname       = p_tabname.
  wa_fieldcat_alv-fieldname     = p_fieldname.
  wa_fieldcat_alv-ref_tabname   = p_reftab.
  wa_fieldcat_alv-ref_fieldname = p_reffield.
  APPEND wa_fieldcat_alv TO ti_fieldcat_alv.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ZF_LAYOUT_ALV
*&---------------------------------------------------------------------*
*& Configura o layout do alv
*&---------------------------------------------------------------------*
FORM zf_layout_alv.

  CLEAR wa_layout_alv.
  wa_layout_alv-zebra = 'X'.
  wa_layout_alv-colwidth_optimize = 'X'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ZF_MOSTRA_ALV
*&---------------------------------------------------------------------*
*& Exibe os relátorio ALV
*&---------------------------------------------------------------------*
FORM zf_mostra_alv.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      i_grid_title       = 'Assentos Ocupados'
      is_layout          = wa_layout_alv
      it_fieldcat        = ti_fieldcat_alv
    TABLES
      t_outtab           = ti_sflight
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

  IF sy-subrc <> 0.

    MESSAGE: TEXT-e01 TYPE 'S' DISPLAY LIKE 'E'.
    LEAVE TO LIST-PROCESSING.

  ENDIF.


ENDFORM.