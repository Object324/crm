<?php
require_once globalStatic::$root_directory.'modules/Users/Group.class.php';
//crm_load_class_file("Group.class",'modules/Users');

global $theme,$currentModule,$current_user;
$group_focus = new Group();
//$_REQUEST['filterown'] = 'yes';
// Frank: 恢复隐藏部门flag
if(isset($_REQUEST['triggertype']) && $_REQUEST['triggertype']=="recover"){
    $group_focus->settrigger_type($_REQUEST['triggertype']);
}
$view = isset($_REQUEST['popup_scopetype'])?$_REQUEST['popup_scopetype']:'';
if($_REQUEST['popup_module'] == 'NOALLOCATEACCOUNTS'||$_REQUEST['popup_module'] == 'UnAssignedAccounts'){
	$_REQUEST['popup_module'] = 'Accounts';
}
$fld_module = isset($_REQUEST['popup_module'])?$_REQUEST['popup_module']:'yes';//模块
 
$filterown = isset($_REQUEST['filterown'])?$_REQUEST['filterown']:'';//是否过滤自己
$isbox = isset($_REQUEST['popup_inputtype'])?$_REQUEST['popup_inputtype']:1;//1 多选  2 单选
$selecttype = isset($_REQUEST['selecttype'])?$_REQUEST['selecttype']:'';	//选择类型
$ishighseaallocate=isset($_REQUEST['ishighseaallocate'])?$_REQUEST['ishighseaallocate']:'no';
$filterrecordid = $_REQUEST['filterrecordid'];//共享时，过滤当前单据的负责人(只控制单个单据)
$fieldname='';
if(isset($_REQUEST['fieldname']))
    $fieldname=$_REQUEST['fieldname'];
if(isset($_REQUEST['user_type']) && !empty($_REQUEST['user_type'])){
    $group_focus->setgroup_type($_REQUEST['user_type']);
}
$groupuser = $group_focus->getGroupListUser($fld_module,$view,$filterown,$selecttype,$ishighseaallocate,$filterrecordid,$fieldname);

$showallgroupstructure = 'yes';
//zkt 20231201 BUG0076127 	kfbcrm-服务合同，负责人字段设置了“根据模块数据范围权限控制”，成员“hxg（123）”数据范围是按部门，勾选单据分配时，弹出层中还是显示全部成员
$showallgroupstructurepopuptypearr = ['listselecthigher','Allocate'];
if(isset($_REQUEST['popup_type'])&&in_array($_REQUEST['popup_type'],$showallgroupstructurepopuptypearr)||$_REQUEST['ishighseaallocate']=='yes'){
    $group_focus->showallgroupstructure = 'no';
}
if(!empty($fieldname)){
    $focus = CRMEntity::getInstance($fld_module);
    if(!empty($focus->fieldobj)){
        $fieldinfo= $focus->fieldobj->getFieldInfoobjBykey('columnname',$fieldname);
        //if(!empty($fieldinfo)&&$fieldinfo->getshowallgroupstructure() == 'yes'&&$focus->fieldobj->is_user_field($fieldinfo->getUIType())){
        if(!empty($fieldinfo)&&!$fieldinfo->isshowallgroupstructure()){
            $group_focus->showallgroupstructure = 'no';
        }
    }
}
$groupuserarray = $group_focus->setOneParent($groupuser);

$groups = $group_focus->getGrouplist();


//多维数组组装成ul->li格式
//isset($groupuserarray[$group_focus->group_parent_key]['children'])
if(isset($groups)){
	$array[$group_focus->group_parent_key] = $groupuserarray[$group_focus->group_parent_key];

    if($selecttype=='group')
    {
        $treehtml = $group_focus->setTreeList($array,$isbox,'','parentgroup');
     
    }
    else
    {
	
        /*if('Allocate' == $_REQUEST['popup_type']){
			 $systems_deploy=getSys_deploy(110);//分配弹出层是否显示所有用户 0是 1否
			 if($systems_deploy['deploy_value'] == 0){
				$view = 'all';
			 }
		}*/
        
       	$view = 'all';
        if($_REQUEST['popup_type']=='listselecthigher')
        {
            $view='';
        }
        if($current_user->is_admin == 'on' || $_REQUEST['popup_module'] == 'Home' || (!empty($_REQUEST['popup_module']) && $_REQUEST['popup_module'] == 'CooperativeWork')){
            $view = 'all';
		}
        if(!empty($view)){
                $treehtml = $group_focus->setTreeList($array,$isbox,'','parentgroup');
        }else{
            
                $keys=array_keys($array);
                global $retgroupusers;
            
                //30515: 查看范围：高级弹出层，仅显示有权限看到人员的部门，若没权限看到的用户，则不显示部门组织架构
                getgrouphaveUsers($array[$keys[0]],$keys[0]);
            
                $tmpusers[$keys[0]]['type']=$array[$keys[0]]['type'];
                $tmpusers[$keys[0]]['name'] =$array[$keys[0]]['name'];
                //zkt 20230919 BUG0072955  	V8.6.0.6--销售360--成员管理--数据范围--不显示公司名
                $tmpusers[$keys[0]]['groupid'] =$array[$keys[0]]['groupid'];
                $tmpusers[$keys[0]]['parentid'] =$array[$keys[0]]['parentid'];
                $tmpusers[$keys[0]]['parentgroup'] =$array[$keys[0]]['parentgroup'];
                $tmpusers[$keys[0]]['children']=$retgroupusers;
            
                $treehtml = $group_focus->setTreeList($tmpusers,$isbox,'','parentgroup');
        }

    	
    }
    
    //18176: 所有模块>列表：高级弹出层显示空白。
	//$treehtml = sprintf($treehtml,'viewuserlist');//添加ID值
	//角色权限显示
	if(isset($_REQUEST['selectprofileuser']) && $_REQUEST['selectprofileuser'] == 'yes'){
		$profileArray = getAllProfile();
      
		$treehtml .= $group_focus->setTreeList($profileArray,$isbox,'','selectprofileuser');	
	}
	//echo $treehtml;die;
    $contenthtml = $treehtml;
}else{
	//echo getFixedLabel('LBL_NOTGROUPINFO');die;
    $contenthtml = getFixedLabel('LBL_NOTGROUPINFO');
}
$arr = [];
$arr['content'] = $contenthtml;
$arr['groupuser'] = $groupuser;
$arr['popup_inputtype'] = $isbox == 1 || $isbox == 'checkbox' ? 'checkbox':'radio';

$haduserlist = [];
$userlist = [];
foreach ($groupuser as $itemid => $iteminfo){
    if($iteminfo['type'] == 'user' && !in_array($iteminfo['groupid'],$haduserlist)){
        $userlist[$itemid] = $iteminfo;
        $haduserlist[] = $iteminfo['groupid'];
    }
}

if(count($userlist) > 0){
    $arr['listdata'] = [array('label'=>getFixedLabel('USER'),'value'=>'user','list'=>$userlist),array('label'=>getFixedLabel('DEPARTMENT'),'value'=>'group','list'=>$groupuserarray[$group_focus->group_parent_key],'group_parent_key'=>$group_focus->group_parent_key)];
}
else{
    $arr['listdata'] = [array('label'=>getFixedLabel('DEPARTMENT'),'value'=>'group','list'=>$groupuserarray[$group_focus->group_parent_key],'group_parent_key'=>$group_focus->group_parent_key)];
}

ConvertTojsonString(1,$arr,"success");
//获取所有的权限，并且按树形结构数组结构存储
function getAllProfile(){
	$profile_focus = new Profile();
	$allProfile = $profile_focus->getProfileArray();
	if(!empty($allProfile)){
		$profileArray['profile']['name'] = '所有角色';
		foreach($allProfile as $profileid => $profilename){
			$profileArray['profile']['children']['profile_'.$profileid]['name'] = $profilename;
		}
		return $profileArray;
	}
	return '';
}
/**
 * 获取有用户的部门getgrouphaveUsers
 * 30515: 查看范围：高级弹出层，仅显示有权限看到人员的部门，若没权限看到的用户，则不显示部门组织架构
 * */
 function getgrouphaveUsers($tmp,$parentkey)
 {
  global $retgroupusers,$array;

     if(!array_key_exists("children",$tmp))
     {
      
        return 'no';
     }
     
    foreach($tmp['children'] as  $key=>$groupinfo )
    {
       
        if(stripos($key,'group_')!==false)
        {
          
            $str= getgrouphaveUsers($groupinfo,$parentkey."##".$key);
        }
        else if(stripos($key,'user_')!==false)
        {
             $keys=explode('##',$parentkey);
          
             if(sizeof($keys)>0&&$keys[1]!='')//最顶层的部门去除
             {
                
                $retgroupusers[$keys[1]]=$array[$keys[0]]['children'][$keys[1]];
               
             }
             else{
                //edit:can 20210706 46738: （https://81mis.com/kfbcrm/ [^]）成员数据范围设置按成员“测试001、测试002、测试003”，客户列表界面，查看范围选择高级界面仅显示“测试001”，没有显示其他成员
                //跟部门下的用户无法显示
                  foreach($array[$keys[0]]['children'] as $tmpkey=>$tmpinfo)
                  {
                        if(stripos($key,'user_')!==false)
                        {
                            $retgroupusers[$tmpkey]=$tmpinfo;
                        }
                        else{
                            break;
                        }
                        
                  }
                    
             }

            $str= 'yes';
           
        }
    }
    
    return $str;
 }
 
?>