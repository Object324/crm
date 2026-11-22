<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
//页面设置->快速创建
$modulename=$_REQUEST['modulename'];
$focus=CRMEntity::getInstance($modulename);
$modulefields=$focus->fieldobj->getModuleFields();
$quickcreatecolumninfo=array();
foreach($modulefields as $fieldname=>$fieldinfo)
{
    if($fieldinfo->get_allowedit()=='yes')
    {
        $bigtype=$fieldinfo->getBigType();
        if($bigtype=='selectsource')
        {
            continue;
        }
		//chj 2021/1/22 44301: （本地php72，8.3.7）客户管理-跟进记录-新建（需要补丁）；pc端新建跟进记录时，快速创建，“签到地址”字段显示了，该字段应只在移动端建立单据时显示；页面设置快速创建栏中，不应该显示
        if($fieldname == 'sign_location_address' ||$fieldname == 'location_address'){
			continue;
		}
        $quickcreate=$fieldinfo->getQuickCreate();
        $tableName=$fieldinfo->getTableName();
        if($modulename=='Accounts'&&($tableName=='ld_contactdetails'||$tableName=='ld_contactscf'))
        {
            continue;
        }
        if($quickcreate==0)
        {
            $quickcreatesequence=$fieldinfo->getQuickCreatesequence();
            while(array_key_exists($quickcreatesequence,$quickcreatecolumninfo))
              {
                //16975: 快速创建-客户：快速创建客户弹出层中，缺少“客户名称”
                //当quickcreatesequence相同时，循环添加$quickcreatesequence;
                  $quickcreatesequence++;
                    
              }     
            $quickcreatecolumninfo[$quickcreatesequence]=array('col'=>$fieldname.":".$fieldinfo->getTypeOfData(),'label'=>$fieldinfo->getFieldLabel());
        }
        else
        {
            $allcolumninfo[]=array('col'=>$fieldname.":".$fieldinfo->getTypeOfData(),'label'=>$fieldinfo->getFieldLabel());
        }
    }
}

ksort($quickcreatecolumninfo);

$smarty=new lingdangCRM_Smarty();
$sql='select isduplicate from ld_tab where name=? ';
$result=$adb->pquery($sql,array($modulename));
$smarty->assign("ISDUPLICATE",$adb->query_result($result,0,'isduplicate'));
$smarty->assign("ALLFIELDS",$allcolumninfo);
$smarty->assign("QUICKCREATEFIELDS",$quickcreatecolumninfo);

$_REQUEST['diony']='yes';
$arr['content']=$smarty->fetch("Settings/QuickCreateSetting.tpl");
$arr['quickcreatetip']=getFixedLabel('MandatoryFieldnotallowedcancelled');
ConvertTojsonString(1,$arr,'success');


?>