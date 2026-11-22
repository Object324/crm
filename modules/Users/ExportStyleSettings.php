<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
global $current_user;

$module = $_REQUEST['frommodule'];
$mode = $_REQUEST['mode'];
$type = 'Export';
$label = 'exportstyle';
if($mode == 'edit'){
    $strhtml='<div class="ld-public-content-small">
		<form method="post">
    		<div class="ld-form-item-div">
        		<div class="ld-form-item-label">'.getFixedLabel('SetExportStyledefault').'</div>
        		<div class="ld-form-item-content">
        		    <select class="ld-select-inner" name="export_style">';
                    $exportstyle_arr = array('multicolheader','firstcolheader','onlycolheader');
                    $exportstyle_selected = 'firstcolheader';
                    //获取数据库设置的值
                    $sql = 'select * from ld_module_setting_byuser where type=? and label=? and userid=? and modulename=?';
                    $result = $adb->pquery($sql,array($type,$label,$current_user->id,$module));
                    if($adb->num_rows($result)>0){
                        $exportstyle_selected = $adb->query_result($result,0,'content');
                    }
                    
                    foreach($exportstyle_arr as $tmpexportstyle){
                        $selected = '';
                        if($tmpexportstyle == $exportstyle_selected){
                            $selected = 'selected';
                        }
                        $strhtml .= '<option value="'.$tmpexportstyle.'" '.$selected.'>'.getFixedLabel('Export'.$tmpexportstyle).'</option>';
                    }
                    $strhtml .='</select>
        		</div>
    		</div>
        </form>
		</div>';
    $arr['oktext']=getFixedLabel("SAVE");
    $arr['canceltext']=getFixedLabel("CANCEL");
    $arr['title']=getFixedLabel("SetDefaultValue");
    $arr['content']=$strhtml;
    ConvertTojsonString(1,$arr,'success');
}
else if($mode == 'save'){
    $exportstyle_default = $_REQUEST['exportstyle_default'];
    //获取数据库设置的值
    $sql = 'select * from ld_module_setting_byuser where type=? and label =? and userid=? and modulename=?';
    $result = $adb->pquery($sql,array($type,$label,$current_user->id,$module));
    if($adb->num_rows($result)>0){
        $id = $adb->query_result($result,0,'id');
        $adb->pquery('update ld_module_setting_byuser set content = ? where id=?',array($exportstyle_default,$id));
    }
    else{
        $adb->pquery('insert into  ld_module_setting_byuser(modulename,userid,type,label,content) value(?,?,?,?,?)',
                array($module,$current_user->id,$type,$label,$exportstyle_default));
    }
    ConvertTojsonString(1,array(),'success');
}
?>