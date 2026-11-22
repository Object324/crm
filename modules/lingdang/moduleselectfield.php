<?php


global $currentModule;
$focus=CRMEntity::getInstance($currentModule);
$fieldtype=$_REQUEST['fieldtype'];
if($fieldtype=='sms')
{
    foreach($focus->fieldobj->getModuleFields() as $fieldname=>$fieldinfo)
    {
        $tablename=$fieldinfo->getTableName();
         if($fieldinfo->getFieldDataType()!='mobile')
         {
             continue;
         }
        if(in_array($tablename,$focus->tab_name))
        {
            $selectfieldtypes[]=array(
          
            'fieldlabel'=>$fieldinfo->getFieldLabel(),
            'tablename'=>$fieldinfo->getTableName(),
            'fieldname'=>$fieldinfo->getFieldName(),
            'columnname'=>$fieldinfo->getColumnName()
            //'newchinesename'=>$adb->query_result($accounttype_SMS_result,$i,'newchinesename')
            
            );
        }
    }
}
else if($fieldtype=='email')
{
    foreach($focus->fieldobj->getModuleFields() as $fieldname=>$fieldinfo)
    {
        $tablename=$fieldinfo->getTableName();
         if($fieldinfo->getFieldDataType()!='email')
         {
             continue;
         }
        if(in_array($tablename,$focus->tab_name))
        {
            $selectfieldtypes[]=array(
          
            'fieldlabel'=>$fieldinfo->getFieldLabel(),
            'tablename'=>$fieldinfo->getTableName(),
            'fieldname'=>$fieldinfo->getFieldName(),
            'columnname'=>$fieldinfo->getColumnName()
            //'newchinesename'=>$adb->query_result($accounttype_SMS_result,$i,'newchinesename')
            
            );
        }
    }
}

$html_accounttype_SMS = "";
$selectcolumns=explode(",",$_REQUEST['selectcolumname']);

for($i=0;$i<sizeof($selectfieldtypes);$i++)
{
  
        $tabname = getTranstab($currentModule);
        $smsmodule=$currentModule;
    $columnname=$selectfieldtypes[$i]['columnname'];
    
    if(in_array($columnname,$selectcolumns))
    {
        $html_accounttype_SMS .= "<tr>";
        $html_accounttype_SMS .= "<td>";
        $html_accounttype_SMS .= "<input type='checkbox'  name='moduleselectfield' checked='checked'  value='".$selectfieldtypes[$i]['columnname']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$tabname.":&nbsp".$selectfieldtypes[$i]['fieldlabel']."";
        $html_accounttype_SMS .= "</td>";
        $html_accounttype_SMS .= "</tr>";
    }
    else
    {
        $html_accounttype_SMS .= "<tr>";
        $html_accounttype_SMS .= "<td>";
        $html_accounttype_SMS .= "<input type='checkbox'  name='moduleselectfield'  value='".$selectfieldtypes[$i]['columnname']."'/>&nbsp;&nbsp;&nbsp;&nbsp;".$tabname.":&nbsp".$selectfieldtypes[$i]['fieldlabel']."";
        $html_accounttype_SMS .= "</td>";
        $html_accounttype_SMS .= "</tr>";
    }
}
$smarty=new lingdangCRM_Smarty();
$smarty->assign('FIELDTYPE',$fieldtype);
$smarty->assign("html_contact_SMS",$html_accounttype_SMS);
$_REQUEST['diony']='yes';

$arr['content']=$smarty->fetch("moduleSelectField.tpl");
$arr['oktext']=getFixedLabel("SELECT");
$arr['canceltext']=getFixedLabel("CANCEL");
if($fieldtype=='email')
{
    $arr['title']=getFixedLabel('PLEASESELECTEMAIL');
    
}
else
{
    $arr['title']=getFixedLabel('PLEASESELECTPHONE');
}
if(sizeOf($selectfieldtypes) <= 0){
	$msg = getFixedLabel('thereisnoemailfield');
	if($fieldtype=='email')
		$arr['msg'] = str_replace("%%","email",$msg);
	else{
		$mobile_label = getFixedLabel('Mobile');
		$arr['msg'] = str_replace("%%",$mobile_label,$msg);
	}
	ConvertTojsonString(-1,$arr,"success");
}else{
	ConvertTojsonString(1,$arr,"success");
}


?>