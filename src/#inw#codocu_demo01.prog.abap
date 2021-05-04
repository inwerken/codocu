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

REPORT /inw/codocu_demo01.

*== Dummy-Eingabeparameter, damit ein Selektionsbild vorhanden ist.
PARAMETERS p_demo TYPE char10.

INITIALIZATION.
*== Anzeige der Dokumentation auf der rechten Seite
  CALL METHOD /inw/cl_codocu=>display(
    iv_id = 'RE'
    iv_obj = sy-repid
    iv_langu = sy-langu
    iv_side = cl_gui_docking_container=>dock_at_right
    iv_ratio = 30 ).
