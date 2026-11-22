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
$editmode = $_REQUEST['editmode'];
$detailid = $_REQUEST['detailid'];
$tabid = getTabid($module);


$focus=CRMEntity::getInstance($module);
$focus->id = $record;
$focus->mode = 'edit';

$fieldobj=Field::getInstance($module,$adb);

if($editmode == 'detail'){
    $detailfieldobj=$focus->detailfieldobj;
    $fieldinfo = $detailfieldobj->getFieldInfoobjBykey("columnname",$fieldname);
}else{

    $fieldinfo = $fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
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
if($editmode != 'detail'){
    $displaytype = $fieldinfo->getDisplaytype();
    if($displaytype != 1)
    {
        ConvertTojsonString(-1,array('errormsg'=>sprintf(getFixedLabel('FIELDCANNOTEDITINLISTVIEW'),$fieldlabel)),"error");
    }
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

//分录字段编辑权限判断
$detailtype = '';

$isProductDetail='yes';
$cashbill_moudle = 'no';
if($module == 'CashBill' || $module == 'SendCashBill'){
    //选择源单
    $cashbill_moudle = 'yes';
    $isProductDetail = 'no';
    $sourcemodules=getSourceModule($module);
    //获取收款单选择源单类型
    $selectlistval = $focus->column_fields['selectlistval'];
    $selectlistval_arr=explode(",",$selectlistval);
    if(!empty($selectlistval_arr)){
        $selectsourceModule = getSalesEntityType($selectlistval_arr[0]);//获取对应模块
    }
    foreach($sourcemodules as $tmp=>$sourcemoduleinfo)
    {
        if($selectsourceModule==$sourcemoduleinfo['entitytype']&&$sourcemoduleinfo['withdetail']=='yes')
        {
            $isProductDetail='yes';
            break;
        }
    }
}

if($cashbill_moudle == 'yes'){
    if($isProductDetail == 'yes'){
        $detailtype = 'product';
        $DetailsHtmlobj = crm_load_class_obj('cls_productDetailsHtml', "modules/$module/ProductDetail", array($module,$selectsourceModule));
        $DetailsHtmlobj->productdetail_mode = 'edit';
        $DetailsHtmlobj->getPageType();
        $arr['detailfieldmodule'] = 'product';
    }else{
        $detailtype = 'normal';
        if($module == 'CashBill'){
            crm_load_class_file('CashBillDetailFieldsHtml','modules/CashBill');
            $DetailsHtmlobj = new CashBillDetailFieldsHtml($focus,$module,$selectsourceModule);
        }else{
            crm_load_class_file('SendCashBillDetailFieldsHtml','modules/SendCashBill');
            $DetailsHtmlobj = new SendCashBillDetailFieldsHtml($focus,$module,$selectsourceModule);
        }
        $DetailsHtmlobj->getPageType();
        $arr['detailfieldmodule'] = $module.'detail';
    }

}elseif(get_file_address($module,"ProductDetails")) { //产品分录
    $detailtype = 'product';
    $DetailsHtmlobj = crm_load_class_obj('cls_productDetailsHtml', "modules/$module/ProductDetails", array($module));
    $DetailsHtmlobj->productdetail_mode = 'edit';
    $DetailsHtmlobj->getPageType();
    $arr['detailfieldmodule'] = 'product';
}elseif(get_file_address($module,$module."DetailFieldsHtml")){ //普通分录
    $detailtype = 'normal';
    crm_load_class_file('cls_TabDetailFieldsHtml','include/TabDetailFields');
    $DetailsHtmlobj = new cls_TabDetailFieldsHtml($focus,$module);
    $DetailsHtmlobj->getPageType();
    $arr['detailfieldmodule'] = $module.'detail';
}else{
    ConvertTojsonString(-1,array('errormsg'=>getFixedLabel('EDITFAILED')),"error");
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
//字段标签名
$typeofdata_arr = explode('~',$typeofdata);

if(count($typeofdata_arr) > 1 && $typeofdata_arr[1] == 'M'){
    $mandotory_str = '<font color="red">*</font>';
}else{
    $mandotory_str = '';
}
$str = '<td class="ld-form-item-label">'.$mandotory_str.$fieldlabel.'</td>';
//调用原有方法生成html
$returndata = $DetailsHtmlobj->getMiniEditTdhtml($focus,$columnname,$detailid);

//根据返回值判断是否允许编辑
if($returndata['code'] == 1){
    $str .= $returndata['content'];
}else{
    $msg = $returndata['msg'];
    $errormsg = getFixedLabel('EDITFAILED');
    $refresh = 'no';
    switch ($msg){
        case 'wrongdetailid':$errormsg = getFixedLabel('DOCUMENTCHANGEDLISTREFRESHED');$refresh='yes';break; //其他页面单据保存后，detailid 未更新
        case 'emptyfield':$errormsg = sprintf(getFixedLabel('FIELDCANNOTEDIT'),$fieldlabel);break; //字段关闭或字段名错误
        case 'noedit':$errormsg = sprintf(getFixedLabel('FIELDCANNOTEDIT'),$fieldlabel);break; //字段不允许编辑或没有权限编辑
        default:break;
    }
    ConvertTojsonString(-1,array('errormsg'=>$errormsg,'refresh'=>$refresh,'refreshlistmodules'=>[$module]),"error");
}


$table = '<table name="listedittab" class="DetailContentTable linefeed" width="100%" cellspacing="0" cellpadding="0" border="0" ><tr>';
$table .= $str;
$table .= '</tr></table>';

//获取字段fiedinfo信息返回至前端；
$all_field_arr = $detailfieldobj->getFieldListArray();
foreach ($all_field_arr as $tmp_arr){
    if($tmp_arr['columnname'] == $columnname){
        $returnfieldinfo = $tmp_arr;
    }
}

$fields = array($returnfieldinfo);

if($bigtype == 'picklist'){
    crm_load_class_file("cls_PickList", 'modules/PickList');
    $objPickList = cls_PickList::getInstance($columnname, $focus->detailfieldobj);
    $picklistvalue = $objPickList->getPickListValues($columnname, $fieldinfo, '', '');

    $picklist_array[''] = '';
    if (!empty($picklistvalue)) {
        foreach ($picklistvalue as $key => $val) {
            $picklist_array[$key] = $val;
        }
    }
    //43190: （https://61mis.com/kfbtest/ [^]）客户问题（徐燕男），合同订单产品分录“下拉框”字段，设置的下拉选项与下拉框中显示的数据不一样（需要补丁）
    //数组合并array_merge，当数组中的键值为数字时，合并后的数字数字键值会重算从0开始
    //$picklist[$tmpcolumnname] = array_merge(array(''=>''),$objPickList->getPickListValues($tmpcolumnname,$detailfieldinfo,'',''));
    $picklist[$columnname] = $picklist_array;
    $picklistseq[$columnname] = array_keys($picklist_array);
    $arr['detailpicklist'] = $picklist;
    $arr['detailpicklistseq'] = $picklistseq;
    global $global_picklist_colors_byvalue;
    $arr['global_picklist_colors_values'] = $global_picklist_colors_byvalue;
}


$arr['isadmin']=$current_user->is_admin;
$arr['fields'] = $fields;
$arr['content'] = $table;
$arr['title'] = getFixedLabel('EDIT').'-'.$fieldlabel;
$arr['oktext'] = getFixedLabel('SAVE');
$arr['canceltext'] = getFixedLabel('CANCEL');
ConvertTojsonString(1,$arr,"success");

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