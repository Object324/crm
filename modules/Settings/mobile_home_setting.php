
<?php

if($_REQUEST['from_module']=='MobileReport'){
    include  globalStatic::$root_directory.'modules/Home/HomeboardListview.php';
    die;
}

//editor:gyq_141 reason:移动端增加首页标签  2019/9/3 16:39 ID1000602
 crm_load_class_file('cls_StaticCommonFun','WeiXinApp/WeiXin_common');
 $_REQUEST['diony']='yes';
 global $current_user;

global $adb;
if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
    //更改报表显示状态
    if($_REQUEST['second_action']=='change_active'){
        $_REQUEST['diony']='diony';
        $report_name = $_REQUEST['report_name'];
        $sql = 'SELECT id,NAME,graphtype,modulenames,image,labelbol,home_presence,home_sequence
        FROM ld_dashboard_app WHERE  NAME=?';
        $result = $adb->pquery($sql,array($report_name));
      
        if($adb->num_rows($result) > 0){
            $home_presence = $adb->query_result($result,0,'home_presence');
           //edit:can 2020-10-15 42837: (61mis.com/kfbcrm)系统设置-界面设置-移动端首页定制（客户问题）；点击没有启用的功能，会显示underfind。（需要补丁）
            if($home_presence=='yes'||$home_presence==''){
                //至少需要启用一个报表
                $sql = 'SELECT id,NAME,graphtype,modulenames,image,labelbol,home_presence,home_sequence
        FROM ld_dashboard_app WHERE  home_presence=\'yes\'';
                $result = $adb->pquery($sql,array());
                if($adb->num_rows($result) < 2){
                    ConvertTojsonString(-1,array(),getFixedLabel('mobile_home_remind_one'));
                }
                $arr['btntext']=getFixedLabel('ACTIVATE');
                $arr['text']=getFixedLabel('NO');
                $arr['status']='no';
                $sql = 'update ld_dashboard_app set home_presence=? WHERE  NAME=?';
                $adb->pquery($sql,array('no',$report_name));
            }elseif($home_presence=='no'){
                $arr['btntext']=getFixedLabel('INACTIVATE');
                $arr['text']=getFixedLabel('YES');
                $arr['status']='yes';
                $sql = 'update ld_dashboard_app set home_presence=? WHERE  NAME=?';
                $adb->pquery($sql,array('yes',$report_name));
            }
        }
       
        ConvertTojsonString(1,$arr,'success');
        //更改报表显示顺序，第一步获取报表列
    }elseif($_REQUEST['second_action']=='report_sort'){
        $query = 'select id,home_sequence,NAME,labelbol from ld_dashboard_app where home_presence=\'yes\' ORDER BY home_sequence asc';
        $result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0){
            for($i = 0; $i<$num_rows; $i++){
                $blockid = $adb->query_result($result,$i,'id');
                $sequence = $adb->query_result($result,$i,'home_sequence');
                $blockname = $adb->query_result($result,$i,'name');
                $labelbol = $adb->query_result($result,$i,'labelbol');
                $allblocks[$blockid] = array('sequence'=>$sequence,'blockname'=>getFixedLabel($labelbol));
            }
        }
        $smarty->assign('ALLBLOCKS',$allblocks);
        $smarty->display('Settings/wechat_miniprogram/mobile_home_sort.tpl');
        //更改报表显示顺序，第二步保存
    }elseif($_REQUEST['second_action']=='save_sort'){
        if(!empty($_REQUEST['tabids'])){
            $tabids_arr = explode(',',$_REQUEST['tabids']);
            $sequence = 1;
            foreach($tabids_arr as $blockid){
                $adb->pquery('update ld_dashboard_app set home_sequence = ? where id = ?',array($sequence,$blockid));
                $sequence++;
            }
        }
        $smarty=new lingdangCRM_Smarty;
        $smarty->assign('TAB',$tab);
        $list_content = get_home_report_list();
        $smarty->assign('LISTCONTENT',$list_content);
        setGLobalURLSmarty($smarty);
        $smarty->display('Settings/wechat_miniprogram/mobile_home_list.tpl');
    }
}else{
    if(isset($_REQUEST['blockid']) && $_REQUEST['blockid'])
        $blockid=$_REQUEST['blockid'];
    $smarty=new lingdangCRM_Smarty;
    $smarty->assign('TAB',$tab);
    $list_content = get_home_report_list();
    $smarty->assign('LISTCONTENT',$list_content);
    $smarty->assign('MODULENAME',$modulename);
    $smarty->assign('BLOCKIDSETTING',$_REQUEST['blockidsetting']);
    $smarty->assign('FIELDIDSETTING',$_REQUEST['fieldidsetting']);
    $smarty->assign('BLOCKID',$blockid);
    // require_once('SetmenuControl.php');
    setGLobalURLSmarty($smarty);
    $arr['title']= getFixedLabel('Default_Kanban');
    $arr['content']=$smarty->fetch('Settings/wechat_miniprogram/mobile_home_setting.tpl');
    ConvertTojsonString(1,$arr,'success');
}
//reason:获取首页标签模块列表  2019/9/5 11:36
function get_home_report_list(){
    global $adb;
    crm_load_class_file('cls_Home_SpecialMC','appCommon/modules/Home');
    //editor:gyq_159 reason:系统设置增加移动端报表菜单定制  2019/11/8 17:19 ID1000638
    //有权限可显示的移动端报表
    $available_list_one = cls_Home_SpecialMC::getWXReportList();
    $available_list_two = array();
    foreach ($available_list_one as $key1=>$value1){
        foreach ($value1['list'] as $key2=>$value2){
            $available_list_two[$value2['orign_name']] = $value2;
        }

    }

    $query='SELECT id,NAME,graphtype,modulenames,image,labelbol,home_presence,home_sequence
        FROM ld_dashboard_app WHERE  home_sequence>0 order by home_presence desc,home_sequence asc';
    $result=$adb->pquery($query,array());
    $num_rows=$adb->num_rows($result);
    $list_content=array();
    if($num_rows){
        $j = 0;
        for($i=0;$i<$num_rows;$i++){
            $report_name = $adb->query_result($result,$i,'name');
            if(!array_key_exists($report_name,$available_list_two)&&($report_name!='keyViews'&&$report_name!='customreportblock'&&$report_name!='commonmodules')){
                continue;
            }
            $list_content[$j]['name'] = $report_name;
            //获取自定义报表区块的名称
            if($report_name == 'customreportblock')
            {
                $custom_result=$adb->pquery("select block_name,block_id from ld_mobile_report_parent_tab where presence =2 and parenttab_label = 'customreportblock'",array());
                $custom_rows = $adb->num_rows($custom_result);
                if($custom_rows>0){
                    $labelol = $adb->query_result($custom_result,0,'block_name');
                    $blockid = $adb->query_result($custom_result,0,'block_id');
                    $list_content[$j]['labelbol'] = $labelol;
                    $list_content[$j]['blockid'] = $blockid;
                }
            }
            if(!isset($list_content[$j]['labelbol'])){
                $list_content[$j]['labelbol'] = getFixedLabel($adb->query_result($result,$i,'labelbol'));
            }
            $list_content[$j]['home_presence'] = $adb->query_result($result,$i,'home_presence');
            $j++;
        }
    }
    return $list_content;
}

?>