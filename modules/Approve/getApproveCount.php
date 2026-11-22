<?php
//session_start();
/**
 * 审批中心数量，异步生成以及异步获取文件
 * @project PROT58 审批中心数量加载速度优化
 * @author Tujt 2014-08-04
 */
if(isset($_REQUEST['ajax'])){//ajax获取审批数量
	global $current_user;
	$key = 'cache_approvecount_'.$current_user->id;
	$approvenum = Cache($key);
       
	if(!$approvenum){//如果未取到值，则再次计算一次
		$approve = new Approve();
		$approvenum = $approve->getApproveCount();
	}
    
	echo $approvenum;exit();
}elseif(isset($_REQUEST['userid'])){//sock方法计算审批数量
	chdir('./../../');
	include("includefile.php");
    
	global $current_user;
	$current_user->id = $_REQUEST['userid'];
	$approve = new Approve();
	$approvenum = $approve->getApproveCount();

	$key = 'cache_approvecount_'.$_REQUEST['userid'];
	/**
	 * 审批中心数量为零，无法重写缓存文件，所以需要将缓存文件删除
	 * @reason 0010841 审批中心待审批数量加载问题
	 * @author Tujt 2014-09-17
	 */
	if($approvenum > 0){//
		Cache($key,$approvenum);
	}else{
		unsetCache($key);
	}
	exit();
}
exit();
?>