*&---------------------------------------------------------------------*
*& Report ZR_CONSULTA_SIMPLES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr_consulta_simples.

*&---------------------------------------------------------------------*
*& TABLES
*&---------------------------------------------------------------------*
TABLES: sflight.

*&---------------------------------------------------------------------*
*& TYPES
*&---------------------------------------------------------------------*
TYPES: BEGIN OF ty_sflight,
         carrid   TYPE sflight-carrid,
         connid   TYPE sflight-connid,
         fldate   TYPE sflight-fldate,
         seatsmax TYPE sflight-seatsmax,
         seatsocc TYPE sflight-seatsocc,
       END OF ty_sflight.

TYPES: BEGIN OF ty_saida,
         carrid   TYPE sflight-carrid,
         connid   TYPE sflight-connid,
         fldate   TYPE sflight-fldate,
         seatsfre TYPE char10,
       END OF ty_saida.

*&---------------------------------------------------------------------*
*& INTERNAL TABLES
*&---------------------------------------------------------------------*
DATA: ti_sflight      TYPE TABLE OF ty_sflight,
      ti_saida        TYPE TABLE OF ty_saida,
      ti_fieldcat_alv TYPE TABLE OF slis_fieldcat_alv.

*&---------------------------------------------------------------------*
*& WORK AREA
*&---------------------------------------------------------------------*
DATA: wa_sflight      TYPE ty_sflight,
      wa_saida        TYPE ty_saida,
      wa_layout_alv   TYPE slis_layout_alv,
      wa_fieldcat_alv TYPE slis_fieldcat_alv.

*&---------------------------------------------------------------------*
*& SELECTION-SCREEN
*&---------------------------------------------------------------------*
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME TITLE TEXT-t01.

SELECT-OPTIONS: s_carrid FOR sflight-carrid,
                s_connid FOR sflight-connid,
                s_fldate FOR sflight-fldate.

SELECTION-SCREEN END OF BLOCK b1.

*&---------------------------------------------------------------------*
*& START-OF-SELECTION
*&---------------------------------------------------------------------*
START-OF-SELECTION.
  PERFORM zf_selecao_dados.

*&---------------------------------------------------------------------*
*& END-OF-SELECTION
*&---------------------------------------------------------------------*
END-OF-SELECTION.
  PERFORM zf_processamento_dados.
  PERFORM zf_monta_fieldcat.
  PERFORM zf_layout_alv.
  PERFORM zf_mostra_alv.

*&---------------------------------------------------------------------*
*& Form ZF_SELECAO_DADOS
*&---------------------------------------------------------------------*
*& Seleção do dados com base nos parâmetros de entrada.
*&---------------------------------------------------------------------*
FORM zf_selecao_dados .

  SELECT carrid
         connid
         fldate
         seatsmax
         seatsocc
    FROM sflight
    INTO TABLE ti_sflight
    WHERE
    carrid IN s_carrid AND
    connid IN s_connid AND
    fldate IN s_fldate.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ZF_PROCESSAMENTO_DADOS
*&---------------------------------------------------------------------*
*& Processamento dos dados selecionados.
*&---------------------------------------------------------------------*
FORM zf_processamento_dados .

  DELETE ADJACENT DUPLICATES FROM ti_sflight COMPARING carrid connid.

  LOOP AT ti_sflight INTO wa_sflight.

    CLEAR wa_saida.

    wa_saida-carrid = wa_sflight-carrid.
    wa_saida-connid = wa_sflight-connid.
    wa_saida-fldate = wa_sflight-fldate.
    wa_saida-seatsfre = ( wa_sflight-seatsmax - wa_sflight-seatsocc ).
    CONDENSE wa_saida-seatsfre NO-GAPS.

    APPEND wa_saida TO ti_saida.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ZF_MONTA_FIELDCAT
*&---------------------------------------------------------------------*
*& Monta tabela Fieldcat.
*&---------------------------------------------------------------------*
FORM zf_monta_fieldcat .

  PERFORM zf_preenche_fieldcat USING:
        'TI_SAIDA' 'CARRID'   'SFLIGHT' 'CARRID' '',
        'TI_SAIDA' 'CONNID'   'SFLIGHT' 'CONNID' '',
        'TI_SAIDA' 'FLDATE'   'SFLIGHT' 'FLDATE' '',
        'TI_SAIDA' 'SEATSFRE' ''         ''       'Seats Free'.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ZF_PREENCHE_FIELDCAT
*&---------------------------------------------------------------------*
*& Preenche a tabela de fieldcat.
*&---------------------------------------------------------------------*
FORM zf_preenche_fieldcat USING p_tabname
                                p_fieldname
                                p_tabref
                                p_fieldref
                                p_seltext_l.

  CLEAR wa_fieldcat_alv.
  wa_fieldcat_alv-tabname       = p_tabname.
  wa_fieldcat_alv-fieldname     = p_fieldname.
  wa_fieldcat_alv-ref_tabname   = p_tabref.
  wa_fieldcat_alv-ref_fieldname = p_fieldref.
  wa_fieldcat_alv-seltext_l     = p_seltext_l.
  APPEND wa_fieldcat_alv TO ti_fieldcat_alv.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ZF_LAYOUT_ALV
*&---------------------------------------------------------------------*
*& Monta o Layout do alv.
*&---------------------------------------------------------------------*
FORM zf_layout_alv.

  wa_layout_alv-zebra             = 'X'.
  wa_layout_alv-colwidth_optimize = 'X'.

ENDFORM.

FORM zf_mostra_alv.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
    EXPORTING
      i_callback_program = sy-repid
      i_grid_title       = 'Assentos Livres'
      is_layout          = wa_layout_alv
      it_fieldcat        = ti_fieldcat_alv
    TABLES
      t_outtab           = ti_saida
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.

  IF sy-subrc <> 0.

    MESSAGE: TEXT-e01 TYPE 'E' DISPLAY LIKE 'S'.
    LEAVE TO LIST-PROCESSING.

  ENDIF.


ENDFORM.