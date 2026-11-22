<?php
/****************************************************
 *{*修改编码格式:统一编码：UTF-8*}
**AUTHOR:BY LD KEVIN
**DATE:20130219
*DESCRIPTION:创建组件模板
****************************************************/

    global $mod_strings,$app_strings;
    //zxm  2020-0127 RelatedTables和AllAssmablys挪到home.php中方法中调用，两边都需要，保持一致
    require_once( globalStatic::$root_directory.'include/home.php');
    $homestuffObj = new Homestuff();
    $RelatedTables = $homestuffObj->getRelatedTables();
    $AllAssmablys = $homestuffObj->getAllAssmablys();

    $smarty=new lingdangCRM_Smarty;
    $templateName = '';
    if(isset($_REQUEST['templateid'])&&$_REQUEST['templateid']!=''){
        global $adb;
        if(isset($_REQUEST['mode'])&&$_REQUEST['mode']!='')
        {
            $mode=vtlib_purify($_REQUEST['mode']);
        }
        //$mode='edit';
        $templateId=vtlib_purify($_REQUEST['templateid']);
        $templateName=getTemplateName($templateId);
        $roleInfos=getRoleInfo($templateId);
        $assmablyInfo=getAssambly($templateId,$RelatedTables,$AllAssmablys);

    }
    else{
        $mode='create';
    }
    function getTemplateName($templateId){
        global $adb;
        
        $tempquery='select templatename from ld_templates where templateid=?';
        $res=$adb->pquery($tempquery,array($templateId));

        $templateName = '';
        if($adb->num_rows($res)>0){
            $templateName = $adb->query_result($res,0,'templatename');
        }
        return $templateName;
    }
    function getRoleInfo($templateId){
        global $adb;
        //$log->debug("Entering getRoleInfo(".$templateid.") method ...");
        $query='select profileid from ld_templatesrole where templateid=? and profileid > 0 group by profileid';
        $result=$adb->pquery($query,array($templateId));
        $num_rows=$adb->num_rows($result);
        $roleIds=array();
        for($i=0;$i<$num_rows;$i++){
            $roleId=$adb->query_result($result,$i,'profileid');
            $roleIds[]=$roleId;
        }
       // $log->debug("Exiting getRoleInfo method ...");
        return $roleIds;
    }
    // @edit:dong @date:2020/09/25 @reason: 添加参数$AllAssmablys
    function getAssambly($templateId,$RelatedTables,$AllAssmablys){
        global $adb,$current_user;
       // $log->debug("Entering getAssambly(".$templateid.") method ...");
        $query='select * from ld_templatesstuff where templateid=? order by ld_templatesstuff.stuffsequence asc;';
        $result=$adb->pquery($query,array($templateId));
        $num_rows=$adb->num_rows($result);
        $stuffInfos=array();
        for($i=0;$i<$num_rows;$i++){
            $stuffId=$adb->query_result($result,$i,'stuffid');
            $source = $adb->query_result($result,$i,'source');
            if($source=='customechart'){
                $stuffId = 'customEchart_'.$stuffId;
            }
            $stuffTitle=$adb->query_result($result,$i,'stufftitle');

            $isActive=true;
            //zxm 2021-0329 增加自定义统计图可显示在首页
            if($source!='customechart'){
                $modulename=$RelatedTables[$stuffId];
                $tabs=explode(',',$modulename);
                if($stuffId==33){
                    $activeNum = 0;
                    foreach($tabs as $tabname)
                    {
                        if(vtlib_isModuleActive($tabname))
                        {
                            $activeNum+=1;
                        }
                    }
                    if($activeNum>=1){
                        $isActive=true;
                    }else{
                        $isActive=false;
                    }
                }else{
                    foreach($tabs as $tabname)
                    {
                        if(!vtlib_isModuleActive($tabname))
                        {
                            $isActive=false;
                            break;
                        }
                    }
                }
            }
            if($modulename==1 ||$isActive){
                if($source == 'customechart'){
                    $stuffTitle = getTranstab('CustomEcharts').'_'.$stuffTitle;
                }
                $stuffInfos[]=array($stuffId,$stuffTitle);
            }
        }
       if($templateId>=76&&$templateId<=79&&empty($stuffInfos))
        {
            // @edit:dong @date:2020/09/25 @reason:  bug0042755 首页组件 重设首页组件模板默认值
            $homeStuffInfosIds =array(35,39,19,34,33,1,9,40,20,13);
            foreach($homeStuffInfosIds as $key=>$stuffId)
            {
                $isActive=true;
                $moduleNames = $RelatedTables[$stuffId];
                $tabs=explode(',',$moduleNames);
                if($stuffId == 33){
                    $activeNum = 0;
                    foreach($tabs as $tabname)
                    {
                        if(vtlib_isModuleActive($tabname))
                        {
                            $activeNum+=1;
                        }
                    }
                    if($activeNum>=1){
                        $isActive = true;
                    }else{
                        $isActive = false;
                    }
                }else{
                    foreach($tabs as $tabname)
                    {
                        if(!vtlib_isModuleActive($tabname))
                        {
                            $isActive=false;
                            break;
                        }
                    }
                }

                if($moduleNames==1)
                {
                    $isActive=true;
                }

                if($isActive && isset($AllAssmablys[$stuffId]))
                {
                    $stuffInfos[]=array($stuffId,$AllAssmablys[$stuffId],'home');
                }

            }
        }
        return $stuffInfos;
    }
    //可用角色
    $query = 'select profileid,profilename from ld_profile';
    $result = $adb->pquery($query);
    $num_rows = $adb->num_rows($result);

    for($i = 0; $i<$num_rows; $i++){
        $profileid = $adb->query_result($result,$i,'profileid');
        $profileidArr[$i] = "'".$adb->query_result($result,$i,'profileid')."'";
        $profilenameArr[$i] = "'".addslashes(decode_html($adb->query_result($result,$i,'profilename')))."'";
        $profileall[$profileid] = addslashes(decode_html($adb->query_result($result,$i,'profilename')));
    }
    $roleIdStr = implode(',', $profileidArr);
    $roleNameStr = implode(',', $profilenameArr);
    //if($mode=='edit'){
        $member=array();
        $profile = new Profile();
        if(!empty($roleInfos)){
            foreach($roleInfos as $roleId){
                unset($profileall[$roleId]);
                
                $profilearr = $profile->getProfileinfo($roleId);
                if(!empty($profilearr['profilename'])){
                     $member[]='roles:'.$roleId;
                    $member[]=getFixedLabel('LBL_ROLES').':'.$profilearr['profilename'];
                }
            }
        }

    $smarty->assign("MEMBER", array_chunk($member,2));
    //}
    /*$templateNameArr=array();
    if(is_array($templateName)&&!empty($templateName)){
        foreach($templateName as $tempName){
            $templateNameArr[]=$tempName['templatename'];
        }
    }*/


    $sql='select * from ld_tab where name=?';
    $result=$adb->pquery($sql,array('ReportLog'));
    if($adb->num_rows($result)<=0){
        unset($AllAssmablys['24']);

    }
    foreach($RelatedTables as $data=>$modulename)
    {
        $isActive=true;
        $tabs=explode(',',$modulename);
        if($data == 33){
            $activeNum = 0;
            foreach($tabs as $tabname)
            {
                if(vtlib_isModuleActive($tabname))
                {
                    $activeNum+=1;
                }
            }
            if($activeNum>=1){
                $isActive = true;
            }else{
                $isActive = false;
            }
        }else{
            foreach($tabs as $tabname)
            {
                if(!vtlib_isModuleActive($tabname))
                {
                    $isActive=false;
                    break;
                }
            }
        }

        if($modulename==1)
        {
            $isActive=true;
        }

        if($isActive && isset($AllAssmablys[$data]))
        {
            $AllTemplates[$data]=$AllAssmablys[$data];
        }

    }
    //zxm 2021-0329 自定义统计图的可显示在首页
    $AllTemplates = $homestuffObj->getCustomEchartTemplate($AllTemplates);
    /**
     *@edit:andy
     *@date:
     *@reason:左右结构改进，修改默认显示模块
     *@version:
     */
    if(isset($assmablyInfo) && count($assmablyInfo)>0){
         $newarr=array();
        foreach ($assmablyInfo as $key=>$val)
         {
             $newarr[$val[0]] = $val[1];
         }
        //获取差集
        $AllTemplates=array_diff($AllTemplates,$newarr);
    }

    //echo count($new_AllTemplates).'----';

    $smarty->assign('VERSIONTYPE',$versioninfo['versiontype']);
    $smarty->assign('RECEIVESUMMARY',getFixedLabel('Receivables').getFixedLabel('SUMMARY'));
    $smarty->assign('ALLASSMABLYS',$AllTemplates);//all assmablys
    $smarty->assign("ROLEIDSTR",$roleIdStr);
    $smarty->assign("ROLENAMESTR",$roleNameStr);
    $smarty->assign('PROFILEALL',$profileall);
    $smarty->assign('ASSIGNED_VALUES',$assmablyInfo);

    $smarty->assign('TEMPLATENAME',$templateName);//组件模板名称
    $smarty->assign('TEMPLATEID',$templateId);
    $smarty->assign('CMOD',$mod_strings);
    $smarty->assign('APP',$app_strings);
    //$smarty->assign("MOD", return_module_language($current_language,'Settings'));
    $smarty->assign('RETURN_ACTION','listtemplate');
    $smarty->assign("MODE",$mode);
    $smarty->assign('LANGUAGETYPE',$languageType);

    $_REQUEST['diony']='diony';
    if($mode == 'edit')
        $arr['title'] = getFixedLabel('EDIT');
    else
        $arr['title'] = getFixedLabel('LBL_TEMPLATES');
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $str=$smarty->fetch("TemplateEditView.tpl");
    $arr['content']=$str;
    ConvertTojsonString(1,$arr,"success");
    exit();
?>