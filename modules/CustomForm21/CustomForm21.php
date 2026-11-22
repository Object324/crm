<?php
include_once('config.php');


class CustomForm21 extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
           globalStatic::$arr_module_require['CustomForm21']='CustomForm21';
          
            
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $log;
    var $db;
    var $table_name='ld_customform21';
    var $table_index='customform21id';
    var $table_code='customform21_no';//琛ㄧ紪鍙峰瓧娈?瀹℃壒涓績)
    var $tab_name=Array('ld_crmentity','ld_customform21','ld_customform21scf');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_customform21'=>'customform21id','ld_customform21scf'=>'customform21id');
   	var $customFieldTable = Array('ld_customform21scf', 'customform21id');//鑷畾涔夊瓧娈垫墍瀛樺偍鐨勮〃
	var $entity_table = "ld_crmentity";
    var $Detail_table="ld_customform21detail";//明细主表
    var $Detail_table_id="lineitem_id";//明细表主键
	var $Detail_table_scf = "ld_customform21detailscf";//明细自定义表
     var $Detail_table_index="id";//明细表和主表关联的字段名称
	var $column_fields = Array();
    var $module_name='CustomForm21';
    var $sortby_fields=Array('customform21_no');
    //绠＄悊妯″潡
    var $relatedtab=array('accounts'=>'','salesorder'=>'','users'=>'','company'=>'','cashbill'=>'','customform21'=>'');
            
    var $list_link_field= 'customform21_no';
   	var $search_fields_name = Array();
    var $required_fields =  array();

//姣斿綍椤?
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'customform21_no');
	var $default_order_by = 'customform21_no';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="customform21_no";
    
    var $detailfieldobj;
    function __construct()
    {
	  // $this->log =LoggerManager::getLogger('CustomForm21');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('CustomForm21',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('CustomForm21');
        $this->list_link_field=$entityname['fieldname'];
        crm_load_class_file('TabDetailFields','include/TabDetailFields');
        $this->detailfieldobj=TabDetailFields::getInstance($this->module_name);
    }
	
    function massEdit_save_before($module,$ids)
    {
        
		global  $adb;
		$becurrency_id=$this->column_fields['currency_id'];
		parent::massEdit_save_before($module,$ids);
		if(isset($_REQUEST['currency_id_mass_edit_check'])&&$becurrency_id!=$_REQUEST['currency_id_mass_edit_check'])
		{
			
				$conversion_rate = $this->currencyobj->getCurrencyRate();
				$currency_symbol = $this->currencyobj->getCurrencySymbol();
				$becurrency_rate=$this->before_currencyobj->getCurrencyRate();
				
			   if($becurrency_id == 1)
				{
					$query = "update ld_customform21 set total = total*?,subtotal = subtotal*? where customform21id = ?";
					$adb->pquery($query,array($conversion_rate,$conversion_rate,$this->id));
					$query2payment = "update ld_customform21detail set amount = amount/? where id = ?";
					$adb->pquery($query2payment,array($conversion_rate,$this->id));
				}
				else
				{
					$query = "update ld_customform21 set total = total/?*?,subtotal = subtotal/?*? where customform21id = ?";
					$adb->pquery($query,array($becurrency_rate,$conversion_rate,$becurrency_rate,$conversion_rate,$this->id));
					$query2payment = "update ld_customform21detail set amount = amount/?*? where id = ?";
					$adb->pquery($query2payment,array($becurrency_rate,$conversion_rate,$this->id));
				}
		}
		$query = "update ld_customform21 set triggercount = triggercount+1 where customform21id = ?";
		$adb->pquery($query,array($this->id));
    }
   	function save_module($module)
	{
        global $adb;
        $i=1;

		if($_REQUEST['action'] != 'CustomForm21Ajax' && $_REQUEST['ajaxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
		  
        }
        else
        {
            //鏌ョ湅鐣岄潰鐨勫皬缂栬緫鍜屾壒閲忎慨鏀?
            return ;
        }
        
		//币种改变
		if($this->currency_status === true)
		{
			$update_query = "update ld_customform21 set currency_id=?, conversion_rate=?,currency_symbol=? where customform21_id=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}
		
        crm_load_class_file('cls_save_moduledetail','data');
        $obj=new cls_save_moduledetail($this->module_name,$this->id);
         
    
        $obj->Savedetail();
		
		$query = "update ld_customform21 set triggercount = triggercount+1 where customform21id = ?";
		$adb->pquery($query,array($this->id));  
    }
    
    function getSourceField($fieldname,$recordid)
    {
        global $adb;
        return array();
        $sql = "select entitytype,entitytypeid from ld_customform212payment where customform21_id = ?";
        
        $result = $adb->pquery($sql,array($recordid));
        return $adb->query_result($result,0,0);
    }
    function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'Accounts'||$return_module=="SalesOrder"||$return_module=="PaymentPlan"|| $return_module == 'ServiceContracts'  ) {
			$this->trash('CustomForm21',$id);
		} 
	}
    
   
    
  
    function getCustomForm21Field($fieldname,$recordid)
    {
        global $adb;
        $sql = "select $fieldname from ld_customform21 where customform21_id = $recordid";
        $result = $adb->pquery($sql,array());
        return $adb->query_result($result,0,0);
    }
    
	public function successApprove($crmid)
    {  
		global $adb;
		$version_info = getVersionInfo();
		//东贸：业绩查询结果通知:签到审批表（CustomForm21）审批通过后，将当前签到审批表信息推送给大巴车司机
        // 商贸批发小程序
		if($version_info['account'] == 'dongmao'&&$version_info['trade'] == 'dongmao'){
			$query = "select accountid,customform21_no,createdtime,ifnull(cf_4652,0) as cf_4652 from ld_customform21 
			LEFT JOIN ld_customform21scf on ld_customform21.customform21id = ld_customform21scf.customform21id 
			LEFT JOIN ld_customform21detail on ld_customform21detail.id = ld_customform21.customform21id 
			where ld_customform21.customform21id = ?";
			$result = $adb->pquery($query,array($crmid));
			$accountid = $adb->query_result($result,0,'accountid');
			$customform21_no = $adb->query_result($result,0,'customform21_no');
			$createdtime = $adb->query_result($result,0,'createdtime');
			$cf_4652 = $adb->query_result($result,0,'cf_4652');	//实际到达人数
			$num_rows = $adb->num_rows($result);	//扫码人数
			if(!empty($accountid)){
				$query = "select unionid,wechatuserid from ld_wechatuser where accountid = ? and deleted = 0";
				$result = $adb->pquery($query,array($accountid));
				$unionid = $adb->query_result($result,0,0);
				$query = "select open_id,wechatuserid from ld_wechatuser where unionid = ? and deleted = 0 and userfromvalue = 'offiaccount_dmgjsc'";
				$result = $adb->pquery($query,array($unionid));
				$num_rows = $adb->num_rows($result);
				//$commission = '扫码人数'.$num_rows.'，实际到达人数'.$cf_4652.'';
				$commission = '实际到达人数'.$cf_4652.'';
				if($num_rows >= 0){
					$open_id = $adb->query_result($result,0,'open_id');
					$wechatuserid = $adb->query_result($result,0,'wechatuserid');
					require_once (globalStatic::$root_directory.'include/weixinMsg/cls_DongmaoMessage.php');
					require_once (globalStatic::$root_directory.'include/weixinMsg/cls_DMmessageDefault.php');
					$dongmaoObj = new cls_DongmaoMessage();
					$dmMsgData = cls_DMmessageDefault::$DMmessageData['Commission'];
					$dmMsgPage = cls_DMmessageDefault::$DMmessageJump['Commission'];
                    // 兰总:oslAm0mRG-6xUXoeBJ7Xx23Tw7HI;王总:oslAm0ptw4yIccjwf1Ba920DXQ8E;邱小光:oslAm0pdy-Da_vZxBvL9oY90IpYI
                    // 兰总:177594;王总:178611;邱小光:121653
                    $open_id = 'oslAm0ptw4yIccjwf1Ba920DXQ8E';
                    $wechatuserid = 178611;
					$title = $dmMsgData['title'];
					$title = str_replace('单据编号',$customform21_no,$title);
					$data = array(
						'title' => $title,	
						'time' => date('Y年m月d日',strtotime($createdtime)),
						'commission' => $commission,
						'remark' => $dmMsgData['remark']
					);
					$dongmaoObj->send('Commission',$open_id,$dmMsgPage['page'],$data,$wechatuserid,'CustomForm21',$crmid,$dmMsgPage['pageType'],$accountid);
				}
			}
		}
		
	}
}
CustomForm21::require_file();
?>