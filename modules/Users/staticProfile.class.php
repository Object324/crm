<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt 2015-03-25
 */
class staticProfile {
	private static $_instance;//存储对象
	public static $group;//部门类
	public static $profile;//权限类
    /**
     * 构造函数
     * @author Tujt 2015-03-25
     */
    function __construct() {
		require_once globalStatic::$root_directory.'modules/Users/Group.class.php';
        self::$group = new Group();
		require_once globalStatic::$root_directory.'modules/Users/Profile.class.php';
        self::$profile = Profile::getInstance();
    }
	/**
     * 防止被克隆
     * @author Tujt 2015-03-25
     */
    private function __clone(){}
	/**
     * 单例初始化类
     * @author Tujt 2015-03-25
     */
    public static function getInstance(){
        if(FALSE == (self::$_instance instanceof self)){
            self::$_instance = new self();
        }
        return self::$_instance;
    }

	/**
	 * 获取模块权限控制信息
	 * @param String $module 模块名
	 * @param Integer $profileid 权限ID
	 * @return 权限控制结果集 Array
	 * @project PROT180 角色权限改进
	 * @author Tujt 2015-03-27
	 */
	public static function getModuleProfile($module,$profileid = '') {
	    return self::$profile->getModuleProfile($module,$profileid);
	}

	/**
     * 析构函数
     * @author Tujt 2015-03-25
     */
    function __destruct() {
        
    }

    /**
	 * 判断模块是否存在指定权限
	 * @param string $module 模块名
	 * @param string $action 权限名
	 * @return string
	 */
	public static function isModuleExistsProfile($module,$action) {
        global $adb;

        $cachekey = 'cache_getModuleExistsProfile';
        $existed_actions = Cache($cachekey);
        $tabid = getTabid($module);

        if(!$existed_actions){
            $existed_actions = array();
            $query = "
                    SELECT
                        ld_profileallpermission.tabid,
                        ld_profileallpermission.operation,
                        ld_actionmapping.actionname
                    FROM
                    ld_profileallpermission
                        LEFT JOIN ld_actionmapping on ld_actionmapping.actionid = ld_profileallpermission.operation
                        LEFT JOIN ld_tab ON ld_tab.tabid=ld_profileallpermission.tabid
                    ";

            $result = $adb->pquery($query,array());
            $num_rows = $adb->num_rows($result);
            if($num_rows > 0) {
                for($i = 0; $i<$num_rows; $i++){
                    $existed_actions[$adb->query_result($result,$i,'tabid')][] = $adb->query_result($result,$i,'actionname');
                }
            }
            Cache($cachekey,$existed_actions);
        }
        
        if(is_array($existed_actions[$tabid]) && in_array($action,$existed_actions[$tabid])){
            return 'yes';
        }
        return 'no';
	}
}
?>