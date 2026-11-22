<?php
//zxm 20221128 approve.php中的代码优化   缓存相关的
class cls_ApproveCache
{
    //获取所有可以开启审批的模块信息
    public static function getAllModuleInfo() {
        $cachekey = 'getallmoduleinfo';
        $approvemod = Cache($cachekey);
        if(!$approvemod){
            global $adb;
            $approvemod = array();
            $query = 'SELECT setype FROM ld_systems_deploy WHERE setype IS NOT NULL AND setype != \'\' ORDER BY id;';
            $result = $adb->pquery($query,array());
            $rows = $adb->num_rows($result);
            if($rows > 0){
                for($i=0;$i<$rows;++ $i){
                    $setype = $adb->query_result($result,$i,'setype');
                    $approvemod[$setype] = $setype;
                }
                Cache($cachekey,$approvemod);
            }
        }
        if(!empty($approvemod)) return $approvemod;
        return false;
    }
    /**
     * 获取有客户字段的模块
     * @author Tujt 2015-04-15
     */
    public static function getAccountModule() {
        $cachekey = 'getaccountmodule';
        $accountmod = Cache($cachekey);
        if(!$accountmod){
            global $adb;
            $accountmod = array();
            $query = 'select tabid from ld_field where uitype=73  and presence in(0,2) group by tabid ';
            $result = $adb->pquery($query,array());
            $rows = $adb->num_rows($result);
            if($rows > 0){
                for($i=0;$i<$rows;++ $i){
                    $tabid = $adb->query_result($result,$i,'tabid');
                    $accountmod[$tabid] = getTabname($tabid);
                }
                Cache($cachekey,$accountmod);
            }
        }
        if(!empty($accountmod)) return $accountmod;
        return false;
    }
    /**
     * 获取有审批的模块
     * @author Tujt 2015-04-10
     */
    public static function getApproveModuleInfo() {
        $cachekey = 'getapprovemoduleinfo';
        $approvemod = Cache($cachekey);
        if(!$approvemod){
            global $adb;
            $approvemod = array();
            $query = 'SELECT setype FROM ld_systems_deploy WHERE setype IS NOT NULL 
						AND deploy_value=0 AND setype != \'\' ORDER BY id;';
            $result = $adb->pquery($query,array());

            $rows = $adb->num_rows($result);
            if($rows > 0){
                for($i=0;$i<$rows;++ $i){
                    $setype = $adb->query_result($result,$i,'setype');
                    $approvemod[$setype] = $setype;
                }
                Cache($cachekey,$approvemod);
            }
        }
        if(!empty($approvemod)) return $approvemod;
        return false;
    }
    //判断模块 判断是否显示停用的审批流程
    public static function ShowDisabledApprove($module){
        $key = 'cache_showdisabledapprove';
        $showdisabledapprove = Cache($key);
        if(!$showdisabledapprove){
            global $adb;
            $showdisabledapprove = array();
            $query = 'SELECT ld_tab.name,ld_tab.tabid FROM ld_tab where showdisabledapprove = "yes" AND ld_tab.tabid > 0 ORDER BY ld_tab.tabid';
            $result = $adb->pquery($query);
            $rows = $adb->num_rows($result);
            if($rows > 0){
                for($i=0;$i<$rows;$i++){
                    $tabid = $adb->query_result($result,$i,'tabid');
                    $name = $adb->query_result($result,$i,'name');
                    $showdisabledapprove[$name] = $tabid;
                }
                Cache($key,$showdisabledapprove);
            }
        }
        if(!empty($showdisabledapprove[$module]))
            return true;
        return false;
    }
    //获取审批日志设置信息
    public static function getApprovelogSet($module){
        global $adb,$current_user;
        $key = "cache_approvelogset";
        $AllApprovelogSetinfo = cache($key);
        if(!$AllApprovelogSetinfo){
            $sql = "select label,content,modulename,userid from ld_module_setting_byuser where type = ?";
            $result = $adb->pquery($sql,array('approvelog'));
            $num_rows = $adb->num_rows($result);
            $approvelogset_arr = array();
            if($num_rows >0){
                for($i=0;$i<$num_rows;$i++){
                    $modulename = $adb->query_result($result,$i,'modulename');
                    $userid = $adb->query_result($result,$i,'userid');
                    $label = $adb->query_result($result,$i,'label');
                    $content = $adb->query_result($result,$i,'content');
                    $approvelogset_arr[$label][$modulename][$userid] = $content;
                }
            }
            $AllApprovelogSetinfo = $approvelogset_arr;
            cache($key,$AllApprovelogSetinfo);
            $AllApprovelogSetinfo = cache($key);
        }
        $result_arr = array();
        $approvelabel_arr = array('showcurrentapprove','hideautopassstep');
        foreach($approvelabel_arr as $tmp_label){
            $result_arr[$tmp_label] = $AllApprovelogSetinfo[$tmp_label][$module][$current_user->id];
        }
        return $result_arr;
    }
    //判断模块 已批准/拒绝的单据允许再次提交审批
    public static function recordAgainSubmit($module){
        $key = 'cache_recordagainsubmit';
        $recordagainsubmit = Cache($key);
        if(!$recordagainsubmit){
            global $adb;
            $recordagainsubmit = array();
            $query = 'SELECT ld_tab.name,ld_tab.tabid FROM ld_tab where againsubmit = "yes" AND ld_tab.tabid > 0 ORDER BY ld_tab.tabid';
            $result = $adb->pquery($query);
            $rows = $adb->num_rows($result);
            if($rows > 0){
                for($i=0;$i<$rows;$i++){
                    $tabid = $adb->query_result($result,$i,'tabid');
                    $name = $adb->query_result($result,$i,'name');
                    $recordagainsubmit[$name] = $tabid;
                }
                Cache($key,$recordagainsubmit);
            }
        }
        if(!empty($recordagainsubmit[$module]))
            return true;
        return false;
    }
    //判断模块是否启用快速提交
    public static function Blocksquicksubmit($module){
        $key = 'cache_blocksquicksubmit';
        $blocksquicksubmit = Cache($key);
        if(!$blocksquicksubmit){
            global $adb;
            $blocksquicksubmit = array();
            $query = 'SELECT ld_tab. NAME,ld_tab.tabid FROM ld_tab where quicksubmit = ? 
                        AND ld_tab.tabid > 0 ORDER BY ld_tab.tabid';
            $result = $adb->pquery($query,array('yes'));
            $rows = $adb->num_rows($result);
            if($rows > 0){
                for($i=0;$i<$rows;++ $i){
                    $tabid = $adb->query_result($result,$i,'tabid');
                    $name = $adb->query_result($result,$i,'name');
                    $blocksquicksubmit[$name] = $tabid;
                }
                Cache($key,$blocksquicksubmit);
            }
        }
        if(!empty($blocksquicksubmit[$module]))
            return true;
        return false;
    }
    /**
     * edit:kevin
     * date:2013-09-24
     * reason:单据是否启用审批
     */
    public static function  startBlocksApprove(){
        /**
         * 将有审批的模块存入缓存中
         * @project PROT58 速度优化：缓存
         * @author Tujt 2014-08-01
         */
        $key = 'cache_startblocksapprove';
        $startapprovemodule = Cache($key);
        if(!$startapprovemodule){
            global $adb;
            $startapprovemodule = array();
            $query = 'SELECT ld_tab.name,ld_tab.tabid FROM ld_systems_deploy 
						 INNER JOIN ld_tab ON ld_tab.name=ld_systems_deploy.setype 
					  WHERE setype IS NOT NULL AND setype!=\'\' AND deploy_value = 0 
					  AND ld_systems_deploy.id > 0 ORDER BY ld_systems_deploy.id;';
            $result = $adb->pquery($query,array());
            $rows = $adb->num_rows($result);
            if($rows > 0){
                for($i=0;$i<$rows;++ $i){
                    $tabid = $adb->query_result($result,$i,'tabid');
                    $name = $adb->query_result($result,$i,'name');
                    $startapprovemodule[$name] = $tabid;
                }
                Cache($key,$startapprovemodule);
            }
        }
        if(!empty($startapprovemodule))
            return $startapprovemodule;
        return '';
    }
    /**
     * 获取审批状态对应的图片
     */
    public static function getApproveStatus($status){
        if(empty($status)) return 0;//为空，未提交
        $array = array(
            constant('D_A_S_UNAPPROVED')=>0,//未提交
            constant('D_A_S_APPROVALOF')=>1,//审批中
            constant('D_A_S_APPROVED')=>2,//已批准
            constant('D_A_S_REJECTED')=>3,//已拒绝
            constant('D_A_S_DISMISSED')=>4,//已驳回
        );
        if(isset($array[$status])){
            return $array[$status];
        }
        return 0;
    }
    /**
     * 是否为并发步骤的最后一步
     * yes:是
     * */
    public static function getisLastStepConcurrent($record,$logconcurrentid,$approveid)
    {
        global $adb;
        $sql='select id from ld_approvelog where crmid=? and logconcurrentid=? and isfinished="no" limit 2';
        $tmp_result=$adb->pquery($sql,array($record,$logconcurrentid));
        if($adb->num_rows($tmp_result)<=1)
        {
            return 'yes';
        }
        return 'no';
    }
}