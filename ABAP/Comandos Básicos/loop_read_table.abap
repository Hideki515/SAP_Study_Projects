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

* START-OF-SELECTION
START-OF-SELECTION.
  PERFORM zf_select_data.

* END-OF-SELECTION
END-OF-SELECTION.

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
    FROM mat_handling
    INTO TABLE @DATA(lt_mat_handling). "Select principal que serão usado para compara entre os selects. 

  LOOP AT lt_mat_handling ASSIGNING FIELD-SYMBOL(<fs_mat_handling>). "Realiza um loop na tabela interna e assina ela com fiel-symbol.

    SELECT DISTINCT "Puxa o campo da tabela que faz a comparação e o campo que se espera retorno.
      whnr,
      description
      FROM storehouse
      INTO TABLE @DATA(lt_storehouse)
      WHERE whnr = @<fs_mat_handling>-whnr AND whnr IN @s_whnr. "Compara os valore para verificar se são do mesmo registro

    SELECT DISTINCT "Puxa o campo da tabela que faz a comparação e o campo que se espera retorno.
      branr,
      compnr
      FROM branch
      INTO TABLE @DATA(lt_branch)
      WHERE branr = @<fs_mat_handling>-whnr. "Compara os valore para verificar se são do mesmo registro

    SELECT DISTINCT "Puxa o campo da tabela que faz a comparação e o campo que se espera retorno.
      matnr,
      maktx,
      price
      FROM material
      INTO TABLE @DATA(lt_material)
      WHERE matnr = @<fs_mat_handling>-matnr. "Compara os valore para verificar se são do mesmo registro

    READ TABLE lt_storehouse INTO DATA(lw_storehouse) WITH KEY whnr = <fs_mat_handling>-whnr. "Realiza uma busca será realizada na tabela interna e define uma variável local e atribui o tipo automaticamente com base no conteúdo da linha da tabela comparando o valor da tabela com o valor do field symbol.
    READ TABLE lt_branch INTO DATA(lw_branch) WITH KEY branr = <fs_mat_handling>-whnr. "Realiza uma busca será realizada na tabela interna e define uma variável local e atribui o tipo automaticamente com base no conteúdo da linha da tabela comparando o valor da tabela com o valor do field symbol.
    READ TABLE lt_material INTO DATA(lw_material) WITH KEY matnr = <fs_mat_handling>-matnr."Realiza uma busca será realizada na tabela interna e define uma variável local e atribui o tipo automaticamente com base no conteúdo da linha da tabela comparando o valor da tabela com o valor do field symbol.

    wa_it-movnr = <fs_mat_handling>-movnr. "Passa o valor para a work area
    wa_it-branr = lw_branch-branr. "Passa o valor para a work area
    wa_it-compnr = lw_branch-compnr. "Passa o valor para a work area
    wa_it-whnr = lw_storehouse-whnr. "Passa o valor para a work area
    wa_it-description = lw_storehouse-description. "Passa o valor para a work area
    wa_it-matnr = lw_material-matnr. "Passa o valor para a work area
    wa_it-maktx = lw_material-maktx. "Passa o valor para a work area
    wa_it-quantity = <fs_mat_handling>-quantity. "Passa o valor para a work area
    wa_it-price = lw_material-price. "Passa o valor para a work area
    wa_it-valor = <fs_mat_handling>-quantity * lw_material-price. "Passa o valor para a work area
    wa_it-doctype = <fs_mat_handling>-doctype. "Passa o valor para a work area
    wa_it-docnr = <fs_mat_handling>-docnr. "Passa o valor para a work area
    wa_it-movtyp = <fs_mat_handling>-movtyp. "Passa o valor para a work area
    wa_it-erdat = <fs_mat_handling>-erdat. "Passa o valor para a work area
    wa_it-entrytime = <fs_mat_handling>-entrytime. "Passa o valor para a work area
    wa_it-ernam = <fs_mat_handling>-ernam. "Passa o valor para a work area

    APPEND wa_it TO it_it. "Passa o valor da work area para a tabela interna
  ENDLOOP.

  PERFORM zf_display_alv.