<?php
/********************************************************
**更新操作
**edit:kevin
**date:2013-11-14
**reason:保存菜单
********************************************************/
global $adb,$default_charset;
$smarty=new lingdangCRM_Smarty;
$parentchinese = '';
$parentenglish = '';
$parentindex = '';
$tabids = '';
if (isset($_REQUEST['parentchinese']) && $_REQUEST['parentchinese'] != '')
    $parentchinese = $_REQUEST['parentchinese'];
if (isset($_REQUEST['parentenglish']) && $_REQUEST['parentenglish'])
    $parentenglish = $_REQUEST['parentenglish'];
if (isset($_REQUEST['parentindex']) && $_REQUEST['parentindex'])
    $parentindex = $_REQUEST['parentindex'];
if (isset($_REQUEST['selectedtabColumnsString']) && $_REQUEST['selectedtabColumnsString'] != '')
    $tabids = $_REQUEST['selectedtabColumnsString'];
$tabids=mb_substr($tabids,0,strlen($tabids)-1,$default_charset);
$tabarr=explode(';',$tabids);
if(isset($_REQUEST['parenttabid']) && $_REQUEST['parenttabid'])
$parenttabid=$_REQUEST['parenttabid'];
if(isset($_REQUEST['visible']) && $_REQUEST['visible'])
	$visible=$_REQUEST['visible'];
$customscope_type = $_REQUEST['customscope_type'];
if(empty($customscope_type))$customscope_type = 'all';
$customscope_ids = $_REQUEST['customscope_ids'];
$labelid = $parenttabid;
if(empty($parenttabid)) {
    $sql_sequence = "select max(parenttabid)+ 1 as parenttabid from ld_parenttab";
    $result_sequence = $adb->query($sql_sequence);
    $parenttabid_new = $adb->query_result($result_sequence, 0, 'parenttabid');
    $labelid = $parenttabid_new;
}
//zxm 2021-1206 上传菜单图标
$update_fields = [];
$insert_fields = [];
$update_values = [];
$insert_values = [];
$error_msg = '';
if(isset($_FILES['inactive_icon'])){
    $inactive_icon = iconUpload('inactive_icon',$labelid);
    $update_fields[] = 'inactive_icon=?';
    $insert_fields[] = 'inactive_icon';
    $update_values[] = $inactive_icon['filepath'];
    $insert_values[] = "'".$inactive_icon['filepath']."'";
    if(!empty($inactive_icon['errorInfo'])){
        $error_msg = '未选中图标上传失败：'.$inactive_icon['errorInfo'];
        ConvertTojsonString(-1,array(),$error_msg);
    }
}
if(isset($_FILES['active_icon'])){
    $active_icon = iconUpload('active_icon',$labelid);
    $update_fields[] = 'active_icon=?';
    $insert_fields[] = 'active_icon';
    $update_values[] = $active_icon['filepath'];
    $insert_values[] = "'".$active_icon['filepath']."'";
    if(!empty($active_icon['errorInfo'])){
        $error_msg = '选中图标上传失败：'.$active_icon['errorInfo'];
        ConvertTojsonString(-1,array(),$error_msg);
    }
}
if(!empty($update_fields)){
    $update_values[] = $labelid;
    $update_fields = ','.implode(',',$update_fields);
    $insert_fields = ','.implode(',',$insert_fields);
    $insert_values = ','.implode(',',$insert_values);
}else{
    $update_values[] = $labelid;
    $update_fields = '';
}


if(empty($parenttabid)){
    $parenttabid = $parenttabid_new;
    $parenttablelabel=$parentenglish.'_'.$parentindex;
    //edit:can 2020-10-27 43039: (http://47.92.171.64/wd_test/ [^])系统设置-网页端菜单定制(梁文乐客户问题)；客户新增了网页端菜单，英文名和付款菜单一致，但导致原付款菜单栏不显示了；kfbcrm新增菜单英文名和原菜单一致时，则会导致新增的原中文名变为新增的菜单名
    if(!empty($update_fields)){
	$sql="insert into ld_parenttab(parenttabid,parenttab_label,sequence,visible,allocatetype,allocateid $insert_fields) 
	values('$parenttabid','$parenttablelabel','$parentindex','$visible','$customscope_type','$customscope_ids' $insert_values)";
    }
    else
    {
        	$sql="insert into ld_parenttab(parenttabid,parenttab_label,sequence,visible,allocatetype,allocateid ) 
	values('$parenttabid','$parenttablelabel','$parentindex','$visible','$customscope_type','$customscope_ids' )";
    }
	$adb->query($sql);
}else{
	$query="update ld_parenttab set `sequence`=?,visible=?,allocatetype=?,allocateid=? $update_fields where parenttabid=?";
	$update_values = array_merge(array($parentindex,$visible,$customscope_type,$customscope_ids),$update_values);
	$adb->pquery($query,$update_values);
	$query='delete from ld_parenttabrel where parenttabid=?';
	$adb->pquery($query,array($parenttabid));
}


$query='insert into ld_parenttabrel(parenttabid,tabid,sequence,tab_tablename)value';
$value='';
for($i=0;$i<count($tabarr);$i++){
    $index=$i+1;
    if(!empty($tabarr[$i])){
        $tmptabs=explode(":",$tabarr[$i]);
        $tmptabid=$tmptabs[0];
        $tab_tablename=$tmptabs[1];
        $value .='('.$parenttabid.','.$tmptabid.','.$index.',"'.$tab_tablename.'")'.',';
    }
}
if(!empty($value)){
    $adb->query($query.mb_substr($value,0,strlen($value)-1,$default_charset));
}
$version_info = getVersionInfo();
if($version_info['account']=='yuwang')
{
    $yuwangsql = "select ld_linkmodulecustom.id as id from ld_linkmodulecustom 
    left join ld_parenttabrel on ld_parenttabrel.tabid = ld_linkmodulecustom.id and tab_tablename = 'ld_linkmodulecustom'
    where entitytype = ? and  linkmodule <> 'Customreport' and parenttabid = ?";
    $yuwangresult = $adb->pquery($yuwangsql,array('custom',$parenttabid));
    $yuwangrows = $adb->num_rows($yuwangresult);
    for($i=0;$i<$yuwangrows;$i++)
    {
        $linkmoduleid = $adb->query_result($yuwangresult,$i,'id');
        $yuwangupdate = "update ld_parenttabrel set isopeninblank = 'yes'  where tabid = ? and tab_tablename = ? and parenttabid = ?;";
        $adb->pquery($yuwangupdate,array($linkmoduleid,'ld_linkmodulecustom',$parenttabid));
    }
    //zkt 禹王设置帆软报表连接模块至PC端界面
    $yuwangsql = "select ld_linkmodulecustom.id as id from ld_linkmodulecustom 
    left join ld_parenttabrel on ld_parenttabrel.tabid = ld_linkmodulecustom.id and tab_tablename = 'ld_linkmodulecustom'
    where entitytype = ? and linkmodule = ? and parenttabid = ?";
    $yuwangresult = $adb->pquery($yuwangsql,array('customfine','Customreport',$parenttabid));
    $yuwangrows = $adb->num_rows($yuwangresult);
    for($i=0;$i<$yuwangrows;$i++)
    {
        $linkmoduleid = $adb->query_result($yuwangresult,$i,'id');
        $yuwangupdate = "update ld_parenttabrel set checkphp = ?,isopeninblank = 'yes'  where tabid = ? and tab_tablename = ? and parenttabid = ?;";
        $adb->pquery($yuwangupdate,array('FineRecordgettoken',$linkmoduleid,'ld_linkmodulecustom',$parenttabid));
    }
}
if(!empty($parenttabid)){
	$adb->pquery('delete from ld_tranlabel  where (languagetype=? or languagetype=?) and trantable=? and relateid=?',array('zh','en','ld_parenttab',$parenttabid));
}
$adb->query("insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
values('en','ld_parenttab',$parenttabid,$parenttabid,'$parentenglish')");
$adb->query("insert into ld_tranlabel(languagetype,trantable,tabid,relateid,fieldlabel)
values('zh','ld_parenttab',$parenttabid,$parenttabid,'$parentchinese')");
create_tab_data_file();
create_parenttab_data_file();
create_parent_language();
$cachekey = 'cache_getparenttabrelinfo';
unsetCache($cachekey);
if($visible == 1){
	$visible = getFixedLabel('YES');
}else{
	$visible = getFixedLabel('NO');
}
$data = array(
	'parentchinese' => $parentchinese,
	'parentenglish' => $parentenglish,
	'parentindex' => $parentindex,
	'visible' => $visible,
	'parenttabid' => $parenttabid,
);
$arr["data"] = $data;
$arr["msg"] = $error_msg;
ConvertTojsonString(1,$arr,"success");


//icon单文件上传
function  iconUpload($fieldname,$parenttabid){
    $uploaddir = globalStatic::$root_directory ."storage/menuIcon/";
    if(!is_dir($uploaddir)){
        mkdir($uploaddir, 0777);
    }

    $allowedExts = array("gif", "jpeg", "jpg", "png");
    $temp = explode(".", $_FILES[$fieldname]["name"]);
    $extension = end($temp);        // 获取文件后缀名
    $errorInfo = '';//错误信息
    $filename_destination = $fieldname.'_'.$parenttabid.".".$extension;
    if ((($_FILES[$fieldname]["type"] == "image/gif")
            || ($_FILES[$fieldname]["type"] == "image/jpeg")
            || ($_FILES[$fieldname]["type"] == "image/jpg")
            || ($_FILES[$fieldname]["type"] == "image/pjpeg")
            || ($_FILES[$fieldname]["type"] == "image/x-png")
            || ($_FILES[$fieldname]["type"] == "image/png"))
        && ($_FILES[$fieldname]["size"] <= 1024*1024)    // 小于 1mb
        && in_array($extension, $allowedExts))
    {
        if ($_FILES[$fieldname]["error"] > 0)
        {
            $errorInfo = $_FILES[$fieldname]["error"];
        }
        else
        {
            //echo "上传文件名: " . $_FILES["file"]["name"] . "<br>";
            //echo "文件类型: " . $_FILES["file"]["type"] . "<br>";
            //echo "文件大小: " . ($_FILES["file"]["size"] / 1024) . " kB<br>";
            //echo "文件临时存储的位置: " . $_FILES[$fieldname]["tmp_name"];
            //移动前判断文件存不存在 存在先删除
            if(file_exists($uploaddir.$filename_destination)){
                unlink($uploaddir.$filename_destination);
            }
            move_uploaded_file($_FILES[$fieldname]["tmp_name"],$uploaddir.$filename_destination);
        }
    }else if($_FILES[$fieldname]["size"] > 1024*1024){
        $errorInfo = getFixedLabel('menuIconUploadTips');
    }else{
        $errorInfo = '文件格式不合法！';
    }
    if($errorInfo==''){
        return ['code'=>1,'filepath'=>"storage/menuIcon/".$filename_destination];
    }else{
        return ['code'=>-1,'errorInfo'=>$errorInfo];
    }
}
?>