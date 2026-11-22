<?php

class cls_Home_SpecialMC
{
//edit:gyq_38 data:20170711 reason:移动端主页合并
    public static function getHomeModule()
    {
        //gyq_36 APP模块灵活设置
        global $adb, $current_user, $PlatformMC,$MobileLanguageType;
        $corpurl_all = getCorpUrl();
        crm_load_class_file("cls_LinkModuleCustom", 'include/utils');
        $transferArr = array('app' => 'mobile', 'weixin' => 'weixin');
        $formtype = $PlatformMC['type'];

        $usermoduleset = ' AND not exists(select setname from ld_appuiset where userid=' . $current_user->id . ' and ld_appuiset.setname=ld_tab.name and ld_appuiset.settype=\'module\' and ld_appuiset.apptype=\'' . $formtype . '\') ';
        if ($formtype == 'weixin' && ($_REQUEST['method'] == 'getCRMModules' || $_REQUEST['method'] == 'ChangeLanguageType')) {
            $spemodule = getWxSpecialModule();
        } else {
            $spemodule = array(-8 => array('module' => 'NearbyAccounts', 'tabname' => getFixedLabel('NearbyAccounts')));
        }
        $profile = new Profile();
        $reports = $profile->getMobileReportNames();
        $SQL = self::getWxModuleSql($spemodule, $usermoduleset, $formtype, $transferArr);
        $result = $adb->pquery($SQL, array());
        $nums = $adb->num_rows($result);
        $availabletables = array();
        $origntables = array();
        //edit: xll 2023/02/08 XUQIU1000984 移动端图标增加显示简易风格
        $deployarr_13 = getAppsys_deploy(13);
        $is_open13 = ($deployarr_13 != '') ? $deployarr_13['is_open'] : 'no';
        $active_icon_head = ($is_open13 == 'yes') ? 'themes/icon2022/crm2/' : 'themes/icon2022/crm/';
        if (!is_admin($current_user)) {
            $groupsql = "select GROUP_CONCAT(groupid) from ld_users2group where userid=?";
            $group_result = $adb->pquery($groupsql, array($current_user->id));
            if ($adb->num_rows($group_result) > 0)
                $curuser_groupids = explode(",", $adb->query_result($group_result, 0, 0));

        }
        if ($nums > 0) {
            $regop=RegOp::getInstance();
             crm_load_class_file('AuthApi','Register');
            $authapiobj=new AuthApi();
            $j = 0;
            $socialpromotion=0;
            $articlesprofile=0;
            $channelcodeprofile=0;
            
            if(method_exists($regop,'getSocialPromotion'))
                $socialpromotion=$regop->getSocialPromotion();
            if(method_exists($regop,'getarticlesprofile'))
                $articlesprofile=$regop->getarticlesprofile();
             if(method_exists($regop,'getchannelcodeprofile'))
                $channelcodeprofile=$regop->getarticlesprofile();
            for ($i = 0; $i < $nums; $i++) {
                $tabid = $adb->query_result($result, $i, 'tabid');
                $blockid = 'blockid' . $adb->query_result($result, $i, 'blockid');
                if($MobileLanguageType == 'en'){
                    $blockname = $adb->query_result($result, $i, 'enblockname');
                }else{
                    $blockname = $adb->query_result($result, $i, 'blockname');
                }
                $menudescription = $adb->query_result($result, $i, 'menudescription');
                $module = $adb->query_result($result, $i, 'name');
                if($module=='SocialPromotion'&&empty($socialpromotion))
                {
                    continue;
                }
                if($module=='Articles'&&empty($articlesprofile))
                {
                    continue;
                }
                if($module=='ChannelCode'&&empty($channelcodeprofile))
                {
                    continue;
                }
                if($module=='TrackLocationMap'){
                    global $weixin_user;
                    if($weixin_user->environment != 'app'){
                        continue;
                    }
                }
                $title = $adb->query_result($result, $i, 'fieldlabel');
                $parenttab_label = $adb->query_result($result, $i, 'parenttab_label');
                $allocatetype = strtolower($adb->query_result($result, $i, 'allocatetype'));
                $tab_tablename = $adb->query_result($result, $i, 'tab_tablename');
                $checkphp = $adb->query_result($result, $i, 'checkphp');
                $default_icon = $adb->query_result($result, $i, 'default_icon');
                $active_icon = $adb->query_result($result, $i, 'active_icon');
                //editor:gyq_20190911 reason:移动端菜单定制配合修改
                $allocateid=$adb->query_result($result, $i, 'allocateid');
                $allocateids=[];
                if(!empty($allocateid))
                     $allocateids = explode(",", $adb->query_result($result, $i, 'allocateid'));
                //editor:gyq_159 reason:系统设置增加移动端报表菜单定制  2019/11/8 14:02 ID1000638
                if (is_admin($current_user)) {
                    $allocatetype = 'all';
                }
                if ($allocatetype == 'user') {
                    if (!in_array($current_user->id, $allocateids)) {
                        continue;
                    }
                } else if ($allocatetype == 'group') {
                    $tmpgroup = 'no';

                    foreach ($curuser_groupids as $curuser_groupid) {
                        if (in_array($curuser_groupid, $allocateids)) {
                            $tmpgroup = 'yes';
                            break;
                        }
                    }
                    if ($tmpgroup == 'no') {
                        continue;
                    }
                }else if($allocatetype == 'role'){//按角色控制
					if (!in_array($current_user->profileid, $allocateids)) {
                        continue;
                    }
				}
                //$_REQUEST['mode']=='quick':表示快速创建
                if ($parenttab_label == 'Reports') {
                    if ($_REQUEST['mode'] == 'quick') {
                        continue;
                    }
                    $relatename = (string)$adb->query_result($result, $i, 'relatename');
                    $report_icon = self::getWXReportListImage($relatename, 'ld_tab');
                    if ($tab_tablename == 'ld_tab') {
                        foreach ($reports as $index => $reportinfo) {
                            //云星空报表查询
                            if(strtolower($relatename) == 'search_erp_stcok'){
                                $stock_view = getErpStockView();
                                if(strpos(strtolower($stock_view),'erp') == false){
                                    continue;
                                }
                            }
                            if ($reportinfo['name'] == strtolower($relatename) && isPermitted("MobileReport", $relatename) == 'yes') {
                                $availabletables[$blockid]['list'][$j] = array('module' => strtolower($relatename), 'title' => $reportinfo['fieldlabel'], 'tabid' => $tabid, 'tab_tablename' => $tab_tablename, 'display'=>'yes','checkphp'=>$checkphp,'report_icon'=>$report_icon, 'commonlyused'=>'no','linkid'=>'');


                                break;
                            }
                        }
                    } else {
                        $tmplinkinfo = self::getLinkModule($tabid);
                        $linkid = $tmplinkinfo['id'];
                        if (!$tmplinkinfo) {
                            continue;
                        }
                        //项目甘特图
                        if(strpos($tmplinkinfo['url'],'gantindex.php')!==false){
                            //edit: xll 2023/02/08 XUQIU1000984 移动端图标增加显示简易风格
                            $report_icon_head = (($is_open13 == 'yes') ? 'report2022_2/' : 'report2022/');
                            $report_icon = $report_icon_head.'report_16.png';
                        }

                        if($tmplinkinfo['linkmodule']=="CustomEcharts"||$tmplinkinfo['linkmodule']=="CustomTables"||strpos($tmplinkinfo['url'],'YashaRoomShow')>0){
                            //zxm 20221107 自定义统计图统计表 移动端显示
                            //$corpurl_all = $_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['HTTP_HOST']. $_SERVER['PHP_SELF'];
                            $tmplinkinfo['url'] = str_replace('index.php','',$tmplinkinfo['url']);
                            $tmplinkinfo['url'] = getCorpUrl().$tmplinkinfo['url'];
                            
                            
                            global $PlatformMC;
                            if(is_array($PlatformMC)&&array_key_exists('isnativeapp',$PlatformMC)&&$PlatformMC['isnativeapp']=='yes')
                            {
                                $encryptobj=new cls_MyCRMcrypt();
                            
                                $tmplinkinfo['url'] .= '&frommobile=yes&userid='.$encryptobj->encode($_REQUEST['userid']);
                                $tmplinkinfo['url'] .="&appusertoken=".$_REQUEST['appusertoken'];
                                
                            }
                            else{
                                $tmplinkinfo['url'] .= '&frommobile=yes&userid='.$_REQUEST['userid'];
                            }
                            $tmplinkinfo['url'] .= '&customreport_chuantou=1';
                            $tmplinkinfo['url'] = htmlspecialchars_decode($tmplinkinfo['url']);
                            $cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
                            $tmplinkinfo['url'] = $cls_UrlEncryptyJudgeobj->EncryptyBynosorturlparseQueryParams($tmplinkinfo['url']);

                            $tab_tablename = 'ld_linkmodulecustom';
                        }
                        if($MobileLanguageType == 'en'){
                            $title = $tmplinkinfo['en_label'];
                        }else{
                            $title = $tmplinkinfo['zh_label'];
                        }
                        $availabletables[$blockid]['list'][$j] = array('module' => $tmplinkinfo['url'], 'title' =>$title , 'tabid' => $tabid, 'tab_tablename' => $tab_tablename, 'display'=>'yes','checkphp'=>$checkphp,'report_icon'=>$report_icon, 'commonlyused'=>'no','linkid'=>$linkid);
                    }
                    $availabletables[$blockid]['blockname'] = $current_user->user_type=='prm'?'':$blockname;
                    $availabletables[$blockid]['menudescription'] = $menudescription;
                }
                else {
                    if ($tab_tablename == 'ld_tab' && ($tabid < -1 || isPermitted($module, 'index') == 'yes')) {
                        //BUG0069915 企业微信移动端，成员没有产品模块查看权限时，应该不显示订货商城模块 hzx
                        if($module == 'Shopping' && isPermitted('ShoppingMall', 'index') != 'yes'){
                            continue;
                        }
                        //$default_icon
                        //$active_icon zxm 2021-1208 模块图标
                        if(empty($active_icon)||!file_exists(globalStatic::$root_directory.$active_icon)){
                            if(empty($default_icon)||!file_exists(globalStatic::$root_directory.$default_icon)){
                                if(empty($module)||!file_exists(globalStatic::$root_directory.$active_icon_head.'crm_'.$module.'.png')){
                                    if(get_file_address($module,'ProductDetails')||get_file_address($module,$module."DetailFieldsHtml")){
                                        $active_icon = $active_icon_head.'crm_CustomForm.png';
                                    }
                                    else{
                                        $active_icon = $active_icon_head.'crm_CustomForm1.png';
                                    }
                                }else{
                                    $active_icon = $active_icon_head.'crm_'.$module.'.png';
                                }
                            }else{
                                $active_icon = $default_icon;
                            }
                        }
                        //editor:gyq_20191119
                        //0038618: （企业微信、微信小程序）>灵当CRM>功能界面：右下角快速创建中缺少了客户模块。
                        //zxm 2021-0601 公海销售线索模块$module == 'Accounts' ||$module == 'Leads'
                        if ($module == 'Accounts' ||$module == 'Leads') {
                            $availabletables[$blockid]['list'][$j] = array('module' => $module, 'title' => $title, 'tabid' => $tabid, 'tab_tablename' => $tab_tablename, 'display'=>'yes','checkphp'=>$checkphp,'linkcvid'=>'', 'commonlyused'=>'no','linkid'=>'');
                            if($tabid >0){
                                $availabletables[$blockid]['list'][$j]['active_icon']=$active_icon;
                            }
                            //微信端公海客户开启，公海成员显示公海客户模块 data:20180302 xxs
                            //$status = getAccount_Set('status');
							crm_load_class_file('cls_Public'.$module, 'modules/'.$module);
							$objModuleName = 'cls_Public'.$module;
                            $cls_Public = new $objModuleName($module);
							$public_account = $cls_Public->getPublicAccountConfig();
							if($public_account['status'] == 'yes' && $formtype == 'weixin'){
								$publicaccount_display = 'no';
								foreach($public_account['public_account_pool'] as $pool_info){
									if (in_array($current_user->id, explode(",", $pool_info['administrators'])) || in_array($current_user->id, explode(',', $pool_info['userids'])) || $pool_info['usertype'] == 'all') {
										$publicaccount_display = 'yes';
										break;
									}
								}
								if($publicaccount_display == 'yes'){
								    if($MobileLanguageType == 'en'){
								        $title = getFixedLabel('HIGHSEAS').' '.getTranstab($module);
								    }else{
								        $title = getFixedLabel('HIGHSEAS').getTranstab($module);
								    }
									$availabletables[$blockid]['list'][++$j] = array('module' => 'Public'.$module, 'title' => $title, 'tabid' => $tabid, 'tab_tablename' => $tab_tablename, 'display'=>'yes','checkphp'=>$checkphp,'linkcvid'=>'', 'commonlyused'=>'no','linkid'=>'');
								}
							}
							/*if (!getAccount_Set('status') && $formtype == 'weixin') {
                                $adminaccount = getAccount_Set("adminaccount");
                                $usersaccount = getAccount_Set('usersaccount');
                                if ($current_user->is_admin == "on" || in_array($current_user->id, explode(",", $adminaccount)) || in_array($current_user->id, explode(',', $usersaccount))) {
                                    $availabletables[$blockid]['list'][++$j] = array('module' => 'PublicAccounts', 'title' => '公海客户', 'tabid' => $tabid, 'tab_tablename' => $tab_tablename);
                                }
                            }*/
                        } else {
                            $availabletables[$blockid]['list'][$j] = array('module' => $module, 'title' => $title, 'tabid' => $tabid, 'tab_tablename' => $tab_tablename, 'display'=>'yes','checkphp'=>$checkphp,'linkcvid'=>'', 'commonlyused'=>'no','linkid'=>'');
                            if($tabid >0){
                                $availabletables[$blockid]['list'][$j]['active_icon']=$active_icon;
                                //zxm @date:2024/11/5 @reason: XUQIU20241029-07 模块图标没有替换，使用CND链接
                                $cdnimageurl = getGlobalImageUrl();
                                if(!empty($cdnimageurl)){
                                    $availabletables[$blockid]['list'][$j]['active_icon_cdn']=$cdnimageurl.$active_icon;
                                }
                            }
                        }
                        $availabletables[$blockid]['blockname'] = $current_user->user_type=='prm'?'':$blockname;
                        $availabletables[$blockid]['menudescription'] = $menudescription;
                    }
                    else if ($tab_tablename == 'ld_linkmodulecustom'||$module=="CustomEcharts"||$module=="CustomTables"|| (is_string($tmplinkinfo['url']) && strpos($tmplinkinfo['url'],'YashaRoomShow')>0)) {
                        //链接模块定制
                        if(empty($active_icon)||!file_exists(globalStatic::$root_directory.$active_icon)){
                            $active_icon = $active_icon_head.'crm_Links.png';
                        }
                        $tmplinkinfo = self::getLinkModule($tabid);

                        if (!$tmplinkinfo) {
                            continue;
                        }
                        $linkid=$tmplinkinfo['id'];
                        $authcheck=$tmplinkinfo['authcheck'];
                        $paramvalue=$tmplinkinfo['paramvalue'];
                        $linkcvid = $tmplinkinfo['linkcvid'];
                        $crmreporturl = '';
                        if(is_array($tmplinkinfo)&&(strstr($tmplinkinfo['url'],'/CustomReport/JsReport/index.php?crm_report_key')== false&&$tmplinkinfo['entitytype']=='custom')&&strpos($tmplinkinfo['url'],'YashaRoomShow')<0)
                         {
                            //非crm报表url增加传输参数
                            $db = PearDatabase::getInstance();
                            $scopeobj = new ScopOfAuthority($db,'Home');
                            if($scopeobj->modulescolist['Home']['scopeauthority']=='1'){
                                $uuid_range = 'all';
                            }
                            else{
                                $uuid_range = $scopeobj->getCurUserScopeId();
                            }
                            $cur_range = $uuid_range;
                            $crmreporturl = '&crmreportuuid='.$current_user->id.'&crmreportuuid_range='.$uuid_range.'&crmreportcur_range='.$cur_range.'&crmreportcur_period=thismonth';
                            if(strstr($tmplinkinfo['url'],'?')!= false)
    						{
    							$tmplinkinfo['url'] .='&'.$crmreporturl;
    						}
    						else
    						{
    							$tmplinkinfo['url'] .='?'.$crmreporturl;
    						}
                             $corpurl_all_customreort_arr = explode('WeiXinApp',$corpurl_all);
                             $tmplinkinfo['url'] = $corpurl_all_customreort_arr[0].$tmplinkinfo['url'];

                         }

                        if($module=="CustomEcharts"||$module=="CustomTables"||strpos($tmplinkinfo['url'],'YashaRoomShow')>0){
                            //zxm 20221107 自定义统计图统计表 移动端显示
                            //$corpurl_all = $_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['HTTP_HOST']. $_SERVER['PHP_SELF'];
                            $tmplinkinfo['url'] = str_replace('index.php','',$tmplinkinfo['url']);
                            $tmplinkinfo['url'] = $corpurl_all.$tmplinkinfo['url'];
                            
                            global $PlatformMC;
                            if(is_array($PlatformMC)&&array_key_exists('isnativeapp',$PlatformMC)&&$PlatformMC['isnativeapp']=='yes')
                            {
                                $encryptobj=new cls_MyCRMcrypt();
                                $tmplinkinfo['url'] .= '&frommobile=yes&userid='.$encryptobj->encode($_REQUEST['userid'])."&appusertoken=".$_REQUEST['appusertoken'] ;
                            }
                            else{
                                
                                $tmplinkinfo['url'] .= '&frommobile=yes&userid='.$_REQUEST['userid'];
                            }
                            $tmplinkinfo['url'] .= '&customreport_chuantou=1';
                            $cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
                            $tmplinkinfo['url'] = $cls_UrlEncryptyJudgeobj->EncryptyBynosorturlparseQueryParams($tmplinkinfo['url']);

                            $tab_tablename = 'ld_linkmodulecustom';
                        }
                        if(strstr($tmplinkinfo['url'],'?')!= false)
                        {
                            
                        }
                        else{
                            $tmplinkinfo['url'].="?crm=yes";
                            
                        }
                        if($authcheck=='yes')
                        {
                            $tmptoken= $authapiobj->encode(array('paramvaule'=>json_decode(html_entity_decode($paramvalue),true)));
                            $tmplinkinfo['url'].='&crm_access_token='.$tmptoken;
                        }
                        //项目甘特图做特殊控制
                        $module = $tmplinkinfo['url'];
                        if(strpos($module,'gantindex.php')!==false){
                            //edit: xll 2023/02/08 XUQIU1000984 移动端图标增加显示简易风格
                            $report_icon16_head = (($is_open13 == 'yes') ? 'themes/icon2022/report2/' : 'themes/icon2022/report/');
                            $active_icon = $report_icon16_head.'report_16.png';
                        }
                        if($MobileLanguageType == 'en'){
                            $title = $tmplinkinfo['en_label'];
                        }else{
                            $title = $tmplinkinfo['zh_label'];
                        }
                        $availabletables[$blockid]['list'][$j] = array('module' => $tmplinkinfo['url'], 'title' => $title, 'tabid' => $tabid, 'tab_tablename' => $tab_tablename, 'display'=>'yes','checkphp'=>$checkphp,'linkcvid'=>$linkcvid, 'commonlyused'=>'no','linkid'=>$linkid);
                        $availabletables[$blockid]['blockname'] = $current_user->user_type=='prm'?'':$blockname;
                        $availabletables[$blockid]['menudescription'] = $menudescription;
                        $availabletables[$blockid]['list'][$j]['active_icon']=$active_icon;
                        //zxm @date:2024/11/5 @reason: XUQIU20241029-07 模块图标没有替换，使用CND链接
                        $cdnimageurl = getGlobalImageUrl();
                        if(!empty($cdnimageurl)){
                            $availabletables[$blockid]['list'][$j]['active_icon_cdn']=$cdnimageurl.$active_icon;
                        }
                        // @edit:dong @date:2020/12/07 @reason: 数据分类设置为自定义链接模块
                    }
                    else if($tab_tablename == 'ld_linkmodulecustom_category'){
                        //链接模块定制
                        $tmplinkinfo = self::getLinkModule($tabid);
                        if(empty($active_icon)||!file_exists(globalStatic::$root_directory.$active_icon)){
                            $active_icon = $active_icon_head.'crm_Links.png';
                        }

                        $linkid = $tmplinkinfo['id'];
                        $linkcvid = $tmplinkinfo['linkcvid'];
                        if (!$tmplinkinfo) {
                            continue;
                        }
                        if($MobileLanguageType == 'en'){
                            $title = $tmplinkinfo['en_label'];
                        }else{
                            $title = $tmplinkinfo['zh_label'];
                        }
                        // @edit:dong @date:2020/12/07 @reason: tabid 是视图id
                        $availabletables[$blockid]['list'][$j] = array('module' => $module, 'title' => $title, 'tabid' => $tmplinkinfo['linkcvid'], 'tab_tablename' => $tab_tablename, 'display'=>'yes','checkphp'=>$checkphp,'linkcvid'=>$linkcvid, 'commonlyused'=>'no','linkid'=>$linkid);
                        $availabletables[$blockid]['blockname'] = $current_user->user_type=='prm'?'':$blockname;
                        $availabletables[$blockid]['menudescription'] = $menudescription;
                        $availabletables[$blockid]['list'][$j]['active_icon']=$active_icon;
                    }
                }
                $j++;
            }
        }
        
        $op = 0;
        //通用设置 是否显示扫一扫和全局查找区块
        $sql_8 = 'select userid,is_open from ld_appsystem where userid= ? and deploy_type=8 and is_open="yes"';
        $result_8 = $adb->pquery($sql_8,array($current_user->id));
        $is_open8 = $adb->num_rows($result_8)>0?'yes':'no';
        $sql_9 = 'select userid,is_open from ld_appsystem where userid= ? and deploy_type=9 and is_open="yes"';
        $result_9 = $adb->pquery($sql_9,array($current_user->id));
        $is_open9 = $adb->num_rows($result_9)>0?'yes':'no';
        if($is_open8=='yes' || $is_open9=='yes'){
            $tools = [];
            if($is_open8=='yes'){
               $tools[] = array('module' => 'GlobalSearch', 'title' => getFixedLabel('QUICKFIND'), 'tabid' => 't_1', 'tab_tablename' => 'ld_tools', 'display'=>'yes', 'commonlyused'=>'no');
            }
            if($is_open9=='yes'){
               $tools[] = array('module' => 'GlobalScan', 'title' => getFixedLabel('SCAN'), 'tabid' => 't_2', 'tab_tablename' => 'ld_tools', 'display'=>'yes', 'commonlyused'=>'no');
            }
            $availabletables_new[$op]['list'] = $tools;
            $availabletables_new[$op]['blockname'] = getFixedLabel('COMMONTOOLS');
            $availabletables_new[$op]['display'] = 'yes';
            $op++;
        }
        foreach ($availabletables as $key => $val) {
            //editor:gyq_20191024 reason:过滤空内容区块
            if (isset($val['list'])) {
                $availabletables_new[$op]['list'] = array_values($val['list']);
                $availabletables_new[$op]['blockname'] = $current_user->user_type=='prm'?'':$val['blockname'];
                $availabletables_new[$op]['menudescription'] = $val['menudescription'];
                $availabletables_new[$op]['display'] = 'yes';
                $op++;
            }
        }
        return $availabletables_new;
    }

    //链接模块定制
    protected static function getLinkModule($tabid)
    {
        global $current_user,$adb;
        require_once globalStatic::$root_directory . 'include/utils/cls_LinkModuleCustom.php';
        $tmplinkinfo = cls_LinkModuleCustom::getLinkModuleCustomInfoById($tabid);
        $scope = $tmplinkinfo['scope'];
        if (!is_admin($current_user)) {
            if ($scope == 'user') {
                $tmpsql = 'select 1 from  ld_linkmodulecustom2user where linkmodulecustomid=? and userid=?';
                $tmpresult = $adb->pquery($tmpsql, array($tabid, $current_user->id));
                if ($adb->num_rows($tmpresult) <= 0) {
                    return false;
                }
            }else if ($scope == 'role') {
                $tmpsql = 'select 1 from  ld_linkmodulecustom2user where linkmodulecustomid=? and userid=?';
                $tmpresult = $adb->pquery($tmpsql, array($tabid, $current_user->profileid));
                if ($adb->num_rows($tmpresult) <= 0) {
                    return false;
                }
            } else if ($scope == 'group') {
                $tmpsql = 'select 1 from ld_linkmodulecustom2user 
                                     inner join ld_users2group on ld_linkmodulecustom2user.userid=ld_users2group.groupid
                                    where linkmodulecustomid=? and ld_users2group.userid=? ';
                $tmp_result = $adb->pquery($tmpsql, array($tabid, $current_user->id));
                if ($adb->num_rows($tmp_result) <= 0) {
                    return false;
                }
            }
        }
        global $PlatformMC;
       
        if(is_array($PlatformMC)&&array_key_exists('isnativeapp',$PlatformMC)&&$PlatformMC['isnativeapp']=='yes')
        {
            
            $encryptobj=new cls_MyCRMcrypt();
            foreach($tmplinkinfo  as &$tmpurlinfo)
            {
                 $tmpurlinfo['url']=$tmpurlinfo['url']."&userid=".$encryptobj->encode($_REQUEST['userid']).'&appusertoken='.$_REQUEST['appusertoken'];
                 
                
            }
        }
        return $tmplinkinfo;
    }

    public static function getWxModuleSql($spemodule, $usermoduleset, $formtype, $transferArr)
    {
        global $current_user,$MobileLanguageType;
        $spe_sql = '';
        $type = $transferArr[$formtype];
        $userid  = $current_user->id;
        $user_type = $current_user->user_type;
        foreach ($spemodule as $tabid => $moduleinfo) {
            $module = $moduleinfo['module'];
            $tabname = $moduleinfo['tabname'];
            $spe_sql .= " UNION
            	SELECT
        		TAB.sequence AS tabsequence,
        		REL.blockid,
        		REL.tabid,
        		'$module',
        		'$tabname',
        		'' as default_icon,
        		'' as active_icon,
        		TAB.blockname,
        		TAB.menudescription,
                TAB.enblockname,
                TAB.parenttab_label,
        		REL.sequence AS relsequence,
                REL.relatename,
                TAB.allocatetype,
                TAB.allocateid,
                REL.tab_tablename,
                IFNULL(REL.checkphp,'') AS checkphp
        	FROM
        		ld_appparenttabrel REL
        	LEFT JOIN ld_appparenttab TAB ON REL.blockid = TAB.blockid
        	WHERE
        		REL.tabid = $tabid
        	AND TAB.presence = 0 and TAB.menu_user_type = '$user_type'
            AND NOT EXISTS (
				SELECT
					setname
				FROM
					ld_appuiset
				WHERE
					userid = $userid
				AND ld_appuiset.setname = '$module'
                AND ld_appuiset.settype = 'module'
                AND ld_appuiset.apptype = '$formtype'
			)";
        }
        //editor:gyq_157 reason:企业微信模块显示设置增加自定义表单\链接模块\报表  2019/11/5 17:25
        //editor:gyq_20191129 reason:ifnull( TAB.parenttab_label,'') 0038684: 微信端，移动端增加区块，注意是增加区块，然后选择链接模块，在移动端不显示。
        // @edit:dong @date:2020/12/07 @reason:  数据分类自定义链接模块 参数修改 ld_linkmodulecustom.linkmodule as  NAME,if(ld_linkmodulecustom.entitytype
        $sql = 'select * from(
        			SELECT
        				TAB.sequence AS tabsequence,
        				REL.blockid,
        				REL.tabid,
        		      	"" as NAME,
		              	"" as fieldlabel,
		              	"" as default_icon,
        		        "" as active_icon,
        				TAB.blockname,
        				TAB.menudescription,
                        TAB.enblockname,
        				TAB.parenttab_label,
        				REL.sequence AS relsequence,
        				REL.relatename,
                        TAB.allocatetype,
                        TAB.allocateid,
                        REL.tab_tablename,
                        IFNULL(REL.checkphp,"") AS checkphp
        			FROM
        				ld_appparenttabrel REL
        			LEFT JOIN ld_appparenttab TAB ON REL.blockid = TAB.blockid
        			WHERE
        				TAB.parenttab_label ="reports" 
        			AND TAB.presence = 0 and TAB.menu_user_type = "'.$user_type.'"
        			and  not exists(select 1 from ld_appuiset
                  where userid=' . $userid . ' and setname=REL.tabid and  ld_appuiset.tab_tablename=\'ld_tab\'and apptype=\'weixin\' ) 
                  and not exists(select 1 from ld_appuiset where userid=' . $userid . ' and setname=REL.tabid 
                  and ld_appuiset.tab_tablename=\'ld_linkmodulecustom\' and apptype=\'weixin\' )
                    union 
                    SELECT
                	TAB.sequence as tabsequence,
                	REL.blockid,
                	REL.tabid,
                	ld_linkmodulecustom.linkmodule as  NAME,
                	zh_label as fieldlabel,
                	"" as default_icon,
                    ld_linkmodulecustom.active_icon as active_icon,
                	TAB.blockname,
                	TAB.menudescription,
                    TAB.enblockname,
                    TAB.parenttab_label,
                	REL.sequence as relsequence,
                    REL.relatename,
                    TAB.allocatetype,
                    TAB.allocateid,
                    if(ld_linkmodulecustom.entitytype=\'category\',concat(REL.tab_tablename,\'_\',ld_linkmodulecustom.entitytype),REL.tab_tablename)as tab_tablename,
                    if(REL.tab_tablename=\'ld_linkmodulecustom\',IFNULL(REL.checkphp,""),"")as checkphp
                FROM
                	ld_appparenttabrel REL
                LEFT JOIN ld_appparenttab TAB ON REL.blockid = TAB.blockid
                INNER JOIN ld_linkmodulecustom on ld_linkmodulecustom.id=REL.tabid
                where  REL.tab_tablename="ld_linkmodulecustom" and ifnull( TAB.parenttab_label,\'\')  <>"reports" 
                 AND TAB.presence = 0 and TAB.menu_user_type = "'.$user_type.'"
                 and not exists(select 1 from ld_appuiset
                  where userid=' . $userid . ' and setname=REL.tabid and  
                  ld_appuiset.tab_tablename=\'ld_linkmodulecustom\'and apptype=\'weixin\' )
                    union
                    SELECT
                	TAB.sequence as tabsequence,
                	REL.blockid,
                	REL.tabid,
                	ld_tab. NAME,
                	ld_tranlabel.fieldlabel,
                	ld_tab.default_icon as default_icon,
                    ld_tab.active_icon as active_icon,
                	TAB.blockname,
                	TAB.menudescription,
                    TAB.enblockname,
                    TAB.parenttab_label,
                	REL.sequence as relsequence,
                    REL.relatename,
                    TAB.allocatetype,
                    TAB.allocateid,
                    REL.tab_tablename,
                    IFNULL(REL.checkphp,"") AS checkphp
                FROM
                	ld_appparenttabrel REL
                LEFT JOIN ld_appparenttab TAB ON REL.blockid = TAB.blockid
                INNER JOIN ld_tab ON REL.tabid = ld_tab.tabid and REL.tab_tablename="ld_tab"
                INNER JOIN ld_tranlabel ON ld_tranlabel.tabid = ld_tab.tabid
                
                WHERE
                	TAB.presence = 0   AND ld_tab.mobilepresence LIKE \'%' . $type . '%\' and TAB.menu_user_type = "'.$user_type.'"
                AND ld_tab.presence = 0
                AND ld_tranlabel.trantable = \'ld_tab\'
                AND ld_tranlabel.languagetype = \''.$MobileLanguageType.'\'
                and (REL.relatename is null or REL.relatename="")
                ' . $usermoduleset . '
                ' . $spe_sql . '
                ) a 
                		ORDER BY
                		tabsequence ASC,
                		relsequence ASC';
        return $sql;
    }
    
    //暂时先不将微信和APP获取所有模块的方法合并，故新增此方法 xxs 2017-08-28
    public static function getWXModulesForMe()
    {
        global $adb, $current_user,$MobileLanguageType;
        $userid = $current_user->id;
        $fromtype = 'weixin';
        $spe_sql = '';
        $spemodule = getWxSpecialModule();
        foreach ($spemodule as $tabid => $moduleinfo) {
            //特殊模块
            $spe_sql .= " UNION 
                    SELECT
                    TAB.sequence,
                    	REL.blockid,
                    	REL.tabid,
                    	'" . $moduleinfo['module'] . "',
                    	'SpecialTab',
                    	'' as default_icon,
		              	'' as active_icon,
                    	TAB.blockname,
                        TAB.enblockname,
                    	TAB.parenttab_label,
                    	REL.sequence,
                    	 REL.relatename,
                    REL.tab_tablename,
                    	IF(exists(select 1 from ld_appuiset where userid='$userid' and setname='" . $moduleinfo['module'] . "' and settype='module' and apptype='weixin'),'','1') display
                    FROM
                    	ld_appparenttabrel REL
                    LEFT JOIN ld_appparenttab TAB ON REL.blockid = TAB.blockid
                    WHERE
                    	TAB.presence = 0 and TAB.menu_user_type='".$current_user->user_type."' and REL.tabid=$tabid";
        }
        //常规模块
        $sqlNormalTab = 'SELECT TAB.sequence tabsequence,REL.blockid,REL.tabid,ld_tab.name,ld_tranlabel.fieldlabel,ld_tab.default_icon,ld_tab.active_icon,
                TAB.blockname,TAB.enblockname,TAB.parenttab_label,REL.sequence relsequence,REL.relatename,REL.tab_tablename,
       	        IF(exists(select 1 from ld_appuiset where userid=' . $userid . ' and setname=ld_tab.`name` and settype=\'module\' 
       	        and apptype=\'weixin\' ),\'\',\'1\') display
                from ld_appparenttabrel REL
				  LEFT JOIN ld_appparenttab TAB on REL.blockid=TAB.blockid
				  INNER JOIN ld_tab on REL.tabid = ld_tab.tabid and REL.tab_tablename="ld_tab"
				  INNER JOIN ld_tranlabel on ld_tranlabel.tabid=ld_tab.tabid
				WHERE TAB.presence=0 and TAB.menu_user_type="'.$current_user->user_type.'" AND ld_tab.mobilepresence like \'%' . $fromtype . '%\' and ld_tab.presence = 0
					  AND ld_tranlabel.trantable=\'ld_tab\' AND ld_tranlabel.languagetype=\''.$MobileLanguageType.'\'
					  and (REL.relatename is null or REL.relatename="")';
        //报表区块reports:移动端报表和链接模块
        //非报表区块:链接模块
        $SQL = 'select * from(
        			SELECT
        				TAB.sequence AS tabsequence,
        				REL.blockid,
        				REL.tabid,
        		      	"" as NAME,
		              	"" as fieldlabel,
		              	"" as default_icon,
		              	"" as active_icon,
        				TAB.blockname,
                        TAB.enblockname,
        				TAB.parenttab_label,
        				REL.sequence AS relsequence,
        				REL.relatename,
                        REL.tab_tablename,
                      IF(exists(select 1 from ld_appuiset
                  where userid=' . $userid . ' and setname=REL.tabid and  ld_appuiset.tab_tablename=\'ld_tab\'and apptype=\'weixin\' ) or
                     exists(select 1 from ld_appuiset where userid=' . $userid . ' and setname=REL.tabid and ld_appuiset.tab_tablename=\'ld_linkmodulecustom\'
                and apptype=\'weixin\' ),\'\',\'1\') display
        			FROM
        				ld_appparenttabrel REL
        			LEFT JOIN ld_appparenttab TAB ON REL.blockid = TAB.blockid
        			WHERE
        				TAB.parenttab_label ="reports"  and TAB.menu_user_type="'.$current_user->user_type.'"
        			AND TAB.presence = 0
                    union 
                    SELECT
                	TAB.sequence as tabsequence,
                	REL.blockid,
                	REL.tabid,
                	"" as  NAME,
                	zh_label as fieldlabel,
                	"" as default_icon,
                    ld_linkmodulecustom.active_icon as active_icon,
                	TAB.blockname,
                    TAB.enblockname,
                    TAB.parenttab_label,
                	REL.sequence as relsequence,
                    REL.relatename,
                    REL.tab_tablename,
                    IF(exists(select 1 from ld_appuiset
                  where userid=' . $userid . ' and setname=REL.tabid and  ld_appuiset.tab_tablename=\'ld_linkmodulecustom\'and apptype=\'weixin\' ),\'\',\'1\') display
                FROM
                	ld_appparenttabrel REL
                LEFT JOIN ld_appparenttab TAB ON REL.blockid = TAB.blockid
                INNER JOIN ld_linkmodulecustom on ld_linkmodulecustom.id=REL.tabid
                and REL.tab_tablename="ld_linkmodulecustom" and TAB.parenttab_label <>"reports" and TAB.menu_user_type="'.$current_user->user_type.'"
                union
                ' . $sqlNormalTab . '
                ' . $spe_sql . '
                ) a 
                		ORDER BY
                		tabsequence ASC,
                		relsequence ASC';
        $result = $adb->pquery($SQL, array());
        $nums = $adb->num_rows($result);
        $availabletables = array();
        $profile = new Profile();
        $reports = $profile->getMobileReportNames();
        if ($nums > 0) {
            $j = 0;
            for ($i = 0; $i < $nums; $i++) {
                $blockid = 'blockid' . $adb->query_result($result, $i, 'blockid');
                $tabid = $adb->query_result($result, $i, 'tabid');
                if($MobileLanguageType == 'en'){
                    $blockname = $adb->query_result($result, $i, 'enblockname');
                }else{
                    $blockname = $adb->query_result($result, $i, 'blockname');
                }
                $module = $adb->query_result($result, $i, 'name');
                if($module=='TrackLocationMap'){
                    global $weixin_user;
                    if($weixin_user->environment != 'app'){
                        continue;
                    }
                }
                $title = $adb->query_result($result, $i, 'fieldlabel');
                $display = $adb->query_result($result, $i, 'display');
                $parenttab_label = $adb->query_result($result, $i, 'parenttab_label');
                $default_icon = $adb->query_result($result, $i, 'default_icon');
                $active_icon = $adb->query_result($result, $i, 'active_icon');
                $tab_tablename = $adb->query_result($result, $i, 'tab_tablename');
                //editor:gyq_157 reason:企业微信模块显示设置增加自定义表单\链接模块\报表  2019/11/5 17:24
                if ($parenttab_label == 'Reports') {
                    $relatename = $adb->query_result($result, $i, 'relatename');
                    if ($tab_tablename == 'ld_tab') {
                        $hiddenValue = implode(',', array($tabid,'','ld_tab'));
                        foreach ($reports as $index => $reportinfo) {
                            if ($reportinfo['name'] == strtolower($relatename) && isPermitted("MobileReport", $relatename) == 'yes') {
                                $report_icon = self::getWXReportListImage($relatename, 'ld_tab');
                                $availabletables[$blockid]['list'][$j] = array(
                                    'module' => strtolower($relatename),
                                    'title' => $reportinfo['fieldlabel'],
                                    'display' => $display,
                                    'hidden_value'=>$hiddenValue,
                                    'tab_tablename'=>'report',
                                    'report_icon'=>$report_icon,
                                    'commonlyused'=>'no'
                                );
                                break;
                            }
                        }
                    } else {
                        $hiddenValue = implode(',', array($tabid,'','ld_linkmodulecustom'));
                        $tmplinkinfo = self::getLinkModule($tabid);
                        if (!$tmplinkinfo) {
                            continue;
                        }
                        $availabletables[$blockid]['list'][$j] = array('module' => $tmplinkinfo['url'], 'title' => $tmplinkinfo['zh_label'], 'display' => $display,
                            'hidden_value'=>$hiddenValue,'tab_tablename'=>'ld_linkmodulecustom', 'commonlyused'=>'no');
                    }
                    $availabletables[$blockid]['blockname'] = $current_user->user_type=='prm'?'':$blockname;
                } else {
                    //edit: xll 2023/02/08 XUQIU1000984 移动端图标增加显示简易风格
                    $deployarr_13 = getAppsys_deploy(13);
                    $is_open13 = ($deployarr_13 != '') ? $deployarr_13['is_open'] : 'no';
                    $active_icon_head = ($is_open13 == 'yes') ? 'themes/icon2022/crm2/' : 'themes/icon2022/crm/';
                    if ($tab_tablename == 'ld_tab' && ($tabid < -1 || isPermitted($module, 'index') == 'yes')) {
                        //原有的模块设置，保留其以模块名module为标识的传值方式，而链接模块定制以及报表模块，以tabid为标识。
                        if ($tabid < -1) {
                            if($tabid == -12){
                                if(vtlib_isModuleActive('ShoppingMall') && isPermitted('ShoppingMall', 'index') == 'yes'){
                                    $hiddenValue = implode(',', array($module,'module',''));
                                    $availabletables[$blockid]['list'][$j] = array(
                                        'module' => $module,
                                        'title' => $title,
                                        'display' => $display,
                                        'hidden_value'=>$hiddenValue,
                                        'tab_tablename'=>'ld_tab',
                                        'commonlyused'=>'no'
                                    ); 
                                }
                            }else{
                               $hiddenValue = implode(',', array($spemodule[$tabid]['module'],'module',''));
                                $availabletables[$blockid]['list'][$j] = array(
                                    'module' => $spemodule[$tabid]['module'],
                                    'title' => $spemodule[$tabid]['tabname'],
                                    'display' => $display,
                                    'hidden_value'=>$hiddenValue,
                                    'tab_tablename'=>'ld_tab',
                                    'commonlyused'=>'no'
                                ); 
                            }
                            
                        } else {
                            $hiddenValue = implode(',', array($module,'module',''));
                            //$default_icon
                            //$active_icon zxm 2021-1208 模块图标
                            if(empty($active_icon)||!file_exists(globalStatic::$root_directory.$active_icon)){
                                if(empty($default_icon)||!file_exists(globalStatic::$root_directory.$default_icon)){
                                    if(empty($module)||!file_exists(globalStatic::$root_directory.$active_icon_head.'crm_'.$module.'.png')){
                                        if(get_file_address($module,'ProductDetails')||get_file_address($module,$module."DetailFieldsHtml")){
                                            $active_icon = $active_icon_head.'crm_CustomForm.png';
                                        }
                                        else{
                                            $active_icon = $active_icon_head.'crm_CustomForm1.png';
                                        }
                                    }else{
                                        $active_icon = $active_icon_head.'crm_'.$module.'.png';
                                    }
                                }else{
                                    $active_icon = $default_icon;
                                }

                            }
                            $availabletables[$blockid]['list'][$j] = array(
                                'module' => $module,
                                'title' => $title,
                                'display' => $display,
                                'hidden_value'=>$hiddenValue,
                                'tab_tablename'=>'ld_tab',
                                'active_icon'=>$active_icon,
                                'commonlyused'=>'no'
                            );
                            //zxm @date:2024/11/5 @reason: XUQIU20241029-07 模块图标没有替换，使用CND链接
                            $cdnimageurl = getGlobalImageUrl();
                            if(!empty($cdnimageurl)){
                                $availabletables[$blockid]['list'][$j]['active_icon_cdn']=$cdnimageurl.$active_icon;
                            }
                        }
                        $availabletables[$blockid]['blockname'] = $current_user->user_type=='prm'?'':$blockname;
                    } elseif ($tab_tablename == 'ld_linkmodulecustom') {
                        if(empty($active_icon)||!file_exists(globalStatic::$root_directory.$active_icon)){
                            $active_icon = $active_icon_head.'crm_Links.png';
                        }
                        $hiddenValue = implode(',', array($tabid,'','ld_linkmodulecustom'));
                        //链接模块定制
                        $tmplinkinfo = self::getLinkModule($tabid);
                        if (!$tmplinkinfo) {
                            continue;
                        }
                        if($MobileLanguageType=='en'){
                            $title = $tmplinkinfo['zh_label'];
                        }else{
                            $title = $tmplinkinfo['en_label'];
                        }
                        $availabletables[$blockid]['list'][$j] = array('module' => $tmplinkinfo['url'],
                            'title' => $tmplinkinfo['zh_label'], 'display' => $display,'hidden_value'=>$hiddenValue,'tab_tablename'=>'ld_linkmodulecustom', 'commonlyused'=>'no');
                        $availabletables[$blockid]['list'][$j]['active_icon'] = $active_icon;
                        $availabletables[$blockid]['blockname'] = $current_user->user_type=='prm'?'':$blockname;
                    }
                }
                $j++;
            }
        }
        $op = 0;
        foreach ($availabletables as $key => $val) {
            $availabletables_new[$op]['list'] = array_values($val['list']);
            $availabletables_new[$op]['blockname'] = $current_user->user_type=='prm'?'':$val['blockname'];
            $op++;
        }
        return $availabletables_new;
    }

    //获取报表列表，包括设置页签
    public static function getWXReportList()
    {
        global $adb, $current_user,$MobileLanguageType;
        global $PlatformMC;
        //报表
        $nameSwitchArr = array('monthweekreport' => 'weeklystatistics', 'Salesfunnel' => 'salesfunnel', 'Contractamount' => 'contractamount','SalesPhaseTransformationAnalysis' => 'SalesPhaseTransformationAnalysis', 'Salessituation' => 'salessituation',
            'Returnamount' => 'returnamount', 'signednumber' => 'signednumber', 'signedamount' => 'signedamount', 'cashbillamount' => 'paymentamount',
            'expense_commission' => 'coststatistics', 'daylog' => 'daylog', 'weeklog' => 'weeklog', 'monthlog' => 'monthlog', 'Saleskit' => 'saleskit');

        $availabletables = array();
        $origntables = array();
        if (!is_admin($current_user)) {
            $groupsql = "select GROUP_CONCAT(groupid) from ld_users2group where userid=?";
            $group_result = $adb->pquery($groupsql, array($current_user->id));
            if ($adb->num_rows($group_result) > 0)
                $curuser_groupids = explode(",", $adb->query_result($group_result, 0, 0));

        }
        //editor:gyq_141 reason:移动端增加首页标签  2019/9/9 11:31 ID1000602
        if (cls_StaticCommonFun::checkVersionIs001()) {
            $sql_where = ' and b.kehu001_presence=1 ';
        }

        //editor:gyq_20191129 reason:超链接模块需要修改SQL
        $sqlRel = 'select * from (select a.block_id,a.tabid,a.tab_tablename,b.name,b.labelbol,b.image,a.sequence,"" AS checkphp  from ld_mobile_report_tab_rel a 
                    left join ld_dashboard_app b on a.tabid=b.id
                    where a.block_id=? and a.tab_tablename<>\'ld_linkmodulecustom\' and b.wx_presence = 1 '.$sql_where.' 
                    union 
                    select a.block_id,a.tabid,a.tab_tablename,\'\',\'\',\'\',a.sequence,IFNULL(a.checkphp,"") AS checkphp from ld_mobile_report_tab_rel a where a.block_id=? 
                    and a.tab_tablename=\'ld_linkmodulecustom\') c order by sequence asc';
        //editor:gyq_159 reason:系统设置增加移动端报表菜单定制  2019/11/8 14:01 ID1000638
        $sql = 'select block_id,block_name,enblock_name,allocateid,allocatetype,menudescription from ld_mobile_report_parent_tab where presence=0 and menu_user_type=? order by sequence asc';
        $result = $adb->pquery($sql, array($current_user->user_type));
        $numrows = $adb->num_rows($result);
        $blockList = array();
        $w = 0;
        for($i=0;$i<$numrows;$i++){
            $block_id = $adb->query_result($result,$i,'block_id');
            $block_name = $adb->query_result($result,$i,'block_name');
            $enblock_name = $adb->query_result($result,$i,'enblock_name');
            $allocateid = $adb->query_result($result,$i,'allocateid');
            $allocatetype = $adb->query_result($result,$i,'allocatetype');
            $menudescription = $adb->query_result($result,$i,'menudescription');
            $allocateids = explode(",",$allocateid);
            //报表区块可见范围
            if (is_admin($current_user)) {
                $allocatetype = 'all';
            }
            if ($allocatetype == 'user') {
                if (!in_array($current_user->id, $allocateids)) {
                    continue;
                }
            }else if ($allocatetype == 'role') {
                if (!in_array($current_user->profileid, $allocateids)) {
                    continue;
                }
            } else if ($allocatetype == 'group') {
                $tmpgroup = 'no';
                foreach ($curuser_groupids as $curuser_groupid) {
                    if (in_array($curuser_groupid, $allocateids)) {
                        $tmpgroup = 'yes';
                        break;
                    }
                }
                if ($tmpgroup == 'no') {
                    continue;
                }
            }
            $resultRel = $adb->pquery($sqlRel,array($block_id,$block_id));
            $numrowsRel = $adb->num_rows($resultRel);
            $cellList = array();
            $q = 0;
            for($j=0;$j<$numrowsRel;$j++){
                $moduleReport = $adb->query_result($resultRel,$j,'name');
                $tab_tablename = $adb->query_result($resultRel,$j,'tab_tablename');
                $checkphp = $adb->query_result($resultRel,$j,'checkphp');
                $tabidReport = $adb->query_result($resultRel,$j,'tabid');
                $image = $adb->query_result($resultRel,$j,'image');
                $title = getFixedLabel( $adb->query_result($resultRel,$j,'labelbol'));
                //客户地图权限控制
                if ($moduleReport == 'AccountsMap' && (!vtlib_isModuleActive('ChinaMap') || isPermitted('ChinaMap') == 'no')) {
                    continue;
                }
                if ($moduleReport == 'CashBillSum_Paymentplan' && (!vtlib_isModuleActive('PaymentPlan') || isPermitted('PaymentPlan', 'index') == 'no')) {
                    continue;
                }
                if ($moduleReport == 'Accountleadsource' || $moduleReport == 'Accountaccounttype') {

                    $fieldobj = Field::getInstance('Accounts', $adb);
                    $accountfield = $fieldobj->getModuleFields();
                    if ($moduleReport == 'Accountleadsource' && !isset($accountfield['leadsource']))
                        continue;
                    if ($moduleReport == 'Accountaccounttype' && !isset($accountfield['accounttype']))
                        continue;
                }
                //权限验证
                if ($tab_tablename == 'ld_tab') {
                    if (isPermitted("MobileReport", $moduleReport) == 'no')
                        continue;
                } else {
                    $tmplinkinfo = self::getLinkModule($tabidReport);
                    if (!$tmplinkinfo) {
                        continue;
                    }
                    $moduleReport = $tmplinkinfo['url'];
                    $linkmodule = $tmplinkinfo['linkmodule'];
                    $entitytype = $tmplinkinfo['entitytype'];
                    if($MobileLanguageType == 'en'){
                        $title = $tmplinkinfo['en_label'];
                    }else{
                        $title = $tmplinkinfo['zh_label'];
                    }
                    $tab_tablename = 'ld_linkmodulecustom';
                }
                if (isset($nameSwitchArr[$moduleReport])) {
                    $nameswitch = $nameSwitchArr[$moduleReport];
                } else if($tab_tablename=='ld_linkmodulecustom'){

                    //zxm 2021-0831 报表库设置链接模块 拼接访问链接
                    //if(in_array($linkmodule,array("CustomEcharts","CustomTables","CustomReport"))){
                    if(in_array($linkmodule,array("CustomEcharts","CustomTables","CustomReport"))&&$entitytype!='customfine'){
                        //$corpurl = $_SERVER['REQUEST_SCHEME'].'://'.$_SERVER['HTTP_HOST']. rtrim($_SERVER['PHP_SELF'],'WeiXinApp/index.php').'/';

                        //zxm 20221019 自定义统计图 统计表 设置链接模块 拼接访问链接
                        if(in_array($linkmodule,array("CustomEcharts","CustomTables"))){
                            /*$corpurl_arr = explode('index.php',$corpurl_all);
                            $nameswitch = $corpurl_arr[0].$moduleReport;*/
                            $moduleReport = str_replace('index.php','',$moduleReport);
                            $nameswitch = getCorpUrl().$moduleReport;

                          if(is_array($PlatformMC)&&array_key_exists('isnativeapp',$PlatformMC)&&$PlatformMC['isnativeapp']=='yes')
                            {
                                $encryptobj=new cls_MyCRMcrypt();
                               
                                
                                $nameswitch .= '&frommobile=yes&userid='.$encryptobj->encode($_REQUEST['userid']);
                                $nameswitch .="&appusertoken=".$_REQUEST['appusertoken'];
                                
                            }
                            else
                                $nameswitch .= '&frommobile=yes&userid='.$_REQUEST['userid'];

                            $nameswitch .= '&customreport_chuantou=1';
                            $cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
                            $nameswitch = $cls_UrlEncryptyJudgeobj->EncryptyBynosorturlparseQueryParams($nameswitch);
                            
                        }else{
                            $corpurl_arr = explode('WeiXinApp',getCorpUrl());
                            $nameswitch = $corpurl_arr[0].$moduleReport;
                        }
                    }else{
                        $nameswitch  = $moduleReport;
                    }
                }else{
                    $nameswitch = strtolower($moduleReport);
                }
                $cellList[$q]['module'] = $nameswitch;
                $cellList[$q]['orign_name'] = $moduleReport;
                $cellList[$q]['tabid'] = $tabidReport;
                $cellList[$q]['title'] = $title;
                $cellList[$q]['image'] = self::getWXReportListImage($nameswitch,$tab_tablename);
                $cellList[$q]['tab_tablename'] = $tab_tablename;
                $cellList[$q]['checkphp'] = $checkphp;
                $cellList[$q]['display'] = 'yes';
                $cellList[$q]['commonlyused'] = 'no';
                $q++;
            }
            if(!empty($cellList)){
                $blockList[$w]['list'] = $cellList;
                if($MobileLanguageType == 'en'){
                    $blockList[$w]['blockname'] = $current_user->user_type=='prm'?'':$enblock_name;
                }else{
                    $blockList[$w]['blockname'] = $current_user->user_type=='prm'?'':$block_name;
                }
                $blockList[$w]['menudescription'] = $menudescription;
                $w++;
            }
        }
        return $blockList;
    }

    //editor:gyq_159 reason:获取报表图片名  2019/11/8 14:48 ID1000638
    protected static function getWXReportListImage($rName,$rTabName){
        //edit: xll 2023/02/08 XUQIU1000984 移动端图标增加显示简易风格
        $deployarr_13 = getAppsys_deploy(13);
        $is_open13 = ($deployarr_13 != '') ? $deployarr_13['is_open'] : 'no';
        $img_url_head = ($is_open13 == 'yes') ? 'report2022_2/' : 'report2022/';
        if($rTabName=='ld_linkmodulecustom'){
            $img_url = ($is_open13 == 'yes') ? "crm2022_2/crm_Links.png" : "crm2022/crm_Links.png";
            //项目甘特图
            if(strpos($rName,'gantindex.php')!==false){
                $img_url = $img_url_head.'report_16.png';
            }
            //客户全景
            if(strpos($rName,'default_account_panorama.mrt')!==false){
                $img_url = $img_url_head.'report_18.png';
            }
        }elseif($rTabName=='ld_tab') {
            $img_url = $img_url_head;
            $rName = strtolower($rName);
            switch ($rName) {
                case 'salesfunnel': //销售漏斗
                case 'salesfunnelreport':
                    $img_url .= "report_1.png";
                    break;
                case 'cashbillamount': //回款金额龙虎榜
                case 'paymentamount':
                case 'cluesourcereport':
                    $img_url .= "report_2.png";
                    break;
                case 'salesdragontiger': //销售龙虎榜
                case 'signedamount': //签约金额龙虎榜
                case 'cluedistributionreport':
                    $img_url .= "report_3.png";
                    break;
                case 'expense_commission': //费用佣金统计表
                case 'coststatistics':
                case 'failureanalysisreport':
                    $img_url .= "report_4.png";
                    break;
                case 'contractamount': //签约金额同比
                case 'salessituation': //最近6个月销售情况
                    $img_url .= "report_5.png";
                    break;
                case 'returnamount': //回款金额同比
                    $img_url .= "report_6.png";
                    break;
                case 'inventoryquery': //即时库存查询
                    $img_url .= "report_7.png";
                    break;
                case 'saleskit': //销售简报
                case 'saleskit_yangduan': //扬锻：销售简报
                case 'regionalstatistics': //蔷薇大树：区域统计
                    $img_url .= "report_8.png";
                    break;
                case 'contractkit': //合同简报
                    $img_url .= "report_9.png";
                    break;
                case 'cashbillsum_salesorder': //应收款统计表_按合同统计
                    $img_url .= "report_10.png";
                    break;
                case 'cashbillsum_paymentplan': //应收款统计表_按回款计划统计
                    $img_url .= "report_11.png";
                    break;
                case 'salesordertrack': //合同跟踪表
                    $img_url .= "report_12.png";
                    break;
                case 'complationratesixmonth': //最近6个月目标完成情况
                    $img_url .= "report_13.png";
                    break;
                case 'signednumber': //签约数量龙虎榜
                case 'contacttimesranking': //跟进频次排行榜
                    $img_url .= "report_14.png";
                    break;
                case 'accountaccounttype': //客户类型分布统计
                case 'accountleadsource': //客户来源分布统计
                    $img_url .= "report_15.png";
                    break;
                case '3': //项目甘特图
                    $img_url .= "report_16.png";
                    break;
                case 'personalaccountbalance': //个人账户余额
                    $img_url .= "report_17.png";
                    break;
                case 'personalaccountbalance': //客户全景
                    $img_url .= "report_18.png";
                    break;
                case 'daylog': //工作汇报日志统计表
                    $img_url .= "report_daylog.png";
                    break;
                case 'weeklog': //周计划统计表
                    $img_url .= "report_weeklog.png";
                    break;
                case 'monthlog': //月计划统计表
                    $img_url .= "report_monthlog.png";
                    break;
                case 'accountsmap': //客户地图
                    $img_url .= "report_AccountsMap.png";
                    break;
                case '2': //链接
                    $img_url .= "report_Link.png";
                    break;
                case 'targetcompletionrate': //目标完成率仪表盘
                    $img_url .= "report_DashBoard.png";
                    break;
                default:
                    $img_url .= "report_5.png";
                    break;
            }
        }
        return $img_url;
    }
    //reason:移动端报表个人用户显示设置 2019/11/8 16:28 ID1000638
    public static function getWXReportForMe(){
        global $adb,$current_user;
        $userid = $current_user->id;
        $sql = 'SELECT
        				TAB.sequence AS tabsequence,
        				REL.block_id,
        				REL.tabid,
        		      	"" as NAME,
		              	"" as fieldlabel,
        				TAB.block_name,
        				TAB.parenttab_label,
        				REL.sequence AS relsequence
                        REL.tab_tablename,
                      IF(exists(select 1 from ld_mobile_report_user_set SE
                  where SE.userid=' . $userid . ' and SE.tabid=REL.tabid and  SE.tab_tablename=\'ld_tab\') or
                     exists(select 1 from ld_mobile_report_user_set SD where SD.userid=' . $userid . ' and SD.tabid=REL.tabid and 
                     SD.tab_tablename=\'ld_linkmodulecustom\'),\'\',\'1\') display
        			FROM
        				ld_mobile_report_tab_rel REL
        			LEFT JOIN ld_mobile_report_parent_tab TAB ON REL.block_id = TAB.block_id
        			WHERE TAB.presence = 0 ORDER BY tabsequence ASC,relsequence ASC';
        $result = $adb->pquery($sql, array());
        $nums = $adb->num_rows($result);
        $availabletables = array();
        $j = 0;
        if ($nums > 0) {
            for ($i = 0; $i < $nums; $i++) {
                $blockid = 'blockid' . $adb->query_result($result, $i, 'blockid');
                $tabid = $adb->query_result($result, $i, 'tabid');
                $blockname = $adb->query_result($result, $i, 'blockname');
                $module = $adb->query_result($result, $i, 'name');
                $title = $adb->query_result($result, $i, 'fieldlabel');
                $display = $adb->query_result($result, $i, 'display');
                $parenttab_label = $adb->query_result($result, $i, 'parenttab_label');
                $tab_tablename = $adb->query_result($result, $i, 'tab_tablename');
                if ($tab_tablename == 'ld_tab') {
                    $hiddenValue = implode(',', array($tabid,'','ld_tab'));
                    foreach ($reports as $index => $reportinfo) {
                        if ( isPermitted("MobileReport", $relatename) == 'yes') {
                            $availabletables[$blockid]['list'][$j] = array(
                                'module' => strtolower($relatename), 'title' => $reportinfo['fieldlabel'], 'display' => $display,
                                'hidden_value'=>$hiddenValue,'tab_tablename'=>'report');
                            break;
                        }
                    }
                } else {
                    $hiddenValue = implode(',', array($tabid,'','ld_linkmodulecustom'));
                    $tmplinkinfo = self::getLinkModule($tabid);
                    if (!$tmplinkinfo) {
                        continue;
                    }
                    $availabletables[$blockid]['list'][$j] = array('module' => $tmplinkinfo['url'], 'title' => $tmplinkinfo['zh_label'], 'display' => $display,
                        'hidden_value'=>$hiddenValue,'tab_tablename'=>'ld_linkmodulecustom');
                }
                $availabletables[$blockid]['blockname'] = $current_user->user_type=='prm'?'':$blockname;
            }
            $j++;
        }
    }
    public static function getNearbyAccountsDisplay($formtype)
    {
        global $current_user, $adb;
        $nearbyaccount_sql = 'select 1 from ld_appuiset where userid=' . $current_user->id . ' and setname=? and settype=? and apptype=?';
        $nbaresult = $adb->pquery($nearbyaccount_sql, array('NearbyAccounts', 'module', $formtype));
        $nbapermit = $adb->num_rows($nbaresult) ? 0 : 1;
        return $nbapermit;
    }
}

?>