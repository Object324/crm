<?php
// zsk2024/5/28XUQIU1001465 成员管理，组织架构->根部门，更多下拉选项中增加“字段设置”参数
$smarty=new lingdangCRM_Smarty();
$isDepartmentNubmer=getSys_deploy(478);
$isDepartmentRemark=getSys_deploy(477);
$smarty->assign("ISDEPARTMENTNUMBER",$isDepartmentNubmer["deploy_value"]);
$smarty->assign("ISDEPARTMENTREMARK",$isDepartmentRemark["deploy_value"]);
$content=$smarty->fetch("UserGroupFieldPopup.tpl");
$arr['content']=$content;
$arr['oktext']=getFixedLabel("SAVE");
$arr['canceltext']=getFixedLabel("CANCEL");
ConvertTojsonString(1,$arr,"success");
?>