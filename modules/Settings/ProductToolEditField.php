<?php
global $adb,$current_user;


require('include/ProductToolFields/cls_AutoLoadDetailFields.php');
$languageType= getLanguageType($current_user);
//edit:can 20210331 45236: （61mis.com/kfbcrm）分录引用字段功能；系统设置-单据分录定制-佣金单；以佣金单分录为例，当分录中有源单字段时，应可以选择新建源单的引用字段
global $selected_referencemodule_fieldlabel;
$smarty=new lingdangCRM_Smarty();
$isProductDetails = 'no';
$autoLoadInstance = new INSTANCE();
/* editor:gyq_10  reason:費用報銷文本类型下拉框事件 */
if(is_string($_REQUEST['selectFieldType_ajax'])&&strlen($_REQUEST['selectFieldType_ajax'])>0){
    echo $autoLoadInstance->fieldType_onchange();
    exit;
}

$tabid = $_REQUEST['tabid'];
$isModule = getTabModuleName($tabid);
$_REQUEST['frommodule']=$isModule;
$producttoolfields = $autoLoadInstance->autoLoad($tabid,'Field');

if(get_file_address($isModule,'ProductDetails')){
	$isProductDetails = 'yes';
}
if(!empty($_REQUEST['selectsourcetype'])&&($isModule=='CashBill'||$isModule == 'SendCashBill')){
    //获取收款单和付款单对应的源单类型,是否显示源单明细
    crm_load_class_file('cls_OptionModule','include/OptionModule');
    $objs=new cls_OptionModule($isModule,0);
    $soureoptioninfoarr=$objs->getData();
    $selectsourcetypeid=getTabid($_REQUEST['selectsourcetype']);
    if($soureoptioninfoarr[$tabid][$selectsourcetypeid]['withdetail']=='yes'){
        $isProductDetails = 'yes';
    }
}
$AllModuleProductToolField = $producttoolfields->getModuleProductToolField($tabid,$languageType);
$columnForProductFields = array('productname');
foreach($AllModuleProductToolField as $toolfields){
	if(is_object($toolfields)){
		if($toolfields->getinput_type() == 1){
			$columnForProductFields[] = $toolfields->getColumnName();
		}
	}else{
		if($toolfields['input_type'] == 1){
			$columnForProductFields[] = $toolfields['columnname'];
		}
	}
}
/*if($tablename == 'ServiceContracts'){
	$fieldarr['servicecontracts_start_date'] = get('PERIODOFSERVICEEND');
}*/
//模块中已设置的关联选择模块
global $selected_referencemodule;
$selected_referencemodule = [];
$selected_referencemodule_fieldlabel = [];
if($isProductDetails == 'no')
	$query = "select referencemodule,ld_tranlabel.fieldlabel,ld_tabdetailfield.columnname,ld_tabdetailfield.bigtype,ld_tabdetailfield.fieldvaluecolor,ld_tabdetailfield.fieldplaceholder from ld_tabdetailfield 
LEFT JOIN ld_tab on ld_tab.`name` = ld_tabdetailfield.referencemodule 
left join ld_tranlabel on ld_tranlabel.tabid = ld_tab.tabid and ld_tranlabel.Relateid = ld_tab.tabid 
 where ld_tabdetailfield.tabid = ? and (bigtype = 'reference' || bigtype = 'selectsource') and ld_tranlabel.languagetype = 'zh' and ld_tranlabel.trantable = 'ld_tab'";
else
	$query = "select referencemodule,ld_tranlabel.fieldlabel,ld_producttoolfield.columnname,ld_producttoolfield.bigtype,ld_producttoolfield.fieldvaluecolor,ld_producttoolfield.fieldplaceholder from ld_producttoolfield 
LEFT JOIN ld_tab on ld_tab.`name` = ld_producttoolfield.referencemodule 
left join ld_tranlabel on ld_tranlabel.tabid = ld_tab.tabid and ld_tranlabel.Relateid = ld_tab.tabid 
 where ld_producttoolfield.tabid = ? and bigtype = 'reference' and ld_tranlabel.languagetype = 'zh' and ld_tranlabel.trantable = 'ld_tab'";
$result=$adb->pquery($query,array($tabid));
$rows=$adb->num_rows($result);

if($rows >= 1){
  
	for($i=0;$i<$rows;$i++)
	{
		$referencemodule = $adb->query_result($result,$i,'referencemodule');
		$bigtype = $adb->query_result($result,$i,'bigtype');
		$fieldvaluecolor = $adb->query_result($result,$i,'fieldvaluecolor');
		$fieldplaceholder = $adb->query_result($result,$i,'fieldplaceholder');
		$selected_referencemodule[] = $referencemodule;
		$selected_referencemodule_fieldlabel[$referencemodule] = array(
			'fieldlabel' => $adb->query_result($result,$i,'fieldlabel'),
			'columnname' => $adb->query_result($result,$i,'columnname'),
			'bigtype' => $bigtype,
			'fieldvaluecolor' => $fieldvaluecolor,
			'fieldplaceholder' => $fieldplaceholder,
		);
	}
}
//选择源单
$optionmodules = [];
if($isProductDetails == 'no'){
	$query = "select ld_tranlabel.fieldlabel,ld_tabdetailfield.columnname,ld_tabdetailfield.bigtype,ld_tabdetailfield.fieldvaluecolor,ld_tabdetailfield.fieldplaceholder from ld_tabdetailfield 
	left join ld_tranlabel on ld_tranlabel.Relateid = ld_tabdetailfield.tabdetailfieldid 
	where ld_tabdetailfield.tabid = ? and ld_tranlabel.tabid = ? and bigtype = 'selectsource' and 
	ld_tranlabel.languagetype = 'zh' and ld_tranlabel.trantable ='ld_tabdetailfield' and ld_tabdetailfield.presence <> 1";
}
else{
    $query = "select ld_tranlabel.fieldlabel,ld_producttoolfield.columnname,ld_producttoolfield.bigtype,ld_producttoolfield.fieldvaluecolor,ld_producttoolfield.fieldplaceholder from ld_producttoolfield 
	left join ld_tranlabel on ld_tranlabel.Relateid = ld_producttoolfield.producttoolfieldid 
	where ld_producttoolfield.tabid = ? and ld_tranlabel.tabid = ? and bigtype = 'selectsource' and 
	ld_tranlabel.languagetype = 'zh' and ld_tranlabel.trantable ='ld_producttoolfield' and ld_producttoolfield.presence <> 1";
}
$result=$adb->pquery($query,array($tabid,$tabid));
$rows=$adb->num_rows($result);

if($rows >= 1){
    
	for($i=0;$i<$rows;$i++)
	{
		$columnname = $adb->query_result($result,$i,'columnname');
		$bigtype = $adb->query_result($result,$i,'bigtype');
        $selected_referencemodule_fieldlabel[$columnname] = array(
			'fieldlabel' => $adb->query_result($result,$i,'fieldlabel'),
			'columnname' => $columnname,
			'bigtype' => $bigtype,'fieldvaluecolor' => $fieldvaluecolor,
            'fieldplaceholder' => $fieldplaceholder,
		);
	}
}
//源单类型
$query = "select ld_tab.name,ld_tab.tabid,withdetail from ld_option_module LEFT JOIN ld_tab on ld_tab.tabid = ld_option_module.option_tabid where ld_option_module.tabid = ? and ld_option_module.presence <> 1 ORDER BY sequence";
$result=$adb->pquery($query,array($tabid));
$rows=$adb->num_rows($result);
if($rows >= 1){
	$modulename_arr = [];
	for($i=0;$i<$rows;$i++)
	{
		$modulename = $adb->query_result($result,$i,'name');
        $withdetail = $adb->query_result($result,$i,'withdetail');
        //zkt 20230524 BUG0066749  	kfbcrm-收款单-单据分录定制-选择源单类型为“合同订单”，点击编辑字段，弹出“undefined”
        if(!empty($modulename) && vtlib_isModuleActive($modulename)){//BUG20240228-06 ls 240228 CRM标准版未授权的模块也显示也出来
            if($modulename=='Potentials'){
                $sysdeploy = getSys_deploy(205);
                if($sysdeploy['deploy_value']==1) 
                    continue;
            }
    		$modulename_arr[] = $modulename;
            $fields = getReferenceField($modulename,$withdetail);
            if(!empty($fields)){
        		$optionmodules[$modulename] = array(
        			'modulelabel' => getTranstab($modulename),
        			'fields' => $fields,
        		);
            }
        }
	}
	$smarty->assign('OPTIONMODULEARRAY',implode(',',$modulename_arr));
}

$query = "";
$query='select ld_tab.name,ld_tab.tabid,ld_tranlabel.fieldlabel from ld_tab inner join ld_field  on ld_field.tabid=ld_tab.tabid 
inner join ld_tranlabel on ld_tranlabel.relateid=ld_tab.tabid 
where ld_tab.presence in(0,2) and ld_tranlabel.trantable="ld_tab" and languagetype=?  and ld_field.columnname="smownerid" group by ld_tab.tabid   order by tabsequence asc ';

$result=$adb->pquery($query,array($languageType));
$rows=$adb->num_rows($result);
for($i=0;$i<$rows;$i++)
{
    $name=$adb->query_result($result,$i,'name');
	$module_tabid=$adb->query_result($result,$i,'tabid');
	if($tabid == $module_tabid || in_array($name,array('Products','Productbom','Emails'))){
		continue;
	}
	if(!empty($selected_referencemodule) && in_array($name,$selected_referencemodule)){
		continue;
	}
    $canselectmodules[]=array('name'=>$name,'label'=>$adb->query_result($result,$i,'fieldlabel'));
}
$smarty->assign('SELECTED_REFERCENCEMODULE',$selected_referencemodule_fieldlabel);
$smarty->assign('CANSELECTMODULES',$canselectmodules);
if(!empty($_REQUEST['id']) && isset($_REQUEST['id'])){//�༭

    $productdetails=$producttoolfields->getProductToolDetails($tabid,$_REQUEST['id']);
    //edit: xll 2023/09/12 BUG0072452 产品模块自定义超链接字段的处理
    $productdetails['isHrefField'] = 'no';
    if($productdetails['columnname'] == getEntitynameInfo(getTabid('Products'))['fieldname'])
        $productdetails['isHrefField'] = 'yes';
    $arr['productdetails'] = $productdetails;
	$smarty->assign('PRODUCTTOOLDETAILS',$productdetails);
	//关联选择单据 - 审批 - 其他条件
	if($productdetails['bigtype'] == 'reference'){
		if(!empty($productdetails['effectivecondition'])){
			$effectivecondition = json_decode(html_entity_decode($productdetails['effectivecondition']));
			$smarty->assign('reference_advft_criteria',$effectivecondition->reference->advft_criteria);
			$smarty->assign('reference_advft_criteria_groups',$effectivecondition->reference->advft_criteria_groups);
		}
	}
	//引用字段信息
	if($productdetails['relatedmodulefield'] == 'yes'){
		$query = "select fromvalue_info,frommodule,fromvalue_type,trigger_columnname from ld_related_detailfield where modulename = ? and curmodule_columninfo = ? limit 1";
		$result = $adb->pquery($query,array($isModule,$productdetails['columnname']));
		$frommodule = $adb->query_result($result,0,'frommodule');
		$fromvalue_type = $adb->query_result($result,0,'fromvalue_type');
		$trigger_columnname = $adb->query_result($result,0,'trigger_columnname');
		$modulelabel = getTranstab($frommodule);
		$fromvalue_info = $adb->query_result($result,0,'fromvalue_info');
		//源单
		if($fromvalue_type == 'selectsource'){
          $smarty->assign('SELECTSOURCE_FIELDBIGTYPE',$productdetails['parentbigtype']);
          $smarty->assign('SELECTSOURCE_FIELDREFERENCEMODULE',$productdetails['referencemodule']);
			$relatedmodule_info = array(
				'modulelabel' => $selected_referencemodule_fieldlabel[$trigger_columnname]['fieldlabel'],
				'fromvalue_type' => $fromvalue_type
			);
			if(!empty($fromvalue_info)){
				$fromvalue_info_arr = ldcrm_json_decode(decode_html($fromvalue_info));
				foreach($fromvalue_info_arr as $infos){
					$focus=CRMEntity::getInstance($infos['module']);
                    if($infos['columntype']=='detail'){
                        //获取分录fieldlabel
                        if(empty($focus->detailfieldobj)){
                            continue;
                       }
					   $fieldlabel=$focus->detailfieldobj->getFieldInfoBykeyValue('columnname',$infos['column'],'fieldlabel');
                    }
					else{
	                   $fieldlabel=$focus->fieldobj->getFieldInfoBykeyValue('columnname',$infos['column'],'fieldlabel');
					}
					$optionmodules[$infos['module']]['fieldlabel'] = $fieldlabel;
				}
			}
		}else{
			$focus=CRMEntity::getInstance($frommodule);
			$fieldlabel=$focus->fieldobj->getFieldInfoBykeyValue('columnname',$fromvalue_info,'fieldlabel');
			//ls 2022-07-06 BUG0053513 引用关联选择单据的字段，再次编辑时，传值需要修改为fieldname。
            $fromvalue_info = $focus->fieldobj->getFieldInfoBykeyValue('columnname',$fromvalue_info,'fieldname');
			$relatedmodule_info = array(
				'fieldlabel' => $fieldlabel,
				'modulelabel' => $modulelabel,
				'frommodule_column' => $fromvalue_info,
				'frommodule' => $frommodule,
				'fromvalue_type' => $fromvalue_type
			);
		}
	}
	$smarty->assign('RELATEDMODULE_INFO',$relatedmodule_info);
	$selected_referencemodule = 1;

    if($productdetails['input_type']==2)//�ֶι�ʽ
    {
        $letters=array('a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','r','s','t','u','v','w','x','y','z');
		if($isProductDetails == 'no'){
			$query = "select columnname,ld_tranlabel.fieldlabel from ld_tabdetailfield
                 LEFT JOIN ld_tranlabel on ld_tranlabel.relateid = ld_tabdetailfield.tabdetailfieldid and ld_tranlabel.tabid = ld_tabdetailfield.tabid 
                 where ld_tabdetailfield.tabid = ? and ld_tranlabel.languagetype=? and  ld_tranlabel.trantable = ?
                 and ld_tabdetailfield.tabdetailfieldid != ? ";
            if((getTabModuleName($tabid)=='CashBill'||getTabModuleName($tabid)=='SendCashBill')&&!empty($_REQUEST['selectsourcetype'])){
                $query.=" and ld_tabdetailfield.sourcemodule='".$_REQUEST['selectsourcetype']."' ";
            }
            $query .="and presence in(0,2) and typeofdata like 'n%' GROUP BY ld_tabdetailfield.tabdetailfieldid
                 order by ld_tabdetailfield.sequence asc";

			$result=$adb->pquery($query,array($tabid,$languageType,'ld_tabdetailfield',$_REQUEST['id']));
		}else{

		      //获取金额，数字类型字段
			 $query="select columnname,ld_tranlabel.fieldlabel from ld_producttoolfield
       	LEFT JOIN ld_tranlabel on ld_tranlabel.relateid = ld_producttoolfield.producttoolfieldid and ld_tranlabel.tabid = ld_producttoolfield.tabid  
    	 where ld_producttoolfield.tabid = ? and ld_tranlabel.languagetype=? and  ld_tranlabel.trantable = ? and ld_producttoolfield.producttoolfieldid != ? "; 
         	if((getTabModuleName($tabid)=='CashBill'||getTabModuleName($tabid)=='SendCashBill')&&!empty($_REQUEST['selectsourcetype'])){
            	$query.=" and ld_producttoolfield.sourcemodule='".$_REQUEST['selectsourcetype']."' ";
         	}
         	$query.=" and ld_producttoolfield.uitype not in (33,35,36)  and presence in(0,2) and 
         	(typeofdata like 'n%' OR ld_producttoolfield.uitype = 99)
         	  and (ld_producttoolfield.tablename!=? )
         	 GROUP BY ld_producttoolfield.producttoolfieldid
    	     order by ld_producttoolfield.sequence asc";
			$result=$adb->pquery($query,array($tabid,$languageType,'ld_producttoolfield',$_REQUEST['id']
            ,CRMEntity::getInstance($isModule)->table_name));

		}
       
         $formulahtml='';
         $idindex=0;
        
       
       //循环字段公式，显示界面
         foreach($productdetails['column'] as $columnname)
         {
           
            $formulahtml.=" <tr id='formual_row_$idindex'> ";
            $formulahtml.=" <td> ";
            $formulahtml.=" <select id='formualcombox_$idindex' name='formualcombox_$idindex' class='ld-select-inner gwidth70'>";
            $formulahtml.=" <option value='none'></option> ";
            //$columnname=substr($columnname,6,-6);
            //$columnname 是sf293
            	$columnname=trim(trim($columnname,'039;'),',');
                $columnname=trim(trim($columnname,'&'),',');
                $columnname=trim(trim($columnname,'#039;'),'&');
              
            for($k=0;$k<$adb->num_rows($result);$k++)
            {
               
                $productcolumn=$adb->query_result($result,$k,'columnname');
                $fieldlabel=$adb->query_result($result,$k,'fieldlabel');
                
                
                   //edit:can 2022-02-22 050045: （https://81mis.com/kfbcrm [^] ）在分录中（不是产品分录）添加单价金额等字段，高级属性选择通过计算公式，保存后不能修改公式
			
                
                if($productcolumn==trim($columnname,"'"))
                {
                 
                   $formulahtml.= " <option value='".$productcolumn."' selected>".$fieldlabel."</option> ";
                }
                else
                {
                    $formulahtml.= " <option value='".$productcolumn."'>".$fieldlabel."</option> ";
                }
                
            }
            
            $formulahtml.='</select>';
            $formulahtml.=" </td> ";
            
            $formulahtml.=" <td> ";
             $tmpstr=trim(trim($productdetails['letters'][$idindex],'&#039;'),',');//&#039;:是单引号的html
            $formulahtml.="<input type='text' class='ld-input-inner gwidth90' name='formualtext_$idindex' id='formualtext_$idindex' value='".$tmpstr."'>";
            $formulahtml.=" </td> ";
            
            $formulahtml.=" <td> ";
            $formulahtml.='<a href="javascript:;" id="formualdeleteimg_'.$idindex.'" onclick="deleteFormulaRow(\''.$idindex.'\')"></a>';
            $formulahtml.=" </td> ";
            $formulahtml.="</tr>";
           $idindex++;
         }
           
          $smarty->assign('FORMULAHTML',$formulahtml);
    }
    $smarty->assign("COLUMNNAME",$productdetails['columnname'])  ;
    
	if(($productdetails['setuitype'] == 63 || $productdetails['setuitype'] == 60)&&$productdetails['columnname']!='wareid'){
		crm_load_class_file("cls_PickList", 'modules/PickList');
		$objpinklist = new cls_PickList();
		$arrprojectstatus = $objpinklist->getPickListValues($productdetails['columnname'],$AllModuleProductToolField[$productdetails['columnname']],array(),"");
		$smarty->assign('PICKLIST_VALUE',$arrprojectstatus);
	}
	$smarty->assign('PRODUCTCOLUMN',$productdetails['columnname']);
    if($productdetails['columnname']=='tax_amount'&&$productdetails['edit_permission']==0)
    {
        //tax_amount:价税合计
        $smarty->assign("reversetabshow",'yes');//反算页签
        $reverseparentid=$_REQUEST['id'];
        include(globalStatic::$root_directory.'modules/Settings/getReverseFormulaList.php');
        
         $smarty->assign("reverseparentid",$_REQUEST['id']);
         $smarty->assign("reversemodule",$isModule);
         $smarty->assign("ReverseArr",$reverse_arr);
                 
    }
    if($isProductDetails=='no')
    {
        //33972: 系统设置>单据分录定制>加班单>编辑任意字段>适用范围选择“按成员适用范围”>保存：结果没有保存成功。
        $query = "SELECT 
            t.userid,
            t.presence,
            t.profilefieldtype,
            t.create_profile,
            t.edit_profile,
            t.details_profile,
            u.last_name as userlabel,
            g.groupname as grouplabel,
            p.profilename as rolelabel
        FROM
            ld_tabdetailprofile t 
        LEFT JOIN ld_users u ON t.userid = u.id and t.profilefieldtype = 'user' 
        LEFT JOIN ld_groups g ON t.userid = g.groupid and t.profilefieldtype = 'group' 
        LEFT JOIN ld_profile p ON t.userid = p.profileid and t.profilefieldtype = 'role' 
        WHERE
            t.tabdetailfieldid = ?
        AND t.tabid = ?
        ";
    }
    else{
	    $query = "SELECT
            t.userid,
            t.presence,
            t.profilefieldtype,
            t.create_profile,
            t.edit_profile,
            t.details_profile,
            u.last_name as `userlabel`,
            g.groupname as `grouplabel`,
            p.profilename as `rolelabel`
        FROM
            ld_producttoolprofile t
        LEFT JOIN ld_users u ON t.userid = u.id and t.profilefieldtype = 'user' 
        LEFT JOIN ld_groups g ON t.userid = g.groupid and t.profilefieldtype = 'group' 
        LEFT JOIN ld_profile p ON t.userid = p.profileid and t.profilefieldtype = 'role' 
        WHERE
            t.producttoolfieldid = ?
        AND t.tabid = ?;";
    }
	$result = $adb->pquery($query,array($_REQUEST['id'],$tabid));
	$num_rows = $adb->num_rows($result);
    $profilefield_detailsarray = [];
	if($num_rows >= 1){
		for($i = 0; $i<$num_rows; $i++){
			$profile_presence = $adb->query_result($result,$i,'presence');
			$userall[$i] = $adb->query_result($result,$i,'userid');
            $profilefieldtype=$adb->query_result($result,$i,'profilefieldtype');
            $profilefield_detailsarray[$adb->query_result($result,$i,'userid')] = array(
                'raleted_label' => $adb->query_result($result,$i,$profilefieldtype.'label'),
                'create_profile' => $adb->query_result($result,$i,'create_profile'),
                'edit_profile' => $adb->query_result($result,$i,'edit_profile'),
                'details_profile' => $adb->query_result($result,$i,'details_profile')
            );
		}
		if($profile_presence == 1){
			$profile_field_userids = implode(',',$userall);
		}else{
			$user_arr=get_user_array(FALSE, "", "");
			$userids = array_keys($user_arr);
			foreach($userids as $uid){
				if(!in_array($uid,$userall)){
					$ids[] = $uid;
				}
			}
			$profile_field_userids = implode(',',$ids);
		}
	}else{
		$profile_field_userids = '';
        $profilefieldtype='all';
        $profilefield_detailsarray[] = array(
            'create_profile' => 'write',
            'edit_profile' => 'write',
            'details_profile' => 'read'
        );
	}
	$smarty->assign('REFRESHMODULE',$productdetails['referencemodule']);
	$smarty->assign('REFRESHMODULELABEL',getTranstab($productdetails['referencemodule']));
    $smarty->assign('profilefieldtype',$profilefieldtype);
	$smarty->assign('PRODUCTTOOLFIELDID',$_REQUEST['id']);
}
else{//
	$producttoolfield['uitype'] = $producttoolfields->getTextTypeOption('','',array(),$tabid);
	$producttoolfield['uitypeoption'] = 1;//
    //新增字体颜色默认值
    $defaultfieldvaluecolor = '#3B4859';
	$producttoolfield['fieldvaluecolor'] = $defaultfieldvaluecolor;//zxm 20211230字段颜色 字段说明
	$producttoolfield['fieldplaceholder'] = $fieldplaceholder;//
	$producttoolfield['width'] = 20;//
	$producttoolfield['length'] = 100;//
    $producttoolfield['defaultcolumn']=1;
    $producttoolfield['maxrowsshow']=5;//ljj 20240320 BUG20240319-35 单据分录定制--关联选择单据，最多显示数据条数，默认值应该是5
	$profile_field_userids = '';
    $profilefield_detailsarray = [];
    $smarty->assign('PRODUCTTOOLFIELDID',0);
    //$smarty->assign('profilefieldtype','all');
	$smarty->assign('PRODUCTTOOLDETAILS',$producttoolfield);
	$smarty->assign('REFRESHMODULE',$canselectmodules[0]['name']);
}
$afterdayNums = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,30,60,90,120,180,365];//XUQIU1001765 xxy 2023-8-11 页面设置/单据分录定制，“日期”和“日期时间”字段默认值下拉选项增加显示n天前选项
$afterdayinfo_arr = array();
foreach ($afterdayNums as $dayNum) {
    $afterdayinfo_arr[] = array(
        'value' => "afterday" . $dayNum,
        'label' => $dayNum . " " . getFixedLabel("AFTERDAY")
    );
}
$daysagoNums = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,30,60,90,120,180,365];
$daysagoinfo_arr = array();
foreach ($daysagoNums as $dayNum) {
    $daysagoinfo_arr[] = array(
        'value' => "daysago" . $dayNum,
        'label' => $dayNum . " " . getFixedLabel("DAYSAGO")
    );
}
$smarty->assign('AfterDayInfo',$afterdayinfo_arr);
$smarty->assign('DaysAgoInfo',$daysagoinfo_arr);
$smarty->assign('PROFILEFIELDUSERIDS',$profile_field_userids);
$smarty->assign('PROFILEFIELDDETAILSARRAY',$profilefield_detailsarray);
$smarty->assign('OPTIONMODULES',$optionmodules);
//分录已有基础资料属性
$fieldobj=Field::getInstance('Products',$adb);
$modulefields = $fieldobj->getModuleFields();
foreach($modulefields as $fieldname => $fieldobj){
	//$fieldname == $productdetails['columnname'] 编辑时，显示当前自己
	if($fieldobj->getColumnName() == 'taxclass'){//BUG0073558 xxy 2023-10-9 带产品的单据分录定制中，录入方式->产品属性，相关字段中去掉“税别”字段（目前没有显示值）
		continue;
	}
	if(!in_array($fieldname,$columnForProductFields) || $fieldname == $productdetails['columnname']){
	   if($fieldobj->getSaveDataBase()=='yes')
		  $fieldarr[$fieldobj->getFieldid()] = $fieldobj->getFieldLabelKey();//��¼���л������ϲ�Ʒ������
	}
	
}
$fieldtype = !is_null($productdetails['fieldtype'])?$productdetails['fieldtype']:'';
$smarty->assign('TABID',$tabid);
$smarty->assign('FIELDDETAILS',$fieldarr);
$smarty->assign('ISPRODUCTDETAILS',$isProductDetails);
$smarty->assign('MODULE',$isModule);
$smarty->assign("expensesourcefield",'no');
$fld_module=getTabname($tabid);
//037922: （1.6）系统设置-单据分录定制-自定义表单21-25：源单字段类型编辑属性界面没有改进
 $boolFileExit = get_file_address($fld_module,$fld_module.'DetailFieldsHtml');
//zkt 20230112 BUG0060817收付款单单据分录定制编辑标签“源单”，编辑源单类型定制，勾选“自动带出所选源单的分录明细”保存后，再次编辑“源单”，源单类型定制区域不显示
if(strtolower($fieldtype)=='selectsource'&&($boolFileExit)&&($isModule != 'CashBill'&&$isModule!='SendCashBill'))
{
    $smarty->assign("expensesourcefield",'yes');
    $smarty->assign("commissionsourcefield",'yes');
    //选择原单
    
    crm_load_class_file("cls_sourcelist",'modules/Settings');
    $sourcelistobj=new cls_sourcelist($fld_module);
    
    $smarty->assign('LIST_ENTRIES',$sourcelistobj->getListContentData());
    $smarty->assign('LIST_HEADER',$sourcelistobj->getListHead());
 
   
}

if(!empty($_REQUEST['id']) && isset($_REQUEST['id'])){
    $arr['title'] = getFixedLabel('EDITPROPERTIES');
}else{
    $arr['title'] = getFixedLabel('LBL_ProductTool_field');
}
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content'] =$smarty->fetch('ProductToolField/EditField.tpl');
ConvertTojsonString(1,$arr,'success');

//获取模块的表头字段、分录字段
function getReferenceField($fldmodule,$withdetail){
	global $adb;
	$focus=CRMEntity::getInstance($fldmodule);
    if(!empty($focus->fieldobj)){
    	$modulefields=$focus->fieldobj->getModuleFields();
        $blockinfo = $focus->fieldobj->getBlockInfos();
        
    	$infos=Field::getAllFieldTypeInfo($adb);
        $fielduitypreferencemoudle = array();//表头字段uitype对应modulename
    	foreach($infos as $index=>$info)
    	{
    		if($info['type']!=''&&$info['fieldtype']!='reference'){
    		  $uitypes[]=$info['uitype'];//获取相关的referencefield
            }
            if($info['fieldtype']=='reference'){
                $fielduitypreferencemoudle[$info['uitype']] = $info['type'];
            }
    		
    	}

    	foreach($modulefields as $fieldname=>$fieldinfo)
    	{
    		$fieldLabel=$fieldinfo->getFieldLabel();
    		$savedatabase=$fieldinfo->getSaveDataBase();
    		$columnname=$fieldinfo->getColumnName();
    		if($savedatabase!='yes')
    		{
    			//42821: (61mis.com/kfbcrm)系统设置-页面设置；在设置字段为引用字段时，可以引用不是数据库中的“字段”；预期：引用字段不可以引用没有保存到数据库的字段
    			continue;
    		}
    		$uitype=$fieldinfo->getUIType();
    		$bigtype=$fieldinfo->getBigType();
    		$tablename=$fieldinfo->getTableName();
    		if(!in_array($tablename,$focus->tab_name)&&($uitype!=1109&&$tablename!='ld_attachments'))
    		{
    			continue;
    		}
            $parentbigtype=$fieldinfo->getParentBigType();
            if($fieldinfo->isRelatedModuleField()&&!empty($parentbigtype)&&$parentbigtype == 'reference'){
                //不能引用 引用关联选择单据字段
                continue;
            }
    		//chj 2020/11/16 引用字段，去除标签字段
            //wym 2023/11/07 XUQIU1002029 单据分录定制，引用字段增加可选关联对象的“附件”和“图片”字段（参考需求：XUQIU1001671）（李小亮）
    		if(/*$uitype==69 ||$uitype==1109 ||*/$uitype==117 ||$uitype==301
    			|| $uitype==28 || $bigtype=='selectsource'||in_array($uitype,$uitypes)||$uitype==222||$uitype==65 || $uitype==64
                || $uitype==1500 || $uitype == 306 || $uitype == 255 || $uitype == 153 || $uitype == 154)
    		{
    			continue;
    		}
            //wym XUQIU1002029 图片和附件的bigtype相同,但两者不能一起选择保存,所以要区分开二者的type
            if($uitype==69){
                $bigtype='image';
            }
            $blockid=$fieldinfo->getBlockId();
    		$arr[$blockinfo[$blockid]['blocklabel']][]=array('columnname'=>$columnname,'columntype'=>'main','bigtype'=>$bigtype,'referencemdoule'=>$fielduitypreferencemoudle[$uitype],'fieldlabel'=>$fieldLabel);
    	}
        //获取分录字段
        if(!empty($focus->detailfieldobj)&&$withdetail=='yes')
        {
            $detailfields = $focus->detailfieldobj->getModuleProductToolField();
            foreach($detailfields as $fieldname=>$detailfieldinfo)
            {
                $fieldLabel=$detailfieldinfo->getFieldLabel();
        		$savedatabase=$detailfieldinfo->getSaveDataBase();
        		$columnname=$detailfieldinfo->getColumnName();
        		if($savedatabase!='yes')
        		{
        			//42821: (61mis.com/kfbcrm)系统设置-页面设置；在设置字段为引用字段时，可以引用不是数据库中的“字段”；预期：引用字段不可以引用没有保存到数据库的字段
        			continue;
        		}
        		$uitype=$detailfieldinfo->getUIType();
        		$bigtype=$detailfieldinfo->getBigType();
        		$tablename=$detailfieldinfo->getTableName();
        		if($tablename!=$focus->Detail_table&&$tablename!=$focus->Detail_table_scf)
        		{
        			continue;
        		}
                $parentbigtype=$detailfieldinfo->getParentBigType();
                if($fieldinfo->isRelatedModuleField()&&!empty($parentbigtype)&&($parentbigtype == 'reference'||$parentbigtype == 'selectsource')){
                    //不能引用 引用关联选择单据字段
                    continue;
                }
                if(empty($uitype))
                {   //非产品分录uitype为空值
                    $fieldtype = $detailfieldinfo->getFieldType();
                    if($fieldtype == 'Image' ){
                        continue;
                    }
                }
        		//chj 2020/11/16 引用字段，去除标签字段
        		if($uitype==69 ||$uitype==1109 ||$uitype==117 ||$uitype==301
        				|| $uitype==28||in_array($uitype,$uitypes)||$uitype==222||$uitype==65 || $uitype==64)
        		{
        			continue;
        		}
                $referencemdoule = $detailfieldinfo->getReferenceModule();
                if(get_file_address($fldmodule,$fldmodule.'DetailFieldsHtml'))
        		{
        			$arr[getTranstab($module).getFixedLabel('INFORMATION')][]=array('columnname'=>$columnname,'columntype'=>'detail','bigtype'=>$bigtype,'referencemdoule'=>$referencemdoule,'fieldlabel'=>$fieldLabel);
        		}
                else{
        		  $arr[getTranstab('Products').getFixedLabel('INFORMATION')][]=array('columnname'=>$columnname,'columntype'=>'detail','bigtype'=>$bigtype,'referencemdoule'=>$referencemdoule,'fieldlabel'=>$fieldLabel);
                }
            }
        }
    }
    return $arr;
}
?>