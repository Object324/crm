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
 //zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user;
set_time_limit(0);
//zkt 20231009 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
/*
*新增操作，收款单批量删除报错，reason 6467 20131225
*/
//require_once('modules/Accounts/Accounts.php');
//require_once('modules/BankAccountSet/BankAccountSet.php');
$idlist = vtlib_purify($_REQUEST['idlist']);
$deployarray=getSys_deploy(67);
$btach_num =  $deployarray['deploy_value'];
$mass_del_totalrows=0;
if($idlist=='all')
{
    $_REQUEST['mass_batch_num_all']=$btach_num;
    $mass_del_totalrows=$_REQUEST['mass_del_totalrows'];
}
$viewid = vtlib_purify($_REQUEST['viewname']);
$SearchScope=vtlib_purify($_REQUEST['SearchScope']);
$returnmodule = vtlib_purify($_REQUEST['return_module']);
$return_action = vtlib_purify($_REQUEST['return_action']);
$excludedRecords=vtlib_purify($_REQUEST['excludedRecords']);
$rstart='';
$approveStatus = 0;//审批模块默认没开启
if($returnmodule =='Stock' || $returnmodule =='OutboundOrder'  || $returnmodule == 'PurchaseBack'){
	require_once('include/Stock/CommonStock.php');
}
//Added to fix 4600
$url = getBasic_Advance_SearchURL();
//审批流程单据

 if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']==true)
 {
    /**
	 * 模块关闭审批权限后，详情页可以随意删除，但批量删除时却有审批判断
	 * 现在添加模块开启审批判断，只有开启了审批才判断是否存在已审批、审批中状态下
	 * @reason 0013797: 客户：序时簿【删除】按钮与客户明细界面的【删除】按钮，代码走的不一样
	 * @author Tujt 2015-03-07
	 */
	$approve = new Approve();
	
	$startapprove = $approve->startBlocksApprove();
	$startapprove['ServiceCharge'] = getTabid('ServiceCharge');
	if(isset($startapprove[$returnmodule]) && !empty($startapprove[$returnmodule]) || $returnmodule =='OutboundOrder' || $returnmodule =='Stock' || $returnmodule=='Checks'){
		$approveStatus = 1;//审批模块开启
	}
 }
	

$entityarray = getEntitynameInfo(getTabid($returnmodule));
$tabname = $entityarray['tablename'];//模块主表
$moduleid = $entityarray['entityidfield'];//模块主表ID
$tabfieldname = $entityarray['fieldname'];//模块链接字段
if(empty($tabname)) $tabname = 'ld_'.strtolower($returnmodule);
if(empty($moduleid)) $moduleid = strtolower($returnmodule).'id';


//@edit:liushuai,2021-03-10,reason:0044897: （61mis.com/kfbcrm）客户管理-销售线索；全选线索单据后，操作删除，审批中的单据无法删除，但提示信息数量内容有误（由于批量删除，审批中的单据导致下面$checkdeletesql的结果每次请求都会重复处理结果集，导致问题的出现，因此将所选单据id分块处理）
$startrow = $_REQUEST['startrow'];
$endrow = $_REQUEST['endrow'];
if (!isset($_REQUEST['endrow'])) {
    $endrow = 99999999;
}
if ($startrow == 0 || !isset($_REQUEST['startrow'])) {
    $startrow = 0;
    unset($_SESSION[$current_user->id . '_' . $returnmodule . '_massdelete']);
}
//缓存结果集
if($_SESSION[$current_user->id . '_' . $returnmodule . '_massdelete']['crmid'])
{
    $storearray=$_SESSION[$current_user->id . '_' . $returnmodule . '_massdelete']['storearray'];
    $records = implode(',', $_SESSION[$current_user->id . '_' . $returnmodule . '_massdelete']['crmid']);
}
else
{
    /**
     *@andrew
     * @time:20140620
     * 0009539: 以下模块序时簿界面：全选所有的单据记录，进行批量修改、删除操作时没有判断单据是否在审批中、已审批，导致已审批或者正在审批的记录批量修改删除了
     */
    $storearray = getSelectedRecords($_REQUEST,$returnmodule,rtrim($idlist,';'),$excludedRecords);
    $_SESSION[$current_user->id . '_' . $returnmodule . '_massdelete']['storearray'] = $storearray;
    /**
     *@andrew
     * @time:20140903
     *0011046: 并发删除单据时，结果弹出提示“undefined”
     */
    if($idlist == 'all'){
        $records_arr = array_unique($storearray);
    }else{
        $records_arr = array_unique(explode(';',rtrim($idlist,';')));
    }

    $_SESSION[$current_user->id . '_' . $returnmodule . '_massdelete']['allcrmid']=$records_arr;
    if(sizeof($records_arr)>$btach_num)
    {
        $records_arr=array_slice($records_arr,0,$btach_num);
    }

    $_SESSION[$current_user->id . '_' . $returnmodule . '_massdelete']['crmid']=$records_arr;
    $records = implode(',', $records_arr);
}

$records_arr = array_slice(explode(',', $records), $startrow, $endrow - $startrow); //$checkdeletesql    没有选择全部时，idlist固定值
$records = implode(',', $records_arr);

if(empty($mass_del_totalrows))
{
    $mass_del_totalrows=sizeof($storearray);
}

$focus = CRMEntity::getInstance($returnmodule);
$tablescf=$focus->customFieldTable[0];
$tablescfindex=$focus->customFieldTable[1];
$maintablename = $focus->table_name;
$maintableindex = $focus->table_index;
if($returnmodule == 'Reminds'){
    $checkdeletesql="select $moduleid from $tabname where $moduleid in($records) and deleted=0 union (select $moduleid from ld_reminds_accepted where  $moduleid in($records) and deleted=0 )";
}else if($returnmodule == 'ChannelCode'){	//chj 2021/8/4 47267: （81mis.com/kfbcrm）营销-渠道码，在渠道码单据列表界面，选择渠道码后点击删除按钮，确定删除后没有出现删除成功弹窗，实际已经删除了的
    $checkdeletesql="select ld_channelcode.id from ld_channelcode where ld_channelcode.id in($records)";
}else{
//chj 2021/1/18 44306: （http://51mis.com.cn/XS/hzxmz/ [^]）合同模块（服务合同）和正式加盟商（服务收费管理）模块（小拇指）；单据列表界面选择单据操作删除后，单据列表仍显示单据，没有小刷新
    $checkdeletesql="select $maintablename.$moduleid from $maintablename left join $tablescf on $tablescf.$tablescfindex=$maintablename.$maintableindex  where $maintablename.$moduleid in($records) and deleted=0";
}


$dresult=$adb->query($checkdeletesql);
$dnum_rows=$adb->num_rows($dresult);
$array=explode(',',$records); 
$checkcount = count($array);
if($dnum_rows==0){

	if(isset($_REQUEST['smodule']) && ($_REQUEST['smodule']!=''))
	{
		$smod = "&smodule=".vtlib_purify($_REQUEST['smodule']);
	}
	if(isset($_REQUEST['start']) && ($_REQUEST['start']!=''))
	{
		$rstart = "&start=".vtlib_purify($_REQUEST['start']);
	}
	if($returnmodule == 'Emails')
	{
		if(isset($_REQUEST['folderid']) && $_REQUEST['folderid'] != ''){
			$folderid = vtlib_purify($_REQUEST['folderid']);
		}else{
			$folderid = 1;
		}
		header("Location: index.php?module=".$returnmodule."&action=".$returnmodule."Ajax&folderid=".$folderid."&ajax=delete".$rstart."&file=ListView&errormsg=".$errormsg.$url);
    }
    elseif($return_action == 'ActivityAjax')
    {
	   $subtab = vtlib_purify($_REQUEST['subtab']);
	   header("Location: index.php?module=".$returnmodule."&action=".$return_action."".$rstart."&view=".vtlib_purify($_REQUEST['view'])."&hour=".vtlib_purify($_REQUEST['hour'])."&day=".vtlib_purify($_REQUEST['day'])."&month=".vtlib_purify($_REQUEST['month'])."&year=".vtlib_purify($_REQUEST['year'])."&type=".vtlib_purify($_REQUEST['type'])."&viewOption=".vtlib_purify($_REQUEST['viewOption'])."&subtab=".$subtab."&onlyforuser=".vtlib_purify($_REQUEST['onlyforuser']).$url);
    }		
    elseif($returnmodule!='Faq')
    {
		header("Location: index.php?module=".$returnmodule."&action=".$returnmodule."Ajax&ajax=delete".$rstart."&file=ListView&viewname=".$viewid."&errormsg=".$errormsg.$url."&SearchScope=".$SearchScope);
    }
    else
    {
		header("Location: index.php?module=".$returnmodule."&action=".$returnmodule."Ajax&ajax=delete".$rstart."&file=ListView&errormsg=".$errormsg.$url);
    }
}elseif($dnum_rows<$checkcount){//并发操作的判断
	for ($i = 0; $i < $dnum_rows; $i++) {      
		$roleid[$i] = $adb->query_result($dresult, $i, $moduleid);
	}

	$records = implode(',',$roleid);
	$idlist = implode(';',$roleid);
	$storearray = getSelectedRecords($_REQUEST,$returnmodule,$idlist,$excludedRecords);
}



$smod = '';//URL参数
$storearray = array_unique(array_filter($storearray));
$ids_list = array();
$errormsg = '';
$correct = 0;	//正确记录数
$error = 0;	//错误记录数
//获取批量处理数

$batchlog = getFixedLabel('DOCUMENTNOSUCCESS');//没有操作权限
$batchotherlog = getFixedLabel('DOCUMENTNOOTHERSUCCESS');//你没有操作其他用户的单据
$batchsuccesslog = getFixedLabel('DOCUMENTSUCCESS');//成功
$batchtype = getFixedLabel('DELETETISHI');
if($returnmodule =='OutboundOrder' || $returnmodule =='Stock'){
	$query = "select $maintablename.$moduleid as id,$tabfieldname as subject,approvestatus as status, approvestatus,smownerid,subsmownerid as approveby from $maintablename left join $tablescf on $tablescf.$tablescfindex=$maintablename.$maintableindex  where $maintablename.$moduleid in (".implode(',',$records_arr).")";
}else if($returnmodule=='Checks'){
	$query = "select $maintablename.$moduleid as id,$tabfieldname as subject,presence as status, smownerid,subsmownerid as approveby from $maintablename left join $tablescf on $tablescf.$tablescfindex=$maintablename.$maintableindex  where $maintablename.$moduleid in (".implode(',',$records_arr).")";
}else if($returnmodule =='WareHouseTransfer'){
	$query = "select $maintablename.$moduleid as id,$tabfieldname as subject,transferstatus as status,smownerid,transfersmownerid as approveby from $maintablename left join $tablescf on $tablescf.$tablescfindex=$maintablename.$maintableindex where $maintablename.$moduleid in (".implode(',',$records_arr).")";
}else if($returnmodule =='CashBill' || $returnmodule == 'SendCashBill'){
	$query = "select $maintablename.$moduleid as id,$tabfieldname as subject,approvestatus as status,smownerid,checker as approveby from $maintablename left join $tablescf on $tablescf.$tablescfindex=$maintablename.$maintableindex where $maintablename.$moduleid in (".implode(',',$records_arr).")";
}else if($returnmodule =='PaymentPlan'){
	$query = "select $maintablename.$moduleid as id,$tabfieldname as subject,paymentstatus as status,smownerid from $maintablename left join $tablescf on $tablescf.$tablescfindex=$maintablename.$maintableindex where $maintablename.$moduleid in (".implode(',',$records_arr).")";
}
else if($returnmodule =='SendPayment'){
	$query = "select $maintablename.$moduleid as id,$tabfieldname as subject,CPStatus as status,smownerid from $maintablename left join $tablescf on $tablescf.$tablescfindex=$maintablename.$maintableindex where $maintablename.$moduleid in (".implode(',',$records_arr).")";
}
else if($returnmodule =='SalesBack'){
	$query = "select $maintablename.$moduleid as id,$tabfieldname as subject,salesbackstatus as status,smownerid from $maintablename left join $tablescf on $tablescf.$tablescfindex=$maintablename.$maintableindex where $maintablename.$moduleid in (".implode(',',$records_arr).")";
}
else if($returnmodule =='PurchaseBack'){
	$query = "select $maintablename.$moduleid as id,$tabfieldname as subject,purchasebackstatus as status,smownerid from $maintablename left join $tablescf on $tablescf.$tablescfindex=$maintablename.$maintableindex where $maintablename.$moduleid in (".implode(',',$records_arr).")";
}else if($returnmodule =='SalesOrder'){
	$query = "select $maintablename.$moduleid as id,$tabfieldname as subject,approvestatus as status,smownerid,approveby,kis_id from $maintablename left join $tablescf on $tablescf.$tablescfindex=$maintablename.$maintableindex where $maintablename.$moduleid in (".implode(',',$records_arr).")";
}else if($returnmodule =='Reminds'){  //消息中心提醒没有自定义表，只有主表
    $query = "select $moduleid as id,$tabfieldname as subject,deleted as status,smownerid from $tabname  where $moduleid in (".implode(',',$records_arr).")";
    $query .= "union (select $moduleid as id,$tabfieldname as subject,deleted as status,smownerid from ld_reminds_accepted  where $moduleid in (".implode(',',$records_arr)."))";
    $query .= " order by field(id,".implode(',',$records_arr).")";
}else if($returnmodule =='ChannelCode'){  //渠道码模块特殊
    $query = "select $moduleid as id,$tabfieldname as subject,deleted as status,smownerid from $tabname where $moduleid in (".implode(',',$records_arr).")";
}
else{
	if(!empty($startapprove[$returnmodule])){
		$query = "select $maintablename.$moduleid as id,$tabfieldname as subject,approvestatus as status,smownerid,approveby from $maintablename left join $tablescf on $tablescf.$tablescfindex=$maintablename.$maintableindex where $maintablename.$moduleid in (".implode(',',$records_arr).")";
	}else{
		$query = "select $maintablename.$moduleid as id,$tabfieldname as subject,deleted as status,smownerid from $maintablename left join $tablescf on $tablescf.$tablescfindex=$maintablename.$maintableindex where $maintablename.$moduleid in (".implode(',',$records_arr).")";
	}
}
if(stripos($query,'order by')===false)
{
    $query .= " order by field(".$maintablename.".".$moduleid.",".implode(',',$records_arr).")";//按in的顺序排序
}
else{
    //order by已添加过的，不需要再次添加
}

//33749: 批量删除：客户批量删除之后，提示信息中的客户顺序与选定客户的顺序不一致
//sort($storearray);
$result = $adb->pquery($query);
$num_rows = $adb->num_rows($result);
for($i = 0; $i<$num_rows; $i++){
	$tabid = $adb->query_result($result,$i,'id');
    //0024686: 已经提交审批的单据，提示信息改进。
    if(isset($_REQUEST['ajax'])&&$_REQUEST['ajax']==true){
       	// $approve_status = $approve->approveStatus($storearray[$i]);
        $approve_status = $approve->approveStatus($adb->query_result($result,$i,'id'));
        $approveby = $adb->query_result($result,$i,'approveby');
        $approvebyid_array = !empty($approve_status['nextstepapproveby'])?explode(',',$approve_status['nextstepapproveby']):[];
        $approvebyname_array = array_map('getUserFullName',$approvebyid_array);
            
        if(count($approvebyname_array)>2){
            $approvebyname_array = array_slice($approvebyname_array,0,2);
            $dot_end = ' ...';
        }
        
        $approveby_ing = implode(',',$approvebyname_array).$dot_end;
    }
    if($returnmodule =='OutboundOrder' || $returnmodule =='Stock'){
        
        $tabArr[$tabid] = array(
		'subject' => $adb->query_result($result,$i,'subject'),
		'status' => $adb->query_result($result,$i,'status'),
		'smownerid' => $adb->query_result($result,$i,'smownerid'),
        'approveby' => getUserFullName($approveby),
        'approvestatus'=>$adb->query_result($result,$i,'approvestatus'),
        'nextstepapproveby' => $approveby_ing
    	);
    }else if($returnmodule =='SalesOrder'){
        
       $tabArr[$tabid] = array(
			'subject' => $adb->query_result($result,$i,'subject'),
			'status' => $adb->query_result($result,$i,'status'),
			'smownerid' => $adb->query_result($result,$i,'smownerid'),
			'approveby' => getUserFullName($approveby),
			'nextstepapproveby' => $approveby_ing,
			'kis_id' => $adb->query_result($result,$i,'kis_id')
    	);
    }
    else
    
    {
        $tabArr[$tabid] = array(
		'subject' => $adb->query_result($result,$i,'subject'),
		'status' => $adb->query_result($result,$i,'status'),
		'smownerid' => $adb->query_result($result,$i,'smownerid'),
        'approveby' => getUserFullName($approveby),
        'nextstepapproveby' => $approveby_ing
    	);
    }
	
}

if($returnmodule == 'BankAccountSet'){
	$sql="SELECT Bankaccountsetid FROM ld_expense 
	UNION 
	SELECT bankaccountsetid FROM ld_cashbill
	UNION 
	SELECT bankaccountsetid FROM ld_sendcashbill
	UNION
	SELECT Outaccount as bankaccountsetid FROM ld_putcash 
	UNION
	SELECT inaccount as bankaccountsetid FROM ld_putcash 
	UNION
	SELECT Outaccount as bankaccountsetid FROM ld_cashdeposit 
	UNION
	SELECT inaccount as bankaccountsetid FROM ld_cashdeposit ";
	$result=$adb->pquery($sql,array());
	$rowCount = $adb->num_rows($result);
	for ($i = 0; $i < $rowCount; $i++) {
		$id_list[] = $adb->query_result($result, $i, 'bankaccountsetid');
	}
}
$userPermission = $current_user->access;
$products_focus = CRMEntity::getInstance('Products');
//关联单据是否删除的判断
$tmp_tableName='mass_del_tmp_'.$current_user->id;
$sql=' drop table if exists  '.$tmp_tableName;
$adb->pquery($sql, array());
$query = "create  table IF NOT EXISTS $tmp_tableName(id int(11) primary key) " ;
$adb->pquery($query,array());
$sql="insert into $tmp_tableName (id) values (" .implode ( "),(", $records_arr ) . ")";
$adb->pquery($sql,array());

$deploy_values=getSys_deploy("69");
$VersionInfo = getVersionInfo();
if($deploy_values['deploy_value']=="1") {
    //商贸批发特殊控制，服务收费管理模块判断是否关联ServiceChargeid
    if($VersionInfo['account'] == 'dongmao' && $returnmodule == 'ServiceCharge'){
        $sqlids = createServiceChargeidsSql();
        $sqlids = $sqlids='select * from (select distinct servicecharge_id from ('. $sqlids.') as vv ) as tmp inner join '.
                    $tmp_tableName.' on tmp.servicecharge_id='.$tmp_tableName.'.id';
        $account_result=$adb->pquery($sqlids,array());
        $rows=$adb->num_rows($account_result);
        for($i=0;$i<$rows;$i++) {
            $accountid=$adb->query_result($account_result,$i,0);
            $accountids[$accountid]=$accountid;
        }
    }
}
crm_load_class_file('cls_CurUserDataScope','include/ListView');
$datascopeobj=cls_CurUserDataScope::getInstance($returnmodule,'list');
import('data.Logic','class');
import('data.BaseLogic','class');
if(!file_exists(globalStatic::$root_directory.'modules/'.$returnmodule.'/'.$returnmodule.'Logic.class.php'))
{

}
else
{
    $cls=$currentModule.'Logic';;
   	import('modules.'.$currentModule.'.'.$cls,'class');
}
BaseLogic::$module=$returnmodule;

//duan 20230112 批量删除时增加验证规则判断
crm_load_class_file('cls_PageValidataSave','data');
$PageValidataSaveobj=new cls_PageValidataSave($returnmodule,0,0);
$PageValidataSaveobj->setApplication('delete');
$PageValidataSaveobj->batchoprate = 'yes';

foreach($records_arr as $key=>$id)
{
	if($btach_num <= $key){//0024366: 日程管理：列表界面批量删除时提示信息错误
	   $error = $mass_del_totalrows- $correct;
	   break;
	}
	$isstatus = 'yes';
    //32409: 消息>未读>勾选多条消息：删除，显示错误。
	$subject = strip_tags(html_entity_decode ($tabArr[$id]['subject']));

	//点击【删除】时，判断该产品是否已经有关联的源单
	if($returnmodule == 'Products'){
	    $SQL='select ld_tab.name from ld_producttoolfield
       inner join ld_tab on ld_tab.tabid=ld_producttoolfield.tabid 
       where ld_tab.presence in(0,2) group by ld_tab.name ';
        $productdetail_result=$adb->pquery($SQL,array());
        for($i=0;$i<$adb->num_rows($productdetail_result);$i++) {
            //判断该产品是否已经有关联的单据
            $tabname=$adb->query_result($productdetail_result,$i,'name');
            
    		$productforsource = $focus->getProductForSource($id,$tabname);
           
            if($productforsource['num_rows']>0)
            {
                
                $edit_err .= sprintf(getFixedLabel('FAILEDFORORDERISAPPROVINGFORINVEN'),'<a referencemodule="'.$tabname.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$subject.'</a>',getFixedLabel('DELETETISHI')).getFixedLabel('associateddocuments').$productforsource['link'] . '<br>';
                $error++;
		      	$isstatus = 'no';
            }
        }
	}
	//客户有关联的单据时是否允许删除
	if($deploy_values['deploy_value']=="1"){
        //商贸批发特殊控制，判断是否关联ServiceChargeid
        if($VersionInfo['account'] == 'dongmao' && $returnmodule == 'ServiceCharge'){
            if(in_array($id,$accountids)){
                $edit_err .= getFixedLabel('BIll').'['.'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" target="_black" style="color:#32A636;">'.$subject.'</a>'.']'.getFixedLabel('THIISRECORDFORTHECORRECTIONINFORMATIONCANNOTBEDELETED').'<br>';
                $error++;
    			$isstatus = 'no';
    		}
        }else{
            if(Delverify($returnmodule,$id)>0){
    			 $edit_err .= getFixedLabel('BIll').'['.'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" target="_black" style="color:#32A636;">'.$subject.'</a>'.']'.getFixedLabel('THIISRECORDFORTHECORRECTIONINFORMATIONCANNOTBEDELETED').'<br>';
    			 $error++;
    			 $isstatus = 'no';
    		}
        }
	}
    //duan 20230112 批量删除时增加验证规则判断
    //先判断不允许保存的验证规则
    $PageValidataSaveobj->resetobj($returnmodule,$id);//重置验证规则对象
    $PageValidataSaveobj->setAllowSave('no');
    $PageValidataSaveobj->getValidDataInfoPhp();
    if(!empty($PageValidataSaveobj->errortip)){
        $edit_err .= sprintf(getFixedLabel('documenterrorinfo'),'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" target="_black" style="color:#32A636;">'.$subject.'</a>',getFixedLabel('DELETE'),$PageValidataSaveobj->errortip). '<br>';
        $error++;
        $isstatus = 'no';
    }

	if($isstatus == 'yes'){
	     //越权保存
        if($datascopeobj->isMyViewData($id)=='no') {
            continue ;
        }
        if(!file_exists(globalStatic::$root_directory.'modules/'.$returnmodule.'/'.$returnmodule.'Logic.class.php')) {
            $btnlogic=new BaseLogic();
        } else {
            require_once(globalStatic::$root_directory.'modules/'.$returnmodule.'/'.$returnmodule.'Logic.class.php');
            $cls=$returnmodule.'Logic';
            $btnlogic=new $cls();
        }
        $focus->id=$id;
        $focus->column_fields['approvestatus']=$tabArr[$id]['status'];
        $focus->column_fields['paymentstatus']=$tabArr[$id]['status'];
        $focus->column_fields['cpstatus']=$tabArr[$id]['status'];
        $focus->column_fields['presence']=$tabArr[$id]['status'];
        if($returnmodule == 'WareHouseTransfer') {
            //38547: （51mis.com/kfbcrm）库存管理>调拨单：序列表“已审核”的单据还能被删除。
            $focus->column_fields['transferstatus']=$tabArr[$id]['status'];
        }
        $btnlogic->controller=$focus;

        $permits=$btnlogic->getDeleteBtn();
		if($permits['permit'] == 'no')
		{
			if(($returnmodule == 'WareHouseTransfer' || $returnmodule == 'CashBill' || $returnmodule == 'SendCashBill') && $tabArr[$id]['status'] == '已审核'){
				$edit_err .= sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECK'),'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" target="_black" style="color:#32A636;">'.$subject.'</a>',$batchtype).getFixedLabel('PLEASECONTACTCHECKER').$tabArr[$id]['approveby'].'<br>';
				$error++;
			}else if(($returnmodule =='Stock' || $returnmodule =='OutboundOrder') && ($tabArr[$id]['status'] == D_A_S_APPROVED)){
				$edit_err .= sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECK'),'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$subject.'</a>',$batchtype).getFixedLabel('PLEASECONTACTCHECKER').$tabArr[$id]['approveby'].'<br>';
				$error++;
			}else if($returnmodule == 'Checks' && $tabArr[$id]['status'] == '盘点结束'){
				$edit_err .= sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVER'),'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$subject.'</a>',$batchtype).getFixedLabel('PLEASECONTACTCHECKER').$tabArr[$id]['approveby'].'<br>';
				$error++;
			}else if($returnmodule == 'PaymentPlan' && $tabArr[$id]['status'] != NOCASHBILL){
				$edit_err .= sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVERSHOUKUAN'),'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$subject.'</a>',$batchtype).'<br>';
				$error++;
			}else if($returnmodule == 'SendPayment' && $tabArr[$id]['status'] != '未付'){
				$edit_err .= sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVERFUKUAN'),'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$subject.'</a>',$batchtype).'<br>';
				$error++;
			}else if(($returnmodule =='SalesBack') && $tabArr[$id]['status'] != NOTINSTOCK){
				$edit_err .= sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKSALESBACK'),'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$subject.'</a>',$batchtype).'<br>';
				$error++;
			}else if(($returnmodule =='PurchaseBack') && $tabArr[$id]['status'] != NOTOUTBOUND){
				$edit_err .= sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKPURCHASEBACK'),'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$subject.'</a>',$batchtype).'<br>';
				$error++;
			}
			else if($returnmodule == 'BankAccountSet'){
				if(in_array($id,$id_list)){
					$edit_err .= sprintf(getFixedLabel('DOCUMENTNOOTHERSUCCESSCHECKOVERGUANLIAN'),'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$subject.'</a>',$batchtype).'<br>';
					$error++;
				}else{
					/**
					 * 银行账户删除，判断是否允许删除
					 * @author Tujt 2015-07-20
					 */
					$focus->id = $id;
					$ischeck = $btnlogic->checkDelInfo($returnmodule,$id);
					if('SUCCESS' != $ischeck){
						$edit_err .= sprintf(getFixedLabel('MASSDELBANKNOTTODELETE'),'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$subject.'</a>',$batchtype).'<br>';
						$error ++;
					}
				}
			}
			////0024686: 已经提交审批的单据，提示信息改进。
			else if((!empty($startapprove[$returnmodule])||$returnmodule=='CashBill'||$returnmodule=='SendCashBill')
                    && $tabArr[$id]['status'] == constant('D_A_S_APPROVALOF')||$tabArr[$id]['approvestatus'] == constant('D_A_S_APPROVALOF')){
				$edit_err .= sprintf(getFixedLabel('FAILEDFORORDERISAPPROVING'),'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$subject.'</a>',$batchtype,$tabArr[$id]['nextstepapproveby']).'<br>';
				$error++;
			}
			else if((!empty($startapprove[$returnmodule])||$returnmodule=='CashBill'||$returnmodule=='SendCashBill') && $tabArr[$id]['status'] == constant('D_A_S_APPROVED')){
				$edit_err .= sprintf(getFixedLabel('FAILEDFORORDERHASAPPROVED'),'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$subject.'</a>',$batchtype,$tabArr[$id]['approveby']).'<br>';
				$error++;
			}
			else if(!empty($startapprove[$returnmodule]) && $tabArr[$id]['status'] == constant('D_A_S_REJECTED')){
				$edit_err .= sprintf(getFixedLabel('FAILEDFORORDERISREJECTED'),'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$subject.'</a>',$batchtype,$tabArr[$id]['approveby']).'<br>';
				$error++;
			}
			else if(Delverify($returnmodule,$id)>0){
				$edit_err .= getFixedLabel("BIll").'['.'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$subject.'</a>'.']已有关联信息不能删除！'.'<br>';
				$error++;
			}
			else if($returnmodule === 'PricePolicy' && $btnlogic->checkIsSelected()){
				$edit_err .= getFixedLabel("BIll").'['.'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$subject.'</a>'.']已被使用不能删除！'.'<br>';
				$error++;
			}
            else if ($returnmodule === 'ProductProperty'){
                //zxm @date:2024/10/17 @reason:  产品属性被关联选择不允许删除
                $edit_err .= getFixedLabel("BIll").'['.'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$subject.'</a>'.']'.getFixedLabel('THIISRECORDFORTHECORRECTIONINFORMATIONCANNOTBEDELETED').'<br>';
                $error++;
            }
            else
    		{
    			$error++;
    			$edit_err .= sprintf($batchlog,'<a referencemodule="'.$returnmodule.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$subject.'</a>',$batchtype,$batchtype).'<br>';
    		}
		} else{
            //判断允许保存的验证规则
            $PageValidataSaveobj->setAllowSave('yes');
            $PageValidataSaveobj->resetinfo = 'yes';
            $PageValidataSaveobj->getValidDataInfoPhp();
            if(!empty($PageValidataSaveobj->errortip)){
                $validata_errortip = getFixedLabel('TIPS').':'.$PageValidataSaveobj->errortip;
            }else{
                $validata_errortip = '';
            }
			//chj 2021/1/18 44325: （本地php72，8.3.7）以附件管理为例，单据列表界面选择单据删除和分配后；点击弹窗提醒的单据编号进详情，此时出现的弹窗提醒能否放在操作成功弹窗的前面
            $edit_err .= sprintf($batchsuccesslog,'<a style="color:#32A636;">'.$subject.'</a>',$batchtype).$validata_errortip.'<br>';
            //liushuai  20230829 XUQIU1001827 工作流程定制，增加“删除”触发点（批量删除）
            $arr = delEntity($returnmodule,$id);
            if (isset($arr['workflow']) && $arr['workflow']['receive_msg'] == "yes") {
                $callapimsg = $arr['workflow']['mobcontent']."</br>";
            }
            $edit_err .= $callapimsg;
				$realids[]=$id;
				$correct++;
        }
	}
}
//if($error == 0){
//	$error = $mass_del_totalrows- $correct;
//}
$_REQUEST['moduleMassDelete']='yes';
//更新提醒数量
if($returnmodule == 'Reminds'){
	if(sizeOf($realids) > 0){
		$query = 'select 1 from ld_reminds 
		where remindsid in ('.implode(',',$realids).') and status_rmd = \'未读\' and ld_reminds.date_time <= \''.date('Y-m-d h:i:s').'\' and is_del_rec = 0 and ld_reminds.recieverid= ?';
        $query .= 'union (select 1 from ld_reminds_accepted 
		where remindsid in ('.implode(',',$realids).') and status_rmd = \'未读\' and ld_reminds_accepted.date_time <= \''.date('Y-m-d h:i:s').'\' and is_del_rec = 0 and ld_reminds_accepted.recieverid= ?)';
		$result = $adb->pquery($query,array($current_user->id,$current_user->id));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			$entity['reminds_num']['value'] = $num_rows;
		}
	}

    $focus->massDelete_after($returnmodule,$realids);
}


//@edit:liushuai,2021-03-08,reason:【ID1001390】批量删除增加显示进度条
if (!isset($_SESSION[$current_user->id . '_' . $returnmodule . '_massdelete']['correct'])) {
    $_SESSION[$current_user->id . '_' . $returnmodule . '_massdelete']['correct'] = 0;
}
$_SESSION[$current_user->id . '_' . $returnmodule . '_massdelete']['correct'] += $correct;
$_SESSION[$current_user->id . '_' . $returnmodule . '_massdelete']['edit_err'] .= $edit_err;
$entity['maxrows'] = sizeof($_SESSION[$current_user->id . '_' . $returnmodule . '_massdelete']['crmid']);
$entity['selectrows'] = $mass_del_totalrows;
$entity['correct'] = $_SESSION[$current_user->id . '_' . $returnmodule . '_massdelete']['correct'];//该返回值仅供排错时查看，可以删除
$entity['edit_err'] = $_SESSION[$current_user->id . '_' . $returnmodule . '_massdelete']['edit_err'];//该返回值仅供排错查看

$submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');
//$submitlog = sprintf($submitlog,$mass_del_totalrows,$correct,$error);
$submitlog = sprintf($submitlog,$mass_del_totalrows,$_SESSION[$current_user->id . '_' . $returnmodule . '_massdelete']['correct'],$mass_del_totalrows- $_SESSION[$current_user->id . '_' . $returnmodule . '_massdelete']['correct']);
$submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
//$entity['log']['value'] = $submitlog."<div class='pop_prc_content'>".$edit_err."</div>";//批量处理信息
$entity['log']['value'] = $submitlog."<div class='pop_prc_content'>".$_SESSION[$current_user->id . '_' . $returnmodule . '_massdelete']['edit_err']."</div>";//批量处理信息
$entity['title']['value'] = $batchtype;//批量处理信息

if(isset($_REQUEST['smodule']) && ($_REQUEST['smodule']!=''))
{
	$smod .= "&smodule=".vtlib_purify($_REQUEST['smodule']);
}
if(isset($_REQUEST['start']) && ($_REQUEST['start']!=''))
{
	$smod .= "&start=".vtlib_purify($_REQUEST['start']);
}
if($returnmodule == 'Emails')
{
	if(isset($_REQUEST['folderid']) && $_REQUEST['folderid'] != '')
	{
		$folderid = vtlib_purify($_REQUEST['folderid']);
	}else
	{
		$folderid = 1;
	}
	$smod .= "&folderid=".$folderid;
}
$sql=' drop table if exists  '.$tmp_tableName;
$adb->pquery($query,array());
$smod .="&ajax=delete";
$entity['start']['value'] = $smod;//
$entity['actionname']['value'] = 'ListView';
$entity['title']['value'] = getFixedLabel('DELETE');// 删除

if($endrow >= $mass_del_totalrows)
{
    unset($_SESSION[$current_user->id.'_'.$returnmodule.'_massdelete']);
}


$json = new Zend_Json();
$jsonentity = $json->encode($entity);
echo $jsonentity;die;
function createAccountidsSql($vtable=array()){
    global $adb;
    $vsb = 'select count(1) as num from ';
    $vse = ' where deleted = 0 and accountid = ';
 
    
    $vsql = '';
    foreach($vtable as $tablename){
        //.' inner join ld_account on ld_account.accountid= '.$tablename.".accountid
          $vsql .= " select $tablename.accountid from  $tablename where $tablename.deleted = 0  " ;
        if($tablename != end($vtable)){
           $vsql.=' union';
        }
    }
    return $vsql;
}/**
 * 
 * @param
 * @return
 * @author Chj
 */
function delEntity($returnmodule,$id) {
	global $adb;
	$focus = CRMEntity::getInstance($returnmodule);
    $receive_return = 'yes';
	if($returnmodule=='Accounts')
	{
		//$focus->updateAccountInfo($returnmodule,'',2,$id);
        $data = DeleteEntity($returnmodule,$returnmodule,$focus,$id,'',$receive_return);
	}
	else if($returnmodule=='CashBack')
	{
		/*$cashback_query = "select total,salesbackid,bankaccountsetid from ld_cashback where cashbackid =?";
		$cashback_result = $adb->pquery($cashback_query, array($id));
		$result_total = $adb->query_result($cashback_result,0,'total');
		$result_salesbackid = $adb->query_result($cashback_result,0,'salesbackid');
		$bankaccountsetid = $adb->query_result($cashback_result,0,'bankaccountsetid');        
		$update_query = "update ld_salesback set havebackamount=IFNULL(havebackamount,0)-IFNULL($result_total,0) where salesbackid=?";
		$adb->pquery($update_query, array($result_salesbackid));    
		$usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)+$result_total WHERE bankaccountsetid=$bankaccountsetid";
		$adb->pquery($usql,array());*/
        //ls 20221101 Xuqiu1000213 服务回访单、销售退货单、采购退货单、销售退款单、采购退款单增加“新建”功能(批量删除销售退款单时重算金额)
        $focus->resetAmount($id);
        $focus->addBankMoney($id);
        $data = DeleteEntity($returnmodule,$returnmodule,$focus,$id,'',$receive_return);
	}
	else if($returnmodule=='PurchaseCashBack')
	{
		/*$purchasecashback_query = "select * from ld_purchasecashback where purchasecashbackid =?";
		$purchasecashback_result = $adb->pquery($purchasecashback_query, array($id));
		$result_total = $adb->query_result($purchasecashback_result,0,'total');
		$result_purchasebackid = $adb->query_result($purchasecashback_result,0,'purchaseback_id');
		$bankaccountsetid = $adb->query_result($purchasecashback_result,0,'bankaccountsetid');        
		$update_query = "update ld_purchaseback set havebackamount=IFNULL(havebackamount,0)-IFNULL($result_total,0) where purchasebackid=?";
		$adb->pquery($update_query, array($result_purchasebackid));    
		$usql = "UPDATE ld_bankaccountset SET curbalancemoney=IFNULL(curbalancemoney,0)-IFNULL($result_total,0) WHERE bankaccountsetid=$bankaccountsetid";
		$adb->pquery($usql,array());*/
        $focus->resetAmount($id);
        $focus->minusBankMoney($id);
        $data = DeleteEntity($returnmodule,$returnmodule,$focus,$id,'',$receive_return);
	}
	else if($returnmodule=='HelpDesk')
	{
		/*
		andrew 
		20140226
		服务合同添加服务次数统计，计数减1
		*/ 
		$su_qry = $adb->pquery("select * from ld_crmentityrel where module='ServiceContracts' and relmodule='HelpDesk' and relcrmid=?", array($id));
		$rowCount = $adb->num_rows($su_qry);
		if($rowCount>0){
		   for($i=0;$i<$rowCount;$i++){
				$tos[$i] .= $adb->query_result($su_qry, $i, 'crmid');
		   }
		   $ctos = implode(',',$tos); 
		   if($rowCount!=0){
				$adb->pquery("update ld_servicecontracts set service_units=service_units-1 where servicecontractsid in($ctos)");
		   } 
		}
        $data = DeleteEntity($returnmodule,$returnmodule,$focus,$id,'',$receive_return);
	}else if($returnmodule == 'SalesOrder'){
        $data = DeleteEntity($returnmodule,$returnmodule,$focus,$id,'',$receive_return);
	}
	else if($returnmodule == 'PurchaseOrder')
	{
        $data = DeleteEntity($returnmodule,$returnmodule,$focus,$id,'',$receive_return);
	}
	else if($returnmodule == 'OutboundOrder')
	{
		$deployarray=getSys_deploy(48);
		$query = 'select quantity,productid,lineitem_id,parent_lineitem_id,entitytypeid,
                        ld_outboundorderdetail.wareid,smownerid
                    ,lineitem_id ,batchtext,ld_outboundorderdetail.entitytype
                    from ld_outboundorderdetail 
                    left join ld_outboundorder on ld_outboundorder.out_id = ld_outboundorderdetail.id where id = ? ';
		$result = $adb->pquery($query,array($id));
		$num_rows = $adb->num_rows($result);
        crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
		crm_load_class_file('cls_OutSale_InverseCompute','include/OptionModule');
        $data = DeleteEntity($returnmodule,$returnmodule,$focus,$id,'',$receive_return);
		for($i = 0; $i<$num_rows; $i++){
			$entitytypeid = $adb->query_result($result,$i,'entitytypeid');
			$productid = $adb->query_result($result,$i,'productid');
			$qty = $adb->query_result($result,$i,'quantity');
			$entitytypeid = $adb->query_result($result,$i,'entitytypeid');
            $entitytype= $adb->query_result($result,$i,'entitytype');
			$parent_lineitem_id =  $adb->query_result($result,$i,'parent_lineitem_id');
			$lineitem_id = $adb->query_result($result,$i,'lineitem_id');
			$wareid = $adb->query_result($result,$i,'wareid');
			$smownerid = $adb->query_result($result,$i,'smownerid');
            $batchtext=$adb->query_result($result,$i,'batchtext');
			if($deployarray['deploy_value']== 1){
				
				insertCondtion($batchtext, $id,'删除出库单',$wareid,$productid,$returnmodule,$smownerid,0,$qty,$parent_lineitem_id,$lineitem_id);
			}
			//$adb->pquery('delete from ld_inventoryproductrel where lineitem_id = ?',array($lineitem_id));
			//更新合同订单的出库状态、未出库和已出库数量
			if($entitytypeid > 0){
				cls_Source_InverseCompute::Source_InveverseCompute($entitytype,$entitytypeid);
				if($deployarray['deploy_value']== 1){
					cls_OutSale_InverseCompute::updateSourceModuleOutboundAmount($entitytypeid,$entitytype);
				}
			}
		}
	}
    else if($returnmodule=='SalesBack')
    {
        $query = 'select quantity,productid,lineitem_id,parent_lineitem_id,
            entitytypeid ,ld_salesbackdetail.entitytype,lineitem_id
                    from ld_salesbackdetail 
                    left join ld_salesback on ld_salesback.salesbackid = ld_salesbackdetail.id where id = ? ';
        $result = $adb->pquery($query,array($id));
        $num_rows = $adb->num_rows($result);
        $data = DeleteEntity($returnmodule,$returnmodule,$focus,$id,'',$receive_return);
        crm_load_class_file("cls_Source_InverseCompute","include/OptionModule");
        for($i=0;$i<$num_rows;$i++)
        {
            	$entitytypeid = $adb->query_result($result,$i,'entitytypeid');
        	$productid = $adb->query_result($result,$i,'productid');
        	$qty = $adb->query_result($result,$i,'quantity');
        	$entitytype = $adb->query_result($result,$i,'entitytype');
        	$parent_lineitem_id =  $adb->query_result($result,$i,'parent_lineitem_id');
        	$lineitem_id = $adb->query_result($result,$i,'lineitem_id');
        
            	if($entitytypeid > 0){
        	  
        	       cls_Source_InverseCompute::Source_InveverseCompute($entitytype,$entitytypeid);
                }
        }
    }
	else if($returnmodule == 'Stock')
	{
	   
	    crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
        
		$deployarray=getSys_deploy(48);
		$query = 'select quantity,productid,lineitem_id,parent_lineitem_id,entitytypeid,ld_stock.wareid
            ,smownerid,lineitem_id ,batchtext,ld_stockdetail.entitytype
		from ld_stock 
		left join ld_stockdetail on ld_stock.stock_id = ld_stockdetail.id where id = ? ';
       
		$result = $adb->pquery($query,array($id));
		$num_rows = $adb->num_rows($result);
        $data = DeleteEntity($returnmodule,$returnmodule,$focus,$id,'',$receive_return);
      
		for($i = 0; $i<$num_rows; $i++){
		  
			$productid = $adb->query_result($result,$i,'productid');
			$qty = $adb->query_result($result,$i,'quantity');
			$entitytypeid = $adb->query_result($result,$i,'entitytypeid');
			$parent_lineitem_id =  $adb->query_result($result,$i,'parent_lineitem_id');
			$lineitem_id = $adb->query_result($result,$i,'lineitem_id');
			$wareid = $adb->query_result($result,$i,'wareid');
			$smownerid = $adb->query_result($result,$i,'smownerid');
            $batchtext=$adb->query_result($result,$i,'batchtext');
			if($deployarray['deploy_value']== 1){
				insertCondtion($batchtext, $id,'删除入库单',$wareid,$productid,$returnmodule,$smownerid,0,$qty,$parent_lineitem_id,$lineitem_id);   
			}
		//	$adb->pquery('delete from ld_inventoryproductrel where lineitem_id = ?',array($lineitem_id));
			//更新采购订单的入库状态、未入库和入出库数量
            $entitype=$adb->query_result($result,$i,'entitytype');
			if($entitytypeid > 0){
				cls_Source_InverseCompute::Source_InveverseCompute($entitype,$entitytypeid);
			}
		}
		
		
	}
	else if($returnmodule == 'LessionPlan'){
		$adb->pquery('delete from ld_crmentity where crmid = ?',array($id));
		$adb->pquery('delete from ld_lessionplan where lessionplanid = ?',array($id));
	}
    // 已使用的价格政策不允许批量删除
    else if($returnmodule === 'PricePolicy') {
        $data = DeleteEntity($returnmodule,$returnmodule,$focus,$id,'',$receive_return);
    }
	else
	{
		//更新合同订单的最新收款日期
        //在触发器中修改了
		//if($returnmodule == 'CashBill')
		//	$focus->UpdateSalesOrderCashBilldate($id,'del');
        $data = DeleteEntity($returnmodule,$returnmodule,$focus,$id,'',$receive_return);
	}

    return $data;
}

//判断产品是否已关联了源单
function getProductForSource($productid){
	global $adb;
    $sql='select * from ld_tab where presence in (0,2)';
    $result=$adb->pquery($sql,array());
    $rows=$adb->num_rows($result);
    for($i=0;$i<$rows;$i++)
    {
        $module=$adb->query_result($result,$i,'name');
        
        $focus=CRMEntity::getInstance($module);
        $detailtable=$focus->Detail_table;
        $tablename=$focus->table_name;
        $tableindex=$focus->table_index;
        $linkfield=$focus->list_link_field;
        $linktablename=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$linkfield,'tablename');
        
    	$sql=   "select DISTINCT id,$linkfield as subject,$module as modulename from  $detailtable. INNER JOIN  $tablename on $tablename.$tableindex =$detailtable.id ";
        if($linktablename!=$tablename)
        {
            $sql.=" left join $linktablename on $linktablename.$tableindex=$tablename.$tableindex";
            
        }
        
        $sql.=" where $detailtable.productid = $productid";
        $querys[]=$sql;
    	
    }
    $query=implode (' union all ',$querys);
    
    $result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		for($i = 0; $i < $num_rows; $i++){
			$id = $adb->query_result($result,$i,'id');
			$setype = $adb->query_result($result,$i,'modulename');
			$linklabel = $adb->query_result($result,$i,'subject');
			if(!empty($linklabel)){
					$label[] = '<a referencemodule="'.$setype.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;">'.$linklabel.'</a>';
				}
			
		}
	}
	$data['link'] = implode('、 ',$label);
	$data['num_rows'] = $num_rows;
	return $data;
}

//商贸批发特殊开发-删除服务收费管理时，通过ServiceChargeid 判断
function createServiceChargeidsSql(){
    global $adb;
     $res = $adb->pquery('select tablename,tabid from ld_field where columnname = \'servicecharge_id\' and presence in(0,2) order by tabid ');
    $ns = $adb->num_rows($res);
    for($i = 0;$i<$ns;$i++){
        $tabid=$adb->query_result($res,$i,'tabid');
        
        $tabname= getTabname($tabid);
        if(!vtlib_isModuleActive($tabname))
        {
            continue;
        }
       
    	$vtable[] = $adb->query_result($res,$i,'tablename');
    }
    
    $vsb = 'select count(1) as num from ';
    $vse = ' where deleted = 0 and accountid = ';
 
    $vsql = '';
    foreach($vtable as $tablename){
        //.' inner join ld_account on ld_account.accountid= '.$tablename.".accountid
          $vsql .= " select $tablename.servicecharge_id from  $tablename where $tablename.deleted = 0  " ;
        if($tablename != end($vtable)){
           $vsql.=' union';
        }
    }
    return $vsql;
}

?>