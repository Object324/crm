<?php

/**
 * 修改统一编码utf-8
 */
/**
*@author:andrew
*@data:20150407
*@reason:首页组件获取销售漏斗数据
*/
//global $adb,$current_user,$list_max_entries_per_page_new;
//
//global $related_header,$related_left_type;
//
//if($_REQUEST['type']=='deleted'){
//    //删除
//    $DELETEDSQL="UPDATE ld_potential SET deleted=1 WHERE potentialid=".$_REQUEST['DeleteID'];
//    $adb->pquery($DELETEDSQL,array());
//}else{
//        if(!isset($_REQUEST['sales_stage']))
//             {
//                //点击列头排序
//                $_REQUEST['sales_stage']=$_SESSION['home_potentials_sales_stage'];
//             }
//            if(!isset($_REQUEST['start']))
//            {
//                 $_REQUEST['start']=$_SESSION['home_potentials_page_start'];
//            }
//    include(globalStatic::$root_directory.'modules/CustomView/PotentialsSalesStageView.php');
//
//    $smarty = new lingdangCRM_Smarty();
//
//    if(isset($_REQUEST['sales_stage']) && $_REQUEST['sales_stage'] != ''
//        && isset($_REQUEST['SearchScope']) && $_REQUEST['SearchScope'] !='')
//    {
//        $SQL="SELECT * FROM ld_field WHERE tabid=(SELECT tabid FROM ld_tab where name='Potentials') AND fieldname='sales_stage' AND presence<>1";
//        $result=$adb->pquery($SQL,array());
//        $rowCount = $adb->num_rows($result);
//        //获取销售全部的数据分类
//        if($rowCount>0){
//
//             $customView = new PotentialsSalesStateView('Potentials');
//             $viewid=$customView->getViewId();
//
//            $sales_stageid=$_REQUEST['sales_stage'];
//            $_SESSION['home_potentials_sales_stage']=$sales_stageid;
//            $_SESSION['home_potentials_page_start']=$_REQUEST['start'];
//
//            //将销售阶段ID转成中文字段.如果修改的话，其他页面传过来的也要是ID
//            //Eidtor:gyq_64M Reason:下拉框改进 Date:2018/3/19 0019 下午 2:14
//            crm_load_class_file("cls_PickList", 'modules/PickList');
//            $objpinklist = new cls_PickList();
//            $sales_stage = $objpinklist->getPickListValues_Byid($_REQUEST['sales_stage']);
//            /*$SQLsales_stage="SELECT sales_stage FROM ld_sales_stage WHERE sales_stage_id=".$_REQUEST['sales_stage'];
//            $result=$adb->pquery($SQLsales_stage,array());
//            $sales_stage=$adb->query_result($result,0,'sales_stage');*/
//            $_REQUEST['sales_stage']=$sales_stage;
//           $deployarray=getSys_deploy(205);//设置销售机会是否显示产品分录明细:0是，1否
//           ////edit:can 2020730 42172: （61mis.com/kfbcrm）首页>销售漏斗弹出层：销售漏斗中所显示的字段与销售机会列表所显示的字段不一致。
//           $queryGenerator=QueryGenerator::getInstance('Potentials', $current_user,$customView);
//
//            $focus = CRMEntity::getInstance('Potentials');
//            //$focus->initSortbyField('Potentials');
//            $sorder = strtoupper($focus->getSortOrder());
//
//
//            $customsortorder = $queryGenerator->getSequence_fields();
//            $queryGenerator->initForCustomViewById($viewid);
//            //作为列表页面查找销售阶段来生成SQL
//
//            $queryGenerator->getQuery();//生成sql
//            $list_query='select distinct ' .$queryGenerator->getSelectClauseColumnSQL().
//
//            $queryGenerator->getChartFrom();
//			if(!empty($_REQUEST['date_custom']) && $_REQUEST['search_date'] == 'custom')
//				$date = getHomeDateScope($_REQUEST['date_custom']);
//			else
//				$date = getHomeDateScope($_REQUEST['search_date']);
//           	$scopeobj = ScopOfAuthority::getInstance($adb,'Potentials');
//            $scopesql = $scopeobj->getHomeSmOwnerSearchSql($_REQUEST['SearchScope'],$_REQUEST['selectuid']);
//			//chj 2020/12/24 43887: （https://61mis.com/kfbcrm/ [^]）客户问题（陈修宏），销售机会单据列表界面显示产品分录明细信息，首页销售漏斗点击【销售阶段】后，销售漏斗弹出层中显示没有数据（需要补丁）
//
//             if(!empty($scopesql))
//             {
//				 $scopesql = 'ld_potential.'.$scopesql;
//				 $userids = explode(',',$_REQUEST['selectuid']);
//                 if($scopeobj->modulescolist['Potentials']['viewselfbills']==1 && in_array($current_user->id,$userids))
//                  {
//                            $scopesql.=' or ld_potential.smcreatorid='.$current_user->id ;
//
//                  }
//                  //19144: 首页>组件视图>销售漏斗：查看范围为我的、我创建的、高级、单选人员，点击销售漏斗，列表不显示数据。
//                  // print_r(stripos($list_query ,'ld_tabshare'));
//                  if(stripos( $list_query,'ld_tabshare')!==false)
//                  {
//                    $scopesql.=' or ld_tabshare.viewuserid='.$current_user->id;
//                  }
//                  $scopesql='( '.$scopesql.') and ld_potential.sales_stage=\''.$sales_stage.'\'';
//
//             }
//             else
//             {
//                $scopesql= 'ld_potential.sales_stage=\''.$sales_stage.'\'';
//             }
//            //zxm 20230410 BUG0064354   首页销售漏斗，更改首页审批状态勾选值，点击销售漏斗显示数据数量没有跟随变化
//            $list_query.=' where  ld_potential.deleted=0 and '.$scopesql;
//            if(!empty($_REQUEST['approve_value'])){
//                crm_load_function_file('getApproveQuery','modules/Home','HomeUtils');
//                $approvestatus = getApproveQuery('ld_potential');
//                $list_query.= $approvestatus;
//            }
//            $list_query.=  ' and ld_potential.createdtime ' . $date;
//
//            $count_result = $adb->query(mkListCountQuery($focus,$list_query));
//            if(!empty($count_result))
//        		$noofrows = $adb->query_result($count_result,0,"count");
//            else
//        		$noofrows = null;
//            $queryMode = (isset($_REQUEST['query']) && $_REQUEST['query'] == 'true');
//            $start = ListViewSession::getRequestCurrentPage('Potentials', $noofrows, $viewid, $queryMode);
//             crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
//            $navigation_array = VT_getSimpleNavigationValues($start,$list_max_entries_per_page_new,$noofrows);
//            $limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
//			$page_list_query='select  distinct potentialid from ld_potential';
//			if(($current_user->is_admin!='on'))
//			{
//				$page_list_query.= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_potential.potentialid";
//
//			}
//            $page_list_query .= ' where deleted=0   and '.$scopesql ;
//            //审批条件 BUG0064516 zxm 20230412 首页销售漏斗，选择审批状态后，点击销售漏斗阶段，“本页合计”和“全部合计”没有跟随变化
//            $extraWhere = '';
//            if(!empty($_REQUEST['approve_value'])){
//                $extraWhere .= $approvestatus;
//            }
//            $extraWhere .= ' and ld_potential.createdtime ' . $date;
//            $page_list_query .= $extraWhere;
//             list($page_list_query,$order_by,$sorder) = $queryGenerator->customview->getOrderWhere($page_list_query);
//
//
//        	    $list_result = $adb->pquery($list_query. " order by $order_by $sorder LIMIT $limit_start_rec, $list_max_entries_per_page_new", array());
//
//          	$ustring = getSearchURL($_REQUEST);
//        	$url_string .= "&query=true$ustring";
//
//            $skipAction=false;
//            if($deployarray['deploy_value']==0)
//            {
//                //edit:can 2020730 42172: （61mis.com/kfbcrm）首页>销售漏斗弹出层：销售漏斗中所显示的字段与销售机会列表所显示的字段不一致。
//                  crm_load_class_file('ProductDetail_ListController','include/ListView/ProductDetail');
//                  $controller = new ProductDetail_ListController($adb, $current_user, $queryGenerator);
//            }
//
//            else{
//                $controller = new ListViewController($adb, $current_user, $queryGenerator);
//            }
//
//
//            $listview_header = $controller->getListViewHeader($focus,'Potentials',$url_string,$sorder,$order_by,$skipAction);
//           $listview_header=str_replace("getListViewEntries_js","PotentialsSalesState_list",$listview_header);
//
//            $listview_entries = $controller->getListViewEntries($focus,'Potentials',$list_result,$navigation_array,$skipAction,false,'DeskTopPotentials');
//
//            $table_id_index=$focus->table_index;
//            $list_query = $queryGenerator->getQuery('',2);
//            $limit_start_rec = ($start-1) * $list_max_entries_per_page_new;
//            $list_result = $adb->pquery($list_query, array());
//            $recordListRangeMsg = getRecordRangeMessage($list_result, $limit_start_rec,$noofrows);
//            $smarty->assign('recordListRange',$recordListRangeMsg);
//            $smarty->assign('NUMOFROWS',$noofrows);
//            $navigationOutput = getRelatedDeskTableHeaderNavigation($navigation_array, $url_string, 'Potentials', 'index', $viewid,$sales_stageid);
//            //$totalfldhtml = $controller->getTotalFldCount($list_query,$list_result,$noofrows);
//
//            crm_load_class_file('clsTotal_List','include/ListView');
//            crm_load_class_file('cls_TotalList_showPotential','modules/Home');
//            $clstotalobj=new cls_TotalList_showPotential($controller,$scopesql,$extraWhere);
//
//            $totalfldhtml = $clstotalobj->getTotalFldCount($page_list_query." LIMIT $limit_start_rec, $list_max_entries_per_page_new ",$list_result,$noofrows);
//            $smarty->assign('TOTALFLDHTML',$totalfldhtml);
//        }
//		$ModuleViewFieldsWidth = getModuleWidth($focus,$controller->getModuleViewFieldsWidth(),'Potentials');
//		$operationWidth = $focus->getModuleLogic('Potentials')->getListButtomName()+3;
//        $table = '<div style="width:100%; overflow: auto; min-height: 200px; max-height:460px;">';
//		$table .='<div style="height:100%;width:'.$customView->pageWidthPercent.'%;">';
//		$table .='<table border=0 cellspacing=1 cellpadding="0" width="'.$customView->pageWidthPercent.'%" class="listEntries">';
//		$table .='<tr>';
//		$table .='<input type="hidden" name="START" id="START" value="'.$start.'">';
//		$table .='<input type="hidden" name="sales_stage" id="sales_stage" value="'.$sales_stageid.'">';
//		//列头
//        //$listview_header[] = getFixedLabel("OPERATING");
//		foreach($listview_header as $key=> $field_label){
//			if(sizeOf($listview_header) == $key + 1){
//				$table .='<th style="width:'.$operationWidth.'px;">'.$field_label.'</th>';
//			}else{
//				$table .='<th nowrap="nowrap">'.$field_label.'</th>';
//			}
//		}
//		$i = 0;
//		if(!empty($listview_entries)){
//			foreach($listview_entries as $recordid => $listInfo){
//				$j = $i++;
//				$table .='<tr id="relation_potentials_'.$j.'" class="lvtColData" onmouseout="relationListOnMouseOut(\'potentials_'.$j.'\',\'on\');" onmouseover="relationListOnMouseOver(\'potentials_'.$j.'\');">';
//				foreach($listInfo as $val=>$value){
//                    if($value=='&&'){
//                        $value = '';
//                    }
//                    if(strpos($val,'_N')>0)
//			        $table .='<td style="word-wrap:break-word;" align="right">'.$value.'</td>';
//                    else
//                    $table .='<td style="word-wrap:break-word;">'.$value.'</td>';
//				}
//				$table .='</tr>';
//			}
//		}else{
//			$table .='<tr style="height: 25px;" bgcolor="white">';
//			$table .='<td colspan='.sizeOf($listview_header).' align=\'center\'><i>'.getFixedLabel('NONE').'</i></td>';
//			$table .='</tr>';
//		}
//		if(!empty($totalfldhtml)){
//			$table .=$totalfldhtml;
//
//		}
//
//		$table .='</table>';
//		$table .='</div>';
//		$table .='</div>';
//		$smarty->assign('TABLE',$table);
//        //$smarty->assign('PAGEWIDTHPERCENT',$customView->pageWidthPercent);
//        $smarty->assign("NAVIGATION", $navigationOutput);
//        $smarty->assign('LISTHEADER', $listview_header);
//        $smarty->assign('START', $start);//删除时候用的，在页面隐藏域，js直接抓取
//        $smarty->assign('sales_stage', $sales_stageid);//删除时候用的，在页面隐藏域，js直接抓取
//        $smarty->assign('LISTVIEWENTRIES', $listview_entries);
//
//        $str= $smarty->fetch("Home/showPotentials.tpl");
//        $_REQUEST['diony']='diony';
//        $arr['content']=$str;
//        $arr['title']=getFixedLabel("SALESFUNNEL");
//        $arr['oktext']='';
//        $arr['canceltext']='';
//        ConvertTojsonString(1,$arr,"success");
//
//        exit;
//    }
//}
?>