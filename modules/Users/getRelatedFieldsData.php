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
//zkt 20231018 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
//获取单据关联信息
	global $adb,$current_user;
	crm_load_class_file('cls_ParentRelatedField_Data','include/RelatedField');
	if(!empty($_REQUEST['curmodule']) && !empty($_REQUEST['module_record']) && !empty($_REQUEST['selecttype'])){
		if($_REQUEST['selecttype'] == 'popupselectfield'){
			$cls_ParentRelatedFields = new cls_ParentRelatedField_Data($_REQUEST['curmodule'],$_REQUEST['module_record'],'');
		}else{
			$cls_ParentRelatedFields = new cls_ParentRelatedField_Data($_REQUEST['curmodule'],$_REQUEST['module_record'],$_REQUEST['columnname']);
		}
		//$cls_ParentRelatedFields = new cls_ParentRelatedField_Data($_REQUEST['curmodule'],$_REQUEST['module_record'],$_REQUEST['columnname']);
		$relatedfielddata = $cls_ParentRelatedFields->getEffectValues('html_input');

        $module = $_REQUEST['curmodule'];
        $record = $_REQUEST['module_recordid'];
        $fieldname_arr = array();
        if(isset($_REQUEST['requestvalues'])){
            $requestvalues_arr = ldcrm_json_decode($_REQUEST['requestvalues']);
            foreach($requestvalues_arr as $tmpfieldname=>$tmpfielidvalue)
            {
                $fieldname_arr[$tmpfieldname] = $tmpfielidvalue;
            }
        }
        if($relatedfielddata==null){
            $relatedfielddata = array();
        }
        else{
            //获取被修改后的字段值
            foreach($relatedfielddata as $tmpinde=>$tmpfielddatainfo){
                if(!empty($tmpfielddatainfo)){
                    $tmpfieldname = $tmpfielddatainfo['rawValue']['input_name'];
                    $fieldname_arr[$tmpfieldname] = $tmpfielddatainfo['rawValue']['value'];
                }
            }
        }
        //zkt 20231121 XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制
        //关联带出,获取敏感规则字段值
        crm_load_class_file('cls_fieldSensitiverule','include/fields');
        $fieldSensitiveruleobj=cls_fieldSensitiverule::getInstance($module);
        $fieldSensitiveruleobj->setColumnValuesbyfieldnamearr($fieldname_arr);
        $sensitiveresultinfo = $fieldSensitiveruleobj->getSensitiveResultInfobyFieldnamearr($fieldname_arr,$record);
        if(!empty($sensitiveresultinfo)){
            $tmprelatedfielddata = $relatedfielddata;
            foreach($relatedfielddata as $tmpindex=>$tmpfielddatainfo){
                if(!empty($tmpfielddatainfo)){
                    $tmpfieldname = $tmpfielddatainfo['rawValue']['input_name'];
                    $tmpfieldinfo = $fieldSensitiveruleobj->focus->fieldobj->getFieldInfoobjByKey('fieldname',$tmpfieldname);
                    if(isset($sensitiveresultinfo[$tmpfieldname])&&!empty($tmpfieldinfo)){
                        $tmprelatedfielddata[$tmpindex]['rawValue']['value'] = $sensitiveresultinfo[$tmpfieldname]['secretvalue'];
                        $tmprelatedfielddata[$tmpindex]['value']['value'] = $sensitiveresultinfo[$tmpfieldname]['secretvalue'];
                        $tmprelatedfielddata[$tmpindex]['rawValue']['sensitiveencryptvalue'] = $sensitiveresultinfo[$tmpfieldname]['encryptvalue'];
                        $tmprelatedfielddata[$tmpindex]['rawValue']['havesensitivevalue'] = $tmpfieldinfo->gethavesensitivevalue();
                    }
                    $fieldname_arr[$tmpfieldname] = $tmpfielddatainfo['rawValue']['value'];
                }
            }
            $relatedfielddata = $tmprelatedfielddata;
        }
        //editor:gyq_161 reason:优化返回值，避免不是json造成的js报错   2019/12/3 17:45
		echo json_encode($relatedfielddata);
	}

	
?>