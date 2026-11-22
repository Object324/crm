<?php




require_once(globalStatic::$root_directory.'modules/Calendar/CalendarCommon.php');
crm_load_class_file("DateTimeField",'include/fields');

// Task is used to store customer information.
class Activity extends CRMEntity {
    
   public $loop_setting_arr;
    
    static  function require_file($requiremodules='')
    {
            globalStatic::$arr_module_require['Activity']='Activity';
            
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
	var $log;
	var $db;
	var $table_name = "ld_activity";
	var $table_index= 'activityid';
	var $reminder_table = 'ld_activity_reminder';
	var $tab_name = Array('ld_crmentity','ld_activity','ld_activitycf');


  //管理模块
    var $relatedtab=array('accounts'=>'','users'=>'','company'=>'','events'=>'','calendar'=>'');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_activity'=>'activityid','ld_seactivityrel'=>'activityid','ld_salesmanactivityrel'=>'activityid','ld_activity_reminder'=>'activity_id','ld_recurringevents'=>'activityid','ld_activitycf'=>'activityid','ld_reminds'=>'related_to','ld_loopcalendar_reminds'=>'activityid');


	var $column_fields = Array();
	var $sortby_fields = Array('subject','due_date','date_start','smownerid','activitytype','lastname');	//Sorting is added for due date and start date	

	// This is used to retrieve related lingdang_fields from form posts.
	var $additional_column_fields = Array('assigned_user_name', 'assigned_user_id', 'contactname', 'contact_phone', 'contact_email', 'parent_name');
	
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_activitycf', 'activityid');
    var $module_name="Calendar";
	// This is the list of lingdang_fields that are in the lists.
	var $list_fields = Array(
       
       );

       var $range_fields = Array(
		'name',
		'date_modified',
		'start_date',
		'id',
		'status',
		'date_due',
		'time_start',
		'description',
		'contact_name',
		'priority',
		'duehours',
		'dueminutes',
		'location'
	   );
       

       var $list_fields_name = Array(
     
       );

       var $list_link_field= 'subject';
	
	//Added these variables which are used as default order by and sortorder in ListView
	///var $default_order_by = 'due_date';
    /*
    edit by LD can
    date:20130226
    reason:更多信息日程管理排序
    */
var $default_order_by = 'ld_activity.activityid';
	var $default_sort_order = 'ASC';

	//var $groupTable = Array('lingdang_activitygrouprelation','activityid');

	function __construct() {
		//$this->log = LoggerManager::getLogger('Calendar');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=new Field('Calendar',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);

        $loop_dayvalue_month_options = [];
        for($i = 1; $i <= 31; $i++){
            //$loop_dayvalue_month_options = array_merge($loop_dayvalue_month_options,array($i=>$i.'号'));
            $loop_dayvalue_month_options = $loop_dayvalue_month_options + array($i=>$i."号");
        }
        $loop_dayvalue_month_options = $loop_dayvalue_month_options + array('lastday'=>"最后一天");

        $this->loop_setting_arr = array(
            "loop_type_options" => array("norepeat"=>"不重复", "daily"=>"每天", "weekly"=>"每周"/*, "biweekly"=>"每两周"*/, "monthly"=>"每月",),
            "loop_month_options" =>array("1"=>"一月", "2"=>"二月", "3"=>"三月", "4"=>"四月", "5"=>"五月", "6"=>"六月",
                "7"=>"七月", "8"=>"八月", "9"=>"九月", "10"=>"十月", "11"=>"十一月", "12"=>"十二月",),
            "loop_dayvalue_options" =>array("1"=>'周一', "2"=>'周二', "3"=>'周三', "4"=>'周四', "5"=>'周五', "6"=>'周六', "7"=>'周日',),
            "loop_dayvalue_month_options" =>$loop_dayvalue_month_options,
            "reminder_setting_options" =>array("0"=>'开始时', "5"=>'5分钟前', "15"=>'15分钟前', "30"=>'30分钟前', "60"=>'1小时前', "120"=>'2小时前',),
        );

        $entityname=getEntitynameByModulename('Calendar');
        $this->list_link_field=$entityname['fieldname'];

        /*
        //带中英翻译
        for($i = 1; $i <= 31; $i++){
            //$loop_dayvalue_month_options = array_merge($loop_dayvalue_month_options,array($i=>$i.'号'));
            $loop_dayvalue_month_options = $loop_dayvalue_month_options + array($i=>$i.getFixedLabel('ST'));
        }
        $loop_dayvalue_month_options = $loop_dayvalue_month_options + array('lastday'=>getFixedLabel('LastDay'));
        $this->loop_setting_arr = array(
            "loop_type_options" => array("norepeat"=>getFixedLabel('NoRepeat'), "daily"=>getFixedLabel('EveryDay'),
                "weekly"=>getFixedLabel('Weekly'), "biweekly"=>getFixedLabel('EveryTwoWeeks'), "monthly"=>getFixedLabel('Monthly'),
            ),
            "loop_month_options" =>array("1"=>getFixedLabel('JANUARY'), "2"=>getFixedLabel('FEBRUARY'), "3"=>getFixedLabel('MARCH'),
                "4"=>getFixedLabel('APRIL'), "5"=>getFixedLabel('MAY'), "6"=>getFixedLabel('JUNE'),
                "7"=>getFixedLabel('JULY'), "8"=>getFixedLabel('AUGUST'), "9"=>getFixedLabel('SEPTEMBER'),
                "10"=>getFixedLabel('OCTOBER'), "11"=>getFixedLabel('NOVEMBER'), "12"=>getFixedLabel('DECEMBER'),
            ),
            "loop_dayvalue_options" =>array("1"=>getFixedLabel('Monday'), "2"=>getFixedLabel('Tuesday'), "3"=>getFixedLabel('Wednesday'),
                "4"=>getFixedLabel('Thursday'), "5"=>getFixedLabel('Friday'), "6"=>getFixedLabel('Saturday'), "7"=>getFixedLabel('Sunday'),
            ),
            "loop_dayvalue_month_options" =>$loop_dayvalue_month_options,
            "reminder_setting_options" =>array("0"=>getFixedLabel('AtTheBeginning'), "5"=>'5'.getFixedLabel('MinutesAgo'), "15"=>'15'.getFixedLabel('MinutesAgo'),
                "30"=>'30'.getFixedLabel('MinutesAgo'), "60"=>'1'.getFixedLabel('HoursAgo'), "120"=>'2'.getFixedLabel('HoursAgo'),
            ),
        );*/
     
	}
    static function ChangeStatus($status,$activityid,$activity_mode='')
    {
	

        global $adb;
        if ($activity_mode == 'Task')
        {
                $query = "Update ld_activity set status=? where activityid = ?";
        }
        elseif ($activity_mode == 'Events')
        {
                $query = "Update ld_activity set eventstatus=? where activityid = ?";
        }
		if($query) {
        	$adb->pquery($query, array($status, $activityid));
		}

 }
    /**
     *  Function to get recurring info depending on the recurring type
     *  return  $recurObj       - Object of class RecurringType
     */
    function getrecurringObjValue() {
        require_once('include/utils/RecurringType.php');
    	$recurring_data = array();
    	if (isset($_REQUEST['recurringtype']) && $_REQUEST['recurringtype'] != null && $_REQUEST['recurringtype'] != '--None--') {
    		if (!empty($_REQUEST['date_start'])) {
    			$startDate = $_REQUEST['date_start'];
    		}
    		if (!empty($_REQUEST['calendar_repeat_limit_date'])) {
    			$endDate = $_REQUEST['calendar_repeat_limit_date'];
    		} elseif (isset($_REQUEST['due_date']) && $_REQUEST['due_date'] != null) {
    			$endDate = $_REQUEST['due_date'];
    		}
    		if (!empty($_REQUEST['time_start'])) {
    			$startTime = $_REQUEST['time_start'];
    		}
    		if (!empty($_REQUEST['time_end'])) {
    			$endTime = $_REQUEST['time_end'];
    		}
    
    		$recurring_data['startdate'] = $startDate;
    		$recurring_data['starttime'] = $startTime;
    		$recurring_data['enddate'] = $endDate;
    		$recurring_data['endtime'] = $endTime;
    
    		$recurring_data['type'] = $_REQUEST['recurringtype'];
    		if ($_REQUEST['recurringtype'] == 'Weekly') {
    			if (isset($_REQUEST['sun_flag']) && $_REQUEST['sun_flag'] != null)
    				$recurring_data['sun_flag'] = true;
    			if (isset($_REQUEST['mon_flag']) && $_REQUEST['mon_flag'] != null)
    				$recurring_data['mon_flag'] = true;
    			if (isset($_REQUEST['tue_flag']) && $_REQUEST['tue_flag'] != null)
    				$recurring_data['tue_flag'] = true;
    			if (isset($_REQUEST['wed_flag']) && $_REQUEST['wed_flag'] != null)
    				$recurring_data['wed_flag'] = true;
    			if (isset($_REQUEST['thu_flag']) && $_REQUEST['thu_flag'] != null)
    				$recurring_data['thu_flag'] = true;
    			if (isset($_REQUEST['fri_flag']) && $_REQUEST['fri_flag'] != null)
    				$recurring_data['fri_flag'] = true;
    			if (isset($_REQUEST['sat_flag']) && $_REQUEST['sat_flag'] != null)
    				$recurring_data['sat_flag'] = true;
    		}
    		elseif ($_REQUEST['recurringtype'] == 'Monthly') {
    			if (isset($_REQUEST['repeatMonth']) && $_REQUEST['repeatMonth'] != null)
    				$recurring_data['repeatmonth_type'] = $_REQUEST['repeatMonth'];
    			if ($recurring_data['repeatmonth_type'] == 'date') {
    				if (isset($_REQUEST['repeatMonth_date']) && $_REQUEST['repeatMonth_date'] != null)
    					$recurring_data['repeatmonth_date'] = $_REQUEST['repeatMonth_date'];
    				else
    					$recurring_data['repeatmonth_date'] = 1;
    			}
    			elseif ($recurring_data['repeatmonth_type'] == 'day') {
    				$recurring_data['repeatmonth_daytype'] = $_REQUEST['repeatMonth_daytype'];
    				switch ($_REQUEST['repeatMonth_day']) {
    					case 0 :
    						$recurring_data['sun_flag'] = true;
    						break;
    					case 1 :
    						$recurring_data['mon_flag'] = true;
    						break;
    					case 2 :
    						$recurring_data['tue_flag'] = true;
    						break;
    					case 3 :
    						$recurring_data['wed_flag'] = true;
    						break;
    					case 4 :
    						$recurring_data['thu_flag'] = true;
    						break;
    					case 5 :
    						$recurring_data['fri_flag'] = true;
    						break;
    					case 6 :
    						$recurring_data['sat_flag'] = true;
    						break;
    				}
    			}
    		}
    		if (isset($_REQUEST['repeat_frequency']) && $_REQUEST['repeat_frequency'] != null)
    			$recurring_data['repeat_frequency'] = $_REQUEST['repeat_frequency'];
    
    		$recurObj = RecurringType::fromUserRequest($recurring_data);
    		return $recurObj;
    	}
    }
	function save_module($module)
	{
	 
		global $adb;
		//Handling module specific save
		//Insert into seactivity rel
      	
		if(isset($_REQUEST['parent_id']) && $_REQUEST['parent_id'] != '')
		{
			$this->insertIntoEntityTable("ld_seactivityrel", $module);
		}
		elseif($_REQUEST['parent_id']=='' && $insertion_mode=="edit")
		{
			$this->deleteRelation("ld_seactivityrel");
		}
		//Insert into cntactivity rel		
		/*if(isset($this->column_fields['contact_id']) && $this->column_fields['contact_id'] != '')
		{
			$this->insertIntoEntityTable('ld_cntactivityrel', $module);
		}
		elseif($this->column_fields['contact_id'] =='' && $insertion_mode=="edit")
		{
			$this->deleteRelation('ld_cntactivityrel');
		}*/
		$recur_type='';	
		if(($recur_type == "--None--" || $recur_type == '') && $this->mode == "edit")
		{
			$sql = 'delete  from ld_recurringevents where activityid=?';
			$adb->pquery($sql, array($this->id));		
		}	
		//Handling for recurring type
		//Insert into lingdang_recurring event table

		//if(isset($this->column_fields['recurringtype']) && $this->column_fields['recurringtype']!='' && $this->column_fields['recurringtype']!='--None--')
		if(isset($_REQUEST['recurringtype']) && !empty($_REQUEST['recurringtype']) && $_REQUEST['recurringtype'] != '--None--')
		{
			$recur_type = trim($this->column_fields['recurringtype']);
			$recur_data =$this->getrecurringObjValue();
			if(is_object($recur_data)){
				$this->insertIntoRecurringTable($recur_data);
			}
		}	
	
		//Insert into lingdang_activity_remainder table

			$this->insertIntoReminderTable('ld_activity_reminder',$module,"");

		//Handling for invitees
   
			if (isset($_REQUEST['inviteesid'])){
                $selected_users_string =  $_REQUEST['inviteesid'];
                $invitees_array = explode(';',$selected_users_string);
                $this->insertIntoInviteeTable($module,$invitees_array);
            }
                    

		//Inserting into sales man activity rel
		$this->insertIntoSmActivityRel($module);
        /**
         * edit:kevin
         * date:2013-07-22
         * reason:相关客户是否是已分配,分配则改变客户信息
         */
        /*
        if(isset($_REQUEST['account_id'])){
           $account=CRMEntity::getInstance('Accounts');
           $account->updateAccountInfo($module,$_REQUEST['account_id']);
        } 
       */
        

		//$this->insertIntoActivityReminderPopup($module);
	}

    public function after_save()
    {
        //ls 20240412 XUQIU1002280  优化日程界面及其设置循环日程功能
        $this->insertIntoLoopCalendarRemindsTable();

        //编辑保存单据时更新循环提醒
        $this->updateLoopCalendarReminds();
    }

    //保存"循环设置"
    public function insertIntoLoopCalendarRemindsTable()
    {

        if(isset($_REQUEST['loop_type']))
        {
            global $adb;
            //更新循环设置数据
            $loop_type = trim($_REQUEST['loop_type']);

            $loop_month_arr = explode(',',$_REQUEST['loop_month']);
            $loop_month = implode(' |##| ',$loop_month_arr);

            $loop_dayvalue_arr = explode(',',$_REQUEST['loop_dayvalue']);
            $loop_dayvalue = implode(' |##| ',$loop_dayvalue_arr);


            $reminder_setting_arr = explode(',',$_REQUEST['reminder_setting']);
            $reminder_setting = implode(' |##| ',$reminder_setting_arr);

            foreach ($reminder_setting_arr as &$tmp_value){//不能用字符串替换
                $tmp_value = $this->loop_setting_arr['reminder_setting_options'][trim($tmp_value)];
            }
            $reminder_description = implode(',',$reminder_setting_arr);


            $expiredate = $_REQUEST['expiredate'];
            if (empty($expiredate)) $expiredate = NULL;



            //前端已经处理过了，这里再处理一遍
            if ($loop_type == 'norepeat') {
                $loop_month = $loop_dayvalue = '';
                $loop_description = '不重复';
            }
            elseif ($loop_type == 'daily') {
                $loop_month = $loop_dayvalue = '';
                $loop_description = '每天重复';
            }
            elseif ($loop_type == 'weekly' || $loop_type == 'biweekly') {
                $loop_month = '';

                if ($loop_type == 'weekly')
                    $loop_description = '每周的';
                else
                    $loop_description = '每两周的';

                foreach ($loop_dayvalue_arr as $val) {
                    $tmp_weekval[] = $this->loop_setting_arr['loop_dayvalue_options'][trim($val)];
                }

                $loop_description = $loop_description.implode(',',$tmp_weekval).'重复';//每周的周一周二重复
            }
            elseif ($loop_type == 'monthly') {
                foreach ($loop_month_arr as $val) {
                    $tmp_monthval[] = $this->loop_setting_arr['loop_month_options'][$val];
                }
                foreach ($loop_dayvalue_arr as $val) {
                    $tmp_dayval[] = $this->loop_setting_arr['loop_dayvalue_month_options'][$val];
                }
                $loop_description = '在'.implode(',',$tmp_monthval).'的'.implode(',',$tmp_dayval).'重复';//在一月二月的1号2号重复
            }

            //考虑到编辑历史数据 可能需要插入
            /*$sql = "INSERT INTO ld_loopcalendar_reminds(activityid,loop_type,loop_month,loop_dayvalue,reminder_setting,expiredate,loop_description) VALUES (?,?,?,?,?,?,?) ON DUPLICATE KEY UPDATE loop_type=?,loop_month=?,loop_dayvalue=?,reminder_setting=?,expiredate=?,loop_description=?";
            $adb->pquery($sql,array($this->id,$loop_type,$loop_month,$loop_dayvalue,$reminder_setting,$expiredate,$loop_description,$loop_type,$loop_month,$loop_dayvalue,$reminder_setting,$expiredate,$loop_description));*/
            $sql = "select 1 from ld_loopcalendar_reminds where activityid = ?";
            $result = $adb->pquery($sql,array($this->id));
            $rows=$adb->num_rows($result);
            if ($rows<1) {
                $sql = "INSERT INTO ld_loopcalendar_reminds(activityid,loop_type,loop_month,loop_dayvalue,reminder_setting,expiredate,loop_description,reminder_description) VALUES (?,?,?,?,?,?,?,?);";
                $params = array($this->id,$loop_type,$loop_month,$loop_dayvalue,$reminder_setting,$expiredate,$loop_description,$reminder_description);
            }else{
                $sql = "UPDATE ld_loopcalendar_reminds SET loop_type=?,loop_month=?,loop_dayvalue=?,reminder_setting=?,expiredate=?,loop_description=?,reminder_description=? WHERE activityid = ?";
                $params = array($loop_type,$loop_month,$loop_dayvalue,$reminder_setting,$expiredate,$loop_description,$reminder_description,$this->id);
            }
            $adb->pquery($sql, $params);
        }
    }

    public function updateLoopCalendarReminds()
    {
        global $adb;
        $record = $this->id;
        if ($this->mode=='edit') {

            //1、如果ld_reminds表有数据已读或发送则不再处理，否则删除
            $adb->pquery("DELETE ld_crmentity FROM ld_crmentity INNER JOIN (SELECT remindsid FROM ld_reminds WHERE related_to =? AND remindstype = 'LoopCalendarCreateRemind' AND DATE(date_time) = CURDATE()
AND (status_rmd = '未读' AND push_to_weixin = 2 AND push_to_ding = 2 AND push_to_yzj = 2 AND push_to_offiaccount = 2 AND push_to_fw = 2 AND push_to_zy = 2)) as tmp on tmp.remindsid=ld_crmentity.crmid;",array($record));

            $remind_sql = "DELETE FROM ld_reminds WHERE related_to = ? AND remindstype = 'LoopCalendarCreateRemind' AND DATE(date_time) = CURDATE()
AND (status_rmd = '未读' AND push_to_weixin = 2 AND push_to_ding = 2 AND push_to_yzj = 2 AND push_to_offiaccount = 2 AND push_to_fw = 2 AND push_to_zy = 2);";
            $adb->pquery($remind_sql,array($record));

            //2、解析数据，重新插入提醒表
            /*$startdate = $curdate = date("Y-m-d");//2024-04-17
            $enddate = date("Y-m-d")." 23:59:59";

            $sql = "SELECT
	ld_activity.`subject`,
	ld_activity.date_start,
	ld_activity.smownerid,
    ld_loopcalendar_reminds.*
FROM
	ld_activity
INNER JOIN ld_loopcalendar_reminds  ON ld_loopcalendar_reminds.activityid = ld_activity.activityid
WHERE
    ld_activity.activityid = ?
AND ld_activity.deleted = 0
AND ld_activity.activitytype != 'emails' 
AND ifnull(ld_loopcalendar_reminds.reminder_setting,'') <> ''
AND ifnull(ld_loopcalendar_reminds.loop_type, 'norepeat') <> 'norepeat'
AND ld_activity.date_start <= ? -- 开始时间应该小于当前面板的结束时间(即还没开始的单据无需解析) '2024-04-17 23:59:59'
AND (
	ifnull(ld_loopcalendar_reminds.expiredate, '') = '' -- 无限循环
	OR ld_loopcalendar_reminds.expiredate >= ? -- 到期日期得在当前面板开始时间之后（即已经到期的单据无需解析） '2024-04-17'
);";
            $result = $adb->pquery($sql,array($record,$enddate,$curdate));

            $this->parseLoopCalendarRemindsResult($result,$startdate,$enddate);*/

        }

        //2、解析数据，重新插入提醒表(兼容不重复也需要提醒，其中不重复的提醒提前写入，重复的提醒仅写入当天的)
        $startdate = $curdate = date("Y-m-d");//2024-04-17
        $enddate = date("Y-m-d")." 23:59:59";
        $sql = "SELECT 
ld_activity.`subject`,
ld_activity.date_start,
ld_activity.smownerid,
ld_loopcalendar_reminds.*
FROM
ld_activity
INNER JOIN ld_loopcalendar_reminds  ON ld_loopcalendar_reminds.activityid = ld_activity.activityid
WHERE
ld_activity.activityid = ?
AND ld_activity.deleted = 0
AND ld_activity.activitytype <> 'emails' 
AND ld_activity.eventstatus <> '已执行'
AND ifnull(ld_loopcalendar_reminds.reminder_setting,'') <> ''
AND CASE WHEN ifnull(ld_loopcalendar_reminds.loop_type, 'norepeat') <> 'norepeat' THEN 
		ld_activity.date_start <= ? -- 开始时间应该小于当前面板的结束时间(即还没开始的单据无需解析) '2024-04-17 23:59:59'
	AND (
		ifnull(ld_loopcalendar_reminds.expiredate, '') = '' -- 无限循环
		OR ld_loopcalendar_reminds.expiredate >= ? -- 到期日期得在当前面板开始时间之后（即已经到期的单据无需解析） '2024-04-17'
	)
	ELSE TRUE 
END
;";

        $result = $adb->pquery($sql,array($record,$enddate,$curdate));

        $this->parseLoopCalendarRemindsResult($result,$startdate,$enddate);

    }

    //解析结果,生成提醒.（单据编辑保存后和任务计划）
    function parseLoopCalendarRemindsResult($result,$startdate,$enddate) {
        global $adb;
        $loop_result_arr = $adb->query_result_all($result);

        foreach ($loop_result_arr as $item) {
            $date_start = $item['date_start'];
            $loop_type = $item['loop_type'];
            $loop_month = $item['loop_month'];
            $loop_dayvalue = $item['loop_dayvalue'];
            $reminder_setting = $item['reminder_setting'];

            $tmp_rangedate_arr = [];
            if ($loop_type == 'daily') {
//                $tmp_rangedate_arr = $this->generateDataByDaily($item, $startdate, $enddate);
                $tmp_rangedate_arr = array($startdate);
            } elseif ($loop_type == 'weekly') {
                $tmp_rangedate_arr = $this->generateDataByWeekly($item, $startdate, $enddate);
            } elseif ($loop_type == 'biweekly') {
            } elseif ($loop_type == 'monthly') {
                $tmp_rangedate_arr = $this->generateDataByMonthly($item, $startdate, $enddate);
                /*if (!empty($loop_month) && !empty($loop_dayvalue)) {
                    $month_numbers = explode(' |##| ',$loop_month);
                    $day_numbers = explode(' |##| ',$loop_dayvalue);

                    $tmp_year = date('Y',strtotime($startdate));
                    foreach ($month_numbers as $tmp_month) {
                        foreach ($day_numbers as $tmp_day) {
                            $tmp_ymd = "$tmp_year-$tmp_month-$tmp_day";
                            if ($tmp_day == 'lastday') {//最后一天
                                $tmp_ym = "$tmp_year-$tmp_month";
                                $tmp_rangedate_arr[] = date("Y-m-t",strtotime($tmp_ym));
                            }else if ($this->isDateValid($tmp_ymd)) {//无效日期忽略
                                $tmp_rangedate_arr[] = date("Y-m-d",strtotime($tmp_ymd));
                            }
                        }
                    }

                }*/

            }

            //根据得到的日期 生成 循环数据
            $date_start_timestamp = strtotime($item['date_start']);
//dump($tmp_rangedate_arr);

            // $tmp_rangedate_arr 最多一个值，即当前日期或者空数组
            if (in_array($startdate,$tmp_rangedate_arr) || $loop_type == 'norepeat') {
                if ($loop_type != 'norepeat') //重复日程需要拼接到当前日期；不重复即为当前单据开始时间，无需拼接到当前日期
                    $item['date_start'] = $startdate.' '.date('H:i:s',$date_start_timestamp);//当天日程开始时间

                $this->createLoopCalendarReminds($item);
            }

        }
    }
    /*
     * 创建循环日程提醒
     * */
    function createLoopCalendarReminds($item) {
        require_once(globalStatic::$root_directory."modules/Reminds/Reminds.php");
//    require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/MessageCorpconversation.php");
        $focusreminds = new Reminds();
        $focusreminds->column_fields['related_to'] = $item['activityid'];
        $focusreminds->column_fields['reltab'] = 'Calendar';
        $focusreminds->column_fields['is_del_send'] = 0;
        $focusreminds->column_fields['is_del_rec'] = 0;
        $focusreminds->column_fields['status_rmd'] = '未读';
        $focusreminds->column_fields['recieverid'] = $item['smownerid'];
        $focusreminds->column_fields['content'] = decode_html($item['subject']);
        $focusreminds->column_fields['remindstype'] = 'LoopCalendarCreateRemind';
        $focusreminds->mode='create';

        $reminder_setting = $item['reminder_setting'];
        if (empty($reminder_setting)) {
            $reminder_numbers = ["0"];
        }else{
            $reminder_numbers = explode(' |##| ',$reminder_setting);
        }

        foreach ($reminder_numbers as $reminder_ago){
            $tmp_date_time = date('Y-m-d H:i:s', strtotime("-$reminder_ago minutes", strtotime($item['date_start'])));//日期提前指定分钟数

            if (strtotime($tmp_date_time) < time()) continue;//今天之前的提醒或者小于当前时间的提醒,应该不提醒了

            $focusreminds->column_fields['date_time'] = $tmp_date_time;
            $focusreminds->save('Reminds');

        }
    }
	
	/*
    date：20130917
    reason:更多信息字段
    edit by chj
    */
    function getRelated($Type)
    {
        
        global $adb,$current_user;
        require('user_privileges/user_language_'.$current_user->id.'.php');
         $this->list_fields_name=array();
         $this->list_fields=array();
        $SqlField = "select tablename,fieldname,case when ifnull(ld_tranlabel.fieldlabel,'')=''then ld_field.fieldlabel else ld_tranlabel.fieldlabel end as fieldlabel
                 from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
              inner join ld_relatedlists_lable  on ld_relatedlists_lable.fieldid=ld_field.fieldid
             where languagetype=? and trantable=? and ld_tranlabel.tabid=?  and ld_relatedlists_lable.presence=1  order by ld_relatedlists_lable.sequence";
        
        $result = $adb->pquery($SqlField,array($languageType,'ld_field',16));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            
                $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
                        "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
                    );   
                  $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";
               
            
        }
          
    }
	/** Function to insert values in ld_activity_reminder_popup table for the specified module
  	  * @param $cbmodule -- module:: Type varchar
 	 */
	function insertIntoActivityReminderPopup($cbmodule) {
		
		global $adb;
		
		$cbrecord = $this->id;
		unset($_SESSION['next_reminder_time']);
		if(isset($cbmodule) && isset($cbrecord)) {
			$cbdate = getValidDBInsertDateValue($this->column_fields['date_start']);
			$cbtime = $this->column_fields['time_start'];
			
			$reminder_query = "SELECT reminderid FROM ld_activity_reminder_popup WHERE semodule = ? and recordid = ?";
			$reminder_params = array($cbmodule, $cbrecord);		
			$reminderidres = $adb->pquery($reminder_query, $reminder_params);
		
			$reminderid = null;
			if($adb->num_rows($reminderidres) > 0) {
				$reminderid = $adb->query_result($reminderidres, 0, "reminderid");
			}
	
			if(isset($reminderid)) {
				$callback_query = "UPDATE ld_activity_reminder_popup set status = 0, date_start = ?, time_start = ? WHERE reminderid = ?"; 
				$callback_params = array($cbdate, $cbtime, $reminderid);
			} else {
				$callback_query = "INSERT INTO ld_activity_reminder_popup (recordid, semodule, date_start, time_start) VALUES (?,?,?,?)";
				$callback_params = array($cbrecord, $cbmodule, $cbdate, $cbtime);
			}
		
			$adb->pquery($callback_query, $callback_params);
		}		
	}


	/** Function to insert values in lingdang_activity_remainder table for the specified module,
  	  * @param $table_name -- table name:: Type varchar
  	  * @param $module -- module:: Type varchar
 	 */
	function insertIntoReminderTable($table_name,$module,$recurid)
	{
	 
		if($_REQUEST['set_remind'] == 'Yes')
		{
			unset($_SESSION['next_reminder_time']);
            $reminder_time = $_REQUEST['email_date_only'];
         
         

            $date = new DateTimeField($reminder_time);
   
            $reminder_time=$date->getDBInsertDateTimeValue();
   
			if ($recurid == "")
			{
				if($_REQUEST['mode'] == 'edit')
				{
					$this->activity_reminder($this->id,$reminder_time,0,$recurid,'edit');
				}
				else
				{
					$this->activity_reminder($this->id,$reminder_time,0,$recurid,'');
				}
			}
			else
			{
				$this->activity_reminder($this->id,$reminder_time,0,$recurid,'');
			}
		}
		elseif($_REQUEST['set_remind'] == 'No'||$_REQUEST['set_remind'] == '')
		{
			$this->activity_reminder($this->id,'0',0,$recurid,'delete');
		}
	}
	

	// Code included by Jaguar - starts
	/** Function to insert values in ld_recurringevents table for the specified tablename,module
  	  * @param $recurObj -- Recurring Object:: Type varchar
 	 */	
function insertIntoRecurringTable(& $recurObj)
{
	global $adb;
	
	$st_date = $recurObj->startdate->get_DB_formatted_date();
	
	$end_date = $recurObj->enddate->get_DB_formatted_date();
	
	$type = $recurObj->getRecurringType();
    $flag="true";

	if($_REQUEST['mode'] == 'edit')
	{
		$activity_id=$this->id;

		$sql='select min(recurringdate) AS min_date,max(recurringdate) AS max_date, recurringtype, activityid from ld_recurringevents where activityid=? group by activityid, recurringtype';
		$result = $adb->pquery($sql, array($activity_id));
		$noofrows = $adb->num_rows($result);
		for($i=0; $i<$noofrows; $i++)
		{
			$recur_type_b4_edit = $adb->query_result($result,$i,"recurringtype");
			$date_start_b4edit = $adb->query_result($result,$i,"min_date");
			$end_date_b4edit = $adb->query_result($result,$i,"max_date");
		}
  
		if(($st_date == $date_start_b4edit) && ($end_date==$end_date_b4edit) && ($type == $recur_type_b4_edit))
		{
			if($_REQUEST['set_reminder'] == 'Yes')
			{
				$sql = 'delete from ld_activity_reminder where activity_id=?';
				$adb->pquery($sql, array($activity_id));
				$sql = 'delete  from ld_recurringevents where activityid=?';
				$adb->pquery($sql, array($activity_id));
				$flag="true";
			}
			elseif($_REQUEST['set_reminder'] == 'No')
			{
				$sql = 'delete  from ld_activity_reminder where activity_id=?';
				$adb->pquery($sql, array($activity_id));
				$flag="false";
			}
			else
				$flag="false";
		}
		else
		{
			$sql = 'delete from ld_activity_reminder where activity_id=?';
			$adb->pquery($sql, array($activity_id));
			$sql = 'delete  from ld_recurringevents where activityid=?';
			$adb->pquery($sql, array($activity_id));
		}
	}

	$recur_freq = $recurObj->getRecurringFrequency();
	$recurringinfo = $recurObj->getDBRecurringInfoString();
    
	if($flag=="true") {
		$max_recurid_qry = 'select max(recurringid) AS recurid from ld_recurringevents;';
		$result = $adb->pquery($max_recurid_qry, array());
		$noofrows = $adb->num_rows($result);
		$recur_id = 0;
		if($noofrows > 0) {
			$recur_id = $adb->query_result($result,0,"recurid");
		}
         
		$current_id =$recur_id+1;
		$recurring_insert = "insert into ld_recurringevents values (?,?,?,?,?,?)";
  
		$rec_params = array($current_id, $this->id, $st_date, $type, $recur_freq, $recurringinfo);
		$adb->pquery($recurring_insert, $rec_params);

		unset($_SESSION['next_reminder_time']);
		if($_REQUEST['set_reminder'] == 'Yes') {
			$this->insertIntoReminderTable("ld_activity_reminder",$module,$current_id,'');
		}
	}
}


	/** Function to insert values in lingdang_invitees table for the specified module,tablename ,invitees_array
  	  * @param $table_name -- table name:: Type varchar
  	  * @param $module -- module:: Type varchar
	  * @param $invitees_array Array
 	 */
	function insertIntoInviteeTable($module,$invitees_array)
	{
		global $adb;
		
		if($this->mode == 'edit'){
			$sql = "delete from ld_invitees where activityid=?";
			$adb->pquery($sql, array($this->id));
		}	
     
		foreach($invitees_array as $inviteeid)
		{
			if($inviteeid != '')
			{
				$query="insert into ld_invitees(activityid,inviteeid) values (?,?)";
				$adb->pquery($query, array($this->id, $inviteeid));
			}
		}
	
	}


	/** Function to insert values in lingdang_salesmanactivityrel table for the specified module
  	  * @param $module -- module:: Type varchar
 	 */

  	function insertIntoSmActivityRel($module)
  	{
    		global $adb;
    		global $current_user;
    		if($this->mode == 'edit'){
      			$sql = "delete from ld_salesmanactivityrel where activityid=?";
      			$adb->pquery($sql, array($this->id));
    		}

		$user_sql = $adb->pquery("select count(1) as count from ld_users where id=?", array($this->column_fields['assigned_user_id']));
    	if($adb->query_result($user_sql, 0, 'count') != 0) {
		$sql_qry = "insert into ld_salesmanactivityrel (smid,activityid) values(?,?)";
    		$adb->pquery($sql_qry, array($this->column_fields['assigned_user_id'], $this->id));
		
		if(isset($_REQUEST['inviteesid']) && $_REQUEST['inviteesid']!='')
		{
			$selected_users_string =  $_REQUEST['inviteesid'];
			$invitees_array = explode(';',$selected_users_string);
			foreach($invitees_array as $inviteeid)
			{
				if($inviteeid != '')
				{
					$resultcheck = $adb->pquery("select * from ld_salesmanactivityrel where activityid=? and smid=?",array($this->id,$inviteeid));
					if($adb->num_rows($resultcheck) != 1){
						$query="insert into ld_salesmanactivityrel values(?,?)";
						$adb->pquery($query, array($inviteeid, $this->id));
					}	
				}	
			}
		}
	}	
}

	/**
	 *
	 * @param String $tableName
	 * @return String
	 */
	public function getJoinClause($tableName) {
        if($tableName == "ld_activity_reminder")
            return 'LEFT JOIN';
		return parent::getJoinClause($tableName);
	}
	
	
	// Mike Crowe Mod --------------------------------------------------------Default ordering for us
	/**
	 * Function to get sort order
	 * return string  $sorder    - sortorder string either 'ASC' or 'DESC'
	 */
	function getSortOrder()
	{
        if (!empty($this->reportSortType)){
            return $this->reportSortType;
        }
		if(isset($_REQUEST['sorder'])) 
			$sorder = $this->db->sql_escape_string($_REQUEST['sorder']);
		else
			$sorder = (($_SESSION['ACTIVITIES_SORT_ORDER'] != '')?($_SESSION['ACTIVITIES_SORT_ORDER']):($this->default_sort_order));
		
		return $sorder;
	}
	
	/**
	 * Function to get order by
	 * return string  $order_by    - fieldname(eg: 'subject')
	 
	function getOrderBy()
	{
	
		$use_default_order_by = '';		
		if(PerformancePrefs::getBoolean('LISTVIEW_DEFAULT_SORTING', true)) {
			$use_default_order_by = $this->default_order_by;
		}

		if (isset($_REQUEST['order_by'])) 
			$order_by = $this->db->sql_escape_string($_REQUEST['order_by']);
		else
			$order_by = (($_SESSION['ACTIVITIES_ORDER_BY'] != '')?($_SESSION['ACTIVITIES_ORDER_BY']):($use_default_order_by));
	
		return $order_by;
	}	*/
	// Mike Crowe Mod --------------------------------------------------------



//Function Call for Related List -- Start
	/**
	 * Function to get Activity related Contacts
	 * @param  integer   $id      - activityid
	 * returns related Contacts record in array format
	 */
	function get_contacts($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global  $singlepane_view,$currentModule,$current_user;
		
		$this_module = $currentModule;

        $related_module = vtlib_getModuleNameById($rel_tab_id);
		require_once("modules/$related_module/$related_module.php");
		$other = new $related_module();
        vtlib_setup_modulevars($related_module, $other);		
		$singular_modname = vtlib_toSingular($related_module);
		
		$parenttab = getParentTab();
		
		$returnset = '&return_module='.$this_module.'&return_action=DetailView&activity_mode=Events&return_id='.$id;
		
		$search_string = '';
		$button = '';
				
		if($actions) {
			if(is_string($actions)) $actions = explode(',', strtoupper($actions));
			if(in_array('SELECT', $actions) && isPermitted($related_module,4, '') == 'yes') {
				$button .= "<input title='".getTranslatedString('LBL_SELECT')." ". getTranslatedString($related_module). "' class='edit' type='button' onclick=\"return window.open('index.php?module=$related_module&return_module=$currentModule&action=Popup&popuptype=detailview&select=enable&form=EditView&form_submit=false&recordid=$id&parenttab=$parenttab$search_string','test','width=640,height=602,resizable=0,scrollbars=0');\" value='". getTranslatedString('LBL_SELECT'). " " . getTranslatedString($related_module) ."'>&nbsp;";
			}
		}
		

		/*$query = 'select ld_users.user_name,ld_contactdetails.accountid,ld_contactdetails.contactid, ld_contactdetails.firstname,ld_contactdetails.lastname, ld_contactdetails.department, ld_contactdetails.title, ld_contactdetails.email, ld_contactdetails.phone, ld_contactdetails.contactid as crmid, ld_contactdetails.smownerid, ld_contactdetails.modifiedtime from ld_contactdetails inner join ld_cntactivityrel on ld_cntactivityrel.contactid=ld_contactdetails.contactid left join ld_users
        on ld_users.id = ld_crmentity.smownerid left join 
        ld_groups on ld_groups.groupid = ld_contactdetails.smownerid 
        where ld_cntactivityrel.activityid='.$id.' and ld_contactdetails.deleted=0';

				
		$return_value = GetRelatedList($this_module, $related_module, $other, $query, $button, $returnset); */
		
		if($return_value == null) $return_value = Array();
		$return_value['CUSTOM_BUTTON'] = $button;	
		return $return_value;
	}
	
	/**
	 * Function to get Activity related Users
	 * @param  integer   $id      - activityid
	 * returns related Users record in array format
	 */

	function get_users($id) {	
	
		global $app_strings;

		$focus = new Users();

		$button = '<input title="Change" accessKey="" tabindex="2" type="button" class="edit" 
					value="'.getTranslatedString('LBL_SELECT_USER_BUTTON_LABEL').'" name="button" LANGUAGE=javascript 
					onclick=\'return window.open("index.php?module=Users&return_module=Calendar&return_action={$return_modname}&activity_mode=Events&action=Popup&popuptype=detailview&form=EditView&form_submit=true&select=enable&return_id='.$id.'&recordid='.$id.'","test","width=640,height=525,resizable=0,scrollbars=0")\';>';                  

		$returnset = '&return_module=Calendar&return_action=CallRelatedList&return_id='.$id;


		$query = 'SELECT ld_users.id, ld_users.first_name,ld_users.last_name, ld_users.user_name, ld_users.email1, ld_users.email2, ld_users.status, ld_users.is_admin, ld_user2role.roleid, ld_users.secondaryemail, ld_users.phone_home, ld_users.phone_work, ld_users.phone_mobile, ld_users.phone_other, ld_users.phone_fax,ld_activity.date_start,ld_activity.due_date,ld_activity.time_start,ld_activity.duration_hours,ld_activity.duration_minutes from ld_users inner join ld_salesmanactivityrel on ld_salesmanactivityrel.smid=ld_users.id  inner join ld_activity on ld_activity.activityid=ld_salesmanactivityrel.activityid inner join ld_user2role on ld_user2role.userid=ld_users.id where ld_activity.activityid='.$id;
		
		$return_data = GetRelatedList('Calendar','Users',$focus,$query,$button,$returnset);
		
		if($return_data == null) $return_data = Array();
		$return_data['CUSTOM_BUTTON'] = $button;

		return $return_data;
	}

	/**
         * Function to get activities for given criteria
	 * @param   string   $criteria     - query string
	 * returns  activity records in array format($list) or null value
         */	 
  	function get_full_list($criteria) {

        return null;

	    $query = "select ld_activity.activityid as crmid,ld_activity.smownerid,ld_crmentity.setype, ld_activity.*, 
	    		ld_contactdetails.lastname, ld_contactdetails.firstname, ld_contactdetails.contactid 
	    		from ld_activity 
	    		inner join ld_crmentity on ld_crmentity.crmid=ld_activity.activityid 
	    		left join ld_cntactivityrel on ld_cntactivityrel.activityid= ld_activity.activityid 
	    		left join ld_contactdetails on ld_contactdetails.contactid= ld_cntactivityrel.contactid 
	    		left join ld_seactivityrel on ld_seactivityrel.activityid = ld_activity.activityid 
	    		WHERE ld_activity.deleted=0 ".$criteria;
    	$result = $this->db->query($query);
        
    if($this->db->getRowCount($result) > 0){
		
      // We have some data.
      while ($row = $this->db->fetchByAssoc($result)) {
        foreach($this->getRelated(2) as $field)
        {
          if (isset($row[$field])) {
            $this->$field = $row[$field];
          }
          else {
            $this->$field = '';   
          }
        }
        $list[] = $this;
      }
    }
    if (isset($list))
    	{
	
	    return $list;
	}
	else
	{
		
	    return null;
	}

  }

	
//calendarsync
    /**
     * Function to get meeting count
     * @param  string   $user_name        - User Name
     * return  integer  $row["count(*)"]  - count
     */
    function getCount_Meeting($user_name) 
	{
	
      $query = "select count(*) from ld_activity inner join ld_salesmanactivityrel on ld_salesmanactivityrel.activityid=ld_activity.activityid inner join ld_users on ld_users.id=ld_salesmanactivityrel.smid where user_name=? and ld_activity.deleted=0 and ld_activity.activitytype='Meeting'";
      $result = $this->db->pquery($query, array($user_name),true,"Error retrieving contacts count");
      $rows_found =  $this->db->getRowCount($result);
      $row = $this->db->fetchByAssoc($result, 0);

      return $row["count(*)"];
    }
   
    
//calendarsync
	/**
	 * Function to get task count
	 * @param  string   $user_name        - User Name
	 * return  integer  $row["count(*)"]  - count
	 */
    function getCount($user_name) 
    {
	   
        $query = "select count(1) from ld_activity inner join ld_salesmanactivityrel on ld_salesmanactivityrel.activityid=ld_activity.activityid inner join ld_users on ld_users.id=ld_salesmanactivityrel.smid where user_name=? and ld_activity.deleted=0 and ld_activity.activitytype='Task'";
        $result = $this->db->pquery($query,array($user_name), true,"Error retrieving contacts count");
        $rows_found =  $this->db->getRowCount($result);
        $row = $this->db->fetchByAssoc($result, 0);
   
        return $row["count(*)"];
    }       

    /**
     * Function to get list of task for user with given limit
     * @param  string   $user_name        - User Name
     * @param  string   $from_index       - query string
     * @param  string   $offset           - query string 
     * returns tasks in array format
     */
   
	
    /**
     * Function to process the activity list query
     * @param  string   $query     - query string
     * return  array    $response  - activity lists
     */
    function process_list_query1($query)
    {
	   
        $result =& $this->db->query($query,true,"Error retrieving $this->object_name list: ");
        $list = Array();
        $rows_found =  $this->db->getRowCount($result);
        if($rows_found != 0)
        {
            $task = Array();
              for($index = 0 , $row = $this->db->fetchByAssoc($result, $index); $row && $index <$rows_found;$index++, $row = $this->db->fetchByAssoc($result, $index))
            
             {
                foreach($this->range_fields as $columnName)
                {
					if (isset($row[$columnName])) {
						if($columnName == 'time_start'){
							$startDate = new DateTimeField($row['date_start'].' '.
									$row[$columnName]);
							$task[$columnName] = $startDate->getDBInsertTimeValue();
						}else{
							$task[$columnName] = $row[$columnName];
						}
                    }   
                    else     
                    {   
                            $task[$columnName] = "";
                    }   
	            }	
    
                $task[contact_name] = return_name($row, 'cfn', 'cln');    

                    $list[] = $task;
                }
         }

        $response = Array();
        $response['list'] = $list;
        $response['row_count'] = $rows_found;
        $response['next_offset'] = $next_offset;
        $response['previous_offset'] = $previous_offset;
        return $response;
    }

    	/**
	 * Function to get reminder for activity
	 * @param  integer   $activity_id     - activity id
	 * @param  string    $reminder_time   - reminder time
	 * @param  integer   $reminder_sent   - 0 or 1
	 * @param  integer   $recurid         - recuring eventid
	 * @param  string    $remindermode    - string like 'edit'	 
	 */	
	function activity_reminder($activity_id,$reminder_time,$reminder_sent=0,$recurid=0,$remindermode='')
	{
		
		$query_exist = "SELECT activity_id FROM ".$this->reminder_table." WHERE activity_id = ?";
		$result_exist = $this->db->pquery($query_exist, array($activity_id));
     
       
		if($remindermode == 'edit')
		{
			if($this->db->num_rows($result_exist) > 0)
			{
				$query = "UPDATE ".$this->reminder_table." SET";
				$query .=" reminder_sent = ?, email_remind = ?,content=? WHERE activity_id =?"; 
               
				$params = array($reminder_sent, $reminder_time,$_REQUEST['contents'],$activity_id);
			}
			else
			{
			 //edit:can date:20140821 reason:10807: 如图所示：日常管理，设置提醒【发送邮件通知】为“是”，结果保存后，下面的【发送邮件通知】提醒还是显示为 否。
				$query = "INSERT INTO ".$this->reminder_table."(activity_id,reminder_time,reminder_sent,recurringid,content,email_remind) VALUES (?,?,?,?,?,?)";
                if(isset($_REQUEST['contents'])&&$_REQUEST['contents']!='')
				$params = array($activity_id, 0, 0, 0,$_REQUEST['contents'],$reminder_time);
                else
                $params = array($activity_id, 0, 0, 0,'',$reminder_time);
            
			}
		}
		elseif(($remindermode == 'delete') && ($this->db->num_rows($result_exist) > 0))
		{
			$query = "DELETE FROM ".$this->reminder_table." WHERE activity_id = ?";
			$params = array($activity_id);
		}
		else
		{
            if($reminder_time==0)$reminder_time='0000-00-00 00:00:00';
			$query = "INSERT INTO ".$this->reminder_table."(activity_id,reminder_time,reminder_sent,recurringid,content,email_remind) VALUES (?,?,?,?,?,?)";
            if(isset($_REQUEST['contents'])&&$_REQUEST['contents']!='')
			$params = array($activity_id,0, 0, 0,$_REQUEST['contents'],$reminder_time);
            else
            $params = array($activity_id, 0,0, 0,'',$reminder_time);
		}
     
      	$this->db->pquery($query,$params,true,"Error in processing ld_tab $this->reminder_table");
	
	}

	//Used for lingdangCRM Outlook Add-In
	/**
 	* Function to get tasks to display in outlookplugin
 	* @param   string    $username     -  User name
 	* return   string    $query        -  sql query 
 	*/
	function get_tasksforol($username)
	{
		global $adb;
	
		global $current_user;
	
		$seed_user=new Users();
		$user_id=$seed_user->retrieve_user_id($username);
		$current_user=$seed_user;
		$current_user->retrieve_entity_info($user_id, 'Users');
        $is_admin=is_admin($current_user);
		if($is_admin == true)
  		{
    		$sql1 = "select tablename,columnname from ld_field where tabid=9 and tablename <> 'ld_recurringevents' and tablename <> 'ld_activity_reminder' and ld_field.presence in (0,2)";
			$params1 = array();
  		}else{
    	$profileList = $current_user->profileid;
    	$sql1 = "select tablename,columnname from ld_field inner join ld_profile2field on ld_profile2field.fieldid=ld_field.fieldid inner join ld_def_org_field on ld_def_org_field.fieldid=ld_field.fieldid where ld_field.tabid=9 and tablename <> 'ld_recurringevents' and tablename <> 'ld_activity_reminder' and ld_field.displaytype in (1,2,4,3) and ld_profile2field.visible=0 and ld_def_org_field.visible=0 and ld_field.presence in (0,2)";
		$params1 = array();
		if (count($profileList) > 0) {
  			$sql1 .= " and ld_profile2field.profileid in (". generateQuestionMarks($profileList) .")";
			array_push($params1, $profileList);
		} 
  	}
  	$result1 = $adb->pquery($sql1,$params1);
  	for($i=0;$i < $adb->num_rows($result1);$i++)
  	{
		$permitted_lists[] = $adb->query_result($result1,$i,'tablename');
      	$permitted_lists[] = $adb->query_result($result1,$i,'columnname');
      	/*if($adb->query_result($result1,$i,'columnname') == "parentid")
      	{
        	$permitted_lists[] = 'lingdang_account';
        	$permitted_lists[] = 'accountname';
      	}*/
  		}
		$permitted_lists = array_chunk($permitted_lists,2);
		$column_table_lists = array();
		for($i=0;$i < count($permitted_lists);$i++)
		{
	   		$column_table_lists[] = implode(".",$permitted_lists[$i]);
  		}
   
		/*$query = "select ld_activity.activityid as taskid, ".implode(',',$column_table_lists)." from ld_activity
			 inner join ld_users on ld_users.id = ld_activity.smownerid 
			 left join ld_cntactivityrel on ld_cntactivityrel.activityid=ld_activity.activityid 
			 left join ld_contactdetails on ld_contactdetails.contactid=ld_cntactivityrel.contactid 
			 left join ld_seactivityrel on ld_seactivityrel.activityid = ld_activity.activityid 
			 where ld_users.user_name='".$username."' and ld_activity.deleted=0 and ld_activity.activitytype='Task'";
				 
		return $query;*/
        return '';
	}

	/**
 	* Function to get calendar query for outlookplugin
 	* @param   string    $username     -  User name                                                                            * return   string    $query        -  sql query                                                                            */ 
	function get_calendarsforol($user_name)
	{
		global $adb;
		
		global $current_user;
	
		$seed_user=new Users();
		$user_id=$seed_user->retrieve_user_id($user_name);
		$current_user=$seed_user;
		$current_user->retrieve_entity_info($user_id, 'Users');
	    $is_admin=is_admin($current_user);
     
		if($is_admin == true)
  		{
    		$sql1 = "select tablename,columnname from ld_field where tabid=9 and tablename <> 'ld_recurringevents' and tablename <> 'ld_activity_reminder' and ld_field.presence in (0,2)";
  			$params1 = array();
  		}else
  		{
    		$profileList =$current_user->profileid;
    		$sql1 = "select tablename,columnname from ld_field inner join ld_profile2field on ld_profile2field.fieldid=ld_field.fieldid inner join ld_def_org_field on ld_def_org_field.fieldid=ld_field.fieldid where ld_field.tabid=9 and tablename <> 'ld_recurringevents' and tablename <> 'ld_activity_reminder' and ld_field.displaytype in (1,2,4,3) and ld_profile2field.visible=0 and ld_def_org_field.visible=0 and ld_field.presence in (0,2)";
			$params1 = array();
			if (count($profileList) > 0) {
				$sql1 .= " and ld_profile2field.profileid in (". generateQuestionMarks($profileList) .")";
				array_push($params1,$profileList);		
			}
  		}
  		$result1 = $adb->pquery($sql1, $params1);
  		for($i=0;$i < $adb->num_rows($result1);$i++)
  		{
			$permitted_lists[] = $adb->query_result($result1,$i,'tablename');
      		$permitted_lists[] = $adb->query_result($result1,$i,'columnname');
      		if($adb->query_result($result1,$i,'columnname') == "date_start")
      		{
        		$permitted_lists[] = 'ld_activity';
        		$permitted_lists[] = 'time_start';
      		}
      		if($adb->query_result($result1,$i,'columnname') == "due_date")
      		{
				$permitted_lists[] = 'ld_activity';
        		$permitted_lists[] = 'time_end';
      		}
  		}
		$permitted_lists = array_chunk($permitted_lists,2);
		$column_table_lists = array();
		for($i=0;$i < count($permitted_lists);$i++)
		{
	   		$column_table_lists[] = implode(".",$permitted_lists[$i]);
  		}
   
	  	/*$query = "select ld_activity.activityid as clndrid, ".implode(',',$column_table_lists)." from ld_activity
				inner join ld_salesmanactivityrel on ld_salesmanactivityrel.activityid=ld_activity.activityid 
				inner join ld_users on ld_users.id=ld_salesmanactivityrel.smid 
				left join ld_cntactivityrel on ld_cntactivityrel.activityid=ld_activity.activityid 
				left join ld_contactdetails on ld_contactdetails.contactid=ld_cntactivityrel.contactid 
				left join ld_seactivityrel on ld_seactivityrel.activityid = ld_activity.activityid 
				where ld_users.user_name='".$user_name."' and ld_activity.deleted=0 and ld_activity.activitytype='Meeting'";
	
		return $query;*/
        return '';
	}
	
	// Function to unlink all the dependent entities of the given Entity by Id
	function unlinkDependencies($module, $id) {
	
		$sql = 'DELETE FROM ld_activity_reminder WHERE activity_id=?';
		$this->db->pquery($sql, array($id));
		
		$sql = 'DELETE FROM ld_recurringevents WHERE activityid=?';
		$this->db->pquery($sql, array($id));

//		$sql = 'DELETE FROM ld_cntactivityrel WHERE activityid = ?';
//		$this->db->pquery($sql, array($id));
		
		parent::unlinkDependencies($module, $id);
	}
	
	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;
		if($return_module == 'Contacts') {
			//$sql = 'DELETE FROM ld_cntactivityrel WHERE contactid = ? AND activityid = ?';
            //$sql = 'DELETE FROM ld_seactivityrel WHERE crmid = ? AND activityid = ?';
			//$this->db->pquery($sql, array($return_id, $id));
			$sql = 'UPDATE ld_activity SET deleted = 1 WHERE activityid = ?;';
			$this->db->pquery($sql, array($id));
		} elseif($return_module == 'Accounts'){
			$sql = 'UPDATE ld_activity SET deleted = 1 WHERE activityid = ?;';
			$this->db->pquery($sql, array($id));
		} elseif($return_module == 'HelpDesk') {
			$sql = 'DELETE FROM ld_seactivityrel WHERE crmid = ? AND activityid = ?';
			$this->db->pquery($sql, array($return_id, $id));
		} else {
			$sql='DELETE FROM ld_seactivityrel WHERE activityid=?';
			$this->db->pquery($sql, array($id));
		
			$sql = 'DELETE FROM ld_crmentityrel WHERE (crmid=? AND relmodule=? AND relcrmid=?) OR (relcrmid=? AND module=? AND crmid=?)';
			$params = array($id, $return_module, $return_id, $id, $return_module, $return_id);
			$this->db->pquery($sql, $params);
		}
	}
	
	/**
	 * this function sets the status flag of activity to true or false depending on the status passed to it
	 * @param string $status - the status of the activity flag to set
	 * @return:: true if successful; false otherwise
	 */
	function setActivityReminder($status){
		global $adb;
		if($status == "on"){
			$flag = 0;
		}elseif($status == "off"){
			$flag = 1;
		}else{
			return false;
		}
		$sql = "update ld_activity_reminder_popup set status=1 where recordid=?";
		$adb->pquery($sql, array($this->id));
		return true;
	}

	/*
	 * Function to get the relation tables for related modules 
	 * @param - $secmodule secondary module name
	 * returns the array with table names and fieldnames storing relations between module and this module
	 */
	function setRelationTables($secmodule){
		$rel_tables = array (
//			"Contacts" => array("ld_cntactivityrel"=>array("activityid","contactid"),"ld_activity"=>"activityid"),
			"Leads" => array("ld_seactivityrel"=>array("activityid","crmid"),"ld_activity"=>"activityid"),
			"Accounts" => array("ld_seactivityrel"=>array("activityid","crmid"),"ld_activity"=>"activityid"),
			"Potentials" => array("ld_seactivityrel"=>array("activityid","crmid"),"ld_activity"=>"activityid"),
		);
		return $rel_tables[$secmodule];
	}
	

	
	public function getNonAdminAccessControlQuery($module, $user,$scope='') {
		require('user_privileges/user_privileges_'.$user->id.'.php');
		$query = ' ';
		$tabId = getTabid($module);
		$focus = CRMEntity::getInstance($module);
		$query.= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = $focus->table_name.$focus->table_index";
		return $query;
	}
/**
	 *
	 * @param <type> $user
	 * @param <type> $parentRole
	 * @param <type> $userGroups
	 */
	function getNonAdminUserAccessQuery($user, $parentRole, $userGroups) {
		$query = "(SELECT $user->id as id) UNION (SELECT ld_user2role.userid AS userid FROM " .
				"ld_user2role INNER JOIN ld_users ON ld_users.id=ld_user2role.userid " .
				"INNER JOIN ld_role ON ld_role.roleid=ld_user2role.roleid WHERE " .
				"ld_role.parentrole like '$parentRole::%')";
		if (count($userGroups) > 0) {
			$query .= " UNION (SELECT groupid FROM ld_groups where" .
					" groupid in (" . implode(",", $userGroups) . "))";
		}
		return $query;
	}

	/**
	 *
	 * @param <type> $module
	 * @param <type> $user
	 */
	function getNonAdminModuleAccessQuery($module, $user) {
		$tabId = getTabid($module);
		$sharingRuleInfoVariable = $module . '_share_read_permission';
		$sharingRuleInfo = $$sharingRuleInfoVariable;
		$sharedTabId = null;
		$query = '';
		if (!empty($sharingRuleInfo) && (count($sharingRuleInfo['ROLE']) > 0 ||
				count($sharingRuleInfo['GROUP']) > 0)) {
			$query = " (SELECT shareduserid FROM ld_tmp_read_user_sharing_per " .
					"WHERE userid=$user->id AND tabid=$tabId) UNION (SELECT " .
					"ld_tmp_read_group_sharing_per.sharedgroupid FROM " .
					"ld_tmp_read_group_sharing_per WHERE userid=$user->id AND tabid=$tabId)";
		}
		return $query;
	}
	protected function setupTemporaryTable($tableName, $tabId, $user, $parentRole, $userGroups) {
		$module = null;
		if (!empty($tabId)) {
			$module = getTabname($tabId);
		}
		$query = $this->getNonAdminAccessQuery($module, $user, $parentRole, $userGroups);
		$query = "create temporary table IF NOT EXISTS $tableName(id int(11) primary key, shared ".
			"int(1) default 0) ignore ".$query;
		$db = PearDatabase::getInstance();
		$result = $db->pquery($query, array());
		if(is_object($result)) {
			$query = "create temporary table IF NOT EXISTS $tableName(id int(11) primary key, shared ".
			"int(1) default 0) replace select 1, userid as id from ld_sharedcalendar where ".
			"sharedid = $user->id";
			$result = $db->pquery($query, array());
			if(is_object($result)) {
				return true;
			}
		}
		return false;
	}
    	/**
	 *
	 * @param <type> $module
	 * @param <type> $user
	 * @param <type> $parentRole
	 * @param <type> $userGroups
	 */
	function getNonAdminAccessQuery($module, $user, $parentRole, $userGroups) {
		$query = $this->getNonAdminUserAccessQuery($user, $parentRole, $userGroups);
		if (!empty($module)) {
			$moduleAccessQuery = $this->getNonAdminModuleAccessQuery($module, $user);
			if (!empty($moduleAccessQuery)) {
				$query .= " UNION $moduleAccessQuery";
			}
		}
		return $query;
	}
    function getDatetimeHtml($fieldname,$sql){
        $adb = $this->db;
        
        $Result=$adb->pquery($sql);
        $value='';
        if($adb->num_rows($Result) > 0)
        $value=$adb->query_result($Result,0);
        $dateValue = $value;
        $date='';
        $isPop=false;
		if ($dateValue == '' || empty($dateValue)||$dateValue == '0000-00-00 00:00:00') {
			$date = new DateTimeField(date('Y-m-d H:i'));

		} else {
	    	$date = new DateTimeField($value);
            $isPop=true;
		}
		$displayValue = $date->getDisplayDateTimeValue();
        
        
        $fieldvalue = array($displayValue,$isPop);
        return $fieldvalue;
    }
    
       function getContent($sql){
        $adb = $this->db;        
        $Result=$adb->pquery($sql);
        if($adb->num_rows($Result) > 0)
        $value=$adb->query_result($Result,0);
        return $value;
    }
    
    
    
    
    function getListQuery($module, $where = '') {
          $adb = $this->db; 
            $customview=CustomView::getInstance($module);
            $moduleobj=$this;
        	
        	$table_name = $moduleobj->table_name;
				    
           // $viewid=$customview->getViewId($module);
		  $cv_res = $adb->pquery("select cvid from ld_customview where viewname='All' and entitytype=?", array('Events'));
		  $viewid = $adb->query_result($cv_res,0,'cvid');
            $columnlist=$customview->getColumnsListByCvid($viewid);
           
            $fromclause="";
        	$ismodtable = array('ld_crmentity'=>'1','ld_accountbillads'=>'1',
        		'ld_accountshipads'=>'1','ld_contactaddress'=>'1','ld_contactsubdetails'=>'1');
        
            foreach($columnlist as $colmn)
            {
                 $arrcolumn=explode(":",$colmn);
        	   if(isset($ismodtable[strtolower($arrcolumn[0])])){
        				$arrcolumn[0] = $table_name;
        			 }
                $fromclause .=" ,".$arrcolumn[0].".".$arrcolumn[1];
            }
            if(strpos(strtolower($fromclause),'ld_activity.priority')<1){
        				$fromclause .= ',ld_activity.priority';
        			}
        			$query = "SELECT distinct ld_activity.activityid as act_id,ld_activity.eventstatus,ld_contactdetails.contactid, ld_activity.smownerid " .$fromclause .
        		 ",ld_activity.activityid as crmid FROM ld_activity
        		LEFT JOIN ld_activitycf
        			ON ld_activitycf.activityid = ld_activity.activityid
        		
        		LEFT JOIN ld_contactdetails
        			ON ld_contactdetails.contactid = ld_activity.contactid
        		LEFT JOIN ld_seactivityrel
        			ON ld_seactivityrel.activityid = ld_activity.activityid
        		LEFT OUTER JOIN ld_activity_reminder
        			ON ld_activity_reminder.activity_id = ld_activity.activityid
        		LEFT JOIN ld_users
        			ON ld_users.id = ld_activity.smownerid
        	
        		LEFT JOIN ld_users ld_users2
        			ON ld_activity.modifiedby = ld_users2.id
        	   left join ld_users as ld_users3
                ON ld_activity.smcreatorid = ld_users3.id
                left join ld_users as ld_users4
                ON ld_activity.approveby = ld_users4.id
        		LEFT OUTER JOIN ld_account
        			ON ld_account.accountid = ld_activity.accountid 
				left join ld_accountscf 
					on ld_accountscf.accountid = ld_account.accountid 
        	
        		LEFT OUTER JOIN ld_account ld_account2
        	        	ON ld_account2.accountid = ld_seactivityrel.crmid
        		LEFT OUTER JOIN ld_potential
        	       		ON ld_potential.potentialid = ld_activity.potentialid
        		LEFT OUTER JOIN ld_troubletickets
        	       		ON ld_troubletickets.ticketid = ld_seactivityrel.crmid
        		LEFT OUTER JOIN ld_salesorder
        			ON ld_salesorder.salesorderid = ld_seactivityrel.crmid
        		LEFT OUTER JOIN ld_purchaseorder
        			ON ld_purchaseorder.purchaseorderid = ld_seactivityrel.crmid
        		LEFT OUTER JOIN ld_quotes
        			ON ld_quotes.quoteid = ld_seactivityrel.crmid
        		LEFT OUTER JOIN ld_invoice
        	                ON ld_invoice.invoiceid = ld_seactivityrel.crmid
        		LEFT OUTER JOIN ld_campaign
        		ON ld_campaign.campaignid = ld_seactivityrel.crmid";
        
        			if (isset($_REQUEST['from_homepage']) && ($_REQUEST['from_homepage'] ==
        					"upcoming_activities" || $_REQUEST['from_homepage'] == "pending_activities")) {
        				$query.=" LEFT OUTER JOIN ld_recurringevents
        			             ON ld_recurringevents.activityid=ld_activity.activityid";
        			}
                    
                  if(isset($_REQUEST['type']) && $_REQUEST['type']=='alpbt')
                    {
                        $query .=" inner join  ld_cosler c on ((CONV(HEX(convert(left( ld_activity.";
                        $query .= $_REQUEST['search_field']." , 1) using gbk)),16,10) between c.cBegin and c.cEnd and f_PY like '".$_REQUEST['search_text']."%') or ld_activity.". $_REQUEST['search_field']." like '". $_REQUEST['search_text']."%') ";
                        
                    }
        			
        			$query.= " LEFT JOIN  ld_tabshare on ld_tabshare.crmid = ld_activity.activityid";
        			$query.=" WHERE ld_activity.deleted = 0 AND activitytype != 'Emails' " . $where;
                    
              return $query;
        }
        //editor:gyq_109 reason:日程管理模块  2019/4/30 16:33
        public function detail_block_news($r_data){
	        global $adb;
            $queryreminder="select  * from ld_activity_reminder where activity_id=? and email_remind !='0000-00-00 00:00:00'";
            $result=$adb->pquery($queryreminder,array($this->id));
            $num_rows=$adb->num_rows($result);

            if($num_rows){
                $all_result = $adb->query_result_all($result);
                foreach($all_result as $reminder){

                    $r_data['set_reminder'] =  getFixedLabel('YES');
                    $r_data['reminder_str'] = $reminder['email_remind'];
                }
            }
            else{
                $r_data['set_reminder'] =  getFixedLabel('NO');
            }
            $querypop="select * from ld_reminds where related_to=?";
            $result=$adb->pquery($querypop,array($this->id));
            $num_rows=$adb->num_rows($result);
            if($num_rows){
                $all_result = $adb->query_result_all($result);
                foreach($all_result as $pop){

                    $r_data['date_time'] =  getFixedLabel('YES');
                    $r_data['date_str'] = $pop['date_time'];
                }
            }
            else{
                $r_data['date_time'] =  getFixedLabel('NO');
            }

            $sql = 'select ld_users.*,ld_invitees.* from ld_invitees left join ld_users on ld_invitees.inviteeid=ld_users.id where activityid=?';
            $result = $adb->pquery($sql, array($this->id));
            $num_rows=$adb->num_rows($result);
            $invited_users=Array();
            $entity_field_info = getEntityFieldNames('Users');
            $fieldsName = $entity_field_info['fieldname'];
            for($i=0;$i<$num_rows;$i++)
            {
                $userid=$adb->query_result($result,$i,'inviteeid');
                $username =$adb->query_result($result,$i,$fieldsName);
                $invited_users[$userid]=$username;
            }
            $r_data['invited_users'] = $invited_users;

            /*循环日程*/
            $sql = "select ifnull(loop_type,'norepeat') as loop_type,loop_dayvalue,loop_month,loop_description,reminder_setting,reminder_description,expiredate from ld_loopcalendar_reminds where activityid = ? limit 1";
            $result = $adb->pquery($sql, array($this->id));
            $num_rows=$adb->num_rows($result);
            $loop_setting_info = ["loop_type"=>"norepeat"];
            if ($num_rows > 0) {
                $loop_setting_info['loop_type'] = $adb->query_result($result,$i,'loop_type');
                $loop_setting_info['loop_description'] = $adb->query_result($result,$i,'loop_description');
                $loop_setting_info['reminder_description'] = $adb->query_result($result,$i,'reminder_description');
                $loop_setting_info['loop_dayvalue'] = implode(',',explode(' |##| ',$adb->query_result($result,$i,'loop_dayvalue')));
                $loop_setting_info['loop_dayvalue_value'] = $adb->query_result($result,$i,'loop_dayvalue');
                $loop_setting_info['loop_month'] = implode(',',explode(' |##| ',$adb->query_result($result,$i,'loop_month')));
                $loop_setting_info['loop_month_value'] = $adb->query_result($result,$i,'loop_month');
                $loop_setting_info['reminder_setting'] = implode(',',explode(' |##| ',$adb->query_result($result,$i,'reminder_setting')));
                $loop_setting_info['reminder_setting_value'] = $adb->query_result($result,$i,'reminder_setting');
                $loop_setting_info['expiredate'] = $adb->query_result($result,$i,'expiredate');
            }
            $r_data['loop_setting_info'] = $loop_setting_info;
            return $r_data;
        }

    /*
 * 生成每天数据
 * */
    public function generateDataByDaily($item, $startdate, $enddate) {
        // 循环遍历起止日期之间的每一天，并将其加入到日期数组中
        $tmp_rangedate_arr = $this->getDatesInRange($startdate,$enddate);
        return $tmp_rangedate_arr;
    }
    public function generateDataByWeekly($item, $startdate, $enddate) {
        $loop_dayvalue = $item['loop_dayvalue'];
        if (empty($loop_dayvalue)) return [];
        $weekday_numbers = explode(' |##| ',$loop_dayvalue);
        $tmp_rangedate_arr = $this->getWeekdayDatesInRange($startdate,$enddate,$weekday_numbers);

        return $tmp_rangedate_arr;
    }

    /*
     * 生成每两周日期
     * 每两周应该从单据开始时间计算，开始时间所在的周日期，+14 days，直到当前面板
     * */
    public function generateDataByBiweekly($item, $startdate, $enddate, $date_start) {
        $loop_dayvalue = $item['loop_dayvalue'];
        if (empty($loop_dayvalue)) return [];
        $weekday_numbers = explode(' |##| ',$loop_dayvalue);
        $tmp_rangedate_arr = $this->getBiweeklyWeekdayDatesInRange($startdate,$enddate,$date_start,$weekday_numbers);

        return $tmp_rangedate_arr;
    }

    /*
     * 生成指定月份、日期的 日期
     * */
    public function generateDataByMonthly($item, $startdate, $enddate) {
        $loop_dayvalue = $item['loop_dayvalue'];
        $loop_month = $item['loop_month'];
        if (empty($loop_month) || empty($loop_dayvalue)) return [];

        $month_numbers = explode(' |##| ',$loop_month);
        $day_numbers = explode(' |##| ',$loop_dayvalue);

        $tmp_rangedate_arr = $this->getSpecifiedDatesInRange($startdate,$enddate,$month_numbers,$day_numbers);

        return $tmp_rangedate_arr;
    }
    /*
     * 计算两个日期之间有哪些日期
     * */
    public function getDatesInRange($startdate, $enddate) {
        $result = array();
        $start_date = strtotime($startdate);
        $end_date = strtotime($enddate);
        $current_date = $start_date;

        // 循环遍历起止日期之间的每一天，并将其加入到日期数组中
        while ($current_date <= $end_date) {
            $result[] = date('Y-m-d', $current_date);
            $current_date = strtotime('+1 day', $current_date);
        }

        return $result;
    }
    public function getWeekdayDatesInRange($startdate, $enddate, $weekday_numbers) {
        $result = array();

        $start_date = strtotime($startdate);
        $end_date = strtotime($enddate);
        $current_date = $start_date;

        while ($current_date <= $end_date) {
            $day_of_week = date('N', $current_date); // 获取星期几，1 表示周一，7 表示周日

            if (in_array($day_of_week, $weekday_numbers)) {
                $result[] = date('Y-m-d', $current_date);
            }

            $current_date = strtotime('+1 day', $current_date); // 增加一天
        }

        return $result;
    }

    public function getBiweeklyWeekdayDatesInRange($startdate, $enddate, $date_start, $weekday_numbers) {
        $result = array();
        $start_date = strtotime($startdate);
        $end_date = strtotime($enddate);
        $current_date = $start_date;

        /*while ($current_date <= $end_date) {
            // 获取当前日期是星期几
            $day_of_week = date('N', $current_date);

            // 如果是目标星期几，则将日期添加到结果数组中
            if (in_array($day_of_week, $weekday_numbers)) {
                $result[] = date('Y-m-d', $current_date);
            }

            if ($day_of_week == 7) {//循环到本周日后 跳一周
                $current_date = strtotime('+8 days', $current_date);
            }else
                $current_date = strtotime('+1 day', $current_date);// 增加一天

        }*/

        return $result;

    }
    public function getSpecifiedDatesInRange($startdate, $enddate, $month_numbers, $day_numbers) {
        $specifiedDates = array();

        //起止日期可能会跨年
        $tmp_years[] = date('Y',strtotime($startdate));//起止时间 年份
        $tmp_years[] = date('Y',strtotime($enddate));
        $tmp_years = array_unique($tmp_years);
        foreach ($tmp_years as $tmp_year) {
            foreach ($month_numbers as $tmp_month) {
                foreach ($day_numbers as $tmp_day) {
                    $tmp_ymd = "$tmp_year-$tmp_month-$tmp_day";
                    if ($tmp_day == 'lastday') {//最后一天
                        $tmp_ym = "$tmp_year-$tmp_month";
                        $specifiedDates[] = date("Y-m-t",strtotime($tmp_ym));
                    }else if ($this->isDateValid($tmp_ymd)) {//无效日期忽略
                        $specifiedDates[] = date("Y-m-d",strtotime($tmp_ymd));
                    }
                }
            }
        }

        return $specifiedDates;
    }
    /*
     * 计算起止时间段内 指定月份和指定日期  有哪些天
     * */
    public function getSpecifiedDatesInRange1($startdate, $enddate, $targetMonths, $targetDays) {
        $specifiedDates = array();

        $start_date = strtotime($startdate);
        $end_date = strtotime($enddate);
        $current_date = $start_date;

        while ($current_date <= $end_date) {
            $currentMonth = date('m', $current_date);
            $currentDay = date('d', $current_date);

            foreach ($targetMonths as $targetMonth) {
                foreach ($targetDays as $targetDay) {
                    if ($currentMonth == $targetMonth) {
                        if ($targetDay == 'lastday') {
                            $lastDayOfMonth = date('t', $current_date);
                            if ($currentDay == $lastDayOfMonth) {
                                $specifiedDates[] = date('Y-m-d', $current_date);
                            }
                        } else if($currentDay == $targetDay){
                            $specifiedDates[] = date('Y-m-d', $current_date);
                        }
                    }
                }
            }

            $current_date = strtotime('+1 day', $current_date);
        }

        return $specifiedDates;
    }

    /*
     * 找到当前日期月份的周几是哪些天  $week    N	ISO 8601 数字表示星期几	1（星期一）到 7（星期天）
     * */
    /*public function findAllWeekDate($year, $month, $week) {
        $weeks = array();
        $numDays = cal_days_in_month(CAL_GREGORIAN, $month, $year); // 获取当前月份的天数
        for ($day = 1; $day <= $numDays; $day++) {
            $date = strtotime("$year-$month-$day");
            if (date('N', $date) == $week) {
                $weeks[] = date('Y-m-d', $date);
            }
        }
        return $weeks;
    }*/

    //检查日期是否正确
    public function isDateValid($date) {
        $parsedDate = date_parse($date);
        return checkdate($parsedDate['month'], $parsedDate['day'], $parsedDate['year']);
    }
}
Activity::require_file();
?>