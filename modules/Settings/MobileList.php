<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @project 工作协同模板
 * @author Tujt 2015-05-05
 */
global $adb,$current_user;
require('user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty;
$menu_user_type = 'crm';
if(!empty($_REQUEST['ajax']) && $_REQUEST['ajax'] == true){
	if($_REQUEST['type'] == 'Inactivate'){	//停用
		$adb->pquery('update ld_appparenttab set presence = 1 where blockid = ?',array($_REQUEST['block_id']));
	}else if($_REQUEST['type'] == 'Activate'){	//启用
		$adb->pquery('update ld_appparenttab set presence = 0 where blockid = ?',array($_REQUEST['block_id']));
	}else if($_REQUEST['type'] == 'deleteblock'){	//删除区块
		$adb->pquery('delete from ld_appparenttab where blockid = ?',array($_REQUEST['block_id']));
		$adb->pquery('delete from ld_appparenttabrel where blockid = ?',array($_REQUEST['block_id']));
	}else if($_REQUEST['type'] == 'allocate'){	//列表分配
		$query = "update ld_appparenttab set allocatetype = ?,allocateid = ? where blockid = ?";
		$adb->pquery($query,array($_REQUEST['radiotype'],$_REQUEST['selectallocateid'],$_REQUEST['record']));
		$_REQUEST['diony']='yes';
		ConvertTojsonString(1,array(),"success");
	}else if($_REQUEST['type'] == 'checkblockname'){	//区块名称验证
		$query = 'select 1 from ld_appparenttab where blockname = ?';
		if(!empty($_REQUEST['blockid']) && $_REQUEST['blockid'] > 0){
			$query .= ' and ld_appparenttab.blockid != ' . $_REQUEST['blockid'];
		}
		$result = $adb->pquery($query,array($_REQUEST['mobileblock_name']));
		if($adb->num_rows($result) >= 1){
			echo 'error';
            exit();
		}
        //英文名称验证
        $query = 'select 1 from ld_appparenttab where enblockname = ?';
		if(!empty($_REQUEST['blockid']) && $_REQUEST['blockid'] > 0){
			$query .= ' and ld_appparenttab.blockid != ' . $_REQUEST['blockid'];
		}
		$result = $adb->pquery($query,array($_REQUEST['mobileblock_name_en']));
		if($adb->num_rows($result) >= 1){
			echo 'enrepeat';
            exit();
		}
	}else if($_REQUEST['type'] == 'SaveMobileBlock'){	//新增、编辑保存
        $allocatetype=$_REQUEST['customscope_type'];//可见范围设置
        $allocateids=$_REQUEST['customscope_ids'];//可见范围设置
        if($allocatetype=='')
        {
            $allocatetype='all';
        }
        if($allocatetype=='all')
        {
            $allocateids='';
        }
		if(!empty($_REQUEST['blockid'])){
			$blockid = $_REQUEST['blockid'];
            $sql='select * from ld_appparenttab where blockid=?';
            $result=$adb->pquery($sql,array($blockid));
            $parenttab_label=$adb->query_result($result,0,'parenttab_label');
            $menu_user_type=$adb->query_result($result,0,'menu_user_type');
			$adb->pquery('update ld_appparenttab set blockname=?,enblockname=?,presence=?,allocatetype=?,allocateid=?,menudescription=?
                            where blockid = ?',array($_REQUEST['mobileblock_name'],$_REQUEST['mobileblock_name_en'],$_REQUEST['presence'],$allocatetype,$allocateids,$_REQUEST['menudescription'],$blockid));
			$adb->pquery('delete from ld_appparenttabrel where blockid = ?',array($blockid));
		}else{
			$query = 'select IFNULL(max(sequence),0) as max_sequence from ld_appparenttab';
			$result = $adb->pquery($query,array());
			$max_sequence = $adb->query_result($result,0,0);
			$adb->pquery('insert into ld_appparenttab(blockname,enblockname,presence,sequence,allocatetype,allocateid,menudescription) 
                            values (?,?,?,?,?,?,?)',array($_REQUEST['mobileblock_name'],$_REQUEST['mobileblock_name_en'],$_REQUEST['presence'],$max_sequence+1,$allocatetype,$allocateids,$_REQUEST['menudescription']));
			$blockid = $adb->getLastInsertID();
		}
		if(!empty($_REQUEST['tabids'])){
			$tabid_arr = explode(',',$_REQUEST['tabids']);
            if($parenttab_label=='Reports')
			{
			     $profile=new Profile();
                 $mobilereports=$profile->getMobileReportNames();
               
                 
    			  foreach($tabid_arr as $key => $relatename){
    			         $reportid=0;
                        $tmprelatenames=explode(':',$relatename);
                        $tmprelatename=$tmprelatenames[0];
                        $tab_tablename=$tmprelatenames[1];
    			         foreach($mobilereports as $index=>$info)
                         {
                            if($info['name']==$tmprelatename)
                            {
                                $reportid=$info['id'];
                                break;
                            }
                         }
                         if(empty($reportid)&&$tab_tablename=='ld_tab')
                         {
                            continue;
                         }
                         if($tab_tablename=='ld_linkmodulecustom')
                         {
                            $reportid=$tmprelatename;
                         }
    				$adb->pquery('insert into ld_appparenttabrel(blockid,tabid,sequence,relatename,tab_tablename) values
                                 (?,?,?,?,?)',array($blockid,$reportid,$key+1,$tmprelatename,$tab_tablename));
    			 }
			}
            else
            {
                foreach($tabid_arr as $key => $tabid){
                    $tabids=explode(":",$tabid);
                    
				$adb->pquery('insert into ld_appparenttabrel(blockid,tabid,sequence,tab_tablename) values (?,?,?,?)'
                    ,array($blockid,$tabids[0],$key+1,$tabids[1]));
			}
            }
            $version_info = getVersionInfo();
            if($version_info['account']=='yuwang')
            {
                // zkt 禹王设置帆软报表连接模块至移动端功能列表区块
                $yuwangsql = "select id from ld_linkmodulecustom 
                    left join ld_appparenttabrel on ld_appparenttabrel.tabid = ld_linkmodulecustom.id and tab_tablename = 'ld_linkmodulecustom'
                    where entitytype = ? and linkmodule = ? and blockid = ?";
                $yuwangresult = $adb->pquery($yuwangsql,array('customfine','Customreport',$blockid));
                $yuwangrows = $adb->num_rows($yuwangresult);
                for($i=0;$i<$yuwangrows;$i++)
                {
                    $linkmoduleid = $adb->query_result($yuwangresult,$i,'id');
                    $yuwangupdate = "update ld_appparenttabrel set checkphp = ? where tabid = ? and tab_tablename = ? and blockid = ?";
                    $adb->pquery($yuwangupdate,array('FineRecordgettoken',$linkmoduleid,'ld_linkmodulecustom',$blockid));
                }
            }
		}
	}else if($_REQUEST['type'] == 'SaveMobileBlockSort'){	//区块排序
		if(!empty($_REQUEST['tabids'])){
			$tabids_arr = explode(',',$_REQUEST['tabids']);
			$sequence = 1;
			foreach($tabids_arr as $blockid){
				$adb->pquery('update ld_appparenttab set sequence = ? where blockid = ?',array($sequence,$blockid));
				$sequence++;
			}
		}
	}
    unsetCacheDirectory('wxmodules');
}
//菜单设置分crm用户和prm用户 zxm 20240911  XUQIU20240826-02 经销商渠道定制--增加移动端相关菜单设置
$query = 'select * from ld_appparenttab 
          where presence in(0,1) and menu_user_type=? ORDER BY sequence';
$result = $adb->pquery($query,array($menu_user_type));
$num_rows = $adb->num_rows($result);
$del_btn = 'no';
$profile = new Profile();
$reports=$profile->getMobileReportNames();

if($num_rows > 0){
	$table = '';
    crm_load_class_file("cls_LinkModuleCustom",'include/utils');
    
	for($i = 0; $i<$num_rows; $i++){
		$module_name = array();
		$blockid = $adb->query_result($result,$i,'blockid');
		$blockname = $adb->query_result($result,$i,'blockname');
        $enblockname = $adb->query_result($result,$i,'enblockname');
		$presence = $adb->query_result($result,$i,'presence');
		$systemdefault = $adb->query_result($result,$i,'systemdefault');
		$parenttab_label=$adb->query_result($result,$i,'parenttab_label');
		$allocatetype=$adb->query_result($result,$i,'allocatetype');
		$allocateid=$adb->query_result($result,$i,'allocateid');
        
  
        if($parenttab_label=="Reports")
        {
            $sql='select * from ld_appparenttabrel where blockid= '.$blockid .' order by sequence asc ';
            $reportresult=$adb->pquery($sql,array());
            $reportrows=$adb->num_rows($reportresult);
        
            for($k=0;$k<$reportrows;$k++)
           {
                $relatename=strtolower($adb->query_result($reportresult,$k,'relatename'));
                $tab_tablename=$adb->query_result($reportresult,$k,'tab_tablename');
                $tabid=$adb->query_result($reportresult,$k,'tabid');
                if($tab_tablename=='ld_tab')
                {
                    foreach($reports as $info)
                    {
                        if($info['name']==$relatename)
                        {
                            $module_name[]=$info['fieldlabel'];
                            break;
                        }
                    }
                }else
                {
                  
                    $linkinfo=cls_LinkModuleCustom::getLinkModuleCustomInfoById($tabid);
                    if($languageType=='zh')
                            $module_name[]=$linkinfo['zh_label'];
                    else  if($languageType=='en')
                            $module_name[]=$linkinfo['en_label'];
                }
           }
            
        }
        else
        {
                    $blocksql= 'SELECT * FROM
                        	(
                        		SELECT app.blockid,app.tabid,app.sequence,ld_tab.presence,tab_tablename
                        		FROM ld_appparenttabrel app
                        		INNER JOIN ld_tab ON ld_tab.tabid = app.tabid
                                and tab_tablename="ld_tab"
                        		  UNION
                       			SELECT blockid,tabid,sequence,0,"ld_tab" as tab_tablename
                       			FROM ld_appparenttabrel WHERE tabid < -1
                                union 
                                    SELECT app.blockid,app.tabid,app.sequence,0 as presence,tab_tablename
                        		FROM ld_appparenttabrel app
                        		INNER JOIN ld_linkmodulecustom ON ld_linkmodulecustom.id = app.tabid
                                and tab_tablename="ld_linkmodulecustom"
                        	) a
                            WHERE blockid = ? AND presence <> 1 ORDER BY sequence;';
            
        		$res = $adb->pquery($blocksql,array($blockid));
        		$res_num_rows = $adb->num_rows($res);
        		for($j = 0;$j<$res_num_rows; $j++){
        			$tabid = $adb->query_result($res,$j,'tabid');
                    $tab_tablename=$adb->query_result($res,$j,'tab_tablename');
                    if($tab_tablename=='ld_tab')
                    {
                          if($tabid>=-1){
                                $tabname = getTabname($tabid);
                    			if(vtlib_isModuleActive($tabname)){
                    				$module_name[] = getTranstab($tabname);
                    			}
                            }else{
								if($tabid == -12 && vtlib_isModuleActive('SalesOrder')){
									$module_name[] = getFixedLabel('shopping');	//订单商城
								}else{
									$spemodule = getWxSpecialModule();
									if(!array_key_exists($tabid,$spemodule)) continue;
									$module_name[] = $spemodule[$tabid]['tabname'];
								}
                            }
                    }
                    else
                    {
                         $linkinfo=cls_LinkModuleCustom::getLinkModuleCustomInfoById($tabid);
                            if($languageType=='zh')
                                    $module_name[]=$linkinfo['zh_label'];
                            else  if($languageType=='en')
                                    $module_name[]=$linkinfo['en_label'];
                    }
        			
        		}
        }
        
		if(sizeOf($module_name) < 1){
			$blockempty = 1;//gyqX170707
		}
        else
        {
            $blockempty = 0;
        }
		if ($i%2 ==0) {
			$table.='<tr id="setting_'.$i.'" class="lvtColData ld-category-draggable"  tag="'.$blockid.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'on\')" >';
		}
		else{
			$table.='<tr id="setting_'.$i.'" class="lvtColDataBj ld-category-draggable" tag="'.$blockid.'" onmouseover="listOnMouseOver(ld(this))" onmouseout="listOnMouseOut(ld(this),\'On\')" >';
		}
		$number = $i + 1;
		$table .= '<td align="left">' . $number . '</td>';
		$table .= '<td align="left">' . $blockname . '</td>';
        $table .= '<td align="left">' . $enblockname . '</td>';
		$table .= '<td align="left">' . implode('、',$module_name) . '</td>';
        //duan 2022-2-16 关于是否启用按钮的显示优化
        $table .= '<td><input type="checkbox" onclick="change_tablefield_presence(this,'.$blockid.',\'appparenttab\')" class="second_switch" ';
		if($presence == 1 || $blockempty==1){
            $table .= ' /></td>';
		}else{
			$table .= 'checked /></td>';
		}
		$button = '';
		$button .= '<a class="Anu3_a" btn="editBtn" record="'.$blockid.'" onclick="fun_mobile_list.getInstance(\''.$blockid.'\').MobileBlock_edit()">'.getFixedLabel('EDIT').'</a>';	//编辑
		$button .= '<a class="Anu3_a" btn="editBtn" record="'.$blockid.'" onclick="ScopePopup_Details.getInstance().allocateTemplate(this,\'0\',\''.$blockid.'\',\''.$allocateid.'\',\''.$allocatetype.'\',\'MobileList\');">'.getFixedLabel('ALLOCATE').'</a>';	//分配
		/*
        if( $blockempty==1){
            $button .= ' ';
        }else{
            if($presence == 1){
                $button .= '<a class="Anu3_a" btn="addBtn" record="'.$blockid.'" onclick="fun_mobile_list.getInstance(\''.$blockid.'\').MobileBlock_activate()">'.getFixedLabel('ACTIVATE').'</a>';
            }else{
                $button .= '<a class="Anu3_a" btn="addBtn" record="'.$blockid.'" onclick="fun_mobile_list.getInstance(\''.$blockid.'\').MobileBlock_inactivate()" >'.getFixedLabel('INACTIVATE').'</a>';
            }
        }*/
		//系统预置字段不能编辑
		//if($systemdefault == 'no'){
		   if($parenttab_label!="Reports")
			         $button .= '<a class="Anu3_a redFont" btn="addBtn" record="'.$blockid.'" onclick="fun_mobile_list.getInstance(\''.$blockid.'\').MobileBlock_delete()">'.getFixedLabel('DELETE').'</a>';
			$del_btn = 'yes';
        $button .='<a class="Anu3_a ld-dragicon drag-handle sort-tip-items" data-tip="'.getFixedLabel('DRAGTOSORT').'"  data-direction="left" data-type="position" style="display:none;cursor:move;" ></a>';
		//}
        //wym 231228 BUG0077982 鼠标悬浮上去后 英文版字体加粗后导致宽度不够 现在加5px
		$table .= '<td align="left" width="175px">' . $button . '</td>';
		$table .= '</tr>';
	}
}
$smarty->assign('DELBTN',$del_btn);
$smarty->assign('MOBILEMODULEHTML',$table);
$smarty->assign('LANGUAGETYPE',$languageType);
$_REQUEST['diony']='yes';
// require_once('SetmenuControl.php');
if($menu_user_type=='prm'){
    echo implode('、',$module_name);exit();
}
else
if($_REQUEST['ajax']&&$_REQUEST['ajax']==true){
    $smarty->display('MobileListEntries.tpl');
	exit();
}
else
{
    $arr['content']= $smarty->fetch('MobileList.tpl');
    ConvertTojsonString(1,$arr,"success");
}
?>