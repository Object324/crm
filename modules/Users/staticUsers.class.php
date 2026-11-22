<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-03-17
 */
// 部门操作方法类
class staticUsers {
	/**
	 * 获取呼叫中心参数类型
	 * @project 汉天呼叫中心批量外呼
	 * @author Tujt 2015-04-29
	 */
	public static function getCallCenterType() {
	   $regop=RegOp::getInstance();
        $callcenter_interface=$regop->GetcallcenterInterfaceStatus();
		//$callcenter_interface = 1;//editor:gyq_69X reason:帮我吧呼叫中心 2018/6/7 16:31
	    $callcentertype = getSys_deploy(55);
		$value = $callcentertype['deploy_value']??'';
		/* gyq_11 */
        if($callcenter_interface==0)
        {
            $callcenterarr = array('电话录音盒'=>1,
                '灵当语音盒'=>'yiwei',//灵当语音盒不需要呼叫中心接口授权
            );
        }
        else{
            //editor:gyq_69 reason:帮我吧呼叫中心 2018/6/4 20:57
            require_once(globalStatic::$root_directory. 'CallCenter/lib/cls_calloption.php');
            $obj_call = new cls_calloption();
            $callcenterarr = $obj_call->s_centertype;
        }
		if(isset($callcenterarr[$value])){
			return $callcenterarr[$value];
		}
		return 0;
	}
	/**
	 * 呼叫中心外呼
	 * @author Tujt 2015-04-29
	 */
	public static function CallCenterCall($mobile,$source = '') {
		global $current_user;
	    require './user_privileges/hantian.inc.php';
        if(strpos($mobile,'-') > -1){
        	$modulearr = explode('-', $mobile);
        	$mobile = $modulearr[0].$modulearr[1];
        }
		$serverIp = $hantian['ec2_server_ip'];
		$serverPort = $hantian['ec2_server_port'];
		$url = 'http://'.$serverIp.':'.$serverPort.'/ec2/http/common/dial?';
		if(!empty($current_user->column_fields['description'])){
			$url .= 'username='.$current_user->column_fields['description'].'&destNum='.$mobile.'';
		}
		if(!empty($hantian['accessId'])){
			$url .= '&accessId='.$hantian['accessId'].'&accessKey='.$hantian['accessKey'].'';
		}
		$elasticscreen = 'false';
		if(!empty($source)){//来源于详情页，需要弹出呼叫弹屏(detail)
			$elasticscreen = 'true';
		}
		$url .= '&elasticscreen='.$elasticscreen;
   
		$output = file_get_contents($url);
		if(!empty($output)){
			return $output;
		}
        return '';
	}
	/**
	 * 自动外呼保存联系记录
	 * @author Tujt 2015-04-29
	 */
	public static function saveCallNode($input) {
		global $adb;
		$focus = CRMEntity::getInstance('ContactRecords');
		setObjectValuesFromRequest($focus);
		//负责人
		if($input['assigntype'] == 'U')  {
			$focus->column_fields['assigned_user_id'] = $input['assigned_user_id'];
		} elseif($input['assigntype'] == 'T') {
			$focus->column_fields['assigned_user_id'] = $input['assigned_group_id'];
		}
		//Changing account address - Ends
		$LINGDANG_BULK_SAVE_MODE = true;
		$focus->save("ContactRecords");
		$module = 'ContactRecords';
		$return_id = $focus->id;
		//add by tifa for reminds 20130301
		$focus_rel = CRMEntity::getInstance('Reminds');
		$focus_rel->saveRemindsInfo($module,$return_id);
		$focus_rel = new Activity();
		$focus_rel->id=$return_id;
		$focus_rel->insertIntoReminderTable('ld_activity_reminder','Calendar',"");
		/**
		* edit:chj
		* date:2014-4-8
		* reason:0008139: 项目任务明细界面，更多信息，联系人记录列表，点击创建按钮，创建后的单据，没有在该列表显示；
		**/
		if(isset($input['projecttaskid']) && $input['projecttaskid'] != '' && $input['Create'] == 'yes')
		{
			$projecttaskid = $input['projecttaskid'];
			$adb->pquery("update ld_contactrecords set projecttaskid = $projecttaskid where contactrecordid = $return_id");
		}
		$accountname = $input['account_name'];
		$datetime = $input['nextcontactdate'];
		$recieverid = $input['assigned_user_id'];
		/**
		* edit:chj
		* date:2014-4-10
		* reason:0008206: 项目明细界面，更多信息，联系人记录列表，点击创建按钮创建的单据，在列表内无显示
		**/
		if(isset($input['projectid']) && $input['projectid'] != '' && $input['Create'] == 'yes')
		{
			$projectid = $input['projectid'];
			$adb->pquery("update ld_contactrecords set projectid = $projectid where contactrecordid = $return_id");
		}
		if($input['contactdate'] < $input['nextcontactdate']){
			$RemindsContent="回访提醒，"."客户 ".$accountname;
			$record = $input['currentid'];
			//新建创建提醒
			self::AddReminds($RemindsContent,$datetime,$recieverid,$record,$input['contactdate'],$input['nextcontactdate']);
		}
	    return 'SUCCESS';
	}
	/**
	 * 更新操作
	 * 创建连系记录新增提醒，提醒销售负责人
	 * edit by andy
	 * date: 20140218
	**/
	//echo "<pre>";
	//print_r($_REQUEST);
	public static function AddReminds($RemindsContent,$datetime,$recieverid,$record,$date1,$date2)
	{
		global $adb,$current_user;
			if($date1<$date2){
				//下次回访日期更新，首先删除该联系记录关联的未读的提醒
				$sql="delete from ld_reminds where related_to='{$record}' and status_rmd='未读'";
				$result = $adb->query($sql);  
                $sql="delete from ld_reminds_accepted where related_to='{$record}' and status_rmd='未读'";
				$result = $adb->query($sql); 
			}
			$smownersql = "select * from ld_crmentity where crmid = ".$record;
			$smownerresult = $adb->query($smownersql);
			$setype = $adb->query_result($smownerresult,0,'setype');
			$focus_rel =CRMEntity::getInstance('Reminds');                    
			$focus_rel->column_fields['date_time'] = $datetime;	   
			$focus_rel->column_fields['related_to']=$record;
			$focus_rel->column_fields['reltab']=$setype;
			
			$focus_rel->column_fields['recieverid']=$recieverid;
			
			$focus_rel->column_fields['status_rmd']='未读';
			$focus_rel->column_fields['content']=$RemindsContent;
			$focus_rel->mode="create";
			$focus_rel->save('Reminds');
            return $focus_rel->id;
	}
}
?>