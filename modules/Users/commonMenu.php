<?php
global $current_user,$adb;
$mode = $_REQUEST['mode'];
$arr = [];
if($mode == 'save'){
    $relid = $_REQUEST['relid'];
    $common_idstr = getUsersettingByLabel('Users',$current_user->id,'CommonMenu');
    if(empty($common_idstr)){
        $common_idarr = [$relid];
    }else{
        $common_idarr = explode(',',$common_idstr);
        if(in_array($relid,$common_idarr)){
            $key = array_search($relid, $common_idarr);
            if ($key !== false) {
                unset($common_idarr[$key]);
            }
        }else{
            if(count($common_idarr) >= 6){
                array_pop($common_idarr);
            }
        }
        $common_idarr = array_merge([$relid],$common_idarr);
    }
    if(count($common_idarr) > 0){
        setUsersettingByLabel('Users',$current_user->id,'CommonMenu',implode(',',$common_idarr),'');
    }
    $module = $_REQUEST['clickmodule'];
    $tabname = $_REQUEST['tabname'];
    $tabid = $_REQUEST['tabid'];
    updateModuleUsage($module.':::'.$tabid.':::'.$tabname);

}
else if($mode == 'getsearch_default'){
    $common_functions = [];
    $common_idstr = getUsersettingByLabel('Users',$current_user->id,'CommonMenu');
    if(!empty($common_idstr)){
        $common_idarr = explode(',',$common_idstr);
        if(count($common_idarr) > 0){
            $query = 'select ld_parenttab.allocatetype,ld_parenttab.allocateid,ld_parenttab.parenttab_label,tmp.*  from 
    ( select ld_parenttabrel.id,ld_parenttabrel.parenttabid,ld_tab.name,ld_parenttabrel.sequence
		,ld_tab.tabid, \'ld_tab\' as tab_tablename, \'\' AS checkphp, \'\' AS isopeninblank from ld_parenttabrel inner join ld_tab 
		on ld_parenttabrel.tabid = ld_tab.tabid  and ld_parenttabrel.tab_tablename=\'ld_tab\'
          and ld_tab.presence in (0,2) 
          union all 
          select ld_parenttabrel.id,ld_parenttabrel.parenttabid,ld_linkmodulecustom.url as name 
          ,ld_parenttabrel.sequence,ld_linkmodulecustom.id as tabid ,\'ld_linkmodulecustom\' as tab_tablename,
          IFNULL(ld_parenttabrel.checkphp,\'\') AS checkphp, IFNULL(ld_parenttabrel.isopeninblank,\'\') AS isopeninblank 
          from ld_parenttabrel
          inner join ld_linkmodulecustom on ld_linkmodulecustom.id=ld_parenttabrel.tabid
          and ld_parenttabrel.tab_tablename=\'ld_linkmodulecustom\'
        ) as tmp 	inner join ld_parenttab 
on tmp.parenttabid = ld_parenttab.parenttabid 
    							where  ld_parenttab.visible=0 and tmp.id in ('.$common_idstr.')';

            $result = $adb->pquery($query,array());
            $rows = $adb->num_rows($result);
            if($rows > 0){
                require_once (globalStatic::$root_directory .'Register/RegOp.php');
                $regop=RegOp::getInstance();
                for($i=0;$i<$rows;$i++){
                    $id = $adb->query_result($result, $i, 'id');
                    $parenttabid = $adb->query_result($result, $i, 'parenttabid');
                    $parenttabname = $adb->query_result($result, $i, 'parenttab_label');
                    $modulename = $adb->query_result($result, $i, 'name');
                    $tablabel = $adb->query_result($result, $i, 'name');
                    $tabid = $adb->query_result($result, $i, 'tabid');
                    $tab_tablename=$adb->query_result($result,$i,'tab_tablename');

                    if($tab_tablename=='ld_linkmodulecustom'){
                        $tabid.='_'.$tab_tablename;
                    }else{
                        if(9 == $tabid) $tabid = 16;
                    }

                    $tmpsocialpromotion=0;
                    $tmparticlesprofile=0;
                    $tmpchannelcodeprofile=0;
                    if(method_exists($regop,'getSocialPromotion'))
                        $tmpsocialpromotion=$regop->getSocialPromotion();
                    if(method_exists($regop,'getarticlesprofile'))
                        $tmparticlesprofile=$regop->getarticlesprofile();
                    if(method_exists($regop,'getchannelcodeprofile'))
                        $tmpchannelcodeprofile=$regop->getchannelcodeprofile();

                    if($modulename=='SocialPromotion'&&empty($tmpsocialpromotion))
                    {
                        continue;
                    }
                    if($modulename=='Articles'&&empty($tmparticlesprofile))
                    {
                        continue;
                    }
                    if($modulename=='ChannelCode'&&empty($tmpchannelcodeprofile))
                    {
                        continue;
                    }
//                    ls 2021-10-26 【ID1001109】增加“小程序商城设置”(未授权不显示菜单)
                    if ($modulename == 'ShopSettings' && !vtlib_isModuleActive($modulename)) continue;
                    $parenttabrelinfo[$parenttabid]['parenttabname'] = 'CommonFunctions';
                    $parenttabrelinfo[$parenttabid]['tab'][$tabid]['id'] = $id;
                    $parenttabrelinfo[$parenttabid]['tab'][$tabid]['modulename'] = $modulename;
                    $parenttabrelinfo[$parenttabid]['tab'][$tabid]['tablabel'] = $tablabel;

                    $parenttabrelinfo[$parenttabid]['tab'][$tabid]['tab_tablename'] = $tab_tablename;
                    $parenttabrelinfo[$parenttabid]['tab'][$tabid]['allocatetype'] =  $adb->query_result($result, $i, 'allocatetype');
                    $parenttabrelinfo[$parenttabid]['tab'][$tabid]['allocateid'] =  $adb->query_result($result, $i, 'allocateid');
                    $parenttabrelinfo[$parenttabid]['tab'][$tabid]['checkphp'] =  $adb->query_result($result, $i, 'checkphp');
                    $parenttabrelinfo[$parenttabid]['tab'][$tabid]['isopeninblank'] =  $adb->query_result($result, $i, 'isopeninblank');
                    $parenttabrelinfo[$parenttabid]['tab'][$tabid]['parenttabname'] =  $parenttabname;

                }
            }
        }

        crm_load_class_file('MenuUtils','modules/Users');
        $MenuUtilsObj = new MenuUtils();
        $parenttablist= $MenuUtilsObj->getAllParenttabmoduleslistbyuser($parenttabrelinfo);
        foreach ($parenttablist['CommonFunctions'] as $index => &$parenttabrel){
            foreach ($parenttabrelinfo as $parentid => $parentinfo){
                foreach ($parentinfo['tab'] as $tab_id => $tab_info){
                    if($parenttabrel['id'] == $tab_info['id']){
                        $parenttabrel['parenttabname'] = $tab_info['parenttabname'];
                        break;
                    }
                }
            }
        }

        $tmp_array = [];
        for($i = 0;$i<count($common_idarr);$i++){
            foreach ($parenttablist['CommonFunctions'] as $index => $parenttabrel){
                if($parenttabrel['id'] == $common_idarr[$i]){
                    $tmp_array[] = $parenttabrel;
                    break;
                }
            }
        }
        $common_functions['CommonFunctions'] = $tmp_array;
    }

    $history_arr = [];
    $history_srt = getUsersettingByLabel('Users',$current_user->id,'MenuSearchHistory');
    if(!empty($history_srt)){
        $history_arr = explode(',',$history_srt);
    }


    $smarty = new lingdangCRM_Smarty();
    $smarty->assign("PARENTTABLIST",$common_functions);

    $smarty->assign("HISTORY_ARR",$history_arr);

    require(globalStatic::$root_directory.'dataCache/tabdatas/parent_language.php');
    $parent_label = [];
    $languageType=getLanguageType($current_user);
    if($languageType == 'en'){
        $parent_label=$enparent_string;
    }
    else{
        $parent_label=$parent_string;
    }
    $parent_label['CommonFunctions'] = getFixedLabel('CommonFunctions');
    $smarty->assign("PARENTTAB_LABEL",$parent_label);

    $cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
    $smarty->assign("cls_UrlEncryptyJudgeobj",$cls_UrlEncryptyJudgeobj);
    $str = $smarty->fetch('menusearchpopup_default.tpl');
    $arr['content']=$str;
}
else if($mode == 'savesearchhistory'){
    $searchtext = str_replace("'","",$_REQUEST['searchtext']);

    $history_arr = [];

    $history_str = getUsersettingByLabel('Users',$current_user->id,'MenuSearchHistory');

    if(empty($history_str)){
        $history_arr = [$searchtext];
    }else{
        $history_arr = explode(',',$history_str);
        if(in_array($searchtext,$history_arr)){
            $key = array_search($searchtext, $history_arr);
            if ($key !== false) {
                unset($history_arr[$key]);
            }
        }else{
            if(count($history_arr) >= 20){
                array_pop($history_arr);
            }
        }
        $history_arr = array_merge([$searchtext],$history_arr);
    }
    if(count($history_arr) > 0){
        setUsersettingByLabel('Users',$current_user->id,'MenuSearchHistory',implode(',',$history_arr),'');
    }
}
else if($mode == 'deletehistory'){
    setUsersettingByLabel('Users',$current_user->id,'MenuSearchHistory','','');
}
ConvertTojsonString(1,$arr,'success');
?>