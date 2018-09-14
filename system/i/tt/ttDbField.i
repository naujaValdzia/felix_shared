
/*------------------------------------------------------------------------
    File        : ttDbField.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : ppacevicius
    Created     : Thu Sep 06 13:46:31 EEST 2018
    Notes       :
  ----------------------------------------------------------------------*/

define temp-table ttDbField
field fieldNum as integer initial "0"
field sourceName as character
field sourcePath as character
field line as integer initial "0"
field type as character
field information as character
field compileUnit as character
field systemName as character
field fileName as character
index systemID is  primary   systemName  ascending 
index typeID  type  ascending.