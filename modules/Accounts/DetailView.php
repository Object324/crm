<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $theme,$adb;
global  $currentModule,$navigationInfo;                     
global $current_user;
$languageType= getLanguageType($current_user);

$smarty = new lingdangCRM_Smarty;

$focus = CRMEntity::getInstance($currentModule);
$fieldobj=Field::getInstance($currentModule,$adb);
$version=getVersionTradeInfo();//获取数据库行业版本
$version_trade=$version['trade'];

if(isset($_REQUEST['record'])) {
    $focus->retrieve_entity_info($_REQUEST['record'],"Accounts");
    $focus->id = $_REQUEST['record'];	
    $focus->name=$focus->column_fields[$focus->list_link_field];
    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$focus->getSmownerColumName());
    if(!empty($fieldinfo) && $focus->column_fields[$fieldinfo->getFieldName()]!=$current_user->id)
    {
        crm_load_class_file('cls_CurUserDataScope','include/ListView');
        $datascopeobj=cls_CurUserDataScope::getInstance('Accounts','record');
        $datascopeobj->isMyViewData($_REQUEST['record']);
    }

}
crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
$cls_PublicAccounts = cls_PublicAccounts::getInstance($currentModule);
$public_account = $cls_PublicAccounts->getPublicAccountConfig();
if($public_account['status'] == 'yes'){
    $focus->setpublicaccountpool($public_account['public_account_pool']);
}
/* 详情页按钮 begin */
$focus->getModuleLogic($currentModule)->getDetailViewButton();

$smarty->assign('APPROVESTATUS',$focus->logic->getApproveImage());//审批状态图片
if(isset($_REQUEST['record']) && isset($_REQUEST['record'])) {
	$focus->id = $_REQUEST['record'];
	$focus->name=$focus->column_fields[$focus->list_link_field];
}
$smarty->assign('APPROVEMOD','1');//审批模块，是否加载审批历史
if(isset($_REQUEST['isDuplicate']) && $_REQUEST['isDuplicate'] == 'true') {
	$focus->id = "";
}
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
//是否显示服务显示
//edit:can reason:16920: 客户服务单模块关闭，然后用户管理中勾选【是否显示服务信息】和【是否允许查看具体的服务到期日】，打开客户明细查看界面，备注信息下面会显示‘undefined’
//edit:duan reason:48297 客户模块的服务合同信息只受服务合同模块控制,不受客户服务单控制
//if(vtlib_isModuleActive('HelpDesk'))
$smarty->assign('SELECTSERVICEDETAIL',$current_user->select_servicedetail);


$smarty->assign("THEME", $theme);
$smarty->assign("IMAGE_PATH", $image_path);
$smarty->assign("PRINT_URL", "phprint.php?jt=".session_id().$GLOBALS['request_string']);

if (isset($focus->name)) $smarty->assign("NAME", $focus->name);
else $smarty->assign("NAME", "");

crm_load_class_file('Detail_Edit_View','include/utils');

$smarty->assign('CONTACTID',Detail_Edit_View::getAccountPrimaryContactInfo($focus));
global $detail_column_fields_value;

global $global_pick_list_values;
crm_load_class_file('ModuleUtils','modules/lingdang');
$ModuleUtilsObj = new ModuleUtils();
$smarty->assign("BLOCKS", $ModuleUtilsObj->getBlocks("Accounts","detail_view",'',$focus->column_fields));

$smarty->assign("COLUMN_FIELDS_VALUE",json_encode($detail_column_fields_value));
 
$smarty->assign("CUSTOMFIELD", $cust_fld);
$smarty->assign("ID", $_REQUEST['record']);
$smarty->assign("SINGLE_MOD",'Accounts');
$fields=$focus->fieldobj->getFieldListArray();
$smarty->assign('FIELDINFOJSON',json_encode($fields['fields']));
$smarty->assign("MODULELINKFIELD",$focus->list_link_field);
$smarty->assign("SMOWNERCOLUMNNAME",$focus->getSmownerColumName());
if(useInternalMailer() == 1)
	$smarty->assign("INT_MAILER","true");

$tabid = getTabid("Accounts");
$fields=$focus->fieldobj->getFieldListArray();
$data=$fieldobj->split_validationdataArray();




$smarty->assign("MODULE",$currentModule);

//$recordNavigationInfo = ListViewSession::getListViewNavigation($focus->id);

//VT_detailViewNavigation($smarty,$recordNavigationInfo,$focus->id);

//更多信息
$is_rel_list = array();

 
         
$is_rel_list = Detail_Edit_View::isPresentRelatedLists($currentModule,$activity_mode);   


if(get_callLinkDisplay() == 'no'){
    crm_load_class_file('cls_CallRecord','modules/Settings');
    $callrecordobj = new cls_CallRecord($currentModule);
    if($callrecordobj->getModuleCallRecordStatus() == 'no'){
        unset($is_rel_list[f_array_search('CallButler',$is_rel_list)]);
    }
}
if($public_account['status'] != 'yes'){
	unset($is_rel_list[f_array_search('publicaccount_log',$is_rel_list)]);
}
if($version_trade != 'finance'){ //更多信息【已购产品】，在非金融行业不显示
    if(!empty($is_rel_list) && f_array_search('BoughtProduct',$is_rel_list) > 0){
        unset($is_rel_list[f_array_search('BoughtProduct',$is_rel_list)]);
    }
  
    
}
$version_info = getVersionInfo();
/** 赛克
* edit: chj
* date: 2020-07-21
* reason: 电话呼入时，根据呼入的电话号码，调用赛克出行api，获取订单信息
*/
if($version_info['account'] == 'saic' && !empty($focus->column_fields['accountname'])){
	crm_load_class_file('cls_saic_api','modules/Accounts');
	$cls_saic_api = new cls_saic_api();
	$orderlist = $cls_saic_api->getOrderListLog($focus->column_fields['accountname']);
	$smarty->assign('ORDERLISTLOG',$orderlist);
}
$smarty->assign('VERSION_ACCOUNT',$version_info['account']);
$smarty->assign('MODE','detail');
/**
 *edit:cyb
 *date:2016-01-15
 *reason:若软件厂商选择“金蝶”，软件版本选择“K3系统”  ,则相关信息显示金蝶订单和金蝶报价单。
*
if(getDatainterface('soft_factory')!='金蝶' || (getDatainterface('soft_factory')=='金蝶' && getDatainterface('soft_version') != 1)){
    if(!empty($is_rel_list) && f_array_search('Kingdeeorders',$is_rel_list) > 0 ){
        unset($is_rel_list[f_array_search('Kingdeeorders',$is_rel_list)]);
    }
    if(!empty($is_rel_list) && f_array_search('Kingdeequotes',$is_rel_list) > 0 ){
        unset($is_rel_list[f_array_search('Kingdeequotes',$is_rel_list)]);
    }
}else{
    if(getDatainterface('using_order_read')==0){//表示未启用订单读取接口
        if(!empty($is_rel_list) && f_array_search('Kingdeeorders',$is_rel_list) > 0){
            unset($is_rel_list[f_array_search('Kingdeeorders',$is_rel_list)]);
        }
    }
    if(getDatainterface('using_quote_read')==0){//表示未启用报价单读取接口。
        if(!empty($is_rel_list) && f_array_search('Kingdeequotes',$is_rel_list) > 0){
            unset($is_rel_list[f_array_search('Kingdeequotes',$is_rel_list)]);
        } 
    } 
}

if(getDatainterface('soft_factory') !='鼎捷' || (getDatainterface('soft_factory')=='鼎捷' && getDatainterface('soft_version')!=201)){
    if(!empty($is_rel_list) && f_array_search('Digiwinorders',$is_rel_list) > 0){
        unset($is_rel_list[f_array_search('Digiwinorders',$is_rel_list)]);
    }
    if(!empty($is_rel_list) && f_array_search('Digiwintickets',$is_rel_list) > 0){
        unset($is_rel_list[f_array_search('Digiwintickets',$is_rel_list)]);
    } 
}else{  
    if(getDatainterface('using_order_read')==0){//表示未启用订单读取接口
        if(!empty($is_rel_list) && f_array_search('Digiwinorders',$is_rel_list) > 0){
            
            unset($is_rel_list[f_array_search('Digiwinorders',$is_rel_list)]);
        }
    }
    if(getDatainterface('using_ticket_read')==0){//表示未启用读取接口。
        if(!empty($is_rel_list) && f_array_search('Digiwintickets',$is_rel_list) > 0){
            unset($is_rel_list[f_array_search('Digiwintickets',$is_rel_list)]);
        } 
    }    
}*/
if(!empty($is_rel_list) && f_array_search('AccountHierarchy',$is_rel_list)> 0&& !isset($focus->column_fields['account_id'])){
    unset($is_rel_list[f_array_search('AccountHierarchy',$is_rel_list)]);
}

$is_rel_list = Detail_Edit_View::setForeachRelatedLists($is_rel_list);
$smarty->assign("IS_REL_LIST",$is_rel_list);

$smarty->assign("ASSIGNUSERID",$focus->column_fields["assigned_user_id"]);

$smarty->assign('DETAILVIEW_AJAX_EDIT', PerformancePrefs::getBoolean('DETAILVIEW_AJAX_EDIT', true));

$smarty->assign('ACCOUNTID',$focus->id);

// 在初始化时已经获取当前客户是否为公海客户，不需要再次读取
global $static_publicaccount;
if(!isset($static_publicaccount)){
	$sql_accountid='select publicaccount from ld_account  where accountid=? limit 1;';
	$sql_result=$adb->pquery($sql_accountid,array($_REQUEST['record']));
	$static_publicaccount=$adb->query_result($sql_result,0,'publicaccount');
}
//chj 2021/1/5 44027: （https://61mis.com/kfbtest/ [^]）测试部账号，客户管理>客户1>全部（含指定公海）>批量领取123；该客户的公海状态：公海未分配 ，详情页面没有显示未分配的图标
$smarty->assign("PUBLICACCOUNT",$static_publicaccount);
/*
 *更新操作
 *edit:lmx
 *data:20140214
 *reason:转公海或者转普通按钮   改成  转换公海
*/
if($public_account['status'] == 'yes'){
	$transfer_permit = 'no';
    $public_account_pool = [];
    if(!empty($public_account['public_account_pool'])){

		$sql_accountid='select pool_id,publicaccount from ld_account  where accountid=? limit 1;';
		$sql_result=$adb->pquery($sql_accountid,array($_REQUEST['record']));
		$acc_pool_id=$adb->query_result($sql_result,0,'pool_id');
        $publicaccount=$adb->query_result($sql_result,0,'publicaccount');
		foreach($public_account['public_account_pool'] as $pool_id => $pool_info){
			if($acc_pool_id != $pool_id && $focus->column_fields['publicaccount'] >= 1)continue;
			$admins = explode(',',$pool_info['administrators']);
			$transfer_users_array = explode(',',$pool_info['transfer_users']??'');	//允许“转换公海”的成员 
			$userids = explode(',',$pool_info['userids']);
			if($focus->column_fields['publicaccount'] == 0 && (in_array($current_user->id,$admins) || in_array($current_user->id,$transfer_users_array) || in_array($current_user->id,$userids))){	//如果该客户是“普通客户”，则仅当用户是“公海管理员”时显示按钮
				$transfer_permit = 'yes';
				break;
			}else if($focus->column_fields['publicaccount'] == 1 && (in_array($current_user->id,$admins) || in_array($current_user->id,$transfer_users_array))){	//如果该客户是“公海未分配客户”，则仅当用户是“公海管理员”时显示按钮
				$transfer_permit = 'yes';
				break;
			}else if(($focus->column_fields['publicaccount'] == 2 || $focus->column_fields['publicaccount'] == 3) && (in_array($current_user->id,$admins) || in_array($current_user->id,$transfer_users_array) || (in_array($current_user->id,$userids) && $pool_info['allow_trasnfer_others'] == 'yes'))){	//如果该客户是“公海已分配客户”，并且当前用户是“公海管理员”时显示按钮
				//当前用户只是“公海用户”且该客户“所属公海”的参数设置勾选了“允许公海成员将已分配或领取的公海客户移客户到其他公海”时，也显示“转换公海”按钮
				$transfer_permit = 'yes';
				break;
			}
		}
		//47686: （81mis.com/kfbcrm）客户管理-客户；成员只在一个‘默认公海’池，该公海池勾选了允许转换公海已分配客户；当成员在已分配客户详情时 不应该显示转换公海按钮
		$commonaccount = 'yes';
        if(!empty($_REQUEST['record'])){
			$query = "select 1 from ld_account where publicaccount >= 1 and accountid in (".$_REQUEST['record'].") and deleted = 0";
			//echo $query;echo '<br><br>';
			$result = $adb->pquery($query,array());
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){ //全部是公海客户
				$focus->retrieve_entity_info($_REQUEST['record'],$currentModule);
				$tmp_pool_id = $focus->column_fields['pool_id'];
				$tmp_publicaccount = $focus->column_fields['publicaccount'];
				if ($tmp_publicaccount >= 1) { //公海客户
					if (!in_array($current_user->id, explode(',',$public_account['public_account_pool'][$tmp_pool_id]['administrators'])) && in_array($current_user->id, explode(',',$public_account['public_account_pool'][$tmp_pool_id]['userids']))) {
						$commonaccount = 'no';//公海成员只显示选项“转移到公海”
					}
				}else{//含有普通客户
//                    $commonaccount = 'no';
//                    break;
				}

            }else{//全部是普通客户，则只显示选项“转移到公海”
                $commonaccount = 'no';
            }
        }else{
            $commonaccount = 'no';
        }

//        @edit:liushuai,2021-07-20,reason: 详情页显示转换公海按钮还需要判断是否有编辑权限（比如共享的单据）、转公海是否有可选公海池
        //获取当前用户有权限看到的公海池  -- 摘自移动端cls_Acccounts_DetailViewWX.php
        foreach($public_account['public_account_pool'] as $temp_pool_id => $pool_info){
            if(!empty($pool_info['administrators'])){
                $admins = explode(',',$pool_info['administrators']);
                if(in_array($current_user->id,$admins)){
                    $public_account_pool[$temp_pool_id] = $pool_info['pool_name'];
                }
                //公海客户“公海已分配”页签：可选公海仅显示当前用户是“公海管理员”或“公海成员”的公海池
                $userids = explode(',',$pool_info['userids']);
                if(in_array($current_user->id,$userids)){
                    $public_account_pool[$temp_pool_id] = $pool_info['pool_name'];
                }
            }
        }
        //公海未分配、公海已分配 。 过滤当前公海池
        if($publicaccount >= 1 && !empty($acc_pool_id)){
            unset($public_account_pool[$acc_pool_id]);
        }
	}

    //edit:can 20210816 47479: （https://61mis.com/order/ [^]）公海已分配客户单据查看详情界面， 在工具条更多中， 没有“转换公海”选项
	if(($commonaccount == 'yes' || ($transfer_permit == 'yes' && !empty($public_account_pool)))  && isPermitted($currentModule,"EditView",$_REQUEST['record']) == 'yes'){
		$publicbutton['turnhighseas'] = getFixedLabel('Transfer');
	}
	$smarty->assign('POOL_ID',$focus->column_fields['pool_id']);

	//ls 2022-02-23 公海状态字段未开启时，需查询优化
    if(!isset($focus->column_fields['publicaccount'])){
        $result = $adb->pquery("select publicaccount from ld_account where accountid = ?",array($focus->id));
        $focus->column_fields['publicaccount'] = $adb->query_result($result,0,0);
    }
	if(isset($focus->column_fields['publicaccount'])){
		if($focus->column_fields['publicaccount'] == 1){
			$smarty->assign('PUBLICACCOUNTTYPE','NOALLOCATE');
		}else if($focus->column_fields['publicaccount'] == 2 ||$focus->column_fields['publicaccount'] == 3){
			$smarty->assign('PUBLICACCOUNTTYPE','PUBLICALLOCATE');
		}else{
			$smarty->assign('PUBLICACCOUNTTYPE','COMMONACCOUNT');
		}
	}
	
}
/*
*更新操作
*edit:diony
*time:2014-07-23
*判断是否启用公海客户
*/    
//$status=getAccount_Set('status');
$smarty->assign('PUBLICACCOUNTSTATUS',$public_account['status']);

/*$status=1;
$adminaccount="";
$usersaccount="";
//if($adb->num_rows($accountset)>0)
//{
    $status=getAccount_set('status');
    $adminaccount=getAccount_set("adminaccount");
    $usersaccount=getAccount_set('usersaccount');
//}
$smarty->assign("ACCOUNTSET",$status);

$splitadmin=explode(",",$adminaccount);
$splituser=explode(',',$usersaccount);

$smarty->assign("PUBLICACCOUNT",$static_publicaccount);
$smarty->assign("LANGUAGETYPE",$languageType);
//客户，公海操作按钮
$publicbutton = array();

if($static_publicaccount==0&&$status==0 &&($current_user->is_admin=="on"||in_array($current_user->id,$splitadmin)
    ||in_array($current_user->id,$splituser)))
{

	 $publicbutton['turnhighseas'] = getFixedLabel('TURNHIGHSEAS');
}
elseif($status==0&&($current_user->is_admin=="on"||in_array($current_user->id,$splitadmin)||in_array($current_user->id,$splituser)))
{
    $normalconvertbuttonprofile=getAccount_set('normalconvertbuttonprofile');//增加公海已分配客户转普通权限
    //dump($static_publicaccount);
    //edit:can 2020812 042363: （http://111.17.206.203:85/crm [^]）（客户问题：山东巨亚环保设备有限公司）系统设置>公海参数设置>勾选了“公海已分配客户不允许转普通（只能由公海管理员转普通）”：使用普通用户账号登录，进入单据明细界面还是可以转普通。
    if($normalconvertbuttonprofile=='yes'&&($static_publicaccount==2 ||$static_publicaccount==3)&&!in_array($current_user->id,$splitadmin)&&!is_admin($current_user))//公海已分配
    {
        
    }
    else
	 $publicbutton['turnordinary'] = getFixedLabel('TURNORDINARY');
}*/
$focus->logic->setPublicDetailBtn($publicbutton);
$smarty->assign('DETAILBUTTON',$focus->logic->detail_buttons);

/**
 * 销售通，基础版，因为只有合同订单模块，所以没必要显示往来对账
 * @author Tujt 2014-06-12
 */
$reg = RegOp::getInstance();
$testFile = $reg->isExistFile();
if($testFile == 0){//不存在
    require_once("VersionType.php");
    global $VersionNo;
    $RegisterVersionNo = $VersionNo;
}else{
    $RegisterVersionNo = $reg->GetVersionNo();
}
$modbalancestr = '';
if($RegisterVersionNo != '2'&&$RegisterVersionNo!='7'){//销售通,基础版，不显示往来对账
	/**
	 * @project PROT21 龙威机械：往来对账
	 * @author Tujt 2014-06-06
	 */
	$modbalance = array('SalesOrder','CashBill','SalesBack','CashBack');
	if($current_user->is_admin == 'on'){
		foreach($modbalance as $mod){
			if(vtlib_isModuleActive($mod))
				$modbalancestr .= $mod.',';
		}
	}else{
		foreach($modbalance as $mod){
			if(isPermitted($mod,'index','')=='yes' && vtlib_isModuleActive($mod))
				$modbalancestr .= $mod.',';
		}
	}
	$modbalancestr = trim($modbalancestr,',');
}

$smarty->assign('MODBALANCESTR',$modbalancestr);
/* 关联创建 begin */
//$smarty->assign('QUICKACTIONLINK',$focus->logic->getActionUserd());
//$smarty->assign('ACTION_SHOW_NO',$focus->logic->getIsShowAction());
//

//diony 2014-10-15 弹屏新增时自动传值
if(isset($_REQUEST['callphone']) && $_REQUEST['callphone'] != '')
{
    $smarty->assign('CALLPHONE',$_REQUEST['callphone']);
}
if(isset($_REQUEST['callfilename']) && $_REQUEST['callfilename'] != '')
{
      $one_callfiles=explode('\\',$_REQUEST['callfilename']);
     $two_callfilename=$one_callfiles[sizeof($one_callfiles)-1];
     $callfilenames=explode('_',$two_callfilename);
     $callphone=$callfilenames[0];
     $xinghao_phone= fieldValueUitype::setReportMobileStyle($callphone);
     for($i=0;$i<sizeof($one_callfiles)-1;$i++)
     {
        $filenames.=$one_callfiles[$i].'\\';
     }
    $one_filenames=$filenames.$xinghao_phone.'_'.$callfilenames[1];
    crm_load_class_file('cls_PhoneEncrypt','include');
    $obj=new cls_PhoneEncrypt();

    $two_filenames=$filenames.$obj->createToken_Phone($callphone).'_'.$callfilenames[1] ;

    $smarty->assign('CALLFILENAME',$one_filenames);
    $smarty->assign('ENCRYPT_FILENAME',$two_filenames);
    
    $smarty->assign('CALLDISPLAY','yes');
    
    $callButlerRemarks = "";
    $callbutlernameNew = str_replace("\\","\\\\",$callbutlername);    
    $callbutlernameNew = str_replace("\\","\\\\",$callbutlernameNew);  
    $callbutlerGetSql = "select id,description from ld_callbutler where soundrecordingfile like '%$two_callfilename%' ";    
    
    $callbutlerGetResult=$adb->pquery($callbutlerGetSql);
    if($adb->num_rows($callbutlerGetResult))
    {
        //存在
        $callButlerID = $adb->query_result($callbutlerGetResult,0,'id');
        $callDescription = $adb->query_result($callbutlerGetResult,0,'description');
        $smarty->assign('CALLDESCRIPTION',$callDescription);
       
        $sqlUpdate = "update ld_callbutler set accountid = ?,description = ?,userid=? where id = ? ";
        $updateResult=$adb->pquery($sqlUpdate,array($_REQUEST['record'],$callButlerRemarks,$current_user->id,$callButlerID));
        
        
    }
    else
    {
		
		
        //不存在
        $sqlInsert = "insert into ld_callbutler 
        (calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
         accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,description) 
        values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
        ";
        $callbutlername = str_replace("\\\\","\\",$callbutlername);
        if($_REQUEST['calltype']==1)
        {
            $calltype='外拨';
        }
        else
        {
            $calltype='来电';
        }
        $insertresult=$adb->pquery($sqlInsert,array($calltype,$callphone,'接通',null,null,'',$one_filenames,$current_user->id,
        $_REQUEST['record'],0,0,0,0,0,0,$callButlerRemarks));
    }
}
else
{
    $smarty->assign('CALLDISPLAY','no');
}
if(vtlib_isModuleActive('Contacts'))
	$smarty->assign('CONTACTSSTATUS','yes');
else
	$smarty->assign('CONTACTSSTATUS','no');
//获取公海参数设置 zyh 20150520
//$buttontype = getAccount_Set('buttontype');
//$smarty->assign('BUTTONTYPE',$buttontype);
//chj 2021/7/20 46998: https://51mis.com/hy/wj0716/ [^]，五金行业演示账套-客户管理-客户-点击任意客户名称-地址信息-编辑城市出现全国所有市，编辑区域出现全国所有区，且点击下拉框会出现明显卡顿
global $global_pick_list_depencyfield;

include(globalStatic::$root_directory.'include/DetailViewBlockStatus.php');
//$smarty->assign("PICKLISTCONTENT",ldcrm_json_encode($global_pick_list_values));
setGLobalURLSmarty($smarty);//设置js,css等访问路径
//单据编号重复提示
//$smarty->assign('MODULEBILLNOTIP',$_SESSION[$currentModule.'_modulebillnotip']);
$_SESSION[$currentModule.'_modulebillnotip']='no';


//相关信息日期高级查询
//Crm_load_class_file("CommonView","modules/CustomView");

$smarty->assign("ReferenceUitypes",cls_module_uitype::getAllUitypes());
$smarty->assign("UITYPEMODULES",cls_module_uitype::getUitypeModules());

DetailViewReturn($currentModule,$focus,$smarty);
//布局规则
//crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
//$fieldruleobj=cls_fieldrule::getInstance($currentModule);
//$_REQUEST['diony']='diony';

//布局规则
//crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
//$fieldruleobj=cls_fieldrule::getInstance($currentModule);
//$_REQUEST['diony']='yes';
//$arr['fieldrulefieldnames']=$fieldruleobj->getAllFieldNameSetChangeEvent();////获取所有的触发字段
//$arr['datetimestr']=CommonView::stdFilterDateTimeStr();
//$arr['picklistcontent']=$global_pick_list_values;
//$arr['validatasave']=getValidataSave($currentModule);
//$arr['picklistdepencyfields']=$global_pick_list_depencyfield;
//$arr['picklistdepency']=$picklistDependencyDatasource;
//$arr['column_fields_value']=$detail_column_fields_value;
//$arr['fields']=$fields['fields'];
//$arr['title']=getTranstab($currentModule);
//$arr['list_link_field']=$focus->list_link_field;
////$arr['oktext']=getFixedLabel("SAVE");
////$arr['canceltext']=getFixedLabel("CANCEL");
//$content=$smarty->fetch("DetailView/PopupDetailRelated.tpl");
//$arr['content']=$content;
//ConvertTojsonString(1,$arr,'success');

?>