<?php
//zkt 20231014 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();

global $currentModule,$current_user,$adb,$languageType;
$iscontinue = $_REQUEST['iscontinue'];
$module = $_REQUEST['module'];
$record = $_REQUEST['record'];
$sourcefrom = $_REQUEST['sourcefrom'];
$source_platform = $_REQUEST['source_platform'];
unset($_REQUEST);
$_REQUEST['diony'] = 'yes';

//TODO focus->renewContracts
$tabid = getTabid($module);
//开始日到期日字段是否全启用
crm_load_class_file('ProductToolFields','include/ProductDetails');
$productToolFields = ProductToolFields::getInstance($module);
$moduleAllPresenceField = $productToolFields->getModuleAllPresenceField($tabid,$languageType);
$start_date_presence = array_key_exists('servicecontracts_start_date',$moduleAllPresenceField);
$end_date_presence = array_key_exists('servicecontracts_end_date',$moduleAllPresenceField);
if (!$start_date_presence || !$end_date_presence){
    $fieldlabel_sql = 'select fieldlabel,columnname from ld_producttoolfield where tabid=? and columnname in (?,?)';
    $fieldlabel_result = $adb->pquery($fieldlabel_sql,array($tabid,'servicecontracts_start_date','servicecontracts_end_date'));
    $fieldlabel_num_rows = $adb->num_rows($fieldlabel_result);
    if ($fieldlabel_num_rows){
        for ($i=0;$i<$fieldlabel_num_rows;$i++){
            $fieldlabel =  $adb->query_result($fieldlabel_result,$i,'fieldlabel');
            $columnname =  $adb->query_result($fieldlabel_result,$i,'columnname');
            if ($columnname == 'servicecontracts_start_date' && !$start_date_presence){
                $str[]=$fieldlabel;
            }elseif ($columnname == 'servicecontracts_end_date' && !$end_date_presence){
                $str[]=$fieldlabel;
            }
        }
    }
    $str = implode('"'.getFixedLabel('AND').'"',$str);
    $msg = getVarFixedLabel('CANNOTRENEWEDCONTRACTS','"'.$str.'"');
    ConvertTojsonString(-2,'',$msg);
}
//判断是否已续签
$renewed_sql = 'select renewed from ld_servicecontracts where servicecontractsid=?';
$renewed_result = $adb->pquery($renewed_sql,array($record));
$renewed_num_rows = $adb->num_rows($renewed_result);
if ($renewed_num_rows > 0){
    $renewed_value = $adb->query_result($renewed_result,0,'renewed');
}
//单据被删除继续续签
$renewed_value = $renewed_value =='yes'?'yes':'no';
if ($renewed_value == 'yes' && $iscontinue !='yes'){//已续签第一次提醒
    $msg = getFixedLabel('RENEWEDCONTRACTSCONTINUETIP');
    ConvertTojsonString('confirm_renew','',$msg);
}
$focus = CRMEntity::getInstance($module);
$allPresenceField = $focus->fieldobj->getModuleAllPreseneceFields();
$focus->fieldobj->setModuleFields($allPresenceField);
$moduleFields=$focus->fieldobj->getModuleFields();
$focus->retrieve_entity_info($record, $module);
$detailtablename = $focus->Detail_table;//ld_servicecontractsdetail
$detailtablescfname = $focus->Detail_table_scf;//ld_servicecontractsdetailscf
$detailtableid = $focus->Detail_table_id;//lineitem_id
$detailtableindex = $focus->Detail_table_index;//id
$table_name = $focus->table_name;//ld_servicecontracts
$table_index = $focus->table_index;//servicecontractsid
$tablecf_name = $focus->customFieldTable[0];//ld_servicecontractscf
$tablecf_index = $focus->customFieldTable[1];//servicecontractsid
//分录数据
//获取分录附件字段数据

//$detailattachment = getAllDetailFile_imageInfo($record,$module);
////dump($detailattachment);
//foreach ($detailattachment as $sequence_no => $detailatt){
//    foreach ($detailatt as $detailatt_colunmname =>$info_arr){
//        foreach ($info_arr as $index => $info){
//            $j = $index+1;
//            $detailatt_lineitem_id = $info['lineitem_id'];
//            foreach ($info as $key => $value){
//                $detailattachment_info[$detailatt_lineitem_id][$detailatt_colunmname][$key.'_'.$j] = $value;
//            }
//            $detailattachment_info[$detailatt_lineitem_id][$detailatt_colunmname]['filerowindex_'.$j] = $j;
//            $detailattachment_info[$detailatt_lineitem_id][$detailatt_colunmname]['fieldname_'.$j] = $detailatt_colunmname;
//            $detailattachment_info[$detailatt_lineitem_id][$detailatt_colunmname]['file_num'] = $j;
//        }
//    }
//}

//是否被允许选择被禁用的产品单据
$deployarr_82 = getSys_deploy(82);
$deploy82_value = $deployarr_82['deploy_value'];

$detail_sql = 'select ld_products.discontinued,'.$detailtablename.'.* from '.$detailtablename.' left join '.$detailtablescfname.' on '.$detailtablename.'.'.$detailtableid.' = '.$detailtablescfname.'.'.$detailtableid;
$detail_sql .= ' left join ld_products on ld_products.productid = '.$detailtablename.'.productid';
$detail_sql .= ' where '.$detailtablename.'.'.$detailtableindex.' = ?';
$detail_result = $adb->pquery($detail_sql,array($record));
$detail_num_rows = $adb->num_rows($detail_result);
$detail_infos = $adb->query_result_all($detail_result);
$now = date('Y-m-d');
$tmpindex = 0;
foreach ($detail_infos as $index => $tmpinfo){
    //判断系统参数是否选择被禁用
    $discontinued = $tmpinfo['discontinued'];
    if ($deploy82_value == '0' && $discontinued == '1'){// 不允许选择禁用的单据&&单据被禁用
        continue;
    }
    $tmpindex ++;
    //获取每条明细的开始日和到期日
    $servicecontracts_start_date = $tmpinfo['servicecontracts_start_date'];
    $servicecontracts_end_date = $tmpinfo['servicecontracts_end_date'];
    //判断是否到期并获取新日期
    if (empty($servicecontracts_end_date) || strtotime($servicecontracts_end_date) < strtotime($now)){//到期
        $new_start_date = $now;
        $new_end_date = date('Y-m-d',strtotime('+364 day',strtotime($now)));
    }else{//未到期
        $new_start_date = date('Y-m-d',strtotime('+1 day',strtotime($servicecontracts_end_date)));
        $new_end_date = date('Y-m-d',strtotime('+365 day',strtotime($servicecontracts_end_date)));
    }
    //分录附件字段
//    $lineitem_id = $tmpinfo['lineitem_id'];
//    $detailatt_info = $detailattachment_info[$lineitem_id];
//    if (!empty($detailatt_info)){
//        foreach ($detailatt_info as $detail_colunmname => $attinfo){
//            foreach ($attinfo as $key => $value){
//                $_REQUEST[$detail_colunmname.$tmpindex.'-'.$key] = $value;
//            }
//        }
//    }
    //分录数据
    foreach ($tmpinfo as $columnname => $value){
        if ($columnname == $detailtableindex || $columnname == 'sequence_no'){
            continue;
        }
        $key = $columnname.$tmpindex;
        switch ($columnname){
            case 'lineitem_id':
                $value = 0;
                $_REQUEST['before_lineitem_id'.$tmpindex] = 0;
                break;
            case 'servicecontracts_start_date':
                $value = $new_start_date;
                break;
            case 'servicecontracts_end_date':
                $value = $new_end_date;
                break;
            case 'productid':
                $key = 'hdnProductId'.$tmpindex;
                break;
        }
        $_REQUEST[$key] = $value;
    }
    $_REQUEST['rowcnt'] = $tmpindex;

}
//主表数据
//附件字段数据
//$file_num = [];
//$attachement_infos = getAllFile_imageInfo($record,$module);
//foreach ($attachement_infos as $columnname =>$attachment_info){
//    foreach ($attachment_info as $index => $tmpinfo){
//        $i = $index + 1;
//        foreach ($tmpinfo as $key => $value){
//            $_REQUEST[$columnname.'-'.$key.'_'.$i] = $value;
//        }
//        $_REQUEST[$columnname.'-file_num'] = $i;
//    }
//}

//获取主表数据
$contract_no = $focus->Library('SystemCode')->getModuleSeqNumRecord($module);
$select_sql = 'select * from '.$table_name.' left join '.$tablecf_name.' on '.$tablecf_name.'.'.$tablecf_index.'='.$table_name.'.'.$table_index.' where '.$table_name.'.'.$table_index.'= ?';
$select_result = $adb->pquery($select_sql,array($record));
$infos = $adb->query_result_all($select_result)[0];
foreach ($infos as $columnname => $value){
    if ($columnname == 'due_date'){
       $value = $now;
    }elseif ($columnname == $table_index){
        continue;
    }
    $uitype = $focus->fieldobj->getFieldInfoBykeyValue('columnname',$columnname,'uitype');
    $fieldname = $focus->fieldobj->getFieldInfoBykeyValue('columnname',$columnname,'fieldname');
    if ($uitype == 4){//编号
        $value = $contract_no;
    }
    if ($columnname == 'total' || $columnname == 'subtotal'){
        $_REQUEST[$columnname] = $value;
    }else if (!empty($fieldname)){
        $_REQUEST[$fieldname] = $value;
    }
}
//负责人

//验证规则开始判断
//非管理员  获取字段权限
if(!is_admin($current_user)){
    $profileobj=Profile::getInstance();
    $profilefields= $profileobj->getProfileInfos($current_user->profileid);
    $profilefields=$profilefields['field'];
}
//判断必填属性
crm_load_class_file('cls_getdisplayfiledsbyrecord','include/fields');
$cls_getdisplayfiledsbyrecordobj = new cls_getdisplayfiledsbyrecord($module,$record);
//附件图片字段不设置值
foreach ($moduleFields as $tmpfieldname=>$tmpfieldinfo){
    if($tmpfieldinfo->getUIType()!=69&&$tmpfieldinfo->getUIType()!=1108&&$tmpfieldinfo->getUIType()!=1109){
        $changefieldvalue_arr = array($tmpfieldname=>$_REQUEST[$tmpfieldname]);
        $cls_getdisplayfiledsbyrecordobj->changeFieldvlaueByFieldname($changefieldvalue_arr);
    }
}
$displayfields = $cls_getdisplayfiledsbyrecordobj->getdisplayFieldinfo();
foreach ($moduleFields as $tmpfieldname=>$tmpfieldinfo){
    $tmpfieldid = $tmpfieldinfo->getFieldid();
    //布局规则隐藏字段不需要判断必填属性
    if(empty($displayfields[$tmpfieldname])){
        continue ;
    }
    $tmpvalue = $displayfields[$tmpfieldname]['value'];
    $requirecolumn = $displayfields[$tmpfieldname]['requirecolumn'];
    $tmptypeofdate = $tmpfieldinfo->getTypeOfData();
    $tmptypeofdatearr=explode('~',$tmptypeofdate);
    if($requirecolumn == 'yes' && empty($tmpvalue)){
        //zkt 20240422 BUG20240415-75  为什么单据都已经保存审核了，修改附件，还会提示有字段不能为空？
        if($tmpvalue == '0' || $tmpvalue == 0){
            if($tmpvalue != ''){
                continue;
            }
        }
        $tmpfieldlabel = $tmpfieldinfo->getfieldLabel();
        ConvertTojsonString("-2",'',getFixedLabel('RENEWEDUNSUCCESSFULLY').$tmpfieldlabel.getFixedLabel('APPCANNOTBEEMPTY'));
    }
}
//先判断验证规则
crm_load_class_file('cls_PageValidataSaveJS','data');
$currency_id=$focus->column_fields['currency_id'];
$PageValidataSavejsobj=new cls_PageValidataSaveJS($module,$record,$_REQUEST['rowcnt']);
if(!$PageValidataSavejsobj->getValidDataJudgeJs()){
    ConvertTojsonString("-2",'',$PageValidataSavejsobj->errortip);
}

//允许保存的验证规则的判断
if (!empty($source_platform)){//移动端
    $focus->currency_status = false;
    $currencyobj=Currency::getInstance($adb,$currency_id);
    $currencySymbol = $currencyobj->getCurrencySymbol();
    $currencyRate = $currencyobj->getCurrencyRate();
    $focus->column_fields['conversion_rate'] = $currencyRate;
    $focus->column_fields['currency_symbol'] = decode_html($currencySymbol);
}
crm_load_class_file('cls_PageValidataSave','data');
$PageValidataSaveobj=new cls_PageValidataSave($module,$record,$_REQUEST['rowcnt']);
$PageValidataSaveobj->setAllowSave('yes');
$currency_id = empty($currency_id)? 1 : $currency_id;
$PageValidataSaveobj->setCurrencyId($currency_id);
$PageValidataSaveobj->getValidDataInfoPhp();
if(!empty($PageValidataSaveobj->errortip)){
    ConvertTojsonString("-2",'',$PageValidataSaveobj->errortip);
}

//dump($_REQUEST);
//保存
$focus->mode = 'create';
setObjectValuesFromRequest($focus);
unset($focus->column_fields['record_id']);
unset($focus->column_fields['record_module']);
$focus->save_overpermission = 'yes';
$focus->save($module);
$newrecordid = $focus->id;
if (!empty($newrecordid)){
    $update_sql = 'update '.$table_name.' set renewed = ? where '.$table_index.' = ?';
    $adb->pquery($update_sql,array('yes',$record));
    $update_sql2 = 'update '.$table_name.' set renewfrom = ? where '.$table_index.' = ?';
    $adb->pquery($update_sql2,array($record,$newrecordid));
}
//dump([$contract_no,$focus->column_fields,$focus->id]);
$arr['contract_no'] = $contract_no;
$msg = getFixedLabel('RENEWEDSUCCESSFULLY');
if($sourcefrom == 'PC'){
    $entityinfo = getEntitynameInfo($tabid);
    $entityfieldlabel = $allPresenceField[$entityinfo['fieldname']]->getfieldLabel();
    $entityfieldname = $entityinfo['fieldname'];
    $entityvalue = $focus->column_fields[$entityfieldname];
    $href = 'index.php?pageto_module='.$module.'&amp;pageto_action=index&amp;pageto_record='.$newrecordid;
    $msg .= '<br/><span>'.$entityfieldlabel.':&ensp;</span><a name="hyperlink" fieldname="'.$entityfieldname.'" module="'.$module.'" record="'.$newrecordid.'" href="'.$href.'" onclick="msgConfirm();ListLinkClick(ld(this),event)" title="'.$entityvalue.'">'.$entityvalue.'</a>';
}
ConvertTojsonString('1',$arr,$msg);


?>