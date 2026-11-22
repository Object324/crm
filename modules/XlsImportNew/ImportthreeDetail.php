<?php
global $currentModule;
global $current_user;
global $adb;
$_REQUEST['diony']='yes';
$filename=$_REQUEST['filename'];
$trade_info = getVersionTradeInfo();
if(empty($filename))
{
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
   //$tmp['canceltext']=getFixedLabel("ASTEP");
    
    ConvertTojsonString(1,$tmp,'success');
    
}

include(globalStatic::$root_directory.'modules/XlsImportNew/NewImportSModule.php');
include(globalStatic::$root_directory.'modules/XlsImportNew/NewImportCommon.php');
include globalStatic::$root_directory.'PHPExcel/PHPExcel/IOFactory.php';
 require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
  require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
$focus=CRMEntity::getInstance($currentModule);
$module_tablename=$focus->table_name;//单据主表
crm_load_class_file('cls_module_advance','modules/Settings');
$cls_module_advance = new cls_module_advance($currentModule);
$module_tableindex=$focus->table_index;
$tablescf=$focus->customFieldTable[0];
$tablescfidname=$focus->customFieldTable[1];
$module_tablename_scf =$focus->customFieldTable[0];//单据自定义表
$detailtable=$focus->Detail_table;
$detailtablescf=$focus->Detail_table_scf;

$profocus=CRMEntity::getInstance('Products');
import('data.Logic','class');
import('data.BaseLogic','class');
BaseLogic::$module=$currentModule;
 if(!file_exists(globalStatic::$root_directory.'modules/'.$currentModule.'/'.$currentModule.'Logic.class.php'))
 {
    $btnlogic=new BaseLogic();
 }
 else
 {
    require_once(globalStatic::$root_directory.'modules/'.$currentModule.'/'.$currentModule.'Logic.class.php');
    $cls=$currentModule.'Logic';
   	$btnlogic=new $cls();
 }
    
$smarty=new lingdangCRM_Smarty();
//导入数据
$allFieldOnly=array();//所有唯一字段
$error='';//错误信息
    //$mapfields=$_REQUEST['mapped_fields'];
$mapfields=json_decode($_REQUEST['mapped_fields']);//导入字段
$totalcolumns=sizeof($mapfields);//导入列数
    
$defaultvalue = json_decode($_REQUEST['defaultvalue']);//导入的字段名称对应值
//主表字段
$result=  $_SESSION['mainfield_'.$currentModule.'_'.$current_user->id];//数组
$producttoolresult=$_SESSION['detailfield_'.$currentModule.'_'.$current_user->id];//数组
    //$module_NO=$focus->fieldobj->getFieldInfoBykeyValue('uitype',4,'fieldname');
   
$importcolumn=array();
   //$field_tables=array();//主表导入字段
$field_tables[$module_tablename]=array();//主表导入字段
$field_columns_only=array();//唯一字段
$fieldonlyXlsIndex=0;//唯一字段在xls文件中列索引
$codeIndex=0;//编号在xls文件中列索引
$adjustmentIdex=-1;//"调整"列的在xlsRowData[$codenum][maintable][$module_tablename]索引
$ServiceContracts_discount_percentIndex=-1;//"整单折扣百分比"列的在xlsRowData[$codenum][maintable][$module_tablename]索引
$saleorder_discount_amountIndex=-1;//"整单直接降价"列的在xlsRowData[$codenum][maintable][$module_tablename]索引
$product_discount_percentIndex=-1;//产品明细中“折扣百分比"列的在xlsRowData[$codenum][inventoryproductrel][$detailtable]索引
$product_discount_amountIndex=-1;//产品明细中“直接降价"列的在xlsRowData[$codenum][inventoryproductrel][$detailtable]索引
$product_tax_amountIndex=-1;//产品明细中“价税合计"列的在xlsRowData[$codenum][inventoryproductrel][$detailtable]索引
$product_quantity_Index=-1;//产品数量所在列
$totalquantity=0;//数量合计列
crm_load_class_file('ProductToolFields','include/ProductDetails');
$detailfieldobj=ProductToolFields::getInstance($currentModule);
$code_num_columnname='';//编号字段名称
$importcolumnname_index=array('smownerid'=>-1,'smcreatorid'=>'-1','code_num'=>-1,'total'=>-1
            ,'currency_id'=>-1,'servicecontracts_start_date'=>-1
            ,'servicecontracts_end_date'=>-1,'entitytype'=>-1,'entitytypeid'=>-1);//导入字段在excel中的列位置,entitytype:目前是合同订单
$inventory_tables[$detailtable]=array();//产品明细表导入字段
$producttoolfield_tables[$detailtablescf]=array();//产品明细自定义表导入字段
$nohaveerror=true;
$fieldcolIndex=0;

$cachekey = 'importtabid_'.$moduleid;
$_REQUEST['product_importdupcheckfields']=$_REQUEST['detail_importdupcheckfields'];
$_REQUEST['product_importdupfields_condition']=$_REQUEST['detail_importdupfields_condition'];
$checkimportfield=implode(',',json_decode($_REQUEST['importdupcheckfields'],true));//查重字段

    $is_checkimportfield = explode(',',$checkimportfield);//将选中的查重字段转为数组
    $tmps=array();
    foreach($is_checkimportfield as $tmpindex=>$checkimportfieldname)
    {
       $tmps[]= $focus->fieldobj->getFieldInfoBykeyValue("fieldname",$checkimportfieldname,'columnname');
    }
    $is_checkimportfield=$tmps;
$importdupfields_condition=json_decode($_REQUEST['importdupfields_condition']);//查重字段条件
    
$conditionorlabel=getFixedLabel('OR');
$conditionandlabel=getFixedLabel('SEARCHAND');
for($i=0;$i<sizeof($is_checkimportfield);$i++)
{
         $fieldlabel=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$is_checkimportfield[$i],'fieldlabel');
        if($importdupfields_condition[$i]=='or')
            $conditionlabel=$conditionorlabel;
        else
            $conditionlabel=$conditionandlabel;
        if($i==sizeof($is_checkimportfield)-1)
        {
            $conditionlabel='';
        }
        $main_fieldlabel_dup_tip.='"'.$fieldlabel.'"'.$conditionlabel;
        
}
     $main_fieldlabel_dup_tip=trim($main_fieldlabel_dup_tip,$conditionlabel);
     $product_checkimportfield=implode(',',json_decode($_REQUEST['product_importdupcheckfields'],true));//查重字段
    $product_is_checkimportfield = explode(',',$product_checkimportfield);//将选中的产品明细查重字段转为数组
    $product_importdupfields_condition=json_decode($_REQUEST['product_importdupfields_condition'],true);//查重字段条件
     for($i=0;$i<sizeof($product_is_checkimportfield);$i++)
     {
         $fieldlabel=$profocus->fieldobj->getFieldInfoBykeyValue("columnname",$product_is_checkimportfield[$i],'fieldlabel');
        if($product_importdupfields_condition[$i]=='or')
            $conditionlabel=$conditionorlabel;
        else
            $conditionlabel=$conditionandlabel;
        $product_fieldlabel_dup_tip.='"'.$fieldlabel.'"'.$conditionlabel;
        
     }
    $product_fieldlabel_dup_tip=trim($product_fieldlabel_dup_tip,$conditionlabel);
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
         $tablename=$result[$i]['tablename'];
         $typeofdata=$result[$i]['typeofdata'];
         $fieldonly=$result[$i]['fieldonly'];//字段值是否唯一，1：唯一
         $fieldLabel=$result[$i]['fieldlabel'];
         $typedata=explode('~',$typeofdata);
        
         if($typedata[1]=='M'&&$uitype!=4&&$columnname!='currency_id')
         {
             
            if(!in_array($columnname.'-field',$mapfields))
            {
              
                 $error.='导入文件中缺少\''.$fieldLabel.'\'列<br>';
                 //break;
            }
         }
      
         
         if(in_array($columnname.'-field',$mapfields))
         {
             if($columnname=='entitytype'&&$currentModule=='SalesOrder')
                continue;
             $field_tables[$tablename][]=array($columnname,$uitype,$typeofdata,array_search($columnname.'-field',$mapfields),$fieldLabel);
             $fieldcolIndex=array_search($columnname.'-field',$mapfields);
             if($columnname=='smownerid')
                $importcolumnname_index['smownerid']=array_search($columnname.'-field',$mapfields);
             else if($columnname=='total')
             {
                $importcolumnname_index['total']=array_search($columnname.'-field',$mapfields);
             }
             else if($uitype==4)
             {
                
                $importcolumnname_index['code_num']=array_search($columnname.'-field',$mapfields);
             }
             else if($columnname=='currency_id')
             {
                $importcolumnname_index['currency_id']=array_search($columnname.'-field',$mapfields);
             }
             else if($uitype==208)
             {
                 $importcolumnname_index['entitytype']=array_search('entitytype-field',$mapfields);
                 $importcolumnname_index['entitytypeid']=array_search('quoteid-field',$mapfields);
             }
             else if($uitype==73)
             {
                $importcolumnname_index['accountid']=array_search($columnname.'-field',$mapfields);
             }
             else if($columnname==$focus->getCreateColumnName())
             {
                $importcolumnname_index['smcreatorid']=array_search($columnname.'-field',$mapfields);
             }

             if(!empty($checkPicklistColumn) && $uitype==15){ //当前模块设置了检查下拉框字段，并且该字段是下拉框类型
                 $selcol=$tablename.':'.$columnname;
                 if(in_array($selcol,$checkPicklistColumn)){ //当前字段是需要检查的下拉框字段
                     if(!isset($_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$columnname])) {
                         $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("columnname", $columnname);
                         if ($fieldinfo) {
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
    }
  
     if(in_array('discount_percent-'.$currentModule,$mapfields))
     {
         $ServiceContracts_discount_percentIndex=sizeof($field_tables[$module_tablename]);
        $field_tables[$module_tablename][]=array('discount_percent',1,'N~O',array_search('discount_percent-'.$currentModule,$mapfields));
       
     } 
     if(in_array('discount_amount-'.$currentModule,$mapfields))
     {/*
     整单折扣字段被载入2次bug:0012901
     */
         $saleorder_discount_amountIndex=sizeof($field_tables[$module_tablename]);
       // $field_tables[$module_tablename][]=array('discount_amount',1,'N~O',array_search('discount_amount-ServiceContracts',$mapfields));
     }     
     if(in_array('adjustment-'.$currentModule,$mapfields))
     {
        $adjustmentIdex=sizeof($field_tables[$module_tablename]);
     
        $field_tables[$module_tablename][]=array('adjustment',1,'N~O',array_search('adjustment-'.$currentModule,$mapfields));
     }
     
     $code_num_columnname=$focus->fieldobj->getFieldInfoBykeyValue("uitype",4,'columnname');
      

    //产品字段
     $product_result=$_SESSION['productfield_'.$currentModule.'_'.$current_user->id];//数组
   
     $product_tablename['ld_products']=array();//产品表导入字段
     //$productcf_tables['ld_productcf']=array();//产品自定义表导入字段
    $havecolums=array();

     for($i=0;$i<sizeof($product_result);$i++){
        $uitype=$product_result[$i]['uitype'];
        $columnname=$product_result[$i]['columnname'];
        if(in_array($columnname,$havecolums))
        {
            continue;
        }
        $havecolums[]=$columnname;
        $typeofdata=$product_result[$i]['typeofdata'];
        $fieldlabel=$product_result[$i]['fieldlabel'];
        $table_name=$product_result[$i]['tablename'];
        $typedata=explode('~',$typeofdata);
         
        if(in_array($columnname.'-products',$mapfields)){
            
            
            if($typedata[1]=='M'){
                $product_tablename[$table_name][]=array($columnname,$uitype,'V~M',array_search($columnname.'-products',$mapfields),$fieldlabel);
            }else{
                $product_tablename[$table_name][]=array($columnname,$uitype,'V~O',array_search($columnname.'-products',$mapfields),$fieldlabel);
            }
                
        }
        else
        {
            if($typedata[1]=='M')
            {
                //28113: 创彩账套（192.168.3.5:85/crm,6.6.5SP3）合同订单>导入：当导入文件中没有必填项产品列的时候，结果导入成功了
                 $error.='导入文件中缺少产品信息工具\''.$fieldlabel.'\'列<br>';
            }
        }
     
                 
        $importcolumnname_index[$columnname]=array_search($columnname.'-producttoolfield',$mapfields);
         if(!empty($checkPicklistColumn) && $uitype==15){ //当前模块设置了检查下拉框字段，并且该字段是下拉框类型
             $selcol=$tablename.':'.$columnname;
             if(in_array($selcol,$checkPicklistColumn)){ //当前字段是需要检查的下拉框字段
                 if(!isset($_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$columnname])) {
                     $fieldinfo = $focus->fieldobj->getFieldInfoobjBykey("columnname", $columnname);
                     if ($fieldinfo) {
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
     $importcolumnname_index['servicecontracts_start_date']=array_search('servicecontracts_start_date-producttoolfield',$mapfields);
     $importcolumnname_index['servicecontracts_end_date']=array_search('servicecontracts_end_date-producttoolfield',$mapfields);
    
  
     $productno_index=0;//产品编号列索引(在产品明细中的索引)

   for($i=0;$i<sizeof($producttoolresult);$i++)
    {
        
        $uitype=$producttoolresult[$i]['uitype'];
        $columnname=$producttoolresult[$i]['columnname'];
        $fieldlabel=$producttoolresult[$i]['fieldlabel'];
        $typeofdata=$producttoolresult[$i]['typeofdata'];
        $input_type=$producttoolresult[$i]['input_type'];
        $table_name=$producttoolresult[$i]['tablename'];
       
       
        $typedata=explode('~',$typeofdata);
         
         if($typedata[1]=='M'||$input_type==2)
         {
          
            if(!in_array($columnname.'-producttoolfield',$mapfields))
            {
                 $error.='导入文件中缺少产品信息工具\''.$fieldlabel.'\'列<br>';
                // break;
            }
            
            $fieldlabel.='*';
         }
         
         if(in_array($columnname.'-producttoolfield',$mapfields))
         {
             $producttoolfield_tables[$table_name][]=array($columnname,$uitype,$typeofdata, array_search($columnname.'-producttoolfield',$mapfields),$fieldlabel);
             if(!empty($checkPicklistColumn) && $uitype==60){ //当前模块设置了检查下拉框字段，并且该字段是下拉框类型
                 $selcol=$table_name.':'.$columnname;
                 if(in_array($selcol,$checkPicklistColumn)){ //当前字段是需要检查的下拉框字段
                     if(!isset($_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$columnname])) {
                         if ($focus->detailfieldobj) {
                             $fieldinfo = $focus->detailfieldobj->getFieldInfoobjBykey('columnname', $columnname);
                             if ($fieldinfo) {
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
         }
    }

  
    require_once('PHPExcel/PHPExcel/IOFactory.php') ;

   
    
    $highestRow=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestrow'];//获取行号数组
    $maxrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_maxrows'];
    $highestColumnIndex = $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_highestColumnIndex'];//总列数
    
   
    $failuredetailscount=0;//该行不导入，失败导入的明细数量
    if($error!='')
    {
      
        
         
            $false = true;
            $importdatainfo=$error;
            $smarty->assign('FALSE',$false);
            $smarty->assign("IMPORTINFO",$importdatainfo);
            $smarty->assign('TOTALROWS',(sizeof($highestRow)));
            $smarty->assign('SUCCESSROWS',0);
            $smarty->assign('ERRORROWS',sizeof($highestRow));
             $filehandler=fopen('storage/importlog_'.$currentModule.'_'.$current_user->id.'.txt','w+');
             fwrite($filehandler,str_replace('<br>',"\r\n",$error));
            fclose($filehandler);
           ConvertTojsonString('-1',array(),$error);
           
    }
    else
    {
       
       
        if(sizeof($highestRow)<2){
            $error .='模板文件中没有数据，导入失败！'.'<br>'; 
            
            $importdatainfo=$error;
            $false=true;
            $smarty->assign('FALSE',$false);
            $smarty->assign("IMPORTINFO",$importdatainfo);
            ConvertTojsonString('-1',array(),$error);
           
        }
       
        $xlsRowData=array();
       
        $nohaveerror=true;
        
        $hangshu=0;
     
         //拼接主表的导入sql脚本       
        $sqlcrmentity='insert into ld_crmentity(crmid,setype)values (?,?)';
        $insert_columname = array();
        $insert_values = array();
        //将所有的字段拼接到一个数组里面
        $insertfield = array_merge($field_tables,$inventory_tables);
        $newInsertfield=array_merge($insertfield,$product_tablename);
       
        $allinsertfield  = array_merge($newInsertfield,$producttoolfield_tables);      
     		
        //拼接sql插入语句
        foreach($allinsertfield as $tablename=>$colinfo)
        {
             if($tablename=='ld_crmentity'){
                continue;
             }
             foreach($colinfo as $ky=>$colnames)
             {
                $insert_columname[$tablename][] = $colnames[0];
             }
            if(strtolower($tablename)==$module_tablename){
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
               // if(!in_array('currency_symbol',$insert_columname[$tablename])){
                 //   $insert_columname[$tablename][] = 'currency_symbol';
                //}
                
                $insert_columname[$tablename][] = $focus->tab_name_index[$tablename];
             }
            if(strtolower($tablename)=='ld_products'){
               
                if(!in_array('smcreatorid',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'smcreatorid';
                }
                if(!in_array('smownerid',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'smownerid';
                }
                if(!in_array('productname',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'productname';
                }
                if(!in_array('createdtime',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'createdtime';
                }
                if(!in_array('modifiedtime',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'modifiedtime';
                }
                if(!in_array('discontinued',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'discontinued';
                }
                if(!in_array('product_no',$insert_columname[$tablename])){
                    $insert_columname[$tablename][] = 'product_no';
                }
                $insert_columname[$tablename][]='productid';
            }
			if(strtolower($tablename)=='ld_productcf'){
				$insert_columname[$tablename][]='productid';
			}
            if($tablename==$detailtable){
                $insert_columname[$tablename][]='productid';
                $insert_columname[$tablename][]='id';
                $insert_columname[$tablename][]='balancepurchasecount';//未采购
                $insert_columname[$tablename][]='balanceoutproductcount';//未出库
                $insert_columname[$tablename][]='balanceinvoicecount';//未开票金额
                $insert_columname[$tablename][]='sequence_no';//排序
            }
            if($tablename==$module_tablename_scf){
                $insert_columname[$tablename][] = $focus->tab_name_index[$module_tablename];
            }
            if($tablename==$detailtablescf)
            {
                $insert_columname[$tablename][]='lineitem_id';
            }         
             foreach($insert_columname as $tablename => $column_fields){
              
                  if($code_num_columnname!=''&&$importcolumnname_index['code_num']<=-1&&$tablename==$focus->table_name)
                  {
                    $field_sql[$tablename]=' insert into '.$tablename.'(' . implode(',',$column_fields). ','.$code_num_columnname.') values (' . generateQuestionMarks($column_fields).',?)' ;
                  }
                  else
                      $field_sql[$tablename]=' insert into '.$tablename.'(' . implode(',',$column_fields). ') values (' . generateQuestionMarks($column_fields).')' ;  
                     
             }
         }
            
        $product_detail_fields = array_merge($field_tables,$product_tablename,$producttoolfield_tables);
        /*导入定义*/
        $import_type = $_REQUEST['choose']; //获取重复时导入方式
       
        $_checkproducts = $product_is_checkimportfield; //获取产品明细表查重字段
        $smcreatorid=$current_user->id;
        $modifiedby=$smcreatorid;
        $createdtime=date("Y-m-d H:i:s");
        $modifiedtime=$createdtime;

        $sql_split=explode(',',$field_sql[$module_tablename]);
        //用于导入完成后，更新订单的合计等
        //$sqlupdate='update ld_servicecontracts set total=?,subtotal=?, discount_type=? where servicecontractsid=?';
       if($currentModule=='SalesOrder')
       {
           //zxm 全盛 用EXCEL表格导入合同订单，订单编号不用按以上规则生成，直接读取EXCEL表格中的编号即可
           if($trade_info['account']=='quansheng'){
               $sqlupdate='update '.$module_tablename.' set currency_symbol=?,total=?,subtotal=?,discount_type=?,totalquantity=?,triggercount=triggercount+1,automatic_numbering="no" where '.$focus->tab_name_index[$module_tablename].'=?';
           }else{
               $sqlupdate='update '.$module_tablename.' set currency_symbol=?,total=?,subtotal=?,discount_type=?,totalquantity=?,triggercount=triggercount+1 where '.$focus->tab_name_index[$module_tablename].'=?';
           }
       }
       else
       {
            $sqlupdate='update '.$module_tablename.' set currency_symbol=?,total=?,subtotal=?,discount_type=? where '.$focus->tab_name_index[$module_tablename].'=?';
       }

        $_checkproductsfield =$product_is_checkimportfield;
        $tmp_cur_row_end_line='no';
        $tmp_prouctDetail_row=0; 
        $product_same_salesorder='no';        
        
        $startrow=$_REQUEST['startrow'];
      
        $endrow=$_REQUEST['endrow'];
        $between_rows=$endrow-$startrow;//每次导入的行数（目前是5条,(0-4))
        $main_module_rows=0;//跨越的主表的行数
        $importdatas= $_SESSION['import_'.$currentModule.'_'.$current_user->id."_data"];//需要导入的数据
        $row=$startrow;
        
        $Importoop = new NewImport_Xls($importcolumnname_index,$currentModule);
        while(true){
            $hangshu++;
            $nohaveerror=true;
            $yijingtishi=true;
            //如果超过xls文件行数则退出循环
            
            if($row>=$maxrows){
             
                break;
            }
           
            if($main_module_rows>$between_rows)
            {
               
                $endrow=$row;//返回到前端，用于判断下次开始导入行数的标识
               
                break;
            }
            
            $excelrow=$row+2;
            if($product_same_salesorder=='no')
           {
            //一定要这样做，只有不为同一条单据才可以重新初始一下变量
                 $xlsRowData=array();
                $product_xlsRowData=array();
                $productid=array();
                 $nohaveerror=true;
                 $new1_service_base_contractstotal=0;
                $service_base_contractstotal=0;
                $service_contracttotal=0;
                $discount_type=0;
                $tax_discount_percent=0;
                $tax_discount_amount=0;
                $tax_adjustment=0;
                $tmp_prouctDetail_row=0;
           }
           
            $col=0;
            if($row+1>=$maxrows)
            {
             
                $tmp_cur_row_end_line='yes' ;
            }
         
            foreach($product_detail_fields as $tablename => $colinfo){
                 $startdate="";
                 $enddate="";
               
                foreach($colinfo as $ky=>$colnames){
                    $columnname=$colnames[0];

                    $typedata=explode('~',$colnames[2]);
                    $fieldcolIndex=$colnames[3];
                    $fieldLabel=$colnames[4];
                    
                    $str=trim((string)$importdatas[$row][$fieldcolIndex]);
                    
                    if($fieldcolIndex==$importcolumnname_index['total'])
                    {
                        //有合计列
                        $service_contracttotal=$str;
                        
                    }
                    $next_row_str='';
                    if($fieldcolIndex==$importcolumnname_index['code_num'])
                    {
                        $checkcodenum=$str;
                    }
                    if(in_array($columnname,$is_checkimportfield)){
                          
                          $_checkValues[$columnname] = $str;
                           if($tmp_cur_row_end_line=='no'){//如果不是最后一行则获取下一行数据，
                             $next_checkValues[$columnname]=trim((string)$importdatas[$row+1][$fieldcolIndex]);
                           }
                    }
  
                    //$str=addslashes($str);
                    //获取用户的lastname
                    $uname =$current_user->last_name;
                    //为空时获取默认值
                    if($str==''){
                        if(in_array($colnames[0].'-field',$mapfields)&&in_array($tablename,$focus->tab_name)){
                            $tmpcolumnindex = array_search($colnames[0].'-field',$mapfields);
                            $str=trim($defaultvalue[$tmpcolumnindex]);
                        }
                    }
                 
                    if($tablename==$detailtable){
                        if($colnames[0]=='tax_amount'){
                            $product_tax_amountIndex=$product_formula_index;
                            if(!empty($str))//价税合计
                                $tmpsubtotal+=$str;
                        }
                        if($colnames[0]=='quantity'){
                            $product_quantity_Index=$product_formula_index;
                            if(!empty($str))//价税合计
                                $totalquantity+=$str;
                        }
                        if($colnames[0]=='discount_percent'){
                            $product_discount_percentIndex=$product_formula_index;
                        }
                        if($colnames[0]=='discount_amount'){
                            $product_discount_amountIndex=$product_formula_index;
                        }
                       
                    }
                    //日期类型
                    if($typedata[0]=='D'){
                        
                        if($str ==''){
                            $str=NULL;
                        }else{
                           
                             if(sizeof(explode('/',$str))<2 &&sizeof(explode('-',$str))<2)
                             {
                                            if(sizeof(explode('.',$str))==3)
                                            {
                                                $datastrs=explode('.',$str);
                                                if(strlen($datastrs[0])<4)
                                                {
                                                    $datastrs[0]="20".$datastrs[0];
                                                }
                                                $str=$datastrs[0].'-'.$datastrs[1].'-'.$datastrs[2];
                                                
                                            }
                                            else
                                            $str= date('Y-m-d',(PHPExcel_Shared_Date::ExcelToPHP($str)));  
                             }
                             else if(sizeof(explode('/',$str))==3)
                             {
                                             $datastrs=explode('/',$str);
                                             if(strlen($datastrs[2])==4)
                                             {
                                                $str=$datastrs[2].'-'.$datastrs[1].'-'.$datastrs[0];
                                                
                                             }
                             }
                                     
                        }  
                    }
                    if($typedata[0]=='T'){
                        if($str==''){
                            $str=NULL;
                        }else{
                            $str=date('H:i:s',PHPExcel_Shared_Date::ExcelToPHP($str));   
                        }  
                    }
                    //日期时间类型
                    if($typedata[0]=='DT'){
                        if($str ==''){
                            $str=NULL;
                        }else{
                             if(sizeof(explode('/',$str))<2 &&sizeof(explode('-',$str))<2)
                             {
                                            if(sizeof(explode('.',$str))==3)
                                            {
                                                $datastrs=explode('.',$str);
                                                if(strlen($datastrs[0])<4)
                                                {
                                                    $datastrs[0]="20".$datastrs[0];
                                                }
                                                $str=$datastrs[0].'-'.$datastrs[1].'-'.$datastrs[2];
                                                
                                            }
                                            else
                                            $str= date('Y-m-d H:i:s',(PHPExcel_Shared_Date::ExcelToPHP($str)));  
                             }
                             else if(sizeof(explode('/',$str))==3)
                             {
                                             $datastrs=explode('/',$str);
                                             if(strlen($datastrs[2])==4)
                                             {
                                                $str=$datastrs[2].'-'.$datastrs[1].'-'.$datastrs[0];
                                                
                                             }
                             }     
                        }    
                    }
				
                    if($typedata[0]=='N'&&$str!=''&&!is_numeric($str)){
						//$str= $objWorksheet->getCellByColumnAndRow($fieldcolIndex, $row)->getCalculatedValue();
						if(!is_numeric($str)){
							$error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列内容为非法数字!<br>';
							$nohaveerror=false;
						}
                    }
                       
                    if($typedata[0]=='N'&&$str==''){
                        $str=NULL;
                    }  
                    if($typedata[0]=='NN'&&$str==''){
                        $str=NULL;
                    }
					//BUG:0027800
                   
                    if($colnames[1]!=117&&$typedata[1]=='M'&&$str==''&&$columnname!='productname'&&$fieldcolIndex!=$importcolumnname_index['code_num']){
                      
                        $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列值不能为空!<br>';
                       // $row++;
                        $nohaveerror=false;
                    }
                    
                    
                    if($fieldcolIndex==$importcolumnname_index['servicecontracts_start_date'])
                    {
                            $startdate=$str;
                          
                    }    
                   
                    if($fieldcolIndex==$importcolumnname_index['servicecontracts_end_date'])
                    {
                        $enddate=$str;
                    }
                     if($colnames[1]==117 ){
                            $currency_id=1;
                                $checkvalue=array_keys($app_currency_strings,$str);
                                 
                            if($checkvalue[0]==''){
                                $checkvalue[0]=$str;
                            }
                            if( $checkvalue[0]!="")
                            {
                                $sqlfield='select id,currency_symbol,conversion_rate from ld_currency_info where currency_name=\''.$checkvalue[0].'\' order by id desc limit 0,1';                                                  
                                $fieldResult=$adb->pquery($sqlfield,array());
                            }
                            else
                            {
                                //37266: （1.6）合同订单模块列表界面>更多>导入>导出模板：导出的模板中缺少了币种字段。（需要补丁）
                                $sqlfield='select id,currency_symbol,conversion_rate from ld_currency_info where id=? order by id desc limit 0,1';                                                  
                                $fieldResult=$adb->pquery($sqlfield,array(1));
                            }
                            
                                if($adb->num_rows($fieldResult)>0){
                                    $arraycurrency[0]['currency_id']=$adb->query_result($fieldResult,0,'id'); 
                                   
                                    $arraycurrency[0]['currency_symbol']=$adb->query_result($fieldResult,0,'currency_symbol');   
                                    $arraycurrency[0]['conversion_rate']=$adb->query_result($fieldResult,0,'conversion_rate');                                   
                                }else{
                                    //edit:can 2020-09-16 42677: （61mis.com/kfbtest）销售管理-合同订单-更多-导入；进行导入表格后，若表格中的币种 系统未设置，币种为空
                                    $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列值在数据库中不存在!<br>';
                                    $str=''; 
                                    $nohaveerror=false;
                                }
                               
                            
                        }
                        $tmpentitytype='';
                        $tmpentitytypeid=0;
                      
                    if(array_key_exists($tablename,$focus->tab_name_index)  && $str !=''){
                        if($colnames[1]==117 ){
                           
                              
                                
                            
                        }
                        else{
                           
                            //获取相关信息id
                            //获取相关信息id
                           
                            if($colnames[1]=='208')
                            {
                             
                               if($importcolumnname_index['entitypeid']>0&&$importcolumnname_index['entitytype']<=0)
                               {
                                   $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$importcolumnname_index['entitytype']].'"列不存在!<br>';
                                   $nohaveerror=false;
                               } 
                               else
                               {
                                    $tmpentitytype=trim((string)$importdatas[$row][$importcolumnname_index['entitytype']]);
                                    $str=trim((string)$importdatas[$row][$importcolumnname_index['entitytypeid']]);
                                  
                                   $sourInformation=getProducts_entitytypeid($str,$tmpentitytype,$currentModule);
                                   $tmpentitytype=$sourInformation['name'];
                                   $tmpentitytypeid=$sourInformation['id'];
                                 
                                   
                                   if($tmpentitytypeid<=0)
                                   {
                                    $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$importcolumnname_index['entitytypeid']].'"列值不存在!<br>';
                                    $nohaveerror=false;
                                   }
                                   else
                                   {
                                    $str=$tmpentitytypeid;
                                    
                                   }
                                    
                                }
                            }
                            else{

								$str = $Importoop->setImprtNameToId($colnames[1],$str,$row);//获取相关信息id
							}
                            $bigtype=$focus->fieldobj->getFieldInfoBykeyValue("columnname",$colnames[0],'bigtype');
                            if((($str==""&&$Importoop->import_nouitype=='yes') ||
                                        (empty($str)&&$Importoop->import_nouitype=='no'))
                                        && $typedata[1]=='M'){
                                if($Importoop->haveerrormsg()){
                                    $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"'.$Importoop->getouterrormsg().'<br>';
                                }
                                else {
                                    $error .= '第' . $excelrow . '行"' . $_SESSION['import_' . $currentModule . '_' . $current_user->id . '_excelfieldlabel'][$fieldcolIndex] . '"列值在数据库中不存在!<br>';
                                }
                                $nohaveerror=false;
                            }
                        }
                               
                    }else{
						
					}
                    if($colnames[1]=='1600'){ //通过用户字段值获取成员所属部门
                        $str = $Importoop->getvaluebyfields($colnames,$str,$product_detail_fields,$importdatas[$row]);
                    }
                    if(array_key_exists($colnames[0],$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'])){ //XUQIU20240402-03 导入，增加“导入控制”，可设置校验下拉框字段
                        if(!empty($str)  && !in_array($str,$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist'][$colnames[0]])){ //检查导入值是否是下拉框选项
                            $error.='第'.$excelrow.'行"'.$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列值为空或在数据库中不存在!<br>';
                            $nohaveerror=false;
                        }
                    }
                    if(isProductTable($tablename)){//判断是否是产品明细
						if($detailtable == $tablename){
							$fieldinfo=$detailfieldobj->getFieldInfoobjBykey('columnname',$colnames[0]);
							if(!empty($fieldinfo)){
								$str = $Importoop->setImprtNameToId_details($fieldinfo,$str,$row);//获取相关信息id
							}
						}
                        $product_xlsRowData[$tmp_prouctDetail_row][$tablename][$colnames[0]]=vtlib_purify($str);            
                    }
                    elseif($product_same_salesorder=='no'){//&& strtolower($typedata[0]) !='i'
                  
                         $xlsRowData[0][$tablename][$colnames[0]]=vtlib_purify($str);
                    }
                }
              
                if(!empty($startdate)&&!empty($enddate)&&$startdate>$enddate)
                    {
                        //33943: （1.6登录）服务合同模块：导入模板中输入的服务开始日大于服务到期日时导入，导入成功了
                        
                           $startlabel=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$importcolumnname_index['servicecontracts_start_date']];
                           $enddlabel=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$importcolumnname_index['servicecontracts_end_date']];
                            $error.='第'.$excelrow.'行'.$startlabel."列值应该小于等于$enddlabel 列值!".'<br>';
                            $nohaveerror=false;
                    }
            }
               
            //模块若设置了没有工商信息不允许导入，则查询工商信息是否存在
            crm_load_class_file('cls_BusinessInformation', 'modules/Users');
            $businessinformationobj = cls_BusinessInformation::getInstance($frommodule);
            if($businessinformationobj->IsEnableBusiness()){
                if($businessinformationobj->IsNoBusinessnoimport()&&!empty($xlsRowData['maintable']))
                {
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
                    if($businesimport == 'no')
                    {
                        $company_name_columnname = $businessinformationobj->getModuleBusinessQueryField('columnname');
                        $company_name = $requestvalues_arr[$company_name_columnname];
                        $error .="第".$excelrow."行".$company_name."工商信息不存在！"."<br>";
                        $nohaveerror=false;
                    }
                }
            }
                
            
            $product_same_salesorder='yes';//判断明细是否为统一单据，yes:是,no:不是
            if((is_array($is_checkimportfield)&&empty($is_checkimportfield[0]))||empty($is_checkimportfield))
            {
                $product_same_salesorder='no';
                
            }
            
            $conditionindex=0;
          
          
            foreach($_checkValues as $check_column =>$cur_value)
            {
                //比较当前行和下一行数据查重字段的值是否相同，或下一行主表查重字段是否为空
                
                
                if($cur_value!=$next_checkValues[$check_column]&&$next_checkValues[$check_column]!=''&&($importdupfields_condition[$conditionindex]=='and'||empty($importdupfields_condition[$conditionindex])))
                {
                    $product_same_salesorder='no';
                     break;
                }
                else if(($importdupfields_condition[$conditionindex]=='or' || empty($importdupfields_condition[$conditionindex]))&&$cur_value==$next_checkValues[$check_column]&&$next_checkValues[$check_column]!='')
                {
                    $product_same_salesorder='yes';
                    break;
                }
                else  if($cur_value!=$next_checkValues[$check_column]&&$next_checkValues[$check_column]!=''&&($importdupfields_condition[$conditionindex]=='or' || empty($importdupfields_condition[$conditionindex])))
                {
                    $product_same_salesorder='no';
                   
                }
                $conditionindex++;
            }
             if($product_same_salesorder=='no'||$tmp_cur_row_end_line=='yes'){
         
          
           
                $main_module_rows++;
                if($tmp_cur_row_end_line=='yes')
                {
                    $endrow=$maxrows;
                    
                }
                if($nohaveerror==false){
                    $row++;
                    $_SESSION['import_'.$currentModule.'_'.$current_user->id."_shijidaorurows"]=$_SESSION['import_'.$currentModule.'_'.$current_user->id."_shijidaorurows"]+1;
                  $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']+1;
                   $xlsRowData=array();
                   $nohaveerror=true;
                    continue;
                }
            }
            
        
            if($product_same_salesorder=='no'||$tmp_cur_row_end_line=='yes'){//如果当前行数据和下一行数据不相同或当前行为excel最后一行
               $_SESSION['import_'.$currentModule.'_'.$current_user->id."_shijidaorurows"]=$_SESSION['import_'.$currentModule.'_'.$current_user->id."_shijidaorurows"]+1;
                $k=0;
                $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']+1;
                $flag = true; //主表重复，为false时，不插入明细表
                $service_base_contractstotal=0; //合同的合计(不包含调整金额、整单折扣金额)
  
            
                if($importcolumnname_index['total']<0)
                        $service_contracttotal=0;//总计：合计金额+调整金额+整单折扣
                $subtotal=$tmpsubtotal;
              
                $tmpsubtotal=0;
                $tax_adjustment=$xlsRowData[0][$module_tablename]['adjustment'];//获取调整金额，调整金额是放在主表中的
                $tax_discount_percent=$xlsRowData[0][$module_tablename]['discount_percent'];//获取折扣百分比
                $tax_discount_amount=$xlsRowData[0][$module_tablename]['discount_amount'];//获取折扣直接降价
                
                if($importcolumnname_index['currency_id']<0)
                {
                    //37266: （1.6）合同订单模块列表界面>更多>导入>导出模板：导出的模板中缺少了币种字段。（需要补丁）
                    $currency_id=1;
                }
                else
                {
                    $currency_id=$xlsRowData[0][$module_tablename]['currency_id'];//获取货币id
                    if(empty($currency_id))
                    {
                        $currency_id=1;
                    }
                }
                $temp=array();
                $uniqueid=array();
                $invenValues=array();
                $_checkCondition=array();
                $_accountid=$xlsRowData[0]['ld_servicecontracts']['accountid'];
                $main_column_is_not_exit=array();

               $_checkdupValues=array();
              
                if($import_type!="Insert"){ //查重判断
                    $_checkdupColumn=array();//不要等于array,如果等于arra()且查重字段的值为空会有bug
                    foreach($xlsRowData[0] as $maintable=>$infos){
                            $temp[$maintable] =$infos;
                        }
                        
                        foreach($is_checkimportfield as $index=>$checkField)
                        {
                                $tmp_tablename=$focus->fieldobj->getFieldInfoBykeyValue("fieldname",$checkField,'tablename');
                           
                                $infos=$xlsRowData[0][$tmp_tablename];
                                if($infos[$checkField]!='')
                                {
                                    $_checkdupColumn[]=$checkField;
                                    $_checkdupValues[$checkField] = $infos[$checkField];
                                    
                                    if($index==sizeof($is_checkimportfield)-2)//判断查重字段最后一个字段是否有值
                                      {
                                        $importfieldobj= $focus->fieldobj->getFieldInfoobjBykey('columnname',$is_checkimportfield[$index+1]);
                                        $importcolumntablename=$importfieldobj->getTableName();//获取查重字段所在表
                                        if($xlsRowData[0][$importcolumntablename][$is_checkimportfield[$index+1]]!='')
                                          {
                                           
                                             $_checkCondition[$checkField]=$importdupfields_condition[array_search($checkField,$is_checkimportfield)];
                                          }
                                           
                                        else
                                            break;
                                      }
                                      else
                                      {
                                        
                                         $_checkCondition[$checkField]=$importdupfields_condition[array_search($checkField,$is_checkimportfield)];
                                      }
                                  
                                     //$_checkCondition[$checkField]=$importdupfields_condition[array_search($checkField,$is_checkimportfield)];
                                }
                        }
                      
                        if(sizeof($_checkdupColumn)>0&&is_array($_checkdupColumn)&&!empty($_checkdupColumn[0]))
                        {
                            //进行查重
                                $main_table_sql = 'SELECT ser.'.$focus->tab_name_index[$module_tablename].' as id from '.$module_tablename.' ser LEFT JOIN
                                '.$module_tablename_scf.' scf on ser.'.$focus->tab_name_index[$module_tablename] .' =scf.'.$focus->tab_name_index[$module_tablename].'';
                                $main_table_sql .=" where ("; 
                                $dupcheckfield_len=sizeof($_checkdupColumn);
                            
                                 foreach($_checkdupColumn as $tmp_dupcheckfield=>$tmp_columnname)
                                {
                                    $main_table_sql.= "  $tmp_columnname= ?  ";
                                    if($_checkCondition[$tmp_columnname]!=""&&$tmp_dupcheckfield!=$dupcheckfield_len-1)
                                    {
                                        $main_table_sql.=$_checkCondition[$tmp_columnname];
                                    }
                                }
                                $main_table_sql.=" ) ";
                                $main_table_sql.=" and deleted=0";
                             
                            
                             
                                $check_result = $adb->pquery($main_table_sql,array($_checkdupValues));
                                $num_rows = $adb->num_rows($check_result);
                                if($num_rows>0){
                                    for($i=0;$i<$num_rows;$i++){
                                        $uniqueid[$i]=$adb->query_result($check_result,$i,'id');
                                    }
                                }  
                        }
                        else
                        {
                            $num_rows=0;
                        }
                                           
                    
                }
                $update_uniqueid=$uniqueid;//需要更新的数据
                   //dump($uniqueid);
				/*product_import_type 	产品不存在时导入方式对应的处理方式
				* NoImportRow：该行不导入  NoImportData：整单不导入  AddProduct：自动添加新产品
				*/
               
				if(!empty($_REQUEST['product_import_type']) && ($_REQUEST['product_import_type'] == 'NoImportData' || $_REQUEST['product_import_type'] == 'NoImportRow')){
				//	$db_product_num = 0;
					//$no_product_row = 0;	//产品不存在行
                    $no_product_rows=array();//产品不存在行
                    $no_product_values=array();//产品不存在列值数组
                    $tmpmaysaveproducts=array();//可以保存到数据库产品临时数据
					foreach($product_xlsRowData as $productData =>$productColumn){//行循环
					  
						foreach($productColumn as $productTablename =>$product_Values){//表循环
						   $_checkimportfieldValues=array();
							if($productTablename=='ld_products'){//先判断产品是否存在
								$productno = $product_Values['product_no'];
								$productname = $product_Values['productname'];

								if($productname==''){                
									$productname=$productno;
								}
								$_product_checkcolumns=array();//不要等于array,如果等于arra()且查重字段的值为空会有bug
								$product_where='';
								if(!empty($_checkproducts)){//产品查重字段不为空的情况下
									foreach($_checkproducts as $index=>$product_key_column )
									{
										if($product_Values[$product_key_column]!='')
										{
											$_product_checkcolumns[]=$product_key_column;
											$_checkimportfieldColumn[$product_key_column] = $product_key_column;
											$_checkimportfieldValues[$product_key_column] = $product_Values[$product_key_column];
											$product_checkCondition[$product_key_column]=$product_importdupfields_condition[array_search($product_key_column,$product_is_checkimportfield)];
										}
									}
									$dupcheckfield_len=sizeof($_product_checkcolumns);
                                    //获取产品的id
                                    $product_sql = 'select productid as productid from ld_products ';
									if(sizeof($dupcheckfield_len)>0&&is_array($_product_checkcolumns)&&$_product_checkcolumns[0]!="")
									{
										foreach($_product_checkcolumns as $index=>$tmp_columnname)
										{
											$product_tablename=$profocus->fieldobj->getFieldInfoBykeyValue('columnname',$tmp_columnname,'tablename');
											if($product_tablename!='ld_products')
											{
												$leftjoin_producttablename=$product_tablename;

											}
											$product_where.= "  $tmp_columnname= ?  ";
											if($product_checkCondition[$tmp_columnname]!=""&&$index!=$dupcheckfield_len-1)
											{
												$product_where.=$product_checkCondition[$tmp_columnname];
											}
										}
										if($leftjoin_producttablename!='')
										{
											$product_sql.=' left join '.$leftjoin_producttablename.' on '.$leftjoin_producttablename.'.productid=ld_products.productid';
										}
										$product_sql .=" where ( "; 
										$product_sql.=$product_where;
										$product_sql.=" ) ";
										$product_sql.=" and deleted=0";
										$product_result=$adb->pquery($product_sql,array($_checkimportfieldValues));
										$product_num=$adb->num_rows($product_result);
										if($product_num >= 1){
											$db_product_num++;
                                            $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successdetailscount']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successdetailscount']+1;//该行不导入，成功导入的明细数量;
                                            
                                            $tmpmaysaveproducts[]=$productColumn;
										}else{
											
											$no_product_row = $row - sizeOf($product_xlsRowData) + 1 + $productData;
											
                                            $no_product_rows[]=$no_product_row;
                                            $no_product_values[]=$_checkimportfieldValues;
                                            if($_REQUEST['product_import_type'] == 'NoImportData')
                                            {
                                                $tmpmaysaveproducts=array();
                                                break;
                                            }
                                            
										}
									}
									else
									{
										
									}
								}
							}
						}
					}
                  $product_xlsRowData=$tmpmaysaveproducts;
                  
				//整单不导入,该行不导入
					if($_REQUEST['product_import_type'] == 'NoImportData'||$_REQUEST['product_import_type'] == 'NoImportRow'){
		              
                        
                        foreach($no_product_rows as $tmpindex=> $no_product_rowindex)
                        {
                            if(empty($no_product_rowindex) && $no_product_rowindex != 0)
                            {
                                break;
                            }
                            $tips="";
                            foreach($no_product_values[$tmpindex] as $tmpcolumnname=>$cellvalue)
                            {
                                
                                $fieldlabel=$profocus->fieldobj->getFieldInfoBykeyValue("columnname",$tmpcolumnname,"fieldlabel");
                                $tips.=$fieldlabel.":".$cellvalue;
                                if($product_checkCondition[$tmpcolumnname]=='and'){
                                    $tips.="和";
                                }
                                else  if($product_checkCondition[$tmpcolumnname]=='or')
                                {
                                    $tips.="或";
                                }
                            }
                            if($_REQUEST['product_import_type'] == 'NoImportData')
                       	    {
                       	        $error .="第".($no_product_rowindex+2)."行 $tips 在数据中不存在，已跳过整个单据!"."<br>";
                                 $flag=false;
                       	    }
                            else
                       	    {
                       	        //$failuredetailscount++;
                                $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_failuredetailscount']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_failuredetailscount']+1;
                                
                       	        $error .="第".($no_product_rowindex+2)."行 $tips 产品在数据中不存在，该行单据不导入!"."<br>";
                   	        }
						
                           	
                        }
					}
                
					 
				}    
                
                    if($num_rows>0 && ($import_type=='Update' || $import_type=='UpdateAll') && $flag == true){ //获取重复的单据id
                      $updateColumns=array();
                      $updateValues=array();
                        $focus->getModuleStatic('ModTracker');
                        foreach($temp as $infoTablename =>$info_values){ //
                            foreach($info_values as $infoKey =>$new_info_values){
                                if (in_array($infoKey,array('approvestatus','createdtime'))) {//覆盖及覆盖(全部)时， 审批状态、创建时间不允许覆盖。
                                    continue;
                                }
                                if($new_info_values!='' && $infoKey !=$focus->tab_name_index[$module_tablename]){//排除导入文件中为空的数据
                                    $updateColumns[$infoTablename][$infoKey] = $infoKey;
                                    $updateValues[$infoTablename][$infoKey] = $new_info_values;
                                }
                            }

                        }
                        if($num_rows>0)//一定要加$num_rows>0的判断
                        {
                            //zkt 20220511 51548（http://121.36.206.222:85/muse/index.php）合同订单》导入，查重“合同编号”“产品编号”，导入方式为覆盖；导入后，弹窗信息没显示导入成功/失败，单据信息也没被覆盖
    					   //全部为覆盖且，全部导入失败时提示信息错误，没有导入失败的提示
    						//$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']+1;
                        }
                        $uniqueid=array();
                       
                         for($i=0;$i<$num_rows;$i++){
                             $_uniqueid=$adb->query_result($check_result,$i,'id');
                             $focus->id=$_uniqueid;
                             $focus->retrieve_entity_info($focus->id,$currentModule);
                             if ($import_type=='Update') {
                                 $btnlogic->controller=$focus;
                                 $editbutton=$btnlogic->getEditViewBtn();
                                 if($editbutton['permit']!='yes')
                                 {

                                     //是否有该单据的编辑权限
                                     if($btnlogic->edit_errorreason['reason']=='approve')
                                     {
                                         $error.='第'.$excelrow.'行单据'.$btnlogic->edit_errorreason['description'].'，不允许覆盖！<br>';

                                     }
                                     else
                                     {
                                         $error.='第'.$excelrow.'行无编辑权限，不允许覆盖！<br>';
                                     }
                                     continue;

                                 }
                             }

                                 $uniqueid[]=$_uniqueid;//插入明细要用的主表id
                                 $focus->modstatic->init($focus,$focus->module_name);//记录覆盖导入日志
                                $all_update_value=[];
                                foreach($updateColumns as $updateTablename => $updatecolumnnames){
                                    
                                    foreach($updatecolumnnames as $updatecolumn)
                                    {
                                        
                                        if(!empty($updateValues[$updateTablename][$updatecolumn]))//等于零不考虑了
                                        {
                                         
                                             //要判断日期字段类型,1600-01-01
                                             if(in_array($updateTablename,$focus->tab_name))
                                             {
                                                    $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey('columnname',$updatecolumn);
                                             }
                                             else
                                             {
                                                  $fieldinfo=$detailfieldobj->getFieldInfoobjBykey('columnname',$updatecolumn);
                                             }
                                             if(!$fieldinfo)
                                             {
                                                continue;
                                             }
                                            
                                            $query = 'update ' . $updateTablename . ' set ' . $updatecolumn . '=? where ' . $focus->tab_name_index[$updateTablename] . ' ='.$_uniqueid;
                                              
                                           
                                             $adb->pquery($query,array($updateValues[$updateTablename][$updatecolumn]));   
                                        }
                                         
                                    }

                                    //edit: xll 2023/08/17 BUG0071293 导入数据导致销售漏斗数据不对
                                    $cls_module_advance->createModuleAdvanceStage($_uniqueid);
                                  
                                    //先删除重复合同的产品明细
                                    $query_delete = "DELETE $detailtable,$detailtablescf FROM $detailtable
                                    LEFT JOIN $detailtablescf ON $detailtable.lineitem_id = $detailtablescf.lineitem_id
                                    where $detailtable.id =".$_uniqueid;
                                    $adb->pquery($query_delete,array());
                                    $all_update_value=array_merge($all_update_value,$updateValues[$updateTablename]);
                                }
                                 //wym 240429 XUQIU20240326-05 导入，增加触发工作流生效（苏宁）
                                 if($trigger_workflow=='yes'){
                                     $workflowreverseobj->setRecord($_uniqueid);
                                     $beforefieldvalue_arr=$focus->column_fields;
                                     $afterfieldvalue_arr=$all_update_value;
                                     $pagemode='updated';
                                     if(!empty($afterfieldvalue_arr)){
                                         $workflowreverseobj->setPageMode($pagemode);
                                         $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);
                                     }
                                 }
                                if($tmpentitytypeid>0&&$tmpentitytype!='')
                                {
                                    $sql='update '.$focus->table_name.' set quoteid=? where '.$focus->table_index.'=?';
                                    $adb->pquery($sql,array($tmpentitytypeid,$_uniqueid));
                                }
                             $focus->modstatic->saveOperationLog($focus->module_name,$focus->id,'IMPORT',$import_type);
                                 $focus->modstatic->triggerEvent($focus->module_name);
                           
                                 $_SESSION['import_'.$currentModule.'_'.$current_user->id."_updaterows"]=$_SESSION['import_'.$currentModule.'_'.$current_user->id."_updaterows"]+1;
                        }
                        
                    }   
                    
                    if((empty($num_rows) || $import_type=='Insert')  && $flag == true){
                        $_uniqueid = $adb->getUniqueID('ld_crmentity');
                        $uniqueid[] = $_uniqueid;
                        $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']+1;
                        $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows']+1;
                        
                        $adb->pquery($sqlcrmentity,array($_uniqueid,$currentModule));
                        foreach($xlsRowData[0] as $maintable=>$infos){
                            
                            if($maintable==$module_tablename){
                                foreach($infos as $key =>$values){
                                    $main_column_is_not_exit[]=$key;
                                }
                                if(!in_array('smcreatorid',$main_column_is_not_exit) || $infos['smcreatorid']==''){
                                    $infos['smcreatorid']=$smcreatorid;
                                }
                                if(!in_array('smownerid',$main_column_is_not_exit)||$infos['smownerid']==''){
                                    $infos['smownerid']=$current_user->id;
                               }
                                if(!in_array('createdtime',$main_column_is_not_exit) || $infos['createdtime']==''){
                                    $infos['createdtime']=date("Y-m-d H:i:s");
                                }
                                if(!in_array('modifiedtime',$main_column_is_not_exit) || $infos['modifiedtime']==''){
                                    $infos['modifiedtime']=date("Y-m-d H:i:s");
                                }
                                if(array_key_exists('approvestatus',$infos) && (!in_array('approvestatus',$main_column_is_not_exit) || $infos['approvestatus']=='')){
                                    $infos['approvestatus']='未提交';
                                }
                                /*if(!in_array('currency_symbol',$main_column_is_not_exit) || $infos['modifiedtime']==''){
                                    if(empty($infos['currency_id']))$infos['currency_id']=1;
                                    $currencyobj=Currency::getInstance($adb,$infos['currency_id']);
                                    $infos['currency_symbol']=$currencyobj->getCurrencyRate();
                                }*/
                                
                               
                            }
                            
                            $infos[$currentModule.'id']=$_uniqueid;
                     
                            if($importcolumnname_index['code_num']>=0&&$checkcodenum==''&&$maintable==$focus->table_name)
                            {
                               
                                $infos[$code_num_columnname]=$focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name);
                                $focus->Library('SystemCode')->setModuleSeqNumber('increment',$currentModule);
                            }
                            else if($maintable==$focus->table_name&&$code_num_columnname!=''&&$importcolumnname_index['code_num']<=-1)
                            {
                                
                                //如果该模块有编号字段，但是导入的excel中没有编号，则编号应该取当前单据的ID
                                
                                if(array_key_exists($code_num_columnname,$infos))
                                {
                                    $infos[$code_num_columnname]=$focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name);
                                  
                                    $focus->Library('SystemCode')->setModuleSeqNumber('increment',$currentModule);
                                }
                                else
                                {
                                    $infos=array_merge($infos,array($_uniqueid));
                                    $focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name);
                                    $focus->Library('SystemCode')->setModuleSeqNumber('increment',$currentModule);
                                     
                                }
                                
                            }
                            else if($maintable==$focus->table_name)
                            {
                                //edit:can 20200820 新增行，要修改系统编号添加1
                                    if($import_type=='Insert'&&$importcolumnname_index['code_num']>=0&&$checkcodenum!='')
                                   {
                                        $sql=" select 1 from $maintable where $code_num_columnname=? and deleted=0 limit 1 ";
                                        $result=$adb->pquery($sql,array($checkcodenum));
                                        if($adb->num_rows($result)>0)
                                        {
                                            
                                            //edit:can 2020-10-30 43071: （https://61mis.com/kfbtest [^]）客户问题（邬丹华），数据模板中录入的合同编号重复，合同订单单据导入时，设置合同订单重复时导入方式为“追加”，导入成功后，单据编号应该为最大编号+1（需要补丁）
                                            $infos[$code_num_columnname]=$focus->Library('SystemCode')->getModuleSeqNumRecord($focus->module_name);
                                           
                                        }
                                   }
                                $focus->Library('SystemCode')->setModuleSeqNumber('increment',$currentModule);
                            }
                          
                           $adb->pquery($field_sql[$maintable],array($infos));
                           $cls_module_advance->createModuleAdvanceStage($_uniqueid);
                            if($maintable&&$focus->table_name&&$tmpentitytypeid>0&&$tmpentitytype!='')
                            {
                                $sql='update '.$focus->table_name.' set quoteid=? where '.$focus->table_index.'=?';
                                $adb->pquery($sql,array($tmpentitytypeid,$_uniqueid                             ));
                            }
                            //wym 240429 XUQIU20240326-05 导入，增加触发工作流生效（苏宁）
                            if($trigger_workflow=='yes'){
                                $workflowreverseobj->setRecord($_uniqueid);
                                $beforefieldvalue_arr=[];
                                $afterfieldvalue_arr=$infos;
                                $pagemode='creation';
                                if(!empty($afterfieldvalue_arr)){
                                    $workflowreverseobj->setPageMode($pagemode);
                                    $workflowreverseobj->getStartComputer($beforefieldvalue_arr,$afterfieldvalue_arr,$pagemode);
                                }
                            }
                            $main_column_is_not_exit=array();
                            $xlsRowData=array();
                        }
                    }
                    if($num_rows>0 && $import_type=='Abort' && $flag == true){
                        $xlsRowData=array();
                        $product_xlsRowData=array();
                        $error .="第".$excelrow."行$main_fieldlabel_dup_tip 重复，已做跳过处理!"."<br>";
                        $flag = false;
                    }
                    if($flag==true){
                         
                        if(sizeOf($productid) <=0 )$productid = '';
                        //开始导入产品明细表
                        $product_total_index=0;
                      
                        foreach($product_xlsRowData as $productData =>$productColumn){
                            $o=0;//32956: 采购询价单导入：导入文件中一对多数据，设置产品管理不存在时导入方式选择“不导入该行”，结果导入后产品名称是空白的
                            
                            $iscontinueproductdetail='yes';
							$productid = array();
                          
                            foreach($productColumn as $productTablename =>$product_Values){//表循环
                                  $_checkimportfieldValues=array();
                                    if($productTablename=='ld_products'){//先判断产品是否存在
                                        $productno = $product_Values['product_no'];
                                        $productname = $product_Values['productname'];
                                        
                                        if($productname==''){                
                                            $productname=$productno;
                                        }
                                       $_product_checkcolumns=array();//不要等于array,如果等于arra()且查重字段的值为空会有bug
                                       $product_where='';
                                    
                                        if(!empty($_checkproducts)){//产品查重字段不为空的情况下
                                           foreach($_checkproducts as $index=>$product_key_column )
                                           {
											   $tmpfieldinfo=$profocus->fieldobj->getFieldInfoobjBykey("columnname",$product_key_column);
											   $tmptablename=$tmpfieldinfo->getTableName();
                                                if($productColumn[$tmptablename][$product_key_column]!='')
                                                {
                                                    $_product_checkcolumns[]=$product_key_column;
                                                    $_checkimportfieldColumn[$product_key_column] = $product_key_column;
                                                    $_checkimportfieldValues[$product_key_column] = $productColumn[$tmptablename][$product_key_column];
                                                    $product_checkCondition[$product_key_column]=$product_importdupfields_condition[array_search($product_key_column,$product_is_checkimportfield)];
                                                }
                                            
                                           }
                                      
                                           $dupcheckfield_len=sizeof($_product_checkcolumns);
                                          
                                            //获取产品的id
                                            $product_sql = 'select ld_products.productid as productid from ld_products ';
                                            //27059: 合同订单>导入：设置的查重字段对应的表格里的值为空时，导入报错
                                            if($dupcheckfield_len>0&&is_array($_product_checkcolumns)&&$_product_checkcolumns[0]!="")
                                            {
                                                  foreach($_product_checkcolumns as $index=>$tmp_columnname)
                                                    {
                                                        
                                                        $product_tablename=$profocus->fieldobj->getFieldInfoBykeyValue('columnname',$tmp_columnname,'tablename');
                                                        if($product_tablename!='ld_products')
                                                        {
                                                            $leftjoin_producttablename=$product_tablename;
                                                            
                                                        }
                                                        $product_where.= "  $tmp_columnname= ?  ";
                                                        if($product_checkCondition[$tmp_columnname]!=""&&$index!=$dupcheckfield_len-1)
                                                        {
                                                            $product_where.=$product_checkCondition[$tmp_columnname];
                                                        }
                                                    }
                                                    if($leftjoin_producttablename!='')
                                                    {
                                                        $product_sql.=' left join '.$leftjoin_producttablename.' on '.$leftjoin_producttablename.'.productid=ld_products.productid';
                                                        
                                                    }
                                                    $product_sql .=" where ( "; 
                                                    $product_sql.=$product_where;
                                                    $product_sql.=" ) ";
                                                    $product_sql.=" and deleted=0";
                                                    $product_result=$adb->pquery($product_sql,array($_checkimportfieldValues));
                                                    $product_num=$adb->num_rows($product_result);
                                                    if($currentModule=='CustomForm37')
                                                    {
                                                       // echo $product_sql;
                                                       // dump($_checkimportfieldValues);
                                                    }
                                            }
                                            else
                                            {
                                                $product_num=0;
                                            }
                                           
                                        }
										//if($currentModule=='CustomForm37')
											//	dump('sssa'.$product_num);
                                        if($product_num>0){//大于0，表示存在产品，直接获取产品id即可
                                                
                                                $productid[]=$adb->query_result($product_result,0,0);

                                        }else{//导入的产品不存在，需要导入产品
											if(!empty($_REQUEST['product_import_type']) && $_REQUEST['product_import_type'] == 'AddProduct'){
                                                $profocus->Library('SystemCode')->setModuleSeqNumber("increment", 'Products');
                                                $product_id=$adb->getUniqueID('ld_crmentity');
                                                $productid[]=$product_id;
                                                
                                                $column_is_not_exit=array();//原来获取所有的columnname，后面原来判断部分字段在导入文件中是否存在
                                                foreach($product_Values as $key =>$productslFieldValues){
                                                    $products_fieldValuess[$key]=$productslFieldValues;
                                                    $column_is_not_exit[]=$key;
                                                }
                                                
                                                if(!in_array('smcreatorid',$column_is_not_exit)){
                                                    $products_fieldValuess['smcreatorid']=$smcreatorid;
                                                }
                                                if(!in_array('smownerid',$column_is_not_exit)){
                                                    $products_fieldValuess['smownerid']=$smcreatorid;
                                                }
                                                if(!in_array('productname',$column_is_not_exit) || $products_fieldValuess['productname']==''){
                                                    $products_fieldValuess['productname']=$productname;
                                                }
                                                if(!in_array('createdtime',$column_is_not_exit)){
                                                    $products_fieldValuess['createdtime']=date("Y-m-d H:i:s");
                                                }
                                                if(!in_array('modifiedtime',$column_is_not_exit)){
                                                    $products_fieldValuess['modifiedtime']=date("Y-m-d H:i:s");
                                                }
                                                if(!in_array('discontinued',$column_is_not_exit)){
                                                    $products_fieldValuess['discontinued']=0;
                                                }
                                                if(!in_array('product_no',$column_is_not_exit)||$products_fieldValuess['product_no']==''){
                                                    //0028901: 合同订单：导入，导入文件中的产品名称系统中不存在时，导入后，生成的产品单据的编号没有自动生成
                                                    $products_fieldValuess['product_no']=SystemCode::getPrevStr("Products",$product_id).$product_id;
                                                }
                                                $products_fieldValuess['productid']=$product_id;
                                                $adb->pquery($sqlcrmentity,array($product_id,'Products'));
                                                $adb->pquery($field_sql[$productTablename],array($products_fieldValuess));
												//ld_productcf 信息导入
												if(!empty($product_id) && !empty($productColumn['ld_productcf']) && $field_sql['ld_productcf']){
													$productcfFieldValuess = array();
													foreach($productColumn['ld_productcf'] as $key =>$productcfFieldValues){
														$productcfFieldValuess[$key]=$productcfFieldValues;
													}
													$productcfFieldValuess[] = $product_id;
													$adb->pquery($field_sql['ld_productcf'],$productcfFieldValuess);
												}
												
                                                $sql='update ld_modentity_num set cur_id=cur_id+1 where semodule=?';
                                                $adb->pquery($sql,array('Products'));
                                                $products_fieldValuess=array();     
											}else if(!empty($_REQUEST['product_import_type']) && $_REQUEST['product_import_type'] == 'NoImportRow'){
												$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successrows']-1;
                                                //032956: 采购询价单导入：导入文件中一对多数据，设置产品管理不存在时导入方式选择“不导入该行”，结果导入后产品名称是空白的
												$error .="第".$excelrow-sizeof($product_xlsRowData)+$product_total_index."行产品在数据中不存在，已做跳过处理!"."<br>";
                                                $iscontinueproductdetail='no';
                                                break;
											}
                                        }
                                    }
                               if(($productTablename==$detailtable&&array_key_exists($detailtable,$productColumn))
								   ||($productTablename==$detailtablescf&&!array_key_exists($detailtable,$productColumn))
										){ 
                                    for($i=0;$i<sizeOf($uniqueid);$i++){
                                        $invenValues=$productColumn[$detailtable];
										if($productid[$o] > 0){
											$invenValues['productid']=$productid[$o];
											$invenValues['id']=$uniqueid[$i];
											$invenValues['balancepurchasecount']=$invenValues['quantity'];
											$invenValues['balanceoutproductcount']=$invenValues['quantity'];
											$invenValues['balanceinvoicecount']=$invenValues['quantity'];
								            $invenValues['sequence_no']=$product_total_index+1;
                                            $kh[$product_total_index] = $invenValues['tax_amount'];
											$adb->pquery($field_sql[$detailtable],array($invenValues));
									 
										  
											$lineitem_id=$adb->getLastInsertID(); 
											
											$invenValuescf=$productColumn[$detailtablescf];
											if(is_array($invenValuescf)&&sizeof($invenValuescf)>0)
											{
												 $adb->pquery($field_sql[$detailtablescf],array($invenValuescf,$lineitem_id));
											}
											else
											 $adb->pquery($field_sql[$detailtablescf],array($lineitem_id));
											
											if(!empty($_accountid)){//bug:0024435: 服务收费管理>列表：导入的服务合同，数据分类基本查询为服务合同—服务到期日，今天，结果：列表中不显示导入的数据。
												$sql1='SELECT 1 from ld_maxservicedate where productid=? and accountid=? AND inventoryid=?;';
												$sql1_result=$adb->pquery($sql1,array($productid[$productData],$_accountid,$uniqueid[$i]));
												$sql1_num=$adb->num_rows($sql1_result);
												if($sql1_num > 0){
													$sql2 = '
															SELECT MAX(servicecontracts_end_date) as servicecontracts_end_date from ld_servicecontractsdetail
															LEFT JOIN ld_servicecontracts on ld_servicecontractsdetail.id=ld_servicecontracts.servicecontractsid
															where productid=? AND ld_servicecontracts.accountid=?';
															$sql2_result=$adb->pquery($sql2,array($productid[$productData],$_accountid));
															
															$servicecontracts_end_date = $adb->query_result($sql2_result,0,'servicecontracts_end_date');
															
															$sql3 = 'update ld_maxservicedate set service_enddate=? where productid=? and accountid=?;';
															$adb->pquery($sql3,array($servicecontracts_end_date,$productid[$productData],$_accountid));
															
												}else{
														$sql = 'insert into ld_maxservicedate(inventoryid,productid,accountid,service_enddate)VALUES(?,?,?,?);';
														$adb->pquery($sql,array($uniqueid[$i],$productid[$productData],$_accountid,$invenValues['servicecontracts_end_date']));
												}
											}
											$k++;
											
										   $invenValues=array();
										}
                                    }
                                    $o++;
                                    $product_total_index++;
                                }                          
                            }
                        }
                          
                }
                
              
            if($flag==true){//没有导入产品的情况下，不需要进行合计
                //计算合计
        
                foreach($kh as $key =>$hejijine){
                    $service_base_contractstotal +=$hejijine;
                }
                 
                $kh=array();
                
                //导入数据后，计算合计
              
                foreach($arraycurrency as $key=>$currencyarr){
                    if($uniqueid!=''){
                        $updatecurrencysql = 'update '.$module_tablename.' set currency_id=?, conversion_rate=?,currency_symbol=? where '.$focus->tab_name_index[$module_tablename].' in('.implode(',',$uniqueid).')';
                        $adb->pquery($updatecurrencysql,array($currencyarr['currency_id'],$currencyarr['conversion_rate'],decode_html($currencyarr['currency_symbol'])));
                    }
                }
    
                if(empty($tax_adjustment) || $tax_adjustment==0){
                    $tax_adjustment=0;
                }
                if(empty($tax_discount_amount) || $tax_discount_amount==0){
                    $tax_discount_amount=0;
                }
    
                if(empty($tax_discount_percent) || $tax_discount_percent==0){
                    $new_tax_discount_percent=0;
                    $discount_type=0;
                }else{
                    $discount_type=1;
                    $zhehoujiage = $service_base_contractstotal*($tax_discount_percent/100);
                    $new_tax_discount_percent = $service_base_contractstotal-($service_base_contractstotal/$tax_discount_percent);
                    $service_base_contractstotal =$new_tax_discount_percent;
                }
              //  $arraycurrency[0]['currency_id']=$adb->query_result($fieldResult,0,'id'); 
                                   
              $currency_id_fuhao  =$arraycurrency[0]['currency_symbol'];
              $conversion_rate=$arraycurrency[0]['conversion_rate'];
           
                
                
                if($importcolumnname_index['total']<0||$service_contracttotal=='')
                {
                    
                    //导入文件没有合计列,或合计列只为空
                    $service_contracttotal +=$service_base_contractstotal+($tax_adjustment+$tax_discount_amount);
                }
               if(!$focus->modstatic)
               {
                $focus->getModuleStatic('ModTracker');
               }
                if(is_array($uniqueid)){
                    if($currentModule=='SalesOrder')
                       {
                             foreach($uniqueid as $tmpid)
                             {
                                 $sql='select total,subtotal from '.$focus->table_name.' where '.$focus->tab_name_index[$module_tablename].'=?';
                                $result=$adb->pquery($sql,array($tmpid));
                                $prevtotal=$adb->query_result($result,0,'total');
                                $prevsubtotal=$adb->query_result($result,0,'subtotal');
                                //zxm 全盛 用EXCEL表格导入合同订单，订单编号不用按以上规则生成，直接读取EXCEL表格中的编号即可
                                 $quansheng_sql= ' ';
                                if($trade_info['account']=='quansheng'){
                                    $quansheng_sql = ' ,automatic_numbering="no" ';
                                }
                                 $new_sqlupdate='update '.$module_tablename.' set currency_symbol=?,conversion_rate=?,total=?,subtotal=?,discount_type=?,totalquantity=?,triggercount=triggercount+1 '.$quansheng_sql.'
                                 where '.$focus->tab_name_index[$module_tablename].'=?';
                                 $adb->pquery($new_sqlupdate,array($currency_id_fuhao,$conversion_rate,$service_contracttotal,$subtotal, $discount_type,$totalquantity,$tmpid)); //如查重后，有多个合同的情况下，更新合同的合计金额
                                   //echo $new_sqlupdate;
                                 //dump(  array($currency_id_fuhao,$conversion_rate,$service_contracttotal,$subtotal, $discount_type,$totalquantity,$tmpid));
                                  $fieldname=$focus->fieldobj->getFieldInfoBykeyValue("columnname",'total','fieldname');
                                   if(!empty($fieldname))
                                        $focus->modstatic->saveFieldLogOne($frommodule,$fieldname,$tmpid,$prevtotal,$service_contracttotal);
                                    $fieldname=$focus->fieldobj->getFieldInfoBykeyValue("columnname",'subtotal','fieldname');
                                    if(!empty($fieldname))
                                            $focus->modstatic->saveFieldLogOne($frommodule,$fieldname,$tmpid,$prevsubtotal,$service_contracttotal);
                                            
                                    //更新对应客户最新进度和最新联系日期，销售机会最新联系日期
                                   $tmpupdatefocus = CRMEntity::getInstance($currentModule);
                                   $tmpupdatefocus->retrieve_entity_info($tmpid,$currentModule);
                                   $tmpaccountids = [];
                                   $tmppotentialids = [];
                                   if (!empty($tmpupdatefocus->column_fields['account_id']))
                                        $tmpaccountids[$tmpupdatefocus->column_fields['account_id']] = $tmpupdatefocus->column_fields['account_id'];
                                    if (sizeof($tmpaccountids) > 0) {
                                        $tmpupdatefocus->updateRelatedTableInfo('ld_account', $tmpaccountids);
                                    }
                                    if (!empty($tmpupdatefocus->column_fields['potential_id']))
                                        $tmppotentialids[$tmpupdatefocus->column_fields['potential_id']] = $tmpupdatefocus->column_fields['potential_id'];
                            
                                    if (sizeof($tmppotentialids) > 0) {
                                        $tmpupdatefocus->updateRelatedTableInfo('ld_potential', $tmppotentialids);
                                    }
                             }
                       }
                       else
                       {
                            foreach( $uniqueid as $tmpid)
                            {
                                $sql='select total,subtotal from '.$focus->table_name.' where '.$focus->tab_name_index[$module_tablename].'=?';
                                $result=$adb->pquery($sql,array($tmpid));
                                $prevtotal=$adb->query_result($result,0,'total');
                                $prevsubtotal=$adb->query_result($result,0,'subtotal');
                                
                                 $new_sqlupdate='update '.$module_tablename.' set currency_symbol=?,conversion_rate=?,total=?,subtotal=?,discount_type=? where '.$focus->tab_name_index[$module_tablename].'=?';
                                 $adb->pquery($new_sqlupdate,array($currency_id_fuhao,$conversion_rate,$service_contracttotal,$subtotal,$discount_type,$tmpid)); //如查重后，有多个合同的情况下，更新合同的合计金额
                               
                                $fieldname=$focus->fieldobj->getFieldInfoBykeyValue("columnname",'total','fieldname');
                               if(!empty($fieldname))
                                    $focus->modstatic->saveFieldLogOne($frommodule,$fieldname,$tmpid,$prevtotal,$service_contracttotal);
                                $fieldname=$focus->fieldobj->getFieldInfoBykeyValue("columnname",'subtotal','fieldname');
                                if(!empty($fieldname))
                                        $focus->modstatic->saveFieldLogOne($frommodule,$fieldname,$tmpid,$prevsubtotal,$service_contracttotal);
                                
                            }
                       }
                       if($currentModule=='Potentials')
                       {
                        $sql='update ld_potential set amount=total where potentialid in(  '.implode(',',$uniqueid).' ) ';
                         $adb->pquery($sql,array());
                       }
                        
                }else{
                         $sql='select total,subtotal from '.$focus->table_name.' where '.$focus->tab_name_index[$module_tablename].'=?';
                        $result=$adb->pquery($sql,array($uniqueid));
                        $prevtotal=$adb->query_result($result,0,'total');
                        $prevsubtotal=$adb->query_result($result,0,'subtotal');
                     if($currentModule=='SalesOrder')
                       {
                            $adb->pquery($sqlupdate,array($currency_id_fuhao,$service_contracttotal,$subtotal,$discount_type,$totalquantity,$uniqueid)); //更新合同的合计金额
                        }
                        else
                        {
                            $adb->pquery($sqlupdate,array($currency_id_fuhao,$service_contracttotal,$subtotal,$discount_type,$uniqueid)); //更新合同的合计金额
                        }
                       
                         if(!empty($fieldname))               
                                $focus->modstatic->saveFieldLogOne($frommodule,$fieldname,$uniqueid,$prevtotal,$service_contracttotal);
                         $fieldname=$focus->fieldobj->getFieldInfoBykeyValue("columnname",'subtotal','fieldname');
                         if(!empty($fieldname))
                                 $focus->modstatic->saveFieldLogOne($frommodule,$fieldname,$uniqueid,$prevsubtotal,$service_contracttotal);
                       if($currentModule=='Potentials')
                       {
                            $sql='update ld_potential set amount=total where potentialid ='.$uniqueid;
                            $adb->pquery($sql,array());
                       }
                } 
                
                $totalquantity=0;
            } 
                
            }
                $tmp_prouctDetail_row++;
                
                $row++;
               
        }
         
            $endrow=$row;//明细的行数不是固定的。
           include(globalStatic::$root_directory.'modules/XlsImportNew/ImportProgress.php');
            $addimportrows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_addimportrows'];
            $updateRows=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_updaterows'];
            /*if($endrow>=$maxrows&&($addimportrows>0||$updateRows>0))
            {
                
                $sql='update ld_modentity_num set cur_id=LPAD((cur_id+?),LENGTH(cur_id),"0") where semodule=? and active=1;';
                if(strtolower($import_type)=='insert'||strtolower($import_type)=='abort')
                    $adb->pquery($sql,array($addimportrows,$currentModule));
                else
                    $adb->pquery($sql,array($updateRows,$currentModule));
            }*/
            if(is_array($update_uniqueid)&&$update_uniqueid[0]>0){
                crm_load_class_file('cls_OptionModule','include/OptionModule');
               
                
               $OptionModuleobj= cls_OptionModule::getInstance($currentModule,0);
               $tmpmoudles= $OptionModuleobj->getHavecurModule_SourceModule();//获取源单包含当前导入模块的其他模块
               foreach($tmpmoudles as $tmpmodule){
                     if(get_file_address($tmpmodule,"ProductDetails")){
                         $tmpfocus=CRMEntity::getInstance($tmpmodule);
                         $tmp_detailtable=$tmpfocus->Detail_table;
                         $tmpsql="update $tmp_detailtable inner join $module_tablename on 
                            $module_tablename.$module_tableindex=$tmp_detailtable.entitytypeid
                            and $tmp_detailtable.entitytype='$currentModule'
                              inner join $detailtable on $detailtable.productid=$tmp_detailtable.productid
                              set  $tmp_detailtable.parent_lineitem_id=$detailtable.lineitem_id
                              where  $tmp_detailtable.entitytypeid in (".implode(",",$update_uniqueid).")
                                and   $detailtable.id  in (".implode(",",$update_uniqueid).")";
                          
                            $adb->pquery($tmpsql,array());
                         
                     }
               }
                
            }
          
            $_SESSION['import_'.$currentModule.'_'.$current_user->id."_error"]=$_SESSION['import_'.$currentModule.'_'.$current_user->id."_error"].$error;
            if($endrow>=$maxrows)
            {
                $sql="  insert into $tablescf($tablescfidname)   
                select $module_tableindex from $module_tablename where $module_tableindex not in(select $tablescfidname from $tablescf)
                and $module_tablename.deleted=0 ;";
               $result=$adb->pquery($sql,array());
              
              
                
                
            }

            $smarty->assign("PRODUCTIMPORTYPE",$_REQUEST['product_import_type']);
            $smarty->assign("SUCCESSDETAILSCOUNT",$successdetailscount);
            $smarty->assign("FAILUREDETAILSCOUNT",$failuredetailscount);
            $tmp['timedescription']=$time_description;
            $tmp['cur_progress_step']=$cur_progress_step;
            $tmp['endimporttime']=$endimporttime;
            $tmp['endrow']=$endrow-1;
          
            ConvertTojsonString(1,$tmp,'success');

    }
?>