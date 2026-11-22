<?php
crm_load_class_file('cls_SaveWX', 'WeiXinApp/detail');

class cls_Accounts_SaveWX extends cls_SaveWX
{

    //字段重复判断
    protected function FieldDuplicate($fieldname, $fieldvalue)
    {
        $ldcls = new staticlingdang();
        $rest = $ldcls->getFieldDuplicateInfo($this->module, $fieldname, $fieldvalue, $this->focus->id);
        if (strpos($rest, '##error##') !== false) {

            if ($fieldname == 'accountname') {
                $system = getSys_deploy(95);
                if ($system['deploy_value'] == 0 && $_REQUEST['accountname'] != '') {
                    /*
                      * editor:gyq_40_1 date:20170728 reason:对冲提醒
                      * */
                    require_once globalStatic::$root_directory.'appCommon/include/piecesFunctionMC.php';
                    $restFinal = set_duplicate_reminds_ac('accountname', $_REQUEST['accountname']);
                    $detail['fieldname'] = 'accountname';
                    ConvertTojsonString(-1, $detail, $restFinal);
                }else{
                    $restFinal = str_replace('##error##', '', $rest);
                    $detail['fieldname'] = $fieldname;
                    ConvertTojsonString(-1, $detail, $restFinal);
                }

            } else {
                $restFinal = str_replace('##error##', '', $rest);
                $detail['fieldname'] = $fieldname;
                ConvertTojsonString(-1, $detail, $restFinal);
            }
        }

    }

    //对冲提醒
    public function duplicateReminds($accountname_orign)
    {
        global $adb,$current_user;
            //gyq_40_1
            //客户重复是否弹出对冲提醒  1:否，0:是
            $accountname = $_REQUEST['accountname'];
            $dialogcontent = '';
            $sql = "SELECT accountid,smownerid,createdtime,ld_users.phone_mobile lsphone,ld_users.last_name lsname
              FROM ld_account LEFT JOIN ld_users on ld_users.id = smownerid  WHERE accountname = '" . $accountname . "'";
            $sqlResult = $adb->pquery($sql, array());
            $sqlCount = $adb->num_rows($sqlResult);
            if ($sqlCount > 0) {
                require_once(globalStatic::$root_directory . "modules/Reminds/Reminds.php");
                $remindinfo = array();

                for ($i = 0; $i < $sqlCount; $i++) {
                    $remindinfo[$i] = array(
                        'accountid' => $adb->query_result($sqlResult, $i, 'accountid'),
                        'smownername' => $adb->query_result($sqlResult, $i, 'lsname'),
                        'smownerid' => $adb->query_result($sqlResult, $i, 'smownerid'),
                        'createdtime' => $adb->query_result($sqlResult, $i, 'createdtime'),
                        'smownerphone' => $adb->query_result($sqlResult, $i, 'lsphone')
                    );

                    /*生成弹框提示
                     {accountname}已被{smowner}在{createdtime}报备，请联系{smowner}，联系电话：{smownerphone}*/
                    //若手机号码为空，显示“暂未录入”
                    if (empty($remindinfo[$i]['smownerphone'])) {
                        $smphone = getFixedLabel('NOENTRY');
                    } else {
                        $smphone = $remindinfo[$i]['smownerphone'];
                    }
                    $newfieldvalue = '[<span style="color: red">' . $accountname . '</span>] ';

                    $search = array('/{accountname}/is', '/{smowner}/is', '/{createdtime}/is', '/{smownerphone}/is');
                    $replace = array($newfieldvalue, $remindinfo[$i]['smownername'], $remindinfo[$i]['createdtime'], $smphone);
                    $dialogcontent .= preg_replace($search, $replace, getFixedLabel('REMINDOWNEFORHEDGING')) . '<br>';
					//chj 2021/2/22 客户重复报备提醒，提醒人收到的报备提醒内容增加报备人
                    /*向负责人发送提醒
                      您的{accountname}客户已有{operator}在{nowtime}正在尝试报备，联系电话：{operatorphone}*/
                    if (empty($remindinfo[$i]['opeatorphone']))  //若手机号码为空，显示“暂未录入”
                        $otphone = getFixedLabel('NOENTRY');
                    else
                        $otphone = $current_user->phone_mobile;
					$date_time = date('Y-m-d H:i:s', time());
					$search = array('/{operator}/is', '/{nowtime}/is', '/{operator}/is', '/{operatorphone}/is');
					$replace = array($current_user->last_name, $date_time, $current_user->last_name, $otphone);
					$remindcontent = preg_replace($search, $replace, getFixedLabel('REMINDOPEAFORHEDGING'));

                    $focusreminds = new Reminds();
                    $focusreminds->column_fields['related_to'] = $remindinfo[$i]['accountid'];
                    $focusreminds->column_fields['reltab'] = $_REQUEST['module']; //Accounts
                    $focusreminds->column_fields['is_del_send'] = 0;
                    $focusreminds->column_fields['is_del_rec'] = 0;
                    $focusreminds->column_fields['status_rmd'] = '未读';
                    $focusreminds->column_fields['date_time'] = $date_time;
                    $focusreminds->column_fields['recieverid'] = $remindinfo[$i]['smownerid'];
                    $focusreminds->mode = 'create';

                    $focusreminds->column_fields['content'] = $remindcontent;

                    $focusreminds->save('Reminds');
                }
                $restStr = str_replace('##error##', "", $dialogcontent);
                $detail['fieldname'] = $accountname_orign;
                ConvertTojsonString('-1', $detail, $restStr);
            }
    }


    public function common_save()
    {//公海参数保存$focus

        if ($_REQUEST['publicaccount'] == 3){
			$_REQUEST['allocatetype'] = 2;
            $allocate = cls_Instance::get_commonAction_Instance('Accounts','AllocateAccount',1);
            //$allocate->setParams(2,$_REQUEST['assigned_user_id'],1);
            $allocate->init_count();
            $allocate->judgeCount();
        }
        elseif ($_REQUEST['publicaccount'] == 1) {
            //ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块(移动端普通客户新建 保存)
            crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
            $cls_PublicAccounts = cls_PublicAccounts::getInstance('Accounts');
            $public_account = $cls_PublicAccounts->getPublicAccountConfig();
            $limit_count = $this->focus->getCommonAccountLimitCount($_REQUEST['assigned_user_id']);
            if($limit_count<9999999999)
            {
                $haved_count = $this->focus->getSmowerNumForCommonAccount($_REQUEST['assigned_user_id']);
                if ($limit_count <= $haved_count) {
                    $errormsg = $public_account['status']=='yes'?sprintf(getFixedLabel('CreateSaveReacheMaximumError1'), getUserFullName($_REQUEST['assigned_user_id'])):sprintf(getFixedLabel('CreateSaveReacheMaximumError'), getUserFullName($_REQUEST['assigned_user_id']));
                    ConvertTojsonString(-1,[],$errormsg);
                }
            }
        }
        //关联新增客户公海参数不为普通客户
        $_REQUEST['publicaccount'] = isset($_REQUEST['publicaccount'])&&$_REQUEST['publicaccount']>=1?$_REQUEST['publicaccount']-1:0;

//        @edit:liushuai,2021-06-24,reason:【ID1000293】企业微信PC端，进入外部联系人聊天窗口界面后，聊天工具栏增加默认显示“当前客户查看详情界面”(新增客户保存,首要联系人设置不显示时，默认给添加上)
        //首要联系人设置不显示时。默认新增上
        $deployarray_72 = getSys_deploy(72);
        if (isset($_REQUEST['WXPCCreationInfo']) && $_REQUEST['WXPCCreationInfo'] != '' && $deployarray_72['deploy_value'] == 1) {
            $WXPCCreationInfo = ldcrm_json_decode(urldecode($_REQUEST['WXPCCreationInfo']));
            if (!empty($WXPCCreationInfo)) {
                foreach ($WXPCCreationInfo as $fieldname=>$val) {
                    if ($fieldname == 'description') {//值description是联系人的备注，不是客户的备注
                        continue;
                    }
                    if (!isset($_REQUEST[$fieldname]) && isset($WXPCCreationInfo[$fieldname])) {
                        $_REQUEST[$fieldname] = trim($val);
                    }
                }
            }
        }

        global $adb,$current_user;
        $focus = $this->focus;
        setObjectValuesFromRequest($focus);

        $this->before_save();

        $sqlcontact = "select contactid from ld_contactdetails
                  where accountid=? and reference=1 and ld_contactdetails.deleted=0  order by contact_no asc limit 0,1";
        $resultcontact = $adb->pquery($sqlcontact, array($this->focus->id));
        $_REQUEST['contactid'] = -1;
        if ($adb->num_rows($resultcontact) > 0) {
            $_REQUEST['contactid'] = $adb->query_result($resultcontact, 0, 0);
        }
        $focus->save($this->module);

// @edit:dong date:2021/09/01 @reason: 禹王特殊开发 保存后同步到nc
        $versioninfo = getVersionInfo();
        if($versioninfo['account'] =='yuwang'){
            require_once(globalStatic::$root_directory.'include/yuwang.php');
            $yuwang = new  yuwang();
            $yuwang->accountToNc($focus);
        }

        $relatedCreationInfo = $_REQUEST['relatedCreationInfo'];
        $relatedCreationArr = json_decode($relatedCreationInfo,true);
        if(isset($relatedCreationArr['frommodule']) && $relatedCreationArr['frommodule'] == "Campaigns")
        {
        	if((isset($relatedCreationArr['fromid']) && $relatedCreationArr['fromid'] != ""))
        	{
        	    $campaignid=$relatedCreationArr['fromid'];
               
        		$campAccStatusResult = $adb->pquery("select campaignrelstatusid from ld_campaignaccountrel where campaignid=? AND accountid=?",array($campaignid, $focus->id));
        		$accountStatus = $adb->query_result($campAccStatusResult,0,'campaignrelstatusid');
        		$sql = "delete from ld_campaignaccountrel where accountid = ?";
        		$adb->pquery($sql, array($focus->id));
        		if(isset($accountStatus) && $accountStatus!=''){
        			$sql = "insert into ld_campaignaccountrel(campaignid,accountid,campaignrelstatusid) values (?,?,?)";
        			$adb->pquery($sql, array($relatedCreationArr['fromid'], $focus->id,$accountStatus));
        		}
        		else{
        			$sql = "insert into ld_campaignaccountrel(campaignid,accountid,campaignrelstatusid) values (?,?,1)";
        			$adb->pquery($sql, array($relatedCreationArr['fromid'], $focus->id));		
        		}
        	}
        }
        
        if(isset($relatedCreationArr['frommodule']) && $relatedCreationArr['frommodule'] == "Potentials")
        {
        	if(isset($relatedCreationArr['fromid']) && $relatedCreationArr['fromid'] != "")
        	{
        		$potentialid = $relatedCreationArr['fromid'];
                $accountid = $focus->id;
                $checkSql = "select count(1) as count from ld_accountpotentialrel WHERE potentialid = $potentialid AND accountid = $accountid ";
                $checkResult = $adb->pquery($checkSql,array());
                if($adb->query_result($checkResult,0,"count") == 0)
                {
                    $adb->pquery("insert into ld_accountpotentialrel values($accountid,$potentialid)", array());
                }
        	}
        }
        if(isset($_REQUEST['previousAction'])&&$_REQUEST['previousAction']=='CreateView'){
            $adb->pquery('update ld_account set servicecasher = ? where accountid = ?',array($current_user->id,$focus->id));
        }
        if(!empty($_REQUEST['file_save_weixin'])){
           // $this->saveAttachmentFromWeiXinApi_CommonModule($focus->id,$this->module,$_REQUEST['file_save_weixin']);
        }


        //duan 20240125 将签到以及审批必填字段的保存合并到一起
        $this->after_save();
    }
    //editor:gyq_150 reason:客户/联系人保存字段重复提示自定义  2019/10/15 14:21
    protected function check_before_field_duplicate()
    {
        crm_load_class_file('cls_rule_validata','include/utils');
        $tabid = getTabid($_REQUEST['module']);
        if(!empty($_REQUEST['wx_fieldInfo'])){
            foreach($_REQUEST['wx_fieldInfo'] as $columnanme => $value){
                $_REQUEST[$columnanme] = $value;
            }
        }
        if(empty($_REQUEST['confirm_save'])){
            $cls_interface_yaoji = new cls_rule_validata($tabid);
            if(get_versiontrade() == 'aode'){
                $data = $cls_interface_yaoji->getForAode();
            }
            $data = $cls_interface_yaoji->get();
            if(!empty($data)){
                if($data['rule_result'] == 'NoSave')
                    ConvertTojsonString(-1, $data['rule_result'], $data['tips']);
                else
                    ConvertTojsonString(2, $data['rule_result'], $data['tips']);
            }
        }
    }
}
?>