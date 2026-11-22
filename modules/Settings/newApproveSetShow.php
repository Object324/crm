<?php

crm_load_class_file("CommonView","modules/CustomView");
//流程设置
global $adb;
global $current_user;
if($current_user->getHaveSetProfile("Settings")!="yes")
{
    exit('sorry ');
}
$smarty=new lingdangCRM_Smarty();
$tabid=$_REQUEST['tabid'];
 $module= getTabname($tabid);
$focus=CRMEntity::getInstance($module);

$approveid=0;
$approveshowtype=$_REQUEST['approveshowtype'];//显示那些信息
$approvename='';
$description='';
$status='0';
$approveallocatetype='0';
$allowediting='0';
$allowantiapproval='0';
$finishedallowedit='no';
$default_on_new='no';
$defalt_on_submit='no';
$showsubmitremark='no';
$submitremarkrequire='no';
$showurgent='no';
$allowagainsubmit='no';
$Enableexpediting='no';
$finishedfield_allocatetype='all';//允许编辑字段适用人员范围
$finishedfield_allocateid='';
$isnewapprove='yes';
$fininsedselectfieldtype='all';
$havechoosefield_arr=[];
if($_REQUEST['approveid'])
{
    $approveid=$_REQUEST['approveid'];
}
$tmp_advancesearch = $_REQUEST['advancesearch'] ?? '';
$advsearch_arr=json_decode($_REQUEST['advancesearch'],true);//高级查询
$groupcondition=$_REQUEST['groupcondition'] ?? '';//组合
$groupcondition_arr=json_decode($groupcondition,true);
$approveallocateid_arr=[];
$finishedalloweditchoosefield=[];
if(empty($approveid))
{
    
}
else
{

	
		//审批流程信息
		$sql='select * from ld_approve where id=? ';
   		$result= $adb->pquery($sql,array($approveid));


   		 $approvename=$adb->query_result($result,0,'name');
		$description=$adb->query_result($result,0,'description');
		$status=$adb->query_result($result,0,'status');
		$approveallocatetype=$adb->query_result($result,0,'approveallocatetype');
		$allowediting=$adb->query_result($result,0,'allowediting');
		$allowantiapproval=$adb->query_result($result,0,'allowantiapproval');
		$finishedallowedit=$adb->query_result($result,0,'finishedallowedit');
		$default_on_new=$adb->query_result($result,0,'default_on_new');
		$default_on_submit=$adb->query_result($result,0,'default_on_submit');
		$showsubmitremark=$adb->query_result($result,0,'showsubmitremark');
		$submitremarkrequire=$adb->query_result($result,0,'submitremarkrequire');
		$showurgent=$adb->query_result($result,0,'showurgent');
		$allowagainsubmit=$adb->query_result($result,0,'allowagainsubmit');
		$Enableexpediting=$adb->query_result($result,0,'enableexpediting');
		$finishedfield_allocatetype=$adb->query_result($result,0,'finishedfield_allocatetype');
		$finishedfield_allocateid=$adb->query_result($result,0,'finishedfield_allocateid');
        $advsearch_arr=json_decode(html_entity_decode($adb->query_result($result,0,'dataadv')),true);
        $groupcondition_arr=json_decode(html_entity_decode($adb->query_result($result,0,'dataadvgroup')),true);
        $editresetapprove=$adb->query_result($result,0,'editresetapprove');
		//已选择的审批结束后允许编辑的字段
    
	    $sql='select * from ld_approve_finishededitfield where approveid=?';
	    $result=$adb->pquery($sql,array($approveid));
	    $rows=$adb->num_rows($result);
	    
	    for($i=0;$i<$rows;$i++)
	    {
	        $columns=$adb->query_result($result,$i,'columns');
	        $col_arr=explode(":",$columns);
	        $tablename=$col_arr[0];
	        $columnname=$col_arr[1];
	       
	        if(in_array($tablename,$focus->tab_name)||$tablename=='ld_attachments')
	        {
	            //edit:can 20220411 （http://crm.airmaster.com.cn/crm）审批流程定制》项目信息表 “项目报备“流程，编辑流程，启用反审批 保存，再编辑打开界面， 显示反审批没保存成功 
	            $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$columnname);
	            
	            
	        }else if($module == 'Accounts'  && in_array($tablename,['ld_contactdetails','ld_contactscf'])){
	            //duan 20231207  客户审批流程中,选择联系人的字段无法保存的问题
                $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$columnname);
            }else {
	            if(empty($focus->detailfieldobj))
	            {
	                continue;
	            }
	             $fieldinfo=$focus->detailfieldobj->getFieldInfoobjBykey("columnname",$columnname);
	        }
	        if(!$fieldinfo)
	            continue;
            //xxy 2023-12-5 审批流程定制-设置已批准的单据允许编辑的字段，勾选字段右移后保存审批流，再打开，已选字段内字段不显示表头表体的前缀
            if(in_array($tablename,$focus->tab_name)||in_array($tablename.'scf',$focus->tab_name)||$tablename=='ld_attachments'){
                $modulelabel = getTranstab($module);
            }else{
                if(get_file_address($module,'ProductDetails')){
                    $modulelabel= getTranstab("Products");
                }else if(get_file_address($module,$module.'DetailFieldsHtml')){
                    $modulelabel= getTranstab($module).getTranstab('DETAIL');
                }
            }
	        $finishedalloweditchoosefield[]=['value'=>$columns,'label'=>$modulelabel.'_'.$fieldinfo->getFieldLabel()];
	        $fininsedselectfieldtype='part';
	        
	        
	    }
	
	 

         /**
     *parameter:approveallocatetype --0表示所有用户，1表示按部门分配，2表示按用户分配. 
     **/
    $query = 'SELECT
      alldata3.allocateid   ,alldata3.allocatename
    FROM
        (
            SELECT
                - 1 AS allocateid,
                "AllUser" AS allocatename
            FROM
                ld_approve2user
            INNER JOIN ld_approve ON ld_approve.`id` = ld_approve2user.approveid

            WHERE
                ld_approve.approveallocatetype = 0
            AND  approveid = ?
            UNION
            SELECT
                ld_users.id AS allocateid,
                ld_users.`last_name` AS allocatename
            FROM
                ld_approve2user
            INNER JOIN ld_approve ON ld_approve.id = ld_approve2user.approveid
            INNER JOIN ld_users ON ld_users.`id` = ld_approve2user.`userid`
            WHERE
                ld_approve.approveallocatetype = 2
            AND  approveid = ?
            UNION
            SELECT
                ld_groups.groupid AS allocateid,
                ld_groups.groupname AS allocatename
            FROM
                ld_approve2user
            INNER JOIN ld_approve ON ld_approve.id = ld_approve2user.approveid
            INNER JOIN ld_groups ON ld_groups.groupid = ld_approve2user.`userid`
            WHERE
                ld_approve.approveallocatetype = 1
            AND approveid = ?
            UNION
            SELECT
                ld_profile.profileid AS allocateid,
                ld_profile.profilename AS allocatename
            FROM
                ld_approve2user
            INNER JOIN ld_approve ON ld_approve.id = ld_approve2user.approveid
            INNER JOIN ld_profile ON ld_profile.profileid = ld_approve2user.`userid`
            WHERE
                ld_approve.approveallocatetype = 3
            AND approveid = ?
        ) AS alldata3;';
    $result=$adb->pquery($query,array($approveid,$approveid,$approveid,$approveid));
    $num_rows=$adb->num_rows($result);
    $approveallocateid_arr=[];
    for($i=0;$i<$num_rows;$i++)
    {
        $approveallocateid_arr[]=$adb->query_result($result,$i,'allocateid');

    }


}
$approveallocateid=implode(",",$approveallocateid_arr);

$advgroup_arr=[];
$groupindex=0;

foreach($groupcondition_arr as $groupid=>$groupinfo)
{

     if(is_array($groupinfo)){
    
        foreach($advsearch_arr  as $searchindex=>$searchinfo)
        {
            if(is_array($searchinfo)&&$searchinfo['groupid']==$groupid)

             {
                $searchinfo['search_comparator']=$searchinfo['comparator'];
                $advgroup_arr[$groupid]['columns'][]=$searchinfo;
             }
        }

         $advgroup_arr[$groupid]['condition']=$groupinfo['groupcondition'];
     }
      
}
 


$arrfield=[];
$main_allFields=$focus->fieldobj->getModuleFields();
$modulelabel=getTranstab($module);

foreach($main_allFields as $fieldname=>$fieldinfo)
{
    if($fieldinfo->getSaveDataBase()=='no')
        continue;
     if($fieldinfo->get_allowedit()=='no')
        continue;
    
    $tablename=$fieldinfo->getTableName();
    $columnname=$fieldinfo->getColumnName();
    $columns="$tablename:$columnname:$module";
    
     //前端做了已选择字段不要显示到全部字段中
    
    $arrfield[$columns]=$modulelabel.'_'.$fieldinfo->getFieldLabel();
    
     
}
if(get_file_address($module,'ProductDetails'))
{
    $detail_allFields=$focus->detailfieldobj->getModuleFields();
    $label= getTranstab("Products");
    
    foreach($detail_allFields as $fieldname=>$fieldinfo)
    {
        if($fieldinfo->getSaveDataBase()=='no')
            continue;
         if($fieldinfo->getedit_permission()=='1')
            continue;
        $fieldid=$fieldinfo->getFieldid();
        if($fieldname=='productname')
            $fieldid=0;
        if($fieldid>0)
            continue;
        $tablename=$fieldinfo->getTableName();
        $columnname=$fieldinfo->getColumnName();
        $columns="$tablename:$columnname:$module";
      //前端做了已选择字段不要显示到全部字段中
        $arrfield[$columns]=$label.'_'.$fieldinfo->getFieldLabel();
        
         
    }
}
else if(get_file_address($module,$module.'DetailFieldsHtml'))
{
    $label= $modulelabel.getTranstab('DETAIL');
    $detail_allFields=$focus->detailfieldobj->getModuleFields();
    foreach($detail_allFields as $fieldname=>$fieldinfo)
    {
        if($fieldinfo->getSaveDataBase()=='no')
            continue;
        if($fieldinfo->getedit_permission()=='1')
            continue;
        
        $tablename=$fieldinfo->getTableName();
        $columnname=$fieldinfo->getColumnName();
        $columns="$tablename:$columnname:$module";
     //前端做了已选择字段不要显示到全部字段中
        $arrfield[$columns]=$label.'_'.$fieldinfo->getFieldLabel();
        
         
    }
}
$processnamelabel=getFixedLabel('PROCESSNAME');//流程名称
$presencelabel=getFixedLabel('WHETHERTOENABLE');//是否启用
$finishedalloweditlabel=getFixedLabel('APPROVEFINISHEDALLOWEDIT');//审批结束是否允许编辑单据
$allowcancellabel=getFixedLabel('WHETHERTOALLOWANTIAPPROVALOFDATA');//是否允许反审批单据
$newdefaultapprovelabel= getFixedLabel('APPROVEDEFAULTVALUEONNEW');//是否新建时默认流程
$submitdefaultapprovelabel=getFixedLabel('APPROVEDEFAULTVALUEONSUBMIT');//是否提交审批时默认流程
$ShowUrgentWhenSubmitlabel=getFixedLabel('ShowUrgentWhenSubmit');//提交审批时是否显示加急选项
$submitshowremarklabel=getFixedLabel('APPROVEDEFAULTVALUEONPURPORT');//提交审批时是否显示审批意见
$approveremarkrequiredlabel=getFixedLabel('APPROVEDEFAULTVALUEONPURPORTREQUIRE');//提交审批时审批意见是否必填
$expeditingfunctionlabel=getFixedLabel('Enableexpeditingfunction');//是否启用催审功能
$remarklabel=getFixedLabel('DESCRIPTION');//
$applicablescopelabel=getFixedLabel('APPLICABLESCOPE');//适用范围
$alluserlabel=getFixedLabel('ALLTHEUSERS');//所有成员 
$bydeptlabel=getFixedLabel('BYDEPARTMENTS');//按部门
$byuserlabel=getFixedLabel('SETBYUSERS');//按成员
$byrolelabel=getFixedLabel('SetByRole');//按角色
$basicinformationlabel=getFixedLabel('BASICINFORMATION');//基本信息
$ApplicatesubmitScopelabel=getFixedLabel('ApplicatesubmitScope');//适用提交人范围
$HighConfiglabel=getFixedLabel('HighConfig');//高级配置
$FinishedApproveAllowEditFieldSetlabel=getFixedLabel('FinishedApproveAllowEditFieldSet');//设置已批准的单据允许编辑的字段
$AllFieldslabel=getFixedLabel('AllFields');//全部字段
$PartialFieldslabel=getFixedLabel('PartialFields');//仅部分字段

$optionfieldlabel=getFixedLabel('OPTIONALFIELD');//可选字段
$Selected_Fieldslabel=getFixedLabel('Selected_Fields');//已选字段
$SetAllowEidtFieldScopelabel=getFixedLabel('SetAllowEidtFieldScope');//设置可编辑字段的适用范围
$moverightlabel=getFixedLabel('MOVERIGHT');
$moveleftlabel=getFixedLabel('MOVELEFT');//左移
$moveuplabel=getFixedLabel('MOVEUP');//上移
$movedownlabel=getFixedLabel('MOVEDOWN');//
$entersearchfieldlabel=getFixedLabel('pleaseenterthecategoryyouarelookingforfield');
$nextlabel = getFixedLabel('NEXT');
$configbasicinfolabel = getFixedLabel('CONFIGUREBASICINFO');
$configureprocesslabel = getFixedLabel('CONFIGUREPROCESS');
$forcedrejectionlabel = getFixedLabel('FORCEDREJECTSUBMITAPPROVAL');
$editdocumentresettheapproval = getFixedLabel('EDITDOCUMENTRESETTHEAPPROVAL');

$_REQUEST['diony']='yes';

$arr['datetimestr']=CommonView::stdFilterDateTimeStr("");
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$controller = ListViewController::getInstance($module);
$arr['advanceFields'] = $controller->getAdvanceFields();
//标签翻译
$arr['label']=['name'=>$processnamelabel,'presence'=>$presencelabel,'finishedallowedit'=>$finishedalloweditlabel,'allowcancel'=>$allowcancellabel,'default_on_new'=>$newdefaultapprovelabel,'default_on_submit'=>$submitdefaultapprovelabel,'submitshowremark'=>$submitshowremarklabel, 'approveremarkrequired'=>$approveremarkrequiredlabel,'ShowUrgentWhenSubmit'=>$ShowUrgentWhenSubmitlabel, 'expeditingfunction'=>$expeditingfunctionlabel,'remark'=>$remarklabel,
'applicablescope'=>$applicablescopelabel,'alluser'=>$alluserlabel,'bydept'=>$bydeptlabel,'byuser'=>$byuserlabel,'byrole'=>$byrolelabel,'basicinformation'=>$basicinformationlabel,'ApplicatesubmitScope'=>$ApplicatesubmitScopelabel,'HighConfig'=>$HighConfiglabel,'FinishedApproveAllowEditFieldSet'=>$FinishedApproveAllowEditFieldSetlabel,'AllFields'=>$AllFieldslabel,'PartialFields'=>$PartialFieldslabel,'optionfield'=>$optionfieldlabel
,'Selected_Fields'=>$Selected_Fieldslabel,'SetAllowEidtFieldScope'=>$SetAllowEidtFieldScopelabel,'next'=>$nextlabel
,'configbasicinfo'=>$configbasicinfolabel,'configureprocess'=>$configureprocesslabel,'forcedrejection'=>$forcedrejectionlabel
,'moveright'=>$moveleftlabel,'moveleft'=>$moveleftlabel,'moveup'=>$moveuplabel,'movedown'=>$movedownlabel,'entersearchfieldlabel'=>$entersearchfieldlabel,'editdocumentresettheapproval'=>$editdocumentresettheapproval];

//数据信息
//zxm 20230519 BUG0066659	已分派	其他	紧急（48H内）	周晓梅kfbcrm-合同订单-审批流程定制 1.当审批流程正在使用时，在审批流程编辑界面也可以关闭审批流 2.审批流程关闭后，在小编辑界面启用审批流程，会弹出提示信息，没办法启用
//增加返回数据 模块ID和审批流id
$arr['approvedatainfo']=['tabid'=>$tabid,'approveid'=>$approveid,'name'=>$approvename,'description'=> $description,'status'=>$status,
'approveallocatetype'=>$approveallocatetype,'approveallocateid'=>$approveallocateid, "allowediting"=> $allowediting,
'allowantiapproval'=>$allowantiapproval,'finishedallowedit'=>$finishedallowedit,'default_on_new'=>$default_on_new,'default_on_submit'=>$default_on_submit,'showsubmitremark'=>$showsubmitremark,
'submitremarkrequire'=>$submitremarkrequire,'showurgent'=>$showurgent,'allowagainsubmit'=>$allowagainsubmit,'enableexpediting'=> $Enableexpediting,
'finishedfield_allocatetype'=>$finishedfield_allocatetype,'finishedfield_allocateid'=>$finishedfield_allocateid,'fininsedselectfieldtype'=>$fininsedselectfieldtype, 'isnewapprove'=>$isnewapprove,
    'finishedalloweditallfields'=>$arrfield,'finishedalloweditchoosefield'=>$finishedalloweditchoosefield,'editresetapprove'=>$editresetapprove];



$arr['title']=getFixedLabel('LBL_APPROVE');


setGLobalURLSmarty($smarty);//设置js,css等访问路径
//设置高级查询

$modulefields=$focus->fieldobj->getListSearchFields();
$blockinfos=$focus->fieldobj->getBlockInfos();
//获取成员管理不显示字段
$modulenoshowfields = array();
if($frommodule == 'Users'){
    $modulenoshowfields = $focus->getSearchNoshowfields();
}
$table_name_index=$focus->tab_name_index;
$advancefields=array();
foreach($modulefields as $fieldname=>$fieldinfo)
{
    //成员管理不显示字段，不显示
    if(in_array($fieldname,$modulenoshowfields)){
        continue;
    }
    $tablename=$fieldinfo->getTableName();
    $columnname=$fieldinfo->getColumnName();
    $display=$fieldinfo->getDisplaytype();
	$uitype = $fieldinfo->getUIType();
 
    if (!empty($triggercolumnname)) {
        if($display==2||$display==3)
        {
            continue;
        }
    }
	//标签应该不显示在布局规则：其它条件
	if($uitype == 301){
		continue;
	}
    if($columnname==$triggercolumnname)
    {
        //触发字段不显示在高级查询中
        continue;
    }
    if(array_key_exists($tablename,$table_name_index))
    {
        $blockfields[$fieldinfo->getBlockId()][]=$fieldinfo;
    }
}
$prevblockid=0;
foreach($blockinfos as $blockid=>$blockinfo)
{
  
    $tmpfields=$blockfields[$blockid];
    if(!is_array($tmpfields) || sizeof($tmpfields)<=0)
    {
        continue;
    }
    $strhtml.="<optgroup label='".$blockinfo['blocklabel']."' class='select' style='border:none'>";
    foreach($tmpfields as $index=>$fieldinfo)
    {
        $tablename=$fieldinfo->getTableName();
       $columnname=$fieldinfo->getColumnName();
       $fieldname=$fieldinfo->getFieldName();
       $fieldlabel=$fieldinfo->getFieldLabel();
       $typeofdata=$fieldinfo->getTypeOfData();
       $typeofdatas=explode('~',$typeofdata);
       $cols="$tablename:$columnname:$fieldname:$frommodule"."_$fieldlabel:".$typeofdatas[0];
    
       $strhtml.="<option value='$cols'>$fieldlabel</option>";
    }
    $strhtml.="</optgroup>";
}
if(get_file_address($module,$module.'DetailFieldsHtml'))
{
    $detailfields=  $focus->detailfieldobj->getModuleAllPreseneceFields();
    $strhtml.="<optgroup label='".getTranstab($module).getFixedLabel('DETAIL'). "' class='select' style='border:none'>";

}
else if(get_file_address($module,"ProductDetails")){
    $detailfields=  $focus->detailfieldobj->getModuleAllPreseneceFields();
    $strhtml.="<optgroup label='".getTranstab('Products').getFixedLabel('DETAIL')."' class='select' style='border:none'>";
}
if(isset($detailfields))
{
    //edit:can 20230302 61460 （医疗器械行业方案）产品通用问题。审批流程-设置条件分支，选不到分录字段
    foreach($detailfields as $tmpcolumn=>$fieldinfo )
    {
        $tablename=$fieldinfo->getTableName();
        $columnname=$fieldinfo->getColumnName();
        $fieldname=$fieldinfo->getFieldName();
        $fieldlabel=$fieldinfo->getFieldLabel();
        $typeofdata=$fieldinfo->getTypeOfData();
        $typeofdatas=explode('~',$typeofdata);
        $cols="$tablename:$columnname:$fieldname:$frommodule"."_$fieldlabel:".$typeofdatas[0];
        //duan 20230808 高级查询取表头的合计,不用分录的合计
        if($columnname == 'total'){
            continue;
        }
        $strhtml.="<option value='$cols'>$fieldlabel</option>";
    }
    $strhtml.="</optgroup>";
}
$fields=$focus->fieldobj->getFieldListArray();

crm_load_class_file('staticProfile.class','modules/Users');
$arr['editprofile'] = staticProfile::isModuleExistsProfile($module,'EditView');
$arr['fields']=$fields['fields'];
$arr['module']=$module;
$arr['content']=$smarty->fetch("Approve/newApproveSetShow.tpl");

$arr['criteria_groups_arr']=$advgroup_arr;
$arr['source']='customview';
$arr['columns_block']=$strhtml;
crm_load_class_file('CommonView',"modules/CustomView");
$comparatorArr = CommonView::getComparatorLabel();
$comparatorArr['belong'] = getFixedLabel('BELONG');
$comparatorArr['notbelong'] = getFixedLabel('NOTBELONG');
// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$comparatorArr['new_belong'] = getFixedLabel('BELONG');
$comparatorArr['new_notbelong'] = getFixedLabel('NOTBELONG');
$advfilterhtml = CommonView::getAdvCriteriaHTML($comparatorArr);
$arr['advfilterhtml'] = $advfilterhtml;
$arr['fLabels'] = $comparatorArr;
$arr['fieldsinfo'] = array_values($modulefields);
$arr['datetimestr']=CommonView::stdFilterDateTimeStr("");

// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
$controller = ListViewController::getInstance($module);
$arr['advanceFields'] = $controller->getAdvanceFields();

ConvertTojsonString(1,$arr,'success');

?>