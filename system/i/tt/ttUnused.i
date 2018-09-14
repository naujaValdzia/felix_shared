
 /*------------------------------------------------------------------------
    File        : ttUnused.i
    Purpose     :
    Syntax      : 
    Description :
    Author(s)   : ppacevicius
    Created     : Mon Sep 10 15:03:53 EEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/
@openapi.openedge.entity.primarykey (fields="id").
    
define temp-table ttunused before-table bttunused
field fileName as character
field type as character
field compileUnit as character
field systemName as character
field info as character
field id as int64 initial "0"
index id is primary unique id ascending.