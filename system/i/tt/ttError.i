
/*------------------------------------------------------------------------
    File        : ttError.i
    Notes       :
  ----------------------------------------------------------------------*/
@openapi.openedge.entity.primarykey (fields="id").
    
define temp-table ttError before-table bttError
field filePath as character
field systemName as character
field errorMessage as character
field id as int64 initial "0"
index id is primary unique id ascending.