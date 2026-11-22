<?php


$module=$_REQUEST['relatemodule'];


$arr["relatedproducttoolfield"]=getRelatedProducttoolfield($module);

$_REQUEST['diony']='yes';
ConvertTojsonString(1,$arr,'success');


?>