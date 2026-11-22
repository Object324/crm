<?php
global $adb;
$smarty=new lingdangCRM_Smarty();

$id=$_REQUEST['id'];
$frommodule=$_REQUEST['frommodule'];
$fromtype = $_REQUEST['fromtype'];

$focus=CRMEntity::getInstance($frommodule);
$funtype='';
$rulename='';//规则名称
$fieldname='';//选择字段
$relatedtable='ld_field';//选择字段所在的表
$status='active';//状态
$validatacheckbutton='create,edit';//应用场景
$allowsave='no';//是否允许保存
$tipzh='';//中文提示
$tipen='';//英文提示

$detailfuntype='';
$comparatortype='';//比较关系
$detailrelatedtable='ld_field';
$relatefieldname='';//比较字段
$with_tpl = 'yes';
$advft_criteria = array();
$advft_criteria_groups = array();
if(empty($id))
{
    //新增
}
else{
    //编辑
    $sql='select * from  ld_validatasavemain where id=?';
    $result=$adb->pquery($sql,array($id));
    $rulename=$adb->query_result($result,0,'rulename');
    $relatedtable=$adb->query_result($result,0,'relatedtable');
    $status=$adb->query_result($result,0,'status');
    $validataapplication=$adb->query_result($result,0,'validataapplication');
    $actionprevent=$adb->query_result($result,0,'actionprevent');
    $tipzh=$adb->query_result($result,0,'tipzh');
    $tipen=$adb->query_result($result,0,'tipen');
    $tipzhtype=$adb->query_result($result,0,'tipzhtype');
    $tipentype=$adb->query_result($result,0,'tipentype');
    $conditiongroup=$adb->query_result($result,0,'conditiongroup');
    $effectivemethod=$adb->query_result($result,0,'effectivemethod');

    $sql_advft = 'select ld_validatasave.funtype as selecttype,ld_validatasave.fieldname,ld_validatasave.comparator,
                	ld_validatasavedetail.funtype as comparetype,ld_validatasavedetail.relatefieldname,
                    ld_validatasave.conditiongroupid,ld_validatasave.valid_condition,
                    ld_validatasave.fungroupdbcolumns as main_groupcolumn,ld_validatasave.fungrouphiddencolumns as main_grouphiddencolumn,
                    ld_validatasavedetail.fungroupdbcolumns as detail_groupcolumn,ld_validatasavedetail.fungrouphiddencolumns as detail_grouphiddencolumn
                from ld_validatasave INNER JOIN ld_validatasavedetail on ld_validatasave.id = ld_validatasavedetail.relateid
                where ld_validatasave.validatasavemainid = ?;';
    $result_advft = $adb->pquery($sql_advft,array($id));
    
    $num_rows = $adb->num_rows($result_advft);
    for($i=0;$i<$num_rows;$i++){
        $groupid = $adb->query_result($result_advft,$i,'conditiongroupid');
        $selecttype = $adb->query_result($result_advft,$i,'selecttype');
        $fieldname = $adb->query_result($result_advft,$i,'fieldname');
        $comparator = $adb->query_result($result_advft,$i,'comparator');
        $comparetype = $adb->query_result($result_advft,$i,'comparetype');
        $relatefieldname = $adb->query_result($result_advft,$i,'relatefieldname');
        $valid_condition = $adb->query_result($result_advft,$i,'valid_condition');
        $fungroupdbcolumns=$adb->query_result($result_advft,$i,'main_groupcolumn');
        $fungrouphiddencolumns=$adb->query_result($result_advft,$i,'main_grouphiddencolumn');
        $detailfungroupdbcolumns=$adb->query_result($result_advft,$i,'detail_groupcolumn');
        $detailfungrouphiddencolumns=$adb->query_result($result_advft,$i,'detail_grouphiddencolumn');
        if($selecttype == 'sum'){
            $fieldname = "sum($fieldname),GroupBy($fungroupdbcolumns,$fungrouphiddencolumns)";
        }
        if($comparetype == 'sum'){
            $relatefieldname = "sum($relatefieldname),GroupBy($detailfungroupdbcolumns,$detailfungrouphiddencolumns)";
        }
        
        $advft_criteria[] = array("groupid"=>$groupid, 
									"selecttype"=>$selecttype,
									"selectfield"=>html_entity_decode($fieldname, ENT_QUOTES, $default_charset),
									"comparatortype"=>$comparator,
									"comparetype"=>$comparetype,
                                    "comparefield"=>html_entity_decode($relatefieldname, ENT_QUOTES, $default_charset),
                                    "columncondition"=>$valid_condition
                                    );
    }
    $advft_criteria_groups = json_decode(html_entity_decode($conditiongroup),true);
}
//应用场景
$application_arr = array('create'=>getFixedLabel('NEW'),'edit'=>getFixedLabel('EDIT'),'delete'=>getFixedLabel('DELETE'),
'submit'=>getFixedLabel('SUBMITAPPROVAL'),'cancel'=>getFixedLabel('APPROVE_ANTIAPPROVAL'),'finish'=>getFixedLabel('APPROVALSUCCEEDED'));
$smarty->assign('application_arr',$application_arr);
$choose_application = trim($validataapplication,',');
if(empty($choose_application) && empty($id)){
    $choose_application_arr = array('create','edit');
}else{
    $choose_application_arr = explode(',',$choose_application);
}
$smarty->assign('choose_application_arr',$choose_application_arr);
//单据分录类型
if(get_file_address($frommodule,'ProductDetails'))
    $detailtype = 'product';
else if(get_file_address($frommodule,$frommodule.'DetailFieldsHtml'))
    $detailtype = 'detail';
else
    $detailtype = 'none';
$smarty->assign('detailtype',$detailtype);
//启用状态
$status_arr = array('active'=>getFixedLabel('ACTIVATE'),'inactive'=>getFixedLabel('INACTIVATING'));
if($fromtype == 'advance'){
    $status = 'active';
}

$smarty->assign('status_arr',$status_arr);
$smarty->assign('status',$status);
//验证提示后是否停止操作
$smarty->assign('actionprevent',$actionprevent);
//中英文提示类型
$smarty->assign('tipzhtype',$tipzhtype);
$smarty->assign('tipentype',$tipentype);
$tiptypearr = array('text'=>sprintf(getFixedLabel('FIXEDTMP'),getFixedLabel('Text')),'sql'=>getFixedLabel('SQLQUERY'));
$smarty->assign('tiptypearr',$tiptypearr);
//中英文提示
$smarty->assign('tipzh',$tipzh);
$smarty->assign('tipen',$tipen);
//规则比较类型
$smarty->assign('funtype',strtolower($funtype));
$smarty->assign('detailfuntype',strtolower($detailfuntype));
//比较字段
$smarty->assign('relatefieldname',$relatefieldname);
//规则信息
$smarty->assign('rulename',$rulename);
//推进特殊判断
$smarty->assign('fromtype',$fromtype);
//条件生效方式
$effectivemethod_content = [
    "notmeetcondition" => getFixedLabel('EffectWhenNotMet'),
    "meetcontidion" => getFixedLabel('EffectWhenMet')
];
$smarty->assign('effectivemethod_content',$effectivemethod_content);
$smarty->assign('effectivemethod',$effectivemethod);

$arr=array();
if($with_tpl == 'yes'){
    $tablehtml = $smarty->fetch('Settings/PageValidata.tpl');
}
$arr['title']=getFixedLabel("CheckValidataRules");
$arr['selectfield']=$fieldname;
$arr['comparatortype']=$comparatortype;
$arr['comparefield']=$relatefieldname;
$arr['relatedtable']=$relatedtable;
if(empty($detailfuntype))
    $detailfuntype='';
$arr['detailfuntype']=$detailfuntype;
$arr['funtype']=$funtype;
$arr['frommodule']=$frommodule;

$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['SQL']='SQL';
$arr['groupbylabel']=getFixedLabel('GroupBy');
$arr['advft_criteria'] = $advft_criteria;
$arr['advft_criteria_groups'] = $advft_criteria_groups;

$arr['nonelabel']=getFixedLabel('NONE');
$arr['function_arr']=array("number"=>array("sum"=>getFixedLabel('SUM'),'SQL'=>"SQL"),'date'=>array('SQL'=>'SQL'));

//$arr['comparatortype_arr']=array('n'=>getFixedLabel("NEQ"), 'e'=>getFixedLabel('EQ'),'l'=>getFixedLabel('LT'),'g'=>getFixedLabel('GT'),'m'=>getFixedLabel("LE"),'h'=>getFixedLabel("GE"));
$arr['comparatortype_arr'] = array('none'=>getFixedLabel('NONE'));

//选择字段类型
$selecttype_arr = array('fields'=>getFixedLabel('DOCUMENTFIELDS'),
    'text'=>sprintf(getFixedLabel('FIXEDTMP'),getFixedLabel('Text')),
    'number'=>sprintf(getFixedLabel('FIXEDTMP'),getFixedLabel('NUMERICALVALUE')),
    'date'=>sprintf(getFixedLabel('FIXEDTMP'),getFixedLabel('DATE')),
    'datetime'=>sprintf(getFixedLabel('FIXEDTMP'),getFixedLabel('DateTime')),
    'sql'=>getFixedLabel('SQLQUERY'));
$arr['selecttype_arr']=$selecttype_arr;



$arr['functionlabel']=getFixedLabel('Function');
$tmp_arr=[];
$modulefields_arr=$focus->fieldobj->getModuleFields();

foreach($focus->fieldobj->getModuleFields() as $fieldname=>$fieldinfo)
{
    if($fieldinfo->getSaveDataBase()!='yes')
        continue;
    if($fieldinfo->getBigType() == 'fileattachment'){
        continue;
    }
    
    $tablename = $fieldinfo->getTableName();
    
    if($tablename == $focus->table_name || $tablename == $focus->customFieldTable[0]){
        $tmp_arr[]=$fieldinfo;
    }
    
    //if($fieldinfo->get_allowedit()!='no')
    //{
        //edit:can 20210531 46035: 验证规则->合同订单->选择字段和比较字段，无法选择到“合计”字段
        /*
        if($fieldinfo->istotalFldMoneyField()||$fieldinfo->istotalFldNumField()||$fieldinfo->getBigType()=='date'||$fieldinfo->getBigType()=='datetime')
        {
            
            $tmp_arr[]=$fieldinfo;
            
        }*/
    //}
}
$arr['fields']=$tmp_arr;
$arr['detailfields']=[];
if($focus->detailfieldobj)
{
    $tmp_arr=[];
    if(get_file_address($frommodule,'ProductDetails'))
    {
        foreach($focus->detailfieldobj->getModuleFields() as $fieldname=>$fieldinfo)
        {
            if($fieldinfo->getSaveDataBase()!='yes')
                continue;
            if($fieldinfo->getTableName()!=$focus->Detail_table&&$fieldinfo->getTableName()!=$focus->Detail_table_scf)
                continue;
            if($fieldinfo->getBigType() == 'image'){
                continue;
            }
                
            if($fieldinfo->istotalFldMoneyField())
                $fieldinfo->setBigType('currency');
            else if($fieldinfo->istotalFldNumField())
                $fieldinfo->setBigType('number');
            else
                $fieldinfo->setBigType("date");
            $fieldinfo->setFieldName($fieldname);    
            $tmp_arr[]=$fieldinfo;
            
            /*
            if($fieldinfo->istotalFldMoneyField()||$fieldinfo->istotalFldNumField()||$fieldinfo->getUIType()=='51')
            {
                if($fieldinfo->istotalFldMoneyField())
                    $fieldinfo->setBigType('currency');
                else if($fieldinfo->istotalFldNumField())
                    $fieldinfo->setBigType('number');
                else
                    $fieldinfo->setBigType("date");
                    
                $tmp_arr[]=$fieldinfo;
                
            }
            */
        }
    }
    else if(get_file_address($frommodule,$frommodule.'DetailFieldsHtml'))
    {
        foreach($focus->detailfieldobj->getModuleFields() as $fieldname=>$fieldinfo)
        {
            if($fieldinfo->getPresence()==1)
                continue;
            if($fieldinfo->getSaveDataBase()!='yes')
                continue;
            
            if($fieldinfo->getTableName()!=$focus->Detail_table&&$fieldinfo->getTableName()!=$focus->Detail_table_scf)
                continue;
             if($fieldinfo->istotalFldMoneyField())
                    $fieldinfo->setBigType('currency');
                else if($fieldinfo->istotalFldNumField())
                    $fieldinfo->setBigType('number');
                else
                    $fieldinfo->setBigType("date");
            //if($fieldinfo->istotalFldMoneyField()||$fieldinfo->istotalFldNumField()||$fieldinfo->getFieldType()=='Date_Ymd')
            //{
            // BUG20240110-72 ls 20240110 收款单——验证规则编辑保存失败（下拉框取的是fieldname）
            $fieldinfo->setFieldName($fieldname);
            $tmp_arr[]=$fieldinfo;
                
            //}
        }
    }
    $arr['detailfields']=$tmp_arr;
}

$arr['content']=$tablehtml;
$_REQUEST['diony']='yes';
ConvertTojsonString(1,$arr,'success');

?>