<?php
global $adb, $current_user ;
require_once globalStatic::$root_directory . 'user_privileges/user_language_' . $current_user->id . '.php';
crm_load_class_file("cls_LinkModuleCustom", 'include/utils');
$smarty = new lingdangCRM_Smarty;
$mode = $_REQUEST['mode'];
$blockid = $_REQUEST['blockid'];
//wym 240130 BUG20240126-22 移动端工作台定制，“自定义报表”编辑界面，已选模块中显示异常
$languageType=getLanguageType($current_user);
if(isset($mode)&& $mode == 'edit')
{
    $alllinkmoduleinfos = cls_LinkModuleCustom::getAllLinkModuleCustomInfo();
    foreach ($alllinkmoduleinfos as $tmpid => $tmplinkmoduleinfo) {
        //zkt 20220418 51114通用问题：PC端--移动端功能，报表定制去除“项目甘特图”选项
        if(stripos($tmplinkmoduleinfo['url'],'gantindex.php')!==false&&$tmplinkmoduleinfo['linkmodule']=='Project')
        {
            continue;
        }
        //zxm 20231117 金蝶库存查询（PC)不应在自定义报表中显示
        if(stripos($tmplinkmoduleinfo['url'],'index.php?module=ReportAnalysis&action=ReportAnalysisAjax&file=stock_report')!==false)
        {
            continue;
        }
        if($tmplinkmoduleinfo['entitytype']!= 'custom'&&$tmplinkmoduleinfo['entitytype']!= 'customfine'){
            continue;
        }
        if ($languageType == 'zh') {
            $tmplabel = $tmplinkmoduleinfo['zh_label'];
        } else {
            $tmplabel = $tmplinkmoduleinfo['en_label'];
        }
        $alltabs[$tmplinkmoduleinfo['id'] . ":ld_linkmodulecustom"] = array('tabid' => $tmplinkmoduleinfo['id'], 'tabname' => $tmplabel, 'tab_tablename' => 'ld_linkmodulecustom');
    }
    $query = 'select block_name,enblock_name,allocatetype,allocateid from ld_mobile_report_parent_tab where block_id = ?';
    $result = $adb->pquery($query, array($blockid));
    $blockname = $adb->query_result($result, 0, 'block_name');
    $enblockname = $adb->query_result($result, 0, 'enblock_name');
    $allocatetype = $adb->query_result($result, 0, 'allocatetype');
    $allocateid = $adb->query_result($result, 0, 'allocateid');
    $presence_result = $adb->pquery('select home_presence from ld_dashboard_app where name = \'customreportblock\'',array());
    $home_presence = $adb->query_result($presence_result,0,'home_presence');
    $presence = $home_presence;
    $query = "select tab_tablename,tabid from ld_mobile_report_tab_rel where block_id = ? ORDER BY sequence";
    $result = $adb->pquery($query, array($blockid));
    $reportrows = $adb->num_rows($result);
    for ($k = 0; $k < $reportrows; $k++) {
        $tab_tablename = $adb->query_result($result, $k, 'tab_tablename');
        $tabid = $adb->query_result($result, $k, 'tabid');
        if ($tab_tablename == 'ld_tab') {
            if (isset($mobile_report_list[$tabid]))
                $havetabs[$mobile_report_list[$tabid]['name'] . ':' . $tab_tablename] = array('tabid' => $mobile_report_list[$tabid]['name'],
                    'tabname' => $mobile_report_list[$tabid]['fieldlabel'], 'tab_tablename' => $tab_tablename);
        } else {
            $tmplinkinfo = cls_LinkModuleCustom::getLinkModuleCustomInfoById($tabid);
            if ($languageType == 'zh') {
                $tmplabel = $tmplinkinfo['zh_label'];
            } else {
                $tmplabel = $tmplinkinfo['en_label'];
            }
            $havetabs[$tabid . ':' . $tab_tablename] = array('tabid' => $tabid, 'tabname' => $tmplabel, 'tab_tablename' => $tab_tablename);
        }
    }
    foreach ($alltabs as $tabid => $tabinfo) {
        if (isset($havetabs[$tabid])) {
            unset($alltabs[$tabid]);
        }
    }
    if (empty($allocatetype)) $allocatetype = 'all';
    $smarty->assign('ALLOCATETYPE', $allocatetype);
    $smarty->assign('ALLOCATEID', $allocateid);

    $smarty->assign('ALLTABS', $alltabs);
    $smarty->assign('HAVETABS', $havetabs);
    $smarty->assign('BLOCKNAME', $blockname);
    $smarty->assign('ENBLOCKNAME', $enblockname);
    $smarty->assign('PRESENCE', $presence);
    $smarty->assign('BLOCKID', $blockid);
	$_REQUEST['diony']='diony';
	$arr['title'] = getFixedLabel('EDIT');
	$arr['oktext']=getFixedLabel("SAVE");
	$arr['canceltext']=getFixedLabel("CANCEL");
	$str=$smarty->fetch("MobileBlock_create.tpl");
	$arr['content']=$str;
	ConvertTojsonString(1,$arr,"success");
}
else if($mode == 'save')
{
    $query = 'select 1 from ld_mobile_report_parent_tab where block_name = ?';
    if(!empty($blockid) && $blockid > 0){
        $query .= ' and ld_mobile_report_parent_tab.block_id != ' .$blockid;
    }
    $result = $adb->pquery($query,array($_REQUEST['mobileblock_name']));
    if($adb->num_rows($result) >= 1){
        ConvertTojsonString(-1,array(),"success");
    }
    $query = 'select 1 from ld_mobile_report_parent_tab where enblock_name = ?';
    if(!empty($blockid) && $blockid > 0){
        $query .= ' and ld_mobile_report_parent_tab.block_id != ' .$blockid;
    }
    $result = $adb->pquery($query,array($_REQUEST['mobileblock_name_en']));
    if($adb->num_rows($result) >= 1){
        ConvertTojsonString(-2,array(),"success");
    }

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
        $sql='select * from ld_mobile_report_parent_tab where block_id=?';
        $result=$adb->pquery($sql,array($blockid));
        $parenttab_label=$adb->query_result($result,0,'parenttab_label');
        $adb->pquery('update ld_mobile_report_parent_tab set block_name=?,enblock_name=?,allocatetype=?,allocateid=? 
                        where block_id = ?',array($_REQUEST['mobileblock_name'],$_REQUEST['mobileblock_name_en'],$allocatetype,$allocateids,$blockid));
        $adb->pquery('delete from ld_mobile_report_tab_rel where block_id = ?',array($blockid));
        //更新自定义报表区块启用状态，即移动端首页显示状态
        $presence = $_REQUEST['presence'];
        $home_presence = 'no';
        if($presence == "yes"){
            $home_presence = 'yes';
        }
        //BUG0066395: 复选框状态无法保存  2023/5/15  余俊
        $adb->pquery('update ld_dashboard_app set home_presence = ? where name = \'customreportblock\'',array($home_presence));
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
            $yuwangresult = $adb->pquery($yuwangsql,array('customfine','CustomReport',$blockid));
            $yuwangrows = $adb->num_rows($yuwangresult);
            for($i=0;$i<$yuwangrows;$i++)
            {
                $linkmoduleid = $adb->query_result($yuwangresult,$i,'id');
                $yuwangupdate = "update ld_mobile_report_tab_rel set checkphp = ? where tabid = ? and tab_tablename = ? and block_id = ?";
                $adb->pquery($yuwangupdate,array('FineRecordgettoken',$linkmoduleid,'ld_linkmodulecustom',$blockid));
            }
        }
    }
    $home_presence_result = $adb->pquery('select home_presence from ld_dashboard_app where name = \'customreportblock\'',array());
    $home_presence = $adb->query_result($home_presence_result,0,'home_presence');
    if($home_presence == 'yes'){
        $arr['reportname'] = $_REQUEST['mobileblock_name'];
        $arr['btntext']=getFixedLabel('INACTIVATE');
        $arr['text']=getFixedLabel('YES');
        $arr['status']='yes';
    }
    else if($home_presence=='no'){
        $arr['reportname'] = $_REQUEST['mobileblock_name'];
        $arr['btntext']=getFixedLabel('ACTIVATE');
        $arr['text']=getFixedLabel('NO');
        $arr['status']='no';
    }
    $arr['blockid'] = $blockid;
    ConvertTojsonString(1,$arr,"success");
}
?>