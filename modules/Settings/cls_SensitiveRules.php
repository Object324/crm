<?php

class cls_SensitiveRules
{
    //根据字段获取敏感规则
    public static function getRulesListByField($fieldid) {
    	global $adb;

    	$query = "SELECT * from ld_sensitiverules where relatedfieldid = ?";
    	$result = $adb->pquery($query, array($fieldid));
    	$num_rows = $adb->num_rows($result);
    	if($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){
                $listdata[$i]['sensitiveid'] = $adb->query_result($result, $i, "sensitiveid");
                $listdata[$i]['sensitivename'] = $adb->query_result($result, $i, "sensitivename");
                $listdata[$i]['rulestatus'] = $adb->query_result($result, $i, "rulestatus");
                $listdata[$i]['ruletype'] = $adb->query_result($result, $i, "ruletype");
                if($listdata[$i]['ruletype'] == 'allencrypted'){
                    $listdata[$i]['ruletypelabel'] = getFixedLabel('SensitiveAllEncrypted');
                }else{
                    $listdata[$i]['ruletypelabel'] = getFixedLabel('SensitiveNonEditable');
                }
            }
    	}
    
    	return $listdata; 
    }
    //根据规则id数组获取规则
    public static function getRulesListByRules($ruleids_str) {
        global $adb;
        $ruleid_arr = explode(',',$ruleids_str);
        $idLength = implode(',', array_fill(0, count($ruleid_arr), '?'));
        $query = "SELECT * from ld_sensitiverules where sensitiveid in (".$idLength.")";

        $result = $adb->pquery($query, array($ruleid_arr));

        $num_rows = $adb->num_rows($result);
        if($num_rows > 0) {
            for($i = 0; $i<$num_rows; $i++){
                $listdata[$i]['sensitiveid'] = $adb->query_result($result, $i, "sensitiveid");
                $listdata[$i]['sensitivename'] = $adb->query_result($result, $i, "sensitivename");
                $listdata[$i]['rulestatus'] = $adb->query_result($result, $i, "rulestatus");
                $listdata[$i]['ruletype'] = $adb->query_result($result, $i, "ruletype");
                if($listdata[$i]['ruletype'] == 'allencrypted'){
                    $listdata[$i]['ruletypelabel'] = getFixedLabel('SensitiveAllEncrypted');
                }else{
                    $listdata[$i]['ruletypelabel'] = getFixedLabel('SensitiveNonEditable');
                }
            }
        }
    
        return $listdata; 
    }
    //获取单条敏感规则的信息
    public static function getRuleInfo($fieldid,$ruleid) {
        global $adb,$default_charset;
    
        $query = "SELECT * from ld_sensitiverules Left JOIN ld_sensitiveruleconditions ON ld_sensitiverules.sensitiveid = ld_sensitiveruleconditions.sensitiveid 
                    where ld_sensitiverules.relatedfieldid = ? and ld_sensitiverules.sensitiveid = ?";
        $result = $adb->pquery($query, array($fieldid,$ruleid));
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0) {
            $ruledata['sensitiveid'] = $adb->query_result($result, 0, "sensitiveid");
            $ruledata['relatedtable'] = $adb->query_result($result, 0, "relatedtable");
            $ruledata['rulestatus'] = $adb->query_result($result, 0, "rulestatus");
            $ruledata['sensitivename'] = $adb->query_result($result, 0, "sensitivename");
            $ruledata['ruletype'] = $adb->query_result($result, 0, "ruletype");
            $ruledata['encryptyinfo'] = $adb->query_result($result, 0, "encryptyinfo");
            $ruledata['effectivemethod'] = $adb->query_result($result, 0, "effectivemethod");
            $ruledata['group_condition'] = $adb->query_result($result, 0, "group_condition");
            $disabledscene = $adb->query_result($result, 0, "disabledscene");
            $ruledata['disabledscene'] = explode(',',$disabledscene);


            for($i=0;$i<$num_rows;$i++){
                $groupid = $adb->query_result($result,$i,'groupid');
                $selecttype = $adb->query_result($result,$i,'selectfuntype');
                $fieldname = $adb->query_result($result,$i,'selectinfo');
                $comparator = $adb->query_result($result,$i,'comparator');
                $comparetype = $adb->query_result($result,$i,'comparefuntype');
                $relatefieldname = $adb->query_result($result,$i,'compareinfo');
                $valid_condition = $adb->query_result($result,$i,'rowcondition');
                
                $advft_criteria[] = array("groupid"=>$groupid, 
                                            "selecttype"=>$selecttype,
                                            "selectfield"=>html_entity_decode($fieldname, ENT_QUOTES, $default_charset),
                                            "comparatortype"=>$comparator,
                                            "comparetype"=>$comparetype,
                                            "comparefield"=>html_entity_decode($relatefieldname, ENT_QUOTES, $default_charset),
                                            "columncondition"=>$valid_condition
                                            );
            }
            $advft_criteria_groups = json_decode(html_entity_decode($ruledata['group_condition']),true);
            $ruledata['advft_criteria'] = $advft_criteria;
            $ruledata['advft_criteria_groups'] = $advft_criteria_groups;
        }
    
        return $ruledata; 
    }
    //获取字段敏感规则开启状态
    public static function getFieldSensitiveStatus($tabid,$fieldid) {
        global $adb;
    
        $query = "SELECT sensitivepresence from ld_field WHERE tabid = ? and fieldid = ?";
        $result = $adb->pquery($query, array($tabid,$fieldid));
        $num_rows = $adb->num_rows($result);
        if($num_rows > 0) {
            $sensitivepresence = $adb->query_result($result, 0, "sensitivepresence");
        }
        return $sensitivepresence; 
    }
    //保存单条敏感规则的信息
    public static function saveRuleInfo($tabid,$fieldid,$ruleid,$newrule_data) {
        global $adb,$current_user,$default_charset;
        $rulename = $newrule_data['rulename'];
        $rulestatus = $newrule_data['rulestatus'];
        $ruletype = $newrule_data['ruletype'];

        $encrypty_way = $newrule_data['encrypty_way'];
        $encrypty_started = $newrule_data['encrypty_started'];
        $encrypty_end = $newrule_data['encrypty_end'];
        $disabledscene = $newrule_data['disabledscene'];
        if($encrypty_way == 'left'){
            $encrypty_end = -1;
        }else if($encrypty_way == 'right'){
            $encrypty_started = 1;
        }
        $encryptyinfo = [
            'encryptyway' => $encrypty_way,
            'started' => $encrypty_started,
            'end' => $encrypty_end,
        ];
        $encryptyinfo = Zend_Json::encode($encryptyinfo);

        $effectivemethod = $newrule_data['effectivemethod'];
        $advft_criteria = $newrule_data['advft_criteria'];
        $advft_criteria_groups = $newrule_data['advft_criteria_groups'];

        $advft_criteria_arr = Zend_Json::decode($advft_criteria,true);
        //判断保存的sql语句是否只包括查询语句
        foreach($advft_criteria_arr as $key=> &$tmp_advft_criteria_check){
            $selecttype = $tmp_advft_criteria_check['selecttype'];
            $comparetype = $tmp_advft_criteria_check['comparetype'];
            if($selecttype == 'sql'){
                $tmp_sql = $tmp_advft_criteria_check['selectfield'];
                self::CheckSqlCorrect($tmp_sql,'selectfield'.$key);
            }
            if($comparetype == 'sql'){
                $tmp_sql = $tmp_advft_criteria_check['comparefield'];
                self::CheckSqlCorrect($tmp_sql,'comparefield'.$key);
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

        if($ruleid == 0){//新增规则
            $insert_sql = "INSERT into ld_sensitiverules(tabid,relatedfieldid,relatedtable,sensitivename,rulestatus,ruletype,
                            encryptyinfo,effectivemethod,group_condition,smcreatorid,modifiedby,disabledscene) value(?,?,?,?,?,?,?,?,?,?,?,?)";
            $adb->pquery($insert_sql, array($tabid,$fieldid,'ld_field',$rulename,$rulestatus,$ruletype,
                        $encryptyinfo,$effectivemethod,$advft_criteria_groups,$current_user->id,$current_user->id,$disabledscene));
            $ruleid = $adb->getLastInsertID();
            foreach($advft_criteria_arr as $tmp_advft_criteria){
                if(empty($tmp_advft_criteria)) continue;
                $groupid = $tmp_advft_criteria['groupid'];
                $insertcondition_sql='INSERT into ld_sensitiveruleconditions(sensitiveid,selectfuntype,selectinfo,comparator,comparefuntype,compareinfo,groupid,rowcondition)
                                        value(?,?,?,?,?,?,?,?)';
                $adb->pquery($insertcondition_sql,array($ruleid,$tmp_advft_criteria['selecttype'],$tmp_advft_criteria['selectfield'],$tmp_advft_criteria['comparatortype'],
                            $tmp_advft_criteria['comparetype'],$tmp_advft_criteria['comparefield'],$groupid,$tmp_advft_criteria['columncondition']));
            }

        }else if($ruleid != 0){//编辑规则
            $update_sql = "UPDATE ld_sensitiverules SET sensitivename=?,rulestatus=?,ruletype=?,encryptyinfo=?,effectivemethod=?,group_condition=?,
                            modifiedby=?,disabledscene=? WHERE relatedfieldid=? AND sensitiveid=?";
            $adb->pquery($update_sql, array($rulename,$rulestatus,$ruletype,$encryptyinfo,$effectivemethod,$advft_criteria_groups,
                            $current_user->id,$disabledscene,$fieldid,$ruleid));
            //先删除已保存条件再插入
            $sql='DELETE from ld_sensitiveruleconditions where sensitiveid = ?';
            $adb->pquery($sql,array($ruleid));
            foreach($advft_criteria_arr as $tmp_advft_criteria){
                if(empty($tmp_advft_criteria)) continue;
                $groupid = $tmp_advft_criteria['groupid'];
                $insertcondition_sql='INSERT into ld_sensitiveruleconditions(sensitiveid,selectfuntype,selectinfo,comparator,comparefuntype,compareinfo,groupid,rowcondition)
                                        value(?,?,?,?,?,?,?,?)';
                $adb->pquery($insertcondition_sql,array($ruleid,$tmp_advft_criteria['selecttype'],$tmp_advft_criteria['selectfield'],$tmp_advft_criteria['comparatortype'],
                            $tmp_advft_criteria['comparetype'],$tmp_advft_criteria['comparefield'],$groupid,$tmp_advft_criteria['columncondition']));
            }

        }

        return $ruleid;
    }
    //新增字段后更新该字段中已创建规则的fieldid
    public static function updateRulesFieldid($fieldid,$ruleids_str) {
        global $adb,$current_user;
        $ruleid_arr = explode(',',$ruleids_str);
        $idLength = implode(',', array_fill(0, count($ruleid_arr), '?'));
        $query = "UPDATE ld_sensitiverules set relatedfieldid = ? WHERE sensitiveid in (".$idLength.")";
        array_unshift($ruleid_arr, $fieldid);
        $adb->pquery($query, array($ruleid_arr));
    }
    //更新字段敏感规则开启状态
    public static function updateFieldSensitiveStatus($fieldid,$sensitivepresence) {
        global $adb,$current_user;
        $query = "UPDATE ld_field set sensitivepresence = ? WHERE fieldid = ?";
        $adb->pquery($query, array($sensitivepresence,$fieldid));
        //删除24小时前的未关联敏感规则,及被删除字段对应的敏感规则
        $adb->query("delete ld_sensitiverules from ld_sensitiverules left join ld_field on ld_sensitiverules.relatedfieldid = ld_field.fieldid and ld_sensitiverules.relatedtable = 'ld_field' 
                where ld_sensitiverules.createdtime<DATE_SUB(NOW(), INTERVAL 1 DAY) and  ld_field.fieldid IS NULL");
        $adb->query("delete  ld_sensitiveruleconditions FROM ld_sensitiveruleconditions LEFT JOIN ld_sensitiverules ON ld_sensitiverules.sensitiveid = ld_sensitiveruleconditions.sensitiveid WHERE ld_sensitiverules.sensitiveid IS NULL");
    }


//判断保存的sql语句是否符合条件
    public static function CheckSqlCorrect($sqlstr,$divname){
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
}

?>