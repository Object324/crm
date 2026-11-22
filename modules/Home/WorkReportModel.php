<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @author Tujt
 */
//include(globalStatic::$root_directory."include/RecordEncrypt.php");
crm_load_class_file('RecordEncrypt','include');
class WorkReportModel {
    public $workreportremind_sql='insert into ld_workreport_remind(relatedtable,remindtype,relatedto,userid,createdtime,content,operationtype)value(?,?,?,?,?,?,?)';
    public $remind_sql='insert into ld_reminds(remindsid,reltab,remindstype,wxremindstype,related_to,recieverid,smcreatorid,
smownerid,status_rmd,date_time,createdtime,modifiedtime,content,modifiedby,
push_to_weixin,push_to_ding,push_to_yzj,push_to_wxselfbuilt,push_to_offiaccount,push_to_fw,push_to_nativeapp) 
value (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
	private $workcffld = array();
	private $workcffldarr = array();
    private $worksignldarr = array();
    private $filesnamelist = array();
    private $cookie_link = array();
    private $fldnamearr = array();
    protected  $plateform;//移动端还是pc端 不想用weixin_user;

    private $worktype;

    private $users_combo = array();
	/**
	 * 构造函数
	 * @author Tujt 2015-02-02
	 */
	public function __construct() {
		   $this->plateform='pc';

	}

    function getReaderList(){
        $wokreportid=$_REQUEST['workreportid'];
    }

    /**
	 * 获取用户所有数据
	 * @author Tujt 2015-02-02
	 */
	public function getUserInfo() {
		global $current_user;
		$assigned_user_id = $current_user->id;
		$userarray = $this->getUserArray();
		foreach($userarray as $userinfo){
			if($userinfo['status']['value'] == 'Active'){
				$this->users_combo[] = $userinfo;
			}
		}
		return $this->users_combo;
	}

     /**
      * edit:can
      * reason:获取工作提醒的总数量
      * */
    public function getWorkRemindsCount(){
        global $adb,$current_user;
        /*$approvecount=0;
        $replycount=0;
        $AtWorkcount=0;
        $Atreplycount=0;
        $myLaunchcount=0;
        $mypraisecount=0;*/
        $sql='select  count(id) from ld_workreport_remind  where userid=? and remind_status=0 and relatedto>0  group by userid ';
        $result=$adb->pquery($sql,array($current_user->id));
        $workreminds['total']=0;
        //$workreminds['content']='';
        //$workreminds['createdtime']='';
        if($adb->query_result($result,0,0)>0){
            $workreminds['total']=$adb->query_result($result,0,0);
            /*
            $sql='select createdtime,content from ld_workreport_remind where userid=?  and remind_status=0 order by createdtime desc limit 1';
            $result=$adb->pquery($sql,array($current_user->id));
            $content=$adb->query_result($result,$i,'content');
            $createdtime=$adb->query_result($result,$i,'createdtime');
            $strlen=mb_strlen($content,'utf8');
            if($strlen<20){
                $workreminds['content']=$content;
            }
            else{
                $workreminds['content']=mb_substr($content,0,20,'utf-8').'....';
            }
            $workreminds['createdtime']=$this->getDateDescription($createdtime);
            */
        }
        return $workreminds;
    }
    /**
     * edit:can
     * reason:获取工作提醒相关数量
     * */
    public function getWorkRemindsDetailCount(){
        global $adb,$current_user;
        $approvecount=0;
        $replycount=0;
        $AtWorkcount=0;
        $Atreplycount=0;
        $myLaunchcount=0;
        $mypraisecount=0;
        $sql='select remindtype,operationtype,relatedtable,relatedto from ld_workreport_remind  where userid=? and remind_status=0  and relatedto>0';
        $result=$adb->pquery($sql,array($current_user->id));
        $noo_frows=$adb->num_rows($result);
        $content='';
        $createdtime='';
        for($i=0;$i<$noo_frows;$i++){
            $remindtype=$adb->query_result($result,$i,'remindtype');
            switch($remindtype)//提醒类别:1：待处理,2:我发出工作的回复,3:@我的工作,4:@我的回复,5：我发出的工作，6：我收到的赞
            {
                case "1":
                    $approvecount++;
                    break;
                case "2":
                    $replycount++;
                    break;
                case "3":
                    $AtWorkcount++;
                    break;
                case "4":
                    $Atreplycount++;
                    break;
                case "5":
                    $myLaunchcount++;
                    break;
                case "6":
                    $mypraisecount++;
                    break;
            }
        }
        /**待处理***/
        $workreminds['approvecount']=$approvecount;
        /***我发出工作的回复*****/
        $workreminds['replycount']=$replycount;
        /***@我的工作*****/
        $workreminds['atworkcount']=$AtWorkcount;
        /***@我的回复****/
        $workreminds['atreplycount']=$Atreplycount;
        /***我发起的工作***/
        $workreminds['mylaunchcount']=$myLaunchcount;
        /****我收到的赞******/
        $workreminds['mypraisecount']=$mypraisecount;

        $workreminds['approveicon']=1;//表示有提醒数量
        if(empty($approvecount))//如果提醒的待处理数量为零
        {
            $workreminds['approvecount']=$this->getprocessingCount();
            $workreminds['approveicon']=0;//表示没有提醒数量
        }
        return $workreminds;
    }

   /**
    * edit:can
    * reason:获取待处理数量
    * */
   protected function getprocessingCount()
   {
     global $adb,$current_user;
     $sql="select count(ld_workreport.workreportid) from ld_workreport 
                left join ld_workreport2user on ld_workreport.workreportid = ld_workreport2user.workreportid
                where (
		(
			(
				ld_workreport.entitytype = 'weibo'
			)
			AND ld_workreport.type = 1
		)
		OR (
			ld_workreport.entitytype = 'workreport'
			AND ld_workreport.type = 1
		)
		OR (
			ld_workreport.entitytype = 'workreport'
			AND ld_workreport.type = 2
		)
		OR (
			ld_workreport.entitytype = 'workreport'
			AND ld_workreport.type = 3
		)
		OR (
			ld_workreport.entitytype = 'cocmd'
			AND ld_workreport.type = 1
		)
	) and ld_workreport.approved=0 and ld_workreport.entitytype in ('workreport','cocmd','approve') 
                and ld_workreport2user.userid = ? and ld_workreport2user.user_type in (5,6,7)";//获取待处理的数量
     $processedresult=$adb->pquery($sql,array($current_user->id));
     if($adb->num_rows($processedresult)>0)
        return $adb->query_result($processedresult,0,0);
      else
        return 0;
   }
    /**
     * edit:can
     * reason:获取报告的相关用户列表
     * */
    public function getReportUserList()
    {
        global $adb,$current_user;
		 $workreportid=$_REQUEST['workreportid'];
		//判断是否选择了所有同事
		$query = 'select 1 from ld_workreport2user where workreportid = ? and userid  = ?';
		$result = $adb->pquery($query,array($workreportid,"-1"));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
			$alluser = $this->getUserInfo();
			if(!empty($alluser)){
				foreach($alluser as $userid => $userinfo){
					$entityContent['list'][]=array('userimage'=>$userinfo['userimgpath']['value'],'curid'=>$userid,'username'=>$userinfo['lastname']['value'],'profilename'=>$userinfo['profilename']['value'],
						'userlevel'=>$userid,'userlevel'=>$userinfo['userlevel']['value']);
				}
				 $entityContent['usercount']=count($alluser);
			}
		}else{
			$sql="select DISTINCT ld_salesmanattachmentsrel.attachmentsid ,ld_users.last_name ,ld_users.wx_userid ,ld_users.userlevel,
                path,ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
                ld_users.id,ld_profile.profilename 
                from ld_workreport
                left join ld_workreport2user on ld_workreport.workreportid=ld_workreport2user.workreportid
                left join ld_users on ld_users.id=ld_workreport2user.userid 
                left join ld_profile on ld_profile.profileid = ld_users.profileid 
                left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
               left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid 
               where ld_workreport.workreportid=? and ld_users.id != '' and ld_users.id != ld_workreport.smcreatorid";
			//0018089: （刘总建议）首页>工作协同：点击查看“3个同事”，弹出框中显示了当前用户。修改为不显示当前用户。
		  $result=$adb->pquery($sql,array($workreportid));
		  for($i=0;$i<$adb->num_rows($result);$i++){
			  $attachmentsid=$adb->query_result($result,$i,'attachmentsid');
			  $path=$adb->query_result($result,$i,'path');
			  $userimagename=$adb->query_result($result,$i,'userimagename');
			  $userid=$adb->query_result($result,$i,'id');
        $storage_location=$adb->query_result($result,$i,'storage_location');
        if($storage_location == 'cos'){
          $userfilepath=$adb->query_result($result,$i,'cloud_path');
        }
        else{
          $userfilepath=$this->getUserImage($path,$userimagename,$attachmentsid,$userid);
        }
			  $profilename = $adb->query_result($result,$i,'profilename');
        if($profilename==null){
          $profilename = '';
        }
        $userlevel = $adb->query_result($result,$i,'userlevel');
        if($userlevel==null){
          $userlevel = '';
        }

        $last_name=$adb->query_result($result,$i,'last_name');
        $wx_userid=$adb->query_result($result,$i,'wx_userid');
        $userobj=new Users();
        $userobj->wx_userid=$wx_userid;
        $userobj->last_name=$last_name;
		    $entityContent['list'][]=array('userimage'=>$userfilepath,'curid'=>$adb->query_result($result,$i,'id'),'username'=>getUserlastName($userobj),'profilename'=>$profilename,'userlevel'=>$userlevel);
		  }
		  $entityContent['usercount']=$adb->num_rows($result);
		}
       return $entityContent;
    }
    /**
     * edit:diony
     * reason:获取即将新增加的相关用户列表
     * */
    public function getNewReportUserList()
    {
        global $adb;
        $workreportid=$_REQUEST['workreportid'];
        $newusernames=$_REQUEST['newusernames'];
        if(empty($newusernames))
        {
            return '';
        }
        $sql='select DISTINCT ld_salesmanattachmentsrel.attachmentsid ,ld_users.last_name ,
                path,ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,ld_users.id
                from ld_workreport
                left join ld_workreport2user on ld_workreport.workreportid=ld_workreport2user.workreportid
                left join ld_users on ld_users.id=ld_workreport2user.userid
                left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
               left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid 
               where ld_workreport.workreportid=? ';
       $result=$adb->pquery($sql,array($workreportid));
       $oldArr = array();
       for($i=0;$i<$adb->num_rows($result);$i++)
       {
          $attachmentsid=$adb->query_result($result,$i,'attachmentsid');
          $path=$adb->query_result($result,$i,'path');
          $userimagename=$adb->query_result($result,$i,'userimagename');
          $storage_location=$adb->query_result($result,$i,'storage_location');
          $userid=$adb->query_result($result,$i,'id');
          if($storage_location == 'cos'){
            $userfilepath=$adb->query_result($result,$i,'cloud_path');
          }
          else{
            $userfilepath=$this->getUserImage($path,$userimagename,$attachmentsid,$userid);
          }
          $last_name = $adb->query_result($result,$i,'last_name');
          $oldArr[$last_name] = 1;
       }
       $newusernames = trim($newusernames,',');
       $newArr = explode(',',$newusernames);
       $userarr = array();
       foreach ($newArr as $key => $value) {
           //直接点击回复时，文本框中会添加:，需要去掉该字符
           $value = trim($value);
           $value = trim($value,':');
           if(!isset($oldArr[$value])){
               $userarr[] = $value;
           }
       }
       $entityContent = array();
       if(!empty($userarr)){
          foreach ($userarr as $key => $value) {
              $userid = $this->getExistsUserName($value);
              if($userid > 0){
                  $entityContent['list'][]=array('userid'=>$userid,'username'=>$value);
              }
          }
       }
       return $entityContent;
    }
    /**
     * edit:can
     * reason:获取用户头像路径
    **/
    function getUserImage($path,$userimagename,$attachmentsid,$userid){
      if(!empty($attachmentsid)&&!empty($path)){
        $userfilepath=$path.$userimagename;
      }
      else{
          // ljj 20231201 XUQIU1000927 更换默认头像
          $userfilepath=getDefaultAvatar($userid);
      }
      $userfilepath_True = globalStatic::$root_directory.$userfilepath;//gyq date:20170324
      //加载图片时图片错误时，显示默认图片
      if(!file_exists($userfilepath_True)||!@getimagesize($userfilepath_True)){
        $userfilepath='themes/images/defaultuser.png';
      }
      return $userfilepath;
    }
    /**
     * edit:can
     * reason:工作报告删除
     * */
    public function DeleteReport()
    {
        global $adb,$current_user,$PlatformMC;
        $workreportid=$_REQUEST['workreportid'];
        //14419: 首页--工作协同,关于删除微博/任务/日志的问题
        $sql="select workreportid from ld_workreport where workreportid=?";
		if($current_user->is_admin != "on" && $current_user->column_fields['user_name'] != 'admin'){
			$sql .= ' and smcreatorid=' . $current_user->id;
			$sql .= " and (replycount is null  or replycount<=0 or replycount='')";
		}
        $result=$adb->pquery($sql,array($workreportid));
        if($adb->num_rows($result)>0)
        {
            //  $sql="delete  from ld_workreply2user where  workreplyid in(select workreplyid from ld_workreport where workreportid=?)";
            // $adb->pquery($sql,array($workreportid));
            // $sql='delete from ld_workreply where workreportid=?';
            // $adb->pquery($sql,array($workreportid));
            $sql='delete from ld_praise where workreportid=?';
            $adb->pquery($sql,array($workreportid));
            $sql='delete from ld_workreport2user where workreportid=?';
            $adb->pquery($sql,array($workrepodelortid));
            //删除相关客户和联系人
            $sql='delete from ld_workreportrelatedto where workreportid=?';
            $adb->pquery($sql,array($workreportid));
            //删除提醒
            $sql="delete from ld_workreport_remind where relatedto=? and relatedtable='workreport' ";
            $adb->pquery($sql,array($workreportid));
            // //删除附件
            // $sql="delete  from ld_workachments where  workreplyid in(select workreplyid from ld_workreport where workreportid=?)";
            // $adb->pquery($sql,array($workreportid));
            $sql='delete from ld_workachments where workreportid=?';
            $adb->pquery($sql,array($workreportid));

            $sql='delete from ld_workreport where workreportid=?';
            $adb->pquery($sql,array($workreportid));
            if(empty($PlatformMC)){
                echo '##success##';
            }

        }
        else
        {
            if(empty($PlatformMC)){
                echo '##error##';
            }
        }

    }
    /**
     * 获取当前用户最近一次发送微博、日志、任务的抄送范围
     * @param 2016-10-19
     * @return
     * @author Chj
     */
    public function getLatelyScope($cur_panel,$cur_panel_tag) {
		global $adb,$current_user;
		if(!empty($cur_panel)){
			switch($cur_panel){
				case 'sendWeibo':
				   $entitytype = 'weibo';
				   break;
				case 'sendLog':
				   $entitytype = 'workreport';
				   break;
				case 'cocmd':
				   $entitytype = 'cocmd';
				   break;
			}

			$query = 'SELECT
                    	ld_workreport2user.userid,
                    	ld_users.last_name,ld_users.wx_userid
                    FROM ld_workreport2user
                    INNER JOIN ld_users ON ld_users.id = ld_workreport2user.userid
                    WHERE ld_workreport2user.workreportid =(SELECT workreportid FROM ld_workreport WHERE smcreatorid = ? AND entitytype = ? ORDER BY createdtime DESC LIMIT 1)
                    	AND ld_workreport2user.user_type=1
                    	AND ld_users.`status` = ? 
                    GROUP BY ld_workreport2user.workreportid,ld_workreport2user.userid';

			$result = $adb->pquery($query,array($current_user->id,$entitytype,'Active'));
			$num_rows = $adb->num_rows($result);
            $userids=[];
			if($num_rows > 0){
                for($i = 0; $i<$num_rows; $i++){
                  $last_name=$adb->query_result($result,$i,'last_name');
                  $wx_userid=$adb->query_result($result,$i,'wx_userid');
                  $userobj=new Users();
                  $userobj->wx_userid=$wx_userid;
                  $userobj->last_name=$last_name;
                  $userids[$adb->query_result($result,$i,'userid')] =  getUserlastName($userobj);
                }
			}
            //固定点评人和最小抄送范围
            if($cur_panel == 'sendLog'){
                $setting_presence = getUsersettingByLabel('WorkTemplateRule',1,$cur_panel_tag);
                $setting_presence = empty($setting_presence)?'yes':$setting_presence;
                if ($setting_presence == 'yes'){
                    crm_load_class_file('WorkTemplateRule','modules/Settings');
                    $workTemplateRuleobj = new WorkTemplateRule();
                    $workTemplateRuleobj->setWorkReportType($cur_panel_tag);
                    $applicable_ruleinfo = $workTemplateRuleobj->getApplicableRuleByUserid($current_user->id);
                    $arr['reportDate'] = $workTemplateRuleobj->getReportDateData();
//                dump($applicable_ruleinfo);
                    $reuser_userinfo = $applicable_ruleinfo['reuser_value_userinfo'];
                    $reuser_presence = $applicable_ruleinfo['reuser_presence'];
                    $ccuser_userinfo = $applicable_ruleinfo['ccuser_value_userinfo'];
                    $ccuser_presence = $applicable_ruleinfo['ccuser_presence'];
                    //点评人
                    if ($reuser_presence == 'yes'){
                        $arr['reuser'] = array('userid'=>'','last_name'=>'','disable'=>'yes');;
                        foreach ($reuser_userinfo as $userid => $last_name){
                            $arr['reuser'] = array('userid'=>$userid,'last_name'=>$last_name,'disable'=>'yes');;
                        }
                    }
//
                    //抄送范围
                    if ($ccuser_presence == 'yes'){
                        foreach ($ccuser_userinfo as $userid => $last_name){
                            $arr['ccuser'][$userid] = array('userid'=>$userid,'last_name'=>$last_name,'disable'=>'yes');
                        }
                    }
                }

            }
            foreach ($userids as $userid => $last_name){
                if (!is_array($arr['ccuser']) || !array_key_exists($userid,$arr['ccuser'])){
                    $arr['ccuser'][$userid] = array('userid'=>$userid,'last_name'=>$last_name,'disable'=>'no');
                }
            }

            // 获取服务器时间
            $arr['serverNowDate'] = date("Y-m-d");
            $today = new DateTime();
            $weekStart = clone $today->modify(('Monday' === $today->format('l')) ? 'this week' : 'last Monday');
            $weekEnd = clone $today->modify('next Sunday');$weekStart->format('Y-m-d');
            $arr['weekStart'] = $weekStart->format('Y-m-d');
            $arr['weekEnd'] = $weekEnd->format('Y-m-d');

            $MonthStart = new DateTime('first day of this month');
            $MonthEnd = new DateTime('last day of this month');
            $arr['MonthStart'] = $MonthStart->format('Y-m-d');
            $arr['MonthEnd'] = $MonthEnd->format('Y-m-d');
            $arr['download_permit'] = isPermitted('CooperativeWork','DownLoad','');
            $arr['preview_permit'] = isPermitted('CooperativeWork','Preview','');

			ConvertTojsonString(1,$arr,'success');

		}
    }
    /**
	 * 检查取消是否需要显示
	 * @author diony 2015-03-27
	 */
    public function checkMore($workreportid) {
        global $adb,$current_user;
	    $sql="select approved,smcreatorid from ld_workreport where workreportid = ? ";
        $result=$adb->pquery($sql,array($workreportid));
        $approved = $adb->query_result($result,0,'approved');
        $smcreatorid = $adb->query_result($result,0,'smcreatorid');
        if($approved == '0'&&$smcreatorid==$current_user->id)
        {
            $approved = 'no';
        }
        else
        {
            $approved = 'yes';
        }
        $entityContent[]=array('approved'=>$approved);
        return $entityContent;
	}

    /**
     * edit:can
     * reason:关键回复
     * */
    function getKeyReply($workreportid)
    {
        global $adb;
        $entitytype = $this->getEntityType($workreportid);
        if($entitytype == 'workreport')
        {
            $user_type = 5;
        }
        else if($entitytype == 'cocmd')
        {
            $user_type = 6;
        }

        $sql="SELECT 
                ld_salesmanattachmentsrel.attachmentsid,
                path,
                ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
                ld_workreply.workreplyid,
                ld_workreply.text,
                ld_workreply.replyuserid,
                ld_workreply.createdtime  
            FROM ld_workreply
            LEFT JOIN ld_workreport ON ld_workreport.workreportid=ld_workreply.workreportid
            LEFT JOIN (
                    SELECT 
                        * 
                    From ld_workreport2user 
                    WHERE user_type = ?
                    GROUP BY workreportid,userid,User_type
            ) AS reportuser ON reportuser.workreportid=ld_workreport.workreportid
            LEFT JOIN ld_users ON ld_users.id=reportuser.userid
            LEFT JOIN ld_salesmanattachmentsrel ON ld_users.id=ld_salesmanattachmentsrel.smid
            LEFT JOIN ld_attachments ON ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
            WHERE ld_workreport.workreportid=? 
                AND ld_workreply.type = 1";
        $result=$adb->pquery($sql,array($user_type,$workreportid));
         for($i=0;$i<$adb->num_rows($result);$i++)
        {
        	$replyuserid = $adb->query_result($result,$i,'replyuserid');
			    $replyusername = getUserFullName($replyuserid);
          $content=$adb->query_result($result,$i,'text');
          $attachmentsid=$adb->query_result($result,$i,'attachmentsid');
          $path=$adb->query_result($result,$i,'path');
          $userimagename=$adb->query_result($result,$i,'userimagename');
          $storage_location=$adb->query_result($result,$i,'storage_location');
          if($storage_location == 'cos'){
            $userfilepath=$adb->query_result($result,$i,'cloud_path');
          }
          else{
            $userfilepath=$this->getUserImage($path,$userimagename,$attachmentsid,$replyuserid);
          }

			if(!empty($content)){
				$content = str_replace("\n","<br>",$content);
			}
           $keyreply='yes';
		   $Obj=new RecordEncrypt("User",$replyuserid);
            $strencrypt= $Obj->encrypt();
            $entityContent[]=array('curid'=>$adb->query_result($result,$i,'workreportreaderid'),'content'=>$content,'createdtime'=>$adb->query_result($result,$i,'createdtime'),'replyusername'=>$replyusername,
                                    'replyuserid'=>$replyuserid,'ecnryptuserid'=>$strencrypt,'keyreply'=>$keyreply,'userimage'=>$userfilepath,'entitytype'=>$entitytype);
        }

        return $entityContent;
    }

    //格式化返回值&替换表情路径
    public function filterWorkSummaryContent($value){
        $value = str_replace("\n","<br>",$value);
        $value = str_replace('themes/softed/emojicookie/','http://www.51mis.cn/websaas/wx_images/emojicookie/',$value);
        return $value;
    }
    /**
     * edit:can
     * reason:回复列表
     * */
    function getReplyList(){
		global $adb,$PlatformMC;
        $workreportid=$_REQUEST['workreportid'];
        $entitytype = $this->getEntityType($workreportid);
        $sql="select ld_salesmanattachmentsrel.attachmentsid,path,ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,workreplyid,text,replyuserid,ld_workreply.createdtime,ld_workreply.type,1 
                from ld_workreply 
                left join ld_users on ld_users.id=ld_workreply.replyuserid
                left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
               left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
               where workreportid=? 
           ";
        //	0031900: 企业微信：工作汇报->查看明细界面,回复内容应该按照时间倒序排序 20180115
    		if($PlatformMC['type']=='weixin'){
    		    $sql .= ' order by createdtime desc ';
    		}

        $result=$adb->pquery($sql,array($workreportid));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
    			$replyuserid = $adb->query_result($result,$i,'replyuserid');
    			$replyusername = getUserFullName($replyuserid);
          $content=$adb->query_result($result,$i,'text');
          $type=$adb->query_result($result,$i,'type');
          $attachmentsid=$adb->query_result($result,$i,'attachmentsid');
          $path=$adb->query_result($result,$i,'path');
          $userimagename=$adb->query_result($result,$i,'userimagename');
          $storage_location=$adb->query_result($result,$i,'storage_location');
          if($storage_location == 'cos'){
            $userfilepath=$adb->query_result($result,$i,'cloud_path');
          }
          else{
            $userfilepath=$this->getUserImage($path,$userimagename,$attachmentsid,$replyuserid);
          }
          if($type==1)
          {
              $keyreply='no';
          }
          else
          {
              $keyreply='yes';
          }
    			if(!empty($content)){
                    if (empty($PlatformMC)){
                        $content = str_replace("\n","<br>",$content);
                    }else{
                        $content = $this->filterWorkSummaryContent($content);
                    }
    			}
          $Obj=new RecordEncrypt("User",$replyuserid);
          $strencrypt= $Obj->encrypt();
          $entityContent[]=array('curid'=>$adb->query_result($result,$i,'workreplyid'),'content'=>$content,'createdtime'=>$adb->query_result($result,$i,'createdtime'),'replyusername'=>$replyusername,
                                    'replyuserid'=>$replyuserid,'ecnryptuserid'=>$strencrypt,
                                    'keyreply'=>$keyreply,'userimage'=>$userfilepath,'entitytype'=>$entitytype);
        }
        return $entityContent;
    }
    /**
     * edit:diony
     * reason:点赞列表
     * */
    function getPraiseList(){
		global $adb;
        $workreportid=$_REQUEST['workreportid'];
        $entitytype = $this->getEntityType($workreportid);
        $sql="select ld_salesmanattachmentsrel.attachmentsid,path,ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,ld_praise.userid,createdtime 
                from ld_praise 
                left join ld_users on ld_users.id=ld_praise.userid
                left join ld_salesmanattachmentsrel on ld_users.id=ld_salesmanattachmentsrel.smid
               left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
               where workreportid=? order by createdtime desc";
        $result=$adb->pquery($sql,array($workreportid));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
          $userid = $adb->query_result($result,$i,'userid');
		      $praiseusername = getUserFullName($userid);
            $attachmentsid=$adb->query_result($result,$i,'attachmentsid');
          $path=$adb->query_result($result,$i,'path');
          $userimagename=$adb->query_result($result,$i,'userimagename');
          $storage_location=$adb->query_result($result,$i,'storage_location');
          if($storage_location == 'cos'){
            $userfilepath=$adb->query_result($result,$i,'cloud_path');
          }
          else{
            $userfilepath=$this->getUserImage($path,$userimagename,$attachmentsid,$userid);
          }
          $entityContent[]=array('praiseusername'=>$praiseusername,'userimage'=>$userfilepath);
        }
        return $entityContent;
    }
    /**
     * 获取工作报告中自定义字段
     * */
    public  function getallFieldsForTable()
    {
        $workreportfields= $this->getWorkFieldEntity('workreport');
        $entityfield['workreport']=array();
        $entityfield['workreport']['cocmd']=array('fieldcount'=>1,'fieldinfo'=>array());
        $entityfield['workreport']['weibo'] = array('fieldcount'=>1,'fieldinfo'=>array());
        foreach(array('name','tablename','label','defaultvalue','defaultheight','is_mandatory') as &$column){
            $entityfield['workreport']['cocmd']['fieldinfo'][0][$column] = '';
            $entityfield['workreport']['weibo']['fieldinfo'][0][$column] = '';
        }
        $entityfield['workreport']['cocmd']['fieldinfo'][0]['name']='workexperience';
        $entityfield['workreport']['weibo']['fieldinfo'][0]['name']='workexperience';
        foreach($workreportfields as $type=>$columnarr)
        {
            if($type==1)
            {
                 $typecount=sizeof($workreportfields[$type]);
                 $entityfield['workreport']['dayreport']['fieldcount']=$typecount;
                foreach($columnarr as $column =>$columninfo)
                {
                    $entityfield['workreport']['dayreport']['fieldinfo'][]=$columninfo;
                }
            }
            else if($type==2)
            {
                  $typecount=sizeof($workreportfields[$type]);
                 $entityfield['workreport']['weekreport']['fieldcount']=$typecount;
                foreach($columnarr as $column=>$columninfo)
                {
                    $entityfield['workreport']['weekreport']['fieldinfo'][]=$columninfo;
                }
            }
            else if($type==3)
            {
                  $typecount=sizeof($workreportfields[$type]);
                 $entityfield['workreport']['monthreport']['fieldcount']=$typecount;
                foreach($columnarr as $column=>$columninfo)
                {
                    $entityfield['workreport']['monthreport']['fieldinfo'][]=$columninfo;
                }
            }
        }

        return $entityfield;

    }
    /**
     * edit:can
     * reason:列表sql
     * */
    public function getList()
    {
        global $adb,$current_user;
    		if(empty($_REQUEST['report_user_id']) || $_REQUEST['info'] == 'yes'){
    			$userid = $current_user->id;
    		}else{
    			$userid = $_REQUEST['report_user_id'];
    		}
        $readers=array();//批阅人数组
        $bigcategory=$_REQUEST['bigcategory'];
        $leftcategory=$_REQUEST['leftcategory'];

        if(empty($bigcategory))
        {
            $bigcategory=1;
        }
        //duan 20221215 相关信息查看工作汇报,默认选择全部页签
        if($_REQUEST['relateinfo'] == 'yes'){
            //管理员和设置了查看所有关联数据的用户可以看到全部数据
            if($current_user->is_admin == 'on' || $current_user->accountallview == '1'){
                $bigcategory = 'All';
            }
        }

        $smallcategory=$_REQUEST['smallcategory'];
        if(empty($smallcategory))
        {
            $smallcategory='all';
        }
        if(!empty($leftcategory))
        {
            $bigcategory=0;
            $smallcategory='';
            //zkt 20230705 BUG0068080 工作汇报这边点击日志出现的内容会把周计划都显示出来
            if(in_array($leftcategory,array('weibo','logday','logweek','logmonth','cocmd'))){
                $smallcategory = $leftcategory;
            }
        }
		    $searchcontent=$_REQUEST['searchcontent'];
        $jsonArray=array();
        $jsonArray['summary']['processedCount']=$this->getprocessingCount();

    		/**
    		 * 获取自定义字段结果集，组装sql
    		 * @project 工作协同模板
    		 * @author Tujt 2015-05-07
    		 */
    		$entity_type = 'workreport';
    		$workfldarr = $this->getWorkCfFieldInfo($entity_type);
    		$workfldsql = '';
    		if(!empty($workfldarr)){
    			$workfldkeyarr = array_keys($workfldarr);
    			$workfldsql = ',ld_workreportcf.'.join(',ld_workreportcf.',$workfldkeyarr);
    		}//end
        //注意 变量$sql的第一个from字符串全部小写，以后的from都写成From,因为分页要用到全部小写的from
        $sql="select ld_salesmanattachmentsrel.attachmentsid ,ld_workreport.createdtime,ld_workreport.startdate,
        ld_users.last_name ,worksummary,workplan,workexperience,workplan_tuesday,workplan_wednesday,
        workplan_thursday,workplan_friday,signaddress,
        ld_workreport.entitytype,ld_workreport.type,usercreator.id as userid,
       
        ld_workreport2user.user_type,editcount,replycount,path,ld_workreport.workreportid,praisecount,
        ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
        ld_workreport.filename,ld_workreport.filepath,
          usercreator.last_name as usercreator, usercreator.wx_userid as usercreator_wx_userid,
          ld_workreport.longtitude,ld_workreport.latitude,
        ld_workreport.sendlog_workdate,ld_workreport.saleskit_day,ld_workreport.saleskit_month,ld_workreport.saleskit_week,ld_workreport.approved,ld_workreport.smcreatorid,tmp.usercount".$workfldsql.",
        ld_workreport.saleskit_showtype,ld_workreport.saleskit_listinfo 
        from ld_workreport 
          left join ld_workreport2user on ld_workreport.workreportid=ld_workreport2user.workreportid
          left join ld_users on ld_users.id=ld_workreport2user.userid
          left join ld_users as usercreator  on ld_workreport.smcreatorid=usercreator.id
          left join ld_salesmanattachmentsrel on   usercreator.id=ld_salesmanattachmentsrel.smid
          left join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid 
		  left join ld_workreportcf on ld_workreportcf.workreportid = ld_workreport.workreportid 
        left join (select count(workreportid) as usercount,workreportid From (select(userid),workreportid From ld_workreport2user inner JOIN ld_users on ld_users.id = ld_workreport2user.userid where ld_users.`status` = 'Active' GROUP BY workreportid,userid ) as counttmp GROUP BY workreportid   ) as tmp 
        on tmp.workreportid=ld_workreport.workreportid ";

       switch($smallcategory)//小分类
       {
           case 'all':
              $sql.=' where ';
              $wheresmallsql=' where ';
              crm_load_class_file('cls_workreportshow',"modules/CooperativeWork");
              $workreportshowobj=new cls_workreportshow();
              $allshowtype=$workreportshowobj->getWorkReportShow();
              foreach($allshowtype as $showval){
                  if($showval['type']=='weibo'&&$showval['reportshow']=='yes'){
                      $all_sql[] = ' ((ld_workreport.entitytype=\'weibo\') and ld_workreport.type=1) ';
                  }elseif($showval['type']=='dayreport'&&$showval['reportshow']=='yes'){
                      $all_sql[] = ' (ld_workreport.entitytype=\'workreport\' and ld_workreport.type=1) ';
                  }elseif($showval['type']=='weekreport'&&$showval['reportshow']=='yes'){
                      $all_sql[] = ' (ld_workreport.entitytype=\'workreport\' and ld_workreport.type=2) ';
                  }elseif($showval['type']=='monthreport'&&$showval['reportshow']=='yes'){
                      $all_sql[] = ' (ld_workreport.entitytype=\'workreport\' and ld_workreport.type=3) ';
                  }elseif($showval['type']=='cocmd'&&$showval['reportshow']=='yes'){
                      $all_sql[] = ' (ld_workreport.entitytype=\'cocmd\' and ld_workreport.type=1) ';
                  }
                  $allsqlstr = '('.implode(' or ',$all_sql).') and ';
              }
              $sql .= $allsqlstr;
              $wheresmallsql .= $allsqlstr;
              break;
            case 'weibo': //微博
                $wheresmallsql=" where (ld_workreport.entitytype='weibo') and ld_workreport.type=1  and ";
                $sql.=" where (ld_workreport.entitytype='weibo') and ld_workreport.type=1  and ";
                break;
            case 'logday': //日志
                $wheresmallsql=" where ld_workreport.entitytype='workreport' and ld_workreport.type=1 and ";
                $sql.=" where ld_workreport.entitytype='workreport' and ld_workreport.type=1 and ";
                break;
            case 'logweek': //周计划
                $wheresmallsql=" where ld_workreport.entitytype='workreport' and ld_workreport.type=2 and ";
                $sql.=" where ld_workreport.entitytype='workreport' and ld_workreport.type=2 and ";
                break;
            case 'logmonth': //月计划
                $wheresmallsql=" where ld_workreport.entitytype='workreport' and ld_workreport.type=3  and ";
                $sql.=" where ld_workreport.entitytype='workreport' and ld_workreport.type=3  and ";
                break;
            case 'cocmd': //任务
                $wheresmallsql=" where ld_workreport.entitytype='cocmd' and ld_workreport.type=1 and ";
                $sql.=" where ld_workreport.entitytype='cocmd' and ld_workreport.type=1 and ";
                break;
			case 'workreply'://工作回复:用户回复的工作
			   $leftcategory = 'cur_myreply';
			   break;
			case 'atmywork'://工作日志中@到当前用户的全部数据
			   $leftcategory = 'cur_me';
			   break;
			case 'atmyreply'://工作回复中@到我的全部数据
				$leftcategory = 'cur_atmyreply';
			   break;
       }
	   if(!empty($_REQUEST['massdelete']) && $_REQUEST['massdelete'] == 'true'){
			$bigcategory = 'All';
	   }
       $searchscope=$_REQUEST['searchscope'];//全部 管理员， 可以查看所有人的工作日志，即使点评人不是管理员，也不抄送给管理员，仅针对PC端

       switch($bigcategory)//大分类
       {
             case '1'://下拉框
                 //$_REQUEST['sponsor']：代表查询发起人
                 if(($searchscope!='all'||!is_admin($current_user))&&$_REQUEST['sponsor']=="")
                 {
                    $scopetype='-1';
                    $higherscopeuserid='';

                    if($_REQUEST['ViewallCooperativeWork']=='yes'&&$_REQUEST['sponsor']=="")
                    {
                        //查看全部的界面
                        $smallcategory=$_REQUEST['smallcategory'];
                        //zkt 20230314 用户的数据权限已将工作汇报设置为全部，登录到用户的系统中，进去工作汇报，全部，任务。不能看到所有人员的任务清单
                        if($smallcategory=='all'||$smallcategory=='weibo'
                                ||$smallcategory=='logweek'||$smallcategory=='logday'||$smallcategory=='logmonth'
                                ||$smallcategory=='cocmd')
                        {
                             $scopeobj=ScopOfAuthority::getInstance($adb,'CooperativeWork');

                            $scopetypes=$scopeobj->getUserAllModuleScope();


                            if(array_key_exists('CooperativeWork',$scopetypes))
                                $scopetype=$scopetypes['CooperativeWork']['scopeauthority'];
                            else
                                $scopetype='-1';

                            if($scopetype=='2'||$scopetype=='3')
                            {
                                //高级
                                $higherscopeuserid=$scopeobj->getUserModuleScopeHigher();
                            }
                        }
                    }
                    if(is_admin($current_user))
                    {
                        //edit:can 2020-08-27 42510: （http://51mis.com.cn/XS/levson/ [^]）客户问题（江苏利物盛）使用普通用户账号操作,工作汇报：填写日志“点评人”和“抄送范围”都不选择“系统管理员”点击保存，然后系统管理员在工作汇报“全部”看不到这条日志记录
                        $scopetype=1;
                    }
                    if($scopetype==1)
                    {
                        //全部
                         $sql.=' 1=1 ';

                    }
                   else  if($scopetype=='2'||$scopetype=='3')
                   {
                        //高级
                        $tmpuserids=trim(implode(',',$higherscopeuserid),',');
                        if(!empty($tmpuserids))
                        {
                             $sql.=' (ld_workreport2user.userid=?  or ld_workreport2user.userid = -1 or ld_workreport.smcreatorid in('.$tmpuserids.')) ';
                        }
                        else
                             $sql.=' (ld_workreport2user.userid=?  or ld_workreport2user.userid = -1) ';
                   }
                    else  //个人或者工作汇报菜单界面
                            $sql.=' (ld_workreport2user.userid=?  or ld_workreport2user.userid = -1) ';

                     if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
                        $sql.=' and ld_workreport.smcreatorid=? ';
                        //duan 20221216 修复工作汇报模块点击头像查看所有信息时，没有数据的问题
                        if($scopetype == 1){
                            $params=array($_REQUEST['viewuserid']);
                        }else{
                            $params=array($_REQUEST['viewuserid'],$_REQUEST['viewuserid']);
                        }

                     }
                     else if($_REQUEST['sponsor']==''&&($scopetype=='-1'||$scopetype=='2'||$scopetype=='3'||$scopetype==0)){
                        if($scopetype == 1){
                            $params=array();
                        }else{
                            $params=array($userid);
                        }
                     }
                 }
                 else
                 {
                    $sql.=' 1=1 ';
                 }

                 break;
             case '2'://待处理
                $sql.=" approved=0 ";
                if($searchscope!='all'||!is_admin($current_user))
                 {
                    $sql.=" and (ld_workreport2user.userid=? or ld_workreport2user.userid = -1) and entitytype in ('cocmd','workreport') and ld_workreport2user.user_type in(5,6,7) ";
                    $params=array($userid);
                }
                break;
             case '3'://已处理

                    $sql.="  approved=1 ";

                   if($searchscope!='all'||!is_admin($current_user))
                     {
                        $sql.=" and (ld_workreport2user.userid=? or ld_workreport2user.userid = -1)   and entitytype in ('cocmd','workreport') and ld_workreport2user.user_type in(5,6,7) ";
                        $params=array($userid);
                    }
                  break;
             case '4'://我发起的

                $sql="select ld_salesmanattachmentsrel.attachmentsid ,ld_workreport.createdtime,startdate,ld_users.last_name  as usercreator,usercreator.wx_userid as usercreator_wx_userid,
                            worksummary,workplan,workexperience,workplan_tuesday,workplan_wednesday,workplan_thursday,workplan_friday,signaddress,ld_workreport.entitytype,ld_workreport.type,ld_users.id as userid,
                           '4' as  user_type,editcount,replycount,path ,ld_workreport.workreportid ,praisecount,
                           ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
                           ld_workreport.filename,ld_workreport.filepath ,
                           ld_workreport.sendlog_workdate,ld_workreport.saleskit_day,ld_workreport.saleskit_month,ld_workreport.saleskit_week,ld_workreport.approved ,ld_workreport.smcreatorid,tmp.usercount,ld_workreport.longtitude,ld_workreport.latitude ".$workfldsql.",
                       ld_workreport.saleskit_showtype,ld_workreport.saleskit_listinfo 
                        from ld_workreport  left join ld_users on ld_users.id=ld_workreport.smcreatorid
                        left join ld_workreportcf on ld_workreportcf.workreportid = ld_workreport.workreportid 
                        left join ld_users as usercreator  on ld_workreport.smcreatorid=usercreator.id
                      left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
                       left join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid  
                       left join (select count(workreportid) as usercount,workreportid From (select(userid),workreportid 
                       
                       From ld_workreport2user inner JOIN ld_users on ld_users.id = ld_workreport2user.userid where ld_users.`status` = 'Active' GROUP BY workreportid,userid ) as counttmp GROUP BY workreportid  ) as tmp 
                        on tmp.workreportid=ld_workreport.workreportid
                         
                         ";
                //edit:can 14756: 首页>工作协同,关于查看微博的问题
                 $sql.=$wheresmallsql. "   ld_workreport.smcreatorid=?";
                 $params=array($userid);
                break;
            case '5'://抄送给我的（微信端需求 20180402）
                $sql.=" (ld_workreport2user.userid=? or ld_workreport2user.userid = -1) and ld_workreport2user.user_type=1";
                $params=array($userid);
                break;
            case '6'://@我的（微信端需求 20180402）
                $sql.=' (ld_workreport2user.userid=? or ld_workreport2user.userid = -1) and ld_workreport2user.user_type=2';
                $params=array($userid);
                break;
			 case '7'://我相关的
                $sql.=' ((ld_workreport2user.userid=? or ld_workreport2user.userid = -1) and ld_workreport2user.user_type=2 or (ld_workreport2user.userid=? or ld_workreport2user.userid = -1) and ld_workreport2user.user_type=1 or (ld_workreport2user.userid=? or ld_workreport2user.userid = -1) and ld_workreport2user.user_type=3 or (ld_workreport2user.userid=? or ld_workreport2user.userid = -1) and ld_workreport2user.user_type=5)';
                $params=array($userid,$userid,$userid,$userid);
                break;
			case '10'://全部 我相关的
			    $sql.=' ((ld_workreport2user.userid=? or ld_workreport2user.userid = -1) and ld_workreport2user.user_type=2 or (ld_workreport2user.userid=? or ld_workreport2user.userid = -1) and ld_workreport2user.user_type=1 or (ld_workreport2user.userid=? or ld_workreport2user.userid = -1) and ld_workreport2user.user_type=3 or (ld_workreport2user.userid=? or ld_workreport2user.userid = -1) and ld_workreport2user.user_type=5)';
                $params=array($userid,$userid,$userid,$userid);
                break;
			   break;
			case 'myreply'://我的回复
				$sql .= "";
				break;
			case 'All':
			   $sql .= " 1=1";
			   break;
       }

       //注意 变量$sql的第一个from字符串全部小写，以后的from都写成From,因为分页要用到全部小写的from
       switch($leftcategory)
       {
            case 'me'://@提到我的
                $sql="select ld_salesmanattachmentsrel.attachmentsid ,ld_workreport.createdtime,ld_workreport.startdate,ld_users.last_name ,worksummary,workplan,workexperience,workplan_tuesday,workplan_wednesday,workplan_thursday,workplan_friday,signaddress,
                ld_workreport.entitytype,ld_workreport.type,usercreator.id as userid,ld_workreport2user.user_type,editcount,replycount,path,ld_workreport.workreportid,praisecount,
                ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
                ld_workreport.filename,ld_workreport.filepath,
                usercreator.last_name as usercreator, usercreator.wx_userid as usercreator_wx_userid,
                ld_workreport.approved,ld_workreport.smcreatorid,tmp.usercount,ld_workreport.longtitude,ld_workreport.latitude
                from ld_workreport left join ld_workreport2user on ld_workreport.workreportid=ld_workreport2user.workreportid
                  left join ld_users on ld_users.id=ld_workreport2user.userid
                  left join ld_users as usercreator  on ld_workreport.smcreatorid=usercreator.id
                  left join ld_salesmanattachmentsrel on   usercreator.id=ld_salesmanattachmentsrel.smid
               left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid 
               left join (select count(workreportid) as usercount,workreportid From (select(userid),workreportid From ld_workreport2user inner JOIN ld_users on ld_users.id = ld_workreport2user.userid where ld_users.`status` = 'Active'  GROUP BY workreportid,userid ) as counttmp GROUP BY workreportid ) as tmp 
                on tmp.workreportid=ld_workreport.workreportid LEFT JOIN ld_workreply on ld_workreply.workreportid=ld_workreport.workreportid
                left join ld_workreply2user on ld_workreply2user.workreplyid=ld_workreply.workreplyid
                where ((ld_workreport2user.userid=? and ld_workreport2user.user_type=2) or(ld_workreply2user.userid=?  and  ld_workreply2user.user_type=2))";

                $params=array($userid,$userid);
                break;
			case 'cur_me'://@
                $sql="select ld_salesmanattachmentsrel.attachmentsid ,ld_workreport.createdtime,ld_workreport.startdate,ld_users.last_name,
                  worksummary,workplan,workexperience,workplan_tuesday,workplan_wednesday,workplan_thursday,workplan_friday,signaddress,
          				ld_workreport.entitytype,ld_workreport.type,usercreator.id as userid,ld_workreport2user.user_type,editcount,replycount,path,ld_workreport.workreportid,praisecount,
          				ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
                  ld_workreport.filename,ld_workreport.filepath,
                usercreator.last_name as usercreator, usercreator.wx_userid as usercreator_wx_userid,
                ld_workreport.longtitude,ld_workreport.latitude,
				ld_workreport.approved,ld_workreport.smcreatorid,tmp.usercount".$workfldsql."
				from ld_workreport 
				  left join ld_workreport2user on ld_workreport.workreportid=ld_workreport2user.workreportid
				  left join ld_users on ld_users.id=ld_workreport2user.userid
				  left join ld_users as usercreator  on ld_workreport.smcreatorid=usercreator.id
				  left join ld_salesmanattachmentsrel on   usercreator.id=ld_salesmanattachmentsrel.smid
				  left join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid 
				  left join ld_workreportcf on ld_workreportcf.workreportid = ld_workreport.workreportid 
				left join (select count(workreportid) as usercount,workreportid From (select(userid),workreportid From ld_workreport2user inner JOIN ld_users on ld_users.id = ld_workreport2user.userid where ld_users.`status` = 'Active'  GROUP BY workreportid,userid ) as counttmp GROUP BY workreportid   ) as tmp 
				on tmp.workreportid=ld_workreport.workreportid where ld_workreport2user.userid= ? and  ld_workreport2user.User_type = 2";

                $params=array($current_user->id);
                break;
           case 'atmyreply'://回复中@提到我的
                //edit: xll 2023/08/01 BUG0065539 kfbcrm -工作汇报-我的消息内@我的，显示没有内容
                $sql="select ld_salesmanattachmentsrel.attachmentsid ,ld_workreport.createdtime,ld_workreport.startdate,ld_users.last_name ,worksummary,workplan,workexperience,workplan_tuesday,workplan_wednesday,workplan_thursday,workplan_friday,signaddress,
                ld_workreport.entitytype,ld_workreport.type,usercreator.id as userid,ld_workreport2user.user_type,editcount,replycount,path,ld_workreport.workreportid,praisecount,
                ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
                ld_workreport.filename,ld_workreport.filepath,
                usercreator.last_name as usercreator, usercreator.wx_userid as usercreator_wx_userid,
                ld_workreport.approved,ld_workreport.smcreatorid,tmp.usercount,ld_workreport.longtitude,ld_workreport.latitude
                from ld_workreport left join ld_workreport2user on ld_workreport.workreportid=ld_workreport2user.workreportid
                  left join ld_users on ld_users.id=ld_workreport2user.userid
                  left join ld_users as usercreator  on ld_workreport.smcreatorid=usercreator.id
                  left join ld_salesmanattachmentsrel on   usercreator.id=ld_salesmanattachmentsrel.smid
               left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid 
               left join (select count(workreportid) as usercount,workreportid From (select(userid),workreportid From ld_workreport2user inner JOIN ld_users on ld_users.id = ld_workreport2user.userid where ld_users.`status` = 'Active'  GROUP BY workreportid,userid ) as counttmp GROUP BY workreportid ) as tmp 
                on tmp.workreportid=ld_workreport.workreportid INNER JOIN ld_workreply on ld_workreply.workreportid=ld_workreport.workreportid
                left join ld_workreply2user on ld_workreply2user.workreplyid=ld_workreply.workreplyid
                where ((ld_workreport2user.userid=? and (ld_workreport2user.user_type=4 or ld_workreport2user.user_type=2 or ld_workreport2user.user_type=1)) or(ld_workreply2user.userid=?  and (ld_workreply2user.user_type=4 or ld_workreply2user.user_type=2 or ld_workreport2user.user_type=1)))";

                $params=array($userid,$userid);
                break;
			case 'cur_atmyreply'://回复中@提到我的
                  $sql="select ld_salesmanattachmentsrel.attachmentsid ,ld_workreport.createdtime,ld_workreport.startdate,ld_users.last_name ,worksummary,workplan,workexperience,workplan_tuesday,workplan_wednesday,workplan_thursday,workplan_friday,signaddress,
                ld_workreport.entitytype,ld_workreport.type,usercreator.id as userid,ld_workreport2user.user_type,editcount,replycount,path,ld_workreport.workreportid,praisecount,
                ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
                ld_workreport.filename,ld_workreport.filepath,
                usercreator.last_name as usercreator, usercreator.wx_userid as usercreator_wx_userid,
                ld_workreport.approved,ld_workreport.smcreatorid,tmp.usercount,ld_workreport.longtitude,ld_workreport.latitude
                from ld_workreport left join ld_workreport2user on ld_workreport.workreportid=ld_workreport2user.workreportid
                  left join ld_users on ld_users.id=ld_workreport2user.userid
                  left join ld_users as usercreator  on ld_workreport.smcreatorid=usercreator.id
                  left join ld_salesmanattachmentsrel on   usercreator.id=ld_salesmanattachmentsrel.smid
               left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid 
               left join (select count(workreportid) as usercount,workreportid From (select(userid),workreportid From ld_workreport2user inner JOIN ld_users on ld_users.id = ld_workreport2user.userid where ld_users.`status` = 'Active'  GROUP BY workreportid,userid ) as counttmp GROUP BY workreportid ) as tmp 
                on tmp.workreportid=ld_workreport.workreportid LEFT JOIN ld_workreply on ld_workreply.workreportid=ld_workreport.workreportid
                left join ld_workreply2user on ld_workreply2user.workreplyid=ld_workreply.workreplyid where ld_workreply2user.userid= ? and (ld_workreply2user.user_type=4 or ld_workreply2user.user_type=2)";

                $params=array($current_user->id);
                break;
			case 'cur_myreply'://工作回复:用户回复的工作
                 $sql="select ld_salesmanattachmentsrel.attachmentsid ,ld_workreport.createdtime,ld_workreport.startdate,ld_users.last_name ,worksummary,workplan,workexperience,workplan_tuesday,workplan_wednesday,workplan_thursday,workplan_friday,signaddress,
                ld_workreport.entitytype,ld_workreport.type,usercreator.id as userid,ld_workreport2user.user_type,editcount,replycount,path,ld_workreport.workreportid,praisecount,
                ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
                ld_workreport.filename,ld_workreport.filepath,
                usercreator.last_name as usercreator, usercreator.wx_userid as usercreator_wx_userid,
                ld_workreport.approved,ld_workreport.smcreatorid,tmp.usercount,ld_workreport.longtitude,ld_workreport.latitude
                from ld_workreport left join ld_workreport2user on ld_workreport.workreportid=ld_workreport2user.workreportid
                  left join ld_users on ld_users.id=ld_workreport2user.userid
                  left join ld_users as usercreator  on ld_workreport.smcreatorid=usercreator.id
                  left join ld_salesmanattachmentsrel on   usercreator.id=ld_salesmanattachmentsrel.smid
               left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid 
               left join (select count(workreportid) as usercount,workreportid From (select(userid),workreportid From ld_workreport2user inner JOIN ld_users on ld_users.id = ld_workreport2user.userid where ld_users.`status` = 'Active'  GROUP BY workreportid,userid ) as counttmp GROUP BY workreportid ) as tmp 
                on tmp.workreportid=ld_workreport.workreportid LEFT JOIN ld_workreply on ld_workreply.workreportid=ld_workreport.workreportid
                left join ld_workreply2user on ld_workreply2user.workreplyid=ld_workreply.workreplyid
                where ld_workreply.replyuserid=?";
				if(!empty($_REQUEST['report_user_id']))
					$params=array($_REQUEST['report_user_id']);
				else
					$params=array($userid);
                break;
            case 'mypraise'://我的赞
                $sql="select ld_salesmanattachmentsrel.attachmentsid ,ld_workreport.createdtime,startdate,ld_users.last_name  as usercreator,
                                worksummary,workplan,workexperience,workplan_tuesday,workplan_wednesday,workplan_thursday,workplan_friday,signaddress,ld_workreport.entitytype,ld_workreport.type,ld_users.id as userid,
                               '4' as  user_type,editcount,replycount,path ,ld_workreport.workreportid ,praisecount,
                               ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
                               ld_workreport.filename,ld_workreport.filepath ,
                               ld_workreport.approved ,ld_workreport.smcreatorid,tmp.usercount,ld_workreport.longtitude,ld_workreport.latitude
                            from ld_workreport  left join ld_users on ld_users.id=ld_workreport.smcreatorid
                          left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
                           left join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid  
                           left join (select count(workreportid) as usercount,workreportid From (select(userid),workreportid From ld_workreport2user inner JOIN ld_users on ld_users.id = ld_workreport2user.userid where ld_users.`status` = 'Active'  GROUP BY workreportid,userid ) as counttmp GROUP BY workreportid ) as tmp 
                            on tmp.workreportid=ld_workreport.workreportid left  join ld_praise  as tmppraise
                        on tmppraise.workreportid=ld_workreport.workreportid  where tmppraise.userid=?";
                $params=array($userid);
                break;
			case 'mywork_praise'://点击“我收到的”，显示所有我发起的工作汇报已被赞了的数据
                $sql="select ld_salesmanattachmentsrel.attachmentsid ,ld_workreport.createdtime,startdate,ld_users.last_name  as usercreator,
                                worksummary,workplan,workexperience,workplan_tuesday,workplan_wednesday,workplan_thursday,workplan_friday,signaddress,ld_workreport.entitytype,ld_workreport.type,ld_users.id as userid,
                               '4' as  user_type,editcount,replycount,path ,ld_workreport.workreportid ,praisecount,
                               ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,
                               ld_workreport.filename,ld_workreport.filepath ,
                               ld_workreport.approved ,ld_workreport.smcreatorid,tmp.usercount,ld_workreport.longtitude,ld_workreport.latitude
                            from ld_workreport  left join ld_users on ld_users.id=ld_workreport.smcreatorid
                          left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
                           left join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid  
                           left join (select count(workreportid) as usercount,workreportid From (select(userid),workreportid From ld_workreport2user inner JOIN ld_users on ld_users.id = ld_workreport2user.userid where ld_users.`status` = 'Active'  GROUP BY workreportid,userid ) as counttmp GROUP BY workreportid ) as tmp 
                            on tmp.workreportid=ld_workreport.workreportid inner  join ld_praise  as tmppraise
                        on tmppraise.workreportid=ld_workreport.workreportid  where ld_workreport.smcreatorid =?";
                $params=array($userid);
                break;
            case 'myreply'://我的回复	我发起的
                $sql.="    left JOIN ld_workreply on ld_workreply.workreportid=ld_workreport.workreportid where ld_workreply.replyuserid=? ";
                $params=array($userid);
                break;
			case 'mywork_reply'://我的回复 我收到的
                $sql.="    INNER JOIN ld_workreply on ld_workreply.workreportid=ld_workreport.workreportid where ld_workreport.smcreatorid=? ";
                $params=array($userid);
                break;
       }

          $searchcontent=trim($_REQUEST['searchcontent']);
          if(isset($searchcontent)&&trim($searchcontent)!=''){
            $sql.= "  and (ld_workreport.workplan like '%$searchcontent%' or ld_workreport.worksummary like '%$searchcontent%' or ld_workreport.workexperience like '%$searchcontent%' 
                            or ld_users.last_name like '%$searchcontent%' or usercreator.last_name like '%$searchcontent%' 
                           or  ld_workreport.saleskit_day like '%$searchcontent%' or ld_workreport.saleskit_week like '%$searchcontent%' or ld_workreport.saleskit_month like '%$searchcontent%' ";
        		//搜索时，添加工作协同自定义字段信息 tujt 2015-05-08
        		if(!empty($workfldkeyarr)){
        			$sql .= 'or ld_workreportcf.'.join(' like "%'.$searchcontent.'%" or ld_workreportcf.',$workfldkeyarr).' like "%'.$searchcontent.'%" ';
        		}
            //15117: 首页>工作协同,关于搜索的问题
            $sql.= " or ld_workreport.workreportid in
                    ( 
                        select DISTINCT workreportid  From  
                        ( 
                            select  ld_workreportrelatedto.workreportid From ld_workreportrelatedto
                            INNER JOIN ld_contactdetails on ld_contactdetails.contactid=ld_workreportrelatedto.relatedto
                            where ld_contactdetails.deleted=0 and lastname like '%".$searchcontent."%'
                            UNION
                            select   ld_workreportrelatedto.workreportid From ld_workreportrelatedto
                            INNER JOIN ld_account on ld_account.accountid=ld_workreportrelatedto.relatedto
                            where ld_account.deleted=0  and accountname like '%".$searchcontent."%'
                        ) as relate_table
                    )";
        		$sql .= ')';
          }

            //注意 变量$sql的第一个from字符串全部小写，以后的from都写成From,因为分页要用到全部小写的from
            if(isset($_REQUEST['roleid']) && $_REQUEST['roleid'] > 0){
				$setype_query = 'select setype from ld_crmentity where crmid = ? limit 1';
				$setype_result = $adb->pquery($setype_query,array($_REQUEST['roleid']));

				if($adb->num_rows($setype_result) >= 1){
					$setype = $adb->query_result($setype_result,0,0);
					if($setype == 'Accounts'){
						 $sql.= " and ld_workreport.workreportid in
                            ( 
                                select DISTINCT workreportid  From  
                                ( 
                                    select   ld_workreportrelatedto.workreportid From ld_workreportrelatedto
                                    INNER JOIN ld_account on ld_account.accountid=ld_workreportrelatedto.relatedto
                                    where ld_account.deleted=0  and ld_workreportrelatedto.relatedto = '".$_REQUEST['roleid']."'
                                ) as relate_table
                            )";
					}else if($setype == 'Contacts'){
					   //23098: 联系人-相关信息：数量显示不正确，有两条数据的情况下显示了1
						 $sql.= " and  ld_workreport.workreportid in
                            ( 
                                select DISTINCT workreportid  From  
                                ( 
                                    select  ld_workreportrelatedto.workreportid From ld_workreportrelatedto
                                    INNER JOIN ld_contactdetails on ld_contactdetails.contactid=ld_workreportrelatedto.relatedto
                                    where ld_contactdetails.deleted=0 and ld_workreportrelatedto.relatedto = '".$_REQUEST['roleid']."'
                                ) as relate_table
                            )";
					}else if($setype == 'Products'){
					   //23098: 联系人-相关信息：数量显示不正确，有两条数据的情况下显示了1
						 $sql.= " and ld_workreport.workreportid in
                            ( 
                                select DISTINCT workreportid  From  
                                ( 
                                    select  ld_workreportrelatedto.workreportid From ld_workreportrelatedto
                                    INNER JOIN ld_products on ld_products.productid=ld_workreportrelatedto.relatedto
                                    where ld_products.deleted=0 and ld_workreportrelatedto.relatedto = '".$_REQUEST['roleid']."'
                                ) as relate_table
                            )";
					}
				}
			}
            $sqlcounts=explode('from',$sql);
			if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
                $sqlcounts[1] .= " and ld_workreport.workreportid in (select workreportid from ld_workreport2user where userid = $userid) ";
            }

			//基本查询 - 时间范围
            if(!empty($_REQUEST['datecategory'])){
				$sql_times = '';
				switch($_REQUEST['datecategory']){
					case 'today':	//今天
					   $sql_times = " and ld_workreport.createdtime like '%".date('Y-m-d')."%'";
					   break;
					case 'yesterday':	//昨日
					   $sql_times = " and ld_workreport.createdtime like '%".date("Y-m-d",strtotime("-1 day"))."%'";
					   break;
					case 'thisweek':	//本周
					   $begin_times = date("Y-m-d H:i:s",mktime(0, 0 , 0,date("m"),date("d")-date("w")+1,date("Y")));
					   $end_times = date("Y-m-d H:i:s",mktime(23,59,59,date("m"),date("d")-date("w")+7,date("Y")));
					   $sql_times = " and ld_workreport.createdtime between '".$begin_times."' and '".$end_times."'";
					   break;
					case 'lastmonth':	//上月
					   $begin_times = date("Y-m-d H:i:s",mktime(0, 0 , 0,date("m")-1,1,date("Y")));
					   $end_times = date("Y-m-d H:i:s",mktime(23,59,59,date("m") ,0,date("Y")));
					   $sql_times = " and ld_workreport.createdtime between '".$begin_times."' and '".$end_times."'";
					   break;
					case 'thismonth':	//本月
					   $begin_times = date("Y-m-d H:i:s",mktime(0, 0 , 0,date("m"),1,date("Y")));
					   $end_times = date("Y-m-d H:i:s",mktime(23,59,59,date("m"),date("t"),date("Y")));
					   $sql_times = " and ld_workreport.createdtime between '".$begin_times."' and '".$end_times."'";
					   break;
					case 'thisyear':	//本年
					   $begin_times = date("Y",time())."-1"."-1 00:00:00";
					   $end_times = date("Y",time())."-12"."-31 23:59:59";
					   $sql_times = " and ld_workreport.createdtime between '".$begin_times."' and '".$end_times."'";
					   break;
					case 'custom':
					   $datecategory_value = $_REQUEST['datecategory_value'];
					   $dates = explode('-',$datecategory_value);
					   $dates[0] = str_replace("/","-",$dates[0]);
					   $dates[1] = str_replace("/","-",$dates[1]);
					   if($dates[0] == $dates[1]){
							$sql_times = " and ld_workreport.createdtime like '%".$dates[0]."%'";
					   }else{
                           //ls 2021-10-29 0048501:（http://119.3.105.233:85/crm [^] ）（江苏森基）工作汇报模块中选择‘月计划’，在使用筛选查询九月一号到九月三十号的数据，没有结果，但是九月三十号是有一条数据的。
                           $sql_times = " and ld_workreport.createdtime between '".$dates[0]." 00:00:00' and '".$dates[1]." 23:59:59'";
					   }
					   break;
				}
				if(!empty($sql_times)){
					$sql .= $sql_times;
					$sqlcounts[1] .= $sql_times;
				}
			}
			if(!empty($_REQUEST['report_user_id'])){
				$_REQUEST['sponsor'] = $_REQUEST['report_user_id'];
			}
			//基本查询 - 发起人
			if(!empty($_REQUEST['sponsor'])){
				$sql .= ' and ld_workreport.smcreatorid in ('.$_REQUEST['sponsor'].')';
				$sqlcounts[1] .= ' and ld_workreport.smcreatorid in ('.$_REQUEST['sponsor'].')';
			}

            $sqlcount='select 1  from '.$sqlcounts[1] .' GROUP BY ld_workreport.workreportid ';


            $resultcount=$adb->pquery($sqlcount,$params);
            // echo $resultcount->sql;echo '<br><br>';die;
            $noofrows=$adb->num_rows($resultcount);
            $jsonArray['summary']['totalrows']=$noofrows;
            $mobile_pagerecordcount=20;
            $startpagenum=0;
            $endpagenum=$mobile_pagerecordcount;
            $startpagerecord=0;
            $endpagerecord=$mobile_pagerecordcount;
            $haveprevpage='yes';
            $havenextpage='yes';

            $totalpagecount=ceil ($noofrows/$mobile_pagerecordcount);
            if($totalpagecount*$mobile_pagerecordcount<$noofrows)
            {
                $totalpagecount+=1;
            }
        //if(!isset($_REQUEST['page']))
            if(empty($_REQUEST['page']))//gyqCom reason:改成为空判断 date:20170301
            {
                $_REQUEST['page']=1;
            }
            $startpagenum=$_REQUEST['page']-1;
            if($_REQUEST['page']>=$totalpagecount)//是否有下一页
            {
                $havenextpage='no';
                $startpagenum=$totalpagecount-1;
            }
            if($_REQUEST['page']<=1)//是否有上一页
            {
                $haveprevpage='no';
                $startpagenum=0;
            }


            $jsonArray['summary']['pagecount']=$totalpagecount;
            $jsonArray['summary']['havenextpage']=$havenextpage;
            $jsonArray['summary']['haveprevpage']=$haveprevpage;
            $jsonArray['summary']['curpagenum']=$startpagenum+1;
            $startpagerecord=$startpagenum*$mobile_pagerecordcount;
            $endpagerecord=$startpagerecord+$mobile_pagerecordcount;

            if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
                $sql .= " and ld_workreport.workreportid in (select workreportid from ld_workreport2user where userid = $userid) ";
            }
            $sql.=" GROUP BY ld_workreport.workreportid  order by ld_workreport.createdtime desc limit $startpagerecord, $mobile_pagerecordcount ";
      			// echo $sql;echo '<br><br>';
      			// echo '<pre>';
      			// print_r($params);
      			// echo '</pre>';
      			// die;

            $result=$adb->pquery($sql,$params);
            $entityContents=$this->createWorkRepotList($result);
            $jsonArray['report']=$entityContents;
            if($_REQUEST['weixin_mark'] != 1){
                $jsonArray['field'] = $this->getallFieldsForTable();
            }
            $jsonArray['permit'] = array('download'=>isPermitted('CooperativeWork','DownLoad',''),'preview'=>isPermitted('CooperativeWork','Preview',''));
            return $jsonArray;

    }
	protected function getWorkReportUser($workreportid){
	    global $adb;
		$alluser = 0;
		if(!empty($workreportid)){
			$query = 'select userid from ld_workreport2user where workreportid = ?';
			$result = $adb->pquery($query,array($workreportid));
			$num_rows = $adb->num_rows($result);
			for($i = 0; $i<$num_rows; $i++){
				if($adb->query_result($result,$i,'userid') == '-1'){
					$alluser = 1;
					break;
				}
			}
		}
		return $alluser;
	}
    protected function createWorkRepotList($result)
    {
        global $adb,$current_user,$PlatformMC;
        $languagetype = getLanguageType($current_user);
	    $entityContents=array();
		/**
		 * 获取自定义字段结果集
		 * @project 工作协同模板
		 * @author Tujt 2015-05-07
		 */
		$entity_type = 'workreport';//日志
		$workfldarr = $this->getWorkCfFieldInfo($entity_type);
		$workfldkeyarr = array();
		if(!empty($workfldarr)){
			$workfldkeyarr = array_keys($workfldarr);
		}
        //XUQIU20240725-04 工作汇报增加汇报日期和编辑时限控制（重庆正川）
        crm_load_class_file('WorkTemplateRule','modules/Settings');
        $workTemplateRuleobj = new WorkTemplateRule();

        /*
        if($PlatformMC['type']=='weixin'){
            crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
            $portObj = new cls_WeixinPort();//gyq_41
            $portObj->getAgentId();
            $ins_crm = 0;
            if(array_key_exists('ldcrm',$portObj->agentid)){
                $install_ldcrm = 1;
            }
        }*/
        $saleskit_listinfo_all = [];
		for($i=0;$i<$adb->num_rows($result);$i++)
		{
			$sendlog_class = '';
			$lastname=$adb->query_result($result,$i,'usercreator');
            $wx_userid=$adb->query_result($result,$i,'usercreator_wx_userid');
            $userobj=new Users();
            $userobj->wx_userid=$wx_userid;
            $userobj->last_name=$lastname;
            $lastname=getUserlastName($userobj);//企业微信kehu001

			$userid=$adb->query_result($result,$i,'userid');
            $Obj=new RecordEncrypt("User",$userid);
            $strencrypt= $Obj->encrypt();
			$attachmentsid=$adb->query_result($result,$i,'attachmentsid');
			$path=$adb->query_result($result,$i,'path');
			$userimagename=$adb->query_result($result,$i,'userimagename');
		  $storage_location=$adb->query_result($result,$i,'storage_location');
          if($storage_location == 'cos'){
            $userfilepath=$adb->query_result($result,$i,'cloud_path');
          }
          else{
            $userfilepath=$this->getUserImage($path,$userimagename,$attachmentsid,$userid);
          }
			$entitytype=$adb->query_result($result,$i,'entitytype');
			$type=$adb->query_result($result,$i,'type');
            if($entitytype == 'weibo'){
                $reporttype='ItemWeibo';
                $rule_reporttype = 'weibo';
            }
            else if($entitytype == 'cocmd'){
                $reporttype='ItemCocmd';
                $rule_reporttype = 'cocmd';
            }
            else if($entitytype == 'workreport'){
                if($type == 1) {
                    $reporttype = 'ItemLogday';
                    $rule_reporttype = 'day';
                }
                else if($type == 2) {
                    $reporttype = 'ItemLogweek';
                    $rule_reporttype = 'week';
                }
                else if($type == 3) {
                    $reporttype = 'ItemLogmonth';
                    $rule_reporttype = 'month';
                }
            }
			$createDateTime=$adb->query_result($result,$i,'createdtime');
			$timedescription=$this->getTimeDescription($createDateTime);
			$worksummary=$adb->query_result($result,$i,'worksummary');
      if(is_null($worksummary)){
        $worksummary='';
      }
			$sendlog_workdate = $adb->query_result($result,$i,'sendlog_workdate');
			$saleskit_day = $adb->query_result($result,$i,'saleskit_day');
            $saleskit_showtype = $adb->query_result($result,$i,'saleskit_showtype');
            $tmp_saleskit_listinfo = html_entity_decode((string)$adb->query_result($result,$i,'saleskit_listinfo'));
            $saleskit_listinfo = ldcrm_json_decode($tmp_saleskit_listinfo);

            if (!empty($saleskit_listinfo) && is_array($saleskit_listinfo)){
                $saleskit_listinfo_all = array_merge($saleskit_listinfo_all,$saleskit_listinfo);
            }
      if(is_null($saleskit_day)){
        $saleskit_day='';
      }
      if(is_null($saleskit_listinfo)){
          $saleskit_listinfo = '';
      }
			$saleskit_month = $adb->query_result($result,$i,'saleskit_month');
      if(is_null($saleskit_month)){
        $saleskit_month='';
      }
			$saleskit_week = $adb->query_result($result,$i,'saleskit_week');
      if(is_null($saleskit_week)){
        $saleskit_week='';
      }
			$workplan=$adb->query_result($result,$i,'workplan');
			if(is_null($workplan)){
				$workplan='';
			}
			$workexperience=$adb->query_result($result,$i,'workexperience');
			if(is_null($workexperience)){
				$workexperience='';
			}
			$workplan_tuesday=$adb->query_result($result,$i,'workplan_tuesday');
			if(is_null($workplan_tuesday)){
				$workplan_tuesday='';
			}
			$workplan_wednesday=$adb->query_result($result,$i,'workplan_wednesday');
			if(is_null($workplan_wednesday)){
				$workplan_wednesday='';
			}
			$workplan_thursday=$adb->query_result($result,$i,'workplan_thursday');
			if(is_null($workplan_thursday)){
				$workplan_thursday='';
			}
			$workplan_friday=$adb->query_result($result,$i,'workplan_friday');
			if(is_null($workplan_friday)){
				$workplan_friday='';
			}
            $signaddress=$adb->query_result($result,$i,'signaddress');
			if(is_null($signaddress)){
				$signaddress='';
			}
			$praisecount=$adb->query_result($result,$i,'praisecount');
            $editcount=$adb->query_result($result,$i,'editcount');
			$replycount=$adb->query_result($result,$i,'replycount');
			$workreportid=$adb->query_result($result,$i,'workreportid');
			$approved=$adb->query_result($result,$i,'approved');

			if($this->getWorkReportUser($workreportid) == 1){
				$userscope = get_user_array(FALSE, "", '');
				$allUserNum = 0;
				foreach($userscope as $userid=>$userinfo){
					$allUserNum++;
				}
				//echo $allUserNum . '--';echo '<br><br>';
				$usercount = $allUserNum;
			}else{
				$usercount=$adb->query_result($result,$i,'usercount')-1;//获取报告相关用户的数量,把包含自己的用户去除
			}
			$startDateTime=$adb->query_result($result,$i,'startdate');
            $startDateDescription='';
			if(!empty($startDateTime))
			{
				$startDateDescription=$this->getStartDateDescription($workreportid,$startDateTime);
			}
            if($praisecount>0)//判断当前用户是否已经点赞
			{
				$praisesql='select 1 from ld_praise where workreportid=? and userid=?';
				$praiseresult=$adb->pquery($praisesql,array($workreportid,$current_user->id));

				if($adb->num_rows($praiseresult)>0)//已经点赞
				{
					$praisecurrentuser='yes';
				}
				else
				{
					$praisecurrentuser='no';
				}
			}
			else
			{
				$praisecurrentuser='no';
			}
			$filename=$adb->query_result($result,$i,'filename');
			$filereportpath=$adb->query_result($result,$i,'filepath');
			//ld_workreport.longtitude,ld_workreport.latitude
			$longtitude=$adb->query_result($result,$i,'longtitude');
			$latitude=$adb->query_result($result,$i,'latitude');
			if(!empty($filename))
				 $workreportfilename=$filereportpath.'/'.$filename;
			else
				$workreportfilename='';
			$sql="select 'Accounts'  as relatedtab ,ld_account.accountname as name ,ld_workreportrelatedto.Relatedto
					from ld_workreportrelatedto 
					LEFT JOIN ld_account on ld_account.accountid=ld_workreportrelatedto.Relatedto
					  where workreportid=? and ld_account.deleted=0
					UNION 
					select 'Contacts'  as relatedtab ,ld_contactdetails.lastname as name ,ld_workreportrelatedto.Relatedto
					from ld_workreportrelatedto 
					LEFT JOIN ld_contactdetails on ld_contactdetails.contactid=ld_workreportrelatedto.Relatedto
					  where workreportid=? and ld_contactdetails.deleted=0
                    UNION 
					select 'Products'  as relatedtab ,ld_products.productname as name ,ld_workreportrelatedto.Relatedto
					from ld_workreportrelatedto 
					LEFT JOIN ld_products on ld_products.productid=ld_workreportrelatedto.Relatedto
					  where workreportid=? and ld_products.deleted=0";
			$resultrelated=$adb->pquery($sql,array($workreportid,$workreportid,$workreportid));
			$relatedModules = array();
			for($tmp_related=0;$tmp_related<$adb->num_rows($resultrelated);$tmp_related++)
			{
				$relatedtab=$adb->query_result($resultrelated,$tmp_related,'relatedtab');
				$relatedto=$adb->query_result($resultrelated,$tmp_related,'relatedto');
				$name=$adb->query_result($resultrelated,$tmp_related,'name');
                if($PlatformMC['type']=='weixin'){
                    if(isPermitted($relatedtab)=='yes'&&vtlib_isModuleActive($relatedtab)){
                        $relatedModules[$relatedtab][]=array('curid'=>$relatedto,'name'=>$name);
                    }
                }else{
                    $relatedModules[$relatedtab][]=array('curid'=>$relatedto,'name'=>$name);
                }
			}

			//查找日志批阅人、任务执行人、微博为空
			$sqlReader="select ld_workreport2user.workreportid,ld_workreport2user.userid,
						ld_workreport2user.user_type,ld_workreport2user.id,
						ld_users.last_name as readername,
                        ld_users.wx_userid as reader_wx_userid
						from ld_workreport2user 
						left join ld_users on ld_workreport2user.userid = ld_users.id
						where ld_workreport2user.workreportid = ? and ld_workreport2user.user_type = ? ";
			switch($entitytype)
			{
				case 'weibo': //微博
					$user_type = 0;
					break;
				case 'workreport': //日志
					$user_type = 5;
					break;
				case 'cocmd': //任务
					$user_type = 6;
					break;
			}
			if($entitytype != 'weibo'){
				$sqlReaderResult=$adb->pquery($sqlReader,array($workreportid,$user_type));
				$reader=$adb->query_result($sqlReaderResult,0,'userid');
                $readername=$adb->query_result($sqlReaderResult,0,'readername');
                $userobj=new Users();
                $userobj->wx_userid=$adb->query_result($sqlReaderResult,0,'reader_wx_userid');
                $userobj->last_name=$readername;
                $userobj->id=$reader;
                $readername=getUserlastName($userobj);

			}
            if($reader==null||$reader==''){
                $reader='';
            }
            if($readername==null||$readername==''){
                $readername='';
            }
            if(empty($usercount)){//如果该工作报告没有抄送范围和@,则显示点评人的名称
                $usercount=$readername;
            }
            else{
                $usercount=$usercount.getFixedLabel('COLLEAGUES');
            }
            if($usercount==''){
                //wyt 221123 BUG0059065 工作汇报，微博，当前用户抄送给自己发布后，抄送人员显示错误（邱：这个应该是翻译没有了，可以看看数据库有没有相关的）
                $usercount = getFixedLabel('BETOVIEWABLEPRIVATE');
            }
            //editor:yang0626
            $isEdit = 'no';
            if ($current_user->id == $adb->query_result($result,$i,'smcreatorid') && $approved==0) {
                //XUQIU20240725-04 工作汇报增加汇报日期和编辑时限控制（重庆正川） 根据编辑时限控制
                if ($entitytype == 'workreport'){
                    $editDateInfo = $workTemplateRuleobj->getReportEditDate($rule_reporttype);
                    $editDate = $editDateInfo['editDate'];
                    $minDate = $editDateInfo['minDate'];
                    $maxDate = $editDateInfo['maxDate'];
                    if ($editDate == 'no'){

                    }else if ($editDate == 'all' || $editDate == 'yes'){
                        $isEdit = 'yes';
                    }else{
                        $sendlog_workdate = $adb->query_result($result,$i,'sendlog_workdate');
                        if(strtotime($sendlog_workdate) >= strtotime($minDate)){
                            $isEdit = 'yes';
                        }
                    }
                }else{
                    $isEdit = 'yes';
                }
            }
            //editor:gyq_20191022 reason:删除按钮判断修改  2019/10/22 14:28
            //0038312: （落落计划）企业微信>灵当CRM>工作汇报：当发布的日志被点评或者回复后【删除】按钮应该隐藏起来，电脑端是正常的。（需要补丁）
            $isDel = 'no';
            if ($current_user->id == $adb->query_result($result,$i,'smcreatorid') && $replycount == 0) {
                $isDel = 'yes';
            }
            /* if($current_user->id!=$adb->query_result($result,$i,'smcreatorid')){
		      $isDel='no';
		   }
		   else{
			 $isDel='yes';
		   }*/
		   if($entitytype == 'workreport' && $reader==$current_user->id&&$approved==0)
				$readerbutton='yes';
		   else
				$readerbutton='no';
		   //关联图片
            $workachment = $this->getWorkAchmentInfo($workreportid);
            $entitytypename = '';
            $workreportstatus = '';
            $workreportstatusclass = '';
            if($entitytype=='weibo'){
                $entitytypename = getFixedLabel('BLOG');
                $workreportstatusclass = 'ui-hide';
				$sendlog_class = "plan-icon-blue";
            }
            else if($entitytype=='cocmd'){
                $entitytypename = getFixedLabel('TASK');
				$sendlog_class = "plan-icon-orange";
                if($approved==0){
                    if(strtotime(date('Y-m-d H:i:s'))<strtotime($startDateTime)){
                        $workreportstatus = getFixedLabel('UNDERIMPLEMENTATION');
                    }else{
                        $workreportstatusclass = 'redFont';
                        $workreportstatus = getFixedLabel('TIMEDOUT');
                    }
                }
                else if($approved==1){
                    $workreportstatus = getFixedLabel('COMPLETED');
                    $workreportstatusclass = 'greenFont';
                }
                else if($approved==2){
                    $workreportstatus = getFixedLabel('CANCELED');
                    $workreportstatusclass = 'redFont';
                }
            }
            else if($entitytype=='workreport'){
				$sendlog_class = "plan-icon-green";
                if($type==1){
                    $entitytypename = getFixedLabel('JOURNAL');
                }
                else if($type==2){
                    $entitytypename = getFixedLabel('WEEKPLAN');
                }
                else if($type==3){
                    $entitytypename = getFixedLabel('MONTHPLAN');
                }
                if($approved==0){
                    $workreportstatus = '<p style="color: #ff8001;">'.getFixedLabel('NOCOMMENTS').'</p>';
                }
                else if($approved==1){
                    $workreportstatus = '<p style="color: #dd4b39;">'.getFixedLabel('REVIEWEDAPP').'</p>';
                    $workreportstatusclass = 'greenFont';
                }
            }
            if(!empty($PlatformMC)) $workreportstatus=strip_tags($workreportstatus);
            $ispraiseclass = 'good';//点赞和未点赞样式
            if($praisecurrentuser=='yes'){
                $ispraiseclass = 'gooded';
            }
            $strInfo='';//日志，任务内容前描述，微博没有描述
            if($entitytype == 'workreport'){
                switch ($type) {
                  case 2:
                    $timestr1Arr = explode(" ~ ", $sendlog_workdate);
                    if($languagetype == 'en'){
                        $timestr1_1 = date('Y-m-d', strtotime($timestr1Arr[0]));
                        $timestr1_2 = date('Y-m-d', strtotime($timestr1Arr[1]));
                        $strInfo = $timestr1_1."-".$timestr1_2." ".getFixedLabel('WEEKPLAN')." is reviewed by <span class=''>".$readername."</span>";
                    }else{
                        $timestr1_1 = date('Y年m月d日', strtotime($timestr1Arr[0]));
                        $timestr1_2 = date('Y年m月d日', strtotime($timestr1Arr[1]));
                        $strInfo = $timestr1_1."-".$timestr1_2." ".getFixedLabel('WEEKPLAN')."由<span class=''>".$readername."</span>点评";
                    }
                    break;
                  case 3:
                    $timestr2Arr = explode(" ~ ", $sendlog_workdate);
                    if($languagetype == 'en'){
                        $timestr2 = date('Y-m', strtotime($timestr2Arr[0]));
                        $strInfo = $timestr2." ".getFixedLabel('MONTHPLAN')." is reviewed by <span class=''>".$readername."</span>";
                    }else{
                        $timestr2 = date('Y年m月', strtotime($timestr2Arr[0]));
                        $strInfo = $timestr2." ".getFixedLabel('MONTHPLAN')."由<span class=''>".$readername."</span>点评";
                    }
                    break;
                  default:
                    if($languagetype == 'en'){
                        $timestr3 = date('Y-m-d', strtotime($sendlog_workdate));
                        $strInfo = $timestr3." ".getFixedLabel('JOURNAL')." is reviewed by <span class=''>".$readername."</span>";
                    }else{
                        $timestr3 = date('Y年m月d日', strtotime($sendlog_workdate));
                        $strInfo = $timestr3." ".getFixedLabel('JOURNAL')."由<span class=''>".$readername."</span>点评";
                    }

                    break;
                }
            }
            else if($entitytype == 'cocmd'){
                if($languagetype == 'en'){
                    $strInfo = "This task is carried out by <span class=''>".$readername."</span>，".$startDateDescription;
                }else{
                    $strInfo = "该".getFixedLabel('TASK')."由<span class=''>".$readername."</span>执行，".$startDateDescription;
                }
            }
			//ld_workreport.longtitude,ld_workreport.latitude
			if(isset($_REQUEST['appversion']) && $_REQUEST['appversion']!=''){
            	$entity = array('userimage'=>$userfilepath,'username'=>$lastname,'userid'=>$userid,'encryptuserid'=>$strencrypt,'workreporttime'=>$timedescription,
                'entitytype'=>$entitytype,'entitytypename'=>$entitytypename,'workreporttype'=>$type,'reporttype'=>$reporttype,'workreportstatusclass'=>$workreportstatusclass,'workreportstatus'=>$workreportstatus,
                'summary'=>$worksummary,'workplan'=>$workplan,'experience'=>$workexperience,'workplan_tuesday'=>$workplan_tuesday,'workplan_wednesday'=>$workplan_wednesday,'workplan_thursday'=>$workplan_thursday,'workplan_friday'=>$workplan_friday,
                'signaddress'=>$signaddress,'longtitude'=>$longtitude,'latitude'=>$latitude,'editcount'=>$editcount,'replycount'=>$replycount,
                'praisecount'=>$praisecount,'ispraise'=>$praisecurrentuser,'ispraiseclass'=>$ispraiseclass,'approved'=>$approved,
				'Accounts'=>$relatedModules['Accounts'],'Contacts'=>$relatedModules['Contacts'],
                'Products'=>$relatedModules['Products'],'isEdit'=>$isEdit,'isDel'=>$isDel,
				'L'=>$workreportfilename,'curid'=>$workreportid,'reader'=>array('userid'=>$reader,'username'=>$readername,'startDateDescription'=>$strInfo),'readerbutton'=>$readerbutton,'workachment'=>$workachment,'sendlog_class' => $sendlog_class);
            }
            else{
                $entity = array('longtitude'=>$longtitude,'latitude'=>$latitude,'userimage'=>$userfilepath,'username'=>$lastname,'userid'=>$userid,'encryptuserid'=>$strencrypt,'workreporttime'=>$timedescription,
                'entitytype'=>$entitytype,'entitytypename'=>$entitytypename,'workreporttype'=>$type,'reporttype'=>$reporttype,'workreportstatusclass'=>$workreportstatusclass,'workreportstatus'=>$workreportstatus,
                'worksummary'=>$worksummary,'workplan'=>$workplan,'workexperience'=>$workexperience,'workplan_tuesday'=>$workplan_tuesday,'workplan_wednesday'=>$workplan_wednesday,'workplan_thursday'=>$workplan_thursday,'workplan_friday'=>$workplan_friday,
                'signaddress'=>$signaddress,'editcount'=>$editcount,'replycount'=>$replycount,'praisecount'=>$praisecount,'ispraise'=>$praisecurrentuser,'approved'=>$approved,
				'Accounts'=>$relatedModules['Accounts'],'Contacts'=>$relatedModules['Contacts'],
                'Products'=>$relatedModules['Products'],'isEdit'=>$isEdit,'isDel'=>$isDel,'relateUserDescription'=>$usercount,
				'L'=>$workreportfilename,'curid'=>$workreportid,'reader'=>array('userid'=>$reader,'username'=>$readername,'startDateDescription'=>$strInfo),'readerbutton'=>$readerbutton,'workachment'=>$workachment,'sendlog_class' => $sendlog_class,'sendlog_workdate'=> $sendlog_workdate,'saleskit_day'=> $saleskit_day,'saleskit_week'=> $saleskit_week,'saleskit_month'=> $saleskit_month,
                    'rule_reporttype'=>$rule_reporttype,'saleskit_showtype'=>$saleskit_showtype,'saleskit_listinfo'=>$saleskit_listinfo);
            }
            $this->init_outputStyle($entity,$entitytype,$saleskit_day,$saleskit_week,$saleskit_month,$type,$worksummary,$workplan,$workexperience,$workplan_tuesday,$workplan_wednesday,$workplan_thursday,$workplan_friday,$workfldkeyarr,$adb,$result,$i);
            /**
			 * 获取自定义字段的值
			 * @project 工作协同模板
			 * @author Tujt 2015-05-07
			 */
			$entityContents[] = $entity;
		}
        $entityContents = $this->changeSalesKitListinfoNewLabel($entityContents,$saleskit_listinfo_all);
		return $entityContents;
    }
    //editor:gyq_29 date:20170327 reason:格式化日志输出样式
    protected function init_outputStyle(&$entity,$entitytype,$saleskit_day,$saleskit_week,$saleskit_month,$type,$worksummary,$workplan,$workexperience,$workplan_tuesday,$workplan_wednesday,$workplan_thursday,$workplan_friday,$workfldkeyarr,$adb,$result,$i){
        if(!empty($worksummary)){
            $worksummary = str_replace("\n","<br>",$worksummary);
        }
		 if(!empty($saleskit_day)){
            $saleskit_day = str_replace("\n","<br>",$saleskit_day);
        }
		 if(!empty($saleskit_week)){
            $saleskit_week = str_replace("\n","<br>",$saleskit_week);
        }
		 if(!empty($saleskit_month)){
            $saleskit_month = str_replace("\n","<br>",$saleskit_month);
        }
        if(!empty($workplan)){
            $workplan = str_replace("\n","<br>",$workplan);
        }
        if(!empty($workexperience)){
            $workexperience = str_replace("\n","<br>",$workexperience);
        }
		if(!empty($workplan_tuesday)){
            $workplan_tuesday = str_replace("\n","<br>",$workplan_tuesday);
        }
		if(!empty($workplan_wednesday)){
            $workplan_wednesday = str_replace("\n","<br>",$workplan_wednesday);
        }
		if(!empty($workplan_thursday)){
            $workplan_thursday = str_replace("\n","<br>",$workplan_thursday);
        }
		if(!empty($workplan_friday)){
            $workplan_friday = str_replace("\n","<br>",$workplan_friday);
        }
		$entity['saleskit_day'] = $saleskit_day;
		$entity['saleskit_week'] = $saleskit_week;
		$entity['saleskit_month'] = $saleskit_month;
        $entity['worksummary'] = $worksummary;
        $entity['workplan']=$workplan;
        $entity['workexperience'] = $workexperience;
		$entity['workplan_tuesday'] = $workplan_tuesday;
		$entity['workplan_wednesday'] = $workplan_wednesday;
		$entity['workplan_thursday'] = $workplan_thursday;
		$entity['workplan_friday'] = $workplan_friday;
        if(!empty($workfldkeyarr)&&$entitytype=='workreport'){
            foreach($workfldkeyarr as $workfld){
                $value = $adb->query_result($result,$i,$workfld);
                if(!empty($value)){
                    $value = str_replace("\n","<br>",$value);
                }else{
                    $value = '';
                }
                $entity[$workfld] = $value;
            }
        }
    }


    //将列表数据中的简报listinfo数据中的label更新
    public function changeSalesKitListinfoNewLabel($entityContents,$saleskit_listinfo_all){
        $moduleRecordLabel_arr = $this->getSalesKitListInfoLabel($saleskit_listinfo_all);
        foreach($entityContents as $key => &$entity){
            $saleskit_listinfo = $entity['saleskit_listinfo'];
            $saleskit_showtype = $entity['saleskit_showtype'];
            if($saleskit_showtype == 'html' && !empty($saleskit_listinfo)){
                foreach ($saleskit_listinfo as $tmp_index => &$listinfo){
                    foreach ($listinfo['list'] as $tmp_key => &$list){
                        foreach ($list['href'] as $tmp_i => &$hrefinfo){
                            $module = $hrefinfo['module'];
                            $record = $hrefinfo['record'];
                            if(isset($moduleRecordLabel_arr[$module]) && isset($moduleRecordLabel_arr[$module][$record])){
                                $hrefinfo['label'] = $moduleRecordLabel_arr[$module][$record];
                            }
                        }
                    }
                }
                $entity['saleskit_listinfo'] = $saleskit_listinfo;
                if (isset($entity['linedetail'])){
                    foreach ($entity['linedetail'] as $tmp_index =>$linedetail){
                        if (isset($linedetail['saleskit_showtype']) && $linedetail['saleskit_showtype'] == 'html'){
                            $entity['linedetail'][$tmp_index]['saleskit_listinfo'] = $entity['saleskit_listinfo'];
                            break;
                        }
                    }
                }
            }
        }
        return $entityContents;
    }

    //获取简报超链接形式中单据的新label
    public function getSalesKitListInfoLabel($saleskit_listinfo_all){
        global $adb;
        $module_recordarr = [];
        $module_columnarr = [];
        foreach ($saleskit_listinfo_all as $key => $listinfo){
            $list = $listinfo['list'];
            foreach ($list as $index => $listinfo){
                $href = $listinfo['href'];
                if(!empty($href)){
                    foreach ($href as $tmp_index => $hrefinfo){
                        $module_recordarr[$hrefinfo['module']][] = $hrefinfo['record'];
                        $module_columnarr[$hrefinfo['module']][] = $hrefinfo['columnname'];
                    }
                }
            }
        }
        unset($list,$href);
        $moduleRecordLabel_arr = [];
        foreach ($module_recordarr as $module => $record_arr){
            if (!empty($record_arr)){
                $tmp_focus = CRMEntity::getInstance($module);
                $tmp_tableindex = $tmp_focus->table_index;
                $tmp_tablename = $tmp_focus->table_name;
                $tmp_tablecf_name = $tmp_focus->customFieldTable[0];
                $tmp_tablecf_index = $tmp_focus->customFieldTable[1];
                $entityfield = getEntityField($module);
                $hreffieldfieldname = $entityfield['fieldname'];
                $hreffieldtablename = $entityfield['tablename'];
                $sql = 'select '.$tmp_tablename.'.'.$tmp_tableindex.','.$hreffieldtablename.'.'.$hreffieldfieldname.' from '.$tmp_tablename.' left join '.$tmp_tablecf_name.' on '.$tmp_tablecf_name.'.'.$tmp_tablecf_index.'='.$tmp_tablename.'.'.$tmp_tableindex.' where '.$tmp_tablename.'.'.$tmp_tableindex.' in ('.implode(',',$record_arr).')';
                $result = $adb->pquery($sql,array());
                $record_label = $adb->query_result_all($result);
                $record_label = array_column($record_label,$hreffieldfieldname,$tmp_tableindex);
                if (!empty($record_label)){
                    $moduleRecordLabel_arr[$module] = $record_label;
                }
            }
        }
        unset($saleskit_listinfo_all,$module_recordarr,$module_columnarr,$tmp_focus,$tmp_tableindex,$tmp_tablename,$tmp_tablecf_name,$tmp_tablecf_index,$entityfield);
        unset($hreffieldfieldname,$hreffieldtablename,$sql,$result,$record_label);
        return $moduleRecordLabel_arr;
    }
	/**
	 * 获取关联图片信息
	 * @author Tujt 2015-02-10
	 */
	public function getWorkAchmentInfo($workreportid) {
		global $adb;
		static $static_workachment_arr;//防止重复执行
		$workachment = array();
		if(!empty($static_workachment_arr) && isset($static_workachment_arr[$workreportid])){
			$workachment = $static_workachment_arr[$workreportid];
		}else{
			$workachmentquery = 'SELECT achmentid,name,type,path,size,newfile_name,storage_location,cloud_path FROM ld_workachments 
					WHERE workreportid = ? ORDER BY achmentid;';
			$workachmentresult = $adb->pquery($workachmentquery,array($workreportid));
			$workachmentrows = $adb->num_rows($workachmentresult);
			if($workachmentrows > 0){
				for($i=0;$i<$workachmentrows;++ $i){
					$achmentid = $adb->query_result($workachmentresult,$i,'achmentid');
					$achmentname = $adb->query_result($workachmentresult,$i,'name');
                    $newfile_name = $adb->query_result($workachmentresult,$i,'newfile_name');
                        if($newfile_name == ''){
                            $newfile_name = $achmentname;
                        }
					$imgtype = $adb->query_result($workachmentresult,$i,'type');
					$achmentpath = trim($adb->query_result($workachmentresult,$i,'path'));
                    $achmentsize= trim($adb->query_result($workachmentresult,$i,'size'));
                    $storage_location=$adb->query_result($workachmentresult,$i,'storage_location');
                    $cloud_path=$adb->query_result($workachmentresult,$i,'cloud_path');
                    //$strlen=strlen($achmentpath);
                    //$lastfile=substr($achmentpath,$strlen,1);
                    if(strrchr($achmentpath,'/')!='/')
                    {
                        $achmentpath.='/';
                    }
                    $workachment[$imgtype][$achmentid]['file_name']['value'] = $achmentname;
                    $workachment[$imgtype][$achmentid]['newfile_name']['value'] = $newfile_name;
                    $workachment[$imgtype][$achmentid]['name']['value'] = urlencode($achmentname);
                    $workachment[$imgtype][$achmentid]['path']['value'] = $achmentpath;
                    $workachment[$imgtype][$achmentid]['storage_location']['value'] = urlencode($storage_location);
                    $workachment[$imgtype][$achmentid]['cloud_path']['value'] = !empty($cloud_path)?urlencode($cloud_path):'';
                    if($achmentsize<1024*1024){
                        $workachment[$imgtype][$achmentid]['size']['value'] = number_format($achmentsize/1024,2).'KB';
                    }else{
                        $workachment[$imgtype][$achmentid]['size']['value'] = number_format($achmentsize/1024/104,2).'M';
                    }
				}
			}
			$static_workachment_arr[$workreportid] = $workachment;
		}
		if(!empty($workachment)) return $workachment;
		return '';
	}
    /**
     * edit:can
     * reason:时间描述
     * */
    function getTimeDescription($createDateTime)
    {
		 $timedescription=date("m月d日 H:i",strtotime($createDateTime));
		 return $timedescription;
       $nowdate=date("Y-m-d");
       $nowtime=date("H:i:s");
       $nowhour=date("H");
       $nowminute=date("i");
       $nowsecond=date("s");

       $createdate=date("Y-m-d",strtotime($createDateTime));
       $createdtime=date("H:i:s",strtotime($createDateTime));
       if(date('Y-m-d',strtotime($createDateTime))!=$nowdate)//发布时间不等于今天，
       {
            $timedescription=date("m月d日 H:i",strtotime($createDateTime));
       }
       else
       {
            $createdhour=date("H",strtotime($createdtime));
            $createdminute=date("i",strtotime($createdtime));
            $createsecond=date("s",strtotime($createdtime));
            $minushour=$nowhour-$createdhour;//小时
            $minusminute=$nowminute-$createdminute;
            $minussecond=$nowsecond-$createdsecond;
            if($minushour>0&&$minusminute>=0)//
            {
                $timedescription="今天".date("H:i",strtotime($createdtime));
            }
            else if($minusminute!=0)
            {
                         if($minusminute<0)
                             $minusminute=60+$minusminute;
                        $timedescription=$minusminute."分钟前";
            }
            else if($minussecond>=0)
            {
                        $timedescription=$minussecond.'秒前';
            }
       }

       return $timedescription;
    }

    /**
     * edit:diony
     * reason:任务时间描述
     * */
    function getStartDateDescription($workreportid,$startDateTime)
    {
        global $adb;
        $startDateDescription = '';
        $sql = "select ld_workreply.createdtime,ld_workreport.approved from ld_workreply left join ld_workreport 
                on ld_workreply.workreportid = ld_workreport.workreportid
                where ld_workreply.workreportid = ? and ld_workreport.entitytype = 'cocmd' and ld_workreport.approved in (1,2)";
        $result = $adb->pquery($sql,array($workreportid));
		if($adb->num_rows($result)>0)
        {
            $finishtime = $adb->query_result($result,0,'createdtime');
            $approved = $adb->query_result($result,0,'approved');
            if($approved == '1')
            {
                $startDateDescription = "该".getFixedLabel('TASK')."已于".$this->getDateDescription($finishtime)."完成。";
            }
            else if($approved == '2')
            {
                $startDateDescription = "该".getFixedLabel('TASK')."已于".$this->getDateDescription($finishtime)."取消。";
            }
        }
        else
        {
            $startDateDescription = "应于".$this->getDateDescription($startDateTime)."前完成，";
            if(strtotime(date('Y-m-d H:i:s'))<strtotime($startDateTime))
            {
                $startDateDescription .= '该'.getFixedLabel('TASK').'正在执行。';
            }
            else
            {
                $startDateDescription .= "<span style='color:red;'>该".getFixedLabel('TASK')."已超时。</span>";
            }
        }
        return $startDateDescription;
    }

    /**
     * edit:diony
     * reason:时间描述
     * */
    function getDateDescription($dateTime)
    {
        $info = '';
        $nowdate=date("Y-m-d");
        $date=date("Y-m-d",strtotime($dateTime));
        $time=date("H:i",strtotime($dateTime));
        $days = (strtotime($date)-strtotime($nowdate))/3600/24;
        if($days == '-2')
        {
            $info = '前天 '.$time;
        }
        else if($days == '-1')
        {
            $info = '昨天 '.$time;
        }
        else if($days == '0')
        {
            $info = '今天 '.$time;
        }
        else if($days == '1')
        {
            $info = '明天 '.$time;
        }
        else if($days == '2')
        {
            $info = '后天 '.$time;
        }
        else
        {
            if(date("Y",strtotime($dateTime))==date("Y"))
            {
                $info = date("m月d日",strtotime($dateTime)).' '.$time;
            }
            else
            {
                $info = date("Y年m月d日",strtotime($dateTime)).' '.$time;
            }
        }
        return $info;
    }

    /**
     * edit:can
     * reason:获取点评弹出框内容
     * */
    function createreaderPop()
    {
        global $adb;
        $workreportid=$_REQUEST['workreportid'];
        $sql="select ld_workreport_field.name,ld_workreport_field.label from ld_workreport
         inner join ld_workreport_field on ld_workreport_field.type=ld_workreport.type
          where workreportid=?  and ld_workreport_field.deleted=0 and tablename='ld_workreportcf' order by  sequence asc";
        $result=$adb->pquery($sql,array($workreportid));
        $rows=$adb->num_rows($result);
        $selectscfcols=array();
        // ljj 20231110 BUG0075328 工作汇报，日志点评时，自定义字段的数据没有显示出来，且最后两个字段的空白行显示undefined
        $labelvaluesql="select * from ld_workreportcf where workreportid=?";
        $labelvalueresult=$adb->pquery($labelvaluesql,array($workreportid));
        for($i=0;$i<$rows;$i++)
        {
            $columname=$adb->query_result($result,$i,'name');
            $label=$adb->query_result($result,$i,'label');
            $selectscfcols[]="ld_workreportcf.".$columname;
            $labelvalue=$adb->query_result($labelvalueresult,0,$columname);
            $labelvalue=empty($labelvalue)?'':$labelvalue;
            $scflabelcols[]=array('col'=>$columname,'label'=>$label,'value'=>$labelvalue);
            $scfcols[]=$columname;
        }
		//chj 2021/1/5 41744: （61mis.com/kfbcrm）工作汇报：点评日志没有根据系统设置中来显示
		$sql="select ld_workreport_field.name,ld_workreport_field.label,tablename from ld_workreport
         inner join ld_workreport_field on ld_workreport_field.type=ld_workreport.type
          where workreportid=?  and ld_workreport_field.deleted=0 and ld_workreport_field.is_activate = 0 and tablename in ('ld_wordreport','ld_workreport') and `name` not in ('saleskit_week','signaddress','saleskit_day','saleskit_month') order by  sequence asc";
        $result=$adb->pquery($sql,array($workreportid));
        $rows=$adb->num_rows($result);
        $selectscfcols=array();
        for($i=0;$i<$rows;$i++)
        {
             $columname=$adb->query_result($result,$i,'name');
             $label=$adb->query_result($result,$i,'label');
            $scflabelcols_old[]=array('col'=>$columname,'label'=>$label);

        }
        //if(sizeof($selectscfcols)>0&&empty($selectscfcols[0]))
        //{
            $selectscfcols[]="ld_workreportcf.workreportid ";
        //}
        $sql='select ld_workreport.entitytype,ld_workreport.type,ld_users.last_name,ld_users.wx_userid, worksummary,workplan,workexperience,workplan_tuesday,
		workplan_wednesday,
		workplan_thursday,
		workplan_friday,
                ld_workreport.smcreatorid,ld_attachments.attachmentsid,ld_attachments.path,ld_workreport.approved,
                ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,ld_workreport.createdtime ,';
           $sql.=implode(",",$selectscfcols)    ;

            $sql.='     from ld_workreport 
                 left join ld_users on ld_users.id=ld_workreport.smcreatorid
                 left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
                 left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
                 left join ld_workreportcf on ld_workreportcf.workreportid=ld_workreport.workreportid
                 where ld_workreport.workreportid=? ';

        $result=$adb->pquery($sql,array($workreportid));

          $attachmentsid=$adb->query_result($result,0,'attachmentsid');
          $path=$adb->query_result($result,0,'path');
          $userimagename=$adb->query_result($result,0,'userimagename');
          $storage_location=$adb->query_result($result,0,'storage_location');
          $smcreatorid=$adb->query_result($result,0,'smcreatorid');
          if($storage_location == 'cos'){
            $userfilepath=$adb->query_result($result,0,'cloud_path');
          }
          else{
            $userfilepath=$this->getUserImage($path,$userimagename,$attachmentsid,$smcreatorid);
          }
          $entityContent['userimage']=$userfilepath;

       $entityContent['summary']=$adb->query_result($result,0,'worksummary');
       $entityContent['workplan']=$adb->query_result($result,0,'workplan');
       $entityContent['experience']=$adb->query_result($result,0,'workexperience');
		$entityContent['workplan_tuesday']=$adb->query_result($result,0,'workplan_tuesday');
		$entityContent['workplan_wednesday']=$adb->query_result($result,0,'workplan_wednesday');
		$entityContent['workplan_thursday']=$adb->query_result($result,0,'workplan_thursday');
		$entityContent['workplan_friday']=$adb->query_result($result,0,'workplan_friday');
		$entityContent['summary'] = strtr($entityContent['summary'],array("\n"=>"<br>"));
	   $entityContent['workplan'] = strtr($entityContent['workplan'],array("\n"=>"<br>"));
	   $entityContent['experience'] = strtr($entityContent['experience'],array("\n"=>"<br>"));
       for($i=0;$i<$rows;$i++)
       {
            $columnname=$scfcols[$i];
            $entityContent[$columnname]=$adb->query_result($result,0,$columnname);
            $entityContent[$columnname]=strtr($entityContent[$columnname],array("\n"=>"<br>"));
       }
       $i=0;
       $entitytype=$adb->query_result($result,$i,'entitytype');

       $type=$adb->query_result($result,$i,'type');
       $createDateTime=$adb->query_result($result,$i,'createdtime');
       $approved=$adb->query_result($result,$i,'approved');
       $timeDescription=$this->getTimeDescription($createDateTime);
       $entityContent['timeDescription']=$timeDescription;
       $entityContent['entitytype']=$entitytype;
       $entityContent['workreporttype']=$type;
       $last_name=$adb->query_result($result,0,'last_name');
       $wx_userid=$adb->query_result($result,0,'wx_userid');
       $userobj=new Users();
       $userobj->wx_userid=$wx_userid;
       $userobj->last_name=$last_name;
       $entityContent['username']=getUserlastName($userobj);
       $entityContent['workreport']=$workreportid;
       $entityContent['approved']=$approved;
       $entityContent['scfcolumnlabe']=$scflabelcols;
	   $entityContent['old_scfcolumnlabe']=$scflabelcols_old;
       return $entityContent;
    }


    /**
     * edit:diony
     * reason:获取转发弹出框内容
     * */
    function createforwardPop()
    {
        global $adb;
        $workreportid=$_REQUEST['workreportid'];
        $sql='select ld_workreport.entitytype,ld_workreport.type,ld_users.last_name, worksummary,workplan,workexperience,
                ld_workreport.smcreatorid,ld_attachments.attachmentsid,ld_attachments.path,
                ld_attachments.newfile_name as userimagename,ld_attachments.cloud_path,ld_attachments.storage_location,ld_workreport.createdtime
                 from ld_workreport 
                 left join ld_users on ld_users.id=ld_workreport.smcreatorid
                 left join ld_salesmanattachmentsrel on   ld_users.id=ld_salesmanattachmentsrel.smid
                 left  join ld_attachments on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
                 where workreportid=? ';
        $result=$adb->pquery($sql,array($workreportid));

        $attachmentsid=$adb->query_result($result,0,'attachmentsid');
        $path=$adb->query_result($result,0,'path');
        $userimagename=$adb->query_result($result,0,'userimagename');
        $storage_location=$adb->query_result($result,0,'storage_location');
        $smcreatorid=$adb->query_result($result,0,'smcreatorid');
        if($storage_location == 'cos'){
            $userfilepath=$adb->query_result($result,0,'cloud_path');
        }
        else{
            $userfilepath=$this->getUserImage($path,$userimagename,$attachmentsid,$smcreatorid);
        }
        $entityContent['userimage']=$userfilepath;
        $entityContent['summary']=$adb->query_result($result,0,'worksummary');
        $entityContent['workplan']=$adb->query_result($result,0,'workplan');
        $entityContent['experience']=$adb->query_result($result,0,'workexperience');
        $entityContent['summary'] = strtr($entityContent['summary'],array("\n"=>"<br>"));
        $entityContent['workplan'] = strtr($entityContent['workplan'],array("\n"=>"<br>"));
        $entityContent['experience'] = strtr($entityContent['experience'],array("\n"=>"<br>"));
        $entitytype=$adb->query_result($result,0,'entitytype');
        $type=$adb->query_result($result,0,'type');
        $createDateTime=$adb->query_result($result,0,'createdtime');
        $timeDescription=$this->getTimeDescription($createDateTime);
        $entityContent['timeDescription']=$timeDescription;
        $entityContent['entitytype']=$entitytype;
        $entityContent['workreporttype']=$type;
        $entityContent['username']=$adb->query_result($result,0,'last_name');
        $entityContent['workreport']=$workreportid;
        return $entityContent;
    }

    /**
     * 获取所有用户信息
     * @author Tujt 2015-02-05
     */
    //gyqTE 如何处理好和PC端getUserArrayWX的关系？   D:\wamp\www\ldcrm\modules\Home\WorkReportModel.php
    public function getUserArray() {
        global $adb;
        $searchcontent = $_REQUEST['searchcontent'];
        $Jurisdiction = $_REQUEST['Jurisdiction'];
        if($Jurisdiction=='yes'){
            $Smownerids= getCurSmOwnerSearchScope('OftenUseReport');
            foreach($Smownerids['UserCombo']as $userid=>$userinfo)
            {
                if($userids == "")
                {
                    $userids .=$userid;
                }
                else
                {
                    $userids .=",".$userid;
                }
            }
            $where='  and ld_users.id in ( '.$userids.' )';
        }
        //AND ld_users.status = "Active"    gyq_45
        $query = 'SELECT ld_users.id as userid, ld_users2group.groupid,ld_users.email1,ld_users.wx_userid,ld_users.user_name as username,
                           ld_users.last_name as lastname,ld_users.real_name as realname,
                      ld_users.userlevel,ld_profile.profilename,ld_users.phone_mobile,ld_users.phone_home,
                           ld_attachments.`path` as userimgpath,
                           ld_attachments.newfile_name as userimgname,ld_attachments.cloud_path,ld_attachments.storage_location,
                           ld_attachments.attachmentsid,ld_users.status,
                           GROUP_CONCAT(ld_groups.groupname order by ld_groups.groupid SEPARATOR \';\') as groupname,
                           GROUP_CONCAT(ld_groups.groupid order by ld_groups.groupid SEPARATOR \';\') as groupid
                    FROM ld_users
                      LEFT JOIN ld_profile ON ld_users.profileid = ld_profile.profileid
                      LEFT JOIN ld_salesmanattachmentsrel
                        ON ld_users.id = ld_salesmanattachmentsrel.smid
                      LEFT JOIN ld_attachments
                        ON ld_attachments.attachmentsid = ld_salesmanattachmentsrel.attachmentsid
                      LEFT JOIN (
                            select GROUP_CONCAT(groupid) as groupid,userid from ld_users2group GROUP BY userid
                    ) as ld_users2group on ld_users2group.userid=ld_users.id
                      LEFT JOIN ld_groups on ld_groups.groupid=ld_users2group.groupid
                    WHERE ld_users.deleted = 0 ';
        $iskehu001='no';
        if($searchcontent!='')
        {
            $searchuser_arr=array();
            $iskehu001=isKehu001ServerPc();
           if($iskehu001=='yes')
           {
              crm_load_class_file("cls_WeixinPort", 'WeiXinApp/WeiXin_common');
                $port_obj = new cls_WeixinPort();//Eidtor:gyq_63 Reason:接口支持多应用管理 Date:2018/3/2 0002 下午 1:21
                $wx_userarr =$port_obj->getwxUserid('like',$searchcontent);

                if(array_key_exists('userid',$wx_userarr))
                {
                        $searchuser_arr=$wx_userarr['userid'];

                }
                if(!empty($searchuser_arr)){
                     $tmp_arr=[];
                    foreach($searchuser_arr as $tmpwx_userid)
                    {
                        $tmp_arr[]="'".$tmpwx_userid."'";
                    }
                 $query .= " and ld_users.wx_userid in (".implode(",",$tmp_arr).')';
                  //  $query .= " and find_in_set(ld_users.wx_userid,?)";
                   // $param=$searchuser_arr;
                }
                else{
                    $query.= ' and ld_users.id <=0';

                }
           }
           else
                 $query .= " and ld_users.last_name like '%$searchcontent%' ";

        }

        /*editor:gyq_29 date:20170328 reason:代码优化*/
        $query = $this->ishighseaallocate($query,$where,$Jurisdiction);
        //$query .= " ORDER BY id ASC ";
        $query .= " group by ld_users.id ORDER BY convert(lastname using gbk) ASC";

        $result = $adb->pquery($query,array());
        $rows = $adb->num_rows($result);

        $userarr = array();
        if($rows > 0){
            $userobj=new Users();
            for($i=0;$i<$rows;++ $i){
                $groupid = $adb->query_result($result,$i,'groupid');
                $email1 = $adb->query_result($result,$i,'email1');
                $wx_userid = $adb->query_result($result,$i,'wx_userid');
                $userarr[$i]['display']='yes';
                if($iskehu001=='yes'&&$searchcontent!=''){
                    if(!in_array($wx_userid,$searchuser_arr)){
                        $userarr[$i]['display']='no';
                    }
                }
                $userid = $adb->query_result($result,$i,'userid');
                $username = $adb->query_result($result,$i,'username');
                $lastname = $adb->query_result($result,$i,'lastname');
                $realname = $adb->query_result($result,$i,'realname');
                $profilename = $adb->query_result($result,$i,'profilename');
                if($profilename==null){
                    $profilename = '';
                }
                $userlevel = $adb->query_result($result,$i,'userlevel');
                if($userlevel==null){
                    $userlevel = '';
                }
                $phone_mobile = $adb->query_result($result,$i,'phone_mobile');
                $phone_home = $adb->query_result($result,$i,'phone_home');
                $userimgpath = $adb->query_result($result,$i,'userimgpath');
                $userimgname = $adb->query_result($result,$i,'userimgname');
                $storage_location=$adb->query_result($result,$i,'storage_location');
                $attachmentsid = $adb->query_result($result,$i,'attachmentsid');
                $status = $adb->query_result($result,$i,'status');
                if($storage_location == 'cos'){
                  $userfilepath = $adb->query_result($result, $i, 'cloud_path');
                }
                else{
                  $userfilepath=$this->getUserImage($userimgpath,$userimgname,$attachmentsid,$userid);
                }
                $groupname=$adb->query_result($result,$i,'groupname');
                $groupid=$adb->query_result($result,$i,'groupid');
                $groupid_array=empty($groupid) ? [] : explode(";",$groupid);
                $groupname_array=empty($groupname) ? [] : explode(';',$groupname);
                $arr_groupname=array();
                foreach($groupid_array as $tmpgroupindex=>$tmpgroupid){
                    $groupobj=new Users();
                    $groupobj->groupid=$tmpgroupid;
                    $groupobj->groupname=$groupname_array[$tmpgroupindex];
                    $arr_groupname[]=getWx_GroupName($groupobj);

                }
                $groupname=implode(';',$arr_groupname);
                /*if(empty($groupname)&& $_REQUEST['weixin_mark'] != 'txl'){//gyq_52 20171206 注册定制化 需要返回部门为空的用户
                    continue;
                }*/

                $userarr[$i]['userid']['value'] = $userid;
                $userarr[$i]['username']['value'] = $username;

                $userobj->wx_userid=$wx_userid;
                $userobj->last_name=$lastname;
                $userarr[$i]['lastname']['value'] = getUserlastName($userobj);
                $userarr[$i]['realname']['value'] = $realname;
                $userarr[$i]['profilename']['value'] = $profilename;
                $userarr[$i]['userlevel']['value'] = $userlevel;
                $userarr[$i]['phone_mobile']['value'] = $phone_mobile;
                $userarr[$i]['phone_home']['value'] = $phone_home;
                $userarr[$i]['userimgpath']['value'] = $userfilepath;
                $userarr[$i]['userimgname']['value'] = $userfilepath;
                $userarr[$i]['status']['value'] = $status;
                $userarr[$i]['groupname']['value'] = $groupname;
                $userarr[$i]['groupid']['value'] = $groupid;
                $userarr[$i]['email']['value'] = $email1;
                $userarr[$i]['wx_userid']['value'] = $wx_userid;

                if(!empty($groupname)&&!empty($profilename)){
                    $description = $profilename.'-'.$groupname;
                }else{
                    $description = $profilename.$groupname;
                }
                $description = empty($description)?'':$description;
                $userarr[$i]['description']['value'] = $description;
            }
        }

        if(!empty($userarr)) return $userarr;
        return '';
    }

    /*editor:gyq_29 date:20170328 reason:代码优化  微信端重载此方法*/
    protected function ishighseaallocate($query,$where,$Jurisdiction)
    {
        if($Jurisdiction=='yes'){
            return $query.$where;
        }else{
            return $query;
        }
    }
	/**
	 * 获取部门对应用户
	 * @author Tujt 2015-02-02
	 */
	public function getGroupUserInfo() {
	    global $adb;
	    $searchcontent = $_REQUEST['searchcontent'];
		$query = 'SELECT ld_groups.groupid,ld_groups.groupname FROM ld_groups ';
        if($searchcontent!='')
        {
            $query .= " where ld_groups.groupname like '%$searchcontent%' ";
        }
        $query .= " ORDER BY groupid ASC ";
        //echo $query;die;
		$result = $adb->pquery($query,array());
		$rows = $adb->num_rows($result);
		$groupuser = array();
		if($rows > 0){
			for($i=0;$i<$rows;++ $i){
			    $groupid = $adb->query_result($result,$i,'groupid');
				$groupname = $adb->query_result($result,$i,'groupname');
				$groupuser[$groupid]['name'] = $groupname;
			}
		}
		if(!empty($groupuser)) return $groupuser;
		return '';
	}

    /**
     * edit:can
     * reason:点赞保存
     * */
    function savePraise()
    {
        global $adb,$current_user;
        $workreportid=$_REQUEST['workreportid'];

        $sql='select 1 from ld_praise where workreportid=? and userid=?';
        $info=array();
        $info['workreportid']=$workreportid;
        $result=$adb->pquery($sql,array($workreportid,$current_user->id));
        if($adb->num_rows($result)>0)
        {
            $sql='delete from ld_praise  where workreportid=? and userid=?';
            $adb->pquery($sql,array($workreportid,$current_user->id));
            $sql='update ld_workreport set praisecount=praisecount-1 where workreportid=?';
            $adb->pquery($sql,array($workreportid));
            $info['addcount']='-1';
            $ispraise = 'no';
        }
        else
        {
            $sql='insert into ld_praise(workreportid,userid,createdtime)values(?,?,?)';

            $adb->pquery($sql,array($workreportid,$current_user->id,date("Y-m-d H:i:s")));
            $praiseid=$adb->getLastInsertID();
            $sql='update ld_workreport set praisecount=IFNULL(praisecount,0)+1 where workreportid=?';

            $adb->pquery($sql,array($workreportid));

            $ispraise = 'yes';

        }
        $sql='select praisecount from ld_workreport where workreportid=?';
        $result=$adb->pquery($sql,array($workreportid));
        $praisecount = $adb->query_result($result,0,0);
        $sql='select smcreatorid from ld_workreport where workreportid=?';
        $result=$adb->pquery($sql,array($workreportid));
        $smcreatorid=$adb->query_result($result,0,0);
        //提醒relatedtable,remindtype,relatedto,userid,createdtime,content,operationtype
        //$sql='insert into ld_workreport_remind(relatedtable,remindtype,reatedto,userid,content,createdtime,operationtype)value(?,?,?,?,?,?)';
        $typearr=$this->getTypeArr($workreportid);
        $tag=$typearr['tag'];
        $tmpreltab=$typearr['tmpreltab'];
        $crmid= $adb->getUniqueID("ld_crmentity");
//        dump($workreportid);
        $adb->pquery($this->workreportremind_sql,array('praise',6,$praiseid,$smcreatorid,date("Y-m-d H:i:s"),$current_user->last_name.'点赞了我的工作',6));
        $resid=$adb->getLastInsertID();
        //WorkReportList praise 6 点赞
        $adb->pquery($this->remind_sql,array($crmid,$tmpreltab,'praise','immediately',(int)$praiseid,$smcreatorid,$current_user->id,$current_user->id,'未读',date("Y-m-d H:i:s"),date("Y-m-d H:i:s"),date("Y-m-d H:i:s"),'【工作汇报】提醒 | '.$current_user->last_name.'点赞了您的'.$tag,0,3,3,3,3,3,3,3));
        //editor:gyq reason:优化返回值 date:20161025
        $outputArr['ispraise'] = $ispraise;
        $outputArr['praisecount'] = $praisecount;
        $outputArr['creatorid'] = $adb->query_result($result,0,0);
        require_once(globalStatic::$root_directory.'WeiXinApp/modules/Reminds/MessageCorpconversation.php');
         if(!empty($praiseid))
         {
             $remind = new MessageCorpconversation();
             //$errorno = $remind->workreport_reminds_half($workreportid,$praiseid,'praise');
             $errorno = $remind->sendAllTypeRemindsImmediately(null,null,'workreport_reminds_half',
                 array(
                     'workreportid'=>$workreportid,'lastinsertid'=>$praiseid,'type'=>'praise'
                )
             );
         }
        //wyt 221121 XUQIU1000569 小程序增加消息提醒功能，关注公众号，接收提醒（第四版）点赞
        $sql="select w.workreport_no,w.workreportid
        from ld_workreport_remind Q
        left join ld_praise p on p.praiseid=Q.relatedto
        left join ld_workreport w on p.workreportid=w.workreportid
        where Q.id=$resid";
        $sqlResult = $adb->pquery($sql, array());
        $rows=$adb->num_rows($sqlResult);
            $workreport_no=$adb->query_result($sqlResult,0,'workreport_no');
            $workreportid=$adb->query_result($sqlResult,0,'workreportid');

            $subject[$workreportid]['subject'] = $workreport_no;
            $subject[$workreportid]['table_code'] = $workreport_no;
            $subject[$workreportid]['module'] = 'CooperativeWork';
        require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_offiaccount.php");
        $offiaccount_remind = new cls_reminds_offiaccount();
        $offiaccount_remind->sendAllTypeRemindsImmediately($resid,'other',$subject,'praise');

        return $outputArr;

    }
    /**
     * edit:can
     * reason:转发保存，任务取消保存，任务完成汇报结果,批阅
     * */
    public function savereader()
    {
        global $adb,$current_user;
        $content=$this->changeemojicookie(Input('reader_content'));//批阅内容
        $score=$_REQUEST['reader_score'];//评分
        $savetype=$_REQUEST['savetype'];//状态

        $ccgroup=$_REQUEST['ccgroup'];//抄送组
        $ccuser=$_REQUEST['ccuser'];//抄送用户
        if(!empty($ccuser))
        {
            $ccuser=explode(',',$ccuser);
            $ccuser=array_filter($ccuser);
        }

        //判断是否@at了所有同事
        $ccUserall = 0;
        $ccGroupArray = explode(',',$ccgroup);
        foreach($ccGroupArray as $userid){
        	if($userid == 'all'){
        		$ccUserall = 1;
        		break;
        	}
        }
        if($ccUserall == 0)
        {
            $ccgroup=explode(',',$ccgroup);
            $ccgroup=array_filter($ccgroup);
            if (!empty($ccgroup)) {
                $grouplist=implode(',',$ccgroup);
                $sql=" select   DISTINCT ld_users2group.userid  from ld_groups  left join  ld_users2group
             on ld_users2group.groupid =ld_groups.groupid
              left join ld_users  on ld_users.id=ld_users2group.userid
             where ld_groups.groupid in($grouplist) and ld_users.`status`='Active'";//获取部门下所有用户

                $groupresult=$adb->pquery($sql,array());
                for($i=0;$i<$adb->num_rows($groupresult);$i++)
                {
                    $userid=$adb->query_result($groupresult,$i,'userid');
                    if(!in_array($userid,$ccuser))
                    {
                        $ccuser[]=$userid;
                    }
                }
            }

        }
        else{
            $SmownerArray = $this->getUserArray();
        	foreach($SmownerArray as $userinfo){
        		if($userinfo['userid']['value'] != $current_user->id){
        			$ccuser[] = $userinfo['userid']['value'];
        		}
        	}
        }

        $approve = 0;
        $type = 0;
        if($savetype == 'savecomment')//批阅
        {
            $approve = 1;
            $type = 1;
        }
        else if($savetype == 'savecancel')//取消任务
        {
            $content = '取消该'.getFixedLabel('TASK');
            $approve = 2;
            $type = 1;
        }
        else if($savetype == 'savefinish')//完成任务
        {
            $approve = 1;
            $type = 1;
        }
        $oldcontent=$content;
        if(!empty($score))
        {
            switch($score)
            {
                case 1:
                    $commentscore="一分：严重批评";
                    break;

                case 2:
                    $commentscore="二分：不合格";
                    break;
                case 3:
                    $commentscore="三分：符合要求";
                    break;
                case 4:
                    $commentscore="四分：超过预期";
                     break;
                case 5:
                    $commentscore="五分：非常满意";
                    break;
            }
        }
        $content = $commentscore.' '.$content;
        $workreportid=$_REQUEST['workreportid'];//报告id
        $parentid=0;
        $sql='insert into ld_workreply(workreportid,text,replyuserid,parentid,createdtime,type)values(?,?,?,?,?,?)';
        $adb->pquery($sql,array($workreportid,$content,$current_user->id,$parentid,date('Y-m-d H:i:s'),$type));
        $lastinsertid=$adb->getLastInsertID();
        //获取汇报类型 微博、日志、周计划、月计划、任务
        $typearr=$this->getTypeArr($workreportid);
        $tag=$typearr['tag'];
        $tmpreltab=$typearr['tmpreltab'];

        if($savetype == 'savecomment')//批阅，我发出工作的提醒
        {
            $sql='update ld_workreport set approved=1,commentscore=?,commenttime=? where workreportid=?';
            $adb->pquery($sql,array($commentscore,date('Y-m-d H:i:s'),$workreportid));

            $sql='select ld_workreport.smcreatorid,ld_workreport.createdtime,ld_users.last_name,ld_users.wx_userid from ld_workreport
                 left join ld_users on ld_users.id= ld_workreport.smcreatorid where ld_workreport.workreportid=?';
            $result=$adb->pquery($sql,array($workreportid));
            $smcreatorid=$adb->query_result($result,0,'smcreatorid');
            $workreporttime=$adb->query_result($result,0,'createdtime');
            $createtime = date('Y-m-d H:i:s');
            //获取创建人lastname
            if($adb->num_rows($result)>0)
            {
                $tmp_last_name = $adb->query_result($result,0,'last_name');
                $tmp_wx_userid = $adb->query_result($result,0,'wx_userid');
                $userobj=new Users();
                $userobj->wx_userid=$tmp_wx_userid;
                $userobj->last_name=$tmp_last_name;
                $smcreator_last_name = getUserlastName($userobj);
            }
            //zkt 20220721 BUG0054122工作汇报，点评后，提交人收到的点评提醒提醒内容中：日志内容应该修改为“点评内容”
            $adb->pquery($this->workreportremind_sql,array('workreply',5,$lastinsertid,$smcreatorid,$createtime,$current_user->last_name."点评了您".$workreporttime."发布的".getFixedLabel('JOURNAL').':'.$score."分<br>".'点评内容：'.$oldcontent,0));
            $resid=$adb->getLastInsertID();
            $crmid= $adb->getUniqueID("ld_crmentity");
            //WorkReportList workreply 5 点评 comment
            $adb->pquery($this->remind_sql,array($crmid,$tmpreltab,'comment','immediately',$lastinsertid,$smcreatorid,$current_user->id,$current_user->id,'未读',$createtime,$createtime,$createtime,"【工作汇报】提醒 | 您的日志被点评 <br/>".$current_user->last_name."点评了您".$workreporttime."发布的".$tag.':'.$score."分<br/>".'点评内容：'.$oldcontent,0,3,3,3,3,3,3,3));
        }
        else if($savetype == 'savecancel')//取消任务，我发出工作的提醒
        {
            $sql="update ld_workreport set approved=2 where workreportid=?";
            $adb->pquery($sql,array($workreportid));
            $sql='select smcreatorid from ld_workreport where workreportid=?';
            $result=$adb->pquery($sql,array($workreportid));
            $smcreatorid=$adb->query_result($result,0,0);
            $adb->pquery($this->workreportremind_sql,array('workreply',5,$lastinsertid,$smcreatorid,date('Y-m-d H:i:s'),$current_user->last_name.'取消'.getFixedLabel('TASK'),2));
            $sql='select userid from ld_workreport2user where User_type=6 and workreportid=?';
            $result=$adb->pquery($sql,array($workreportid));
            $userid=$adb->query_result($result,0,0);
            $crmid= $adb->getUniqueID("ld_crmentity");
            //WorkReportList workreply 5 取消任务 canceltask
            $adb->pquery($this->remind_sql,array($crmid,$tmpreltab,'canceltask','immediately',$lastinsertid,$userid,$current_user->id,$current_user->id,'未读',date('Y-m-d H:i:s'),date('Y-m-d H:i:s'),date('Y-m-d H:i:s'),'【工作汇报】提醒 | 您的任务被取消 <br/>'.$current_user->last_name.'取消了您的'.getFixedLabel('TASK'),0,3,3,3,3,3,3,3));
        }
        else if($savetype == 'savefinish')//完成任务，我发出工作的提醒
        {
            $sql='update ld_workreport set approved=1 where workreportid=?';
            $adb->pquery($sql,array($workreportid));
            $sql='select smcreatorid from ld_workreport where workreportid=?';
            $result=$adb->pquery($sql,array($workreportid));
            $smcreatorid=$adb->query_result($result,0,0);
            $adb->pquery($this->workreportremind_sql,array('workreply',5,$lastinsertid,$smcreatorid,date('Y-m-d H:i:s'),$current_user->last_name.'完成'.getFixedLabel('TASK').':'.$content,1));
            $crmid= $adb->getUniqueID("ld_crmentity");
            //WorkReportList workreply 5 完成任务 finishtask
            $adb->pquery($this->remind_sql,array($crmid,$tmpreltab,'finishtask','immediately',$lastinsertid,$smcreatorid,$current_user->id,$current_user->id,'未读',date('Y-m-d H:i:s'),date('Y-m-d H:i:s'),date('Y-m-d H:i:s'),'【工作汇报】提醒 | 您发布的任务已完成 <br/>'.$current_user->last_name.'完成了'.getFixedLabel('TASK').'<br/>回复内容:'.$content,0,3,3,3,3,3,3,3));
        }
             //给回复用户表添加数据
        for($i=0;$i<sizeof((array)$ccuser);$i++)
        {
            $sql='insert into ld_workreply2user(workreplyid,userid,user_type) values(?,?,?)';
			$adb->pquery($sql,array($lastinsertid,$ccuser[$i],1));
        }
        //更改回复条数
        $sql='update ld_workreport set replycount=replycount+1 where workreportid=?';
        $adb->pquery($sql,array($workreportid));
        //todo:抄送到单据用户表中

        $sql='select smcreatorid from ld_workreport where workreportid=?';
        $result=$adb->pquery($sql,array($workreportid));
        $smcreatorid=$adb->query_result($result,0,'smcreatorid');

        if(!empty($ccuser)){
			 foreach($ccuser as $id)
			 {
					if($id!=$current_user->id)
					{
						 $sql='insert into ld_workreport2user(workreportid,userid,user_type)values(?,?,?)';
						  if($savetype == 'saveforward')//转发抄送
                          {
                                $adb->pquery($sql,array($workreportid,$id,8));
                                $converlastid=$adb->getLastInsertID();
                              $crmid= $adb->getUniqueID("ld_crmentity");
                              //WorkReportList workreply 10 转发抄送 forwardCC
                              $adb->pquery($this->remind_sql,array($crmid,$tmpreltab,'forwardCC','immediately',$lastinsertid,$id,$current_user->id,$current_user->id,'未读',date('Y-m-d H:i:s'),date('Y-m-d H:i:s'),date('Y-m-d H:i:s'),'【工作汇报】提醒 | '.$current_user->last_name."转发了".$tag."给您<br/>".'回复内容：'.$oldcontent,0,3,3,3,3,3,3,3));

                          }
                          else if($savetype == 'savecomment')//点评抄送
                          {
                                $adb->pquery($sql,array($workreportid,$id,10));
                                //点评抄送提醒
                              $adb->pquery($this->workreportremind_sql,array('workreply',10,$lastinsertid,$id,date('Y-m-d H:i:s'),$current_user->last_name."点评了".$smcreator_last_name.$workreporttime."发布的".getFixedLabel('JOURNAL')."<br>".'提醒内容：'.$current_user->last_name.'回复内容：'.$oldcontent,0));
                              $crmid= $adb->getUniqueID("ld_crmentity");
                              //WorkReportList workreply 10 点评抄送 commentCC
                              $adb->pquery($this->remind_sql,array($crmid,'WorkReportList','commentCC','immediately',$lastinsertid,$id,$current_user->id,$current_user->id,'未读',date('Y-m-d H:i:s'),date('Y-m-d H:i:s'),date('Y-m-d H:i:s'),'【工作汇报】提醒 | '.$current_user->last_name."抄送了".$tag."点评内容给您<br/>".'内容：'.$oldcontent,0,3,3,3,3,3,3,3));
                          }
                          else
                          {
                                $adb->pquery($sql,array($workreportid,$id,1));
                          }

					}
			 }
		}
        //提醒
        require_once(globalStatic::$root_directory.'WeiXinApp/modules/Reminds/MessageCorpconversation.php');

        if(!empty($lastinsertid))
         {
             $remind = new MessageCorpconversation();
             //$errorno = $remind->workreport_reminds_half($workreportid,$lastinsertid,'reply');
             $errorno = $remind->sendAllTypeRemindsImmediately(null,null,'workreport_reminds_half',
                 array(
                     'workreportid'=>$workreportid,'lastinsertid'=>$lastinsertid,'type'=>'reply'
                 )
             );

         }
        //wyt 221121 XUQIU1000569 小程序增加消息提醒功能，关注公众号，接收提醒（第四版） 点评
        if(!empty($resid)){
            $sql="select w.workreport_no,w.workreportid
            from ld_workreport_remind Q
            left join ld_workreply y on y.workreplyid=Q.relatedto
            left join ld_workreport w on y.workreportid=w.workreportid
            where Q.id=?";
            $sqlResult = $adb->pquery($sql, array($resid));
            $rows=$adb->num_rows($sqlResult);
            if($rows >0){
                $workreport_no=$adb->query_result($sqlResult,0,'workreport_no');
                $workreportid=$adb->query_result($sqlResult,0,'workreportid');

                $subject[$workreportid]['subject'] = $workreport_no;
                $subject[$workreportid]['table_code'] = $workreport_no;
                $subject[$workreportid]['module'] = 'CooperativeWork';

                require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_offiaccount.php");
                $offiaccount_remind = new cls_reminds_offiaccount();
                $offiaccount_remind->sendAllTypeRemindsImmediately($resid,'other',$subject,'comment');
            }
        }

    }
    //editor:gyq_102 reason:日志回复提醒关联的所有人  2019/2/27 15:21
    public function replay_remind($r_reportid,$r_content,$r_replyid,$r_remindid){
        global $adb,$current_user;
        $TransforSecondCategory = array(1 => getFixedLabel('JOURNAL'), 2 => getFixedLabel('WEEKPLAN'), 3 => getFixedLabel('MONTHPLAN'),'6'=>getFixedLabel('TASK'));
        $CooperativeWorktype = getTranstab('CooperativeWork');
        $remind_user_direct = array();//回复直接相关的人员，如日志提交人、被回复人等
        $remind_userid_direct = array();//回复直接相关的人员，如日志提交人、被回复人等
        //获取创建人lastname
        $sql = 'select ld_users.id,ld_users.last_name,ld_users.wx_userid,ld_users.dingtalk_userid,ld_workreport.entitytype,ld_workreport.createdtime,ld_workreport.type from ld_workreport
						LEFT JOIN ld_users on ld_users.id = ld_workreport.smcreatorid
							where ld_workreport.workreportid=?';
        $result = $adb->pquery($sql,array($r_reportid));
        if($adb->num_rows($result)>0)
        {
            $userid = $adb->query_result($result,0,'id');
            if($current_user->id != $userid){
                $remind_userid_direct[] = $userid;
                $wx_userid = $adb->query_result($result,0,'wx_userid');
                if(!empty($wx_userid)){
                    $remind_user_direct[] = $wx_userid;
                }
                $dingtalkUserid = $adb->query_result($result,0,'dingtalk_userid');

                if(!empty($dingtalkUserid)){
                    $remindDingUser_direct[] = $dingtalkUserid;
                }

            }
            $entitytype = $adb->query_result($result,0,'entitytype');
            $createdtime = $adb->query_result($result,0,'createdtime');
            $type = $adb->query_result($result,0,'type');
            $last_name = $adb->query_result($result,0,'last_name');
            $userobj=new Users();
            $userobj->wx_userid=$userid;
            $userobj->last_name=$last_name;
            $smcreator_last_name = getUserlastName($userobj);
            //获取回复的对象：日志、周计划、月计划、微博、任务
            if($entitytype == 'cocmd'){
                $CooperativeWorktype = getFixedLabel('TASK');
            }
            else if($entitytype  =='weibo'){
                $CooperativeWorktype = getFixedLabel('BLOG');
            }
            else if($entitytype  =='workreport'){
                $CooperativeWorktype = $TransforSecondCategory[$type];
            }
        }

        //获取被回复人
        $sql = 'select ld_users.id,ld_users.last_name,ld_users.wx_userid,ld_users.dingtalk_userid from ld_workreply
                INNER JOIN ld_workreply as oldworkreply on oldworkreply.workreplyid=ld_workreply.parentid
                LEFT JOIN ld_users on ld_users.id = oldworkreply.replyuserid
             where ld_workreply.workreplyid = ? and ld_users.push_wx_reminds = 1;';
        $result = $adb->pquery($sql,array($r_replyid));
        if($adb->num_rows($result)){
            $replyed_userid = $adb->query_result($result,0,'id');
            $replyed_last_name = $adb->query_result($result,0,'last_name');
            $replyed_wx_userid = $adb->query_result($result,0,'wx_userid');
            if($current_user->id != $replyed_userid){
                $remind_userid_direct[] = $replyed_userid;
                $wx_userid = $adb->query_result($result,0,'wx_userid');
                if(!empty($replyed_wx_userid)){
                    $remind_user_direct[] = $replyed_wx_userid;
                }
                $dingtalkUserid = $adb->query_result($result,0,'dingtalk_userid');
                if(!empty($dingtalkUserid)){
                    $remindDingUser_direct[] = $dingtalkUserid;
                }
            }
        }
        if(!empty($remind_user_direct)||!empty($remindDingUser_direct)){
            $multi_content = array(
                array(
                    'message'=>getWxMobileRemindInfo($current_user).'回复了'.$smcreator_last_name.$createdtime.'发布的'.$CooperativeWorktype.'<br>回复内容：'.$r_content,
                    'title'=>'【'.getTranstab('CooperativeWork').'】回复提醒',
                    'reltab'=>'CooperativeWork',
                    'related_to'=>$r_reportid,
                    'date_time'=>date("Y-m-d H:i:s"),
                    'modulelabel'=>'回复',
                    'entitytype'=>$entitytype,
                )
            );
            if(count($remind_user_direct) > 0){
                $multi_content[0]['userid'] = $remind_user_direct;
            }
            if(count($remindDingUser_direct) > 0){
                $multi_content[0]['userid_ding'] = $remindDingUser_direct;
            }
            $remind = new MessageCorpconversation();
            $errorno = $remind->sendAllTypeRemindsImmediately([$r_remindid],$multi_content);
        }

        $sql = 'select distinct ld_users.id,ld_users.last_name,ld_users.wx_userid,PORT.entitytype,ld_users.dingtalk_userid from ld_users
              left join ld_workreport2user USER on USER.userid=ld_users.id
              left join ld_workreport PORT on PORT.workreportid=USER.workreportid
            where PORT.workreportid=? and ld_users.push_wx_reminds=1 ';
        $result = $adb->pquery($sql,array($r_reportid));
        $nums = $adb->num_rows($result);
        $remind_user = array();
        $remind_userid = array();
        //editor:gyq_165 reason:钉钉消息提醒类型 ，日志回复提醒  2019/12/30 17:23
        for($i=0;$i<$nums;$i++){
            //editor:gyq_20191008 修改方法：在所有评论提醒中，过滤掉当前评论人，即：不提醒当前评论人。
            //0036530: 工作汇报提醒：A写了日志抄送给B，B评论A的日志后却收到了自己评论的提醒。
            $userid = $adb->query_result($result,$i,'id');
            if($current_user->id == $userid||in_array($userid,$remind_userid_direct)){
                continue;
            }
            $remind_userid[] = $userid;
            $wx_userid = $adb->query_result($result,$i,'wx_userid');
            if(!empty($wx_userid)){
                $remind_user[] = $wx_userid;
            }
            $dingtalkUserid = $adb->query_result($result,$i,'dingtalk_userid');
            if(!empty($dingtalkUserid)){
                $remindDingUser[] = $dingtalkUserid;
            }
            $entitytype = $adb->query_result($result,$i,'entitytype');
        }
        //editor:gyq_20191028 reason:调用发消息方法前，需要判断用户列表不为空
        //0038358: （落落计划）企业微信>灵当CRM>工作汇报模块>日志回复界面：填写内容后点击发布按钮没有发布成功。

        if(!empty($remind_user)||!empty($remindDingUser)){
            $multi_content = array(
                array(
                    'message'=>getWxMobileRemindInfo($current_user).'回复了'.$smcreator_last_name.$createdtime.'发布的'.$CooperativeWorktype.'<br>'.getWxMobileRemindInfo($current_user).'回复内容：'.$r_content,
                    'title'=>'【'.getTranstab('CooperativeWork').'】提醒|有新的回复内容抄送您',
                    'reltab'=>'CooperativeWork',
                    'related_to'=>$r_reportid,
                    'date_time'=>date("Y-m-d H:i:s"),
                    'modulelabel'=>'回复',
                    'entitytype'=>$entitytype,
                )
            );
            if(count($remind_user) > 0){
                $multi_content[0]['userid'] = $remind_user;
            }
            if(count($remindDingUser) > 0){
                $multi_content[0]['userid_ding'] = $remindDingUser;
            }
            $remind = new MessageCorpconversation();
            $errorno = $remind->sendAllTypeRemindsImmediately([$r_remindid],$multi_content);
        }
    }

    function getMaxRemindsid(){
        global $adb;
        $remindsidsql="select max(remindsid) from ld_reminds ";
        $remindsidresult=$adb->pquery($remindsidsql,array());
        $maxremindsid=$adb->query_result($remindsidresult,0,0);
        return $maxremindsid+1;
    }
    function getTypeArr($workreportid){
        //获取汇报类型 微博、日志、周计划、月计划、任务
        global $adb;
        $reporttype=[];
        $typearr=[];
        $tmpreltab='WorkReportList';
        $reporttypesql='select entitytype,type from ld_workreport where workreportid=?';
        $reporttypesqlresult=$adb->pquery($reporttypesql,array($workreportid));
        $reporttype['entitytype']=$adb->query_result($reporttypesqlresult,0,'entitytype');
        $reporttype['type']=$adb->query_result($reporttypesqlresult,0,'type');
        if($reporttype['entitytype'] == 'workreport'){
            if($reporttype['type'] == 1){
                $tag=getTranstab('JOURNAL');
            }elseif ($reporttype['type'] == 2){
                $tag=getTranstab('JOURNAL');
            }elseif ($reporttype['type'] == 3){
                $tag=getTranstab('JOURNAL');
            }
        }elseif ($reporttype['entitytype'] == 'cocmd'){
            $tag=getTranstab('TASK');
            $tmpreltab='CooperativeWork';
        }elseif ($reporttype['entitytype'] == 'weibo'){
            $tag=getTranstab('BLOG');
            $tmpreltab='CooperativeWork';
        }
        $typearr['tag']=$tag;
        $typearr['tmpreltab']=$tmpreltab;
        return $typearr;
    }

    /**
     * 保存***
     * **/
    function save()
    {
        require_once(globalStatic::$root_directory.'WeiXinApp/modules/Reminds/MessageCorpconversation.php');
        global $adb,$current_user;
        $entitytype=$_REQUEST['entitytype'];//日志、微博、任务
        $savetype=$_REQUEST['savetype'];//1:日志，2：周报，3：月,4:回复
		$saleskit_date = $_REQUEST['saleskit_date'];	//日志、周报、月报，销售简报日期

        if ($entitytype == 'workreport' && $savetype != 4){
            $reporttype_arr = array('1'=>'day','2'=>'week','3'=>'month');
            $reporttype = $reporttype_arr[$savetype];
            crm_load_class_file('WorkTemplateRule','modules/Settings');
            $workTemplateRuleobj = new WorkTemplateRule();
            $workTemplateRuleobj->setWorkReportType($reporttype);
            $reportDate = $workTemplateRuleobj->getReportDateData();
            $editDate = $reportDate['editDate'];
            if($editDate == 'no'){
                crm_load_class_file("CommonView","modules/CustomView");
                $datetimestr=CommonView::stdFilterDateTimeStr();//获取日期，时间本年，明年等下拉框字符串
                if ($savetype == 1){
                    $saleskit_date = $datetimestr['today'][0];
                }elseif ($savetype == 2){
                    $saleskit_date = $datetimestr['thisweek'][0].' ~ '.$datetimestr['thisweek'][1];
                }elseif ($savetype == 3){
                    $saleskit_date = $datetimestr['thismonth'][0].' ~ '.$datetimestr['thismonth'][1];
                }
            }else{
                if ($savetype == 1){
                    $minDate = $reportDate['minDate'];
                    $maxDate = $reportDate['maxDate'];
                    $label = $reportDate['label'];
                    if ( ($minDate == '' && $maxDate == '')  || strtotime($saleskit_date) >= strtotime($minDate) && strtotime($maxDate) >= strtotime($saleskit_date)){

                    }else{
                        ConvertTojsonString(-1,'',getVarFixedLabel('ReportDateSubmitTip',$label));
                    }
                }
            }
        }
        $Atgroup=$_REQUEST['atgroup'];
        $Atuser=$_REQUEST['atuser'];
        if(!empty($Atuser))
        {
            $Atuser=explode(',',$Atuser);
            $Atuser=array_filter($Atuser);
            //15113: android：发日志、发微博、发任务时，@一个用户多次时，【@我的工作】信息条数显示多条，应显示一条。
            $Atuser=array_flip($Atuser);
            $Atuser=array_flip($Atuser);
        }
		//判断是否@at了所有同事
		$atUserall = 0;
        $Atgroup=(string)$Atgroup;
		$atGroupArray = explode(',', $Atgroup);
		foreach($atGroupArray as $userid){
			if($userid == 'all'){
				$atUserall = 1;
				break;
			}
		}
        if($atUserall == 0)
        {
            $Atgroup=explode(',',$Atgroup);
            $Atgroup=array_filter($Atgroup);
            $Atgroup=array_flip($Atgroup);
            $Atgroup=array_flip($Atgroup);
            if (!empty($Atgroup)) {
                $grouplist=implode(',',$Atgroup);
                $sql=" select DISTINCT ld_users2group.userid  from ld_groups  left join  ld_users2group
             on ld_users2group.groupid =ld_groups.groupid
              left join ld_users  on ld_users.id=ld_users2group.userid
             where ld_groups.groupid in($grouplist) and ld_users.`status`='Active' ";//获取部门下所有用户
                $groupresult=$adb->pquery($sql,array());
                for($i=0;$i<$adb->num_rows($groupresult);$i++)
                {
                    $userid=$adb->query_result($groupresult,$i,'userid');
                    if(!in_array($userid,$Atuser))
                    {
                        $Atuser[]=$userid;
                    }
                }
            }

        }else{
			$SmownerArray = $this->getUserArray();
			//$Smownerids= getCurSmOwnerSearchScope('OftenUseReport');
            foreach($SmownerArray as $userinfo){
				if($userinfo['userid']['value'] != $current_user->id){
                    $Atuser[] = $userinfo['userid']['value'];
				}
            }
		}

        //editor:gyq_102 reason:日志回复提醒关联的所有人  2019/2/27 11:40
        if($savetype==4)//.回复保存
        {
             $replycontent=$this->changeemojicookie(Input('replycontent'));
             $workreportid=$_REQUEST['workreportid'];
             $backstatus = $_REQUEST['backstatus'];
             //$replycount=$_REQUEST['replycount'];
             $parentid=0;
             if(isset($_REQUEST['parentid'])&&$_REQUEST['parentid']>0)
                $parentid=$_REQUEST['parentid'];
             $sql='insert into ld_workreply(workreportid,text,replyuserid,parentid,createdtime,type)values(?,?,?,?,?,?)';

             $adb->pquery($sql,array($workreportid,$replycontent,$current_user->id,$parentid,date('Y-m-d H:i:s'),0));
             $lastinsertid=$adb->getLastInsertID();
              $sql='insert into ld_workreply2user(workreplyid,userid,user_type) 
              select  ?,?,?
              from dual
              where not EXISTS(select 1 from ld_workreply2user where workreplyid=? and userid=? and user_type=?)';
              $adb->pquery($sql,array($lastinsertid,$current_user->id,1,$lastinsertid,$current_user->id,1));
              $workreportsql='select smcreatorid from ld_workreport  where workreportid=?';
              $workreportresult=$adb->pquery($workreportsql,array($workreportid));
              $workreportcreatorid=$adb->query_result($workreportresult,0,0);
                    //我发出工作的回复
            $createtime = date('Y-m-d H:i:s');
            //editor:gyq_102 reason:日志回复提醒关联的所有人  2019/2/27 16:13
            $workreprotremind_sql = 'insert into ld_workreport_remind(relatedtable,remindtype,relatedto,userid,createdtime,content,operationtype,push_to_weixin)value(?,?,?,?,?,?,?,?)';
            $adb->pquery($workreprotremind_sql,array('workreply2report',2,$workreportid,'',$createtime,$current_user->last_name.'回复:'.$replycontent,12,3));
            $resid=$adb->getLastInsertID();
            $typearr=$this->getTypeArr($workreportid);
            $tag=$typearr['tag'];
            $tmpreltab=$typearr['tmpreltab'];

            //WorkReportList workreply2report 2 回复 reply
            $crmid= $adb->getUniqueID("ld_crmentity");
            $adb->pquery($this->remind_sql,array($crmid,$tmpreltab,'reply','immediately',$workreportid,$workreportcreatorid,$current_user->id,$current_user->id,'未读',$createtime,$createtime,$createtime,'【工作汇报】提醒 | '.$current_user->last_name.'回复了您的'.$tag.'<br/>回复内容：'.$replycontent,0,3,3,3,3,3,3,3));

            $this->replay_remind($workreportid,$_REQUEST['replycontent'],$lastinsertid,$crmid);
            if(!empty($Atuser)){
			     $sqlreport='insert into ld_workreport2user(workreportid,userid,user_type)
                 select  ?,?,?
                 from dual
                 where not EXISTS(select 1 from ld_workreport2user where workreportid=? and userid=? and user_type=?)';

                 $sql='insert into ld_workreply2user(workreplyid,userid,user_type)
                 select  ?,?,?
                 from dual
                 where not EXISTS(select 1 from ld_workreply2user where workreplyid=? and userid=? and user_type=?)';
                $workreprotremind_sql='insert into ld_workreport_remind(relatedtable,remindtype,relatedto,userid,createdtime,content,operationtype)
                            select ?,?,?,?,?,?,? from dual
                 where not EXISTS(select 1 from ld_workreport2user where workreportid=? and userid=? and user_type=?)';

				 foreach($Atuser as $id){
					if($current_user->id!=$id && $id != $workreportcreatorid){
						if($backstatus == 'yes')//yes:表示@中有用户在发布工作报告，任务没有添加的用户
                        {

                            $adb->pquery($sql,array($lastinsertid,$id,4,$lastinsertid,$id,4));

                           // print_r(array('workreply',4,$lastinsertid,$workreportcreatorid,date('Y-m-d H:i:s'),$current_user->last_name.'在回复中提到了我',8,$workreportid,$id,4));
                            $adb->pquery($workreprotremind_sql,array('workreply',4,$lastinsertid,$id,date('Y-m-d H:i:s'),$current_user->last_name.'在回复中提到了我',8,$workreportid,$id,4));
                            $adb->pquery($sqlreport,array($workreportid,$id,4,$workreportid,$id,4));
                        }
                        else
                        {
                            $adb->pquery($sql,array($lastinsertid,$id,2,$lastinsertid,$id,2));
                            //WorkReportList workreply 4 回复抄送 replyCC
                            $crmid= $adb->getUniqueID("ld_crmentity");
                            $adb->pquery($this->remind_sql,array($crmid,$tmpreltab,'replyCC','immediately',$lastinsertid,$id,$current_user->id,$current_user->id,'未读',date('Y-m-d H:i:s'),date('Y-m-d H:i:s'),date('Y-m-d H:i:s'),'【工作汇报】提醒 | 有新的回复内容抄送给你 <br/>回复内容：'.$replycontent,0,3,3,3,3,3,3,3));
                        }


                    }
                }
			}

            //todo:附件保存
             $sql='update ld_workreport set replycount=replycount+1 where workreportid=?';
             $adb->pquery($sql,array($workreportid));
             $remind = new MessageCorpconversation();
             //$errorno = $remind->workreport_reminds_half($workreportid,$lastinsertid,'reply');
            $errorno = $remind->sendAllTypeRemindsImmediately(null,null,'workreport_reminds_half',
                array(
                    'workreportid'=>$workreportid,'lastinsertid'=>$lastinsertid,'type'=>'reply'
                )
            );

            //wyt 221121 XUQIU1000569 小程序增加消息提醒功能，关注公众号，接收提醒（第四版）  回复
            $sql="select w.workreport_no,w.workreportid
        from ld_workreport_remind Q
        left join ld_workreport w on Q.relatedto=w.workreportid
        where Q.id=$resid";
            $sqlResult = $adb->pquery($sql, array());
            $rows=$adb->num_rows($sqlResult);
            $workreport_no=$adb->query_result($sqlResult,0,'workreport_no');
            $workreportid=$adb->query_result($sqlResult,0,'workreportid');

            $subject[$workreportid]['subject'] = $workreport_no;
            $subject[$workreportid]['table_code'] = $workreport_no;
            $subject[$workreportid]['module'] = 'CooperativeWork';

            require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_offiaccount.php");
            $offiaccount_remind = new cls_reminds_offiaccount();
            $offiaccount_remind->sendAllTypeRemindsImmediately($resid,'other',$subject,'reply');
        }
        else
        {
            $ccgroup=$_REQUEST['ccgroup'];
            $ccuser=$_REQUEST['ccuser'];

            if(isset($_REQUEST['appversion']) && $_REQUEST['appversion']!=''){
                //记录发送范围、点评人或执行人
                $comment_execution = '';
                if($entitytype == 'workreport'){
                    $comment_execution = $_REQUEST['reader'];//日志批阅人
                }
                else if($entitytype == 'cocmd'){
                    $comment_execution = $_REQUEST['cmduser'];//任务执行人
                }
                $ccgroupname=$_REQUEST['ccgroupname'];
                $ccusername=$_REQUEST['ccusername'];
                $comment_execution_name = getUserFullName($comment_execution);
                $this->saveRangeCommentExecutor($ccgroup,$ccuser,$ccgroupname,$ccusername,$comment_execution,$comment_execution_name,$entitytype,$savetype);
            }

            $contactlist=$_REQUEST['contactlist'];
            $accountlist=$_REQUEST['accountlist'];
            $productslist=$_REQUEST['productslist'];

            $startdate=$_REQUEST['startdate'];
            $enddate=$_REQUEST['enddate'];
            if(empty($startdate))
            {
                $startdate = Null;
            }
            if(empty($enddate))
            {
                $enddate = Null;
            }


            if(!empty($ccuser))
            {
                $ccuser=explode(',',$ccuser);
                $ccuser=array_flip($ccuser);
                $ccuser=array_flip($ccuser);
                $ccuser=array_filter($ccuser);

            }
            $alluser = 0;//判断是否选择了所有同事  0 没有 1有
            if(!empty($ccgroup))
            {
                $ccgroup=explode(',',$ccgroup);
				foreach($ccgroup as $userid){
					if($userid == 'all'){
						$alluser = 1;//勾选了全部同事
						break;
					}
				}
				if($alluser == 0){
					$ccgroup=array_filter($ccgroup);
					$grouplist=implode(',',$ccgroup);
					$sql=" select   DISTINCT ld_users2group.userid  from ld_groups  left join  ld_users2group
					 on ld_users2group.groupid =ld_groups.groupid
					  left join ld_users  on ld_users.id=ld_users2group.userid
					 where ld_groups.groupid in($grouplist) and ld_users.`status`='Active'";//获取部门下所有用户

					$groupresult=$adb->pquery($sql,array());
					for($i=0;$i<$adb->num_rows($groupresult);$i++)
					{
						$userid=$adb->query_result($groupresult,$i,'userid');
						if(!in_array($userid,$ccuser))
						{
							$ccuser[]=$userid;
						}
					}
				}else{
					$SmownerArray = $this->getUserArray();
					foreach($SmownerArray as $userinfo){
						if($userinfo['userid']['value'] != $current_user->id){
							$ccuser[] = $userinfo['userid']['value'];
						}
					}
				}
            }
            $relatedto_account = $relatedto_contact = $relatedto_product = '';
             if(!empty($contactlist))
             {
                $contactlist=explode(',',$contactlist);
                $contactlist=array_filter($contactlist);
                $relatedModules['Contacts']=$contactlist;
                 $relatedto_contact = implode(',',$contactlist);
             }
             if(!empty($accountlist))
             {
                $accountlist=explode(',',$accountlist);
                $accountlist=array_filter($accountlist);
                $relatedModules['Accounts']=$accountlist;
                 $relatedto_account = implode(',',$accountlist);
             }
             if(!empty($productslist))
             {
                $productslist=explode(',',$productslist);
                $productslist=array_filter($productslist);
                $relatedModules['Products']=$productslist;
                 $relatedto_product = implode(',',$productslist);
             }
            $worksummary=$this->changeemojicookie(Input('worksummary'));
            $workplan=$this->changeemojicookie(Input('workplan'));
            $workexperience=$this->changeemojicookie(Input('workexperience'));
			$workplan_tuesday=$this->changeemojicookie(Input('workplan_tuesday'));
			$workplan_wednesday=$this->changeemojicookie(Input('workplan_wednesday'));
			$workplan_thursday=$this->changeemojicookie(Input('workplan_thursday'));
			$workplan_friday=$this->changeemojicookie(Input('workplan_friday'));
            $saleskit_showtype=$_REQUEST['saleskit_showtype'];
            $saleskit_listinfo=$_REQUEST['saleskit_listinfo'];
            $tmp_saleskit_listinfo = ldcrm_json_decode($saleskit_listinfo);
            if ($entitytype == 'workreport' && $savetype != 4 && $saleskit_showtype == 'html'){
                $saleskit_arr =  $this->getSalesKitByListinfo($saleskit_listinfo);
                $_REQUEST['saleskit_'.$reporttype] = $saleskit_arr['saleskit'];
                $saleskit_listinfo = $saleskit_arr['listinfo'];
            }

			$saleskit_day=$this->changeemojicookie($_REQUEST['saleskit_day']);
			$saleskit_week=$this->changeemojicookie($_REQUEST['saleskit_week']);
			$saleskit_month=$this->changeemojicookie($_REQUEST['saleskit_month']);
            //判断如果为空，给自动赋值
            if(trim($worksummary) == '' || $worksummary == 'undefined')
            {
                $worksummary = '';
            }
            if(trim($workplan) == '' || $workplan == 'undefined')
            {
                $workplan = '';
            }
            if(trim($workexperience) == '' || $workexperience == 'undefined')
            {
                $workexperience = '';
            }
			if(trim($workplan_tuesday) == '' || $workplan_tuesday == 'undefined')
            {
                $workplan_tuesday = '';
            }
			if(trim($workplan_wednesday) == '' || $workplan_wednesday == 'undefined')
            {
                $workplan_wednesday = '';
            }
			if(trim($workplan_thursday) == '' || $workplan_thursday == 'undefined')
            {
                $workplan_thursday = '';
            }
			if(trim($workplan_friday) == '' || $workplan_friday == 'undefined')
            {
                $workplan_friday = '';
            }
			if(trim($saleskit_day) == '' || $saleskit_day == 'undefined')
            {
                $saleskit_day = '';
            }
			if(trim($saleskit_week) == '' || $saleskit_week == 'undefined')
            {
                $saleskit_week = '';
            }
			if(trim($saleskit_month) == '' || $saleskit_month == 'undefined')
            {
                $saleskit_month = '';
            }
            $smcreatorid=$current_user->id;
            $readerid=$_REQUEST['reader'];//日志批阅人
            $cmduserid=$_REQUEST['cmduser'];//任务执行人

            $longtitude='';//经度
            $latitude='';//纬度
            $signaddress='';//定位地址
            if($_REQUEST['longtitude'])
            {
                $longtitude=$_REQUEST['longtitude'];//经度
            }
            if($_REQUEST['latitude'])
            {
                $latitude=$_REQUEST['latitude'];//纬度
            }
            if($_REQUEST['signaddress'])
            {
                $signaddress=$_REQUEST['signaddress'];//定位地址
            }
            $createtime = date("Y-m-d H:i:s");
            $fieldsql = 'createdtime,smcreatorid,type,approved,startdate,
                            enddate,entitytype,longtitude,latitude';
            $sql='insert into ld_workreport(createdtime,worksummary,workplan,workexperience,smcreatorid,type,approved,startdate,enddate,entitytype,longtitude,latitude,
                          signaddress,workplan_tuesday,workplan_wednesday,workplan_thursday,workplan_friday,sendlog_workdate,saleskit_day,
                          saleskit_week,saleskit_month,relatedto_account,relatedto_contact,relatedto_product,saleskit_showtype,saleskit_listinfo,smownerid
            )values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)';
            $adb->pquery($sql,array($createtime,$worksummary,$workplan,$workexperience,$smcreatorid,$savetype,0,$startdate,
                $enddate,$entitytype,$longtitude,$latitude,$signaddress,$workplan_tuesday,$workplan_wednesday,$workplan_thursday,$workplan_friday,
                $saleskit_date,$saleskit_day,$saleskit_week,$saleskit_month,$relatedto_account,$relatedto_contact,$relatedto_product,$saleskit_showtype,$saleskit_listinfo,$smcreatorid));
            $lastinsertid=$adb->getLastInsertID();
            $workreportid=$lastinsertid;

            //ls 20221012 XUQIU1000284  增加“工作汇报（列表）”模块(写工作汇报时插入编号和是否补交，以及维护点评人、点评评分、抄送范围、点评时间、周报、月报、签到地址)
            $tmpmodule = 'WorkReportList';
            $focus = CRMEntity::getInstance($tmpmodule);
            $focus->Library('SystemCode')->setModuleSeqNumber("increment", $tmpmodule);//使当前流水号加1，避免单据编号重复
            $num_no = $focus->Library('SystemCode')->reSetModuleSeqNumRecord($tmpmodule);
            $sql = "update " . $focus->table_name . " set ".$focus->table_code."=?,
             isresubmission = 
CASE WHEN type = 1 THEN 
(CASE WHEN DATE_FORMAT(createdtime,'%Y-%m-%d') = IFNULL(DATE_FORMAT(sendlog_workdate,'%Y-%m-%d'),DATE_FORMAT(createdtime,'%Y-%m-%d')) THEN '否' ELSE '是' END) 
ELSE
(CASE WHEN DATE_FORMAT(createdtime,'%Y-%m-%d') BETWEEN REPLACE(SUBSTRING_INDEX(IFNULL(sendlog_workdate,DATE_FORMAT(createdtime,'%Y-%m-%d')),'~','1'),' ','') AND REPLACE(SUBSTRING_INDEX(IFNULL(sendlog_workdate,DATE_FORMAT(createdtime,'%Y-%m-%d')),'~','-1'),' ','') THEN '否' ELSE '是' END)
END
             where " . $focus->table_index . "=?";
            $adb->pquery($sql, array($num_no, $workreportid));

            $ccuser_str = '';//点评抄送人
            if (!empty($ccuser)) {
                $ccuser_str = implode(',',$ccuser);
            }
            if ($savetype == 1) {
                $sql='update ld_workreport set reuser=?,ccuser=? where workreportid=?';
                $adb->pquery($sql,array($readerid,$ccuser_str,$workreportid));
            } elseif ($savetype == 2) {//周报
                //lius 20231115 BUG0075540 统一使用signaddress字段作为签到地址字段，signaddress_week,signaddress_month 字段废弃
                $sql='update ld_workreport set reuser=?,ccuser=?,worksummary_week=?,workplan_week=?,workexperience_week=?,signaddress=? where workreportid=?';
                $adb->pquery($sql,array($readerid,$ccuser_str,$worksummary,$workplan,$workexperience,$signaddress,$workreportid));
            } elseif ($savetype == 3) {//月报
                $sql='update ld_workreport set reuser=?,ccuser=?,worksummary_month=?,workplan_month=?,workexperience_month=?,signaddress=? where workreportid=?';
                $adb->pquery($sql,array($readerid,$ccuser_str,$worksummary,$workplan,$workexperience,$signaddress,$workreportid));
            }


            //微信保存图片需要
            $_REQUEST['home_lastinsert']['id'] = $lastinsertid;
            /**
			 * 保存自定义字段的值
			 * @project 工作协同模板
			 * @author Tujt 2015-05-07
			 */
			if(isset($_REQUEST['workfld'])){//文本域textarea的name值
				$workfld = trim($_REQUEST['workfld'],',');
				$workfldarr = explode(',',$workfld);
				$workcffld = '';$workcfval = '';//组装sql
				$entity_type = 'workreport';
				$workfieldarray = $this->getWorkCfFieldInfo($entity_type);
				foreach($workfldarr as $fld){

					if(is_array($workfieldarray) && 'ld_workreportcf' == $workfieldarray[$fld]){//判断是否工作协同自定义字段
                    $_REQUEST[$fld]= $this->changeemojicookie(Input($fld));
						$workcffld .= $fld.',';
						$workcfval .= '"'.$_REQUEST[$fld].'",';
					}
				}
				if(!empty($workcffld)){//不为空，则插入数据库
					$workcffld = trim($workcffld,',');
					$workcfval = trim($workcfval,',');
					$insertcf = 'insert into ld_workreportcf(workreportid,'.$workcffld.') 
									values('.$lastinsertid.','.$workcfval.');';
					//echo $insertcf;die;
                    $adb->query($insertcf);//插入自定义字段存储表
				}
			}//保存自定义字段end

            $sql='insert into ld_workreport2user(workreportid,userid, user_type)values(?,?,?)';

            //如果是日志，需要增加任务批阅人，user_type为5
            //如果是任务，需要增加任务执行人，user_type为6
            $remind_content='在工作中提到我';
            $operationtype=9;
            if($entitytype == 'workreport')
            {
                if($savetype == 1){
                    $remind_content='在工作汇报日志中提到我';
                    $tag=getFixedLabel('JOURNAL');
                }elseif ($savetype == 2){
                    $remind_content='在工作汇报周计划中提到我';
                    $tag=getFixedLabel('WEEKPLAN');
                }elseif ($savetype == 3){
                    $remind_content='在工作汇报月计划中提到我';
                    $tag=getFixedLabel('MONTHPLAN');
                }
                 $operationtype=9;
                $adb->pquery($sql,array($lastinsertid,$readerid,5));//日志批阅人
                $sqlupdate='update ld_users set reader=?  where id=?';
                $adb->pquery($sqlupdate,array($readerid,$current_user->id));//修改最近批阅人
                //待处理提醒
                $adb->pquery($this->workreportremind_sql,array('workreport',1,$lastinsertid,$readerid,
                    date("Y-m-d H:i:s"),$current_user->last_name.'发出'.getFixedLabel('JOURNAL').':'.$worksummary,4));

                $crmid= $adb->getUniqueID("ld_crmentity");
                //WorkReportList workreport 1 日志/周计划/月计划 workreport
                if ($readerid != $current_user->id ){
                    $adb->pquery($this->remind_sql,array($crmid,'WorkReportList','workreport','immediately',$lastinsertid,$readerid,$current_user->id,$current_user->id,'未读',date("Y-m-d H:i:s"),date("Y-m-d H:i:s"),date("Y-m-d H:i:s"),'【工作汇报】提醒 | 有新的'.$tag.'需要您点评',0,3,3,3,3,3,3,3));
                }
            }
            else if($entitytype == 'cocmd')
            {
                 $remind_content='在'.getFixedLabel('TASK').'中提到我';
                $tag=getFixedLabel('TASK');
                 $operationtype=10;
                $adb->pquery($sql,array($lastinsertid,$cmduserid,6));//任务执行人
                 //待处理提醒
                $contentsql='select workexperience from ld_workreport where workreportid=?';
                $contentresult=$adb->pquery($contentsql,array($lastinsertid));
                $workcontent=$adb->query_result($contentresult,0,'workexperience');
                $adb->pquery($this->workreportremind_sql,array('workreport',1,$lastinsertid,$cmduserid,date("Y-m-d H:i:s"),$current_user->last_name.'发出'.getFixedLabel('TASK').':'.$worksummary,5));
                $crmid= $adb->getUniqueID("ld_crmentity");
                //WorkReportList workreport 1 任务 task
                $adb->pquery($this->remind_sql,array($crmid,'CooperativeWork','task','immediately',$lastinsertid,$cmduserid,$current_user->id,$current_user->id,'未读',date("Y-m-d H:i:s"),date("Y-m-d H:i:s"),date("Y-m-d H:i:s"),'【工作汇报】提醒 | 有新的'.getFixedLabel('TASK').'派送给您 <br/> 任务内容：'.$workcontent,0,3,3,3,3,3,3,3));
            }
            else if($entitytype=='weibo')
            {
                $remind_content='在'.getFixedLabel('BLOG').'中提到我';
                $tag=getFixedLabel('BLOG');
                $contentsql='select workexperience from ld_workreport where workreportid=?';
                $contentresult=$adb->pquery($contentsql,array($lastinsertid));
                $workcontent=$adb->query_result($contentresult,0,'workexperience');
                 $operationtype=11;
                //editor:gyq reason:新增微博改为向提醒表插入记录 userid=-5使新增微博提醒不在APP端显示  date:20161201
                $adb->pquery($this->workreportremind_sql,array('workreport',1,$lastinsertid,-5,date("Y-m-d H:i:s"),$current_user->last_name.'发出'.getFixedLabel('BLOG'),11));
            }
            $adb->pquery($sql,array($lastinsertid,$smcreatorid,3));//我发布的

			if(!empty($ccuser)){
				 foreach($ccuser as $id)//抄送
				 {//editor:gyq_20180817	0034910: 企业微信>灵当CRM>工作汇报：写日志、写周计划、写月计划，抄送人为自己的情况下，不会收到自己写的工作汇报的提醒。
						 if($id>0)
						{
                            $sql='insert into ld_workreport2user(workreportid,userid,user_type)values(?,?,?)';
                            $adb->pquery($sql,array($lastinsertid,$id,1));//抄送
                            if ($id != $current_user->id){
                                $crmid= $adb->getUniqueID("ld_crmentity");
                                $tmpreltab='WorkReportList';
                                $content='【工作汇报】提醒 | 有新的'.$tag.'抄送给你 ';
                                if ($entitytype == 'cocmd' || $entitytype == 'weibo'){
                                    $content.='<br/>'.$tag.'内容: '.$workcontent;
                                    $tmpreltab='CooperativeWork';
                                }
                                //WorkReportList workreport 3 日志抄送 reportCC
                                $adb->pquery($this->remind_sql,array($crmid,$tmpreltab,'reportCC','immediately',$lastinsertid,$id,$current_user->id,$current_user->id,'未读',date("Y-m-d H:i:s"),date("Y-m-d H:i:s"),date("Y-m-d H:i:s"),$content,0,3,3,3,3,3,3,3));
                            }
                        }
				 }
			}

			if(!empty($Atuser)){
				 foreach($Atuser as $id)//@
				 {
							if($id!=$current_user->id)// 部门id和用户ID不会重复
							{
									$sql='insert into ld_workreport2user(workreportid,userid,user_type)values(?,?,?)';
									 $adb->pquery($sql,array($lastinsertid,$id,2));//@

                                     if(!in_array($id,$ccuser))
                                     {
                                      // echo $this->remind_sql;
                                      // print_r(array('workreport',3,$lastinsertid,$id,date("Y-m-d H:i:s"),$current_user->last_name.'在工作中提到我',9));
                                        //@我的工作
                                         $adb->pquery($this->workreportremind_sql,array('workreport',3,$lastinsertid,$id,date("Y-m-d H:i:s"),$current_user->last_name.$remind_content, $operationtype));
                                         $crmid= $adb->getUniqueID("ld_crmentity");
                                         $tmpreltab='WorkReportList';
                                         $content='【工作汇报】提醒 | 有新的'.$tag.'抄送给你 ';
                                         if ($entitytype == 'cocmd' || $entitytype == 'weibo'){
                                             $content.='<br/>'.$tag.'内容: '.$workcontent;
                                             $tmpreltab='CooperativeWork';
                                         }
                                         //WorkReportList workreport 3 日志@抄送 reportCC
                                         $adb->pquery($this->remind_sql,array($crmid,$tmpreltab,'reportCC','immediately',$lastinsertid,$id,$current_user->id,$current_user->id,'未读',date("Y-m-d H:i:s"),date("Y-m-d H:i:s"),date("Y-m-d H:i:s"),$content,0,3,3,3,3,3,3,3));
                                     }
							}

				 }
			}
			if(!empty($relatedModules)){
				 foreach($relatedModules as $relatedtab=>$ids)//相关客户、联系人、产品
				 {
					 foreach($ids as $id)
					 {
						 $sql='insert into ld_workreportrelatedto(relatedto,relatedtab,workreportid)value(?,?,?)';
						 $adb->pquery($sql,array($id,$relatedtab,$lastinsertid));
					 }
				 }
			}

           //todo:附件图片
			if(isset($_REQUEST['uploadimgList']) && !empty($_REQUEST['uploadimgList'])){
				$uploadimgList = trim($_REQUEST['uploadimgList'],',');
				$update = 'update ld_workachments set workreportid = ? 
							where achmentid in ('.$uploadimgList.') ';
				$adb->pquery($update,array($lastinsertid));

                $sql="delete from ld_attachments_tempsave where newfile_name =(select concat(path,newfile_name) from ld_workachments where achmentid in (".$uploadimgList."))";
                $adb->pquery($sql,array());

			}
            //todo:附件附件
			if(isset($_REQUEST['uploadattList']) && !empty($_REQUEST['uploadattList'])){
				$uploadattList = trim($_REQUEST['uploadattList'],',');
				$update = 'update ld_workachments set workreportid = ? 
							where achmentid in ('.$uploadattList.') ';
				$adb->pquery($update,array($lastinsertid));
                $sql="delete from ld_attachments_tempsave where newfile_name =(select concat(path,newfile_name) from ld_workachments where achmentid in (".$uploadattList."))";
                $adb->pquery($sql,array());

			}
            $remind = new MessageCorpconversation();
            $errorno = $remind->sendAllTypeRemindsImmediately(null,null,'workreport_reminds_aftersave',array('workreportid'=>$workreportid));

            //wyt 221121 XUQIU1000569 小程序增加消息提醒功能，关注公众号，接收提醒（第四版）  抄送remindtype=1 ld_workreport2user.User_type=1代表有被抄送人
            $sql='SELECT Q.id,w.workreport_no,w.workreportid
from ld_workreport_remind Q
left join ld_workreport w on  w.workreportid=Q.relatedto
left join ld_workreport2user w2u on w.workreportid=w2u.workreportid
where w.deleted=0
and Q.push_to_offiaccount=2
and Q.remindtype=1
 
ORDER BY Q.createdtime desc';
                $sqlResult = $adb->pquery($sql, array());
                $id=$adb->query_result($sqlResult,0,'id');
                $workreport_no=$adb->query_result($sqlResult,0,'workreport_no');
                $workreportid=$adb->query_result($sqlResult,0,'workreportid');
                $subject[$workreportid]['subject'] = $workreport_no;
                $subject[$workreportid]['table_code'] = $workreport_no;
                $subject[$workreportid]['module'] = 'CooperativeWork';

            require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_offiaccount.php");
            $offiaccount_remind = new cls_reminds_offiaccount();


            $offiaccount_remind->sendAllTypeRemindsImmediately($id,'other',$subject,'copyin');
        }
    }

    /**
     * diony
     * 获取分类
     * 2015-03-20
     * **/
    function getEntityType($workreportid)
    {
        global $adb;
        $sql=" select entitytype from ld_workreport where workreportid = ?";
        $result=$adb->pquery($sql,array($workreportid));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
        	$entitytype = $adb->query_result($result,$i,'entitytype');
        }
        return $entitytype;
    }

    /**
     * diony
     * 判断用户是否存在
     * 2015-03-24
     * **/
    function getExistsUserName($username)
    {
        global $adb;
        $sql="select id,user_name from ld_users where last_name = ?";
        $result=$adb->pquery($sql,array($username));
        if($adb->num_rows($result)>0)
        {
            $value = $adb->query_result($result,0,'id');
        }
        else
        {
            $value = '0';
        }
        return $value;
    }

	/**
	 * 获取大类的所有字段
	 * @project 工作协同模板
	 * @author Tujt 2015-05-06
	 */
	public function getWorkFieldEntity($entitytype) {
		if(!empty($this->workcffldarr)) return $this->workcffldarr;
		$cachekey = 'cache_getworkreportfieldentity';
		$this->workcffldarr = Cache($cachekey);
		if(!$this->workcffldarr){
			global $adb;
      //字段排除签到字段 diony 2020-04-27
			$query = 'SELECT type,tablename,name,label,defaultvalue,defaultheight,is_mandatory 
						FROM ld_workreport_field where deleted = 0 and is_activate = 0 
							and entitytype = ? and name != "signaddress" order by sequence;';
			$result = $adb->pquery($query,array($entitytype));
			$rows = $adb->num_rows($result);
			$this->workcffldarr = array();
			if($rows > 0){
				for($i=0;$i<$rows;++ $i){
					$type = $adb->query_result($result,$i,'type');
					$name = $adb->query_result($result,$i,'name');
					$tablename = $adb->query_result($result,$i,'tablename');
					$this->workcffldarr[$type][$name]['name'] = $name;
					$this->workcffldarr[$type][$name]['tablename'] = $tablename;
                    if ($name == 'saleskit_week' || $name == 'saleskit_day' || $name == 'saleskit_month'){
                        $this->workcffldarr[$type][$name]['label'] = getFixedLabel('JobBriefDetails');
                    }else{
                        $this->workcffldarr[$type][$name]['label'] = $adb->query_result($result,$i,'label');
                    }
					$defaultvalue =(string) $adb->query_result($result,$i,'defaultvalue');
                    if(isset($defaultvalue))
                    {
                        $defaultvalue = strtr($defaultvalue,array('/r'=>chr(13)));
                        $defaultvalue = strtr($defaultvalue,array('/n'=>chr(13)));
                    }
					$this->workcffldarr[$type][$name]['defaultvalue'] = $defaultvalue;
					$this->workcffldarr[$type][$name]['defaultheight'] = $adb->query_result($result,$i,'defaultheight');
					$this->workcffldarr[$type][$name]['is_mandatory'] = $adb->query_result($result,$i,'is_mandatory');
				}
				Cache($cachekey,$this->workcffldarr);
			}
		}
		if(!empty($this->workcffldarr)) return $this->workcffldarr;
		return '';
	}

    public function getWorkPrevFld($entitytype,$type,$prevreport)
    {
        global $adb;
        //在field表中微博和任务的type有特殊处理
        if($entitytype == 'weibo'){
            $entitytype = 'workreport';
            $type = 4;
        }else if($entitytype == 'cocmd'){
            $entitytype = 'workreport';
            $type = 5;
        }
        $prevfldarr = $this->getWorkFieldEntity($entitytype)[$type];
        foreach($prevfldarr as &$value){
            $defaultvalue = $prevreport[$value['name']];
            $defaultvalue = strtr($defaultvalue, array('/r' => chr(13)));
            $defaultvalue = strtr($defaultvalue, array('/n' => chr(13)));
            $value['defaultvalue'] = $defaultvalue;
        }

        if(!empty($prevfldarr)) return $prevfldarr;
        return '';
    }
    /**
    * 获取签到字段
    * @project 工作协同模板
    * @author diony 2020-04-27
    */
    public function getSignAddress() {
    if(!empty($this->worksignldarr)) return $this->worksignldarr;
    $cachekey = 'cache_getworkreportsignentity';
    $this->worksignldarr = Cache($cachekey);
    if(!$this->worksignldarr){
      global $adb;
      $query = 'SELECT type,tablename,name,label,defaultvalue,defaultheight,is_mandatory,is_activate 
            FROM ld_workreport_field where deleted = 0 and entitytype = "workreport" and name = "signaddress" order by sequence;';
      $result = $adb->pquery($query,array());
      $rows = $adb->num_rows($result);
      $this->worksignldarr = array();
      if($rows > 0){
        for($i=0;$i<$rows;++ $i){
          $type = $adb->query_result($result,$i,'type');
          $name = $adb->query_result($result,$i,'name');
          $tablename = $adb->query_result($result,$i,'tablename');
          $this->worksignldarr[$type]['name'] = $name;
          $this->worksignldarr[$type]['tablename'] = $tablename;
          $this->worksignldarr[$type]['label'] = $adb->query_result($result,$i,'label');
          $defaultvalue = $adb->query_result($result,$i,'defaultvalue')??'';
          $defaultvalue = strtr($defaultvalue,array('/r'=>chr(13)));
          $defaultvalue = strtr($defaultvalue,array('/n'=>chr(13)));
          $this->worksignldarr[$type]['defaultvalue'] = $defaultvalue;
          $this->worksignldarr[$type]['defaultheight'] = $adb->query_result($result,$i,'defaultheight');
          $this->worksignldarr[$type]['is_mandatory'] = $adb->query_result($result,$i,'is_mandatory');
          $this->worksignldarr[$type]['is_activate'] = $adb->query_result($result,$i,'is_activate');
        }
        Cache($cachekey,$this->worksignldarr);
      }
    }
    if(!empty($this->worksignldarr)) return $this->worksignldarr;
    return '';
  }

	/**
	 * 获取对应的自定义字段
	 * @project 工作协同模板
	 * @author Tujt 2015-05-07
	 */
	public function getWorkCfFieldInfo($entitytype) {
		if(!empty($this->workcffld)) return $this->workcffld;
	    $workfieldarray = $this->getWorkFieldEntity($entitytype);
		if(!empty($workfieldarray)){
			foreach($workfieldarray as $setype=>$workfield){
				foreach($workfield as $fldname=>$fldobj){
					if('ld_workreportcf' == strtolower($fldobj['tablename']))//判断是否工作协同自定义字段
						$this->workcffld[$fldname] = $fldobj['tablename'];
				}
			}
		}
		if(!empty($this->workcffld)) return $this->workcffld;
		return [];
	}

   	/**
	 * 将内容中的表情转换成连接
	 * @project 添加表情
	 * @author andrew 2015-05-22
	 */
	public function changeemojicookie($contents) {
	   	$this->getemojicookie();
           if(is_null($contents))
               $contents='';
           $contents = strtr($contents, $this->cookie_link);
          return $contents;
	}
    public function getemojitext($contents) {
        $this->getemojicookie();
        $contents = strtr($contents, array_flip($this->cookie_link));
        return $contents;
    }
   	public function getemojicookie() {
	    if(!$this->filesnamelist){
   	   	    require globalStatic::$root_directory.'modules/Home/ExpressionList.php';
            $filesnamelist=$this->filesnamelist;
                foreach($filesnamelist as $key=>$arr){
                    $key='['.$key.']';
                    //$this->cookie_link[$key]='<img height=\'18\' width=\'18\' style=\'vertical-align:middle\' src=\'themes/softed/emojicookie/cookie_'.$arr.'.png\' >';
                    $this->cookie_link[$key]='<img height="18" width="18" style="vertical-align:middle" src="themes/softed/emojicookie/cookie_'.$arr.'.png" >';
                }
        }
	}

    //保存发送范围、点评人或执行人
    public function saveRangeCommentExecutor($ccgroup,$ccuser,$ccgroupname,$ccusername,$comment_execution,$comment_execution_name,$entitytype,$savetype){
        global $adb,$current_user;
        $userid=$current_user->id;

        $sql = 'select userid,type from ld_workrangenote where userid= ? and type = ? and entitytype = ?';
        $result=$adb->pquery($sql,array($userid,$savetype,$entitytype));
        if($adb->num_rows($result)>0){
            $sql_update='update ld_workrangenote set rang_group= ?,rang_group_name= ?,rang_users= ?,rang_users_name= ?,comment_execution= ?,comment_execution_name= ? where userid= ? and type = ? and entitytype = ?';
            $adb->pquery($sql_update,array($ccgroup,$ccgroupname,$ccuser,$ccusername,$comment_execution,$comment_execution_name,$userid,$savetype,$entitytype));
        }
        else{
            $sql_insert='insert into ld_workrangenote(userid,type,entitytype,rang_group,rang_group_name,rang_users,rang_users_name,comment_execution,comment_execution_name)values(?,?,?,?,?,?,?,?,?)';
            $adb->pquery($sql_insert,array($userid,$savetype,$entitytype,$ccgroup,$ccgroupname,$ccuser,$ccusername,$comment_execution,$comment_execution_name));
        }
    }

    /**
     * edit:diony
     * reason:获取文档列表
     * */
    public function getDocumentList(){
        global $adb,$current_user;
        $readers=array();//批阅人数组
        $doc_type = $_REQUEST['doc_type'];
        $bigcategory = 1;
        $smallcategory='all';
        $searchcontent='';

        $jsonArray=array();
        $jsonArray['summary']['processedCount']=$this->getprocessingCount();
        $sql = '';
        if($doc_type=='document'){
            /*
            $sql = "SELECT * FROM ld_workachments
                    where type = 'att' and workreportid != 0 and name != ''
                    GROUP BY workreportid ORDER BY achmentid";
            */
            $sql = "SELECT workreportid FROM ld_workachments 
                    where type = 'att' and name != '' ";
            if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
                $viewuserid = $_REQUEST['viewuserid'];
                $sql .= " and ld_workachments.workreportid in (select workreportid from ld_workreport2user where userid = $viewuserid) ";
            }
            else{
                $sql .= " and ld_workachments.workreportid in (select workreportid from ld_workreport2user where userid = $current_user->id) ";
            }
            if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
                $sql .= " and ld_workachments.workreportid in (select workreportid from ld_workreport2user where userid = $current_user->id) ";
            }
            $sqlcount='select 1  from ('.$sql .') as a1 ';
        }
        else if($doc_type=='picture'){
            /*
            $sql = "SELECT * FROM ld_workachments
                    where type = 'image' and workreportid != 0 and name != ''
                    GROUP BY workreportid ORDER BY achmentid";
            */
            $sql = "SELECT workreportid FROM ld_workachments 
                    where type = 'image' and name != '' ";
            if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
                $viewuserid = $_REQUEST['viewuserid'];
                $sql .= " and ld_workachments.workreportid in (select workreportid from ld_workreport2user where userid = $viewuserid) ";
            }
            else{
                $sql .= " and ld_workachments.workreportid in (select workreportid from ld_workreport2user where userid = $current_user->id) ";
            }
            if(isset($_REQUEST['viewuserid']) && $_REQUEST['viewuserid']!= ''){
                $sql .= " and ld_workachments.workreportid in (select workreportid from ld_workreport2user where userid = $current_user->id) ";
            }
            $sqlcount='select 1  from ('.$sql .' GROUP BY ld_workachments.workreportid) as a1 ';
        }
        //echo $sqlcount;echo '<br><br>';die;
        $resultcount=$adb->pquery($sqlcount);

        $noofrows=$adb->num_rows($resultcount);
        $jsonArray['summary']['totalrows']=$noofrows;
        $mobile_pagerecordcount=20;
        $startpagenum=0;
        $endpagenum=$mobile_pagerecordcount;
        $startpagerecord=0;
        $endpagerecord=$mobile_pagerecordcount;
        $haveprevpage='yes';
        $havenextpage='yes';

        $totalpagecount=ceil ($noofrows/$mobile_pagerecordcount);
        if($totalpagecount*$mobile_pagerecordcount<$noofrows)
        {
            $totalpagecount+=1;
        }
        if(!isset($_REQUEST['page']))
        {
            $_REQUEST['page']=1;
        }
        $startpagenum=$_REQUEST['page']-1;
        if($_REQUEST['page']>=$totalpagecount)//是否有下一页
        {
            $havenextpage='no';
            $startpagenum=$totalpagecount-1;
        }
        if($_REQUEST['page']<=1)//是否有上一页
        {
            $haveprevpage='no';
            $startpagenum=0;
        }

        $jsonArray['summary']['pagecount']=$totalpagecount;
        $jsonArray['summary']['havenextpage']=$havenextpage;
        $jsonArray['summary']['haveprevpage']=$haveprevpage;
        $jsonArray['summary']['curpagenum']=$startpagenum+1;
        $startpagerecord=$startpagenum*$mobile_pagerecordcount;
        $endpagerecord=$startpagerecord+$mobile_pagerecordcount;

        $sql.=" GROUP BY ld_workachments.workreportid ORDER BY ld_workachments.achmentid desc limit $startpagerecord, $mobile_pagerecordcount ";
        $result=$adb->pquery($sql,array());
        /*
        echo $sql;echo '<br><br>';
        print_r($params);die;
        */
        $entityContents=$this->createDocumentList($result);//创建工作文档
        $jsonArray['report']=$entityContents;
        return $jsonArray;
    }
    //创建工作文档
    protected function createDocumentList($result){
        global $adb,$current_user;
        $entityContents=array();
        for($i=0;$i<$adb->num_rows($result);$i++){
            $workreportid=$adb->query_result($result,$i,'workreportid');
            $workachment = $this->getWorkAchmentInfo($workreportid);

            $date_sql = "select createdtime,entitytype,type from ld_workreport where workreportid = ? ";
            $date_params=array($workreportid);
            $date_result=$adb->pquery($date_sql,$date_params);
            $entitytype=$adb->query_result($date_result,0,'entitytype');
			$type=$adb->query_result($date_result,0,'type');
            if($entitytype=='weibo'){
                $entitytypename = getFixedLabel('BLOG');
            }
            else if($entitytype=='cocmd'){
                $entitytypename = getFixedLabel('TASK');
            }
            else if($entitytype=='workreport'){
                if($type==1){
                    $entitytypename = getFixedLabel('JOURNAL');
                }
                else if($type==2){
                    $entitytypename = getFixedLabel('WEEKPLAN');
                }
                else if($type==3){
                    $entitytypename = getFixedLabel('MONTHPLAN');
                }
            }
            $createDateTime=$adb->query_result($date_result,0,'createdtime');
            $timedescription=$this->getTimeDescription($createDateTime);

            $achmentArr = array('curid'=>$workreportid,'workreporttime'=>$timedescription,
                                'entitytype'=>$entitytype,'entitytypename'=>$entitytypename,
                                'workachment'=>$workachment);
            $entityContents[] = $achmentArr;
        }
        $entity['list'] = $entityContents;
        return $entity;
    }
	public function getSendLog_SalesKit_date($workreportid,$userid){
		global $adb;
		$query = "select createdtime,type,sendlog_workdate from ld_workreport where workreportid = ? and entitytype = 'workreport'";
		$result = $adb->pquery($query,array($workreportid));
		$createdtime = $adb->query_result($result,0,0);
		$type = $adb->query_result($result,0,1);
		$sendlog_workdate = $adb->query_result($result,0,2);
		if(empty($sendlog_workdate)){
			if($type == 1){
				$sendlog_date = date("Y-m-d",strtotime($createdtime));
			}else if($type == 2){
				$first = 1;
				$createdtime = date("Y-m-d",strtotime($createdtime));
				$w=date('w',strtotime($createdtime));
				$week_start=date('Y-m-d',strtotime("$createdtime -".($w ? $w - $first : 6).' days'));
				$week_end=date('Y-m-d',strtotime("$week_start +6 days"));
				$sendlog_date = $week_start .' ~ '. $week_end;
			}else{
				$createdtime = date("Y-m-d",strtotime($createdtime));
				$startTime=mktime(0,0,0,date('m',strtotime($createdtime)),1,date('Y',strtotime($createdtime)));
				$end=strtotime('+1 month');
				$endTime=mktime(0,0,0,date('m',$end),1,date('Y',$end))-1;//当前月结束时间
				$sendlog_date = date('Y-m-d',$startTime) . ' ~  ' . date('Y-m-d',$endTime);
			}
		}else{
			$sendlog_date = $sendlog_workdate;
		}
		return $this->getSendLog_SalesKit($sendlog_date,$userid);
	}
	//获取工作汇报日志的销售简报
	public function getSendLog_SalesKit($sendlog_date,$userid=''){
        global $adb,$current_user,$languageType;
        $option = vtlib_purify($_REQUEST['option']);
        if(!empty($_REQUEST['getInfo']) && $_REQUEST['getInfo'] == 'yes'){
            $option = 'text';//手机端
        }
        if (empty($option)){
            $option = 'list';
        }
        if($sendlog_date=='undefined'||empty($sendlog_date))
        {
            $sendlog_date=date("Y-m-d");
        }
		if(empty($userid)){
			$userid = $current_user->id;
		}
		$sendlog_dates = explode(' ~ ',$sendlog_date);

        $showtype = getUsersettingByLabel('CooperativeWork',1,'WorkBriefReportShowType');
        $showtype = empty($showtype)?'text':$showtype;

        $list = $this->getSendLogResult($option,$sendlog_dates,$userid,$showtype);

        //XUQIU1002237 工作汇报模板定制，增加“自动生成简报”参数（宋清华）wsh
        crm_load_class_file('WorkTemplateRule','modules/Settings');
        $workTemplateRuleobj = new WorkTemplateRule();
        $workTemplateRuleobj->setWorkReportType($this->getWorktype());
        $applicable_ruleinfo = $workTemplateRuleobj->getApplicableRuleByUserid($current_user->id);
        $arr['list']=$list;
        $arr['userid']=$userid;
        $arr['auto_generate_brief'] = isset($applicable_ruleinfo['auto_generate_brief'])?$applicable_ruleinfo['auto_generate_brief']:'';
        $arr['sendlog_date'] = $sendlog_date;
        $arr['saleskit_showtype'] = $showtype;
        return $arr;
    }
    public function getSendLogResult($option,$sendlog_dates,$userid,$showtype){
        global $adb,$current_user,$languageType, $MobileLanguageType;
        include(globalStatic::$root_directory."include/VarGeneralBol/GeneralBolSql.php");
        require_once(globalStatic::$root_directory."modules/Home/DataRangeHomeboard.php");
        $sys_delpoy_351 = getSys_deploy(351);//金额小数位数
        $sys_delpoy_49 = getSys_deploy(49);//数量小数位数
        $sys_delpoy_93 = getSys_deploy(93);//单价小数位数
        $uitype_module = [];
        if($showtype == 'html'){
            require_once(globalStatic::$root_directory.'include/fields/cls_module_uitype.php');
            $referenceUitype = cls_module_uitype::getAllReferenceUitype();
            $multiReferenceUitype = cls_module_uitype::getAllMultiReferenceUitype();
            foreach ($referenceUitype as $module => $uitype_arr){
                foreach ($uitype_arr as $key => $uitype){
                    $uitype_module[$uitype] = $module;
                }
            }
            foreach ($multiReferenceUitype as $module => $uitype_arr){
                foreach ($uitype_arr as $key => $uitype){
                    $uitype_module[$uitype] = $module;
                }
            }
        }

        $DataRangeHomeboardObj = DataRangeHomeboard::getInstance('WorkBriefReport');
        $starttime = trim($sendlog_dates[0]);
        $endtime = empty($sendlog_dates[1])?$sendlog_dates[0]:$sendlog_dates[1];
        if(sizeof($sendlog_dates) > 1){
            $daterange = " between '$sendlog_dates[0] 00:00:00' and '$sendlog_dates[1] 23:59:59' " ;
        }else{
            $daterange = " like '%$sendlog_dates[0]%' " ;
        }
        $sql= "select 
        name,sequence,presence,is_default,label_zh,label_en,count_module,count_type,count_columnname,count_datarange,count_timerange,advft_criteria,advft_criteria_groups,content_value 
        from ld_workreport_briefreport_detail 
        where `delete`=0 and presence = 'yes' 
        order by sequence asc;";
        $result = $adb->pquery($sql,array());
        $num_row = $adb->num_rows($result);
        if($num_row>0){
            $dataArr = $adb->query_result_all($result);
            $dataArr = array_filter($dataArr);
            foreach ($dataArr as $key => $info){
                $list = [];
                $name = $info['name'];
                $count_module = $info['count_module'];
                if(vtlib_isModuleActive($count_module) && isPermitted($count_module,'index','')=='yes'){
                    $count_type = $info['count_type'];
                    $count_columnname = $info['count_columnname'];
                    $count_datarange = $info['count_datarange'];
                    $count_timerange = $info['count_timerange'];
//                    $focus = CRMEntity::getInstance($count_module);
//                    $datafieldarr = explode(':',$count_datarange);
//                    $timefieldarr = explode(':',$count_timerange);
//                    $datacolumnname = $datafieldarr[1];
//                    $timecolumnname = $timefieldarr[1];
//                    if (!array_key_exists($datacolumnname,$focus->column_fields) && !array_key_exists($timecolumnname,$focus->column_fields)){//判断字段有没有启用
//                        continue;
//                    }
                    $fieldobj = Field::getInstance($count_module,$adb);
                    $wholeModuleField = $fieldobj->getModuleWholeFields();
                    $fieldobj->setModuleAllPreseneceFields($wholeModuleField);
                    if($this->plateform=='pc')
                            $label = $languageType == 'zh'?$info['label_zh']:$info['label_en'];
                    else
                        $label = $MobileLanguageType == 'en'?$info['label_en']:$info['label_zh'];
                    $advft_criteria_groups= decode_html($info['advft_criteria_groups']);
                    $advft_criteria= ldcrm_json_decode(decode_html($info['advft_criteria']));

                    if(isKehu001ServerPc()=='yes')
                        $last_name= getUserRealName($userid);
                    else
                        $last_name=getUserFullName($userid);

                    if (empty($advft_criteria)){
                        $tmp_advft_criteria = array(
                            ['groupid'=>1,
                                'columnname'=>$count_timerange,
                                'comparator'=>'bw',
                                'value'=>$starttime.' 00:00:00,'.$endtime.' 23:59:59',
                                'columncondition'=>'']
                        );
                        $new_advft_criteria = array(
                            ['groupid'=>1,
                                'columnname'=>$count_datarange,
                                'comparator'=>'e',
                                'value'=>$last_name,
                                'columncondition'=>'and'],
                            ['groupid'=>1,
                                'columnname'=>$count_timerange,
                                'comparator'=>'bw',
                                'value'=>$starttime.' 00:00:00,'.$endtime.' 23:59:59',
                                'columncondition'=>'']
                        );
                        $advft_criteria_groups = '[null,{"groupcondition":""}]';
                    }
                    else{
                        $tmp_advft_criteria = array(
                            ['groupid'=>1,
                                'columnname'=>$count_timerange,
                                'comparator'=>'bw',
                                'value'=>$starttime.' 00:00:00,'.$endtime.' 23:59:59',
                                'columncondition'=>'and']
                        );
                        $tmp_advft_criteria = array_merge($tmp_advft_criteria,$advft_criteria);
                        $new_advft_criteria = array(
                            ['groupid'=>1,
                                'columnname'=>$count_datarange,
                                'comparator'=>'e',
                                'value'=>$last_name,
                                'columncondition'=>'and'],
                            ['groupid'=>1,
                                'columnname'=>$count_timerange,
                                'comparator'=>'bw',
                                'value'=>$starttime.' 00:00:00,'.$endtime.' 23:59:59',
                                'columncondition'=>'and']
                        );
                        $new_advft_criteria = array_merge($new_advft_criteria,$advft_criteria);
                    }
                    $content_value = $info['content_value'];
                    $inner_input['advft_criteria'] = ldcrm_json_encode($tmp_advft_criteria);
                    $inner_input['advft_criteria_groups']=$advft_criteria_groups;
                    $new_inner_input['advft_criteria'] = ldcrm_json_encode($new_advft_criteria);
                    $new_inner_input['advft_criteria_groups']=$advft_criteria_groups;
                    $saleskit_params = [
                        'stuffid'=>'workBriefReport',
                        'compute_module'=>$count_module,//计算模块
                        'scopeType'=>'smowner_search_senior',//查询范围类型
                        'senioruserid'=>$userid,//人员ID
                        'datewhere'=>$daterange,//本期时间
                        'before_datewhere'=>'',//上期时间
                        'approve_value'=> 'all',//审批条件
                        'advance_demand'=>$inner_input['advft_criteria'],
                        'compute_columns'=>$count_columnname,
                        'advance_demand_groups'=>$inner_input['advft_criteria_groups'],
                        'viewrange'=>$count_datarange,//查看范围限制字段
                        'daterange'=>$count_timerange,//日期字段限制字段
                        'searchtype'=>'now'
                    ];

                    $DataRangeHomeboardObj->getDataRangeSqlSalesKit($saleskit_params);
                    $where = $DataRangeHomeboardObj->datarangesqlArr['cur'];

                    $tmpQueryObj = $DataRangeHomeboardObj->queryObjArr[$count_module];
                    $from = $tmpQueryObj->getFromClause();
                    $maintablename=$tmpQueryObj->moduleobj->table_name;
                    $maintableindex=$tmpQueryObj->moduleobj->table_index;
                    $focus=CRMEntity::getInstance($count_module);
                    $maintablecf_info = $tmpQueryObj->moduleobj->customFieldTable;
                    if(sizeof($maintablecf_info)>0){
                        $maintablecfname = $maintablecf_info[0];
                        $maintablecfid = $maintablecf_info[1];
                    }
                    if ($option == 'list'){//显示
                        $ismoney = 'no';
                        $columnname=explode('.',$count_columnname)[1];
                        $tablename=explode('.',$count_columnname)[0];
                        if(array_key_exists($tablename,$focus->tab_name_index))
                            $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$columnname);
                        else{
                            if(!empty($focus->detailfieldobj)){
                                $fieldinfo=$focus->detailfieldobj->getFieldInfoobjBykey("columnname",$columnname);
                            }
                        }
                       if ($fieldinfo){
                           if ($count_type == 'sum'){
                               if($fieldinfo&&($fieldinfo->getBigType()=="currency"||$fieldinfo->getBigType()=='amount') && isHaveCurrrencyColumn($count_module) == 'yes'){//金额字段
                                   $ismoney = 'yes';
                                   $currencyobj=Currency::getInstance($adb);
                                   $currencyid = $currencyobj->getcurrencyid();
                                   $currencyinfo = $currencyobj->getCurrencyCacheInfo($currencyid);
                                   $currency_symbol = html_entity_decode($currencyinfo['currency_symbol']);
                                   $query = 'select sum(if('.$maintablename.'.currency_id > 1 ,ifnull('.$count_columnname.',0)/'.$maintablename.'.conversion_rate ,ifnull('.$count_columnname.',0))) as total ';
                               }else{
                                   $query = 'select sum(ifnull('.$count_columnname.',0)) as total ';
                               }
                           }else{
                               $query = 'select count( ifnull('.$count_columnname.',1)) as total ';
                           }

                           if ($maintablecfname == $tablename || $maintablename == $tablename){
                               $from = ' from '.$maintablename.' ';
                               if ($tablename == $maintablecfname){
                                   $from .= ' left join '.$maintablecfname.' on '.$maintablecfname.'.'.$maintablecfid.'='.$maintablename.'.'.$maintableindex.' ';
                               }
                           }
                           $query .=$from.$where;
                           $displayresult = $adb->pquery($query,array());
                           if ($adb->num_rows($displayresult) > 0) {
                               $total = $adb->query_result($displayresult,0,'total');
                           }
                       }else{
                           $total = '0';
                       }


                        $total = empty($total)?'0':$total;
                        if (!empty($fieldinfo)){
                            $bigtype = $fieldinfo->getBigType();
                            $uitype = $fieldinfo->getUIType();
                            if (($bigtype == "currency" || $bigtype == 'amount') && isHaveCurrrencyColumn($count_module) == 'yes'){
                                $total = setNumberFormat($total,$sys_delpoy_351['deploy_value']);
                            }elseif($bigtype == 'num'){
                                $total = setNumberFormat($total,$sys_delpoy_49['deploy_value']);
                            }elseif ($uitype == 163){
                                $total = setNumberFormat($total,$sys_delpoy_93['deploy_value']);
                            }
                        }
                        $istotalempty = 'yes';
                        if ($total != '0'){
                            $istotalempty = 'no';
                        }
                        $nums = $ismoney == 'no'?$total:($currency_symbol.$total);
                        $arr[strtolower($name)]=array('nums'=>$nums,'label'=>$label,'module'=>$count_module,'istotalempty'=>$istotalempty,'session_search_criteria'=>json_encode($new_inner_input),'session_count_columnname'=>json_encode($count_columnname));
                    }else{//生成
                        if (empty($content_value)){
                            continue;
                        }
                        $GeneralBolSqlObj=new GeneralBolSql($count_module,'');
                        $GeneralBolSqlObj->createPrintSQL($content_value);
                        $var_select = $GeneralBolSqlObj->getVarSelectQuery();
                        $leftjoin = $GeneralBolSqlObj->getFromQuery();
                        $printcolumn = $GeneralBolSqlObj->getPrintColumns();
                        $fieldarr = $GeneralBolSqlObj->getFieldArr();
                        $lower_fieldname_uitype = $fieldarr['lower_fieldname_uitype'];


                        $hrefcolumnname_select_str = '';
                        $hrefcolumnname_select_arr = [];
                        $hrefcolumnname_arr = [];

                        //简报样式为text
                        if ($showtype == 'text'){
                            $hrefcolumnname_select_str = '';
                        }else if ($showtype == 'html'){//简报样式为html
                            $entityfield = getEntityField($count_module);
                            $hreffieldfieldname = $entityfield['fieldname'];
                            foreach ($printcolumn as $tmp_key => $tmp_value){
                                $tmp_fieldname = substr($tmp_key, 0, strrpos($tmp_key, '_'));
                                $tmp_fieldinfo = $fieldobj->getFieldInfoobjBykey('fieldname',$tmp_fieldname);
                                if ($tmp_fieldinfo){
                                    $fieldinfo_arr[$tmp_columnname] = $tmp_fieldinfo;
                                    $tmp_columnname = $tmp_fieldinfo->getColumnName();
                                    $tmp_ShowHyperlinks = $tmp_fieldinfo->get_ShowHyperlinks();
                                    $tmp_uitype = $tmp_fieldinfo->getUIType();
                                    if ($tmp_fieldname == $hreffieldfieldname || $tmp_ShowHyperlinks == 'yes'){
                                        if ($tmp_ShowHyperlinks == 'yes' && $tmp_uitype == 202) {
                                            $relatedModule = 202;
                                            $relatedField = 'yes';
                                        }else if ($tmp_ShowHyperlinks == 'yes' && $tmp_fieldname != $hreffieldfieldname ){
                                            $relatedModule = $uitype_module[$tmp_uitype];
                                            $relatedField = 'yes';
                                        }else{
                                            $relatedModule = $count_module;
                                            $relatedField = 'no';
                                        }
                                        $tmp_table = $tmp_fieldinfo->getTableName();
                                        $tmp_tablename = explode('_',$tmp_table)[1];
                                        $hrefcolumnname_arr[$tmp_columnname] = array('text'=>strtolower('[var.'.$tmp_tablename.'_'.$tmp_fieldname.'_'.$count_module.']'),'relatedField'=>$relatedField,'relatedModule'=>$relatedModule);
                                        $hrefcolumnname_select_arr[] = $tmp_table.'.'.$tmp_columnname;
                                    }
                                }
                            }

                            $hrefcolumnname_select_str = implode(',',$hrefcolumnname_select_arr);
                            $hrefcolumnname_select_str = empty($hrefcolumnname_select_str)?'':$hrefcolumnname_select_str.', ';
                        }

                        $query = 'select '.$hrefcolumnname_select_str.$maintablename.'.'.$maintableindex.$var_select.' from '.$maintablename.' '.$leftjoin;
                        $query .=' inner join (select distinct '.$maintablename.'.'.$maintableindex.' '.$from.$where.') as tmp on tmp.'.$maintableindex.' = '.$maintablename.'.'.$maintableindex;
                        $textresult = $adb->pquery($query,array());
                        if($adb->num_rows($textresult) > 0){
                            $data = $adb->query_result_all($textresult);

                            if (in_array('202',$printcolumn)) {
                                $sourcelist_key = array_search('202', $printcolumn);
                                $showfieldvalueobj=new ShowFieldValue($focus->fieldobj,$count_module,SHOW_POPUP);
                            }
                            foreach ($data as $key => $value){
                                $href = [];
                                if (in_array('202',$printcolumn)){
                                    $tmp_sourcelistvalue = $value['[var.'.strtolower($count_module).'_'.$sourcelist_key.']'];
                                    if (!empty($tmp_sourcelistvalue)){
                                        $tmp_recordid = $value[$maintableindex];
                                        $showfieldvalueobj->setRecorId($tmp_recordid);
                                        $sourcelistvalue_fieldobj = $focus->fieldobj->getFieldInfoobjBykey('uitype','202');
                                        $value_arr = $showfieldvalueobj->getFieldValueByField($sourcelistvalue_fieldobj,$tmp_sourcelistvalue,$tmp_sourcelistvalue);
                                        $value['[var.'.strtolower($count_module).'_'.$sourcelist_key.']'] = $value_arr['value'];
                                    }
                                }
                                //BUG20240508-12 V8.6.3.2版本，工作汇报-工作简报详情中的金额信息是8位小数，单据上是2位，正常应该是2位才对
                                foreach($value as $k=>&$v){
                                    $tmp_fieldname_curtable = str_replace(']','',substr(strstr($k, '_'), 1));
                                    $uitype = $lower_fieldname_uitype[$tmp_fieldname_curtable];
                                    if($uitype == 71 || $uitype == 72){
                                        $v=setNumberFormat($v,$sys_delpoy_351['deploy_value']);
                                    }
                                    if (array_key_exists($k,$hrefcolumnname_arr)){
                                        $tmp_label = $value[$hrefcolumnname_arr[$k]['text']];
                                        $tmp_label = empty($tmp_label)?'':$tmp_label;
                                        $tmp_record = $hrefcolumnname_arr[$k]['relatedField'] == 'yes'?$value[$k]:$value[$maintableindex];
                                        $tmp_relatedModule = $hrefcolumnname_arr[$k]['relatedModule'];
                                        $tmp_record_arr = explode(',',$tmp_record);
                                        $tmp_key = $hrefcolumnname_arr[$k]['text'];

                                        if (sizeof($tmp_record_arr) > 1){
                                            $tmp_label_arr = explode(',',$tmp_label);
                                            $tmp_replace_arr = [];
                                            foreach ($tmp_record_arr as $tmp_index => $tmp_record){
                                                if (!empty($tmp_record) && !empty($tmp_relatedModule)){
                                                    $tmp_replace = $tmp_key.'_'.$tmp_index;
                                                    $tmp_replace_arr[] = $tmp_replace;
                                                    if ($tmp_relatedModule == 202){
                                                        $tmp_relatedmodule = getSalesEntityType($tmp_record);
                                                    }else{
                                                        $tmp_relatedmodule = $tmp_relatedModule;
                                                    }
                                                    $href[] = array('columnname'=>$k,'module'=>$tmp_relatedmodule,'record'=>$tmp_record,'label'=>$tmp_label_arr[$tmp_index],'replace'=>$tmp_replace);
                                                }
                                            }
                                            $value[$hrefcolumnname_arr[$k]['text']] = implode(',',$tmp_replace_arr);
                                        }else{
                                            if (!empty($tmp_record) && !empty($tmp_relatedModule)){
                                                if ($tmp_relatedModule == 202){
                                                    $tmp_relatedmodule = getSalesEntityType($tmp_record);
                                                }else{
                                                    $tmp_relatedmodule = $tmp_relatedModule;
                                                }
                                                $value[$hrefcolumnname_arr[$k]['text']] = $tmp_key;
                                                $href[] = array('columnname'=>$k,'module'=>$tmp_relatedmodule,'record'=>$tmp_record,'label'=>$tmp_label,'replace'=>$tmp_key);
                                            }
                                        }
                                    }
                                }

                                $content =strtr(strtolower($content_value),$value);
                                if(!empty($content)){
                                    if(!empty($href)){//将href的数据按照label的长度从大到小重新排序
                                        usort($href, function($a, $b) {
                                            return strlen($b['label']) - strlen($a['label']);
                                        });
                                    }
                                    $content = trim(str_replace('"','',$content));
                                    $list[]=array('text'=>$content,'href'=>$href);
                                }
                            }
                        }
                        $list = array_filter($list);
                        if(!empty($list)){
                            $arr[]=array('label'=>$label,'list'=>$list);
                        }



                    }
                    $queryarr[]=$query;
                }
            }
        }
//        dump($queryarr);
        if (empty($arr)) $arr = array();
        return $arr;
    }

	//快速搜索
    public function unifiedSearch(){
        global $adb,$current_user;
        $_REQUEST['diony'] = 'yes';
        $sql = 'select searchmodules from ld_users where id=?';
        $result = $adb->pquery($sql,array($current_user->id));
        if($adb->num_rows($result)>0)
        {
            $tmpsearchmodules = trim(trim($adb->query_result($result,0,0),','));
            if($tmpsearchmodules == ''){
                $tmpsearchmodules = 'Accounts,Contacts,ContactRecords,SalesOrder';
            }
            if($tmpsearchmodules!='')
            {
                $_SESSION['__UnifiedSearch_SelectedModules__']=explode(',',$tmpsearchmodules);
                $_REQUEST['search_onlyin']=$tmpsearchmodules;
                $_SESSION['__UnifiedSearch_SelectedModules__']=$tmpsearchmodules;
            }
        }
        if($_REQUEST['quick_query_session']==1)
        {
            $_REQUEST['query_string']=$_SESSION['quick_query_session'];
            $_REQUEST['search_onlyin']=implode(',',$_SESSION['__UnifiedSearch_SelectedModules__'] );

        }
        $query_string = trim($_REQUEST['query_string']);
        $_SESSION['quick_query_session'] = $query_string;
        if(isset($query_string) && $query_string != ''){
            // Was the search limited by user for specific modules?
            $search_onlyin = $_REQUEST['search_onlyin'];
            if(!empty($search_onlyin) && $search_onlyin != '--USESELECTED--') {
                $search_onlyin = explode(',', $search_onlyin);
            } else if($search_onlyin == '--USESELECTED--') {
                $search_onlyin = $_SESSION['__UnifiedSearch_SelectedModules__'];
            } else {
                $search_onlyin = array();
            }
            $_SESSION['__UnifiedSearch_SelectedModules__'] = $search_onlyin;
            $object_array = $this->getSearchModules($search_onlyin);
            if(vtlib_isModuleActive('ReportLog'))
            {
                if(in_array('DailyReport',$search_onlyin))
                {
                    $object_array['DailyReport']='DailyReport';
                }
                if(in_array('WeekReport',$search_onlyin))
                {
                    $object_array['WeekReport']='WeekReport';
                }
                if(in_array('MonthReport',$search_onlyin))
                {
                    $object_array['MonthReport']='MonthReport';
                }
            }
            $i = 0;
            $allsearchfields = array();
            $moduleRecordCount = array();
            $list_max_entries_per_page_new = 20;
            crm_load_class_file('Inventory','data');
            crm_load_class_file("UnifiedSearch_CustomView",'modules/Home');
            crm_load_class_file("cls_QuickQuery",'modules/Home/QuickQuery');

            crm_load_class_file("cls_UnifiedSearch_Controller",'include/ListView/UnifiedSearch');
            setSearchAllAccount();
            $listres = [];

            //下拉框对象,用于获取下拉框颜色
            global $global_picklist_colors_byvalue;
            crm_load_class_file("cls_PickList_Ori",'include/Functions/PickList');
            $picklistobj = new cls_PickList_Ori();

            foreach($object_array as $module => $object_name){
                if($module=='DailyReport'||$module=='WeekReport'||$module=='MonthReport')
                {
                    $permitted = isPermitted('ReportLog',"DailyReportLog");
                }else{
                    $focus = CRMEntity::getInstance($module);
                    if(!vtlib_isModuleActive($module)) {
                        $permitted = 'no';
                    }else{
                        $permitted=isPermitted($module,"index");
                    }
                }
                if( $permitted== "yes"){
                    if($module=='DailyReport'|| $module=='WeekReport'||$module=='MonthReport')
                    {
                        $listquery = ReportLogSql($module);
                        $count_result = $adb->query($listquery);
                        $noofrows = $adb->num_rows($count_result);
                        if($noofrows<=0) {
                            continue;//37087: （1.6）快速查找>录入【合同】进行查找：查找出的结果没有数据的模块不显示。（需要补丁）
                        }
                    }else {
                        $oCustomView = '';
                        $queryGenerator =new cls_QuickQuery($module);
                        $controller = new cls_UnifiedSearch_Controller($adb, $current_user, $queryGenerator->queryobj,$module);
                        $page_list_query=$queryGenerator->getQuery("1");//排序
                        $_SESSION[$module.'_quicksearch_listquery']=$page_list_query;
                        $list_query=$queryGenerator->getQuery("2");
                        if(!empty($_REQUEST['start']) && !empty($_REQUEST['refmodule']) && $_REQUEST['refmodule'] == $module){
                            $start = $_REQUEST['start'];
                            if($start == 'last'){
                                $count_result = $adb->query( $page_list_query);
                                $noofrows = $adb->num_rows($count_result);
                                if($noofrows > 0){
                                    $start = ceil($noofrows/$list_max_entries_per_page_new);
                                }
                            }
                            if(!is_numeric($start)){
                                $start = 1;
                            } elseif($start < 0){
                                $start = 1;
                            }
                            $start = ceil($start);
                        }else{
                            $start = 1;

                        }
                        $count_result = $adb->query( $page_list_query);
                        $noofrows = $adb->num_rows($count_result);
                        if($noofrows<=0)
                        {
                            continue;//37087: （1.6）快速查找>录入【合同】进行查找：查找出的结果没有数据的模块不显示。（需要补丁）
                        }

                        $navigation_array['start']=$start;
                        $limitStartRecord = ($navigation_array['start'] - 1) * $list_max_entries_per_page_new;

                        list($page_list_query,$order_by,$sorder)=$queryGenerator->customviewobj->getOrderWhere($page_list_query);
                        if($module=='PublicAnnouncement') {
                            $listquery=$page_list_query;
                        }else {
                            $listquery=$list_query." inner join  ($page_list_query limit $limitStartRecord, $list_max_entries_per_page_new ) as tmp on tmp.".$focus->table_index."=".$focus->table_name.".".$focus->table_index;
                            $listquery.=$queryGenerator->queryobj->getGroupBy();//服务收费管理查询
                            $listquery.=' order by '.$order_by.' '.$sorder.' , '.$focus->table_name.".".$focus->table_index.' '.$sorder;
                        }
                    }
                    $moduleRecordCount[$module]['count'] = $noofrows;
                    crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
                    $navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new, $noofrows);

                    $list_result = $adb->query($listquery);
                    $count_result = $adb->query($page_list_query . " limit $limitStartRecord, $list_max_entries_per_page_new");
                    $moduleRecordCount[$module]['recordListRangeMessage'] = getRecordRangeMessage($count_result, $limitStartRecord, $noofrows);
                    $listview_field = array();

                    if($module!='DailyReport'&&$module!='WeekReport'&&$module!='MonthReport')
                    {


                        $listview_header =$controller->getListViewHeader($focus, $module,'',$sorder,$order_by,'');
                        $listview_field = $controller->listviewcontroller->getListViewFields($module);
                        $focus_obj=Field::getInstance($module,$adb);
                        $moduleFields = $focus_obj->getModuleFields();
                        $tmpfields=$focus_obj->getFieldListArray();
                        $allsearchfields[$module]=$tmpfields['fields'];
                        $listview_entries = $controller->getListViewEntries($focus,$module,$list_result,$navigation_array,'');
                    }else{
                        $listview_header = ReportLogHeader($module);
                        $listview_entries = ReportLogEntries($module,$list_result);
                    }
                    //按索引获取所有列表页字段对象
                    $listview_fieldobj = array();
                    if(sizeof($listview_field)>0){
                        foreach($listview_field as $tmp_index => $fieldname){
                            $listview_fieldobj[$tmp_index] = $focus_obj->getFieldInfoobjBykey('fieldname',$fieldname);
                        }
                    }
                    //剥离html
                    foreach($listview_header as &$h){
                        $h = strip_tags($h);
                    }
                    foreach($listview_entries as $lk_str => &$l){
                        $l = array_values($l);
                        $lk = explode(',',$lk_str);
                        $temp_l = [];
                        $new_field = array();
                        $title_color = '';
                        foreach($l as $k=>$e){
                            if($k<=4){
                                $temp_l[$k] = strip_tags($e);
                                $tmp_value = trim($temp_l[$k]);

                                $temp_l[$k] = $listview_header[$k].':'.$temp_l[$k];

                                $fieldinfo = $listview_fieldobj[$k];
                                if(!empty($fieldinfo)){
                                    if($fieldinfo->getBigType() == 'picklist'){
                                        $picklistobj->getPickListValues($fieldinfo->getFieldName(),$fieldinfo);
                                        $color_arr = $global_picklist_colors_byvalue[$fieldinfo->getFieldName()];
                                        $fieldvaluecolor = isset($color_arr[$tmp_value])&&!empty($color_arr[$tmp_value])?$color_arr[$tmp_value]:'';
                                    }else{
                                        $fieldvaluecolor = $fieldinfo->getFieldValueColor();
                                        if(empty($fieldvaluecolor)) $fieldvaluecolor = '';
                                    }

                                    if($k == 0){
                                        $title_color = $fieldvaluecolor;
                                    }
                                    $new_field[$k][] = array('label'=>$listview_header[$k].':','value'=>$tmp_value,'fieldvaluecolor'=>$fieldvaluecolor);

                                }else{
                                    $new_field[$k][] = array('label'=>$listview_header[$k].':','value'=>$tmp_value,'fieldvaluecolor'=>'');
                                }
                            }
                        }
                        if(!empty($listres[$lk_str])){// 服务收费管理和客户键值一样内容会被覆盖
                            $lk_str .= ';'.$module;
                        }
                        $listres[$lk_str]['curid'] = $lk[0];
                        $listres[$lk_str]['module'] = $module;
                        $listres[$lk_str]['modulelabel'] = getTranstab($module);
                        $listres[$lk_str]['title'] = $temp_l[0];
                        $listres[$lk_str]['title_color'] = $title_color;
                        unset($temp_l[0]);
                        $listres[$lk_str]['field'] = array_values($temp_l);
                        unset($new_field[0]);
                        $listres[$lk_str]['newfield'] = array_values($new_field);
                    }

                }
            }
            $arr['list1'] = array_values($listres);
            $arr['listSettings']['havephone'] = 'yes';
            ConvertTojsonString(1,$arr,'success');
        }
        else {
            ConvertTojsonString(1,array('list1'=>[]),'success');
        }
    }
    //快速搜索用到的方法 1
    public function getSearchModules($filter = array()){
        global $adb;
        $sql = 'select distinct ld_field.tabid,name from ld_field inner join ld_tab on ld_tab.tabid=ld_field.tabid where ld_tab.tabid not in (16,29) and ld_tab.presence != 1 and 
            (ld_tab.name = "Attachment"  or isentitytype=1) and ld_field.presence in (0,2)  and ld_tab.name!=\'InventoryQuery\' order by ld_tab.tabsequence asc';
        $result = $adb->pquery($sql, array());
        $return_arr = [];
        while($module_result = $adb->fetch_array($result)){
            if(!empty($filter)){
                $modulename = $module_result['name'];
                if(is_array($filter) && !in_array($modulename, $filter)) {
                    continue;
                }
                if($modulename != 'Calendar'){
                    $return_arr[$modulename] = $modulename;
                }else{
                    $return_arr[$modulename] = 'Activity';
                }
            }
        }
        return $return_arr;
    }
    //获取快速搜索的所有模块
    public function unifiedSearchModules(){
        global $current_user, $adb;
        $quick_query_session = $_REQUEST['quick_query_session'];
        if($quick_query_session=='save'){
            //保存设置
            $search_onlyin = $_REQUEST['search_onlyin'];
            if(empty($search_onlyin)){
                $search_onlyin = "'Accounts','Contacts','ContactRecords','Calendar','DailyReport','WeekReport','MonthReport','SalesOrder'";
            }
            $sql='update ld_users set searchmodules=? where id=?';
            $adb->pquery($sql,array($search_onlyin,$current_user->id));
            $_REQUEST['diony']='yes';
            ConvertTojsonString(1,array(),'success');
        }else {
            $select_sql='select searchmodules from  ld_users where id=?';
            $select_res = $adb->pquery($select_sql,array($current_user->id));
            $selected_modules = $adb->query_result($select_res,0,'searchmodules');
            $selected_modules = explode(',',$selected_modules);
            if (empty($selected_modules) || !is_array($selected_modules)) {
                $selected_modules = array('Accounts', 'Contacts', 'ContactRecords', 'Calendar', 'DailyReport', 'WeekReport', 'MonthReport', 'SalesOrder');
            }
            $allowed_modules = array();
            $sql = 'select distinct ld_field.tabid,name from ld_field inner join ld_tab on ld_tab.tabid=ld_field.tabid 
INNER JOIN ld_entityname ON ld_entityname.`tabid` = ld_tab.`tabid`
where ld_tab.tabid not in (16,29) and ld_field.presence in (0,2) and ld_tab.presence in (0,2) order by ld_tab.tabsequence asc';
            $moduleres = $adb->query($sql);
            while ($modulerow = $adb->fetch_array($moduleres)) {
                if (is_admin($current_user) || isPermitted($modulerow['name'], 'DetailView') == 'yes') {
                    $modulename = $modulerow['name'];
                    $modulelabel = getTranstab($modulename);
                    if (empty($modulelabel)) {
                        continue;
                    }
                    $allowed_modules[$modulename] = array(
                        'label' => $modulelabel,
                        'modulename' => $modulename,
                        'selected' => (in_array($modulename, $selected_modules)) ? 'yes' : 'no'
                    );
                }
            }
            if (vtlib_isModuleActive('ReportLog')) {
                $allowed_modules['DailyReport'] = array(
                    'label' => getFixedLabel('DAILYREPORT'),
                    'modulename' => 'DailyReport',
                    'selected' => (in_array('DailyReport', $selected_modules))? 'yes' : 'no'
                );
                $allowed_modules['WeekReport'] = array('label' => getFixedLabel('WEEKREPORT'),
                    'modulename' => 'WeekReport',
                    'selected' => (in_array('WeekReport', $selected_modules))? 'yes' : 'no'
                );
                $allowed_modules['MonthReport'] = array('label' => getFixedLabel('MONTHREPORT'),
                    'modulename' => 'MonthReport',
                    'selected' => (in_array('MonthReport', $selected_modules))? 'yes' : 'no'
                );
            }
            ConvertTojsonString(1, array('list' => array_values($allowed_modules)), 'success');
        }
    }


    /*
     * editor:ljj
     * time:20231117
     * reason:XUQIU1002166
     * content:工作汇报模板定制增加“自动引用工作内容”（宋清华）
     * node:工作汇报PC和移动端 日志周计划月计划 获取“引用内容”
     * */
    public function getRelatedModuleField($reporttype){
        global $adb,$current_user;
        if ($reporttype == 'day' || $reporttype == 'ItemLogday'){
            $type=1;
        }else if ($reporttype == 'week' || $reporttype == 'ItemLogweek'){
            $type=2;
        }else if ($reporttype == 'month' || $reporttype == 'ItemLogmonth'){
            $type=3;
        }else{
            return false;
        }
        //获取后台设置-工作汇报模版ld_workreport_field 引用设置
        $sql='select id,name,label,relatedmodulefield,related_time,related_fieldid from ld_workreport_field where is_activate=0 and type =?';
        $result=$adb->pquery($sql,array($type));
        $num_row=$adb->num_rows($result);
        if ($num_row>0){
            for ($i=0;$i<$num_row;$i++){
                $name=$adb->query_result($result,$i,'name');
                if($name == 'saleskit_week' || $name == 'saleskit_day' || $name == 'saleskit_month' || $name == 'signaddress'){
                    continue;
                }
                $relatedmodulefield=$adb->query_result($result,$i,'relatedmodulefield');
                if ($relatedmodulefield == 'yes'){
                    $arr['name']=$name;
                    $arr['label']=$adb->query_result($result,$i,'label');
                    $arr['related_time']=$adb->query_result($result,$i,'related_time');
                    $arr['related_fieldid']=$adb->query_result($result,$i,'related_fieldid');
                    $relatedmodulefield_arr[]=$arr;
                }
            }
        }
//        dump($relatedmodulefield_arr);
//        $sql_arr=[];
        //根据后台模版的引用设置 获取数据
        foreach ($relatedmodulefield_arr as $key =>$arr){
            $related_fieldid=$arr['related_fieldid'];
            if (empty($related_fieldid)){
                continue;
            }
            //获取id对应name
            $fieldname_sql = " select name,label,type from ld_workreport_field where is_activate=0 and id in ($related_fieldid)";
            $fieldname_result = $adb->pquery($fieldname_sql,array());
            $fieldname_num_row = $adb->num_rows($fieldname_result);
            if ($fieldname_num_row>0){
                $type=$adb->query_result($fieldname_result,0,'type');
                $fieldname_arr=[];
                for($i=0;$i<$fieldname_num_row;$i++){
                    $fieldname_arr[]=$adb->query_result($fieldname_result,$i,'name');
                    $name_label_arr[$adb->query_result($fieldname_result,$i,'name')]=$adb->query_result($fieldname_result,$i,'label');
                }
            }
            if(empty($fieldname_arr)){
                continue;
            }
            //name即ld_workreport内字段名，获取内容
            $workreport_sql = "select sendlog_workdate,".implode(',',$fieldname_arr);
            $workreport_sql .= " from ld_workreport left join ld_workreportcf on ld_workreportcf.workreportid=ld_workreport.workreportid";
            $workreport_sql .= " where ld_workreport.type=$type and ld_workreport.smcreatorid = $current_user->id";
            $related_time=$arr['related_time'];
            //获取时间列表数组 时间是精确到秒的
            crm_load_class_file('ReportAnalysisUtils','modules/ReportAnalysis');
            $ReportAnalysisUtilsObj = new ReportAnalysisUtils();
            $time_arr=$ReportAnalysisUtilsObj->getComparatorValue();
            $relatedtimearr=array('yesterday','thisweek','thismonth','lastweek','lastmonth');
            if ($related_time == 'latest'){//最新一次
                $workreport_sql .= " order by ld_workreport.sendlog_workdate desc,ld_workreport.createdtime desc";
                $workreport_sql .= " limit 1";
            }elseif (in_array($related_time,$relatedtimearr)){
                if ($related_time == 'yesterday'){//昨天
                    $yesterday=date('Y-m-d',strtotime($time_arr['syesterday'][0]));//时间精确到天
                    $workreport_sql .= " and ld_workreport.sendlog_workdate = '".$yesterday."'";
                }else{//本周本月上周上月
                    $starttime=date('Y-m-d',strtotime($time_arr[$related_time][0]));//时间精确到天
                    $endtime=date('Y-m-d',strtotime($time_arr[$related_time][1]));//时间精确到天
                    $workreport_sql .= " and ld_workreport.sendlog_workdate >= '".$starttime."' and ld_workreport.sendlog_workdate <= '".$endtime."'";
                }
                $workreport_sql .= " order by ld_workreport.sendlog_workdate asc";
            }
//            $sql_arr[]=$workreport_sql;
            $workreport_result = $adb->pquery($workreport_sql,array());
            $workreport_num_row = $adb->num_rows($workreport_result);
            //组内容形式
            $content='';
            if ($workreport_num_row >0){
                for ($i=0;$i<$workreport_num_row;$i++){
                    foreach ($fieldname_arr as $key => $fieldname){
                        //decode_html 数据库值转义
                        $field_value=decode_html($adb->query_result($workreport_result,$i,$fieldname));
                        if (!empty($field_value)){
                            // ljj 20231211 BUG0077054 kfbcrm-工作汇报-自动引用工作内容 上一天的日志是表情，带出后显示html代码
                            //获取表情和对应链接的数组
                            $this->getemojicookie();
                            //将键和值互换位置
                            $cookie_link=array_flip($this->cookie_link);
                            //strtr,数组的键是替换的字符串，值是替换的内容 html_entity_decode转义
                            $field_value= html_entity_decode(strtr($field_value,$cookie_link), ENT_QUOTES);
                            $content .= $field_value."<br>";
                        }
                    }
                }
            }
            $related_content[]=array('name'=>$arr['name'],'content'=>$content);
        }
//        dump($sql_arr);

        return $related_content;
    }
    public function getPreviousReport($workreportid)
    {

        global $adb, $PlatformMC;
        $jsonArray = array();
        $entity_type = 'workreport';
        $workfldarr = $this->getWorkCfFieldInfo($entity_type);
        $workfldsql = '';
        if (!empty($workfldarr)) {
            $workfldkeyarr = array_keys($workfldarr);
            $workfldsql = ',ld_workreportcf.' . join(',ld_workreportcf.', $workfldkeyarr);
        }
        //读取文本字段内容
        $sql = "select entitytype,type,createdtime,startdate,
        worksummary,workplan,workexperience,workplan_tuesday,workplan_wednesday,workplan_thursday,workplan_friday,
        sendlog_workdate,saleskit_day,saleskit_month,saleskit_week,saleskit_showtype,saleskit_listinfo,
        approved,smcreatorid,ccuser,reuser" . $workfldsql . "
        from ld_workreport LEFT JOIN ld_workreportcf 
            on ld_workreportcf.workreportid = ld_workreport.workreportid where ld_workreport.workreportid = ?";
        $result = $adb->pquery($sql, array($workreportid));
        $i = 0;
        $entitytype = $adb->query_result($result, $i, 'entitytype');
        $type = $adb->query_result($result, $i, 'type');
        $startdate = $adb->query_result($result, $i, 'startdate');
        $worksummary = $this->getemojitext(html_entity_decode($adb->query_result($result, $i, 'worksummary')));
        if (is_null($worksummary)) {
            $worksummary = '';
        }
        $sendlog_workdate = $adb->query_result($result, $i, 'sendlog_workdate');
        $saleskit_day = $this->getemojitext(html_entity_decode($adb->query_result($result, $i, 'saleskit_day')));
        if (is_null($saleskit_day)) {
            $saleskit_day = '';
        }
        $saleskit_month = $this->getemojitext(html_entity_decode($adb->query_result($result, $i, 'saleskit_month')));
        if (is_null($saleskit_month)) {
            $saleskit_month = '';
        }
        $saleskit_week = $this->getemojitext(html_entity_decode($adb->query_result($result, $i, 'saleskit_week')));
        if (is_null($saleskit_week)) {
            $saleskit_week = '';
        }
        $workplan = $this->getemojitext(html_entity_decode($adb->query_result($result, $i, 'workplan')));
        if (is_null($workplan)) {
            $workplan = '';
        }
        $workexperience = $this->getemojitext(html_entity_decode($adb->query_result($result, $i, 'workexperience')));
        if (is_null($workexperience)) {
            $workexperience = '';
        }
        $workplan_tuesday = $this->getemojitext(html_entity_decode($adb->query_result($result, $i, 'workplan_tuesday')));
        if (is_null($workplan_tuesday)) {
            $workplan_tuesday = '';
        }
        $workplan_wednesday = $this->getemojitext(html_entity_decode($adb->query_result($result, $i, 'workplan_wednesday')));
        if (is_null($workplan_wednesday)) {
            $workplan_wednesday = '';
        }
        $workplan_thursday = $this->getemojitext(html_entity_decode($adb->query_result($result, $i, 'workplan_thursday')));
        if (is_null($workplan_thursday)) {
            $workplan_thursday = '';
        }
        $workplan_friday = $this->getemojitext(html_entity_decode($adb->query_result($result, $i, 'workplan_friday')));
        if (is_null($workplan_friday)) {
            $workplan_friday = '';
        }
        $approved = $adb->query_result($result, $i, 'approved');
        $saleskit_showtype = $adb->query_result($result, $i, 'saleskit_showtype');
        $saleskit_listinfo = $adb->query_result($result, $i, 'saleskit_listinfo');
        $saleskit_listinfo = html_entity_decode($saleskit_listinfo);
        $tmp_saleskit_listinfo = ldcrm_json_decode($saleskit_listinfo);
        if ($saleskit_showtype == 'html'){//获取最新的label
            $moduleRecordLabel_arr = $this->getSalesKitListInfoLabel($tmp_saleskit_listinfo);
            foreach ($tmp_saleskit_listinfo as $tmp_index => &$listinfo){
                foreach ($listinfo['list'] as $tmp_key => &$list){
                    foreach ($list['href'] as $tmp_i => &$hrefinfo){
                        $module = $hrefinfo['module'];
                        $record = $hrefinfo['record'];
                        if(isset($moduleRecordLabel_arr[$module]) && isset($moduleRecordLabel_arr[$module][$record])){
                            $hrefinfo['label'] = $moduleRecordLabel_arr[$module][$record];
                        }
                    }
                }
            }
            $saleskit_listinfo = $tmp_saleskit_listinfo;
        }

        //读取关联客户、联系人、产品
        $sql = "select 'Accounts'  as relatedtab ,ld_account.accountname as name ,ld_workreportrelatedto.Relatedto
					from ld_workreportrelatedto 
					LEFT JOIN ld_account on ld_account.accountid=ld_workreportrelatedto.Relatedto
					  where workreportid=? and ld_account.deleted=0
					UNION 
					select 'Contacts'  as relatedtab ,ld_contactdetails.lastname as name ,ld_workreportrelatedto.Relatedto
					from ld_workreportrelatedto 
					LEFT JOIN ld_contactdetails on ld_contactdetails.contactid=ld_workreportrelatedto.Relatedto
					  where workreportid=? and ld_contactdetails.deleted=0
                    UNION 
					select 'Products'  as relatedtab ,ld_products.productname as name ,ld_workreportrelatedto.Relatedto
					from ld_workreportrelatedto 
					LEFT JOIN ld_products on ld_products.productid=ld_workreportrelatedto.Relatedto
					  where workreportid=? and ld_products.deleted=0";
        $resultrelated = $adb->pquery($sql, array($workreportid, $workreportid, $workreportid));
        $relatedModules = array();
        for ($tmp_related = 0; $tmp_related < $adb->num_rows($resultrelated); $tmp_related++) {
            $relatedtab = $adb->query_result($resultrelated, $tmp_related, 'relatedtab');
            $relatedto = $adb->query_result($resultrelated, $tmp_related, 'relatedto');
            $name = $adb->query_result($resultrelated, $tmp_related, 'name');
            if ($PlatformMC['type'] == 'weixin') {
                if (isPermitted($relatedtab) == 'yes' && vtlib_isModuleActive($relatedtab)) {
                    $relatedModules[$relatedtab][] = array('curid' => $relatedto, 'name' => $name);
                }
            } else {
                $relatedModules[$relatedtab][] = array('curid' => $relatedto, 'name' => $name);
            }
        }

        //读取附件
        $workachment = $this->getWorkAchmentInfo($workreportid);
        //读取点评人和任务执行人
        $sqlReader="select ld_workreport2user.userid,
						ld_users.last_name
						from ld_workreport2user 
						left join ld_users on ld_workreport2user.userid = ld_users.id
						where ld_workreport2user.workreportid = ? and ld_workreport2user.user_type = ? ";
        switch($entitytype)
        {
            case 'workreport': //日志
                $user_type = 5;//点评人
                break;
            case 'cocmd': //任务
                $user_type = 6;//执行人
                break;
        }
        if($entitytype != 'weibo'){
            $sqlReaderResult=$adb->pquery($sqlReader,array($workreportid,$user_type));
            $reader=$adb->query_result($sqlReaderResult,0,'userid');
            $readername=$adb->query_result($sqlReaderResult,0,'last_name');
        }else {
            $reader = '';
            $readername = '';
        }
        //读取抄送人
        $sqlReaderResult=$adb->pquery($sqlReader,array($workreportid,1));
        $ccuser = array();
        $ccusername = array();
        for($i= 0;$i<$adb->num_rows($sqlReaderResult,0,'userid');$i++){
            $ccuser[]=$adb->query_result($sqlReaderResult,$i,'userid');
            $ccusername[] = $adb->query_result($sqlReaderResult,$i,'last_name');
        }
        $entity = array(
            'curid' => $workreportid, 'entitytype' => $entitytype, 'workreporttype' => $type, 'startdate'=> $startdate,'sendlog_workdate'=>$sendlog_workdate,
            'worksummary' => $worksummary, 'workplan' => $workplan, 'workexperience' => $workexperience, 'workplan_tuesday' => $workplan_tuesday, 'workplan_wednesday' => $workplan_wednesday, 'workplan_thursday' => $workplan_thursday, 'workplan_friday' => $workplan_friday,
            'approved' => $approved,'workachment' => $workachment, 'saleskit_day'=>$saleskit_day,'saleskit_week'=>$saleskit_week,'saleskit_month'=>$saleskit_month,'saleskit_showtype'=>$saleskit_showtype,'saleskit_listinfo'=>$saleskit_listinfo,
            'Accounts' => $relatedModules['Accounts'], 'Contacts' => $relatedModules['Contacts'],'Products' => $relatedModules['Products'],
            'reader' => $reader, 'readername'=> $readername,'ccuser' => $ccuser, 'ccusername'=> $ccusername );
        if(!empty($workfldkeyarr)&&$entitytype=='workreport'){
            foreach($workfldkeyarr as $workfld){
                $value = $adb->query_result($result,0,$workfld);
                if(!empty($value)){
                    $value = $this->getemojitext(html_entity_decode($value));
                }else{
                    $value = '';
                }
                $entity[$workfld] = $value;
            }
        }
        $entityContents[] = $entity;
        $jsonArray['report'] = $entityContents;
        return $jsonArray;
    }
    public function getAchmentInfoByID($idarr) {
        global $adb;
        $workachmentquery = 'SELECT achmentid,name,type,path,size,newfile_name,storage_location,cloud_path FROM ld_workachments WHERE achmentid in ('.implode(',',$idarr).')';
        $workachmentresult = $adb->pquery($workachmentquery, array());
        $workachmentnum = $adb->num_rows($workachmentresult);
        $workachmentarr = array();
        if ($workachmentnum > 0) {
            for ($i = 0; $i < $workachmentnum; $i++) {
                $workachment = array();
                $achmentname = $adb->query_result($workachmentresult, $i, 'name');
                $newfile_name = $adb->query_result($workachmentresult, $i, 'newfile_name');
                if ($newfile_name == '') {
                    $newfile_name = $achmentname;
                }
                $imgtype = $adb->query_result($workachmentresult, $i, 'type');
                $achmentid = $adb->query_result($workachmentresult, $i, 'achmentid');
                $achmentpath = trim($adb->query_result($workachmentresult, $i, 'path'));
                $achmentsize = trim($adb->query_result($workachmentresult, $i, 'size'));
                if (strrchr($achmentpath, '/') != '/') {
                    $achmentpath .= '/';
                }
                if ($achmentsize < 1024)
                    $showsize = $achmentsize . ' B';
                else if ($achmentsize > 1024 && $achmentsize < 1048576)
                    $showsize = round($achmentsize / 1024, 2) . ' KB';
                else if ($achmentsize > 1048576)
                    $showsize = round($achmentsize / (1024 * 1024), 2) . ' MB';

                $workachment['name'] = $achmentname;
                $workachment['path'] = $achmentpath . urlencode($newfile_name);
                $workachment['real_path'] = $achmentpath;
                $workachment['urlencode_path'] = urlencode($achmentpath . $newfile_name);//editor:gyq date:20170330 reasn:附件预览传递文件路径
                $workachment['size'] = $showsize;
                $workachment['sizeraw'] = $achmentsize;
                $workachment['achmentid'] = $achmentid;
                $workachment['newfile_name'] = $newfile_name;
                $workachment['storage_location'] = trim($adb->query_result($workachmentresult, $i, 'storage_location'));
                $workachment['cloud_path'] = trim($adb->query_result($workachmentresult, $i, 'cloud_path'));
                $workachmentarr[$achmentid]= $workachment;
            }
        }
        return $workachmentarr;
    }
    public function getChangeLog($workreportid)
    {
        global $adb,$weixin_user;
        $jsonArray = array();
        $sql = 'select * from ld_workreport_modtracker where workreportid = ? order by changedon desc';
        $result = $adb->pquery($sql, array($workreportid));
        $rows = $adb->num_rows($result);
        $loglist = array();

        if ($rows > 0) {
            if($weixin_user->environment_weixin){
                $fieldnamename = getFixedLabel('LBL_Field');
                $prevaluename = getFixedLabel('LBL_Earlier');
                $postvaluename = getFixedLabel('LBL_Present');
                $changedonname = getFixedLabel('OPERATTIME');
            }

            //先初始化所有字段名称的转化$fldnameTransfer

            //文字字段名称转化$workfldname
            $workfldname = array();
            $entitysql = 'select entitytype, type from ld_workreport where workreportid = ?';
            $entityresult = $adb->pquery($entitysql,array($workreportid));
            $entitytype = $adb->query_result($entityresult,0,'entitytype');
            $type = $adb->query_result($entityresult,0,'type');
            if($entitytype == 'weibo'){
                $workfldname = array('workexperience'=>getFixedLabel('BLOG').getFixedLabel('Content'));
            }else if($entitytype == 'cocmd'){
                $workfldname = array('workexperience'=>getFixedLabel('TASK').getFixedLabel('Content'));
            }else{
                $workfldarr = $this->getWorkFieldEntity($entitytype)[$type];
                foreach($workfldarr as $workfld){
                    $workfldname[$workfld['name']]=$workfld['label'];
                }
            }
            //和其他字段名称转化进行合并
            if(empty($this->fldnamearr)){
                $this->fldnamearr = array('image'=>getFixedLabel('Image'),
                    'att'=>getFixedLabel('Attachment'),
                    'startdate'=> getFixedLabel('COMPLETIONTIMEAPP'),
                    'sendlog_workdate'=>getFixedLabel('DATE'),
                    'Accounts'=>getTransTab('Accounts'),
                    'Contacts'=>getTransTab('Contacts'),
                    'Products'=>getTransTab('Products')
                );
            }
            $fldnameTransfer = array_merge($workfldname,$this->fldnamearr);


            //缓存用于保存当前已查询的内容
            $fldvalueCache = array('image'=>array(),'att'=>array(),'Accounts'=>array(),'Contacts'=>array(),'Products'=>array());

            for ($i = 0; $i < $rows; $i++) {
                $fieldname = $adb->query_result($result, $i, 'fieldname');
                $prevalue = $adb->query_result($result, $i, 'prevalue');
                $postvalue = $adb->query_result($result, $i, 'postvalue');
                $changedon = $adb->query_result($result, $i, 'changedon');
                if ($fieldname == 'image' || $fieldname == 'att' ) {
                    $prevatt = $prevalue==''?array():explode(',', $prevalue);
                    $postatt = $postvalue==''?array():explode(',', $postvalue);
                    $newatt = array();
                    foreach($prevatt as $attid){
                        if(!array_key_exists($attid,$fldvalueCache[$fieldname])){
                            $newatt[] = $attid;
                        }
                    }
                    foreach($postatt as $attid){
                        if(in_array($attid,$newatt)== false && !array_key_exists($attid,$fldvalueCache[$fieldname])){
                            $newatt[] = $attid;
                        }
                    }
                    if(!empty($newatt)){
                        $attinfo = $this->getAchmentInfoByID($newatt);
                        foreach($attinfo as $id=>$info){
                            $fldvalueCache[$fieldname][$id] = $info;
                        }
                    }
                    $prevalue = array();
                    foreach($prevatt as $attid){
                        $prevalue[] = $fieldname == 'image'?$fldvalueCache[$fieldname][$attid]:$fldvalueCache[$fieldname][$attid]['name'];
                    }
                    $postvalue = array();
                    foreach($postatt as $attid){
                        $postvalue[] = $fieldname == 'image'?$fldvalueCache[$fieldname][$attid]:$fldvalueCache[$fieldname][$attid]['name'];
                    }

                } else if(in_array($fieldname,array('Accounts','Contacts','Products'))){
                    $focus = CRMEntity::getInstance($fieldname);
                    $previd = $prevalue==''?array():explode(',', $prevalue);
                    $postid = $postvalue==''?array():explode(',', $postvalue);
                    $newid = array();
                    foreach($previd as $id){
                        if(!array_key_exists($id,$fldvalueCache[$fieldname])){
                            $newid[] = $id;
                        }
                    }
                    foreach($postid as $id){
                        if(in_array($id,$newid)== false && !array_key_exists($id,$fldvalueCache[$fieldname])){
                            $newid[] = $id;
                        }
                    }
                    if(!empty($newid)){
                        $relatedsql = 'select ' . $focus->table_index.','.$focus->list_link_field . ' from ' . $focus->table_name . ' where deleted=0 and ' .$focus->table_index . ' in ('.implode(',',$newid).')';
                        $relatedresult = $adb->pquery($relatedsql, array());
                        $relatednum = $adb->num_rows($relatedresult);
                        if ($relatednum != 0) {
                            for($tmpi=0;$tmpi<$relatednum;$tmpi++){
                                $relatedname = $adb->query_result($relatedresult, $tmpi, $focus->list_link_field );
                                $relatedid = $adb->query_result($relatedresult, $tmpi,$focus->table_index);
                                $fldvalueCache[$fieldname][$relatedid] = $relatedname;
                            }
                        }
                    }
                    $prevalue = array();
                    foreach($previd as $id){
                        $prevalue[] = $fldvalueCache[$fieldname][$id];
                    }
                    $prevalue = implode(',', $prevalue);
                    $postvalue = array();
                    foreach($postid as $id){
                        $postvalue[] = $fldvalueCache[$fieldname][$id];
                    }
                    $postvalue = implode(',', $postvalue);
                }else{
                    $prevalue = html_entity_decode($prevalue);
                    $postvalue = html_entity_decode($postvalue);
                }

                if($weixin_user->environment_weixin) {
                    $loglist[] = array('fieldname' => array('k' => $fieldnamename, 'v' =>  $fldnameTransfer[$fieldname]), 'prevalue' => array('k' => $prevaluename, 'v' => $prevalue), 'postvalue' => array('k' => $postvaluename, 'v' => $postvalue), 'changedon' => array('k' => $changedonname, 'v' => $changedon));
                }else{
                    $loglist[] = array('fieldname' =>  $fldnameTransfer[$fieldname], 'prevalue' => $prevalue, 'postvalue' => $postvalue, 'changedon' => $changedon);
                }
            }
        }
        $jsonArray['loglist'] = $loglist;
        if($weixin_user->environment_weixin) {
            ConvertTojsonString(1, $jsonArray, 'success');
        }else {
            return ($jsonArray);
        }
    }
    public function getApproveStatus($workreportid,$prevapproved){
        global $adb;
        $sql = 'select entitytype,type,approved from ld_workreport where workreportid = ?';
        $result = $adb->pquery($sql,array($workreportid));
        $approved = $adb->query_result($result,0,'approved');
        $entitytype = $adb->query_result($result,0,'entitytype');
        $type = $adb->query_result($result,0,'type');
        if($prevapproved == 1 && $entitytype != 'cocmd'){
            return "";
        }
        if($entitytype=='weibo' || $approved ==0){
            return "";
        }
        if($entitytype == 'cocmd'){
            if($approved == 1){
                $remindstr = getFixedLabel('Executed');
            }
            else if($approved == 2){
                $remindstr = getFixedLabel('CANCELED');
            }
            $entitytypename = getFixedLabel('TASK');
        }
        else if($entitytype == 'workreport'){
            $remindstr = getFixedLabel('HAVEREVIEWED');
            if($type ==1){
                $entitytypename = getFixedLabel('JOURNAL');
            }
            else if($type ==2){
                $entitytypename = getFixedLabel('WEEKPLAN');
            }
            else if($type ==3){
                $entitytypename = getFixedLabel('MONTHPLAN');
            }
        }
        return $entitytypename.$remindstr.', '.getFixedLabel('PUBLISHFAILED').'!';
    }
    public function saveFileFromWeiXinApi($id, $module, $imageArr){
        if(!empty($imageArr)){
            $saveObj = cls_Instance::get_moduleAction_Instance('Home','Save');
            $saveObj->saveFileFromWeiXinApi($id, $module, $imageArr);
        }
    }
    public function editReport($editreportinfo){
        global $adb,$weixin_user;
        $prevapproved = $editreportinfo['approved'];
        $workreportid = $editreportinfo['reportid'];
        $approvedmsg = $this->getApproveStatus($workreportid,$prevapproved);
        if($approvedmsg != ''){
            ConvertTojsonString(-1,array(),$approvedmsg);
        }
        $entitytype=$editreportinfo['entitytype'];//日志、微博、任务
        $changedon = date('Y-m-d H:i:s');
        $changelog = array();

        if($prevapproved== 0){
            $prevsql = 'select * from ld_workreport where workreportid = ?';
            $prevresult = $adb->pquery($prevsql, array($workreportid));
            $prevsqlcf = 'select * from ld_workreportcf where workreportid = ?';
            $prevresultcf = $adb->pquery($prevsqlcf, array($workreportid));

            $workdate_changestatus = 'yes';
            if ($entitytype == 'workreport' ){
                $saleskit_date = $editreportinfo['saleskit_date'];
                $savetype = $adb->query_result($prevresult,0,'type');
                $reporttype_arr = array('1'=>'day','2'=>'week','3'=>'month');
                $reporttype = $reporttype_arr[$savetype];
                if ($adb->num_rows($prevresult) > 0){
                    $workdate = $adb->query_result($prevresult,0,'sendlog_workdate');
                    if ($workdate == $saleskit_date){//汇报日期未变动
                        $workdate_changestatus = 'no';
                    }else{
                        crm_load_class_file('WorkTemplateRule','modules/Settings');
                        $workTemplateRuleobj = new WorkTemplateRule();
                        $workTemplateRuleobj->setWorkReportType($reporttype);
                        $reportDate = $workTemplateRuleobj->getReportDateData();
                        $editDate = $reportDate['editDate'];
                        if($editDate == 'no'){//不允许修改 或仅当天
                            crm_load_class_file("CommonView","modules/CustomView");
                            $datetimestr=CommonView::stdFilterDateTimeStr();//获取日期，时间本年，明年等下拉框字符串
                            if ($savetype == 1){
                                $tmp_saleskit_date = $datetimestr['today'][0];
                            }elseif ($savetype == 2){
                                $tmp_saleskit_date = $datetimestr['thisweek'][0].' ~ '.$datetimestr['thisweek'][1];
                            }elseif ($savetype == 3){
                                $tmp_saleskit_date = $datetimestr['thismonth'][0].' ~ '.$datetimestr['thismonth'][1];
                            }
                            if ($saleskit_date == $tmp_saleskit_date){

                            }else{
                                if ($savetype != 1){
                                    $label = getFixedLabel('NoModificationsAllowed');
                                }else{
                                    $label = $reportDate['label'];
                                }
                                ConvertTojsonString(-1,'',getVarFixedLabel('ReportDateSubmitTip',$label));
                            }
                        }else{
                            if ($savetype == 1){
                                $minDate = $reportDate['minDate'];
                                $maxDate = $reportDate['maxDate'];
                                $label = $reportDate['label'];
                                if ( ($minDate == '' && $maxDate == '')  || strtotime($saleskit_date) >= strtotime($minDate) && strtotime($maxDate) >= strtotime($saleskit_date)){

                                }else{
                                    ConvertTojsonString(-1,'',getVarFixedLabel('ReportDateSubmitTip',$label));
                                }
                            }
                        }
                    }
                }
                //更新汇报日期
                if( $workdate_changestatus == 'yes'){
                    $update = 'update ld_workreport set sendlog_workdate = ? where workreportid = ? ';
                    $adb->pquery($update, array($saleskit_date , $workreportid));
                    $changelog[]=array('fieldname'=>'sendlog_workdate','prevalue'=>  $workdate,'postvalue'=>$saleskit_date);
                }



            }
            //编辑文本字段
            if(isset($editreportinfo['workfld'])){//文本域textarea的name值
                $workfld = trim($editreportinfo['workfld'],',');
                $workfldarr = explode(',',$workfld);
                $entity_type = 'workreport';
                $workfieldarray = $this->getWorkCfFieldInfo($entity_type);
                foreach($workfldarr as $fld) {
                    $fldcontent =$this->changeemojicookie(Input($fld));
                    if (!empty($workfieldarray) && 'ld_workreportcf' == $workfieldarray[$fld]) {//自定义字段
                        $prevalue = $adb->query_result($prevresultcf, 0, $fld);
                        $fldtable = 'ld_workreportcf';
                    } else {
                        $prevalue = $adb->query_result($prevresult, 0, $fld);
                        $fldtable = 'ld_workreport';
                    }
                    if ( html_entity_decode($prevalue)!= $fldcontent) {
                        $update = 'update '.$fldtable.' set ' . $fld . '=? where workreportid = ?';
                        $adb->pquery($update, array($fldcontent, $workreportid));
                        $changelog[]=array('fieldname'=>$fld,'prevalue'=> $prevalue,'postvalue'=>$fldcontent);
                    }
                }
            }
            if ($entitytype == 'workreport' && isset($editreportinfo['saleskit_showtype'])){
                $showtype = $editreportinfo['saleskit_showtype'];
                if ($showtype == 'html'){
                    $saleskit_listinfo = $editreportinfo['saleskit_listinfo'];
                    $tmp_saleskit_listinfo = ldcrm_json_decode($saleskit_listinfo);
                    $saleskit_arr = $this->getSalesKitByListinfo($tmp_saleskit_listinfo);
                    $saleskit_listinfo = $saleskit_arr['listinfo'];
                    $saleskit = $saleskit_arr['saleskit'];
                    $saleskit_updatesql = 'update ld_workreport set saleskit_'.$reporttype.'=? ,saleskit_listinfo=?,saleskit_showtype=? where workreportid =? ';
                    $adb->pquery($saleskit_updatesql, array($saleskit,$saleskit_listinfo,$showtype,$workreportid));
                    unset($saleskit_listinfo,$saleskit);
                }else{
                    $saleskit_updatesql = 'update ld_workreport set saleskit_showtype=?,saleskit_listinfo=? where workreportid =? ';
                    $adb->pquery($saleskit_updatesql, array($showtype,'',$workreportid));
                }
                unset($showtype,$saleskit_updatesql);
            }

            //编辑任务完成时间
            if($entitytype == 'cocmd'){
                $startdate=$editreportinfo['startdate'];
                $prevdate = $adb->query_result($prevresult,0,'startdate');
                if($startdate !=$prevdate){
                    $update = 'update ld_workreport set startdate = ?,enddate = ? where workreportid = ? ';
                    $adb->pquery($update, array($startdate ,$startdate, $workreportid));
                    $changelog[]=array('fieldname'=>'startdate','prevalue'=>   $prevdate,'postvalue'=> $startdate.':00');
                }
            }

            $relatedTypes = $weixin_user->environment_weixin?array('Accounts','Contacts'):array('Accounts','Contacts','Products');
            $RequestTransfer = array('Accounts'=>'accountlist','Contacts'=>'contactlist','Products'=>'productslist');
            $RelatedTransfer = array('Accounts'=>'relatedto_account','Contacts'=>'relatedto_contact','Products'=>'relatedto_product');
            foreach($relatedTypes as $relatedType){
                if(isset($editreportinfo[$RequestTransfer[$relatedType]])){
                    $relatedlist = trim($editreportinfo[$RequestTransfer[$relatedType]],",");
                    $relatedarr = explode(",",$relatedlist);
                    $prevrelated = $adb->query_result($prevresult,0,$RelatedTransfer[$relatedType]);
                    $prevrelatedarr = explode(",",trim($prevrelated,","));
                    if(array_diff($relatedarr,$prevrelatedarr)!=array_diff($prevrelatedarr,$relatedarr)){
                        $update = 'update ld_workreport set '.$RelatedTransfer[$relatedType].' = ? where workreportid = ? ';
                        $adb->pquery($update, array($relatedlist , $workreportid));
                        $changelog[]=array('fieldname'=> $relatedType,'prevalue'=> $prevrelated,'postvalue'=>$relatedlist );
                        $delete = 'delete from ld_workreportrelatedto where workreportid = ? and relatedtab = ?';
                        $adb->pquery($delete, array($workreportid,$relatedType));
                        foreach($relatedarr as $related){
                            $insert = 'insert into ld_workreportrelatedto(Relatedto,relatedtab,workreportid) value(?,?,?)';
                            $adb->pquery($insert, array($related,$relatedType,$workreportid));
                        }
                    }
                }
            }

        }

        //保存附件
        $attTransfer = array('att'=>'uploadattList','image'=>'uploadimgList');
        $attTypes = $weixin_user->environment_weixin?array('image'):array('image','att');
        foreach($attTypes as $attType){
            $prevattarr = array();
            $postattarr = array();
            $oldattarr = array();
            $newattarr = array();
            $deleteattarr = array();
            //获取修改前的附件
            $prevsql = "select achmentid from ld_workachments where workreportid = ? and type = ?";
            $prevresult = $adb->pquery($prevsql,array($workreportid,$attType));
            $prevnum = $adb->num_rows($prevresult);
            if($prevnum > 0){
                for($i=0;$i<$prevnum;$i++){
                    $prevattarr[]=$adb->query_result($prevresult,$i,'achmentid');
                }
            }
            //获取当前上传的附件中的旧附件
            if(isset($editreportinfo[$attTransfer[$attType]]) && !empty($editreportinfo[$attTransfer[$attType]])) {
                if($weixin_user->environment_weixin){
                    foreach ($editreportinfo[$attTransfer[$attType]] as &$att) {
                        if (!array_key_exists('achmentid', $att)) {
                            $newattarr[] = $att;
                        }else{
                            $oldattarr[] = $att['achmentid'];
                        }
                    }
                    //有新图片则保存
                    if(!empty($newattarr)) {
                        $this->saveFileFromWeiXinApi($workreportid, 'Home', $newattarr);
                    }
                }else{
                    $uploadattlist= trim($editreportinfo[$attTransfer[$attType]],",");
                    $uploadattarr = explode(",",$uploadattlist);
                    foreach ($uploadattarr as &$att) {
                        if (in_array($att,$prevattarr)) {
                            $oldattarr[] = $att;
                        }else{
                            $newattarr[]=$att;
                        }
                        if(!empty($newattarr)){
                            $update = 'update ld_workachments set workreportid=? where achmentid in ('.implode(',',$newattarr).')';
                            $adb->pquery($update,array($workreportid));
                        }
                    }

                }
            }

            if($prevapproved==0) {//未点评时需要考慮刪除旧附件
                if (!empty($prevattarr)) {
                    //寻找需要删除的旧附件
                    $deleteattarr = array_diff($prevattarr, $oldattarr);
                    if (!empty($deleteattarr)) {
                        $update = 'update ld_workachments set workreportid=0 where achmentid in ('.implode(',',$deleteattarr).')';
                        $adb->pquery($update,array());
                    }
                }
            }
            if (!empty($deleteattarr) || !empty($newattarr)) {
                if($weixin_user->environment_weixin){
                    //重新获取上传的附件id
                    $postsql = "select achmentid from ld_workachments where workreportid = ? and type = ?";
                    $postresult = $adb->pquery($postsql, array($workreportid, $attType));
                    $postnum = $adb->num_rows($postresult);
                    $postattarr = array();
                    for ($i = 0; $i < $postnum; $i++) {
                        $postattarr[] = $adb->query_result($postresult, $i, 'achmentid');
                    }
                }else{
                    $postattarr = $uploadattarr;
                }
                $changelog[]=array('fieldname'=>$attType,'prevalue'=>implode(",", $prevattarr),'postvalue'=>implode(',', $postattarr));
            }
        }


        $editcount = 0;
        foreach($changelog as $log){
            $insert = 'insert into ld_workreport_modtracker (workreportid,fieldname,prevalue,postvalue,changedon) value(?,?,?,?,?)';
            $adb->pquery($insert, array($workreportid, $log['fieldname'], $log['prevalue'], $log['postvalue'] , $changedon));
            $editcount+=1;
        }
        $update = 'update ld_workreport set editcount=editcount+? where workreportid = ?';
        $adb->pquery($update,array($editcount,$workreportid));
        ConvertTojsonString(1,$editcount,'success');
    }

    public function getWorktype()
    {
        return $this->worktype;
    }
    public function setWorktype($worktype)
    {
        $this->worktype = $worktype;
    }

    public function getSalesKitByListinfo($listinfo){
        $saleskit = '';
        if (!is_array($listinfo)){
            $listinfo = ldcrm_json_decode($listinfo);
        }
        foreach($listinfo as $tmp_index => &$tmp_info){
            $saleskit .= $tmp_info['label'].': ';
            foreach ($tmp_info['list'] as $index => &$list){
                $text = $list['text'];
                foreach ($list['href'] as $tmp_key => &$hrefinfo){
                    $replace = $hrefinfo['replace'];
                    $label = $hrefinfo['label'];
                    $text = str_replace($replace,$label,$text);
                    unset($hrefinfo['label']);
                }
                $saleskit .= $text;
            }
        }
        $saleskit = str_replace('\n','',$saleskit);
        $saleskit = str_replace('\\n','',$saleskit);
        $listinfo = ldcrm_json_encode($listinfo);
        return array('saleskit'=>$saleskit,'listinfo'=>$listinfo);
    }

}
?>