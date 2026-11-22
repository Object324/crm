<?php

$idstring=$_REQUEST['idstring'];


$sourcemodule=$_REQUEST['sourcemodule'];
  crm_load_class_file("Detail_Edit_View_finance",'include/utils');
   // $relatedinformations=getRelatedOrderInformation($_REQUEST['selectsourcename'],$_REQUEST['listval'],1,1);

   $html=Detail_Edit_View_finance::getInvoice_SoureInfo($sourcemodule,$idstring);
   ob_clean();
  ob_flush();

   echo $html;
   exit();

?>