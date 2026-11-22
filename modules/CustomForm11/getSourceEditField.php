<?php
$_REQUEST['diony']='yes';

if(file_exists(globalStatic::$root_directory.'modules/CustomForm11/SourceEditField.txt')){
 
   $sourceEditField= file_get_contents(globalStatic::$root_directory.'modules/CustomForm11/SourceEditField.txt');
   $sourceEditfields=explode(',',$sourceEditField);
   ConvertTojsonString(1,array("sourceeditfield"=>$sourceEditfields),'success');
}
else{
    $sourceEditFields=array();
    ConvertTojsonString(1,array("sourceeditfield"=>$sourceEditfields),'error');
}

?>