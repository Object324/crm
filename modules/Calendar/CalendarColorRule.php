<?php
class CalendarColorRule{
    public $rulearr = [];
    public $ruleColumnnameArr = [];
    public $ruleColumnsTableArr = [];
    public $focus;
    public $ruleRelatedTable = [];
    public $allPresentFields;
    public $tab_name_index;
    public $loopcalenda_arr=['loop_type','loop_month','loop_dayvalue','reminder_setting','expiredate','loop_calendar'];


    public function __construct()
    {
        $this->focus = CRMEntity::getInstance('Calendar');
        $this->tab_name_index = $this->focus->tab_name_index;
//        $this->replaceWhereTable=array('ld_activity'=>'tmp','ld_activitycf'=>'tmp');
//        $this->replaceFromTable=array(' ld_activity'=>'tmp');
        $this->allPresentFields = $this->focus->fieldobj->getModuleAllPreseneceFields();
    }

    //获取启用规则所有高级查找的字段名和表名，用于和自定义显示的字段查重
    function getAllRuleColumnsTable(){
        return $this->ruleColumnsTableArr;
    }

    function getAllRuleColumns(){
        return $this->ruleColumnnameArr;
    }

    function getRuleRelatedTable(){
        return $this->ruleRelatedTable;
    }


    //获取当前所有开启的颜色规则条件
    function getRules(){
        global $adb,$current_user;
        if (is_array($this->rulearr) && sizeof($this->rulearr)>0){
            return $this->rulearr;
        }
        $sql='select status,backgroundcolor,textcolor,rulevalue from ld_calendar_colorrule where status = ? order by sequence';
        $result=$adb->pquery($sql,array('yes'));
        $num_rows = $adb->num_rows($result);
        if ($num_rows > 0){
            for ($i=0;$i<$num_rows;$i++){
                $arr = [];
                $arr['backgroundcolor'] = $adb->query_result($result,$i,'backgroundcolor');
                $arr['textcolor'] = $adb->query_result($result,$i,'textcolor');
                $rulevalue_json = $adb->query_result($result,$i,'rulevalue');
                $rulevalue = ldcrm_json_decode($rulevalue_json);
                $arr['rulevalue'] = $rulevalue;
                $advft_criteria = $rulevalue['advft_criteria'];
                $arr['advft_criteria'] = $advft_criteria;
                $advft_criteria_groups = $rulevalue['advft_criteria_groups'];
                $arr['advft_criteria_groups'] = $advft_criteria_groups;
                $input['searchtype']='advance';
                $input['advft_criteria']=ldcrm_json_encode($advft_criteria);
                $input['advft_criteria_groups']=ldcrm_json_encode($advft_criteria_groups);
                $arr['input'] = $input;
                $this->rulearr[] = $arr;
                if (!empty($advft_criteria)){
                    foreach ($advft_criteria as $tmp_key => $tmp_arr){
                        $tmp_columnname = $tmp_arr['columnname'];
                        if (empty($tmp_columnname)){
                            continue;
                        }
                        $tmp_columnname_arr = explode(':',$tmp_columnname);
                        $tablename = $tmp_columnname_arr[0];
                        $columnname = $tmp_columnname_arr[1];
                        $fieldname = $tmp_columnname_arr[2];
                        if(!array_key_exists($fieldname,$this->allPresentFields)){//判断字段是否启用
                            continue;
                        }
                        $curtable = explode('_',$tmp_columnname_arr[3])[0];
                        if (!array_key_exists(strtolower($fieldname.'_'.$curtable),$this->ruleColumnsTableArr)){
                            $this->ruleColumnsTableArr[strtolower($fieldname.'_'.$curtable)]=$tablename.'.'.$columnname;
                            $this->ruleColumnnameArr[$columnname] = $tablename.'.'.$columnname;
                        }
                        if (!array_key_exists($tablename,$this->ruleRelatedTable) && $tablename != $this->focus->table_name){
                            $this->ruleRelatedTable[$tablename] = ' '.$tablename.' on '.$tablename.'.'.$this->tab_name_index[$tablename].'='.$this->focus->table_name.'.'.$this->focus->table_index;
                        }
                    }
                }
            }
        }
        return $this->rulearr;
    }

    public function setLoopCalendarColunmns($loopcalenda_arr){
        $this->loopcalenda_arr = $loopcalenda_arr;
    }
    public function getLoopCalendarColunmns(){
        return $this->loopcalenda_arr;
    }



    //通过union all 将所有数据合并成一个sql表
    public function getTempTableSql($calendarArr){
        $tablesqlarr = [];
        $loopcalenda_arr = $this->getLoopCalendarColunmns();
        $tmp_arr = $calendarArr[0];
        foreach ($tmp_arr as $tmp_key => $arr){
            if (in_array($tmp_key,$loopcalenda_arr)){
                continue;
            }
            $columnname_arr[$tmp_key] = $tmp_key;
        }

        $tablesql = [];
        $calendarChunkArr = array_chunk($calendarArr, 50);
        foreach ($calendarChunkArr as $chunk_key => $tmp_calendarArr){
            foreach ($tmp_calendarArr as $tmp_key => $arr){
                $tmp_arr = [];
                foreach ($columnname_arr as $key => $tmp_value){
                    $tmp_arr[] = '"'.$arr[$key].'" as "'.$key.'"';
                }
                $tmp_arr[] = '"0" as "deleted" ';
                $tablesqlarr[]= ' (select '.implode(',',$tmp_arr).') ';
            }
            $tablesql[] = ' ('.implode(' union all',$tablesqlarr).') as ld_activity ';
        }
        return $tablesql;
    }

    /*
 * editor:ljj
 * time:20240118
 * reason:XUQIU1000599
 * content:日程管理->日历视图，可自定义单据背景色和字体颜色（杨雅媚）
 * node:获取所有条件下的数据id和颜色
 * */
    function getAllColorByRules($calendarArr,$startdate,$enddate){
        global $adb,$current_user;
        $activityid_color_arr=[];
        $rule = $this->getRules();
        $customView = CustomView::getInstance('Calendar');
        //获取from表
        $tmptablesql = $this->getTempTableSql($calendarArr);
        foreach ($rule as $tmp_key => $ruleinfo){
            $backgroundcolor = $ruleinfo['backgroundcolor'];
            $textcolor = $ruleinfo['textcolor'];
            $backgroundcolor = $ruleinfo['backgroundcolor'];
            $input = $ruleinfo['input'];
            $queryGenerator = new QueryGenerator('Calendar', $current_user,$customView);
            $queryGenerator->addUserSearchConditions($input);
            $wheresql = $queryGenerator->getWhereClause();
            $fromsql = $queryGenerator->getFromClause();
            $frommaintablesql = $queryGenerator->setMaintable_nameSql();
            $fromsql = str_replace($frommaintablesql,'',$fromsql);
            if (is_array($tmptablesql)){
                foreach ($tmptablesql as $key => $tmp_tablesql){
                    $sql = 'select parent_activityid from '.$tmp_tablesql;
                    $sql .= $fromsql.$wheresql . " AND ld_activity.activitytype <> 'emails' ";
                    $sql .= ' AND ((date_start >="'.$startdate.'" AND due_date <="'.$enddate.'") OR (date_start BETWEEN "'.$startdate.'" AND "'.$enddate.'") OR (due_date BETWEEN "'.$startdate.'" AND "'.$enddate.'"))';
                    $arrrr[]= [$sql,$fromsql];
                    $result=$adb->pquery($sql,array());
                    $num_row=$adb->num_rows($result);
                    if ($num_row>0){
                        for($j=0;$j<$num_row;$j++){
                            $parent_activityid = $adb->query_result($result,$j,'parent_activityid');
                            if (!array_key_exists($parent_activityid,$activityid_color_arr)){
                                $activityid_color_arr[$parent_activityid]=array('backgroundcolor'=>$backgroundcolor,'textcolor'=>$textcolor);
                            }
                        }
                    }
                }
            }
        }
//        dump($arrrr);
        return  $activityid_color_arr;
    }

}


?>