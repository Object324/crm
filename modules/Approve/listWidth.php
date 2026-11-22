<?php
if(!globalStatic::$root_directory)
{
    exit() ;
}
$module=$_REQUEST['fromapprovemodule'];
$focus=CRMEntity::getInstance($module);

$widths=$_REQUEST['listwidth'];

$widths=array_filter(explode(",",$widths));
$widths=implode(',',$widths);
$widths=explode(",",$widths);
$headernames=$_REQUEST['headername'];
$headermodules=$_REQUEST['headermodule'];

$headernames=array_filter(explode(",",$headernames));
$headernames=implode(',',$headernames);
$headernames=explode(",",$headernames);//fieldname


$headermodules=array_filter(explode(",",$headermodules));
$headermodules=implode(',',$headermodules);
$headermodules=explode(",",$headermodules);
global $adb,$current_user;
//$fieldobj=Field::getInstance($module);

if($_REQUEST['type']=='customview')//数据分类
{
    
      $viewid=$_REQUEST['viewid'];
      //42138: 审批中心->不能记住设置的列宽
	   crm_load_class_file('Approve_Field','modules/Approve/ListView');
         $main_fieldobj= new Approve_Field($module,$adb);
      if(get_file_address($module,'ProductDetails')||$module=='ServiceCharge')
      {
         crm_load_class_file("cls_Approve_Productdetail",'modules/Approve/ListView');
         $detailfieldobj=new cls_Approve_Productdetail($module);
         $detailfields=$detailfieldobj->getModuleFields();
      }
      else if(get_file_address($module,'ContactsDetails'))
      {
		crm_load_class_file("cls_Approve_Productdetail",'modules/Approve/ListView');
		$detailfieldobj=new cls_Approve_Productdetail($module);
		$detailfields=$detailfieldobj->getModuleFields();
      }
      else if(get_file_address($module,'VendorsDetails'))
      {
		crm_load_class_file("cls_Approve_Productdetail",'modules/Approve/ListView');
		$detailfieldobj=new cls_Approve_Productdetail($module);
		$detailfields=$detailfieldobj->getModuleFields();
      }
      else if(get_file_address($module,$module.'DetailFieldsHtml'))
      {
         crm_load_class_file("cls_Approve_TabDetails",'modules/Approve/ListView');
        $TabDetails=new cls_Approve_TabDetails($module);
        $detailfields=$TabDetails->getModuleFields();
      }else{

	
	  }
     
      $cur_module=$module;
      if($module=='ServiceCharge')
      {
        $cur_module='Accounts';
      }
     
      for($i=0;$i<sizeof($headernames);$i++)
      {
            $header_module=$headermodules[$i];
            $fieldname=$headernames[$i];
             
			if($fieldname=='chkbox')
			{
				//带checkbox列表
				$tablename=$focus->table_name;
				$columnname='chkbox';
				
			}else{
				if($header_module!=$cur_module&&$header_module!='ServiceCharge')
				{
					$detailfieldinfo=$detailfields[$fieldname];
					$tablename=$detailfieldinfo->getTableName();
					$columnname=$detailfieldinfo->getColumnName();
				}
				else{
                    $fieldInfo=$main_fieldobj->getFieldInfoobjBykey("fieldname",$fieldname);
                    
                    $tablename=$fieldInfo->getTableName();
                    $columnname=$fieldInfo->getColumnName();
                }
			}
            $columninfos[]=$tablename.":".$columnname.":".$fieldname.":".$header_module;
      }
     $SQL='delete from ld_list_headerwidth where module=? and type=?  and userid=? and relateid= ?';
     $adb->pquery($SQL,array($module,'Approve',$current_user->id,$viewid));
     $i=0;
    
     foreach($widths as $td_width)
     {
       
        if($td_width>=0)
        {
            $SQL='insert into ld_list_headerwidth(module,type,userid,header_width,columns,relateid)value(?,?,?,?,?,?)';
            $adb->pquery($SQL,array($module,'Approve',$current_user->id,$td_width,$columninfos[$i],$viewid));
            
        }
        $i++;
     }
}

?>