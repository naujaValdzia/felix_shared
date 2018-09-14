
/*------------------------------------------------------------------------
    File        : ttError.i
    Purpose     : 
    Syntax      :
    Description : 
    Author(s)   : ppacevicius
    Created     : Mon Sep 10 15:42:21 EEST 2018
    Notes       :
  ----------------------------------------------------------------------*/
@openapi.openedge.entity.primarykey (fields="id").
    
define temp-table tterror before-table btterror
field filePath as character
field systemName as character
field errorMessage as character
field id as int64 initial "0"
index id is primary unique id ascending.