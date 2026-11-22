<?php


crm_load_class_file('Accounts','modules/Accounts');///
class ServiceCharge extends Accounts
{
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['ServiceCharge']='ServiceCharge';
        
            
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                include("modules/$requiremodules/$requiremodules.php");
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
            }

    }
     var $module_name='ServiceCharge';
    function __construct()
    {
	   //$this->log =LoggerManager::getLogger('ServiceCharge');
		$this->db = PearDatabase::getInstance();
         $this->fieldobj=Field::getInstance('ServiceCharge',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $this->relatedtab=array('servicecharge'=>'','users'=>'','company'=>'');//打印需要
        $entityname=getEntitynameByModulename('ServiceCharge');
        $this->list_link_field=$entityname['fieldname'];
    }
     /**
      * 获取模块的负责人字段
      * */
     public function getSmownerColumName()
     {
        $columname='servicecasher';
        return $columname;
     }
    function getServiceGroup()
    {
        global $adb,$current_user,$languageType;
        require("user_privileges/user_language_".$current_user->id.'.php');
        if($languageType == 'zh')
            $servicegroupname = 'servicegroupname_zh';
        else
            $servicegroupname = 'servicegroupname_en';
      /*  $sqlgroup = "select servicegroupid,$servicegroupname,is_edit,count(ld_account.accountid) from ld_servicegroup
        left join ld_account on ld_account.servicegroup = ld_servicegroup.servicegroupid
        GROUP BY ld_servicegroup.servicegroupid
        order by sequence asc";*/
        $sqlgroup='select servicegroupid,'.$servicegroupname.',is_edit from ld_servicegroup order by sequence asc';
        $querygroup = $adb->pquery($sqlgroup,array());
        for($i = 0; $i<$adb->num_rows($querygroup); $i++)
        {
            $Group[$i] = array(
                'servicegroupid' => $adb->query_result($querygroup,$i,'servicegroupid'),
                'servicegroupname' => $adb->query_result($querygroup,$i,$servicegroupname),
                'is_edit' => $adb->query_result($querygroup,$i,'is_edit'),
            );
        }
        return $Group;
    }
    
    
    
    
    /**
     * edit:chj
     * reason:获取服务分组名称
     * description: 服务收费 - 获取服务收费分组名称
     * date:2014-8-18
     * 
    static function getServiceGroupName($servicegroupid){
    
    	global $current_user;
    	if(empty($servicegroupid)) return false;
    	$cachekey = 'cacheservicegroupname';
    	static $staticservice;
    	if(!empty($staticservice) && isset($staticservice[$servicegroupid])){
    		require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
    		if(isset($staticservice[$servicegroupid][$languageType]) && !empty($staticservice[$servicegroupid][$languageType]))
    			return $staticservice[$servicegroupid][$languageType];
    		else
    			return '--';
    	}
    	$serviceobj = Cache($cachekey);
    	if(!$serviceobj){
    		global $adb;
    		$serviceobj = array();
    		$query = 'select servicegroupid,servicegroupname_zh,servicegroupname_en 
    					from ld_servicegroup ORDER BY servicegroupid DESC ';
    		$result = $adb->pquery($query,array());
    		$rows = $adb->num_rows($result);
    		if($rows > 0){
    			for($i=0;$i<$rows;++ $i){
    			    $id = $adb->query_result($result,$i,'servicegroupid');
    				$serviceobj[$id]['zh'] = $adb->query_result($result,$i,'servicegroupname_zh');
    				$serviceobj[$id]['en'] = $adb->query_result($result,$i,'servicegroupname_en');
    			}
    			Cache($cachekey,$serviceobj);
    		}
    	}
    	$staticservice = $serviceobj;
        require("user_privileges/user_language_".$current_user->id.'.php');
    	if(isset($serviceobj[$servicegroupid][$languageType]) && !empty($serviceobj[$servicegroupid][$languageType]))
    		return $serviceobj[$servicegroupid][$languageType];
    	else
    		return '--';
      
    }*/
}
ServiceCharge::require_file();
?>