<?php
/*
 * edit:duan
 * date:20230314
 * reason:销售指标操作按钮文件
 * */
global $currentModule, $current_user, $adb;
crm_load_class_file('SalesGoalOperation','modules/SalesGoal');
crm_load_class_file('cls_related_scope','include/utils');
crm_load_class_file('SalesGoalNew.class','modules/SalesGoal');

$mode = $_REQUEST['mode'];
$code = 1;
$msg = 'success';
$scopetype = 'TargetRange';
$arr = array();
$all_entitytype_arr = array();
$main_field_arr = array();
$detail_field_arr = array();


if($mode == 'edit'){
    $targetid = $_REQUEST['targetid'];
    $targetinfo = array();
    $smarty = new lingdangCRM_Smarty();
    $entitytype_arr = array();
    if($targetid >0){
        $sql = "SELECT zhlabel,enlabel,modulename,groupsetting,scope,smownerid,displayinactiv,indicator_unit,conversion_rate from ld_salestarget_basic where targetid = ?";
        $result = $adb->pquery($sql,array($targetid));

        if($adb->num_rows($result)>0){
            $zhlabel = $adb->query_result($result,0,'zhlabel');
            $enlabel = $adb->query_result($result,0,'enlabel');
            $modulename = $adb->query_result($result,0,'modulename');
            $groupsetting = $adb->query_result($result,0,'groupsetting');
            $scope = $adb->query_result($result,0,'scope');
            $smownerid = $adb->query_result($result,0,'smownerid');
            $indicator_unit = $adb->query_result($result,0,'indicator_unit');
            $conversion_rate = $adb->query_result($result,0,'conversion_rate');
            $displayinactiv = $adb->query_result($result,0,'displayinactiv');
            switch ($scope){
                case 'all':$scope_new = '0';break;
                case 'group':$scope_new = '1';break;
                case 'user':$scope_new = '2';break;
                case 'role':$scope_new = '3';break;
                default:$scope = $scope_new = $modulename;break;
            }
            $scopeid_arr = cls_related_scope::get_related_scope($currentModule,$scopetype,$targetid);
            if($scope == 'all'){
                $scopeid_str = 'all';
            }else{
                $scopeid_str = implode(',',$scopeid_arr);
            }
            $scopname_arr = SalesGoalOperation::getEntitynameByid($scope,$scopeid_arr);
            $scopname_str = implode(',',$scopname_arr);

            $smarty->assign('zhlabel',$zhlabel);
            $smarty->assign('enlabel',$enlabel);
            $smarty->assign('modulename',$modulename);
            $smarty->assign('groupsetting',$groupsetting);
            $smarty->assign('scope_new',$scope_new);
            $smarty->assign('scopeid',$scopeid_str);
            $smarty->assign('scopname',$scopname_str);
            $smarty->assign('smownerid',$smownerid);
            $smarty->assign('displayinactiv',$displayinactiv);
            $detailinfo = array();
            $detailinf_sql = "SELECT entitytype,referencefield,funname,countfield,datefield,approvedemand,othercondition from ld_salestarget_detail where targetid = ?;";
            $detail_result = $adb->pquery($detailinf_sql,array($targetid));
            $num_rows = $adb->num_rows($detail_result);
            if($num_rows>0){
                for($i=0;$i<$num_rows;$i++){
                    $tmp_arr = array();
                    $entitytype = $adb->query_result($detail_result,$i,'entitytype');
                    $tmp_arr['entitytype'] = $entitytype;
                    if(!in_array($entitytype,$entitytype_arr)){
                        $entitytype_arr[] = $tmp_arr['entitytype'];
                    }

                    $tmp_arr['referencefield'] = $adb->query_result($detail_result,$i,'referencefield');
                    $tmp_arr['funname'] = $adb->query_result($detail_result,$i,'funname');
                    $tmp_arr['countfield'] = $adb->query_result($detail_result,$i,'countfield');
                    $tmp_arr['datefield'] = $adb->query_result($detail_result,$i,'datefield');
                    $tmp_arr['approvedemand'] = $adb->query_result($detail_result,$i,'approvedemand');
                    $othercondition = $adb->query_result($detail_result,$i,'othercondition');

                    if(!empty($othercondition)){
                        $advft_arr = ldcrm_json_decode($othercondition);
                        if(!empty($advft_arr['advft_criteria'])){
                            $tmp_arr['advft_criteria'] = ldcrm_json_encode($advft_arr['advft_criteria']);
                        }else{
                            $tmp_arr['advft_criteria'] = '';
                        }
                        if(!empty($advft_arr['advft_criteria_groups'])){
                            $tmp_arr['advft_criteria_groups'] = ldcrm_json_encode($advft_arr['advft_criteria_groups']);
                        }else{
                            $tmp_arr['advft_criteria_groups'] = '';
                        }
                    }else{
                        $tmp_arr['advft_criteria'] = '';
                        $tmp_arr['advft_criteria_groups'] = '';
                    }
                    $detailinfo[] = $tmp_arr;
                }
            }
            $arr['rowcnt'] = $num_rows;
            $arr['detailinfo'] = $detailinfo;
            $smarty->assign('mode','edit');
        }else{
            $modulename = 'Users';
            $arr['detailinfo'] = [];
            $smarty->assign('groupsetting','noedit');
            $smarty->assign('mode','create');
        }
    }else{
        $modulename = 'Users';
        $arr['detailinfo'] = [];
        $smarty->assign('modulename',$modulename);
        $smarty->assign('groupsetting','noedit');
        $smarty->assign('mode','create');
    }
    //指标对象选项
    $module_arr = array('Users','Accounts','Products');
    foreach ($module_arr as $tmp_module){
        if(vtlib_isModuleActive($tmp_module)){
            $modulename_arr[$tmp_module] = getTranstab($tmp_module);
        }
    }
    //部门设置选择
    $groupsetting_arr = array('close'=>getFixedLabel('HIDE'),'noedit'=>getFixedLabel('GROUPTOTALNOTALLOWEDIT'),'allowedit'=>getFixedLabel('GROUPTOTALALLOWEDIT'));

    //获取可选负责人
    require_once globalStatic::$root_directory.'modules/Users/Group.class.php';
    $group_focus = new Group();
    $moduleuserid_str = $group_focus->getModuleListUser($currentModule);
    $sql = "SELECT id,last_name from ld_users where id in ($moduleuserid_str)";
    $result = $adb->pquery($sql,array());
    $userid_arr = array();
    if($adb->num_rows($result)>0){
        $userid_arr = $adb->query_result_all($result);
        foreach ($userid_arr as $tmp_key => $tmp_arr){
            if(isKehu001ServerPc() == 'yes'){
                $userid_arr[$tmp_key]['namelabel'] = getUserFullName($tmp_arr['id']);
            }else{
                $userid_arr[$tmp_key]['namelabel'] = $tmp_arr['last_name'];
            }
        }
    }


    $all_entitytype_arr = SalesGoalOperation::getRelatedEntitytype($modulename);
    if(count($all_entitytype_arr)>0){
        $first_module = reset($all_entitytype_arr);
        $entitytype_arr[] = $first_module['name'];
    }

    foreach($entitytype_arr as $tmp_entitytype){
        $returnfield_arr = SalesGoalOperation::getEntityField($modulename,$tmp_entitytype);
        $main_field_arr[$tmp_entitytype] = $returnfield_arr['main'];
        $detail_field_arr[$tmp_entitytype] = $returnfield_arr['detail'];
    }
    //计算方法
    $funname_arr = array();
    $funname_arr[] = array('name'=>'sum','fieldlabel'=>getFixedLabel('Summation'));
    $funname_arr[] = array('name'=>'count','fieldlabel'=>getFixedLabel('COUNT'));
    $funname_arr[] = array('name'=>'unicount','fieldlabel'=>getFixedLabel('UCOUNT'));
    $arr['funname_arr'] =$funname_arr;
    //审批要求
    $approvedemand_arr = array();
    $approvedemand_arr[] = array('name'=>'0','fieldlabel'=>getFixedLabel('NONE'));
    $approvedemand_arr[] = array('name'=>'1','fieldlabel'=>getFixedLabel('Approved'));
    $arr['approvedemand_arr'] =$approvedemand_arr;

    $arr['all_entitytype_arr'] = $all_entitytype_arr;
    $arr['main_field_arr'] = $main_field_arr;
    $arr['detail_field_arr'] = $detail_field_arr;
    $arr['label_arr'] = array('DOCUMENTHEADERFIELD'=>getFixedLabel('DOCUMENTHEADERFIELD'),'Entryfield'=>getFixedLabel('Entryfield'));
    $smarty->assign('modulenamearr',$modulename_arr);
    $smarty->assign('groupsettingarr',$groupsetting_arr);
    $smarty->assign('useridarr',$userid_arr);

    //wym 240408  XUQIU20240305-01 目标管理，增加设置“指标单位”和“换算率”（张华）
    $modstatic = new SalesGoalNew();
    $unitlabel_arr=$modstatic->unitlabel_arr;
    $unit_option_arr=[];
    $languageType=getLanguageType($current_user);
    $indicator_unit_enlaebl=$unitlabel_arr[$indicator_unit]["en_label"]; //英文翻译有重复 重复的不显示
    foreach ($unitlabel_arr as $key=>$label){
        if($languageType=='zh'){
            $unit_option_arr[$key] = $label["zh_label"];
        }else{
            //数据库存值的选项必须要
            //英文标签不重复 并且 也不会和数据库存值的英文标签重复
            if( ($indicator_unit==$key) || ( !in_array($label["en_label"],$unit_option_arr) && $label["en_label"] != $indicator_unit_enlaebl )){
                $unit_option_arr[$key] = $label["en_label"];
            }
        }
    }
    $smarty->assign('selectedunit',$indicator_unit);
    $smarty->assign('unit_option_arr',$unit_option_arr);

    $rate_option_arr=array("0.0000001","0.000001","0.00001","0.0001","0.001","0.01","0.1","1","10","100","1000","10000","100000","1000000");
    if(!$conversion_rate){
        $conversion_rate=1;
    }
    $smarty->assign('selectedrate',$conversion_rate);
    $smarty->assign('rate_option_arr',$rate_option_arr);

    $content = $smarty->fetch('modules/SalesGoal/SalesGoalEditView.tpl');
    $arr['content'] = $content;
    $arr['title'] = getTranstab('SalesGoal');
    $arr['oktext'] = getTranstab('SAVE');
    $arr['canceltext'] = getTranstab('CANCEL');
}else if($mode == 'save'){
    $targetid = $_REQUEST['targetid'];
    //需要获取的字段值
    $label_arr = array('zhlabel','enlabel','modulename','groupsetting','scope','scopeid','smownerid','displayinactiv','indicator_unit','conversion_rate');

    $maininfo_arr = array();
    foreach ($label_arr as $tmp_label){
        $maininfo_arr[$tmp_label] = $_REQUEST[$tmp_label];
    }
    $scope = '';
    switch ($maininfo_arr['scope']){
        case '0':$scope = 'all';break;
        case '1':$scope = 'group';break;
        case '2':$scope = 'user';break;
        case '3':$scope = 'role';break;
        default:$scope = $maininfo_arr['modulename'];break;
    }

    $scopeid_arr = explode(',',$maininfo_arr['scopeid']);

    //判断销售指标名称是否重复
    $sql = "SELECT COUNT(zhlabel = ? or null) as zh_count,COUNT(enlabel = ? or null) as en_count from ld_salestarget_basic where targetid <> ?;";
    $result = $adb->pquery($sql,array($maininfo_arr['zhlabel'],$maininfo_arr['enlabel'],$targetid));
    if($adb->num_rows($result)>0){
        $zh_count = $adb->query_result($result,0,'zh_count');
        $en_count = $adb->query_result($result,0,'en_count');
        if($zh_count >0){
            $remind_str = getFixedLabel('INDICATORSNAME').'(zh)'.getFixedLabel('CANOTREPEATED');
            $arr['divlabel'] = 'zhlabel';
            ConvertTojsonString(-1,$arr,$remind_str);
        }else if($en_count >0){
            $remind_str = getFixedLabel('INDICATORSNAME').'(en)'.getFixedLabel('CANOTREPEATED');
            $arr['divlabel'] = 'enlabel';
            ConvertTojsonString(-1,$arr,$remind_str);
        }
    }

    //保存指标信息
    if($targetid >0){
        //wym 240408 XUQIU20240305-01 目标管理，增加“设置指标单位”参数控制，可配置统计字段的计量单位（张华）
        $column_arr = array('zhlabel','enlabel','status','modulename','groupsetting','scope','smownerid','displayinactiv','modifiedby','indicator_unit','conversion_rate');
        $column_info = array();
        $columnsql_arr = array();

        $maininfo_arr['targetid'] = $targetid;
        $maininfo_arr['status'] = 'yes';
        $maininfo_arr['scope'] = $scope;
        $maininfo_arr['modifiedby'] = $current_user->id;

        foreach ($column_arr as $tmp_column){
            $column_info[] = $maininfo_arr[$tmp_column];
            $columnsql_arr[] = $tmp_column.' = ?';
        }
        $column_info[] = $maininfo_arr['targetid'];
        //更新主表字段信息
        $query = 'update ld_salestarget_basic set '.implode(',',$columnsql_arr).' where targetid =?';
        $adb->pquery($query,$column_info);
        //清除指标详数据
        $delete_detail_sql = "DELETE from ld_salestarget_detail where targetid = ?";
        $adb->pquery($delete_detail_sql,array($targetid));
        //清除目标范围数据
        cls_related_scope::delete_related_scope($currentModule,$scopetype,$targetid);
        //保存更新人
        SalesGoalOperation::SaveModifiedby($targetid,$current_user->id);
    }else{
        $targetid = $adb->getUniqueID("ld_crmentity");
        $column_arr = array('targetid','targetname','zhlabel','enlabel','status','modulename','groupsetting','scope','sequence','smownerid','smcreatorid','indicator_unit','conversion_rate');
        $column_info = array();
        $sequence_sql = "SELECT IFNULL(MAX(sequence),0)+1 as new_sequence from ld_salestarget_basic;";
        $sequence_result = $adb->pquery($sequence_sql,array());
        $new_sequence = $adb->query_result($sequence_result,0,'new_sequence');

        $maininfo_arr['targetid'] = $targetid;
        $targetname = "cfamount_".$targetid;
        $maininfo_arr['targetname'] = $targetname;
        $maininfo_arr['status'] = 'yes';
        $maininfo_arr['scope'] = $scope;
        $maininfo_arr['sequence'] = $new_sequence;
        $maininfo_arr['smcreatorid'] = $current_user->id;

        foreach ($column_arr as $tmp_column){
            $column_info[] = $maininfo_arr[$tmp_column];
        }
        //主表信息

        $basic_sql = "insert into ld_salestarget_basic(".implode(',',$column_arr).") values(".generateQuestionMarks($column_arr).")";

        $adb->pquery($basic_sql,$column_info);
    }
    //目标范围
    cls_related_scope::save_related_scope($currentModule,$scopetype,$targetid,$scopeid_arr);

    $detail_column_arr = array('targetid','entitytype','referencefield','datefield','funname','countfield','approvedemand','othercondition');
    //详情信息
    $rowcnt = $_REQUEST['rowcnt'];
    $detail_sql = "INSERT into ld_salestarget_detail(".implode(',',$detail_column_arr).") values(".generateQuestionMarks($detail_column_arr).")";
    for($rowindex = 1;$rowindex<=$rowcnt;$rowindex++){
        $detailinfo_arr = array();
        foreach ($detail_column_arr as $tmp_column){
            if($tmp_column == 'targetid'){
                $detailinfo_arr[] = $targetid;
            }else if($tmp_column == 'othercondition'){
                $othercondition_arr = array();
                $othercondition_arr['advft_criteria'] = ldcrm_json_decode($_REQUEST['advance_demand'.$rowindex]);
                $othercondition_arr['advft_criteria_groups'] = ldcrm_json_decode($_REQUEST['advance_demand_groups'.$rowindex]);
                $othercondition = ldcrm_json_encode($othercondition_arr);
                $detailinfo_arr[] = $othercondition;
            }else{
                $detailinfo_arr[] = $_REQUEST[$tmp_column.$rowindex];
            }
        }
        $adb->pquery($detail_sql,$detailinfo_arr);
    }
}

ConvertTojsonString($code,$arr,$msg);
?>
