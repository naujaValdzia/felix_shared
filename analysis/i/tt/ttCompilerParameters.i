
/*------------------------------------------------------------------------
    File        : ttCompilerParameters.i
    Purpose     : 

    Syntax      :

    Description : 

    Author(s)   : ppacevicius
    Created     : Tue Sep 11 15:36:50 EEST 2018
    Notes       :
  ----------------------------------------------------------------------*/

define temp-table ttSystemInfo no-undo
    field systemName as character format "x(40)"
    field localSourcePath as character format "x(200)"
    field systemPropath as character format "x(200)"
    field systemDBparameters as character format "x(100)".