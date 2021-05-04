*&---------------------------------------------------------------------*
*& Report            /INW/CODOCU_DEMO01
*&---------------------------------------------------------------------*
*                                                                      *
*     _____                        _                         _____     *
*    |_   _|                      | |                  /\   / ____|    *
*      | |  _ ____      _____ _ __| | _____ _ __      /  \ | |  __     *
*      | | | '_ \ \ /\ / / _ \ '__| |/ / _ \ '_ \    / /\ \| | |_ |    *
*     _| |_| | | \ V  V /  __/ |  |   <  __/ | | |  / ____ \ |__| |    *
*    |_____|_| |_|\_/\_/ \___|_|  |_|\_\___|_| |_| /_/    \_\_____|    *
*                                                                      *
*                                                  einfach Inwerken.   *
*                                                                      *
*&---------------------------------------------------------------------*


* DOKU ANZEIGE IM SUBSCREEN.


REPORT /inw/codocu_demo02.

*== Dummy-Eingabeparameter, damit ein Selektionsbild vorhanden ist.
PARAMETERS p_demo TYPE char10.
SELECTION-SCREEN SKIP 2.
SELECTION-SCREEN BEGIN OF TABBED BLOCK docu FOR 30 LINES.
SELECTION-SCREEN END OF BLOCK docu.

AT SELECTION-SCREEN.

  IF 1 = 2.
    CALL SCREEN 500.
  ENDIF.

INITIALIZATION.
  docu-dynnr = 500.
  docu-prog  = sy-repid.

*&---------------------------------------------------------------------*
*&      Module  STATUS_0500  OUTPUT
*&---------------------------------------------------------------------*
MODULE status_0500 OUTPUT.


*== Anzeige der Dokumentation auf der rechten Seite
  CALL METHOD /inw/cl_codocu=>display(
      iv_id      = 'RE'
      iv_obj     = sy-repid
      iv_cc_name = 'CC_DOCU'
                   ).

ENDMODULE.                 " STATUS_0500  OUTPUT
