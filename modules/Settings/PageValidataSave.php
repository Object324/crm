<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$_REQUEST['diony']='yes';

global $adb;

$frommodule=$_REQUEST['frommodule'];

$rulename=$_REQUEST['rulename'];

if($rulename=='')
{
    ConvertTojsonString(-1,array(),getFixedLabel("RULENAME").getFixedLabel('CANOTEMPTYGTH'));
    
}
$relatedtable=$_REQUEST['relatedtable'];
$status=$_REQUEST['status'];
$validataapplication=trim($_REQUEST['validataapplication'],',');

if($validataapplication=='')
{
    ConvertTojsonString(-1,array(),getFixedLabel("PLEASESELECTATLEASTONE").getFixedLabel('ApplicationScenarios'));
    
}
$allowsave=$_REQUEST['allowsave'];
$actionprevent = $_REQUEST['actionprevent'];

$tipzh=$_REQUEST['tipzh'];
if(trim($tipzh)=='')
{
     ConvertTojsonString(-1,array(),getFixedLabel("TipMsg").'(ZH)'.getFixedLabel('CANOTEMPTYGTH'));
}

$tipen=$_REQUEST['tipen'];
if(trim($tipen)=='')
{
     ConvertTojsonString(-1,array(),getFixedLabel("TipMsg").'(EN)'.getFixedLabel('CANOTEMPTYGTH'));
}

$tipzhtype = $_REQUEST['tipzhtype'];
$tipentype = $_REQUEST['tipentype'];
//判断保存的sql查询提示是否正确
if($tipzhtype == 'sql'){
    $tmp_sql = $tipzh;
    CheckSqlCorrect($tmp_sql,'tipzh');
}
if($tipentype == 'sql'){
    $tmp_sql = $tipen;
    CheckSqlCorrect($tmp_sql,'tipen');
}

$selectfield=$_REQUEST['selectfield'];
$comparatortype=$_REQUEST['comparatortype'];
$comparefield=$_REQUEST['comparefield'];

$advft_criteria_json = $_REQUEST['advft_criteria'];
$advft_criteria_groups_json = $_REQUEST['advft_criteria_groups'];

$advft_criteria_arr = json_decode($advft_criteria_json,true);
$advft_criteria_groups_arr = json_decode($advft_criteria_groups_json,true);

$effectivemethod = $_REQUEST['effectivemethod'];
if(empty($effectivemethod))$effectivemethod = 'notmeetcondition';

//判断保存的sql语句是否只包括查询语句
foreach($advft_criteria_arr as $key=> &$tmp_advft_criteria_check){
    $selecttype = $tmp_advft_criteria_check['selecttype'];
    $comparetype = $tmp_advft_criteria_check['comparetype'];
    if($selecttype == 'sql'){
        $tmp_sql = $tmp_advft_criteria_check['selectfield'];
        CheckSqlCorrect($tmp_sql,'selectfield'.$key);
    }
    if($comparetype == 'sql'){
        $tmp_sql = $tmp_advft_criteria_check['comparefield'];
        CheckSqlCorrect($tmp_sql,'comparefield'.$key);
    }
    
    if($selecttype == 'sum'){
        $sumstr = html_entity_decode($tmp_advft_criteria_check['selectfield'], ENT_QUOTES, $default_charset);
        //使用正则表达式从sum(rmb_total),GroupBy(ld_expense.expenseid,ld_expense.expenseid) 中提取字符串
        preg_match_all("/sum(?:\()(.*)(?:\)),GroupBy(?:\()(.*)(?:\))/i",$sumstr,$tmp_arr);
        if(is_array($tmp_arr)){
            $tmp_advft_criteria_check['selectfield'] = $tmp_arr[1][0];
            $groupcolumnstr = explode(',',$tmp_arr[2][0]);
            $tmp_advft_criteria_check['main_groupcolumn'] = $groupcolumnstr[0];
            $tmp_advft_criteria_check['main_grouphiddencolumn'] = $groupcolumnstr[1];
        }
    }
    
    if($comparetype == 'sum'){
        $sumstr = html_entity_decode($tmp_advft_criteria_check['comparefield'], ENT_QUOTES, $default_charset);
        //使用正则表达式从sum(rmb_total),GroupBy(ld_expense.expenseid,ld_expense.expenseid) 中提取字符串
        preg_match_all("/sum(?:\()(.*)(?:\)),GroupBy(?:\()(.*)(?:\))/i",$sumstr,$tmp_arr);
        if(is_array($tmp_arr)){
            $tmp_advft_criteria_check['comparefield'] = $tmp_arr[1][0];
            $groupcolumnstr = explode(',',$tmp_arr[2][0]);
            $tmp_advft_criteria_check['detail_groupcolumn'] = $groupcolumnstr[0];
            $tmp_advft_criteria_check['detail_grouphiddencolumn'] = $groupcolumnstr[1];
        }
    }
}

if($_REQUEST['id']>0)
{
    $id=$_REQUEST['id'];
    $sql='update ld_validatasavemain set rulename=?,`status`=?,actionprevent=?,tipzh=?,tipen=?,conditiongroup=?,validataapplication=?,relatedtable=?,tipzhtype=?,tipentype=?,effectivemethod=? where id = ?';
    $adb->pquery($sql,array($rulename,$status,$actionprevent,$tipzh,$tipen,$advft_criteria_groups_json,$validataapplication,$relatedtable,$tipzhtype,$tipentype,$effectivemethod,$id));
    
    
    /*
    $funtype=$adb->query_result($result,0,'funtype');
    if(!empty($funtype))
    {
        //有自定义函数或sql
        //edit:can 56425: 	在费用报销单，页面设置--验证规则，将验证规则中的比较关系进行任意更改（改为小于等于），保存后规则仍是大于等于，更改没有
         $sql='update ld_validatasave set relatedtable=?,comparator=?,status=?,rulename=?,validatacheckbutton=?,allowsave=?,tipzh=?,tipen=? where id=?';
         $adb->pquery($sql,array($relatedtable,$comparatortype,$status,$rulename,$validatacheckbutton,$allowsave,$tipzh,$tipen,$id));
    }
    else{
         $sql='update ld_validatasave set fieldname=?,relatedtable=?,comparator=?, status=?,rulename=?,validatacheckbutton=?,allowsave=?,tipzh=?,tipen=? where id=?';
         $adb->pquery($sql,array($selectfield,$relatedtable,$comparatortype, $status,$rulename,$validatacheckbutton,$allowsave,$tipzh,$tipen,$id));
         
    }*/
    $sql='DELETE from ld_validatasavedetail where relateid in (select id from ld_validatasave where validatasavemainid = ?)';
    $adb->pquery($sql,array($id));
    
    $sql='DELETE from ld_validatasave where validatasavemainid = ?';
    $adb->pquery($sql,array($id));
    
    $savemainid=$id;
    

    foreach($advft_criteria_arr as $tmp_advft_criteria){
        if(empty($tmp_advft_criteria))continue;
        $groupid = $tmp_advft_criteria['groupid'];
        $sql='insert into ld_validatasave(module,relatedtable,funtype,fieldname,comparator,sequence,isshowlist,validatasavemainid,conditiongroupid,valid_condition,fungroupdbcolumns,fungrouphiddencolumns)
        value(?,?,?,?,?,?,?,?,?,?,?,?)';
        $adb->pquery($sql,array($frommodule,$relatedtable,$tmp_advft_criteria['selecttype'],$tmp_advft_criteria['selectfield'],$tmp_advft_criteria['comparatortype'],0,'yes',$savemainid,$groupid,
            $tmp_advft_criteria['columncondition'],$tmp_advft_criteria['main_groupcolumn'],$tmp_advft_criteria['main_grouphiddencolumn']));
        $id=$adb->getLastInsertID();
        echo $tmp_advft_criteria['selectfield'];
        echo '<br>';
        $sql=' insert into ld_validatasavedetail(relateid, relatefieldname,relatedtable,funtype,fungroupdbcolumns,fungrouphiddencolumns) value(?,?,?,?,?,?)';
        $adb->pquery($sql,array($id,$tmp_advft_criteria['comparefield'],$relatedtable,$tmp_advft_criteria['comparetype'],$tmp_advft_criteria['detail_groupcolumn'],$tmp_advft_criteria['detail_grouphiddencolumn']));
    }
    
}
else 
{
        
    $result=  $adb->pquery('select max(sequence) from ld_validatasavemain where module=?',array($frommodule));
    if($adb->num_rows($result)>0)
        $maxsequence=$adb->query_result($result,0,0)+1;
    else
        $maxsequence=1;
    
    $sql='insert into ld_validatasavemain(rulename,module,`status`,actionprevent,tipzh,tipen,conditiongroup,validataapplication,relatedtable,sequence,isshowlist,tipzhtype,tipentype,effectivemethod)
    value(?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
    $adb->pquery($sql,array($rulename,$frommodule,$status,$actionprevent,$tipzh,$tipen,$advft_criteria_groups_json,$validataapplication,$relatedtable,$maxsequence,'yes',$tipzhtype,$tipentype,$effectivemethod));
    
    $savemainid=$adb->getLastInsertID();
    
    foreach($advft_criteria_arr as $tmp_advft_criteria){
        if(empty($tmp_advft_criteria))continue;
        $groupid = $tmp_advft_criteria['groupid'];
        $sql='insert into ld_validatasave(module,relatedtable,funtype,fieldname,comparator,sequence,isshowlist,validatasavemainid,conditiongroupid,valid_condition,fungroupdbcolumns,fungrouphiddencolumns)
        value(?,?,?,?,?,?,?,?,?,?,?,?)';
        $adb->pquery($sql,array($frommodule,$relatedtable,$tmp_advft_criteria['selecttype'],$tmp_advft_criteria['selectfield'],$tmp_advft_criteria['comparatortype'],0,'yes',$savemainid,$groupid,
            $tmp_advft_criteria['columncondition'],$tmp_advft_criteria['main_groupcolumn'],$tmp_advft_criteria['main_grouphiddencolumn']));
        $id=$adb->getLastInsertID();
        
        $sql=' insert into ld_validatasavedetail(relateid, relatefieldname,relatedtable,funtype,fungroupdbcolumns,fungrouphiddencolumns) value(?,?,?,?,?,?)';
        $adb->pquery($sql,array($id,$tmp_advft_criteria['comparefield'],$relatedtable,$tmp_advft_criteria['comparetype'],$tmp_advft_criteria['detail_groupcolumn'],$tmp_advft_criteria['detail_grouphiddencolumn']));
    }
}
$arr = [];
//推进界面的验证规则不在公共位置显示
if($validataapplication == 'advance_self'){
    $sql='update ld_validatasavemain set isshowlist=? where id = ?';
    $adb->pquery($sql,array('no',$savemainid));

    $arr['return_id'] = $savemainid;
    $arr['return_name'] = $rulename;
    $arr['return_status'] = $status;
}

$_REQUEST['diony']='yes';
ConvertTojsonString(1,$arr,'success');

//判断保存的sql语句是否符合条件
function CheckSqlCorrect($sqlstr,$divname){
    $error = array('divname'=>$divname);
    
    require_once globalStatic::$root_directory. 'sqlparser/vendor/autoload.php';
    $parser = new PhpMyAdmin\SqlParser\Parser($sqlstr);
    if(sizeof($parser->statements)<=0)
    {
        ConvertTojsonString(-2,$error,'不符合条件的sql！');die;
    }
    $parserArr = $parser->statements;
    
    $is_select = 'no';
    foreach($parserArr as $parserOne){
        //判断是不是查询语句  要每个都判断 不放过任何一个不是select的语句
        if($parserOne instanceof  PhpMyAdmin\SqlParser\Statements\SelectStatement)
        {
            $is_select = 'yes';

        }else{
            ConvertTojsonString(-2,$error,'此sql不是查询语句！');die;
        }
    }
    return $is_select;
}

?>