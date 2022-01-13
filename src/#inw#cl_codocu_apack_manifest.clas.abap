class /INW/CL_CODOCU_APACK_MANIFEST definition
  public
  final
  create public .

public section.

  interfaces ZIF_APACK_MANIFEST .

  methods CONSTRUCTOR .
protected section.
private section.
ENDCLASS.



CLASS /INW/CL_CODOCU_APACK_MANIFEST IMPLEMENTATION.


  METHOD constructor.

    zif_apack_manifest~descriptor-group_id = 'https://github.com/inwerken'.
    zif_apack_manifest~descriptor-artifact_id = 'codocu'.
    zif_apack_manifest~descriptor-git_url = 'https://github.com/inwerken/codocu.git'.
    zif_apack_manifest~descriptor-dependencies = VALUE #( ).

  ENDMETHOD.
ENDCLASS.
