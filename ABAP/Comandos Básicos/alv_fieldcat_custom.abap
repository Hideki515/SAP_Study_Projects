DATA: lt_fieldcat TYPE slis_t_fieldcat_alv.
DATA: lw_fieldcat TYPE LINE OF slis_t_fieldcat_alv.
DATA: lw_layout   TYPE slis_layout_alv.

lw_fieldcat-fieldname = 'carrid'. "Nome do campo a ter o nome mudado na exibição do ALV.
lw_fieldcat-seltext_l = 'Código Compania Aerea'. "Nome que vai aparecer na exibição do relatorio ALV.
APPEND lw_fieldcat TO lt_fieldcat. "Adiciona a linha a uma tabela interna.
CLEAR lw_fieldcat. "limpa o conteúdo da workarea.

CALL FUNCTION 'REUSE_ALV_GRID_DISPLAY'
  EXPORTING
    i_callback_program = sy-repid
    i_grid_title       = 'Title'
*   i_save             = sy-abcde(1) "Utilizado para salvar o layout do ALV
*   is_variant         = gv_variant  "Utilizado para salvar o layout do ALV
    is_layout          = lw_layout "Aqui passa o Layout do ALV
    it_fieldcat        = lt_fieldcat "Aqui é passado a estrutura do ALV
  TABLES
    t_outtab           = it_saida. "Aqui passa os valores a serem exibidos no ALV

IF sy-subrc NE 0.
  MESSAGE s208(00) DISPLAY LIKE sy-abcde+4(1) WITH TEXT-e02.
ENDIF.