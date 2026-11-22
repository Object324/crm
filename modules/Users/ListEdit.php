<?php
/**
 * edit:zkt
 * date:2022-3-9
 * reason:列表界面小编辑
 **/
global $adb,$current_user,$mod_strings,$theme;
//zkt 20231009 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$_REQUEST['diony']='diony';
$module = $_REQUEST['frommodule'];
$mode = $_REQUEST['mode'];
$fieldname = $_REQUEST['fieldname'];
$record = $_REQUEST['record'];
$tabid = getTabid($module);

$focus=CRMEntity::getInstance($module);
$focus->id = $record;
$focus->mode = 'edit';

$fieldobj=Field::getInstance($module,$adb);

//$fieldinfo = $fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
//duan 20240301 修复客户模块存在columnname相同的字段导致小编辑错误的问题
$modulefieldsobj=$fieldobj->getModuleFields();
foreach($modulefieldsobj as $tmp_fieldname=>$tmp_fieldInfo)
{
    if($tmp_fieldInfo->getFieldName() == $fieldname)
    {
        $fieldinfo = $tmp_fieldInfo;
    }
}
if(empty($fieldinfo))
{
    ConvertTojsonString(-1,array('errormsg'=>getFixedLabel('EDITFAILED')),"error");
}
$editpage = $fieldinfo->getEditpage();
$fieldlabel = $fieldinfo->getfieldLabel();
//判断editpage的值是否等于 listview ，若不为listview则不可编辑 则该字段在列表界面不可小编辑
if(strpos('listview',$editpage)===false)
{
    ConvertTojsonString(-1,array('errormsg'=>sprintf(getFixedLabel('FIELDCANNOTEDITINLISTVIEW'),$fieldlabel)),"error");//$fieldlabel.'字段在列表界面不能编辑'
}
//列表界面显示，编辑界面不显示字段
$displaytype = $fieldinfo->getDisplaytype();
if($displaytype != 1)
{
    ConvertTojsonString(-1,array('errormsg'=>sprintf(getFixedLabel('FIELDCANNOTEDITINLISTVIEW'),$fieldlabel)),"error");
}

$focus->retrieve_entity_info($record,$module);
$logic = $focus->getModuleLogic($module);
$buttons=$logic->getEditViewBtn();

$curapproveformodulefield = array();
if(!empty($record)){
	$approveobj= Approve::getInstance($module);
	$curapproveformodulefield = $approveobj->getCurApproveForModulefield($record);
}
//判断单据的编辑权限，是否可编辑。
if($buttons['permit'] != 'yes')
{
    if($logic->edit_errorreason['reason']=='approve')
    {
        $approvestatus = $logic->edit_errorreason['description'];
        $approvestatus=$approveobj->getApproveStatus($approvestatus);
        $errormsg = '';
        switch($approvestatus){					   
				    case 1://该记录正在审批中，不允许编辑！
                        //duan 2022-6-2 如果获取到的审批人为空，则重新从数据库获取一次审批人
                        if(empty($logic->approvebtn['info']['nextstepapproveby'])){
                            $sql = "select currentapprover from ".$focus->table_name." where ".$focus->table_index."= ?";
                            $result = $adb->pquery($sql,array($record));
                            if($adb->num_rows($result)>0){
                                $currentapprover = $adb->query_result($result,0,'currentapprover');
                            }
                            $approvebyid_array = explode(',',$currentapprover);
                        }else{
                            $approvebyid_array = explode(',',$logic->approvebtn['info']['nextstepapproveby']);
                        }
                        
                        $approvebyname_array = array_map('getUserFullName',$approvebyid_array);
    
                        if(count($approvebyname_array)>2){
                            $approvebyname_array = array_slice($approvebyname_array,0,2);
                            $dot_end = ' ...';
                        }
                        
                        $approveby_ing = implode(',',$approvebyname_array).$dot_end;
				        $errormsg = getFixedLabel('THERECORDPROCESSEDING').getFixedLabel('PLEASECONTACTAPPROVER').$approveby_ing;
				        break;
				    case 2://该记录已被审批通过，不允许编辑！
				        $errormsg = getFixedLabel('THERECORDAPPROVED');//.getFixedLabel('PLEASECONTACTAPPROVER').$approveby_ed;
				        break;
					case 3://该记录已被审批拒绝，不允许编辑！
					    $errormsg = getFixedLabel('THERECORDEDITING').getFixedLabel('PLEASECONTACTAPPROVER').$approveby_ed;
					    break;
					default://
						$errormsg = sprintf(getFixedLabel('FIELDCANNOTEDIT'),$fieldlabel);//$fieldlabel.'字段不能编辑'
				}
                ConvertTojsonString(-1,array('errormsg'=>$errormsg),"error");
                
    }
    ConvertTojsonString(-1,array('errormsg'=>sprintf(getFixedLabel('FIELDCANNOTEDIT'),$fieldlabel).'原因:'.$logic->edit_errorreason[description].'!'),"error");
}


//zkt 20230417 BUG0064928 kfbcrm 付款计划----当状态为：已付----单据不允许编辑----但在序时簿列表编辑字段，可以正常保存 例：CP50 
//模块是否可编辑特殊判断
$errormsg = JudgetEditStatusSpecial($focus);
if(!empty($errormsg)){
    ConvertTojsonString(-1,array('errormsg'=>$errormsg),"error");
}


//判断是否可编辑
//非管理员  控制只读字段不在模块的新增和编辑时显示
if(!is_admin($current_user)){
	$profileobj=Profile::getInstance();
	$profilefields= $profileobj->getProfileInfos($current_user->profileid);
	$profilefields=$profilefields['field'];
}

$customviewobj=CustomView::getInstance($module);
//链接模块
$advfilter_arr = array();
if(isset($_REQUEST['linkmodule_viewname'])&&!empty($_REQUEST['linkmodule_viewname'])){
    $linkmodule_cvid = $_REQUEST['linkmodule_viewname'];
    $advfilter_arr=$customviewobj->getAdvFilterByCvid($linkmodule_cvid);
}


$uitype=$fieldinfo->getUIType();
$fieldonly=$fieldinfo->getfieldOnly();
$fieldid = $fieldinfo->getFieldid();
$fieldvaluecolor = $fieldinfo->getFieldValueColor();//文字颜色
$fieldplaceholder = $fieldinfo->getFieldPlaceholder();
$allowedit = $fieldinfo->allowedit;//是否允许编辑
 
$columnname=$fieldinfo->getColumnName();
$maxlength = $fieldinfo->getMaximumLength();
$generatedtype = $fieldinfo->getGeneratedtype();
$typeofdata = $fieldinfo->getTypeOfData();
$defaultvalue =$fieldinfo->getDefaultValue();
$bigtype=$fieldinfo->getBigType();
$focusmode = 'edit';




//编辑时只读的字段在编辑时，返回不可编辑，
 if( !empty($profilefields) && $profilefields[$fieldid]['editreadonly']==1 && (isset($_REQUEST['record'])&&!isset($_REQUEST['Create']))){
	ConvertTojsonString(-1,array('errormsg'=>$fieldlabel.'字段权限设置字段权限为"编辑时只读",不能编辑,请联系管理员'),"error");
 }
 //只读权限的字段在小编辑时，返回不可编辑
 if( !empty($profilefields) && $profilefields[$fieldid]['readonly']==1){
	ConvertTojsonString(-1,array('errormsg'=>$fieldlabel.'字段权限设置请联系管理员为"只读",不能编辑,请联系管理员'),"error");
 }
 

 
 
//判断单据的审批状态，是否可编辑。（单据审批且不在审批后可编辑字段中）
$startapprovemodule = $approveobj->startBlocksApprove();
if(isset($startapprovemodule[$module])){//审批模块开启
    $approvestatus = $focus->column_fields[$focus->getApproveStatusColumnName()];
    $approvestatus = $approveobj->getApproveStatus($approvestatus);
    if($approvestatus == 2)
    {
        crm_load_class_file('ApproveFinished','modules/Approve');
        $approvefinishedobj=ApproveFinished::getInstance($module,$record);
        
        $alloweditfield_arr= $approvefinishedobj->getAllowEditField();//审批通过可以编辑的字段
        $tablename=$fieldinfo->getTableName();
        $columnname=$fieldinfo->getColumnName();
        
        if(!array_key_exists("$tablename:$columnname:$module",$alloweditfield_arr))
        {
        	ConvertTojsonString(-1,array('errormsg'=>getFixedLabel('THERECORDAPPROVED')),"error");
        	
        }
    }
}



$smarty=new lingdangCRM_Smarty;

$col_fields=$focus->column_fields;
crm_load_class_file('cls_EditView_OutPut','include/utils');
$obj_cls = new cls_EditView_OutPut();
if(isset($advfilter_arr)&&!empty($advfilter_arr)){
    $obj_cls->setAdvFilter($advfilter_arr);
}
//获取字段小编辑框内容
$custfld = $obj_cls->getEditViewOutputHtml($fieldinfo, $maxlength, $col_fields,$generatedtype,$module,$focusmode,$typeofdata,$fieldonly,$curapproveformodulefield);


if($custfld['allowedit'] == 'no')
{
    ConvertTojsonString(-1,array('errormsg'=>sprintf(getFixedLabel('FIELDCANNOTEDIT'),$fieldlabel)),"error");
}
if($fieldname == 'user_name' && $module == 'Users')
{
    ConvertTojsonString(-1,array('errormsg'=>sprintf(getFixedLabel('FIELDCANNOTEDIT'),$fieldlabel)),"error");
}


$sql='select * from ld_fieldrule where tabid=? and enablestatus = "yes"  ';
$result=$adb->pquery($sql,array($tabid));
$rows=$adb->num_rows($result);
if($rows>0)
{
    $showfieldvalue = new ShowFieldValue($fieldobj,$module,constant('SHOW_EDITVIEW'));
    $columnvalues = array();
    foreach($col_fields as $tmpfieldname=>$tmpvalue)
    {
        $tmpfieldinfo = $fieldobj->getFieldInfoobjBykey("fieldname",$tmpfieldname);
        if(empty($tmpfieldinfo))
        {
            continue;
        }
        $tmpcolumnname = $tmpfieldinfo->getColumnName();
        if($tmpfieldinfo->getBigType()=='reference'||$tmpfieldinfo->getBigType()=='picklist'||($tmpfieldinfo->getColumnName()=='sales_stage'&&$module=='Potentails'))
        {
            
            $columnvalues[$tmpcolumnname]=$col_fields[$tmpfieldname];
            if($tmpfieldinfo->getBigType()=='reference')
            {
                $columnvalues[$tmpcolumnname]=$col_fields[$tmpfieldname."_name"];
            }
            
        }
        else{
            $showvalue=$showfieldvalue->getFieldValueByField($tmpfieldinfo,$tmpvalue,$tmpvalue);
            if(!empty($tmpcolumnname))
            {
                $columnvalues[$tmpcolumnname] = $showvalue['value'];
            }
        }
    }
    
    crm_load_class_file('cls_fieldrule','include/fields/fieldrule');
    //主表字段布局规则
    $fieldruleobj=cls_fieldrule::getInstance($module);
    $fieldruleobj->setColumnValues($columnvalues);
	$fieldrulecolsproperty= $fieldruleobj->getFieldRuleProperty($columnname);
    
    //布局规则重新设置界面显示
   $hidecolumns=$fieldrulecolsproperty['hidecolumns'];//隐藏的字段
   $requiredcolumns=$fieldrulecolsproperty['requiredcolumns'];//必填字段
    
    if(in_array($columnname,$hidecolumns))
    {
        ConvertTojsonString(-1,array('errormsg'=>'设置了布局规则，'.$fieldlabel.'字段不能编辑,请联系管理员'),"error");
    }
    if(in_array($columnname,$requiredcolumns))
    {
        $custfld[4] = 'M';
    }
}




global $global_pick_list_values,$global_picklist_colors_byvalue;
global $global_pick_list_depencyfield;
crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
$DependentPicklistFields = lingdang_DependencyPicklist::getDependentPicklistFields($module);
$picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($module);
$arr['global_picklist_colors_values']=$global_picklist_colors_byvalue;
$arr['detailpicklist']=[];
$arr['detailpicklistseq']=[];
if($module == 'Users'){
    $arr['cur_groupinfo']=getUserGroupinfo($focus);//当前用户的部门信息
}

//zkt 20240110 BUG0077956 客户模块里面，在序时簿列表里选择省份，下拉框不出现，左上角弹出白边。
if($fieldname=='bill_state'||$fieldname=='bill_city'||$fieldname=='bill_area')
{
    //先这样吧，应该是判断下拉框字段是否有级联
    if($fieldname=='bill_state')
    {
        $tmpfieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname","bill_country");
        $sql='select * from ld_picklist_dependency where tabid=? and sourcefield=? and targetfield=?';
        $tmpresult=$adb->pquery($sql,array(getTabid($module),'bill_country','bill_state'));
        if($adb->num_rows($tmpresult)<=0)
            unset($tmpfieldinfo);
    }
    else if($fieldname=='bill_city')
    {
        $tmpfieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname","bill_state");
    }
    else{
        $tmpfieldinfo=$focus->fieldobj->getFieldInfoobjBykey("fieldname","bill_city");
    }
    if($tmpfieldinfo&&!empty($tmpfieldinfo->getFieldName()))
        $optionvalue=[];
    else
        $optionvalue = getEditViewPagePickList($fieldname, $custfld[6], $uitype, $fieldinfo);
    $global_pick_list_values[] = array('fieldname' => $fieldname, 'optionvalue' => $optionvalue);
}
$arr['picklistcontent']=$global_pick_list_values;



if($uitype == 15 ||$bigtype == 'picklist')
{
    //是否为级联字段,必须有判断，存在下级字段下拉框内容为空的情况
    $sql = "select * from ld_picklist_dependency where tabid = ? and ( sourcefield = ? or targetfield = ?)";
    $result = $adb->pquery($sql,array($tabid,$fieldname,$fieldname));
    $rows = $adb->num_rows($result);
    if($rows>0)
    {
        $haveuperfield = false;
        $tmppicklistarr = array();
        for($i=0; $i<$rows; $i++)
        {
            $tmpsourcefield = $adb->query_result($result,$i,'sourcefield');
            $tmpsourcevalue = $adb->query_result($result,$i,'sourcevalue');
            $tmptargetfield = $adb->query_result($result,$i,'targetfield');
            $tmptargetvalue = $adb->query_result($result,$i,'targetvalues');
            if($tmptargetfield == $fieldname)
            {
                //有上级字段
                $haveuperfield = true;
                if(empty($col_fields[$tmpsourcefield]))
                {
                    //上级字段为空
                    $tmpfieldlabel = $focus->fieldobj->getFieldInfoBykeyValue('fieldname',$tmpsourcefield,'fieldlabel');
                    if(trim($tmpfieldlabel)=='')
                    {
                        continue;
                    }
                    //zkt 20220607 50878: （81mis.com/kfbcrm）（列表编辑）客户》客户列表，编辑客户 重要级别，下拉框选项点不出来
                    ConvertTojsonString(-1,array('errormsg'=>$fieldlabel.'字段的上级字段'.$tmpfieldlabel.'为空'),"error");
                }
                if($tmpsourcevalue == $col_fields[$tmpsourcefield])
                {
                    $tmppicklistarr = json_decode($tmptargetvalue);//获取下拉框内容
                    
                }
            }
            if($tmpsourcefield == $fieldname)
            {
                //有下级级字段
                //ConvertTojsonString(-1,array('errormsg'=>$fieldlabel.'字段存在下级字段，暂不支持单独编辑'),"error");
            }
        }
        //修改为下拉框传值至前端结构
        if($haveuperfield)
        {
            $pickcolors = $global_picklist_colors_byvalue;
            if (!empty($tmppicklistarr))
            {
                $optionvalue[] = array('','','','');
                foreach ($tmppicklistarr as $tmpindex => $pickListValue) {
                    if (htmlspecialchars(trim($col_fields[$fieldname])) == htmlspecialchars(trim($pickListValue))) {
                        $chk_val = 'selected';
                    } else {
                        $chk_val = '';
                    }
                    $optionvalue[] = array($pickListValue, $pickListValue, $chk_val,$pickcolors[$pickListValue]);
                }
            }
            $arr['picklistcontent']=array(array('fieldname'=>$fieldname,'optionvalue'=>$optionvalue));
            foreach($global_pick_list_values as $picklistarr)
            {
                if($picklistarr['fieldname'] == $fieldname)
                {
                    $tmpoptionvalue = $picklistarr['optionvalue'];
                    foreach($picklistarr['optionvalue'] as $tmpindex => $tmpoptions)
                    {
                        if($tmpindex == 0 && empty($tmpoptions[0]))
                        {
                            continue;
                        }
                        if(!in_array($tmpoptions[0],$tmppicklistarr))
                        {
                            unset($tmpoptionvalue[$tmpindex]);
                        }
                    }
                    break;
                }
            }
            
            
        }
    }
}
if($uitype=4)
{
    $isallow= $focus->Library('SystemCode')->getModentityfield('isallow',$module);
    $smarty->assign('ISALLOW',$isallow);
}

// -------------------------- 编辑判断结束


$smarty->assign("CURRENT_USERID", $current_user->id);
$smarty->assign('ISADMIN',$current_user->is_admin);
$smarty->assign('ID', $focus->id);
$smarty->assign('MODE','edit');
$smarty->assign('MODULE',$module);
$version_info = getVersionInfo();
$smarty->assign('VERSIONTRADE',$version_info['trade']);
$smarty->assign('VERSIONACCOUNT',$version_info['account']);
$smarty->assign('VERSION_ACCOUNT',$version_info['account']);
$smarty->assign("THEME", $theme);
//币种
$smarty->assign('CURRENCYID',$focus->column_fields['currency_id']);
$smarty->assign('CONVERSIONRATE', $focus->column_fields['conversion_rate']);
//客户名称
if($fieldinfo->getUIType() == 73)
{
    if($module == 'OutboundOrder')
    {
        $smarty->assign("ACCOUNTID",$focus->column_fields['account_id']);
        $smarty->assign("ACCOUNTNAME",getModuleHref('Accounts',$focus->column_fields['account_id']));
        $smarty->assign('CONTACTID', $focus->column_fields['contact_id']);
    }
}



//附件编辑
//wym BUG0074511 当关联创建模块包含附件或图片类型的引用字段时，focus对象上有fieldjsondata（此时foucs->id无值）
$fieldjsondata = empty($focus->fieldjsondata)?array():$focus->fieldjsondata;
if($fieldinfo->getBigType() == "fileattachment")
{
    if($focus->id>0)
    {
        if($focus->id>0){
            $tmp_record = $focus->id;
        }else if($_REQUEST['record']>0){ //edit:duan date:2021-9-30 复制的时候带出附件信息
            $tmp_record = $_REQUEST['record'];
        }
        $fieldjsondata=getAllFile_imageInfo($tmp_record,$module);
    }
    //编辑附件未完成--直接返回
    //ConvertTojsonString(-1,array('errormsg'=>$fieldlabel.'字段不能编辑（编辑功能尚未完成）'),"error");
}
$arr['filejsondata']=$fieldjsondata;


//模块对应的$smarty传值
setSmartyassignBymodule($smarty,$module,$fieldname);
//zxm 20230403  kfbcrm 客户--序时簿列表 客户来源字段，点编辑不显示颜色---需要手动重新选择一下才显示  
$tmppicklist_value = $custfld[6];
$tmppicklist_color = $global_picklist_colors_byvalue[$fieldname][$tmppicklist_value];
crm_load_class_file("cls_fieldSensitiverule", "include/fields");
$cls_fieldSensitiveruleobj = cls_fieldSensitiverule::getInstance($module);
$cls_fieldSensitiveruleobj->setColumnValuesbyfieldnamearr($col_fields);
$cls_fieldSensitiveruleobj->setRecord($focus->id);
if (isset($_REQUEST['editmode']) && $_REQUEST['editmode'] == 'listview'){
    $cls_fieldSensitiveruleobj->setApplicationScene('ModuleListView');
}
$sensitiveresultinfo = $cls_fieldSensitiveruleobj->getSensitiveResultInfobyColumnname();
$sensitiveRealtedfield = $cls_fieldSensitiveruleobj->getAllRealtedfieldbyfieldname();
if(!empty($sensitiveresultinfo)){
    if($fieldinfo->gethavesensitivevalue() == 'yes'){
        $cls_fieldSensitiveruleobj = cls_fieldSensitiverule::getInstance($module);
        //BUG20240807-44  设置联系人“不可编辑”字段的敏感规则为仅在“单据详情”中“不可编辑”，实际在单据列表中点击“不可编辑”字段后的“编辑”浮显按钮也不能编辑该字段
        $tmp_ruleinfo = $cls_fieldSensitiveruleobj->getColumnameHaveSensitiveFuleinfo($fieldname);
        if ($tmp_ruleinfo['ruletype'] == 'noneditable'){
            ConvertTojsonString(-1,array('errormsg'=>sprintf(getFixedLabel('FIELDCANNOTEDIT'),$fieldlabel)),"error");
        }
        $tmpcolumn_value = $custfld[3][0];
        $tmpcolumn_value_arr = $cls_fieldSensitiveruleobj->getfieldsecretvaluearr($fieldinfo,$tmpcolumn_value);
        if(!empty($tmpcolumn_value_arr)){
            $custfld[3][0] = $tmpcolumn_value_arr['secretvalue'];
            if($fieldinfo->get_allowedit() == 'no'){
                $custfld['allowedit'] = $fieldinfo->get_allowedit();
            }
        }
    }
}
$arr['sensitiverelatedfield'] = array($fieldname=>$sensitiveRealtedfield[$fieldname]);
$arr['tmppicklist_color'] = $tmppicklist_color;
//获取td
$smarty->assign('maindata',$custfld);
$str = $smarty->fetch("DetailView/EditViewUI.tpl");


$table = '<table name="listedittab" class="DetailContentTable linefeed" width="100%" cellspacing="0" cellpadding="0" border="0" ><tr>';
$table .= $str;
$table .= '</tr></table>';

//获取字段fiedinfo信息返回至前端；
$returnfieldinfo = $fieldobj->FieldInfoListByKeyValue('fieldname',$fieldname);
$tmptypeofdate = $returnfieldinfo['typeofdata'];
$tmptypeofdatearr = explode('~',$tmptypeofdate);
$tmptypeofdatearr[1] = $custfld[4];//获取字段是否必填属性值
$returnfieldinfo['typeofdata'] = implode('~',$tmptypeofdatearr);
$returnfieldinfo['havesensitivevalue'] = $fieldinfo->gethavesensitivevalue();
$returnfieldinfo['sensitiveencryptvalue'] = $fieldinfo->getsensitiveencryptvalue();
$returnfieldinfo['isenablebusinessfuzzyquery'] = $fieldinfo->getenablebusinessfuzzyquery();

$fields = array($returnfieldinfo);


$arr['isadmin']=$current_user->is_admin;
$arr['fields'] = $fields;
$arr['content'] = $table;
$arr['title'] = getFixedLabel('EDIT').'-'.$fieldlabel;
$arr['oktext'] = getFixedLabel('SAVE');
$arr['canceltext'] = getFixedLabel('CANCEL');
ConvertTojsonString(1,$arr,"success");

function setSmartyassignBymodule($smarty,$module,$fieldname)
{
    global $adb;
    $version_info = getVersionInfo();
    
    $focus = CRMEntity::getInstance($module);
    $fieldobj = $focus->fieldobj->getFieldInfoobjBykey('fieldname',$fieldname);
    
    if($module == 'Users')
    {
        $authtype =  $focus->getAuthType();
        $smarty->assign('AUTHTYPE',$authtype);
        if($fieldname == 'userlevel')
        {
            //职位级别
            $level_show_user="";
            if(isset($_REQUEST['record']))
            {   
                $sql = "select userlevel from ld_users where id=".$_REQUEST['record']."";
                $result = $adb->pquery($sql,array());
                $level_show_user = $adb->query_result($result,0);
                $smarty->assign("level_show_user",$level_show_user);
            }
            if(is_admin($current_user)||isPermitted("Users", 'index','') == 'yes' ){
                $smarty->assign("IS_ADMIN", true);
            }
        }
        else if($fieldobj->getUIType() == 15 && $fieldname == 'approvestatus')
        {
            //审批委托
            $approvestatus_show_user="";
            if(isset($_REQUEST['record']))
            {
                $sql = "select approvestatus from ld_users where id=".$_REQUEST['record']."";
                $result = $adb->pquery($sql,array());
                $approvestatus_show_user = $adb->query_result($result,0);
                $smarty->assign("approvestatus_show_user",$approvestatus_show_user);
            }
        }
        else if($fieldobj -> getUIType()== 11 && $fieldname == 'approveby')
        {
            //审批委托人
            $last_name="";
            $approvestatus_show_user="";
            if(isset($_REQUEST['record']))
            {
                $sql = "select last_name,id from ld_users where id in (select approveby from ld_users where id=".$_REQUEST['record']." )";
                $result = $adb->pquery($sql,array());
                $num_rows = $adb->num_rows($result);
                $last_name=array();
                for($i=0;$i<$num_rows;$i++)
                {
                $last_name[]=array(
                        'last_name'=> $adb->query_result($result,$i,"last_name"),
                        'id'=>$adb->query_result($result,$i,"id")
                        );
                }
                $smarty->assign("last_name",$last_name);
                $sql = "select approvestatus from ld_users where id=".$_REQUEST['record']."";
                $result = $adb->pquery($sql,array());
                $approvestatus_show_user = $adb->query_result($result,0);
                $smarty->assign("approvestatus_show_user",$approvestatus_show_user);
            }
        }
        else if($fieldobj->getUIType()==56||$fieldobj->getUIType()==98)
        {
            $smarty->assign('USEREDIT','useredit');
            $smarty->assign("ALLSETROLEDATAPROFILE",isPermitted("Users","AllowSetRoleDataProfile"));
        }
        
        
    }
    else if($module == 'Accounts')//CALLPHONE？，
    {
        if($fieldname == 'accountname')
        {
            // //工商查询
            // crm_load_class_file('cls_BusinessInformation', 'modules/Users');
            // $businessinformationobj = cls_BusinessInformation::getInstance($currentModule);
            // $smarty->assign('ACCOUNTBUSINESS',1);
            // if($businessinformationobj->IsEnableBusiness()){
            //     $smarty->assign('ACCOUNTBUSINESS',0);
            // }
            // //工商查询列表
            // $smarty->assign('ACCOUNTLISTBUS',1);
            // if($businessinformationobj->IsEnableBusinessfuzzyquery()){
            //     $smarty->assign('ACCOUNTLISTBUS',0);
            // }
        }
        
        
    }
    else if($module == 'BankAccountSet')
    {
        if($fieldobj->getUIType()==72||$fieldobj->getUIType()==117 )
        {
            if($_REQUEST['record']){
                $sqlstus="select confirmed from ld_bankaccountset where bankaccountsetid=".$_REQUEST['record']; 
                $reslutsturs = $adb->pquery($sqlstus);
                $confirmedst = $adb->query_result($reslutsturs,0,'confirmed');
            }
            $smarty->assign("CONFIRMEDST", $confirmedst);
        }
    }
    else if($module == 'Contacts')
    {
        if($fieldobj->getUIType()==57)
        {
            //未发现传值位置
            
        }
    }
    else if($module == 'Products')
    {
        if($fieldobj->getUIType()== 72||$fieldobj->getUIType()==71)
        {
            if($fieldname == 'unit_price' || $fieldname == 'procostprice')
            {
                $record = $_REQUEST['record'];
                $focus->id = $record;
                $focus->mode = 'edit';
                $focus->retrieve_entity_info($record, $module);
                crm_load_function_file('getInventoryCurrencyInfo','include/utils','InventoryUtils');
            	$currencyInfo = getInventoryCurrencyInfo($module,$focus->id);
            	$product_base_currency = $currencyInfo['currency_id'];
                $productid = $focus->id;
                
                if($fieldname == 'unit_price')
                {
                    //参考价 - 价格设定
                    $unit_price = $focus->column_fields['unit_price'];
                    $price_details = getPriceDetailsForProduct($productid, $unit_price, 'available',$module,'unit_price');
                    $smarty->assign("PRICE_DETAILS", $price_details);
                    $smarty->assign("PRICE_DETAILS_NUM", sizeOf($price_details));
                    $base_currency = 'unit_price_curname' . $product_base_currency;
                    $smarty->assign("BASE_CURRENCY", $base_currency);
                }
                if($fieldname == 'procostprice')
                {
                    //参考成本价 - 价格设定
                    $procostprice = $focus->column_fields['procostprice'];
                    $price_details = getPriceDetailsForProduct($productid, $procostprice, 'available',$module,'procostprice');
                    $smarty->assign("PROCOSTPRICE_DETAILS", $price_details);
                    $smarty->assign("PROCOSTPRICE_DETAILS_NUM", sizeOf($price_details));
                    $base_currency = 'procostprice_curname' . $product_base_currency;
                    $smarty->assign("PROCOSTBASE_CURRENCY", $base_currency);
                }
                $sysdeploy_93 = getSys_deploy(93);	// 系统参数控制单价小数位
                $smarty->assign('price_decimal',$sysdeploy_93['deploy_value']);
                
            }
            
        }
    }
    else if($module == 'PurchaseCashBack')
    {
        if($fieldobj->getUIType()==801)
        {
            if (isset ($_REQUEST['record']) && $_REQUEST['record'] != '') {
                $sql = "select a.purchasebackid,a.purchaseback_no,b.vendorname,b.vendorid from ld_purchaseback a,ld_vendor b,ld_purchasecashback c 
                where a.vendorid = b.vendorid and c.purchaseback_id = a.purchasebackid and c.purchasecashbackid = ?";
                $result=$adb->pquery($sql,array($_REQUEST['record']));
                $smarty->assign("PURCHASEBACKID", $adb->query_result($result,0,"purchasebackid"));
                $smarty->assign("PURCHASEBACKNO", $adb->query_result($result,0,"purchaseback_no"));
            }
        }
        else if($fieldobj->getUIType()==75||$fieldobj->getUIType()==81)
        {
            if (isset ($_REQUEST['record']) && $_REQUEST['record'] != '') {
                $focus->id = $_REQUEST['record'];
                $purchasebackid = $_REQUEST['record'];
                $sql = "select purchaseorder_id from ld_purchaseback where purchasebackid = ?";
                $result=$adb->pquery($sql,array($purchasebackid));
                $purchaseorder_id = $adb->query_result($result,0,"purchaseorder_id");
            	$entityarray = getEntitynameInfo(getTabid('PurchaseOrder'));
            	$tabname = $entityarray['tablename'];
            	$tabindex = $entityarray['entityidfield'];
            	$tabfieldname = $entityarray['fieldname'];
            	$sql = "
            		select $tabfieldname as subject,ld_vendor.vendorname,ld_vendor.vendorid from ld_purchaseorder 
            		LEFT JOIN ld_vendor on ld_vendor.vendorid = ld_purchaseorder.vendorid 
            		LEFT JOIN ld_purchaseordercf on ld_purchaseordercf.purchaseorderid = ld_purchaseorder.purchaseorderid
            		where ld_purchaseorder.purchaseorderid = $purchaseorder_id";
                $result=$adb->pquery($sql);
                $smarty->assign("PURCHASEORDERID", $purchaseorder_id);
                $smarty->assign("VENDORNAME", $adb->query_result($result,0,"vendorname"));
                $smarty->assign("VENDORID", $adb->query_result($result,0,"vendorid"));
            }
        }
        
    }
    else if($module == 'PurchaseCashBack')
    {
        if($fieldobj->getUIType()==75||$fieldobj->getUIType()==81)
        {
            $focus->id = $_REQUEST['record'];
            $sql = "select a.purchasebackid,a.purchaseback_no,b.vendorname,b.vendorid from ld_purchaseback a,ld_vendor b,ld_purchasecashback c 
            where a.vendorid = b.vendorid and c.purchaseback_id = a.purchasebackid and c.purchasecashbackid = $focus->id";
            $result=$adb->pquery($sql);
            $smarty->assign("PURCHASEBACKID", $adb->query_result($result,0,"purchasebackid"));
            $smarty->assign("PURCHASEBACKNO", $adb->query_result($result,0,"purchaseback_no"));
            $smarty->assign("VENDORNAME", $adb->query_result($result,0,"vendorname"));
            $smarty->assign("VENDORID", $adb->query_result($result,0,"vendorid"));
        }
        
    }
    else if($module == 'Rate')
    {
        if($fieldobj->getUIType()==111)//小编辑不需要留作后续使用
        {
            $selectinfo = $focus->getRateSelect();
            $smarty->assign('SELECTTYPE',$selectinfo['selecttype']);
            $smarty->assign('SELECTVALUE',$selectinfo['selectvalue']);
        }
    }
    else if($module == 'ServiceCharge')
    {
        if($fieldname == 'accountname')
        {
            // //工商查询
            // crm_load_class_file('cls_BusinessInformation', 'modules/Users');
            // $businessinformationobj = cls_BusinessInformation::getInstance($currentModule);
            // $smarty->assign('ACCOUNTBUSINESS',1);
            // if($businessinformationobj->IsEnableBusiness()){
            //     $smarty->assign('ACCOUNTBUSINESS',0);
            // }
            // //工商查询列表
            // $smarty->assign('ACCOUNTLISTBUS',1);
            // if($businessinformationobj->IsEnableBusinessfuzzyquery()){
            //     $smarty->assign('ACCOUNTLISTBUS',0);
            // }
        }
    }
    else if($module == 'Vendors')
    {
        if($fieldname == 'vendorname')
        {
            // //工商查询
            // crm_load_class_file('cls_BusinessInformation', 'modules/Users');
            // $businessinformationobj = cls_BusinessInformation::getInstance($currentModule);
            // $smarty->assign('VENDORBUSINESS',1);
            // if($businessinformationobj->IsEnableBusiness()){
            //     $smarty->assign('VENDORBUSINESS',0);
            // }
            // //工商查询列表
            // $smarty->assign('VENDORLISTBUS',1);
            // if($businessinformationobj->IsEnableBusinessfuzzyquery()){
            //     $smarty->assign('VENDORLISTBUS',0);
            // }
        }
    }

}

function JudgetEditStatusSpecial($focus){
    global $adb;
    $record = $focus->id;
    $module = $focus->moduleName;
    $strStatus = '';
    if($module == 'SendPayment')
    {
        $sql="select cpstatus from ld_sendpayment where sendpaymentid=$record";
        $result=$adb->pquery($sql,array());
        $cppaymentstatus=$adb->query_result($result,0,0);
        if($cppaymentstatus=="已付")
        {
             $strStatus = getFixedLabel('thecurrentdocumenthasbeenpaid');	//"当前单据已付款，不允许编辑！";
        }
        if($cppaymentstatus=="部分已付")
        {
            $strStatus=	getFixedLabel('thecurrenrpartofthebillhasbeenpaid');//"当前单据部分已付款，不允许编辑";
        }
    }
    
    return $strStatus;
    
    
}

?>