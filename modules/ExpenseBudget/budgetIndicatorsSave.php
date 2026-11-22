<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb;
$newisopen = $_REQUEST['newisopen'];
$_REQUEST['diony']='diony';
$budgetType = $_REQUEST['budgetType'];
//判断是否至少启用一个
$selectSql = "select * from ld_expensebudget_totalcolumns where isopen='yes' and type='$budgetType'";
$selectRes = $adb->pquery($selectSql);
$nums =  $adb->num_rows($selectRes);
if($nums<=1&&$newisopen=='no'){
    ConvertTojsonString(-1, [], getFixedLabel('AtLeastOneNeedsToBeEnabled'));
}
if(!empty($newisopen)){

    //更改停用启用状态
    $name = $_REQUEST['name'];
    $sql = "update ld_expensebudget_totalcolumns set isopen=? where `name`=?";
    $res = $adb->pquery($sql,[$newisopen,$name]);
    $effectRows = $adb->getAffectedRowCount($res);
    ConvertTojsonString(1, ['effectRows'=>$effectRows], "success");
}else{
    //修改排序 保存
    $comboxjson = $_REQUEST['comboxjson'];
    $comboxjson = json_decode($comboxjson,true);
    $effectRows = [];
    foreach($comboxjson as $key=>$value){
        $updateSql = "update ld_expensebudget_totalcolumns set `sequence`=? where `name`=?";
        $res = $adb->pquery($updateSql,[$key,$value['name']]);
        $effectRows[] = $adb->getAffectedRowCount($res);
    }
    $budgetType = $_REQUEST['budgetType'];
    $selectvalue = $_REQUEST['selectvalue'];
    $focus = CRMEntity::getInstance('ExpenseBudget');
    $budgetTypePicklist = $focus->getExpenseBudgetTypePicklist($budgetType,'',$selectvalue,['name','translateName'],'yes','yes');
    $budgetTypePicklist = array_values($budgetTypePicklist);
    ConvertTojsonString(1, ['budgetTypePicklist'=>$budgetTypePicklist], "success");
}


