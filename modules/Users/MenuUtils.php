<?php

class MenuUtils
{
    /**
     * 获取主菜单信息
     * @project PROT58 速度优化：缓存
     * @author Tujt 2014-07-29
     */
    public function getAllParenttabmoduleslist() {
        $parenttabrelinfo = getParentTabrelInfo();
        return $this->getAllParenttabmoduleslistbyuser($parenttabrelinfo);
    }

    public function getPrmmenurelInfo() {
        $parenttabrelinfo = getPrmmenurelInfo();
        return $this->getAllParenttabmoduleslistbyuser($parenttabrelinfo);
    }

    public function getAllParenttabmoduleslistbyuser($parenttabrelinfo){
        global $current_user,$adb;
        if(!empty($parenttabrelinfo)){
            @include(globalStatic::$root_directory.'dataCache/tabdatas/parent_language.php');
            @include(globalStatic::$root_directory.'dataCache/tabdatas/tab_language.php');
            $languageType=getLanguageType($current_user);
            //$user_info=	getuserInfoByPrivileges($current_user);
            //$Group_Special = crm_load_class_obj('Group_Special', 'modules/Users');
            crm_load_class_file('cls_LinkModuleCustom','include/utils');
            crm_load_class_file('AuthApi','Register');
            $authapiobj=new AuthApi();
            if(is_admin($current_user)){
                foreach($parenttabrelinfo as $parenttabrel){
                    $parenttabname = $parenttabrel['parenttabname'];
                    if(empty($parenttabrel['tab']) || !isset($parenttabrel['tab'])) continue;
                    foreach($parenttabrel['tab'] as $tabid=>$parenttab){
                        $id = $parenttab['id'];
                        $modulename = $parenttab['modulename'];
                        $tab_tablename=$parenttab['tab_tablename'];
                        $checkphp=$parenttab['checkphp'];
                        $isopeninblank=$parenttab['isopeninblank'];
                        $linkcvid = 0;
                        if($tab_tablename=='ld_tab'||$tab_tablename=='')
                        {
                            $tmptabid = $tabid;
                            $modulename = getTranstab($modulename);
                            $tablabel = $parenttab['tablabel'];

                        }
                        else
                        {
                            //自定义模块链接
                            $tmptabids=explode("_",$tabid);
                            $tmptabid = $tmptabids[0];
                            $linkmoduleinfo=cls_LinkModuleCustom::getLinkModuleCustomInfoById($tmptabids[0]);
                            if(empty($linkmoduleinfo))
                            {
                                continue;
                            }
                            //$scope=$linkmoduleinfo['scope'];
                            // @edit:dong @date:2020/12/02 @reason: 调整下返回值的位置
                            $tablabel=$linkmoduleinfo['linkmodule'];
                            // @edit:dong @date:2020/10/29 @reason: 数据分类设置为链接模块 增加两个属性
                            $linkurl =$linkmoduleinfo['url'];
                            $linkcvid = $linkmoduleinfo['linkcvid'];
                            $entitytype =$linkmoduleinfo['entitytype'];
                            $authcheck=$linkmoduleinfo['authcheck'];

                            $paramvalue=$linkmoduleinfo['paramvalue'];
                            $crmreporturl = '';
                            //zkt 20220506 51458齐心客户系统升级V8.4.6.1后，报表管理中的报表未显示数据(报表为齐心开发报表)
                            if(strstr($linkurl,'/CustomReport/JsReport/index.php?crm_report_key')== false&&$entitytype=='custom')
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
                                //  $crmreporturl = 'crmreportuuid='.$current_user->id.'&crmreportuuid_range='.$uuid_range.'&crmreportcur_range='.$cur_range.'&crmreportcur_period=thismonth';

                            }
                            if($authcheck=='yes'||!empty($paramvalue))
                            {
                                if(!empty($crmreporturl)){
                                    $crmreporturl.='&crm=yes';
                                }
                                else{
                                    $crmreporturl.='crm=yes';
                                }
                            }
                            $paramvalue=$linkmoduleinfo['paramvalue'];
                            if($paramvalue=='[]')
                            {
                                $paramvalue='';
                            }
                            if(!empty($crmreporturl)){
                                if(strstr($linkurl,'?')!= false)
                                {
                                    $linkurl .='&'.$crmreporturl;
                                }
                                else
                                {
                                    $linkurl .='?'.$crmreporturl;
                                }
                            }
                            $webparamvalue=$linkmoduleinfo['webparamvalue'];

                            if($authcheck=='yes')
                            {
                                $tmptoken= $authapiobj->encode(array('paramvaule'=>json_decode(html_entity_decode($paramvalue),true)));
                                $linkurl.='&crm_access_token='.$tmptoken;
                            }
                            else if(!empty($paramvalue))
                            {
                                $tmp_param_arr=json_decode(html_entity_decode($paramvalue),true);
                                foreach($tmp_param_arr as $tmpparamkey=> $tmpparamvalue)
                                {
                                    $linkurl.="&$tmpparamkey=$tmpparamvalue";
                                }
                            }



                            if(!empty($webparamvalue))
                            {
                                if(strstr($linkurl,'?')!= false)
                                {
                                    $linkurl .= '&';
                                }
                                else
                                {
                                    $linkurl .='?';
                                }
                                $webparam_arr=json_decode(html_entity_decode($webparamvalue),true);
                                foreach($webparam_arr as $tmpparamkey=> $tmpparamvalue)
                                {
                                    if($tmpparamvalue=='[uuid]')
                                        $linkurl.="&$tmpparamkey=".$current_user->id;
                                    else if($tmpparamvalue=='[uuid_range]')
                                    {
                                        $linkurl.="&$tmpparamkey=".$uuid_range;
                                    }
                                    else if($tmpparamvalue=='[thismonth]')
                                    {
                                        $linkurl.="&$tmpparamkey=thismonth";
                                    }
                                    else{
                                        $linkurl.="&$tmpparamkey=$tmpparamvalue";
                                    }
                                }

                            }
                            if($languageType=='zh')
                                $modulename=$linkmoduleinfo['zh_label'];
                            else
                                $modulename=$linkmoduleinfo['en_label'];
                        }
                        $resultant_array[$parenttabname][] = Array(
                            'id'=>$id,
                            'tabid'=>$tmptabid,
                            'modulename'=>$modulename,
                            'tablabel'=>$tablabel,
                            'tab_tablename'=>$tab_tablename,
                            'entitytype'=>$entitytype,
                            'linkurl'=>$linkurl,
                            'checkphp'=>$checkphp,
                            'isopeninblank'=>$isopeninblank,
                            'linkcvid'=>$linkcvid);
                    }
                }
            }else{
                foreach($parenttabrelinfo as $parenttabrel){
                    $userids = '';
                    $parenttabname = $parenttabrel['parenttabname'];
                    if(empty($parenttabrel['tab']) || !isset($parenttabrel['tab'])) continue;
                    foreach($parenttabrel['tab'] as $tabid=>$parenttab)
                    {
                        $id = $parenttab['id'];
                        $tab_tablename=$parenttab['tab_tablename'];
                        $checkphp=$parenttab['checkphp'];
                        $isopeninblank=$parenttab['isopeninblank'];
                        $linkcvid = 0;
                        if($parenttab['allocatetype'] != 'all')
                        {
                            if($parenttab['allocatetype'] == 'user'){
                                $userids = explode(',',$parenttab['allocateid']);
                                if(!in_array($current_user->id,$userids)){
                                    continue;
                                }
                            }else if($parenttab['allocatetype'] == 'role'){
                                $roleids = explode(',',$parenttab['allocateid']);
                                if(!in_array($current_user->profileid,$roleids)){
                                    continue;
                                }
                            }else if($parenttab['allocatetype'] == 'group'){
                                //zxm 20221227 mysql group_concat的长度限制是1024,超过就截取
                                $groupids = explode(',',$parenttab['allocateid']);
                                $usergroupids = $current_user->groupid;
                                $usergroupids_arr = explode(',',$usergroupids);
                                $usergroupids_arr_intersect = array_intersect($usergroupids_arr,$groupids);
                                if(empty($usergroupids_arr_intersect)){
                                    continue;
                                }
                                /*$userinfoStr=array();
                                //有待优化，实在是没有时间
                                $sql="select GROUP_CONCAT(userid) from ld_users2group  where groupid in( ".$parenttab['allocateid'].") ";
                                $result=$adb->pquery($sql,array());
                                if($adb->num_rows($result))
                                    $userinfoStr = $adb->query_result($result,0,0);


                                $userids = explode(',',$userinfoStr);
                                if(!in_array($current_user->id,$userids)){

                                    continue;
                                }*/
                            }
                        }

                        if($tab_tablename=='ld_tab')
                        {

                            $modulename = $parenttab['modulename'];
                            if(!vtlib_isModuleActive($modulename))
                            {
                                continue;
                            }
                            /**
                             * V6.0角色权限改进
                             * @reason 如果用户没有当前模块访问权限，则不显示当前模块
                             * @author Chj 2015/4/24
                             */
                            if(isPermitted($modulename,"index","") == 'no'){
                                continue;
                            }
                            $modulename = getTranstab($modulename);
                            $tablabel = $parenttab['tablabel'];
                            if (is_admin($current_user)==false && (isPermitted($tablabel,"index","") == 'yes') ) {
                                $resultant_array[$parenttabname][] = Array(
                                    'id'=>$id,
                                    'tabid'=>$tabid,
                                    'modulename'=>$modulename,
                                    'tablabel'=>$tablabel,
                                    'tab_tablename'=>$tab_tablename,
                                    'entitytype'=>'',
                                    'linkurl'=>$linkurl,
                                    'checkphp'=>'',
                                    'isopeninblank'=>'',
                                    'linkcvid'=>'');
                            }
                        }
                        else
                        {
                            //自定义模块链接
                            $tmptabids=explode("_",$tabid);

                            $linkmoduleinfo=cls_LinkModuleCustom::getLinkModuleCustomInfoById($tmptabids[0]);
                            // @edit:dong @date:2020/10/29 @reason: 数据分类设置为链接模块  返回空则说明没有权限
                            if(empty($linkmoduleinfo)){
                                continue;
                            }
                            // @edit:dong @date:2020/12/23 @reason: 权限 数据分类为私有的时候非管理员用户不显示 数据分类。
                            //前端已控制 以后可以删除这一段
                            if(!empty($linkmoduleinfo['linkcvid'])){
                                $sql='select status from ld_customview where cvid =?';
                                $tmp_result=  $adb->pquery($sql,array($linkmoduleinfo['linkcvid']));
                                if($adb->num_rows($tmp_result)>0){
                                    if($adb->query_result($tmp_result,0,'status') ==1){
                                        continue;
                                    };
                                }
                            }
                            $tablabel=$linkmoduleinfo['linkmodule'];
                            $scope=$linkmoduleinfo['scope'];
                            // @edit:dong @date:2020/10/29 @reason: 数据分类设置为链接模块 增加两个属性
                            // @edit:dong @date:2020/12/02 @reason: 调整下返回顺序
                            $linkurl =$linkmoduleinfo['url'];
                            $linkcvid = $linkmoduleinfo['linkcvid'];
                            $tmptabid = $tmptabids[0];
                            $entitytype =$linkmoduleinfo['entitytype'];
                            $crmreporturl = '';
                            if(strstr($linkurl,'/CustomReport/JsReport/index.php?crm_report_key')== false&&$entitytype=='custom')
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
                                //$crmreporturl = 'crmreportuuid='.$current_user->id.'&crmreportuuid_range='.$uuid_range.'&crmreportcur_range='.$cur_range.'&crmreportcur_period=thismonth';

                            }
                            if($scope=='user')
                            {
                                $sql='select 1 from ld_linkmodulecustom2user where linkmodulecustomid=? and userid=? ';
                                $tmp_result=$adb->pquery($sql,array($tabid,$current_user->id));
                                if($adb->num_rows($tmp_result)<=0)
                                {
                                    continue;
                                }

                            }else if($scope=='role')
                            {
                                $sql='select 1 from ld_linkmodulecustom2user where linkmodulecustomid=? and userid=? ';
                                $tmp_result=$adb->pquery($sql,array($tabid,$current_user->profileid));
                                if($adb->num_rows($tmp_result)<=0)
                                {
                                    continue;
                                }

                            }
                            else if($scope=='group')
                            {
                                $sql='select 1 from ld_linkmodulecustom2user 
                                     inner join ld_users2group on ld_linkmodulecustom2user.userid=ld_users2group.groupid
                                    where linkmodulecustomid=? and ld_users2group.userid=? ';
                                $tmp_result=$adb->pquery($sql,array($tabid,$current_user->id));
                                if($adb->num_rows($tmp_result)<=0)
                                {
                                    continue;
                                }
                            }
                            $authcheck=$linkmoduleinfo['authcheck'];

                            $paramvalue=$linkmoduleinfo['paramvalue'];

                            if($authcheck=='yes'||!empty($paramvalue))
                            {
                                if(!empty($crmreporturl)){
                                    $crmreporturl.='&crm=yes';
                                }
                                else{
                                    $crmreporturl.='crm=yes';
                                }
                            }


                            if(!empty($crmreporturl))
                            {
                                if(strstr($linkurl,'?')!= false)
                                {
                                    $linkurl .= '&'.$crmreporturl;
                                }
                                else
                                {
                                    $linkurl .='?'.$crmreporturl;
                                }
                            }
                            //zkt 20240312 BUG20240306-25  ERP库存查询，是设置的链接模块，管理员能点击查看，新增的成员点击查看提示如图报错。  ———— 放在前面会导致链接不带？时产生错误
                            $paramvalue=$linkmoduleinfo['paramvalue'];
                            if($paramvalue=='[]')
                            {
                                $paramvalue='';
                            }


                            if($authcheck=='yes')
                            {
                                $tmptoken= $authapiobj->encode(array('paramvaule'=>json_decode(html_entity_decode($paramvalue),true)));
                                $linkurl.='&crm_access_token='.$tmptoken;
                            }
                            else if(!empty($paramvalue))
                            {
                                $tmp_param_arr=json_decode(html_entity_decode($paramvalue),true);
                                foreach($tmp_param_arr as $tmpparamkey=> $tmpparamvalue)
                                {
                                    $linkurl.="&$tmpparamkey=$tmpparamvalue";

                                }
                            }

                            $webparamvalue=$linkmoduleinfo['webparamvalue'];
                            if(!empty($webparamvalue))
                            {
                                if(strstr($linkurl,'?')!= false)
                                {
                                    $linkurl .= '&';
                                }
                                else
                                {
                                    $linkurl .='?';
                                }
                                $webparam_arr=json_decode(html_entity_decode($webparamvalue),true);
                                foreach($webparam_arr as $tmpparamkey=> $tmpparamvalue)
                                {
                                    if($tmpparamvalue=='[uuid]')
                                        $linkurl.="&$tmpparamkey=".$current_user->id;
                                    else if($tmpparamvalue=='[uuid_range]')
                                    {
                                        $linkurl.="&$tmpparamkey=".$uuid_range;
                                    }
                                    else if($tmpparamvalue=='[thismonth]')
                                    {
                                        $linkurl.="&$tmpparamkey=thismonth";
                                    }
                                    else{
                                        $linkurl.="&$tmpparamkey=$tmpparamvalue";
                                    }
                                }

                            }
                            if($languageType=='zh')
                                $modulename=$linkmoduleinfo['zh_label'];
                            else
                                $modulename=$linkmoduleinfo['en_label'];

                            $resultant_array[$parenttabname][] = Array(
                                'id'=>$id,
                                'tabid'=>$tmptabid,
                                'modulename'=>$modulename,
                                'tablabel'=>$tablabel,
                                'tab_tablename'=>$tab_tablename,
                                'entitytype'=>$entitytype,
                                'linkurl'=>$linkurl,
                                'checkphp'=>$checkphp,
                                'isopeninblank'=>$isopeninblank,
                                'linkcvid'=>$linkcvid);
                        }
                    }
                }
            }
        }
        if(!empty($resultant_array)) return $resultant_array;
        return [];
    }

    /**
     * @param $parenttablist
     * @return false|mixed|void
     * @throws Exception
     * 获取菜单拼音  做缓存  zxm 20230829
     */
    public function getParentTabListPinyin(){
        global $adb,$languageType;
        $cacheKey = 'pinyinAlllabel3_'.$languageType;//按语言缓存
       $pinyinAlllabel = Cache($cacheKey);

        if(!$pinyinAlllabel){
            $pinyinAlllabel=[];
            $pinyinsql = "select `name` ,fieldlabel,(select getpinyin(fieldlabel))as pinyin from (
        select ld_tab.`name`,ld_tranlabel.fieldlabel  from ld_tab  
        left join 
        (select * from ld_tranlabel where trantable='ld_tab' and ld_tranlabel.languagetype='$languageType')ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid  
        union all
        select `name`,(case when '$languageType'='en' then en_label else zh_label end)as fieldlabel from ld_linkmodulecustom
        
        union all
        select 'LOGINPOLICY'as `name`,(select fieldlabel from ld_desk where labelbol='LoginPolicy' and languagetype='$languageType' and labelType='fixedstr' limit 1)as fieldlabel
        union all
        select 'listroles'as `name`,(select fieldlabel from ld_desk where labelbol='profileauthority' and languagetype='$languageType' and labelType='fixedstr' limit 1)as fieldlabel
        union all
        select 'Settings'as `name`,(select fieldlabel from ld_desk where labelbol='SYSTEM_DESCRIPTION' and languagetype='$languageType' and labelType='fixedstr' limit 1)as fieldlabel
    ) a where ifnull(fieldlabel,'')<>'' ";
            $pinyinres = $adb->pquery($pinyinsql);
            $pinnums = $adb->num_rows($pinyinres);
            if($pinnums>0){
                for($i=0;$i<$pinnums;$i++){
                    $label = $adb->query_result($pinyinres,$i,"fieldlabel");
                    $labelpinyin = $adb->query_result($pinyinres,$i,"pinyin");
                    $pinyinAlllabel[$label] =  $labelpinyin;
                }
            }

             Cache($cacheKey,$pinyinAlllabel);
        }

        return $pinyinAlllabel;
    }

    /**
     * @return false|mixed|void
     * @throws Exception
     * 获取模块ld_tab的图标
     */
    public function getTabModuleIconArr()
    {
        global $adb;
        $cacheKey = 'getTabModuleIconArr' ;
        $moduleIconArr = Cache($cacheKey);
        $menuDefaultUrl = getGlobalImageUrl();
        if (!$moduleIconArr) {
            $moduleIconArr=[];
            $select_tab_sql = "select `name`,default_icon,active_icon from ld_tab";
            $select_tab_res = $adb->pquery($select_tab_sql);
            $select_tab_nums = $adb->num_rows($select_tab_res);
            for ($i = 0; $i < $select_tab_nums; $i++) {
                $temp_name = $adb->query_result($select_tab_res, $i, 'name');
                $temp_default_icon = $adb->query_result($select_tab_res, $i, 'default_icon');
                $temp_active_icon = $adb->query_result($select_tab_res, $i, 'active_icon');
                if (empty($temp_active_icon) || !file_exists(globalStatic::$root_directory . $temp_active_icon)) {
                    if (empty($temp_default_icon) || !file_exists(globalStatic::$root_directory . $temp_default_icon)) {
                        if (empty($temp_name) || !file_exists(globalStatic::$root_directory . 'themes/icon2022/crm2/crm_' . $temp_name . '.png')) {
                            if (get_file_address($temp_name, 'ProductDetails') || get_file_address($temp_name, $temp_name . "DetailFieldsHtml")) {
                                $moduleIconArr[$temp_name] = $menuDefaultUrl.'themes/icon2022/crm2/crm_CustomForm.png';
                            } else {
                                $moduleIconArr[$temp_name] = $menuDefaultUrl.'themes/icon2022/crm2/crm_CustomForm1.png';
                            }
                        } else {
                            $moduleIconArr[$temp_name] = $menuDefaultUrl.'themes/icon2022/crm2/crm_' . $temp_name . '.png';
                        }
                    } else {
                        $moduleIconArr[$temp_name] = $temp_default_icon;
                    }
                } else {
                    $moduleIconArr[$temp_name] = $temp_active_icon;
                }
            }
        }
        return $moduleIconArr;
    }

    /**
     * @return array|int|mixed|string|string[]|null
     * @throws Exception
     * 获取水印的文字--没做缓存
     */
    public function getwatermark_setting(){
        global $adb,$current_user;
        $sql_watermark="select * from ld_watermark_setting where id=1";
        $result_watermark = $adb->pquery($sql_watermark, array());
        $watermark_presence = $adb->query_result($result_watermark,0,'presence');
        $watermark_txt = '';
        if ($watermark_presence =='yes'){
            $watermark_display = $adb->query_result($result_watermark,0,'watermark_display');

            $phone_mobile=$current_user->phone_mobile;
            $get_phone_mobile = '';
            if(!empty($phone_mobile))
                $get_phone_mobile = substr($phone_mobile,-4);//取手机尾号后四位
            //edit: xll BUG0061395 水印设置显示特殊字符错误
            $custom_content = $adb->query_result($result_watermark,0,'custom_content');
            if(!empty($custom_content))
                $custom_content = html_entity_decode(trim($adb->query_result($result_watermark,0,'custom_content')));

            $sql_organization="select * from ld_organizationdetails";
            $result_organization = $adb->pquery($sql_organization, array());
            $organization_name =  $adb->query_result($result_organization,0,'organizationname');

            if(isKehu001ServerPc()=='yes'){
                $wx_userid=$current_user->wx_userid;
                $login_username = getUserRealNameBywxuserid($wx_userid);
            }else{
                $login_username = $current_user->last_name;
            }

            if( $watermark_display=='username'){
                $watermark_txt = $login_username;
            }
            else if( $watermark_display=='username_date'){
                $watermark_txt = $login_username.' '. date('Y-m-d');
            }
            else if ($watermark_display=='username_phone'){
                $watermark_txt = $login_username.' '. $get_phone_mobile;
            }
            else if ($watermark_display=='Companyname_username'){
                $watermark_txt = $organization_name.' '.$login_username;
            }
            else if ($watermark_display=='Companyname_username_phone'){
                $watermark_txt = $organization_name.' '.$login_username.' '.$get_phone_mobile;
            }
            else if ($watermark_display=='companyname_username_date'){
                $watermark_txt = $organization_name.' '.$login_username.' '.date('Y-m-d') ;
            }
            else{
                $watermark_txt = $custom_content ;
            }
        }
        return $watermark_txt;
    }

    public function getHeaderMenuColor(){
        global $adb,$current_user;
        $cachekey = 'updateMenuStyleinfo';
        $menustyleinfo = CacheDirectory($cachekey,'MenuStyleinfo');

        if($menustyleinfo && isset($menustyleinfo[$current_user->id])){
            return  $menustyleinfo[$current_user->id];
        }
        else{
            if(!is_array($menustyleinfo))
            {
                $menustyleinfo=array();
            }
            $Menustyle = getUsersettingByLabel('notbymodule',$current_user->id,'Menustyle');
            if(empty($Menustyle)){
                $query = 'select menuback_color,menuhover_color,menustyle from ld_organizationdetails';
                $result = $adb->pquery($query,array());
                $Menuback_color = $adb->query_result($result,0,'menuback_color');
                $Menuhover_color = $adb->query_result($result,0,'menuhover_color');
                $menustyle = $adb->query_result($result,0,'menustyle');
                if($menustyle == 'dark' || $menustyle == 'custom'){
                    $Menufont_color = '#FFFFFF';
                }
                else{
                    $Menufont_color = '#3B4859';
                }
                return array(
                    'Menuback_color'=>$Menuback_color,
                    'Menuhover_color'=>$Menuhover_color,
                    'Menufont_color'=>$Menufont_color,
                    'Background_color'=>'#CFDEF5'
                );
            }else{
                $Menuback_color = getUsersettingByLabel('notbymodule',$current_user->id,'Menuback_color');
                $Menuhover_color = getUsersettingByLabel('notbymodule',$current_user->id,'Menuhover_color');
                $Background_color = getUsersettingByLabel('notbymodule',$current_user->id,'Background_color');
                $fonttype = getUsersettingByLabel('notbymodule',$current_user->id,'Menufont_color');
                $Menufont_color = $fonttype;
                if($fonttype == 'black'){
                    $Menufont_color = '#3B4859';
                }elseif($fonttype == 'white'){
                    $Menufont_color = '#FFFFFF';
                }
                $menustyleinfo[$current_user->id] = array(
                    'Menuback_color'=>$Menuback_color,
                    'Menuhover_color'=>$Menuhover_color,
                    'Menufont_color'=>$Menufont_color,
                    'Menustyle'=>$Menustyle,
                    'Background_color'=>$Background_color
                );
                CacheDirectory($cachekey,'MenuStyleinfo',$menustyleinfo);
                return $menustyleinfo[$current_user->id];
            }
        }


    }

    public function getorganizationdetailslogo(){
        global $adb,$current_user;
        $sql="select small_logoname,logoname,menustyle from ld_organizationdetails";
        $result = $adb->pquery($sql, array());
        $organization_logo = decode_html($adb->query_result($result,0,'logoname'));
        $organization_smalllogo = decode_html($adb->query_result($result,0,'small_logoname'));
//wym 原先存在ld_organizationdetails表中,现在修改成在ld_module_setting_byuser表里,如果新表没数据则取老表的数据
        $menustyle = getUsersettingByLabel('notbymodule',$current_user->id,'Menustyle');
        if($menustyle){
            if($menustyle=='custom')
                $menufont=getUsersettingByLabel('notbymodule',$current_user->id,'Menufont_color');
        }else{
            $menustyle = decode_html($adb->query_result($result,0,'menustyle'));
        }
        if(empty($organization_smalllogo)){
            //浅色菜单模式
            if($menustyle == 'lightcolour' || $menufont=='black'){
                $organization_smalllogo = 'logo_mini_light_0721.png';
            }
            else{
                $organization_smalllogo = 'logo_mini_dark_0721.png';
            }
        }
        if(empty($organization_logo)){
            //浅色菜单模式
            if($menustyle == 'lightcolour' || $menufont=='black'){
                $organization_logo = 'logo_big_light_0721.png';
            }
            else{
                $organization_logo = 'logo_big_dark_0721.png';
            }
        }
        return array(
            "MENUSTYLE"=>$menustyle,
            "LOGO"=>$organization_logo,
            "SMALLLOGO"=>$organization_smalllogo
        );
    }

    public function getPRMlogoname(){
        global $adb;
        $sql="select logoname,prmlogoname from ld_organizationdetails";
        $result = $adb->pquery($sql, array());
        $prmlogoname = $adb->query_result($result,0,'prmlogoname');
        if(empty($prmlogoname)){
            $crmlogoname = $adb->query_result($result,0,'logoname');
            if(empty($crmlogoname)){
                $prmlogoname = 'logo_big_light_0721.png';
            }
            else{
                $prmlogoname = $crmlogoname;
            }
        }
        return $prmlogoname;
    }

    public function getPRMAccountName(){
        global $adb,$current_user;
        $account_name = '';
        $sql = 'select parentgroup from ld_groups where groupid = ?;';
        $result = $adb->pquery($sql,array($current_user->groupid));
        if($adb->num_rows($result) > 0){
            $grouplevel = $adb->query_result($result,0,'parentgroup');
            $grouplevelarr = explode("::", $grouplevel);
            $grouplevelarr = array_reverse($grouplevelarr);
            $query = 'select ld_account.accountname from ld_groups LEFT JOIN ld_account on ld_groups.related_crmid = ld_account.accountid where ld_groups.groupid in ('.implode(',',$grouplevelarr).') ORDER BY FIELD(ld_groups.groupid,'.implode(',',$grouplevelarr).');';
            $result_name = $adb->pquery($query,array());
            $num = $adb->num_rows($result_name);
            if($num > 0){
                for($i = 0;$i<$num;$i++){
                    if(empty($adb->query_result($result_name,$i,'accountname'))){
                        continue;
                    }
                    $account_name = $adb->query_result($result_name,$i,'accountname');
                }
            }
            if(empty($account_name)){
                $sql_sel = 'select organizationname from ld_organizationdetails';
                $result_sel = $adb->pquery($sql_sel,array());
                if($adb->num_rows($result_sel) > 0){
                    $account_name = $adb->query_result($result_sel,0,'organizationname');
                }
            }
        }
        return $account_name;
    }

}