 
 /*------------------------------------------------------------------------
    File        : DbFieldDTO
    Notes       : 
  ----------------------------------------------------------------------*/

using Progress.Lang.*.
block-level on error undo, throw.

class DbFieldDTO:
    {ds/dsDbField.i}
    {ds/dsDbFieldDto.i}
    {ds/dsDbFieldDetailDto.i}

    method public void fromDomain (input dataset dsDbField,
                                   output dataset dsDbFieldDto):
        dataset dsDbFieldDto:empty-dataset().
        for each ttDbField:
            create ttDbFieldDto.
            buffer-copy ttDbField to ttDbFieldDto.
        end.                
        dataset dsDbFieldDto:accept-changes().
    end method.
    
    method public void fromDomainDetail (input dataset dsDbField,
                                   output dataset dsDbFieldDetailDto):
        dataset dsDbFieldDetailDto:empty-dataset().
        for each ttDbField:
            create ttDbFieldDetailDto.
            buffer-copy ttDbField to ttDbFieldDetailDto.
        end.                
        dataset dsDbFieldDetailDto:accept-changes().
    end method.
end class.