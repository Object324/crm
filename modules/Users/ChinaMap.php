<?php
/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}

 ********************************************************************************/
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user;
$smarty = new lingdangCRM_Smarty;
require('user_privileges/user_language_'.$current_user->id.'.php');
if(isset($_REQUEST['hiddenscope']))
{
    $ownScope = $_REQUEST['hiddenscope'];
}else{
	$ownScope = 'SmOwner_Search_All';
}
$smarty->assign("SENIORUSERIDSS",$_REQUEST['selectuid']);
$smarty->assign('module_ownerScope', $ownScope);
$focus=CRMEntity::getInstance('Accounts');
$main_module_fields=$focus->fieldobj->getModuleFields();
setSearchAllAccount();//设置查询所有的客户（包括公海客户）
if(!empty($_REQUEST['getCountry']) && $_REQUEST['getCountry'] == 'true'){
    //editor:gyq_20190528 reason:将PC代码提取为类方法get_account_map 0036898
    //0036898: （公司自用账套）企业微信>灵当CRM>报表>客户地图：地图没有统计数据，电脑端是有数据的。
    crm_load_class_file('cls_ReportDetailInfoMC','appCommon/detail');
    $modelobj = new cls_ReportDetailInfoMC(0);
    $account_info = $modelobj->get_account_map();
    @ob_clean();
	@ob_flush();
    echo json_encode($account_info);
    exit();
}else if(!empty($_REQUEST['bill_state']) && !empty($_REQUEST['bill_city'])){
    //editor:gyq_20190813 reason:企业微信参考此段代码，新增了ChinaMap方法,地址WeiXinApp\modules\Accounts\cls_Accounts\cls_Accounts_ListViewWX.php
	$focus=CRMEntity::getInstance('Accounts');
    $main_module_fields=$focus->fieldobj->getModuleFields();
	$arrfieldLabels=$focus->fieldobj->getFieldLables();
	unset($_SESSION['LiveViewSearch']['Accounts']['input']);
    resetPublicSession();

	$k = 0;
         if(($_REQUEST['bill_state']=='上海'||$_REQUEST['bill_state']=='上海市')||($_REQUEST['bill_state']=='北京'||$_REQUEST['bill_state']=='北京市')
         ||($_REQUEST['bill_state']=='天津'||$_REQUEST['bill_state']=='天津市')
            ||($_REQUEST['bill_state']=='重庆'||$_REQUEST['bill_state']=='重庆市'))
         {
            $bill = array('bill_state','bill_area');
         }
         else
		  $bill = array('bill_state','bill_city');
    foreach($main_module_fields as $fieldname=>$fieldinfo){
		if(in_array($fieldname,$bill)){
			$columncondition = '';
			$tablename=$fieldinfo->getTableName();
            $columnname=$fieldinfo->getColumnName();
            $typeofdata=$fieldinfo->getTypeOfData();
			$types=explode('~',$typeofdata);
            $typeofname=$types[0];
            $fieldlabel=$fieldinfo->getFieldLabelKey();
			if(isset($arrfieldLabels[$fieldname])){
				$label=$arrfieldLabels[$fieldname];
				$fieldLabelEscaped = str_replace(" ","_",$label);
			}
			$typeOfData = $fieldinfo->getTypeOfData();
			$typeOfData = explode("~",$typeOfData);
			$typeOfData = $typeOfData[0];
			if($k == 0){
				$columncondition = 'and';
			}
			if(!empty($columnname)){
				$columnname_str = $tablename.":".$columnname.":".$fieldname.":Accounts_".$fieldLabelEscaped.":".$typeOfData;
				if($fieldname == 'bill_area')$fieldname = 'bill_city';
				$advft_criteria[] = array(
					'groupid' => 1,
					'columnname' => $columnname_str,
					'comparator' => 'c',
					'value' => $_REQUEST[$fieldname],
					'columncondition' => $columncondition,
					
				);
			}
			$k++;
		}
	}
	//平铺查找条件
    $advft_criteria_request = $_REQUEST['advft_criteria'];
    $advft_criteria_groups_request = $_REQUEST['advft_criteria_groups'];
    $advft_criteria_request = Zend_Json::decode($advft_criteria_request);
    if(is_array($advft_criteria_request)&&sizeof($advft_criteria_request)>0){
        $advft_criteria[sizeof($advft_criteria)-1]["columncondition"] = "and";
        $advft_criteria = array_merge($advft_criteria,$advft_criteria_request);
    }
    $fieldinfo=$main_module_fields['bill_country'];
    if($fieldinfo&&$fieldinfo->getFieldName()!='')
    {
    	//添加 国家 条件
        $groupcondition = '[null,{"groupcondition":"and"},{"groupcondition":""}]';
        $advft_criteria[] = array(
            'groupid' => 2,
            'columnname' =>"ld_account:bill_country:bill_country:Accounts_".$fieldinfo->getFieldLabelKey().":V",
            'comparator' => 'isnull',
            'value' => '',	
            'columncondition' => 'or',
            );
        $advft_criteria[] = array(
            'groupid' => 2,
            'columnname' =>"ld_account:bill_country:bill_country:Accounts_".$fieldinfo->getFieldLabelKey().":V",
            'comparator' => 'e',
            'value' => '中国',	
            'columncondition' => '',
            );
    }
   /*$groupcondition='';
    if(
        //zxm 20230601 0051711 上面已经对上海特殊判断了 这里就不需要上海了 不然条件就重复了 客户地图，点进上海》再点击有客户的区域，界面跳转到客户列表后，带出的高级条件重复
//        ($_REQUEST['bill_state']=='上海') ||
        ($_REQUEST['bill_state']=='北京')
    ||($_REQUEST['bill_state']=='天津')
    ||($_REQUEST['bill_state']=='重庆'))
    {
        if(sizeof($advft_criteria)>0)
        {
            $groupcondition='[null,{"groupcondition":"or"},{"groupcondition":""}]';
        }
        
        
        $fieldinfo=$main_module_fields['bill_city'];
       if($fieldinfo&&$fieldinfo->getFieldName()!='')
        {
        
        $advft_criteria[] = array(
            'groupid' => 2,
            'columnname' =>"ld_account:bill_city:bill_city:Accounts_".$fieldinfo->getFieldLabelKey().":V",
            'comparator' => 'c',
            'value' => $_REQUEST['bill_state'],	//chj 2021/1/18 44302: (http://124.248.48.38:85/crm/ [^])客户问题-联合济康，客户管理>客户地图：点击“北京-顺义区”显示客户数为“31”，穿透到列表提示“没有找到任何记录”
            'columncondition' => 'and',
            );
        }
         $fieldinfo=$main_module_fields['bill_area'];
        if($fieldinfo&&$fieldinfo->getFieldName()!='')
        {
        	$advft_criteria[] = array(
                'groupid' => 2,
                'columnname' =>"ld_account:bill_area:bill_area:Accounts_".$fieldinfo->getFieldLabelKey().":V",
                'comparator' => 'c',
                'value' => $_REQUEST['bill_city'],
                'columncondition' => '',

            );
        }
        //平铺查找条件--改变groupid
        if(is_array($advft_criteria_request)&&sizeof($advft_criteria_request)>0){
            $advft_criteria[sizeof($advft_criteria)-1]["columncondition"] = "and";
            $advft_criteria_request_2 = [];
            foreach($advft_criteria_request as $v){
                $v['groupid'] = 2;
                $advft_criteria_request_2[] = $v;
            }
            $advft_criteria = array_merge($advft_criteria,$advft_criteria_request_2);
        }
    }*/
	$input['advft_criteria'] = json_encode($advft_criteria);
	$input['advft_criteria_groups'] = empty($groupcondition)?$advft_criteria_groups_request:$groupcondition;
	$input['SearchScope'] = $_REQUEST['SearchScope'];

    $input['searchtype'] = 'advance';
	$_SESSION['LiveViewSearch']['Accounts']['input'] = $input;
	$_SESSION['lvs']['Accounts']['SearchScope'] = $_REQUEST['SearchScope'];
	exit();
}
//zkt 20220527 52051（https://81mis.com/kfbtest）客户管理》客户地图》查询字段创建人    选择条件没有当前用户选项
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
//---2021-1015-- zxm 【客户地图增加“平铺查找”功能】https://www.tapd.cn/63637123/prong/stories/view/1163637123001002063
//下拉框字段
$frommodule = 'Accounts';
$customView = CustomView::getInstance($frommodule);
$viewid = $customView->getViewId($frommodule);
$queryGenerator =QueryGenerator::getInstance($frommodule, $current_user,$customView);
crm_load_class_file('ProductDetail_ListController','include/ListView/ProductDetail');
$controller = new ProductDetail_ListController($adb, $current_user, $queryGenerator);
$fieldnames = $controller->getAdvancedSearchOptionString();
$smarty->assign("FIELDNAMES", $fieldnames);
$smarty->assign("MODULE", 'ChinaMap');
$smarty->assign("is_admin", $current_user->is_admin);
Crm_load_class_file("CommonView","modules/CustomView");
$smarty->assign("DATETIMESTR",json_encode(CommonView::stdFilterDateTimeStr()));
//平铺查找条件显示 --只有一条数据
$sql = 'select id,searchvalue from ld_searchhistory where modulename = ? and searchtype = ? order by searchtime desc';
$result = $adb->pquery($sql,array('ChinaMap','TiledSearch'));
//$result = $adb->pquery($sql,array('Accounts','advance'));//测试用
$num_rows = $adb->num_rows($result);
$tiledSearch = '';
if($num_rows >0){
    $tiledSearch = $adb->query_result($result,0,'searchvalue');
}
$smarty->assign("tiledSearch", $tiledSearch);

$AccountMergeSmowner=getCurSmOwnerSearchScope('Accounts');
unset($AccountMergeSmowner["UserCombo"][$current_user->id]);//去除当前用户
$smarty->assign('AccountMergeSmowner',$AccountMergeSmowner);
$smarty->assign('LANGUAGETYPE',$languageType);
// zhouxiaomei 2020-0928 客户地图增加全球客户地图的显示 重新写的模板与js方法

//zxm 20230614 获取列表页面公共参数并assign到tpl
crm_load_function_file('ListViewCommonAssign','include/utils','ListViewUtils');
ListViewCommonAssign($currentModule,$smarty,$focus);


$smarty->display("ChinaMap.tpl");
?>