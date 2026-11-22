<?php
require_once("Register/RegOp.php");
$regop=RegOp::getInstance();

$deploy_values=getSys_deploy(55);
/*
$callcenter_interface=$regop->GetcallcenterInterfaceStatus();
if($callcenter_interface==0&&$deploy_values['deploy_value']!='?绰?????')
{
    exit();
}*/
//$_REQUEST['columnname'] ??fieldname
	if(!empty($_REQUEST['columnname']) && !empty($_REQUEST['tablename']) && !empty($_REQUEST['frommodule'])){
		//$_REQUEST['columnname']????????columname??fieldname
		global $current_user,$adb;
		$module = $_REQUEST['frommodule'];
		$focus = CRMEntity::getInstance($module);
		$fieldobj=Field::getInstance($module,$adb);
        $columnname=$_REQUEST['columnname'];
	//	$columnname=$fieldobj->getFieldInfoBykeyValue('fieldname',$_REQUEST['columnname'],'columnname');
		$table_name = $focus->table_name;
		$table_index = $focus->table_index;
		$detailrecordid = $_REQUEST['detailrecordid'];
		//editor:gyq_20181204 reason:查询号码排除已删除的单据
		if(in_array($_REQUEST['tablename'],$focus->tab_name)){
			$query = 'select ' . $_REQUEST['tablename'] . '.'.$columnname .' FROM ' . $_REQUEST['tablename'] ;
               
			if($_REQUEST['tablename']!=$table_name)
			{
				$fromtablename=$_REQUEST['tablename'];
				$query.=" left join $table_name on $table_name.$table_index=$fromtablename.".$focus->tab_name_index[$fromtablename];
				
			}
			$query.=' where '.$table_name.'.'. $table_index . '='. $_REQUEST['record'].' and '.$table_name.'.deleted=0';
			
		}
        else if(($_REQUEST['tablename']=='ld_contactdetails'||$_REQUEST['tablename']=='ld_contactscf')&&empty($detailrecordid))
        {
            //客户界面外拨
            $query = 'select ' . $_REQUEST['tablename'] . '.'.$columnname .' FROM ' . $_REQUEST['tablename'] ;
            if($_REQUEST['tablename']!='ld_contactdetails')
            {
                $query.=' left join ld_contactdetails on ld_contactdetails.contactid=ld_contactscf.contactid ';
            }
            $query.=' inner join ld_account on ld_account.accountid=ld_contactdetails.accountid ';
            $query.=' where ld_account.accountid='.$_REQUEST['record'].' and ld_contactdetails.deleted=0
            and ld_contactdetails.reference=1';
        }
        else{
			if(!empty($detailrecordid)){
			 $detailfocus=CRMEntity::getInstance("Contacts");
   	       // $columnname=$detailfocus->fieldobj->getFieldInfoBykeyValue('fieldname',$_REQUEST['columnname'],'columnname');
				//??????????б?
				if(get_file_address($module,'ContactsDetails')){
					$query = 'select ' . $_REQUEST['tablename'] . '.'.$columnname .' FROM ' . $_REQUEST['tablename'] . ' where contactid ='. $detailrecordid;
				}
			}
		}
      
		$result = $adb->pquery($query,array());
		echo '##$$##'.$adb->query_result($result,0,0).'##$$##';
		die;
	}

?>