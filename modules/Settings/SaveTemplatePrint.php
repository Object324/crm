<?php
/**
 * 更新操作
 * date:20150817
 * edit：cyb
 * reason:保存模板定制分配人员
 * */
    global $adb;
    $owners=$_REQUEST['selectuser'];
    $allocatetype=$_REQUEST['allocatetype'];
	if($allocatetype == 'user'){
		$allocatetype = 2;
		$_REQUEST['radioUserValue'] = 2;
	}else if($allocatetype == 'group'){
		$allocatetype = 1;
		$_REQUEST['radioUserValue'] = 1;
	}else if($allocatetype == 'role'){
		$allocatetype = 3;
		$_REQUEST['radioUserValue'] = 3;
	}else{
		$allocatetype = 0;
		$_REQUEST['radioUserValue'] = 0;
	}
	 $_REQUEST['diony']='diony';
    if($owners == ''&&$_REQUEST['radioUserValue']=='1'){ //这边设定为选择到按部门时会提示错误，所以选择到所有用户时就可以执行下面的语句，就可以给id赋值为：‘-1’，默认为所有用户了。
        echo '##WrongGroup##' ;die;
    }  
    if($owners == ''&&$_REQUEST['radioUserValue']=='2'){ //这边设定为选择到部分用户时会提示错误，所以选择到所有用户时就可以执行下面的语句，就可以给id赋值为：‘-1’，默认为所有用户了。
        echo '##WrongSelectedUser##';die;
    }
    else{
        $templateprintid=$_REQUEST['templateprintid']; //获取打印模板ID
        $printtabid=$_REQUEST['printtabid']; //获取打印模块tabid
        $delsql="delete  from  ld_templateprint2user where templateprintid=?";
        $adb->pquery($delsql,array($templateprintid));
        $updatesql="update ld_templateprint SET allocatetype=? where templateprintid=?";
        $adb->pquery($updatesql,array($allocatetype,$templateprintid));
        if($_REQUEST['radioUserValue']=='0'){
            $sql='insert into ld_templateprint2user(templateprintid,userid)values(?,?)';
            $adb->pquery($sql,array($templateprintid,'-1'));
        }elseif($_REQUEST['radioUserValue']=='1'||$_REQUEST['radioUserValue']=='2'||$_REQUEST['radioUserValue']=='3'){
            $owners = explode(",",$owners);
            foreach($owners as $key=>$arr){
                $sql="insert into ld_templateprint2user(templateprintid,userid) values(?,?)";
                $adb->pquery($sql,array($templateprintid,$arr));                              
            }
        }
		ConvertTojsonString(1,array(),"success");
    }
?>