<?php
/**
*@another :      Liver
*@date :         2016-10-09
*@brief :        保存Direct 项目明细表
**/
    
$subjectcode = $_REQUEST['subjectcode'];
$subjectsummary = $_REQUEST['subjectsummary'];
$expensedetailid = $_REQUEST['expensedetailid'];
$sql1='SELECT count(1) as count from ld_expensedetail where expensedetailid=?';

    $result1 = $adb->pquery($sql1, array($expensedetailid));
    $iscount1 = $adb->query_result($result1,0,'count');
 if($iscount1 > 0){//表示存在这条数据

    $sql = 'update ld_expensedetail set subjectcode=?,subjectsummary=? where expensedetailid=?;';

    $result = $adb->pquery($sql, array($subjectcode,$subjectsummary,$expensedetailid));
    echo '###SUCCESS###';
 }else{
    echo '###USEDEN###';
 }

?>