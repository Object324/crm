<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//界面字段布局规则
global $adb;
$frommodule=$_REQUEST['frommodule'];
$focus=CRMEntity::getInstance($frommodule);

$wx_fieldInfo=$_REQUEST['wx_fieldInfo'];

$modulefields=$focus->fieldobj->getModuleFields();
foreach($modulefields as $fieldname=>$fieldinfo)
{
   
    $focus->column_fields[$fieldname]=$wx_fieldInfo[$fieldname];
    //edit:can 20200818 42433: （https://61mis.com/kfbcrm [^]）（王杰客户问题）企业微信>灵当CRM>合同订单新增界面>“服务类型”字段选择“上门”：显示出来的“备注”字段没有将默认值自动
    $_REQUEST[$fieldname]=$wx_fieldInfo[$fieldname];
   
}

//edit:can 20200818 42433: （https://61mis.com/kfbcrm [^]）（王杰客户问题）企业微信>灵当CRM>合同订单新增界面>“服务类型”字段选择“上门”：显示出来的“备注”字段没有将默认值自动
setObjectValuesFromRequest($focus);
//用于储存display值为2的信息
$display2_info_arr = array();
foreach($modulefields as $fieldname=>$fieldinfo)
{

    //edit:can 2020-09-09 42523: (https://61mis.com/WX/kh40518/ [^])客户问题（天津盛世），移动端>企业微信>灵当CRM>跟进记录>新建单据界面：无法选择客户，选择之后会自动消失（布局规则：当“客户名称”不为空值是“跟进记录”为必录项）
    if($fieldinfo->getBigType()=='reference')
    {
        $focus->column_fields[$fieldname.'_name']=$wx_fieldInfo[$fieldname.'_name'];
        //$focus->column_fields[$fieldname]=$wx_fieldInfo[$fieldname];
    }
    if($fieldinfo->getUIType()==208&&$frommodule=='SalesOrder')
    {
        $focus->column_fields['selectsourcename']=$wx_fieldInfo['selectsourcename'];
        $focus->column_fields['selectsourcename_name']=$wx_fieldInfo['selectsourcename_name'];
        $focus->column_fields['quote_id_name']=$wx_fieldInfo['quote_id_name'];
        
        
    }
    /*
    if($fieldinfo->getUIType()==1600)
    {
        $tmpstr='';
        $tmpgroupname_arr=explode("、",$wx_fieldInfo[$fieldinfo->getFieldName()]);
        if(!is_numeric($tmpgroupname_arr[0]))
        {
            
           foreach($tmpgroupname_arr  as $tmpgroupname)
           {
                $tmpstr.="'".$tmpgroupname."',";
           }
           // $sql='select '
        }
        $tmpstr=trim($tmpstr,',');
        $sql='select group_concat(groupid) as groupid from ld_groups where groupname in( '.$tmpstr.') ';
        $tmpresult=$adb->pquery($sql,array());
        
      
        if($adb->num_rows($tmpresult)>0)
        {
             $wx_fieldInfo[$fieldinfo->getFieldName()]=$adb->query_result($tmpresult,0,'groupid');
            $focus->column_fields[$fieldinfo->getFieldName()]=$adb->query_result($tmpresult,0,'groupid');
        }
    }
    */
    
    //zkt 20220523 52026（https://81mis.com/kfbtest/index.php）合同订单，SSO305，已审批单据；设置了布局规则，编辑单据时，触发布局规则后，其他“审批通过后”不可编辑的字段都显示可编辑了
    if($fieldinfo->getDisplaytype() == 2)
    {
        $tmpcolumnname = $fieldinfo->getColumnName();
        $tmpfieldname = $fieldinfo->getFieldName();
        $tablename = $focus->table_name;
        $tableindex = $focus->table_index;
        $tmpthistablename = $fieldinfo->getTableName();
        $tmpsavedatabase = $fieldinfo->getSaveDataBase();
        if($tmpsavedatabase == 'no')
        {
            continue;
        }
        if(in_array($tmpthistablename,$focus->tab_name))
        {
            $display2_info_arr['select_column'][] = "$tmpcolumnname";
            $display2_info_arr['select_column_sql'] .= " $tmpthistablename.$tmpcolumnname,";
            $display2_info_arr['select_column_to_field'][$tmpcolumnname] = $tmpfieldname; 
            if(empty($display2_info_arr['select_table']) || (is_array($display2_info_arr['select_table']) && !in_array($tmpthistablename,$display2_info_arr['select_table']))){
                $display2_info_arr['select_table'][] = $tmpthistablename; 
                $tmpthistablenameindex = $focus->tab_name_index[$tmpthistablename];
                if($tmpthistablename != $tablename){
                    $tmpsql = " left join $tmpthistablename on $tmpthistablename.$tmpthistablenameindex = $tablename.$tableindex ";
                    $display2_info_arr['select_leftjoin_sql'] .= $tmpsql;
                }
            }
        }
    }
}
//zkt 20220523 52026（https://81mis.com/kfbtest/index.php）合同订单，SSO305，已审批单据；设置了布局规则，编辑单据时，触发布局规则后，其他“审批通过后”不可编辑的字段都显示可编辑了
if(!empty($display2_info_arr))
{
    $tablename = $focus->table_name;
    $tableindex = $focus->table_index;
    $select_column_sql = rtrim($display2_info_arr['select_column_sql'],',');
    $select_leftjoin_sql = $display2_info_arr['select_leftjoin_sql'];
    $tmpsql = "select $select_column_sql from $tablename  $select_leftjoin_sql  where $tablename.$tableindex = ?;";
    $tmpresult = $adb->pquery($tmpsql,array($_REQUEST['record']));
    if($adb->num_rows($tmpresult)>0)
    {
        foreach($display2_info_arr['select_column'] as $tmpindex=>$tmpcolumnname)
        {
            $tmpvalue = $adb->query_result($tmpresult,0,$tmpcolumnname);
            $tmpfieldname = $display2_info_arr['select_column_to_field'][$tmpcolumnname];
            $focus->column_fields[$tmpfieldname]=$tmpvalue;
        }
        
    }
}
$focus->column_fields['record_id']=$_REQUEST['record'];
global $weixin_user;
if ($weixin_user->environment == 'weixin_self_help'){
    $obj = cls_MP_CommonFun::get_moduleAction_Instance($frommodule,'DetailView');
}else{
    crm_load_class_file('cls_DetailViewWX','WeiXinApp/detail');
    $obj=new cls_DetailViewWX($frommodule);
}

$act_data = $obj->getBlockFields($frommodule, '', 'showpagerule', $focus->column_fields);
 crm_load_class_file('cls_detailfieldrule','include/fields/fieldrule');
 $detailfieldruleobj=cls_detailfieldrule::getInstance($frommodule);
 $fieldrulecolsproperty= $detailfieldruleobj->getFieldRuleProperty();//布局规则字段的隐藏和必填项

$arr['entry']['detailfieldruleinfo']=$detailfieldruleobj->getFieldRuleProperty();

$arr['list']=$act_data;

$arr['otherset'] = [];
if($obj->isOpenSignIn($frommodule)){
    $arr['otherset']['signData'] = ['signShow'=>$obj->jsonArr['signData']['signShow'],'required'=>$obj->jsonArr['signData']['required']];
}


ConvertTojsonString(1,$arr,'success');
?>