<?php

global $theme,$adb,$currentModule,$current_user;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$allMonth = $_REQUEST['allmonth'];

$allUsers = $_REQUEST['alluserid'];
$userArr = array();

$monthArr = explode(',',$allMonth);

crm_load_class_file('SalesGoalNew.class','modules/SalesGoal');
list($start,$end) = SalesGoalNew::getFilterDateInfo($monthArr);

$startdates=explode("-",$monthArr[0]);
$enddates=explode("-",$monthArr[sizeof($monthArr)-1]);
$viewrangeone_year=$startdates[0];
$viewrangeone_month=$startdates[1];

$viewrangetwo_year=$enddates[0];
$viewrangetwo_month=$enddates[1];

$targetid = $_REQUEST['targetid'];
$record_str = $_REQUEST['record_str'];
$groupid_str = $_REQUEST['groupid_str'];
$modulename = $_REQUEST['modulename'];

$groupid_arr = explode(',',$groupid_str);
$record_arr = explode(',',$record_str);
$type = $modulename;
//保存用户目标
for ($i = 0; $i<count($record_arr); $i++){
    $tmp_record = $record_arr[$i];
    $delete_sql = "DELETE from ld_salestarget_info
        where STR_TO_DATE(CONCAT(targetyear,'-',targetmonth,'-15'),'%Y-%m-%d') BETWEEN ? and ?
        AND record = ? and type = ? and targetid=? ";
    $adb->pquery($delete_sql,[$start,$end,$tmp_record,$type,$targetid]);

    $insert_sql = 'insert into ld_salestarget_info(targetid,record,`type`,targetyear,targetmonth,targetvalue) values';
    $valuesql_arr = [];
    for($j = 0; $j<count($monthArr); $j++)
    {
        $quest_key = $tmp_record . '-' . $monthArr[$j] . '-' . $targetid;
        $value = $_REQUEST[$quest_key];
        $mArra = explode('-',$monthArr[$j]);
        $valuesql_arr[] = "($targetid,$tmp_record,'$type',$mArra[0],$mArra[1],$value)";
    }
    if(sizeof($valuesql_arr) > 0){
        $combine_sql = $insert_sql.implode(',',$valuesql_arr);
        $adb->query($combine_sql);
    }
}
//保存部门目标
$type = 'Group';
for ($i = 0; $i<count($groupid_arr); $i++){
    $tmp_groupid = $groupid_arr[$i];
    //删除当前单据在日期范围内的目标
    $delete_sql = "DELETE from ld_salestarget_info
        where STR_TO_DATE(CONCAT(targetyear,'-',targetmonth,'-15'),'%Y-%m-%d') BETWEEN ? and ?
        AND record = ? and type = ? and targetid=?";
    $adb->pquery($delete_sql,[$start,$end,$tmp_groupid,$type,$targetid]);
    //重新使用批量插入目标数据
    $insert_sql = 'insert into ld_salestarget_info(targetid,record,`type`,targetyear,targetmonth,targetvalue) values';
    $valuesql_arr = [];
    for($j = 0; $j<count($monthArr); $j++)
    {
        $quest_key = $tmp_groupid . '-' . $monthArr[$j] . '-' . $targetid.'_group';
        $value = $_REQUEST[$quest_key]??"''";
        $mArra = explode('-',$monthArr[$j]);
        $valuesql_arr[] = "($targetid,$tmp_groupid,'$type',$mArra[0],$mArra[1],$value)";
    }
    if(sizeof($valuesql_arr) > 0){
        $combine_sql = $insert_sql.implode(',',$valuesql_arr);
        $adb->query($combine_sql);
    }
}

function updateSalesTarget($record,$month,$targetid,$value,$type)
{
    global $adb;
    $mArra = explode('-',$month);
    $sql = "select id from ld_salestarget_info where record = ? and targetyear = ? and targetmonth = ? and targetid = ? and `type` = ?";
    $result = $adb->pquery($sql,array($record,$mArra[0],$mArra[1],$targetid,$type));

    if($value == '')
        $value = 0;
    if($adb->num_rows($result) > 0)
    {
        $id = $adb->query_result($result,0,'id');
        $sql = "update ld_salestarget_info set targetvalue = ? where id = ? ";
        $adb->pquery($sql,array($value,$id));
    }
    else
    {
        $sql = "insert into ld_salestarget_info(targetid,record,`type`,targetyear,targetmonth,targetvalue) values(?,?,?,?,?,?)";
        $adb->pquery($sql,array($targetid,$record,$type,$mArra[0],$mArra[1],$value));
    }

}
//edit:can 20210723 47038: （https://51mis.com/hy/liu0712 [^]）金融行业演示账套-基础资料-销售目标-目标设置-编辑错误
unset($_REQUEST['query']);
$_REQUEST['ajax']='yes';
include(globalStatic::$root_directory.'modules/SalesGoal/ListView_edit_new.php');
//$_REQUEST['diony']='yes';
//ConvertTojsonString(1,array(),'success');

?>