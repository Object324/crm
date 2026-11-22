<?php
/**
 * edit:andrew
 * date:2015-6-2
 * reason:弹窗选择客户
 **/
 require_once(globalStatic::$root_directory.'modules/PickList/DependentPickListUtils.php');
global $app_strings, $default_charset;
global $currentModule, $current_user;
global $theme, $adb;
if(isset($_REQUEST['selectmodule']))
{
    $isFaqType=1;
	$row = 1;//控制checkbox显示行
	$rowDisplay = 0;
	$PickList = new lingdang_DependencyPicklist();//级联类
	$PicklistFields = $PickList->getDependentPicklistFields($_REQUEST['selectmodule']);//获取模块级联字段
	$selectmodule = $_REQUEST['selectmodule'];//弹窗显示的模块
	$frommodule = $_REQUEST['frommodule'];
	$focus=CRMEntity::getInstance($selectmodule) ;
	$tmp_field_obj=Field::getInstance($selectmodule,$adb);
	$showfieldvalue=new ShowFieldValue($tmp_field_obj,$selectmodule,constant('SHOW_EDITVIEW'));
	$moduleFields=$tmp_field_obj->getModuleFields();
	//获取常见问题 - 类别
	if(!empty($moduleFields['faqcategories'])){
		//获取类别下拉框内容
		$showvalue=$showfieldvalue->getFieldValueByField($moduleFields['faqcategories'],'','');
		//获取类别fieldlabel
		$ticketarr['faqcategory_label'] = $moduleFields['faqcategories']->getfieldLabel();
		foreach($showvalue['optionvalue'] as $key=>$data){
			if(!empty($data[0])){
				if($rowDisplay%6 == 0 && $rowDisplay > 0){//控制每行显示6个 避免换行问题
					$row++;
				}
				$ticketarr_value[$row][] = $data[0];
				$rowDisplay++;
			}
		}
		foreach($ticketarr_value as $row => $ticketarr_array){
			for($i = 0; $i<6;$i++){
				if(!empty($ticketarr_array[$i])){
					$ticketarr['faqcategory'][$row][$i] = $ticketarr_array[$i];
				}else{
					$ticketarr['faqcategory'][$row][$i] = '';
				}
			}
		}
	}
	//判断常见问题模块 - 问题类别和常见问题是否有级联关系
	$sPickListType = 0;// 1：是 0 否
	if(!empty($PicklistFields)){
		foreach($PicklistFields as $FieldInfo){
			if($FieldInfo['sourcefield'] == 'faqcategories' && $FieldInfo['targetfield'] == 'faqtype'){
				$sPickListType = 1;
				break;
			}
		}
	}
   
    
	//获取常见问题 -  常见问题 (如果问题类别和常见问题没有级联关系则显示全部)
	if($sPickListType == 0 || (!empty($_REQUEST['faqcategory_name']))){
		if(!empty($moduleFields['faqtype'])){
			//获取常见问题fieldlabel
			$faqtype['faqtype_label'] = $moduleFields['faqtype']->getfieldLabel();
			if($sPickListType == 0 && empty($_REQUEST['faqcategory_name'])){
				//获取常见问题下拉框内容
				$showvalue=$showfieldvalue->getFieldValueByField($moduleFields['faqtype'],'','');
				$rowDisplay = 0;
				$row = 1;
				foreach($showvalue['optionvalue'] as $key=>$data){
					if(!empty($data[0])){
						if($rowDisplay%6 == 0 && $rowDisplay > 0){//控制每行显示6个 避免换行问题
							$row++;
						}
						$faqtype_value[$row][] = array('faqvalue'=>$data[0],'ischecked'=>'');
						$isFaqType = 1;
						$rowDisplay++;
					}
				}
				foreach($faqtype_value as $row => $faqtype_array){
					for($i = 0; $i<6;$i++){
						if(!empty($faqtype_array[$i])){
							$faqtype['faqtype'][$row][$i] = $faqtype_array[$i];
						}else{
							$faqtype['faqtype'][$row][$i] = '';
						}
					}
				}
			}else{
				//获取级联字段的具体内容
				$PickListContent = $PickList->getPickListDependency($_REQUEST['selectmodule'],'faqcategories','faqtype');
				if(!empty($PickListContent['valuemapping'])){
					if(!empty($_REQUEST['faqcategory_name'])){
						$faqcategory_array = explode('|',$_REQUEST['faqcategory_name']);
						$i = 0;
						foreach($PickListContent['valuemapping'] as $info){
							if(in_array($info['sourcevalue'],$faqcategory_array)){
								foreach($info['targetvalues'] as $value){
									$fieldValue[$value] = $value;
								}
							}
						}
						$rowDisplay = 0;
						$row = 1;
						$isFaqType = 0;//极端处理:判断当前已选的问题类别下不存在级联常见问题选项，则不现实常见问题区域
						//已选的常见问题选项
						if(isset($_REQUEST['select_faqtype']) && !empty($_REQUEST['select_faqtype'])){
							$select_faqtype = explode('|',$_REQUEST['select_faqtype']);
						}
						foreach($fieldValue as $data){
							if($rowDisplay%6 == 0 && $rowDisplay >= 0){//控制每行显示6个 避免换行问题
								$row++;
							}
							$checked = '';
							if(!empty($data)){
								if(!empty($select_faqtype)){
									if(in_array($data,$select_faqtype)){
										$checked = "checked";
									}
								}
								$faqtype_value[$row][] = array('faqvalue'=>$data,'ischecked'=>$checked);
								$isFaqType = 1;
							}
							$rowDisplay++;
						}
						foreach($faqtype_value as $row => $faqtype_array){
							for($i = 0; $i<6;$i++){
								if(!empty($faqtype_array[$i])){
									$faqtype['faqtype'][$row][$i] = $faqtype_array[$i];
								}else{
									$faqtype['faqtype'][$row][$i] = '';
								}
							}
						}
					}
				}
			}
		}
	}else{
		$faqtype['faqtype_label'] = $moduleFields['faqtype']->getfieldLabel();
		$faqtype['faqtype'] = '';
	}
	//获取常见问题 - 问题
	if(!empty($moduleFields['question'])){
		$question_label = $moduleFields['question']->getfieldLabel();
	}
	//客户服务单
	$frommodule_obj=Field::getInstance($frommodule,$adb);
	$frommoduleFields=$frommodule_obj->getModuleFields();
	//问题描述 
	if(!empty($frommoduleFields['description'])){
		$description_label = $frommoduleFields['description']->getfieldLabel();
	}
	//解决方案
	if(!empty($frommoduleFields['solution'])){
		$solution_label = $frommoduleFields['solution']->getfieldLabel();
	}
	//分页 页码
	if(!empty($_REQUEST['start'])){
		$start = $_REQUEST['start'];
	}else{
		$start = 1;
	}
	//常见问题选项(checkbox -> value)
	if(!empty($_REQUEST['select_keys'])){
		$keys = ldcrm_json_decode($_REQUEST['select_keys']);
        if(!empty($keys)){
            $keys = $keys[0];
        }
	}
	//当前页已选的常见问题faqid
	if(!empty($_REQUEST['select_id_json'])){
		$select_id_json = json_decode($_REQUEST['select_id_json'],true);
		foreach($select_id_json as $select_id => $page){
			if($page == $start){
				$page_select_id[$select_id] = $select_id;
			}
		}
	}
	//查找关键字
	if(!empty($_REQUEST['keywords'])){
		$keywords = $_REQUEST['keywords'];
	}
	//获取列表内容
	$searchInfo = getSearchEntries($focus,$selectmodule,$keywords,$search_field,$curry_start,$_REQUEST['record'],$_REQUEST['frommodule'],$start,$keys);
}
//判断模糊查询内容是否为空
if(isset($searchInfo['entries']))
    $searchInfo['columnname'] = $columnname;
else
    $searchInfo['columnname'] = '';
$table ='<div class="fixedheaderDiv" style="padding-right:0;">';
$table .='<table class="listEntries fir-center" border="0" cellpadding="0" cellspacing="1" width="100%"><tbody>';
if(!empty($searchInfo)){
	$table .='<tr>';
		$table .='<th style="text-align:center;width:40px;"><input id="selectCurrentPageRec" type="checkbox" onclick="toggleSelect_Faq(this.checked,\'selected_id\',\''.$selectmodule.'\')" name="selectall"></th>';
		foreach($searchInfo['listviewheader'] as $columnname=> $header){
			if($columnname == 'question'){
				$width = '110';
			}else{
				$width='40';
			}
			$table .='<th width="'.$width.'px"><span title="'.$header.'">' .$header . '</span></th>'; 
		}
	$table .='</tr>';
}
if(empty($searchInfo['listviewentity'])){
	$colspan = count($searchInfo['listviewheader'])+1;
	$table .='<tr align="center">';
	$table .='<td colspan="'.$colspan.'" style="background-color:#fff;height:160px;">';
    $table .='<div class="warningTableContent" style="z-index:600;width:300px;">';
    $table .='<div class="wtc_img"><img src="themes/icon2023/ld-no-records.png?v='.$global_minversin.'"></div>';
    $table .='<div class="wtc_content">'.getFixedLabel('NOTFOUNDANYRECORD').'</div>';
    $table .='<div class="wtc_btn"></div><div></div>';
	$table .='</div>';
	$table .='</td></tr>';
}else{
    $i=0;    
	foreach($searchInfo['listviewentity'] as $entity_id => $entity){
        if ($i%2 ==0) {
            $table.='<tr id="poprow_'.$i.'" class="lvtColData" onmouseover="setPopTrColor(\'poprow_'.$i.'\')" onmouseout="setPopTrColorOut(\'poprow_'.$i.'\',\'on\')">';
        }
        else{
            $table.='<tr id="poprow_'.$i.'" class="lvtColDataBj" onmouseover="setPopTrColor(\'poprow_'.$i.'\')" onmouseout="setPopTrColorOut(\'poprow_'.$i.'\',\'On\')">';
        }
		//checkbox
		$select_id_checked = '';
		if(in_array($entity_id,$page_select_id)){
			$select_id_checked = 'checked';
		}
		$table .='<td align="center" width="10px" style="background-color:transparent;"><input id="check_'.$entity_id.'" '.$select_id_checked.' type="checkbox" onclick="check_object_faq(this,\''.$selectmodule.'\')" value="'.$entity_id.'" name="selected_id"></td>';
		foreach($entity as $columnname => $val){
			if($columnname == 'question'){
				$width = '110';
			}else{
				$width='40';
			}
			$table .='<td  width="'.$width.'px" style="background-color:transparent;"><span title="'.$val.'">' . $val . '</span></td>';
		}
		$table .='</tr>';
        $i++;
	}
}
$table .='</tbody></table>';
$table .='</div>';
$smarty = new lingdangCRM_Smarty;
$theme_path="themes/".$theme."/";
$image_path=$theme_path."images/";
$smarty->assign('TABLE',$table);//内容
$smarty->assign("THEME", $theme);
$smarty->assign("THEME_PATH",$theme_path);
$smarty->assign("SELECTMODULE",$selectmodule);
$smarty->assign("FROMMODULE",$frommodule);
$smarty->assign('TICKETARR',$ticketarr);//问题类别
$smarty->assign('FAQTYPE',$faqtype);//常见问题
$smarty->assign('DESCRIPTIONLABEL',$description_label);//问题描述
$smarty->assign('SOLUTIONLABEL',$solution_label);//解决方案
$smarty->assign('QUESTIONLABEL',$question_label);//问题
$smarty->assign('NUMOFROWS',$searchInfo['navigation']);//分页
$smarty->assign('recordListRange',$searchInfo['recordListRangeMsg']);
$smarty->assign('PICKLISTTYPE',$sPickListType);//是否存在级联关系
$smarty->assign('PAGE',$start);
$smarty->assign('KEYWORDS',$keywords);
if($_REQUEST['search_type']=='true'){//内容
    $smarty->display("SelectRelSpecialPopupContents.tpl");
}else if($_REQUEST['category_type'] == 'true'){//常见问题选项
	echo $isFaqType . '##SUCCESS##';
	$smarty->display("SelectRelatedFaqType.tpl");
	exit();
}else{
	$_REQUEST['diony']='diony';
	$arr['title']=getTransTab('Faq');
	$str=$smarty->fetch('SelectRelatedSpecialPopup.tpl');
	$arr['content']=$str;
	$arr['oktext'] = getFixedLabel('CONFIRME');
	$arr['canceltext'] = getFixedLabel('CANCEL');
	ConvertTojsonString(1,$arr,"success");
}
exit();

/**
 * edit:andrew
 * date:2015-6-3
 * reason:获取模块的模糊查询关联内容信息                                                                                                    
 * */
function getSearchEntries($focus,$module,$keywords,$search_field,$curry_start,$record,$frommodule,$start,$keys=''){
	global $adb,$current_user;
	//global $list_max_entries_per_page_new;
	require_once('modules/CustomView/PopupSpecialCustomView.php');
	require_once('include/ProductDetails/PopupProductDetails.php');
	//相关信息列表每页显示记录的条数
	$deployarray=getSys_deploy(14);
	$list_max_entries_per_page_new = $deployarray['deploy_value'];
	$limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
	$popupProductDetails=new PopupProductDetails($module);
	$customView=new PopupSpecialCustomView($module);
	$tabid = getTabid($module);
	$viewid=0;
	$table_name = $focus->table_name;
	$table_index = $focus->table_index;
	$tab_name_index = $focus->tab_name_index;
	$limit_sql = " limit $limit_start_rec,$list_max_entries_per_page_new";
	$orderby = " order by $table_name.pinci DESC ";//排序 默认创建时间倒序
	//常见问题 - 查询条件
	if(!empty($keys)){
	   foreach($keys as $tmpindex=>$tmpkeys){
	       $keys_arr = explode('|',$tmpkeys);
    		for($i = 0; $i<count($keys_arr); $i++){
    			$keys_where[$i] = "ld_faq.".$tmpindex."='".$keys_arr[$i]."'";
    		}
            $keywhere = ' and (' . implode(' or ',$keys_where) . ') ';
	   }
	}
	
	$queryGenerator = new QueryGenerator($module,$current_user,$customView);
	$queryGenerator->initForCustomViewById($viewid);
	if(!empty($keywords)){
		$keywhere .=" and ld_faq.question like '%".$keywords."%'";
		/*$selectColumn = explode(',',$queryGenerator->getSelectClauseColumnSQL());
		foreach($selectColumn as $_fieldname){
			if($_fieldname != 'ld_faq.id'){
				$keywords_arr[] = $_fieldname . " like '%" .$keywords . "%'";
			}
		}
		if(sizeOf($keywords_arr) > 0){
			$keywhere = ' and (' . implode(' or ',$keywords_arr) . ') ';
		}*/
	}
	//$list_query = $queryGenerator->getQuery('').$keywhere;
	$list_query = "SELECT distinct " . $queryGenerator->getSelectClauseColumnSQL() . $queryGenerator->getFromClause() . $queryGenerator->getWhereClause() . $keywhere . $orderby;
	//if(!empty($keywhere)){
		$allResult = $adb->pquery($list_query);//获取总条目数
		$all_num_rows = $adb->num_rows($allResult);
		$result = $adb->pquery($list_query . $limit_sql);
		$num_rows = $adb->num_rows($result);    
		$showfieldvalueobj=new ShowFieldValue($focus->fieldobj,$module,SHOW_POPUP);
		$showfieldvalueobj->setadbResult($result);
		$searchFieldArr  = $customView->getSearchField();
		for($i = 0; $i<$num_rows; $i++)
		{
			$id = $adb->query_result($result,$i,$table_index);
			$showfieldvalueobj->setRecorId($id);
			$showfieldvalueobj->setLine_index($i);
			foreach($searchFieldArr as $key => $columnname)
			{
				  $field=$focus->fieldobj->getFieldInfoobjBykey('columnname',$columnname);
				
				  $showvalue=$showfieldvalueobj->getFieldValueByField($field,$adb->query_result($result,$i,$columnname),$adb->query_result($result,$i,$columnname));
				  $res=$showvalue['value'];
				
					if($res == null)
						$res = '';
					$listviewentity[$id][$columnname] = $res;
			}
		  
		}
        crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
		$navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$all_num_rows);
		$navigationOutput = getTableHeaderSimpleNavigation2($navigation_array, $frommodule, $module, 'index', 0);
		$recordListRangeMsg = getRecordRangeMessage($result, $limit_start_rec,$all_num_rows);
	//}
	return array('listviewentity'=>$listviewentity,'listviewheader'=>$customView->getListViewHeader(),'navigation'=>$navigationOutput,'recordListRangeMsg'=>$recordListRangeMsg);
}
    
?>