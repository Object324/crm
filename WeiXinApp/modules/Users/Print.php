<?php
crm_load_class_file('cls_PrintWX', 'WeiXinApp/detail');
$mobj = new cls_PrintWX($_REQUEST['frommodule']);
$details = $mobj->doPrint();
echo $details;