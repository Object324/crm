<?php



class cls_PageValidataSave{
    
    public $module;
    public $record;
    public $focus;
    public $errortip;
    public $isallowsave;
    public $detailrowcnt;
    public $currencyid;
    public $havecurrency_id;
    public $db;
    public $choose_validataid;
    public $user;
    public $application;
    public $AllFieldValue;
    public $resetinfo;
    public $batchoprate;
    public $new_smownerid;
    public $allowsave;
    public $all_advft_criteria_arr = [];
    public $all_validatainfo_arr = [];
    public $sum_value_arr = [];
    public $request_application_arr = [];
    public $pagecation;
    public function __construct($module,$record,$detailrowcnt)
    {
        global $adb,$current_user;
        $this->module=$module;
        $this->db = $adb;
        $this->user = $current_user;
        if(isset($_REQUEST['isDuplicate'])&&$_REQUEST['isDuplicate']==true)
        {
            $record = 0;
        }else if(empty($record)){
            $record = 0;
        }
        $this->record=$record;
        $this->focus=CRMEntity::getInstance($module);
        $this->errortip='';
        $this->detailrowcnt=$detailrowcnt;//明细总行数
        
        if(empty($this->record)){
            $this->application = 'create';
        }else{
            $this->application = 'edit';
        }
        $this->AllFieldValue = array();
        $this->resetinfo = 'no';
        $this->batchoprate = 'no';//批量操作判断
        $this->new_smownerid = 0;//新负责人，分配时需要用到
        
        $this->all_advft_criteria_arr = array();
        $this->all_validatainfo_arr = array();
        $this->sum_value_arr = array();
        $this->request_application_arr = ['create','edit','savesubmit'];
    }
    public function setAllowSave($allowsave)
    {
        $this->allowsave=$allowsave;
    }
    public function setCurrencyId($currencyid)
    {
        $this->currencyid=$currencyid;
    }
    public function setChooseValidataid($choose_validataid){
        $this->choose_validataid = $choose_validataid;
    }

    public function setApplication($application){
        //设置验证规则应用场景
        $this->application = $application;
    }
    public function setNewSmownerid($smownerid){
        $this->new_smownerid = $smownerid;
    }
    public function getNewSmownerid(){
        return $this->new_smownerid;
    }

    public function getDetailRowcnt(){
        global $adb;
        if(empty($this->focus->Detail_table)){
            $this->detailrowcnt = 0;
            return '';
        }
        $detail_tablename = $this->focus->Detail_table;
        $Detail_table_index = $this->focus->Detail_table_index;
        $sql = "select count(1) as rowcnt from $detail_tablename where $Detail_table_index = ?";
        $result = $adb->pquery($sql,array($this->record));
        if($adb->num_rows($result)>0){
            $rowcnt = $adb->query_result($result,0,'rowcnt');
        }else{
            $rowcnt = 0;
        }
        
        $this->detailrowcnt=$rowcnt;
    }
    //重置对象模块和信息
    public function resetobj($module,$record){
        $this->module=$module;
        $this->record=$record;
        $this->getDetailRowcnt();
        $this->ResetCurrencyid();
        $this->resetinfo = 'yes';
        $this->errortip='';

        crm_load_class_file('cls_fieldsearchcondition','include/utils/');
        $cls_fieldsearchconditionobj = cls_fieldsearchcondition::getInstance($this->module);
        $cls_fieldsearchconditionobj->resetobj($this->module,$this->record);
    }
    public  function sethavecurrencyid(){
        global $adb;
        $this->havecurrency_id = 'no';
        $tablename = $this->focus->table_name;
        $tmpsql = "select 1 from ld_field where columnname='currency_id' and tablename = ?";
        $result = $adb->pquery($tmpsql,array($tablename));
        unset($tablename);
        if($adb->num_rows($result)>0){
            $this->havecurrency_id = 'yes';
        }
    }
    public  function gethavecurrencyid(){
        $havecurrency_id = $this->havecurrency_id;
        if(empty($havecurrency_id)){
            $this->sethavecurrencyid();
        }
        return $havecurrency_id;
    }
    //重设币种
    public function ResetCurrencyid(){
        global $adb;
        $currency_id=$_REQUEST['currency_id'];
        if(get_file_address($this->module,"ProductDetails"))
        {
            $currency_id=$_REQUEST['inventory_currency'];
        }
        if(empty($currency_id) && $this->record>0&&$this->gethavecurrencyid() == 'yes')
        {
            $tablename = $this->focus->table_name;
            $tableindex = $this->focus->table_index;
            $sql = "SELECT currency_id from $tablename where $tableindex = ? ";
            $result = $adb->pquery($sql,array($this->record));
            $currency_id = 1;
            if($adb->num_rows($result)>0){
                $currency_id = $adb->query_result($result,0,'currency_id');
            }
        }else{
            $currency_id=1;
        }
        $this->setCurrencyId($currency_id);
    }
    public function getValidDataInfoPhp()
    {
        //获取验证规则中所有需要使用的字段
        global $adb,$current_user;
        $record = $this->record;
        $module = $this->module;
        $languageType=getLanguageType($current_user);
        
        if($this->allowsave == 'yes'){
            $actionprevent = 'no';
        }else{
            $actionprevent = 'yes';
        }
        
        if($this->module=='Invoice'&&$this->allowsave=='no')
         {
            $versioninfo=getVersionInfo();
            if($versioninfo['account']=='zhongde'&&$_REQUEST['selectsourcename']=='CustomForm41' )
             {
               
                 $tmp_rowindex=1;
                do{
                            if(!isset($_REQUEST['hdnProductId'.$tmp_rowindex]))
                            {
                                $tmp_rowindex++;
                                continue;
                            }
                           $customform41id=$_REQUEST['entitytypeid'.$tmp_rowindex];
                           if(empty($customform41id))
                           {
                            $tmp_rowindex++;
                           }
                          
                          $tmpsql='select salesorder_01 from ld_customform41 where customform41id=?  and salesorder_01>0 ';
                         $tmpresult=$adb->pquery($tmpsql,array($customform41id));
                       if($adb->num_rows($tmpresult)>0)
                        {
                            $salesorder01_id=$adb->query_result($tmpresult,0,'salesorder_01');
                            $hdnProductId=$_REQUEST['hdnProductId'.$tmp_rowindex];
                              $tmplineiem_id=$_REQUEST['lineitem_id'.$tmp_rowindex];  
                            $quantity=$_REQUEST['quantity'.$tmp_rowindex];//数量
                            $tax_amount=$_REQUEST['tax_amount'.$tmp_rowindex];//价税合计
                             $sql='select tax_amount from  ld_salesorderdetail where id=? and productid=?';
                             $result=$adb->pquery($sql,array($salesorder01_id,$hdnProductId));
                             $ordertax_amount=$adb->query_result($result,0,'tax_amount');
                             
                            $sql="
                            select case when  sumquantity-ifnull(haveinvoicequantity,0)-ifnull(orderhaveinvoicecount,0) >quantity
                            					then 	quantity
                            ELSE			
                            					sumquantity-ifnull(haveinvoicequantity,0)-ifnull(orderhaveinvoicecount,0)
                            end as balancevalue,ld_customform41detail.lineitem_id,
                            case when  sumtax_amount-ifnull(haveinovicetax_amount,0) >tax_amount
                            					then 	tax_amount
                            ELSE			
                            					sumtax_amount-ifnull(haveinovicetax_amount,0) 
                            end as balancetax_amount,sumtax_amount,ld_customform41detail.tax_amount,ld_customform41detail.quantity
                            
                   		  from 
                            ld_customform41detail inner  join 
                            (select sum(quantity) as sumquantity,productid,sum(tax_amount) as sumtax_amount
                            	from ld_customform41 INNER JOIN ld_customform41detail 
                            on ld_customform41detail.id=ld_customform41.customform41id
                            where ld_customform41.deleted=0 and ld_customform41.salesorder_01=$salesorder01_id
                            group by productid  ) as tmp   on tmp.productid=ld_customform41detail.productid
                            left    JOIN 
                            (
                                                    	SELECT
                                                    		sum(ld_invoicedetail.quantity) AS haveinvoicequantity,
                                                            sum(ld_invoicedetail.tax_amount) as haveinovicetax_amount,
                                                    		entitytypeid,
                                                    		productid,
                                                    		ld_invoice.currency_id,
                                                    		ld_invoice.conversion_rate,
																parent_lineitem_id
                                                    	FROM
                                                    		ld_invoicedetail
                                                    	INNER JOIN ld_invoice ON ld_invoice.invoiceid = ld_invoicedetail.id
                                                    	WHERE
                                                    		ld_invoice.deleted = 0
                                                    	AND ld_invoicedetail.entitytypeid = $customform41id
                                                    	AND ld_invoicedetail.entitytype = 'CustomForm41'
                                                    	GROUP BY
                                                    		ld_invoicedetail.parent_lineitem_id
                                 ) AS tmp1 ON   tmp1.parent_lineitem_id=ld_customform41detail.lineitem_id 
                                  where ld_customform41detail.id=? and ld_customform41detail.lineitem_id=? ";      
                            }
                      
                         $result=$adb->pquery($sql,array($customform41id,$tmplineiem_id));
                         if($adb->num_rows($result)<=0)
                            continue;
                         $editdbtaxamount=0;
                         $editdbquantity=0;
                           if(!empty($this->record))
                            {
                                $sql='select productid,quantity,entitytypeid,tax_amount from ld_invoicedetail where id=? and entitytypeid=? and productid=? ';
                                $tmpresult=$adb->pquery($sql,array($this->record,$customform41id,$hdnProductId));
                                if($adb->num_rows($tmpresult)>0)
                                {
                                    $editdbtaxamount=setNumberFormatEmptySeperator($adb->query_result($tmpresult,0,'tax_amount'),2);
                                    $editdbquantity=setNumberFormatEmptySeperator($adb->query_result($tmpresult,0,'quantity'),4);
                                }
                                
                            }
                        $balancevalue=$adb->query_result($result,0,'balancevalue');//剩余数量
                        $balancetax_amount=setNumberFormatEmptySeperator($adb->query_result($result,0,'balancetax_amount'));//剩余金额
                        $customform41tax_amount=setNumberFormatEmptySeperator($adb->query_result($result,0,'tax_amount'));
                       $customform41quantity=setNumberFormatEmptySeperator($adb->query_result($result,0,'quantity'),4);
                       if($quantity>$customform41quantity)
                       {
                            $this->errortip="第".$tmp_rowindex."行实际开票数量".$tax_amount.' 不能大于应收单数量'.$customform41quantity;
                               return '';
                       }
                       
                        if($quantity-($balancevalue+$editdbquantity)>0.00001)
                       {
                            $this->errortip="第".$tmp_rowindex."行实际开票数量".$quantity.' 不能大于销售订单与应收单剩余开票数量'.setNumberFormatEmptySeperator(($balancevalue+$editdbquantity),4);
                               return '';
                       }
                        if($tax_amount>$customform41tax_amount){
                            $this->errortip="第".$tmp_rowindex."行实际开票金额".$tax_amount.' 不能大于应收单金额'.$customform41tax_amount;
                               return '';
                            
                        }
                         
                        if($tax_amount-($balancetax_amount+$editdbtaxamount)>0.00001)
                        {
                                $this->errortip="第".$tmp_rowindex."行实际开票金额".$tax_amount.'不能大于销售订单与应收单剩余开票金额'.setNumberFormatEmptySeperator(($balancetax_amount+$editdbtaxamount),2);
                                return '';
                                
                        }
                       $tmp_rowindex++;
                 }while($tmp_rowindex<=$this->detailrowcnt);
                     
                          
             }
         }
        //wym BUG0078375 kfbcrm-成员管理-批量编辑-admin账号应不能修改状态为“离职”
        if($module=='Users' && $record==1)
        {
            if($this->focus->column_fields['status']=='Inactive'){
                $this->errortip="admin账号不能设置为离职状态";
                return '';
            }
        }
        

        $validatainfo_arr = array();
        if(isset($this->all_validatainfo_arr[$module]) && isset($this->all_validatainfo_arr[$module][$actionprevent])){
            $validatainfo_arr = $this->all_validatainfo_arr[$module][$actionprevent];
        }
        else{
         
            $sql = "select * from  ld_validatasavemain where module = ?  and validatasavetype='php' and `status`= 'active'  
                    and actionprevent=? and FIND_IN_SET(?,validataapplication) order by sequence desc,id desc;";
            $frommodule = $this->module;
            if($frommodule == 'Calendar'){
                $frommodule = 'Events';
            }
            $validataapplication = $this->application;
            if($validataapplication == 'savesubmit'){
                $validataapplication = 'submit';
            }
            $result=$adb->pquery($sql,array($frommodule,$actionprevent,$validataapplication));
            
            $rows=$adb->num_rows($result);
            
            for($i=0;$i<$rows;$i++)
            {
                $validatasaveid=$adb->query_result($result,$i,'id');
                $relatedtable=$adb->query_result($result,$i,'relatedtable');
                $conditiongroup=$adb->query_result($result,$i,'conditiongroup');
                $effectivemethod=$adb->query_result($result,$i,'effectivemethod');
                if(empty($relatedtable))$relatedtable = 'ld_field';
                
                $savetip = '';
                $tiptype = '';
                if($languageType=='zh'){
                    $savetip=$adb->query_result($result,$i,'tipzh');
                    $tiptype=$adb->query_result($result,$i,'tipzhtype');
                }else{
                    $savetip=$adb->query_result($result,$i,'tipen');
                    $tiptype=$adb->query_result($result,$i,'tipentype');
                }
                
                //批量操作时增加缓存
                $sql_advft = 'select ld_validatasave.funtype as selecttype,ld_validatasave.fieldname,ld_validatasave.comparator,
                        		ld_validatasavedetail.funtype as comparetype,ld_validatasavedetail.relatefieldname,
                        		ld_validatasave.conditiongroupid,ld_validatasave.valid_condition,ld_validatasavedetail.relatedtable as detailtable,
                        		ld_validatasave.fungroupdbcolumns,ld_validatasave.fungrouphiddencolumns,
                        		ld_validatasavedetail.fungroupdbcolumns as detailfungroupdbcolumns,
                        		ld_validatasavedetail.fungrouphiddencolumns as detailfungrouphiddencolumns
                        from ld_validatasave INNER JOIN ld_validatasavedetail on ld_validatasave.id = ld_validatasavedetail.relateid
                        where ld_validatasave.validatasavemainid = ?  order by ld_validatasave.conditiongroupid asc,ld_validatasave.id asc;';
                $result_advft = $adb->pquery($sql_advft,array($validatasaveid));
                $rows_advft = $adb->num_rows($result_advft);
                
                $advft_criteria = array();
                //读取所有验证规则条件
                for($j=0;$j<$rows_advft;$j++){
                    $funtype=trim($adb->query_result($result_advft,$j,'selecttype'));
                    $fieldname = $adb->query_result($result_advft,$j,'fieldname');
                    $fungroupdbcolumns=$adb->query_result($result_advft,$j,'fungroupdbcolumns');
                    $fungrouphiddencolumns=$adb->query_result($result_advft,$j,'fungrouphiddencolumns');
                    $comparator = $adb->query_result($result_advft,$j,'comparator');
                    $valid_condition = $adb->query_result($result_advft,$j,'valid_condition');
                    
                    $detailfuntype = $adb->query_result($result_advft,$j,'comparetype');
                    $detailfieldname = $adb->query_result($result_advft,$j,'relatefieldname');
                    $conditiongroupid = $adb->query_result($result_advft,$j,'conditiongroupid');
                    $detailrelatedtable=$adb->query_result($result_advft,$j,'detailtable');
                    $detailfungroupdbcolumns=$adb->query_result($result_advft,$j,'detailfungroupdbcolumns');
                    $detailfungrouphiddencolumns=$adb->query_result($result_advft,$j,'detailfungrouphiddencolumns');
                    
                    if($relatedtable == 'ld_field'){
                        $fieldobj = $this->focus->fieldobj;
                        $column_key = 'fieldname';
                    }else{
                        $fieldobj = $this->focus->detailfieldobj;
                        $column_key = 'columnname';
                    }
                    $fieldinfo = '';
                    $detailfieldinfo = '';
                    $withfieldinfo = 'yes';
                    
                    if(empty($funtype)||$funtype == 'fields'){
                        $fieldinfo=$fieldobj->getFieldInfoobjBykey($column_key,$fieldname);
                        if(empty($fieldinfo)){
                            $withfieldinfo = 'no';
                        }
                 }
                    
                    if((empty($detailfuntype)||$detailfuntype == 'fields') && !in_array($comparator,array('isnull','isnotnull','curuser'))){
                        
                        
                        $detailfieldinfo=$fieldobj->getFieldInfoobjBykey($column_key,$detailfieldname);
                        
                        if(empty($detailfieldinfo)){
                            $withfieldinfo = 'no';
                        }
                    }
                    
                    $advft_criteria[] = array(
                        'withfieldinfo'=>$withfieldinfo,
                        'fieldinfo'=>$fieldinfo,
                        'detailfieldinfo'=>$detailfieldinfo,
                        'funtype'=>$funtype,
                        'fieldname'=>$fieldname,
                        'fungroupdbcolumns'=>$fungroupdbcolumns,
                        'fungrouphiddencolumns'=>$fungrouphiddencolumns,
                        'comparator'=>$comparator,
                        'valid_condition'=>$valid_condition,
                        'detailfuntype'=>$detailfuntype,
                        'detailfieldname'=>$detailfieldname,
                        'detailrelatedtable'=>$detailrelatedtable,
                        'groupid'=>$conditiongroupid,
                        'detailfungroupdbcolumns'=>$detailfungroupdbcolumns,
                        'detailfungrouphiddencolumns'=>$detailfungrouphiddencolumns,
                    );
                }
                
                $validatainfo_arr[] = array(
                    'validatasaveid'=>$validatasaveid,
                    'relatedtable'=>$relatedtable,
                    'conditiongroup'=>$conditiongroup,
                    'savetip'=>$savetip,
                    'tiptype'=>$tiptype,
                    'effectivemethod'=>$effectivemethod,
                    'advft_criteria'=>$advft_criteria
                );
             }
             $this->all_validatainfo_arr[$module][$actionprevent] = $validatainfo_arr;
         }
        crm_load_class_file('cls_fieldsearchcondition','include/utils/');
        $cls_fieldsearchconditionobj = cls_fieldsearchcondition::getInstance($this->module);
        $columnvalues = $this->getColumnvaluearr();
        $cls_fieldsearchconditionobj->setRecord($this->record);
        //zkt 20241107 BUG20241107-15 模块：销售订单，验证规则新版本校验错误不管是否外币都会阻断。规则名称：(VH)币种不是人民币税率为0（new）。
        $cls_fieldsearchconditionobj->setCurrencyId($this->currencyid);
        $cls_fieldsearchconditionobj->setColumnValues($columnvalues);
        $cls_fieldsearchconditionobj->setdetailrowcnt($this->detailrowcnt);
        $cls_fieldsearchconditionobj->setNewSmownerid($this->getNewSmownerid());
        $errortip_arr = array();
         foreach($validatainfo_arr as $tmp_validatainfo){
            $validatasaveid = $tmp_validatainfo['validatasaveid'];
            if($this->choose_validataid>0 && $this->choose_validataid != $validatasaveid){
                continue;
            }

            $relatedtable = $tmp_validatainfo['relatedtable'];
            $conditiongroup = html_entity_decode($tmp_validatainfo['conditiongroup']);
            $savetip = $tmp_validatainfo['savetip'];
            $tiptype = $tmp_validatainfo['tiptype'];
            $effectivemethod = $tmp_validatainfo['effectivemethod'];
            $advft_criteria = $tmp_validatainfo['advft_criteria'];
            //$advft_criteria处理，
             $new_advft_criteria = array();
             foreach($advft_criteria as $tmp_advftinfo){
                 $new_advftinfo = $tmp_advftinfo;
                 $new_advftinfo['selecttype'] = $tmp_advftinfo['funtype'];
                 $new_advftinfo['selectfield'] = $tmp_advftinfo['fieldname'];
                 $new_advftinfo['comparetype'] = $tmp_advftinfo['detailfuntype'];
                 $new_advftinfo['comparefield'] = $tmp_advftinfo['detailfieldname'];
                 $new_advftinfo['comparatortype'] = $tmp_advftinfo['comparator'];
                 $new_advftinfo['columncondition'] = $tmp_advftinfo['valid_condition'];
                 $new_advft_criteria[] = $new_advftinfo;
             }
             if(!empty($conditiongroup)){
                 $conditiongroup_arr = json_decode($conditiongroup,true);
             }else{
                 $conditiongroup_arr = ['',['groupcondition'=>'']];
             }
            $fieldconditionarr = array('relatedtable'=>$relatedtable,'advft_criteria'=>$new_advft_criteria,'group_condition'=>$conditiongroup_arr);
            $tmp_value = $cls_fieldsearchconditionobj->getresultbySearchconditioninfo($fieldconditionarr);


            if($relatedtable == 'ld_field'){

                if($this->judegevalidataallow($tmp_value,$effectivemethod)){
                    $this->errortip = $this->getFullTip($tiptype,$savetip,0);
                    if($this->allowsave == 'yes'){
                        $errortip_arr[] = $this->errortip;
                    }else{
                        return '';
                    }
                }
            }
            else{
                $detail_rowcnt = $this->detailrowcnt;
                $detail_checkresult = array();
                $this->sum_value_arr = array();
                $deteil_line_tmpvalue_arr = $cls_fieldsearchconditionobj->getDetailSearchvalue();
                for($line=1;$line<=$detail_rowcnt;$line++){
                    $tmp_value = $deteil_line_tmpvalue_arr[$line];
                    if($this->judegevalidataallow($tmp_value,$effectivemethod)){
                        $linesavetip = str_replace('{line}',$line,$savetip);
                        $detail_checkresult[] = $this->getFullTip($tiptype,$linesavetip,$line);
                    }
                }
                if(sizeof($detail_checkresult)>0){
                    //根据不同的提示框，选择不同的换行方式
                    if($this->batchoprate == 'yes'){
                        $wrapstr = ',';
                    }else{
                        $wrapstr = "<br>";
                    }
                    if(strpos($savetip,'{line}') !== false){
                        $this->errortip = implode($wrapstr,$detail_checkresult);
                    }else{
                        $this->errortip = $detail_checkresult[0];
                    }
                    
                    if($this->allowsave == 'yes'){
                        $errortip_arr[] = $this->errortip;
                    }else{
                        return '';
                    }
                }
            }
           
        }
        
        if(sizeof($errortip_arr)>0){
            if($this->batchoprate == 'yes'){
                $wrapstr = ',';
            }else{
                $wrapstr = "<br>";
            }
            $this->errortip = implode($wrapstr,$errortip_arr);
        }
       
       

    }

    public function judegevalidataallow($conditionstatus,$effectivemethod){
        $flage = false;
        if(($effectivemethod == 'notmeetcondition' && empty($conditionstatus))||($effectivemethod == 'meetcontidion' && !empty($conditionstatus))){
            $flage = true;
        }
        return $flage;
    }
    /**
     * group by 创建多维数组
     * */
    public function createMultiArr($key)
    {
        
         $nodes = explode ( '#@' , $key );
        $config = &$c ;
        $nodecount=sizeof($nodes);
        
        foreach ( $nodes as $tmpindex=> $node ) {
            if (isset( $config [ $node ])) {
                $config = & $config [ $node ];
               
            }
            else {
                $config [ $node ] = array ();
                $config = & $config [ $node ];
            }
            
        } 
        return $c;
    }
    
    public function getMultiArrValue($key,$arr)
    {
        $value = $arr ;
        $nodes = explode ( '.' , $key );
        foreach ( $nodes as $node ) {
            if (isset( $value [ $node ])) {
                $value = $value [ $node ];
            }
            else {
                $value = null;
                break ;
            }
        }
    }
    public function getSql(){
        
    }
    
    public function ParseMainSql($sql,$detailrowindex){
        $fieldobj=$this->focus->fieldobj;
      // $sql=html_entity_decode($sql);
     
        foreach($fieldobj->getModuleFields() as $fieldname=>$fieldinfo)
        {
              $tablename=$fieldinfo->getTableName();
              $columnname = $fieldinfo->getColumnName();
              $reqfieldname=$fieldname;
             if($fieldinfo->getFieldName()=='hdnGrandTotal')
             {
                //edit:can 20221101  58227 收款单，SQL 类型的验证规则，SQL中需要使用“实际收款金额”字段，使用 ld_cashbill.hdnGrandTotal  或者  cashbill_total 都取不到值

                 if($this->module=='CashBill')
                {
                    $reqfieldname='cashbill_total';
                }
                else if($this->module=="SendCashBill")
                {
                    if(is_numeric($_REQUEST['sendcashbill_total']))
                    {
                        $reqfieldname='sendcashbill_total';
                    }
                    else{
                        $reqfieldname='total';
                    }
                }
                else
                    $reqfieldname='total';
                
             }
             $fieldvalue = $this->getFieldValueByFieldinfo($fieldinfo,'ld_field',0,'sql');
            $fieldvalue = addslashes($fieldvalue);//BUG20240123-30 ls 240201 暂时将引号转义，避免sql因此执行报错。实际上应该采用解析sql后，参数绑定的方法。
            $sql=str_replace('{'.$tablename.'.'.$fieldname.'}',$fieldvalue,$sql);
            $sql=str_replace('{'.$tablename.'.'.$columnname.'}',$fieldvalue,$sql);
        }
         
        if($this->focus->detailfieldobj)
		{
		  
			$detailfieldobj=$this->focus->detailfieldobj;
			foreach($detailfieldobj->getModuleFields() as $columnname=>$fieldinfo)
			{
				$tablename=$fieldinfo->getTableName();
                $fieldvalue = $this->getFieldValueByFieldinfo($fieldinfo,'detailtable',$detailrowindex,'sql');
                $fieldvalue = addslashes($fieldvalue);
				$sql=str_replace('{'.$tablename.'.'.$columnname.'}',$fieldvalue,$sql);
			}
		}
        //duan 20231101验证规则通配符增加单据分录特殊字段
        if(get_file_address($this->module,"ProductDetails")){
            $product_extra_column_arr = ['productid','lineitem_id','parent_lineitem_id'];
            foreach ($product_extra_column_arr as $tmp_column){
                $request_key = $tmp_column.$detailrowindex;
                if(in_array($this->application,$this->request_application_arr)){
                    //lineitem_id 字段特殊处理
                    if($tmp_column == 'lineitem_id'){
                        $request_key = 'before_lineitem_id'.$detailrowindex;
                    }else if($tmp_column == 'parent_lineitem_id'){
                        $request_key = 'lineitem_id'.$detailrowindex;
                    }else if($tmp_column == 'productid'){
                        $request_key = 'hdnProductId'.$detailrowindex;
                    }
                }
                $tmp_value = $this->getFieldvalueByKey($request_key);
                $tmp_value = addslashes($tmp_value);
                $sql=str_replace('{'.$tmp_column.'}',$tmp_value,$sql);
                if($tmp_column == 'productid'){
                    $sql=str_replace('{hdnProductId}',$tmp_value,$sql);
                }
            }

        }

         $sql=str_replace('{Record.ID}',$this->record,$sql);
        $sql=str_replace('{uuid}',$this->user->id,$sql);
        $sql=str_replace('{new_smownerid}',$this->getNewSmownerid(),$sql); //获取新负责人的id,分配时用到

        // $sql=html_entity_decode($sql);
      
       return $sql;
    
    }
    
    public function getFieldvalueByKey($request_key){
        //duan 20231009 详情页小编辑获取值特殊处理
        if($_REQUEST['ajxaction'] == 'DETAILVIEW' && $_REQUEST['fldName'] == $request_key){
            return $_REQUEST['fieldValue'];
        }
        //新建编辑时从$_REQUEST获取字段值
        if(in_array($this->application,$this->request_application_arr) && isset($_REQUEST[$request_key])) {
            return $_REQUEST[$request_key];
        }elseif(in_array($this->application,$this->request_application_arr) && isset($this->focus->column_fields[$request_key])){
            return $this->focus->column_fields[$request_key];//lius 20231031 通过代码save方法创建的单据增加验证规则的取值方式
        }else{
            //删除、提交审批、反审批、审批成功时从数据库获取字段值
            $AllFieldValue = $this->getAllFieldValue();
            if(isset($AllFieldValue[$request_key])){
                return $AllFieldValue[$request_key];
            }else{
                return '';
            }
        }
    }
    //一次性从数据库读取出所有需要的字段值
    public function getAllFieldValue(){
        $record = $this->record;
        $module = $this->module;
        if(empty($record)){
            return array();    
        }
        
        if(sizeof($this->AllFieldValue)>0 && $this->resetinfo == 'no'){
            return $this->AllFieldValue;
        }
        $this->resetinfo = 'no';
        
        //获取当前单据的所有字段值
        global $adb;
        $main_fieldname_arr = array();
        $detail_columnname_arr = array();
        $focus = $this->focus;
        $fieldobj=$this->focus->fieldobj;
      // $sql=html_entity_decode($sql);
     
        foreach($fieldobj->getModuleFields() as $fieldname=>$fieldinfo)
        {
            if($fieldinfo->getSaveDataBase()!='yes')
                continue;
            if($fieldinfo->getBigType() == 'fileattachment'){
                continue;
            }
            $tablename = $fieldinfo->getTableName();
            if($tablename != $focus->table_name && $tablename != $focus->customFieldTable[0]){
                continue;
            }
            $main_fieldname_arr[] = $fieldname;
        }
        
        if($this->focus->detailfieldobj)
		{
		  
			$detailfieldobj=$this->focus->detailfieldobj;
			foreach($detailfieldobj->getModuleFields() as $columnname=>$fieldinfo)
			{
                if($fieldinfo->getSaveDataBase()!='yes')
                    continue;
                if($fieldinfo->getTableName()!=$focus->Detail_table&&$fieldinfo->getTableName()!=$focus->Detail_table_scf)
                    continue;
                if($fieldinfo->getBigType() == 'image'){
                    continue;
                }
                
                $tablename=$fieldinfo->getTableName();
                $detail_columnname_arr[] = $columnname;
			}
		}
        
        //获取验证规则中需要使用的表头字段值
        $focus = $this->focus;
        $AllFieldValue = array();
        if(sizeof($main_fieldname_arr)>0){
            $fieldobj = $focus->fieldobj;
            $fieldstr_arr = array();
            $columnname_arr = array();
            $main_tablename = $focus->table_name;
            $main_tablenamescf = $focus->customFieldTable[0];
            $scf_table_index = $focus->customFieldTable[1];
            foreach($main_fieldname_arr as $tmp_fieldname){
                $fieldinfo = $fieldobj->getFieldInfoobjBykey('fieldname',$tmp_fieldname);
                if(empty($fieldinfo)){
                    continue;
                }
                $tablename = $fieldinfo->getTableName();
                if($tablename != $main_tablename && $tablename != $main_tablenamescf){
                    continue;
                }
                $columnname = $fieldinfo->getColumnName();
                $tmp_fieldstr = $tablename.'.'.$columnname;
                $fieldstr_arr[] = $tmp_fieldstr;
                $columnname_arr[$tmp_fieldname] = $columnname;
            }
            if(sizeof($fieldstr_arr)>0){
                $table_index = $focus->table_index;
                $main_sql = "select ".implode(',',$fieldstr_arr)." from 
                    $main_tablename left join $main_tablenamescf on $main_tablename.$table_index = $main_tablenamescf.$scf_table_index 
                    where $main_tablename.$table_index = ?";
                $main_result = $adb->pquery($main_sql,array($record));
                if(!empty($main_result)){
                    foreach($columnname_arr as $tmp_fieldname => $tmp_columnname){
                        $tmp_fieldvalue = $adb->query_result($main_result,0,$tmp_columnname);
                        $AllFieldValue[$tmp_fieldname] = $tmp_fieldvalue;
                    }
                }
            }
        }
        
        //获取验证规则中需要使用的分录字段值
        if(sizeof($detail_columnname_arr)>0){
            $detailfieldobj = $focus->detailfieldobj;
            $detailfieldstr_arr = array();
            $columnname_arr = array();
            $detail_tablename = $focus->Detail_table;
            $detail_tablenamescf = $focus->Detail_table_scf;
            
            foreach($detail_columnname_arr as $tmp_columnname){
                $detailfieldinfo = $detailfieldobj->getFieldInfoobjBykey('columnname',$tmp_columnname);
                if(empty($detailfieldinfo)){
                    continue;
                }
                $tablename = $detailfieldinfo->getTableName();
                if($tablename != $detail_tablename && $tablename != $detail_tablenamescf){
                    continue;
                }
                $columnname = $detailfieldinfo->getColumnName();
                $tmp_detailfieldstr = $tablename.'.'.$columnname;
                $detailfieldstr_arr[] = $tmp_detailfieldstr;
            }
            //duan 20231101验证规则通配符增加单据分录特殊字段
            if(get_file_address($module,"ProductDetails")){
                $product_extra_column_arr = ['productid','lineitem_id','parent_lineitem_id'];
                foreach ($product_extra_column_arr as $tmp_column){
                    $detailfieldstr_arr[] = $detail_tablename.'.'.$tmp_column;
                    $detail_columnname_arr[] = $tmp_column;
                }
            }

            if(sizeof($detailfieldstr_arr)>0){
                $Detail_table_id = $focus->Detail_table_id;
                $Detail_table_index = $focus->Detail_table_index;
                $main_sql = "select ".implode(',',$detailfieldstr_arr)." from 
                    $detail_tablename left join $detail_tablenamescf on $detail_tablename.$Detail_table_id = $detail_tablenamescf.$Detail_table_id 
                    where $detail_tablename.$Detail_table_index = ?";
                $main_result = $adb->pquery($main_sql,array($record));
                
                $num_rows = $adb->num_rows($main_result);
                for($i=0;$i<$num_rows;$i++){
                    foreach($detail_columnname_arr as $tmp_columnname){
                        $tmp_fieldvalue = $adb->query_result($main_result,$i,$tmp_columnname);
                        $line = $i+1;
                        $AllFieldValue[$tmp_columnname.$line] = $tmp_fieldvalue;
                    }
                }
            }
        }
        $this->AllFieldValue = $AllFieldValue;
        
        return $this->AllFieldValue;
    }
    
    //根据字段信息判断获取值的方式，并判断获取后是否需要处理
    public function getFieldValueByFieldinfo($fieldinfo,$relatedtable,$row_index,$type){
        if(empty($fieldinfo)){
            return '';
        }
        $fieldname = $fieldinfo->getFieldName();
        $bigtype = $fieldinfo->getBigType();
        $uitype = $fieldinfo->getUIType();
        if($relatedtable == 'ld_field'){
        	if(in_array($this->application,$this->request_application_arr)){
                $origin_fieldname = $fieldname;
                if($fieldname=='hdnGrandTotal'){
                    if($this->module=='CashBill'){
                        $fieldname='cashbill_total';
                    }else if($this->module=="SendCashBill"){
                        if(is_numeric($_REQUEST['sendcashbill_total'])){
                            $fieldname='sendcashbill_total';
                        }else{
                            $fieldname='total';
                        }
                    }else{
                        $fieldname='total';
                    }
                }
                //BUG0076008 lius 20231124 验证规则在审批通过填写必填字段时失效，无法保存单据 (审批有必填字段时，sql中查询字段为hdnGrandTotal，此时不能转$fieldname，后续取值使用fieldname而不是columnname)
                if (!isset($_REQUEST[$fieldname])) {
                    $fieldname = $origin_fieldname;
                }

        	}
        	if($uitype == 117){
        	    //币种字段传值特殊处理
                $fieldvalue = $this->currencyid;
            }else if($this->application == 'create'){
                //新建时创建时间和创建人取值
                if($fieldname == 'createdtime'){
                    $fieldvalue = date('Y-m-d H:i:s', time());
                }else if($fieldname == 'creator'){
                    $fieldvalue = $this->user->id;
                }else{
                    $fieldvalue = $this->getFieldvalueByKey($fieldname);
                }
            }
        	else{
                $fieldvalue = $this->getFieldvalueByKey($fieldname);
            }
        }else{
            $fieldvalue = $this->getFieldvalueByKey($fieldname.$row_index);
        }
        
        //根据字段类型对获取到的值进行处理
        if(!empty($fieldvalue)){
            $sql_transfer_arr = ['multipicklist'];//sql填充时也需要转化的类型
            if($type == 'sql' && !in_array($bigtype,$sql_transfer_arr)){
                //做sql填充时不需要转化
            }else if($fieldinfo->getFieldDataType() == 'owner'){ //单选用户
                $fieldvalue = getUserFullName($fieldvalue);
            }else if($fieldinfo instanceof fieldInfo && in_array($uitype,Field::getUseField_arr())){ //多选用户
                $userid_arr = explode(',',trim($fieldvalue,','));
                $username_arr = array_map("getUserFullName",$userid_arr);
                $fieldvalue = implode(',',$username_arr);
            }
            //zkt 20241111 BUG20241111-57 付款单模块-验证规则“1”设置不生效
            else if ($uitype == 251 || $uitype == 252) {
                crm_load_class_file("BankAccountSet", "modules/BankAccountSet");
                $fieldvalue = BankAccountSet::getBackAccountNameById($fieldvalue);
            }else if($bigtype == 'reference' || $bigtype == 'selectsource'){ //关联选择单据字段和选择源单字段

                $fieldvalue = trim($fieldvalue,',');
                $record_arr = explode(',',$fieldvalue);
                $entitytype = getSalesEntityType($record_arr[0]);
                //获取链接字段信息
                $entityarray = getEntitynameInfo(getTabid($entitytype));
                $entity_focus = CRMEntity::getInstance($entitytype);
                $link_tabname = $entityarray['tablename'];
                $main_tablename = $entity_focus->table_name;
                $main_tableindex = $entity_focus->table_index;
                $tablename_cf = $entity_focus->customFieldTable[0];
                $tablename_cf_index = $entity_focus->customFieldTable[1];
                $link_tabfieldname = $entityarray['fieldname'];
                $link_tabindex = $entityarray['entityidfield'];
                $sql_select_no = "select GROUP_CONCAT($link_tabfieldname) as linkfield_str from $main_tablename inner join $tablename_cf 
                        on $main_tablename.$main_tableindex = $tablename_cf.$tablename_cf_index 
                        where $main_tablename.$main_tableindex in ($fieldvalue) and deleted = 0";
                $tmp_result = $this->db->pquery($sql_select_no,array());
                
                if($this->db->num_rows($tmp_result)>0){
                    $fieldvalue = $this->db->query_result($tmp_result,0,'linkfield_str');
                }else{
                    $fieldvalue = '';
                }
            }else if($bigtype == 'multipicklist'){ //多选框字段
                $fieldvalue = str_replace(' |##| ',',',$fieldvalue);
                $fieldvalue = str_replace('########',',',$fieldvalue);
            }else if($fieldname == 'entitytype'){
                $entitytype = trim($fieldvalue);
                $fieldvalue = getTranstab($entitytype);
            }else if($uitype == 117){
                //币种字段转化为文字
                $curreny_id = $fieldvalue;
                $curreny_sql = "SELECT ld_currencies.description from ld_currency_info 
                    INNER JOIN ld_currencies on ld_currency_info.currency_code = ld_currencies.currency_code
                    where ld_currency_info.id = ?";
                $result = $this->db->pquery($curreny_sql,[$curreny_id]);
                if($this->db->num_rows($result)>0){
                    $fieldvalue = $this->db->query_result($result,0,'description');
                }else{
                    $fieldvalue = '';
                }

            }else if($bigtype == 'boolean'){//复选框字段做处理，把1，0转成“是”和“否”
                if($fieldvalue == 1){
                    $fieldvalue = getFixedLabel('YES');
                }else if($fieldvalue == 0){
                    $fieldvalue = getFixedLabel('NO');
                }
            }
        }else{
            if($fieldinfo->isFldNumOrMoney()){
                $fieldvalue = '0';
            }
            else if($bigtype == 'reference' || $bigtype == 'selectsource'){
                if($fieldvalue == 0 || $fieldvalue == '0'){
                    $fieldvalue = '';
                }
            }
            else if($bigtype == 'boolean'){//复选框字段做处理，把1，0转成“是”和“否”
                $fieldvalue = getFixedLabel('NO');
            }
        }
        
        return $fieldvalue;
    }
    //判断根据提示类型获取提示信息
    public function getFullTip($tiptype,$tipcontent,$detailrowindex){
        if($tiptype == 'sql'){
            global $adb;
            $sql = $this->ParseMainSql($tipcontent,$detailrowindex);
            $sql = html_entity_decode($sql, ENT_QUOTES, $default_charset);
            $result = $adb->pquery($sql);
            if($adb->num_rows($result) > 0){
                $fulltip = $adb->query_result($result,0,0);
                if ($fulltip === '')
                    $fulltip = getFixedLabel('SQLQUERY').getFixedLabel('LBL_RESULT').getFixedLabel('UserEmpty');
            }else{
                $fulltip = getFixedLabel('SQLQUERY').getFixedLabel('error');
            }
        }else{
            $fulltip = $tipcontent;
        }
        return $fulltip;
    }

    
    
    //移动端提交审批,删除,反审批,审批成功的验证规则判断
    public function MobileValidataInfo($application){
        global $weixin_user;
        
        $_REQUEST['diony']='yes';
        $this->ResetCurrencyid();
        $this->setApplication($application);
        $this->getDetailRowcnt();
        $this->setAllowSave('no');
        $this->getValidDataInfoPhp();
        if(!empty($this->errortip)){
            ConvertTojsonString("-1",array(),$this->errortip);
        }
        
        $this->resetinfo = 'yes';
        $this->setAllowSave('yes');
        $this->getValidDataInfoPhp();
        //ConvertTojsonString("-2",array(),$PageValidataSaveobj->errortip);
        if(!empty($this->errortip)){
            //edit:can 20210425 保存验证规则
            ConvertTojsonString("confirm_save",array(),$this->errortip);
        }
    }


    //获取需要判断的columnname-value数字
    public function getColumnvaluearr(){
        $columnnamevaluearr = array();
        if(in_array($this->application,$this->request_application_arr)) {
            $columnnamevaluearr =  $_REQUEST;
            $product_extra_column_arr = ['productid','lineitem_id','parent_lineitem_id'];
            foreach($product_extra_column_arr as $tmpindex=>$tmpcolumnname){
                $detailrowcnt = $this->detailrowcnt;
                for($detailrowindex=0;$detailrowindex<$detailrowcnt;$detailrowindex++){
                    if($tmpcolumnname == 'lineitem_id'){
                        $column_request_key = 'before_lineitem_id'.$detailrowindex;
                    }else if($tmpcolumnname == 'parent_lineitem_id'){
                        $column_request_key = 'lineitem_id'.$detailrowindex;
                    }else if($tmpcolumnname == 'productid'){
                        $column_request_key = 'hdnProductId'.$detailrowindex;
                    }
                    $columnnamevaluearr[$tmpcolumnname] = $_REQUEST[$column_request_key];
                }

            }
        }
        else{
            if($this->record>0){
                $this->focus->retrieve_entity_info($this->record, $this->module);
            }
        }
        if($this->pagecation == 'create'){
            //新建时创建时间和创建人取值
            $columnnamevaluearr['createdtime'] = date('Y-m-d H:i:s', time());
            $columnnamevaluearr['creator'] = $this->user->id;
        }
        $modulefields = $this->focus->fieldobj->getModuleFields();
        foreach ($modulefields as $fieldname=>$fieldinfo){
            $columnname = $fieldinfo->getColumnName();
            if(isset($_REQUEST[$fieldname])){
                if($fieldname=='hdnGrandTotal'){
                    if($this->module=='CashBill'){
                        $fieldname='cashbill_total';
                    }else if($this->module=="SendCashBill"){
                        if(is_numeric($_REQUEST['sendcashbill_total'])){
                            $fieldname='sendcashbill_total';
                        }else{
                            $fieldname='total';
                        }
                    }else{
                        $fieldname='total';
                    }
                }
                $columnnamevaluearr[$columnname] =$_REQUEST[$fieldname];
            }
        }
        return $columnnamevaluearr;
    }
}


?>