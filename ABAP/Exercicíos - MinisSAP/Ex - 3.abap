*&---------------------------------------------------------------------*
*& Report ZR_DINAMIC_SELECT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zr_dinamic_select.

TABLES: sbook.

TYPES: BEGIN OF ty_sbook,
         carrid   TYPE sbook-carrid,
         connid   TYPE sbook-connid,
         fldate   TYPE sbook-fldate,
         bookid   TYPE sbook-bookid,
         custtype TYPE sbook-custtype,
       END OF ty_sbook.

DATA: ti_sbook   TYPE TABLE OF ty_sbook.

DATA: wa_sobook TYPE ty_sbook.

SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.

SELECT-OPTIONS: s_carrid FOR sbook-carrid,
                s_connid FOR sbook-connid.

SELECTION-SCREEN END OF BLOCK b1.

START-OF-SELECTION.
  PERFORM zf_selecao_dados.
  PERFORM zf_exibir_dados.

*&---------------------------------------------------------------------*
*& Form ZF_SELECAO_DADOS
*&---------------------------------------------------------------------*
*& Seleção dos dados conforme os parâmetros de seleção
*&---------------------------------------------------------------------*
FORM zf_selecao_dados .

  SELECT carrid
         connid
         fldate
         bookid
         custtype
    FROM sbook
    INTO TABLE ti_sbook
    WHERE
    carrid IN s_carrid AND
    connid IN s_connid.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form ZF_EXIBIR_DADOS
*&---------------------------------------------------------------------*
*& Exibe os dados selecionados.
*&---------------------------------------------------------------------*
FORM zf_exibir_dados .

  cl_demo_output=>display( ti_sbook ).

ENDFORM.