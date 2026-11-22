<?php
$dizhi=substr($_SERVER['PHP_SELF'],0,strpos($_SERVER['PHP_SELF'],'CustomReport'));
$url= 'http://'.$_SERVER['HTTP_HOST'].$dizhi.'/index.php?module=PurchaseInvoice&action=EditView&return_action=DetailView&Create=true&frommodule=Customreport&report_sourceid='.$_REQUEST['report_sourceid'].'&report_sourcemodule='.$_REQUEST['report_sourcemodule'].'&vendor_id='.$_REQUEST['vendor_id'];
header("Location:".$url);
exit();

?>