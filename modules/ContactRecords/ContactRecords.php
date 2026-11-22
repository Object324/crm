<?php
/*
{*修改编码格式:统一编码：UTF-8*}
*/ 

class ContactRecords extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
           globalStatic::$arr_module_require['ContactRecords']='ContactRecords';
            if(empty(globalStatic::$arr_module_require['Emails']))
            {
                globalStatic::$arr_module_require['Emails']='Emails';
                include(globalStatic::$root_directory."modules/Emails/Emails.php");
                
            }
            if(empty(globalStatic::$arr_module_require['Potentials']))
            {
                globalStatic::$arr_module_require['Potentials']='Potentials';
                include(globalStatic::$root_directory."modules/Potentials/Potentials.php");
                
            }
            if(empty(globalStatic::$arr_module_require['Activity']))
            {
                globalStatic::$arr_module_require['Activity']='Activity';
                include(globalStatic::$root_directory."modules/Calendar/Activity.php");
                
            }
            if(empty(globalStatic::$arr_module_require['Documents']))
            {
                globalStatic::$arr_module_require['Documents']='Documents';
                include(globalStatic::$root_directory."modules/Documents/Documents.php");
                
            }
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include(globalStatic::$root_directory."modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $log;
    var $db;
    var $table_name='ld_contactrecords';
    var $table_index='contactrecordid';
    var $table_code='contactrecord_no';
    var $tab_name=Array('ld_crmentity','ld_contactrecords','ld_contactrecordscf');//'ld_cnContactRecordrel','ld_SeaContactRecord');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_contactrecords'=>'contactrecordid','ld_contactrecordscf'=>'contactrecordid');
   	var $customFieldTable = Array('ld_contactrecordscf', 'contactrecordid');//自定义字段所存储的表
	var $entity_table = "ld_crmentity";
	var $relatedtab=array('accounts'=>'','potentials'=>'','contacts'=>'','users'=>'','company'=>'','contactrecords'=>'','helpdesk'=>'','salesorder'=>'','project'=>'','projecttask'=>'');
	var $column_fields = Array();
    var $module_name='ContactRecords';
    var $sortby_fields=Array('contactrecordid,subject,contactdate,nextcontactdate');
    var $popup_fields = Array('subject');
    static $mass_before_focus=array();// 修改前客户ID或销售机会ID

    var $list_link_field= 'subject';

    var $search_fields_name = Array();

    var $required_fields =  array();

//比录项
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime');
	var $default_order_by = 'subject';
	var $default_sort_order = 'ASC';
    var $def_basicsearch_col="subject";
    public $before_save_infos;
    public $after_save_infos;
    function __construct()
    {
	  // $this->log =LoggerManager::getLogger('contactrecords');
		$this->db = PearDatabase::getInstance();
        	$this->fieldobj=Field::getInstance('ContactRecords',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        /**
         * edit:can
         * reason:动态创建序时簿超链接
         * */
        $entityname=getEntitynameByModulename('ContactRecords');
        $this->list_link_field=$entityname['fieldname'];
        $this->popup_fields=Array($this->list_link_field);
    }
   
    /** Function to handle module specific operations when saving a entity
     *reason: 更新客户的下次回访日期
     * edit by LD can
     * date:20130226
	*/
	function save_module($module) {
	   global $adb,$current_user;

        if($this->id>0)
        {
            $accountids = [];
            $potentialids = [];
            $leadsids = [];
            $contactids = [];
            foreach($this->before_field_info  as $fieldinfo)
            {
                //获取保存前客户或销售机会ID
                $columnname=$fieldinfo->getColumnName();//
                $relateid=$fieldinfo->getColumn_Value();
                if($columnname=='accountid'&&!empty($relateid))
                {
                    $accountids[$relateid]=$relateid;
                }
                if($columnname=='potentialid'&&!empty($relateid))
                {
                    $potentialids[$relateid]=$relateid;
                }
                if($columnname=='leads_id'&&!empty($relateid))
                {
                    $leadsids[$relateid]=$relateid;
                }
            } 
            if(!empty($this->column_fields['account_id'])){
              $accountids[$this->column_fields['account_id']] = $this->column_fields['account_id'];
            }           
            if(sizeof($accountids)>0) {
              $this->updateRelatedTableInfo('ld_account',$accountids);
            }

            if(!empty($this->column_fields['potential_id'])){
              $potentialids[$this->column_fields['potential_id']] = $this->column_fields['potential_id'];
            }
            if(sizeof($potentialids)>0) {
               $this->updateRelatedTableInfo('ld_potential',$potentialids);
            }

            if(!empty($this->column_fields['leads_id'])){
              $leadsids[$this->column_fields['leads_id']] = $this->column_fields['leads_id'];
            }
           
            if(is_array($leadsids)&& sizeof($leadsids)>0) {
               $this->updateRelatedTableInfo('ld_leads',$leadsids);
            }
            //hjz 获取保存时联系人的id
            if(!empty($this->column_fields['contact_id'])){
              $contactids[$this->column_fields['contact_id']] = $this->column_fields['contact_id'];
            }
           
            if(sizeof($contactids)>0) {
               $this->updateRelatedTableInfo('ld_contactdetails',$contactids);
            }
            

            //判断是否有录音文件，并插入或者修改录音文件信息
            $callButlerRemarks = "";
            if(isset($_REQUEST['callButlerRemarks']) && $_REQUEST['callButlerRemarks'] != '')
            {
                $callButlerRemarks = $_REQUEST['callButlerRemarks'];
            }
            if(isset($_REQUEST['callbutlername']) && $_REQUEST['callbutlername'] != '')
            {
                crm_load_class_file('cls_PhoneEncrypt','include');
                $obj=new cls_PhoneEncrypt();
                $callbutlername = $_REQUEST['callbutlername'];
               
                $one_callfiles=explode('\\',$callbutlername);
                $two_callfilename=$one_callfiles[sizeof($one_callfiles)-1];
                $callfilenames=explode('_',$two_callfilename);
                $callphone=$callfilenames[0];
                $restore_phone= $obj->Restore_Phone_token($callphone);
                for($i=0;$i<sizeof($one_callfiles)-1;$i++)
                 {
                    $filenames.=$one_callfiles[$i].'\\';
                 }
                $one_filenames=$filenames.$restore_phone.'_'.$callfilenames[1];
                
                $callbutlernameNew = str_replace("\\","\\\\",$one_filenames);    
                $callbutlernameNew = str_replace("\\","\\\\",$callbutlernameNew);
                $params[]=$current_user->id;
                $params[]=$restore_phone;
                $params[]=$this->id;
                
                 //if(isset($_REQUEST['calltype'])&&$_REQUEST['calltype']==1)
                 //{
                    $accountid=$this->column_fields['account_id'];
                    $contactid=$this->column_fields['contact_id'];
                    $params[]=$accountid;
                    $params[]=$contactid;
               //  }
                $callbutlerGetSql = "select id from ld_callbutler where soundrecordingfile like '$callbutlernameNew' ";
             // file_put_contents(globalStatic::$root_directory.'modules/ContactRecords/2.txt',$callbutlernameNew);
                $callbutlerGetResult=$adb->pquery($callbutlerGetSql);
                if($adb->num_rows($callbutlerGetResult))
                {
                    //存在
                    $callButlerID = $adb->query_result($callbutlerGetResult,0,'id');
                    
                  if(isset($_REQUEST['calltype'])&&$_REQUEST['calltype']==1)
                     {
                        //外拨
                         $sqlUpdate = "update ld_callbutler set userid=?, phone=?, contactrecordsid = ?,accountid=?,contactid=?,description = ? where id = ? ";
                     }
                     else
                     
                         $sqlUpdate = "update ld_callbutler set userid=?, phone=?, contactrecordsid = ?,accountid=?,contactid=? ,description = ? where id = ? ";
                    $params[]=$callButlerRemarks;
                    $params[]=$callButlerID;
                   
                    $updateResult=$adb->pquery($sqlUpdate,$params);


                }
                else
                {
                    //不存在
                    $sqlInsert = "insert into ld_callbutler 
                    (calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
                     accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,description) 
                    values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                    ";
                    $callbutlername = str_replace("\\\\","\\",$one_filenames);
					if($_REQUEST['calltype'] == 1){
						$calltype = '去电';
					}else{
						$calltype = '来电';
					}
                    if($_REQUEST['calltype'] == 1)
                    {
                         $insertresult=$adb->pquery($sqlInsert,array($calltype,$restore_phone,'接通',null,null,'',$callbutlername,$current_user->id,
                        $this->column_fields['account_id'],$this->column_fields['contact_id'],0,0,0,$this->id,0,$callButlerRemarks));
                    }
                    else
                        $insertresult=$adb->pquery($sqlInsert,array($calltype,$restore_phone,'接通',null,null,'',$callbutlername,$current_user->id,
                        0,0,0,0,0,$this->id,0,$callButlerRemarks));
                }
            }
            //九维 思孚 汉天 单据新增保存更新对应通话记录表
            if(isset($_REQUEST['jiuweiaccount'])&&isset($_REQUEST['callcenter_switch'])){
                crm_load_class_file('cls_UpdatePhoneRecord','CallCenter/lib');
                $obj=new cls_UpdatePhoneRecord($_REQUEST['jiuweiaccount'],$_REQUEST['callcenter_switch'],$this->id,$module);
                $obj->updatePhoneRecord();
            }

//           @edit:liushuai,2021-05-26,reason:【ID1001533】呼叫中心接口设置，增加接口类型“灵当语音盒”
            //灵当语音盒
           if(isset($_REQUEST['calltalkid']) && $_REQUEST['calltalkid'] != '')
           {
               $calltalkid = $_REQUEST['calltalkid'];

               $accountid = $this->column_fields['account_id'];
               $contactid = $this->column_fields['contact_id'];

               $callbutlerGetSql = "select id from ld_callbutler where talkid = ? and userid = ? ";
               $callbutlerGetResult=$adb->pquery($callbutlerGetSql, array($calltalkid, $current_user->id));
               if($adb->num_rows($callbutlerGetResult))
               {
                   //存在
                   $callButlerID = $adb->query_result($callbutlerGetResult,0,'id');

                   $sqlUpdate = "update ld_callbutler set contactrecordsid = ?,accountid = ?,contactid = ?,description = ? where id = ? ";
                   $updateResult=$adb->pquery($sqlUpdate,array($this->id,$accountid,$contactid,"",$callButlerID));

               }
               else
               {
                   //不存在
                   $sqlInsert = "insert into ld_callbutler 
                    (talkid,calltype,phone,status,begintime,endtime,time,soundrecordingfile,userid,
                     accountid,contactid,ticketid,vendorid,vendorcontactid,contactrecordsid,vendorcontactrecordsid,potentialid,description) 
                    values(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)
                    ";

                   if($_REQUEST['calltype'] == 1)
                   {
                       $insertresult=$adb->pquery($sqlInsert,array($calltalkid,'','','',null,null,'','',$current_user->id,
                           $accountid,$contactid,0,0,0,$this->id,0,0,''));
                   }
                   else
                       $insertresult=$adb->pquery($sqlInsert,array($calltalkid,'','','',null,null,'','',$current_user->id,
                           0,0,0,0,0,$this->id,0,0,''));
               }
           }
       }
       
       
       /**
         * edit:kevin
         * date:2013-07-22
         * reason:相关客户是否是已分配,分配则改变客户信息
         * 更新客户保护结束日期，
         */

        /*
       if(isset($_REQUEST['account_id'])){
           crm_load_class_file('Accounts','modules/Accounts');
           $account=new Accounts();
              
          $account->updateAccountInfo($module,$_REQUEST['account_id']);
          
        }
        */
       if($_REQUEST['file']=='DetailViewAjax'&&$_REQUEST['ajxaction']=='DETAILVIEW')
       {
            //查看界面的小编辑
            $_REQUEST[$_REQUEST['fldName']]=$_REQUEST['fieldValue'];
        
       }
        if($_REQUEST['rating']&&array_key_exists('rating',$this->column_fields))
          {
              //跟进记录模块关联客户中的“客户状态”
               // $rating=$_REQUEST['rating'];
                $sql='update ld_account inner join ld_contactrecords on ld_contactrecords.accountid=ld_account.accountid
                set ld_account.rating=ld_contactrecords.rating where ld_contactrecords.contactrecordid=?;';
                $adb->pquery($sql,array($this->id));
                
          }
        
        //跟进记录根据下次回访日期保存后增加回访提醒
        $this->ContactRecords_AddReminds();

	}
    function restore($module, $contactrecordid)
    {
        global $adb;
        parent::restore($module,$contactrecordid);
       
        if(array_key_exists("account_id",$this->column_fields)||array_key_exists("potential_id",$this->column_fields)||array_key_exists("leads_id",$this->column_fields))
        {
            $sql='select accountid,potentialid,leads_id from ld_contactrecords where contactrecordID=?';          
            $result=$adb->pquery($sql,array($contactrecordid));
            $accountid=$adb->query_result($result,0,'accountid');
            $potentialid=$adb->query_result($result,0,'potentialid');
            $leadsid=$adb->query_result($result,0,'leads_id');
        }
        
        if($accountid>0){
          $this->updateRelatedTableInfo('ld_account',array($accountid));        
        }
        if($potentialid>0){
          $this->updateRelatedTableInfo('ld_potential',array($potentialid));
        }
        if($leadsid>0){
          $this->updateRelatedTableInfo('ld_leads',array($leadsid));
        }
    }
     /**
     * 分配负责人，修改创建人
     * $type:操作类型:allocate,changecreator
     * */
    function massChangeUser_after($module,$ids,$type)
    {
        global $current_user,$adb;
         if(empty($ids)||$ids=='')
         {
            return ;
         }
         if(is_array($ids))
         {
            $ids=implode(',',$ids);
         }
        
         
        if(strtolower($type)=='allocate')
        {
             $accountidArr=array();
             if(array_key_exists('account_id',$this->column_fields))
              {
                $sql="select accountid from ld_contactrecords  where contactrecordID in($ids) group by accountid";
                $result=$adb->pquery($sql,array());
                for($i=0;$i<$adb->num_rows($result);$i++)
                {
                    $accountid=$adb->query_result($result,$i,'acountid');
                    if(!empty($accountid))
                     $accountidArr[]=$accountid;
                }
              }
              if(sizeof($accountidArr)>0)
                $this->updateRelatedTableInfo('ld_account', $accountidArr);
                
        }
    }
    
    /*
     * editor : gyq_02
     * function : 更新对应客户最新进度和最新联系日期，销售机会最新联系日期
     * date   : 2016  1  22
     * explain :
     * $relateids：更改前后的客户或销售机会ID数组
     *      $table : 待更新的数据表名，例如ld_account
     * */
    function updateRelatedTableInfo($table,$relateids)
    {
        global $adb;

        if(sizeof($relateids) > 0)
        {

            foreach($relateids as $accountid) {
                 if(empty($accountid))
                 {
                    continue;
                 }
                if ($table == 'ld_account')    $condition = " accountid=$accountid ";
                if ($table == 'ld_potential')  $condition = " potentialid=$accountid ";
                if ($table == 'ld_leads')  $condition = " leads_id=$accountid ";
                if ($table == 'ld_contactdetails')  $condition = " contactid=$accountid ";

                $sql = "SELECT
								content,
								contactdate,
								createdtime,
								nextcontactdate,
								smownerid
							FROM ld_contactrecords
							WHERE deleted = 0
								AND " . $condition . "
							ORDER BY
								ifnull(contactdate,createdtime) DESC,
								createdtime DESC limit 1";

                $result = $adb->pquery($sql);

                if ($adb->num_rows($result) > 0) {

                    $content = $adb->query_result($result, 0, 'content');
                    $contactdate = $adb->query_result($result, 0, 'contactdate');
                    $createdtime = $adb->query_result($result, 0, 'createdtime');
                   $nextcontactdate=$adb->query_result($result,0,'nextcontactdate');
                    $lastcontact = $adb->query_result($result, 0, 'smownerid');
                  
                    
                    $sql = "update $table set  ";

                    $update_params = array();

                    if ($contactdate != '' && $contactdate > '1600-01-01') {
                        $lastcontactdate = $contactdate;

                    } elseif ($createdtime != '' && $createdtime > '1600-01-01') {

                        $lastcontactdate = date('Y-m-d', strtotime($createdtime));

                    }

                    if ($lastcontactdate > 0) {

                        $sql .= ' lastcontactdate=?';

                        $update_params[] = $lastcontactdate;

                    }

//                    if (trim($content) != '' && ($table == 'ld_account' || $table == 'ld_leads')) {
                    // @edit:dong @date:2020/08/12 @reason: 【销售机会增加“未联系天数”和“最新进展”字段】
                    if (trim($content) != '' ) {
                        if (is_array($update_params) && sizeof($update_params) > 0) $sql .= ',';

                        $sql .= ' lastcontent=? ';

                        $update_params[] = vtlib_purify($content);

                    }

                    if ($nextcontactdate != '' && $nextcontactdate > '1600-01-01' && $table == 'ld_account') {

                        if (is_array($update_params) && sizeof($update_params) > 0) $sql .= ',';

                        $sql .= ' nextcontactdate=?';

                        $update_params[] = $nextcontactdate;

                    }

                    /*新增反写客户模块最新联系人，取联系记录负责人 */
                    if($lastcontact > 0 && $table != 'ld_leads' && $table != 'ld_contactdetails'){
                        if (is_array($update_params) && sizeof($update_params) > 0) 
                            $sql .= ',';

                        $sql .= ' lastcontactuser=?';
                        $update_params[] = $lastcontact;

                    }
                    // @edit:dong @date:2020/08/26 @reason: bug0042419 销售机会关联创建跟进记录保存后，没有更新“未联系天数”值
                    if($table == 'ld_potential' || $table == 'ld_contactdetails'){
                       // $nolinkdays=floor((time()-strtotime($lastcontactdate))/3600/24) ;
                       // if($nolinkdays<0) $nolinkdays=0;
                        //$sql .= ', nolinkdays='.$nolinkdays;
                    }

                    if (is_array($update_params) && sizeof($update_params) > 0) {
                        if ($table == 'ld_account'){
                          $sql .= ' where accountid=? ;';
                        }                            
                        else if ($table == 'ld_potential'){
                          $sql .= ' where potentialid=? ;';
                        }
                        else if ($table == 'ld_leads'){
                          $sql .= ' where leadsid=? ;';
                        }
                        else if ($table == 'ld_contactdetails'){
                          $sql .= ' where contactid=? ;';
                        }
                        $update_params[] = $accountid;
                        $adb->pquery($sql, $update_params);
                    }

                } else {
                        //如果客户或者销售机会没有相关联系记录，则清空客户或销售机会的相关字段
                    if ($table == 'ld_account') {

                        $sql = "update $table set lastcontactdate=?,lastcontent=?,lastcontactuser=? where accountid=? ";

                        $adb->pquery($sql, array(null, null,null, $accountid));
                    } 
                    elseif ($table == 'ld_potential') {
                        $sql = "update $table set lastcontactdate=? where potentialid=? ; ";

                        $adb->pquery($sql, array(null, $accountid));
                    }
                    elseif ($table == 'ld_leads') {
                        $sql = "update $table set lastcontactdate=?,lastcontent=? where leadsid=? ; ";

                        $adb->pquery($sql, array(null, null, $accountid));
                    }
                    elseif ($table == 'ld_contactdetails') {
                        $sql = "update $table set lastcontactdate=?,lastcontent=? where contactid=? ; ";

                        $adb->pquery($sql, array(null, null, $accountid));
                    }
                }
                if($table=='ld_leads')
                {
                    $sql="update ld_leads set nolinkdays=DATEDIFF(CURDATE(),IFNULL(lastcontactdate,DATE_FORMAT(createdtime,'%Y-%m-%d'))) where leadsid=?";
                    $adb->pquery($sql, array($accountid));
                }
				elseif($table=='ld_account')
				{
					//客户的未联系天数消触发器计算改用程序实现 add by luyx at 2022-11-11
                    $sql="update ld_account set nolinkdays=DATEDIFF(CURDATE(),IFNULL(lastcontactdate,DATE_FORMAT(createdtime,'%Y-%m-%d'))) where accountid=?";
                    $adb->pquery($sql, array($accountid));
				}
                elseif($table=='ld_potential')
				{
					//销售机会的未联系天数消触发器计算改用程序实现 add by luyx at 2022-11-11
                    $sql="update ld_potential set nolinkdays=DATEDIFF(CURDATE(),IFNULL(lastcontactdate,DATE_FORMAT(createdtime,'%Y-%m-%d'))) where potentialid=?";
                    $adb->pquery($sql, array($accountid));
				}
                elseif($table=='ld_contactdetails')
				{
					//销售机会的未联系天数消触发器计算改用程序实现 add by luyx at 2022-11-11
                    $sql="update ld_contactdetails set nolinkdays=DATEDIFF(CURDATE(),IFNULL(lastcontactdate,DATE_FORMAT(createdtime,'%Y-%m-%d'))) where contactid=?";
                    $adb->pquery($sql, array($accountid));
				}
            }


       }
       ContactRecords::$mass_before_focus=array();
    }

    /**
     * editor  : gyq_02
     * date    : 2016 1 26
     * explain : 批量编辑保存后处理
     *$ids : 被批量选择的记录ID数组，例如联系记录
     * */
    function massEdit_save_after($module,$ids)
    {

        $accountids = array();
        $potentialids = array();
        $leadsids = array();
        foreach( $ids as $contactrecord )
        {
            $ids_before= ContactRecords::$mass_before_focus[$contactrecord];
            $accountids[$ids_before['account_id']]=$ids_before['account_id'];
            $potentialids[$ids_before['potential_id']] = $ids_before['potential_id'];
            $leadsids[$ids_before['leads_id']] = $ids_before['leads_id'];
        }

        if(sizeof($ids)>0){
          if($_REQUEST['account_id_mass_edit_check']!=''){
            $accountids[$_REQUEST['account_id_mass_edit_check']]=$_REQUEST['account_id_mass_edit_check'] ;
          }
          if($_REQUEST['potential_id_mass_edit_check']!=''){
            $potentialids[$_REQUEST['potential_id_mass_edit_check']]=$_REQUEST['potential_id_mass_edit_check'] ;
          }
          if($_REQUEST['leads_id_mass_edit_check']!=''){
            $leadsids[$_REQUEST['leads_id_mass_edit_check']]=$_REQUEST['leads_id_mass_edit_check'] ;
          }
          if(sizeof($accountids) > 0){
            $this->updateRelatedTableInfo('ld_account',$accountids);
          }   
          if(sizeof($potentialids) > 0){
            $this->updateRelatedTableInfo('ld_potential',$potentialids);
          }
          if(sizeof($leadsids) > 0){
            $this->updateRelatedTableInfo('ld_leads',$leadsids);
          }
        }
        
    }

    /*
     * editor : gyq_02
     * explain : 批量操作保存前，以记录ID在$mass_before_focus中存储修改前信息
     * */
    function massEdit_save_before($module,$contactrecord)
    {
        ContactRecords::$mass_before_focus[$contactrecord[0]]=$this->column_fields;
    }

    /*
     * editor : gyq_02
     * explain : 批量删除后处理
     * */
    function massDelete_after($module,$ids)
    {
        $accountids = array();
        $potentialids = array();
        $leadsids = array();
        global $adb;
        $contactrecordids=implode(",",$ids);
        $sql='select accountid,potentialid,leads_id from ld_contactrecords where contactrecordid in (' .$contactrecordids.')';
        $result=$adb->pquery($sql,array());
        for( $i=0; $i<$adb->num_rows($result);$i++ )
        {
            $accountid=$adb->query_result($result,$i,'accountid');
            $potentid=$adb->query_result($result,$i,'potentialid');
            $leadsid=$adb->query_result($result,$i,'leads_id');
            if(!empty($accountid)){
              $accountids[$accountid]=$accountid;
            }
            if(!empty($potentid)){
              $potentialids[$potentid] = $potentid;
            }
            if(!empty($leadsid)){
              $leadsids[$leadsid] = $leadsid;
            }
        }

        if(sizeof($accountids)>0) {
            $this->updateRelatedTableInfo('ld_account', $accountids);
        }
        if(sizeof($potentialids) > 0){
            $this->updateRelatedTableInfo('ld_potential',$potentialids);
        }
        if(sizeof($leadsids) > 0){
            $this->updateRelatedTableInfo('ld_leads',$leadsids);
        }
    }


    /*
    Edit by LD Can
    date:20130205
    reason:删除联系记录以及和联系记录相关的业务信息
    */
	function unlinkRelationship($id, $return_module, $return_id){
		$this->trash('ContactRecords',$id);
		if(!empty($this->column_fields['account_id'])){
			$accountids[$this->column_fields['account_id']] = $this->column_fields['account_id'];
    }

		if(sizeof($accountids)>0) {
			$this->updateRelatedTableInfo('ld_account',$accountids);
		}

		if(!empty($this->column_fields['potential_id'])){
			$potentialids[$this->column_fields['potential_id']] = $this->column_fields['potential_id'];
    }
		if(sizeof($potentialids)>0) {
			$this->updateRelatedTableInfo('ld_potential',$potentialids);
		}

    if(!empty($this->column_fields['leads_id'])){
      $leadsids[$this->column_fields['leads_id']] = $this->column_fields['leads_id'];
    }
    if(sizeof($leadsids)>0) {
      $this->updateRelatedTableInfo('ld_leads',$leadsids);
    }		
  }
    
     //add by tifa 20130226 for reminds      
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
    
    function returnDatetime($sql){
        $adb = $this->db;        
        $Result=$adb->pquery($sql);
        if($adb->num_rows($Result) > 0)
        $value=$adb->query_result($Result,0);
        $dateValue = $value;
        $date='';
        $isPop='No';
		if ($dateValue == '' || empty($dateValue)) {
			$date = new DateTimeField(date('Y-m-d H:i'));

		} else {
	    	$date = new DateTimeField($value);
            $isPop='Yes';
		}
        $displayValue = $date->getDisplayDateTimeValue();
        $fieldvalue=array($isPop,$displayValue);
        return $fieldvalue;
    }
    
    function getContent($sql){
        $adb = $this->db;        
        $Result=$adb->pquery($sql);
        if($adb->num_rows($Result) > 0)
        $value=$adb->query_result($Result,0);
        return $value;
    }
    // 跟进记录根据下次回访日期保存后增加回访提醒
    //duan 2022-6-8 将pc端和移动端的代码整合到一起，并支持小编辑调用
    function ContactRecords_AddReminds(){
        global $current_user;
        $deployarray=getSys_deploy(462);
        //跟进记录是否启用回访提醒
        if($deployarray['deploy_value']==0){
            $contactdate = $this->column_fields['contactdate'];
            $nextcontactdate = $this->column_fields['nextcontactdate'];
            //首先判断回访日期和下次回访日期是否启用
            if(!empty($contactdate)&&!empty($nextcontactdate)){
                $beforenextcontactdate=$this->before_save_infos[0]['nextcontactdate'];
                //判断下次回访日期是否发生变化
                if($nextcontactdate != $beforenextcontactdate ){
                    $adb = $this->db;
                    //删除旧的回访提醒
                    $record = $this->id;
                    $sql="delete from ld_reminds where related_to=? and reltab=?  and content like '%".getFixedLabel('RETURNVISIT')."%' 
                                and (reminds_ruleid is null or reminds_ruleid=0)";
                    $adb->pquery($sql,array($record,$this->module_name));

                    $sql="delete from ld_reminds_accepted where related_to=? and reltab=?  and content like '%".getFixedLabel('RETURNVISIT')."%' 
                                and (reminds_ruleid is null or reminds_ruleid=0)";
                    $adb->pquery($sql,array($record,$this->module_name));

                    //判断跟进记录是否关联客户,以及回访日期是否小于下次回访日期
                    $accountid = $this->column_fields['account_id'];
                    if($accountid >0 && $contactdate <$nextcontactdate){

                        $sql = "select accountname from ld_account where accountid=?";
                        $accountname = $adb->query_result($adb->pquery($sql, array($accountid)),0,'accountname');
                        $RemindsContent=getFixedLabel('RETURNVISIT').gettranslabelfields('Accounts','accountname').'：'.$accountname;

                        //提醒接收人
                        if(!empty($this->column_fields['assigned_user_id'])){
                            $recieverid = $this->column_fields['assigned_user_id'];
                        }else{
                            $recieverid = $current_user->id;
                        }

                        $smownersql = "select * from ld_crmentity where crmid = ".$record;
                        $smownerresult = $adb->query($smownersql);
                        $setype = $adb->query_result($smownerresult,0,'setype');
                        $focus_rel =CRMEntity::getInstance('Reminds');
                        $focus_rel->column_fields['date_time'] = $nextcontactdate;
                        $focus_rel->column_fields['related_to']=$record;
                        $focus_rel->column_fields['reltab']=$setype;
                        //zxm  2021-0702 跟进记录提醒 设置个remindstype
                        $focus_rel->column_fields['remindstype']='ContactRecordsDate';
                        $focus_rel->column_fields['recieverid']=$recieverid;
                        //  $focus_rel->column_fields['wxremindstype']='immediately';
                        $focus_rel->column_fields['status_rmd']='未读';
                        $focus_rel->column_fields['content']=$RemindsContent;
                        $focus_rel->mode="create";
                        $focus_rel->save('Reminds');
                    }
                }
            }
        }
    }
    
    //重载删除单据方法
    public function trash($module, $record){
        parent::trash($module, $record);
        
        //跟进记录删除后，同步删除对应的回访提醒
        $adb = $this->db;
        $sql="delete from ld_reminds where related_to=? and reltab=?  and content like '%".getFixedLabel('RETURNVISIT')."%' 
                    and (reminds_ruleid is null or reminds_ruleid=0)";
        $adb->pquery($sql,array($record,$module));
        
        $sql="delete from ld_reminds_accepted where related_to=? and reltab=?  and content like '%".getFixedLabel('RETURNVISIT')."%' 
                    and (reminds_ruleid is null or reminds_ruleid=0)";
        $adb->pquery($sql,array($record,$module));
    }
    
	/*
    function get_CallButler($id, $cur_tab_id, $rel_tab_id, $actions=false) {
		global $adb;
		global $currentModule;
		global $list_max_entries_per_page_new_more;
        $root_dir_index= dirname(dirname(dirname(__FILE__)));
        require_once($root_dir_index.'/CallCenter/lib/jiuWei.php');
        $jiuObj = jiuWei::autoLoad();
        if($jiuObj->deploy_switch == 5 || $jiuObj->deploy_switch == 6 || $jiuObj->deploy_switch == 4){
            return $jiuObj->showCallRecords($id, $cur_tab_id, $rel_tab_id, $actions,'ContactRecords');
        }
        crm_load_class_file('fieldValueUitype','include/fields/');
        $sql = 'select T3.last_name,T1.begintime,T1.calltype,T1.phone,T1.`status`,T1.time,T1.soundrecordingfile   
        from ld_callbutler as T1 
        left join ld_contactrecords as T2 on  T1.contactrecordsid = T2.contactrecordID 
        left join ld_users as T3 on T1.userid = T3.id
        where T1.contactrecordsid > 0 and T1.contactrecordsid = '.$id;
        
        $count_result = $adb->query( mkCountQuery( $sql));
		$noofrows = $adb->query_result($count_result,0,'count');
		global $related_left_type;
		if($related_left_type == 3){//获取相关信息条数
			$related_entries = array();
			$related_entries['relcount'] = $noofrows;
			return $related_entries;
		}
		if(isset($_REQUEST['start']) && $_REQUEST['start'] != '') {
			$start = vtlib_purify($_REQUEST['start']);
			if($start == 'last'){
				if($noofrows > 0){
					$start = ceil($noofrows/$list_max_entries_per_page_new_more);
				}
			}
			if(!is_numeric($start)) $start = 1;
			elseif($start < 1) $start = 1;
			$start = ceil($start);
		}else{
			$start = 1;
		}
		global $related_left_start;
		$related_left_start = $start;
		$limstart=($start-1)*$list_max_entries_per_page_new_more;
		$sql .= ' LIMIT '.$limstart.','.$list_max_entries_per_page_new_more.' ';
        //用户、时间、类型、电话号码、状态、时长、操作
        //$header = array(getFixedLabel('USERS'),getFixedLabel('TIMES'),getFixedLabel('SERVICECONTRACTSTYPE'),getFixedLabel('PhoneNumber'),getFixedLabel('STATUS'),getFixedLabel('DURATION'),getFixedLabel('OPERATING'));
        $header = array(getFixedLabel('USERS'),getFixedLabel('TIMES'),getFixedLabel('SERVICECONTRACTSTYPE'),getFixedLabel('PhoneNumber'),getFixedLabel('DURATION'),getFixedLabel('OPERATING'));
        $result = $adb->pquery($sql,array());
        $num_rows=$adb->num_rows($result);
        if($num_rows>0)
        {
            for($i=0;$i<$num_rows;$i++)
            {
                $listview_entrie = array();
                $soundrecordingfile = $adb->query_result($result,$i,'soundrecordingfile');
                $soundrecordingfilenew = str_replace("\\","/",$soundrecordingfile);                

                $listview_entrie[]= $adb->query_result($result,$i,'last_name');
                $listview_entrie[]= $adb->query_result($result,$i,'begintime');
                $listview_entrie[]= $adb->query_result($result,$i,'calltype');
                $listview_entrie[]= fieldValueUitype::setReportMobileStyle($adb->query_result($result,$i,'phone'));
                //$listview_entrie[]= $adb->query_result($result,$i,'status');
               $time = $adb->query_result($result,$i,'time');
                $listview_entrie[]= $time;
				
				if(empty($time)){
					$listview_entrie[]= "";
				}else{
					$listview_entrie[]= "<a class='Anu3_a' onclick='play_click(this,\"".$soundrecordingfilenew."\")' href='###'>".getFixedLabel('PLAYER')."</a>";
				}
                $listview_entries[] = $listview_entrie;
            }
        }
		$navigationOutput = Array();$url_qry = '';
        crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
		$navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
		$navigationOutput[] =  getRecordRangeMessage($result, $limstart,$noofrows);
		$navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry,$currentModule,'CommunicationLog',$id);
        //print_r($listview_entries);
        $return_value = array('header'=>$header,'entries'=>$listview_entries,'navigation'=>$navigationOutput);
		return $return_value;
	}*/
    /*
    function getListQuery($module, $where = '') {
        $query="select distinct ld_contactrecords.*,ld_contactrecords.contactrecordid as crmid,ld_contactrecordscf.*,
                        ld_account.accountname FROM ld_contactrecords 
                        LEFT OUTER JOIN ld_account
			        ON ld_account.accountid = ld_contactrecords.accountid
			LEFT JOIN ld_contactdetails ON ld_contactdetails.contactid = ld_contactrecords.contactid
            LEFT JOIN ld_contactrecordscf on ld_contactrecordscf.contactrecordid = ld_contactrecords.contactrecordid 
            left join ld_vendor on ld_vendor.vendorid=ld_contactrecordscf.vendorid
            LEFT JOIN ld_users
				ON ld_users.id = ld_contactrecords.smownerid";
			$query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_contactrecords.contactrecordid";
			$query .= " WHERE ld_contactrecords.deleted = 0 " . $where;
            return $query;   
    }*/
}
ContactRecords::require_file();
?>