<?php
/**
 * edit:andrew
 * date:2015-6-2
 * reason:弹窗选择客户
 **/
//zkt 20231122 XUQIU1001341 SQL注入
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
global $app_strings, $default_charset;
global $currentModule, $current_user;
global $theme, $adb;
//dump($_REQUEST);
//require_once('include/SelectRelatedPopu/SelectRelatedPopu.php');
//wyt 221116 XUQIU1000658 关联选择单据（单选）字段弹出层中增加【快速创建】操作按钮
if($_REQUEST['quickcreate']=='yes'){
    global $adb;
    $selectmodule=$_REQUEST['selectmodule'];
    crm_load_class_file("SelectRelatedPopu",'include/SelectRelatedPopu');
    $from_focus=CRMEntity::getInstance($selectmodule);
    $SelectRelatedPopu = new SelectRelatedPopu($selectmodule,$adb);
    $SelectRelatedPopu->setRelatedPopopSql();
    $fromtablename=$from_focus->table_name;
    $fromtableindex=$from_focus->table_index;
    $sql=$SelectRelatedPopu->page_list_query." and $fromtablename.$fromtableindex=".$_REQUEST['recordid'];
    $result=$adb->pquery($sql,array());

    if($adb->num_rows($result)<=0)
    {
        ConvertTojsonString(-1,null,"不满足其它条件");
        die;
    }else{
        ConvertTojsonString(1,null,"success");
        die;
    }
}

if(!empty($_REQUEST['selectmodule'])){
    $frommodule=$_REQUEST['frommodule'];
	$selectmodule = $_REQUEST['selectmodule'];

    $smarty = new lingdangCRM_Smarty;
    $smarty->assign('CURRENT_USER_ID',$current_user->id);
    $smarty->assign('MODULE',$selectmodule);
    //ljj XUQIU20240425-01 关联选择单据（单选）、关联选择单据（多选）、选择源单弹出层界面，增加显示树结构分类（徐昱轩）
    crm_load_class_file('cls_Module_Tree', 'include/utils');
    $cls_module_tree = cls_Module_Tree::getInstance($selectmodule);
    if(isset($_REQUEST['ajax']) && $_REQUEST['ajax'] != '')
    {
        if (isset($_REQUEST['isshowModuleListTree']) && $_REQUEST['isshowModuleListTree'] == 'yes'){
            $smarty->assign('tree_enable','yes');
            $smarty->assign('tree_width',$cls_module_tree->getTreeWidth());
        }
    }
    else
    {
        if($cls_module_tree->moduleenable=='yes'){
            //加载初始listview树状结构
            $modulelisttree = $cls_module_tree->getModuleListTree();
//            dump($modulelisttree);
            $smarty->assign('tree_enable','yes');
            $smarty->assign('POPUPMODULElISTTREE',$modulelisttree);
            if ($modulelisttree['enable']=='yes') {
                $_REQUEST['isshowModuleListTree'] = 'yes';
            }
            //若$_SESSION中储存的selectrecord值,为级联下拉值id，设置selectrecord为0（或获取下级对应html）
            if(isset($modulelisttree)&&$modulelisttree['enable']=='yes'&&!isset($modulelisttree['list'][$_SESSION['module_list_tree'][$selectmodule]['selectrecord']])){
                //$_SESSION['module_list_tree'][$currentModule] = array('selectrecord'=>0,'list'=>array());
                //获取下级对应html
                $sessionarr = $_SESSION['module_list_tree'][$selectmodule];
                $Inithtmlexpand = $cls_module_tree->getInithtmlexpand($sessionarr['selectrecord'],$sessionarr['list']);
                $smarty->assign('Inithtmlexpand',$Inithtmlexpand);
            }
            //获取设置选中的树结构id和list
            $module_list_treeselectrecord = 0;
            if(isset($_SESSION['module_list_tree'][$selectmodule])){
                $module_list_treeselectrecord= $_SESSION['module_list_tree'][$selectmodule]['selectrecord'];
            }
            $smarty->assign('POPUPMODULE_TREE_PICKLIST_ID',$module_list_treeselectrecord);
        }
    }


    if(($selectmodule=='Project' && $frommodule=='PaymentPlan')||$selectmodule=='QuotesChange'||$selectmodule=='BudgetChange'){//wyt 221110 XUQIU1000658 主题：关联选择单据（单选）字段弹出层中增加【快速创建】操作按钮
        $isCreate='no';
    }else{
        $isCreate = isPermitted($_REQUEST['selectmodule'],"Create", '');
    }
//	if($selectmodule=='SalesOrder'||$selectmodule=='ServiceContracts'||$selectmodule=="ProjectTask"){
//		$isCreate='no';
//	}else{
//		$isCreate = isPermitted($_REQUEST['selectmodule'],"Create", '');
//	}
	//当开启公海时，并且不允许创建普通客户，则隐藏 快速按钮 按钮
	if($selectmodule == 'Accounts'){
        crm_load_class_file('cls_PublicAccounts', 'modules/Accounts');
		$cls_PublicAccounts = cls_PublicAccounts::getInstance($selectmodule);
		$public_account = $cls_PublicAccounts->getPublicAccountConfig();
		if($public_account['status'] == 'yes' && $public_account['is_commonaccount_create'] == 'no'){
			$isCreate = 'no';
		}
	}

    if($selectmodule == 'Leads'){
        crm_load_class_file('cls_PublicLeads', 'modules/Leads');
        $cls_PublicLeads = new cls_PublicLeads($selectmodule);
        $public_account = $cls_PublicLeads->getPublicAccountConfig();
        if($public_account['status'] == 'yes' && $public_account['is_commonaccount_create'] == 'no'){
            $isCreate = 'no';
        }
    }

    $fromfocus=CRMEntity::getInstance($frommodule);
    $fieldname=$_REQUEST['fieldname'];
    if($_REQUEST['selectrelationfrom']=='entry')
    {
        //duan 20240419 收款单,付款单分录选择单据时,增加源单类型获取,用于判断字段信息
        if($frommodule == 'SendCashBill' || $frommodule == 'CashBill'){
            $fromfocus->detailfieldobj->setsourceModuleType($_REQUEST['sourcemodule']);
        }
        //选择字段是明细还主表：entry:明细，main:主表
        $fieldinfo=$fromfocus->detailfieldobj->getFieldInfoobjBykey("columnname",$fieldname);
    }
    else
        $fieldinfo=$fromfocus->fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
    if($_REQUEST['maxrowsshow']>0)
    {
        $maxrowsshow=$_REQUEST['maxrowsshow'];
    }
    else if(!empty($fieldname) && !empty($fieldinfo))
    {
        //editor:gyq_158_参考 reason:选择源单  2019/11/5 19:54
        if(strtolower($fieldinfo->getBigType()??'')=='selectsource')
        {
            crm_load_class_file('cls_OptionModule','include/OptionModule');
            $optionmoduleobj=cls_OptionModule::getInstance($frommodule);
            $options= $optionmoduleobj->getData();
            $tabid=getTabid($frommodule);
            $option_tabid=getTabid($selectmodule);
            $maxrowsshow=$options[$tabid][$option_tabid]['maxrowsshow'];
            $approve_demand=$options[$tabid][$option_tabid]['approve_demand'];//1：已批准
        }
        else
        {
            //引用
            $maxrowsshow=$fieldinfo->getMaxRowsShow();//获取最大显示行数
            $approve_demand=$fieldinfo->get_approve_demand();//1：已批准
            $dataRange=$fieldinfo->getDataRang();//1：已批准
            $advance_demand = $fieldinfo->get_advance_demand();//关联选择单据（单选）的审批要求 and 其他条件
        }
    }


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
    $listHeaderWidthArr = $SelectRelatedPopu->getListHeaderWidth();//列头
	$searchFieldCurrency = $SelectRelatedPopu->getRelatedFieldCurrency();//金额字段
	$searchFieldDouble = $SelectRelatedPopu->getRelatedFieldDouble();//数字
	$listviewentity = $SelectRelatedPopu->getSearchEntries();//列表内容
    $serachfieldsOptions = $SelectRelatedPopu->getRelatedSearchFieldsOptions();//获取选择相关单据的字段数组 zxm 20221214


    //ljj XUQIU20240425-01 关联选择单据（单选）、关联选择单据（多选）、选择源单弹出层界面，增加显示树结构分类（徐昱轩）
    if (isset($_REQUEST['isshowModuleListTree']) && $_REQUEST['isshowModuleListTree'] == 'yes'){
        $SelectRelatedPopu->setIsShowModuleListTree('yes');
        $cls_MyCRMcryptobj=new cls_MyCRMcrypt();
        $page_list_query = $SelectRelatedPopu->getPageListQuery();
        $pageListQuery_NoTreeWhere = $SelectRelatedPopu->querygeneratoryobj->getSqlNoTreeWhere($page_list_query);
//        dump($pageListQuery_NoTreeWhere);
        $Encrypt_TreeWhere = $cls_MyCRMcryptobj->encode($pageListQuery_NoTreeWhere);
        $smarty->assign("Encrypt_TreeWhere",$Encrypt_TreeWhere);

    }

    //海格 新建报价单不允许选择已创建过1.0版本的“特价申请编号”,复制、编辑时只能选择当前编号（重新带入信息）
    $VersionInfo = getVersionInfo();
    if ($VersionInfo['account'] == 'haige' && $_REQUEST['selectmodule'] == 'Potentials' && $_REQUEST['frommodule'] == 'Quotes') {	
        //判断当前选择的特价单编号是否已创建过报价单，如果是则为编辑或复制界面
        $potentialid_allowedit = 'yes';
        if(isset($_REQUEST['potential_id'])&&$_REQUEST['potential_id']>0){
            global $adb;
            $seleted_focus = CRMEntity::getInstance($_REQUEST['selectmodule']);
            $columnname = $seleted_focus->table_index;
            $tablename = $seleted_focus->table_name;
            $potential_id = $_REQUEST['potential_id'];
            $sql = "select * from ld_quotes where $columnname = $potential_id and deleted = 0 ";
            $result=$adb->pquery($sql,array());
            $num_row = $adb->num_rows($result);
            if($num_row>0){
                $potentialid_allowedit = 'no';
            }
        }
	}
    //ls 20221111 XUQIU1000848  普罗定制开发表单特殊带入需求(支持多选)
    if ($VersionInfo['account'] == 'probiotic' && ($_REQUEST['frommodule']=='CustomForm26' || $_REQUEST['frommodule']=='CustomForm25') && ($_REQUEST['selectmodule']=='CustomForm23' || $_REQUEST['selectmodule']=='CustomForm22')) {
        $selectmorerecord = 'yes';
    }
    //山水：多选客户字段，可选择多条用户单据
    if($selectmodule=='Users'){
        //单据分录，选择用户单选，山水 的客户可以通过修改数据库字段多选，或者将来特殊判断
     //   $selectmorerecord = 'yes';
    }
    
    //dump($SelectRelatedPopu->setRelatedPopopSql());
	$serachPrompt = implode('/',$serachPromptarr);
    $smarty->assign('selectmodule',$selectmodule);

    //列头html
    $headerHtml = '';
    if($selectmorerecord=='yes'){
        $headerHtml .= '<th style="width:40px;text-align:center"><input type="checkbox" name="select_all" id="select_all" value="" cur_sequence="1" onclick="SpecialUserSelect(this,'."'selected_id'".')"/></th>';
    }
    $tmp_i = 0;
    foreach ($listviewFields as $columnname => $label){
        $fieldinfo = $focus->fieldobj->getFieldByColumnName($columnname);
        $headerHtml .= '<th style="'.$fieldinfo->getLabelStyle().'width:'.$listHeaderWidthArr[$tmp_i].'px" headermodule="'.$selectmodule.'" headername="'.$fieldinfo->getFieldName().'" tag="'.$tmp_i.'">'.$label.'</th>';
        $tmp_i++;
    }
    $smarty->assign('headerHtml',$headerHtml);

//	//列头
//	$table ='<div class="fixedheaderDiv"><table class="listdata" name="listviewheader" border="0" cellpadding="0" cellspacing="1" width="100%"><tbody><tr>';
//	if($selectmorerecord=='yes'){
//	   $table .= '<th style="width:40px;text-align:center"><input type="checkbox" name="select_all" id="select_all" headermodule="'.$selectmodule.'" value="" cur_sequence="1" onclick="SpecialUserSelect(this,'."'selected_id'".')"/></th>';
//	}
//    foreach($listviewFields as $columnname=> $header){//wsh 标签颜色
//        $fieldinfo = $focus->fieldobj->getFieldByColumnName($columnname);
//		$table .='<th><span style="'. $fieldinfo->getLabelStyle() .'" title="'.$header.'">' .$header . '</span></th>';
//	}
//	$table .='</tr></tbody></table></div>';
//	//内容
//	$table .='<div id="related_listcontent" name="related_listcontent" style="max-height:400px;overflow-y: scroll;">';

    $table = '';
	$tabDetailtypes = explode('tabdetail_',$_REQUEST['type']);
	$shareequally = explode('shareequally_',$_REQUEST['type']);
	if(empty($listviewentity)){
		$table .='<tr align="center">';
		$table .='<td colspan="'.count($listviewFields).'" bgcolor="#fff" style="height:198px">';
		$table .='<div class="warningTableContent" style="z-index:600;top: calc(50% - 75px);">';
		$table .='<div class="wtc_img" style="width:255px"><img src="themes/icon2023/ld-no-records.png?v='.$global_minversin.'"></div>';
		$table .='<div class="wtc_content">'.getFixedLabel('NOTFOUNDANYRECORD').'</div>';
		$table .='<div></div></div>';
		$table .='</td></tr>';
	}else{
		$i=0;    
        $fieldname=$_REQUEST['fieldname'];
        $rowindex=0;
		foreach($listviewentity as $entity_id => $entity){
			
            $tdhtml = '';
            if($selectmorerecord=='yes'){
                $tdhtml .= '<td style="width:40px;text-align:center"><input type="checkbox" billinfo="'.$entity_id.'" id="'.$entity_id.'" name="selected_id" value="'.$entity_id.'" link_field_value="'.$entity[$focus->list_link_field].'" sequence="-1" onclick="SpecialUserSelectAll(this,'."'select_all'".','.$entity_id.')"/></td>';
        	}
            $clickfun = '';
            $rowindex++;
			foreach($listviewFields as $ckey => $header){
                
                $uitype = $focus->fieldobj->getFieldInfoBykeyValue('columnname',$ckey,'uitype');
                $selectmodule_fieldinfo = $focus->fieldobj->getModuleFields();//BUG0073451 xxy 2023-10-12 关联选择单选字段、选择源单字段、选择产品和套餐弹出层界面，显示列字段增加颜色显示（根据页面设置中的字段属性“文字颜色”显示） 
                $fieldvaluecolor = $selectmodule_fieldinfo[$ckey]->fieldvaluecolor;
                $bigtype = $selectmodule_fieldinfo[$ckey]->bigtype;
                $styleclass = "";
                if($selectmodule_fieldinfo[$ckey]->auto_wordwrap == 'yes'){//xxy 2023-11-30 自动换行属性
                    $styleclass = "ld-wordwrap-listcontent";
                }

				if(in_array($ckey,$searchFieldCurrency) || in_array($ckey,$searchFieldDouble)){
					$tdhtml .="<td align=\"right\">";
				}else{
					$tdhtml .="<td align=\"left\">";
				}
                $smownername='';
                //20230512 Yujun  BUG0066185:
                if($ckey == $focus->list_link_field){
					//明细界面选择原单
                    if($tabDetailtypes[1] >= 1){
					   //24699: 付款单新建：选择供应商“一棵树”，显示在文本框的文字错误,删除urlencode
                       $tdhtml .= '<a class="'.$styleclass.'" href="javascript:void(0);" referencemodule=\''.$selectmodule.'\' record=\''.$entity_id.'\' linkname=\''.rawurlencode($entity[$focus->list_link_field]).'\' frommodule=\''.$_REQUEST['frommodule'].'\' columnname=\''.$_REQUEST['return_columnname'].'\' click_funtionname=\'detail_selectReference.setvalue()\' title="'.$entity[$focus->list_link_field].'">';
                    }else if($shareequally[1] >= 1){	//均摊
						$maxrowsshow = 5;
						//$tdhtml .= '<a href="javascript:void(0);"  title="'.$entity[$focus->list_link_field].'">';
                        $clickfun = 'selectrelated_special(\''.$selectmodule.'\',\''.$entity_id.'\',\''.rawurlencode($entity[$focus->list_link_field]).'\',\''.$_REQUEST['select_fieldname'].'\',\''.$_REQUEST['frommodule'].'\')';
                        $tdhtml .= '<a href="javascript:void(0);" onclick = "'.$clickfun.'" title="'.$entity[$focus->list_link_field].'">';
                    }else{
						//特殊控制：多个字段可以选择同一模块单据信息
						if(!empty($_REQUEST['select_fieldname'])){
							$clickfun = 'selectrelated_special(\''.$selectmodule.'\',\''.$entity_id.'\',\''.rawurlencode($entity[$focus->list_link_field]).'\',\''.$_REQUEST['select_fieldname'].'\',\''.$_REQUEST['frommodule'].'\')';
                            $tdhtml .= '<a class="'.$styleclass.'" href="javascript:void(0);" onclick = "'.$clickfun.'" title="'.$entity[$focus->list_link_field].'">';
						}else{
						     
                              $fldname=$fieldname;
                            if($VersionInfo['account'] == 'shenglawei' && $_REQUEST['selectmodule'] == 'CustomForm24' && $_REQUEST['frommodule'] == 'Accounts'){//圣维拉单选框点击带出特殊处理
                                $clickfun = 'selectrelated_special(\''.$selectmodule.'\',\''.$entity_id.'\',\''.rawurlencode($entity[$focus->list_link_field]).'\',\''.$fldname.'\',\''.$_REQUEST['frommodule'].'\')';
                                $tdhtml .= '<a class="'.$styleclass.'" href="javascript:void(0);" onclick = "'.$clickfun.'" title="'.$entity[$focus->list_link_field].'">';
							}else{
                                $clickfun = 'selectrelated(\''.$selectmodule.'\',\'\',\''.$entity_id.'\',\''.rawurlencode($entity[$focus->list_link_field]).'\',\''.$fldname.'\',\''.$smownername.'\',\''.$_REQUEST['frommodule'].'\')';
                                $tdhtml .= '<a class="'.$styleclass.'" href="javascript:void(0);" onclick = "'.$clickfun.'" title="'.$entity[$focus->list_link_field].'">';
							}
						}
					}
					if(in_array($ckey,$searchFieldCurrency)){
						$tdhtml .= $entity['currency_symbol'];
					}
					$tdhtml .= $entity[$focus->list_link_field] . '</a></td>';
				}
                else if($uitype == '222'){
                    if(!empty($entity[$ckey]['imagepath'])){
                        $title = getFixedLabel('handwritingdatetime') . ':' . $entity[$ckey]['datetime'];
                        $tdhtml .= '<img src="' . $entity[$ckey]['imagepath'] . '" alt="" title="" LANGUAGE=javascript align="absmiddle" width="50" height="80" style="transform:rotate(-90deg);left: 20px;position: relative;"></img>'
                                  .'<br /><span title="' . $title .'">'. $title .'</span>'.
                           '</td>' ;
                    }else{
                        $tdhtml .='<span title=""></span></td>';
                    }
                }
                else if($uitype == '33'){
                        $tdhtml .='<span title="'.str_replace('|##| ',',',$entity[$ckey]).'">' . str_replace('|##| ',',',$entity[$ckey]) . '</span></td>';
                }
                else{
					if(in_array($ckey,$searchFieldCurrency)){
						$tdhtml .= $entity['currency_symbol'];
					}
                    if(stripos($entity[$ckey],'ww-open-data')!==false)
                    {
                        $tdhtml .='<span>' . $entity[$ckey] . '</span></td>';
                    }
                    else{
                        if($fieldvaluecolor != ''){
                            $tdhtml .='<span class="'.$styleclass.'" title="'.$entity[$ckey].'" style="color:'.$fieldvaluecolor.'">' . $entity[$ckey] . '</span></td>';
                        }
                        else if($bigtype == 'picklist'){//下拉框字段颜色
                             global $global_picklist_colors_byvalue;
                            if($rowindex==1)
                            {
                                //同一个字段下拉框的值只需要获取一次就行了
                                crm_load_class_file("cls_PickList_Ori",'include/Functions/PickList');
                                
                                $picklistobj = new cls_PickList_Ori();
                                $picklistobj->getPickListValues($ckey,$fieldinfo);
                            }
                            $fieldName = $selectmodule_fieldinfo[$ckey]->getFieldName();
                          
                            $all_pick_colors = $global_picklist_colors_byvalue[$fieldName];

                            if(!empty($entity[$ckey])&&isset($all_pick_colors[$entity[$ckey]])&&!empty($all_pick_colors[$entity[$ckey]])){
                                $tdhtml .= '<a class="'.$styleclass.' ld-fieldbg-common" style="background-color:'.$all_pick_colors[$entity[$ckey]].';" title="'.$entity[$ckey].'">'.$entity[$ckey].'</a>';
                            }else{
                                $tdhtml .='<span class="'.$styleclass.'" title="'.$entity[$ckey].'">' . $entity[$ckey] . '</span></td>';
                            }
                        }
                        else{
                            $tdhtml .='<span class="'.$styleclass.'" title="'.$entity[$ckey].'">' . $entity[$ckey] . '</span></td>';
                        }
                    }
				}
                
			}
            if ($i%2 ==0){
                $trhtml = '';
                $trhtml = '<tr ispopupdoubleclick="yes" ondblclick="'.$clickfun.'"  id="poprow_'.$i.'" class="lvtColData" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')">';
			}else{
                $trhtml = '';
                $trhtml = '<tr ispopupdoubleclick="yes" ondblclick="'.$clickfun.'"  id="poprow_'.$i.'" class="lvtColDataBj" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')">';
            }
            $table.= $trhtml.$tdhtml;    
			$table .='</tr>';
			$i++;
		}
	}

    //37770: （1.6）合同订单模块>将客户名称字段的审批要求设置【已批准】>合同订单新增界面>选择客户弹出层>选择快速创建客户：在创建完客户后系统自动选择
    $smarty->assign("Approve_Demand",$approve_demand);//已批准：1
	$smarty->assign('TABLE',$table);
	$smarty->assign('TABLEDETAIL_ROW',$tabDetailtypes[1]);
	$smarty->assign("THEME", $theme);
	$smarty->assign("KEYIDS", $_REQUEST['keyids']);
	$smarty->assign("THEME_PATH",$theme_path);
	$smarty->assign("KEYWORDS",$_REQUEST['keywords']);
	$smarty->assign("serachfieldsOptions",$serachfieldsOptions);//获取选择相关单据的字段数组 zxm 20221214
	$smarty->assign("SELECTMODULE",$selectmodule);
	$smarty->assign("SEARCHPROMPT",$serachPrompt);
	$smarty->assign("FROMMODULE",$_REQUEST['frommodule']);
	$smarty->assign("TYPE",$_REQUEST['type']);
	$smarty->assign("ISADMIN",is_admin($current_user));
	$smarty->assign("SEARCH_TYPE",$_REQUEST['search_type']);
	//$smarty->assign("CP",$cp);
	$smarty->assign("LANGUAGETYPE",$languageType);
	$smarty->assign("FIELDNAME",$_REQUEST['fieldname']);
	$smarty->assign('RETURN_COLUMN',$_REQUEST['return_columnname']);
	$smarty->assign('SELECTFIELDNAME',$_REQUEST['select_fieldname']);
	$smarty->assign('SELECTREALTIONFROM',$_REQUEST['selectrelationfrom']);
	$smarty->assign('ISCREATE',$isCreate);
//	$system_deploy=getSys_deploy(151);
//	$deployvalue=$system_deploy['deploy_value'];	
    $smarty->assign("LIMITCOUNT",$maxrowsshow);

    $smarty->assign('VERSIONINFO',$VersionInfo);
    $smarty->assign("HAIGE_POTENTIALID_ALLOWEDIT",$potentialid_allowedit);
    $smarty->assign('SELECTMORERECORD',$selectmorerecord);
	if($VersionInfo['account']=='shanshui'&&$selectmodule=='Users'){
        //edit:duan reason：山水选择客户增加特殊说明
        $smarty->assign('RULEDESCRIPTIOM','yes');
    }
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
    //zkt 选择产品界面增加树状结构
    crm_load_class_file('cls_Module_Tree', 'include/utils');
    $cls_module_tree = cls_Module_Tree::getInstance($selectmodule);
    if($cls_module_tree->moduleenable=='yes'){
        //加载初始树状结构
        $modulelisttree = $cls_module_tree->getModuleListTree();
        $smarty->assign('POPUPMODULElISTTREE',$modulelisttree);
        //【近期使用】不使用树结构
        if(isset($_REQUEST['prodbomtag_d'])&&$_REQUEST['prodbomtag_d']=='3'){
            $modulelisttree['enable'] = 'no';
            $modulelisttree->moduleenable = 'no';
        }
        //BUG20240118-61 ls 240122 合同订单分录选产品，树结构选中分类和列表数据不符，列表数据为全部数据
        if ($modulelisttree['enable']=='yes') {
            $_REQUEST['isshowModuleListTree'] = 'yes';
        }
        $module_list_treeselectrecord=0;
        //若$_SESSION中储存的selectrecord值,为级联下拉值id，获取下级对应html

        if(isset($modulelisttree)&&$modulelisttree['enable']=='yes'&&!isset($modulelisttree['list'][$_SESSION['module_list_tree'][$selectmodule]['selectrecord']])){
            //获取下级对应html
            $sessionarr = $_SESSION['module_list_tree'][$selectmodule];
            $Inithtmlexpand = $cls_module_tree->getInithtmlexpand($sessionarr['selectrecord'],$sessionarr['list']);
            $smarty->assign('Inithtmlexpand',$Inithtmlexpand);
        }
        $cls_MyCRMcryptobj=new cls_MyCRMcrypt();
        $queryGenerator =  QueryGenerator::getInstance($selectmodule, $current_user,$SelectRelatedPopu->customView);
        $smarty->assign("Encrypt_TreeWhere",$cls_MyCRMcryptobj->encode($queryGenerator->getSqlNoTreeWhere($SelectRelatedPopu->page_list_query)));

    }

	if($_REQUEST['search_type']=='true'){
		$content=$smarty->fetch("SelectRelPopupContents.tpl");
	}else{
		$content=$smarty->fetch("SelectRelatedPopup.tpl");
	}
    $_REQUEST['diony']='diony';
    $arr['content']=$content;
    $arr['fullscreen']=getUsersettingByLabel('notbymodule','','Fullscreen');
    ConvertTojsonString(1,$arr,"success");
 
}else{
    ConvertTojsonString(-1,'',getFixedLabel('SELECTTHESOURCEDOCUMENTTYPE'));
}
?>