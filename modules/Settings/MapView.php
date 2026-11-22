<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
//页面设置->地图视图
$modulename=$_REQUEST['modulename'];
$focus=CRMEntity::getInstance($modulename);
$modulefields=$focus->fieldobj->getModuleFields();
$mapviewcolumninfo=array();
$map_type = $_REQUEST['maptype'];
if(empty($map_type))$map_type = 'list';
foreach($modulefields as $fieldname=>$fieldinfo)
{
    if($fieldinfo->getSaveDataBase() != 'no')
    {
        $tableName=$fieldinfo->getTableName();
        if($tableName=='ld_contactdetails'||$tableName=='ld_contactscf')
        {
            continue;
        }
		$uitype = $fieldinfo->getUIType();
		if(in_array($uitype,array(64,1109))){
			continue;
		}
		$columnname = $tableName.':'.$fieldinfo->getColumnName().':'.$fieldname.':'.$modulename.'_fieldlabel:'.$fieldinfo->getTypeOfData();
        $allcolumninfo[$columnname]=array('col'=>$columnname,'label'=>$fieldinfo->getFieldLabel());
		$allcolumninfo_label[$columnname] = $fieldinfo->getFieldLabel();
    }
}
$query = "select columnname from ld_map_field where module = ? and map_type = ? order by sequence";
$result = $adb->pquery($query,array($modulename,$_REQUEST['maptype']));
$num_rows = $adb->num_rows($result);
if($num_rows >= 1){
	for($i = 0; $i < $num_rows; $i++){
		$columnanme = $adb->query_result($result,$i,'columnname');
		$cols = explode(':',$columnanme);
		$fieldname = $cols[2];
		if(empty($modulefields[$fieldname])){
			continue;
		}
		$mapviewcolumninfo[] = array(
			'col' => $columnanme,	
			'label' => $allcolumninfo_label[$columnanme]
		);
		unset($allcolumninfo[$columnanme]);
	}
}

$smarty=new lingdangCRM_Smarty();
$smarty->assign("ALLFIELDS",$allcolumninfo);
$smarty->assign("QUICKCREATEFIELDS",$mapviewcolumninfo);
$smarty->assign('MAPTYPE',$_REQUEST['maptype']);
$smarty->assign('MODULE',$modulename);
$_REQUEST['diony']='yes';
$arr['content']=$smarty->fetch("Settings/MapField.tpl");
ConvertTojsonString(1,$arr,'success');


?>