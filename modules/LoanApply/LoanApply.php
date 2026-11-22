<?php
class LoanApply extends CRMEntity
{
    
   var $table_name = "ld_loanapply";
	var $table_index= 'loanapplyid';
    var $table_code='loanapply_no';//表编号字段(审批中心)
	var $tab_name = Array('ld_crmentity','ld_loanapply','ld_loanapplyscf');
	var $tab_name_index = Array('ld_crmentity'=>'crmid','ld_loanapply'=>'loanapplyid','ld_loanapplyscf'=>'loanapplyid');
	/**
	 * Mandatory table for supporting custom fields.
	 */
	var $customFieldTable = Array('ld_loanapplyscf', 'loanapplyid');
    //	//关联模块
    var $relatedtab=array('accounts'=>'','users'=>'','company'=>'','loanapply'=>'');
	var $column_fields = Array();
     var $module_name='LoanApply';
     var $moduleName='LoanApply';
	//Pavani: Assign value to entity_table
        var $entity_table = "ld_crmentity";

	var $sortby_fields = Array();


	var $list_link_field= 'loanapply_no';

    var $required_fields =  array();

	var $mandatory_fields = Array('assigned_user_id', 'createdtime', 'modifiedtime');
        var $default_order_by = 'loanapply_no';
        var $default_sort_order = 'DESC';

	
	var $def_basicsearch_col = 'loanapply_no';
    public $firstname;
	public $lastname;
	function __construct()
	{
	
		$this->db = PearDatabase::getInstance();
		 $this->fieldobj=Field::getInstance($this->module_name,$this->db);
		$this->column_fields =$this->fieldobj->getFieldArray('fieldname',$this);
      

        $entityname=getEntitynameByModulename($this->module_name);
        $this->list_link_field=$entityname['fieldname'];
	}
//@edit:liushuai,2021-05-21,reason:【ID1001643】借款申请单增加“账户”字段，并计入银行账户和现金银行流水账（已批准和反审核需要对银行账户进行相应的增减当前余额）
    function  save_module($module)
    {
        global $weixin_user;

        if($_REQUEST['action'] != 'LoanApplyAjax' && $_REQUEST['ajxaction'] != 'DETAILVIEW'
            && $_REQUEST['action'] != 'MassEditSave' && $_REQUEST['action'] != 'ProcessDuplicates' &&  $_REQUEST['action'] !='ApiNoEditDetails')
        {

        }
        else
        {
            //查看界面的小编辑和批量修改
            return ;
        }
        //编辑时判断币种是否改变$this->currency_status  true:改变，false:没改变
        //	if($this->currency_status === true){
        $currencyfieldinfo= $this->fieldobj->getFieldInfoobjBykey('columnname','currency_id');
        if(!$currencyfieldinfo)
        {
            global $adb;
            $bankaccountsetfieldinfo= $this->fieldobj->getFieldInfoobjBykey('columnname','bankaccountsetid');
            if($bankaccountsetfieldinfo)
            {
                $bankaccountid=  $this->column_fields[$bankaccountsetfieldinfo->getFieldName()];
                $sql='select currency_id, conversion_rate,currency_symbol from ld_bankaccountset where bankaccountsetid=? ';
                $result=$adb->pquery($sql,array($bankaccountid));
                if($adb->num_rows($result)>0)
                {
                    $this->column_fields['currency_id']=$adb->query_result($result,0,'currency_id');
                    $this->column_fields['conversion_rate']=$adb->query_result($result,0,'conversion_rate');
                    $this->column_fields['currency_symbol']=$adb->query_result($result,0,'currency_symbol');
                }
            }
            else{
                $this->column_fields['currency_id']=1;
                $this->column_fields['conversion_rate']=1;
                $this->column_fields['currency_symbol']='¥';
            }

        }

        //币种隐藏，美元合同关联创建币种错误
        $update_query = "update ld_loanapply set currency_id=?, conversion_rate=?,currency_symbol=? where loanapplyid=?";
        $update_params = array($this->column_fields['currency_id'], $this->column_fields['conversion_rate'],decode_html($this->column_fields['currency_symbol']), $this->id);
        $this->db->pquery($update_query, $update_params);
        //	}
    }

    //审批-》已批准
    function successApprove($record)
    {
        $this->minusBankMoney(array($record));
    }
    //反审批操作
    public function rejectApproved($record)
    {
        $this->addBankMoney(array($record));
    }

    public function minusBankMoney($records)
    {
        global $adb;
        if(empty($records))
        {
            return ;
        }
        $tmprecords=$records;
        if(is_array($records)&&$records[0]!="")
        {
            $tmprecords=implode(",",$records);
        }
        $usql = "UPDATE ld_bankaccountset
            
                INNER JOIN ld_loanapply on ld_bankaccountset.Bankaccountsetid=ld_loanapply.bankaccountsetid
                 SET curbalancemoney=IFNULL(curbalancemoney,0)-ld_loanapply.loanmoney
             WHERE ld_loanapply.loanapplyid in( $tmprecords )";
        $adb->pquery($usql,array());
    }

    public function addBankMoney($records)
    {
        global $before_approveinfo;
        global $adb;
        if(empty($records))
        {
            return ;
        }
        //因为有审批状态为10，所以不宜获取审批日志
        $tmprecords=$records;
        if(is_array($records)&&$records[0]!="")
        {
            $tmprecords=implode(",",$records);
        }
        if($before_approveinfo['approvestatus']==constant('D_A_S_APPROVED'))
        {

            $usql = "UPDATE ld_bankaccountset
            
                INNER JOIN ld_loanapply on ld_bankaccountset.Bankaccountsetid=ld_loanapply.bankaccountsetid
                 SET curbalancemoney=IFNULL(curbalancemoney,0)+ld_loanapply.loanmoney
             WHERE ld_loanapply.loanapplyid in( $tmprecords )";
            $adb->pquery($usql,array());
        }


    }
}
?>