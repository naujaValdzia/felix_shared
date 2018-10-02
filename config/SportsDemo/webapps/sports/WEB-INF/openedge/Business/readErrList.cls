 
 /*------------------------------------------------------------------------
    File        : readErrList
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : ppacevicius
    Created     : Fri Aug 31 16:47:10 EEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class Business.readErrList: 
    define public property cSystem as character no-undo get.

    constructor public readErrList ():
        
        
    end constructor.

end class.