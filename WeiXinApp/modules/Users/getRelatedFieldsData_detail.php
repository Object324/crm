<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/
//获取单据关联信息
global $adb,$current_user;
crm_load_class_file('cls_RelatedEntryField_Data','include/RelatedField');
$relatedfielddata = array();
$data = [];
if(!empty($_REQUEST['clear']) && $_REQUEST['clear'] == 'yes'){
	//清除
	$cls_RelatedEntryField_Data = new cls_RelatedEntryField_Data($_REQUEST['curmodule'],$_REQUEST['trigger_columnname']);
	$relatedfielddata = $cls_RelatedEntryField_Data->getClearData();
}else{
	if(!empty($_REQUEST['curmodule']) && !empty($_REQUEST['trigger_columnname'])){
		$_REQUEST['relatedtype'] = 'trigger';
		$cls_RelatedEntryField_Data = new cls_RelatedEntryField_Data($_REQUEST['curmodule'],$_REQUEST['trigger_columnname']);
		$relatedfielddata = $cls_RelatedEntryField_Data->getData();
		if(!empty($relatedfielddata)){
			$i = 0;
			foreach($relatedfielddata as $relatedinfos){
				foreach($relatedinfos as $infos){
					if($infos['value']){
						foreach($infos['value'] as $columnname => $value){
							$data['list'][$i] = array(
								'bigtype' => $infos['bigtype'],
								'isproductdetails' => $infos['isproductdetails'],
							);
							$data['list'][$i]['columnname'] = $columnname;

                            if(!empty( $infos['parentbigtype'])){
                                $data['list'][$i]['parentbigtype'] = $infos['parentbigtype'];
                            }
                            if(!empty( $infos['relatedmodulefield'])){
                                $data['list'][$i]['relatedmodulefield'] = $infos['relatedmodulefield'];
                            }
                            if($infos['bigtype'] == 'image' || $infos['bigtype'] == 'fileattachment'){
                                $attr_info = [];
                                if(count($value) > 0){
                                    $cls_MyCRMcrypt = new cls_MyCRMcrypt();
                                    for($j=0;$j<count($value);$j++){
                                        $tmp_info = [];
                                        $tmp_info['filename'] = $value[$j]['file_name'];
                                        $tmp_info['filesize'] = $value[$j]['file_size'];
                                        $tmp_info['filetype'] = $value[$j]['file_type'];
                                        $tmp_info['filepath'] = $cls_MyCRMcrypt->decode($value[$j]['file_path']);
                                        $tmp_info['newfile_name'] = $cls_MyCRMcrypt->decode($value[$j]['newfile_name']);
                                        $tmp_info['cloud_path'] = $cls_MyCRMcrypt->decode($value[$j]['cloud_path']);
                                        $tmp_info['id'] = $value[$j]['fileid'];
                                        $tmp_info['storage_location'] = $value[$j]['storage_location'];
                                        $tmp_info['upload_from'] = $value[$j]['upload_from'];
                                        $tmp_info['isEncrypt'] = 'no';
                                        $attr_info[] = $tmp_info;
                                    }

                                }
                                $data['list'][$i]['value'] = $attr_info;
                            }else{
                                $data['list'][$i]['value'] = $value;
                                $data['list'][$i]['hiddenvalue'] = $infos['rawvalue'][$columnname];
                            }

							$i++;
						}
					}
				}
			}
		}
	}
}
$_REQUEST['diony']='diony';
ConvertTojsonString(1,$data,"success");
exit();
	
?>