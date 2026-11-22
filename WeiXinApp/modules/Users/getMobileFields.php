<?php
global $adb,$current_user;
$record = $_REQUEST['record'];
$relatedModule = $_REQUEST['relatedModule'];
$_REQUEST['diony'] = 'yes';
$fieldArr = [];
//zxm 2021-02-24  移动端 点击列表的拨打电话按钮 查询单据对应的phone mobile类型的字段值 字段名
/**zxm2022-6-15 XUQIU1000251  单据列表界面，点击“快速拨打电话”操作按钮，电话列表显示规则
1.通用列表：字段名称+号码
2.客户列表：联系人姓名+字段名称+号码
3.供应商列表：供应商联系人姓名+字段名称+号码
**/
$fieldArr = getFieldsValues($relatedModule,$record,$fieldArr,'');


//如果是客户模块 还查询联系人电话
if($relatedModule=='Accounts'||$relatedModule=='ServiceCharge'){
    //查询联系人ID
    $contact_sql = "select contactid,lastname from ld_contactdetails where accountid=? and deleted=0 ";
    if($current_user->accountallview!=1&&$current_user->is_admin!='on'){
        //zxm 20230308 成员管理-角色权限区块，关闭“单据相关信息查询所有关联数据”这个参数后，微信小程序的“客户模块”，客户详情页，联系人区块有其他自己 查看权限之外的联系人
        $Smownerids= getCurSmOwnerSearchScope('Contacts');
        $tmpuserid_arr = array_keys($Smownerids['UserCombo']);
        if(!empty($tmpuserid_arr)){
            $tmpuserid_str = implode(',',$tmpuserid_arr);
            $contact_sql .= ' and find_in_set(ld_contactdetails.smownerid,"'.$tmpuserid_str.'") ';
        }
    }
    $contact_res = $adb->pquery($contact_sql,array($record));
    $contact_nums = $adb->num_rows($contact_res);
    if($contact_nums>0){
        for($i=0;$i<$contact_nums;$i++){
            $contactid = $adb->query_result($contact_res,$i,'contactid');
            $contactname = $adb->query_result($contact_res,$i,'lastname');
            getFieldsValues('Contacts',$contactid,$fieldArr,$contactname);
        }
    }
}
if($relatedModule=="Vendors"){
    //供应商联系人 VendorContact
    $vendorcontacts_sql = "select vendorcontactsid,lastname from ld_vendorcontacts where Vendorid=? and deleted=0 ";
    if($current_user->accountallview!=1&&$current_user->is_admin!='on'){
        //zxm 20230308 成员管理-角色权限区块，关闭“单据相关信息查询所有关联数据”这个参数后，微信小程序的“客户模块”，客户详情页，联系人区块有其他自己 查看权限之外的联系人
        $Smownerids= getCurSmOwnerSearchScope('VendorContact');
        $tmpuserid_arr = array_keys($Smownerids['UserCombo']);
        if(!empty($tmpuserid_arr)){
            $tmpuserid_str = implode(',',$tmpuserid_arr);
            $vendorcontacts_sql .= ' and find_in_set(ld_vendorcontacts.smownerid,"'.$tmpuserid_str.'") ';
        }
    }
    $vendorcontacts_res = $adb->pquery($vendorcontacts_sql,array($record));
    $vendorcontacts_nums = $adb->num_rows($vendorcontacts_res);
    $vendorcontacts_fieldArr = [];
    if($vendorcontacts_nums>0){
        for($i=0;$i<$vendorcontacts_nums;$i++){
            $vendorcontactsid = $adb->query_result($vendorcontacts_res,$i,'vendorcontactsid');
            $vendorcontactname = $adb->query_result($vendorcontacts_res,$i,'lastname');
            getFieldsValues('VendorContact',$vendorcontactsid,$fieldArr,$vendorcontactname);
        }
    }
}

ConvertTojsonString(1,['list'=>$fieldArr],'success');

function getFieldsValues($module,$record,&$fieldArr,$subfix){
    $temp_focus = CRMEntity::getInstance($module);
    $temp_fieldobj = $temp_focus->fieldobj;
    $temp_focus->retrieve_entity_info($record,$module);
    $temp_focus->id = $record;
    foreach ($temp_fieldobj->getModuleFields() as $fieldinfo)
    {
        if($fieldinfo->bigtype=='mobile'||$fieldinfo->bigtype=='phone') {
            if(in_array($fieldinfo->tableName,$temp_focus->tab_name)){
                $fieldname = $fieldinfo->fieldName;
                $fieldvalue = $temp_focus->column_fields[$fieldname];
                $fieldlabel = $fieldinfo->fieldLableKey;
                if(!empty($subfix)){
                    $fieldlabel = $subfix.' '.$fieldlabel;
                }
                if(!empty($fieldvalue)){
                    $fieldArr[] = array(
                        'tabid' => getTabid($module),
                        'module' => $module,//模块名称  Accounts
                        'fieldlabel' => $fieldlabel,
                        'fieldname' => $fieldname,
                        'fieldvalue' => $temp_focus->column_fields[$fieldname]
                    );
                }

            }
        }
    }
    return $fieldArr;
}





