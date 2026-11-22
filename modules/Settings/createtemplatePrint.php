<?php

global $adb,$current_user,$global_regop;
$product_field_obj=Field::getInstance('Products',$adb);
$profieldlabel=$product_field_obj->getFieldLables();
$tabid=$_REQUEST['printtabid'];
$smarty=new lingdangCRM_Smarty;
$smarty->assign('PRODUCTFIELDLABELS',$profieldlabel);
$sql="select  tabid,name,tablabel from ld_tab where (name in('accounts','contacts','quotes','salesorder','invoice','products','paymentplan','sendpayment','potentials','helpdesk','expense','contactrecords','vendors','vendorcontact','VendorContactRecords','purchaseorder','Stock','OutboundOrder','Checks','project') or printtab=1) and presence in(0,2)  order by tabsequence";
$result=$adb->pquery($sql,array());
$printtabs=array();
for($i=0;$i<$adb->num_rows($result);$i++)
{
      //$printtabs[$adb->query_result($result,$i,'tabid')]=$app_strings[$adb->query_result($result,$i,'tablabel')];
      $printtabs[$adb->query_result($result,$i,'tabid')]=getTranstab($adb->query_result($result,$i,'name'));
}

if(isset($_REQUEST['type']) && !empty($_REQUEST['type']))
    $type = $_REQUEST['type'];
else
    $type = '';

if(isset($_REQUEST['printId']))
{
    $printId=$_REQUEST['printId'];
    $sql="select * from ld_templateprint where templateprintid=?";
    $result=$adb->pquery($sql,array($printId));
    if($adb->num_rows($result)>0)
    {
       
        if(isset($_REQUEST['CopyTemplate']))
        {
            $smarty->assign("ISDEFAULT",0);
            $smarty->assign("ApprovedAllowPrint",'no');
            $smarty->assign("TEMPLATENAME",'');
            $smarty->assign("MODE","create");
            $smarty->assign("MODECAPTION",getFixedLabel('COPY'));
            $smarty->assign("TEMPLATECOPY",1);
            $smarty->assign('REPLACESPACEVALUE',$adb->query_result($result,0,'replacespacevalue'));
            $smarty->assign("TEMPLATENAME",$adb->query_result($result,0,'templateprintname'));
        }
        else
        {
            $smarty->assign("PRINTID",$printId);
            $smarty->assign("TEMPLATENAME",$adb->query_result($result,0,'templateprintname'));
            $smarty->assign("ISDEFAULT",$adb->query_result($result,0,'isdefault'));
            $smarty->assign("ApprovedAllowPrint",$adb->query_result($result,0,'approvedallowprint'));
            $smarty->assign('REPLACESPACEVALUE',$adb->query_result($result,0,'replacespacevalue'));
            $smarty->assign("MODE","edit");
            $smarty->assign("MODECAPTION",getFixedLabel('EDIT'));
        }
       
        $tabid=$adb->query_result($result,0,'tabid');
        $printfilename=$adb->query_result($result,0,'printfilename');
        if(file_exists("templatePrintFile/".$printfilename))
        {  
            
            if ( !is_readable("templatePrintFile/".$printfilename) )
            {
                die("文件:" .$printfilename. "不可读，请检查！");
            }

            $extension = pathinfo($printfilename, PATHINFO_EXTENSION);// 文件格式
            if($extension == 'doc' || $extension == 'docx' || $extension == 'xls' || $extension == 'xlsx'){// 2024-5-15 xxy Word/Excel打印模板,编辑时显示已上传文件
                if($extension == 'doc' || $extension == 'docx'){
                    $type = 'Word';
                }else if($extension == 'xls' || $extension == 'xlsx'){
                    $type = 'Excel';
                }
                $smarty->assign("TYPE",$type);
                $attname = $adb->query_result($result,0,'originalfilename');// 用户上传的文件名,用于显示
                
                $storage_location = "local";
                $path = "templatePrintFile/";
                $cloud_path = "templatePrintFile/";
                $file_type = '';
                $newfile_name = $printfilename;

                $size = filesize($path.$newfile_name);
                if ($size < 1024)
                    $size = $size . ' B';
                else if ($size > 1024 && $size < 1048576)
                    $size = round($size / 1024, 2) . ' KB';
                else if ($size > 1048576)
                    $size = round($size / (1024 * 1024), 2) . ' MB';

                // 下载
                $cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
                $download_path = $cls_AESencryptionbykeyobj->getencryption($path.$newfile_name);
                $arr['downloadpath'] = $download_path;
                $arr['originalfilename'] = $attname;
                //edit: xll XUQIU1001183 下载优化：newfile_name、path、cloud_path加密
                $cls_MyCRMcrypt = new cls_MyCRMcrypt();
                $path = $cls_MyCRMcrypt->encode($path);
                $cloud_path = $cls_MyCRMcrypt->encode($cloud_path);
                $newfile_name = $cls_MyCRMcrypt->encode($newfile_name);
                $isEncrypt = 'yes';

                // edit: xll 2023/07/25 XUQIU1001352 PC端和移动端上传附件功能：新增、编辑界面上传附件后，增加预览功能（生成预览按钮并返回）
                $httppath = $cls_MyCRMcrypt->decode($cloud_path);
                $pre_path = $cls_MyCRMcrypt->decode($path) . $cls_MyCRMcrypt->decode($newfile_name);
                $file = array('id' => $id, 'storage_location' => $storage_location, 'httppath' => $httppath,
                    'pre_path' => $pre_path, 'name' => $attname, 'type' => $file_type, 'isEncrypt' => $isEncrypt,
                    'path' => $path, 'cloud_path' => $cloud_path, 'newfile_name' => $newfile_name);
                crm_load_class_file('AttachmentUtils','modules/Attachment');
                $AttachmentUtilsObj = new AttachmentUtils();
                $pre_button = $AttachmentUtilsObj->getPreviewButton($file);

                $file_info[] = array('file_name' => $attname, 'file_size' => $size, 'file_type' => $file_type
                , 'file_path' => $path, 'cloud_path' => $cloud_path, 'newfile_name' => $newfile_name, 'fileid' => $id, 'storage_location' => $storage_location, 'isEncrypt' => $isEncrypt
                , 'pre_button' => $pre_button);
                
                $arr['templatetype'] = $type;
                $arr['filejsondata'] = Zend_Json::encode($file_info);
            }else{

                $file_handle=fopen("templatePrintFile/".$printfilename,"r");
            
                $contents = fread($file_handle, filesize ("templatePrintFile/".$printfilename));
                fclose($file_handle);
                $smarty->assign("CKEDITORHTML",$contents);
            }

            
        }
        else
        {
            $extension = pathinfo($printfilename, PATHINFO_EXTENSION);// 文件格式
            // 模板文件被删除
            if($extension == 'doc' || $extension == 'docx' || $extension == 'xls' || $extension == 'xlsx'){
                if($extension == 'doc' || $extension == 'docx'){
                    $type = 'Word';
                }else if($extension == 'xls' || $extension == 'xlsx'){
                    $type = 'Excel';
                }
                $smarty->assign("TYPE",$type);
                $smarty->assign("Errortips",getFixedLabel('TEMPLATEFILEISMISSING').getFixedLabel('PLEASE').getFixedLabel('UPLOADAGAIN'));
            }else{
                $smarty->assign("CKEDITORHTML",getFixedLabel('TEMPLATEFILEISMISSING'));
            }
        }
         
    }
    else
    {
        echo "模板文件已删除！";
        exit();
    }
}
else
{
    $smarty->assign("MODE",'create');
    $smarty->assign("ISDEFAULT",0);
    $smarty->assign("ApprovedAllowPrint",'no');
    $smarty->assign("TEMPLATENAME",'');
    $smarty->assign("CKEDITORHTML",'');
    $smarty->assign('REPLACESPACEVALUE','');
    $smarty->assign("MODECAPTION",getFixedLabel('NEWTEMPLATE'));
}
/*--
更新操作
操作人：andy
时间：2013-12-5
说明：打印模板定制 BUG处理 0006057
*/
$cur_module=getTabname($tabid);
$cur_focus=CRMEntity::getInstance($cur_module);
//$result = $adb->query("select newchinesename from ld_languagepackage where tabid='{$tabid}' ");
//$mokuai_name = $adb->query_result($result, 0, 'newchinesename');
$smarty->assign("MODULE",$cur_module);
$smarty->assign("mokuai_name",getTranstab($cur_module));
$haveProductDetails = 'no';

/**
 * 从ld_producttoolfield表中取出启用的自定义产品字段，
 * presence：0 启用/1 不启用
 * @project 打印模板添加自定义产品字段
 * @author Tujt 
 */
require('user_privileges/user_language_'.$current_user->id.'.php');
$main_tablename=$cur_focus->table_name;
if(get_file_address($cur_module,'ProductDetails'))
{
    $haveProductDetails = 'yes';
    $profldsql = 'select distinct defaultvalue,uitype,typeofdata,columnname,ld_tranlabel.fieldlabel from ld_producttoolfield inner join ld_tranlabel on ld_tranlabel.relateid=ld_producttoolfield.producttoolfieldid
          where languagetype=? and trantable=? and ld_producttoolfield.tabid=?
            and presence=0  and tablename not in(\''.$main_tablename.'\') order by sequence';

        $profldresult = $adb->pquery($profldsql,array($languageType,'ld_producttoolfield',$tabid));
        $rows = $adb->num_rows($profldresult);
        
        $prodtoolhtml = '';
        if($rows > 0){
        	$prodtoolhtml = '<div id="divPrint5" class="ld-pop-container padT28 padB0" style="display: none;">
                                <div class="ld-pop-contnet-title-items">
                                    <div class="ld-pop-contnet-title-item">'.getFixedLabel('PRODUCTENTRYFIELDS').'</div>
                                </div>
                            </div>
                            <div id="divPrint5_1" class="ld-pop-container ld-table-container ld-table-container-lines" style="display: none;">
                               <table class="DetailContentTable linefeed" width="100%" cellspacing="0" cellpadding="0" border="0">
                                    <thead>
                                        <tr>
                                            <th width="10%">'.getFixedLabel('NORMALNAME').'</th>
                                            <th width="23%">'.getFixedLabel('Value').'</th>
                                            <th width="10%">'.getFixedLabel('NORMALNAME').'</th>
                                            <th width="23%">'.getFixedLabel('Value').'</th>
                                            <th width="10%">'.getFixedLabel('NORMALNAME').'</th>
                                            <th width="23%">'.getFixedLabel('Value').'</th>
                                        </tr>
                                    </thead>
                                    <tbody>
                                        <tr>';
        	for($i=0;$i<$rows;++ $i){
        		$columnname = $adb->query_result($profldresult,$i,'columnname');
        		$fieldlabel = $adb->query_result($profldresult,$i,'fieldlabel');
                //兼容V6.1版本之前的打印
                if($cur_module=='ServiceContracts'&&(strtolower($columnname)=='servicecontracts_end_date'||strtolower($columnname)=='servicecontracts_start_date'))
                {
                    if(strtolower($columnname)=='servicecontracts_end_date')
                    {
                        $columnname='end_date';
                    }
                    else
                    {
                        $columnname='start_date';
                    }
                }
        		$prodtoolhtml .= '<td><span>'.$fieldlabel.'</span></td>
                                  <td><span>[var.productdetails_'.$columnname.'_products]</span></td>';
        		if(($i+1)%3 == 0){
        			$prodtoolhtml .= '</tr><tr>';
        		}
        	}
             
        	if($i%3 != 0){
        		$k = 3-($i%3);
        		for($j=0;$j<$k;++ $j){
        		   $prodtoolhtml .= '<td><span></span></td>
                                     <td><span></span></td>';
        		}
        	}
        	$prodtoolhtml .= '</tr></tbody></table></div>';
        }
}
else if(get_file_address($cur_module,$cur_module.'DetailFieldsHtml'))
{
     $tabname_detail=$cur_focus->Detail_table;
     $tabname_detailscf=$cur_focus->Detail_table_scf;
     $detail_table_index=$cur_focus->Detail_table_id;

     //BUG0076341 lius 20231130 销售部审批-广告申请表单的打印模板 安装位置图片附件字段不显示(附件不支持打印不应该显示)
      $sql="select DISTINCT tablename,columnname,ld_tranlabel.fieldlabel from ld_tabdetailfield
            inner join ld_tranlabel on ld_tranlabel.Relateid=ld_tabdetailfield.tabdetailfieldid
            where ld_tabdetailfield.tabid=$tabid and ld_tranlabel.languagetype='$languageType' and ld_tranlabel.trantable='ld_tabdetailfield'
             and ld_tranlabel.tabid=$tabid  and presence in(0,2) and ld_tabdetailfield.fieldtype not in('Attachment') and  ld_tabdetailfield.tablename in('$tabname_detail','$tabname_detailscf') ORDER BY sequence";
      
       $result=$adb->pquery($sql,array());
       $rows=$adb->num_rows($result);      
        $prodtoolhtml='<div class=" VariableDivTitle marT10">'.getTranstab($cur_module).getFixedLabel('DETAIL').'</div>
            <table class=" VariableTable  borderL" width="100%" cellspacing="0" cellpadding="5" border="0">
              <tbody>
                <tr>';
        $prodtoolhtml .= '<td width="8%">'.getFixedLabel('SEQUENCE').'</td><td width="25%">[var.'.strtolower($cur_module).'details_#_'.strtolower($cur_module).']</td>';
      
        for($i=0;$i<$rows;$i++)
        {
            //收款单有在ld_tabdetailfield表中有entitytype字段
            $columnname = $adb->query_result($result,$i,'columnname');
            $tabdetailcolumns[$columnname]=$columnname;
        }
        $ik=0;
        	for($i=0;$i<$rows;++ $i){
        		$columnname = $adb->query_result($result,$i,'columnname');
        		$fieldlabel = $adb->query_result($result,$i,'fieldlabel');
               if($columnname=='entitytypeid'&&!array_key_exists($columnname,$tabdetailcolumns))
               {
                $prodtoolhtml .= '<td width="8%">'.getFixedLabel('SOURCETYPE').'</td><td width="25%">[var.'.strtolower($cur_module).'details_entitytype_'.strtolower($cur_module).']</td>';   
                $ik++;
               }
        		$prodtoolhtml .= '<td width="8%">'.$fieldlabel.'</td>
                                    <td width="25%">[var.'.strtolower($cur_module).'details_'.$columnname.'_'.strtolower($cur_module).']</td>';
        		$ik++;
                if(($ik+1)%3 == 0){
        			$prodtoolhtml .= '</tr><tr>';
        		}
                
        	}
             
             $i++;
             $ik++;
        	if($ik%3 != 0){
        		$k = 3-($ik%3);
        		for($j=0;$j<$k;++ $j){
        		   $prodtoolhtml .= '<td width="8%">&nbsp;</td>
                                    <td width="26%">&nbsp;</td>';
        		}
        	}
        	$prodtoolhtml .= '</tr></tbody></table>';
}
$smarty->assign("haveProductDetails",$haveProductDetails);

//获取客户首要联系人信息
$query = 'select fieldlabel from ld_tranlabel 
where tabid = 6 and ld_tranlabel.languagetype = ?
and Relateid = (select blockid from ld_blocks where blocklabel = \'LBL_ACCOUNT_PRIMARYCONTACT\' and tabid = 6)';
$result = $adb->pquery($query,array($languageType));
$block_fieldlabel = $adb->query_result($result,0,0);
require( globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
$sqlcontact = 'select ld_field.columnname,ld_field.tablename,ld_field.fieldname, ld_tranlabel.fieldlabel as tranlabel  FROM ld_field 
                inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
			where  ld_tranlabel.trantable=\'ld_field\' and  ld_tranlabel.tabid=6
and ld_field.tablename in(?,?,?) and ld_field.presence in(0,2)
and ld_field.tabid=6 and languagetype = ? order by ld_field.sequence asc,ld_field.fieldid asc,ld_tranlabel.languagetype desc';

$resultcontact=$adb->pquery($sqlcontact,array('ld_contactdetails','ld_contactscf','ld_contactaddress',$languageType));
$sqlcontactrows = $adb->num_rows($resultcontact);
if($sqlcontactrows > 0){
	for($i=0;$i<$sqlcontactrows;++ $i){
		$cacheacctcontfld[$i]['fieldlabel'] = $adb->query_result($resultcontact,$i,'tranlabel');
		$cacheacctcontfld[$i]['print'] = '[var.contactdetails_' . $adb->query_result($resultcontact,$i,'columnname') . '_Accounts]';
	}
}
$smarty->assign('BLOCKFIELDLABEL',$block_fieldlabel);
$smarty->assign('ACCTCONTFLD',$cacheacctcontfld);
$smarty->assign('PRODTOOLHTML',$prodtoolhtml);
$smarty->assign("PRINTTABS",$printtabs);
$smarty->assign("PRINTTABID",$tabid);
$smarty->assign('CURRENT_USERID',$current_user->id);
$smarty->assign('OEM_CRM',$common_version['oem_crm']);

//@edit:liushuai,2020-8-6,reason:1000994/打印模板定制审批历史中增加“手写签名”变量
//判断手写签名是否开启
if(!isset($global_regop))
    $global_regop=RegOp::getInstance();
$smarty->assign('AUTOGRAPH',$global_regop->gethandleWriteSign_interface());

if(!empty($type)){// XUQIU1000367 打印模板优化--新增Word和Excel打印模板--第一版（参考纷享）
    $smarty->assign("TYPE",$type);
    $arr['templatetype'] = $type;

    // 预置打印模板路径
    $default_template = $cur_module.'Default.';
    if($type == 'Excel'){
        $default_template .= 'xlsx';
    }else{
        $default_template .= 'docx';
    }
    $default_filepath = 'templatePrintFile/'.$default_template;

    if(!file_exists($default_filepath)){
        $default_filepath = '';
    }
    $cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
    $default_filepath = $cls_AESencryptionbykeyobj->getencryption($default_filepath);
    $smarty->assign("DefaultTemplate",$default_filepath);
}

$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('LBL_PRINT_TEMPLATE');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$str=$smarty->fetch("createtemplatePrint.tpl");
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
exit();
?>