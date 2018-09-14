
/*------------------------------------------------------------------------
    File        : ttSystem.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : ppacevicius
    Created     : Mon Sep 10 16:23:32 EEST 2018
    Notes       :
  ----------------------------------------------------------------------*/

@openapi.openedge.entity.primarykey (fields="id").
    
define temp-table ttsystem before-table bttsystem
field systemName as character
field localSourcePath as character
field systemPropath as character
field systemDBparameters as character
field entryPoints as character
field hasErrors as logical initial "no"
field systemLocation as character
field id as int64 initial "0"
index id is primary unique id ascending 
index systemName is unique systemName ascending.