<?php
include_once('config.php');


class CustomForm24 extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
           globalStatic::$arr_module_require['CustomForm24']='CustomForm24';
          
            
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $log;
    var $db;
    var $table_name='ld_customform24';
    var $table_index='customform24id';
    var $table_code='customform24_no';//鐞涖劎绱崣宄扮摟濞?鐎光剝澹掓稉顓炵妇)
    var $tab_name=Array('ld_crmentity','ld_customform24','ld_customform24scf');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_customform24'=>'customform24id','ld_customform24scf'=>'customform24id');
   	var $customFieldTable = Array('ld_customform24scf', 'customform24id');//閼奉亜鐣炬稊澶婄摟濞堝灚澧嶇€涙ê鍋嶉惃鍕€?
	var $entity_table = "ld_crmentity";
    var $Detail_table="ld_customform24detail";//明细主表
    var $Detail_table_id="lineitem_id";//明细表主键
	var $Detail_table_scf = "ld_customform24detailscf";//明细自定义表
     var $Detail_table_index="id";//明细表和主表关联的字段名称
	var $column_fields = Array();
    var $module_name='CustomForm24';
    var $sortby_fields=Array('customform24_no');
    //缁狅紕鎮婂Ο鈥虫健
    var $relatedtab=array('accounts'=>'','salesorder'=>'','users'=>'','company'=>'','cashbill'=>'','customform24'=>'');
            
    var $list_link_field= 'customform24_no';
   	var $search_fields_name = Array();
    var $required_fields =  array();

//濮ｆ柨缍嶆い?
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'customform24_no');
	var $default_order_by = 'customform24_no';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="customform24_no";
    
    var $detailfieldobj;
    function __construct()
    {
	  // $this->log =LoggerManager::getLogger('CustomForm24');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('CustomForm24',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('CustomForm24');
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
        				$query = "update ld_customform24 set total = total*?,subtotal = subtotal*? where customform24id = ?";
        				$adb->pquery($query,array($conversion_rate,$conversion_rate,$this->id));
        				$query2payment = "update ld_customform24detail set amount = amount/? where id = ?";
        				$adb->pquery($query2payment,array($conversion_rate,$this->id));
        			}
        			else
        			{
        				$query = "update ld_customform24 set total = total/?*?,subtotal = subtotal/?*? where customform24id = ?";
        				$adb->pquery($query,array($becurrency_rate,$conversion_rate,$becurrency_rate,$conversion_rate,$this->id));
        				$query2payment = "update ld_customform24detail set amount = amount/?*? where id = ?";
        				$adb->pquery($query2payment,array($becurrency_rate,$conversion_rate,$this->id));
        			}
         }
    }
   	function save_module($module)
	{
        global $adb;
        $i=1;

        $account_version=getVersionInfo();
        if($account_version['account']=='baxter'){
            $this->addPendingOrder($this);
        }

      if($_REQUEST['action'] != 'CustomForm24Ajax' && $_REQUEST['ajaxaction'] != 'DETAILVIEW'
				&& $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
		{
		  
        }
        else
        {
            //閺屻儳婀呴悾宀勬桨閻ㄥ嫬鐨紓鏍帆閸滃本澹掗柌蹇庢叏閺€?
            return ;
        }
        
		//甯佺鏀瑰彉
		if($this->currency_status === true)
		{
			$update_query = "update ld_customform24 set currency_id=?, conversion_rate=?,currency_symbol=? where customform24_id=?";
			$update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],$this->column_fields['currency_symbol'], $this->id);
			$this->db->pquery($update_query, $update_params);
		}
         crm_load_class_file('cls_save_moduledetail','data');
         $obj=new cls_save_moduledetail($this->module_name,$this->id);
         
    
          $obj->Savedetail();


    }
    
    function getSourceField($fieldname,$recordid)
    {
        global $adb;
        return array();
        $sql = "select entitytype,entitytypeid from ld_customform242payment where customform24_id = ?";
        
        $result = $adb->pquery($sql,array($recordid));
        return $adb->query_result($result,0,0);
    }
    function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'Accounts'||$return_module=="SalesOrder"||$return_module=="PaymentPlan"|| $return_module == 'ServiceContracts'  ) {
			$this->trash('CustomForm24',$id);
		} 
	}
    

    function getCustomForm24Field($fieldname,$recordid)
    {
        global $adb;
        $sql = "select $fieldname from ld_customform24 where customform24_id = $recordid";
        $result = $adb->pquery($sql,array());
        return $adb->query_result($result,0,0);
    }

    //百特添加待处理单据
    function addPendingOrder($focus){
        global $adb;
        $query = "select cf_6208 from ld_customform24scf where customform24id=?";
        $result=$adb->pquery($query,array($focus->id));
        $nums=$adb->num_rows($result);
        if($nums>0){
            $sychScenario=$adb->query_result($result, 0, 'cf_6208');
        }

        $sql = "insert into baxter_yuntouxi(crmid,sychscenario) values(?,?)";
        $adb->pquery($sql,array($focus->id,$sychScenario));

    }
}
CustomForm24::require_file();
?>