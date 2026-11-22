<?php


class Campaigns extends CRMEntity {
    static  function require_file($requiremodules='')
    {
        
          globalStatic::$arr_module_require['Campaigns']='Campaigns';
            if(empty(globalStatic::$arr_module_require['Contacts']))
            {
                globalStatic::$arr_module_require['Contacts']='Contacts';
                include('modules/Contacts/Contacts.php');
                
            }
            
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }

    }
	var $log;
	var $db;
	var $table_name = "ld_campaign";
	var $table_index= 'campaignid';
    var $module_name='Campaigns';
	var $tab_name = Array('ld_crmentity','ld_campaign','ld_campaignscf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_campaign'=>'campaignid','ld_campaignscf'=>'campaignid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_campaignscf', 'campaignid');
	var $column_fields = Array();
    var $table_code='campaign_no';//审批中编号字段
	var $sortby_fields = Array('campaignname','smownerid','campaigntype','productname','expectedrevenue','closingdate','campaignstatus','expectedresponse','targetaudience','expectedcost');

    //管理模块
    var $relatedtab=array('campaigns'=>'','users'=>'','company'=>'');


	var $list_link_field= 'campaignname';
	//Added these variables which are used as default order by and sortorder in ListView
	var $default_order_by = 'campaignid';
	var $default_sort_order = 'DESC';

	//var $groupTable = Array('lingdang_campaigngrouprelation','campaignid');

	var $search_fields = Array(
			'Campaign Name'=>Array('ld_campaign'=>'campaignname'),
			'Campaign Type'=>Array('ld_campaign'=>'campaigntype'),
			);

	var $search_fields_name = Array(
			'Campaign Name'=>'campaignname',
			'Campaign Type'=>'campaigntype',
			);
	// Used when enabling/disabling the mandatory fields for the module.
	// Refers to lingdang_field.fieldname values.
	var $mandatory_fields = Array('createdtime' ,'modifiedtime','assigned_user_id');

	// For Alphabetical search
	var $def_basicsearch_col = 'campaignname';

	function __construct() 
	{
		//$this->log =LoggerManager::getLogger('campaign');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('Campaigns',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
  
        $entityname=getEntitynameByModulename('Campaigns');
        $this->list_link_field=$entityname['fieldname'];
	}

	/** Function to handle module specific operations when saving a entity
	*/
	function save_module($module)
	{
	   global $adb,$current_user;
       
	   /**********判断基金行业并且是凯银数据库时，同步积分 begin************/      
        
        /**
         * edit:diony
         * time:2014-12-08 
         * 凯银同步积分
         * 只有是编辑保存时，才会操作
        */        
        if($this->column_fields['mode']=='edit')
        {
            if(get_versiontrade()=='fund' && get_versionaccount()=='kylin')
            {
                $this->updateIntegral($this->id,1);    
            }
        }
        
        
        /**********判断基金行业并且是凯银数据库时，同步积分 end************/
	}
	/*
	 * Function populate the status columns' HTML
	 * @param - $related_list return value from GetRelatedList
	 * @param - $status_column index of the status column in the list.
	 * returns true on success
	 */
	function add_status_popup($related_list, $status_column = 7, $related_module = '')
	{
		global $adb;

		if(!$this->campaignrelstatus)
		{
			$result = $adb->query('SELECT * FROM ld_campaignrelstatus;');
			while($row = $adb->fetchByAssoc($result))
			{
				$this->campaignrelstatus[$row['campaignrelstatus']] = $row;
			}
		}
		foreach($related_list['entries'] as $key => &$entry)
		{
			$popupitemshtml = '';
			foreach($this->campaignrelstatus as $campaingrelstatus)
			{
				$camprelstatus = getTranslatedString($campaingrelstatus[campaignrelstatus],'Campaigns');
				$popupitemshtml .= "<a onmouseover=\"javascript: showBlock('campaignstatus_popup_$key')\" href=\"javascript:updateCampaignRelationStatus('$related_module', '".$this->id."', '$key', '$campaingrelstatus[campaignrelstatusid]', '".addslashes($camprelstatus)."');\">$camprelstatus</a><br />";
			}
			$popuphtml = '<div onmouseover="javascript:clearTimeout(statusPopupTimer);" onmouseout="javascript:closeStatusPopup(\'campaignstatus_popup_'.$key.'\');" style="margin-top: -14px; width: 200px;" id="campaignstatus_popup_'.$key.'" class="calAction"><div style="background-color: #FFFFFF; padding: 8px;">'.$popupitemshtml.'</div></div>';

			$entry[$status_column] = "<a href=\"javascript: showBlock('campaignstatus_popup_$key');\">[+]</a> <span id='campaignstatus_$key'>".$entry[$status_column]."</span>".$popuphtml;
		}

		return $related_list;
	}

	/*
	 * Function to get the secondary query part of a report
	 * @param - $module primary module name
	 * @param - $secmodule secondary module name
	 * returns the query string formed on fetching the related data for report for secondary module
	 
	function generateReportsSecQuery($module,$secmodule){
		$query = $this->getRelationQuery($module,$secmodule,"ld_campaign","campaignid");
		$query .=" left join ld_crmentity as ld_crmentityCampaigns on ld_crmentityCampaigns.crmid=ld_campaign.campaignid and ld_crmentityCampaigns.deleted=0
				left join ld_products as ld_productsCampaigns on ld_campaign.product_id = ld_productsCampaigns.productid
				left join ld_campaignscf on ld_campaignscf.campaignid = ld_crmentityCampaigns.crmid
				left join ld_groups as ld_groupsCampaigns on ld_groupsCampaigns.groupid = ld_crmentityCampaigns.smownerid
				left join ld_users as ld_usersCampaigns on ld_usersCampaigns.id = ld_crmentityCampaigns.smownerid
                left join ld_users as ld_lastModifiedByCampaigns on ld_lastModifiedByCampaigns.id = ld_crmentityCampaigns.modifiedby ";

		return $query;
	}*/

	/*
	 * Function to get the relation tables for related modules
	 * @param - $secmodule secondary module name
	 * returns the array with table names and fieldnames storing relations between module and this module
	 */
	function setRelationTables($secmodule){
		$rel_tables = array (
			"Contacts" => array("ld_campaigncontrel"=>array("campaignid","contactid"),"ld_campaign"=>"campaignid"),
			"Leads" => array("ld_campaignleadrel"=>array("campaignid","leadid"),"ld_campaign"=>"campaignid"),
			"Accounts" => array("ld_campaignaccountrel"=>array("campaignid","accountid"),"ld_campaign"=>"campaignid"),
			"Potentials" => array("ld_potential"=>array("campaignid","potentialid"),"ld_campaign"=>"campaignid"),
			"Calendar" => array("ld_seactivityrel"=>array("crmid","activityid"),"ld_campaign"=>"campaignid"),
			"Products" => array("ld_campaign"=>array("campaignid","product_id")),
		);
		return $rel_tables[$secmodule];
	}

	// Function to unlink an entity with given Id from another entity
	function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'Leads') {
			$sql = 'DELETE FROM ld_campaignleadrel WHERE campaignid=? AND leadid=?';
			$this->db->pquery($sql, array($id, $return_id));
		} elseif($return_module == 'Contacts') {
			$sql = 'DELETE FROM ld_campaigncontrel WHERE campaignid=? AND contactid=?';
			$this->db->pquery($sql, array($id, $return_id));
		} elseif($return_module == 'Accounts') {
			$sql = 'DELETE FROM ld_campaignaccountrel WHERE campaignid=? AND accountid=?';
			$this->db->pquery($sql, array($id, $return_id));
		} else {
			$sql = 'DELETE FROM ld_crmentityrel WHERE (crmid=? AND relmodule=? AND relcrmid=?) OR (relcrmid=? AND module=? AND crmid=?)';
			$params = array($id, $return_module, $return_id, $id, $return_module, $return_id);
			$this->db->pquery($sql, $params);
		}
	}

	function save_related_module($module, $crmid, $with_module, $with_crmids) {
		$adb = PearDatabase::getInstance();
        $integralAccountID = $with_crmids;
		if(!is_array($with_crmids)) $with_crmids = Array($with_crmids);
		foreach($with_crmids as $with_crmid) {
		  if($with_module == 'Contacts') {
				$checkResult = $adb->pquery('SELECT 1 FROM ld_campaigncontrel WHERE campaignid = ? AND contactid = ?',
												array($crmid, $with_crmid));
				if($checkResult && $adb->num_rows($checkResult) > 0) {
					continue;
				}
				$sql = 'INSERT INTO ld_campaigncontrel(campaignid,contactid,campaignrelstatusid) VALUES(?,?,1)';
				$adb->pquery($sql, array($crmid, $with_crmid));

			} elseif($with_module == 'Accounts') {
				$checkResult = $adb->pquery('SELECT 1 FROM ld_campaignaccountrel WHERE campaignid = ? AND accountid = ?',
												array($crmid, $with_crmid));
				if($checkResult && $adb->num_rows($checkResult) > 0) {
					continue;
				}
				$sql = 'INSERT INTO ld_campaignaccountrel(campaignid,accountid,campaignrelstatusid) VALUES(?,?,1)';
				$adb->pquery($sql, array($crmid, $with_crmid));

			} else {
				parent::save_related_module($module, $crmid, $with_module, $with_crmid);
			}
		}
        
        /**
        *diony
        *2014-12-09
        *同步保存时更新积分
        */
        if(get_versiontrade()=='fund')
        {
            if($with_module == 'Accounts')
            {
                CalculationIntegral($integralAccountID);
            }
            if($with_module == 'Accounts' && get_versionaccount()=='kylin')
            {
                $this->updateIntegral($crmid,2);
            }
        }
	}
    
    function updateIntegral($crmid,$type)
    {
        global $adb,$current_user;
       
	   /**********判断基金行业并且是凯银数据库时，同步积分 begin************/      
        
        /**
         * edit:diony
         * time:2014-12-08 
         * 凯银同步积分
         * 保存后选择客户更新积分
        */
        if($type == 1)
        {
            $title = $this->column_fields['campaignname'];//市场活动主题
            $timeline = strtotime($this->column_fields['startdate']);//CRM中的积分消费日期
            $field2 = $this->column_fields['consumedintegral'];//CRM中的消费积分
        }
        else if($type == 2) 
        {
             require(globalStatic::$root_directory.'include/trade/fund/kylin.php');
            $campaignsArr =project_kylin::getCampaignsbyIDforKY($crmid);
            $title = $campaignsArr['campaignname'];//市场活动主题
            $timeline = strtotime($campaignsArr['startdate']);//CRM中的积分消费日期
            $field2 = $campaignsArr['consumedintegral'];//CRM中的消费积分
        }
          
        require('user_privileges/kaiyinconfig.php');
        
        $con=mysql_connect($db_hostname_ky,$db_username_ky,$db_password_ky);
        mysql_query("set names 'utf8'",$con); 
        if(!$con){
            return;
        }
        
        $campaignid = $crmid;
        
        $campaignSql = "select campaignid,accountid from ld_campaignaccountrel where campaignid = ? ";
        $campaignResult = $adb->pquery($campaignSql,array($campaignid));
        $num_rows=$adb->num_rows($campaignResult);
        $arr=array();
        if($num_rows){
            for($i=0;$i<$num_rows;$i++)
            {
                $accountid = $adb->query_result($campaignResult,$i,"accountid");
                $accountname_ky = getModuleHref('Accounts',$accountid);          
                $account_check="select id,username from boc_users where username = '$accountname_ky' ";
                $result_accoount=mysql_db_query($db_database_ky,$account_check,$con);
                $num_rows_accoount=mysql_num_rows($result_accoount);
                if($num_rows_accoount)
                {
                    $accountid_ky = mysql_result($result_accoount,0,'id');
                    
                    $integration_check="select id from boc_integration where type_id = $accountid_ky and campaignid = $crmid ";
                    $result_integration=mysql_db_query($db_database_ky,$integration_check,$con);
                    $num_rows_integration=mysql_num_rows($result_integration);
                    if(!$num_rows_integration)
                    {
                        //没有，插入                                
                        //获取最大合同ID
                        $query_getintegrationID=" SELECT (max(id) + 1) as integrationid FROM boc_integration "; 
                        $result_getintegrationID=mysql_db_query($db_database_ky,$query_getintegrationID,$con);
                        //输出结果
                        if(mysql_num_rows($result_getintegrationID))
                        {
                            $integrationid_ky = mysql_result($result_getintegrationID,0,'integrationid');
                        }
                        //获取排序ID
                        $query_getsortID=" SELECT (max(sort_id) + 1) as sortID FROM boc_integration "; 
                        $result_getsortID=mysql_db_query($db_database_ky,$query_getsortID,$con);
                        //输出结果
                        if(mysql_num_rows($result_getsortID))
                        {
                            $sortid_ky = mysql_result($result_getsortID,0,'sortID');
                        }
                        
                        $integration_insert="INSERT INTO boc_integration (
                        id,sort_id,type_id,title,intro,content,timeline,expire,author,click,`show`,top,recommend,photo,
                        thumb,field1,field2,field3,expiration,campaignid) 
                        values 
                        ($integrationid_ky,$sortid_ky,$accountid_ky,'$title',null,null,'$timeline',null,null,0,1,0,0,null,
                        null,null,'$field2',null,null,$crmid)
                        ";
                        
                        mysql_db_query($db_database_ky,$integration_insert,$con);     
                    }
                    else
                    {
                        //有，修改
                        $id = mysql_result($result_integration,0,'id');               
            
                        $integration_update="UPDATE boc_integration set 
                    	title = '$productname',
                        timeline = '$timeline',
                        field2 = '$totalfiled2',
                        where id = $id 
                        ";
                        
                        mysql_db_query($db_database_ky,$integration_update,$con);
                    }
                }
            }
        }
        
        /**********判断基金行业并且是凯银数据库时，同步积分 end************/
    }
  /*
	
    function getListQuery($module, $where = '') {
        $query = "SELECT DISTINCT ld_campaign.*,ld_campaign.campaignid as crmid
			FROM ld_campaign 
			INNER JOIN ld_campaignscf
			        ON ld_campaign.campaignid = ld_campaignscf.campaignid
		
			LEFT JOIN ld_users
				ON ld_users.id = ld_campaign.smownerid
			LEFT JOIN ld_products
				ON ld_products.productid = ld_campaign.product_id";
            
        if(isset($_REQUEST['type']) && $_REQUEST['type']=='alpbt')
            {
                $query .=" inner join  ld_cosler c on ((CONV(HEX(convert(left( ld_campaign.";
                $query .= $_REQUEST['search_field']." , 1) using gbk)),16,10) between c.cBegin and c.cEnd and f_PY like '".$_REQUEST['search_text']."%') or ld_campaign.". $_REQUEST['search_field']." like '". $_REQUEST['search_text']."%') ";
                
            }
			$query .= " LEFT JOIN ld_tabshare on ld_tabshare.crmid = ld_campaign.campaignid";
			$query .= " WHERE ld_campaign.deleted = 0 " . $where;    
      return $query;
    }*/

}

Campaigns::require_file();
?>