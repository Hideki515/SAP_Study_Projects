SELECTION-SCREEN PUSHBUTTON 1(30)  but1 USER-COMMAND cli1. "Comando para PushButton

PARAMETERS: p_chkbox AS CHECKBOX DEFAULT 'X' USER-COMMAND chk, "Comando para colocar CheckBox.
            p_radio  RADIOBUTTON GROUP rb USER-COMMAND rbu, "Comando para Radio Button.
            p_radio2 RADIOBUTTON GROUP rb, "Comando para Radio Button.
            p_drp    TYPE char30 AS LISTBOX VISIBLE LENGTH 30 MODIF ID pdf. "Comando para Drop List|DropDown.

INITIALIZATION.
  but1 = 'PushButton'. "Define o Texto no PushButton.



AT SELECTION-SCREEN OUTPUT.
  " Estrutura DropDown.
*&---------------------------------------------------------------------*
  CLEAR: it_funcionarios, list. "Limpa os campos

  SELECT id FROM ztb_bm_teste INTO TABLE it_funcionarios. "Seleciona o id da tabela ztb_bm_teste e passa para a tabela interna.

  LOOP AT it_funcionarios INTO wa_funcionario.
    CLEAR: lv_id.
    value-key = lv_id.
    lv_id = wa_funcionario-id. " Ajuste conforme necessário para combinar chave e texto
    APPEND VALUE #( key = lv_id text = wa_funcionario-id ) TO list.
  ENDLOOP.

  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      id     = 'P_DRP'
      values = list.

  MESSAGE p_drp TYPE 'S'.
*&---------------------------------------------------------------------*

AT SELECTION-SCREEN.

  " Estutura PushButton.
*&---------------------------------------------------------------------*
  CASE sscrfields."Case o PushButton.
    WHEN 'CLI1'. "Verifica qual PushButton foi pressionado.
      MESSAGE 'PushButton Pressionado' TYPE 'S'.
  ENDCASE.
*&---------------------------------------------------------------------*

  " Estrutura ChechBox.
*&---------------------------------------------------------------------*
  IF sy-ucomm = 'CHK'. "Verifica se o CHK está selecionado user command.
    IF p_chkbox = 'X'. "Verifica se o CheckBox está selecionado.
      MESSAGE 'Checkbox is checked' TYPE 'S'.
    ELSE.
      MESSAGE 'Checkbox is not checked' TYPE 'S'.
    ENDIF.
  ENDIF.
*&---------------------------------------------------------------------*

  " Estrutura RadioButton.
*&---------------------------------------------------------------------*
  IF sy-ucomm = 'RBU'. "Verifica se o RBU está selecionado user command.
    IF p_radio = abap_true.
      MESSAGE 'Radio is checked' TYPE 'S'.
    ELSEIF p_radio2 = abap_true.
      MESSAGE 'Radio2 is checked' TYPE 'S'.
    ENDIF.
  ENDIF.
*&---------------------------------------------------------------------*