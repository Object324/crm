<?php
$smarty=new lingdangCRM_Smarty();
  $fld_module=$_REQUEST['frommodule'];
  $focus=CRMEntity::getInstance($fld_module);
  $modulefields=$focus->fieldobj->getModuleFields();
  foreach($modulefields as $fieldname=>$fieldinfo)
  {
    if($fieldinfo->getBigType()=='selectsource')
    {
        $sourcefieldid=$fieldinfo->getFieldid();
        break;
        
    }
  }
  crm_load_class_file("cls_sourcelist",'modules/Settings');
  $sourcelistobj=new cls_sourcelist($fld_module);
  $sourcelistobj->sourcefieldid=$sourcefieldid;
  $smarty->assign("MODULE",$fld_module);
  $smarty->assign('LIST_ENTRIES',$sourcelistobj->getListContentData());
    $smarty->assign('LIST_HEADER',$sourcelistobj->getListHead());
  $_REQUEST['diony']='yes';
  $arr['content']=$smarty->fetch("Settings/SelectSourceList.tpl");
  ConvertTojsonString(1,$arr,'success');

?>