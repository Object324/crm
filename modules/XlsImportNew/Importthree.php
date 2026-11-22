<?php
 set_time_limit(0);
 require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
  require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
 
global $current_user;
global $currentModule;
$filename=$_REQUEST['filename'];
if(empty($filename)) {
    $frommodule=$_REQUEST['frommodule'];
    $focus=CRMEntity::getInstance($frommodule);
    $arr['modulelabel']=gettranstab($frommodule);
    $arr['dupfieldlabel']=getFixedLabel('CHECKIMPORTFIELD');//查重字段
    $arr['fileuploadlabel']=getFixedLabel('FILEUPLOAD');//上传文档
    $arr['mappingfieldlabel']=getFixedLabel('MAPPINGFIELD');//映射字段
    $arr['importdatalabel']=getFixedLabel('IMPORTDATATTITLE');//导入数据
    $arr['finishedlabel']=getFixedLabel('TEMPLATECOMPLETE');//完成
    $smarty=new lingdangCRM_Smarty();
    $smarty->assign("STEPINDEX",$_REQUEST['stepindex']);
    $smarty->assign("ARRLABEL",$arr);
    $tmp['content']=$smarty->fetch('ImportXlsNew/ThreeImport.tpl');
    $tmp['title']=getFixedLabel("IMPORT").$arr['modulelabel'];
    //$tmp['oktext']=getFixedLabel("ASTEP");
    $_REQUEST['diony']='yes';
    ConvertTojsonString(1,$tmp,'success');
}

if($currentModule=='Users') {
    include(globalStatic::$root_directory."modules/XlsImportNew/ImportThreeUsers.php");
    exit();
}
include(globalStatic::$root_directory.'modules/XlsImportNew/NewImportSModule.php');
include(globalStatic::$root_directory.'modules/XlsImportNew/NewImportCommon.php');
include globalStatic::$root_directory.'PHPExcel/PHPExcel/IOFactory.php';
crm_load_class_file('cls_Bangwoba', 'modules/Users');
$cls_Bangwoba = new cls_Bangwoba();
static $db_checkValues;	//查重信息
$smarty=new lingdangCRM_Smarty();
$page_width= $_SESSION['bodywidth'];
$smarty->assign("PAGEWIDTH",$page_width);
//这里开始处理数据并且导入
//$_SESSION[$currentModule]['importXls']['count']
$start_importxl_row_index=1;
$mapfields=json_decode($_REQUEST['mapped_fields']);//导入字段
$totalcolumns=sizeof($mapfields);  
$defaultvalue = json_decode($_REQUEST['defaultvalue']);//导入的字段名称对应值
//主表字段
$result=  $_SESSION['mainfield_'.$currentModule.'_'.$current_user->id.'_fields'];//数组
$error='';//错误信息
import('data.Logic','class');
import('data.BaseLogic','class');
BaseLogic::$module=$currentModule;
if(!file_exists(globalStatic::$root_directory.'modules/'.$currentModule.'/'.$currentModule.'Logic.class.php')) {
    $btnlogic=new BaseLogic();
} else {
    require_once(globalStatic::$root_directory.'modules/'.$currentModule.'/'.$currentModule.'Logic.class.php');
    $cls=$currentModule.'Logic';
   	$btnlogic=new $cls();
}
$taxcolumn_arr=[];//产品税别字段
$taxcolumn_excelIndex=[];//税别字段对应的excel列索引
$currentModule=$import_module = $_REQUEST['frommodule'];

$smarty->assign("IMPORTMODULE",$import_module);
$importcolumn=array();
$main_focus=CRMEntity::getInstance($currentModule);
//edit: xll 2023/08/17 BUG0071293 导入数据导致销售漏斗数据不对
crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance = new cls_module_advance($currentModule);
$field_tables[$main_focus->table_name]=array();//主表导入字段
$field_columns_only=array();//唯一字段
$codeIndex=0;//编号在xls文件中列索引

$findcodenum=false;
$nohaveerror=true;
$fieldcolIndex=0;
$userarr=array();//用户集合
//smcreatorid,createdtime,modifiedtime,modifiedby

$moduleid = getTabid($currentModule);
$noeditField=array('smcreatorid'=>'-1','createdtime'=>'-1','modifiedtime'=>'-1','modifiedby'=>'-1');
$smownerfield=array('smownerid'=>'-1');
$importcolumnname_index=array('smownerid'=>-1,'smcreatorid'=>'-1','code_num'=>-1,'accountid'=>'-1','currency_id'=>'-1');//导入字段在excel中的列位置
$salutationfield=array('salutation'=>'-1');//联系人称谓
$moduleImport['choose'] = $_REQUEST['choose'];

$cachekey = 'importtabid_'.$moduleid;
CacheDirectory($cachekey,'Cache',$moduleImport);
$import_type = $_REQUEST['choose']; //获取重复时导入方式
$checkimportfield=implode(',',json_decode($_REQUEST['importdupcheckfields'],true));//查重字段
$is_checkimportfield = explode(',',$checkimportfield);//将选中的查重字段转为数组
$importdupfields_condition=json_decode($_REQUEST['importdupfields_condition']);//查重字段条件

$conditionorlabel=getFixedLabel('OR');
$conditionandlabel=getFixedLabel('SEARCHAND');
for($i=0;$i<sizeof($is_checkimportfield);$i++)
{
    $fieldlabel=$main_focus->fieldobj->getFieldInfoBykeyValue("columnname",$is_checkimportfield[$i],'fieldlabel');
    if($importdupfields_condition[$i]=='or')
        $conditionlabel=$conditionorlabel;
    else
        $conditionlabel=$conditionandlabel;

    if($i==sizeof($is_checkimportfield)-1) {
        $conditionlabel='';
    }
    $fieldlabel_dup_tip.='"'.$fieldlabel.'"'.$conditionlabel;
}

$fieldlabel_dup_tip=trim($fieldlabel_dup_tip,$conditionlabel);
$code_num_columnname=$main_focus->fieldobj->getFieldInfoBykeyValue("uitype",4,'columnname');

$joinmodule=getUsersettingByLabel($currentModule,'1','JointCheckDuplicate');
// wym 240423 XUQIU20240402-03 检查下拉框字段
$checkPicklist=getUsersettingByLabel($currentModule, $current_user->id,'ImportCheckPicklist');
if(!empty($checkPicklist) && $checkPicklist!='no' && $checkPicklist!='yes'){//yes代表虽然开启了检查,但没有设置检查字段
    $checkPicklistColumn=explode('##',$checkPicklist);
}
//wym 240429 XUQIU20240326-05 导入，增加触发工作流生效（苏宁）
$trigger_workflow=getUsersettingByLabel($currentModule,$current_user->id,'ImportCheckWorkflow');
if($trigger_workflow=='yes') {
    crm_load_class_file("cls_savereverse", 'include/SaveReverse');
    $workflowreverseobj = cls_savereverse::getInstance($currentModule);
}
for($i=0;$i<sizeof($result);$i++)
{
     $uitype=$result[$i]['uitype'];
     $columnname=$result[$i]['columnname'];
     $fieldinfo=$main_focus->fieldobj->getFieldInfoobjBykey("columnname",$columnname);
     if(!empty($fieldinfo) && $fieldinfo->getSaveDataBase()=='no')
        continue;
     $tablename=$result[$i]['tablename'];
     $typeofdata=$result[$i]['typeofdata'];
     $fieldLabel=$result[$i]['fieldlabel'];
     $typedata=explode('~',$typeofdata);
     //$is_checkimportfield=$result[$i]['is_checkimportfield']; //是否导入字段
     $smcreatorid=$current_user->id;

     if($tablename=='ld_producttaxrel')
     {
        $taxcolumn_arr[]=$columnname;//税别字段
        $taxcolumn_excelIndex[$columnname]=array_search($columnname.'-field',$mapfields);
     }
     if($code_num_columnname!=''){
         if(!in_array($code_num_columnname.'-field',$mapfields)){
             $onlytablename = $tablename;
         }
     }
     //edit:duan  reason:导入模块中缺少币种字段时无法保存，添加$columnname=='currency_id'判断
     if(in_array($columnname.'-field',$mapfields)||$columnname=='currency_id') {
         $field_tables[$tablename][]=array($columnname,$uitype,$typeofdata,array_search($columnname.'-field',$mapfields),$fieldLabel);
         $fieldcolIndex++;
         if($columnname=='smownerid')
            $importcolumnname_index['smownerid']=array_search($columnname.'-field',$mapfields);
         else if($columnname==$main_focus->getCreateColumnName())
         {
            $importcolumnname_index['smcreatorid']=array_search($columnname.'-field',$mapfields);
         }
         else if($uitype==73)
         {
            $importcolumnname_index['accountid']=array_search($columnname.'-field',$mapfields);
         }
         else if($uitype==117)
         {
            $importcolumnname_index['currency_id']=array_search($columnname.'-field',$mapfields);
         }
         if($uitype==4){
            $codeIndex=array_search($columnname.'-field',$mapfields);
            $codeIndex_No=array_search($columnname.'-field',$mapfields);
            $onlytablename = $tablename;
            $onlyfieldLabel = $columnname;
            $importcolumnname_index['code_num']=array_search($columnname.'-field',$mapfields);
         }
         elseif($currentModule=='ContactRecords')
         {
            $onlytablename='ld_contactrecords';
         }
         elseif($currentModule=='VendorContactRecords')
         {
            $onlytablename='ld_vendorcontactrecords';
         }
         else if($currentModule=='Calendar')
         {
            $onlytablename='ld_activity';
         }
         if('lastname-field'==$columnname.'-field')
         {
            $contactlastindex=array_search($columnname.'-field',$mapfields);
         }
         if(!empty($checkPicklistColumn) && $uitype==15){ //当前模块设置了检查下拉框字段，并且该字段是下拉框类型
             $selcol=$tablename.':'.$columnname;
             if(in_array($selcol,$checkPicklistColumn)){ //当前字段是需要检查的下拉框字段
                 if(!isset($_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$columnname])) {
                     $fieldname = $fieldinfo->getFieldName();
                     crm_load_class_file('cls_PickList', 'modules/PickList');
                     $cls_picklistobj = cls_PickList::getInstance($fieldname, $fieldinfo);
                     $tmppicklistinfo = $cls_picklistobj->getPickListValues($fieldname, $fieldinfo);
                     $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_picklist'][$columnname] = $tmppicklistinfo; //把需要检查的字段下拉框值存入session，减少多次查询
                 }
             }
         }
     }
}
if($error!=''){
    $filehandler=fopen('storage/importlog_'.$currentModule.'_'.$current_user->id.'.txt','w+');
    fwrite($filehandler,str_replace('<br>',"\r\n",$error));
    fclose($filehandler);
    $_REQUEST['diony']='yes';
    ConvertTojsonString("-1",array(),$error);
}else{
    $filename=$_REQUEST['filename'];
    $filetype =pathinfo($filename, PATHINFO_EXTENSION);//获取导入文件的后缀名
    $focus=$main_focus;
    $AccountDeskstr=array();
    $highestRow=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestrow'];
    if(sizeof($highestRow)<2){
        $error .='模板文件中没有数据，导入失败！'.'<br>';
        $importdatainfo=$error;
        $false=true;
        $_REQUEST['diony']='yes';
        ConvertTojsonString("-1",array(),$error);
    }
    $highestColumnIndex=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestColumnIndex'];//总列数
    $sqlcrmentity='insert into ld_crmentity(crmid,setype)values (?,?)';
    $insert_columname = array();
    $insert_values = array();


    foreach($field_tables as $tablename=>$colinfo)
    {
        if($tablename=='ld_crmentity'){
            continue;
        }
        foreach($colinfo as $ky=>$colnames) {
            $insert_columname[$tablename][] = $colnames[0];
        }
        if(strtolower($tablename)==$focus->table_name){
            if(!in_array('smcreatorid',$insert_columname[$tablename])){
                $insert_columname[$tablename][] = 'smcreatorid';
            }
            if(!in_array('smownerid',$insert_columname[$tablename])){
                $insert_columname[$tablename][] = 'smownerid';
            }
            if(!in_array('createdtime',$insert_columname[$tablename])){
                $insert_columname[$tablename][] = 'createdtime';
            }
            if(!in_array('modifiedtime',$insert_columname[$tablename])){
                $insert_columname[$tablename][] = 'modifiedtime';
            }
            if(!in_array('modifiedby',$insert_columname[$tablename])){
                $insert_columname[$tablename][] = 'modifiedby';
            }
            if($focus->fieldobj->getFieldInfoBykeyValue('columnname','currency_id','uitype')!='') {
                if(!in_array('currency_id',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'currency_id';
                }
            }
        }
        $insert_columname[$tablename][] = $focus->tab_name_index[$tablename];
        foreach($insert_columname as $tablename => $column_fields){
            if($code_num_columnname!=''&&$importcolumnname_index['code_num']<0&&$tablename==$main_focus->table_name) {
                 $field_sql[$tablename]=' insert into '.$tablename.'(' . implode(',',$column_fields). ','.$code_num_columnname.') values (' . generateQuestionMarks($column_fields).',?)' ;
            } else{
                if($tablename=='ld_producttaxrel') {
                    foreach($column_fields as $tmpcolumnname) {
                        if($tmpcolumnname=='productid') {
                            continue;
                        }
                        $field_sql[$tablename][]=' insert into '.$tablename.'(productid,' . $tmpcolumnname. ',taxpercentage) values (?,?,?)' ;
                    }
                } else {
                    $field_sql[$tablename]=' insert into '.$tablename.'(' . implode(',',$column_fields). ') values (' . generateQuestionMarks($column_fields).')' ;
                }
            }
        }
    }

    //dump($field_sql);
    $columnname = array();
    $insertvalue = array();
    $importdatas= $_SESSION['import_'.$currentModule.'_'.$current_user->id."_data"];//需要导入的数据
    $startrow=$_REQUEST['startrow'];
    $endrow=$_REQUEST['endrow'];

    $nohaveerror=true;
    $codenum=0;
    $g=0;

    $module_tablename=$focus->table_name;//单据主表
    $module_tablename_scf =$focus->customFieldTable[0];//单据自定义表
    $current_user_name = $current_user->last_name;
    $maxrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_maxrows'];//导入的总行数
    $Importoop = new NewImport_Xls($importcolumnname_index,$currentModule);

    for($row=$startrow;$row<=$endrow;$row++) {
        $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_hangshu']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_hangshu']+1;
        $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']+1;

        $nohaveerror=true;
        $xlsRowData=array();
        $st = array();
        $flag = true;

        if($row>=$maxrows) {//如果超过xls文件行数则退出循环
            break;
        }
        $excelrow=$row+2;
        if(!array_key_exists($excelrow,$highestRow)) {
            continue;
        }
        if($code_num_columnname!='') {
            $checkcodenum=trim((string)$importdatas[$row][$codeIndex]);
            if($checkcodenum!='')
                $checkcodenum=preg_replace("/(\s|\&nbsp\;|　|\xc2\xa0)/","",$checkcodenum);
            if($checkcodenum==''){
                $g=1;
            }else{
                $codenum=$checkcodenum;
            }
        }

        $uniqueid=$adb->getUniqueID('ld_crmentity');
        $xlsRowData=array();
        foreach($field_tables as $tablename=>$colinfo)
        {
            foreach($colinfo as $ky=>$colnames) {
                $typedata=explode('~',$colnames[2]);
                $fieldcolIndex=$colnames[3];
                $colname=$colnames[0];
                $uitype=$main_focus->fieldobj->getFieldInfoBykeyValue('columnname',$colname,'uitype');
                $bigtype=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$colname,'bigtype');
                $fieldLabel=$colnames[4];
                $str=trim((string)$importdatas[$row][$fieldcolIndex]);

                $uname = getUserFullName($current_user->id);
                if($str=='') {
                    $tmpcolumnindex = array_search($colnames[0].'-field',$mapfields);
                    $str=trim($defaultvalue[$tmpcolumnindex]);
                }

                if($typedata[0]=='D'){
                    $str=NewImportCommon::operationDate($str);
                }

                if($typedata[0]=='DT'){
                   $str=NewImportCommon::operationDateTime($str);
                }

                if($typedata[0]=='T'){
                    if($str==''){
                        $str=NULL;
                    }else{
                        $str=date('H:i:s',PHPExcel_Shared_Date::ExcelToPHP($str));
                    }
                }

                if($typedata[0]=='N'&&$str!=''&&!is_numeric($str)) {
                    //$str= $objWorksheet->getCellByColumnAndRow($fieldcolIndex, $row)->getCalculatedValue();
                    if(!is_numeric($str))
                    {
                        $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列内容为非法数字!<br>';
                        $nohaveerror=false;
                    }
                }
                if($typedata[0]=='N'&&$str=='') {
                    $str=NULL;
                }

                if($typedata[0]=='NN'&&$str=='') {
                    $str=NULL;
                }
                if(array_key_exists($colnames[0],$noeditField)&&is_array($xlsRowData[$codenum]['maintable'][$tablename])) {
                    $noeditField[$colnames[0]]=sizeof($xlsRowData[$codenum]['maintable'][$tablename]);
                }
                if(array_key_exists($colnames[0],$smownerfield)&& is_array($xlsRowData[$codenum]['maintable'][$tablename])) {//负责人的值

                    $smownerfield[$colnames[0]]=sizeof($xlsRowData[$codenum]['maintable'][$tablename]);
                }

                //获取导入列值
                $oldstr=$str;
                $str=$Importoop->setImprtNameToId($colnames[1],$str,$row);

                if($colnames[1]==117) {
                    if($oldstr=='') {
                        $str=1;//37266: （1.6）合同订单模块列表界面>更多>导入>导出模板：导出的模板中缺少了币种字段。（需要补丁）
                        $currency_id=1;
                    } else {
                        $currency_id=$str;
                    }
                }
                if($colnames[1]=='1600'){ //通过用户字段值获取成员所属部门
                    $str = $Importoop->getvaluebyfields($colnames,$str,$field_tables,$importdatas[$row]);
                }
                if($colnames[1]==15 ){
                    if(mb_convert_encoding($str, "GBK","UTF-8")=='?'){
                        $str = '';
                    }
                }
                if($colnames[1]==15 && array_key_exists($colnames[0],$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'])){ //XUQIU20240402-03 导入，增加“导入控制”，可设置校验下拉框字段
                    if(!empty($str)  && !in_array($str,$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$colnames[0]])){ //检查导入值是否是下拉框选项
                        $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列值为空或在数据库中不存在!<br>';
                        $nohaveerror=false;
                    }
                }
                if($importcolumnname_index['currency_id']<0&&$frommodule=='Potentials') {
                    $currency_id=1;
                }

                if($str == ''  && $typedata[1]=='M' && $uitype!=4){
                    $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列值为空或在数据库中不存在!<br>';
                    $nohaveerror=false;
                }else{
                    if($bigtype=='reference'||$uitype==52||$uitype==53) {
                        if($typedata[1]=='M'&&empty($str)){
                            if($Importoop->haveerrormsg()){
                                $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"'.$Importoop->getouterrormsg().'<br>';
                            } else {
                                $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列值为空或在数据库中不存在!<br>';
                            }
                            $nohaveerror=false;
                        }
                    }
                    if(strtolower($typedata[0]) == 'i'){
                        if(empty($str)) $str = 0;
                    }
                    $values[] = $str;
                    $xlsRowData['maintable'][$tablename][$colnames[0]]=$str;
                }
            }
        }//ls 20221115  XUQIU1000422 “公海参数设置”界面增加“客户数量上限”区块（导入判断线索数量上限）
        if($frommodule == 'Leads'){
            crm_load_class_file('cls_PublicLeads', 'modules/Leads');
            $cls_PublicAccounts = new cls_PublicLeads($frommodule);
            $public_account = $cls_PublicAccounts->getPublicAccount();
            foreach($xlsRowData['maintable'] as $maintable=>$infos){
                if($maintable=='ld_leads'){
                    $tmp_smownerid = !empty($infos['smownerid'])?$infos['smownerid']:$current_user->id;
                    if($public_account['status'] != 'yes' || ($public_account['status'] == 'yes' && ($infos['pool_id'] === '' || $infos['pool_id'] === 0))){//普通线索  如果所属公海为空，则设置公海状态为普通线索
                        $limit_count = $focus->getCommonAccountLimitCount($tmp_smownerid);//普通数量上限
                        if($limit_count<9999999999) {
                            $haved_count = $focus->getSmowerNumForCommonAccount($tmp_smownerid);//已有数量
                            if ($limit_count <= $haved_count) {
                                $error .="第".$excelrow."行销售负责人拥有的普通".getTranstab($frommodule)."数量已达上限！"."<br>";
                                $nohaveerror=false;
                            }
                        }
                    } elseif ($public_account['status'] == 'yes' && $infos['pool_id'] > 0 && $infos['publicaccount'] == 2) {//公海已分配   如果所属公海不为空，并且公海状态为公海已分配时，判断上限，其它情况属于公海未分配
                        $limit_count = $focus->getPublicAccountLimitCount($tmp_smownerid,$infos['pool_id']);//公海已分配数量上限
                        if($limit_count<9999999999) {
                            $haved_count = $focus->getSmowerNumForPublicAccount($tmp_smownerid,$infos['pool_id']);//已有公海已分配数量
                            if ($limit_count <= $haved_count) {
                                $error .="第".$excelrow."行销售负责人拥有的公海已分配".getTranstab($frommodule)."数量已达上限！"."<br>";
                                $nohaveerror=false;
                            }
                        }
                    }
                }
            }
        }
        if($nohaveerror==false) {
             continue;
        }
        if($g!=0){
            //$codenum++;
        }

        //下面开始导入数据
        $temp=array();
        $_uniqueid=array();
        $_checkdupValues=array();
        $_checkColumn=array();////不要等于array,如果等于arra()且查重字段的值为空会有bug
        $_checkValues=array();
        $_checkCondition=array();

        //模块若设置了没有工商信息不允许导入，则查询工商信息是否存在
        crm_load_class_file('cls_BusinessInformation', 'modules/Users');
        $businessinformationobj = cls_BusinessInformation::getInstance($frommodule);
        if($businessinformationobj->IsEnableBusiness()){
            if($businessinformationobj->IsNoBusinessnoimport()&&!empty($xlsRowData['maintable'])) {
                $requestvalues_arr = array();
                foreach($xlsRowData as $reqtabtype=>$reqtabtypeinfo)
                {
                    foreach($reqtabtypeinfo as $reqtabname=>$reqtabfields)
                    {
                        foreach($reqtabfields as $reqcolumnname=>$reqcolumnvalue)
                        {
                            $requestvalues_arr[$reqcolumnname]=$reqcolumnvalue;
                        }
                    }
                }
                crm_load_function_file('getSaveBusiness','modules/Users','GetTianYanSearchInfo');
                $businesimport = getSaveBusiness($frommodule,$requestvalues_arr);
                if($businesimport == 'no') {
                    $company_name_columnname = $businessinformationobj->getModuleBusinessQueryField('columnname');
                    $company_name = $requestvalues_arr[$company_name_columnname];
                    $error .="第".$excelrow."行".$company_name."工商信息不存在！"."<br>";
                    continue;//工商信息不存在时，本行记录不进行导入
                }
            }
        }

        if($import_type!="Insert"){ //查重判断
            foreach($xlsRowData as $main => $values_one){
                 $temp =$values_one;
                 //edit:can 20210507 0045630: （http://210.13.216.146:85/crm [^]）（福建省闽发铝业股份有限公司）营销管理-销售业绩单，导入的查重字段选择客户名称，重复时选择跳过。但是导入数据时客户名称重复了但是没有跳过，并且编号没有自动增加
                //常用审批单
                 foreach($is_checkimportfield as $index=>$tmpfieldname)
                 {
                     if($tmpfieldname != ''){
                         $tablename=$focus->fieldobj->getFieldInfoBykeyValue('fieldname',$tmpfieldname,'tablename');
                         $columnname=$focus->fieldobj->getFieldInfoBykeyValue('fieldname',$tmpfieldname,'columnname');
                         if($values_one[$tablename][$columnname]!='') {
                             $_checkColumn[]=$columnname;
                             $_checkdupValues[] = $values_one[$tablename][$columnname];
                             if($index==sizeof($is_checkimportfield)-2)//判断查重字段最后一个字段是否有值
                             {


                                    $importfieldobj= $focus->fieldobj->getFieldInfoobjBykey('fieldname',$is_checkimportfield[$index+1]);
                                    $importcolumntablename=$importfieldobj->getTableName();//获取查重字段所在表
                                    //wym 240515 BUG20240507-36 $xlsRowData键是columnname,$is_checkimportfield键是fieldname
                                    $next_colname=$focus->fieldobj->getFieldInfoBykeyValue('fieldname',$is_checkimportfield[$index+1],'columnname');
                                    if($xlsRowData['maintable'][$importcolumntablename][$next_colname]!='')
                                        $_checkCondition[$columnname]=$importdupfields_condition[$index];
                                    else
                                        break;
                             }
                             else
                             {
                                    $_checkCondition[$columnname]=$importdupfields_condition[array_search($columnname,$is_checkimportfield)];
                             }
                             //$_checkCondition[$columnname]=$importdupfields_condition[array_search($columnname,$is_checkimportfield)];
                         }
                     }
                 }
             }
            //进行查重
            $main_table_sql = 'SELECT '.$module_tablename.'.'.$focus->tab_name_index[$module_tablename].' as id from '.$module_tablename.'  LEFT JOIN
            '.$module_tablename_scf.' on '.$module_tablename_scf.'.'.$focus->tab_name_index[$module_tablename] .' = '.$module_tablename.'.'.$focus->tab_name_index[$module_tablename].'';
            $main_table_sql .=" where (   ";
            $dupcheckfield_len=sizeof($_checkColumn);
            $tmp_dupcheckfield=0;
            if($dupcheckfield_len>0&&is_array($_checkColumn)&&$_checkColumn[0]!="")
            {
                $joincheckdup=false;
                foreach($_checkColumn as $tmp_dupcheckfield=>$tmp_columnname)
                {
                    $main_table_sql.= "  $tmp_columnname= ?  ";
                    if($_checkCondition[$tmp_columnname]!=""&&$tmp_dupcheckfield!=$dupcheckfield_len-1)
                    {
                        $main_table_sql.=$_checkCondition[$tmp_columnname];
                    }
                    //wym 240417 1000195 销售线索和客户增加一起查重功能，包括新增、导入（邹晓宇）
                    if($tmp_columnname=='accountname' && $_checkCondition[$tmp_columnname]=='or'){
                        if(!empty($joinmodule) && $joinmodule!='no'){
                            $fieldvalue=$_checkdupValues[$tmp_dupcheckfield];
                            crm_load_class_file('cls_rule_validata','include/utils');
                            $joincheckdup=cls_rule_validata::checkDuplicate($fieldvalue,$joinmodule,'');
                        }
                    }
                }
                $main_table_sql.=" ) ";
                $main_table_sql.=" and deleted=0";
                $check_result = $adb->pquery($main_table_sql,array($_checkdupValues));
                $num_rows = $adb->num_rows($check_result);
            }
            else {
                $num_rows=0;
            }
        }

        if(($num_rows>0 || $joincheckdup==true)&&$import_type=='Abort'){
            $xlsRowData=array();
            if($num_rows>0){
                $error .="第".$excelrow."行".$main_fieldlabel_dup_tip."在".getTranstab($currentModule)."模块重复，已做跳过处理!"."<br>";
            } elseif($joincheckdup==true){
                $error .="第".$excelrow."行".$main_fieldlabel_dup_tip."在".getTranstab($joinmodule)."模块重复，已做跳过处理!"."<br>";
            }
            if($num_rows>0 && $joincheckdup==true){ //wym 240424 BUG20240423-29 两模块都重复时应该都提示
                $error .="第".$excelrow."行".$main_fieldlabel_dup_tip."在".getTranstab($currentModule)."和".getTranstab($joinmodule)."模块重复，已做跳过处理!"."<br>";
            }
            $flag = false;
        }
        if($flag == true){
            if(strtolower($import_type)=='update' || $import_type=='UpdateAll'){
                if($num_rows > 0){
                    $updateValues=array();
                    $updateColumns=array();
                    foreach($temp as $t_table => $t_files_values){
                        foreach($t_files_values as $t_files =>$t_values){
                            if (in_array($t_files,array('approvestatus','createdtime'))) {//覆盖及覆盖(全部)时， 审批状态、创建时间不允许覆盖。
                                continue;
                            }
                            if($t_values!=''){
                                $updateColumns[$t_table][$t_files] = $t_files;
                                $updateValues[$t_table][$t_files] = $t_values;
                            }
                        }
                    }

                    $main_focus->getModuleStatic('ModTracker');
                    //覆盖脚本
                    for($j=0;$j<$num_rows;$j++) {
                        $_uniqueid=$adb->query_result($check_result,$j,'id');
                        $main_focus->id=$_uniqueid;
                        $main_focus->retrieve_entity_info($main_focus->id,$currentModule);
                        if ($import_type=='Update') {
                            $btnlogic->controller=$main_focus;
                            $editbutton=$btnlogic->getEditViewBtn();
                            if($editbutton['permit']!='yes') {
                             //是否有该单据的编辑权限
                                if($btnlogic->edit_errorreason['reason']=='approve') {
                                    $error.='第'.$excelrow.'行单据'.$btnlogic->edit_errorreason['description'].'，不允许覆盖！<br>';
                                } else {
                                    $error.='您没有第'.$excelrow.'行编辑权限，不允许覆盖！<br>';
                                }
                                continue;
                            }
                        }
                        $main_focus->modstatic->init($main_focus,$main_focus->module_name);//记录覆盖导入日志

                        $all_update_value=[];
                        foreach($updateColumns as $tablename => $updatecolumnnames){
                            foreach($updatecolumnnames as $updatecolumn) {
                                //zkt 20230424 BUG0065438 【病人数据统计表 CustomForm07】数字字段【存活病人数】在导入数据时，需要覆盖的方式，但是如果导入表格中是0则不会覆盖
                                if($updateValues[$tablename][$updatecolumn] != ''){ //等于零不考虑了
                                    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$updatecolumn);
                                    if(!$fieldinfo)
                                        continue;
                                    $query = 'update ' . $tablename . ' set ' . $updatecolumn . '=?' . ' where ' . $focus->tab_name_index[$tablename] . ' =?  ';
                                    $adb->pquery($query,array($updateValues[$tablename][$updatecolumn],$_uniqueid));
                                    $all_update_value=array_merge($all_update_value,$updateValues[$tablename]);
                                    if($currentModule == 'Contacts'&&$tablename=='ld_contactscf'){	//帮我吧//$cls_Bangwoba->setContactsToBangwoba($_uniqueid,'edit');
                                        $focus->SyncContactsToBangwoba($_uniqueid,'edit');
                                    }
                                    //如果是币种，则更新对应的币种符号和汇率
                                    if($updatecolumn == 'currency_id'){
                                        if(!empty($updateValues[$tablename][$updatecolumn])){
                                            $updateValues[$tablename][$updatecolumn]=1;
                                        }
                                        $currency_obj=new Currency($adb,$updateValues[$tablename][$updatecolumn]);
                                        $adb->pquery("update ".$tablename." set currency_symbol = ?,conversion_rate=? where ".$focus->tab_name_index[$tablename]." = ? ",
                                            array($currency_obj->getCurrencySymbol(),$currency_obj->getCurrencyRate(),$_uniqueid));
                                    }
                                }
                            }
                            //wym 240429 XUQIU20240326-05 导入，增加触发工作流生效（苏宁）
                            if($trigger_workflow=='yes'){
                                $workflowreverseobj->setRecord($_uniqueid);
                                $beforefieldvalue_arr=$main_focus->column_fields;
                                $afterfieldvalue_arr=$all_update_value;
                                $pagemode='updated';
                                if(!empty($afterfieldvalue_arr)){
                                    $workflowreverseobj->setPageMode($pagemode);
                                    $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);
                                }
                            }
                            if($tablename=='ld_producttaxrel') {
                                //edit:can 20210601 46131: （81mis.com/kfbcrm）产品管理-导入；导入模板中，含有销售税率，附加税等字段，导入时没有这些字段可选择进行映射
                                foreach($taxcolumn_arr as $taxcolumnname) {
                                    $taxvalue=$updateValues[$tablename][$taxcolumnname];
                                    if(empty($taxvalue))
                                        continue;
                                    preg_match_all('/\d+/',$taxcolumnname,$tmp_arr);//默认只到9，相信没有10以上的税率
                                    $sql='select 1 from ld_producttaxrel where productid=? and taxid=? ';
                                    $tax_result=$adb->pquery($sql,array($_uniqueid, $tmp_arr[0][0]));
                                    //dump($tablename);
                                    if($adb->num_rows($tax_result)<=0)
                                        $adb->pquery("insert into ld_producttaxrel(productid,taxid,taxpercentage)value(?,?,?) ",array($_uniqueid, $tmp_arr[0][0],$updateValues[$tablename][$taxcolumnname]));
                                    else {
                                        $sql='update ld_producttaxrel set  taxpercentage=? where productid=? and taxid=? ';
                                        $adb->pquery($sql,array($updateValues[$tablename][$taxcolumnname],$_uniqueid,$tmp_arr[0][0]));
                                    }
                                }
                            }
                        }
                        //ls 20221206 XUQIU1000959 导入增加覆盖(全部)选项（导入日志）
                        $main_focus->modstatic->saveOperationLog($main_focus->module_name,$main_focus->id,'IMPORT',$import_type);
                        $main_focus->modstatic->triggerEvent($main_focus->module_name);
                        $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows']+1;
                    }
                    if($num_rows>0) {
                        //edit:can 2020-08-27 042514: （61mis.com/kfbcrm）（梁文乐客户问题）借款申请单模块>更多>导入：选择“覆盖”导入，导入成功后，导入日志显示错误。（需要补丁）
                        //// $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']+1;
                    }
                    //edit: xll 2023/08/17 BUG0071293 导入数据导致销售漏斗数据不对
                    $cls_module_advance->createModuleAdvanceStage($_uniqueid);
                    $updateColumns=array();
                    $updateValues=array();
                } elseif ($joincheckdup==true){ //在当前模块不重复，但在查重模块重复，无法覆盖
                    $xlsRowData=array();
                    $contact_xlsRowData=array();
                    $error .="第".$excelrow."行".$fieldlabel_dup_tip."在".getTranstab($joinmodule)."模块重复，覆盖失败!<br>";
                    $flag = false;
                }
            }

            if ( (empty($num_rows) && $joincheckdup==false )   || $num_rows< 1 || $import_type =='Insert') { //目前flag为false仅针对：联合查重模块重复，当前模块不重复的情况，此时不插入
                $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows']+1;
                $all_insert_value=[];
                foreach($xlsRowData as $main => $values_one){

                    foreach($values_one as $inert_tablename => $insert_files_values){
                        $st = array();
                        if(strtolower($inert_tablename)==strtolower($module_tablename)){
                            $k =array();
                            foreach($insert_files_values as $key => $value){
                                if(!empty($value)){
                                      $k[] = $key;
                                }
                            }

                            if(!in_array('smcreatorid',$k)){
                                $st['smcreatorid']=$smcreatorid;
                            }
                            if(!in_array('smownerid',$k)){
                                $st['smownerid']=$current_user->id;
                            }
                            if(!in_array('createdtime',$k)){
                                $st['createdtime']=date("Y-m-d H:i:s");
                            }
                            if(!in_array('modifiedtime',$k)){
                                $st['modifiedtime']=date("Y-m-d H:i:s");
                            }
                            if(!in_array('modifiedby',$k)){
                                $st['modifiedby']=$smcreatorid;
                            }
                            //BUG0059746 ls 20221209 导入->审批状态不填写时，新增单据时应该显示为“未提交”
                            if(array_key_exists('approvestatus',$insert_files_values) && !in_array('approvestatus',$k)){
                                $st['approvestatus']='未提交';
                            }
                            if(in_array('taxclass',$k)){
                                $sql = "insert into ld_producttaxrel(productid,taxid,taxpercentage)values(?,?,?);";
                                $adb->pquery($sql,array($uniqueid,1,$values['taxclass']));
                            }
                            if($import_module=='ServiceCharge') {
                                //037509: （1.6）服务收费管理导入错误。
                                $adb->pquery($sqlcrmentity,array($uniqueid,'Accounts'));
                            } else
                            {
                                file_put_contents("aa2.txt",$sqlcrmentity."\r\n",FILE_APPEND);

                                $adb->pquery($sqlcrmentity,array($uniqueid,$import_module));
                            }
                        }

                        $st['id']=$uniqueid;//获取crmid
                        $insert_value = array_merge($insert_files_values, $st);//拼接数组



                        if($importcolumnname_index['code_num']>=0&&$checkcodenum==''&&$inert_tablename==$focus->table_name) {
                            $insert_value[$code_num_columnname]=$focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name);
                            $focus->Library('SystemCode')->setModuleSeqNumber('increment',$currentModule);
                        } else  if($inert_tablename==$focus->table_name&&$code_num_columnname!=''&&($importcolumnname_index['code_num']<0)) {
                            //如果该模块有编号字段，但是导入的excel中没有编号，则编号应该取当前单据的ID
                            $insert_value=array_merge($insert_value,array($focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name)));
                            $focus->Library('SystemCode')->setModuleSeqNumber('increment',$currentModule);
                        } else if($inert_tablename==$focus->table_name) {//edit:can 20200820 新增行，要修改系统编号添加1
                            if($import_type=='Insert'&&$importcolumnname_index['code_num']>=0&&$checkcodenum!='') {
                                $sql=" select 1 from $maintable where $code_num_columnname=? and deleted=0 limit 1 ";
                                $result=$adb->pquery($sql,array($checkcodenum));
                                if($adb->num_rows($result)>0) {
                                    //edit:can 2020-10-30 43071: （https://61mis.com/kfbtest [^]）客户问题（邬丹华），数据模板中录入的合同编号重复，合同订单单据导入时，设置合同订单重复时导入方式为“追加”，导入成功后，单据编号应该为最大编号+1（需要补丁）
                                    $infos[$code_num_columnname]=$focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name);
                                }
                            }
                            //edit:can 20200820 新增行，要修改系统编号添加1
                            $focus->Library('SystemCode')->setModuleSeqNumber('increment',$currentModule);
                            if($importcolumnname_index['currency_id']<0&&$frommodule=='Potentials'&&$focus->fieldobj->getFieldInfoBykeyValue('columnname','currency_id','uitype')!='') {
                                $insert_value['currency_id']=1;
                            }
                        }
                        if($inert_tablename=='ld_producttaxrel') {
                            //edit:can 20210601 46131: （81mis.com/kfbcrm）产品管理-导入；导入模板中，含有销售税率，附加税等字段，导入时没有这些字段可选择进行映射
                            foreach($taxcolumn_arr as $taxcolumnname) {
                                $taxvalue=$insert_files_values[$taxcolumnname];
                                if(empty($taxvalue))
                                    continue;
                                preg_match_all('/\d+/',$taxcolumnname,$tmp_arr);//默认只到9，相信没有10以上的税率
                                $sql='select 1 from ld_producttaxrel where productid=? and taxid=? ';
                                $tax_result=$adb->pquery($sql,array($uniqueid, $tmp_arr[0][0]));
                                if($adb->num_rows($tax_result)<=0)
                                    $adb->pquery("insert into ld_producttaxrel(productid,taxid,taxpercentage)value(?,?,?) ",array($uniqueid, $tmp_arr[0][0],$insert_files_values[$taxcolumnname]));
                                else {
                                    $sql='update ld_producttaxrel set  taxpercentage=? where productid=? and taxid=? ';
                                    $adb->pquery($sql,array($insert_files_values[$taxcolumnname],$uniqueid,$tmp_arr[0][0]));
                                }
                            }
                        } else {

                            $adb->pquery($field_sql[$inert_tablename],array($insert_value));
                            $all_insert_value = array_merge($all_insert_value, $insert_value);
                        }

                        if($import_module=='Potentials'&&$inert_tablename=='ld_potential') {
                            $sql='update ld_potential set total=amount,subtotal=amount where potentialid=?';
                            $adb->pquery($sql,array($uniqueid));
                        }
                        if($currentModule == 'Contacts'&&$inert_tablename=='ld_contactscf'){	//帮我吧
                            //$cls_Bangwoba->setContactsToBangwoba($uniqueid,'edit');
                           $focus->SyncContactsToBangwoba($_uniqueid,'create');
                        }
                        //如果导入币种，则更新汇率和币种符号
                        if (array_key_exists("currency_id",$insert_files_values)){
                            if(!empty($insert_files_values['currency_id'])){
                                $currency_obj=new Currency($adb,$insert_files_values['currency_id']);
                                $insertid = $adb->getLastInsertID();
                                if(!empty($insertid)){
                                    $adb->pquery("update ".$focus->table_name." set currency_symbol = ?,conversion_rate=? where ".$focus->table_index." = ? ",
                                    array($currency_obj->getCurrencySymbol(),$currency_obj->getCurrencyRate(),$insertid));
                                }
                            }
                        }
                        //edit: xll 2023/08/17 BUG0071293 导入数据导致销售漏斗数据不对
                        $cls_module_advance->createModuleAdvanceStage($uniqueid);
                        $insert_value=array();
                    }
                    //wym 240429 XUQIU20240326-05 导入，增加触发工作流生效（苏宁）
                    if($trigger_workflow=='yes'){
                        $workflowreverseobj->setRecord($uniqueid);
                        $beforefieldvalue_arr=[];
                        $afterfieldvalue_arr=$all_insert_value;
                        $pagemode='creation';
                        if(!empty($afterfieldvalue_arr)){
                            $workflowreverseobj->setPageMode($pagemode);
                            $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);
                        }
                    }
                    $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']+1;
                }
            }
        }
    }
    if($import_module=='Calendar'){$import_module='Activity';}
    $accountfocus=new $import_module();
    $accountfocus->setFieldDefaultValue($insertIdArr,$import_module);
    $importdatainfo=$error;

    $tablescf=$focus->customFieldTable[0];
    $tablescfidname=$focus->customFieldTable[1];
    $maintable=$focus->table_name;
    $maintableindex=$focus->table_index;
    $_REQUEST['diony']='yes';
    include(globalStatic::$root_directory.'modules/XlsImportNew/ImportProgress.php');//进度条
    $addimportrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows'];
    $updateRows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows'];
    $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_error'].=$error;
    if($endrow>=$maxrows) {
        $sql="  insert into $tablescf($tablescfidname)   
        select $maintableindex from $maintable where $maintableindex not in(select $tablescfidname from $tablescf);";
        $result=$adb->pquery($sql,array());
        if($maintable=='ld_leads') {
            //edit:can 20230420 BUG0065194
            $sql='update ld_leads set pool_id=1 where   ifnull(publicaccount,0)>0 and ifnull(pool_id,0)=0' ;
            $result=$adb->pquery($sql,array());
        }
    }
    $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']=$maxrows;
    $tmp['timedescription']=$time_description;
    $tmp['cur_progress_step']=$cur_progress_step;
    $tmp['endimporttime']=$endimporttime;
    $tmp['endrow']=$endrow;
    ConvertTojsonString(1,$tmp,'success');
}
?>