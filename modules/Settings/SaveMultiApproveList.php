<?php
/**
 * 更新操作
 * date:20151211
 * edit：cyb
 * reason:保存审批流程管理分配方式。
 * */
    global $adb;
    $owners=$_REQUEST['selectallocateid'];
/**
 *parameter:approveallocatetype --0表示所有用户，1表示按部门分配，2表示按用户分配.
 **/
/* editor:gyq_14 reason:统一radioTypeValue和allocatetype date:20160715*/
    $approveallocatetype=$_REQUEST['radioTypeValue'];
    if($owners == ''&&$_REQUEST['radioTypeValue']=='1'){ //这边设定为选择到按部门时会提示错误，所以选择到所有用户时就可以执行下面的语句，就可以给id赋值为：‘-1’，默认为所有用户了。
        echo '##WrongGroup##' ;die;
    }  
    if($owners == ''&&$_REQUEST['radioTypeValue']=='2'){ //这边设定为选择到部分用户时会提示错误，所以选择到所有用户时就可以执行下面的语句，就可以给id赋值为：‘-1’，默认为所有用户了。
        echo '##WrongSelectedUser##';die;
    }
    else{
        $approveid=$_REQUEST['approveid']; //获取打印模板ID
        $approvetabid=$_REQUEST['approvetabid']; //获取打印模块tabid
        $delsql="delete  from  ld_approve2user where approveid=?";
        $adb->pquery($delsql,array($approveid));
        $updatesql="update ld_approve SET approveallocatetype=? where id=?";        
        $adb->pquery($updatesql,array($approveallocatetype,$approveid));
        if($_REQUEST['radioTypeValue']=='0'){
            $sql='insert into ld_approve2user(approveid,userid)values(?,?)';
            $adb->pquery($sql,array($approveid,'-1'));
        }elseif($_REQUEST['radioTypeValue']=='1'||$_REQUEST['radioTypeValue']=='2'){
            $owners = explode(",",$owners);
            foreach($owners as $key=>$arr){
                $sql="insert into ld_approve2user(approveid,userid) values(?,?)";
                $adb->pquery($sql,array($approveid,$arr));                              
            }
        }elseif($_REQUEST['radioTypeValue']=='1'||$_REQUEST['radioTypeValue']=='3'){
            $owners = explode(",",$owners);
            foreach($owners as $key=>$arr){
                $sql="insert into ld_approve2user(approveid,userid) values(?,?)";
                $adb->pquery($sql,array($approveid,$arr));                              
            }
        }
		$_REQUEST['diony']='yes';
        ConvertTojsonString(1,array(),"success");
    }
?>