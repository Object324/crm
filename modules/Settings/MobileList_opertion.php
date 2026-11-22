<?php
global $adb,$current_user,$languageType;
require('user_privileges/user_language_'.$current_user->id.'.php');
$smarty = new lingdangCRM_Smarty;
if(!empty($_REQUEST['blockid']))
{
    $result=$adb->pquery('select * from ld_appparenttab where blockid=?',array($_REQUEST['blockid']));
    $parenttab_label=$adb->query_result($result,0,'parenttab_label');
    
}
$regopobj=RegOp::getInstance();
$prmauthenmodule_arr=explode(",",$regopobj->getPrmModules());
crm_load_class_file("cls_LinkModuleCustom",'include/utils');
if($_REQUEST['type'] == 'mobile_block_edit' || $_REQUEST['type'] == 'mobile_block_create'){
    $menu_user_type = 'crm';
    if($_REQUEST['type'] == 'mobile_block_edit' && !empty($_REQUEST['blockid'])) {

        $query = 'select blockname,enblockname,presence,allocatetype,allocateid,menudescription,menu_user_type from ld_appparenttab where blockid = ?';
        $editresult = $adb->pquery($query,array($_REQUEST['blockid']));
        $menu_user_type = $adb->query_result($editresult,0,'menu_user_type');
    }
    if($parenttab_label=='Reports')
    {
        $profile = new Profile();
        $reports=$profile->getMobileReportNames();
        foreach($reports as $index=>$val){
            $alltabs[$val['name'].":ld_tab"] = array('tabid'=>$val['name'],'tabname'=>$val['fieldlabel'],'tab_tablename'=>'ld_tab');
        }
       
        $alllinkmoduleinfos=cls_LinkModuleCustom::getAllLinkModuleCustomInfo();
        foreach($alllinkmoduleinfos as $tmpid =>$tmplinkmoduleinfo)
        {
            //zkt 20220418 51114通用问题：PC端--移动端功能，报表定制去除“项目甘特图”选项
            if(stripos($tmplinkmoduleinfo['url'],'gantindex.php')!==false&&$tmplinkmoduleinfo['linkmodule']=='Project')
            {
                continue;
            }
            //zxm 20230417 金蝶库存查询(PC)应当在移动端菜单定制的时候选择不到
            if(stripos($tmplinkmoduleinfo['url'],'file=stock_report')!==false)
            {
                continue;
            }
            //edit:can 20210820 47543: （81mis.com/kfbcrm）系统设置-在PC端系统设置-移动端功能菜单定制，报表区块设置时，可选模块应当只显示报表模块，不显示其他类型的模块
            if($languageType=='zh')
            {
                $tmplabel=$tmplinkmoduleinfo['zh_label'];
            }
            else
            {
                $tmplabel=$tmplinkmoduleinfo['en_label'];
            }
            $linkmodule=$tmplinkmoduleinfo['linkmodule'];
            if($linkmodule=='CustomEcharts'||$linkmodule=='CustomTables'||$linkmodule=='Customreport'||$linkmodule=='OftenUseReport')
                $linkmodule='ReportAnalysis';
            if($linkmodule!=''&&(!vtlib_isModuleActive($linkmodule)||!in_array($linkmodule,$prmauthenmodule_arr)))
            {
                continue;
            }
            $alltabs[$tmplinkmoduleinfo['id'].":ld_linkmodulecustom"] = array('tabid'=>$tmplinkmoduleinfo['id'],'tabname'=>$tmplabel,'tab_tablename'=>'ld_linkmodulecustom');
       }
    }
	else
    {
        if($languageType=='zh')
        {
            $linkmodulefieldlabelcolumn='zh_label';
        }
        else
        {
            $linkmodulefieldlabelcolumn='en_label';
        }
        $query = "select *from (select  ld_tab.tabid,ld_tab.name,ld_tranlabel.fieldlabel,'ld_tab' as  tab_tablename,tabsequence from ld_tab
                inner join ld_tranlabel on ld_tab.tabid=ld_tranlabel.tabid
                and ld_tranlabel.trantable='ld_tab' and ld_tranlabel.languagetype=?
                     where (mobilepresence like '%mobile%' or mobilepresence like '%weixin%') 
                     and ld_tab.presence <> 1
             union all
                 select   id as tabid ,linkmodule,$linkmodulefieldlabelcolumn as fieldlabel
                ,'ld_linkmodulecustom' as tab_tablename,(id+500000) as tabsequence from ld_linkmodulecustom)
                as tmp  order by tabsequence ";
      
    	$result = $adb->pquery($query,array($languageType));
    	$num_rows = $adb->num_rows($result);
        $spemodule = getWxSpecialModule();
    	if($num_rows > 0){
    		for($i = 0; $i<$num_rows; $i++){
    			$tabid = $adb->query_result($result,$i,'tabid');
    			$tabname = $adb->query_result($result,$i,'name');

                $tab_tablename=$adb->query_result($result,$i,'tab_tablename');
                $fieldlabel=$adb->query_result($result,$i,'fieldlabel');
                if($tabname=='Shopping'){ //订货商城
                    if(vtlib_isModuleActive('SalesOrder')){
                        $alltabs[$tabid.':'.$tab_tablename] = array('tabid'=>$tabid,'tabname'=>getTranstab($tabname),'tab_tablename'=>$tab_tablename);
                    }
                }
    			else if($tab_tablename=='ld_tab'&&vtlib_isModuleActive($tabname)){
                    if($menu_user_type=='prm'&&!in_array($tabname,$prmauthenmodule_arr))
                        continue;
                    $alltabs[$tabid.':'.$tab_tablename] = array('tabid'=>$tabid,'tabname'=>getTranstab($tabname),'tab_tablename'=>$tab_tablename);
					//订货商城  根据合同订单权限走
                }
                else if($tab_tablename=='ld_linkmodulecustom')
                {


                    //zkt 20220418 51114通用问题：PC端--移动端功能，报表定制去除“项目甘特图”选项
                    $tmplinkmoduleinfo = cls_LinkModuleCustom::getLinkModuleCustomInfoById($tabid);
                    $linkmodule=$tmplinkmoduleinfo['linkmodule'];

                    if($linkmodule=='CustomEcharts'||$linkmodule=='CustomTables'||$linkmodule=='Customreport'||$linkmodule=='OftenUseReport')
                        $linkmodule='ReportAnalysis';

                    if($linkmodule!=''&&! vtlib_isModuleActive($linkmodule))
                    {
                        continue;
                    }
                    else
                    {
                        if($menu_user_type=='prm'&&$linkmodule!=''&&!in_array($linkmodule,$prmauthenmodule_arr))
                            continue;
                    }
                    if(stripos($tmplinkmoduleinfo['url'],'gantindex.php')!==false&&$tmplinkmoduleinfo['linkmodule']=='Project')
                    {
                        continue;
                    }
                    //zxm 20230417 金蝶库存查询(PC)应当在移动端菜单定制的时候选择不到
                    if(stripos($tmplinkmoduleinfo['url'],'file=stock_report')!==false)
                    {
                        continue;
                    }
                    $alltabs[$tabid.':'.$tab_tablename] = array('tabid'=>$tabid,'tabname'=>$fieldlabel,'tab_tablename'=>$tab_tablename);
                }
    		}
    	}
        foreach($spemodule as $key=>$val){

            $alltabs[$key.':ld_tab'] = array('tabid'=>$key,'tabname'=>$val['tabname'],'tab_tablename'=>'ld_tab');
        }
    }
	if($_REQUEST['type'] == 'mobile_block_edit' && !empty($_REQUEST['blockid'])){
		//$query = 'select blockname,enblockname,presence,allocatetype,allocateid,menudescription,menu_user_type from ld_appparenttab where blockid = ?';
		$result =$editresult;// $adb->pquery($query,array($_REQUEST['blockid']));
		$blockname = $adb->query_result($result,0,'blockname');

        $enblockname = $adb->query_result($result,0,'enblockname');
		$presence = $adb->query_result($result,0,'presence');
        $allocatetype=$adb->query_result($result,0,'allocatetype');
        $allocateid=$adb->query_result($result,0,'allocateid');
        $menudescription = $adb->query_result($result,0,'menudescription');
        $menu_user_type = $adb->query_result($result,0,'menu_user_type');
       // $tab_tablename=$adb->query_result($result,0,'tab_tablename');
        if($parenttab_label=='Reports')
        {
            $query = "select relatename,tab_tablename,tabid from ld_appparenttabrel where blockid = ? ORDER BY sequence";
            $result = $adb->pquery($query,array($_REQUEST['blockid']));
            $reportrows=$adb->num_rows($result);
            for($k=0;$k<$reportrows;$k++)
           {
                $relatename=strtolower($adb->query_result($result,$k,'relatename'));
                $tab_tablename=$adb->query_result($result,$k,'tab_tablename');
                $tabid=$adb->query_result($result,$k,'tabid');
                if($tab_tablename=='ld_tab')
                {
                    foreach($reports as $info)
                    {
                        if($info['name']==$relatename)
                        {
                           $havetabs[$info['name'].':'.$tab_tablename] = array('tabid'=>$info['name'],'tabname'=>$info['fieldlabel'],'tab_tablename'=>$tab_tablename);
                            break;
                        }
                    }
                }
                else
                {
                    $tmplinkinfo=cls_LinkModuleCustom::getLinkModuleCustomInfoById($tabid);
                    if($languageType=='zh')
                    {
                        $tmplabel=$tmplinkinfo['zh_label'];
                    }
                    else
                    {
                        $tmplabel=$tmplinkinfo['en_label'];
                    }
                    $havetabs[$tabid.':'.$tab_tablename] = array('tabid'=>$tabid,'tabname'=>$tmplabel,'tab_tablename'=>$tab_tablename);
                }
           }
        }
        else
        {
            $query = "select tabid,tab_tablename from ld_appparenttabrel where blockid = ? ORDER BY sequence";
    		$result = $adb->pquery($query,array($_REQUEST['blockid']));
    		$num_rows = $adb->num_rows($result);
    		if($num_rows > 0){
    			for($i = 0; $i<$num_rows; $i++){
    				$tabid = $adb->query_result($result,$i,'tabid');
                    $tab_tablename=$adb->query_result($result,$i,'tab_tablename');
                    if($tab_tablename=='ld_tab')
                    {
                         if($tabid>=-1){
                            $tabname = getTabname($tabid);
                            if($menu_user_type=='prm'&&!in_array($tabname,$prmauthenmodule_arr))
                                    continue;
                            if(vtlib_isModuleActive($tabname))
        				        $havetabs[$tabid.':'.$tab_tablename] = array('tabid'=>$tabid,'tabname'=>getTranstab($tabname),'tab_tablename'=>$tab_tablename);
                        }else{
							if($tabid == -12 && vtlib_isModuleActive('SalesOrder')){
                                if($menu_user_type=='prm'&&!in_array("SalesOrder",$prmauthenmodule_arr))
                                    continue;
								$havetabs[$tabid.':'.$tab_tablename] = array('tabid'=>$tabid,'tabname'=>getFixedLabel('shopping'),'tab_tablename'=>$tab_tablename);
							}else{
								if(!array_key_exists($tabid,$spemodule)) continue;
								$havetabs[$tabid.':'.$tab_tablename] = array('tabid'=>$tabid,'tabname'=>$spemodule[$tabid]['tabname'],'tab_tablename'=>$tab_tablename);
							}
                        }
                    }
                    else
                    {
                            $tmplinkinfo=cls_LinkModuleCustom::getLinkModuleCustomInfoById($tabid);
                            $linkmodule=$tmplinkmoduleinfo['linkmodule'];
                            if($name=='CustomEcharts'||$name=='CustomTables'||$name=='Customreport'||$name=='OftenUseReport')
                                $name='ReportAnalysis';
                            if($menu_user_type=='prm'&&$linkmodule!='' && $menu_user_type=='prm')
                            {
                                if(!in_array($linkmodule,$prmauthenmodule_arr))
                                    continue;
                            }
                            if($languageType=='zh')
                            {
                                $tmplabel=$tmplinkinfo['zh_label'];
                            }
                            else
                            {
                                 $tmplabel=$tmplinkinfo['en_label'];
                            }
                            $havetabs[$tabid.':'.$tab_tablename] = array('tabid'=>$tabid,'tabname'=>$tmplabel,'tab_tablename'=>$tab_tablename);
                    }
    				
    			}
    		}
        }
		foreach($alltabs as $tabid => $tabinfo){
			if(isset($havetabs[$tabid])){
				unset($alltabs[$tabid]);
			}
		}
	}
    if(empty($allocatetype))$allocatetype = 'all';
    $smarty->assign('ALLOCATETYPE',$allocatetype);
    $smarty->assign('ALLOCATEID',$allocateid);
    $smarty->assign('MENUDESCRIPTION',$menudescription);
	$smarty->assign('ALLTABS',$alltabs);
	$smarty->assign('HAVETABS',$havetabs);
	$smarty->assign('BLOCKNAME',$blockname);
    $smarty->assign('ENBLOCKNAME',$enblockname);
    $smarty->assign('menu_user_type', $menu_user_type);
    $smarty->assign('FUNCTIONMENUDESCRIPTION', getFixedLabel('APPFUNCTION').getFixedLabel('MENU').getFixedLabel('CAMCARDCAPTION'));
    $presence=$presence==0?'yes':'no';
	$smarty->assign('PRESENCE',$presence);
	$smarty->assign('BLOCKID',$_REQUEST['blockid']);
	//$smarty->display('MobileBlock_create.tpl');
	$_REQUEST['diony']='diony';
	if(!empty($parenttabid)){
		$arr['title'] = getFixedLabel('EDIT');
	}else{
		$arr['title'] = getFixedLabel('MobileAppMenuCustomization');
	}
	$arr['oktext']=getFixedLabel("SAVE");
	$arr['canceltext']=getFixedLabel("CANCEL");
	$str=$smarty->fetch("MobileBlock_create.tpl");
	$arr['content']=$str;
	ConvertTojsonString(1,$arr,"success");
	exit();
}else{
    global $languageType;
	$query = 'select blockid,sequence,blockname,enblockname from ld_appparenttab where presence in(0,1) ORDER BY sequence asc';
	$result = $adb->pquery($query,array());
	$num_rows = $adb->num_rows($result);
	if($num_rows > 0){
		for($i = 0; $i<$num_rows; $i++){
			$blockid = $adb->query_result($result,$i,'blockid');
			$sequence = $adb->query_result($result,$i,'sequence');
			$blockname = $adb->query_result($result,$i,'blockname');
            $enblockname = $adb->query_result($result,$i,'enblockname');
            if($languageType == 'en'){
                $allblocks[$blockid] = array('sequence'=>$sequence,'blockname'=>$enblockname);
            }else{
                $allblocks[$blockid] = array('sequence'=>$sequence,'blockname'=>$blockname);
            }
		}
	}
    $arr['title'] = getFixedLabel('SortMenu');
    $arr['oktext']=getFixedLabel("SAVE");
	$arr['canceltext']=getFixedLabel("CANCEL");
    $smarty->assign('ALLBLOCKS',$allblocks);
    $str=$smarty->fetch("MobileBlock_sort.tpl");
    $arr['content']=$str;
    ConvertTojsonString(1,$arr,"success");
}
exit();
?>