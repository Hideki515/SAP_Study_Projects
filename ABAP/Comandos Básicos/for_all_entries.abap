*&---------------------------------------------------------------------*
*& Report ZPR_BM_FOR_ALL_ENTRIES
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zpr_bm_for_all_entries.

***************
***	TABELAS	***
***************
TABLES:
  mat_handling,
  material,
  storehouse,
  branch.

***************
***	 TYPES  ***
***************
TYPES: BEGIN OF ty_it,
         movnr       TYPE mat_handling-movnr,
         branr       TYPE branch-branr,
         compnr      TYPE branch-compnr,
         whnr        TYPE storehouse-whnr,
         description TYPE storehouse-description,
         matnr       TYPE material-matnr,
         maktx       TYPE material-maktx,
         quantity    TYPE mat_handling-quantity,
         price       TYPE material-price,
         valor       TYPE material-price,
         doctype     TYPE mat_handling-doctype,
         docnr       TYPE mat_handling-docnr,
         movtyp      TYPE mat_handling-movtyp,
         erdat       TYPE mat_handling-erdat,
         entrytime   TYPE mat_handling-entrytime,
         ernam       TYPE mat_handling-ernam,
       END OF ty_it.

*************************
***	 INTERNAL TABLES  ***
*************************
DATA: it_it TYPE TABLE OF ty_it.

*******************
*** WORK AREAS  ***
*******************
DATA: wa_it TYPE ty_it.

***************************************
***         SELECT-OPTIONS          ***
***************************************
SELECTION-SCREEN BEGIN OF BLOCK b1 WITH FRAME.
SELECT-OPTIONS: s_movnr FOR mat_handling-movnr,
                s_whnr  FOR storehouse-whnr,
                s_matnr FOR mat_handling-matnr.
SELECTION-SCREEN END OF BLOCK b1.

* START-OF-SELECTION
START-OF-SELECTION.
  PERFORM zf_select_data.

* END-OF-SELECTION
END-OF-SELECTION.

*--------------------------------------------------------*
*                 Form  Z_SELECT_DATA                    *
*--------------------------------------------------------*
*   SELECIONA OS DADOS A SEREM EXIBIDOS PELO RELATÓRIO   *
*--------------------------------------------------------*
FORM zf_select_data.
  SELECT
    movnr,
    quantity,
    doctype,
    docnr,
    movtyp,
    erdat,
    entrytime,
    ernam,
    whnr,
    matnr
  INTO TABLE @DATA(lt_mat_handling)
  FROM mat_handling
  WHERE
    movnr IN @s_movnr AND
    matnr IN @s_matnr.

  SELECT DISTINCT
    whnr,
    description
  FROM storehouse
  INTO TABLE @DATA(lt_storehouse)
  FOR ALL ENTRIES IN @lt_mat_handling
  WHERE
    whnr = @lt_mat_handling-whnr AND
    whnr IN @s_whnr.

  SELECT DISTINCT
    branr,
    compnr
  INTO TABLE @DATA(lt_branch)
  FROM branch
  FOR ALL ENTRIES IN @lt_mat_handling
  WHERE branr = @lt_mat_handling-whnr.

  SELECT DISTINCT
    matnr,
    maktx,
    price
  INTO TABLE @DATA(lt_material)
  FROM material
  FOR ALL ENTRIES IN @lt_mat_handling
  WHERE matnr = @lt_mat_handling-matnr.

  LOOP AT lt_mat_handling INTO DATA(lw_mat_handling).
    READ TABLE lt_storehouse INTO DATA(lw_storehouse) WITH KEY whnr = lw_mat_handling-whnr    BINARY SEARCH.
    READ TABLE lt_branch     INTO DATA(lw_branch)     WITH KEY branr = lw_mat_handling-whnr   BINARY SEARCH.
    READ TABLE lt_material   INTO DATA(lw_material)   WITH KEY matnr = lw_mat_handling-matnr  BINARY SEARCH.

    "lw_mat_handling
    wa_it-movnr     =	lw_mat_handling-movnr.
    wa_it-quantity  = lw_mat_handling-quantity.
    wa_it-valor     = lw_mat_handling-quantity * lw_material-price.
    wa_it-doctype   = lw_mat_handling-doctype.
    wa_it-docnr     = lw_mat_handling-docnr.
    wa_it-movtyp    = lw_mat_handling-movtyp.
    wa_it-erdat     = lw_mat_handling-erdat.
    wa_it-entrytime = lw_mat_handling-entrytime.
    wa_it-ernam     = lw_mat_handling-ernam.

    "lw_branch
    wa_it-branr = lw_branch-branr.
    wa_it-compnr = lw_branch-compnr.

    "lw_storehouse
    wa_it-whnr = lw_storehouse-whnr.
    wa_it-description = lw_storehouse-description.

    "lw_material
    wa_it-matnr = lw_material-matnr.
    wa_it-maktx = lw_material-maktx.
    wa_it-price = lw_material-price.

    APPEND wa_it TO it_it.
  ENDLOOP.

  PERFORM zf_display_alv.

ENDFORM.

*--------------------------------------------------------*
*                 Form  ZF_DISPLAY_ALV                   *
*--------------------------------------------------------*
*     Exibe o relátorio ALV com os dados selecionados    *
*--------------------------------------------------------*
FORM zf_display_alv.
  DATA: lt_fieldcat TYPE lvc_t_fcat.
  DATA: lw_layout   TYPE lvc_s_layo.
  DATA: lw_saida TYPE ty_it.

  lw_layout-zebra = abap_true.
  lw_layout-cwidth_opt = abap_true.

* criação da tabela de fieldcat
  CALL FUNCTION 'STRALAN_FIELDCAT_CREATE'
    EXPORTING
      is_structure = lw_saida
    IMPORTING
      et_fieldcat  = lt_fieldcat.

  CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY_LVC'
    EXPORTING
      i_callback_program = sy-repid
      is_layout_lvc      = lw_layout
      it_fieldcat_lvc    = lt_fieldcat
    TABLES
      t_outtab           = it_it
    EXCEPTIONS
      program_error      = 1
      OTHERS             = 2.
  IF sy-subrc NE 0.
    MESSAGE s208(00) DISPLAY LIKE sy-abcde+4(1) WITH TEXT-e02.
  ENDIF.
ENDFORM.