 
 /*------------------------------------------------------------------------
    File        : errors
    Syntax      : 
    Author(s)   : ppacevicius
    Created     : Fri Aug 31 12:27:40 EEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/
  
@program FILE(name="errorsBE.cls", module="AppServer").
@openapi.openedge.export FILE(type="REST", executionMode="singleton", useReturnValue="false", writeDataSetBeforeImage="false").
@progress.service.resource FILE(name="errors", URI="/errors", schemaName="dserrors", schemaFile="Sports/PASOEContent/WEB-INF/openedge/Business/errors.i").

using Progress.Lang.*.
using Spark.Core.Service.SparkEntity.

block-level on error undo, throw.

class Business.errorsBE inherits SparkEntity use-widget-pool:

    {Business\errors.i}
    
    constructor public errorsBE():
        ProDataSet = dataset dsErrors:handle.
        extent(DataSourceArray) = 1.
        create data-source DataSourceArray[1].
        DataSourceArray[1]:add-source-buffer(buffer errors:handle, ?).
        ProDataSource = DataSourceArray.
        extent(SkipListArray) = 1.
        SkipListArray[1] = "".
        SkipList = SkipListArray.
                 
    end constructor.
        
    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").
    @progress.service.resourceMapping(type="REST", operation="read", URI="?filter=~{filter~}", alias="", mediaType="application/json"). 
    
    @openapi.openedge.method.property(name="mappingType", value="AFP").
    @openapi.openedge.method.property(name="capabilities", value="filter,top,skip,id,sort,orderBy").
    
    method public void ReadErrors(
            input filter as character, 
            output DATASET dserrors):
        
            define variable iNumRecs as int64 no-undo.
            super:ReadData(filter, iNumRecs, output dataset dsErrors by-reference).
    end method.
      
/*    /*------------------------------------------------------------------------------                                                */
/*            Purpose: Create one or more new records                                                                                 */
/*            Notes:                                                                                                                  */
/*    ------------------------------------------------------------------------------*/                                                */
/*    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").                                  */
/*    @progress.service.resourceMapping(type="REST", operation="create", URI="", alias="", mediaType="application/json").             */
/*    method public void Createerrors(input-output DATASET dserrors):                                                                 */
/*                                                                                                                                    */
/*        super:CreateData(DATASET dserrors by-reference).                                                                            */
/*    end method.                                                                                                                     */
/*                                                                                                                                    */
/*    /*------------------------------------------------------------------------------                                                */
/*            Purpose:  Update one or more records                                                                                    */
/*            Notes:                                                                                                                  */
/*    ------------------------------------------------------------------------------*/                                                */
/*    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").                                  */
/*    @progress.service.resourceMapping(type="REST", operation="update", URI="", alias="", mediaType="application/json").             */
/*    method public void Updateerrors(input-output DATASET dserrors):                                                                 */
/*                                                                                                                                    */
/*        super:UpdateData(DATASET dserrors by-reference).                                                                            */
/*    end method.                                                                                                                     */
/*                                                                                                                                    */
/*    /*------------------------------------------------------------------------------                                                */
/*            Purpose:    Delete a record                                                                                             */
/*            Notes:                                                                                                                  */
/*    ------------------------------------------------------------------------------*/                                                */
/*    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").                                  */
/*    @progress.service.resourceMapping(type="REST", operation="delete", URI="", alias="", mediaType="application/json").             */
/*    method public void Deleteerrors(input-output DATASET dserrors):                                                                 */
/*                                                                                                                                    */
/*        super:DeleteData(DATASET dserrors by-reference).                                                                            */
/*    end method.                                                                                                                     */
/*                                                                                                                                    */
/*    /*------------------------------------------------------------------------------                                                */
/*            Purpose:    Submit a record                                                                                             */
/*            Notes:                                                                                                                  */
/*    ------------------------------------------------------------------------------*/                                                */
/*    @openapi.openedge.export(type="REST", useReturnValue="false", writeDataSetBeforeImage="true").                                  */
/*    @progress.service.resourceMapping(type="REST", operation="submit", URI="/Submiterrors", alias="", mediaType="application/json").*/
/*    method public void Submiterrors(input-output DATASET dserrors):                                                                 */
/*                                                                                                                                    */
/*          super:Submit(DATASET dserrors by-reference).                                                                              */
/*    end method.                                                                                                                     */
/*                                                                                                                                    */
/*                                                                                                                                    */
end class.
