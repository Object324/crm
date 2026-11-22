<?php
require_once globalStatic::$root_directory.'modules/Users/Group.class.php';

if(!empty($_REQUEST['accountid'])){
	$group_focus = new Group();
	$accountid = $_REQUEST['accountid'];
	$focus = CRMEntity::getInstance('Accounts');
	$accounts_list = Array();
	$encountered_accounts = array($accountid);
	$accounts_list = $focus->__getParentAccounts($accountid, $accounts_list, $encountered_accounts);
    //zkt 20221011 BUG0053976https://www.51mis.com/hy/ty0608/）客户：中国东方航空集团公司的查看上下级关系中不显示123的下级单位
    //因为需要获取所有下级部门信息，所以去除上级部门为当前部门的数据
    foreach($accounts_list as $tmpid=>$tmpinfo){
        if($tmpinfo['parentid'] == $accountid&&$tmpinfo['parentid'] != $tmpid){
            unset($accounts_list[$tmpid]);
        }
    }

	$accounts_list = $focus->__getChildAccounts($accountid, $accounts_list, $accounts_list[$accountid]['depth']);

	if(!empty($accounts_list)){
        //BUG20241009-35 客户管理，客户图谱，A-B-C，设置A的上级单位C；查看上下级关系界面打不开，一直转圈；
        foreach($accounts_list as $acc_id => $account_info){//闭环关系根节点的parentid修改为0，否则陷入死循环无法生成树结构
            if ($accounts_list[$acc_id]['parentid'] != 0){
                $accounts_list[$acc_id]['parentid'] = 0;
            }
            $root_depth = $accounts_list[$acc_id]['depth'];
            break;
        }

		foreach($accounts_list as $acc_id => $account_info){
			$depth_arr[] = $account_info['depth'];
			$depth_arr_length[$account_info['depth']][] = '';
		}
      
		$pos = array_search(max($depth_arr),$depth_arr);
		if($pos > 0){
			$depth_max = $depth_arr[$pos];
		}
		for($depth = 0; $depth <= $depth_max; $depth++){
			foreach($accounts_list as $acc_id => $account_info){
				if($account_info['depth'] == $depth){
					$data[] = array(
						'accountid' => $acc_id,
						'type' => 'account',
						'name' => $account_info['accountname'],
						'depth' => $account_info['depth'],
						'parentid' => $account_info['parentid'],
					);
				}
			}
		}
	}
    global $view_accounttree;

	$tree_data = getTree($data,$root_depth,$depth_max,$depth_arr_length);

	//@edit:liushuai,2020-08-18,reason:0042424/客户模块查看上下级关系，重复显示。
    end($tree_data);
    $tree_data = [key($tree_data)=>end($tree_data)];

	$treehtml .= $group_focus->setTreeList($tree_data,'','','selectaccount');

    $arr = [];
    $arr['content'] = $treehtml;
    $arr['groupuser'] = $accounts_list;
    //$arr['popup_inputtype'] = $isbox == 1 || $isbox == 'checkbox' ? 'checkbox':'radio';
    $arr['listdata'] = [array('label'=>getFixedLabel('DEPARTMENT'),'value'=>'group','list'=>$tree_data[array_keys($tree_data)[0]],'group_parent_key'=>array_keys($tree_data)[0])];
    ConvertTojsonString(1,$arr,"success");
}

function getTree($data,$i,$depth_max,$depth_arr_length){
    //edit:can 20200728 42122: （61mis.com/kfbcrm）客户模块>选择编号为“ACC1051”进入单据详情界面：相关“查看上下级关系”显示“3条”，点击进去只显示“一个”
	global $view_accounttree;
	$k = 1;
	foreach($data as $info){
		if($info['depth'] == $i){
			if($k <= count($depth_arr_length[$i])){
				$children = [];
				$contact_data = getAccountContact($info['accountid']);
              
				if(!empty($contact_data)){
					foreach($contact_data as $contactid => $concat_infos){
						$children['contacts_'.$contactid] = $concat_infos;
					}
				}
				$tree_data = getTree($data,$i+1,$depth_max,$depth_arr_length);
				if(!empty($tree_data)){
					foreach($tree_data as $key => $infos){
						if($infos['parentid'] == $info['accountid']){
							$children[$key] = $infos;
						}
					}
				}
				$info['children'] = $children;
			}

			if($info['children'] == null){
				unset($info['children']);             //如果子元素为空则unset()进行删除，说明已经到该分支的最后一个元素了（可选）
			}

			if(!empty($info)){
				
                
				$view_accounttree['accounts_'.$info['accountid']] = $info;
                
				
			}
			$k++;
		}
	}

	return $view_accounttree; 
}

//获取客户对应的联系人
function getAccountContact($accountid){
	global $adb;
	if(vtlib_isModuleActive('Contacts')){
	   //zkt 20230403 BUG0064048 已删除的联系人在“查看上下级关系”中仍有保留，须在回收站中把相关联系人也清除，“查看上下级关系”才能正常显示 
		$query = 'select lastname,department,title,contactid from ld_contactdetails where accountid = ? and deleted=0 ORDER BY contactid';
		$result = $adb->pquery($query,array($accountid));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 0){
			for($i = 0; $i < $num_rows; $i++){
				$descroption = array();
				$contactid = $adb->query_result($result,$i,'contactid');
				$last_name =  $adb->query_result($result,$i,'lastname');
				if($adb->query_result($result,$i,'department') != ''){
					$descroption[] = $adb->query_result($result,$i,'department');
				}
				if($adb->query_result($result,$i,'title') != ''){
					$descroption[] = $adb->query_result($result,$i,'title');
				}
				$data[$contactid]['type'] = 'Contacts';
				$data[$contactid]['name'] = $last_name . '&nbsp;&nbsp;&nbsp;&nbsp;<span style="color:#DADADA;font-size:12px;">' . implode('-',$descroption) . '</span>';
			}
		}
	}
	return $data;
}
?>