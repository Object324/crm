<?php


class ExpenseBudget extends CRMEntity
{
    static  function require_file($requiremodules='')
    {
           globalStatic::$arr_module_require['ExpenseBudget']='ExpenseBudget';
          
            
            if(!empty($requiremodules)&&empty(globalStatic::$arr_module_require[$requiremodules]))
            {
                globalStatic::$arr_module_require[$requiremodules]=$requiremodules;
                include("modules/$requiremodules/$requiremodules.php");
                
            }
    }
    var $log;
    var $db;
    var $table_name='ld_expensebudget';
    var $table_index='expensebudgetid';
    var $table_code='expensebudget_no';//鐞涖劎绱崣宄扮摟濞?鐎光剝澹掓稉顓炵妇)
    var $tab_name=Array('ld_crmentity','ld_expensebudget','ld_expensebudgetscf');
    var $tab_name_index=Array('ld_crmentity'=>'crmid','ld_expensebudget'=>'expensebudgetid','ld_expensebudgetscf'=>'expensebudgetid');
   	var $customFieldTable = Array('ld_expensebudgetscf', 'expensebudgetid');//閼奉亜鐣炬稊澶婄摟濞堝灚澧嶇€涙ê鍋嶉惃鍕€?
	var $entity_table = "ld_crmentity";
    var $Detail_table="ld_expensebudgetdetail";//明细主表
    var $Detail_table_id="lineitem_id";//明细表主键
	var $Detail_table_scf = "ld_expensebudgetdetailscf";//明细自定义表
     var $Detail_table_index="id";//明细表和主表关联的字段名称
	var $column_fields = Array();
    var $module_name='ExpenseBudget';
    var $sortby_fields=Array('expensebudget_no');
    //缁狅紕鎮婂Ο鈥虫健
    var $relatedtab=array('accounts'=>'','salesorder'=>'','users'=>'','company'=>'','cashbill'=>'','expensebudget'=>'');
            
    var $list_link_field= 'expensebudget_no';
   	var $search_fields_name = Array();
    var $required_fields =  array();

//濮ｆ柨缍嶆い?
	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime', 'expensebudget_no');
	var $default_order_by = 'expensebudget_no';
	var $default_sort_order = 'DESC';
    var $def_basicsearch_col="expensebudget_no";
    
    var $detailfieldobj;
    function __construct()
    {
	  // $this->log =LoggerManager::getLogger('ExpenseBudget');
		$this->db = PearDatabase::getInstance();
		$this->fieldobj=Field::getInstance('ExpenseBudget',$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
        $entityname=getEntitynameByModulename('ExpenseBudget');
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
        				$query = "update ld_expensebudget set total = total*?,subtotal = subtotal*? where expensebudgetid = ?";
        				$adb->pquery($query,array($conversion_rate,$conversion_rate,$this->id));
        				$query2payment = "update ld_expensebudgetdetail set amount = amount/? where id = ?";
        				$adb->pquery($query2payment,array($conversion_rate,$this->id));
        			}
        			else
        			{
        				$query = "update ld_expensebudget set total = total/?*?,subtotal = subtotal/?*? where expensebudgetid = ?";
        				$adb->pquery($query,array($becurrency_rate,$conversion_rate,$becurrency_rate,$conversion_rate,$this->id));
        				$query2payment = "update ld_expensebudgetdetail set amount = amount/?*? where id = ?";
        				$adb->pquery($query2payment,array($becurrency_rate,$conversion_rate,$this->id));
        			}
         }
    }
   	function save_module($module)
	{
        global $adb;
        $i=1;

      if($_REQUEST['action'] != 'ExpenseBudgetAjax' && $_REQUEST['ajaxaction'] != 'DETAILVIEW'
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
			$update_query = "update ld_expensebudget set currency_id=?, conversion_rate=?,currency_symbol=? where expensebudgetid=?";
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
        $sql = "select entitytype,entitytypeid from ld_expensebudgetdetail where lineitem_id = ?";
        
        $result = $adb->pquery($sql,array($recordid));
        return $adb->query_result($result,0,0);
    }
    function unlinkRelationship($id, $return_module, $return_id) {
		
		if(empty($return_module) || empty($return_id)) return;

		if($return_module == 'Accounts'||$return_module=="SalesOrder"||$return_module=="PaymentPlan"|| $return_module == 'ServiceContracts'  ) {
			$this->trash('ExpenseBudget',$id);
		} 
	}
    function getExpenseBudgetField($fieldname,$recordid)
    {
        global $adb;
        $sql = "select $fieldname from ld_expensebudget where expensebudgetid = $recordid";
        $result = $adb->pquery($sql,array());
        return $adb->query_result($result,0,0);
    }

    /***
     * @param $type
     * @param null $name
     * @param string $selectedValue
     * @param string[] $fields
     * @param string $cancelKeys
     * @param string $isopen
     * @return array
     * @throws Exception
     * 获取费用预算单 预算指标的下拉框值
     */
    function getExpenseBudgetTypePicklist($type,$name=null,$selectedValue='Paymentamount',$fields=['totalcolumnsid','name','columns','time_condition_field','time_condition_default','approved','type','sequence'],$cancelKeys='no',$isopen=""){
        //edit: xll 2023/08/11 XUQIU1001400 按销售目标预算改为动态读取设置的销售目标
        if($type == 'salesGoalBudget'){
            $picklistvalue = $this->getExpenseBudgetTypePicklist_SalesGoal($selectedValue,$fields,$cancelKeys);
            return $picklistvalue;
        }
        $sql = "select * from ld_expensebudget_totalcolumns where `type`=? ";
        if(!empty($isopen)&&$isopen=='yes'){
            $sql.=" and isopen='yes'";
        }
        $conditionArr = [$type];
        if(!empty($name)){
            $sql .= " and name=? ";
            $conditionArr[] = $name;
        }
        $sql .= " order by sequence asc";
        $res = $this->db->pquery($sql, $conditionArr);
        $nums = $this->db->num_rows($res);
        $picklist = [];
        if($nums>0){
            for($i=0;$i<$nums;$i++){
                $name = $this->db->query_result($res,$i,'name');
                $modulename = $this->db->query_result($res,$i,'modulename');
                if(!vtlib_isModuleActive($modulename)){
                    continue;
                }
                if(!isset($picklist[$name])){
                    $picklist[$name] = [];
                }else{
                    continue;
                }

                foreach($fields as $v){
                    $value = $this->db->query_result($res,$i,$v);
                    $picklist[$name][$v] = $value;
                    if($v=='name'&&$value==$selectedValue){
                        $picklist[$name]['selected'] = 'selected';
                    }
                    if($v=='translateName'){
                        $picklist[$name]['translateName'] = getFixedLabel($name);
                    }

                }
                if($cancelKeys=='yes'){
                    $picklist[$name] = array_values($picklist[$name]);
                }
                if(!isset($picklist[$name]['selected'])){
                    $picklist[$name][] = '';
                }
            }
        }
        return $picklist;
    }
    /***
     * AUTHOR:BY  xll
     * DATE: 2023/08/11
     * DESCRIPTION:动态读取销售目标，并处理为格式一致的下拉框值数组
     * param $selectedValue 选中的值
     */
    function getExpenseBudgetTypePicklist_SalesGoal($selectedValue,$fields,$cancelKeys){
        global $languageType;

        $selectedValue = $this->switchSelectedValue($selectedValue);

        crm_load_class_file('SalesGoalNew.class','modules/SalesGoal');
        $SalesGoalNewObj = new SalesGoalNew();
        $salesGoalList = $SalesGoalNewObj->getPermitSalesGoal('');
        $picklist = [];
        foreach ($salesGoalList as $key => $salesGoalInfo){
            $targetname = $salesGoalInfo['targetname'];
            foreach ($fields as $tmpfield){
                if($tmpfield == 'name'){
                    $tmpvalue = $targetname;
                    if($targetname == $selectedValue){
                        $picklist[$targetname]['selected'] = 'selected';
                    }
                }
                if($tmpfield == 'translateName'){
                    $tmpvalue = ($languageType == 'zh') ? $salesGoalInfo['zhlabel'] : $salesGoalInfo['enlabel'];
                }
                $picklist[$targetname][$tmpfield] = $tmpvalue;
            }
            if($cancelKeys=='yes'){
                $picklist[$targetname] = array_values($picklist[$targetname]);
            }
            if(!isset($picklist[$targetname]['selected'])){
                $picklist[$targetname][] = '';
            }
        }
        return $picklist;
    }
    /***
     * AUTHOR:BY  xll
     * DATE: 2023/08/11
     * DESCRIPTION:将旧销售目标指标转化为新销售目标指标
     * param $selectedValue 选中的值
     */
    function switchSelectedValue($selectedValue){
        $value = 'paymentamount';
        switch ($selectedValue) {
            case "ContractVolumeamount":
                $value = "contractamount";
                break;
            case "Invoicedamount":
                $value = "invoiceamount";
                break;
            case "Outboundorderamount":
                $value = "outboundorderamount";
                break;
            case "Paymentamount":
                $value = "paymentamount";
                break;
            default:
                $value = $selectedValue;
                break;
        }
        return $value;
    }


}
ExpenseBudget::require_file();
?>