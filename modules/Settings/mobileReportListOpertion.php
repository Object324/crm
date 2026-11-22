<?php
//editor:gyq_159 reason:系统设置增加移动端报表菜单定制  2019/11/7 19:31 ID1000638
global $adb, $current_user,$languageType;
require_once globalStatic::$root_directory . 'user_privileges/user_language_' . $current_user->id . '.php';
crm_load_class_file("cls_LinkModuleCustom", 'include/utils');
$smarty = new lingdangCRM_Smarty;
$actionType = $_REQUEST['type'];
$blockid = $_REQUEST['blockid'];
$menu_user_type = 'crm';
$regopobj=RegOp::getInstance();
$prmauthenmodule_arr=explode(",",$regopobj->getPrmModules());
switch ($actionType) {
        //编辑显示模块
    case 'mobile_block_edit':
        //新增区块
    case 'mobile_block_create':
    if ($actionType == 'mobile_block_edit') {
        $query = 'select block_name,enblock_name,presence,allocatetype,allocateid,menudescription,menu_user_type from ld_mobile_report_parent_tab where block_id = ?';
        $editresult = $adb->pquery($query, array($blockid));
        $menu_user_type = $adb->query_result($editresult, 0, 'menu_user_type');
    }

        $profile = new Profile();
        $reports = $profile->getMobileReportNames();
        $mobile_report_list = array();
        foreach ($reports as $key => $value) {
            $mobile_report_list[$value['id']] = $value;
        }

        //editor:gyq_20191111 reason:0038517: （kfbcrm）移动端报表菜单定制中，新增的自定义链接模块应该放在可选模块的最上方
        $alllinkmoduleinfos = cls_LinkModuleCustom::getAllLinkModuleCustomInfo();
        foreach ($alllinkmoduleinfos as $tmpid => $tmplinkmoduleinfo) {
            $linkmodule=$tmplinkmoduleinfo['linkmodule'];
            $entitytype=$tmplinkmoduleinfo['entitytype'];
            if($linkmodule=='CustomEcharts'||$linkmodule=='CustomTables'||$linkmodule=='Customreport'||$linkmodule=='OftenUseReport'){
                $linkmodule='ReportAnalysis';
            }else if($entitytype=='category'){
                //BUG20241028-16 //zxm @date:2024/10/30 @reason: 数据分类设置成的连接模块不应该在报表页签被选择到
                continue;
            }


            if($menu_user_type=='prm'&& !in_array($linkmodule,$prmauthenmodule_arr))
            {
                continue;
            }
            //zkt 20220418 51114通用问题：PC端--移动端功能，报表定制去除“项目甘特图”选项
            if(stripos($tmplinkmoduleinfo['url'],'gantindex.php')!==false&&$tmplinkmoduleinfo['linkmodule']=='Project')
            {
                continue;
            }
            //zxm 20230417 金蝶库存查询(PC)应当在移动端菜单定制的时候选择不到
            if(stripos($tmplinkmoduleinfo['url'],'file=stock_report')!==false)
            {
                continue;
            }
            //zxm 2021-1221 049340: （81mis.com/kfbcrm/index.php）系统设置》移动端报表菜单定制》设置菜单时，不应显示图表的链接模块，应只显示报表库的链接模块
            //if($tmplinkmoduleinfo['linkmodule']!='CustomTables'&&$tmplinkmoduleinfo['linkmodule']!='CustomEcharts') {
                if ($languageType == 'zh') {
                    $tmplabel = $tmplinkmoduleinfo['zh_label'];
                } else {
                    $tmplabel = $tmplinkmoduleinfo['en_label'];
                }
                $alltabs[$tmplinkmoduleinfo['id'] . ":ld_linkmodulecustom"] = array('tabid' => $tmplinkmoduleinfo['id'], 'tabname' => $tmplabel, 'tab_tablename' => 'ld_linkmodulecustom');
            //}
        }
        foreach ($reports as $index => $val) {
            $alltabs[$val['name'] . ":ld_tab"] = array('tabid' => $val['name'], 'tabname' => $val['fieldlabel'], 'tab_tablename' => 'ld_tab');
        }
        if ($actionType == 'mobile_block_edit') {
         //   $query = 'select block_name,enblock_name,presence,allocatetype,allocateid,menudescription,menu_user_type from ld_mobile_report_parent_tab where block_id = ?';
            $result =$editresult;// $adb->pquery($query, array($blockid));
            $blockname = $adb->query_result($result, 0, 'block_name');
            $enblockname = $adb->query_result($result, 0, 'enblock_name');
            $presence = $adb->query_result($result, 0, 'presence');
            $allocatetype = $adb->query_result($result, 0, 'allocatetype');
            $allocateid = $adb->query_result($result, 0, 'allocateid');
            $menudescription = $adb->query_result($result, 0, 'menudescription');
            $menu_user_type = $adb->query_result($result, 0, 'menu_user_type');
            // $tab_tablename=$adb->query_result($result,0,'tab_tablename');
            $query = "select tab_tablename,tabid from ld_mobile_report_tab_rel where block_id = ? ORDER BY sequence";
            $result = $adb->pquery($query, array($blockid));
            $reportrows = $adb->num_rows($result);
            for ($k = 0; $k < $reportrows; $k++) {
                $tab_tablename = $adb->query_result($result, $k, 'tab_tablename');
                $tabid = $adb->query_result($result, $k, 'tabid');
                if ($tab_tablename == 'ld_tab') {
                    //这里都是移动端报表的数据  ld_tab判断不正确   存的tabid实际上是ld_dashboard_app表的id
                    /*if(!vtlib_isModuleActive( getTabname($tabid)))
                    {
                        continue;
                    }
                    if($menu_user_type=='prm')
                    {
                        if(!in_array(getTabname($tabid),$prmauthenmodule_arr))
                        {
                            continue;
                        }

                    }*/
                    if (isset($mobile_report_list[$tabid]))
                        $havetabs[$mobile_report_list[$tabid]['name'] . ':' . $tab_tablename] = array('tabid' => $mobile_report_list[$tabid]['name'],
                            'tabname' => $mobile_report_list[$tabid]['fieldlabel'], 'tab_tablename' => $tab_tablename);
                } else {
                    $tmplinkinfo = cls_LinkModuleCustom::getLinkModuleCustomInfoById($tabid);
                    $linkmodule=$tmplinkinfo['linkmodule'];
                    if($linkmodule=='CustomEcharts'||$linkmodule=='CustomTables'||$linkmodule=='Customreport'||$linkmodule=='OftenUseReport')
                        $linkmodule='ReportAnalysis';
                    if($menu_user_type=='prm'&&$linkmodule!=''&&(!vtlib_isModuleActive($linkmodule)||!in_array($linkmodule,$prmauthenmodule_arr)))
                    {
                        continue;
                    }
                    //zxm 2021-1221 049340: （81mis.com/kfbcrm/index.php）系统设置》移动端报表菜单定制》设置菜单时，不应显示图表的链接模块，应只显示报表库的链接模块
                    //if($tmplinkinfo['linkmodule']!='CustomTables'&&$tmplinkinfo['linkmodule']!='CustomEcharts') {
                        if ($languageType == 'zh') {
                            $tmplabel = $tmplinkinfo['zh_label'];
                        } else {
                            $tmplabel = $tmplinkinfo['en_label'];
                        }
                        $havetabs[$tabid . ':' . $tab_tablename] = array('tabid' => $tabid, 'tabname' => $tmplabel, 'tab_tablename' => $tab_tablename);
                    //}
                }
            }
            foreach ($alltabs as $tabid => $tabinfo) {
                if (isset($havetabs[$tabid])) {
                    unset($alltabs[$tabid]);
                }
            }
        }
        if (empty($allocatetype)) $allocatetype = 'all';
        $smarty->assign('ALLOCATETYPE', $allocatetype);
        $smarty->assign('ALLOCATEID', $allocateid);
        $smarty->assign('MENUDESCRIPTION', $menudescription);
        $smarty->assign('ALLTABS', $alltabs);
        $smarty->assign('HAVETABS', $havetabs);
        $smarty->assign('BLOCKNAME', $blockname);
        $smarty->assign('ENBLOCKNAME', $enblockname);
        $smarty->assign('menu_user_type', $menu_user_type);
        $smarty->assign('FUNCTIONMENUDESCRIPTION', getFixedLabel('Table').getFixedLabel('MENU').getFixedLabel('CAMCARDCAPTION'));
        //edit: xll 2023/08/16 BUG0071012 报表区块的启用状态需要和原启用状态保持一致
        $presence = ($presence == '0') ? 'yes' : $presence;// 0: 开启
        $smarty->assign('PRESENCE', $presence);
        $smarty->assign('BLOCKID', $blockid);
        //$smarty->display('MobileBlock_create.tpl');
		$_REQUEST['diony']='diony';
		if(!empty($parenttabid)){
			$arr['title'] = getFixedLabel('EDIT');
		}else{
			$arr['title'] = getFixedLabel('report_menu_customization');
		}
		$arr['oktext']=getFixedLabel("SAVE");
		$arr['canceltext']=getFixedLabel("CANCEL");
		$str=$smarty->fetch("MobileBlock_create.tpl");
		$arr['content']=$str;
		ConvertTojsonString(1,$arr,"success");
		exit();

        break;
        //检测区块名是否重复
    case 'checkblockname':
        //中文名称是否重复
        $query = 'select 1 from ld_mobile_report_parent_tab where block_name = ?';
        if(!empty($blockid) && $blockid > 0){
            $query .= ' and ld_mobile_report_parent_tab.block_id != ' .$blockid;
        }
        $result = $adb->pquery($query,array($_REQUEST['mobileblock_name']));
        if($adb->num_rows($result) >= 1){
            echo 'error';
            break;
        }
        //英文名称是否重复
        $query = 'select 1 from ld_mobile_report_parent_tab where enblock_name = ?';
        if(!empty($blockid) && $blockid > 0){
            $query .= ' and ld_mobile_report_parent_tab.block_id != ' .$blockid;
        }
        $result = $adb->pquery($query,array($_REQUEST['mobileblock_name_en']));
        if($adb->num_rows($result) >= 1){
            echo 'enrepeat';
            break;
        }
        break;
        //区块编辑后的保存
    case 'SaveMobileBlock':
        $allocatetype=$_REQUEST['customscope_type'];//可见范围设置
        $allocateids=$_REQUEST['customscope_ids'];//可见范围设置
        if($allocatetype=='')
        {
            $allocatetype='all';
        }
        if($allocatetype=='all')
        {
            $allocateids='';
        }
        if(!empty($blockid)){
            $sql='select * from ld_mobile_report_parent_tab where block_id=? ';
            $result=$adb->pquery($sql,array($blockid));
            $parenttab_label=$adb->query_result($result,0,'parenttab_label');
            $menu_user_type=$adb->query_result($result,0,'menu_user_type');
            $adb->pquery('update ld_mobile_report_parent_tab set block_name=?,enblock_name=?,presence=?,allocatetype=?,allocateid=? ,menudescription=?
                            where block_id = ?',array($_REQUEST['mobileblock_name'],$_REQUEST['mobileblock_name_en'],$_REQUEST['presence'],$allocatetype,$allocateids,$_REQUEST['menudescription'],$blockid));
            $adb->pquery('delete from ld_mobile_report_tab_rel where block_id = ?',array($blockid));
        }else{
            $query = 'select IFNULL(max(sequence),0) as max_sequence from ld_mobile_report_parent_tab';
            $result = $adb->pquery($query,array());
            $max_sequence = $adb->query_result($result,0,0);
            $adb->pquery('insert into ld_mobile_report_parent_tab (block_name,enblock_name,presence,sequence,allocatetype,allocateid,menudescription) 
                            values (?,?,?,?,?,?,?)',array($_REQUEST['mobileblock_name'],$_REQUEST['mobileblock_name_en'],$_REQUEST['presence'],$max_sequence+1,$allocatetype,$allocateids,$_REQUEST['menudescription']));
            $blockid = $adb->getLastInsertID();
        }
        if(!empty($_REQUEST['tabids'])){
            $tabid_arr = explode(',',$_REQUEST['tabids']);
            $profile=new Profile();
            $mobilereports=$profile->getMobileReportNames();
            foreach($tabid_arr as $key => $relatename){
                $reportid=0;
                $tmprelatenames=explode(':',$relatename);
                $tmprelatename=$tmprelatenames[0];
                $tab_tablename=$tmprelatenames[1];
                foreach($mobilereports as $index=>$info)
                {
                    if($info['name']==$tmprelatename)
                    {
                        $reportid=$info['id'];
                        break;
                    }
                }
                if(empty($reportid)&&$tab_tablename=='ld_tab')
                {
                    continue;
                }
                if($tab_tablename=='ld_linkmodulecustom')
                {
                    $reportid=$tmprelatename;
                }
                $adb->pquery('insert into ld_mobile_report_tab_rel (block_id,tabid,sequence,tab_tablename) values
                             (?,?,?,?)',array($blockid,$reportid,$key+1,$tab_tablename));
            }
            $version_info = getVersionInfo();
            if($version_info['account']=='yuwang')
            {
                //zkt 禹王设置帆软报表连接模块至移动端报表区块
                $yuwangsql = "select ld_linkmodulecustom.id as id from ld_linkmodulecustom
                    left join ld_mobile_report_tab_rel on ld_mobile_report_tab_rel.tabid = ld_linkmodulecustom.id and tab_tablename = 'ld_linkmodulecustom'
                     where entitytype = ? and linkmodule = ? and block_id = ?";
                $yuwangresult = $adb->pquery($yuwangsql,array('customfine','Customreport',$blockid));
                $yuwangrows = $adb->num_rows($yuwangresult);
                for($i=0;$i<$yuwangrows;$i++)
                {
                    $linkmoduleid = $adb->query_result($yuwangresult,$i,'id');
                    $yuwangupdate = "update ld_mobile_report_tab_rel set checkphp = ? where tabid = ? and tab_tablename = ? and block_id = ?";
                    $adb->pquery($yuwangupdate,array('FineRecordgettoken',$linkmoduleid,'ld_linkmodulecustom',$blockid));
                }
            }
        }

        unsetCacheDirectory('wxmodules');
        include globalStatic::$root_directory.'modules/Settings/reportMenuCustomization.php';
        break;
        //删除区块
    case 'deleteblock':
        $adb->pquery('delete from ld_mobile_report_parent_tab where block_id = ?',array($_REQUEST['block_id']));
        $adb->pquery('delete from ld_mobile_report_tab_rel where block_id = ?',array($_REQUEST['block_id']));
        unsetCacheDirectory('wxmodules');
        include globalStatic::$root_directory.'modules/Settings/reportMenuCustomization.php';
        break;
        //区块排序
    case 'mobile_block_sort':
        global $languageType;
        $query = 'select block_id,sequence,block_name,enblock_name from ld_mobile_report_parent_tab where presence in(0,1) ORDER BY sequence asc';
        $result = $adb->pquery($query, array());
        $num_rows = $adb->num_rows($result);
        if ($num_rows > 0) {
            for ($i = 0; $i < $num_rows; $i++) {
                $blockid = $adb->query_result($result, $i, 'block_id');
                $sequence = $adb->query_result($result, $i, 'sequence');
                $blockname = $adb->query_result($result, $i, 'block_name');
                $enblockname = $adb->query_result($result, $i, 'enblock_name');
                if($languageType == 'en'){
                    $allblocks[$blockid] = array('sequence' => $sequence, 'blockname' => $enblockname);
                }else{
                    $allblocks[$blockid] = array('sequence' => $sequence, 'blockname' => $blockname);
                }
            }
        }
        $arr['title'] = getFixedLabel('SortMenu');
        $arr['oktext']=getFixedLabel("SAVE");
        $arr['canceltext']=getFixedLabel("CANCEL");
        $smarty->assign('ALLBLOCKS',$allblocks);
        $str=$smarty->fetch("MobileBlock_sort.tpl");
        $arr['content']=$str;
        ConvertTojsonString(1,$arr,"success");
        break;
        //区块排序后的保存
    case 'SaveMobileBlockSort':
        if(!empty($_REQUEST['tabids'])){
            $tabids_arr = explode(',',$_REQUEST['tabids']);
            $sequence = 1;
            foreach($tabids_arr as $blockid){
                $adb->pquery('update ld_mobile_report_parent_tab set sequence = ? where block_id = ?',array($sequence,$blockid));
                $sequence++;
            }
        }
        unsetCacheDirectory('wxmodules');
        include globalStatic::$root_directory.'modules/Settings/reportMenuCustomization.php';
        break;
}

exit();
?>