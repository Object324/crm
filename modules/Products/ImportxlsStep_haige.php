<?php
$frommodule=$_REQUEST['frommodule'];

if($_REQUEST['stepindex']==1)
{
    include("modules/Products/haige/ImportFirst.php");
    
}
else if($_REQUEST['stepindex']==2)
{
    if(get_file_address($frommodule,"ProductDetails")&&$frommodule!='ServiceCharge')
    {
        
            include("modules/XlsImportNew/ImportSecondDetail.php");
    }
    else if($frommodule=='Accounts')
    {
         include("modules/XlsImportNew/ImportSecondAccountContact.php");
    }
    else if(get_file_address($frommodule,$frommodule.'DetailFieldsHtml')||$frommodule=='TimeSheet')
    {
        include("modules/XlsImportNew/ImportSecondTabDetail.php");
    }
    else
    include("modules/XlsImportNew/ImportSecond.php");
}
else if($_REQUEST['stepindex']==3)
{
    include("modules/Products/haige/Importthree.php");
}
else if($_REQUEST['stepindex']==4){
    
     include("modules/Products/haige/ImportFinished.php");
}
else if($_REQUEST['clearimportsession']=='yes')
{
    include("modules/XlsImportNew/ImportclearSession.php");
}
else if($_REQUEST['getimportrows']=='yes')
{
    include("modules/Products/haige/XlsInsertTmpMemory.php");
}
else if($_REQUEST['getprogress']=='yes'){
    
     include("modules/XlsImportNew/ImportProgress.php");
}else if($_REQUEST['fileupload'] == 'XlsFileUpload'){
	include("modules/Products/haige/XlsFileUpload.php");
}else if($_REQUEST['fileupload'] == 'ExportTemplateFile'){
	include("modules/Products/haige/ExportTemplateFile.php");
}


?>