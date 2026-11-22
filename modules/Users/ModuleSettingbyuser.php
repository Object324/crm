<?php
//按用户按模块的设置保存
global $currentModule, $current_user;
$_REQUEST['diony']='yes';
$label=$_REQUEST['label'];
$module=$_REQUEST['curmodule'];
$notbymodule_Arr=['EditFullscreen','Fullscreen'];//部分label不需要按模块保存
$defaultlabel_Arr=['EditFullscreen'=>'yes'];//label对应的默认值
if(in_array($label,$notbymodule_Arr)){
    $module='notbymodule';
}
$arr=[];
if($_REQUEST['mode']=='get'){
    $content=getUsersettingByLabel($module, $current_user->id, $label);
    //默认值
    if(empty($content) && array_key_exists($label,$defaultlabel_Arr)){
        $content = $defaultlabel_Arr[$label];
    }
    $arr['content']=$content;
    ConvertTojsonString(1,$arr,"success");
} else if($_REQUEST['mode']=='save'){
    $content= $_REQUEST['content'];
    if($content){
        setUsersettingByLabel($module, $current_user->id, $label, $content);
    }
    ConvertTojsonString(1,$arr,"success");
}
ConvertTojsonString(-1,$arr,"fail");
?>