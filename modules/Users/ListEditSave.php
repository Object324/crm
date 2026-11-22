<?php
/**
 * edit:zkt
 * date:2022-3-9
 * reason:列表界面小编辑
 **/
global $adb,$current_user;
//zkt 20231009 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
$module = $_REQUEST['frommodule'];
$fieldname = $_REQUEST['fieldname'];
$record = $_REQUEST['record'];
$tabid = getTabid($module);

$fieldvalue = ($_REQUEST[$fieldname]);//BUG0054447 20220729 序时簿小编辑字段下拉框 10% 保存失败
$fieldobj=Field::getInstance($module,$adb);
$fieldinfo = $fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);

$uitype=$fieldinfo->getUIType();
$fieldid = $fieldinfo->getFieldid();
$columnname=$fieldinfo->getColumnName();
$tablename = $fieldinfo->getTableName();

//非管理员  获取字段权限
if($current_user->is_admin=='off'){
	$profileobj=Profile::getInstance();
	$profilefields= $profileobj->getProfileInfos($current_user->profileid);
	$profilefields=$profilefields['field'];
}

$savefocus=CRMEntity::getInstance($module);
$savefocus->id = $record;
$savefocus->mode = "edit";
$savefocus->retrieve_entity_info($record,$module);
$moduleFields=$fieldobj->getModuleFields();
$savemoduleFields=$moduleFields;
//单据保存值获取 存在特殊模块retrieve_entity_info获取信息不全
foreach($moduleFields as $tmpfieldname=>$tmpfieldinfo){
    $tmptabname = $tmpfieldinfo->getTableName();
    $tmpcolumnname = $tmpfieldinfo->getColumnName();
    if(!in_array($tmptabname,$savefocus->tab_name)
        &&(($module != 'Accounts' && $module != 'ServiceCharge') &&!in_array($tmptabname,array('ld_contactdetails','ld_contactscf')))){
        unset($savemoduleFields[$tmpfieldname]);
    }
    //zkt 20240715 BUG20240613-12  项目管理,小编辑预计成交日期时,报错最新分配日期不能为空（华：这个字段莫名其妙必填了，但是属性依旧是非必填）
    if($tmpfieldinfo->getDisplaytype()==2){
        unset($savemoduleFields[$tmpfieldname]);
    }
    //客户、服务收费管理模块，联系人信息
    if(($module == 'Accounts' || $module == 'ServiceCharge') && in_array($tmptabname,array('ld_contactdetails','ld_contactscf'))){
        $contactfieldnames[]=$tmpfieldname;
        $contactcolumns[]=$tmpcolumnname;
    }
}
 
if(($module == 'Accounts' || $module == 'ServiceCharge') && !empty($contactcolumns)){
    $columns=implode(',',$contactcolumns);
  //inner join ld_crmentity on ld_crmentity.crmid=ld_contactdetails.contactid
	 $sqlcontact="select $columns,ld_contactdetails.contactid from ld_contactdetails 
	  left join ld_contactscf on ld_contactscf.contactid=ld_contactdetails.contactid
	  where accountid=? and reference=1 and ld_contactdetails.deleted=0 order by contact_no asc limit 0,1";
    $resultcontact=$adb->pquery($sqlcontact,array($savefocus->id));
    if($adb->num_rows($resultcontact)>0)
    {
        for($i=0;$i<sizeof($contactfieldnames);$i++)
        {
            $savefocus->column_fields[$contactfieldnames[$i]]=$adb->query_result($resultcontact,0,$contactcolumns[$i]);
        }
        $contactid = $adb->query_result($resultcontact,0,'contactid');
        $savefocus->column_fields["contactid"]=$contactid;
        
    }
}
foreach($savefocus->column_fields as $tmpfieldname=>$value)
{
    //zkt 20230428 BUG0065762 合同订单列表界面任意一条单据，使用小编辑编辑“客户类型”保存提示合同 不允许大于合计（实际上单据是满足验证规则条件的）
	$reqfieldname = $tmpfieldname;
    if($tmpfieldname=='hdnGrandTotal'){
         if($module=='CashBill')
            {
                $reqfieldname='cashbill_total';
            }
            else if($module=="SendCashBill")
            {
                if(is_numeric($_REQUEST['sendcashbill_total']))
                {
                    $reqfieldname='sendcashbill_total';
                }
                else{
                    $reqfieldname='total';
                }
            }
            else
                $reqfieldname='total';
    }
    if($reqfieldname!=$fieldname){
        $_REQUEST[$reqfieldname]=$value;
    }
    if($reqfieldname == 'selectlistval' && !empty($value))
    {
        $value_arr = explode(',',$value);
        $_REQUEST['selectsourcename'] = getSalesEntityType($value_arr[0]);
    }
}

$isProductDetail='no';
$cashbill_moudle = 'no';
if($module == 'CashBill' || $module == 'SendCashBill'){
    //选择源单
    $cashbill_moudle = 'yes';
    $isProductDetail = 'no';
    $sourcemodules=getSourceModule($module);
    if(isset($_REQUEST['selectsourcename'])){
        $selectsourceModule = $_REQUEST['selectsourcename'];
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

//获取明细信息
$detailfieldInfo_arr=[];
if((get_file_address($module,"ProductDetails")&&$module!='ServiceCharge') || $isProductDetail == 'yes')
{
    if($cashbill_moudle == 'yes'){
        crm_load_class_file('cls_productDetailsData',"modules/$module/ProductDetail");
        $cls_productDetailsDataobj = new cls_productDetailsData($module,$selectsourceModule);
    }else{
        crm_load_class_file('cls_productDetailsData',"modules/$module/ProductDetails");
        $cls_productDetailsDataobj = new cls_productDetailsData($module);
    }
    $detailarr = $cls_productDetailsDataobj->getProductToolFieldValue($savefocus,'edit');
    crm_load_class_file('ProductToolFields','include/ProductDetails');
    $detailfieldobj=ProductToolFields::getInstance($module);
    $rowcount = 0;
    if(!empty($detailarr))
    {
        $rowindex = 1;
        foreach($detailarr as $index=>$tmpdetailinfo)
        {
            $detailfieldInfo_arr=$tmpdetailinfo;
            foreach($tmpdetailinfo as $tmpdetailcolumnname=>$tmpdetailfieldvalue)
            {
                if($tmpdetailcolumnname == 'detailid'||$tmpdetailcolumnname == 'id')
                {
                    continue;
                }
                $tmpcolumnname  = $detailfieldobj->getFieldInfoBykeyValue('columnname',$tmpdetailcolumnname,'columnname');
                if(!empty($tmpcolumnname))
                {
                    $_REQUEST[$tmpcolumnname.$rowindex] = $tmpdetailfieldvalue;
                }
            }
            $rowcount = $rowindex;
            $rowindex++;
        }
    }
    $_REQUEST['inventory_currency'] = $savefocus->column_fields['currency_id'];
    $_REQUEST['rowcut'] = $rowcount;
}
else if(get_file_address($module,$module.'DetailFieldsHtml')&&!(empty($selectsourceModule)&&($module=='CashBill'||$module=='SendCashBill')))
{

    //获取明细数据类
    if($module == 'CashBill'){
        crm_load_class_file("CashBillTabDetailFieldsData",'modules/CashBill');
        $TabDetailFieldsDatalobj = new CashBillTabDetailFieldsData($savefocus,$module,$selectsourceModule);
    }elseif($module == 'SendCashBill'){
        crm_load_class_file("SendCashBillTabDetailFieldsData",'modules/SendCashBill');
        $TabDetailFieldsDatalobj = new SendCashBillTabDetailFieldsData($savefocus,$module,$selectsourceModule);
    }else{
        crm_load_class_file("TabDetailFieldsData",'include/TabDetailFields');
        $TabDetailFieldsDatalobj = new TabDetailFieldsData($savefocus,$module);
    }
    $detailarr = $TabDetailFieldsDatalobj->getTabDetailHtmlContentData();
    crm_load_class_file("TabDetailFields",'include/TabDetailFields');
    $detailfieldobj = TabDetailFields::getInstance($module);
    
    $rowcount = 0;
    if(!empty($detailarr))
    {
        $rowindex = 1;
        foreach($detailarr as $index=>$tmpdetailinfo)
        {
            $detailfieldInfo_arr=$tmpdetailinfo;
            foreach($tmpdetailinfo as $tmpdetailcolumnname=>$tmpdetailfieldvalue)
            {
                if($tmpdetailcolumnname == strtolower($module).'detailid'||$tmpdetailcolumnname == 'detailid')
                {
                    continue;
                }
                $tmpfieldinfo  = $detailfieldobj->getFieldInfoobjBykey('columnname',$tmpdetailcolumnname);
                
                if(!empty($tmpfieldinfo))
                {
                    $_REQUEST[$tmpdetailcolumnname.$rowindex] = $tmpdetailfieldvalue;
                }
            }
            $rowcount = $rowindex;
            $rowindex++;
        }
    }
    $_REQUEST['rowcut'] = $rowcount;
}
if(isset($_REQUEST[$fieldname]))
{
    $col_fields=$savefocus->column_fields;
    $sql='select * from ld_fieldrule where tabid=? and enablestatus = "yes"  ';
    $result=$adb->pquery($sql,array($tabid));
    $rows=$adb->num_rows($result);
    if($rows>0)
    {
        $showfieldvalue = new ShowFieldValue($fieldobj,$module,constant('SHOW_EDITVIEW'));
        //获取column-value数组对
        $columnvalues = array();
        foreach($col_fields as $tmpfieldname=>$tmpvalue)
        {
            if($tmpfieldname == $fieldname)
            {
                //获取最新字段值
                $tmpvalue = $_REQUEST[$fieldname];
            }
            $tmpfieldinfo = $fieldobj->getFieldInfoobjBykey("fieldname",$tmpfieldname);
            if(empty($tmpfieldinfo))
            {
                continue;
            }
            $tmpcolumnname = $tmpfieldinfo->getColumnName();
            if($tmpfieldinfo->getBigType()=='reference'||$tmpfieldinfo->getBigType()=='picklist'||($tmpfieldinfo->getColumnName()=='sales_stage'&&$module=='Potentails'))
            {
                $columnvalues[$tmpcolumnname]=$tmpvalue;
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
    	$fieldrulecolsproperty= $fieldruleobj->getFieldRuleProperty();//获取编辑字段触发的布局规则
        
        $requiredcolumns=$fieldrulecolsproperty['requiredcolumns'];//必填字段
       
        if(!empty($requiredcolumns))
        {
            foreach($requiredcolumns as $tmprequiredcolumn)
            {
                $tmprequirefieldname = $fieldobj->getFieldInfoBykeyValue("columnname",$tmprequiredcolumn,'fieldname');
                $tmprequirefieldlabel = $fieldobj->getFieldInfoBykeyValue("columnname",$tmprequiredcolumn,'fieldlabel');
                if(!empty($tmprequirefieldname))
                {
                   $tmpfieldinfo=  $savefocus->fieldobj->getFieldInfoobjBykey('columnname',$tmprequiredcolumn);
                   if($tmpfieldinfo->getBigType()=='fileattachment')
                   {
                    //edit:can 20231030  61order-开发任务-erp任务，；列表或详情界面小编辑“优先级”字段，会弹出“客户签字扫描件不能为空”的提示信息，但是该字段有内容 
                        $fieldjsondata=getAllFile_imageInfo($record,$module);
                        if(!array_key_exists($tmprequirefieldname,$fieldjsondata))
                        {
                             ConvertTojsonString(-1,array('operation'=>'editpage'),'保存失败，存在布局规则，'.$tmprequirefieldlabel.'不能为空');
                        }
                   }
                   else  if(empty($col_fields[$tmprequirefieldname])&&empty($_REQUEST[$tmprequirefieldname]))
                    {
                        ConvertTojsonString(-1,array('operation'=>'editpage'),'保存失败，存在布局规则，'.$tmprequirefieldlabel.'不能为空');
                    }
                }
            }
        }
    }
    
    
    //判断必填属性
    crm_load_class_file('cls_getdisplayfiledsbyrecord','include/fields');
    $cls_getdisplayfiledsbyrecordobj = new cls_getdisplayfiledsbyrecord($module,$record);
    //附件图片字段不设置值
    if($fieldinfo->getUIType()!=69&&$fieldinfo->getUIType()!=1108&&$fieldinfo->getUIType()!=1109){
        $changefieldvalue_arr = array($fieldname=>$_REQUEST[$fieldname]);
        $cls_getdisplayfiledsbyrecordobj->changeFieldvlaueByFieldname($changefieldvalue_arr);
    }
    $displayfields = $cls_getdisplayfiledsbyrecordobj->getdisplayFieldinfo();
    foreach ($savemoduleFields as $tmpfieldname=>$tmpfieldinfo){
        //当前字段判断必填在js进行，（附件、图片字段判断时会报错）
        if($tmpfieldname ==$fieldname){
            continue;
        }
        $tmpfieldid = $tmpfieldinfo->getFieldid();
        //只读权限的字段在编辑时，不显示
		 if( !empty($profilefields) && $profilefields[$fieldid]['readonly']==1){
			continue;
		 }
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
                if($tmpvalue!=''){
                    continue ;
                }
            }
            $tmpfieldlabel = $tmpfieldinfo->getfieldLabel();
            ConvertTojsonString("-1",array(),$tmpfieldlabel.getFixedLabel('APPCANNOTBEEMPTY'));
        }
    }
}

$_REQUEST['ajxaction'] = "DETAILVIEW";
$savefocus->logaction = 'listedit';

//保存调用保存方法
if(file_exists(globalStatic::$root_directory."modules/$module/DetailViewAjax.php"))
{
    //先判断验证规则
    crm_load_class_file('cls_PageValidataSaveJS','data');
    $currency_id=$savefocus->column_fields['currency_id'];
    $PageValidataSavejsobj=new cls_PageValidataSaveJS($module,$record,$_REQUEST['rowcut']);
    if(!$PageValidataSavejsobj->getValidDataJudgeJs()){
        $_REQUEST['diony']='yes';
        ConvertTojsonString("-1",array(),$PageValidataSavejsobj->errortip);
    }
  
    //允许保存的验证规则的判断
    if($_REQUEST['pagevaliddatasavetip']=='yes'){
        crm_load_class_file('cls_PageValidataSave','data');
        $PageValidataSaveobj=new cls_PageValidataSave($module,$record,$_REQUEST['rowcut']);
        $PageValidataSaveobj->setAllowSave($_REQUEST['pagevaliddatasavetip']);
        
        if(empty($currency_id))
        {
            $currency_id=1;
        }
        $PageValidataSaveobj->setCurrencyId($currency_id);
        $PageValidataSaveobj->getValidDataInfoPhp();
       if(!empty($PageValidataSaveobj->errortip)){
            ConvertTojsonString("-10",array(),$PageValidataSaveobj->errortip);
       }
    }
    
    //zkt 20220525 52207(http://localhost85/crm/index.)客户管理》客户》编辑    详情页编辑用户名称之后，修改日志没反应（在表单首页直接改是有反应的）
    $_REQUEST['mode'] = 'edit';
    crm_load_class_file("DetailViewAjaxSave",'data');
     $DetailViewAjaxSaveobj=new DetailViewAjaxSave($module,$record,$fieldname,$fieldvalue);
     $DetailViewAjaxSaveobj->save();
     $returncode = $DetailViewAjaxSaveobj->code;
     $returnerrormsg = $DetailViewAjaxSaveobj->errormsg;
     $returnarr = $DetailViewAjaxSaveobj->ret_arr;
     if($uitype == 28 || $uitype == 1109)
    {
        //附件保存
        $modObj=CRMEntity::getInstance($module);
        $modObj->id = $record;
        $modObj->mode = "edit";
        $modObj->addFileToAttachmentSavenoJudge($record,$module,array('filetoattachment'=>array($columnname)));
    }
    else if($uitype == 69)
    {
        //图片保存
        $modObj=CRMEntity::getInstance($module);
        $modObj->id = $record;
        $modObj->mode = "edit";
        $modObj->addFileToAttachmentSavenoJudge($record,$module,array('imageattachment'=>array($columnname)));
    }
     if($returncode == 1)
     {
        $returnarr = array();

         //edit:duan date:2024/10/29 reason:职位级别字段保存后刷新静态变量缓存
         if($fieldname == 'userlevel'){
             getUserGroupLevel($record,'yes');
         }

        //获取新的td内容
        //zkt 20220414 0050877 （81mis.com/kfbcrm）（列表编辑）客户》客户列表，编辑客户名称，点击✔号保存，界面一直转圈
        crm_load_class_file('Cls_FieldShowValue', 'modules/Users');
        $cls_fieldshowvalueobj = new Cls_FieldShowValue($module,$record,$fieldname);
        
        /*$showvalue = $cls_fieldshowvalueobj->getFieldValue();
        $returnarr['showvalue']=$showvalue;*/
        
        $tdinnerhtml = $cls_fieldshowvalueobj->getListFieldValue();
        $returnarr['tdinnerhtml'] = $tdinnerhtml;
        //zkt 20220525 52115(https://81mis.com/kfbcrm/index.php)(序时簿小编辑)（客户管理》客户》客户编号》2022-05-23-201修改为2022-05-23-200，与其他客户重复，但是保存时没有提醒而且还很卡，必须要刷新页面才可以显示）
        //单据编号重复时自动生成新编号提醒
        $returnfieldinfo = $cls_fieldshowvalueobj->fieldobj;
        if(!empty($returnfieldinfo)){
            $returnfielduityp = $returnfieldinfo->getUIType();
            $returnfieldlables = $returnfieldinfo->getFieldLabel();
            if($returnfielduityp==4)
            {
                $returnfieldvalue = $cls_fieldshowvalueobj->getFieldValue();
                if($returnfieldvalue != $_REQUEST[$fieldname])
                {
                    $returnarr['modulebillnotip'] = 'yes';
                }
            }
        }
        
        crm_load_class_file("cls_mainfieldformula","include/fields");

            $mainfieldformula=cls_mainfieldformula::getInstance($module);
            $tmpArr=array($fieldname=>$_REQUEST[$fieldname]);
            //设置哪些字段 在界面上保存
            $mainfieldformula->setMainFieldHadRequest($tmpArr);
            $mainfieldformula->setRecord($record);
            //设置数据库字段的值
            $mainfieldformula->setColumn_fieldsValue($savefocus->retrieve_entity_info($record,$module));
            /*可以不需要传入明细，默认明细界面的值没有被修改
            $keys=array_keys($detailfieldInfo_arr);
            $mainfieldformula->setDetailFieldHadRequest($keys);
            $mainfieldformula->setdetailColumn_fieldsValue($detailarr);*/
          
            $mainfieldformula->updateDbValue($fieldname,$record);
        
        
        
        $DetailViewAjaxSaveobj->ret_arr = array('fieldshowinfo'=>$returnarr,'fieldinfo'=>$fieldinfo);
     }
     $DetailViewAjaxSaveobj->setEcho();
}
else
{
    ConvertTojsonString(-1,array(),"保存失败");
}

    



?>