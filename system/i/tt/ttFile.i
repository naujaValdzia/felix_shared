
/*------------------------------------------------------------------------
    File        : ttFile.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : ppacevicius
    Created     : Wed Sep 05 15:56:32 EEST 2018
    Notes       :
  ----------------------------------------------------------------------*/

define temp-table ttfile
field fileNum as integer initial "0"
field fileName as character
field sourceName as character
field sourcePath as character
field line as integer initial "0"
field type as character
field info as character
field compileUnit as character
field systemName as character
index systemID is  primary   systemName  ascending 
index typeID type ascending.
