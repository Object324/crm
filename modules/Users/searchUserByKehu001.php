<?php
/*
global $current_user;

$fieldinfo=$current_user->fieldobj->getFieldInfoobjBykey("columnname",$lastname);
$conditionInfo=array();
$conditionInfo['name']='last_name';
$conditionInfo['test']='last_name';
crm_load_class_file('cls_where_user','include/QueryGenerator/SqlWhere/NormalWhere'); 
$whereobj=new cls_where_user('Users',$field,$conditionInfo,$current_user,$valueSql,$this);
$whereobj->setAsTablename('ld_users');
$whereobj->getWhereCondition();
$fieldSql.= $fieldGlue.$whereobj->fieldSql;*/

global $adb;
if($_REQUEST['iskehu001']=='yes')
{
    crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
    $port_obj = new cls_WeixinPort();//Eidtor:gyq_63 Reason:�ӿ�֧�ֶ�Ӧ�ù��� Date:2018/3/2 0002 ���� 1:21
    $wx_userarr =$port_obj->getwxUserid('like',$_REQUEST['searchvalue']);  
    global $adb;
    if(array_key_exists('userid',$wx_userarr))
    {
            $wx_userid=implode("','",$wx_userarr['userid']);
            $wx_userid="'".$wx_userid."'";
            $sql='select group_concat(id) as id from ld_users where wx_userid in( '.$wx_userid.') ';
            
            $result=$adb->pquery($sql,array());
            $arr=explode(",",$adb->query_result($result,0,0));
      }
      else
      {
        $arr=array();
      } 
}
else{
     //230505 wyt BUG0065830 选择成员字段无法检索模糊查找 原因:客户服务器没有中文环境，导致转换为大写后乱码。用mb_strtoupper替代。
     //$searchValue=strtoupper($_REQUEST['searchvalue']);
     $searchValue=mb_strtoupper($_REQUEST['searchvalue']);
     $sql=" select group_concat(id) as id from ld_users where  last_name like  '%$searchValue%' or getPY(last_name) like '%$searchValue%'";
     $result=$adb->pquery($sql,array());
     $contactid_str = $adb->query_result($result,0,0);
     if($contactid_str != ""){
        $arr=explode(",",$adb->query_result($result,0,0));
     }else{
        $arr = array();
     }
}
   $_REQUEST['diony']='yes';
   ConvertTojsonString(1,array('list'=>$arr),'successs');            
?>