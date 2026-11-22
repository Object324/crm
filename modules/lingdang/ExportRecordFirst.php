<?php
//zkt 20231013 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $currentModule,$adb;
global $current_user;
unset($_SESSION[$currentModule][$current_user->id]['export']);

$strhtml='<div class="ld-public-content-small">
		<form method="post">
		<div class="ld-form-item-div">
    		<div class="ld-form-item-label">'.getFixedLabel('EXPORTDATATITLE').'</div>
    		<div class="ld-form-item-content">
        		<select class="ld-select-inner" name="search_type">
            		<option value="includesearch">'.getFixedLabel('ExportSearchResults').'</option>
            		<option value="selecteddata">'.getFixedLabel('ExportSelectedRecords').'</option>
        		</select>
    		</div>
		</div>
		<div class="ld-form-item-div">
    		<div class="ld-form-item-label">'.getFixedLabel('ExportFileFormat').'</div>
    		<div class="ld-form-item-content">
        		<select class="ld-select-inner" name="exportformat">
            		<option value="exportexcel">'.getFixedLabel('ExportFileFormatExcel').'</option>
            		<option value="exportcsv">'.getFixedLabel('ExportFileFormatCSV').'</option>
        		</select>
    		</div>
		</div>';
//带有分录的模块显示导出样式
$display = 'display:none;';
$exportdetail = 'no';
if(get_file_address($currentModule,"ProductDetails")||get_file_address($currentModule,'ContactsDetails')
    ||(get_file_address($currentModule,'VendorsDetails') && $currentModule != 'Home')
    ||get_file_address($currentModule,$currentModule.'DetailFieldsHtml')||$module=='Documents' || $module=='Attachment'){
    $display = '';
    $exportdetail = 'yes';        
}
    
    $exportstyle_arr = array('multicolheader','firstcolheader','onlycolheader');
    $exportstyle_selected = '';
    //zkt 20221104 BUG0058126通用账套默认值修改：所有带分录单据导出时，导出样式默认值改为第二个“导出明细：单据头字段仅显示首行”。
    if($exportdetail=='yes'){
        $exportstyle_selected = 'firstcolheader';
    }
    //获取数据库设置的值
    $sql = 'select * from ld_module_setting_byuser where type=? and label=? and userid=? and modulename=?';
    $result = $adb->pquery($sql,array('Export','exportstyle',$current_user->id,$currentModule));
    if($adb->num_rows($result)>0){
        $exportstyle_selected = $adb->query_result($result,0,'content');
    }
    
    $tmphtml = '';
    $tmphtml = '<div class="ld-form-item-div" style="'.$display.'">
		<div class="ld-form-item-label">'.getFixedLabel('Exportstyles').'</div>
		<div class="ld-form-item-content">
		<select class="ld-select-inner" name="export_style" style="width: 92%;">';
        foreach($exportstyle_arr as $tmpexportstyle){
            $selected = '';
            if($tmpexportstyle == $exportstyle_selected){
                $selected = 'selected';
            }
            $tmphtml .= '<option value="'.$tmpexportstyle.'" '.$selected.'>'.getFixedLabel('Export'.$tmpexportstyle).'</option>';
        }
	$tmphtml .='</select><b class="icon-categorybtn categorymanager-set cursorPointer" name="export_style_setting" id="export_style_setting" style="margin: 0px 0 0 5px;" title="'.getFixedLabel('SetDefaultValue').'"></b>
		</div>
		</div>';
$strhtml.= $tmphtml;

$strhtml.='</form>
		</div>
		<div class="E_pbtn" id="export_foot">  
        <input name="exportfirst_btnok" id="exportfirst_btnok" class="E_pbtnok ld-button ld-button-primary" value="'.getFixedLabel('EXPORT').'"  type="button">
        <input name="button" class="E_pbtncancel ld-button ld-button-cancel" value="'.getFixedLabel("CANCEL").'" id="export_btncancel" type="button" onclick="msgConfirm()"> </div>';

  
    $_REQUEST['diony']='yes';

    //$arr['title']=getFixedLabel("EXPORT");
    global $languageType;
    if($languageType == 'en') {
        $arr['title'] = getFixedLabel("EXPORT") .' '. getTranstab($currentModule);
    }
    else{
        $arr['title'] = getFixedLabel("EXPORT") . getTranstab($currentModule);
    }
    $arr['content']=$strhtml;
    ConvertTojsonString(1,$arr,'success');
?>