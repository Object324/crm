<?php
global $adb;
if(!empty($_REQUEST['mode'])){
    $workflow_actionsid = (int)$_REQUEST['workflow_actionsid'];
    if(empty($_REQUEST['body_query_type'])) $_REQUEST['body_query_type'] = "form-data";
    $_REQUEST['api_receive_msg'] = $_REQUEST['api_receive_msg'] == 'yes'?'yes':'no';
	if($_REQUEST['mode'] == 'save'){	//新增、编辑
        if ($_REQUEST['action_type'] == 'Link2ERP') $_REQUEST['action_title'] = getFixedLabel('CallLink2ERP');//连接erp默认标题.
		$action_title = $_REQUEST['action_title'];
		$api_url = $_REQUEST['api_url'];
		$json_data = $_REQUEST['json_data'];
		if(!empty($json_data) && $_REQUEST['body_query_type'] == 'json'){
			$array = json_decode($json_data);
			$error = json_last_error();
			if($error >= 1){
				$_REQUEST['diony']='yes';
				ConvertTojsonString(-1,array(''),"error");
			}
		}
		//workflow_actionsid
		if(empty($_REQUEST['workflow_id'])){
			$workflow_id = 1;
			$query = 'select id from ld_workflow_seq limit 1';
			$result = $adb->pquery($query,array());
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				$workflow_id = $adb->query_result($result,0,0) +1;
			}
			$query = 'update ld_workflow_seq set id = ?';
			$adb->pquery($query,array($workflow_id));
		}else{
			$workflow_id = $_REQUEST['workflow_id'];
		}
		if(empty($workflow_actionsid)){
            $sql='select max(sequence) from  ld_workflow_actions where workflow_id=? ';
            $result=$adb->pquery($sql,array($workflow_id));
            $sequence=1;
            if($adb->num_rows($result)>0)
            {
                $sequence=intval($adb->query_result($result,0,0))+1;
            }
               
			$query = "insert into ld_workflow_actions(workflow_id,action_title,action_type,
            api_url,api_jsondata,createdtime,body_query_type,sequence,api_receive_msg) values (?,?,?,?,?,?,?,?,?)";
			$adb->pquery($query,array($workflow_id,$action_title,$_REQUEST['action_type'],$api_url,$json_data
                    ,date('Y-m-d H:i:s'),$_REQUEST['body_query_type'],$sequence,$_REQUEST['api_receive_msg']));
            $workflow_actionsid = $adb->getLastInsertID();
		}else{
			$query = "update ld_workflow_actions set action_title = ?,api_url = ?,api_jsondata = ?,body_query_type=?,api_receive_msg=? where id = ?";
			$adb->pquery($query,array($action_title,$api_url,$json_data,$_REQUEST['body_query_type'],$_REQUEST['api_receive_msg'],$workflow_actionsid));
		}
		if($_REQUEST['action_type'] == 'API'){	//调用API
			if(!empty($workflow_id) && !empty($workflow_actionsid)){
				$query = "delete from ld_workflow_api_parameter where workflow_id = ? and workflow_action_id = ?";
				$adb->pquery($query,array($workflow_id, $workflow_actionsid));

				//post参数
				if(!empty($_REQUEST['post_tr_cnt'])){
					$sequence = 1;
					for($i = 1; $i<=$_REQUEST['post_tr_cnt'];$i++){
						if($_REQUEST['post_tr_display_'.$i] == 'yes'){
                            if (empty($_REQUEST['post_'.$i])) continue; //没有设置参数key，不保存数据库。

							if($_REQUEST['post_parameter_type_'.$i] == 'manual'){
								$parameter_value = trim($_REQUEST['post_manual_'.$i]);
							}else if($_REQUEST['post_parameter_type_'.$i] == 'module_fields'){
								$parameter_value = trim($_REQUEST['post_module_fields_'.$i]);
							}else if($_REQUEST['post_parameter_type_'.$i] == 'system_fields'){
								$parameter_value = trim($_REQUEST['post_system_fields_'.$i]);
							}

							$query = "insert into ld_workflow_api_parameter(workflow_id,workflow_action_id,parameter_name,parameter_type,parameter_value,parameter_description,sequence,workflow_api_type) values (?,?,?,?,?,?,?,?)";

                            $adb->pquery($query,array($workflow_id,$workflow_actionsid,trim($_REQUEST['post_'.$i]),$_REQUEST['post_parameter_type_'.$i],$parameter_value,$_REQUEST['post_description_'.$i],$sequence,'post'));
							$sequence++;
						}
					}
				}

                //code参数
                if($_REQUEST['api_receive_msg'] == 'yes' && !empty($_REQUEST['code_tr_cnt'])){
                    $sequence = 1;
                    for($i = 1; $i<=$_REQUEST['code_tr_cnt'];$i++){
                        if($_REQUEST['code_tr_display_'.$i] == 'yes'){
                            if ($_REQUEST['code_'.$i] === '') continue; //没有设置状态码，不保存数据库。可以为负数和0

                            $parameter_value = $_REQUEST['code_description_'.$i];
                            $query = "insert into ld_workflow_api_parameter(workflow_id,workflow_action_id,parameter_name,parameter_type,parameter_value,parameter_description,sequence,workflow_api_type) values (?,?,?,?,?,?,?,?)";
                            $adb->pquery($query,array($workflow_id,$workflow_actionsid,(int)$_REQUEST['code_'.$i],NULL,$parameter_value,NULL,$sequence,'code'));
                            $sequence++;
                        }
                    }
                }
			}
		}
        else if($_REQUEST['action_type'] == 'Link2ERP'){ //调用连接ERP
            if(!empty($workflow_id) && !empty($workflow_actionsid)){
                $query = "delete from ld_workflow_api_parameter where workflow_id = ? and workflow_action_id = ?";
                $adb->pquery($query,array($workflow_id, $workflow_actionsid));

                //post参数  ERP不能添加自定义传参，实际上仅有一行数据
                if(!empty($_REQUEST['post_tr_cnt'])){
                    $sequence = 1;
                    for($i = 1; $i<=$_REQUEST['post_tr_cnt'];$i++){
                        if($_REQUEST['post_tr_display_'.$i] == 'yes'){
                            if (empty($_REQUEST['post_'.$i])) continue; //没有设置参数key，不保存数据库。

                            if($_REQUEST['post_parameter_type_'.$i] == 'manual'){
                                $parameter_value = trim($_REQUEST['post_manual_'.$i]);
                            }else if($_REQUEST['post_parameter_type_'.$i] == 'module_fields'){
                                $parameter_value = trim($_REQUEST['post_module_fields_'.$i]);
                            }else if($_REQUEST['post_parameter_type_'.$i] == 'system_fields'){
                                $parameter_value = trim($_REQUEST['post_system_fields_'.$i]);
                            }

                            $query = "insert into ld_workflow_api_parameter(workflow_id,workflow_action_id,parameter_name,parameter_type,parameter_value,parameter_description,sequence,workflow_api_type) values (?,?,?,?,?,?,?,?)";

                            $adb->pquery($query,array($workflow_id,$workflow_actionsid,trim($_REQUEST['post_'.$i]),$_REQUEST['post_parameter_type_'.$i],$parameter_value,trim($_REQUEST['post_description_'.$i]),$sequence,'post'));
                            $sequence++;
                        }
                    }
                }

            }
        }
        else if($_REQUEST['action_type'] == 'UpdateFields'){	//更新字段
			if(!empty($workflow_actionsid)){
				$query = "delete from ld_workflow_updatefields where workflow_action_id = ?";
				$adb->pquery($query,array($workflow_actionsid));
				$updatefield_json = json_decode($_REQUEST['updatefields_json_data']);
				foreach($updatefield_json as $json){
					$temp_arr = json_decode($json);
					$query = "insert into ld_workflow_updatefields(workflow_action_id,module,tabid,fieldname,setmode,setvalue) values (?,?,?,?,?,?)";
					$module = $temp_arr[0];
					$tabid = getTabid($module);
					if($temp_arr[4] == 33){
						$temp_arr[3] = str_replace('########',' |##| ',$temp_arr[3]);
					}
					$adb->pquery($query,array($workflow_actionsid,$module,$tabid,$temp_arr[1],$temp_arr[2],$temp_arr[3]));
				}
			}
		}
        else if($_REQUEST['action_type'] == 'ExcuteSql'){
			$query = "delete from ld_workflow_excutesql where workflow_action_id = ?";
			$adb->pquery($query,array($workflow_actionsid));
			$query = "insert into ld_workflow_excutesql(workflow_action_id,query_sql) values (?,?)";
            $excute_sql_content_encry = $_REQUEST['excute_sql_content'];
            $cls_AESencryptionbykeyobj = cls_AESencryptionbykey::getInstance();
            $excute_sql_content = $cls_AESencryptionbykeyobj->getdecryption($excute_sql_content_encry);

			$adb->pquery($query,array($workflow_actionsid,$excute_sql_content));
		}
        else if($_REQUEST['action_type'] == 'AutoShare'){	//自动共享
            $query = "delete from ld_workflow_autoshare where workflow_action_id = ?";
            $adb->pquery($query,array($workflow_actionsid));
            $query = "insert into ld_workflow_autoshare(workflow_action_id,share_setmode,share_setvalue) values (?,?,?)";
            $adb->pquery($query,array($workflow_actionsid,$_REQUEST['autoshare_setmode'],$_REQUEST['autoshare_setvalue']));
        }
	}else if($_REQUEST['mode'] == 'delete'){	//删除
		$workflow_id = $_REQUEST['workflow_id'];
		$query = 'update ld_workflow_actions set deleted = 1 where id = ?';
		$adb->pquery($query,array($_REQUEST['workflow_actionid']));
	}else if($_REQUEST['mode'] == 'status'){	//停用、启用
		$workflow_id = $_REQUEST['workflow_id'];
		$status = 'Active';
		if($_REQUEST['status'] == 'Active'){
			$status = 'Inactive';
		}
		$query = 'update ld_workflow_actions set status = ? where id = ?';
		$adb->pquery($query,array($status,$_REQUEST['workflow_actionid']));
	}
}
$query = "select id,workflow_id,action_title,action_type,api_url,api_jsondata,status from ld_workflow_actions where workflow_id = ? and deleted = 0";
$result = $adb->pquery($query,array($workflow_id));
$num_rows = $adb->num_rows($result);
$table = '';
$workflow_actions = [];
$smarty = new lingdangCRM_Smarty();
if($num_rows >= 1){
	for($i = 0; $i < $num_rows; $i++){
		$rowid = $i + 1;
		$action_title = $adb->query_result($result,$i,'action_title');
		$action_type = $adb->query_result($result,$i,'action_type');
		$status = $adb->query_result($result,$i,'status');
		$id = $adb->query_result($result,$i,'id');
		$temp_action_type = $action_type;
		if($action_type == 'API') {
            $action_type = getFixedLabel('CallAPI');
        }else if($action_type == 'Link2ERP'){
                $action_type = getFixedLabel('CallLink2ERP');
		}else if($action_type == 'UpdateFields'){
			$action_type = getFixedLabel('updatefields');
		}else if($action_type == 'ExcuteSql'){
			$action_type = getFixedLabel('ExcuteSQL');
		}else if($action_type == 'AutoShare'){
            $action_type = getFixedLabel('AUTOSHARE');
        }
        $workflow_actions[$id] = array(
            'action_title' => $action_title,
            'action_type' => $temp_action_type,
            'status' => $status
        );
        /*
		$table .= '<tr id="setting_'.$rowid.'"workflow_actionid="'.$id.'" class="lvtColData dragtrrow" onmouseover="listOnMouseOver(ld(this));" onmouseout="listOnMouseOut(ld(this),\'on\');">';
		$table .= '<td>'.$rowid.'</td>';
		$table .= '<td>'.$action_type.'</td>';
		$table .= '<td>'.$action_title.'</td>';
		$checked = '';
		if($status == 'Active'){
			$checked = 'checked';
		}
		$table .='<td><input type="checkbox" class="second_switch" '.$checked.' onclick="WorkflowCustomization.operateActions(this,event)" tag="status" workflow_actionid="'.$id.'" /></td>';
		$table .= '<td>';
        $table .= '<a class="Anu3_a" onclick="WorkflowCustomization.operateActions(this,event)" action_type="'.$temp_action_type.'" workflow_actionid="'.$id.'" tag="edit">'.getFixedLabel('EDIT').'</a>';
        $table .='<a class="Anu3_a redFont" onclick="WorkflowCustomization.operateActions(this,event)" workflow_actionid="'.$id.'" tag="delete">'.getFixedLabel('DELETE').'</a></td>';
        //edit: xll 2023/07/28 BUG0058814 kfbcrm 工作流程定制---编辑页面---操作里的拖动行图标放到‘编辑’前面----并且拖动后序号应动态变化
        if($num_rows == 1){
            $table .='<a class="drag-handle ld-category-icon ld-category-drag" title="移动" style="cursor:move;display: none;"></a>';
        }else{
            $table .='<a class="drag-handle ld-category-icon ld-category-drag" title="移动" style="cursor:move;"></a>';
            //$table .='<span  class="drag-handle icon-layout2 icon-layout2-move" title="'.getFixedLabel("MOVE").'"style="cursor:move;"></span>';
        }
		$table .='</tr>';
        */

	}
}
//edit: xll 2023/07/31 BUG0070345 kfbcrm-工作流程，编辑保存或新增保存后拖动图标变了
$smarty->assign('WORKFLOW_ACTIONS',$workflow_actions);
$table = $smarty->fetch('WorkflowCustomization/WorkflowCustomizationContentEntries.tpl');
$_REQUEST['diony']='yes';
ConvertTojsonString(1,array('content'=>$table,'workflow_id'=>$workflow_id,'workflow_action_id'=>$workflow_actionsid),"success");
?>