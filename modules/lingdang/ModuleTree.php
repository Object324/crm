<?php
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $adb,$current_user,$currentModule;
$smarty=new lingdangCRM_Smarty();
$_REQUEST['diony']='diony';

//设置session
if(!empty($_REQUEST['setsession']) && $_REQUEST['setsession'] == 'yes')
{
    //zkt 20230419 (没有模块权限时产品模块权限选择产品)BUG0065162 http://81.70.87.230:85/crm/（沐宸科技）：项目设备清单选择产品时，单击左侧树结构右侧产品无变化；
    $setsessionmodule = $currentModule;
    if(isset($_REQUEST['setsessionmodule'])){
        $setsessionmodule = $_REQUEST['setsessionmodule'];
    }
    crm_load_class_file('cls_Module_Tree','include/utils');
    $cls_module_tree = new cls_Module_Tree($setsessionmodule);
    $selectrecord = $_REQUEST['selectrecord'];
    $setsessionreturn = array();
    $data = array();
    $datakeys = array();
    if(!empty($selectrecord)&&$selectrecord!='0')
    {
        //设置$_SESSION
        $moduletreearr = array();
        if(isset($_REQUEST['moduletreejson'])&&!empty($_REQUEST['moduletreejson']))
        {
            $moduletreearr = ldcrm_json_decode($_REQUEST['moduletreejson']);
        }
        $_SESSION['module_list_tree'][$setsessionmodule] = array('selectrecord'=>$selectrecord,'list'=>$moduletreearr);

        //获取下级列表
        if(!empty($_REQUEST['getdependency']) && $_REQUEST['getdependency'] == 'yes')
        {
            $sourcefield = $_REQUEST['sourcefield'];
            $targetfield = $_REQUEST['targetfield'];
            $result = $adb->pquery('select * from ld_picklist_values where id = ?',array($selectrecord));
            if($adb->num_rows($result)>0){
                $sourcevalue = $adb->query_result($result,0,'listvalue');
                $data = $cls_module_tree->getFieldTargetDependency($sourcefield,$targetfield,$sourcevalue);
                //zkt 20220221 0050052: （81mis.com/kfbtest/index.php）产品管理》左侧树状图，树状图的选项顺序和级联设置的选项顺序不一样
                $datakeys = is_array($data['list'])?array_keys($data['list']):[];
            }
        }
    }
    else
    {
        $_SESSION['module_list_tree'][$setsessionmodule] = array('selectrecord'=>0,'list'=>array());
    }
    
    $setsessionreturn['dependencymoduletreelist'] = $data;
    $setsessionreturn['dependencymoduletreelistseq'] = $datakeys;
    ConvertTojsonString(1,$setsessionreturn,"success");
    
}
elseif(isset($_REQUEST['setexpand']) && !empty($_REQUEST['setexpand']))
{
    //树结构保存用户 展开收起状态
    $expand = trim($_REQUEST['setexpand']);//yes or no
    if (empty($expand)) $expand = 'yes';
    setUsersettingByLabel($currentModule,$current_user->id,'structuretree_expend',$expand);
    ConvertTojsonString(1,array(),"success");
}
elseif(isset($_REQUEST['setwidth']) && !empty($_REQUEST['setwidth']))
{
    //树结构保存用户 宽度
    $width = trim($_REQUEST['setwidth']);
    if (empty($width)) $expand = '220';
    setUsersettingByLabel($currentModule,$current_user->id,'structuretree_width',$width);
    ConvertTojsonString(1,array(),"success");
}

$focus=CRMEntity::getInstance($currentModule);
//$fieldobj=Field::getInstance($currentModule,$adb);
$fieldobj=$focus->fieldobj;
//获取树结构分组字段的下级字段
$moduleFields=$fieldobj->getModuleFields();
if(!empty($_REQUEST['getFieldForPickListDependency']) && $_REQUEST['getFieldForPickListDependency'] == 'yes' && !empty($_REQUEST['fieldname'])){
	$data[] = $_REQUEST['fieldname'];
	$tree_field = getPickListDependencies($_REQUEST['fieldname'],$data);
	if(sizeOf($tree_field) == 1){
		ConvertTojsonString(1,array(),"success");
	}
	$kong = '';
	foreach($tree_field as $fieldname){
		$fieldinfo = $moduleFields[$fieldname];
		if(!empty($fieldinfo)){
			$treefield_dependency[$fieldname] = $kong . $fieldinfo->getFieldLabelKey();
			$kong .= '&nbsp;&nbsp;&nbsp;';
		}
	}
	ConvertTojsonString(1,$treefield_dependency,"success");
}
//树结构设置保存
if(!empty($_REQUEST['save']) && $_REQUEST['save'] == 'yes'){
	$deleted = 1;
	if($_REQUEST['is_module_tree'] == 'true'){
		$deleted = 0;
        if(empty($_REQUEST['tree_fieldname'])){
    		ConvertTojsonString(-2,array(),getFixedLabel('LBL_PLEASE_SELECT').getFixedLabel('Treestructuregroupingfield'));
    	}
	}
	$query = "select id from ld_module_tree where module = ?";
	$result = $adb->pquery($query,array($currentModule));
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		$tree_id = $adb->query_result($result,0,0);
		$query = "update ld_module_tree set fieldname = ?,deleted = ? where module = ?";
		$adb->pquery($query,array($_REQUEST['tree_fieldname'],$deleted,$currentModule));
        $query = "delete from ld_module_tree_field where tree_id = ?";
	    $adb->pquery($query,array($tree_id));
	}else{
	    if($deleted == 0)
        {
          $query = "insert into ld_module_tree(module,fieldname,deleted) values(?,?,?)";
		  $adb->pquery($query,array($currentModule,$_REQUEST['tree_fieldname'],$deleted));
		  $tree_id = $adb->getLastInsertID();
        }
	}
	if(!empty($_REQUEST['tree_field_json'])&&$deleted == 0){
		$tree_field_json = ldcrm_json_decode($_REQUEST['tree_field_json']);
		$sequence = 1;
		foreach($tree_field_json as $tree_field_string){
			$tree_field_arr = explode('__',$tree_field_string);
			$query = "insert into ld_module_tree_field(tree_id,fieldname,deleted,sequence) values(?,?,?,?)";
			$deleted = 1;
			if($tree_field_arr[1] == 'true'){
				$deleted = 0;
			}
			$adb->pquery($query,array($tree_id,$tree_field_arr[0],$deleted,$sequence));
			$sequence++;
		}
	}
	ConvertTojsonString(1,array(),"success");
}
$smarty->assign('is_module_tree',1);
$smarty->assign('tree_field_cnt',0);
crm_load_class_file('cls_Module_Tree','include/utils');
$cls_module_tree = cls_Module_Tree::getInstance($currentModule);
//$cls_module_tree->getFieldTargetDependency('cf_4182','cf_4183',333);
$tree_info = $cls_module_tree->getTree();

if(!empty($tree_info)){
	$smarty->assign('is_module_tree',$tree_info['deleted']);
	$smarty->assign('tree_fieldname',$tree_info['fieldname']);

	$tree_field = [];
	if(!empty($tree_info['tree_field'])){
        $tmp_fieldname_first = $tree_info['tree_field'][0]['fieldname'];//最上级字段fieldname
        $dependency_tree_field[] = $tmp_fieldname_first;//级联字段数组
        $tmp_tree_field_arr = $tree_info['tree_field'];
        //zkt 20230914 BUG0071730  	kfbcrm-客户-树结构设置-开启树结构 点击保存，不生效--加载界面时,应显示所有下级字段
        //获取下级字段
        $dependency_tree_field = getPickListDependencies($tmp_fieldname_first,$dependency_tree_field);

        $kong = '';
		foreach($tmp_tree_field_arr as $key => $info){
			$disabled = '';
			$info['fieldlabel'] = $kong . $info['fieldlabel'];
			if($key == 0){
				$disabled = 'disabled=""';
			}else{
				if(!empty($tmp_tree_field_arr[$key+1]) && $tmp_tree_field_arr[$key+1]['deleted'] == 0){
					$disabled = 'disabled=""';
				}
			}
			$info['disabled'] = $disabled;
            if(in_array($info['fieldname'],$dependency_tree_field)){
                $tmpindex = array_keys($dependency_tree_field,$info['fieldname'])[0];
                unset($dependency_tree_field[$tmpindex]);
            }
			$tree_field[] = $info;
			$kong .= '&nbsp;&nbsp;&nbsp;';
		}
        if(sizeOf($dependency_tree_field)>1){
            foreach($dependency_tree_field as $fieldname){
                $fieldinfo = $moduleFields[$fieldname];
                if(!empty($fieldinfo)){
                    $tmpinfo = array();
                    $tmpinfo['fieldname'] = $fieldname;
                    $tmpinfo['fieldlable'] = $fieldinfo->getFieldLabelKey();
                    $tmpinfo['deleted'] = 0;
                    $info['disabled'] = " ";
                    $tree_field[] = $info;
                    $kong .= '&nbsp;&nbsp;&nbsp;';
                }
            }
        }
	}
	$smarty->assign('tree_field_cnt',sizeOf($tree_field));
	$smarty->assign('tree_field',$tree_field);
}
$field_tree = [];
foreach($moduleFields as $fieldinfo){
	$uitype = $fieldinfo->getUIType();
	$fieldname = $fieldinfo->getFieldName();
	$label = $fieldinfo->getFieldLabelKey();
	if($uitype == 15){
		$field_tree[$fieldname] = $label;
	}
}
//刷新分组字段下拉框的值
if(!empty($_REQUEST['RefreshGroupValues']) && $_REQUEST['RefreshGroupValues'] == 'yes'){
    $arr['FIELDTREE']=$field_tree;
    $arr['FIELDNAME']=$tree_info['fieldname'];
    $arr['field_length']=sizeof($field_tree);
    ConvertTojsonString(1,$arr,"success");
}
$ccfield = $focus->getCreateColumnName();
$smownerid = $focus->getSmownerColumName();
$selectmodule = $_REQUEST['module'];
//zxm @date:2024/10/23 @reason: 订货商城 用的是产品模块的字段
if($selectmodule=='ShoppingMall'){
    $selectmodule = 'Products';
}
$smarty->assign('selectmodule',$selectmodule);
$smarty->assign('tabid',getTabid($selectmodule));

$smarty->assign('blockid',getmoduleblockid($selectmodule,$ccfield,$smownerid));

$smarty->assign('IS_ADMIN',is_admin($current_user));
$smarty->assign('FIELDTREE',$field_tree);
$smarty->assign('FIELDTREELENGTH',sizeof($field_tree));
$content=$smarty->fetch("ModuleTree.tpl");
$arr['title']=getFixedLabel("treestruturesettings");
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$content;
ConvertTojsonString(1,$arr,"success");


function getPickListDependencies($fieldname,&$data){
	global $adb,$currentModule;
    $modulename = $currentModule;
    if($currentModule=='ShoppingMall'){
        $modulename = 'Products';
    }
	$tabid = getTabid($modulename);

    //zkt 树结构加载下级字段信息，未启用字段应获取不到
	$query = "select targetfield from ld_picklist_dependency 
            LEFT JOIN ld_field on ld_field.tabid=ld_picklist_dependency.tabid and ld_field.fieldname=ld_picklist_dependency.targetfield
             where ld_picklist_dependency.tabid = ? and sourcefield = ? and ld_field.presence in (0,2,5) limit 1";
	$result = $adb->pquery($query,array($tabid,$fieldname));
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		for($i = 0; $i<=$num_rows; $i++){
			$targetfield = $adb->query_result($result,$i,'targetfield');
			if(!empty($targetfield)){
				
				$data[] = $targetfield;
				
				getPickListDependencies($targetfield,$data);
			}
		}
	}
	return $data;
}

//hjz 获取当前模块的tabid和创建人字段找到blockid传入tpl文件中,盘点单需要特殊判断
function getmoduleblockid($selectmodule,$ccfield,$smownerid){
    global $adb;
   	$tabid = getTabid($selectmodule);
    $query = "SELECT * from ld_field where tabid = ? and columnname = ?";
    if($tabid != 76){
        $result = $adb->pquery($query,array($tabid,$ccfield)); 
    }else{
        $result = $adb->pquery($query,array($tabid,$smownerid)); 
    }
   	$num_rows = $adb->num_rows($result);
    if($num_rows >= 1){
        $blockid = $adb->query_result($result,0,'block');
    }
    return $blockid;
}
?>