<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//ls 2022-03-10 【1002521】页面设置，增加【字段列表】标签
require_once('include/CustomFieldUtil.php');
require_once 'modules/PickList/PickListUtils.php';
global $adb;
$_REQUEST['diony']='yes';
$smarty=new lingdangCRM_Smarty;

$fld_module=vtlib_purify($_REQUEST['fromodule']);
$searchtext=vtlib_purify($_REQUEST['searchtext']);
if($fld_module=='Calendar') {
    $fld_module='Events';
}

$subMode = $_REQUEST['sub_mode'];
if ($subMode == 'updateFieldPresence'){
    //更改字段启用状态
    updateFieldPresence();
    ConvertTojsonString(1,array(),'success');//如果启用状态需要刷新页面，删除该行返回值即可。
}


$smarty->assign("MODULE",$fld_module);
$fieldz = getFieldList($fld_module,$searchtext);
//dump($fieldz);
$smarty->assign("CFENTRIES",$fieldz);//字段信息

if(isset($_REQUEST['ajax']) && $_REQUEST['ajax']==true){
    $arr['content']=$smarty->fetch('Settings/LayoutBlockFieldListEntries.tpl');
}else{
    $arr['content']=$smarty->fetch('Settings/LayoutBlockFieldList.tpl');
}
ConvertTojsonString(1,$arr,'success');


function getFieldList($module,$searchtext='') {
    global $handleWriteSign_interface;

    if($module=='Events')
    {
        $tabid =16;
    }
    else
    {
        $tabid = getTabid($module);
    }
    global $adb, $smarty,$current_user,$languageType;
    global $theme;
    $theme_path="themes/".$theme."/";
    $image_path="themes/images/";

    require('user_privileges/user_language_'.$current_user->id.'.php');
    $otherlanguage='zh';
    if($languageType=='zh')
    {
        $otherlanguage='en';
    }
    $notShowModulecolumns['Users']=array('time_zone','date_format','activity_view','lead_view','language','theme','email2','reports_to_id','currency_id','email2','secondaryemail','phone_other','level','hour_format','start_hour');

    if($module == 'Users'){
        $otherConditions = " and blocklabel<>'LBL_CURRENCY_CONFIGURATION' and blocklabel<>'LBL_MORE_INFORMATION'";
    }

    //字段搜索
    if (!empty($searchtext)) {
        $otherConditions .=" AND (ld_tranlabel.fieldlabel like '%".$searchtext."%' OR ld_field.columnname like '%".$searchtext."%') ";
    }

    $focus = CRMEntity::getInstance($module);
    $nonEditableUiTypes = array('70','117');

    $fieldobj=Field::getInstance($module,$adb);
    $referenceFieldNames = array_keys($fieldobj->getReferenceFieldDetails());


    //借鉴字段布局显示的字段sql
    if($module!='Invoices' && $module!='Quotes' && $module!='SalesOrder' && $module!='Invoice') {
        $sql_field="select distinct ld_tranlabel.fieldlabel, othertable.otherlabel,ld_field.fieldid,
                columnname,defaultvalue ,block,uitype,bigtype,relatedmodulefield,fieldonly,presence,fieldname,quickcreate,masseditable,typeofdata,
                displaytype ,approve_demand,advance_demand,advance_demand_groups,allowhide,createdtime,tablename,'ld_fieldid' as fieldtable
                from  ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
                INNER JOIN ld_blocks ON ld_field.block = ld_blocks.blockid
                 inner join (select ld_tranlabel.fieldlabel as otherlabel,relateid from ld_tranlabel inner
                  join ld_field on ld_field.fieldid=ld_tranlabel.relateid where languagetype=? 
                  and trantable=? and ld_tranlabel.tabid=? and ld_field.tabid=? order by sequence,fieldid asc ) as othertable 
                             on othertable.relateid=ld_tranlabel.relateid
                     where languagetype=? and trantable=? and ld_field.tabid = ? and ld_tranlabel.tabid=?  and ld_field.displaytype IN (1,2,4) 
                     AND ld_blocks.tabid=? AND  ld_blocks.visible=0 AND IFNULL(blocklabel,'')<>'' AND IFNULL(blocklabel,'')<>'LBL_LABEL' AND blocklabel<>'LBL_PUBLICACCOUNT_LOG' ".$otherConditions."
                     order by ld_blocks.sequence,ld_blocks.blockid,ld_field.sequence,fieldid ASC ";
        $sql_field_params = array($otherlanguage,'ld_field',$tabid,$tabid,$languageType,'ld_field',$tabid,$tabid,$tabid,);



    }else {
        $sql_field="select distinct ld_tranlabel.fieldlabel, othertable.otherlabel,ld_field.fieldid,columnname
                        ,defaultvalue ,block,uitype,bigtype,relatedmodulefield,fieldonly,presence,fieldname,quickcreate,masseditable,typeofdata 
                        ,displaytype,approve_demand,advance_demand,advance_demand_groups,allowhide,createdtime,tablename,'ld_fieldid' as fieldtable
                            from  ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid 
                            INNER JOIN ld_blocks ON ld_field.block = ld_blocks.blockid
                             inner join (select ld_tranlabel.fieldlabel as otherlabel,relateid from ld_tranlabel inner join ld_field on ld_field.fieldid=ld_tranlabel.relateid where languagetype=? and trantable=? and ld_tranlabel.tabid=? order by sequence,fieldid asc ) as othertable 
                             on othertable.relateid=ld_tranlabel.relateid
                     where languagetype=? and trantable=? and ld_field.tabid = ? and  ld_tranlabel.tabid=? and (ld_field.fieldlabel!='Total' and ld_field.fieldlabel!='Sub Total' and ld_field.fieldlabel!='Tax') and ld_field.displaytype IN (1,2,4) 
                     AND ld_blocks.tabid=? AND  ld_blocks.visible=0 AND IFNULL(blocklabel,'')<>'' AND IFNULL(blocklabel,'')<>'LBL_LABEL' AND blocklabel<>'LBL_PUBLICACCOUNT_LOG' ".$otherConditions."
                     order by ld_blocks.sequence,ld_blocks.blockid,ld_field.sequence,fieldid ASC ";
        $sql_field_params = array($otherlanguage,'ld_field',$tabid,$languageType,'ld_field',$tabid,$tabid,$tabid);
    }
    $result_field = $adb->pquery($sql_field,$sql_field_params);
    $row_field= $adb->fetch_array($result_field);
    $cf_element=Array();
    $cf_hidden_element=Array();
    $count=0;
    $hiddencount=0;

    //单据分录
    if(get_file_address($module,"ProductDetails")||get_file_address($module,$module."DetailFieldsHtml"))
    {

        //edit:can  BUG20240117-40 成员管理-页面设置-数据字典，无法打开，一直转圈（kfbcrm通用bug）

        $tem_sql_field = "SELECT DISTINCT ld_tranlabel.fieldlabel,ld_field.bigtype,columnname,tablename,presence,allowhide,uitype,fieldtable,ld_field.tabid,ld_field.fieldid
                          FROM ld_tranlabel
                          INNER JOIN(SELECT fieldlabel,bigtype,sequence,columnname,tablename,presence,allowhide,tabid,uitype,'ld_producttoolfield' as fieldtable,producttoolfieldid as fieldid
                                     FROM ld_producttoolfield
                                     UNION
                                     SELECT fieldlabel,bigtype,sequence,columnname,tablename,presence,allowhide,tabid,fieldtype as uitype,'ld_tabdetailfield' as fieldtable,tabdetailfieldid as fieldid
                                     FROM ld_tabdetailfield) as ld_field 
                          ON ld_field.fieldlabel = ld_tranlabel.fieldlabel
                          
                          WHERE ld_field.tabid =? ".$otherConditions."
                          order by ld_field.sequence,fieldid ASC";
        $tem_sql_field_params = array($tabid);
        $tem_result_field = $adb->pquery($tem_sql_field,$tem_sql_field_params);

        $tem_row_field= $adb->fetch_array($tem_result_field);
    }
    $check = Array();


    if ($row_field != '') {
        do {
            $documenthead = getFixedLabel('DOCHEAD');
            $fieldlabel = getTranFieldForModuleLabel($row_field['fieldlabel']);
            $tablename = $row_field['tablename'];
            $fieldid = $row_field['fieldid'];
            $presence = $row_field['presence'];
            $fieldname = $row_field['fieldname'];
            $customfieldflag = InStrCount($row_field['fieldname'], 'cf_', true);
            $quickcreate = $row_field['quickcreate'];
            $massedit = $row_field['masseditable'];
            $typeofdata = $row_field['typeofdata'];
            $displaytype = $row_field['displaytype'];
            $uitype = $row_field['uitype'];
            $bigtype = $row_field['bigtype'];
            $relatedmodulefield = $row_field['relatedmodulefield'];
            $fieldtable=$row_field['fieldtable'];
            if ($relatedmodulefield == 'yes') {
                $bigtype = 'relatedmodulefield';
            }


            if ($uitype == 222 && $handleWriteSign_interface == 0) {
                continue;
            }
            $fieldonly = $row_field['fieldonly'];

            $fld_type_name = getCustomFieldTypeByBigtype($uitype, $bigtype,$fieldtable);
            $defaultValue = $row_field['defaultvalue'];
            $approve_demand = $row_field['approve_demand'];
            $advance_demand = $row_field['advance_demand'];
            $advance_demand_groups = $row_field['advance_demand_groups'];
            $allowhide = $row_field['allowhide'];
            if ($focus->list_link_field == $fieldname) {
                //36733: 模块超链接字段应该控制不允许隐藏。
                $allowhide = 'no';
            }

            $createdtime = $row_field['createdtime'];

            if (!empty($defaultValue) && ($uitype == '5' || $uitype == '6' || $uitype == '23' || $uitype == '86')) {
                //21558: 控制面板>页面设置>销售机会：编辑字段“预计成交日期”，设置默认值为明天，保存后，查看该字段属性，还是显示为“今天”
                //$defaultValue = date("Y-m-d",strtotime($defaultValue));
            }
            if (is_array($notShowModulecolumns[$module]) && in_array($row_field['columnname'], $notShowModulecolumns[$module])) {
                continue;
            }

            //费用报销币种已迁移到了明细里，在这里因为考虑到其他报表使用了币种计算费用金额，所以不直接deleted永久隐藏处理
            if ($module == 'Expense' && $row_field['columnname'] == 'currency_id') {
                continue;
            }
            $otherlabel = ($row_field['otherlabel']);

            $defaultPermitted = true;
            $strictlyMandatory = false;
            if (isset($focus->mandatory_fields) && (!empty($focus->mandatory_fields)) && in_array($fieldname, $focus->mandatory_fields)) {
                $strictlyMandatory = true;
                $defaultPermitted = false;
            } elseif (in_array($uitype, $nonEditableUiTypes) || $displaytype == 2) {
                $strictlyMandatory = true;
                $defaultPermitted = false;
            }
            if (in_array($fieldname, $referenceFieldNames)) {
                $defaultPermitted = false;
            }
            $visibility = getFieldInfo($fieldname, $typeofdata, $quickcreate, $massedit, $presence, $strictlyMandatory, $customfieldflag, $displaytype, $uitype);
            if ($module == 'Users') {
                if (in_array($fieldname, array('user_name', 'user_password', 'confirm_password', 'last_name', 'profileid'))) {
                    $visibility['mandatory'] = 4;
                }
            }
            //if($visibility)
            $allValues = array();
            if (in_array($uitype, array('15', '16', '33'))) {
                if ($fieldname == 'approvestatus' && $module == 'Users') {
                    $allValues = array(getFixedLabel('ACTIVATE'), getFixedLabel('INACTIVATE'));
                } else {
                    $allValues = getAllPickListValues($fieldname);
                }

            }

            if (in_array($uitype, array('251', '252'))) {
                crm_load_class_file("BankAccountSet", "modules/BankAccountSet");
                $bankresult = BankAccountSet::getBackAccount(1);

                for ($tmpi = 0; $tmpi < $adb->num_rows($bankresult); $tmpi++) {
                    $allValues[$adb->query_result($bankresult, $tmpi, 'bankaccountsetid')] = $adb->query_result($bankresult, $tmpi, 'accountname');

                }


            }


            $cf_element[$count]['tablename'] = $tablename;
            $cf_element[$count]['documenthead'] = $documenthead;
            $cf_element[$count]['fieldid'] = $fieldid;
            $cf_element[$count]['blockid'] = $row_field['block'];
            $cf_element[$count]['tabid'] = $tabid;
            $cf_element[$count]['no'] = $count;
            $cf_element[$count]['label'] = $fieldlabel;
            $cf_element[$count]['otherlabel'] = $otherlabel;
            $cf_element[$count]['fieldlabel'] = $row_field['fieldlabel'];
            $cf_element[$count]['type'] = $fld_type_name;
            $cf_element[$count]['typeofdata'] = $typeofdata;
            $cf_element[$count]['uitype'] = $uitype;
            $cf_element[$count]['bigtype'] = $bigtype;
            $cf_element[$count]['columnname'] = $row_field['columnname'];

            $cf_element[$count]['defaultvalue'] = array('permitted' => $defaultPermitted, 'value' => $defaultValue, '_allvalues' => $allValues);
            $cf_element[$count] = array_merge($cf_element[$count], $visibility);
            $cf_element[$count]['fieldonly'] = $row_field['fieldonly'];
            $cf_element[$count]['displaytype'] = $displaytype;
            $cf_element[$count]['approve_demand'] = $approve_demand;
            $cf_element[$count]['advance_demand'] = $advance_demand;
            $cf_element[$count]['advance_demand_groups'] = $advance_demand_groups;
            $cf_element[$count]['allowhide'] = $allowhide;
            $cf_element[$count]['createdtime'] = $createdtime;
            $count++;
        } while ($row_field = $adb->fetch_array($result_field));
    }
    if($tem_row_field!=''){
        do {
            $fieldlabel = getTranFieldForModuleLabel($tem_row_field['fieldlabel']);
            $documenthead = getFixedLabel('DOCENTRY');
            $uitype = $tem_row_field['uitype'];
            $bigtype = $tem_row_field['bigtype'];
            $fieldtable = $tem_row_field['fieldtable'];
            $fld_type_name = getCustomFieldTypeByBigtype($uitype,$bigtype,$fieldtable);
            $columnname = $tem_row_field['columnname'];
            $fieldid = $tem_row_field['fieldid'];
            $tablename = $tem_row_field['tablename'];
            $allowhide = $tem_row_field['allowhide'];
            $presence = $tem_row_field['presence'];
            $tmpkey = $tablename.$columnname;
            if(in_array($tmpkey,$check)){
                continue;
            }
            $check[$count]=$tmpkey;
            $cf_element[$count]['label']=$fieldlabel;
            $cf_element[$count]['documenthead']=$documenthead;
            $cf_element[$count]['type']=$fld_type_name;
            $cf_element[$count]['columnname']=$columnname;
            $cf_element[$count]['fieldid']=$fieldid;
            $cf_element[$count]['tablename']=$tablename;
            $cf_element[$count]['createdtime']=null;
            $cf_element[$count]['allowhide']=$allowhide;
            $cf_element[$count]['presence']=$presence;
            $cf_element[$count]['fieldtable']=$fieldtable;
            $count++;
        } while ($tem_row_field= $adb->fetch_array($tem_result_field));
    }
    return $cf_element;
}

function updateFieldPresence() {
    global $adb,$current_user;
    $fieldid = $_REQUEST['fieldid'];
    if(empty($fieldid)) return;

    $req_sql = "select typeofdata,tabid,fieldname,uitype,fieldlabel,tablename,quickcreate,masseditable,presence,
    fieldonly,columnname,bigtype,allowedit from ld_field where fieldid = ? and ld_field.presence in (0,2)";
    $req_result = $adb->pquery($req_sql, array($fieldid));

    $typeofdata = $adb->query_result($req_result,0,'typeofdata');
    $tabid = $adb->query_result($req_result,0,'tabid');

    $fieldname = $adb->query_result($req_result,0,'fieldname');
    $uitype = $adb->query_result($req_result,0,'uitype');
    $oldfieldlabel = $adb->query_result($req_result,0,'fieldlabel');
    $tablename = $adb->query_result($req_result,0,'tablename');
    $columnname = $adb->query_result($req_result,0,'columnname');
    $oldquickcreate = $adb->query_result($req_result,0,'quickcreate');
    $oldmassedit = $adb->query_result($req_result,0,'masseditable');
    $oldpresence = $adb->query_result($req_result,0,'presence');
    $bigtype=$adb->query_result($req_result,0,'bigtype');


    if($tabid==6)//客户
    {
        $servicecharge_tabid=getTabid('ServiceCharge');
        $req_sql = "select fieldid from ld_field where columnname = ? and tabid=?  and ld_field.presence in (0,2)";

        $service_charge_req_result = $adb->pquery($req_sql, array($columnname,$servicecharge_tabid));
        if($adb->num_rows($service_charge_req_result))
        {
            $service_charge_id=$adb->query_result($service_charge_req_result,0,0);
        }

    }

    if(!empty($_REQUEST['fromodule'])) {
        $fld_module = vtlib_purify($_REQUEST['fromodule']);
    }else {
        $fld_module = getTabModuleName($tabid);
    }

//    $focus = CRMEntity::getInstance($fld_module);
    $presence_check = $_REQUEST['isPresent'];

    if($oldpresence != 3) {
        if($presence_check == 'true' || $presence_check == '') {
            $presence = 2;
        }else {
            $presence = 1;
        }
    }else {
        $presence =1;
    }

    if($bigtype=='mobile')
    {
        if($presence==1)
        {
            $sql='delete from ld_validatasavedetail where relateid in(select id from ld_validatasave where module=? and  fieldname=? and relatedtable=?  and comparator=?)';
            $adb->pquery($sql,array($fld_module,$fieldname,'ld_field','regexp'));

            $sql=' delete from  ld_validatasave where module=? and  fieldname=? and relatedtable=?  and comparator=?';
            $adb->pquery($sql,array($fld_module,$fieldname,'ld_field','regexp'));
        }
        else
        {
            $sql='select id from ld_validatasave where module=? and  fieldname=? and relatedtable=?  and comparator=?';
            $tmpresult=$adb->pquery($sql,array($fld_module,$fieldname,'ld_field','regexp'));
            if($adb->num_rows($tmpresult)<=0)
            {
                $sql='insert into  ld_validatasave(module,relatedtable,fieldname,comparator,formulavalue,comparatordescription,validatasavetype,isshowlist)
                            value(?,?,?,?,?,?,?,?)';
                $adb->pquery($sql,array($fld_module,'ld_field',$fieldname,'regexp','','正则表达式','js','no'));
                $tmp_relateid=$adb->getLastInsertID();
                $sql='insert into  ld_validatasavedetail(relateid,relateformulavalue,sequence)value(?,?,?)';
                $adb->pquery($sql,array($tmp_relateid,"^1\\d{10}$",1));
            }
        }

    }

    //联系人模块改了字段名，客户首要联系人区块下的那些字段也同步修改；
    $tabmodulename = getTabModuleName($tabid);
    if($tabid==4 || ($tabmodulename == 'Accounts' && ($tablename == 'ld_contactdetails' || $tablename == 'ld_contactscf')) || ($tabmodulename == 'ServiceCharge' && ($tablename == 'ld_contactdetails' || $tablename == 'ld_contactscf')))//联系人	、客户 、服务收费管理
    {
        $servicechargetabid=getTabid('ServiceCharge');
        //BUG20240815-34 ls 240821 客户隐藏首要联系人字段，联系人模块里的不应该隐藏
        if($tabid == 4){
            $update_tabid = array(6,$servicechargetabid);
        }else if($tabmodulename == 'Accounts'){
            $update_tabid = array($servicechargetabid);
        }else{
            $update_tabid = array(6);
        }
        $colname=$columnname;
        foreach($update_tabid as $stabid){
            $sql="update ld_field set presence =?  where columnname=? and tablename=? and tabid=? "	;
            $adb->pquery($sql,array($presence,$columnname,$tablename,$stabid));
        }
        $cachekey = 'cache_productdetails_setModuleFields_'.$tabmodulename.'_setModuleFields_'.$current_user->profileid;
        unsetCache($cachekey);
    }


    if(!empty($service_charge_id))
    {
        $colname=$columnname;
        $sql="update ld_field set presence=? where fieldid=?";
        $adb->pquery($sql,array($presence,$service_charge_id));
    }

    //更新启用状态
    $sql=' update ld_field set presence=? where fieldid=? ';
    $adb->pquery($sql,array($presence,$fieldid));

    //合同订单：关闭“上级合同”字段后，合同相关信息不应该显示【变更单（子合同）】
    if(getTabModuleName($tabid) == 'SalesOrder' && $colname == 'parentid'){	//客户
        $related_module = getTabModuleName($tabid);
        $query = 'update ld_relatedlists set presence = ? where tabid = ? and related_tabid = ? and `name` = \'get_salesorder\' and label = ?';
        $adb->pquery($query,array($presence,$tabid,$tabid,$related_module));
    }


    /*$presence_query = "update ld_field set presence = ? where fieldid = ? and presence not in (0,3) and quickcreate != 0";
    $quickcreate_params = array($presence,$fieldid);
    $adb->pquery($presence_query,$quickcreate_params);*/

    unsetCacheDirectory('Cache');
    clearCacheFiles();//删除数据缓存
    unsetCacheDirectory('fields');
}

?>