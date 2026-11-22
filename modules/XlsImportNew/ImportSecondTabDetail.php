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

$sql="SELECT ld_tranlabel.fieldlabel,typeofdata,fieldtype,columnname,input_type,ld_tabdetailfield.tablename,ld_tabdetailfield.newline
            FROM ld_tabdetailfield INNER JOIN ld_tranlabel ON ld_tranlabel.relateid = ld_tabdetailfield.tabdetailfieldid
            WHERE ld_tranlabel.languagetype =?
            AND trantable =?
            AND presence IN (0, 2)
            AND ld_tabdetailfield.tabid =?
			AND ld_tabdetailfield.columnname not in('source_total','received_amount')
             and ld_tabdetailfield.newline<>1
            ORDER BY sequence ;";        

$producttoolresult=$adb->pquery($sql,array($languageType,'ld_tabdetailfield',$moduleid));

//主表
$sql='select blocktran.fieldlabel as blocklabel,fieldtran.fieldlabel,ld_field.typeofdata,ld_field.uitype,ld_field.columnname,tablename ,fieldonly
      from ld_field  inner join ld_blocks on ld_blocks.blockid=ld_field.block 
    inner join ld_tranlabel as fieldtran on ld_field.fieldid=fieldtran.relateid 
    inner join ld_tranlabel as blocktran on blocktran.relateid=ld_blocks.blockid 
    where (fieldtran.languagetype=? and fieldtran.trantable=? and fieldtran.tabid=?) 
    and (blocktran.languagetype=? and blocktran.trantable=? and blocktran.tabid=?) 
     and presence in(0,2)   and ld_blocks.visible=0 and ld_field.columnname not in("entitytypeid","subtotal") and ld_field.uitype <>202  
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
        $producttoolfieldarr[$i]['uitype']=$uitype;
        $producttoolfieldarr[$i]['columnname']=$columnname;
        $producttoolfieldarr[$i]['fieldlabel']=$fieldLabel;
        $producttoolfieldarr[$i]['input_type']=$input_type;
        $producttoolfieldarr[$i]['tablename']=$tablename;
        $producttoolfieldarr[$i]['fieldtype']=$fieldtype;
        $newline=$adb->query_result($producttoolresult,$i,'newline');
		//XUQIU1000907 zl $mainfield为数组，用来取所有的表头字段,判断fieldlabel是否与表头字段重复，重复则增加标识
        if(in_array($fieldLabel,$mainfield)){
            $fieldLabel=getTranstab($currentModule).getFixedLabel('DETAIL'). '_'.$fieldLabel;
        }
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
	/*
	*edit:chj
	*date:2020-07-15
	*reason:灵当CRM详细需求-费用报销单、佣金单、自定义表单21-25增加导入功能:表体只有源单一个字段，这里默认添加源单类型字段
	*/
    //由于判断该模块是否有源单字段
	$entitytypefieldinfo=$focus->detailfieldobj->getFieldInfoobjBykey('columnname','entitytypeid');
	/*
	*edit:chj
	*date:2020-07-15
	*reason:灵当CRM详细需求-费用报销单、佣金单、自定义表单21-25增加导入功能:表体只有源单一个字段，这里默认添加源单类型字段
	*/
	//if($currentModule == 'Commission'|| $currentModule == 'Expense'|| $currentModule == 'CustomForm21'|| $currentModule == 'CustomForm22'|| $currentModule == 'CustomForm23'|| $currentModule == 'CustomForm24'|| $currentModule == 'CustomForm25'){
    if(!empty($entitytypefieldinfo) && $entitytypefieldinfo->getPresence() != 1){
        $tablename = $focus->Detail_table;
        $importcolumn[]=array(1,'entitytype-producttoolfield',getFixedLabel('SOURCETYPE'),'V~O');
        $producttoolfieldarr[] = array('uitype'=>0,'columnname'=>'entitytype','fieldlabel'=>getFixedLabel('SOURCETYPE'),'input_type'=>1,'tablename'=>$tablename,'typeofdata'=>'V~O');
    }
	//}
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
   $smarty->assign('DROPHTML',$drophtml);//下拉框数组
   $smarty->assign('IMPORTDATA',$objstr);//Excel标题数组
   $smarty->assign("STEPINDEX",$_REQUEST['stepindex']);
    $tmp['excelcolumncount']=$highestColumnIndex;
    $tmp['content']=$smarty->fetch("ImportXlsNew/secondImport.tpl");
    ConvertTojsonString(1,$tmp,"success");

?>