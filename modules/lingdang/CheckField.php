<?php
include('include/utils/duplicateFindRecords.php');
global $currentModule;
$smarty = new lingdangCRM_Smarty();
$smarty->assign('MODULE',$currentModule);
$focus = CRMEntity::getInstance($currentModule);

/**
 *@edit: andy 
 *@date: 20141203
 *@reason: 0012738: ����BUG�������Ż����ع������ֶ���ʾ��ʽ
 *@version: v5.9
*/

$allcolumns  =duplicateFindRecords::getMergeFields($currentModule,"available_fields");
$showcolumns =duplicateFindRecords::getMergeFields($currentModule,"fileds_to_merge");

if(empty($showcolumns)){
    if($currentModule == 'Leads'){
        $accountname_fieldinfo = $focus->fieldobj->getFieldInfoobjBykey('fieldname','accountname');
        $showcolumns = '<option value="'.$accountname_fieldinfo->fieldid.'">'.$accountname_fieldinfo->getFieldLabel().'</option>';
    }
}

$allcolumnsArr=explode('</option>',$allcolumns);
$showcolumnsArr=explode('</option>',$showcolumns);

$allcolumnsArr=array_diff($allcolumnsArr,$showcolumnsArr);
$leftcolumns=array();
foreach($allcolumnsArr as $key => $val)
{
    $leftcolumns[$key]=$val.'</option>';
}
$leftcolumns=implode('</option>',$leftcolumns);

$smarty->assign("AVALABLE_FIELDS", $leftcolumns);
$smarty->assign("FIELDS_TO_MERGE", $showcolumns);
/*echo '&#&#&#';
$smarty->display('MergeColumns.tpl');
exit();*/
//edior:gyq_20200309
$strcontent=$smarty->fetch('MergeColumns.tpl');
$_REQUEST['diony']='diony';
$arr['title']=getFixedLabel('QUERY');
$arr['oktext']=getFixedLabel("FINDDUPLICATERECORDS");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$strcontent;
//$arr['picklistDependencyDatasource']=$picklistDependencyDatasource;
//$arr['picklistcontent']=$global_pick_list_values;
//$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
ConvertTojsonString(1,$arr,"success");


?>