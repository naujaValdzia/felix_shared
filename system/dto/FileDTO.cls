 
 /*------------------------------------------------------------------------
    File        : FileDTO
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.

class FileDTO:
    {ds/dsFile.i}
    {ds/dsFileDto.i}
    {ds/dsFileDetailDto.i}

    method public void fromDomain (input dataset dsFile,
                                   output dataset dsFileDto):
        dataset dsFileDto:empty-dataset().
        for each ttFile:
            create ttFileDto.
            buffer-copy ttFile to ttFileDto.
        end.                
        dataset dsFileDto:accept-changes().
    end method.
    
    method public void fromDomainDetail (input dataset dsFile,
                                   output dataset dsFileDetailDto):
        dataset dsFileDetailDto:empty-dataset().
        for each ttFile:
            create ttFileDetailDto.
            buffer-copy ttFile to ttFileDetailDto.
        end.                
        dataset dsFileDetailDto:accept-changes().
    end method.
end class.