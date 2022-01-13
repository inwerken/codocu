CLASS /inw/cl_codocu DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE .

  PUBLIC SECTION.

    CLASS-METHODS convert_html
      CHANGING
        !ct_html TYPE htmltable .
    CLASS-METHODS display
      IMPORTING
        !iv_id        TYPE doku_id
        !iv_obj       TYPE clike
        !iv_langu     TYPE doku_langu DEFAULT sy-langu
        !iv_typ       TYPE doku_typ DEFAULT 'E'
        !iv_cc_name   TYPE clike OPTIONAL
        !ir_container TYPE REF TO cl_gui_container OPTIONAL
        !iv_lifetime  TYPE i OPTIONAL
        !iv_side      TYPE i OPTIONAL
        !iv_extension TYPE i OPTIONAL
        !iv_ratio     TYPE i OPTIONAL
        !iv_repid     TYPE syrepid OPTIONAL
        !iv_dynnr     TYPE sydynnr OPTIONAL
      RAISING
        /inw/cx_codocu .
  PROTECTED SECTION.

    DATA dynnr TYPE sydynnr .
    DATA repid TYPE syrepid .
    DATA docu_lines TYPE tline_tab .
    DATA docu_header TYPE thead .
    DATA docu_container TYPE REF TO cl_gui_container .
    DATA display_html TYPE REF TO cl_gui_html_viewer .
    DATA conv_charformats TYPE tline_tab .
    DATA conv_parformats TYPE tline_tab .
    CLASS-DATA codocu_object TYPE REF TO /inw/cl_codocu .

    METHODS create_information_no_docu .
    METHODS set_docu_sapscript
      IMPORTING
        !iv_id    TYPE doku_id
        !iv_langu TYPE doku_langu DEFAULT sy-langu
        !iv_obj   TYPE doku_obj
        !iv_typ   TYPE doku_typ .
    METHODS show_docu .
    METHODS create_display_area
      IMPORTING
        !ir_container TYPE REF TO cl_gui_container
        !iv_lifetime  TYPE i
        !iv_side      TYPE i
        !iv_extension TYPE i
        !iv_ratio     TYPE i
        !iv_cc_name   TYPE clike
      RAISING
        /inw/cx_codocu .
  PRIVATE SECTION.

    METHODS constructor
      IMPORTING
        !iv_repid TYPE syrepid
        !iv_dynnr TYPE sydynnr .
ENDCLASS.



CLASS /inw/cl_codocu IMPLEMENTATION.


  METHOD constructor.

*== set global data
    repid = iv_repid.
    dynnr = iv_dynnr.


*** _______________________________________________________________ ***
***                                                                 ***
***  Convert character and parameter formats
*** _______________________________________________________________ ***
***                                                                 ***
    PERFORM build_mapping_tables IN PROGRAM rshtmimg_2
     TABLES conv_charformats
            conv_parformats.

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
      docu_container = ir_container.
    ENDIF.

    IF docu_container IS INITIAL.
      IF iv_cc_name IS INITIAL.

*== create docking container
        CREATE OBJECT docu_container
          TYPE cl_gui_docking_container
          EXPORTING
            side                    = lv_side
            extension               = lv_extension
            lifetime                = lv_lifetime
            ratio                   = iv_ratio
            no_autodef_progid_dynnr = 'X'.
      ELSE.
*== create custom container
        CREATE OBJECT docu_container
          TYPE cl_gui_custom_container
          EXPORTING
            container_name          = iv_cc_name
            no_autodef_progid_dynnr = abap_true.
      ENDIF.
    ENDIF.

    IF display_html IS INITIAL.
*== create HTML control
      CREATE OBJECT display_html
        EXPORTING
          parent = docu_container.
    ENDIF.

  ENDMETHOD.


  METHOD create_information_no_docu.

*== local data
    FIELD-SYMBOLS <line> TYPE tline.

*== set dummy header
    docu_header-tdobject = 'TEXT'.
    docu_header-tdname   = 'DUMMY'.
    docu_header-tdid     = 'ST'.
    docu_header-tdspras  = sy-langu.
    docu_header-tdtitle  = 'Dummy'.

*== set dummy lines
    APPEND INITIAL LINE TO docu_lines ASSIGNING <line>.
    <line>-tdformat = 'U1'.
    <line>-tdline   = 'Kein Dokumentation vorhanden'(kdv).

  ENDMETHOD.


  METHOD display.

    DATA lv_langu  TYPE doku_langu.
    DATA lv_object TYPE doku_obj.


*== Selbstreferenz faktorieren
    IF codocu_object IS INITIAL.
      CREATE OBJECT codocu_object
        EXPORTING
          iv_repid = iv_repid
          iv_dynnr = iv_dynnr.
    ENDIF.

*== Eingaben übernehmen
    lv_langu  = iv_langu.
    lv_object = iv_obj.

* Hier ggf. verschiedene Sprachen abklopfen
    TRY.
        CALL METHOD codocu_object->create_display_area
          EXPORTING
            ir_container = ir_container
            iv_cc_name   = iv_cc_name
            iv_lifetime  = iv_lifetime
            iv_side      = iv_side
            iv_extension = iv_extension
            iv_ratio     = iv_ratio.

        CALL METHOD codocu_object->set_docu_sapscript
          EXPORTING
            iv_id    = iv_id
            iv_langu = lv_langu
            iv_obj   = lv_object
            iv_typ   = iv_typ.

        codocu_object->show_docu( ).

      CATCH /inw/cx_codocu.
        RAISE EXCEPTION TYPE /inw/cx_codocu.
    ENDTRY.

  ENDMETHOD.


  METHOD set_docu_sapscript.

*== local data
    DATA lv_spras        TYPE sylangu.

*== clear
    CLEAR docu_lines.
    CLEAR docu_header.

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
          head              = docu_header
        TABLES
          line              = docu_lines
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
    DATA html    TYPE STANDARD TABLE OF  htmlline.
    DATA url     TYPE c LENGTH 500.


    CHECK docu_lines IS NOT INITIAL.

*** _______________________________________________________________ ***
***                                                                 ***
***  Conver Docu to HTML
*** _______________________________________________________________ ***
***                                                                 ***

    CALL FUNCTION 'CONVERT_ITF_TO_HTML'
      EXPORTING
        i_header           = docu_header
      TABLES
        t_itf_text         = docu_lines
        t_html_text        = html
        t_conv_charformats = conv_charformats
        t_conv_parformats  = conv_parformats
      EXCEPTIONS
        syntax_check       = 1
        replace            = 2
        illegal_header     = 3
        OTHERS             = 4.
    IF sy-subrc = 0.
*** Convert HTML data
      convert_html( CHANGING ct_html = html ).


*** Push data to control
      display_html->load_data(
        IMPORTING
          assigned_url = url
        CHANGING
          data_table   = html
        EXCEPTIONS
          OTHERS       = 4 ).

      IF sy-subrc = 0.
        display_html->show_url( url ).
      ENDIF.
    ENDIF.


  ENDMETHOD.
ENDCLASS.
