class /INW/CL_CODOCU_APACK_MANIFEST definition
  public
  final
  create public .

public section.

  interfaces /INW/IF_APACK_MANIFEST .
  interfaces ZIF_APACK_MANIFEST .

  methods CONSTRUCTOR .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS /INW/CL_CODOCU_APACK_MANIFEST IMPLEMENTATION.


  METHOD constructor.

    /inw/if_apack_manifest~descriptor-group_id     = 'https://github.com/inwerken'.
    /inw/if_apack_manifest~descriptor-artifact_id  = 'codocu'.
    /inw/if_apack_manifest~descriptor-git_url      = 'https://github.com/inwerken/codocu.git'.
    /inw/if_apack_manifest~descriptor-dependencies = VALUE #( ).

    zif_apack_manifest~descriptor = /inw/if_apack_manifest~descriptor.

  ENDMETHOD.
ENDCLASS.
