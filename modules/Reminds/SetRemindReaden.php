<?php
//@edit:zkt @date:2024/12/19 @reason: url验证
$cls_UrlEncryptyJudgeobj = cls_UrlEncryptyJudge::getInstance();
$cls_UrlEncryptyJudgeobj->LingdangUrlencryptJudge();
/**
 * edit:limengxing
 * date:20140212
 * reason:温馨提醒改进
 * other:修改状态为已读/和更新提醒时间/上一篇下一篇
 * */
  global $adb, $current_user;
  $request_remindsid = $_REQUEST['remindsid']??'';
  $request_remindtime = $_REQUEST['remindtime']??'';
  if(isset($_REQUEST['types'])&&$_REQUEST['types']=='update_state')
  {
	//chj 2021/5/19 45989: （61mis.com/kfbcrm）公告消息阅读；公告消息接收人点击消息弹窗或消息浮显已读时，阅读记录不显示阅读时间
      $sql="update ld_reminds set status_rmd='已读',readedtime = now() where remindsid=?";
      $adb->pquery($sql,array($request_remindsid));
      $sql="update ld_reminds_accepted set status_rmd='已读',readedtime = now() where remindsid=?";
      $adb->pquery($sql,array($request_remindsid));
  }
  else if(!empty($request_remindtime)){
        switch ($request_remindtime)
        {
            case 5:
            $date_time=date('Y-m-d H:i:s',time()+5*60);
            if($request_remindtime=='5D'){//Liver 20170110,bug0026998: 提醒：对当前弹出的温馨提醒推迟5天，结果提醒的时间没有变
                $date_time=date('Y-m-d H:i:s',time()+5*24*3600);
            }
            break;  
            case 10:
            $date_time=date('Y-m-d H:i:s',time()+10*60);
            break;
            case 15:
            $date_time=date('Y-m-d H:i:s',time()+15*60);
            break;
            case 30:
            $date_time=date('Y-m-d H:i:s',time()+30*60);
            break;
            case '1H':
            $date_time=date('Y-m-d H:i:s',time()+3600);
            break;
            case '2H':
            $date_time=date('Y-m-d H:i:s',time()+2*3600);
            break;
            case '4H':
            $date_time=date('Y-m-d H:i:s',time()+4*3600);
            break;
            case '8H':
            $date_time=date('Y-m-d H:i:s',time()+8*3600);
            break;
            case '1D':
            $date_time=date('Y-m-d H:i:s',time()+24*3600);
            break;
            case '2D':
            $date_time=date('Y-m-d H:i:s',time()+2*24*3600);
            break;
            case '3D':
            $date_time=date('Y-m-d H:i:s',time()+3*24*3600);
            break;
            //case '5D':
            //$date_time=date('Y-m-d H:i:s',time()+5*24*3600);
            //break;
        } 

        $sql="update ld_reminds set date_time=? where  remindsid=?";
        $adb->pquery($sql,array($date_time,$request_remindsid));
        $sql="update ld_reminds_accepted set date_time=? where  remindsid=?";
        $adb->pquery($sql,array($date_time,$request_remindsid));
        
  }
  //消息提醒
	if(!empty($_REQUEST['getRemindsContent']) && $_REQUEST['getRemindsContent'] == 'yes'){
		$smarty = new lingdangCRM_Smarty();
		require_once(globalStatic::$root_directory.'modules/Reminds/static_reminds.php');
		$_REQUEST['diony']='yes';
        $smarty->assign('REMINDSCOUNT',static_Reminds::getRemindsCount());
		$smarty->assign('REMINDSINFO',static_Reminds::getRemindsContent());
		$str=$smarty->fetch("RemindContents.tpl");
		$arr['content'] = $str;
        $arr['remindscount'] = static_Reminds::getRemindsCount();
		ConvertTojsonString(1,$arr,'success');
	}else{
		include('modules/Reminds/RemindsPopup.php');
		exit();
	}



?>