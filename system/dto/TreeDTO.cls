 
 /*------------------------------------------------------------------------
    File        : treeDTO
    Purpose     : 
    Syntax      : 
    Description : 
    Author(s)   : ppacevicius
    Created     : Wed Sep 05 18:19:08 EEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.

block-level on error undo, throw.

class TreeDTO:
    {ds/dsFile.i}
    {ds/dsTree.i}
    /*------------------------------------------------------------------------------
     Purpose:
     Notes:
    ------------------------------------------------------------------------------*/
        
    constructor public TreeDTO (  ):
        super ().
        
    end constructor.

    method public void fromDomain (input dataset dsFile,
                                   output dataset dsTree):
        dataset dsTree:empty-dataset().
        for each ttFile:
            create ttTree.
            buffer-copy ttFile to ttTree.
        end.                
        dataset dsTree:accept-changes().
    end method.
end class.