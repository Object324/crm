<?php

/**
 * 公海客户类型转换
 * User: chj
 * Date: 2018-03-01
 */

class cls_ConvertLeads
{
	private $userid;
	private $btach_num;
	private $transfer;	//公海转换  转移到公海：transfer_to，转移出公海（转为普通客户）：transfer_out 
	private $transfer_pool_id; //转换至公海池
	public $module;
	public $db;
	public $public_account;
	public $userid_after_transfer;
	public $tabfieldname;
	public $focus;
	public $assigned;
	public $operation;
    public function __construct($module,$transfer,$pool_id)
    {
		$this->module = $module;
		$this->transfer = $transfer;
		$this->transfer_pool_id = $pool_id;
		$this->db = PearDatabase::getInstance();
		//所有公海池信息
		crm_load_class_file('cls_PublicLeads', 'modules/'.$module);
		$cls_PublicAccounts = new cls_PublicLeads($module);
		$this->public_account = $cls_PublicAccounts->getPublicAccountConfig();
		$this->userid_after_transfer = $this->getAfterTransferUserid();	//普通客户转为公海后，更改客户负责人为（为空表示不更改）
		//获取批量处理数
		$deployarray=getSys_deploy(67);
		$this->btach_num =  $deployarray['deploy_value'];

		$entityarray = getEntitynameInfo(getTabid($module));
		$this->tabfieldname = $entityarray['fieldname'];

		$this->focus=CRMEntity::getInstance($module);
		$smcolumnname=$this->focus->getSmownerColumName();
		$field_obj=$this->focus->fieldobj->getFieldInfoobjBykey('columnname',$smcolumnname);
		$this->assigned=$field_obj->getFieldName();

		if($this->transfer== 'transfer_to')//转移到公海
		{
			$this->operation='TOBETHEHIGHSEASCUSTOMTERS';
		}
		else//转移出公海（转为普通客户）
		{
			$this->operation='TOBETHEORDINARYCUSTOMERS';
		}
    }
	
	/**	单
	 * $record：单据ID
	 * @param 2018-03-01
	 * @return
	 * @author Chj
	 */
	public function setConvertAccount_row($record){
		if(!empty($record)){
			if($this->customtype == 'transfer_to')//转公海
			{   
				$this->setAccountForPublic($record,array());
			}
			else	//转普通
			{
				$this->setAccountForCommon($record,array());
			}
			$this->insertLogPublicAccount($record);	//插入公海日志
		}
	}
	
	//转移到公海
	private function setAccountForPublic($record,$account_infos){
        global $current_user;
		if(!empty($account_infos)){
			$data = $account_infos;
			$old_assign_userid = $data['smownerid'];
		}else{
			$this->focus->retrieve_entity_info($record,$this->module);
			$data = $this->focus->column_fields;
			$old_assign_userid=$this->focus->column_fields['assigned_user_id'];
		}

//        @edit:liushuai,2021-07-09,reason:【ID1001735】公海成员，普通销售线索和普通客户增加“转公海”功能
        //检查当前登录用户是否有该单据的编辑权限
        if (isPermitted($this->module,"EditView",$record) == 'no') {
            return -2;
        }
        // 1 公海未分配 3 公海已分配 0 普通客户
		if($data['publicaccount'] >= 1){	//公海 - 公海
            if($this->public_account['status'] == 'yes' && !empty($this->public_account['public_account_pool'])){
                $pool_id = $data['pool_id'];
                $pool_info = $this->public_account['public_account_pool'][$pool_id];

                $adminaccount = $pool_info['administrators'];	//公海管理员
                $usersaccount = $pool_info['userids'];	//公海普通用户
                $splitadmin = $splituser = [];
                if(!empty($adminaccount)) $splitadmin = explode(',',$adminaccount);
                if(!empty($usersaccount)) $splituser = explode(',',$usersaccount);
                if (!in_array($current_user->id,$splitadmin) && in_array($current_user->id,$splituser)) {
                    if ($data['publicaccount'] == 1) {
                        return -3;//如果不是公海管理员，而是公海成员，就不能转换公海未分配客戶，则返回提示（当前单据已经为公海客户了）
                    }else if($data['publicaccount'] > 1 && $pool_info['allow_trasnfer_others'] == 'no'){
                        return -3;//如果不是公海管理员，而是公海成员，如果参数公海已分配客户转其它公海没有勾选，则返回提示（当前单据已经为公海客户了）
                    }
                }
            }

			if($data['pool_id'] != $this->transfer_pool_id){
				if($data['publicaccount'] > 1){
					$limit_count = $this->getSmowerlimit_count($old_assign_userid);	//公海已分配客户数量上限
					$smowner_have_count = $this->getSmowerForPublicAccount($old_assign_userid);	//获取负责人在对应公海池的已分配客户数
					if($smowner_have_count < $limit_count){
						$this->updateAccountPoolid($record,$data['pool_id']);
                        
						if($data['publicaccount'] > 1){
							$opdate=date('Y-m-d');
							$days=getLeads_set_ProtectedDays("",$record);
                            
							$protectdate=date("Y-m-d",strtotime("$opdate +$days day"));
                            
							$update_query = "update ld_leads set protectdate=?,distributiondate=?,allocatedate=?,completed=? where leadsid=?";
							$this->db->pquery($update_query, array($protectdate,$opdate,$opdate,'',$record));
						}
					}else{
						return -1;	//公海已分配客户数量上限，转换失败
					}
				}else{
					$this->updateAccountPoolid($record,$data['pool_id']);
				}
			}
		}else{	//普通 - 公海
			$sql="update ld_leads set publicaccount = ?,protectdate=null,protectstartdate=null,allocatedate=null,pool_id=? where leadsid=?";
			$this->db->pquery($sql,array(1,$this->transfer_pool_id,$record));
			$this->updateAccountSmownerid($record,$old_assign_userid);
		}
		return 1;
	}
	
	//更改公海池
	private function updateAccountPoolid($record,$pool_id){
		if(!empty($this->transfer_pool_id)){
			$sql="update ld_leads set pool_id = ? where leadsid=?";
			$this->db->pquery($sql,array($this->transfer_pool_id,$record));
			if($pool_id != $this->transfer_pool_id){
				$this->focus->getModuleStatic('ModTracker');//字段修改日志/变更销售负责人
				$this->focus->modstatic->saveFieldLogOne($this->module,'pool_id',$record,$pool_id,$this->transfer_pool_id);
			}
		}
	}

	//更改负责人
	private function updateAccountSmownerid($record,$old_assign_userid){
		if(!empty($this->userid_after_transfer)){
			$sql="update ld_leads set smownerid = ? where leadsid=?";
			$this->db->pquery($sql,array($this->userid_after_transfer,$record));
			if($old_assign_userid != $this->userid_after_transfer){
				$this->focus->getModuleStatic('ModTracker');//字段修改日志/变更销售负责人
				$this->focus->modstatic->saveFieldLogOne($this->module,$this->assigned,$record,$old_assign_userid,$this->userid_after_transfer);
			}

            require_once  globalStatic::$root_directory.'modules/Users/Group.class.php';
            $group_focus = new Group();
            $depInfo = $group_focus->getUserGroup($this->userid_after_transfer);//变更后的负责人
            ksort($depInfo);
            $depId = implode(',',array_keys($depInfo));//部门id
            foreach($this->focus->fieldobj->getModuleFields() as $tmp_fieldname => $tmp_fieldinfo)
            {
                if($tmp_fieldinfo->getUIType() == 1600)
                {
                    $tmp_effect_fieldid = $tmp_fieldinfo->getFieldId();
                    $result_related_field = $this->db->pquery('select * from ld_related_field where effect_fieldid = ?', array($tmp_effect_fieldid));
                    if ($this->db->num_rows($result_related_field) >= 1) {
                        //检查设置的触发字段类型（负责人、创建人、单选用户类型不处理）
                        $tmp_trigger_fieldid = $this->db->query_result($result_related_field,0,'trigger_fieldid');
                        $sql_field = "select uitype,columnname from ld_field where fieldid = ? and ld_field.presence in (0,2)";
                        $result_field = $this->db->pquery($sql_field, array($tmp_trigger_fieldid));
                        if ($this->db->num_rows($result_field) >= 1 && $this->db->query_result($result_field,0,'columnname') == $this->focus->getSmownerColumName()) {//触发字段为负责人
                            $sql = 'update ' . $tmp_fieldinfo->getTableName() . ' set ' . $tmp_fieldinfo->getColumnName() . ' = ? where ' . $this->focus->table_index . ' = ? ';
                            $this->db->pquery($sql, array($depId, $record));
                        }

                    }

                }
            }
		}
	}

	//公海转普通
	private function setAccountForCommon($record,$account_infos){
        global $adb,$weixin_user;
        $focus = CRMEntity::getInstance($this->module);
        $limit_count = $focus->getCommonAccountLimitCount($account_infos['smownerid']);
        if($limit_count<9999999999)
        {
            $haved_count = $focus->getSmowerNumForCommonAccount($account_infos['smownerid']);
            if ($limit_count <= $haved_count) {
                if(!empty($weixin_user)){
                    $errormsg = $this->public_account['status'] == 'yes'?sprintf(getFixedLabel('TransferToCommonLeadsAppError1'), getUserFullName($account_infos['smownerid'])):sprintf(getFixedLabel('TransferToCommonLeadsAppError'), getUserFullName($account_infos['smownerid']));//单据负责人[张三]拥有的普通销售线索数量已达上限!
                    ConvertTojsonString(-1,array(),$errormsg);
                }else if ($_REQUEST['mode'] == 'detail'){//PC详情页返回
                    $errormsg = $this->public_account['status'] == 'yes'?sprintf(getFixedLabel('TransferToCommonLeadsAppError1'), getUserFullName($account_infos['smownerid'])):sprintf(getFixedLabel('TransferToCommonLeadsAppError'), getUserFullName($account_infos['smownerid']));
                    ConvertTojsonString(-1,array(),$errormsg);
                }else{
                    return -1;
                }
            }
        }

		$query = "select DATE_FORMAT(createdtime,'%Y-%m-%d'),ifnull(distributiondate,'') from ld_leads where leadsid = ?";
		$result = $adb->pquery($query,array($record));
		$createdtime = $adb->query_result($result,0,0);
		$distributiondate = $adb->query_result($result,1);
		$days=getLeads_set_normal_ProtectedDays("",$this->id);
		if(!empty($distributiondate)){
			if(!empty($days)){
				$protectdate=date("Y-m-d",strtotime("$distributiondate +$days day"));
			}
		}else{
			if(!empty($days)){
				$protectdate=date("Y-m-d",strtotime("$createdtime +$days day"));
			}
		}
		$sql="update ld_leads set publicaccount= 0,protectdate=?,protectstartdate=now(),allocatedate=null,pool_id = 0 where leadsid=?";
		$this->db->pquery($sql,array($protectdate,$record));
        return 1;
	}
	
	//插入公海日志
	private function insertLogPublicAccount($record){
		global $current_user;
		$opdate=date("Y-m-d H:i:s");
		$sql="insert into ld_logpublicleads(username,operation,opdate,leadsid,userid,pool_id)values(?,?,?,?,?,?)";
		$this->db->pquery($sql,array($current_user->last_name,$this->operation,$opdate,$record,$current_user->id,$this->transfer_pool_id));
		//系统操作日志
		$logid = $this->db->getLastInsertID();
		crm_load_class_file('cls_OperationLogs', 'modules/Settings/cls_OperationLogs');
		cls_OperationLogs::saveLogs('Leads','Transfer',$record,'',$logid);
	}

	/**	多
	 * $idstring：批量操作单据ID    $mass_convert_totalrows：批量操作记录数
	 * @param 2018-03-01
	 * @return
	 * @author Chj
	 */
	public function setConvertAccount_more($idstring){
		global $current_user;
		if(!empty($idstring)){
			$usersaccount=getAccount_set('usersaccount');
			$adminaccount=getAccount_set("adminaccount");
			$splitadmin=explode(",",$adminaccount);
			$splituser=explode(',',$usersaccount);
			$storearray = explode(',',$idstring);
			$mass_convert_totalrows=sizeOf($storearray);
            //edit:can 20210207 44614: 苏州浩辰（无外网地址）转换公海失败，反复提示说是普通客户，但显示为公海已分配（详情见附件）
			$query="select publicaccount,".$this->tabfieldname." as subject,ld_leads.leadsid,ld_leads.smownerid,pool_id 
            from ld_leads 
			left join ld_leadscf on ld_leadscf.leadsid=ld_leads.leadsid
			where ld_leads.leadsid in ($idstring)";
			$result=$this->db->pquery($query,array());
			$rows=$this->db->num_rows($result);
			for($i=0;$i<$rows;$i++)
			{
				$leadsid=$this->db->query_result($result,$i,'leadsid');
				$subject=$this->db->query_result($result,$i,'subject');
				$publicaccount=$this->db->query_result($result,$i,'publicaccount');
				$smownerid = $this->db->query_result($result,$i,'smownerid');
				$pool_id = $this->db->query_result($result,$i,'pool_id');
				$account_infos[$leadsid]=array('subject'=>$subject,'publicaccount'=>$publicaccount,'smownerid'=>$smownerid,'pool_id'=>$pool_id);
			}
		
			$countsuccess=0;	//成功条目数
			$error = 0;	//错误条目数
			$edit_err = '';	//成功、错误提示日志
			if($this->transfer == 'transfer_to'){	//转移到公海
				$batchlog = getFixedLabel('TOTHEHIGNSEASCUSTOMERERROR1');	//单据[%s]转为公海客户失败，原因：已超出转换公海负责人的保有数量！
				$batchsuccesslog = getFixedLabel('TOTHEHIGNSEASCUSTOMERSUCCESS');	//单据[%s]转为公海客户成功！
				$title = getFixedLabel('Transfer');//标题：转换公海
				foreach($storearray as $key => $record){
					if($this->btach_num <= $key)break;
					$subject = $account_infos[$record]['subject'];
					$result = $this->setAccountForPublic($record,$account_infos[$record]);
					if($result == 1){
						$this->insertLogPublicAccount($record);	//插入公海日志
						$countsuccess++;
						$edit_err .= sprintf($batchsuccesslog,'<a href="javascript:;" module="Leads" record="'.$record.'"  onclick="ListLinkClick(ld(this),event)">'.$subject.'</a>').'<br>';
					}
                    elseif($result == -2){
                        $edit_err .= sprintf(getFixedLabel('TOTHEHIGNSEASCUSTOMERERROR2'),'<a href="javascript:;" module="Leads" record="'.$record.'"   onclick="ListLinkClick(ld(this),event)">'.$subject.'</a>').'<br>';
                        $error++;
                    }
                    elseif($result == -3){
                        $edit_err .= sprintf(getFixedLabel('TOTHEHIGNSEASCUSTOMERERROR3'),'<a href="javascript:;" module="Leads" record="'.$record.'"   onclick="ListLinkClick(ld(this),event)">'.$subject.'</a>').'<br>';
                        $error++;
                    }
					else{
						//单据[%s]转为公海客户失败，原因：当前单据已经时公海客户了！
						$edit_err .= sprintf($batchlog,'<a href="javascript:;" module="Leads" record="'.$record.'"   onclick="ListLinkClick(ld(this),event)">'.$subject.'</a>').'<br>';
						$error++;
					}
				}
			}else if($this->transfer == 'transfer_out'){	//转移出公海（转为普通客户）
				$batchlog = getFixedLabel('TOANORDINARYCUSTOMERERROR');	//单据[%s]转为普通客户失败，原因：当前单据已经是普通客户了！
				$batchsuccesslog = getFixedLabel('TOANORDINARYCUSTOMERSUCCESS');	//单据[%s]转为普通客户成功！
				$title = getFixedLabel('Transfer');//标题：转换公海
                $batreachmax_transfercommon = $this->public_account['status'] == 'yes'?getFixedLabel('TransferToCommonLeadsError1'):getFixedLabel('TransferToCommonLeadsError');//列表批量转公海（转普通销售线索）上限提示内容

				foreach($storearray as $key => $record){
					if($this->btach_num <= $key)break;
					$subject = $account_infos[$record]['subject'];
					if($account_infos[$record]['publicaccount'] >= 1){
						$result = $this->setAccountForCommon($record,$account_infos[$record]);
//						$result = 1;
						if($result == 1){
							$this->insertLogPublicAccount($record);	//插入公海日志
							$countsuccess++;
							$edit_err .= sprintf($batchsuccesslog,'<a href="javascript:;" module="Leads" record="'.$record.'"  onclick="ListLinkClick(ld(this),event)">'.$subject.'</a>').'<br>';
                        } elseif ($result == -1) {
                            //单据[%s]转公海失败！原因：单据负责人【张三】拥有的普通销售线索数量已经达到上限！
                            $edit_err .= sprintf($batreachmax_transfercommon,'<a href="javascript:;" module="Accounts" record="'.$record.'"   onclick="ListLinkClick(ld(this),event)">'.$subject.'</a>',getUserFullName($account_infos[$record]['smownerid'])).'<br>';
                            $error++;
                        }
					}else{
						//单据[%s]转为公海客户失败，原因：当前单据已经时公海客户了！
						$edit_err .= sprintf($batchlog,'<a href="javascript:;" module="Leads" record="'.$record.'"   onclick="ListLinkClick(ld(this),event)">'.$subject.'</a>').'<br>';
						$error++;
					}
				}
			}
		}
		if($error == 0){
			$error = $mass_convert_totalrows - $countsuccess;
		}
		return array('success'=>$countsuccess,'error'=>$error,'log'=>$edit_err,'title'=>$title,'mass_convert_totalrows'=>$mass_convert_totalrows);
		
	}
	
	//普通客户转为公海后，更改客户负责人为（为空表示不更改）
	private function getAfterTransferUserid(){
		if(!empty($this->public_account['public_account_pool'][$this->transfer_pool_id])){
			return $this->public_account['public_account_pool'][$this->transfer_pool_id]['userid_after_transfer'];
		}else{
			return 0;
		}
	}
	
	//公海已分配客户数量上限
	private function getSmowerlimit_count($userid){
		global $adb;
		if(!empty($this->transfer_pool_id)){
			$pool_info = $this->public_account['public_account_pool'][$this->transfer_pool_id];
			if($pool_info['limit_type'] == 'user'){
				$count = $pool_info['limit_count'];
			}else{
				require_once globalStatic::$root_directory.'include/utils/UserInfoUtil.php';
				$roleid = getUserRoleId($userid);
				$sql = 'SELECT limit_count FROM ld_leads_role_limitcount WHERE roleid=? and pool_id = ? limit 1;';
				$result = $adb->pquery($sql, array($roleid,$this->transfer_pool_id));
				$rows = $adb->num_rows($result);
				if ($rows > 0) {
					$count = $adb->query_result($result, 0, 'limit_count');
				} else {
					$count = 0;
				}
			}
		}
		return $count;
	}
	
	//获取负责人在对应公海池的已分配客户数
	private function getSmowerForPublicAccount($userid){
		global $adb;
		$query = "select 1 from ld_leads where publicaccount > 1 and deleted = 0 and smownerid = ? and pool_id = ?";
		$result = $adb->pquery($query,array($userid,$this->transfer_pool_id));
		return $adb->num_rows($result);
	}
}