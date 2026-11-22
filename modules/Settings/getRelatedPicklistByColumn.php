<?php
//zkt 20231122 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
if(!isset($adb))
{
    exit();
}
//获取产品明细的下拉框字段内容
$effect_columnname=$_REQUEST['effect_columnname'];
$module=$_REQUEST['modulename'];
$param = json_decode($_REQUEST['param'],true);
$requestvalues = $_REQUEST['requestvalues'];

$SQL='select * from ld_related_producttoolfield  where modulename=? and effect_columnname=? ';

$result=$adb->pquery($SQL,array($module,$effect_columnname));
if($adb->num_rows($result)>0)
{
     $query_sql = $adb->query_result($result,0,'query_sql');  //待替换sql字符串

    $focus = CRMEntity::getInstance($module);
    $related_table = $focus->tab_name;  //模块相关表

    $requestvalues_arr = json_decode($requestvalues,true);  //字段对应的值
    if (!empty($query_sql)) {
            //sql  替换  1、先替换{hdnProductId} 不带表前缀的
            foreach ($param as $key=>$val){
                $query_sql =  str_replace('{'.$key.'}',$val,$query_sql);
            }
    
            //2、在替换{ld_salesorder.accountid}，带表前缀的。
            foreach ($related_table as $tab_name){
                foreach ($requestvalues_arr as $columnname=>$value){
                    $query_sql =  str_replace('{'.$tab_name.'.'.$columnname.'}',$value,$query_sql);
                }
            }
    }
   
    $result = $adb->pquery(html_entity_decode($query_sql,ENT_QUOTES,'utf-8'), array());
    $rows=$adb->num_rows($result);
    $pickcontentlist=[];
    for($i=0;$i<$rows;$i++)
    {
        $effect_value=$adb->query_result($result,$i,$effect_columnname);
        $pickcontentlist[$effect_value]=$effect_value;
    }
 
    $_REQUEST['diony']='yes';
    $list=array();
    $list['list']=$pickcontentlist;
    ConvertTojsonString(1,$list,"success");
}
else
{
    ConvertTojsonString(-1,array(),"success");
}



?>