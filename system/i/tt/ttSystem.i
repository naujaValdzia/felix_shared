
/*------------------------------------------------------------------------
    File        : ttSystem.i
    Notes       :
  ----------------------------------------------------------------------*/

@openapi.openedge.entity.primarykey (fields="id").
    
define temp-table ttSystem before-table bttSystem
field systemName as character
field localSourcePath as character
field systemPropath as character
field systemDBparameters as character
field entryPoints as character
field hasErrors as logical initial "false"
field id as int64 initial "0"
index id is primary unique id ascending 
index systemName is unique systemName ascending.