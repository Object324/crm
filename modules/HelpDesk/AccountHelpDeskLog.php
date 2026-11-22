<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
global $app_strings, $mod_strings, $currentModule, $theme;
global $list_max_entries_per_page_new;
global $current_user,$adb;
$url_string = '';
$smarty = new lingdangCRM_Smarty();
//获取客户ID
if(!empty($_REQUEST['acount_id'])){
    $account_id = $_REQUEST['acount_id'];
}
$focus = CRMEntity::getInstance($currentModule);//初始化模块类
$focus_obj=Field::getInstance($currentModule,$adb);//初始化模块字段类
$customView = CustomView::getInstance($currentModule);//初始化分类类
$all_cvid = getCvIdOfAll($currentModule);
$customViewColumnList = $customView->getColumnsListByCvid($all_cvid);
$moduleFields = $focus_obj->getModuleFields();
$queryGenerator = new QueryGenerator($currentModule, $current_user,$customView);
$queryGenerator->initForCustomViewById($all_cvid);
$queryGenerator->getSelectClauseColumnSQL();
$fields = $queryGenerator->getFields();
$list_max_entries_per_page_new = 5;//每页显示5个
$start = 1;
//获取模块链接字段
$entityfieldname = getEntityFieldNames($currentModule);
$entityname = $entityfieldname['fieldname'];
if(!empty($_REQUEST['start'])){
    $start = $_REQUEST['start'];
}
$column_fieldInfo = $queryGenerator->column_fieldInfo;
foreach($column_fieldInfo as $field){
	if($field->getUIType() != 73){
		$searchFieldArr[] = $field->getColumnName();
		$listview_header[] = $field->getfieldLabel();
		$columns[] = $queryGenerator->getSQLColumn($field->getFieldName());
	}
}
$table_name = $focus->table_name;
$table_index = $focus->table_index;
$controller = new ListViewController($adb, $current_user, $queryGenerator);
$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
$limit_sql = " limit $limit_start_rec,$list_max_entries_per_page_new";
$order_by = " order by ld_troubletickets.modifiedtime desc";
$query = "SELECT distinct $table_name.$table_index," .implode(',',$columns) .  $queryGenerator->getFromClause() . $queryGenerator->getWhereClause();
//客户id
$query .= ' and '.$table_name . '.accountid=' .$_REQUEST['acount_id'];

/*********************************************************************************
 * Liver 2016/06/01
 *bug0022802: 客户服务单>明细：服务单历史记录，服务单历史建议修改为根据修改时间降序显示
 ********************************************************************************/
 $query .=$order_by;
//list($query,$order_by,$sorder) = $focus->getOrderWhere($query);//排序
$noofrows = $adb->num_rows($adb->pquery($query));//获取总条目数
$query .= $limit_sql;
$list_result = $adb->pquery($query,array());
$showfieldvalueobj = new ShowFieldValue($focus->fieldobj,$currentModule,SHOW_POPUP);
$showfieldvalueobj->setadbResult($list_result);
$num_rows = $adb->num_rows($list_result);
if(empty($_REQUEST['acount_id']))$num_rows = 0;
for($i = 0; $i<$num_rows; $i++){
    foreach($searchFieldArr as $key => $columnname){
        $recordid = $adb->query_result($list_result,$i,$table_index);
        $showfieldvalueobj->setRecorId($recordid);
        $field=$focus->fieldobj->getFieldInfoobjBykey('columnname',$columnname);
        $showvalue=$showfieldvalueobj->getFieldValueByField($field,$adb->query_result($list_result,$i,$columnname),$adb->query_result($list_result,$i,$columnname));
        $res=$showvalue['value'];
    	if($res == null)$res = '';
        if($entityname == $columnname){
           // $res = "<a href='index.php?module=$module&action=DetailView&record=$recordid' title=$res target='_blank'>" . $res ."</a>";
           $res="<a href='javascript:;' referencemodule='HelpDesk' referencerecord='$recordid' onclick='ListReferenceLinkClick(ld(this),event)' fieldname='$entityname' title=$res>$res</a>";
           
        }
    	$listviewentity[$recordid][$columnname] = $res;
    }
}
crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
$navigation_array = VT_getSimpleNavigationValues($start,5,$noofrows);//获取分页具体参数数组
//获取分页
crm_load_function_file('getTableHeaderSimpleNavigation2','include/utils','ListViewUtils');
$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, 'getAccountByHelpDesk', $currentModule, 'index', $all_cvid);
crm_load_function_file('getRecordRangeMessage','include/utils','ListViewUtils');
$recordListRangeMsg = getRecordRangeMessage($list_result, $limit_start_rec,$noofrows);
//显示列表
$table = '<table border="0" cellspacing="1" cellpadding="0" width="100%" class="listdata">';
$table .='<input type="hidden" id="accountid" name="accountid" value="'.$account_id.'" />';

if(!empty($listviewentity)){
    //列头
    $table .='<tr>';
    foreach($listview_header as $fieldlabel){
        $tmptitle = strip_tags(html_entity_decode($fieldlabel));
        $table .='<th data-tip="'.$tmptitle.'" data-direction="top" data-type="position" class="tip-items-list ">' . $fieldlabel . '</th>';
    }
    $table .='</tr>';
    //内容
    foreach($listviewentity as $record=>$listview){
        $table .='<tr bgcolor="white">';
        foreach($listview as $keyval => $val){
            $fieldname=$focus->fieldobj->getFieldInfoBykeyValue('columnname',$keyval,'fieldname');
            $uitype = $focus->fieldobj->getFieldInfoBykeyValue('columnname',$keyval,'uitype');
            //zkt 20240524 BUG20240523-04
            $tmptitle = strip_tags(html_entity_decode($val));
            if($uitype == '222'){
                If(!empty($val['imagepath']))
                    $table .='<td title="" referencemodule="HelpDesk" referencerecord="'.$record.'" fieldname="'.$fieldname.'">' .
                                 '<img src="' . $val['imagepath'] . '" alt="" title="" LANGUAGE=javascript align="absmiddle" width="50" height="80" style="transform:rotate(-90deg);left: 20px;position: relative;"></img>'
                                     .'<br />'. getFixedLabel('handwritingdatetime') . ':' . $val['datetime'] .
                             '</td>';
                else{
                    $table .='<td data-tip="'.$tmptitle.'" data-direction="top" data-type="position" class="tip-items-list "  referencemodule="HelpDesk" referencerecord="'.$record.'" fieldname="'.$fieldname.'"></td>';
                }
            }else{
                $table .='<td data-tip="'.$tmptitle.'" data-direction="top" data-type="position" class="tip-items-list "  referencemodule="HelpDesk" referencerecord="'.$record.'" fieldname="'.$fieldname.'">' . $val .'</td>';
            }
            //$table .='<td title="'.$val.'" referencemodule="HelpDesk" referencerecord="'.$record.'" fieldname="'.$fieldname.'">' . $val .'</td>';
        }
        $table .='</tr>';
    }
}else{
    $colspan = count($listview_header);
    $table .='<tr align="left"><td style="padding-left: 5px;background-color:#fff;font-size: 13px;"colspan="'.$colspan.'">' . getFixedLabel('NOTFOUNDANYRECORD') . '</td></tr>';
}
$table .='</table>';
$smarty->assign('TABLE',$table);
$smarty->assign("NAVIGATION", $navigationOutput);
$smarty->assign('recordListRange',$recordListRangeMsg);
$smarty->assign('COUNT',count($listviewentity));
$smarty->assign('START',$start);
$smarty->display('AccountHelpDeskListView.tpl');
exit();
?>