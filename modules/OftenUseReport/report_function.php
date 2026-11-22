<?php
//editor:gyq_135 reason:微信打卡同步至月度考勤表  2019/8/6 16:49 ID1000568
function getAdvCriteriaHTML($selected="") {
    $adv_filter_options = array("e" => "" . getFixedLabel('EQ') . "",
        "n" => "" . getFixedLabel('NEQ')  . "",
        "s" => "" . getFixedLabel('Begins') . "",
        "ew" => "" .getFixedLabel('Ends') . "",
        "c" => "" . getFixedLabel('IN')  . "",
        "k" => getFixedLabel('NOT_IN'),
        "l" => getFixedLabel('LT'),
        "g" => getFixedLabel('GT'),
        "m" => getFixedLabel('LE'),
        "h" =>getFixedLabel('GE'),
        "b" => getFixedLabel('Before'),
        "a" => getFixedLabel('After'),
        "bw" => getFixedLabel('Interval'),
        "isnull" => getFixedLabel('ISNULL'),
        "isnotnull" => getFixedLabel('ISNOTNULL'),
    );

    foreach($adv_filter_options as $key=>$value) {
        if($selected == $key) {
            $shtml .= "<option selected value=\"".$key."\">".$value."</option>";
        } else {
            $shtml .= "<option value=\"".$key."\">".$value."</option>";
        }
    }
    return $shtml;
}
function getadvDropHtml($reporttabid)
{
    global $adb,$current_user;
    require('user_privileges/user_language_'.$current_user->id.'.php');
    $reporttab=getTabname($reporttabid);

    $sql='select distinct blockid,ld_tranlabel.fieldlabel as blocklabel  from ld_blocks 
        inner join ld_field  on ld_field.block=ld_blocks.blockid 
        inner join ld_tranlabel on ld_tranlabel.relateid=ld_blocks.blockid
        where languagetype=? and trantable=? and  ld_tranlabel.tabid=? and displaytype != 3 and ld_field.presence in (0,2)  order by ld_blocks.sequence asc';

    $resulttt=$adb->pquery($sql,array($languageType,'ld_Blocks', $reporttabid));
    $advFilterHtml="";
    $roofrows=$adb->num_rows($resulttt);
    for($i=0;$i<$roofrows;$i++)
    {
        $blocklabel=$adb->query_result($resulttt,$i,'blocklabel');
        $blockid=$adb->query_result($resulttt,$i,'blockid');
        $sql="select tablename,columnname,fieldname,ld_tranlabel.fieldlabel,typeofdata from ld_field  
         inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
          where ld_tranlabel.fieldlabel<>'' and languagetype=? and trantable=? and  ld_tranlabel.tabid=?  and block=? and ld_field.presence in(0,2) order by sequence asc  ";
        $fieldresult=$adb->pquery($sql,array($languageType,'ld_field',$reporttabid,$blockid));
        $modulelabel=($blocklabel);
        $advFilterHtml.="<optgroup label=\"$modulelabel\" > ";

        for($j=0;$j<$adb->num_rows($fieldresult);$j++)
        {
            $tablename=$adb->query_result($fieldresult,$j,'tablename');
            $columnname=$adb->query_result($fieldresult,$j,'columnname');
            $fieldname=$adb->query_result($fieldresult,$j,'fieldname');
            $fieldlabel=$adb->query_result($fieldresult,$j,'fieldlabel');
            // $fieldlabel=getTranslatedString($fieldlabel,$reporttab);
            $typeofdate=$adb->query_result($fieldresult,$j,'typeofdata');
            $typeofdate=explode('~',$typeofdate);
            $typeofdate=$typeofdate[0];
            if($typeofdate!='DT'&&$typeofdate!='D')
            {
                $typeofdate='V';
            }
            $value=$tablename.':'.$columnname.':'.$reporttab.'_'.str_replace(' ','_',$fieldlabel).':'.$fieldname.':'.$typeofdate;
            $adv_rel_fields[$typeofdate][] = '$'.$reporttab.'#'.$fieldname.'$'."::".getTranstab($reporttab)." ".($fieldlabel);
            $advFilterHtml.="<option value=\"".$value."\"> ".($fieldlabel)." </option>";

        }
        $advFilterHtml.=" </optgroup>";
    }
    $advfilter[0]=$advFilterHtml;
    $advfilter[1]=$adv_rel_fields;
    return $advfilter;

}
function opChildLabel($childlabel)
{
    // global $app_strings;
    $prevfix=substr($childlabel,0,strpos($childlabel,'{'));
    if(!isset($prevfix))
    {
        $prevfix="";
    }
    $module=substr($childlabel,strpos($childlabel,'{')+2,strpos($childlabel,'}')-strpos($childlabel,'{')-2);
    $lastfix=substr($childlabel,strpos($childlabel,'}')+1);

    $modulelabel=getTranstab($module);

    $childlabel=$prevfix.$modulelabel.$lastfix;

    return $childlabel;
}



function updateUseReportCriteria($reportid, $advft_criteria, $advft_criteria_groups) {

    global $adb;

    $idelrelcriteriasql = "delete from ld_usereportadv where reportid=?";
    $idelrelcriteriasqlresult = $adb->pquery($idelrelcriteriasql, array($reportid));

    $idelrelcriteriagroupsql = "delete from ld_usereportadv_grouping where reportid=?";
    $idelrelcriteriagroupsqlresult = $adb->pquery($idelrelcriteriagroupsql, array($reportid));

    if(empty($advft_criteria)) return;

    foreach($advft_criteria as $column_index => $column_condition) {

        if(empty($column_condition)) continue;

        $adv_filter_column = $column_condition["columnname"];
        $adv_filter_comparator = $column_condition["comparator"];
        $adv_filter_value = $column_condition["value"];
        $adv_filter_column_condition = $column_condition["columncondition"];
        $adv_filter_groupid = $column_condition["groupid"];

        $column_info = explode(":",$adv_filter_column);
        $moduleFieldLabel = $column_info[2];
        $fieldName = $column_info[3];

        list($module, $fieldLabel) = explode('_', $moduleFieldLabel, 2);
        $fieldInfo = getFieldByReportLabel($module, $fieldLabel);
        $fieldType = null;
        if(!empty($fieldInfo)) {
            $field = WebserviceField::fromArray($adb, $fieldInfo);
            $fieldType = $field->getFieldDataType();
        }
        if($fieldType == 'currency') {
            // Some of the currency fields like Unit Price, Total, Sub-total etc of Inventory modules, do not need currency conversion
            if($field->getUIType() == '72') {
                $adv_filter_value = setNumberFormatsetNumberFormat($adv_filter_value);
            } else {
                $adv_filter_value = setNumberFormatsetNumberFormat($adv_filter_value);
            }
        }

        $temp_val = explode(",",$adv_filter_value);
        if(($column_info[4] == 'D' || ($column_info[4] == 'T' && $column_info[1] != 'time_start' && $column_info[1] != 'time_end') || ($column_info[4] == 'DT')) && ($column_info[4] != '' && $adv_filter_value != '' ))
        {
            $val = Array();
            for($x=0;$x<count($temp_val);$x++) {
                if(trim($temp_val[$x]) != '') {
                    $date = new DateTimeField(trim($temp_val[$x]));
                    if($column_info[4] == 'D') {
                        $val[$x] = DateTimeField::convertToUserFormat(
                            trim($temp_val[$x]));
                    } elseif($column_info[4] == 'DT') {
                        $val[$x] = $date->getDBInsertDateTimeValue();
                    } else {
                        $val[$x] = $date->getDBInsertTimeValue();
                    }
                }
            }
            $adv_filter_value = implode(",",$val);
        }

        $irelcriteriasql = "insert into ld_usereportadv (reportid,COLUMNINDEX,COLUMNNAME,COMPARATOR,VALUE,GROUPID,COLUMN_CONDITION) values (?,?,?,?,?,?,?)";
        $irelcriteriaresult = $adb->pquery($irelcriteriasql, array($reportid, $column_index, $adv_filter_column, $adv_filter_comparator, $adv_filter_value, $adv_filter_groupid, $adv_filter_column_condition));

        // Update the condition expression for the group to which the condition column belongs
        $groupConditionExpression = '';
        if(!empty($advft_criteria_groups[$adv_filter_groupid]["conditionexpression"])) {
            $groupConditionExpression = $advft_criteria_groups[$adv_filter_groupid]["conditionexpression"];
        }
        $groupConditionExpression = $groupConditionExpression .' '. $column_index .' '. $adv_filter_column_condition;
        $advft_criteria_groups[$adv_filter_groupid]["conditionexpression"] = $groupConditionExpression;
    }

    foreach($advft_criteria_groups as $group_index => $group_condition_info) {

        if(empty($group_condition_info)) continue;
        if(empty($group_condition_info["conditionexpression"])) continue; // Case when the group doesn't have any column criteria

        $irelcriteriagroupsql = "insert into ld_usereportadv_grouping(GROUPID,reportid,GROUP_CONDITION,CONDITION_EXPRESSION) values (?,?,?,?)";
        $irelcriteriagroupresult = $adb->pquery($irelcriteriagroupsql, array($group_index, $reportid, $group_condition_info["groupcondition"], $group_condition_info["conditionexpression"]));
    }
}
function getFieldByReportLabel($module, $label) {

    // this is required so the internal cache is populated or reused.
    global $adb;
    $fieldobj=Field::getInstance($module,$adb);
    //lookup all the accessible fields

    $cachedModuleFields=$fieldobj->getFieldArray('columnname');
    if(empty($cachedModuleFields)) {
        return null;
    }
    foreach ($cachedModuleFields as $fieldInfo) {
        $fieldLabel = str_replace(' ', '_', $fieldInfo['fieldlabel']);
        if($label == $fieldLabel) {
            return $fieldInfo;
        }
    }
    return null;
}
function getAdvancedFilterList($reportid)
{
    global $adb;
    global $modules;

    global $current_user;

    $advft_criteria = array();
    $sql = 'SELECT * FROM ld_usereportadv_grouping WHERE reportid = ? ORDER BY groupid';
    $groupsresult = $adb->pquery($sql, array($reportid));
    $num_rows = $adb->num_rows($groupsresult);
    $i = 1;
    while($relcriteriagroup = $adb->fetch_array($groupsresult)&&$num_rows>0) {
        $groupId = $relcriteriagroup["groupid"];
        $groupCondition = $relcriteriagroup["group_condition"];

        $ssql = 'select ld_usereportadv.* from ld_usereport
					inner join ld_usereportadv on ld_usereportadv.reportid = ld_usereport.usereportid
					left join ld_usereportadv_grouping on ld_usereportadv.reportid = ld_usereportadv_grouping.reportid
							and ld_usereportadv.groupid = ld_usereportadv_grouping.groupid';
        $ssql.= " where ld_usereport.usereportid = ? AND ld_usereportadv.groupid = ? order by ld_usereportadv.columnindex";
        //echo $ssql;
        $result = $adb->pquery($ssql, array($reportid, $groupId));
        $noOfColumns = $adb->num_rows($result);

        if($noOfColumns <= 0) continue;
        $j = 0;
        while($relcriteriarow = $adb->fetch_array($result)) {
            $columnIndex = $relcriteriarow["columnindex"];
            $criteria = array();

            $criteria['columnname'] = html_entity_decode($relcriteriarow["columnname"]);

            $criteria['comparator'] = $relcriteriarow["comparator"];
            $advfilterval = $relcriteriarow["value"];
            $col = explode(":",$relcriteriarow["columnname"]);
            $moduleFieldLabel = $col[2];
            $fieldName = $col[3];
            $tablename=$col[0];
            $columnname=$col[1];
            $arrLabel=explode("_",$moduleFieldLabel);
            $tabname=$arrLabel[0];
            $tabid=getTabid($tabname);
            $sql="select fieldlabel from ld_field where tabid=? and columnname=? ";
            $resultfield=$adb->pquery($sql,array($tabid,$columnname));

            $tabFieldlable=$adb->query_result($resultfield,0,0);
            if(!empty($tabFieldlable))
            {

                if(count(explode(' ',$tabFieldlable))<=0)
                {
                    $criteria['columnname']= $tablename.":".$columnname.":".$tabname."_".$tabFieldlable.":".$fieldName.":".$col[4];
                }
                else
                {
                    $strlabelArr=explode(' ',$tabFieldlable);
                    $strLabel=$strlabelArr[0];

                    for($jk=1;$jk<count($strlabelArr);$jk++)
                    {
                        $strLabel .="_".$strlabelArr[$jk];
                    }
                    $criteria['columnname']= $tablename.":".$columnname.":".$tabname."_".$strLabel.":".$fieldName.":".$col[4];
                }
            }

            //echo    $criteria['columnname'];
            list($module, $fieldLabel) = explode('_', $moduleFieldLabel, 2);
            $fieldInfo = getFieldByReportLabel($module, $fieldLabel);
            $fieldType = null;
            if(!empty($fieldInfo)) {
                $field = WebserviceField::fromArray($adb, $fieldInfo);
                $fieldType = $field->getFieldDataType();
            }
            if($fieldType == 'currency') {
                if($field->getUIType() == '71') {
                    $advfilterval = setNumberFormatsetNumberFormat($advfilterval);
                } else if($field->getUIType() == '72') {
                    $advfilterval = setNumberFormatsetNumberFormat($advfilterval);
                }
            }

            $temp_val = explode(",",$relcriteriarow["value"]);
            if($col[4] == 'D' || ($col[4] == 'T' && $col[1] != 'time_start' && $col[1] != 'time_end') || ($col[4] == 'DT')) {
                $val = Array();
                for($x=0;$x<count($temp_val);$x++) {
                    if($col[4] == 'D') {
                        $date = new DateTimeField(trim($temp_val[$x]));
                        $val[$x] = $date->getDisplayDate();
                    } elseif($col[4] == 'DT') {
                        $date = new DateTimeField(trim($temp_val[$x]));
                        $val[$x] = $date->getDisplayDateTimeValue();
                    } else {
                        $date = new DateTimeField(trim($temp_val[$x]));
                        $val[$x] = $date->getDisplayTime();
                    }
                }
                $advfilterval = implode(",",$val);
            }
            $criteria['value'] = decode_html($advfilterval);
            $criteria['column_condition'] = $relcriteriarow["column_condition"];
            $advft_criteria[$i]['columns'][$j] = $criteria;
            $advft_criteria[$i]['condition'] = $groupCondition;
            $j++;
        }
        $i++;
    }
    // Clear the condition (and/or) for last group, if any.
    if(!empty($advft_criteria[$i-1]['condition'])) $advft_criteria[$i-1]['condition'] = '';
//	print_r($advft_criteria);
    return $advft_criteria;

    $log->info("Reports :: Successfully returned getAdvancedFilterList");
    return true;
}

/**
 * 更新操作
 * edit:can
 * date:20131129
 * reason:显示列设置保存
 * */
function UpdateColumnSet()
{
    global $adb;
    $selectcolumnstring=$_REQUEST['selectedAssmablyColumnsString'];
    $showcolumns=explode(',',$selectcolumnstring);
    $showcolumns=array_filter($showcolumns);
    $usereportid=$_REQUEST['UseReport'];
    $sql='select * from ld_usereportcolumns where usereportid=? order by sequence asc';
    $result=$adb->pquery($sql,array($usereportid));
    $countshowcolumns=count($showcolumns)+4;
    $j=3;

    for($i=0;$i<$adb->num_rows($result);$i++)
    {
        $id=$adb->query_result($result,$i,'id');

        if(in_array($id,$showcolumns))
        {
            //echo array_search($id,$showcolumns).'<br>';
            $sqlcolumns='update ld_usereportcolumns set sequence=?,columnshow=1 where  id=?';
            $adb->pquery($sqlcolumns,array(array_search($id,$showcolumns)+3,$id));

        }
        else
        {
            $sqlcolumns='update ld_usereportcolumns set sequence=?,columnshow=0 where id=?';
            $adb->pquery($sqlcolumns,array($countshowcolumns,$id));
            $countshowcolumns+=3;
        }
    }
    $sql="update ld_usereport set pagewidthpercent=? where usereportid=?";
    $adb->pquery($sql,array($_REQUEST['pagewidth'],$usereportid));
}
/**
 * 更新操作
 * edit:can
 * date:20131129
 * reason:常用报表列名称修改（V3.1)
 * */
function UpdateColumnLabel()
{
    global $adb;
    $columnsid=$_REQUEST['columnid'];
    $columnsid=explode(',',$columnsid);
    $columnsid=array_filter($columnsid);
    for($i=0;$i<count($columnsid);$i++)
    {
        $j=$i+1;
        //zkt 20220602 52427常用报表里的销售预测分析表导出Excel数据后，有一部分的表头没有显示，详情见附件。
        if(!isset($_REQUEST['txt'.$j])||!isset($_REQUEST['txtc'.$j]))
        {
            continue;
        }
        $fieldlabel=$_REQUEST['txt'.$j];
        $fieldlabelen=$_REQUEST['txtc'.$j];
        $sql='select realcolumns,realencolumns from ld_usereportcolumns where id=?';
        $result=$adb->pquery($sql,array($columnsid[$i]));
        if($adb->num_rows($result)>0)
        {
            $realcolumns=$adb->query_result($result,0,'realcolumns');
            $columnlabels=explode(':',$realcolumns);
            $fieldlabels=explode('_',$columnlabels[3]);
            $fieldlabel=$fieldlabels[0].'_'.$fieldlabel;
            $realcolumns=$columnlabels[0].':'.$columnlabels[1].':'.$columnlabels[2].':'.$fieldlabel.':'.$columnlabels[4];

            $sql='update  ld_usereportcolumns set realcolumns=? where id=?';
            $adb->pquery($sql,array($realcolumns,$columnsid[$i]));

        }
        if($adb->num_rows($result)>0)
        {
            $realencolumns=$adb->query_result($result,0,'realencolumns');
            $encolumnlabels=explode(':',$realcolumns);
            $enfieldlabels=explode('_',$encolumnlabels[3]);
            $fieldlabelen=$fieldlabels[0].'_'.$fieldlabelen;
            $realencolumns=$encolumnlabels[0].':'.$encolumnlabels[1].':'.$encolumnlabels[2].':'.$fieldlabelen.':'.$encolumnlabels[4];

            $sql='update  ld_usereportcolumns set realencolumns=? where id=?';
            $adb->pquery($sql,array($realencolumns,$columnsid[$i]));

        }

    }
}
//TimeSheet个人月汇总表
function getTimeSheetReport($start_date,$end_date,$userid){
    global $adb;
    $dates = diffBetweenTwoDays($start_date, $end_date) + 1;
    //var_dump($dates);
    //获取用户的所有项目及项目花费时间
    $entityarray = getEntitynameInfo(getTabid('Project'));
    $fieldname = $entityarray['fieldname'];
    $query = "select workdate,timetype,costtime,project_id,indirectcharge,ld_project.$fieldname as name from ld_timesheet 
    LEFT JOIN ld_timesheetdetail on ld_timesheet.timesheet_id = ld_timesheetdetail.timesheet_id 
    LEFT JOIN ld_project on ld_project.projectid = ld_timesheetdetail.project_id
    where ld_timesheet.smownerid = ".$userid." and project_id > 0 and ld_timesheetdetail.timetype = 'Direct' ";
    //print_r($query);
    $result = $adb->pquery($query,array());
    $num_rows = $adb->num_rows($result);
    for($i = 0; $i<$num_rows; $i++){
        $workdate = $adb->query_result($result,$i,'workdate');
        $projectname = $adb->query_result($result,$i,'name');
        $direct_projectname[] = $projectname;
        $directInfo[] = array(
            'date' => $workdate,
            'direct_name' => $projectname,
            'costtime' => $adb->query_result($result,$i,'costtime'),
        );
    }
    //获取用户的所有非项目及项目花费时间
    $query = "select workdate,timetype,costtime,project_id,indirectcharge from ld_timesheet 
    LEFT JOIN ld_timesheetdetail on ld_timesheet.timesheet_id = ld_timesheetdetail.timesheet_id 
    where ld_timesheet.smownerid = ".$userid." and ld_timesheetdetail.timetype = 'Indirect' ";
    $result = $adb->pquery($query,array());
    $num_rows = $adb->num_rows($result);
    for($i = 0; $i<$num_rows; $i++){
        $workdate = $adb->query_result($result,$i,'workdate');
        $indirectInfo[] = array(
            'date' => $workdate,
            'indirect_name' => $adb->query_result($result,$i,'indirectcharge'),
            'costtime' => $adb->query_result($result,$i,'costtime'),
        );
    }
    //获取所有项目以及项目花费时间
    $query = "select workdate,timetype,costtime,project_id,indirectcharge,ld_project.$fieldname as name from ld_timesheet 
    		LEFT JOIN ld_timesheetdetail on ld_timesheet.timesheet_id = ld_timesheetdetail.timesheet_id 
    		LEFT JOIN ld_project on ld_project.projectid = ld_timesheetdetail.project_id
    		where ld_timesheet.smownerid = ".$userid." and ld_timesheetdetail.timetype != '' ";
    $result = $adb->pquery($query,array());
    $num_rows = $adb->num_rows($result);
    for($i = 0; $i<$num_rows; $i++){
        $workdate = $adb->query_result($result,$i,'workdate');
        $projectname = $adb->query_result($result,$i,'name');
        $direct_projectname[] = $projectname;
        $alldirectInfo[] = array(
            'date' => $workdate,
            'direct_name' => $projectname,
            'costtime' => $adb->query_result($result,$i,'costtime'),
        );
    }
    //当前用户的当月的所有项目
    $direct_projectname = array_values(array_unique($direct_projectname));
    //获取所有Indirect
    //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/16 0016 下午 4:48
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objpinklist = new cls_PickList();
    $result_pick = $objpinklist->getPickListValues('indirectcharge',array(),'','ld_tabdetailfield');
    /*$query = 'select indirectcharge from ld_indirectcharge';
    $result = $adb->pquery($query,array());*/
    $indirectcharge_num_rows = count($result_pick);
    $table = '<table class="rptTable TableOften" cellspacing="0" cellpadding="0" width="100%">';
    //第一行
    $table .='<tr>';
    $table .='<td colspan="13" align="center"><b>Direct Charge Codes</b></td>';
    $table .='<td colspan="'.$indirectcharge_num_rows.'" align="center" ><b>Indirect Charge Codes</b></td>';
    $table .='<td><b>Total</b></td>';
    $table .='</tr>';
    //第二行
    $table .='<tr>';
    $table .='<td align="center">Date</td>';
    for($i = 0; $i<12;$i++){
        $table .='<td align="center">IDWA#</td>';
    }
    foreach($result_pick as $value){
        $indirect_info[] = $value;
        $table .='<td align="center">'.$value.'&nbsp;</td>';
    }
    /*for($i = 0; $i<$indirectcharge_num_rows; $i++){
    	$indirectcharge = $adb->query_result($result,$i,'indirectcharge');
    	$indirect_info[] = $indirectcharge;
    	$table .='<td align="center">'.$indirectcharge.'</td>';
    }*/
    $table .='<td>Hours</td>';
    $table .='</tr>';
    //列头结束
    //项目开始
    $table .='<tr><td></td>';
    for($i = 0; $i<12; $i++){
        $table .='<td align="center">'.$direct_projectname[$i].'</td>';
    }
    for($i = 0; $i<$indirectcharge_num_rows+1; $i++){
        $table .='<td align="center"></td>';
    }
    for($i = 0; $i<$dates; $i++){
        $date = date('Y-m-d', strtotime ("+$i day", strtotime(''.$start_date.'')));
        $table .='<tr>';
        $table .='<td>' . $date . '</td>';
        for($j = 0; $j<12; $j++){
            $d_costtime = '';
            foreach($directInfo as $infos){
                if($infos['date'] == $date && $direct_projectname[$j] == $infos['direct_name']){
                    $d_costtime += $infos['costtime'];
                }
            }
            $direct_total['direct'][$direct_projectname[$j]] += $d_costtime;//竖：合计
            $table .='<td align="center">'.$d_costtime.'</td>';
        }
        for($k = 0; $k<$indirectcharge_num_rows; $k++){
            $ind_costtime = '';
            foreach($indirectInfo as $infos){
                if($infos['date'] == $date && $indirect_info[$k] == $infos['indirect_name']){
                    $ind_costtime = $infos['costtime'];
                }
            }
            $in_direct_total['in_direct'][$infos['indirect_name']] += $ind_costtime;//竖：合计
            $table .='<td align="center">'.$ind_costtime.'</td>';
        }
        //行合计值
        for($j=0;$j<$dates;$j++)
        {
            $linesum='';
            foreach($alldirectInfo as $infos)
            {
                if($infos['date'] == $date)
                {
                    $linesum+=$infos['costtime'];
                }
            }
        }
        if($linesum!=0)
        {
            $linesum=$linesum;
        }else{
            $linesum=0;
        }
        $table.='<td align="center">'.$linesum.'</td>';
        $table .='</tr>';
    }
    //Direct统计
    $table .='<tr><td align="center">Total</td>';
    for($j = 0; $j<12; $j++){
        $total = 0;
        if(!empty($direct_projectname[$j])){
            if(!empty($direct_total['direct'][$direct_projectname[$j]])){
                $total = $direct_total['direct'][$direct_projectname[$j]];
            }else{
                $total = 0;
            }
        }
        $table .='<td align="center">'.$total.'</td>';
        $Alltotal+=$total;
    }
    //InDirect统计
    for($j = 0; $j<$indirectcharge_num_rows; $j++){
        $total = 0;
        if(!empty($indirect_info[$j])){
            if(!empty($in_direct_total['in_direct'][$indirect_info[$j]])){
                $total = $in_direct_total['in_direct'][$indirect_info[$j]];
            }else{
                $total = 0;
            }
        }
        $table .='<td align="center">'.$total.'</td>';
        $Alltotal+=$total;
    }
    $table.='<td align="center">'.$Alltotal.'</td>';
    $table .='</tr>';
    $table .= '<table>';
    return $table;
}
function diffBetweenTwoDays ($day1, $day2){
    $second1 = strtotime($day1);
    $second2 = strtotime($day2);
    if ($second1 < $second2) {
        $tmp = $second2;
        $second2 = $second1;
        $second1 = $tmp;
    }
    return ($second1 - $second2) / 86400;
}
function getSalesRankingType($type){
    if('sendpament_amount' == $type){
        if(vtlib_isModuleActive('CashBill')){
            $label[] = getTransTab('CashBill');
        }
    }else if('invoice_amount' == $type){
        if(vtlib_isModuleActive('Invoice')){
            $label[] = getTransTab('Invoice');
        }
    }else if('out_amount' == $type){
        if(vtlib_isModuleActive('OutboundOrder')){
            $label[] = getTransTab('OutboundOrder');
        }
    }else if('due_num' == $type || 'due_amount' == $type){
        if(vtlib_isModuleActive('SalesOrder')){
            $label[] = getTransTab('SalesOrder');
        }
        if(vtlib_isModuleActive('ServiceContracts')){
            $label[] = getTransTab('ServiceContracts');
        }
    }else if('SalesOrderTrack' == $type){	//合同跟踪表
        $setsystem_approve = getSys_deploy(3);	//合同订单是否开启审批流程  0是  1否
        if(vtlib_isModuleActive('SalesOrder') && $setsystem_approve['deploy_value'] != 1){
            $label[] = getTransTab('SalesOrder');
        }
        $setsystem_approve = getSys_deploy(47);	//服务合同是否开启审批流程  0是  1否
        if(vtlib_isModuleActive('ServiceContracts') && $setsystem_approve['deploy_value'] != 1){
            $label[] = getTransTab('ServiceContracts');
        }
    }else if('Salesforecastandanalysistable' == $type){	//销售预测分析表
        $setsystem_approve = getSys_deploy(29);	//销售机会是否开启审批流程  0是  1否
        if(vtlib_isModuleActive('Potentials') && $setsystem_approve['deploy_value'] != 1){
            $label[] = getTransTab('Potentials');
        }
    }else if('CashBillSum_SalesOrder' == $type){//应收款统计表-按合同统计
        $setsystem_approve = getSys_deploy(3);	//合同订单是否开启审批流程  0是  1否
        if(vtlib_isModuleActive('SalesOrder') && $setsystem_approve['deploy_value'] != 1){
            $label[] = getTransTab('SalesOrder');
        }
        $setsystem_approve = getSys_deploy(47);	//服务合同是否开启审批流程  0是  1否
        if(vtlib_isModuleActive('ServiceContracts') && $setsystem_approve['deploy_value'] != 1){
            $label[] = getTransTab('ServiceContracts');
        }
    }else if('CashBillSum_Outboundorder' == $type){//应收款统计表-按出库单统计
        $setsystem_approve = getSys_deploy(135);	//出库单是否开启审批流程  0是  1否
        if(vtlib_isModuleActive('OutboundOrder') && $setsystem_approve['deploy_value'] != 1){
            $label[] = getTransTab('OutboundOrder');
        }
    }else if('PurchaseOrderTrack' == $type || 'SendCashBillSum_PurchaseOrder' == $type){	//采购订单跟踪表  应付款统计表-按采购订单统计
        $setsystem_approve = getSys_deploy(8);	//采购订单否开启审批流程  0是  1否
        if(vtlib_isModuleActive('PurchaseOrder') && $setsystem_approve['deploy_value'] != 1){
            $label[] = getTransTab('PurchaseOrder');
        }
    }
    if(is_array($label) && sizeOf($label) > 0){
        return getFixedLabel('Onlythroughdatastatisticsexaminationapproval1') . implode('、',$label);
    }else{
        return '';
    }
}