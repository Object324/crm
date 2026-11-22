<?php
/**
 * User: Dong
 * Project: 灵当CRM
 * Date: 2020/11/5 14:10
 * Description:
 */
//zkt 20231012 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user;
$record = (int)vtlib_purify($_REQUEST['record']); //当前的视图id
$cvModule = vtlib_purify($_REQUEST['cvmodule']); //当前的模块
$tabid = getTabid($cvModule);
if ($cvModule == 'Calendar'){
    $cvModule = 'Events';
}
$customViewName = vtlib_purify($_REQUEST['customViewName']); //新视图名称
$_REQUEST['diony'] ='yse';
//zkt 20230425 BUG0064837 kfbcrm 高级查找---点击保存为查询分类---名称“全部”---能够正常保存---导致查询分类中出现重复的分类 
if($customViewName == '全部')
{
    $customViewName = 'All';
}
//查询是否重名
$sql = 'SELECT viewname FROM ld_customview WHERE viewname =? and entitytype=?';
$result = $adb->pquery($sql,array($customViewName,$cvModule));
$num_rows = $adb->num_rows($result);
if($num_rows >0){
    $arr['msg'] = getFixedLabel('Category_Name').getFixedLabel('CANOTREPEATED');
    ConvertTojsonString(-1,$arr,'fail');
}
//查询当前
$sql = 'select  customcategory,pool_id from ld_customview where cvid = ?';
$result = $adb->pquery($sql,array($record));
$num_rows = $adb->num_rows($result);
$customcategory = $adb->query_result($result,0,'customcategory');
//zkt 20221008 0052356高级查找创建数据分类，不能在对应的查询分类里面找到
$pool_id = $adb->query_result($result,0,'pool_id');
//插入主表
$genCVid = $adb->getUniqueID("ld_customview"); //新视图id
$status =CV_STATUS_PRIVATE;  //默认私有
$seq_sql='select max(sequence) from ld_customview where entitytype=?';
$seq_result = $adb->pquery($seq_sql, array($cvModule));
$seq_no=$adb->query_result($seq_result,0);
$seq_no+=1;
$insertSql = 'INSERT INTO ld_customview (cvid,viewname,entitytype,status,userid,sequence,pagewidthpercent,customcategory,pool_id) VALUES  (?,?,?,?,?,?,?,?,?)';
$result =  $adb->pquery($insertSql,array($genCVid,$customViewName,$cvModule,$status,$current_user->id,$seq_no,100,$customcategory,$pool_id));
if(!$result){
    $arr['msg'] =getFixedLabel('USERSAVEFAIL');
    ConvertTojsonString(-1,$arr,'fail');
}

//插入字段
$module = $cvModule;
require_once('modules/Settings/ProductListView.php');//带产品明细的视图
$rightlist = array_keys($rightlist);
foreach ($rightlist as $key=> $columnName){
    $sql = 'INSERT INTO ld_cvcolumnlist (cvid,columnindex,columnname) VALUES (?,?,?)';
    $adb->pquery($sql,array($genCVid,$key+1,$columnName));
}

//插入视图排序规则
$sql = 'SELECT columnname,sorttype from ld_cvcolumnlistsort WHERE cvid =?';
$result=$adb->pquery($sql,array($record));
$columnName= $adb->query_result($result,0,0);
$sorttype = $adb->query_result($result,0,1);
$insertSql = 'INSERT INTO ld_cvcolumnlistsort (cvid, columnname, sorttype) VALUES (?,?,?)';
$adb->pquery($insertSql,array($genCVid,$columnName,$sorttype));
//插入视图的宽度
$CvColumnListWidth =getCvColumnListWidth($cvModule,'customview',$record);
if(!empty($CvColumnListWidth)){
    foreach ($CvColumnListWidth as $columns=>$width){
        $type='customview';
        $insertSql ='INSERT INTO ld_list_headerwidth (header_width, userid, type, module, columns, relateid) VALUES (?,?,?,?,?,?)';
        $adb->pquery($insertSql,array($width,$current_user->id,$type,$cvModule,$columns,$genCVid));
    }
}
//查询分录字段是否保存了宽度
$sql = 'SELECT   * FROM ld_tabwithproductview WHERE tabid =? AND  cvid =?';
$result = $adb->pquery($sql,array($tabid,$record));
if($adb->num_rows($result) >0 ){
    $i=0;
    while ($tmpArr = $adb->fetch_array($result)){
        $tmpInsertSql = 'insert into ld_tabwithproductview (tabid, columns,sequence,cvid) VALUES (?,?,?,?)';
        $adb->pquery($tmpInsertSql,array($tabid,$tmpArr['columns'],$i,$genCVid));
        $i++;
    }
}


//插入搜索条件
$advft_criteria = $_REQUEST['advft_criteria'];
$advft_criteria = Zend_Json::decode($advft_criteria);
$advft_criteria_groups = $_REQUEST['advft_criteria_groups'];
$advft_criteria_groups = Zend_Json::decode($advft_criteria_groups);

if (!empty($advft_criteria)) {

    foreach ($advft_criteria as $column_index => $column_condition) {

        if (empty($column_condition)) continue;

        $adv_filter_column = $column_condition["columnname"];
        // @edit:dong @date:2020/11/18 @reason:  bug0043328   替换string中的columnname为fieldlabel
        $tmpArr = explode(':',$adv_filter_column);
        $tmpArr2 = explode('_',$tmpArr[3]);
        $tmpArr2[1] = 'fieldlabel';
        $tmpArr[3] = implode('_',$tmpArr2);
        $adv_filter_column = implode(':',$tmpArr);

        $adv_filter_comparator = $column_condition["comparator"];
        $adv_filter_value = $column_condition["value"];
        $adv_filter_column_condition = $column_condition["columncondition"];
        $adv_filter_groupid = $column_condition["groupid"];

        $column_info = explode(":", $adv_filter_column);

        $fieldName = $column_info[2];
        $fieldObj = $moduleFields[$fieldName];
        $newModule = explode('_', $column_info[3]);
        $fieldType = '';
        if ($newModule[0] == $cvmodule) {
            $fieldType = $fieldObj->getFieldDataType();
        } else {
            if ($column_info[4] == 'D') {
                $fieldType == 'date';
            }
        }
        $temp_val = explode(",", $adv_filter_value);
        if (($fieldType == 'date' || ($fieldType == 'time' && $fieldName != 'time_start' && $fieldName != 'time_end') || ($fieldType == 'datetime')) && ($fieldType != '' && $adv_filter_value != '')) {
            $val = array();
            for ($x = 0; $x < count($temp_val); $x++) {

                if (trim($temp_val[$x]) != '') {
                    $date = new DateTimeField(trim($temp_val[$x]));
                    if ($fieldType == 'date') {
                        $val[$x] = DateTimeField::convertToDBFormat(
                            trim($temp_val[$x]));
                    } elseif ($fieldType == 'datetime') {
                        $val[$x] = $date->getDBInsertDateTimeValue();
                    } else {
                        $val[$x] = $date->getDBInsertTimeValue();
                    }
                }
            }
            $adv_filter_value = implode(",", $val);
        }
        $irelcriteriasql = "INSERT INTO ld_cvadvfilter(cvid,columnindex,columnname,comparator,value,groupid,column_condition) VALUES (?,?,?,?,?,?,?)";
        $irelcriteriaresult = $adb->pquery($irelcriteriasql, array($genCVid, $column_index, $adv_filter_column, $adv_filter_comparator, $adv_filter_value, $adv_filter_groupid, $adv_filter_column_condition));
        // Update the condition expression for the group to which the condition column belongs
        $groupConditionExpression = '';
        if (!empty($advft_criteria_groups[$adv_filter_groupid]["conditionexpression"])) {
            $groupConditionExpression = $advft_criteria_groups[$adv_filter_groupid]["conditionexpression"];
        }
        $groupConditionExpression = $groupConditionExpression . ' ' . $column_index . ' ' . $adv_filter_column_condition;
        $advft_criteria_groups[$adv_filter_groupid]["conditionexpression"] = $groupConditionExpression;
    }
}
if (!empty($advft_criteria_groups)) {
    foreach ($advft_criteria_groups as $group_index => $group_condition_info) {

        if (empty($group_condition_info)) continue;
        if (empty($group_condition_info["conditionexpression"])) continue; // Case when the group doesn't have any column criteria

        $irelcriteriagroupsql = "INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression) VALUES (?,?,?,?)";
        $irelcriteriagroupresult = $adb->pquery($irelcriteriagroupsql, array($group_index, $genCVid, $group_condition_info["groupcondition"], $group_condition_info["conditionexpression"]));
    }
} else {
    $irelcriteriagroupsql = "INSERT INTO ld_cvadvfilter_grouping(groupid,cvid,group_condition,condition_expression) VALUES (?,?,?,?)";
    $adb->pquery($irelcriteriagroupsql, array(1, $genCVid, 0, ''));
}
$arr['cvid'] =$genCVid;
ConvertTojsonString(1,$arr,'success');



