<?php

$smarty=new lingdangCRM_Smarty();

$record=$_REQUEST['record'];

// zsk2024/5/28XUQIU1001465 成员管理，组织架构->根部门，更多下拉选项中增加“字段设置”参数
$isDepartmentNubmer=getSys_deploy(478);
$isDepartmentRemark=getSys_deploy(477);
$smarty->assign("ISDEPARTMENTNUMBER",$isDepartmentNubmer["deploy_value"]);
$smarty->assign("ISDEPARTMENTREMARK",$isDepartmentRemark["deploy_value"]);

$smarty->assign("RECORD","");
$_REQUEST['diony']='diony';
$group_type = 'crm';
if(!empty($record))
{
    //编辑
    if(isPermitted("Users","EditView")!='yes')
    {
        ConvertTojsonString("-1",array(),"无编辑权限");
    }
    $arr['title']=getFixedLabel('EDITGROUP');
    $sql='select ld_groups.*,parentgroup.groupname as parentgroupname,parentgroup.group_no as parentgroupno,a.accountname as related_crmid_name from ld_groups 
        left join ld_groups as parentgroup  on parentgroup.groupid=ld_groups.parentid
        left join ld_account as a on a.accountid = ld_groups.related_crmid 
        where ld_groups.groupid=?';
    $result=$adb->pquery($sql,array($record));
    if($adb->num_rows($result)>0)
    {
        $groupname=$adb->query_result($result,0,'groupname');
        $groupno=$adb->query_result($result,0,'group_no');
        $parentid=$adb->query_result($result,0,'parentid');
        $parentgroupname=$adb->query_result($result,0,'parentgroupname');
        $parentgroupno=$adb->query_result($result,0,'parentgroupno');
        $smarty->assign("GROUPNAME",$groupname);
        $smarty->assign("GROUPNO",$groupno);
        $smarty->assign("PARENTID",$parentid);
        $smarty->assign("PARENTNAME",$parentgroupname);
        $smarty->assign("PARENTGROUPNO",$parentgroupno);
        $smarty->assign("DESCRIPTION",$adb->query_result($result,0,'description'));
        
        $smarty->assign("RECORD",$record);

        $depth=$adb->query_result($result,0,'depth');
        $smarty->assign("DEPTH",$depth);

        $related_crmid=$adb->query_result($result,0,'related_crmid');
        $related_crmid_name=$adb->query_result($result,0,'related_crmid_name');
        if(empty($related_crmid_name)){
            $related_crmid_name = '<span style="color: #999;">'.getFixedLabel('PRMGROUPRELATEDTISHI').'</span>';
        }
        $smarty->assign("related_crmid",$related_crmid);
        $smarty->assign("related_crmid_name",$related_crmid_name);

    }
    $group_type = 'crm';
    if(isset($_REQUEST['group_type'])){
        $group_type = $_REQUEST['group_type'];

    }
}
else 
{
    //添加下级部门
    if(isPermitted("Users","Create")!='yes')
    {
        ConvertTojsonString("-1",array(),"无新增权限");
    }
    $parentid=$_REQUEST['parentid'];
    $arr['title']=getFixedLabel('NEWGROUP');
    $sql="select * from ld_groups where groupid=?";
    $result=$adb->pquery($sql,array($parentid));
    if($adb->num_rows($result)>0)
    {
        $groupname=$adb->query_result($result,0,'groupname');
        $groupno=$adb->query_result($result,0,'group_no');
        $depth=$adb->query_result($result,0,'depth');

        $smarty->assign("PARENTNAME",$groupname);
        $smarty->assign("PARENTGROUPNO",$groupno);
        $smarty->assign("PARENTID",$parentid);
        $smarty->assign("DEPTH",$depth+1);
    }
    $group_type = 'crm';
    if(isset($_REQUEST['group_type'])){
        $group_type = $_REQUEST['group_type'];

    }
    $related_crmid_name = '<span style="color: #999;">'.getFixedLabel('PRMGROUPRELATEDTISHI').'</span>';
    $smarty->assign("related_crmid_name",$related_crmid_name);
    
}
$smarty->assign("group_type",$group_type);
$content=$smarty->fetch("EditGroup.tpl");
$_REQUEST['diony']='diony';
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
$arr['content']=$content;
$arr['departmentNumber']=$isDepartmentNubmer["deploy_value"];
$arr['departmentRemark']=$isDepartmentRemark["deploy_value"];
ConvertTojsonString(1,$arr,"success");
?>