<?php
//链接模块定制-》保存
global $adb,$current_user;
$_REQUEST['diony']='yes';
$zh_label=$_REQUEST['zh_label'];
if(trim($zh_label)=='')
{
    ConvertTojsonString("-1",array(),getFixedLabel("CNTAG").getFixedLabel('CANOTEMPTYGTH'));
}
$en_label=$_REQUEST['en_label'];
if(trim($en_label)=='')
{
    ConvertTojsonString("-1",array(),getFixedLabel("ENTAG").getFixedLabel('CANOTEMPTYGTH'));
}
$url=$_REQUEST['linkaddress'];
if(trim($url)=='')
{
    ConvertTojsonString("-1",array(),getFixedLabel("LINKADDRESS").getFixedLabel('CANOTEMPTYGTH'));
}

$id=$_REQUEST['id'];
$scope=$_REQUEST['scopetype'];
$scopeids=$_REQUEST['scopeids'];
$sql='select zh_label,en_label from ld_linkmodulecustom where (zh_label=? or en_label=?) ';
if(!empty($id))
{
    $sql.=" and id<>".$id;
}
$result=$adb->pquery($sql,array($zh_label,$en_label));

if($adb->num_rows($result)>0)
{
    $tmp_zh_label=$adb->query_result($result,0,'zh_label');
    if($tmp_zh_label==$zh_label)
    {
        ConvertTojsonString("-1",array(),getFixedLabel("CNTAG").getFixedLabel('REPEAT'));
    }
    else
    {
         ConvertTojsonString("-1",array(),getFixedLabel("ENTAG").getFixedLabel('REPEAT'));
    }
}
$authcheck=$_REQUEST['authcheck'];
$paramvalue_arr=$_REQUEST['param'];

if(!empty($id)){
    // @edit:dong @date:2020/10/29 @reason: 数据分类设置为链接模块
    $sql ='select entitytype from ld_linkmodulecustom where id =?';
    $result = $adb->pquery($sql,array($id));
    $entitytype = $adb->query_result($result,0,0);
    if($entitytype =='custom'){  //设置里面自己添加的自定义模块
        $sql='update ld_linkmodulecustom set zh_label=? ,en_label=? ,url=?,scope=?,authcheck=?,paramvalue=? where id=?';
        $adb->pquery($sql,array($zh_label,$en_label,$url,$scope,$authcheck,$paramvalue_arr, $id));
    }else{ // 数据分类设置的链接模块
        $sql='update ld_linkmodulecustom set zh_label=? ,en_label=? ,scope=?,authcheck=?,paramvalue=? where id=?';
        $adb->pquery($sql,array($zh_label,$en_label,$scope,$authcheck,$paramvalue_arr,$id));
    }
    

}
else
{
   
    $sql='insert into ld_linkmodulecustom(zh_label,en_label,url,scope,entitytype,authcheck,paramvalue)value(?,?,?,?,?,?,?)';
    $adb->pquery($sql,array($zh_label,$en_label,$url,$scope,'custom',$authcheck,$paramvalue_arr));
    $id=$adb->getLastInsertID();
}


//zxm 2021-1206 上传菜单图标
//更新name字段 值为空才更新
$selectsql = "select ifnull(name,'')as name from ld_linkmodulecustom where id=? ";
$selectres = $adb->pquery($selectsql,array($id));
$name = '';
if($adb->num_rows($selectres)>0){
    $name = $adb->query_result($selectres,0,'name');
}
if(empty($name)){
    $update_fields = ['name=?'];
    $update_values = ['CRMLinkModuleCustom'.$id];
}
$error_msg = '';
if(isset($_FILES['active_icon'])){
    $active_icon = iconUpload('active_icon',$id);
    $update_fields[] = 'active_icon=?';
    $update_values[] = $active_icon['filepath'];
    if(!empty($active_icon['errorInfo'])){
        $error_msg = '选中图标上传失败：'.$active_icon['errorInfo'];
        ConvertTojsonString(-1,array(),$error_msg);
    }
}
if(!empty($update_fields)){
    //zxm 20240512 更新连接模块的name  格式是CRMLinkModuleCustom拼接id
    $update_values[] = $id;
    $update_fields = implode(',',$update_fields);
    $adb->pquery("update ld_linkmodulecustom set $update_fields where id=?",$update_values);
}

if($scope=='user'||$scope=='group'||$scope=='role')
{
    $sql='delete from ld_linkmodulecustom2user where linkmodulecustomid=?';
    $adb->pquery($sql,array($id));
    $userids=explode(',',$scopeids);
    foreach($userids as $userid)
    {
        if(!empty($userid)&&is_numeric($userid)&&$userid>0)
        {
            $sql="insert into ld_linkmodulecustom2user(linkmodulecustomid,userid)value(?,?) ";
            $adb->pquery($sql,array($id,$userid));
        }
    }
}
//zxm 20230901 修改模块名称需要把拼音模糊搜索的缓存清除掉
unsetCache('pinyinAlllabel_zh');
unsetCache('pinyinAlllabel_en');
ConvertTojsonString(1,array(),"success");





//icon单文件上传
function  iconUpload($fieldname,$parenttabid){
    $uploaddir = globalStatic::$root_directory ."storage/linkModuleIcon/";
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
    }else if ($_FILES[$fieldname]["size"] > 1024*1024){
        $errorInfo = getFixedLabel('menuIconUploadTips');
    }else{
        $errorInfo = '文件格式不合法！';
    }
    if($errorInfo==''){
        return ['code'=>1,'filepath'=>"storage/linkModuleIcon/".$filename_destination];
    }else{
        return ['code'=>-1,'errorInfo'=>$errorInfo];
    }
}
?>