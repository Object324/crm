<?php


class PublicAnnouncement extends CRMEntity
{
    var $log;
    var $db;
    var $table_name = 'ld_publicannouncement';
    var $table_index = 'publicannouncementid';
    //var $table_code='commission_no';//表编号字段(审批中心)
    var $tab_name = Array('ld_crmentity', 'ld_publicannouncement', 'ld_receipts','ld_publicannouncementscf');
    var $tab_name_index = Array('ld_crmentity' => 'crmid', 'ld_publicannouncement' => 'publicannouncementid', 'ld_receipts' => 'id','ld_publicannouncementscf'=>'publicannouncementid');
    var $customFieldTable = Array('ld_publicannouncementscf', 'publicannouncementid');//自定义字段所存储的表
    var $entity_table = "ld_crmentity";
    var $module_name = 'PublicAnnouncement';
    var $column_fields = Array();
    //var $sortby_fields=Array('commission_no');
    //打印
    var $relatedtab = array('users' => '', 'company' => '', 'publicannouncement' => '');

    //var $list_link_field= 'cashbill_no';
    var $search_fields_name = Array();
    var $required_fields = array();

//比录项
    var $mandatory_fields = Array('type', 'startdate', 'enddate', 'recipient', 'content', 'smownerid');
    //var $default_order_by = 'commission_no';
    var $default_sort_order = 'DESC';
    var $def_basicsearch_col = "subject";//拼音查找字段，序时簿链接字段;

    function __construct()
    {
        //$this->log =LoggerManager::getLogger('PublicAnnouncement');
        $this->db = PearDatabase::getInstance();
        //$this->column_fields = getColumnFields('PublicAnnouncement',$this);
        $this->fieldobj = Field::getInstance('PublicAnnouncement', $this->db);
        $this->column_fields = $this->fieldobj->getFieldArray('fieldname', $this);
        $entityname = getEntitynameByModulename('PublicAnnouncement');
        $this->list_link_field = $entityname['fieldname'];
    }

    //20241223 jby XUQIU20241120-04 新建公告阅读状态
    function insertIntoReadingStatus($recipts_array)
    {
        global $adb;
        $insertsql = 'insert into ld_publicannouncement_readingstatus(publicannouncementid,recieverid) values ';
        foreach ($recipts_array as $tmpindex=> $recipts) {

            $insertsql .= ' ('.$this->id.','.$recipts.'),';
        }
        $adb->pquery(trim($insertsql,','), array());

    }

    //20241226 jby XUQIU20241120-04 进公告详情更新阅读状态
    function updatePublicAnnouncementStatus($recordid,$userid){
        global $adb;
        $updatesql = 'update ld_publicannouncement_readingstatus set reading_status="已读",readedtime = now() where deleted = 0 and publicannouncementid=? and recieverid=?';
        $adb->pquery($updatesql, array($recordid,$userid));
        //更新阅读状态字段已读未读人数
        $newStatus = '';
        $tmpquery = "select reading_status, COUNT(*) as nums from ld_publicannouncement_readingstatus where publicannouncementid=? and deleted=0 GROUP BY reading_status";
        $tmpresult = $adb->pquery($tmpquery, array($recordid));
        $tmprows = $adb->num_rows($tmpresult);

        if($tmprows==1){
            $tmpstatus = $adb->query_result($tmpresult, 0,'reading_status');
            if($tmpstatus=='未读'){
                $newStatus = '已读0 未读'.$adb->query_result($tmpresult, 0,'nums');
            }else{
                $newStatus = $adb->query_result($tmpresult, 0,'nums').'人全部已读';
            }
        }else if($tmprows==2){
            $newStatus = $adb->query_result($tmpresult, 0,'reading_status'). $adb->query_result($tmpresult, 0,'nums').' '.$adb->query_result($tmpresult, 1,'reading_status'). $adb->query_result($tmpresult, 1,'nums').' ';
        }
        $updateStatus = "update ld_publicannouncement set reading_status=? where publicannouncementid=?";
        $adb->pquery($updateStatus, array($newStatus,$recordid));
    }

    /**
     * uity242公告接收人字段另存在ld_receipts表中 1对多关系
     * by andy
     * date 20140715
     * verson v5.4
     */
    function insertIntoReceiptsTable($module, $fielid = '')
    {
        global $adb;
        $delsql = 'delete from ld_receipts where id = ? ';
        $adb->pquery($delsql, array($this->id));
        //print_r($this->column_fields);exit;
        $recipts_array = explode(',', $this->column_fields['recipient']);
        $insert = 'insert into ld_receipts(id,userid,setype) values ';
        
        foreach ($recipts_array as $tmpindex=> $recipts) {
           
              
                $insert .= ' ('.$this->id.','.$recipts.',"'.$module.'"),';
            
        }
        
        $adb->pquery(trim($insert,','), array());
          
    }

    //发送消息提醒
    function sendReminds($recipient_userid)
    {
        if(empty($recipient_userid)){
            return;
        }
        require_once(globalStatic::$root_directory . 'WeiXinApp/modules/Reminds/MessageCorpconversation.php');
        //$recipient_userid = explode(',', $this->column_fields['recipient']);
        $focus_rel = CRMEntity::getInstance('Reminds');
        $datetime = date("Y-m-d H:i:s");
        $receiverid_arr=[];
        foreach ($recipient_userid as $tmpindex=> $userid) {

            $focus_rel->id = 0;
            $focus_rel->column_fields['date_time'] = $datetime;
            $focus_rel->column_fields['related_to'] = $this->id;
            $focus_rel->column_fields['reltab'] = "PublicAnnouncement";

            $focus_rel->column_fields['recieverid'] = $userid;
            $focus_rel->column_fields['wxremindstype'] = 'immediately';
            $focus_rel->column_fields['status_rmd'] = '未读';
            $focus_rel->column_fields['content'] = $this->column_fields['content'];
            $focus_rel->mode = "create";
            $focus_rel->save('Reminds');
            $ids[] = $focus_rel->id;
            $receiverid_arr[]=$userid;
        }
        $remindcontent = $this->column_fields['content'];
        $setype = 'PublicAnnouncement';
        $record = $this->id;

        $r_multi_content = array(
            array(
                'received_id' => implode(",",$receiverid_arr),
                'message' => $remindcontent,
                'reltab' => $setype,
                'related_to' => $record,
                'date_time' => $datetime,
                'remindtype' => '',
                //zkt 20220428 【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
                'title' =>  '【' .getTranstab('PublicAnnouncement').'】'.getFixedLabel('TIXING'),
            )
        );
        //editor:gyq_165 reason:钉钉消息提醒类型,新增公告提醒   2019/12/24 13:20
        $remind = new MessageCorpconversation();
        $remind->sendAllTypeRemindsImmediately($ids, $r_multi_content);
        //zxm 20221116 公众号提醒消息单独请求--公告
        if($remind->judgeOffiaccount()=='yes'){
            $subject[$record]['subject'] = '【' .getTranstab('PublicAnnouncement').'】'.getFixedLabel('TIXING');
            $subject[$record]['time'] = $_REQUEST['startdate'].' 00:00:00';;
            $subject[$record]['module'] = 'PublicAnnouncement';
            require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_offiaccount.php");
            $offiaccount_remind = new cls_reminds_offiaccount();
            $offiaccount_remind->sendAllTypeRemindsImmediately($ids,'other',$subject);
        }

    }

    function save_module($module)
    {
        global $adb;
        if(isset($this->column_fields['recipient'])) {
            //2024-12-24 jby XUQIU20241120-04  修改公告已读/未读逻辑
            if (empty($this->mode) || $this->mode == 'create') //新增
            {
                $recipient_userid = explode(',', $this->column_fields['recipient']);

                $updateStatus = "update ld_publicannouncement set reading_status=? where publicannouncementid=?";
                $readStatus = '已读0 ' . '未读' . sizeof($recipient_userid);
                $adb->pquery($updateStatus, array($readStatus, $this->id));

                $this->insertIntoReadingStatus($recipient_userid);
                $this->sendReminds($recipient_userid);


            } else if ($this->mode == 'edit') //编辑
            {
                $precontent = '';
                if (isset($this->before_save_infos[0]['content'])) {
                    $precontent = $this->before_save_infos[0]['content'];
                }
                $remindcontent = isset($this->column_fields['content']) ? $this->column_fields['content'] : '';

                $recipient_userid = explode(',', $this->column_fields['recipient']);
                //原公告内容为空或者公告内容修改后,直接更新状态并发提醒
                if (empty($precontent) || $precontent != $remindcontent) {
                    $updatesql = 'update ld_publicannouncement_readingstatus set deleted=1 where publicannouncementid=?';
                    $adb->pquery($updatesql, array($this->id));

                    $updateStatus = "update ld_publicannouncement set reading_status=? where publicannouncementid=?";
                    $readStatus = '已读0 ' . '未读' . sizeof($recipient_userid);
                    $adb->pquery($updateStatus, array($readStatus, $this->id));

                    $this->insertIntoReadingStatus($recipient_userid);
                    $this->sendReminds($recipient_userid);
                } else {
                    $tmpsql = "select a.recieverid from ld_publicannouncement_readingstatus a WHERE a.deleted = 0 AND a.publicannouncementid = ?";
                    $tmpresult = $adb->pquery($tmpsql, array($this->id));

                    $tmp_remind_userid_arr = $recipient_userid;
                    $reminded_userid_arr = array();
                    $tmprows = $adb->num_rows($tmpresult);
                    if ($tmprows > 0) {
                        for ($i = 0; $i < $tmprows; $i++) {
                            $tmpreminduserid = $adb->query_result($tmpresult, $i, 'recieverid');
                            if (!in_array($tmpreminduserid, $tmp_remind_userid_arr)) {
                                $updatesql = 'update ld_publicannouncement_readingstatus set deleted=1 where publicannouncementid=? and recieverid=?';
                                $adb->pquery($updatesql, array($this->id, $tmpreminduserid));
                                //$tmp_index = array_keys($mon);
                            }
                            $reminded_userid_arr[] = $tmpreminduserid;
                        }
                    }

                    $no_remind_userid = array();
                    foreach ($recipient_userid as $index => $userid_value) {
                        if (empty($reminded_userid_arr) || !in_array($userid_value, $reminded_userid_arr)) {
                            $no_remind_userid[] = $userid_value;
                        }
                    }

                    if (!empty($no_remind_userid)) {
                        $recipient_userid = $no_remind_userid;
                        $this->insertIntoReadingStatus($recipient_userid);
                        $this->sendReminds($recipient_userid);
                    }

                    $newStatus = '';
                    $tmpquery = "select reading_status, COUNT(*) as nums from ld_publicannouncement_readingstatus where publicannouncementid=? and deleted=0 GROUP BY reading_status";
                    $tmpresult = $adb->pquery($tmpquery, array($this->id));
                    $tmprows = $adb->num_rows($tmpresult);

                    if($tmprows==1){
                        $tmpstatus = $adb->query_result($tmpresult,0,'reading_status');
                        if($tmpstatus=='未读'){
                            $newStatus = '已读0 未读'.$adb->query_result($tmpresult, 0,'nums');
                        }else{
                            $newStatus = $adb->query_result($tmpresult, 0,'nums').'人全部已读';
                        }
                    }else if($tmprows==2){
                        $newStatus = $adb->query_result($tmpresult,0,'reading_status'). $adb->query_result($tmpresult,0,'nums').' '.$adb->query_result($tmpresult,1,'reading_status'). $adb->query_result($tmpresult,1,'nums').' ';
                    }

                    $updateStatus = "update ld_publicannouncement set reading_status=? where publicannouncementid=?";
                    $adb->pquery($updateStatus, array($newStatus, $this->id));
                }


                /*
                $tmpsql = "select a.publicannouncementid,b.recieverid from ld_publicannouncement a
                            LEFT JOIN ld_reminds b ON a.publicannouncementid = b.related_to
                            LEFT JOIN ld_reminds_accepted c ON a.publicannouncementid = c.related_to
                            WHERE a.deleted = 0
                            and a.publicannouncementid = ?
                            AND CURDATE() BETWEEN startdate AND enddate;";

                $tmpresult = $adb->pquery($tmpsql,array($this->id));
                $tmp_remind_userid_arr = $recipient_userid;
                $reminded_userid_arr = array();
                $tmprows = $adb->num_rows($tmpresult);
                if($tmprows>0)
                {
                    for($i = 0; $i<$tmprows;$i++)
                    {
                        $tmpreminduserid = $adb->query_result($tmpresult,$i,'recieverid');
                        if(!in_array($tmpreminduserid,$tmp_remind_userid_arr))
                        {
                            $tmp_index = array_keys($mon);
                        }
                        $reminded_userid_arr[] = $tmpreminduserid;
                    }
                }
                $no_remind_userid = array();
                foreach($recipient_userid as $index=>$userid_value)
                {
                    if(empty($reminded_userid_arr)||!in_array($userid_value,$reminded_userid_arr))
                    {
                        $no_remind_userid[] = $userid_value;
                    }
                }
                if(!empty($no_remind_userid))
                {
                    //编辑公告时，未提醒的人员公告提醒应立即发送
                    require_once(globalStatic::$root_directory . 'WeiXinApp/modules/Reminds/MessageCorpconversation.php');
                    $recipient_userid = $no_remind_userid;
                    $focus_rel = CRMEntity::getInstance('Reminds');
                    $datetime = date("Y-m-d H:i:s");
                    foreach ($recipient_userid as $userid) {
                        $focus_rel->id = 0;
                        $focus_rel->column_fields['date_time'] = $datetime;
                        $focus_rel->column_fields['related_to'] = $this->id;
                        $focus_rel->column_fields['reltab'] = "PublicAnnouncement";

                        $focus_rel->column_fields['recieverid'] = $userid;
                        $focus_rel->column_fields['wxremindstype'] = 'immediately';
                        $focus_rel->column_fields['status_rmd'] = '未读';
                        $focus_rel->column_fields['content'] = $this->column_fields['content'];
                        $focus_rel->mode = "create";
                        $focus_rel->save('Reminds');
                        $ids[] = $focus_rel->id;
                    }
                    $remindcontent = $this->column_fields['content'];
                    $setype = 'PublicAnnouncement';
                    $record = $this->id;
                    $r_multi_content = array(
                        array(
                            'received_id' => $this->column_fields['recipient'],
                            'message' => $remindcontent,
                            'reltab' => $setype,
                            'related_to' => $record,
                            'date_time' => $datetime,
                            'remindtype' => '',
                            //zkt 20220428 【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
                            'title' =>  '【' .getTranstab('PublicAnnouncement').'】'.getFixedLabel('TIXING'),
                        )
                    );
                    //editor:gyq_165 reason:钉钉消息提醒类型,新增公告提醒   2019/12/24 13:20
                    $remind = new MessageCorpconversation();
                    $remind->sendAllTypeRemindsImmediately($ids, $r_multi_content);

                    //zxm 20221116 公众号提醒消息单独请求--公告
                    if($remind->judgeOffiaccount()=='yes'){
                        $subject[$record]['subject'] = '【' .getTranstab('PublicAnnouncement').'】'.getFixedLabel('TIXING');
                        $subject[$record]['time'] = $_REQUEST['startdate'].' 00:00:00';
                        $subject[$record]['module'] = 'PublicAnnouncement';
                        require_once(globalStatic::$root_directory."WeiXinApp/modules/Reminds/cls_reminds_offiaccount.php");
                        $offiaccount_remind = new cls_reminds_offiaccount();
                        $errorno = $offiaccount_remind->sendAllTypeRemindsImmediately($ids,'other',$subject);
                    }
                }*/


            }
        }
        /*生成公告提醒
		if(empty($this->mode)||$this->mode=='create'){//新增
			if(!empty($this->column_fields['recipient'])){
				$recipient_userid = explode(',', $this->column_fields['recipient']);
				for($i = 0; $i<count($recipient_userid); $i++){
					$query = 'insert into ld_publicannouncement_reminds(crmid,userid) values (?,?);';
					$adb->pquery($query,array($this->id,$recipient_userid[$i]));
				}
			}
		}else{//编辑
			//获取当前单据的公告提醒
			$query = 'select userid,presence from ld_publicannouncement_reminds where crmid = ?';
			$result = $adb->pquery($query,array($this->id));
			$num_rows = $adb->num_rows($result);
			if($num_rows > 0){
				//获取编辑之前公告单据的接受人
				for($i = 0; $i < $num_rows; $i++){
					$userid = $adb->query_result($result,$i,'userid');
					$before_recipient[$userid] = $adb->query_result($result,$i,'presence');
				}
				//直接删除编辑之前的公告提醒
				$adb->pquery('delete from ld_publicannouncement_reminds where crmid = ?',array($this->id));
				//判断编辑后的单据是否存在接受人
				if(!empty($this->column_fields['recipient'])){
					$recipient_array = explode(',', $this->column_fields['recipient']);
					foreach($recipient_array as $userid){
						if(isset($before_recipient[$userid])){
							$new_recipient[$userid] = $before_recipient[$userid];
						}else{
							$new_recipient[$userid] = 0;
						}
					}
					//重新插入编辑后的接受人公告提醒
					foreach($new_recipient as $userid => $presence){
						$query = 'insert into ld_publicannouncement_reminds(crmid,userid,presence) values (?,?,?);';
						$adb->pquery($query,array($this->id,$userid,$presence));
					}
				}
			}
		} */

    }

    function unlinkRelationship($id, $return_module, $return_id)
    {


    }

    //公告需求删除为彻底删除
    function trash($module, $record)
    {
        global $adb;
        //$sql="delete from ld_publicannouncement where publicannouncementid=?";
        foreach ($this->tab_name_index as $tablename => $tableindex) {
            $sql = 'delete from ' . $tablename . ' where ' . $tableindex . '=?';
            $adb->pquery($sql, array($record));
        }
        $sql='delete from ld_receipts where id=?';
        $adb->pquery($sql,array($record));

        $sql = 'delete from ld_publicannouncement_readingstatus where publicannouncementid=?';
        $adb->pquery($sql,array($record));

         //	公告删除后，界面没有刷新 BUG20240329-26 zxm 20240329 
        crm_load_class_file('cls_OperationLogs','modules/Settings/cls_OperationLogs');
        cls_OperationLogs::saveLogs($module,'Delete',$record,$_REQUEST);

    }

    /**
     * 增加getrelated方法
     * @reason 0010111 快速查找报新公告缺少方法
     * @author Tujt 2014-07-17
     *
     * function getRelated($Type)
     * {
     * global $adb,$current_user;
     * require('user_privileges/user_language_'.$current_user->id.'.php');
     *
     * $tabid = getTabid('PublicAnnouncement');
     * $SqlField = "select tablename,fieldname,case when ifnull(ld_tranlabel.fieldlabel,'')=''then ld_field.fieldlabel else ld_tranlabel.fieldlabel end as fieldlabel
     * from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
     * left join ld_relatedlists_lable  on ld_relatedlists_lable.fieldid=ld_field.fieldid
     * where languagetype=? and trantable=? and ld_tranlabel.tabid=".$tabid." and ld_field.presence in (0,2)
     * and ld_field.displaytype in (1) order by ld_field.sequence";//ld_relatedlists_lable.presence=1
     * $result = $adb->pquery($SqlField,array($languageType,'ld_field'));
     * $rows = $adb->num_rows($result);
     * for($i=0;$i<$rows;$i++)
     * {
     *
     * $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
     * "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
     * );
     * $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";
     *
     *
     * }
     * if($Type==1)
     * {
     * return $this->list_fields;
     * }
     * else
     * {
     * return $this->list_fields_name;
     * }
     *
     * } */
    

    //@edit:liushuai,2021-04-16,reason:【ID1001520】公告增加阅读数和阅读记录
    //公告-》阅读记录 - 条目数
    public function getReadRecordLogNum($record){
        global $adb, $current_user;

        $query = "select ld_users.wx_userid,ld_users.last_name,a.* from ld_publicannouncement_readingstatus a
        left join ld_users on ld_users.id=a.recieverid
        where a.publicannouncementid = ? and a.deleted = 0 and a.reading_status = '已读'";

        $result = $adb->pquery($query, array($record));
        $noofrows = $adb->num_rows($result);
        $return_value['relcount'] = $noofrows;
        return $return_value;
    }
    //公告-》阅读记录 默认已读
    public function getReadRecordLog($viewid, $module, $record, $tabid, $relationInfo){
        global $adb, $list_max_entries_per_page_new_more, $currentModule;
        global $current_user, $PlatformMC, $languageType;
        $label = $relationInfo['label'];
        $tabid = getTabid($module);
        $status = '已读';
        if ($viewid == 108) {
            $status = '未读'; //ALL
        } elseif ($viewid == 114) {
            $status = '已读'; //readen
        }else{
            $status = '';// 全部
        }

        $query = "select ld_users.wx_userid,ld_users.last_name,a.* from ld_publicannouncement_readingstatus a
        left join ld_users on ld_users.id=a.recieverid
        where a.publicannouncementid = ? and a.deleted = 0";
        /*
        $query = "select ld_users.wx_userid,ld_users.last_name,ld_reminds.* from ld_reminds
        left join ld_users on ld_users.id=ld_reminds.recieverid
        where related_to=? and is_del_rec=0 ";*/

        if(!empty($status)){
            $query .= " and a.reading_status = '$status' ";
        }

        $query .= " and recieverid is not null GROUP BY recieverid";
        $result = $adb->pquery($query, array($record));
        $noofrows = $adb->num_rows($result);
        //获取当前页数
        if (isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
            $start = $_REQUEST['start'];
            if ($start == 'last') {
                if ($noofrows > 0) {
                    $start = ceil($noofrows / $list_max_entries_per_page_new_more);
                }
            }
            if (!is_numeric($start)) $start = 1;
            elseif ($start < 1) $start = 1;
            $start = ceil($start);
        } else {
            $start = 1;
        }
        $filter['start'] = $start;
        //计算limit
        $limstart = ($start - 1) * $list_max_entries_per_page_new_more;
        if ($status == '已读') {
            $query .= " order by readedtime desc";
        }
        if (!empty($PlatformMC)) {
            $query .= ' limit 0,10';
        } else {
            $query .= ' LIMIT ' . $limstart . ',' . $list_max_entries_per_page_new_more . ' ';
        }
        //读取数据
        $result = $adb->pquery($query, array($record));
        $rows = $adb->num_rows($result);
        $header = array(
            'whodid' => getFixedLabel('Reader'),
            'changedon' => getFixedLabel('LatestReadingTime')
        );
        $entity = array();
        $navigationOutput = array();
        $url_qry = '';
        if ($rows > 0) {
            for ($i = 0; $i < $rows; $i++) {
//                $receiverid = $adb->query_result($result,$i,'recieverid');
                $readedtime = $adb->query_result($result, $i, 'readedtime');

                $userobj = new Users();
                $userobj->last_name = $adb->query_result($result, $i, "last_name");
                $userobj->wx_userid = $adb->query_result($result, $i, "wx_userid");
                $username = getUserlastName($userobj);

                $entity[$i]['username'] = $username;
                $entity[$i]['readedtime'] = $readedtime;

            }
            crm_load_function_file('VT_getSimpleNavigationValues', 'include/utils', 'ListViewUtils');
            $navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more, $noofrows);
            $navigationOutput[] = getRecordRangeMessage($result, $limstart, $noofrows);
            $navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry, $module, 'ModTrackerFldLog', $record);
            crm_load_function_file('getModuleFieldProportion', 'include/utils', 'ListViewUtils');
            $total_width = 0;
            $tmpwidth['fieldwidth']['username'] = getModuleFieldProportion(1);
            $tmpwidth['fieldwidth']['readedtime'] = getModuleFieldProportion(1);
            $tmp['headername']['columnname']['username'] = 'username';
            $tmp['headername']['columnname']['readedtime'] = 'readedtime';
            $tmp['headername']['fieldname']['username'] = 'username';
            $tmp['headername']['fieldname']['readedtime'] = 'readedtime';
            $widthinfo = getModuleWidth("", $tmpwidth['fieldwidth'], $currentModule);
            $tmpwidth['fieldwidth']['username'] = $widthinfo[0];
            $tmpwidth['fieldwidth']['readedtime'] = $widthinfo[2];
            foreach ($widthinfo as $tmp_width) {
                $total_width += $tmp_width;
            }
        }
        $publicAccountLogNum = $this->getReadRecordLogNum($record);
        $return_value = array('header' => $header, 'entries' => $entity, 'navigation' => $navigationOutput,
            'headername' => $tmp['headername'], 'fieldwidth' => $tmpwidth['fieldwidth'], 'total_width' => $total_width, 'noofrows' => $publicAccountLogNum['relcount'],
            'title' => getFixedLabel('RECORDSOFOPERATION'), 'filter' => $filter, 'lbl_none' => getFixedLabel('NONE'));

        return $return_value;
    }


    /*
    function getListQuery($module, $where = '') {

    $customview=CustomView::getInstance($module);
    $moduleobj=$this;
	
	$table_name = $moduleobj->table_name;

    $viewid=$customview->getViewId($module);
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
    $fromclause = str_replace('ld_publicannouncement.recipient','ld_receipts.receiptname as userid',$fromclause);
		    $query = 'SELECT 
							ld_publicannouncement.publicannouncementid as crmid,ld_publicannouncement.* '.$fromclause.' 
						FROM
							ld_publicannouncement 
						LEFT JOIN ld_users 
							ON ld_publicannouncement.smownerid = ld_users.id 
						LEFT JOIN 
						(SELECT 
							ld_receipts.id,
                            ld_users.id as userid,
							GROUP_CONCAT(ld_users.last_name) AS receiptname 
						FROM
							ld_receipts 
							LEFT JOIN ld_users 
								ON ld_users.id = ld_receipts.userid 
						GROUP BY ld_receipts.id) AS ld_receipts 
						ON ld_receipts.id = ld_publicannouncement.publicannouncementid ';
		   $query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_publicannouncement.publicannouncementid";
		   $query .= "  WHERE ld_publicannouncement.deleted = 0 " . $where;
         return  $query;
    }*/
}

?>