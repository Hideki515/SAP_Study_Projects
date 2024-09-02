*&---------------------------------------------------------------------*
*&  Include           ZPR_EXEC_32_BHS_F01
*&---------------------------------------------------------------------*

*&---------------------------------------------------------------------*
*&      Form  ZF_SELECT_FILE
*&---------------------------------------------------------------------*
*& -> Seleção do local no qual o arquivo está armazenado.
*&---------------------------------------------------------------------*
FORM zf_select_file.
  DATA: lt_filetable TYPE filetable. "Variavel local do tipo filetable.
  DATA: lv_rc        TYPE i. "Variavel local do tipo inteiro.

  "Chama o metodo de janela de seleção de arquivo.
  CALL METHOD cl_gui_frontend_services=>file_open_dialog
    EXPORTING
      window_title = 'Selecione um arquivo' "Nome da janela
    CHANGING
      file_table   = lt_filetable "Guarda a localização do arquivo.
      rc           = lv_rc
    EXCEPTIONS
      OTHERS       = 1.

  IF sy-subrc = 0. "Verifica senão ocorreu erro ao seleciona o arquivo.
    READ TABLE lt_filetable INDEX 1 INTO DATA(ls_file).
    gv_filename = ls_file-filename.
    MESSAGE 'Arquivo selecionado: &1' TYPE 'S' DISPLAY LIKE 'I'.
  ELSE.
    MESSAGE 'Nenhum arquivo selecionado ou ocorreu um erro.' TYPE 'E'.
  ENDIF.

  p_loc = gv_filename.
ENDFORM.

*&---------------------------------------------------------------------*
*&      Form  ZF_UPLOAD_FILE
*&---------------------------------------------------------------------*
*& -> Upload do arquivo.
*&---------------------------------------------------------------------*

FORM zf_upload_file USING p_filename.

  "Chama a função que faz o upload do ar  arquivo.
  CALL FUNCTION 'GUI_UPLOAD'
    EXPORTING
      filename = p_filename "Local do arquivo com nome do arquivo.
    TABLES
      data_tab = it_entrada "Tabela onde os dados dos arquivos serão armazenados
    EXCEPTIONS
      OTHERS   = 1.

  IF sy-subrc <> 0.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDIF.
ENDFORM.


*&---------------------------------------------------------------------*
*&      Form  zf_process_file
*&---------------------------------------------------------------------*
*& -> Processamento do arquivo
*&---------------------------------------------------------------------*
FORM zf_process_file.

  IF rb_csv = 'X'. "Verifica se o radio button da extensão do arquivo csv está selecionado.
    LOOP AT it_entrada INTO wa_entrada. "Loop na tabela interna passando os valores do laço atual para uma work area

      CLEAR wa_bebida. "Limpa a work area atual.

      SPLIT wa_entrada AT ',' INTO wa_bebida_csv-matnr
                                   wa_bebida_csv-maktx
                                   wa_bebida_csv-meins
                                   wa_bebida_csv-brgew
                                   wa_bebida_csv-gewei
                                   wa_bebida_csv-volum
                                   wa_bebida_csv-voleh. "Separa a linha conforme ',' em seus respectivos campos.

      APPEND wa_bebida_csv TO it_bebida_csv. "Preenche a tabela interna com os dados da work area.
    ENDLOOP.

    MOVE-CORRESPONDING it_bebida_csv TO it_bebida. "Passa os dados da tabela interna para outra.

  ELSEIF rb_txt = 'X'. "Verifica se o botão de arquivo .txt está selecionado.

    LOOP AT it_entrada INTO wa_entrada. "Loop na tabela interna passando os dados da linha atual para uma work area.

      CLEAR wa_bebida. "Limpa a work area.

      wa_bebida-matnr = wa_entrada+0(18).   "Pega os valores conforme especificado.
      wa_bebida-maktx = wa_entrada+18(40).  "Pega os valores conforme especificado.
      wa_bebida-meins = wa_entrada+58(3).   "Pega os valores conforme especificado.

*      wa_bebida-brgew = wa_entrada+62(16).  "Pega os valores conforme especificado.

      WRITE wa_entrada+62(16) TO wa_bebida-brgew. "Escreve o valor do campo da work area de entrada na work area de saida.
      CONDENSE wa_bebida-brgew. "Condensa os valores tirando os espaços em branco.

      wa_bebida-brgew = '1000'.  "Pega os valores conforme especificado.
      wa_bebida-gewei = wa_entrada+79(3).   "Pega os valores conforme especificado.


      WRITE wa_entrada+82(16) TO wa_bebida-volum. "Escreve o valor do campo da work area de entrada na work area de saida.
      CONDENSE wa_bebida-volum NO-GAPS. "Condensa os valores tirando os espaços em branco.

      wa_bebida-voleh = wa_entrada+99(3).   "Pega os valores conforme especificado.

      APPEND wa_bebida TO it_bebida. "Preenche a tabela interna conforme os valores da work area.

    ENDLOOP. "Fim loop it_entrada into wa_entrada.

  ENDIF. "Fim if.

ENDFORM. "Fim form zf_process_file.

*&---------------------------------------------------------------------*
*&      FORM  ZF_PROCESS_BDC
*&---------------------------------------------------------------------*
*& -> Processa as chamadas das rotinas do BDC
*&---------------------------------------------------------------------*
FORM zf_process_bdc.

  DESCRIBE TABLE it_bebida LINES gv_lidos. "Passa a quantidade de linhas da tabela para a varialvel.

  LOOP AT it_bebida INTO wa_bebida. "Loop na tabela interna passando os dados do laço atual para uma work area.

    CALL FUNCTION 'ZFM_EXEC_33_BI_BHS'
      EXPORTING
        i_matnr    = wa_bebida-matnr
        i_maktx    = wa_bebida-maktx
        i_meins    = wa_bebida-meins
        i_brgew    = wa_bebida-brgew
        i_gewei    = wa_bebida-gewei
        i_volum    = wa_bebida-volum
        i_voleh    = wa_bebida-voleh
      TABLES
        it_erro    = it_erro
        it_sucesso = it_sucesso.

  ENDLOOP. "Fim loop it_bebida.

ENDFORM. "Fim form zf_process_bdc.

FORM zf_message.
  DATA: lv_erro TYPE i. "Variavel local.
  DATA: lv_sucesso TYPE i. "Variavel local.
  DATA: lv_total TYPE i. "Variavel local.

  DESCRIBE TABLE it_bebida LINES lv_total. "Passa a quantidade de registros para contador total.

  LOOP AT it_erro INTO wa_erro.
    ADD 1 TO lv_erro. "Adiciona um no contador de erro.
  ENDLOOP.

  LOOP AT it_sucesso INTO wa_sucesso.
    ADD 1 TO lv_sucesso. "Adiciona um no contador de sucesso.
  ENDLOOP.

  SKIP. "Pula uma linha.

  WRITE: / 'Processamento Concluído.'. "Mensagem de Processamento.
  WRITE: / lv_total, ' registros processados.' COLOR COL_TOTAL. "Quantos registros foram processados.
  WRITE: / lv_sucesso, ' registros processados com sucesso.' COLOR COL_TOTAL. "Mensagem de registros processados com sucesso.
  WRITE: / lv_erro, ' registros com erro.' COLOR COL_TOTAL. "Mensagem de registros processados com sucesso.

  CLEAR lv_erro. "Limpa o contador de errps.
  CLEAR lv_sucesso. "Limpa o contador de sucesso.
ENDFORM.