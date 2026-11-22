<?php
global $currentModule;

global $current_user,$languageType;
global $adb;
$_REQUEST['diony']='yes';
$filename=$_REQUEST['filename'];

$filetype =pathinfo($filename, PATHINFO_EXTENSION);//获取导入文件的后缀名
$focus=CRMEntity::getInstance($currentModule);
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel']=array();
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist']=array();
$frommodule=$_REQUEST['frommodule'];
$focus=CRMEntity::getInstance($frommodule);
$arr['modulelabel']=gettranstab($frommodule);
$arr['dupfieldlabel']=getFixedLabel('CHECKIMPORTFIELD');//查重字段
$arr['fileuploadlabel']=getFixedLabel('FILEUPLOAD');//上传文档
$arr['mappingfieldlabel']=getFixedLabel('MAPPINGFIELD');//映射字段
$arr['importdatalabel']=getFixedLabel('IMPORTDATATTITLE');//导入数据
$arr['finishedlabel']=getFixedLabel('TEMPLATECOMPLETE');//完成
$smarty=new lingdangCRM_Smarty();
$smarty->assign("ARRLABEL",$arr);

$_REQUEST['diony']='yes';
$tmp['title']=getFixedLabel("IMPORT").$arr['modulelabel'];
$tmp['oktext']=getFixedLabel("ASTEP");
$tmp['canceltext']=getFixedLabel("NEXT");
$moduleid=getTabid($currentModule);
$detail_focus=CRMEntity::getInstance('Contacts');
if($filetype=='xlsx'){$inputFileType = 'Excel2007';} else{$inputFileType = 'Excel5';}
$inputFileName = 'storage/'.$filename;

//主表
$sql='select blocktran.fieldlabel as blocklabel,fieldtran.fieldlabel,ld_field.typeofdata,ld_field.uitype,
            ld_field.columnname,tablename ,fieldonly,ld_field.fieldname,ld_field.displaytype
            from ld_field  inner join ld_blocks on ld_blocks.blockid=ld_field.block 
            inner join ld_tranlabel as fieldtran on ld_field.fieldid=fieldtran.relateid 
            inner join ld_tranlabel as blocktran on blocktran.relateid=ld_blocks.blockid 
            where (fieldtran.languagetype=? and fieldtran.trantable=? and fieldtran.tabid=? 
            AND ld_field.tablename not in(\'ld_contactdetails\',\'ld_contactscf\')) 
            and (blocktran.languagetype=? and blocktran.trantable=? and blocktran.tabid=?) 
            and presence in(0,2)   and ld_blocks.visible=0
            and ld_field.uitype not in(69,1109,301) 
            order by ld_blocks.sequence, ld_field.sequence ';


$result=$adb->pquery($sql,array($languageType,'ld_field',$moduleid,$languageType,'ld_blocks',$moduleid));
$defaultvalueHtml='';
$importcolumn=array();
$drophtml=array();
$sessionMainfield=array();
//28625: 客户>列表：导入地址字段时，默认匹配的是联系人的“地址”，应该是默认匹配客户的“地址”
$importcolumn[]=array('0','none-field','--无--');
for($i=0;$i<$adb->num_rows($result);$i++)
{
    $uitype=$adb->query_result($result,$i,'uitype');
    $columnname=$adb->query_result($result,$i,'columnname');
    $fieldLabel=($adb->query_result($result,$i,'fieldlabel'));
    $typeofdata=$adb->query_result($result,$i,'typeofdata');
    $fieldonly=$adb->query_result($result,$i,'fieldonly');
    $tablename=$adb->query_result($result,$i,'tablename');
    $fieldname=$adb->query_result($result,$i,'fieldname');
    $displaytype=$adb->query_result($result,$i,'displaytype');
    $savedatabase=$adb->query_result($result,$i,'savedatabase');
    if($savedatabase=='no')
        continue;
    $sessionMainfield[$i]['uitype']=$uitype;
    $sessionMainfield[$i]['columnname']=$columnname;
    $sessionMainfield[$i]['fieldlabel']=$fieldLabel;
    $sessionMainfield[$i]['typeofdata']=$typeofdata;
    $sessionMainfield[$i]['fieldonly']=$fieldonly;
    $sessionMainfield[$i]['tablename']=$tablename;
    $sessionMainfield[$i]['displaytype']=$$displaytype;
    $typedata=explode('~',$typeofdata);
    $isM = 'no';
    if($typedata[1]=='M'||$uitype==4)
    {
        $fieldLabel.='*';
        $isM = 'yes';
    }
    if($uitype==15 ||$uitype==33)
    {
        $profileid=$current_user->profileid;
        crm_load_function_file('getAssignedPicklistValues','modules/PickList','PickListUtils');
        $picklistdrop = getAssignedPicklistValues($fieldname, $profileid, $adb,array(),'');
        $drophtml[$columnname.'-field']=$picklistdrop;
    }
    $importcolumn[]=array($uitype,$columnname.'-field',trim($fieldLabel),$displaytype,$isM);
//XUQIU1000907 zl $changefield为数组，用来取所有的表头字段
    $changefield[]=$sessionMainfield[$i]['fieldlabel'];
}


$_SESSION['mainfield_'.$currentModule.'_'.$current_user->id]=$sessionMainfield;

//明细表
$detail_sql ='select blocktran.fieldlabel as blocklabel,fieldtran.fieldlabel,ld_field.typeofdata,ld_field.uitype,
                ld_field.columnname,tablename ,fieldonly,ld_field.fieldname,ld_field.displaytype
                from ld_field  inner join ld_blocks on ld_blocks.blockid=ld_field.block 
                inner join ld_tranlabel as fieldtran on ld_field.fieldid=fieldtran.relateid 
                inner join ld_tranlabel as blocktran on blocktran.relateid=ld_blocks.blockid 
                where (fieldtran.languagetype=? and fieldtran.trantable=? and fieldtran.tabid=4
                AND ld_field.columnname NOT in(\'smownerid\',\'accountid\',\'smcreatorid\',\'modifiedtime\',\'modifiedby\',\'createdtime\',\'imagename\',\'mailingcountry\',\'mailingstate\',\'mailingcity\',\'mailingzip\')) 
                and (blocktran.languagetype=? and blocktran.trantable=? and blocktran.tabid=4) 
                and presence in(0,2)   and ld_blocks.visible=0 and ld_field.uitype not in(69,1109,301) 
                order by ld_blocks.sequence, ld_field.sequence ';
$detail_Active = isset($detail_Active)?? '';
if($detail_Active != 1) $detail_result=$adb->pquery($detail_sql,array($languageType,'ld_field',$languageType,'ld_blocks'));
$session_Detailfield=array();
for($i=0;$i<$adb->num_rows($detail_result);$i++)
{
    $uitype=$adb->query_result($detail_result,$i,'uitype');
    $columnname=$adb->query_result($detail_result,$i,'columnname');
    $fieldLabel=($adb->query_result($detail_result,$i,'fieldlabel'));
    $typeofdata=$adb->query_result($detail_result,$i,'typeofdata');
    $fieldonly=$adb->query_result($detail_result,$i,'fieldonly');
    $tablename=$adb->query_result($detail_result,$i,'tablename');
    $fieldname=$adb->query_result($detail_result,$i,'fieldname');
    $displaytype=$adb->query_result($result,$i,'displaytype');
    $session_Detailfield[$i]['uitype']=$uitype;
    $session_Detailfield[$i]['columnname']=$columnname;
    $session_Detailfield[$i]['fieldlabel']=$fieldLabel;
    $session_Detailfield[$i]['typeofdata']=$typeofdata;
    $session_Detailfield[$i]['fieldonly']=$fieldonly;
    $session_Detailfield[$i]['tablename']=$tablename;
    $typedata=explode('~',$typeofdata);
    $isM = 'no';
//XUQIU1000907 zl $changefield为数组，用来取所有的表头字段,判断fieldlabel是否与表头字段重复，重复则增加联系人标识
    if (in_array($fieldLabel,$changefield)){
        $fieldLabel= getTranstab('Contacts').'_'.$fieldLabel;
    }
    if($typedata[1]=='M'||$uitype==4)
    {
        $fieldLabel.='*';
        $isM = 'yes';
    }
    if($uitype==15 ||$uitype==33)
    {
        $profileid=$current_user->profileid;
        crm_load_function_file('getAssignedPicklistValues','modules/PickList','PickListUtils');
        $picklistdrop = getAssignedPicklistValues($fieldname, $profileid, $adb,array(),'');
        $drophtml[$columnname.'-detailfield']=$picklistdrop;
    }


    if($detail_Active !=1) $importcolumn[]=array($uitype,$columnname.'-detailfield',trim($fieldLabel),$displaytype,$isM);
}
$_SESSION['detailfieldContacts']=$session_Detailfield;

$selcolumnName=array();
include 'PHPExcel/PHPExcel/IOFactory.php';
$objReader = PHPExcel_IOFactory::createReader($inputFileType);
$objPHPExcel = $objReader->load($inputFileName);
$objPHPExcel->setActiveSheetIndex(0);
$objWorksheet = $objPHPExcel->getActiveSheet();//

$highestRow=$objWorksheet->getHavaDataRow();//获取行号数组
print_r($highestRow);
$highestColumn = $objWorksheet->getHighestColumn();
$highestColumnIndex = PHPExcel_Cell::columnIndexFromString($highestColumn);//总列数
$objvalue_name = array();
//取第一行标题和第二行数据
for ($col = 0;$col < $highestColumnIndex;$col++)
{
    $uitype=0;
    $columnname='';
    $tmp_value1 = $objWorksheet->getCellByColumnAndRow($col, $highestRow[1])->getValue();
    $objvalue0 = !is_null($tmp_value1) ? trim($tmp_value1) : '';
    if($objvalue0=="")
    {
        break;
    }
    $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][]=$objvalue0;
    $tmp_value2 = $objWorksheet->getCellByColumnAndRow($col, $highestRow[2])->getValue();
    $objvalue1= !is_null($tmp_value2) ? trim($tmp_value2) : '';
    $have_label = $have_label??array();
    foreach($importcolumn as $index=>$cols)
    {

        if(in_array($objvalue0,$cols)||in_array($objvalue0.'*',$cols))
        {
            $uitype=$cols[0];
            $isM = $cols[4];
            if(in_array($objvalue0,$objvalue_name)){
                $objvalue_clear[] = $objvalue0;
            }
            $have_label[$objvalue0]+=1;

            $columnname=$cols[1];
            $displaytype=$cols[3];
            $selcolumnName[$columnname]='';
            //28625: 客户>列表：导入地址字段时，默认匹配的是联系人的“地址”，应该是默认匹配客户的“地址”
            if($have_label[$objvalue0]<=1)//联系人和客户都销售负责人字段
                break;

        }
    }
    $objvalue_name[] = $objvalue0;
    $objstr[$col]=array($objvalue0,$objvalue1,$uitype,$columnname,$displaytype,$isM);
}



//获取主表查重字段
$modulefieldblocks= $focus->fieldobj->getBlockVisibleInfos();
foreach($modulefieldblocks as $blockid=>$blockinfo)
{
    //删除没有字段的区块
    $blockfield='no';
    if($blockinfo['label']=='LBL_ACCOUNT_PRIMARYCONTACT')
        continue;
    foreach($focus->fieldobj->getModuleFields() as $index=>$fieldinfo)
    {
        if($fieldinfo->getBlockId()==$blockid)
        {
            $blockfield='yes';
            break;
        }
    }
    if($blockfield=='yes')
    {
        $blocks[]=$blockinfo;
    }
}
$smarty->assign("MODULEFIELDBLOCKS",$blocks);


$smarty->assign("JSONMODULEFIELDBLOCKS",json_encode($blocks));

$i=0;
$select = $select ?? array();
foreach($focus->fieldobj->getModuleFields() as $index=>$fieldinfo)
{
    if($fieldinfo->getfieldOnly()==1)
    {
        //客户导入时，不显示首要联系人的查重字段
        if(($frommodule == 'Accounts' || $frommodule == 'ServiceCharge') && $fieldinfo->getTableName() == 'ld_contactdetails'){
            continue;
        }
        $module_dupField[]=$fieldinfo->getColumnName();
    }
    $select[$i]['columnname'] = $fieldinfo->getColumnName();
    $select[$i]['fieldlabel']= $fieldinfo->getFieldLabel();
    $select[$i]['blockid']=$fieldinfo->getBlockId();
    $i++;
}

//获取客户联系人查重字段
$contact_show_deploy=getSys_deploy(72);

$i=0;
foreach($detail_focus->fieldobj->getModuleFields() as $index=>$fieldinfo)
{
    if($fieldinfo->getUIType()==73)
    {
        //033231: 客户>列表：导入时，联系人选择查重字段下拉选项不应该显示“客户名称”
        continue;
    }
    $contactselect[$i]['columnname'] = $fieldinfo->getColumnName();
    $contactselect[$i]['fieldlabel']= $fieldinfo->getFieldLabel();
    $i++;
}


//获取文件缓存中的查重字段
if (isset($moduleImport['select'])){
    $cache_columnname = explode(',',$moduleImport['select']);
}
if (isset($mutli_main_importcheckdupfields) && is_array($mutli_main_importcheckdupfields)){
    $multi_dupfieldkeys=array_keys($mutli_main_importcheckdupfields);//根据数据库中查重字段排序,有可能$select的排序方式和$mutli_importcheckdupfields排序不一样
}else{
    $multi_dupfieldkeys = [];
	$mutli_main_importcheckdupfields = [];
}

foreach($select as $key => $selInfo){
    $select[$key]['columnname'] = $selInfo['columnname'];
    if(sizeof($mutli_main_importcheckdupfields)>0)
    {
        if(array_key_exists($selInfo['columnname'],$mutli_main_importcheckdupfields))
        {

            $select_label[] = $selInfo['fieldlabel'];
            ////根据数据库中查重字段排序有可能$select的排序方式和$mutli_importcheckdupfields排序不一样
            $checkselect_column[array_search($selInfo['columnname'],$multi_dupfieldkeys)]=array('column'=>$selInfo['columnname'],'condition'=>$mutli_main_importcheckdupfields[$selInfo['columnname']]['condition']);

        }
    }
    else if(!empty($module_dupField)){
        if(in_array($selInfo['columnname'],$module_dupField)){
            $checkselect_column[]=array('column'=>$selInfo['columnname'],'condition'=>'or');
            $select_label[] = $selInfo['fieldlabel'];
        }
    }else{
        if($selInfo['columnname'] ==$focus->table_code){
            $checkselect_column[]=array('column'=>$focus->table_code,'condition'=>'or');
            $select_label[] = $selInfo['fieldlabel'];
        }
    }
}
ksort($checkselect_column);  //根据数据库中查重字段排序

if(sizeof($checkselect_column)<=0){
    $checkselect_column[]=array(0,'none-field','--无--');
}
if(!empty($moduleImport['select'])){
    $hidden_select = $moduleImport['select'];
}else{
    $hidden_select = $focus->table_code;
}

//获取明细文件缓存中的查重字段
if (isset($module_detail_Import['select2'])){
    $cache_columnname_detail = explode(',',$module_detail_Import['select2']);
}

//获取模块的关键字链接columnanme
// $new_entitynames_details = getEntitynameByModulename($detail_modules);

foreach($contactselect as $key => $selInfo2)
{
    if(isset($mutli_contact_importcheckdupfields) && is_array($mutli_contact_importcheckdupfields) && sizeof($mutli_contact_importcheckdupfields)>0)
    {

        if(array_key_exists($selInfo2['columnname'],$mutli_contact_importcheckdupfields))
        {
            $select_label[] = $selInfo2['fieldlabel'];
            $contactdetail_checkselect_column[]=array('column'=>$selInfo2['columnname'],'condition'=>$mutli_contact_importcheckdupfields[$selInfo2['columnname']]['condition']);
        }
    }
    else if (!empty($module_detail_Import['select2'])){
        if(in_array($selInfo2['columnname'],$cache_columnname_detail)){

            $select_label2[] = $selInfo2['fieldlabel'];
            $contactdetail_checkselect_column[]=array('column'=>$selInfo2['columnname'],'condition'=>'or');
        }
    }else{
        if($selInfo2['columnname'] == $detail_focus->table_code){ //改为为空时，默认产品编号
            $contactdetail_checkselect_column[]=array('column'=>$detail_focus->table_code,'condition'=>'or');
            $select_label2[] = $selInfo2['fieldlabel'];
        }
    }
}
if(sizeof($contactdetail_checkselect_column)<=0)
{
    $contactdetail_checkselect_column[]=array('column'=>'','condition'=>'or');
    $select_label2[] = getFixedLabel('CAMCARDNONE');
}

if(!empty($module_detail_Import['select2'])){
    $hidden_select_detail = $module_detail_Import['select2'];
}else{
    $hidden_select_detail = $detail_focus->table_code;
}
$smarty->assign('FILETYPE',$filetype); //将导入文件后缀传入tpl，方便后面获取
$smarty->assign('CACHE_LABEL',implode(',',$select_label));
$smarty->assign('CACHE_LABEL_DETAIL',implode(',',$select_label2));
$smarty->assign('CACHE_SELECT',$hidden_select);
$smarty->assign('CACHE_SELECT_DETAIL',$hidden_select_detail);
$smarty->assign('MODULENAME',$currentModule);
//29987: 单据>列表：选择重复时导入方式，不记住上次的选择，一直显示默认值“跳过”
$smarty->assign('IMPORTCHOOSE','Abort');
$smarty->assign('SELECTCOLUMNS',$select);//查重字段
$smarty->assign('DETAILACTIVE',$detail_Active);//首要联系人模块是否关闭
$smarty->assign('JSONSELECTCOLUMNS',json_encode($select));
$smarty->assign('CHECKEDCOLUMNS',$checkselect_column);
$smarty->assign('JSONPRODUCTSELECTCOLUMNS',json_encode($contactselect));
$smarty->assign('PRODUCTSELECT',$contactselect);//联系人明细下拉查重字段
//0027271: 导入客户时查重字段设置问题：联系人查重字段是否显示不应该跟据首要联系人区块是否显示相关
if(vtlib_isModuleActive('Contacts') != 'yes'){
    $contactdetail_checkselect_column = array();
}
$smarty->assign("PRODUCTCHECKEDCOLUMNS",$contactdetail_checkselect_column);//选择的联系人明细查重字段

$smarty->assign('IMPORTCOLUMN',$importcolumn);//所有字段数组
$smarty->assign('SELCOLUMN',$selcolumnName);//导入字段数组

$smarty->assign('DROPHTML',$drophtml);//下拉框数组
$smarty->assign('IMPORTDATA',$objstr);//Excel标题数组
$smarty->assign("STEPINDEX",$_REQUEST['stepindex']);
$tmp['excelcolumncount']=$highestColumnIndex;
$tmp['content']=$smarty->fetch("ImportXlsNew/secondImport.tpl");
ConvertTojsonString(1,$tmp,"success");


?>