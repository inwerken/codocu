class /INW/CL_CODOCU definition
  public
  final
  create private .

public section.

  class-methods CONVERT_HTML
    changing
      !CT_HTML type HTMLTABLE .
  class-methods DISPLAY
    importing
      !IV_ID type DOKU_ID
      !IV_OBJ type CLIKE
      !IV_LANGU type DOKU_LANGU default SY-LANGU
      !IV_TYP type DOKU_TYP default 'E'
      !IV_CC_NAME type CLIKE optional
      !IR_CONTAINER type ref to CL_GUI_CONTAINER optional
      !IV_LIFETIME type I optional
      !IV_SIDE type I optional
      !IV_EXTENSION type I optional
      !IV_RATIO type I optional
      !IV_REPID type SYREPID optional
      !IV_DYNNR type SYDYNNR optional .
protected section.

  data GV_DYNNR type SYDYNNR .
  data GV_REPID type SYREPID .
  data GT_DOCU_LINES type TLINE_TAB .
  data GS_DOCU_HEADER type THEAD .
  data GR_CONTAINER type ref to CL_GUI_CONTAINER .
  data GR_DISPLAY_HTML type ref to CL_GUI_HTML_VIEWER .
  data GT_CONV_CHARFORMATS type TLINE_TAB .
  data GT_CONV_PARFORMATS type TLINE_TAB .
  class-data GR_ME type ref to /INW/CL_CODOCU .

  methods CREATE_INFORMATION_NO_DOCU .
  methods SET_DOCU_SAPSCRIPT
    importing
      !IV_ID type DOKU_ID
      !IV_LANGU type DOKU_LANGU default SY-LANGU
      !IV_OBJ type DOKU_OBJ
      !IV_TYP type DOKU_TYP .
  methods SHOW_DOCU .
  methods CREATE_DISPLAY_AREA
    importing
      !IR_CONTAINER type ref to CL_GUI_CONTAINER
      !IV_LIFETIME type I
      !IV_SIDE type I
      !IV_EXTENSION type I
      !IV_RATIO type I
      !IV_CC_NAME type CLIKE
    raising
      /INW/CX_CODOCU .
private section.

  methods CONSTRUCTOR
    importing
      !IV_REPID type SYREPID
      !IV_DYNNR type SYDYNNR .
ENDCLASS.



CLASS /INW/CL_CODOCU IMPLEMENTATION.


METHOD constructor.

*== set global data
  gv_repid = iv_repid.
  gv_dynnr = iv_dynnr.


*** _______________________________________________________________ ***
***                                                                 ***
***  Convert character and parameter formats
*** _______________________________________________________________ ***
***                                                                 ***
  PERFORM build_mapping_tables IN PROGRAM rshtmimg_2
   TABLES gt_conv_charformats
          gt_conv_parformats.

ENDMETHOD.


METHOD convert_html.

*** Convert Tables
  PERFORM convert_tables IN PROGRAM rshtmimg_2 TABLES ct_html.

*** Set colours (Make text look like SAP documentation)
  PERFORM set_colors     IN PROGRAM rshtmimg_2 TABLES ct_html.

*** set table cells to size 2
  REPLACE ALL  OCCURRENCES OF '<td>' IN TABLE ct_html
     WITH '<td><font FACE="Arial" SIZE=2>'.

*** set table border "dashed" and grey background
  REPLACE ALL  OCCURRENCES OF '<table>' IN TABLE ct_html
     WITH '<table style="border:thin dashed blue" width="100%" cellpadding=4 bgcolor=#F0F0F0>'.

ENDMETHOD.


METHOD create_display_area.

  DATA lv_lifetime  TYPE i.
  DATA lv_side      TYPE i.
  DATA lv_extension TYPE i.

*== lifetime
  IF iv_lifetime IS INITIAL.
    lv_lifetime = cl_gui_docking_container=>lifetime_dynpro.
  ELSE.
    lv_lifetime = iv_lifetime.
  ENDIF.

*== side of container
  IF iv_side IS INITIAL.
    lv_side = cl_gui_docking_container=>dock_at_right.
  ELSE.
    lv_side = iv_side.
  ENDIF.

  IF iv_extension IS INITIAL.
    lv_extension = 400.
  ELSE.
    lv_extension = iv_extension.
  ENDIF.

  IF ir_container IS BOUND.
    gr_container = ir_container.
  ENDIF.

  IF gr_container IS INITIAL.
    IF iv_cc_name IS INITIAL.

*== create docking container
      CREATE OBJECT gr_container
        TYPE cl_gui_docking_container
        EXPORTING
          side                    = lv_side
          extension               = lv_extension
          lifetime                = lv_lifetime
          ratio                   = iv_ratio
          no_autodef_progid_dynnr = 'X'.
    ELSE.
*== create custom container
      CREATE OBJECT gr_container
        TYPE cl_gui_custom_container
        EXPORTING
          container_name          = iv_cc_name
          no_autodef_progid_dynnr = abap_true.
    ENDIF.
  ENDIF.

  IF gr_display_html IS INITIAL.
*== create HTML control
    CREATE OBJECT gr_display_html
      EXPORTING
        parent = gr_container.
  ENDIF.

ENDMETHOD.


METHOD create_information_no_docu.

*== local data
  FIELD-SYMBOLS <line> TYPE tline.

*== set dummy header
  gs_docu_header-tdobject = 'TEXT'.
  gs_docu_header-tdname   = 'DUMMY'.
  gs_docu_header-tdid     = 'ST'.
  gs_docu_header-tdspras  = sy-langu.
  gs_docu_header-tdtitle  = 'Dummy'.

*== set dummy lines
  APPEND INITIAL LINE TO gt_docu_lines ASSIGNING <line>.
  <line>-tdformat = 'U1'.
  <line>-tdline   = 'Kein Dokumentation vorhanden'(kdv).

ENDMETHOD.


METHOD display.

  DATA lv_langu  TYPE doku_langu.
  data lv_object TYPE DOKU_OBJ.


*== Selbstreferenz faktorieren
  IF gr_me IS INITIAL.
    CREATE OBJECT gr_me
      EXPORTING
        iv_repid = iv_repid
        iv_dynnr = iv_dynnr.
  ENDIF.

*== Eingaben übernehmen
  lv_langu  = iv_langu.
  lv_object = iv_obj.

* Hier ggf. verschiedene Sprachen abklopfen
  TRY.
      CALL METHOD gr_me->create_display_area
        EXPORTING
          ir_container = ir_container
          iv_cc_name   = iv_cc_name
          iv_lifetime  = iv_lifetime
          iv_side      = iv_side
          iv_extension = iv_extension
          iv_ratio     = iv_ratio.

      CALL METHOD gr_me->set_docu_sapscript
        EXPORTING
          iv_id    = iv_id
          iv_langu = lv_langu
          iv_obj   = lv_object
          iv_typ   = iv_typ.

      CALL METHOD gr_me->show_docu.

    CATCH /inw/cx_codocu.
      RAISE EXCEPTION TYPE /inw/cx_codocu.
  ENDTRY.

ENDMETHOD.


METHOD set_docu_sapscript.

*== local data
  DATA lv_spras        TYPE sylangu.

*== clear
  CLEAR gt_docu_lines.
  CLEAR gs_docu_header.

*== set language
  IF iv_langu IS INITIAL.
    lv_spras = sy-langu.
  ELSE.
    lv_spras = iv_langu.
  ENDIF.

*** _______________________________________________________________ ***
***                                                                 ***
***  Read table docu
*** _______________________________________________________________ ***
***                                                                 ***

  DO 2 TIMES.
*** read docu
    CALL FUNCTION 'DOCU_GET'
      EXPORTING
        id                = iv_id
        langu             = lv_spras
        object            = iv_obj
        typ               = iv_typ
      IMPORTING
        head              = gs_docu_header
      TABLES
        line              = gt_docu_lines
      EXCEPTIONS
        no_docu_on_screen = 1
        no_docu_self_def  = 2
        no_docu_temp      = 3
        ret_code          = 4
        OTHERS            = 5.
    IF sy-subrc > 0.
      CASE lv_spras.
        WHEN 'D'.
          lv_spras = 'E'.
        WHEN 'E'.
          lv_spras = 'D'.
        WHEN OTHERS.
          lv_spras = 'D'.
      ENDCASE.
    ELSE.
      EXIT. "from do
    ENDIF.
  ENDDO.

  IF sy-subrc > 0.
    create_information_no_docu( ).
  ENDIF.

ENDMETHOD.


METHOD show_docu.

*** local data
  DATA lt_html    TYPE STANDARD TABLE OF  htmlline.
  DATA lv_url     TYPE c LENGTH 500.


  CHECK gt_docu_lines IS NOT INITIAL.

*** _______________________________________________________________ ***
***                                                                 ***
***  Conver Docu to HTML
*** _______________________________________________________________ ***
***                                                                 ***

  CALL FUNCTION 'CONVERT_ITF_TO_HTML'
    EXPORTING
      i_header           = gs_docu_header
    TABLES
      t_itf_text         = gt_docu_lines
      t_html_text        = lt_html
      t_conv_charformats = gt_conv_charformats
      t_conv_parformats  = gt_conv_parformats
    EXCEPTIONS
      syntax_check       = 1
      replace            = 2
      illegal_header     = 3
      OTHERS             = 4.
  IF sy-subrc = 0.
*** Convert HTML data
    convert_html( CHANGING ct_html = lt_html ).


*** Push data to control
    CALL METHOD gr_display_html->load_data
      IMPORTING
        assigned_url = lv_url
      CHANGING
        data_table   = lt_html
      EXCEPTIONS
        OTHERS       = 4.

    IF sy-subrc = 0.
*** _______________________________________________________________ ***
***                                                                 ***
***  Display HTML-Text
*** _______________________________________________________________ ***
***                                                                 ***

      CALL METHOD gr_display_html->show_url
        EXPORTING
          url = lv_url.
    ENDIF.
  ENDIF.


ENDMETHOD.
ENDCLASS.
