<?php
crm_load_class_file('cls_SaveWX', 'WeiXinApp/detail');

class cls_Contacts_SaveWX extends cls_SaveWX
{
    public function common_save()
    {
        //duan 20240125 留空方法重写
        $this->before_save();

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

//        @edit:liushuai,2021-06-24,reason:【ID1000293】企业微信PC端，进入外部联系人聊天窗口界面后，聊天工具栏增加默认显示“当前客户查看详情界面”(新增联系人保存)
        if (isset($_REQUEST['WXPCCreationInfo']) && $_REQUEST['WXPCCreationInfo'] != '') {
            $WXPCCreationInfo = ldcrm_json_decode(urldecode($_REQUEST['WXPCCreationInfo']));
            if (!empty($WXPCCreationInfo) && !empty($WXPCCreationInfo['weixin_external_userid'])) {
                $SQL = 'update ld_contactdetails set weixin_external_userid=\''.$WXPCCreationInfo['weixin_external_userid'].'\' WHERE deleted=0 and contactid='.$focus->id;
                $adb->pquery($SQL, array());
            }
        }

        $relatedCreationInfo = $_REQUEST['relatedCreationInfo'];
        $relatedCreationArr = json_decode($relatedCreationInfo,true);
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