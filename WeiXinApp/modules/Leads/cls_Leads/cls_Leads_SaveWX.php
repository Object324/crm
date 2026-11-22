<?php
crm_load_class_file('cls_SaveWX', 'WeiXinApp/detail');

class cls_Leads_SaveWX extends cls_SaveWX
{
    public function common_save()
    {
        $this->before_save();

        if ($_REQUEST['publicaccount'] == 3){
            $_REQUEST['allocatetype'] = 2;
            $allocate = cls_Instance::get_commonAction_Instance('Leads','AllocateAccount',1);
            $allocate->init_count();
            $allocate->judgeCount();
        }
        elseif ($_REQUEST['publicaccount'] == 1) {
            //ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块(移动端普通销售线索新建 保存)
            crm_load_class_file('cls_PublicLeads', 'modules/Leads');
            $cls_PublicAccounts = new cls_PublicLeads('Leads');
            $public_account = $cls_PublicAccounts->getPublicAccountConfig();
            $limit_count = $this->focus->getCommonAccountLimitCount($_REQUEST['assigned_user_id']);
            if($limit_count<9999999999)
            {
                $haved_count = $this->focus->getSmowerNumForCommonAccount($_REQUEST['assigned_user_id']);
                if ($limit_count <= $haved_count) {
                    $errormsg = $public_account['status']=='yes'?sprintf(getFixedLabel('CreateSaveReacheMaximumLeadsError1'), getUserFullName($_REQUEST['assigned_user_id'])):sprintf(getFixedLabel('CreateSaveReacheMaximumLeadsError'), getUserFullName($_REQUEST['assigned_user_id']));
                    ConvertTojsonString(-1,[],$errormsg);
                }
            }
        }
        //关联新增销售线索公海参数不为普通客户
        $_REQUEST['publicaccount'] = isset($_REQUEST['publicaccount'])&&$_REQUEST['publicaccount']>=1?$_REQUEST['publicaccount']-1:0;

        global $adb,$current_user;
        //reason:联系人拍名片创建关联创建客户 editor:gyq_20 date:20170111
        $cache_record = $_REQUEST['record'];
        /*$_REQUEST['CamCard_RelatedCreate'] = "TEL;CELL:+1008610086\n
                TEL;WORK;FAX:+86021500983\n
                URL;WORK:NOVOTEL.COM\n
                URL;WORK:ovotel.com\n
                ORG;PREF;WORK;CHARSET=UTF-8:SuperMarket01;
                ";*/
        //editor:gyq_40_6 date:20170727
        require_once globalStatic::$root_directory.'appCommon/include/piecesFunctionMC.php';
        $_REQUEST['account_id'] = set_camcard_related_create_mc($_REQUEST['CamCard_RelatedCreate'],'Accounts','account_id');
        $_REQUEST['record'] = $cache_record;

        $focus = $this->focus;
        //0025802: （微信端-安卓）联系人：新增自定义的多选框字段，新增联系人选择多选框信息，出现代码
        //微信传过来的保存至需要转为数组
        foreach ($focus->column_fields as $fieldname => $val) {
            if (isset($_REQUEST[$fieldname])) {
                if($focus->columns_uitype[$fieldname]==33){
                    //editor:gyqX160929 reason:微信端备注等长字段是经POST数组放在REQUSET中，此时用POST接收不到数据
                    $_REQUEST[$fieldname] = explode(',',$_REQUEST[$fieldname]);
                }
            }
        }
        setObjectValuesFromRequest($focus);
        $focus->save($this->module);
        $versionInfo = getVersionInfo();
        //2021-0201 zxm 陌远特殊开发 销售线索新建保存发送邮件
        if($versionInfo['account'] == "moyuan"){
            include globalStatic::$root_directory.'modules/Home/CustomMade/MoyuanUtils.php';
            $moyuanObj = new MoyuanUtils();
            $moyuanObj->emailLeadsForSave($focus->mode,$focus->id);
        }

        $relatedCreationArr = isset($_REQUEST['relatedCreationInfo']) ? json_decode($_REQUEST['relatedCreationInfo'],true) : array();
        if(isset($relatedCreationArr['frommodule']) && $relatedCreationArr['frommodule'] == "Campaigns")
    	{
    		if((isset($relatedCreationArr['fromid']) && $relatedCreationArr['fromid'] != ""))
    		{
    			$campContStatusResult = $adb->pquery("select campaignrelstatusid from ld_campaigncontrel where campaignid=? AND contactid=?",array($_REQUEST['return_id'], $focus->id));
    			$contactStatus = $adb->query_result($campContStatusResult,0,'campaignrelstatusid');
    			$sql = "delete from ld_campaigncontrel where contactid = ?";
    			$adb->pquery($sql, array($focus->id));
    			if(isset($contactStatus) && $contactStatus!=''){
    				$sql = "insert into ld_campaigncontrel values (?,?,?)";
    				$adb->pquery($sql, array($relatedCreationArr['fromid'], $focus->id,$contactStatus));
    			}
    			else
    			{
    				$sql = "insert into ld_campaigncontrel values (?,?,1)";
    				$adb->pquery($sql, array($relatedCreationArr['fromid'], $focus->id));
    			}
    		}
    	}
        if(isset($relatedCreationArr['frommodule']) && $relatedCreationArr['frommodule'] == "Potentials")
    	{
    		if((isset($relatedCreationArr['fromid']) && $relatedCreationArr['fromid'] != ""))
    		{
				$sql = "insert into ld_contpotentialrel values(?,?)";
				$adb->pquery($sql, array($focus->id,$relatedCreationArr['fromid']));
    		}
    	}
        if(!empty($_REQUEST['file_save_weixin'])){
            $this->saveAttachmentFromWeiXinApi_CommonModule($focus->id,$this->module,$_REQUEST['file_save_weixin']);
        }

        //duan 20240125 将签到以及审批必填字段的保存合并到一起
        $this->after_save();
    }
}