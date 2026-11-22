<?php


class SalesGoalOperation
{
    public static $entitytype_arr = [];
    //获取指标对象可关联对象
    public static function getRelatedEntitytype($modulename){
        global  $current_user,$adb;
        $static_entitytype_arr = self::$entitytype_arr;
        if(isset($static_entitytype_arr[$modulename])){
            return $static_entitytype_arr[$modulename];
        }
        if($modulename != 'Users'){
            $uitypemodules=cls_module_uitype::getUitypeModules();
            $uitype_arr = array();
            foreach ($uitypemodules as $tmp_uitype=>$tmp_module){
                if($tmp_module ==  $modulename){
                    $uitype_arr[] = $tmp_uitype;
                }
            }
            $uitype_str = implode(',',$uitype_arr);
        }

        //不允许选择关联的模块
        $languagetype = getLanguageType($current_user);
        $noshow_entitytype = array('Emails','Faq','Users','ModComments','Reminds','Articles','ChannelCode','Ambassador','Questionnaire','WeChatUser','WorkReportList');
        if(!in_array($modulename,$noshow_entitytype)){
            $noshow_entitytype[] = $modulename;
        }
        //判断销售机会是否启用产品分录
        $potentials_moudle = 'Potentials';
        if($modulename=='Products' && !get_file_address($potentials_moudle,"ProductDetails")){
            $noshow_entitytype[] = $potentials_moudle;
        }

        //查询指标对象可以关联的模块
        switch ($modulename){
            case 'Users':
                $query = "SELECT ld_tab.tabid,ld_tab.`name`,ld_tranlabel.fieldlabel from ld_tab INNER JOIN 
                (SELECT DISTINCT tabid from ld_field where bigtype in ('users','selectoneuser') and presence in (0,2) and savedatabase = 'yes') as tmp
                on ld_tab.tabid = tmp.tabid
                INNER JOIN ld_tranlabel on ld_tranlabel.Relateid = ld_tab.tabid AND ld_tranlabel.trantable = 'ld_tab'
                where ld_tranlabel.languagetype = ? and FIND_IN_SET(ld_tab.`name`,?) <= 0 and ld_tab.presence in (0,2) ORDER BY ld_tab.tabsequence asc;";
                $module_result = $adb->pquery($query,array($languagetype,implode(',',$noshow_entitytype)));
                break;
            case 'Products':
                $query = "SELECT ld_tab.tabid,ld_tab.`name`,ld_tranlabel.fieldlabel from ld_tab INNER JOIN 
                    (SELECT DISTINCT tabid FROM(
                        SELECT tabid from ld_field where FIND_IN_SET(uitype,?) and presence in (0,2)
                        UNION
                        SELECT tabid from ld_producttoolfield where columnname = 'productname' AND presence in (0,2)
                        ) as tmp_tabid
                    ) as tmp
                on ld_tab.tabid = tmp.tabid
                INNER JOIN ld_tranlabel on ld_tranlabel.Relateid = ld_tab.tabid AND ld_tranlabel.trantable = 'ld_tab'
                where ld_tranlabel.languagetype = ? and FIND_IN_SET(ld_tab.`name`,?) <= 0 and ld_tab.presence in (0,2) ORDER BY ld_tab.tabsequence asc;";
                $module_result = $adb->pquery($query,array($uitype_str,$languagetype,implode(',',$noshow_entitytype)));
                break;
            default:
                $query = "SELECT ld_tab.tabid,ld_tab.`name`,ld_tranlabel.fieldlabel from ld_tab INNER JOIN 
                    (SELECT DISTINCT tabid FROM(
                        SELECT tabid from ld_field where FIND_IN_SET(uitype,?) and presence in (0,2)
                        UNION
                        SELECT tabid from ld_tabdetailfield where bigtype = 'reference'  AND referencemodule = ? and presence in (0,2)
                        UNION
                        SELECT tabid from ld_producttoolfield where bigtype = 'reference' AND referencemodule = ? and presence in (0,2)
                        ) as tmp_tabid
                    ) as tmp
                on ld_tab.tabid = tmp.tabid
                INNER JOIN ld_tranlabel on ld_tranlabel.Relateid = ld_tab.tabid AND ld_tranlabel.trantable = 'ld_tab'
                where ld_tranlabel.languagetype = ? and FIND_IN_SET(ld_tab.`name`,?) <= 0 and ld_tab.presence in (0,2) ORDER BY ld_tab.tabsequence asc;";

                $module_result = $adb->pquery($query,array($uitype_str,$modulename,$modulename,$languagetype,implode(',',$noshow_entitytype)));
                break;
        }
        $num_rows = $adb->num_rows($module_result);
        $all_entitytype_arr = array();
        if($num_rows > 0){
            $all_entitytype_arr = $adb->query_result_all($module_result);
            self::$entitytype_arr[$modulename] = $all_entitytype_arr;
        }
        return $all_entitytype_arr;
    }


    //获取指标模块可用的字段信息
    public static function getEntityField($modulename,$tmp_entitytype){
        global $current_user;
        if(empty($tmp_entitytype)){
            return array();
        }
        //获取模块对象所对应的uitype
        $uitypemodules = array();
        if($modulename != 'Users'){
            $uitypemodules=cls_module_uitype::getUitypeModules();
        }
        $returnfield_arr = array();
        $focus = CRMEntity::getInstance($tmp_entitytype);
        $fieldobj = $focus->fieldobj;
        //主表字段
        $all_field = $fieldobj->getModuleFields();
        $returnfield_arr['main'] = array();
        foreach ($all_field as $tmp_fieldinfoobj){
            if($tmp_fieldinfoobj->getSaveDataBase() == 'no'){
                continue;
            }
            $tmp_fieldinfo_arr = array();
            $columname = $tmp_fieldinfoobj->getColumnName();
            $fieldname = $tmp_fieldinfoobj->getFieldName();
            $tablename = $tmp_fieldinfoobj->getTableName();
            $typeofdata = $tmp_fieldinfoobj->getTypeOfData();
            $fieldlabel = $tmp_fieldinfoobj->getfieldLabel();
            $uitype = $tmp_fieldinfoobj->getUIType();
            $bigtype = $tmp_fieldinfoobj->getBigType();
            $typeofdata_arr = explode('~',$typeofdata);

            $combine_column = $tablename.":".$columname.":".$fieldname.":".$tmp_entitytype."_fieldlabel:".$typeofdata_arr[0];
            $tmp_fieldinfo_arr['column'] = $combine_column;
            $tmp_fieldinfo_arr['label'] = $fieldlabel;
            //对象查询字段
            $tmp_fieldinfo_arr['referencefield'] = 'no';
            if($modulename == 'Users'){
                if(in_array($bigtype,array('users','selectoneuser'))){
                    $tmp_fieldinfo_arr['referencefield'] = 'yes';
                }
            }else{
                if($bigtype == 'reference'){
                    $referencemodule=$uitypemodules[$uitype];
                    if($referencemodule == $modulename){
                        $tmp_fieldinfo_arr['referencefield'] = 'yes';
                    }
                }
            }
            //日期字段
            if(in_array($bigtype,array('date','datetime'))){
                $tmp_fieldinfo_arr['datefield'] = 'yes';
            }else{
                $tmp_fieldinfo_arr['datefield'] = 'no';
            }
            //统计字段
            if($tmp_fieldinfoobj->isFldNumOrMoney()){
                $tmp_fieldinfo_arr['counttotal'] = 'yes';
            }else{
                $tmp_fieldinfo_arr['counttotal'] = 'no';
            }
            $returnfield_arr['main'][] = $tmp_fieldinfo_arr;
        }
        //分录字段
        $returnfield_arr['detail'] = array();
        if(get_file_address($tmp_entitytype,$tmp_entitytype."DetailFieldsHtml")||get_file_address($tmp_entitytype,"ProductDetails")){
            $all_detailfield = $focus->detailfieldobj->getModuleFields();

            foreach ($all_detailfield as $tmp_fieldinfoobj){
                if($tmp_fieldinfoobj->getSaveDataBase() == 'no'){
                    continue;
                }
                $tablename = $tmp_fieldinfoobj->getTableName();
                $columname = $tmp_fieldinfoobj->getColumnName();
                if($columname != 'productname' && $tablename != $focus->Detail_table && $tablename != $focus->Detail_table_scf){
                    continue;
                }
                $tmp_fieldinfo_arr = array();

                $fieldname = $tmp_fieldinfoobj->getFieldName();
                $typeofdata = $tmp_fieldinfoobj->getTypeOfData();
                $fieldlabel = $tmp_fieldinfoobj->getfieldLabel();
                $bigtype = $tmp_fieldinfoobj->getBigType();
                $typeofdata_arr = explode('~',$typeofdata);

                $tmp_module = $tmp_entitytype;
                if(get_file_address($tmp_entitytype,"ProductDetails")){
                    $tmp_module = 'Products';
                }
                $combine_column = $tablename.":".$columname.":".$fieldname.":".$tmp_module."_fieldlabel:".$typeofdata_arr[0];
                $tmp_fieldinfo_arr['column'] = $combine_column;
                $tmp_fieldinfo_arr['label'] = $fieldlabel;
                //对象查询字段
                $tmp_fieldinfo_arr['referencefield'] = 'no';
                if($modulename == 'Products'){
                    if($columname == 'productname'){
                        $tmp_fieldinfo_arr['referencefield'] = 'yes';
                    }
                }else{
                    if($bigtype == 'reference'){
                        $referencemodule=$tmp_fieldinfoobj->getReferenceModule();
                        if($referencemodule == $modulename){
                            $tmp_fieldinfo_arr['referencefield'] = 'yes';
                        }
                    }
                }

                //日期字段
                if(in_array($typeofdata_arr[0],array('D','DT'))){
                    $tmp_fieldinfo_arr['datefield'] = 'yes';
                }else{
                    $tmp_fieldinfo_arr['datefield'] = 'no';
                }
                //统计字段
                if($tmp_fieldinfoobj->isFldNumOrMoney()){
                    $tmp_fieldinfo_arr['counttotal'] = 'yes';
                }else{
                    $tmp_fieldinfo_arr['counttotal'] = 'no';
                }
                $returnfield_arr['detail'][] = $tmp_fieldinfo_arr;
            }
        }
        return $returnfield_arr;
    }

    //获取目标范围相关的链接字段值
    public static function getEntitynameByid($scopetype,$scopeid_arr){
        $sql = '';
        $EntitynameStr = '';
        $scopeid_str = implode(',',$scopeid_arr);
        $scopename_arr= [];

        //全部成员
        if($scopetype == 'all'){
            $scopename_arr[] = getFixedLabel('ALLTHEUSERS');
            return  $scopename_arr;
        }elseif ($scopetype == 'user'){
            //按用户显示时要处理客户001的情况
            foreach ($scopeid_arr as $tmp_id){
                $scopename_arr[$tmp_id] = getUserFullName($tmp_id);
            }
            return $scopename_arr;
        }
        global $adb;
        switch ($scopetype){
            case 'group':
                $column = 'groupname';
                $tablename = 'ld_groups';
                $tableindex = 'groupid';
                $table_index = 'groupid';
                break;
            case 'role':
                $column = 'profilename';
                $tablename = 'ld_profile';
                $tableindex = 'profileid';
                $table_index = 'profileid';
                break;
            default:
                $focus = CRMEntity::getInstance($scopetype);
                $column = $focus->list_link_field;
                $table_name = $focus->table_name;
                $table_index = $focus->table_index;
                $tablename_cf = $focus->customFieldTable[0];
                $tablename_cf_index = $focus->customFieldTable[1];

                $tablename = "$table_name inner join $tablename_cf on $table_name.$table_index = $tablename_cf.$tablename_cf_index";
                $tableindex = $table_name.'.'.$table_index;
                break;
        }
        if(!empty($focus)){
            $sql = "SELECT ".$column.",$tableindex from ".$tablename." where ".$tableindex." in (".$scopeid_str.")";
            $result = $adb->query($sql);
            $num_rows = $adb->num_rows($result);
            if($num_rows>0){
                for($i = 0;$i < $num_rows;$i++){
                    $tmp_id = $adb->query_result($result,$i,$table_index);
                    $tmp_name = $adb->query_result($result,$i,$column);
                    $scopename_arr[$tmp_id] = $tmp_name;
                }
            }
        }
        return $scopename_arr ;
    }
    //保存更新人和更新时间
    public static function SaveModifiedby($targetid,$userid){
        global $adb;
        $sql = "UPDATE ld_salestarget_basic set modifiedtime = now(),modifiedby = ? where targetid = ?;";
        $adb->pquery($sql,array($userid,$targetid));
    }
    //获取用户最近一次查询的历史
    public static function getSearchHistory(){
        SalesGoalOperation::getDateHistory();
        SalesGoalOperation::getTargetHistory();
    }

    //获取用户户最近查询的日期
    public static function getDateHistory(){
        global $currentModule,$current_user;
        //如果没有选择日期,根据上次查找的日期显示
        $settinglabel = 'viewdate';
        if(isset($_REQUEST['viewrangeone_year']) && isset($_REQUEST['viewrangeone_month'])
            && isset($_REQUEST['viewrangetwo_year']) && isset($_REQUEST['viewrangetwo_month'])){
            $date_arr = [$_REQUEST['viewrangeone_year'],$_REQUEST['viewrangetwo_year'],$_REQUEST['viewrangeone_month'],$_REQUEST['viewrangetwo_month']];
            $content= ldcrm_json_encode($date_arr);
            setUsersettingByLabel($currentModule,$current_user->id,$settinglabel,$content);
        }else{
            $content = getUsersettingByLabel($currentModule,$current_user->id,$settinglabel);
            $date_arr = ldcrm_json_decode($content);
            $_REQUEST['viewrangeone_year'] = $date_arr[0];
            $_REQUEST['viewrangetwo_year'] = $date_arr[1];
            $_REQUEST['viewrangeone_month'] = $date_arr[2];
            $_REQUEST['viewrangetwo_month'] = $date_arr[3];
        }
    }

    //获取客户最近选择的销售指标
    public static function getTargetHistory(){
        global $currentModule,$current_user;
        //如果没有选择指标，根据上次查询的指标显示
        $settinglabel = 'viewtargetid';
        if(isset($_REQUEST['targetid'])){
            $targetid = $_REQUEST['targetid'];
            $content= $targetid;
            setUsersettingByLabel($currentModule,$current_user->id,$settinglabel,$content);
        }else{
            $content = getUsersettingByLabel($currentModule,$current_user->id,$settinglabel);
            $targetid = $content;
            $_REQUEST['targetid'] = $targetid;
        }
    }
}