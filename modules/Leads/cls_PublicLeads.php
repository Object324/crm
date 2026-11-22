<?php
/*

*date 2021/05/25
*reason 公海设置类
*/
class cls_PublicLeads
{
    public $module;

    public function __construct($module)
    {
		$this->module = $module;
    }

    public static function getInstance($module)
    {
        static $static_publicleads_obj;
        if(isset($static_publicleads_obj))
        {
            return $static_publicleads_obj;
        }
        $static_publicleads_obj=new cls_PublicLeads($module);
        return $static_publicleads_obj;

    }

	//获取公海参数配置信息
	public function getPublicAccountConfig(){
		global $current_user,$languageType;
		$public_account = $this->getPublicAccount();
		$administrator = 'no';//是否是超级管理员
		if(!empty($public_account['administrators'])){
			$administrator_arr = explode(',',(string)$public_account['administrators']);
			if(in_array($current_user->id,$administrator_arr)){
				$administrator = 'yes';
			}
		}
		require_once(globalStatic::$root_directory.'modules/Users/Group.class.php');
		$cls_group = new Group();
		//所有公海池
		$all_public_account_pool = $this->getAllPublicAccountPool();
		if(!empty($all_public_account_pool)){
			foreach($all_public_account_pool as $pool_id => $public_account_pool_info){
				$group_userid = [];
				$admin_arr = explode(',',(string)$public_account_pool_info['administrators']);
				if($public_account_pool_info['usertype'] == 'user'){
					$userids_arr = explode(',',(string)$public_account_pool_info['userids']);
				}else if($public_account_pool_info['usertype'] == 'group'){
					$groupids = explode(',',(string)$public_account_pool_info['userids']);
					foreach($groupids as $groupid){
						$groupUserArr = $cls_group->getGroupOfusers_id($groupid);//获取部门下的所有用户
						foreach($groupUserArr as $userid => $username){
							$group_userid[$userid] = $userid;
						}
					}
					$userids_arr = $group_userid;
					$public_account_pool_info['userids'] = trim(implode(',',$group_userid),',');
				}else{
					$userscope = get_user_array(false, "", '');
					$userids_arr = array_keys($userscope);
					$public_account_pool_info['userids'] =  implode(',',$userids_arr);
				}
				if($administrator == 'yes' || in_array($current_user->id,$admin_arr) || in_array($current_user->id,$userids_arr)){
					if($languageType == 'zh')
						$public_account_pool_info['pool_name'] = $public_account_pool_info['zh_name'];
					else
						$public_account_pool_info['pool_name'] = $public_account_pool_info['en_name'];

					$public_account_pool[$pool_id] = $public_account_pool_info;
				}
			}
		}
		return array(
			'status' => $public_account['status'],	
			'administrator' => $administrator,	
			'show_publicaccount_tab' => $public_account['show_publicaccount_tab'],	//	全部（含所有公海）页签是否显示
			'default_publicaccount_tab' => $public_account['default_publicaccount_tab'],	//全部（含所有公海） 默认显示
			'public_account_pool' => $public_account_pool,	//公海池信息
			'show_commonaccount_tab' => $public_account['show_commonaccount_tab'],	//显示 “全部（普通线索）”页签 
			'show_account_rule' => $public_account['show_account_rule'],	//普通线索自动回收规则设置
			'account_rule_pool_id' => $public_account['account_rule_pool_id'],	//启用普通线索自动回收规则，自动回收到公海池
			'is_commonaccount_create' => $public_account['is_commonaccount_create'],	//允许创建普通线索
            'set_default_tab' => $public_account['set_default_tab'],	//设置默认页签
            'limit_type' => $public_account['limit_type'],	//普通客户 分配上限类型 按成员、按角色
            'limit_count' => $public_account['limit_count'],	//普通客户 分配上限数量
            'showpublicmodule' => $public_account['showpublicmodule'],
            'public_limit_type' => $public_account['public_limit_type'],
            'public_limit_count' => $public_account['public_limit_count'],
		);
	}
	//获取所有公海池
	public function getAllPublicAccountPool(){
		global $adb;
		if(!empty($cache_public_account_pool))
			return $cache_public_account_pool;
		$cache_public_account_pool = Cache('public_leads_pool');
		if(!is_array($cache_public_account_pool)||empty($cache_public_account_pool)){
		  $cache_public_account_pool=[];
			$query = "select id,zh_name,en_name,limit_count,limit_type,administrators,userids,usertype,dataprofile,allowget,allow_unallocated_showinall,allow_allocated_showinall,allow_trasnfer_others,
			userid_after_transfer,userid_after_release,create_buttons,beforereminddays,objtainaccountcontroldays,createdtime,smcreatorid,modifiedtime,modifiedby,recycleselect,allow_users,transfer_users,default_pool,
			poolmember_show_noallocate,releasetype from ld_leads_public_pool where deleted = 0 and active = 'yes' order by sequence";
			$result = $adb->pquery($query,array());
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				for($i = 0; $i < $num_rows; $i++){
					$pool_id = $adb->query_result($result,$i,'id');
					$limit_type = $adb->query_result($result,$i,'limit_type');
					$cache_public_account_pool[$pool_id] = array(
						'zh_name' => $adb->query_result($result,$i,'zh_name'),	//公海名称中文
						'en_name' => $adb->query_result($result,$i,'en_name'),	//公海名称英文
						'limit_count' => $adb->query_result($result,$i,'limit_count'),	//公海已分配客户上线
						'limit_type' => $limit_type,	//公海已分配上线 1按成员 2按角色
						'limit_type_role' => $this->getAccountRoleLimitCount($pool_id),
						'administrators' => $adb->query_result($result,$i,'administrators'),	//公海管理员
						'userids' => $adb->query_result($result,$i,'userids'),	//公海成员
						'usertype' => $adb->query_result($result,$i,'usertype'),	//公海成员类型 all所有 group 部门 user 用户
						'dataprofile' => $adb->query_result($result,$i,'dataprofile'),	//公海未分配客户不允许领取（只能由公海管理员分配） 
						'allowget' => $adb->query_result($result,$i,'allowget'),	//公海未分配客户不控制数据权限（可查询所有公海未分配客户） 
						'allow_unallocated_showinall' => $adb->query_result($result,$i,'allow_unallocated_showinall'),	//允许公海未分配客户显示在“全部（含指定公海）”列表 
						'allow_allocated_showinall' => $adb->query_result($result,$i,'allow_allocated_showinall'),	// 允许公海已分配客户显示在“全部（含指定公海）”列表 
						'allow_trasnfer_others' => $adb->query_result($result,$i,'allow_trasnfer_others'),	//允许公海成员将已分配或领取的公海客户转移到其他公海 
						'userid_after_transfer' => $adb->query_result($result,$i,'userid_after_transfer'),	//客户转到本公海后，更改负责人为（只能选择公海成员，为空表示不更改）
						'userid_after_release' => $adb->query_result($result,$i,'userid_after_release'),	//公海已分配客户释放后，更改客户负责人为（为空表示不更改）
						'create_buttons' => $adb->query_result($result,$i,'create_buttons'),	//公海成员客户序时簿“新建”功能下拉选项
						'beforereminddays' => $adb->query_result($result,$i,'beforereminddays'),	//客户回收前提前多少天提醒销售负责人（为0表示当天提醒，为空表示不提醒） 
						'objtainaccountcontroldays' => $adb->query_result($result,$i,'objtainaccountcontroldays'),	//客户被自动回收后天内不允许被当前销售负责人再次领取（为0或空表示不控制） 
						'recycleselect' => $adb->query_result($result,$i,'recycleselect'),	//公海回收条件sql
						'createdtime' => $adb->query_result($result,$i,'createdtime'),
						'smcreatorid' => $adb->query_result($result,$i,'smcreatorid'),
						'modifiedtime' => $adb->query_result($result,$i,'modifiedtime'),
						'modifiedby' => $adb->query_result($result,$i,'modifiedby'),
						'allow_users' => $adb->query_result($result,$i,'allow_users'),	//允许“公海分配”的成员  
						'transfer_users' => $adb->query_result($result,$i,'transfer_users'),	//允许“转换公海”的成员
						'default_pool' => $adb->query_result($result,$i,'default_pool'),	//默认公海
                        'poolmember_show_noallocate' => $adb->query_result($result,$i,'poolmember_show_noallocate'),	//允许公海成员查看“公海未分配”列表
                        'releasetype'=> $adb->query_result($result,$i,'releasetype'),
					);
				}
				Cache('public_leads_pool',$cache_public_account_pool);
			}
		}
		return $cache_public_account_pool;
	}
	
	//获取 - 设置公海参数
	public function getPublicAccount(){
		global $adb;
		$query = 'select status,show_publicaccount_tab,default_publicaccount_tab,administrators,show_commonaccount_tab,show_account_rule,account_rule_pool_id,
            is_commonaccount_create,set_default_tab,limit_type,ifnull(limit_count,0) as limit_count,showpublicmodule,public_limit_type,ifnull(public_limit_count,0) as public_limit_count from ld_leads_public limit 1';
		$result = $adb->pquery($query,array());
		$data = array(
			'status' => $adb->query_result($result,0,'status'),	
			'show_publicaccount_tab' => $adb->query_result($result,0,'show_publicaccount_tab'),	
			'default_publicaccount_tab' => $adb->query_result($result,0,'default_publicaccount_tab'),	
			'administrators' => $adb->query_result($result,0,'administrators'),	
			'show_commonaccount_tab' => $adb->query_result($result,0,'show_commonaccount_tab'),	
			'show_account_rule' => $adb->query_result($result,0,'show_account_rule'),	
			'account_rule_pool_id' => $adb->query_result($result,0,'account_rule_pool_id'),	
			'is_commonaccount_create' => $adb->query_result($result,0,'is_commonaccount_create'),
            'set_default_tab' => $adb->query_result($result,0,'set_default_tab'),
            'limit_type' => $adb->query_result($result,0,'limit_type'),
            'limit_count' => $adb->query_result($result,0,'limit_count'),
            'showpublicmodule' => $adb->query_result($result,0,'showpublicmodule'),
            'public_limit_type' => $adb->query_result($result,0,'public_limit_type'),
            'public_limit_count' => $adb->query_result($result,0,'public_limit_count'),
		);
		return $data;
	}

	//获取公海池的领取信息
	public function getPublicAccountPoolForAllowget($pool_id){
		global $adb;
		$noallowget = 0;	//为领取个数
		$allowget = 0; //领取个数
        return [];
		if(!empty($pool_id)){
			$query = "select publicaccount,count(1) as num from ld_leads where deleted = 0 and pool_id = ? and publicaccount >= 1 GROUP BY publicaccount";
			$result = $adb->pquery($query,array($pool_id));
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				for($i = 0; $i < $num_rows; $i++){
					$publicaccount = $adb->query_result($result,$i,'publicaccount');
					$num = $adb->query_result($result,$i,'num');
					if($publicaccount == 1){
						$noallowget += $num;
					}else if($publicaccount == 2 || $publicaccount == 3){
						$allowget += $num;
					}
				}
			}
		}
		return array('noallowget'=>$noallowget,'allowget'=>$allowget);
	}
	
	//获取个人已领取的公海数   参数$userid  因为公海分配时，可能会分配给其他负责人
	public function getCurrentUserAllowget($pool_id,$userid){
		global $adb;
		$user_allowget = 0;
        return 0;
		$query = "select count(1) as a from ld_leads where deleted = 0 and pool_id = ? and smownerid = ? and publicaccount >= 2 ";
		$result = $adb->pquery($query,array($pool_id,$userid));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			$user_allowget = $adb->query_result($result,0,0);
		}
		return $user_allowget;
	}
	
	//公海已分配客户上线，按角色控制表
	public function getAccountRoleLimitCount($pool_id){
		global $adb;
		if(!empty($pool_id)){
			$account_role_limitcount = array();
			$query = "select roleid,limit_count from ld_leads_role_limitcount where pool_id = ?";
			$result = $adb->pquery($query,array($pool_id));
			$num_rows = $adb->num_rows($result);
			if($num_rows >= 1){
				for($i = 0; $i < $num_rows; $i++){
					$roleid = $adb->query_result($result,$i,'roleid');
					$limit_count = $adb->query_result($result,$i,'limit_count');
					$account_role_limitcount[$roleid] = $limit_count;
				}
			}
		}
		//获取角色权限
		$profile_focus = new Profile();
		$all_role = $profile_focus->getProfileArray();
		foreach($all_role as $role_id => $role_name){
			$data[$role_id]['role_name'] = $role_name;
			if(!empty($account_role_limitcount[$role_id])){
				$data[$role_id]['limit_count'] = $account_role_limitcount[$role_id];
			}else{
				$data[$role_id]['limit_count'] = 0;
			}
		}
		return $data;
	}

    //普通客户上限，按角色控制表(弹窗显示页数据)
    public function getCommonAccountRoleLimitCount(){
        global $adb;

        $account_role_limitcount = array();
        $query = "select roleid,limit_count from ld_leads_role_limitcount_common";
        $result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            for($i = 0; $i < $num_rows; $i++){
                $roleid = $adb->query_result($result,$i,'roleid');
                $limit_count = $adb->query_result($result,$i,'limit_count');
                $account_role_limitcount[$roleid] = $limit_count;
            }
        }

        //获取角色权限
        $profile_focus = new Profile();
        $all_role = $profile_focus->getProfileArray();
        foreach($all_role as $role_id => $role_name){
            $data[$role_id]['role_name'] = $role_name;
            if(!empty($account_role_limitcount[$role_id])){
                $data[$role_id]['limit_count'] = $account_role_limitcount[$role_id];
            }else{
                $data[$role_id]['limit_count'] = 0;
            }
        }
        return $data;
    }

	//获取默认公海
	public function getDefaultPublicPool($returntype= ''){
        $all_public_config = $this->getPublicAccountConfig();

        $all_public_leads_pool = !empty($all_public_config['public_account_pool'])?$all_public_config['public_account_pool']:[];
		$pool_id_arr = array_keys($all_public_leads_pool);
		foreach($all_public_leads_pool as $pool_id => $pool_info){
			if(empty($first_pool_info)){
				$first_pool_info = $pool_info;
			}
			if($pool_info['default_pool'] == 'yes'){
				if($returntype == '' || $returntype == 'pool_id'){
					$default_pool = $pool_id;
				}else if($returntype == 'pool_info'){
					$default_pool = $pool_info;
				}
			}
		}
		if(empty($default_pool)){//没有默认公海取排序第一个公海
			if($returntype == '' || $returntype == 'pool_id'){
				$default_pool = $pool_id_arr[0];
			}else if($returntype == 'pool_info'){
				$default_pool = $first_pool_info;
			}			
		}
		return $default_pool;
	}

    //获取所有未删除的公海池信息
    public function getAllActivePool(){
        global $adb;
        $resultinfo = [];
        $query = "select * from ld_leads_public_pool where deleted = 0 order by sequence";
        $result = $adb->pquery($query,array());
        $num_rows = $adb->num_rows($result);
        if($num_rows >= 1){
            $resultinfo = $adb->query_result_all($result);
        }
        return $resultinfo;
    }

}



?>