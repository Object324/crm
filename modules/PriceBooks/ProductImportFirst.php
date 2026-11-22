<?php
global $adb;
global $currentModule;
global $current_user;
$stepindex = $_REQUEST['stepindex'];
$_REQUEST['diony']='yes';
if($stepindex==1){
    $smarty=new lingdangCRM_Smarty();
    $frommodule=$_REQUEST['frommodule'];
    $focus=CRMEntity::getInstance($frommodule);
    $arr['modulelabel']=gettranstab($frommodule);
    $arr['dupfieldlabel']=getFixedLabel('CHECKIMPORTFIELD');//查重字段
    $arr['fileuploadlabel']=getFixedLabel('FILEUPLOAD');//上传文档
    $arr['mappingfieldlabel']=getFixedLabel('MAPPINGFIELD');//映射字段
    $arr['importdatalabel']=getFixedLabel('IMPORTDATATTITLE');//导入数据
    $arr['finishedlabel']=getFixedLabel('TEMPLATECOMPLETE');//完成
    $arr['accordingimportdatalabel']=getFixedLabel('ACCORDINGTEMPLATEIMPORTDATA');//请按照数据模板的格式准备要导入的数据。
    $arr['downloadtemplatedatalabel']=getFixedLabel('DOWNTEMPLATEDATA');//下载模板数据
    $arr['viewcareitemlabel']=getFixedLabel('VIEWCAREITEM');//查看注意事项
    $arr['notelabel']=getFixedLabel('NOTE');//注意事项
    $arr['notencontent_firstlabel']=getFixedLabel('STOPDELETEIMPORTTEMPLATEHEAD'); //模板中的表头名称不可更改，表头行不能删除
    $arr['notencontent_secondlabel']=getFixedLabel('MAYADJUSTORDERIMPORT');//项目顺序可以调整，不需要的项目可以删减
    $arr['notencontent_thirdlabel']=getFixedLabel('REDREPRESENTNOTEMPTY'); //红色*表示为必录项，必须保留并且不能为空
    $arr['detaildupcheckmethod'] = getFixedLabel("IMPORT_PLEASESETDUMPLICATEFIELDS").getTranstab("Products") . getFixedLabel('CHECKIMPORTFIELD');//设置产品管理查重字段
    $arr['productnotexistsmethod_label'] = getFixedLabel('howtodowhentheproductsisnotexists');//设置产品管理不存在时导入方式


    $detailmodule='Products';
    $detailfocus=CRMEntity::getInstance($detailmodule);
    //$secondaction='ImportSecondDetail';
    $detailfields=$detailfocus->fieldobj->getModuleFields();
    $detailblocks=$detailfocus->fieldobj->getBlockVisibleInfos();
    $smarty->assign("DETAILFIELDS",$detailfields);
    $smarty->assign("DETAILBLOCKS",$detailblocks);
    if($detailmodule!='')
    {
        $fileblockdel='yes';

        $tmpdetailblocks=array();
        foreach($detailfields as $fieldname=>$fieldinfo)
        {
            if($fieldinfo->getUIType()==69 ||$fieldinfo->getUIType()==1109 ||$fieldinfo->getUIType()==28)
            {
                $fileattachblockid=$fieldinfo->getBlockId();
            }
            else
            {
                $tmpdetailblocks[]=$fieldinfo->getBlockId();
                if(in_array($fileattachblockid,$tmpdetailblocks))
                {
                    $fileblockdel='no';

                    break;
                }
            }
        }
        $tmpdetailblocks=array();
        foreach($detailblocks as $blockid=>$blockinfo)
        {
            if($fileblockdel=='yes'&&$blockid==$fileattachblockid)
            {
                continue;
            }
            if($blockinfo['label']=='LBL_LABEL')
            {
                continue;
            }
            if(array_key_exists($blockid,$detailfocus->fieldobj->presencefield_blockids))
            {
                $tmpdetailblocks[$blockid]=$blockinfo;
            }

        }
        $detailblocks=$tmpdetailblocks;
        $smarty->assign("DETAILBLOCKS",$detailblocks);
    }
    $tmp['detailfields']=$detailfields;
    $tmp['detailblocks']=$detailblocks;
    $tmp['detailmodule']=$detailmodule;



    $mutli_detail_importcheckdupfields[0] = array('columns' => 'productcode', 'condition' => 'or');
    $smarty->assign("DETAILIMPORTCHECKDUPFIELDS", $mutli_detail_importcheckdupfields);

    $smarty->assign("STEPINDEX",1);
    $smarty->assign("ARRLABEL",$arr);
    $tmp['title'] = getFixedLabel("IMPORTENTRY");

    $tmp['oktext']=getFixedLabel("NEXT");
    $tmp['content']=$smarty->fetch("modules/PriceBooks/FirstImport.tpl");
    ConvertTojsonString(1,$tmp,"success");
}
elseif ($stepindex == 2){
    set_time_limit(0);
    
    $filename=$_REQUEST['filename'];
    $filetype =pathinfo($filenamess, PATHINFO_EXTENSION);//获取导入文件的后缀名
    if($filetype=='xlsx'){
        $inputFileType = 'Excel2007';
    }
    else{
        $inputFileType = 'Excel5';
    }
    $sessionMainfield=array();
    include 'PHPExcel/PHPExcel/IOFactory.php';
    $objReader = PHPExcel_IOFactory::createReader($inputFileType);
    $objReader->setReadDataOnly(true);
    $objPHPExcel = $objReader->load('storage/'.$filename);
    
    $objPHPExcel->setActiveSheetIndex(0);
    $objWorksheet = $objPHPExcel->getActiveSheet();//
            
    $highestRow=$objWorksheet->getHavaDataRow();//获取行号数组
    if (sizeof($highestRow) < 2) {
        $error .= '模板文件中没有数据，导入失败！' . '<br>';
        ConvertTojsonString("-1", array(), $error);
    }
                
    $_totalRows=count($highestRow)-1; //导入的数据总行数
    
    $highestColumn = $objWorksheet->getHighestColumn();
    $highestColumnIndex = PHPExcel_Cell::columnIndexFromString($highestColumn);//总列数
    
    $_REQUEST['product_importdupcheckfields'] = $_REQUEST['detail_importdupcheckfields'];
    $product_checkimportfield = implode(',', json_decode($_REQUEST['product_importdupcheckfields'], true));//查重字段
    $product_is_checkimportfield = explode(',',$product_checkimportfield);//将选中的产品明细查重字段转为数组
    
    $mapfields = array();//导入字段
    $mapfields[] = $product_is_checkimportfield[0].'-Products';
    $mapfields[] = 'listprice-PriceBooks';
    $totalcolumns = sizeof($mapfields);//导入列数
    if($highestColumnIndex>=$totalcolumns){
        $highestColumnIndex = $totalcolumns;
    }
    
    $maxrows = $objWorksheet->getHighestRow();
    while (true) {
        //获取excel中数据行数，防止有删除的空行也算入导入行数了
        for ($tmppk = 0; $tmppk < $totalcolumns; $tmppk++) {
            $tmp_str = trim((string)$objWorksheet->getCellByColumnAndRow($tmppk, $maxrows)->getValue());
            if ($tmp_str !== '') {
                break;
            }
        }
        if ($tmp_str != '') {
            break;
        }
        if ($maxrows <= 0) {
            break;
        }
        $maxrows--;
    }
    
    //获取excel数据
    $xlsRowData = array();
    $tmprow = 0;
    $row = 2;
    while (true) {
    
        if ($row > $maxrows)//如果超过xls文件行数则退出循环
        {
            break;
        }
        if (!array_key_exists($row, $highestRow)) {
            $row++;
            continue;
        }
    
        for ($excel_col_index = 0; $excel_col_index < $highestColumnIndex; $excel_col_index++) {
            $excel_value = $objWorksheet->getCellByColumnAndRow($excel_col_index, $row)->getValue();
            $excel_value = trim((string)$excel_value);
            $xlsRowData[$tmprow][] = $excel_value;
        }
        $row++;
        $tmprow++;
    }
    
    $_REQUEST['diony'] = 'yes';
    $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . "_data"] = array();
    $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_startdate'] = date("Y-m-d H:i:s");
    $_REQUEST['startrow'] = 0;
    
    if ($filetype == 'xlsx') {
        $inputFileType = 'Excel2007';
    } else {
        $inputFileType = 'Excel5';
    }
    
    
    if ($totalcolumns <= 0) {
        ConvertTojsonStringIndex("-1", array(), '导入字段不能为空');
    }
    
    
    
    $focus = CRMEntity::getInstance($currentModule);
    $profocus = CRMEntity::getInstance('Products');
    $tmpcolumnname = $product_is_checkimportfield[0];
    $fieldlabel = $profocus->fieldobj->getFieldInfoBykeyValue("columnname", $tmpcolumnname, 'fieldlabel');
    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel']=array();
    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][]='产品查重字段*';
    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][]='单价*';
    if (!in_array($tmpcolumnname . '-Products', $mapfields)) {
        $error .= '导入文件中缺少查重\'' . $fieldlabel . '\'列<br>';
    }
    if (!empty($error)) {
        ConvertTojsonString("-1", array(), $error);
    }
    
    $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . "_data"] = $xlsRowData;
    $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_highestColumnIndex'] = $highestColumnIndex;
    $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_maxrows'] = sizeof($xlsRowData);
    $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_highestrow'] = $highestRow;
    $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_hangshu'] = 0;
    $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_totalrows'] = 0;  //总记录数
    $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_addimportrows'] = 0;
    $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_successrows'] = 0;
    $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_updaterows'] = 0;
    $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . "_shijidaorurows"] = 0;//实际导入的单据数量，按主表计算
    $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_successdetailscount'] = 0;//导入成功的明细条数
    $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_failuredetailscount'] = 0;//失败导入的明细条数
    $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . "_error"] = '';
    
    include(globalStatic::$root_directory . 'modules/PriceBooks/ImportProductProgress.php');//进度条
    $tmp['maxrows'] = $maxrows;
    $tmp['timedescription'] = $time_description;
    $tmp['cur_progress_step'] = $cur_progress_step;
    ConvertTojsonString(1, $tmp, 'success');
}
elseif ($stepindex == 3){
    $filename=$_REQUEST['filename'];
    $pricebookid = $_REQUEST['pricebookid'];
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
        if(empty($pricebookid)){
            ConvertTojsonString(-1,$tmp,'获取价格表id失败');
        }
        $tmp['content']=$smarty->fetch('modules/PriceBooks/ThreeImport.tpl');
        $tmp['title']=getFixedLabel("IMPORT").$arr['modulelabel'];
        
        ConvertTojsonString(1,$tmp,'success');
    }
    require_once(globalStatic::$root_directory.'WeiXinApp/WeiXin_common/cls_WeixinPort.php');
    require_once(globalStatic::$root_directory.'appCommon/appCommon.php');
    include globalStatic::$root_directory.'PHPExcel/PHPExcel/IOFactory.php';
    require_once(globalStatic::$root_directory.'PHPExcel/PHPExcel/IOFactory.php') ;
    $focus=CRMEntity::getInstance($currentModule);
    $module_tablename=$focus->table_name;//单据主表
    $module_tablename_scf =$focus->customFieldTable[0];//单据自定义表
    $pricebookreal = 'ld_pricebookproductrel';
    $profocus=CRMEntity::getInstance('Products');
    $smarty=new lingdangCRM_Smarty();
    //导入数据
    $allFieldOnly=array();//所有唯一字段
    $error='';//错误信息
    $_REQUEST['product_importdupcheckfields'] = $_REQUEST['detail_importdupcheckfields'];
    $product_checkimportfield = implode(',', json_decode($_REQUEST['product_importdupcheckfields'], true));//查重字段
    $product_is_checkimportfield = explode(',',$product_checkimportfield);//将选中的产品明细查重字段转为数组
    $mapfields = array();//导入字段
    $mapfields[] = $product_is_checkimportfield[0].'-Products';
    $mapfields[] = 'listprice-PriceBooks';
    $totalcolumns=sizeof($mapfields);//导入列数
    
    $fieldcolumnindex_arr = array();
    $fieldcolumnindex_arr[$product_is_checkimportfield[0]] = 0;
    $fieldcolumnindex_arr['listprice'] = 1;
    
    $prodcutimport_field = array();
    $prodcutimport_field[$pricebookreal] = array();
    $prodcutimport_field['ld_products'][] = $product_is_checkimportfield[0];
    $prodcutimport_field[$pricebookreal][] = 'listprice';
    
    $importproduct_tables = array();
    $importproduct_tables[$pricebookreal] = array();
    $importproduct_tables[$pricebookreal][] = 'pricebookid';
    $importproduct_tables[$pricebookreal][] = 'productid';
    $importproduct_tables[$pricebookreal][] = 'listprice';
    $importproduct_tables[$pricebookreal][] = 'usedcurrency';
    
    $updateproduct_tables = array();
    $updateproduct_tables[$pricebookreal] = array();
    $updateproduct_tables[$pricebookreal][] = 'pricebookid';
    $updateproduct_tables[$pricebookreal][] = 'productid';
    $updateproduct_tables[$pricebookreal][] = 'listprice';
    
    
    
    //放在函数的最下面，等待主表更新total字段更新完成
    crm_load_class_file('cls_Source_InverseCompute','include/OptionModule');
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
     
     $highestRow=$_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_highestrow'];//获取行号数组
     $maxrows=$_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_maxrows'];
     
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
           
            $smarty->assign("IMPORTINFO",$importdatainfo);
             ConvertTojsonString('-1',array(),$error);
            
        }
    }
     
     $import_type = $_REQUEST['choose']; //获取重复时导入方式
     $_checkproducts = $product_is_checkimportfield; //获取产品明细表查重字段
     $successRows=0;//成功导入的合同订单数
     $updateRows=0;//成功覆盖单据数
     
     $nohaveerror=true;
     $fieldcolIndex=0;
     $_checkproductsfield = explode(',',$_checkproducts);//将产品查重字段转换为数组
     
     $startrow=$_REQUEST['startrow'];
     $endrow=$_REQUEST['endrow'];
     
     $between_rows=$endrow-$startrow;//每次导入的行数（目前是5条,(0-4))
     $module_importproduct_rows=0;//导入的产品的行数
     $importdatas= $_SESSION['productimport_'.$currentModule.'_'.$current_user->id."_data"];//需要导入的数据
     $product_same_pricebook = 'no';
     $row=$startrow;
     crm_load_function_file('getPriceBookCurrency','include/utils','InventoryUtils');


     while(true){
        //如果超过xls文件行数则退出循环
        if($row>=$maxrows){
            break;
        }
        if($module_importproduct_rows>$between_rows)
        {
            $endrow=$row;//返回到前端，用于判断下次开始导入行数的标识
            break;
        }
        $excelrow=$row+2;
        $col=0;
        if($row+1>=$maxrows)
        {
            $tmp_cur_row_end_line='yes' ;
        }
        if($product_same_pricebook=='no')
        {
            $xlsRowData=array();
            $product_xlsRowData=array();
            $pricebookproductid = array();
            $productid=array();
            $nohaveerror=true;
        }
        foreach($prodcutimport_field as $tablename => $importfields)
        {
            foreach($importfields as $ky=>$colname)
            {
                $flag = true;
                $fieldcolIndex = $fieldcolumnindex_arr[$colname];
                $str=trim((string)$importdatas[$row][$fieldcolIndex]);
                if($colname == 'listprice'){
                    if($str==''){
                        
                    }else if(!is_numeric($str)){
						$error.='第'.$excelrow.'行"'.$_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列内容为非法数字!<br>';
						$nohaveerror=false;
					}
                }
                //为空时获取改行不导入
                else if($str==''){
                     $error.='第'.$excelrow.'行"'.$_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel'][$fieldcolIndex].'"列值不能为空!<br>';
                     $nohaveerror=false;
                }
                
                if(in_array($colname,$product_is_checkimportfield)){
                    $product_xlsRowData[0][$tablename][$colname]=vtlib_purify($str); 
                }
                else{
                    $xlsRowData[0][$tablename][$colname]=vtlib_purify($str);
                }
            }
        }
        //
        if($nohaveerror==false){
               $row++;
                $_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_totalrows']+1;
                $xlsRowData=array();
               $nohaveerror=true;
                continue;
        }
        
        $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_totalrows'] = $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_totalrows'] + 1;
        
        if(!empty($_REQUEST['product_import_type']) && ($_REQUEST['product_import_type'] == 'NoImportRow')){
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
								$product_sql.=" and deleted=0 ORDER BY createdtime desc";
								$product_result=$adb->pquery($product_sql,array($_checkimportfieldValues));

								$product_num=$adb->num_rows($product_result);
                               
								if($product_num >= 1){
									$db_product_num++;
                                    $pricebookproductid[] = $adb->query_result($product_result,0,0);
                                    $tmpmaysaveproducts[]=$productColumn;
                                    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_successdetailscount']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_successdetailscount']+1;//该行不导入，成功导入的明细数量;
                                   
								}else{

									$no_product_row = $row - sizeof($product_xlsRowData) + 1 + $productData;
                                    $no_product_rows[]=$no_product_row;
                                    $no_product_values[]=$_checkimportfieldValues;
                                    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_failuredetailscount']=$_SESSION['import_'.$currentModule.'_'.$current_user->id.'_failuredetailscount']+1;

								}
							}
							else
							{
								
							}
                            
                        }
                    }
                }
            }
        }
        $product_xlsRowData= $tmpmaysaveproducts;//把不需要导入的产品数据从数组中删除
        //整单不导入,该行不导入
		if($_REQUEST['product_import_type'] == 'NoImportData'||$_REQUEST['product_import_type'] == 'NoImportRow'){
            foreach($no_product_rows as $tmpindex=> $no_product_rowindex)
            {
                //wym BUG0071111 第一条数据$no_product_rowindex为0,不能跳过,否则错误日志不显示第一条
                if(empty($no_product_rowindex)&&$no_product_rowindex!=0)
                {
                    break;
                }
                $tips="";
                foreach($no_product_values[$tmpindex] as $tmpcolumnname=>$cellvalue)
                {
                    
                    $fieldlabel=$profocus->fieldobj->getFieldInfoBykeyValue("columnname",$tmpcolumnname,"fieldlabel");
                    $tips.=$fieldlabel.":".$cellvalue;
                }
                if($_REQUEST['product_import_type'] == 'NoImportData')
       	        {
       	            $error .="第".($no_product_rowindex+2)."行 $tips 在数据中不存在，已跳过整个单据!"."<br>";
                   $flag = false;
       	        }
                else
           	    {
           	        $error .="第".($no_product_rowindex+2)."行 $tips 产品在数据中不存在，该行单据不导入!"."<br>";
           	    }
            }
		}
        
        $temp=array();
        $import_type = 'Update';
        if($import_type!="Insert"){ //查重判断
           if(!empty($pricebookproductid)){
                $tmpsql = "select productid from ".$pricebookreal." where productid = ? and pricebookid = ?";
                $tmpresult = $adb->pquery($tmpsql,array($pricebookproductid[0],$pricebookid));
                $num_rows = $adb->num_rows($tmpresult); 
           }
           else{
                $num_rows = 0;
           }
        }
        
        if($num_rows>0 && ($import_type=='Update' ) && $flag == true){ //获取重复的单据id
            $tmppricebookproductid =$pricebookproductid[0];
            $tmplistprice = $xlsRowData[0][$pricebookreal]['listprice'];
            //zkt 20230719 BUG0069490  kfbcrm-价格表-产品管理-导入-当导入数据中单价字段为空时，导入失败 
            if($tmplistprice == ''){
                $tmpsql = 'select unit_price from ld_products where productid=?';
                $tmpresult = $adb->pquery($tmpsql,array($pricebookproductid[0]));
                if($adb->num_rows($tmpresult)>0){
                    $tmplistprice = $adb->query_result($tmpresult,0,0);
                }
                else{
                    $tmplistprice = 0;
                }
            }
            //更新重复数据
            $tmpsql = "update ".$pricebookreal." set listprice=? where productid = ? and pricebookid = ?";
            $tmpresult = $adb->pquery($tmpsql,array($tmplistprice,$pricebookproductid[0],$pricebookid));
            $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_updaterows']=$_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_updaterows']+1;
            $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_successrows']=$_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_successrows']+1;
            
        }
        //没有重复数据时插入数据
        else if(empty($num_rows)&&!empty($pricebookproductid)&&$flag == true){ //获取重复的单据id
            $tmppricebookproductid =$pricebookproductid[0];
            $tmplistprice = $xlsRowData[0][$pricebookreal]['listprice'];
            //zkt 20230719 BUG0069490  kfbcrm-价格表-产品管理-导入-当导入数据中单价字段为空时，导入失败 
            if($tmplistprice == ''){
                $tmpsql = 'select unit_price from ld_products where productid=?';
                $tmpresult = $adb->pquery($tmpsql,array($pricebookproductid[0]));
                if($adb->num_rows($tmpresult)>0){
                    $tmplistprice = $adb->query_result($tmpresult,0,0);
                }
                else{
                    $tmplistprice = 0;
                }
            }
            
	        $currency_id = getPriceBookCurrency($pricebookid);
            //更新重复数据
            $query= "insert into ld_pricebookproductrel (pricebookid,productid,listprice,usedcurrency) values(?,?,?,?)";
            $adb->pquery($query, array($pricebookid,$tmppricebookproductid,$tmplistprice,$currency_id));
            
            $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_addimportrows']=$_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_addimportrows']+1;
            $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_successrows']=$_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_successrows']+1;
        }
        else{
            //导入失败
        }
        $row++;
     }
     //zkt 20230719 BUG0069483 kfbcrm-价格表-产品管理-导入-导入失败时提示信息错误 
     $_SESSION['productimport_'.$currentModule.'_'.$current_user->id."_error"]=$_SESSION['productimport_'.$currentModule.'_'.$current_user->id."_error"].$error;
     include(globalStatic::$root_directory . 'modules/PriceBooks/ImportProductProgress.php');//进度条
     $tmp['timedescription']=$time_description;
    $tmp['cur_progress_step']=$cur_progress_step;
    $tmp['endimporttime']=$endimporttime;
    $tmp['endrow']=$endrow-1;
    ConvertTojsonString(1,$tmp,'success');
}
elseif($stepindex==4){
    //导入完成
    $frommodule = $_REQUEST['frommodule'];
    $focus = CRMEntity::getInstance($frommodule);
    $arr['modulelabel'] = gettranstab($frommodule);
    $arr['dupfieldlabel'] = getFixedLabel('CHECKIMPORTFIELD');//查重字段
    $arr['fileuploadlabel'] = getFixedLabel('FILEUPLOAD');//上传文档
    $arr['mappingfieldlabel'] = getFixedLabel('MAPPINGFIELD');//映射字段
    $arr['importdatalabel'] = getFixedLabel('IMPORTDATATTITLE');//导入数据
    $arr['finishedlabel'] = getFixedLabel('TEMPLATECOMPLETE');//完成
    $smarty = new lingdangCRM_Smarty();
    $smarty->assign("STEPINDEX", $_REQUEST['stepindex']);
    $smarty->assign("ARRLABEL", $arr);
    $smarty->assign("MODULE", $currentModule);
    $smarty->assign("FILENAME", getTranstab('Products') . '导入日志.txt');
    
    $tmp['title'] = getFixedLabel("IMPORTENTRY");
    $tmp['oktext'] = getFixedLabel('LBL_FINISH_BUTTON_LABEL');
    $maxrows = $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_maxrows'];
    $successRows = $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_successrows'];
    $addimportrows = $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_addimportrows'];
    $updateRows = $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_updaterows'];
    
    if (empty($successRows)) {
        $successRows = 0;
    }
    if (empty($addimportrows)) {
        $addimportrows = 0;
    }
    if (empty($updateRows)) {
        $updateRows = 0;
    }
    $totalrows = $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_totalrows'];
    
    $smarty->assign("HANGSHU", $maxrows);
    $smarty->assign("IMPORTINFO", $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_error']);
    $smarty->assign('SUCCESSROWS', $successRows);
    $smarty->assign('ADDIMPORTROWS', $addimportrows);
    $smarty->assign('UPDATEROWS', $updateRows);
    $smarty->assign('TOTALROWS', $totalrows);
    
    
    $smarty->assign('ERRORROWS', ($totalrows - $successRows));
    $smarty->assign("PRODUCTIMPORTYPE", $_REQUEST['product_import_type']);
    
    $filehandler = fopen('storage/importlog_' . $currentModule . '_' . $current_user->id . '.txt', 'w+');
    $error = $_SESSION['productimport_' . $currentModule . '_' . $current_user->id . '_error'];
    if ($error == "") {
        $error = '<br>';
    }
    fwrite($filehandler, str_replace('<br>', "\r\n", $error));
    fclose($filehandler);
    $smarty->assign("FILEPATH", 'storage/importlog_' . $currentModule . '_' . $current_user->id . '.txt');
    //editor:gyq_162 reason:海格产品分录导入   2019/12/11 16:34
    ImportclearSession();//清空session
    $tmp['content'] = $smarty->fetch('modules/PriceBooks/FinishedImport.tpl');
    ConvertTojsonString(1, $tmp, 'success');
}

function ImportclearSession(){
    global $currentModule;
    global $current_user;
    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_excelfieldlabel']=array();
    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id."_data"]=array();
    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_highestColumnIndex']=0;
    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_maxrows']=0;
    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_highestrow']=$highestRow;  
    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_hangshu']=0;    
    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_totalrows']=0;  
    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_addimportrows']=0; 
    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_successrows']=0; 
    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_updaterows']=0; 
    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id."_shijidaorurows"]=0;//实际导入的单据数量，按主表计算
    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_successdetailscount']=0;//导入成功的明细条数
    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id.'_failuredetailscount']=0;//失败导入的明细条数
    $_SESSION['productimport_'.$currentModule.'_'.$current_user->id."_error"]='';
}
?>