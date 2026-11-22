<?php
//zxm 2021-1210 清除自定义图标
global $adb,$current_user;
$_REQUEST['diony']='yes';
$type = $_REQUEST['type'];
if($current_user->getHaveSetProfile("Settings")!="yes")
{
    ConvertTojsonString(-1,[],'error');
    
}
if ($type=='module'){
    //wym 230414 模块管理->恢复默认图标按钮
    if(isset($_REQUEST['tabid'])){
        $restoreId = $_REQUEST['tabid'];
        $restoreId = rtrim($restoreId,',');
        $sql = "select active_icon from ld_tab where FIND_IN_SET(tabid,?)";
        $result = $adb->pquery($sql,array($restoreId));
        $num_result= $adb->num_rows($result);

        if($num_result>0) {
            for ($i = 0; $i < $num_result; $i++) {
                $active_icon = $adb->query_result($result, $i, 'active_icon');
                unlink(globalStatic::$root_directory.$active_icon);
            }
        }

        $sql = "update ld_tab set active_icon='' where FIND_IN_SET(tabid,?)";
        $adb->pquery($sql,array($restoreId));
    }
    else{
        $sql = "update ld_tab set active_icon=''";
        $adb->pquery($sql);
        delDirPics(globalStatic::$root_directory.'storage/moduleIcon/');
    }
}else if($type=='linkmodule'){
    $sql = "update ld_linkmodulecustom set active_icon=''";
    $adb->pquery($sql);
    delDirPics(globalStatic::$root_directory.'storage/linkModuleIcon/');
}else if($type=='menu'){
    $sql = "update ld_parenttab set active_icon='',inactive_icon=''";
    $adb->pquery($sql);
    delDirPics(globalStatic::$root_directory.'storage/menuIcon/');
}
clearAllCaCheFiles();//清除缓存
ConvertTojsonString(1,array(),'success');




function delDirPics($dir) {
    //先删除目录下的文件：
    $dh=opendir($dir);
    while ($file=readdir($dh)) {
        if($file!="." && $file!="..") {
            $fullpath=$dir."/".$file;
            if(!is_dir($fullpath)) {
                unlink($fullpath);
            } else {
                deldir($fullpath);
            }
        }
    }
    closedir($dh);
}