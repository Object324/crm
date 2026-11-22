<?php




// Account is used to store ld_account information.
class Reminds extends CRMEntity {
    public $show_customview_num = 'no';// 是否显示消息页签("全部","未读")或分类对应的数量

    static  function require_file($requiremodules='')
    {
   
            globalStatic::$arr_module_require['Reminds']='Reminds';
            if(empty(globalStatic::$arr_module_require['Contacts']))
            {
                globalStatic::$arr_module_require['Contacts']='Contacts';
                include('modules/Contacts/Contacts.php');
                
            }
            if(empty(globalStatic::$arr_module_require['Potentials']))
            {
                globalStatic::$arr_module_require['Potentials']='Potentials';
                include('modules/Potentials/Potentials.php');
                
            }
            if(empty(globalStatic::$arr_module_require['Activity']))
            {
                 globalStatic::$arr_module_require['Activity']='Activity';
                include('modules/Calendar/Activity.php');
               
            }
            if(empty(globalStatic::$arr_module_require['Documents']))
            {
                globalStatic::$arr_module_require['Documents']='Documents';
                include('modules/Documents/Documents.php');
                
            }
            if(empty(globalStatic::$arr_module_require['Emails']))
            {
                globalStatic::$arr_module_require['Emails']='Emails';
                include('modules/Emails/Emails.php');
                
            }
            
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                include("modules/$requiremodules/$requiremodules.php");
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
            }
    }
    
	var $log;
	var $db;
	var $table_name = "ld_reminds";
	var $table_index= 'remindsid';//主表主键
	var $tab_name = Array('ld_crmentity','ld_reminds');
    
    //定义各个表主键
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_reminds'=>'remindsid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array();//自定义字段所存储的表
	var $entity_table = "ld_crmentity";

	var $column_fields = Array();

	var $sortby_fields = Array('date_start','time_start');
    var $module_name='Reminds';
    

	//var $groupTable = Array('lingdang_accountgrouprelation','accountid');

	// 叙事簿列头或者视图列头。include/util/listviewutils/getListviewHeader()中用到该变量
	var $list_fields = Array(
		'content'=>Array('ld_reminds'=>'content'),
		'related_to'=>Array('ld_reminds'=>'related_to'),
		'reltab'=>Array('ld_reminds'=>'reltab'),
		'date_time'=>Array('ld_reminds'=>'date_time'),
		'smcreatorid'=>Array('ld_reminds'=>'creator')
	);

	var $list_fields_name = Array(
			'content'=>'content',
			'related_to'=>'related_to'
			);
	var $list_link_field= 'content';

	var $search_fields = Array(
			'content'=>Array('ld_reminds'=>'content'),
			'related_to'=>Array('ld_reminds'=>'related_to')
			);

	var $search_fields_name = Array(
			'content'=>Array('ld_reminds'=>'content'),
			'related_to'=>Array('ld_reminds'=>'related_to')
			);
	// This is the list of lingdang_fields that are required
	var $required_fields =  array();

	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to ld_field.fieldname values.
    //比录项
	var $mandatory_fields = Array('createdtime');

	//Default Fields for Email Templates -- Pavani
	var $emailTemplate_defaultFields = array('content');

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'date_start';
	var $default_sort_order = 'desc';

	// For Alphabetical search
	var $def_basicsearch_col = 'content';
 
	function __construct() {
	
		$this->db = PearDatabase::getInstance();
		// $this->column_fields = getColumnFields('Reminds');
		$this->fieldobj = Field::getInstance('Reminds',$this->db);
		$this->column_fields = $this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('Reminds');
        $this->list_link_field=$entityname['fieldname'];
	}

	/** Function to handle module specific operations when saving a entity
	*/
	function save_module($module) {
	   global $current_user,$adb;
	   if($this->column_fields['reltab']!='')
       {
         
          $sql='update ld_reminds set reltab=? where remindsid=?';
          $adb->pquery($sql,array($this->column_fields['reltab'],$this->id));
       }
       else if($_REQUEST['related_to_type']!='')
       {
            $sql='update ld_reminds set reltab=? where remindsid=?';
            $adb->pquery($sql,array($_REQUEST['related_to_type'],$this->id));
       }

	   if($this->column_fields['remindstype'] != ''){
			$sql='update ld_reminds set remindstype=? where remindsid=?';
            $adb->pquery($sql,array($this->column_fields['remindstype'],$this->id));
	   }
        if($this->column_fields['wxremindstype']!= ''){
			$sql='update ld_reminds set wxremindstype=? where remindsid=?';
            $adb->pquery($sql,array($this->column_fields['wxremindstype'],$this->id));
	   }

        if ($this->mode == "create" && $_SERVER["REQUEST_METHOD"] == "POST" && $this->column_fields['date_time'] < date('Y-m-d H:i:s')) {
            $parent_id = $this->column_fields['related_to'];
            $reltab = $this->column_fields['reltab'];
            if (!empty($parent_id)) {
                $related_to_flag = 1;
                $parent_module = getSalesEntityType($parent_id);
                $valueTitle = $parent_module;
                $valueTitle = getTranstab($valueTitle);
                $displayValueArray = getEntityName($parent_module, $parent_id);
                if (!empty($displayValueArray)) {
                    foreach ($displayValueArray as $key => $value) {
                        $displayValue = $value;
                    }
                }
                $label_fld ="<a style='display:inline;' target='_blank' href='index.php?pageto_module=$parent_module&pageto_action=index&pageto_record=$parent_id' title='$valueTitle'>$displayValue</a>";
            }else{
                $related_to_flag = 0;
            }
            if($reltab!='ReportLog'&&!empty($reltab)&&$reltab!='CooperativeWork' && $reltab!='WorkReportList' )
            {
                $relfocus=CRMEntity::getInstance($reltab);
                if($relfocus )
                {//32501: 企业微信消息提醒
                    $listlinkfield=$relfocus->list_link_field;
                    $fieldlabel=$relfocus->fieldobj->getFieldInfoBykeyValue("fieldname",$listlinkfield,'fieldlabel');
                    $listlinkfieldlabel = $fieldlabel;
                    //wym 240604 BUG20240520-15 销售线索即将回收提醒，右上角弹窗中多了个编号字段
                    //相关对象为空时 不应该显示字段翻译 目前只有回收提醒有该情况,如果其他提醒不想隐藏,可以在sql中获取type值,筛选出只有回收提醒不显示
                    if(empty($parent_id)){
                        $listlinkfieldlabel = '';
                    }
                }
            }else{
                $listlinkfieldlabel = getTranstab($reltab);
                if ($reltab == 'CooperativeWork'){//工作汇报没有相关对象
                    $label_fld='';
                }
            }
           $message = array(
                $this->column_fields['recieverid'],
                $this->column_fields['content'],
                $current_user->last_name,
                $current_user->id,
                $this->column_fields['date_time'],
                $this->column_fields['remindsid'],
                $_SERVER['SCRIPT_NAME'],
                $listlinkfieldlabel,
                $label_fld,
                $related_to_flag
            );

            $key = 'ld_message';

            $encrypted_message = array_map(function($value) use ($key){
                return ld_php_secret($value, $key);
            }, $message);
            $serverDomain = $_SERVER['SERVER_NAME'];  // or $_SERVER['HTTP_HOST']
            $scheme = isset($_SERVER['HTTPS']) && $_SERVER['HTTPS'] === 'on' ? 'https' : 'http';
            $url = "$scheme://$serverDomain:5000/notify";

            $data = array('message' => $encrypted_message);

            $ch = curl_init();

            $api_key = 'lingdang20240617messagekey';

            // Set cURL options
            curl_setopt($ch, CURLOPT_URL, $url);
            curl_setopt($ch, CURLOPT_POST, true);
            curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($data));
            curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
            curl_setopt($ch, CURLOPT_HTTPHEADER, array(
                'Content-Type: application/json',
                'X-API-KEY: ' . $api_key
            ));

            curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);

        //    $result = curl_exec($ch);



        }


	}


	// Mike Crowe Mod --------------------------------------------------------Default ordering for us
	

	

	
    function saveReminds() {
        global $current_user,$adb;
        if($_REQUEST['module'] == 'Reminds' && isset($_REQUEST['recieverid'])){
            require_once(globalStatic::$root_directory.'include/fields/DateTimeField.php');
            foreach($this->column_fields as $fieldname => $val)
            {
                if(isset($_REQUEST[$fieldname]))
                {
                    if(is_array($_REQUEST[$fieldname]))
                        $value = $_REQUEST[$fieldname];
                    else
                        $value = trim($_REQUEST[$fieldname]);
                    if($fieldname=='date_time'){
                        $date = new DateTimeField($_REQUEST['date_time']);
                        $value=$date->getDBInsertDateTimeValue();
                        
                    }
                    
                    $this->column_fields[$fieldname] = $value;    
            
                }
            }
            if(!empty($_REQUEST['recieverid']))
            {
                /**
                 * 更新操作
                 * edit:can
                 * date:20131213
                 * reason:5872: 普通用户新增提醒后，设置多个提醒人，保存单据，结果单据上面的发送提醒人全部显示为admin。(可以用admin登录，然后在提醒->已发送里面查看)
                 *other:每一次new一个对象相当于新增页面，所以要给$current_user先赋值
                * */
                $curuserid=$current_user;
                $tmp_revs=explode(',',$_REQUEST['recieverid']);
                foreach($tmp_revs as $rev)
                {
                    // $focus = new Reminds();
                    $current_user=$curuserid;
                    if(isset($_REQUEST['record']))
                    {
                        $this->id = $_REQUEST['record'];
                    }
                    else{
                       // if(!isset($_REQUEST['record']))
                       // $sql_get='select max(orderid) from ld_reminds';
                      //  $sql_id = $adb->pquery($sql_get,array(),0);
                      //  $this->column_fields['orderid']=$sql_id[0]+1;
                    }
                    if(isset($_REQUEST['mode']))
                    {
                        $this->mode = $_REQUEST['mode'];
                    }

                    //zkt 20220428 【ID1002781】【审批、分配、共享等“消息提醒”标签修改为【模块】操作提醒（第一版）】
                    //新增提醒增加remindstype
                    $this->column_fields['remindstype'] = 'ModuleCreateRemind';
                    $this->column_fields['recieverid'] = $rev;
                    parent::save('Reminds');

                }
            }
        }else{
            parent::save('Reminds');
        }
    }
	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

	}

	function save_related_module($module, $crmid, $with_module, $with_crmids) {
		$adb = $this->db;

		if(!is_array($with_crmids)) $with_crmids = Array($with_crmids);
		foreach($with_crmids as $with_crmid) {
			if($with_module == 'Products')
				$adb->pquery("insert into ld_seproductsrel values(?,?,?)", array($crmid, $with_crmid, $module));
			elseif($with_module == 'Campaigns') {
				$checkResult = $adb->pquery('SELECT 1 FROM ld_campaignaccountrel WHERE campaignid = ? AND accountid = ?',
												array($with_crmid, $crmid));
				if($checkResult && $adb->num_rows($checkResult) > 0) {
					continue;
				}
				$adb->pquery("insert into ld_campaignaccountrel values(?,?,1)", array($with_crmid, $crmid));
			} else {
				parent::save_related_module($module, $crmid, $with_module, $with_crmid);
			}
		}
	}
    function setStatus($recordid,$type=1){
        if(empty($recordid)) return;
        global $current_user;
        $adb = $this->db;
        $sql="select recieverid from ld_reminds where remindsid='".$recordid."'";
        $res=$adb->pquery($sql);
        if($adb->num_rows($res)>0)
        {
            $senderid=$adb->query_result($res,0);
           if($type==1)
            $adb->pquery("update ld_reminds set status_rmd='已读',readedtime = now() where remindsid=".$recordid);
            else
            $adb->pquery("update ld_reminds set status_rmd='未读' where remindsid=".$recordid);
        }
        else{
            $sql="select recieverid from ld_reminds_accepted where remindsid='".$recordid."'";
             $res=$adb->pquery($sql);
             $senderid=$adb->query_result($res,0);
           if($type==1)
            $adb->pquery("update ld_reminds_accepted set status_rmd='已读',readedtime = now() where remindsid=".$recordid);
            else
            $adb->pquery("update ld_reminds_accepted set status_rmd='未读' where remindsid=".$recordid);
            
        }

         
    }

    
    function deleteRecord($recordid,$status=''){
        $adb = $this->db;
        if(!empty($status))
        {
            $sql="select group_concat(remindsid) from  ld_reminds where related_to='".$recordid."'  and status_rmd=? AND remindstype <> 'LoopCalendarCreateRemind'";
            
            $result=$adb->pquery($sql,array($status));
            if($adb->num_rows($result)>0)
            {
                $relatedtoids=$adb->query_result($result,0,0);
                if(!empty($relatedtoids)&&$relatedtoids!=',')
                    $adb->pquery(" delete from ld_crmentity where crmid in(select remindsid from ld_reminds where related_to='".$recordid."'  and status_rmd=? AND remindstype <> 'LoopCalendarCreateRemind')",array($status));
            }
             
             $adb->pquery("DELETE FROM ld_reminds where related_to='".$recordid."'  and status_rmd=? AND remindstype <> 'LoopCalendarCreateRemind'",array($status));
        }
        else
        
        $adb->pquery("DELETE FROM ld_reminds where related_to='".$recordid."' AND remindstype <> 'LoopCalendarCreateRemind'");
    }
    
    function DeleteEntity($returnmodule,$returnmodules,$focus,$recordid,$type){
		global $current_user;
        //033930: 企业微信>灵当CRM>客户明细界面（选择编号为66CON557的单据）>相关信息>提醒>删除其中的一条提醒：结果客户明细界面相关提醒模块的显示数字还是显示两条。
        if($_REQUEST['viewname']==115||$_REQUEST['return_viewname']==115)
		$query = "UPDATE ld_reminds set is_del_send=1,deleted=1 where remindsid=".$recordid;
        else
        $query = "UPDATE ld_reminds set is_del_rec=1,deleted=1 where remindsid=".$recordid;
		$this->db->pquery($query);
        //zkt 20220620 BUG0053005 	右上角的消息，有一部分的消息类型删除不了。提醒内容是：有新客户分配给您，敬请关注！这种的删除不成功。删除没反应。客户想要删除客户模块，发送人是郭晶晶的消息提醒。详情见附件。
        if($_REQUEST['viewname']==115||$_REQUEST['return_viewname']==115)
		$query = "UPDATE ld_reminds_accepted set is_del_send=1,deleted=1 where remindsid=".$recordid;
        else
        $query = "UPDATE ld_reminds_accepted set is_del_rec=1,deleted=1 where remindsid=".$recordid;
		$this->db->pquery($query);
    }
    //zkt 20220620 BUG0053005 	右上角的消息，有一部分的消息类型删除不了。提醒内容是：有新客户分配给您，敬请关注！这种的删除不成功。删除没反应。客户想要删除客户模块，发送人是郭晶晶的消息提醒。详情见附件。
     function mark_deleted($id) {
		global $current_user;
		$date_var = date('Y-m-d H:i:s',time());
		
		$query = 'update '.$this->table_name.' set deleted=1,modifiedtime=?,modifiedby=? where '.$this->table_index.' = ?;';
		$this->db->pquery($query, array($this->db->formatDate($date_var, true), $current_user->id, $id));
        
        $query = 'update ld_reminds_accepted set deleted=1,modifiedtime=?,modifiedby=? where '.$this->table_index.' = ?;';
        $this->db->pquery($query, array($this->db->formatDate($date_var, true), $current_user->id, $id));
        
	}
    
    function getRmdInfo($record){
        $adb = $this->db;
        $sql="select * from ld_reminds where is_del_send=0 and related_to=".$record;
        $res=$adb->pquery($sql);
        $rmd_rel=array();
        if(!empty($rmd_rel))
        $rmd_rel=$adb->query_result($res,0);
        return $rmd_rel;
    }
    
    function saveRemindsInfo($module,$return_id){
        global $adb;
        $this->deleteRecord($return_id);
        $rmd_rel=$this->getRmdInfo($return_id);
        if($module=='PaymentPlan')
        $dateField='plandate';
        else
        $dateField = 'date_time';
    	//$date = new DateTimeField($_REQUEST[$dateField]);
        //$this->column_fields['date_time']=$date->getDBInsertDateTimeValue();
        $this->column_fields['date_time']=date("Y-m-d H:i:s",strtotime($_REQUEST[$dateField]));
        
        if(!empty($rmd_rel) && $module=='PaymentPlan'){
            $this->column_fields['status_rmd']=$rmd_rel['status_rmd'];
            $this->id=$rmd_rel['remindsid'];
            $this->mode='edit';
        }elseif($module=='PaymentPlan' && empty($rmd_rel)){
            $this->column_fields['status_rmd']='未读';
            $this->column_fields['related_to']=$return_id;//关联单据id
            $this->column_fields['reltab']=$module;
            if($_REQUEST['account_name']=='')
            {
                $sql='select accountname from ld_account inner join  ld_paymentplan 
                    on ld_paymentplan.accountid=ld_account.accountid 
                     where ld_paymentplan.paymentplanid=?';
                 $result=$adb->pquery($sql,array($return_id));
                 if($adb->num_rows($result)>0)   
                 {
                    $_REQUEST['account_name']=$adb->query_result($result,0,0);
                    
                 } 
            }
            
            /**
             * edit:kevin
             * date:2013-10-10
             * reason:4311
             */ 
            $this->column_fields['content']=getTranstab('PaymentPlan')."到期，请及时催收！公司名称：".$_REQUEST['account_name']."，期次："
            .$_REQUEST['periodtime']."，金额：".$_REQUEST['amount'];
            $this->column_fields['recieverid']=$_REQUEST['assigned_user_id'];            
            $this->save('Reminds');
           
        }
        //17933: (新账套 192.168.1.169:85/crm)日采购管理>新增,关于设置提醒方式的问题
        //&&($_REQUEST['assigntype'] == 'U'||$_REQUEST['assigntype'] == 'US')
         if(isset($_REQUEST['pop_reminds'])&&$_REQUEST['pop_reminds']=='Yes'){             
           
            if(!empty($rmd_rel)){
                $this->column_fields['status_rmd']=$rmd_rel['status_rmd'];
                $this->id=$rmd_rel['remindsid'];
                $this->mode='edit';
            }
            else
            $this->column_fields['status_rmd']='未读';
            $this->column_fields['related_to']=$return_id;//关联单据id
            $this->column_fields['reltab']=$module;
       
            if($module=='ContactRecords'){
                $this->column_fields['recieverid']=$_REQUEST['assigned_user_id'];
                $this->column_fields['content']=$_REQUEST['content'];
                $this->save('Reminds');
            }
            else
            {
               $this->column_fields['content']=$_REQUEST['subject'];
                $inviteesid=$_REQUEST['inviteesid'];
                $invitees_array = explode(';',$inviteesid);
                foreach($invitees_array as $inviteeid){
                    if($inviteeid != ''){
                        $this->column_fields['recieverid']=$inviteeid;
                        $this->save('Reminds');
                    }
                }
                
                $this->column_fields['recieverid']=$_REQUEST['assigned_user_id'];
                $this->save('Reminds');
                
            }
        }elseif(($_REQUEST['pop_reminds']=='No'||$_REQUEST['pop_reminds']=='') && $module!='PaymentPlan'){          
            $this->deleteRecord($return_id);
        }
    }

   /*
    date：20130916
    reason:更多信息字段
    edit by chj
    
    function getRelated($Type)
    {
        global $adb,$current_user;
        require('user_privileges/user_language_'.$current_user->id.'.php');
       
        $tabid = getTabid('Reminds');
        $SqlField = "select tablename,fieldname,case when ifnull(ld_tranlabel.fieldlabel,'')=''then ld_field.fieldlabel else ld_tranlabel.fieldlabel end as fieldlabel
                 from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
              left join ld_relatedlists_lable  on ld_relatedlists_lable.fieldid=ld_field.fieldid
             where languagetype=? and trantable=? and ld_tranlabel.tabid=".$tabid." and ld_field.presence in (0,2)
			 and ld_field.displaytype in (1) order by ld_field.sequence";//ld_relatedlists_lable.presence=1 
        $result = $adb->pquery($SqlField,array($languageType,'ld_field'));
		$rows = $adb->num_rows($result);
        unset($this->list_fields);
        for($i=0;$i<$rows;$i++)
        {
            
            $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
                    "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
                );   
              $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";
               
            
        }
    }*/
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
    $query = 'SELECT 
							ld_reminds.remindsid as crmid,ld_reminds.* '.$fromclause.' 
						FROM
							ld_reminds 
						LEFT JOIN ld_users 
							ON ld_reminds.smownerid = ld_users.id ';
		   $query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_reminds.remindsid";
		   $query .= "  WHERE ld_reminds.deleted = 0 " . $where;
      return $query;
    }*/
}
Reminds::require_file();
?>