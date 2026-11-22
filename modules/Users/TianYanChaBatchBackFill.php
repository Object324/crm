<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user;
$module = $_REQUEST['frommodule'];
// if($module == 'Accounts'){
//     $tabbusinessname = 'accountname';
// }
// else if($module == 'Vendors'){
//     $tabbusinessname = 'vendorname';
// }
// else if($module == 'ServiceCharge'){
//     $tabbusinessname = 'accountname';
// }


$error = 0;
$success = 0;
//获取批量处理数
$deployarray=getSys_deploy(67);
$btach_num =  $deployarray['deploy_value'];
$batchsuccesslog = getFixedLabel('DOCUMENTSUCCESS');//单据[%s]%s成功！
$batcherrorlog = getFixedLabel('documenterrorinfo');//单据[%s]%s失败！原因：%s!
//获取模块链接字段
$tabid = getTabid($module);
$entityarray = getEntitynameInfo($tabid);
$tabname = $entityarray['tablename'];
$tabindex = $entityarray['entityidfield'];
$tabfieldname = $entityarray['fieldname'];
$focus=CRMEntity::getInstance($module);
$table_name = $focus->table_name;//字段主表
$custom_tabname = $focus->customFieldTable[0];//自定义字段表
$modulefields=$focus->fieldobj->getModuleFields();
/*$assigned=$field_obj->getFieldName();
$fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$tabfieldname);
$fieldinfo_field=$fieldinfo->getfieldLabel();*/
//获取模块回填字段
crm_load_class_file('cls_BusinessInformation', 'modules/Users');
$businessinformationobj = cls_BusinessInformation::getInstance($module);
$tabbusinessname = $businessinformationobj->getModuleBusinessQueryField('columnname');
$backfillfields_arr = $businessinformationobj->getBackFillfields();
$backfillarr = array();
foreach($backfillfields_arr as $key => $backfillinfo)
{
    $tianyanchaname = $backfillinfo['tianyanchaname'];
    $trancolumnname = $backfillinfo['trancolumnname'];
    $fieldname = $backfillinfo['fieldname'];
    $type = $backfillinfo['type'];
    if($trancolumnname == 'null'||!empty($modulefields[$fieldname]))continue;
    $backfillarr[$trancolumnname] = array('tianyanchaname'=>$tianyanchaname,'bigtype'=>$type);
}
$detailaddress_arr = array('bill_country','bill_state','bill_city','bill_area','bill_street','street');
$poiaddress_arr = array('address','state','city','district','point','country');
//批量回填功能是否启用
if(!$businessinformationobj->IsEnableBatchbackfill() || isPermitted($module, 'BatchBackFilling','')!='yes'){
    $edit_err = getFixedLabel('BatchBackFillingunusing'); //批量回填功能未启用
}
$VersionInfo = getVersionInfo();
//
if(empty($backfillarr))
{
    $edit_err = getFixedLabel('NOBACKFILLFIELDS'); //无可回填字段
}
$objPickList = crm_load_class_obj("cls_PickList",'modules/PickList',array());
global $global_picklist_colors;
$pickbyfieldnamearr = [];

if($_REQUEST['idstring'] && !empty($_REQUEST['idstring'])&&$businessinformationobj->IsEnableBatchbackfill() && isPermitted($module, 'BatchBackFilling','')=='yes'&&!empty($backfillarr))
{
    include './modules/lingdang/staticlingdang.class.php';
    $ldcls = new staticlingdang();
    crm_load_class_file('cls_GetTianYanCha', 'modules/Users');
    crm_load_class_file('Contacts','modules/Contacts');
    $excludedRecords = vtlib_purify($_REQUEST['excludedRecords']);
    $storearray = getSelectedRecords($_REQUEST, $module, $_REQUEST['idstring'],$excludedRecords);
    $storearray=array_filter($storearray);
    $searcharr = [];
    if(count($storearray)>0){
        $ids = implode(",",$storearray);
        $query = "select $tabbusinessname,$tabfieldname as subject,smownerid,$table_name.$tabindex  from $table_name left join $custom_tabname 
                    on $table_name.$tabindex = $custom_tabname.$tabindex where $table_name.$tabindex in ($ids)";
// dump($query);

        $result = $adb->pquery($query,array());
        $rows = $adb->num_rows($result);
        for($tmpi=0;$tmpi<$rows;$tmpi++){
            $subject = $adb->query_result($result,$tmpi,'subject');
            $tmpid = $adb->query_result($result,$tmpi,$tabindex);
            $businessname = $adb->query_result($result,$tmpi,$tabbusinessname);
            $smownerid=$adb->query_result($result,$tmpi,'smownerid');
            $searcharr[$tmpid] = array('subject'=>$subject,$tabbusinessname=>$businessname,'smownerid'=>$smownerid);
        }

        //单据保存值获取 存在特殊模块retrieve_entity_info获取信息不全
        foreach($modulefields as $tmpfieldname=>$tmpfieldinfo){
            $tmptabname = $tmpfieldinfo->getTableName();
            $tmpcolumnname = $tmpfieldinfo->getColumnName();

            //客户、服务收费管理模块，联系人信息
            if(($module == 'Accounts' || $module == 'ServiceCharge') && in_array($tmptabname,array('ld_contactdetails','ld_contactscf'))){
                $contactfieldnames[]=$tmpfieldname;
                $contactcolumns[]=$tmpcolumnname;
            }
        }
        $contactcolumnsarr = [];
        if(($module == 'Accounts' || $module == 'ServiceCharge') && !empty($contactcolumns)){
            $columns=implode(',',$contactcolumns);
            //inner join ld_crmentity on ld_crmentity.crmid=ld_contactdetails.contactid
            $sqlcontact="select $columns,ld_contactdetails.contactid,accountid from ld_contactdetails 
	        left join ld_contactscf on ld_contactscf.contactid=ld_contactdetails.contactid
	        where accountid in ($ids) and reference=1 and ld_contactdetails.deleted=0 order by contact_no asc limit 0,1";
            $resultcontact=$adb->pquery($sqlcontact,array());
            $tmprows = $adb->num_rows($resultcontact);
            for($tmpi=0;$tmpi<$tmprows;$tmpi++){
                $tmpcontactarr = [];
                $tmpaccountid = $adb->query_result($resultcontact,$tmpi,'accountid');
                for($i=0;$i<sizeof($contactfieldnames);$i++)
                {
                    $tmpcontactarr[$contactfieldnames[$i]]=$adb->query_result($resultcontact,$tmpi,$contactcolumns[$i]);
                }
                $contactid = $adb->query_result($resultcontact,$tmpi,'contactid');
                $tmpcontactarr["contactid"]=$contactid;
                $contactcolumnsarr[$tmpaccountid]=$tmpcontactarr;
            }
        }
    }


    foreach($storearray as $key => $id)
    {
		if($btach_num <= $key)break;
		if(empty($id) || $id <=0)continue;

        if(empty($searcharr[$id])){
            $query = "select $tabbusinessname,$tabfieldname as subject,smownerid from $table_name left join $custom_tabname 
                        on $table_name.$tabindex = $custom_tabname.$tabindex where $table_name.$tabindex = ?";
            $result = $adb->pquery($query,array($id));
            $subject = $adb->query_result($result,0,'subject');
            $smownerid=$adb->query_result($result,0,'smownerid');//负责人id
            $businessname = $adb->query_result($result,0,$tabbusinessname);
        }
        else{
            $subject = $searcharr[$id]['subject'];
            $smownerid= $searcharr[$id]['smownerid'];//负责人id
            $businessname = $searcharr[$id][$tabbusinessname];
        }
        $cls_GetTianYanCha = cls_GetTianYanCha::getInstance('info',$businessname);
        $cls_GetTianYanCha->setModulename($module);
        $cls_GetTianYanCha->setSearchtype('advance');
        $cls_GetTianYanCha->setOperationType('backfill');
        $cls_GetTianYanCha->setKeyWords($businessname);
        //zkt 20240119 XUQIU1002473 【中司控股】客户批量回填时，通过”经营范围“字段为判断依据，经营范围有值就仅抓取客户的“资质证书”接口信息，经营范围是空值就抓取客户的基本信息+证书信息
        $only_certificate = '';
        if($VersionInfo['account'] == 'zhongsi' && $module == 'Accounts'){
            $record_focus=CRMEntity::getInstance($module);
            $record_focus->id = $id;
            $record_focus->retrieve_entity_info($id,$module);
            if(!empty($record_focus->column_fields['scope_of_business'])){
                $tianyancharesult = $cls_GetTianYanCha->getaddcertificatedata();
                $only_certificate = 'yes';
            }
            else{
                $tianyancharesult = $cls_GetTianYanCha->getCurlResult();
                $only_certificate = 'no';
            }
        }
        else{
            $tianyancharesult = $cls_GetTianYanCha->getCurlResult();
        }

        $updatemapflag = 'no';//更新地图对应经纬度点信息标志
    	$state = 'no';
    	if(!empty($tianyancharesult)){
            $updatetabarr = array();
            $contact_fieldarr = array();
            $record_focus=CRMEntity::getInstance($module);
            $record_focus->mode = 'edit';
            $record_focus->is_check_business = 'no';    //不再次进行工商信息查询
            $record_focus->is_batchbackfill = 'yes';    //不再次进行工商信息查询
            $record_focus->id = $id;
            $record_focus->retrieve_entity_info($id,$module);
            $setcontactid = 0;
            if($module == 'Accounts' || $module == 'ServiceCharge'){
                if(!empty($contactcolumnsarr[$id])){
                    foreach ($contactcolumnsarr[$id] as $tmpfieldname=>$tmpfieldvalue){
                        $record_focus->column_fields[$tmpfieldname] = $tmpfieldvalue;
                    }
                }
                else{
                    setbackfillContactinfo($focus);//获取首要联系人信息
                    if(isset($record_focus->column_fields['contactid'])){
                        $setcontactid = $record_focus->column_fields['contactid'];
                        unset($record_focus->column_fields['contactid']);
                    }
                }
            }
            $empty_fields = '';  //不可为空字段回填空值字段内容
            $repeat_fields = '';//不可重复字段重复字段内容
          
    		foreach($backfillarr as $tmpcolumnname=>$backfillinfo)
            {
                $tianyanname = $backfillinfo['tianyanchaname'];
                $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("columnname",$tmpcolumnname);
                if(empty($fieldinfo)){
                    continue;
                }
                $fieldname = $fieldinfo->getfieldname();
                $typeofdata = $fieldinfo->typeofData;
                $fieldonly = $fieldinfo->fieldonly;
                $fieldLableKey = $fieldinfo->fieldLableKey;
                if($only_certificate == 'yes'  && strpos($tianyanname,'certificate')=== false){
                    continue;
                }
                
                //回填详细地址时需更新经纬度
                if($fieldname == 'locationaddress'){
                    $updatemapflag = 'yes';
                }
                if(in_array($tianyanname,$poiaddress_arr)){
                    $fieldvalue = $tianyancharesult['poi_address'][$tianyanname];
                }
                else{
                    $fieldvalue = $tianyancharesult[$tianyanname];
                    if($backfillinfo['type']=='picklist'&&!empty($fieldvalue))
                    {
                        //获取编辑下拉框内容
                        if(array_key_exists($fieldname,$pickbyfieldnamearr)){
                            $pickarr=$pickbyfieldnamearr[$fieldname];
                        }
                        else{
                            $pickarr = array();
                            $pickarr = $objPickList->getPickListValues($fieldname,$fieldinfo,array(),'id');
                            $pickbyfieldnamearr[$fieldname]=$pickarr;
                        }
                        $values= array_values($pickarr);
                        if(!in_array($fieldvalue,$values))
                        {
                            $objPickList->addPickValue($fieldname,$fieldvalue);
                            unset($pickbyfieldnamearr[$fieldname]);
                        }
                    }
                }
                //zkt 20240313 BUG20240313-22 PC端--工商回填/批量回填，如果工商查询结果为空，不覆盖字段原有的值
                if(empty($fieldvalue)&&$fieldvalue!='0'&&$fieldvalue!=0){
                    continue;
                }
                //验证必填字段不为空
                $typeofdataarr = explode("~",$typeofdata);
                if($typeofdataarr[1]=='M')
                {
                    if(empty($fieldvalue))
                    {
                        $empty_fields .= $fieldLableKey.',';
                    }
                }
                //首要联系人内容区块为空时，联系人姓名不能为空
                if($fieldname == 'lastname'&&$typeofdataarr[1]!='M'&&$setcontactid=0){
                    if(empty($fieldvalue))
                    {
                        $empty_fields .= $fieldLableKey.',';
                    }
                }
                //验证不可重复
                if($fieldonly == '1'&&$fieldinfo->tableName=='ld_contactdetails')
                {

                	$rest = $ldcls->getFieldDuplicateInfo($module,$fieldname,$fieldvalue,$id);
                    if(strpos($rest,'##error##')!==false){
                        $repeat_fields .= $fieldLableKey.',';
                    }
                }
                $field_tabname = $fieldinfo->tableName;
                if(in_array($field_tabname,$focus->tab_name)){
                    $record_focus->column_fields[$fieldname] = $fieldvalue;
                }
                else if($field_tabname == 'ld_contactdetails'){
                    $contact_fieldarr[$fieldname] = $fieldvalue;
                }
            }
            //首要联系人区块为空，设置了首要联系人模块字段回填未设置回填联系人姓名时，不进行回填并提示回填失败
            if(!empty($contact_fieldarr)&&!isset($contact_fieldarr['lastname'])&&$setcontactid=0)
            {
                $unsetcontactfield = $focus->fieldobj->getFieldInfoobjBykey("fieldname",'lastname')->fieldLableKey.getFixedLabel('CANOTEMPTY'); //联系人姓名不能为空
                ////单据[%s]%s失败！原因：%s! //联系人姓名不能为空
                $edit_err .=sprintf($batcherrorlog,'<a referencemodule="'.$module.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;" >'.$subject.'</a>',getFixedLabel('Backfill'),$unsetcontactfield).'<br>';
                $error++;
                continue;
            }
            //存在不可为空字段回填空值时，不进行回填并提示回填失败
            if(!empty($empty_fields))
            {
                $empty_fields = trim($empty_fields,',');
                ////单据[%s]%s失败！原因：%s! //“单据字段”不能为空
                $edit_err .=sprintf($batcherrorlog,'<a referencemodule="'.$module.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;" >'.$subject.'</a>',getFixedLabel('Backfill'),$empty_fields.getFixedLabel('CANOTEMPTY')).'<br>';
                $error++;
                continue;
            }
            //存在不可重复字段重复时，不进行回填并提示回填失败
            if(!empty($repeat_fields))
            {
                $repeat_fields = trim($repeat_fields,',');
                ////单据[%s]%s失败！原因：%s! //“单据字段”不能为空，“单据字段”不能重复
                $edit_err .=sprintf($batcherrorlog,'<a referencemodule="'.$module.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;" >'.$subject.'</a>',getFixedLabel('Backfill'),$repeat_fields.getFixedLabel('CANNOTREPEAT')).'<br>';
                $error++;
                continue;
            }
            
            //保存回填内容,不包括首要联系人区块信息
            $record_focus->save($module);
            //zkt 20231228
            if(!empty($record_focus->saveerrormsg)){
                ////单据[%s]%s失败！原因：%s!
                $edit_err .=sprintf($batcherrorlog,'<a referencemodule="'.$module.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;" >'.$subject.'</a>',getFixedLabel('Backfill'),$record_focus->saveerrormsg).'<br>';
                $error++;
                continue;
            }
            //客户修改日志
            if($record_focus->mode=='edit'){
                $record_focus->modstatic->triggerEvent($module);
            }
            //更新经纬度信息
            $point=$tianyancharesult['poi_address']['point'];
            $pointarr = explode(',',$point);
            $latitude = $pointarr[0];
            $longtitude = $pointarr[1];
            if(($module == 'Accounts' || $module == 'ServiceCharge') && $updatemapflag = 'yes'){
                //$focus->updateAccountAddress($id);
                //直接使用天眼查坐标
                $query = "select CONCAT_WS('',bill_state,bill_city,bill_street) as address,accountid from ld_account where accountid = ?";
                $addrresult = $adb->pquery($query,array($id));
                $address = $adb->query_result($addrresult,0,0);
                $adb->pquery('update ld_account set location_address =?, longtitude = ?, latitude = ? where accountid = ?',array($address,$longtitude,$latitude,$id));
            }
            //回填信息设置联系人时:联系人存在且与回填联系人相同或原联系人信息不存在，则更新联系人信息；联系人存在与回填联系人不同，新增联系人；
            if(!empty($contact_fieldarr))
            {
                $contactsql = "select contactid,lastname from ld_contactdetails where accountid = ? and lastname = ? and deleted=0 order by createdtime asc";
                $contactresult = $adb->pquery($contactsql,array($id,$contact_fieldarr['lastname']));
                $contact_num_rows = $adb->num_rows($contactresult);

                if(empty($smownerid)||$smownerid<0){
                    $smownerid = $current_user->id;
                }
                //联系人默认值
                $contact_fieldarr['assigned_user_id'] = $smownerid;
                $contact_fieldarr['account_id'] = $id;
                $lastname_arr = array();
                $contactfocus=CRMEntity::getInstance('Contacts');
                $contactfocus->id = 0;
                $contactfocus->column_fields = [];
                //联系人信息不存在
                if($contact_num_rows<=0)
                {
                    $contactfocus->mode="create";
                    foreach($contact_fieldarr as $contact_fieldname=>$value)
                    {
                        $contactfocus->column_fields[$contact_fieldname]=$value;
                    }
                    //首要联系人为空创建首要联系人
                    if($setcontactid==0){
                        $contactfocus->column_fields['reference']=1;
                    }
                    $contactfocus->save("Contacts");
                }
                //联系人信息存在
                else if($contact_num_rows>0)
                {
                    //回填信息设置了联系人电话则判断联系人信息存在同时判断联系人电话
                    $sql = "select contactid,lastname,reference from ld_contactdetails where deleted=0 and accountid = $id and lastname =? ";
                    if(isset($contact_fieldarr['mobile'])){
                        $sql .= " and (mobile = ? or mobile is null)";
                        $result = $adb->pquery($sql." order by mobile desc, createdtime asc limit 1",array($contact_fieldarr['lastname'],$contact_fieldarr['mobile']));
                    }
                    else{
                        $result = $adb->pquery($sql." order by createdtime asc limit 1",array($contact_fieldarr['lastname']));
                    }
                    $sevecontactid = 0;
                    if($adb->num_rows($result)>0){
                        $sevecontactid = $adb->query_result($result,0,'contactid');
                    }
                    if($sevecontactid>0){
                        $contactfocus->id=$sevecontactid;
                        $contactfocus->retrieve_entity_info($sevecontactid,'Contacts');
                        $contactfocus->mode="edit";
                    }
                    else{
                        $contactfocus->mode="create";
                        //首要联系人为空创建首要联系人
                        if($setcontactid=0){
                            $contactfocus->column_fields['reference']=1;
                        }
                    }
                    
                    foreach($contact_fieldarr as $contact_fieldname=>$value)
                    {
                        $contactfocus->column_fields[$contact_fieldname]=$value;
                    }
					$contactfocus->save("Contacts");
                }
                //联系人修改日志
                if($contactfocus->mode=='edit'){
                    $contactfocus->modstatic->triggerEvent("Contacts");
                }
            }
            //单据[%s]%s成功！
            $edit_err .= sprintf($batchsuccesslog,'<a referencemodule="'.$module.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;" >'.$subject.'</a>',getFixedLabel('Backfill')).'<br>';
            $success++;
    	}
        else{
            ////单据[%s]%s失败！原因：%s! //工商信息不存在
            $edit_err .=sprintf($batcherrorlog,'<a referencemodule="'.$module.'" referencerecord="'.$id.'"  onclick="DetailViewReferenceLinkClick(ld(this),event)" style="color:#32A636;" >'.$subject.'</a>',getFixedLabel('Backfill'),getFixedLabel('thecustomerbusiness')).'<br>';
            $error++;
        }
		
    }
}
$storearray = array_filter($storearray);
$submitlog = getFixedLabel('APPROVE_BATCHSUBMITLOG_INFO');//共选择 %d 条记录，成功提交 %d 条，失败 %d 条。

$submitlog = sprintf($submitlog,count($storearray),$success,$error);

$submitlog = '<div class="ld-description"><b class="info-icon"></b><div class="ld-description-content">'.$submitlog.'</div></div>';
$edit_err = "<div class='pop_prc_content'>".$edit_err."</div>";

$viewid = vtlib_purify($_REQUEST['viewname']);
if(isset($_SESSION['lvs'][$module]['viewname'])){
	$viewid = $_SESSION['lvs'][$module]['viewname'];
	$start = $_SESSION['lvs'][$module][$viewid]['start'];
}
if(!$start) $start = 1;
$_REQUEST['diony'] = 'yes';
$entity['log']['value'] = $submitlog.$edit_err;//批量处理信息
$entity['start']['value'] = $start;//当前页数
$entity['download']['value'] = getFixedLabel('CONFIRMED');// 确认
$entity['title']['value'] = getFixedLabel('BatchBackFilling');//标题
ConvertTojsonString(1,$entity,'success');

   
//获取单据对应首要联系人区块内容信息
function setbackfillContactinfo($focus)
{
    if($focus->module_name!='Accounts'&&$focus->module_name!='ServiceCharge'){
        return;
    }
    global $adb;
    $sqlcontact='select columnname,tablename,fieldname from ld_field where tabid=6 and tablename in(?,?) and presence in(0,2)';
    $resultcontact=$adb->pquery($sqlcontact,array('ld_contactdetails','ld_contactscf'));
    $contactcolumns=Array();
    $contactfieldnames=Array();
    for($i=0;$i<$adb->num_rows($resultcontact);$i++)
    {
        $contactcol=$adb->query_result($resultcontact,$i,'columnname');
        $tablename=$adb->query_result($resultcontact,$i,'tablename');
        $fieldname=$adb->query_result($resultcontact,$i,'fieldname');
        $contactfieldnames[]=$fieldname;
        $contactcolumns[]=$contactcol;
    }
    $columns=implode(',',$contactcolumns);
	 $sqlcontact="select $columns,ld_contactdetails.contactid from ld_contactdetails 
	  left join ld_contactscf on ld_contactscf.contactid=ld_contactdetails.contactid
	  where accountid=? and reference=1 and ld_contactdetails.deleted=0 order by contact_no asc limit 0,1";
    $resultcontact=$adb->pquery($sqlcontact,array($focus->id));

    if($adb->num_rows($resultcontact)>0)
    {
        for($i=0;$i<sizeof($contactfieldnames);$i++)
        {
            $focus->column_fields[$contactfieldnames[$i]]=$adb->query_result($resultcontact,0,$contactcolumns[$i]);
        }
        $focus->column_fields["contactid"]=$adb->query_result($resultcontact,0,'contactid');
    }
}


?>