<?php
/**
*@another :      Liver
*@date :         2016-10-09
*@brief :        保存Indirect 项目明细表
**/
    
$subjectcode = $_REQUEST['subjectcode'];
$subjectsummary = $_REQUEST['subjectsummary'];
$subjectcode2 = $_REQUEST['subjectcode2'];
$subjectsummary2 = $_REQUEST['subjectsummary2'];
$expensedetailid = $_REQUEST['expensedetailid'];
$sql1='SELECT count(1) as count from ld_expensedetail where expensedetailid=?';

    $result1 = $adb->pquery($sql1, array($expensedetailid));
    $iscount1 = $adb->query_result($result1,0,'count');
 if($iscount1 > 0){//表示存在这条数据

    $sql = 'update ld_expensedetail set subjectcode=?,subjectsummary=?,subjectcode2=?,subjectsummary2=? where expensedetailid=?;';

    $result = $adb->pquery($sql, array($subjectcode,$subjectsummary,$subjectcode2,$subjectsummary2,$expensedetailid));
    echo '###SUCCESS###';
 }else{
    echo '###USEDEN###';
 }

?>