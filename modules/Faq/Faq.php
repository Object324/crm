<?php


	global $empty_string;
// Faq is used to store ld_faq information.
class Faq extends CRMEntity {
	var $log;
	var $db;
	var $table_name = "ld_faq";
	var $table_index= 'id';
	var $tab_name = Array('ld_crmentity','ld_faq','ld_faqscf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_faq'=>'id','ld_faqcomments'=>'faqid','ld_faqscf'=>'faqid');
	
    var $customFieldTable = Array('ld_faqscf', 'faqid');
    		
	var $entity_table = "ld_crmentity";

	//管理模块
    var $relatedtab=array('faq'=>'','users'=>'','company'=>'');
	
	var $column_fields = Array();
	 var $module_name='Faq';
	var $sortby_fields = Array('question','category','id');		

	// This is the list of lingdang_fields that are in the lists.
	/*var $list_fields = Array(
				'FAQ Id'=>Array('faq'=>'id'),
				'Question'=>Array('faq'=>'question'),
				'Category'=>Array('faq'=>'category'),
				'Product Name'=>Array('faq'=>'product_id'), 
				'Created Time'=>Array('crmentity'=>'createdtime'), 
				'Modified Time'=>Array('crmentity'=>'modifiedtime') 
				);
	
	var $list_fields_name = Array(
				        'FAQ Id'=>'',
				        'Question'=>'question',
				        'Category'=>'faqcategories',
				        'Product Name'=>'product_id',
						'Created Time'=>'createdtime',
						'Modified Time'=>'modifiedtime' 
				      );*/
	var $list_link_field= 'question';

	var $search_fields = Array(
				'Account Name'=>Array('account'=>'accountname'),
				'City'=>Array('accountbillads'=>'bill_city'), 
				);
	
	var $search_fields_name = Array(
				        'Account Name'=>'accountname',
				        'City'=>'bill_city',
				      );

	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'id';
	var $default_sort_order = 'DESC';

	var $mandatory_fields = Array('createdtime' ,'modifiedtime');

	// For Alphabetical search
	var $def_basicsearch_col = 'question';
	
	/**	Constructor which will set the column_fields in this object
	 */
	function __construct() {
		//$this->log =LoggerManager::getLogger('faq');
	//	$this->log->debug("Entering Faq() method ...");
		$this->db = PearDatabase::getInstance();
        $this->fieldobj=Field::getInstance('Faq',$this->db);
		$this->column_fields = $this->fieldobj->getFieldArray('fieldname',$this);
		$entityname=getEntitynameByModulename('Faq');
        $this->list_link_field=$entityname['fieldname'];
	}

	function save_module($module)
	{
		//Inserting into Faq comment table
		$this->insertIntoFAQCommentTable('ld_faqcomments', $module);
		
		$version_info = getVersionInfo();
		/* 赛克
		edit:chj
		date:2020/8/6
		reason:更新：点更新，在新标签页打开一个新建“工单处理和判责单”，保存后调用MIS接口回调结果到MIS系统，同时“工单主状态”为【保存】。并调用MIS接口回调结果到MIS系统。将操作作为日志记录工单修改日志。
		*/
		if($version_info['account'] == 'saic'){
			global $adb,$current_user;
			$query = 'select cf_2880,cf_2902,ld_accountscf.accountid from ld_accountscf LEFT JOIN ld_faq on ld_faq.accountid = ld_accountscf.accountid where id = ?';
			$result = $adb->pquery($query,array($this->id));
			$cf_2880 = $adb->query_result($result,0,'cf_2880');	//工单主状态
			$cf_2902 = $adb->query_result($result,0,'cf_2902');	//工单子状态
			$accountid = $adb->query_result($result,0,'accountid');	
			//获取判责单上处理人员对应的部门
			$query = 'select GROUP_CONCAT(groupname) as g_name from ld_groups where groupid in (select groupid from ld_faq LEFT JOIN ld_users on ld_users.id = ld_faq.smownerid where ld_faq.id = ?)';
			$result = $adb->pquery($query,array($this->id));
			$groupname = $adb->query_result($result,0,'g_name');	//部门名称
			//保存：当前服务人员对应的部门+“保存”；
			$groupname = $groupname . '提交';
			$query = 'update ld_accountscf LEFT JOIN ld_faq on ld_faq.accountid = ld_accountscf.accountid set cf_2880 = ?,cf_2902 = ? where id = ?';
			$adb->pquery($query,array('提交',$groupname,$this->id));
			if($cf_2880 != '提交'){
				$time = date('Y-m-d H:i:s',time());$status = 0;
				$id = $adb->getUniqueID('ld_modtracker_basic');
				$query = 'insert into ld_modtracker_basic(id,crmid,module,whodid,changedon,status) 
									values(?,?,?,?,?,?);';
				$adb->pquery($query,array($id,$accountid,'Accounts',$current_user->id,$time,$status));
				$query = 'insert into ld_modtracker_detail(id,fieldname,prevalue,postvalue) values(?,?,?,?);';
				$adb->pquery($query,array($id,'cf_2880',$cf_2880,'提交'));
			}
			if($cf_2902 != $groupname){
				$time = date('Y-m-d H:i:s',time());$status = 0;
				$id = $adb->getUniqueID('ld_modtracker_basic');
				$query = 'insert into ld_modtracker_basic(id,crmid,module,whodid,changedon,status) 
									values(?,?,?,?,?,?);';
				$adb->pquery($query,array($id,$accountid,'Accounts',$current_user->id,$time,$status));
				$query = 'insert into ld_modtracker_detail(id,fieldname,prevalue,postvalue) values(?,?,?,?);';
				$adb->pquery($query,array($id,'cf_2902',$cf_2902,$groupname));
			}
			crm_load_class_file('cls_saic_api','modules/Accounts');
			$cls_saic_api = new cls_saic_api();
			$cls_saic_api->saveOrderResult($accountid,2);	//2 未结案-保存
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
       
        $SqlField = "select tablename,fieldname,case when ifnull(ld_tranlabel.fieldlabel,'')=''then ld_field.fieldlabel else ld_tranlabel.fieldlabel end as fieldlabel
                 from ld_field inner join ld_tranlabel on ld_tranlabel.relateid=ld_field.fieldid
              inner join ld_relatedlists_lable  on ld_relatedlists_lable.fieldid=ld_field.fieldid
             where languagetype=? and trantable=? and ld_tranlabel.tabid=(select tabid from ld_tab where name=? ) and ld_relatedlists_lable.presence=1  order by ld_relatedlists_lable.sequence";
             
        $result = $adb->pquery($SqlField,array($languageType,'ld_field','Faq'));
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            
                $this->list_fields[$adb->query_result($result,$i,'fieldlabel')]= array(
                        "".$adb->query_result($result,$i,'tablename')."" => "".$adb->query_result($result,$i,'fieldname')."",
                    );   
                  $this->list_fields_name[$adb->query_result($result,$i,'fieldlabel')]= "".$adb->query_result($result,$i,'fieldname')."";
               
            
        }
    } */

	/** Function to insert values in lingdang_faqcomments table for the specified module,
  	  * @param $table_name -- table name:: Type varchar
  	  * @param $module -- module:: Type varchar
 	 */	
	function insertIntoFAQCommentTable($table_name, $module)
	{
	
        	global $adb;

        	$current_time = $adb->formatDate(date('Y-m-d H:i:s'), true);

		if($this->column_fields['comments'] != '')
			$comment = $this->column_fields['comments'];
		else
			$comment = $_REQUEST['comments'];

		if($comment != '')
		{
			$params = array('', $this->id, from_html($comment), $current_time);
			$sql = "insert into ld_faqcomments values(?, ?, ?, ?)";	
			$adb->pquery($sql, $params);
		}
	}	
	

	/**     Function to get the list of comments for the given FAQ id
         *      @param  int  $faqid - FAQ id
	 *      @return list $list - return the list of comments and comment informations as a html output where as these comments and comments informations will be formed in div tag.
        **/	
	function getFAQComments($faqid)
	{
		global  $default_charset;
		
		global $mod_strings;
		$sql = "select * from ld_faqcomments where faqid=?";
		$result = $this->db->pquery($sql, array($faqid));
		$noofrows = $this->db->num_rows($result);

		//In ajax save we should not add this div
		if($_REQUEST['action'] != 'FaqAjax')
		{
			$list .= '<div id="comments_div" style="overflow: auto;height:100px;width:100%;">';
			$enddiv = '</div>';
		}

		for($i=0;$i<$noofrows;$i++)
		{
			$comment = $this->db->query_result($result,$i,'comments');
			$createdtime = $this->db->query_result($result,$i,'createdtime');
			if($comment != '')
			{
				//this div is to display the comment
				if($_REQUEST['action'] == 'FaqAjax') {
					$comment = htmlentities($comment, ENT_QUOTES, $default_charset);
				}
				$list .= '<div valign="top" style="width:99%;padding-top:10px;" class="dataField">'.make_clickable(nl2br($comment)).'</div>';
				
				//this div is to display the created time
				$list .= '<div valign="top" style="width:99%;border-bottom:1px dotted #CCCCCC;padding-bottom:5px;" class="dataLabel"><font color=darkred>'.$mod_strings['Created Time'];
				$list .= ' : '.$createdtime.'</font></div>';
			}
		}

		$list .= $enddiv;
		return $list;
	}



	/*
	 * Function to get the relation tables for related modules 
	 * @param - $secmodule secondary module name
	 * returns the array with table names and fieldnames storing relations between module and this module
	 */
	function setRelationTables($secmodule){
		$rel_tables = array (
			"Documents" => array("ld_senotesrel"=>array("crmid","notesid"),"ld_faq"=>"id"),
		);
		return $rel_tables[$secmodule];
	}

	function clearSingletonSaveFields() {
		$this->column_fields['comments'] = '';
	}
	
    /*
    function getListQuery($module, $where = '') {

	
			$query = "SELECT distinct ld_faq.id as crmid ,ld_faq.* ".$fromclause .
				" FROM ld_faq 
				LEFT JOIN ld_products
					ON ld_faq.product_id = ld_products.productid";
				$query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_faq.id";
				$query .= " LEFT JOIN ld_users on ld_users.id = ld_faq.smownerid LEFT JOIN ld_faqscf on ld_faqscf.faqid = ld_faq.id";
				$query .= "  WHERE ld_faq.deleted = 0 " . $where;
			return $query;
    }*/
}
?>