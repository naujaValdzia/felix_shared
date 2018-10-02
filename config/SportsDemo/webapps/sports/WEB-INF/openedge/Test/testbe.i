
 /*------------------------------------------------------------------------
    File        : TestBE
    Purpose		:
    Syntax      : 
    Description :
    Author(s)   : ppacevicius
    Created     : Fri Aug 31 12:09:37 EEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/
  
  /* ***************************  Definitions  ************************** */
  
  /* ********************  Preprocessor Definitions  ******************** */
  
  /* ***************************  Main Block  *************************** */
  
  /** Dynamically generated schema file **/
   
@openapi.openedge.entity.primarykey (fields="EmpNum,StartDate").
	
define temp-table ttVacation before-table bttVacation
field EmpNum as integer initial "0" label "Emp No"
field StartDate as date label "Start Date"
field EndDate as date label "End Date"
field id as character
field seq as integer init ?

index EmpNoStartDate is unique  EmpNum  ascending  StartDate  ascending 
index pkSeq as primary unique seq. 


define dataset dsVacation for ttVacation.