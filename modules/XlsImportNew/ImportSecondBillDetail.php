<?php
global $currentModule;
global $adb;
global $current_user;



$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel']=array();
$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_picklist']=array();
require('user_privileges/user_language_'.$current_user->id.'.php');
$currentModule=$_REQUEST['frommodule'];

$focus=CRMEntity::getInstance($currentModule);
$module_tablename=$focus->table_name;//单据主表
$module_tablename_scf =$focus->customFieldTable[0];//单据自定义表
$detailtable=$focus->Detail_table;
$detailtablescf=$focus->Detail_table_scf;
$profocus=CRMEntity::getInstance('Products');
$moduleid=getTabid($currentModule);
$_REQUEST['diony']='yes';
$tmp['title']=getFixedLabel("IMPORT").$arr['modulelabel'];
$tmp['canceltext']=getFixedLabel("NEXT");
$tmp['oktext']=getFixedLabel("ASTEP");
$filename=$_REQUEST['filename'];
$filetype =pathinfo($filename, PATHINFO_EXTENSION);//获取导入文件的后缀名

$smarty=new lingdangCRM_Smarty();
$arr['modulelabel']=gettranstab($frommodule);
$arr['dupfieldlabel']=getFixedLabel('CHECKIMPORTFIELD');//查重字段
$arr['fileuploadlabel']=getFixedLabel('FILEUPLOAD');//上传文档
$arr['mappingfieldlabel']=getFixedLabel('MAPPINGFIELD');//映射字段
$arr['importdatalabel']=getFixedLabel('IMPORTDATATTITLE');//导入数据
$arr['finishedlabel']=getFixedLabel('TEMPLATECOMPLETE');//完成
$smarty->assign("ARRLABEL",$arr);

if($filetype=='xlsx'){$inputFileType = 'Excel2007';} else{$inputFileType = 'Excel5';}
$inputFileName = "storage/".$filename;

//zkt 获取源单类型，用于收付款单判断源单类型，若含有源单类型使用产品分录即withdetail=yes，则显示设置产品管理不存在时导入方式
$sourcemodule_arr = getSourceModule($frommodule);
$productdetailcount = 0;
foreach($sourcemodule_arr as $sourcemoduleinfo)
{
    if($sourcemoduleinfo['withdetail'] == 'yes')
    {
        $productdetailcount++;
    }
}
 //产品名称字段
$sql='SELECT DISTINCT
	ld_producttoolfield.uitype AS uitype,
	ld_field.typeofdata,
	ld_producttoolfield.fieldlabel AS fieldlabel,
	ld_producttoolfield.columnname AS columnname,
	ld_producttoolfield.tablename AS tablename
    FROM
    	ld_producttoolfield
    inner join ld_field on ld_producttoolfield.tablename=ld_field.tablename and ld_producttoolfield.columnname=ld_field.columnname
    WHERE
    	(ld_field.tablename =? or ld_field.tablename=?)
    AND ld_producttoolfield.tabid =?
    and ld_field.savedatabase="yes"
    AND ld_producttoolfield.presence <> 1 and ld_field.uitype not in(69,1109)  and ld_field .tabid=14';
    $proresult=$adb->pquery($sql,array('ld_products','ld_productcf',$moduleid));
    $proresult_nums=$adb->num_rows($proresult); 
$sql1="SELECT ld_tranlabel.fieldlabel,typeofdata,fieldtype,columnname,input_type,ld_tabdetailfield.tablename,ld_tabdetailfield.newline
            FROM ld_tabdetailfield INNER JOIN ld_tranlabel ON ld_tranlabel.relateid = ld_tabdetailfield.tabdetailfieldid
            WHERE ld_tranlabel.languagetype =?
            AND trantable =?
            AND presence IN (0, 2)
            AND ld_tabdetailfield.tabid =?
			AND ld_tabdetailfield.columnname not in('source_total','received_amount')
             and ld_tabdetailfield.newline<>1
            ORDER BY sequence ";
$params1 = array($languageType,'ld_tabdetailfield',$moduleid);
$sql2 = "select ld_tranlabel.fieldlabel,typeofdata,uitype,columnname,input_type,ld_producttoolfield.tablename,ld_producttoolfield.newline
    from ld_producttoolfield
    inner join ld_tranlabel on ld_tranlabel.relateid=ld_producttoolfield.producttoolfieldid
      where ld_tranlabel.languagetype=? and trantable=? and presence in(0,2)and 
       ld_producttoolfield.tabid=? and ld_producttoolfield.savedatabase='yes' and (ld_producttoolfield.tablename=? or ld_producttoolfield.tablename=? ) AND ld_producttoolfield.savedatabase = 'yes'  ORDER BY sequence";
$params2 = array($languageType,'ld_producttoolfield',$moduleid,$detailtable,$detailtablescf);

if(empty($productdetailcount)){
    $sql="select * from (".$sql1.") as tmpdetailtab";
    $params = $params1;
}
else if($productdetailcount>0 &&$productdetailcount == sizeof($sourcemodule_arr)){
    $sql="select * from (".$sql2.") as tmpdetailtab ";
    $params = $params2;
}
else{
    $sql="select * from ((".$sql1.") union all (".$sql2.")) as tmpdetailtab ";
    $params = array($languageType,'ld_tabdetailfield',$moduleid,$languageType,'ld_producttoolfield',$moduleid,$detailtable,$detailtablescf);
}
$sql .= ' group by tmpdetailtab.columnname '; 
$producttoolresult=$adb->pquery($sql,$params);

//主表
$sql='select blocktran.fieldlabel as blocklabel,fieldtran.fieldlabel,ld_field.typeofdata,ld_field.uitype,ld_field.columnname,tablename ,fieldonly
      from ld_field  inner join ld_blocks on ld_blocks.blockid=ld_field.block 
    inner join ld_tranlabel as fieldtran on ld_field.fieldid=fieldtran.relateid 
    inner join ld_tranlabel as blocktran on blocktran.relateid=ld_blocks.blockid 
    where (fieldtran.languagetype=? and fieldtran.trantable=? and fieldtran.tabid=?) 
    and (blocktran.languagetype=? and blocktran.trantable=? and blocktran.tabid=?) 
     and presence in(0,2)   and ld_blocks.visible=0 and ld_field.columnname not in("subtotal")  
    order by ld_blocks.sequence, ld_field.sequence  ';
$result=$adb->pquery($sql,array($languageType,'ld_field',$moduleid,$languageType,'ld_blocks',$moduleid));

$defaultvalueHtml='';
$importcolumn=array();
$drophtml=array();
$sessionMainfield=array();
$importcolumn[]=array(0,'none-field','--无--');
for($i=0;$i<$adb->num_rows($result);$i++)
{
     $uitype=$adb->query_result($result,$i,'uitype');
     $columnname=$adb->query_result($result,$i,'columnname');
     $fieldLabel=($adb->query_result($result,$i,'fieldlabel'));
     $typeofdata=$adb->query_result($result,$i,'typeofdata');
     $fieldonly=$adb->query_result($result,$i,'fieldonly');
     $tablename=$adb->query_result($result,$i,'tablename');
//XUQIU1000907 zl $mainfield为数组，用来取所有的表头字段
     $mainfield[]=$fieldLabel;
     $sessionMainfield[$i]['uitype']=$uitype;
     $sessionMainfield[$i]['columnname']=$columnname;
     $sessionMainfield[$i]['fieldlabel']=$fieldLabel;
     $sessionMainfield[$i]['typeofdata']=$typeofdata;
     $sessionMainfield[$i]['fieldonly']=$fieldonly;
     $sessionMainfield[$i]['tablename']=$tablename;

     $typedata=explode('~',$typeofdata);
     if($typedata[1]=='M'||$uitype==4)
     {
        $fieldLabel.='*';
     }
     if($uitype=='202')
     {
        //收付款单下拉框增加 源单类型列
        $sessionMainfield[$kk]['uitype']=1;
         $sessionMainfield[$kk]['columnname']='entitytype';
         $sessionMainfield[$kk]['fieldlabel']=getTranstab($frommodule).'_'.getFixedLabel('CHOOSEENTITYTYPE');
         if($typedata[1]=='M')
         {
            $sessionMainfield[$kk]['fieldlabel'].='*';
         }
         $sessionMainfield[$kk]['typeofdata']=$typeofdata;
         $sessionMainfield[$kk]['fieldonly']=$fieldonly;
         $sessionMainfield[$kk]['tablename']=$tablename;
         $importcolumn[]=array($uitype,'entitytype-field',$sessionMainfield[$kk]['fieldlabel'],$typeofdata);
         $kk++;
     }
     if($uitype==15 ||$uitype==33)
     {
        $profileid=$current_user->profileid;

        crm_load_function_file('getAssignedPicklistValues','modules/PickList','PickListUtils');

        $picklistdrop = getAssignedPicklistValues($columnname, $profileid, $adb,array(),"");
        $drophtml[$columnname.'-field']=$picklistdrop;
     }

     $importcolumn[]=array($uitype,$columnname.'-field',$fieldLabel,$typeofdata);
}
$_SESSION['mainfield_'.$currentModule.'_'.$current_user->id]=$sessionMainfield;

//产品字段
if($proresult_nums>0&&$productdetailcount>0){
    $producttoolfield_arr=array();
    for($i=0;$i<$proresult_nums;$i++){
            $product_uitype=$adb->query_result($proresult,$i,'uitype');
            $product_columnname=$adb->query_result($proresult,$i,'columnname');
            $product_fieldLabel=$adb->query_result($proresult,$i,'fieldlabel');
            $product_tablename=$adb->query_result($proresult,$i,'tablename');
            $product_typeofdata=$adb->query_result($proresult,$i,'typeofdata');
            //XUQIU1000907 zl $mainfield为数组，用来取所有的表头字段,判断fieldlabel是否与表头字段重复，重复则增加标识
            if(in_array($product_fieldLabel,$mainfield))
            {
                $product_fieldLabel=getTranstab($currentModule).getFixedLabel('DETAIL').'_'.$product_fieldLabel;
            }
            if(!in_array($product_columnname,$exist_product_column))
            {
                $producttoolfield_arr[$i]['uitype']=$product_uitype;
                $producttoolfield_arr[$i]['columnname']=$product_columnname;
                $producttoolfield_arr[$i]['fieldlabel']=$product_fieldLabel;
                $producttoolfield_arr[$i]['tablename']=$product_tablename;
                $producttoolfield_arr[$i]['typeofdata']=$product_typeofdata;
            }
            $exist_product_column[]=$product_columnname;
        
        if(stripos($product_typeofdata,'~M')!==false){
            $importcolumn[]=array($product_uitype,$product_columnname.'-products',$product_fieldLabel.'*');//给产品编号加上必录项符号
        }else{
            $importcolumn[]=array($product_uitype,$product_columnname.'-products',$product_fieldLabel);
        } 
    }
    
     if(empty($product_no))
    {
        $prodctno_fieldinfo=$profocus->fieldobj->getFieldInfoobjBykey('columnname','product_no');
        //XUQIU1000907 zl $mainfield为数组，用来取所有的表头字段,判断fieldlabel是否与表头字段重复，重复则增加标识
        $productno_fieldLabel = $prodctno_fieldinfo->getFieldLabel();
        if(in_array($productno_fieldLabel,$mainfield))
        {
            $product_fieldLabel=getTranstab($currentModule).getFixedLabel('DETAIL').'_'.$product_fieldLabel;
        }
        if($prodctno_fieldinfo)
        {
            $producttoolfield_arr[$i]['uitype']=$prodctno_fieldinfo->getUIType();
            $producttoolfield_arr[$i]['columnname']='product_no';
            $producttoolfield_arr[$i]['fieldlabel']=$prodctno_fieldinfo->getFieldLabel();
            $producttoolfield_arr[$i]['tablename']=$prodctno_fieldinfo->getTableName();
            $producttoolfield_arr[$i]['typeofdata']=$prodctno_fieldinfo->getTypeOfData();
            if(stripos($prodctno_fieldinfo->getTypeOfData(),'~M')!==false)
            {
                $importcolumn[]=array($prodctno_fieldinfo->getUIType(),'product_no-products',$productno_fieldLabel.'*');
            }
            else
                $importcolumn[]=array($prodctno_fieldinfo->getUIType(),'product_no-products',$productno_fieldLabel);
            
        }
    }
    $_SESSION['productfield_'.$currentModule.'_'.$current_user->id]=$producttoolfield_arr;
}
$producttoolfieldarr=array();
for($i=0;$i<$adb->num_rows($producttoolresult);$i++)
{
    $uitype=$adb->query_result($producttoolresult,$i,'uitype');
    $fieldtype=$adb->query_result($producttoolresult,$i,'fieldtype');
    $columnname=$adb->query_result($producttoolresult,$i,'columnname');
    $fieldLabel=$adb->query_result($producttoolresult,$i,'fieldlabel');
    $typeofdata=$adb->query_result($producttoolresult,$i,'typeofdata');
    $input_type=$adb->query_result($producttoolresult,$i,'input_type');
    $tablename=$adb->query_result($producttoolresult,$i,'tablename');
//XUQIU1000907 zl $mainfield为数组，用来取所有的表头字段,判断fieldlabel是否与表头字段重复，重复则增加标识
    if(in_array($fieldLabel,$mainfield))
    {
        $fieldLabel=getTranstab($currentModule).getFixedLabel('DETAIL').'_'.$fieldLabel;
    }
    if($columnname == 'entitytype'){
        $fieldLabel = getTranstab($currentModule).getFixedLabel('DETAIL').'_'.$fieldLabel;  
    }
    $producttoolfieldarr[$i]['uitype']=$uitype;
    $producttoolfieldarr[$i]['columnname']=$columnname;
    $producttoolfieldarr[$i]['fieldlabel']=$fieldLabel;
    $producttoolfieldarr[$i]['input_type']=$input_type;
    $producttoolfieldarr[$i]['tablename']=$tablename;
    $producttoolfieldarr[$i]['fieldtype']=$fieldtype;
    $newline=$adb->query_result($producttoolresult,$i,'newline');
    if($input_type==2&&$newline!=2)
    {
        $typedata=explode('~',$typeofdata);
        $producttoolfieldarr[$i]['typeofdata']=$typedata[0].'~M';
    }
    else
        $producttoolfieldarr[$i]['typeofdata']=$typeofdata;
    $typedata=explode('~',$typeofdata);

    //26500: 采购订单>导入-步骤4：建议CRM字段和字段标题都能自动匹配上
     if($typedata[1]=='M'||$input_type==2||$columnname=='entitytype')
     {
        $fieldLabel.='*';
     }
   $importcolumn[]=array($uitype,$columnname.'-producttoolfield',$fieldLabel,$typeofdata);
}
$_SESSION['detailfield_'.$currentModule.'_'.$current_user->id]=$producttoolfieldarr;

$selcolumnName=array();
include 'PHPExcel/PHPExcel/IOFactory.php';
 $objReader = PHPExcel_IOFactory::createReader($inputFileType);
$objPHPExcel = $objReader->load($inputFileName);
$objPHPExcel->setActiveSheetIndex(0);
$objWorksheet = $objPHPExcel->getActiveSheet();//
$highestRow=$objWorksheet->getHavaDataRow();//获取行号数组
$highestColumn = $objWorksheet->getHighestColumn();
$highestColumnIndex = PHPExcel_Cell::columnIndexFromString($highestColumn);//总列数
//取第一行标题和第二行数据
for ($col = 0;$col < $highestColumnIndex;$col++)
{
    $uitype=0;
    $columnname='';
    $objvalue0=(string) $objWorksheet->getCellByColumnAndRow($col, $highestRow[1])->getValue(); 
    $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][]=$objvalue0; 
    if($objvalue0=="")
    {
        break;
    }
    $objvalue1= $objWorksheet->getCellByColumnAndRow($col, $highestRow[2])->getValue();  

    foreach($importcolumn as $ccols)
    {
        if(in_array($objvalue0,$ccols)||in_array($objvalue0.'*',$ccols))
        {
            $uitype=$ccols[0];
            $columnname=$ccols[1];
            $selcolumnName[$columnname]='';
            $typeofdata=$ccols[3];
            $typedata=explode('~',$typeofdata);
        }
    }
    if($uitype==51 && !strstr($columnname,"-field")){
        $objvalue1 = date('Y-m-d',PHPExcel_Shared_Date::ExcelToPHP($objvalue1));
    }
    $objstr[$col]=array($objvalue0,$objvalue1,$uitype,$columnname);             
}




$smarty->assign('IS_PRODUCTDETAIL',$is_ProductDetail);//带产品明细的，不包括客户、服务收费管理  
$smarty->assign('FILETYPE',$filetype); //将导入文件后缀传入tpl，方便后面获取
$smarty->assign('CACHE_LABEL',implode(',',$select_label));
$smarty->assign('CACHE_LABEL_DETAIL',implode(',',$select_label2));
$smarty->assign('CACHE_SELECT',$hidden_select);
$smarty->assign('CACHE_SELECT_DETAIL',$hidden_select_detail);
$smarty->assign('SELECTCOLUMNS',$select);//查重字段
$smarty->assign('JSONSELECTCOLUMNS',json_encode($select));
$smarty->assign('CHECKEDCOLUMNS',$checkselect_column);
$smarty->assign('JSONPRODUCTSELECTCOLUMNS',json_encode($productselect));

$smarty->assign('PRODUCTSELECT',$productselect);//产品明细下拉查重字段
//29987: 单据>列表：选择重复时导入方式，不记住上次的选择，一直显示默认值“跳过”
$smarty->assign('IMPORTCHOOSE','Abort');

$smarty->assign('MODULENAME',$currentModule); 
$smarty->assign('IMPORTCOLUMN',$importcolumn);//所有字段数组
$smarty->assign('SELCOLUMN',$selcolumnName);//导入字段数组
$smarty->assign('PRODUCTIMPORTTYPE',$product_import_type);
$smarty->assign('DROPHTML',$drophtml);//下拉框数组
$smarty->assign('IMPORTDATA',$objstr);//Excel标题数组
$smarty->assign("STEPINDEX",$_REQUEST['stepindex']);
$tmp['excelcolumncount']=$highestColumnIndex;
$tmp['content']=$smarty->fetch("ImportXlsNew/secondImport.tpl");
ConvertTojsonString(1,$tmp,"success");

?>