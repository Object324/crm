<?php

    require_once('SetmenuControl.php');

    //20240614 hzx 后台设置分离
    $parenttabs = [];
    $parenttablist = [];
    $pinyinAlllabel = [];
    $parenttabimagelist = [];
    foreach ($SettingsBlocks as $blockid => $blockname) {
        $parenttabs[$blockname] = getFixedLabel($blockname);

        foreach ($SettingsFields[$blockid] as $index => $fieldinfo){
            if($fieldinfo['fieldid'] && $fieldinfo['fieldid']>0){
                $fieldinfo['label'] = getFixedLabel($fieldinfo['name']);
                $parenttablist[$blockname][] = $fieldinfo;
            }
        }

    }
    global $adb,$current_user;
    $sql = "select ld_desk.fieldlabel,getpinyin(ld_desk.fieldlabel) as pinyin from ld_settings_field LEFT JOIN ld_desk on ld_settings_field.`name` = ld_desk.labelbol where ld_desk.Labeltype = 'fixedstr' and ld_desk.languagetype = 'zh'";
    $result = $adb->pquery($sql,array());
    $num = $adb->num_rows($result);
    if($num > 0){
        for($i = 0;$i<$num;$i++){
            $pinyinAlllabel[$adb->query_result($result,$i,'fieldlabel')] = $adb->query_result($result,$i,'pinyin');
        }
    }


    $defaultIconPath='themes/icon2024/left/light/';
    $sql_icon = 'select label,inactive_icon,active_icon from ld_settings_blocks where blockid in ('.implode(',', array_keys($SettingsBlocks)).')';
    $result_icon = $adb->pquery($sql_icon,array());
    $num_icon = $adb->num_rows($result_icon);
    if($num_icon > 0){
        for($i = 0;$i<$num_icon;$i++){
            $inactive = $adb->query_result($result_icon,$i,'inactive_icon');
            $active = $adb->query_result($result_icon,$i,'active_icon');
            if(file_exists($defaultIconPath.$inactive)){
                $parenttabimagelist[$adb->query_result($result_icon,$i,'label')] = array('inactive'=>$defaultIconPath.$inactive,'active'=>$defaultIconPath.$active);
                if(!file_exists($defaultIconPath.$active)){
                    $parenttabimagelist[$adb->query_result($result_icon,$i,'label')] = array('inactive'=>$defaultIconPath.$inactive,'active'=>$defaultIconPath.$inactive);
                }
            }else{
                $parenttabimagelist[$adb->query_result($result_icon,$i,'label')] = array('inactive'=>'','active'=>'');
            }

        }
    }

    $arr = [];
    $arr['parenttabs'] = $parenttabs;
    $arr['parenttablist'] = $parenttablist;
    $arr['pinyinAlllabel'] = $pinyinAlllabel;
    $arr['parenttabimagelist'] = $parenttabimagelist;

    $arr['current_user_id'] = $current_user->id;

    $arr['MODULE_NAME'] = 'Settings';
    $arr['menufile'] = $_REQUEST['menufile'];
    if($_REQUEST['menufile'] == 'SelfServiceConfig') {
        $arr['selftype'] = $_REQUEST['page_addurl'];

    }

    ConvertTojsonString(1,$arr,'success');
?>