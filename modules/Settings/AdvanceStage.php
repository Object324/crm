<?php
/****************************************************************
**edit:chj
**date:2020-05-08
**reason:推进进度条
****************************************************************/
global $theme,$current_user;
$code=1;
$msg='success';

if(!empty($_REQUEST['record']) && !empty($_REQUEST['frommodule'])){
	$module = $_REQUEST['frommodule'];
	$record = $_REQUEST['record'];
    //duan 2021-10-19 当前用户没有编辑其他用户或自己单据的权限时，点击推进时给出提示         
               
	crm_load_class_file('cls_module_advance','modules/Settings');
	$cls_module_advance = cls_module_advance::getInstance($module);
	// $cls_module_advance->getWeiXin($record);

	 //die;
	
	//显示推进弹出层
	if($_REQUEST['mode'] == 'show'){
	   $advancestage = $cls_module_advance->get($record);
		$cur_advancestage_value = '';
		//根据新的推进关系，获取可以推进的阶段
        if($cls_module_advance->moduleadvance['method'] == 'field'){//进度跟踪方式:field:字段
            if(isset($_REQUEST['advanceid'])&&$_REQUEST['advanceid']>0){
                $next_advanceid = $_REQUEST['advanceid'];
            }else{
                $next_advanceid = $cls_module_advance->getLastUpdateAdvanceid($record);
            }
            $cls_module_advance->showtype = 'inpopup';//推进操作样式 inpopup:弹出层
            $alltaskinfo_detailview = $cls_module_advance->get_alltaskinfo_detailview($record);
            $tmp_taskinfo_arr = $alltaskinfo_detailview[$next_advanceid];
            $AdvanceRelations = $cls_module_advance->getAdvanceRelationsByuser($record);
            $arr['advancedata'] = $cls_module_advance->getReturnAdvanceData();
            //涉及自动化任务的字段信息
            if(sizeof($cls_module_advance->advancetaskfield_arr)>0){
                $advancefields = $cls_module_advance->advancetaskfield_arr;
                $arr['advancefields'] = $advancefields;
                
                $len = sizeof($advancefields);
                for($i=0;$i<$len;$i++){
                    $tmp_fields = $advancefields[$i];
                    if($tmp_fields['uitype'] == 15 || $tmp_fields['uitype'] == 33){
                        $picklistfield = 'yes';
                    }
                }
                
                if($picklistfield == 'yes'){
                    global $global_pick_list_values,$global_picklist_colors_byvalue;
                    global $global_pick_list_depencyfield;
                    crm_load_class_file('lingdang_DependencyPicklist','modules/PickList');
                    $DependentPicklistFields = lingdang_DependencyPicklist::getDependentPicklistFields($module);
                    $picklistDependencyDatasource = lingdang_DependencyPicklist::getPicklistDependencyDatasource($module);
                    $arr['global_picklist_colors_values']=$global_picklist_colors_byvalue;
                    $arr['picklistcontent']=$global_pick_list_values;
                    $arr['picklistdepency']=$DependentPicklistFields;
                    $arr['picklistdepencyfields']=$global_pick_list_depencyfield;
                }else{
                    $arr['global_picklist_colors_values']=array();
                    $arr['picklistcontent']=array();
                }
            }
            foreach($AdvanceRelations as $tmp_advanceid=>$tmp_relation ){
                if(!empty($tmp_relation['map_module']) && $tmp_relation['map_module'] != 'close'){
                    $map_module_arr = explode(':',$tmp_relation['map_module']);
                    foreach ($map_module_arr as $index => $mmodule) {
                        if(!vtlib_isModuleActive($mmodule)){// 有一个模块未开启则不显示该选项
                            continue 2;
                        }
                    }
                }
                if($tmp_advanceid == $next_advanceid){
                    $cur_advancestage_value = $tmp_relation['stagename_target'];
                    $cur_advancestage_mapmodule = $tmp_relation['map_module'];
                }
                $advance_stage[$tmp_advanceid]['stagename_target'] = $tmp_relation['stagename_target'];
                $advance_stage[$tmp_advanceid]['map_module'] = $tmp_relation['map_module']; // wym XUQIU20240204-09 销售线索可编辑追踪字段
            }
            $advance_stage_allowpush = $advance_stage;

            $smarty->assign('TASKLOG',$tmp_taskinfo_arr['tasklog']);
            $smarty->assign('TASKINFO',$tmp_taskinfo_arr['taskinfo']);
            $smarty->assign('ALLOWEDIT',$tmp_taskinfo_arr['allow_edit']);
            $smarty->assign('STAGENAME',$tmp_taskinfo_arr['stagename']);
            $smarty->assign('pushback_presence','yes');
            $smarty->assign('MODULENAME',$module);

        }else{
            if(!empty($advancestage['advancestage_values'])){
    			foreach($advancestage['advancestage_values'] as $key => $stage){
    				if($stage['cur_flag'] == 'yes'){
    					$cur_advancestage_value = $advancestage['advancestage_values'][$key+1]['value'];
    				}else{
    					$advance_stage[$stage['value']] = $stage['value'];
    				}
    			}
    		}
    		//$columnForDependencyPicklist = $cls_module_advance->getColumnForDependencyPicklist($record);
            //    if(!empty($columnForDependencyPicklist)){
            // 	$advance_stage = $columnForDependencyPicklist;
            // }
            $advance_stage_allowpush = $advance_stage;

            if($cls_module_advance->moduleadvance['pushback'] == 'yes' || is_admin($current_user)){
    			$smarty->assign('pushback_presence','yes');
    		}else{
    			$smarty->assign('pushback_presence','no');
    		}
        }

		$smarty->assign('CUR_ADVANCESTAGE_VALUE',$cur_advancestage_value);
        $smarty->assign('CUR_ADVANCESTAGE_MAPMODULE',$cur_advancestage_mapmodule);
		$smarty->assign('ADVANCE_STAGE',$advance_stage);
        $smarty->assign('ADVANCE_STAGE_ALLOWPUSH',$advance_stage_allowpush);
		$smarty->assign('ISADMIN',$current_user->is_admin);
		$smarty->assign('RECORD',$record);
		$smarty->assign('MODULE',$module);
        $smarty->assign('inpopup','yes');
        $smarty->assign('moduleadvance_method',$cls_module_advance->moduleadvance['method']);

        $arr['method']=$cls_module_advance->moduleadvance['method'];
        $arr['isadmin']=$current_user->is_admin;
		$arr['title']=getFixedLabel("ADVANCE");
		$arr['oktext']=getFixedLabel("SAVE");
        $arr['pushtext']=getFixedLabel("ADVANCE");
		$arr['canceltext']=getFixedLabel("CANCEL");
        $arr['columnfields_value']=$cls_module_advance->focus->column_fields;
		$str=$smarty->fetch("Settings/AdvanceStage.tpl");
		$arr['content']=$str;
	}else if($_REQUEST['mode'] == 'save'){
        $stagename_now = $cls_module_advance->getStagenameNow($record);
        //避免出现并发操作
        if($stagename_now == $_REQUEST['advance_stage_value']){
            ConvertTojsonString(1,array(),'success');
        }
		//保存
		$arr = $cls_module_advance->updateModuleAdvanceStage($record,$_REQUEST['advance_stage_value']);
        $arr["workflow"] = $cls_module_advance->workflow_apiinfo;
		//销售线索模块：当商机状态推进为“商机状态”时“关闭原因”字段无法填写内容。
		if(!empty($_REQUEST['frommodule']) && $_REQUEST['frommodule'] == 'Leads'){
			$query = 'update ld_leads set failurereason=?,modifiedtime="'.date('Y-m-d H:i:s').'" where leadsid = ?';
			$adb->pquery($query,array($_REQUEST['fileurereason'],$record));
		}
        if($cls_module_advance->errorDescription!=''){
            $msg=$cls_module_advance->errorDescription;
            $arr['info'] = 'fieldrule';
            $code='-1';

        }
	}else if($_REQUEST['mode'] == 'complete'){
		//完成
		$cls_module_advance->completeModuleAdvanceStage($record);
	}else if($_REQUEST['mode'] == 'list'){	//显示单据详情页的推进进度条
		$smarty->assign('MODULEADVANCE',$cls_module_advance->get($record));
		$str=$smarty->fetch("DetailView/PopupAdvance.tpl");
		$arr['content']=$str;
	}
}
$_REQUEST['diony']='diony';
ConvertTojsonString($code,$arr,$msg);
exit();
?>