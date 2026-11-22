<?php

global $app_strings, $default_charset;
global $currentModule, $current_user;
global $theme, $adb;
//dump($_REQUEST);
//require_once('include/SelectRelatedPopu/SelectRelatedPopu.php');
if(!empty($_REQUEST['selectmodule'])){
	$selectmodule = $_REQUEST['selectmodule'];
	$isCreate = isPermitted($_REQUEST['selectmodule'],"Create", '');
    
    $frommodule=$_REQUEST['frommodule'];
    
    if(!isset($_REQUEST['maxrowsshow'])){
        $_REQUEST['maxrowsshow'] = 10;
    }
    $maxrowsshow=$_REQUEST['maxrowsshow'];
	$focus = CRMEntity::getInstance($selectmodule);
	crm_load_class_file("Carousel_SelectPopup",'modules/ShopSettings');
	$SelectPopu = new Carousel_SelectPopup($selectmodule,$adb);
	$serachPromptarr = $SelectPopu->getRelatedSearchFields();//查询字段
	$listviewFields = $SelectPopu->getRelatedHeader();//列头
	$searchFieldCurrency = $SelectPopu->getRelatedFieldCurrency();//金额字段
	$searchFieldDouble = $SelectPopu->getRelatedFieldDouble();//数字
	$listviewentity = $SelectPopu->getSearchEntries();//列表内容
    
	$serachPrompt = implode('/',$serachPromptarr);

	//列头
	$table ='<div class="fixedheaderDiv"><table class="listdata" border="0" cellpadding="0" cellspacing="1" width="100%"><tbody><tr>';
	foreach($listviewFields as $header){
		$table .='<th><span title="'.$header.'">' .$header . '</span></th>'; 
	}
	$table .='</tr></tbody></table></div>';
	//内容
	$table .='<div style="max-height:200px;overflow-y: scroll;">';
	if(empty($listviewFields))
		$border=0;
	else
		$border=1;
	$table .= '<table class="listdata" border="0" cellpadding="0" cellspacing="'.$border.'" width="100%"><tbody>';
	$tabDetailtypes = explode('tabdetail_',$_REQUEST['type']);
	$shareequally = explode('shareequally_',$_REQUEST['type']);
	if(empty($listviewentity)){
		$table .='<tr align="center">';
		$table .='<td colspan="'.count($listviewFields).'" bgcolor="#efefef">';
		$table .='<div class="warningTableContent" style="z-index:600;width: 50%;margin: 10px auto;">';
		$table .='<div class="wtc_img"><img src="themes/icon2023/ld-no-records.png?v='.$global_minversin.'"></div>';
		$table .='<div class="wtc_content">'.getFixedLabel('NOTFOUNDANYRECORD').'</div>';
		$table .='<div class="wtc_btn"></div>';
		$table .='<div></div></div>';
		$table .='</td></tr>';
	}else{
		$i=0;    
        $fieldname=$_REQUEST['returnfieldname'];
        
		foreach($listviewentity as $entity_id => $entity){
			if ($i%2 ==0){
				$table.='<tr id="poprow_'.$i.'" class="lvtColData" onmouseover="setPopTrColor(\'poprow_'.$i.'\')" onmouseout="setPopTrColorOut(\'poprow_'.$i.'\',\'on\')">';
			}
			else{
				$table.='<tr id="poprow_'.$i.'" class="lvtColDataBj" onmouseover="setPopTrColor(\'poprow_'.$i.'\')" onmouseout="setPopTrColorOut(\'poprow_'.$i.'\',\'On\')">';
			}
			foreach($listviewFields as $ckey => $header){
				if(in_array($ckey,$searchFieldCurrency) || in_array($ckey,$searchFieldDouble)){
					$table .="<td align=\"right\">";
				}else{
					$table .="<td align=\"left\">";
				}
                $smownername='';
				if($ckey == $focus->list_link_field){
				    $fldname=$fieldname;
				    $table .= '<a href="javascript:void(0);" onclick="CarouselSelectProducs(\''.$selectmodule.'\',\'\',\''.$entity_id.'\',\''.rawurlencode($entity[$focus->list_link_field]).'\',\''.$fldname.'\',\''.$smownername.'\',\''.$_REQUEST['frommodule'].'\')" title="'.$entity[$focus->list_link_field].'">';
					
					if(in_array($ckey,$searchFieldCurrency)){
						$table .= $entity['currency_symbol'];
					}
					$table .= $entity[$focus->list_link_field] . '</a></td>';
				}else{
					if(in_array($ckey,$searchFieldCurrency)){
						$table .= $entity['currency_symbol'];
					}
                    if(stripos($entity[$ckey],'ww-open-data')!==false)
                    {
                        	$table .='<span>' . $entity[$ckey] . '</span></td>';
                    }
                    else
				    	$table .='<span title="'.$entity[$ckey].'">' . $entity[$ckey] . '</span></td>';
				}
			}
			$table .='</tr>';
			$i++;
		}
	}
	$table .='</tbody></table>';
	$table .='</div>';
	$smarty = new lingdangCRM_Smarty;
    //37770: （1.6）合同订单模块>将客户名称字段的审批要求设置【已批准】>合同订单新增界面>选择客户弹出层>选择快速创建客户：在创建完客户后系统自动选择
    $smarty->assign("Approve_Demand",$approve_demand);//已批准：1
	$smarty->assign('TABLE',$table);
	$smarty->assign('TABLEDETAIL_ROW',$tabDetailtypes[1]);
	$smarty->assign("THEME", $theme);
	$smarty->assign("KEYIDS", $_REQUEST['keyids']);
	$smarty->assign("THEME_PATH",$theme_path);
	$smarty->assign("KEYWORDS",$_REQUEST['keywords']);
	$smarty->assign("SELECTMODULE",$selectmodule);
	$smarty->assign("SEARCHPROMPT",$serachPrompt);
	$smarty->assign("FROMMODULE",$_REQUEST['frommodule']);
	$smarty->assign("TYPE",$_REQUEST['type']);
	$smarty->assign("ISADMIN",is_admin($current_user));
	$smarty->assign("SEARCH_TYPE",$_REQUEST['search_type']);
	//$smarty->assign("CP",$cp);
	$smarty->assign("LANGUAGETYPE",$languageType);
	$smarty->assign("FIELDNAME",$_REQUEST['returnfieldname']);
	$smarty->assign('RETURN_COLUMN',$_REQUEST['return_columnname']);
	$smarty->assign('SELECTFIELDNAME',$_REQUEST['select_fieldname']);
	$smarty->assign('SELECTREALTIONFROM',$_REQUEST['selectrelationfrom']);
	$smarty->assign('ISCREATE',$isCreate);	
    $smarty->assign("LIMITCOUNT",$maxrowsshow);
    
    $smarty->assign("HAIGE_POTENTIALID_ALLOWEDIT",$potentialid_allowedit);
	/*
    if($selectmodule== 'Accounts'||$selectmodule=='Vendors'||$selectmodule=='VendorContact'||$selectmodule=='Contacts')
	{
    //0037168: （1.6）销售机会新增界面>选择联系人弹出框：显示条数根据【设置客户查重和选择客户/供应商列表每页显示记录的条数】参数设置的条数显示，手机端也需要做出对应的修改
        $system_deploy=getSys_deploy(151);
        $deployvalue=$system_deploy['deploy_value'];
        if(!empty($deployvalue))
        {
            $smarty->assign("LIMITCOUNT",$deployvalue);
        }
	}
    */
	
    $arr['title']=getTranstab($selectmodule);

    // 230720 wym BUG0068703 商城设置->轮播图设置，新建界面“导航链接类型”选择产品明细，选择产品弹出层界面，查询字段没有显示下拉选项值
    $focus = CRMEntity::getInstance($selectmodule);
    if($_REQUEST['selectrelationfrom']=='entry'){
        crm_load_class_file("SelectRelatedPopu_detail",'include/SelectRelatedPopu');
        $SelectRelatedPopu = new SelectRelatedPopu_detail($selectmodule,$adb);
    }else{
        crm_load_class_file("SelectRelatedPopu",'include/SelectRelatedPopu');
        $SelectRelatedPopu = new SelectRelatedPopu($selectmodule,$adb);
    }
    $serachPromptarr = $SelectRelatedPopu->getRelatedSearchFields();//查询字段
    $listviewFields = $SelectRelatedPopu->getRelatedHeader();//列头
    $searchFieldCurrency = $SelectRelatedPopu->getRelatedFieldCurrency();//金额字段
    $searchFieldDouble = $SelectRelatedPopu->getRelatedFieldDouble();//数字
    $listviewentity = $SelectRelatedPopu->getSearchEntries();//列表内容
    $serachfieldsOptions = $SelectRelatedPopu->getRelatedSearchFieldsOptions();//获取选择相关单据的字段数组 zxm 20221214
    $smarty->assign("serachfieldsOptions",$serachfieldsOptions);//获取选择相关单据的字段数组 zxm 20221214
	
	$content=$smarty->fetch("SelectRelatedPopup.tpl");
    $_REQUEST['diony']='diony';
    $arr['content']=$content;
    
    ConvertTojsonString(1,$arr,"success");
 
}
?>