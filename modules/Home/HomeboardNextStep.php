<?php
/****************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 **AUTHOR:BY hzx
 **DATE:20230307
 *DESCRIPTION:下一步
 ****************************************************/
//zkt 20231012 XUQIU1001341 SQL注入
$filejudgepramkeyarr =['module','action','frommodule','filerand','filename'];
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->setJudgeparamkeyarr($filejudgepramkeyarr);
$JudgeUrlstringbyarr = array_merge($_REQUEST,array('filename'=>$_FILES['ImportXlsFile']['name']));
$cls_UrlEncryptyJudgeobj->setJudgeUrlstringbyarr($JudgeUrlstringbyarr);
global $adb;
$homeboardname = $_REQUEST['homeboardname'];
$boardid = $_REQUEST['boardid'];
$boardtype = $_REQUEST['boardtype'];

$sql_select = 'select 1 from ld_homeboard where boardname = ? and deleted = 0 and boardid != ? and boardtype=? ;';
$result = $adb->pquery($sql_select,array($homeboardname,$boardid,$boardtype));

//edit: xll 2023/07/19 BUG0069735 kfbcrm-可视化分析-新建数据看板-当上传封面失败时，在点击下一步时就弹出提示信息
if(isset($_FILES['active_icon'])){
    //edit: xll 2023/07/06 XUQIU1001446 增加“可视化分析”模块（图标上传保存）
    $cur_boardid = $boardid;
    if($boardid <= 0){ // 新增
        $boardid_sql = "select max(boardid) as boardid from ld_homeboard";
        $max_result = $adb->pquery($boardid_sql,array());
        $cur_boardid = $adb->query_result($max_result,0,'boardid') + 1;
    }
    $error_msg = '';
    $icon_path = (isset($_REQUEST['icon_path']) && !empty($_REQUEST['icon_path'])) ? $_REQUEST['icon_path'] : '';
    crm_load_class_file("VisualAnalysisBoard",'modules/VisualAnalysis');
    $active_icon = VisualAnalysisBoard :: iconUpload('active_icon',$cur_boardid);
    $icon_path = $active_icon['filepath'];
    $error_info = $active_icon['errorInfo'];
}
$num = $adb->num_rows($result);

if($num > 0 && empty($error_info)){
    //仅名字重复
    ConvertTojsonString(-2,'',"success");
} else if($num > 0 && !empty($error_info)){
    //名字重复并且图片上传失败
    $error_msg = getFixedLabel('ICONERROR').$error_info;
    ConvertTojsonString(-1,array(),$error_msg);
} else if($num == 0 && !empty($error_info)){
    //仅图片上传失败
    $error_msg = getFixedLabel('ICONERROR').$error_info;
    ConvertTojsonString(-3,array(),$error_msg);
} else
    //成功
    ConvertTojsonString(1,array($icon_path),"success");

?>