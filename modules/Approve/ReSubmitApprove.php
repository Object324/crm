<?php
global $adb,$current_user;

$approve=new Approve();

//提交审批
if(isset($_REQUEST['record']) && $_REQUEST['record']!='')
    $record=$_REQUEST['record'];

if(isset($_REQUEST['save']) && $_REQUEST['save']!=''){

    $save=$_REQUEST['save'];

}
if(isset($_REQUEST['fromapprovemodule']) && $_REQUEST['fromapprovemodule']!=''){    
    $fld_module=$_REQUEST['fromapprovemodule'];
    //19646: 服务收费管理>列表：勾选单据，提交审批，弹出提示信息。点击提示信息的链接字段，结果：页面跳转到的是客户模块。
    $old_module=$fld_module;
    if($fld_module=='ServiceCharge')
        $fld_module='Accounts';
    $tabid=getTabid($fld_module);
}
//$approve=new Approve();
$smarty=new lingdangCRM_Smarty;
$approveid = $_REQUEST['approvevalue'];
//获取批量处理数
$deployarray = getSys_deploy(67);
$btach_num =  $deployarray['deploy_value'];

if($save=='false'){
    $approveinfo=$approve->submitApprove($tabid);
    if(empty($approveinfo)){
        echo "###NO###";
        exit();
    }
    else{
        echo "###SUCCESS###";

        /*
         * editor:gyq_05
         * reason:初始化审批步骤值
         * date  : 2016 3 1
         * */
		 $selectid = $_REQUEST['selectid'];
		if(!empty($selectid)){
			if($selectid != 'all'){
				$selectarr = explode(';',$selectid);
				$record = $selectarr[0];
			}else{
				$query = getListAllQuery($old_module,1);//获取query，不需要任何附加条件
              
				$result = $adb->pquery($query['query'],array());
				$record = $adb->query_result($result,0,0);
			}
		}
        $nextStepInfo = $approve->getApproveStepInfo($approveinfo[0]['approveid'],$record);
        $smarty->assign('APPROVEFIRSTSTEP',$nextStepInfo);
        $smarty->assign('APPROVE',$approveinfo);
        $smarty->assign('RECORD',$record);
        $smarty->assign('BLOCK',$old_module);
        $smarty->assign('RETURNMODULE',$returnmodule);
		$smarty->assign('APPROVETYPE',$_REQUEST['approvetype']);
        $smarty->display('Approve/SubmitApprove.tpl');
        exit();
    }
}else{
	//批量提交审批
	$selectid = $_REQUEST['selectid'];
	$selectlen = $_REQUEST['selectlen'];//提交的单据数量
	$entityarray = getEntitynameInfo(getTabid($fld_module));
	$focus = CRMEntity::getInstance($fld_module);
	$enity_tabname = $entityarray['tablename'];
	$tabname = $focus->table_name;
	$tabindex = $focus->table_index;
	$tabnamecf = $focus->customFieldTable;
	$tabfieldname = $entityarray['fieldname'];
	$submitlog = '';

	if('all' == $selectid){//全选模式
		//如果不为空，则判断当前有基本查询或高级查询条件
		if(is_array($_SESSION['LiveViewSearch'][$fld_module]['input'])&&sizeof($_SESSION['LiveViewSearch'][$fld_module]['input']))
		{
			$searchinput = $_SESSION['LiveViewSearch'][$fld_module]['input'];
			
			if($searchinput['searchtype'] == 'BasicSearch'){
				if(!empty($searchinput['search_text'])){
					$_REQUEST['search_field'] = $searchinput['search_field'];
					$_REQUEST['search_text'] = $searchinput['search_text'];
					$_REQUEST['SearchScope'] = $searchinput['SearchScope'];
					$_REQUEST['searchtype'] = $searchinput['searchtype'];
					$_REQUEST['type'] = $searchinput['type'];
					$input['search_field'] = $searchinput['search_field'];
					$input['search_text'] = $searchinput['search_text'];
					$input['SearchScope'] = $searchinput['SearchScope'];
					$input['searchtype'] = $searchinput['searchtype'];
					$input['type'] = $searchinput['type'];
					$input['query']='true';
				}
			}else if($searchinput['searchtype'] == 'advance')
			{
				if(!empty($searchinput['advft_criteria']) && $searchinput['advft_criteria'] != '[]')
				{
					$_REQUEST['advft_criteria'] = $searchinput['advft_criteria'];
					$_REQUEST['advft_criteria_groups'] = $searchinput['advft_criteria_groups'];
					$_REQUEST['SearchScope'] = $searchinput['SearchScope'];
					$_REQUEST['searchtype'] = $searchinput['searchtype'];
					 $input['query']='true';
					 $input['advft_criteria'] = $searchinput['advft_criteria'];
					$input['advft_criteria_groups'] = $searchinput['advft_criteria_groups'];
					$input['SearchScope'] = $searchinput['SearchScope'];
					$input['searchtype'] = $searchinput['searchtype'];
				}
			
			}
		}
		global $customView,$approvestatus;
		$approvestatus = 3;
		crm_load_class_file('cls_Approve_CustomView','modules/Approve/ListView');
		$customView = new cls_Approve_CustomView($fld_module);
		//实例化列表SQL类
		crm_load_class_file('cls_Approve_ListView','modules/Approve/ListView');
		$queryGenerator = new cls_Approve_ListView();
		$list_query = $queryGenerator->getquery($fld_module, $current_user,$customView);
		$queryGenerator->queryGenerator->addUserSearchConditions($input);
		$query='select distinct '.$tabname.'.'.$tabindex.' as crmid,'.$tabname.'.approvestatus,'.$enity_tabname.'.'.$tabfieldname.' as subject '.$queryGenerator->queryGenerator->getFromClause().'  '.$queryGenerator->queryGenerator->approveSql . $queryGenerator->queryGenerator->getWhereClause();
		$count_result=$adb->pquery($query,array());
		$noofrows=$adb->num_rows($count_result);
		if($noofrows>$btach_num)
		{
			$noofrows=$btach_num;
		}
		$success = 0;
		if($btach_num > 3000){//如果大于三千条，分奇偶数两个进程处理
			//ID偶数列循环
			$even = $query.' and '.$tabname.'.'.$tabindex.'%2 = 0  ';
			if($orderby)
			{
				$even.=' order by '.$orderby;
			}
			if($btach_num > 0){
				$even .= ' LIMIT '.$btach_num.' ';
			}
			$result = $adb->pquery($even,array());
			$data = submitApprove($approve,$result,$fld_module,$approveid);
			$log = $data['log'];
			$success += $data['success'];
			//ID奇数列循环
			$uneven = $query.' and '.$tabname.'.'.$tabindex.'%2 != 0  ';
			if($orderby)
			{
				$uneven.=' order by '.$orderby;
			}
			if($btach_num > 0){
				$uneven .= ' LIMIT '.$btach_num.' ';
			}
			$result = $adb->pquery($uneven,array());
			$data = submitApprove($approve,$result,$fld_module,$approveid);
			$log .= $data['log'];
			$success += $data['success'];
		}else{//小于三千天，一条一条循环创建
			if($orderby)
			{
				$query.=' order by '.$orderby;
			}
			if($btach_num > 0){
				$query .= ' LIMIT '.$btach_num.' ';
			}
			$result = $adb->pquery($query,array());
			$data = submitApprove($approve,$result,$fld_module,$approveid);
			$log = $data['log'];
			$success = $data['success'];
		}
		//18998: 客户>联系记录：联系记录列表界面，勾选所有单据，点击”全选所有185条记录“，点击【批量提交】按钮，弹出框点击保存，界面提示信息不正确
		$submitlog = sprintf(getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO'),
						$selectlen,$success,($selectlen-$success));
		$submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
        $submitlog = "<div class='pop_prc_content' style='height: 140px;'>" . $log."</div>";

		//ID 奇数列
	}else{//非全选
		$selectid = trim($selectid,',');
		$selectarr = explode(',',$selectid);
		$selectlen = sizeOf($selectarr);
		$failurearr = array();//不能提交审批的单据
		//组装sql，查询选中的id中，审批中、已批准的单据结果集
		$notapprove = array(constant('D_A_S_REJECTED')=>1,
						constant('D_A_S_APPROVALOF')=>1,
						constant('D_A_S_APPROVED')=>1);
		$approvestatusarr = array(
			'1'=>constant('D_A_S_APPROVALOF'),//'审批中',
			'2'=>constant('D_A_S_APPROVED'),//'已批准',
			'3'=>constant('D_A_S_REJECTED'),//'已拒绝',
			'4'=>constant('D_A_S_DISMISSED'),//'已驳回'
			'5'=>constant('D_A_S_APPROVALOF'),//'审批中',
		);
		$query = 'SELECT distinct '.$tabname.'.'.$tabindex.' as crmid,
					'.$tabname.'.approvestatus,'.$enity_tabname.'.'.$tabfieldname.' as subject 
						from '.$tabname.' left join '.$tabnamecf[0]. ' on '.$tabnamecf[0] . '.' . $tabnamecf[1] . ' = '.$tabname . '.'.$tabindex.' 
					where '.$tabname.'.deleted = 0 and '.$tabname.'.'.$tabindex.' in ('.$selectid.') order by field('.$tabname.'.'.$tabindex.','.$selectid.')';
		//0024365: 日程管理：列表界面批量提交时提示信息错误 order by field根据in内顺序排序 edit:xxs date:16-09-19
		if($btach_num > 0) $query .= 'limit '.$btach_num.' ';
		$result = $adb->pquery($query,array());
		$rows = $adb->num_rows($result);
		$failurelog = array();$selectinfo = array();
		$selectarr = array();
		if($rows > 0){
			for($i=0;$i<$rows;++ $i){
				$crmid = $adb->query_result($result,$i,'crmid');
				$approvestatus = $adb->query_result($result,$i,'approvestatus');
				$subject = $adb->query_result($result,$i,'subject');
				if($approvestatus != constant('D_A_S_DISMISSED')){
					$failurelog[$crmid]['status'] = $approvestatus;
					$failurelog[$crmid]['subject'] = $subject;
					$failurearr[] = $crmid;//不能提交审批的单据ID
				}else{
					$selectinfo[$crmid] = $subject;
					$selectarr[] = $crmid;
				}
			}
		}
		if(!empty($failurearr))//用array_diff获取两个数组的差集
			$selectarr = array_diff($selectarr,$failurearr);
		$successlog = '';//提交成功记录日志
		if(!empty($selectarr)){
			$selectarrlen = count($selectarr);//执行提交审批的单据数量
			$submitlog = sprintf(getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO'),$selectlen,
							$selectarrlen,($selectlen-$selectarrlen));
			$color = '#32A636';//提交审批成功的单据，颜色设为绿色
			foreach($selectarr as $key=>$crmid){
				if($key >= $btach_num){
					break;
				}
				$approve->ApproveSubmit($fld_module,$crmid,$approveid);//执行提交审批操作
				$batchlog = getFixedLabel('DOCUMENTSUCCESS');
				$successlog .= sprintf($batchlog,'<a referencemodule="'.$old_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:'.$color.'">'.$selectinfo[$crmid].'</a>',getFixedLabel('SUBMITAPPROVAL')).'<br>';
			}
			$successlog = trim($successlog,'<br>');
		}else{
			$submitlog = sprintf(getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO'),$selectlen,
							0,$selectlen);
		}
		$submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
        $submitlog = "<div class='pop_prc_content' style='height: 140px;'>";//提交总计信息，字体加粗
		if(!empty($successlog)){
			$submitlog .= $successlog;
		}
		if(!empty($failurelog)){
			if(!empty($successlog))
				$submitlog .= "<br>";
			$color = '';$key = 0;
			foreach($failurelog as $crmid=>$failure){
				if($key >= $btach_num){
					break;
				}
				$key ++;
				if($failure['status'] == constant('D_A_S_APPROVED')){//'已批准'
					$batchlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_APPROVED');
					$color = '#FF0000';//已审批的单据，颜色设为红色
				}else{
					$batchlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_SUBMIT');
					$color = '';
				}
				$submitlog .= sprintf($batchlog,'<a referencemodule="'.$old_module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:'.$color.'">'.$failure['subject'].'</a>').'<br>';
			}
		}
	}
	$entity['log']['value'] = $submitlog."</div>";
	$entity['download']['value'] = getFixedLabel('CONFIRMED');//DOWNLOAD 下载
	if(isset($_SESSION['lvs'][$fld_module]['viewname'])){
		$viewid = $_SESSION['lvs'][$fld_module]['viewname'];
		$start = $_SESSION['lvs'][$fld_module][$viewid]['start'];
	}
	if(!$start) $start = 1;
	$entity['start']['value'] = $start;
	$json = new Zend_Json();
	$jsonentity = $json->encode($entity);
	echo $jsonentity;die;
}
die;
 
/**
 * 此处代码段需要反复调用，所以放到一个函数中统一调用
 * @param Object $approve Approve.class对象
 * @param Object $result Query查询结果集
 * @param String $module 模块名
 * @param Integer $approveid 审批流程ID
 * @project PROT144 审批功能改进
 * @return 执行提交审批操作
 * @author Tujt 2014-12-25
 */
function submitApprove($approve,$result,$module,$approveid) {
	global $adb;
    $rows = $adb->num_rows($result);
	if($rows > 0){
		$success = 0;
		for($i=0;$i<$rows;++ $i){
			$crmid = $adb->query_result($result,$i,'crmid');
			$approvestatus = $adb->query_result($result,$i,'approvestatus');
			$subject = $adb->query_result($result,$i,'subject');
			if($approvestatus == constant('D_A_S_DISMISSED')){
				$batchlog = getFixedLabel('DOCUMENTSUCCESS');
				$color = '';
				$success++;
				if($crmid > 0)
					$approve->ApproveSubmit($module,$crmid,$approveid);
			}else{
				$batchlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_SUBMIT');
				$color = '#FF0000';//已审批的单据，颜色设为红色
			}
			$log .= sprintf($batchlog,'<a referencemodule="'.$module.'" referencerecord="'.$crmid.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:'.$color.'">'.$subject.'</a>',getFixedLabel('SUBMITAPPROVAL')).'<br>';
			
		}
	}
	$data = array('log'=>$log,'success'=>$success);
	return $data;
}
?>