<?php
/**
 * edit:kevin
 * date:2013-07-15
 * reason:公海客户设置保存
 */ 

 global $adb,$default_charset;
 if(isset($_REQUEST['return_module']) && $_REQUEST['return_module']!=''){
    $return_module=$_REQUEST['return_module'];
 }
 if(isset($_REQUEST['return_action']) && $_REQUEST['return_action']!=''){
    $return_action=$_REQUEST['return_action'];
 }
 if(isset($_REQUEST['isset']) && $_REQUEST['isset']!=''){
    $iset=$_REQUEST['isset'];
 }
 if(isset($_REQUEST['astricttype']) && $_REQUEST['astricttype']!=''){
    $astricttype=$_REQUEST['astricttype'];
 }
 $dataProfile=1;
 if(isset($_REQUEST['dataProfile']))
 {
    $dataProfile=$_REQUEST['dataProfile'];
 }
 
 $getProfile=1;
 if(isset($_REQUEST['getProfile']))
 {
    $getProfile=$_REQUEST['getProfile'];
 }
 $wheathershow=1;
 if(isset($_REQUEST['wheathershow']))
 {
    $wheathershow=$_REQUEST['wheathershow'];
 }
 $userid='';
 if(isset($_REQUEST['userid']))
 {
    $userid=$_REQUEST['userid'];
 }
 $allotuserid = '';
 if(isset($_REQUEST['allotuserid']))
 {
    $allotuserid=$_REQUEST['allotuserid'];
 }
 $publicaccount = 0;
 if(isset($_REQUEST['publicaccount'])){
	$publicaccount = $_REQUEST['publicaccount'];
 }
 $beforereminddays=$_REQUEST['beforereminddays'];
 if(!is_numeric($beforereminddays))
 {
    $beforereminddays="";
 }
$days=$_REQUEST['days'];
$bills=$_REQUEST['bills'];
$count=$_REQUEST['count'];
if(isset($_REQUEST['selectedcolumnsforadmin']) && $_REQUEST['selectedcolumnsforadmin']!=''){
	$adminaccount=$_REQUEST['selectedcolumnsforadmin'];         
//	$adminaccount=mb_substr($adminaccount,0,strlen($adminaccount)-1,$default_charset);       
}

 $usersaccount_type = $_REQUEST['customscope_type'];
 $usersaccount = $_REQUEST['customscope_ids'];
 if(!$iset){
    $query="update ld_field set presence=0 where tabid=6 and columnname in('publicaccount','allocatedate','protectdate','completed') ";
    $adb->query($query);
 }
 else{
    //更新公海客户为普通客户
    $query="update ld_account set publicaccount=0,protectdate=null,allocatedate=null,modifiedtime=now()
    where publicaccount>=1";
    $days='';
    
    $adb->query($query);
    $query="update ld_field set presence=1 where tabid=6 and columnname in('publicaccount','allocatedate','protectdate') ";
    $adb->query($query);
 }

$newdropdownoption=$_REQUEST['m_newdropdownoption'];//yyx 2015-4-21 获取序时簿“新建”功能下拉按钮选项中选中的值
 $query="select * from ld_account_set";
 $result=$adb->query($query);
 $num_rows=$adb->num_rows($result);
 if($astricttype==2){
     $count = $adb->query_result($result,0,'count');
 }

 if($_REQUEST['normalconvertbuttonprofile']=='on'||$_REQUEST['normalconvertbuttonprofile']=='1')
 {
    $normalconvertbuttonprofile='yes';
 }
 else
 {
    $normalconvertbuttonprofile='no';
 }
if($count==''){
    $count=0;
}
$objtainaccountcontroldays=$_REQUEST['objtainaccountcontroldays'];//客户被自动回收后     天内不允许被当前负责人再次领取（为0或空表示不控制）
 if(!$num_rows){
    $query="insert into ld_account_set(status,days,bills,count,adminaccount,usersaccount,usersaccount_type,dataprofile,getprofile,wheathershow
                ,userid,astricttype,allotaccount,buttontype,publicaccount,beforereminddays,normalconvertbuttonprofile,objtainaccountcontroldays)
    value(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    $adb->pquery($query,array($iset,$days,$bills,$count,$adminaccount,$usersaccount,$usersaccount_type,$dataProfile,$getProfile,$wheathershow,$userid,$astricttype
            ,$allotuserid,implode(',',$newdropdownoption),$publicaccount,$beforereminddays,$normalconvertbuttonprofile,$objtainaccountcontroldays));
 }
 else{
    $query="update ld_account_set set status=?,days=?,bills=?,count=?,adminaccount=?,usersaccount=?,usersaccount_type=?,dataProfile=?,getProfile=?,wheathershow=?
                ,userid=?,astricttype=?,allotaccount=?,buttontype=?,publicaccount=?
                ,beforereminddays=?,normalconvertbuttonprofile=?,objtainaccountcontroldays=?";
    $adb->pquery($query,array($iset,$days,$bills,$count,$adminaccount,$usersaccount,$usersaccount_type
        ,$dataProfile,$getProfile,$wheathershow,$userid,$astricttype,$allotuserid,implode(',',$newdropdownoption)
        ,$publicaccount,$beforereminddays,$normalconvertbuttonprofile,$objtainaccountcontroldays));
 } //yyx 2015-4-21 在原sql语句中添加buttontype字段，将$newdropdownoption插入或更新到buttontype字段中
 getAccount_Set('aa');//重新生成缓存文件
 
 $sql="select * from ld_account_set_rule order by type desc ";

$result=$adb->pquery($sql,array());
$rows=$adb->num_rows($result);

for($i=0;$i<$rows;$i++)
{
    
    $tabname=$adb->query_result($result,$i,'tabname');
    $type=$adb->query_result($result,$i,'type');
    if($type=='nocomplete' or $type=='singlenormal')
        continue;
        
    $condition=$_REQUEST[$type.'opt'];
    $days=$_REQUEST[$tabname."_".$type."days"];
  
    $status=$_REQUEST[$tabname."_".$type."chk"];
    if($status=='on')
    {
        $status='active';
    }
    else
    {
        $status='inactive';
    }
     $iscycle=$_REQUEST['changerule_'.$type.'_'.$tabname];
    if($iscycle=='no')
    {
        $days=$_REQUEST[$tabname."_single_".$type."days"];
    }
    $sql="update ld_account_set_rule set status=?,days=?,`condition`=?,iscycle=?  where type=? and tabname=?";
   
    $adb->pquery($sql,array($status,$days,$condition,$iscycle,$type,$tabname));
    
}

if($_REQUEST['normaloptionrecycle']=='singlenormal')
{
          $sql="update ld_account_set_rule set status=? where  type=?";
          $adb->pquery($sql,array('inactive','normal'));
}
else
{
          $sql="update ld_account_set_rule set status=? where  type=?";
          $adb->pquery($sql,array('inactive','singlenormal'));
}
$sql="update ld_sys_event set eventdate=? where type='publicaccount'";
$adb->pquery($sql,array('1600-01-01'));
$sql="delete from ld_account_set_advfilter "; 
$adb->pquery($sql,array());
$sql="delete from ld_account_set_advfilter_grouping "; 
$adb->pquery($sql,array());
//提醒高级条件 start
$columlist = array();
$tmpk=0;
$advfilterlist=json_decode($_REQUEST['account_set_advft_criteria'],true);
$advfiltergroup=json_decode($_REQUEST['account_set_advft_criteria_groups'],true);


/*
for($i = 0; $i<100;$i++)
{
    //为空值的修改
    if($_REQUEST['fcol' . $i] != '' && $_REQUEST['fop' . $i] != '' )
    {
        $columlist[$tmpk] = array(
            'index'=>$tmpk+1,
            'fcol' =>$_REQUEST['fcol' . $i],
            'fop' =>$_REQUEST['fop' . $i],
            'fval' =>$_REQUEST['fval' . $i],
            'fcon' =>$_REQUEST['fcon' . $i],
        );
        $tmpk++;
    }
}*/


//提醒高级条件设置保存

        $index=1;
        for($i=0;$i<count($advfilterlist);$i++)
        {
                $sql="INSERT INTO ld_account_set_advfilter (groupid,columnindex,columnname,comparator,value,column_condition) VALUES(?,?,?,?,?,?)"; 
                //$columname=explode(':',$columlist[$i]['fcol']);
               $groupid= $advfilterlist[$i]['groupid'];
                if($advfilterlist[$i]['columnname']=='')
                {
                    continue;
                }
                $params=array(
                    $advfilterlist[$i]['groupid'],
                    $index++,
                    $advfilterlist[$i]['columnname'],
                    $advfilterlist[$i]['comparator'],
                    $advfilterlist[$i]['value'],
                    $advfilterlist[$i]['columncondition']
                    
                );
                $adb->pquery($sql,$params);
        }
        
        
       foreach($advfiltergroup as $groupid=>$groupinfo)
      {
        
      

        if(!array_key_exists('groupcondition',$groupinfo))
        {
            continue;
        }
          $sql='insert into ld_account_set_advfilter_grouping(groupid,group_condition,condition_expression)
        value(?,?,?)';
        
      
        $adb->pquery($sql,array($groupid,$groupinfo['groupcondition'],$groupid-1));
      }
        


crm_load_class_file("AccountSetCustomView",'modules/Accounts/AccountSet');
crm_load_class_file("AccountSetProductDetails",'modules/Accounts/AccountSet');
$AccountSetCustomView=new AccountSetCustomView();
$AccountSetProductDetails=new AccountSetProductDetails();
crm_load_class_file("AccountsQueryGenerator",'include/QueryGenerator');
crm_load_class_file("AccountsSetQueryGenerator",'modules/Accounts/AccountSet');
if(count($advfilterlist)>0)
{
    $queryGenerator =new AccountsSetQueryGenerator('Accounts', $current_user,$AccountSetCustomView,$AccountSetProductDetails);
    $queryGenerator->initForDefaultCustomView();
    $query= $queryGenerator->getQuery();

    $queryGenerator->getWhereClause();
    $queryGenerator->getFromClause();
}
else
{
    $query='';
}


$sql=' update ld_account_set set recycleselect=?';
$adb->pquery($sql,array($query));
unsetCache('account_set');
f_sockopen('modules.Cache.unsetCache','ajax=true');
$_REQUEST['diony']='diony';
ConvertTojsonString(1,array(),"success");
?>