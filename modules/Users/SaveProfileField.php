<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Chj
 */


$smarty = new lingdangCRM_Smarty;

global $adb;
global $theme;

if(!empty($_REQUEST['tabid']))
{
	$tabid = $_REQUEST['tabid'];
	$profileid = $_REQUEST['profileid'];
	$module = getTabModuleName($tabid);
	$field = new Field($module,$adb);
	$fieldListResult = $field->getProfileFieldPermissionFortab($profileid);
    	$tab_id = $tabid;
     
 
	foreach($fieldListResult as $fld_module => $fld_label)
    {
     
     
		//$fieldListResult = getProfile2FieldList($fld_module, $profileid);
		//$noofrows = $adb->num_rows($fieldListResult);
	
		//for($i=0; $i<$noofrows; $i++)
		//{
			$fieldid =  $fld_label[4];
            $tablename=$fld_label[8];
            
			
            $uitype=$fld_label[2];
            
			$readonlyfieldid = $fieldid.'_permission';
            $visible_value=0;
            $readOnlyValue=0;
            $editreadonlyValue=0;
            //获取设置的权限
			if($_REQUEST[$readonlyfieldid]=='invisible'){
			     $visible_value = 1;         //不可见
			}
            else if($_REQUEST[$readonlyfieldid]=='readandwrite'){
                $readOnlyValue=0;   //读写权限
            }
            else if($_REQUEST[$readonlyfieldid]=='readonly'){
                $readOnlyValue = 1;     //只读权限
            }
            else if($_REQUEST[$readonlyfieldid]=='readonlyduringedit'){
                $editreadonlyValue = 1;     //编辑时只读
            }
            if(($module=='Accounts'||$module=='ServiceCharge')&&($tablename=='ld_contactdetails'||$tablename=='ld_contactscf'))
            {
                //edit:can 20210128 44487: （61mis.com/kfbcrm）角色权限-字段权限-客户；客户模块的字段权限中，首要联系人区块的权限消失了，新建客户时无法添加联系人信息
                $visible_value=0;
                $readOnlyValue=0;
            }
            if($uitype==301)//标签
            {
                //edit:can 20210330 45192: （https://61mis.com/kfbcrm [^]）普通成员登陆，客户查看详情界面没有显示标签功能
                $visible_value=0;
                $readOnlyValue=0;
            }
			//Updating the Mandatory lingdang_fields
			$uitype = $fld_label[2];
			$displaytype = $fld_label[5];
			$fieldname = $fld_label[7];
			$typeofdata =$fld_label[6];
			$fieldtype = explode("~",$typeofdata);
			if($fieldtype[1] == 'M')
			{
			 //36459: （1.6）角色权限明细界面>字段权限弹出层：将某个字段设置为必录项后无法去除勾选。（需要补丁）
				//$visible_value = 0;
			}
            $sql='select 1 from ld_profile2field  where profileid=? and tabid=? and fieldid=?  ';
          
            $result=$adb->pquery($sql,array($profileid,$tab_id,$fieldid));
           
            if($adb->num_rows($result)>0)
			{
			 $update_query = "update ld_profile2field set visible=?, readonly=?,editreadonly=? where fieldid=? and profileid=? and tabid=?";
			$result=$adb->pquery($update_query, array($visible_value, $readOnlyValue,$editreadonlyValue, $fieldid, $profileid, $tab_id));
          
			}
            else
            {
                $update_query = " insert into ld_profile2field(profileid,tabid,fieldid,visible,readonly,editreadonly)value(?,?,?,?,?,?)";
			  
                 $result=$adb->pquery($update_query, array($profileid,$tab_id,$fieldid,$visible_value,$readOnlyValue,$editreadonlyValue));
              // echo $fieldid."<br>";
            }
			
		//}
	}
  
   
    unsetCacheDirectory('fields');
    unsetCacheDirectory('profile');
    unsetCacheDirectory('Cache');
	$_REQUEST['diony']='diony';
	ConvertTojsonString(1,array(),"success");
	exit();
}
/*
function getProfile2FieldList($fld_module, $profileid)
{

	global $adb;
	$tabid = getTabid($fld_module);

	$query = "select ld_profile2field.visible,ld_field.* from ld_profile2field inner join ld_field 
    on ld_field.fieldid=ld_profile2field.fieldid where ld_profile2field.profileid=? 
    and ld_profile2field.tabid=? and ld_field.presence in (0,1,2)";
	$result = $adb->pquery($query, array($profileid, $tabid));

	return $result;
}*/


?>