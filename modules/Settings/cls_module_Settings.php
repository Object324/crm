<?php

class cls_module_Settings
{
    public static function getSettingsBlockId($label) {
    	global  $adb;
    
    	$blockid = '';
    	$query = "select blockid from ld_settings_blocks where label = ?";
    	$result = $adb->pquery($query, array($label));
    	$noofrows = $adb->num_rows($result);
    	if ($noofrows == 1) {
    		$blockid = $adb->query_result($result, 0, "blockid");
    	}
    
    	return $blockid; 
    }
        public static function getSettingsBlocks(){
    	global $adb;
    	//editor:gyq_108 reason:订单小程序  2019/4/17 10:28
            //editor:gyq_20190424
    	$regop=RegOp::getInstance();
        require_once globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_StaticCommonFun.php';
        require_once globalStatic::$root_directory.'appCommon/appCommon.php';
        $servicehelp = 0;
        $orderhelp = 0;
       // if(judgeCorpInfo("kehu001")==false){
        //edit:can 20200824 0042498: (https://61mis.com/KH/kh40115/ [^])客户问题（广东顺德德胜学校）已授权“服务小程序”权限，系统设置中没有显示“服务小程序设设置”
           $servicehelp=$regop->getservicehelp_interface();
            /* 
            wym 230802 BUG0068433 成员管理查看详情界面，和右上角个人头像下拉选项中，去掉“订单小程序”操作按钮（包括后台设置和注册系统去掉“订单小程序”设置菜单栏和接口授权，“商城”在注册系统增加了另外的接口授权）
            if(method_exists($regop,'getorder_smallinterface')){
                $orderhelp=$regop->getorder_smallinterface();
            }
            */
       // }
        $service_blockid = getSettingsBlockId('LBL_SERVICE_MINI_SETTINGS');
        $order_blockid = getSettingsBlockId('LBL_ORDER_MINI_SETTINGS');

        /**
         * diony 2013-03-15 增加字段，判断控制面板显示信息
        */
    	$sql = "select * from ld_settings_blocks where active=0 order by sequence";
    	$result = $adb->query($sql);
    	$count = $adb->num_rows($result);
    	$blocks = array();
        
    	if($count>0){
    		for($i=0;$i<$count;$i++){
    			$blockid = $adb->query_result($result, $i, "blockid");
                if($servicehelp==0&&$blockid==$service_blockid)
                    continue;
                if($orderhelp==0&&$blockid==$order_blockid)
                    continue;
    			$label = $adb->query_result($result, $i, "label");
               
    			$blocks[$blockid] = $label;
    		}
    	}

        
    	return $blocks;
    }
    public static  function getSettingsFields(){
    	global $adb;
        //载入使用的语言和语言包
       // global $current_user;
        //require "user_privileges/user_language_$current_user->id.php";
        
        //require_once "include/language/$languageType.php";
        //editor:gyq_108 reason:订单小程序  2019/4/17 10:28
        //editor:gyq_104 reason:小程序设置优化  2019/3/4 13:31
        //editor:gyq_135 reason:微信打卡同步  2019/8/16 16:03
        //editor:gyq_141 reason:移动端增加首页标签  2019/9/4 1  3:46 ID1000602
        //editor:gyq_144 reason:钉钉,仅一下版本显示钉钉：                       2019/9/12 15:02
        //灵当CRM基础版\灵当CRM标准版\灵当CRM企业版\灵当进销存\灵当CRM金融行业版 2019/9/24 13:38 gyq_20190924
        //editor:gyq_159 reason:系统设置增加移动端报表菜单定制  report_menu_customization 2019/11/8 11:55 ID1000638
        $regop=RegOp::getInstance();
        $datainterfacestate=$regop->GetDataInterfaceStatus();
        require_once globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_StaticCommonFun.php';
        require_once globalStatic::$root_directory.'appCommon/appCommon.php';
        $where_sql = '';

//        @edit:liushuai,2020-09-18,reason:【ID1001104】钉钉群消息推送设置功能优化（合同订单和自定义11-45模块提交审批时,如果模块关闭就左侧栏就不显示钉钉群消息推送设置按钮）
        $res = $adb->query("SELECT * FROM ld_tab WHERE presence IN (0,2) AND (name = 'SalesOrder' OR REPLACE(name,'CustomForm','') BETWEEN 11 AND 45) ORDER BY tabid");
        if ($adb->num_rows($res) > 0) {
//        @edit:liushuai,2020-08-21,reason:【ID1001020】钉钉接口参数设置增加参数“钉钉群消息推送设置”,重新登录系统会把钉钉的active置1，菜单栏就看不到了
            $where_sql .= ' or `name`=\'dingtalk_webhook_setting\'  ';
        }
        $installDing=false;
       if(judgeDingTalkInstall()){
         
            require_once globalStatic::$root_directory . 'WeiXinApp/dingtalk/model/event_model.php';
            $eventModel = new event_model();
            if ($eventModel->initConfig()) {
                
                $installDing=true;
            } else {
                $installDing=false;
            }
        }else{
            $installDing=false;
        }
        $installDing = true;
       if(get_class($regop)=='RegOp')//edit:can 钉钉接口设置是否显示判断改进：私有部署的全部显示，部署在我们的租赁服务器上的根据域名控制
            $where_sql .= ' or `name`=\'dingtalk_setting\' ';
        $where_sql .= ' or `name`=\'yunzhijia_setting\' ';
        //BUG0054219 （客户001账套和租赁账套）系统设置->接口设置，应该去掉“企业微信自建应用设置”参数
        if (get_class($regop)=='RegOp'||get_class($regop)=='Reg_autoInfo') {
            $where_sql .= ' or `name`=\'wxselfbuiltapp_setting\' ';
        }

        //frank XUQIU20240430-08 通话录音需要授权才可以使用
        /*
        $regOP=RegOp::getInstance();
        $call_record = $regOP->getCall_Record();
        if($call_record==1){
            $where_sql .= ' or `name`=\'CallRecordSetting\' ';
        }
        */

		//chj 2020/11/9 43181没有授权“渠道码”功能，系统设置->接口设置：应该不显示企业微信渠道码设置参数
		$regobj=RegOp::getInstance();
		$channelcode_status = $regobj->getchannelcodeprofile();
		if($channelcode_status == 1){
            crm_load_class_file("cls_WeiXinSelfBuiltApp", 'WeiXinApp/WeiXin_common');
            $wxselfbuilt_obj = new cls_WeiXinSelfBuiltApp();
            if ($wxselfbuilt_obj->installWXSelfBuilt) {//第三方应用使用渠道码不再需要去设置
                $where_sql .= ' or `name`=\'channelcode_settings\' ';
            }
		}
        //ls 2021-12-15 【1002160】企业微信通讯录及部门同步
        /*if (isKehu001ServerPc() == 'no') {
            $where_sql .= ' or `name`=\'addressbook_setting\' ';
        }*/
        if($regobj->getCall_Record()=='1')
        {
            $where_sql .= ' or `name`=\'CallRecordSetting\' ';
        }
        if($regobj->getMove_Trace()=='1')
        {
            $where_sql .= ' or `name`=\'TRACKPOSITONINGGROUP\' ';
        }
        else{

             $and_sql .= ' and `name`!=\'TRACKPOSITONINGGROUP\' ';
        }
        if($regobj->getPrmAuth()=='yes')
        {
            $where_sql .= ' or `name`=\'prm_web_customization\' ';
            $where_sql .= ' or `name`=\'prm_mobile_customization\' ';
        }
        if($regobj->getwechatprofile()=='1') {
            $where_sql .= ' or `name`=\'LBL_WECHATSESSION_SETTINGS\' ';
        }
        //zxm 20230426 接口设置-微信支付商户号设置
        $interface_name_arr = array('LBL_WECHATAPPLICATION','ExternalContactSetting','LBL_AUTHENINFO','CHECKINSETTING','ld_global_ui_setting',
            'SYSTEMCONFIGURATIONGUIDANCE','mobile_home_setting','report_menu_customization','LBL_RESTOREDATABASE','LBL_WORKFLOWCUSTOMIZATION_SET',
            'LBL_cooperative_REMIND_SET','LBL_SMS_VOICE_SETTINGS','watermark_setting','weixinpay_setting','OperationLogs','ImportExportLogs',
            'LBL_EXPRESS100_SETTINGS','LBL_PIAOZONE_SETTINGS','ButtonsCustomization','FeishuInterfaceSettings'
        );
        $interface_name_content = "'".implode("','",$interface_name_arr)."'";

    	$sql = "select * from ld_settings_field where blockid!=? and (active=0 ".$and_sql.")
         or `name` in ($interface_name_content) ".$where_sql." or `blockid` in (?,?,?)";


        $service_blockid = getSettingsBlockId('LBL_SERVICE_MINI_SETTINGS');
        $order_blockid = getSettingsBlockId('LBL_ORDER_MINI_SETTINGS');

        
    	/**
    	 * 基础版中不显示工作协同模板
    	 * @project 工作协同模板
    	 * @author Tujt 2015-05-06
    	 */
    	$versioninfo = getVersionTradeInfo();
    	if(2 == $versioninfo['versiontype']){
    		$sql .= ' and name != "LBL_WORK_TEMPLATE" ';
    	}

    	$sql .= ' order by blockid,sequence;';

        

    	$result = $adb->pquery($sql, array(
    	    getSettingsBlockId('LBL_MODULE_MANAGER'),
            getSettingsBlockId('LBI_MINI_SETTINGS'),
            $service_blockid,
            $order_blockid
            ));
    	$count = $adb->num_rows($result);
    	$fields = array();
        $servicehelp = 0;
        $orderhelp = 0;//0是没有 1是有
        $iskehu001=judgeCorpInfo("kehu001");
      // if($iskehu001==false){
        //edit:can 20200824 0042498: (https://61mis.com/KH/kh40115/ [^])客户问题（广东顺德德胜学校）已授权“服务小程序”权限，系统设置中没有显示“服务小程序设设置”
       
            $servicehelp=$regop->getservicehelp_interface();
            /* wym 230802 BUG0068433 成员管理查看详情界面，和右上角个人头像下拉选项中，去掉“订单小程序”操作按钮（包括后台设置和注册系统去掉“订单小程序”设置菜单栏和接口授权，“商城”在注册系统增加了另外的接口授权）
            if(method_exists($regop,'getorder_smallinterface')){
               $orderhelp=$regop->getorder_smallinterface();
            }*/
        // }
	 
        $cardinterface=$regop->GetCardInterfaceStatus();
        $bwb_interface=$regop->GetbwbInterfaceStatus();
        $business_interface=$regop->GetbusinessInterfaceStatus();
        $callcenter_interface=$regop->GetcallcenterInterfaceStatus();
		$crmversion=$regop->GetVersionNo();
		$focus = CRMEntity::getInstance('Users');
		
		$checkVersionIs001 = cls_StaticCommonFun::checkVersionIs001();
		
        if($iskehu001==false)
             $versionno=$crmversion;
		$autype=$focus->getAuthType();
        $regclassname=get_class($regop);//if(get_class($regop)!='Reg_weixinInfo')
    	if($count>0){
    		for($i=0;$i<$count;$i++){
    		    $fieldid = $adb->query_result($result, $i, "fieldid");
    			$blockid = $adb->query_result($result, $i, "blockid");
    			$iconpath = $adb->query_result($result, $i, "iconpath");
    			$description = $adb->query_result($result, $i, "description");
    			$linkto = $adb->query_result($result, $i, "linkto");
				  
    			$action = getPropertiesFromURL($linkto, "action");
    			$module = getPropertiesFromURL($linkto, "module");
    			$name = $adb->query_result($result, $i, "name");
                if($regclassname=='Reg_weixinInfo')
                {
                     if($name=='weixinpay_setting' || $name=='yunzhijia_setting'||$name=='dingtalk_webhook_setting')
                     {
                         continue;
                     }
                }
                //edti:can 20210506 045677: （https://61mis.com/WX/kh40903 [^]）客户问题（刘家云），系统设置->接口设置，去掉“钉钉群消息设置”参数
                if($name=='dingtalk_webhook_setting'&&!$installDing)
                    continue;
				if($name=='LBL_cooperative_REMIND_SET'&&!vtlib_isModuleActive('CooperativeWork'))
                {
                    //工作汇报提醒设置
                    continue;
                }
                //zxm BUG0075273 kfbcrm-后台设置-模板设置-首页数据看板定制-操作栏按钮点击没反应--之前写脚本将active=1 改完第二天又显示了
                if($name=='LBL_TEMPLATES')
                    continue;
                else if ($name == 'LBL_PIAOZONE_SETTINGS' &&!vtlib_isModuleActive('Expense')){
                    continue;
                }

                if($name=='ExternalContactSetting')
                {
                    //ls 2022-07-04 导入外部联系人考虑自建应用
                    crm_load_class_file("cls_WeiXinSelfBuiltApp", 'WeiXinApp/WeiXin_common');
                    $wxselfbuilt_obj = new cls_WeiXinSelfBuiltApp();
                    if (!$wxselfbuilt_obj->installWXSelfBuilt) {
                        if(!file_exists(globalStatic::$root_directory.'dataCache/weixin/auth_info.txt'))
                        {
                            continue;
                        }
                        $qywxht_interface=$regop->getqywxht_interface();
                        $tmparr=explode(",",$qywxht_interface);

                        if(!in_array('externalcontact',$tmparr))
                        {
                            continue;
                        }
                    }

                }
                if($iskehu001==false)
                {
                    
                    //35515:客户001、销售360账套去掉>系统设置>界面设置：“登录界面设置”应该去掉。
                //    if(in_array($versionno,array(6,42,43,44))&&($name=='LBL_AUTHENINFO' || $name=='LBL_LOGIN_SETTINGS'))
                   // {
                    //    continue;
                   // }
                }
                else
                {
                    //35516:客户001、销售360账套去掉>系统设置>其他设置：“授权信息”应该去掉。
                    if($name=='LBL_AUTHENINFO' ||$name=='LBL_RESTOREDATABASE')
                    {
                        continue;
                    }
                    if(isKehu001ServerPc()=='yes'&&$name=='LBL_LOGIN_SETTINGS')
                    {
                        continue;
                    }
                }
				
                if($datainterfacestate==0&&$name=='LBL_DATAINTERFACE_SETTING')
                {
                    continue;
                }
                if($servicehelp==0&&$blockid==$service_blockid)
                {
                    continue;
                }
                if($orderhelp==0&&$blockid==$order_blockid)
                {
                    continue;
                }
				//客户001 不显示文档模板定制、税率设定
				
				if($autype == 'yes'){
					if($action == 'showDocTemplateindex')
						continue;
				}
				
				if($checkVersionIs001 > 0 && $checkVersionIs001 == 55){	//(客户001标准版）系统设置>税率设定：模块去掉。
					if($action == 'TaxConfig')continue;
				}
				//企业微信
				if($action == 'Wechat'){
					if($checkVersionIs001 <= 0){	
						continue;
					}
				}
				
                //27738: 呼叫中心授权控制改进：未授权呼叫中心可以使用电话录音盒
                /*if($callcenter_interface==0 && $name=='LBL_PHONESTEWARD_SET')
                {
                    continue;
                }*/
                if($bwb_interface==0&& $name=='BANGWO8INTERFACE')
                {
                    continue;
                }
                if($cardinterface==0 && $name=='LBL_EXPANSION_CAMCARD')
                {
                    continue;
                }
				//自动任务设置
				if($name == 'LBL_AUTOMATIC_TASK'){
					continue;
				}
                //duan 20221230 隐藏源单分录定制
				if($name == 'LBL_Optionalmodule_Customization'){
					continue;
				}
                
    			$fields[$blockid][] = array("icon"=>$iconpath, "description"=>$description, "link"=>$linkto, "name"=>$name, "action"=>$action, "module"=>$module, "fieldid"=>$fieldid);
    		}
    
    		//add blanks for 4-column layout
    		foreach($fields as $blockid=>&$field){
    			if(count($field)>0 && count($field)<4){
    				for($i=count($field);$i<4;$i++){
    					$field[$i] = array();
    				}
    			}
    		}
    	}

    	return $fields;
    } 
}


?>