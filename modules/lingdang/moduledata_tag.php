<?php
/*
*edit: chj
*date: 2020/10/19
*reason: 添加标签
*/
global  $current_language, $currentModule, $theme,$current_user;
global $adb;
$smarty = new lingdangCRM_Smarty();
$module = $_REQUEST['module'];
$record = $_REQUEST['record'];
crm_load_class_file('cls_moduledata_tag','include/utils');
$cls_moduledata_tag = new cls_moduledata_tag($module,$record);
$is_admin = is_admin($current_user);
$smarty->assign('IS_ADMIN',$is_admin);
$tag = [];
$tag_id = [];
$tag_type = [];
//标签保存
if($_REQUEST['ajax'] == 'true' && $_REQUEST['save'] == 'true'){
	$_REQUEST['diony']='diony';
	if(!empty($_REQUEST['new_moduledata_tag'])|| $_REQUEST['new_moduledata_tag'] === 0 || $_REQUEST['new_moduledata_tag'] === '0'){ //BUG0065998 2023-5-9 xxy 添加标签无法添加名为“0”的标签,改为可以添加
		$duplicate_tag = $cls_moduledata_tag->duplicateTagForUser($_REQUEST['new_moduledata_tag']);
		if($duplicate_tag == 'no'){
			ConvertTojsonString(-1,array('msg'=>getFixedLabel("NewTagalreadyexists")),"error");
		}
	}
	$cls_moduledata_tag->save($_REQUEST['selected_moduledata_tag'],$_REQUEST['new_moduledata_tag'],$_REQUEST['corp_tag']);
	$moduledata_tag = $cls_moduledata_tag->getModuledataTagForUser();
	if(!empty($moduledata_tag)){
		foreach($moduledata_tag as $key=> $tag_info){
			$tag[] = $tag_info['tag'];
			$tag_type[] = $tag_info['tag_type'];
            $tag_id[] =$key;
		}
	}
	ConvertTojsonString(1,array('tag'=>implode(',',$tag),'tag_type'=>implode(',',$tag_type),'tag_id'=>implode(',',$tag_id)),"success");
}
//设置可选标签下拉框
if($_REQUEST['ajax'] == 'true' && $_REQUEST['setSelect'] == 'true' && !empty($_REQUEST['select_module_tag_json'])){
/*	$select_module_tag_json = ldcrm_json_decode($_REQUEST['select_module_tag_json']);
	foreach($select_module_tag_json as $tag_info){
		$tag_display[$tag_info['tag_id']] = $tag_info['tag_display'];
		$tag_id_arr[] = $tag_info['tag_id'];
	}*/
    $tag_id_arr=[];
    $tag_display=[];
   $tag_arr= $cls_moduledata_tag->getAllModuleTagForSequence();
	//chj 2021/3/5 44875: （https://61mis.com/kfbcrm [^]）进入客户的详情界面点击新增标签，然后再点击小齿轮，弹出的新增页面没有数据，实际上在选择可用标签的是时候是有数据的。
    foreach($tag_arr as $taginfo)
    {
        $tag_id_arr[]=$taginfo['tag_id'];
        $tag_display[$taginfo['tag_id']]='list-item';
        
    }
	$tag_id = implode(',',$tag_id_arr);
	$module_tag = $cls_moduledata_tag->getModuleTagForId($tag_id);
	$headtitle = getFixedLabel("EDITPICKLIST");
    $table .= '<div class="ld-pop-container ld-table-container ld-table-container-lines"><div style="max-height:350px;width: 100%;overflow-y:auto;" id="dv_scroll">';
    $table .= '<table name="moduletagcontent" class="" border="0" cellpadding="0" cellspacing="0" width="100%"><input type="hidden" name="deleted_tag_id" value="" >';
    $table .= '<thead><tr>';
    $table .= '<th>'.getFixedLabel('MAILNAME').'</th>';
    $table .= '<th style="width: 22%;">'.getFixedLabel('OPERATING').'</th>';
    $table .= '</tr></thead><tbody>';
    $i = 1;
	$count_module_tag = sizeOf($module_tag);
    foreach($module_tag as $val){
        //edit: xll 2023/03/31 BUG0062888 “客户”模块，编辑标签，保存无效（邱：不知道是不是最上面特殊字符问题）
        $val['tag'] = htmlentities($val['tag']);
		$tag_id = $val['tag_id'];
        $table .= '<tr class="ld-category-draggable">';
        $table .= '<td><input tag="combox" class="ld-input-inner" tag_display="'.$tag_display[$tag_id].'" tag_sequence="'.$val['tag_sequence'].'" tag_type="'.$val['tag_type'].'" oldvalue="'.$val['tag'].'" tag_id="'.$tag_id.'" value="'.$val['tag'].'" type="text"></td>';
        $table .= '<td class="sort_td dragings">';
		if($is_admin == 1){
			if($val['tag_type'] == 'personal'){	//个人
				 $table .= '<a class="module-tagger-icon-personal" name="tag_sequence_'.$val['tag_sequence'].'" style="cursor: pointer;margin-right: 6px;" onclick="moduledata_tag.updateTagType(event,ld(this))" title="'.getFixedLabel('Converttocampanytag').'"></a>';
			}else{
				$table .= '<a class="module-tagger-icon-company" name="tag_sequence_'.$val['tag_sequence'].'" style="cursor: pointer;margin-right: 6px;" onclick="moduledata_tag.updateTagType(event,ld(this))" title="'.getFixedLabel('onverttopersonaltag').'"></a>';
			}
		}
        //wym 240109 BUG20240108-93 标签-选择可用标签-设置-改为拖动按钮
        $table .= '<a class="ld-category-icon ld-category-drag drag-handle" style="cursor: pointer;margin-left: -5px;"></a>';
        $table .= '<a class="ld-category-icon ld-category-del" style="cursor: pointer;" onclick="moduledata_tag.delSelectTag(event,ld(this))" title="'.getFixedLabel('DELETE').'"></a>';
        $table .= '</td>';
        $table .= '</tr>';
		$i++;
    }
    $table .= '</tbody></table>';
    $table .= '</div></div>';
	$_REQUEST['diony']='diony';
	$arr['title']=getFixedLabel("SelectavailableTags");
	$arr['oktext']=getFixedLabel("SAVE");
	$arr['canceltext']=getFixedLabel("CANCEL");
	$arr['content']=$table;
	ConvertTojsonString(1,$arr,"success");
}
//修改标签类型（个人、企业）
if($_REQUEST['ajax'] == 'true' && $_REQUEST['updateTagType'] == 'true'){
	$_REQUEST['diony']='diony';
	if(!empty($_REQUEST['tag_id']) && !empty($_REQUEST['tag_type'])){
		$cls_moduledata_tag->updateTagType($_REQUEST['tag_id'],$_REQUEST['tag_type']);
		ConvertTojsonString(1,array(),"success");	
	}
	ConvertTojsonString(-1,array(),"success");
}
//标签下拉框保存
if($_REQUEST['ajax'] == 'true' && $_REQUEST['saveSelect'] == 'true'){
	$_REQUEST['diony']='diony';
	if(!empty($_REQUEST['tag_combox_json'])){
	    //edit: xll 2023/03/31 BUG0062888 “客户”模块，编辑标签，保存无效（邱：不知道是不是最上面特殊字符问题）
		$tag_combox_array = json_decode($_REQUEST['tag_combox_json'],true);
		if(!empty($tag_combox_array)){
			$sequence = 1;
			foreach($tag_combox_array as $tag_info){
				$cls_moduledata_tag->updateTag($tag_info['tag_id'],$tag_info['tag'],$sequence);
				$sequence++;
			}
		}	
	}
	if(!empty($_REQUEST['deleted_tag_id'])){
		$cls_moduledata_tag->deleteTag($_REQUEST['deleted_tag_id']);
	}
    
    //edit: xll 2023/05/05 BUG0065787 编辑已有标签时，标签类型转换后保存，当前标签栏对应标签颜色未改变，且可选标签下拉框选项不应包含已选标签
    $moduledata_tag = $cls_moduledata_tag->getModuledataTagForUser();
	if(!empty($moduledata_tag)){
		foreach($moduledata_tag as $tag_id => $tag_info){
			$tag_type[$tag_id] = $tag_info['tag_type'];
		}
	}
    $comboxjson = $cls_moduledata_tag->getAllModuleTag();
    //返回已选标签类型
    $moduledata_taglist = array('tag_type'=>$tag_type,'comboxjson'=>$comboxjson);
	ConvertTojsonString(1,$moduledata_taglist,"success");
}
$all_moduledatalabelforuser = $cls_moduledata_tag->getModuledataTagForUser();
if(!empty($all_moduledatalabelforuser)){
	foreach($all_moduledatalabelforuser as $id => $tag_info){
		$tag[$id] = $tag_info['tag'];
		$tag_id[] = $id;
		$tag_type[$id] = $tag_info['tag_type'];
	}
}
//当前用户设置的所有企业标签和个人标签
$all_modulelabel = $cls_moduledata_tag->getTabByUserOrCompany();
if(!empty($all_modulelabel)){
	foreach($all_modulelabel as $tag_info){
		$stag_id = $tag_info['tag_id'];
        $allmodulelabel[$stag_id] = $tag_info;

		if(!empty($tag[$stag_id])){
			continue;
		}
        $option_label_id .=  $stag_id . ",";
		$modulelabel[] = $tag_info;
	}
}

$smarty->assign('MODULE',$module);
$smarty->assign('RECORD',$record);
$smarty->assign('OPTION_LABEL_ID',$option_label_id);
$smarty->assign('MODULELABEL',$modulelabel);
$smarty->assign('ALL_MODUELDATAFORUSER',$tag);
$smarty->assign('MODULE_LIST_TAG',htmlentities(implode(',',$tag)));
//$list_tag_id = array_flip($all_moduledatalabelforuser);
$smarty->assign('MODULE_LIST_TAG_ID',implode(',',$tag_id));
$smarty->assign('MODULE_LIST_TAG_TYPE',implode(',',$tag_type));
$_REQUEST['diony']='diony';
$arr['title'] = getFixedLabel('CREATE').'/'.getFixedLabel('SELECT').getFixedLabel('Tag');
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['allmodulelabel']=$allmodulelabel;
$ismodulemapedit=$_REQUEST['ismodulemapedit'];
if (isset($_REQUEST['ismodulemapedit']) && $_REQUEST['ismodulemapedit'] != ''){
    $smarty->assign('ismodulemapedit',$ismodulemapedit);
    $str=$smarty->fetch("modulemapdata_tag.tpl");
}else{
    $str=$smarty->fetch("moduledata_tag.tpl");
}
$arr['content']=$str;
ConvertTojsonString(1,$arr,"success");
?>