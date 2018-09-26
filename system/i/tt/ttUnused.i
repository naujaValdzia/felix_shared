
 /*------------------------------------------------------------------------
    File        : ttUnused.i
    Notes       : 
  ----------------------------------------------------------------------*/
@openapi.openedge.entity.primarykey (fields="id").
    
define temp-table ttUnused before-table bttUnused
field fileName as character
field type as character
field compileUnit as character
field systemName as character
field info as character
field id as int64 initial "0"
index id is primary unique id ascending.