
 /*------------------------------------------------------------------------
    File        : errors
    Purpose		:
    Syntax      : 
    Description :
    Author(s)   : ppacevicius
    Created     : Fri Aug 31 12:27:40 EEST 2018
    Notes       : 
  ----------------------------------------------------------------------*/
  
  /* ***************************  Definitions  ************************** */
  
  /* ********************  Preprocessor Definitions  ******************** */
  
  /* ***************************  Main Block  *************************** */
  
  /** Dynamically generated schema file **/
   

define temp-table tterrors no-undo before-table btterrors
field filePath as character
field systemName as character
field errorMessage as character

/* required fields */
field id as char
field seq as integer init ?
index pkSeq as primary unique seq. 

define dataset dserrors for tterrors.