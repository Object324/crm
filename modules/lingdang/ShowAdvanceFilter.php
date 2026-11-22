<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

$smarty=new lingdangCRM_Smarty();
if($_REQUEST['advft_criteria']!='')
{
   $advfts= json_decode($_REQUEST['advft_criteria'],true);
   $advft_criteria_groups= json_decode($_REQUEST['advft_criteria_groups'],true);
 
   $tmparr=array();
    foreach($advfts as $tmpindex=>$info)
    {
        if(array_key_exists('columnname',$info))
        {
            $groupid=$info['groupid'];
            $info['search_comparator']=$info['comparator'];
            $tmpar[$groupid]['columns'][]=$info;
            $tmpar[$groupid]['condition']=$advft_criteria_groups[$groupid]['groupcondition'];
        }
    }
    $arr['criteria_groups_arr'] = $tmpar;

}


$arr['content']=$smarty->fetch("newAdvanceFilter.tpl");
$_REQUEST['diony']='yes';
$arr['title']=getFixedLabel('CUSTOMIZESEARCH');
$arr['oktext']=getFixedLabel('FINDNOW');
$arr['canceltext']=getFixedLabel("CANCEL");

crm_load_class_file('CommonView',"modules/CustomView");
$comparatorArr = CommonView::getComparatorLabel();
$comparatorArr['belong'] = getFixedLabel('BELONG');
$comparatorArr['notbelong'] = getFixedLabel('NOTBELONG');
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$comparatorArr['new_belong'] = getFixedLabel('BELONG');
$comparatorArr['new_notbelong'] = getFixedLabel('NOTBELONG');
$advfilterhtml = CommonView::getAdvCriteriaHTML($comparatorArr);
$arr['advfilterhtml'] = $advfilterhtml;
$arr['fLabels'] = $comparatorArr;
$arr['datetimestr']=CommonView::stdFilterDateTimeStr("");
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
global $currentModule;
$controller = ListViewController::getInstance($currentModule);
$arr['advanceFields'] = $controller->getAdvanceFields();
if(isset($_REQUEST['onecheck']) && $_REQUEST['onecheck'] == 'yiwen'){
    // @edit:ls @date:2020-7-8 @reason: 义文机电一键检测需求
    $arr['onecheck'] = $_REQUEST['onecheck'];//相关对象
}
ConvertTojsonString(1,$arr,'success');

?>