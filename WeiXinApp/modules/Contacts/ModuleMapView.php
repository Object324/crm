<?php
//zkt 20231019 XUQIU1002065 登录记住密码优化+SQL注入相关需求：XUQIU1001341
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
$frommodule = $_REQUEST['frommodule'];
$module = $_REQUEST['module'];
$fromrecord = $_REQUEST['fromrecordid'];
$mode = $_REQUEST['mode'];

$relatedid = $_REQUEST['relatedid'];
crm_load_class_file("cls_ModuleMap","modules/Users");
$cls_modulemapobj = new cls_ModuleMap($frommodule,$module,$fromrecord,$relatedid);
$cls_modulemapobj->setSourceFromPC('no');
//获取保存的图谱信息
$modulemapdateinfo = $cls_modulemapobj->getmapdateinfo();
//获取字段信息
$modulemapfieldinfo = $cls_modulemapobj->getmodulemapFieldInfo();
//获取对应的数据信息
$moduledatainfo = $cls_modulemapobj->getmoduleDatainfo();
$moduledataindex_arr = array_keys($moduledatainfo);
$hreffieldinfo = $cls_modulemapobj->hreffieldinfo;
if(!empty($hreffieldinfo)){
    $hreffieldlabel = $hreffieldinfo->getFieldLabel();
    $hreffieldcolumnname = $hreffieldinfo->getColumnName();
}
$arr['nomapdata'] = $cls_modulemapobj->nomapdate;
$arr['arrFixedLabel'] = array();
$arr['arrFixedLabel']['ADDMODULEMAPINPC'] = getFixedLabel('ADDMODULEMAPINPC');
$arr['arrFixedLabel']['RETURN'] = getFixedLabel('RETURN');
$arr['arrFixedLabel']['TOBEADD'] = getFixedLabel('TOBEADD');
$arr['mapdata_arr']=$modulemapdateinfo;
$arr['modulemapfieldinfo']=$modulemapfieldinfo;
$arr['moduledatainfo']=$moduledatainfo;
$arr['moduledataindex_arr']=$moduledataindex_arr;
$arr['hreffieldcolumnname']=$hreffieldcolumnname;
$arr['page_title']=getFixedLabel('ContactsMap');
ConvertTojsonString(1,$arr,'success');
?>