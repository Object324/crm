<?php
/**
 * edit:chj
 * date:2017-03-13
 * reason:恢复列表默认列宽设置
 **/
global $adb,$current_user;
if(!empty($_REQUEST['frommodule']) && !empty($_REQUEST['viewname']))
{
	$frommodule = $_REQUEST['frommodule'];
	$viewname = $_REQUEST['viewname'];
	$query = 'select 1 from ld_list_headerwidth where userid = ? and type = ? and module = ? and relateid = ?';
    $type = 'customview';
    if(isset($_REQUEST['type'])){
        $type = $_REQUEST['type'];
    }
	$result = $adb->pquery( $query,array($current_user->id,$type,$frommodule,$viewname));
	$num_rows = $adb->num_rows($result);
	if($num_rows >= 1){
		$adb->pquery('delete from ld_list_headerwidth where userid = ? and type = ? and module = ? and relateid = ?',array($current_user->id,$type,$frommodule,$viewname));
	}
	echo 'success';exit();
}else{
	//审批中心
	if(!empty($_REQUEST['frommodule']) && $_REQUEST['frommodule'] == 'Approve'){
		$fromapprovemodule = $_REQUEST['fromapprovemodule'];
		$approvestatus = $_REQUEST['approvestatus'];
		$query = 'select 1 from ld_list_headerwidth where userid = ? and type = ? and module = ? and relateid = ?';
		$result = $adb->pquery( $query,array($current_user->id,'Approve',$fromapprovemodule,$approvestatus));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			$adb->pquery('delete from ld_list_headerwidth where userid = ? and type = ? and module = ? and relateid = ?',array($current_user->id,'Approve',$fromapprovemodule,$approvestatus));
		}
		echo 'success';exit();
	}
}
	
?> 