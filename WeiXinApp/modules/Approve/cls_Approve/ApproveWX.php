<?php
crm_load_class_file('Approve','modules/Approve');
class ApproveWX extends Approve{
    private $approveInfo=array();

	/**
	 * 微信获取有审批的模块
	 * @author gyq_22 20170116
	 */
	public static function getApproveModuleInfoWX() {
	    global $current_user;
	    $cachekey = 'getapprovemoduleinfoWX'.$current_user->id;
        $approvemod = CacheDirectory($cachekey,'wxapprovemodules');
		if(!$approvemod||!is_array($approvemod)){
			global $adb;
			$approvemod = array();
			/*$query = 'SELECT DISTINCT modulename from ld_cvcolumnlist_wx
                      LEFT JOIN ld_tab on ld_tab.name=ld_cvcolumnlist_wx.modulename
                    WHERE  ld_tab.presence in(0,2)';
            $result = $adb->pquery($query,array());
            $num_rows = $adb->num_rows($result);
            for($i = 0; $i < $num_rows; $i++){
                $module[] = $adb->query_result($result,$i,'modulename');
            }*/
            $module = cls_StaticCommonFun::validmodule();
			//获取已开启审批的模块
            $query = "select  setype from ld_systems_deploy where setype is not null and deploy_value=0 
            and setype in ('".implode("','",$module)."')";
			$result = $adb->pquery($query,array());
			$rows = $adb->num_rows($result);
			if($rows > 0){
				for($i=0;$i<$rows;++ $i){
				    $setype = $adb->query_result($result,$i,'setype');
					$approvemod[$setype] = $setype;
				}
                CacheDirectory($cachekey,'wxapprovemodules',$approvemod);
			}
		}
		if(!empty($approvemod)) return $approvemod;
		return false;
	}
    //gyq_40_4
}
?>