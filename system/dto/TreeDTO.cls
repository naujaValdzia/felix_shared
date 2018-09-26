 
 /*------------------------------------------------------------------------
    File        : TreeDTO
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.

class TreeDTO:
    {ds/dsFile.i}
    {ds/dsTree.i}

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