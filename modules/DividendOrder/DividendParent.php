<?php

require(globalStatic::$root_directory.'modules/DividendOrder/DividendField.php');
require(globalStatic::$root_directory.'modules/DividendOrder/HistoryProductField.php');
require(globalStatic::$root_directory.'modules/DividendOrder/Formula_base.php');
class DividendParent
{

    var $float_income='none';//浮动收益
    var $salesorder_focus;//订单对象
    var $dividendField_objs=array();//派息明细对象数组
    var $salesorder_productdetail_obj;//一行产品
    var $currency_id;//当前客户，当前产品所对应的币种（投资金额函数获取)
    var $invenst_enddate='';//投资到期日
    var $dividend_rules=array();
     var $startdate_bol='startdate_';
    var $enddate_bol="enddate_";
    var $rate_days_bol="rate_days_";
    var $rate_sendday_bol="rate_sendday_";
    var $dividend_money_bol="dividend_money_";
    var $rate_hidden_money_bol="rate_hidden_money_";
    var $investment_amount_bol="investment_amount_";
    var $float_income_bol="float_income_";
    var $txt_row_bol="txt_row_";
    var $hidden_dividend_status="hidden_dividend_status_";
    var $hide_detail="hidedetail_";

    var  $account_focus_obj=null;
    var $hide_htmltable;
    var $htmltable;
    var $float_income_money;//浮动收益
    var $Investment_Amount;//投资金额
    var $formula_obj;//派息公式类对象
    var $show_dividendObjs=array();//列表重算（Formula_base类中函数createTableContent赋值）
    var $hide_dividendObjs=array();//列表重算（Formula_base类中函数createHideTableDetail赋值）
    var $show_html_table=array();
    var $hide_html_table=array();
    var $Multi_DividendOrder_Detail='no';//设置派息单表格是否有操作列
    var $tr_Multi_DividendOrder_detail='no';//设置派息单表格每行是否有查看按钮
    var $accountid;
    var $productid;
    var $smownerid;//负责人
    var $dividendOrderObjs_dataBase=array();//数据库中已经存在的派息单数组
    var $historyProductFieldObjs=array();
     public static function getInstance($salesorder_focus)
     {
       global $adb;
       $detailtable=$salesorder_focus->Detail_table;
       $sql='select  tax_amount,ld_dividend_rules.* from ld_dividend_rules 
        inner join '.$detailtable.'  on ld_dividend_rules.productid='.$detailtable.'.productid where id=?';
       $result=$adb->pquery($sql,array($salesorder_focus->id));
  
        if($adb->num_rows($result)>0)
        {
            $tax_amount=$adb->query_result($result,0,'tax_amount');
            $productid=$adb->query_result($result,0,'productid');
            $formualcaptial=$adb->query_result($result,0,'formulacapital');
            
            switch($formualcaptial)
            {
                case "totalsubscription"://已购金额
                if(!class_exists('cls_Rate_havetotal'))
                    require(globalStatic::$root_directory.'modules/DividendOrder/cls_Rate_havetotal.php');
                $rate_type_focus=new cls_Rate_havetotal(); 
                   
                   break;
                case "everycontract"://合同订单
                    if(!class_exists('cls_Rate_SalesOrder'))
                         require(globalStatic::$root_directory.'modules/DividendOrder/cls_Rate_SalesOrder.php');
                   $rate_type_focus=new cls_Rate_SalesOrder(); 
                   break;
            }
            $rate_type_focus->dividend_rules['formulacapital']=$formualcaptial;
            $rate_type_focus->dividend_rules['deadline']=$adb->query_result($result,0,'deadline');//月结算截止日期
            $rate_type_focus->dividend_rules['formulamode']=$adb->query_result($result,0,'formulamode');//利息计算方式
            $rate_type_focus->dividend_rules['grantdate']=$adb->query_result($result,0,'grantdate');//利息发放日
            $rate_type_focus->dividend_rules['grantdate_switch']=$adb->query_result($result,0,'grantdate_switch');//利息发放日类型（当月，下月)
            $rate_type_focus->dividend_rules['formulas']=$adb->query_result($result,0,'formulas');//公式
            $rate_type_focus->dividend_rules['float_switch']=$adb->query_result($result,0,'float_switch');//浮动收益
            $rate_type_focus->dividend_rules['floatstartdate']=$adb->query_result($result,0,'floatstartdate');//浮动收益开始日期
            $rate_type_focus->dividend_rules['floatyield']=$adb->query_result($result,0,'floatyield');//浮动收益开始日期
          
            $rate_type_focus->dividend_rules['grantdate_designated']=$adb->query_result($result,0,'grantdate_designated');//指定派息日期
            if($rate_type_focus->dividend_rules['float_switch']=='on')
            {
                $rate_type_focus->float_income='all';
            }
            crm_load_class_file('ProductFields','include/ProductDetails');
            $productfieldinfo=new ProductFields();
            $productfieldinfo->setcolumnName('tax_amount');
            $productfieldinfo->setColumn_Value($tax_amount);
            $rate_type_focus->salesorder_productdetail_obj[0]['tax_amount']=$productfieldinfo;
            
            $productfieldinfo=new ProductFields();
            $productfieldinfo->setcolumnName('productid');
            $productfieldinfo->setColumn_Value($productid);
        
            $rate_type_focus->salesorder_productdetail_obj[0]['productid']=$productfieldinfo;
             $rate_type_focus->salesorder_focus=$salesorder_focus;
             return $rate_type_focus;
        }
        else
        {
            
        }
       
        
     }
   
    /**
     * 重算
     * */
    public function Recalculate()
    {
        ob_clean();
        ob_flush();
 
        if($_REQUEST['type']=='detail')
        {
             $this->Recalculate_delete_no_dividendorder();
               $this->getDividendDetail();//派息单
            $jsonarray['showtable']=$this->htmltable;
            $jsonarray['hidetable']=$this->hide_htmltable;
           return $jsonarray;
        }
           
        else //if($_REQUEST['type']=='list')
        {//21932: （金融账套）合同订单序时簿界面：按“重算搜索结果”【利息重算】后没有保存重算后的派息单
          //if($_REQUEST['type']=='list')
          
            if($_REQUEST['recalculate_method']=='2')
            {
                $this->Recalculate_delete_all_dividendorder();
            }
            else if($_REQUEST['recalculate_method']=='1')
            {
                $this->Recalculate_delete_no_dividendorder();
                
            }
            $this->getDividendDetail();//派息单
           
        }
       
        
       
    }
    
    public function get_account_product_id()
    {
         $account_fieldinfo=$this->salesorder_focus->fieldobj->getFieldInfoobjBykey('uitype',73);
        $account_fieldname=$account_fieldinfo->getFieldName();
  		$account_id = $this->salesorder_focus->column_fields[$account_fieldname];
        $productid =  $this->salesorder_productdetail_obj[0]['productid']->getColumn_Value();
        $this->accountid=$account_id;
        $this->productid=$productid;
    }
    public function getHistoryMoney_array($startdate,$enddate)
    {
    }
    public function getDividendOrderObjs_dataBase()
    {
    }
    public function getHistoryProductFieldObjs()
    {
        
    }
    /**
     * 合同订单相关信息sql组成
     * */
     public function getRelatedInfo_Sql($query)
     {
        
     }
     /**
     *重算 删除未派记录
     * 
     * */
    public  function Recalculate_delete_no_dividendorder()
    {
      
    }
    /**
     * 重算删除所有记录
     * */
    public  function Recalculate_delete_all_dividendorder()
    {
       
    }
    private function getColumn_DBValue($focus,$columnname)
    {
            $fieldinfo=$focus->fieldobj->getFieldInfoobjBykey("columnname",$columnname);
            if($fieldinfo)
            {
                return $focus->column_fields[$fieldinfo->getFieldName()];
            }
            return "";
    }
    private function setfieldValue_ByColumn($focus,$columnname,$value)
    {
         $fieldname=$focus->fieldobj->getFieldInfoBykeyValue('columnname',$columnname,'fieldname');
         if(!empty($fieldname))
              $focus->column_fields[$fieldname]=$value;
    }
    
   /**
    * 计算派息金额
    * 
    * */
   public function Computer_Principal()
   {
    
   }
   
    public function getTableWith()
    {
        //$this->dividend_rules['float_switch']:浮动收益
        //$this->formula_obj->isExistHaveDividendOrder:是否已经派息表示
        //$this->Multi_DividendOrder_Detail:是否有操作列
   
         $tdWidths=array('sequence'=>40,'startdate'=>100,'enddate'=>100,'days'=>60,'rate_senddate'=>100,'capital'=>120,'rate'=>120,'adjustment'=>80,'dividendmoney'=>120,'status'=>'');
         if($this->dividend_rules['float_switch']=='on'&&$this->formula_obj->isExistHaveDividendOrder=='yes'&&$this->Multi_DividendOrder_Detail=='yes')
         {
          
            $tdWidths=array('sequence'=>20,'startdate'=>70,'enddate'=>70,'days'=>60,'rate_senddate'=>70,'capital'=>90,'rate'=>80,'float_income'=>80,'adjustment'=>80,'dividendmoney'=>90,'olddividendmoney'=>90,'status'=>56,'operation'=>'');
         }
         else if($this->dividend_rules['float_switch']=='on'&&$this->formula_obj->isExistHaveDividendOrder=='yes')
         {
            $tdWidths=array('sequence'=>20,'startdate'=>80,'enddate'=>80,'days'=>60,'rate_senddate'=>70,'capital'=>100,'rate'=>100,'float_income'=>70,'adjustment'=>80,'dividendmoney'=>100,'olddividendmoney'=>100,'status'=>'');
         }
         else if($this->dividend_rules['float_switch']=='on'&&$this->Multi_DividendOrder_Detail=='yes')
         {
            $tdWidths=array('sequence'=>30,'startdate'=>90,'enddate'=>90,'days'=>60,'rate_senddate'=>90,'capital'=>110,'rate'=>90,'float_income'=>80,'adjustment'=>80,'dividendmoney'=>110,'status'=>56,'operation'=>'');
         }
         else if($this->formula_obj->isExistHaveDividendOrder=='yes'&&$this->Multi_DividendOrder_Detail=='yes')
         {
           
            
            $tdWidths=array('sequence'=>20,'startdate'=>80,'enddate'=>80,'days'=>60,'rate_senddate'=>80,'capital'=>100,'rate'=>90,'adjustment'=>80,'dividendmoney'=>110,'olddividendmoney'=>110,'status'=>56,'operation'=>'');
         }
         else if($this->dividend_rules['float_switch']=='on')
         {
            $tdWidths=array('sequence'=>30,'startdate'=>80,'enddate'=>80,'days'=>60,'rate_senddate'=>80,'capital'=>110,'rate'=>90,'float_income'=>70,'adjustment'=>80,'dividendmoney'=>110,'status'=>'');
            
         }
         else if($this->formula_obj->isExistHaveDividendOrder=='yes')
         {
            
            $tdWidths=array('sequence'=>25,'startdate'=>90,'enddate'=>90,'days'=>60,'rate_senddate'=>80,'capital'=>110,'rate'=>90,'adjustment'=>80,'dividendmoney'=>110,'olddividendmoney'=>110,'status'=>'');
          
         }
         else if($this->Multi_DividendOrder_Detail=='yes')
         {
            
            $tdWidths=array('sequence'=>30,'startdate'=>90,'enddate'=>90,'days'=>90,'rate_senddate'=>90,'capital'=>110,'rate'=>110,'adjustment'=>90,'dividendmoney'=>110,'status'=>60,'operation'=>'');
         }
        return $tdWidths;
    }
    /**
    * 创建派息单列头
    * $ishaveDividendOrder:客户和产品是否已经有派息单了，yes:有，no:没有
    * */
   public   function createTable($ishaveDividendOrder){
    
       $tdWidth=$this->getTableWith();
    	$table = '<table class="listEntries fir-center" style="margin-top: 10px;" width="100%" border="0" cellspacing="1" cellpadding="0">';
    	//列头
    	$table .='<tr>';
        $table.='<th width="'.$tdWidth['sequence'].'" >#</th>';
    	$table .='<th  width="'.$tdWidth['startdate'].'" title="'.getFixedLabel('STARTDATE').'">'.getFixedLabel('STARTDATE').'</th>';
    	$table .='<th  width="'.$tdWidth['enddate'].'" title="'.getFixedLabel('ENDDATE').'">'.getFixedLabel('ENDDATE').'</th>';
    	$table .='<th  width="'.$tdWidth['days'].'"  title="'.getFixedLabel('INTERESTSDAYS').'">'.getFixedLabel('INTERESTSDAYS').'</th>';
    	$table .='<th width="'.$tdWidth['rate_senddate'].'"  title="'.getFixedLabel('INTERESTPAYMENTDATE').'">'.getFixedLabel('INTERESTPAYMENTDATE').'</th>';
    	$table .='<th width="'.$tdWidth['capital'].'"   title="'.getFixedLabel('PRINCIPAL').'">'.getFixedLabel('PRINCIPAL').'</th>';
    	$table .='<th width="'.$tdWidth['rate'].'" title="'.getFixedLabel('INTEREST').'">'.getFixedLabel('INTEREST').'</th>';
        if(strtolower($this->dividend_rules['float_switch'])=="on")
        {
            $table .='<th width="'.$tdWidth['float_income'].'"  tag=\'float_income_td\' title="'.getFixedLabel('FLOATINCOME').'">'.getFixedLabel('FLOATINCOME').'</th>';
             
        }
        else
        {
            $table .='<th width="0"  tag=\'float_income_td\' style="display:none" title="'.getFixedLabel('FLOATINCOME').'">'.getFixedLabel('FLOATINCOME').'</th>';
        }
    	$table .='<th width="'.$tdWidth['adjustment'].'"  title="'.getFixedLabel('Adjustment').'">'.getFixedLabel('Adjustment').'</th>';
        if($ishaveDividendOrder=='no')
    	   $table .='<th width="'.$tdWidth['dividendmoney'].'" tag="no_dividend" title="'.getFixedLabel('DIVIDENDBTN').getFixedLabel('AMOUNT').'">'.getFixedLabel('DIVIDENDBTN').getFixedLabel('AMOUNT').'</th>';
        
         else
         {
            $table .='<th width="'.$tdWidth['dividendmoney'].'" tag="yes_dividend" title="'.getFixedLabel('DIVIDENDBTN').getFixedLabel('AMOUNT').'(新)">'.getFixedLabel('DIVIDENDBTN').getFixedLabel('AMOUNT').'(新)</th>';
            $table .='<th width="'.$tdWidth['olddividendmoney'].'" tag="yes_dividend" title="'.getFixedLabel('DIVIDENDBTN').getFixedLabel('AMOUNT').'(旧)">'.getFixedLabel('DIVIDENDBTN').getFixedLabel('AMOUNT').'(旧)</th>';
         }
    	$table .='<th width="'.$tdWidth['status'].'"  title="'.getFixedLabel('STATUS').'">'.getFixedLabel('STATUS').'</th>';
    	//$table .='<th width="56" data-resizable-column-id="Operating" title="'.getFixedLabel('OPERATING').'">'.getFixedLabel('OPERATING').'</th>';
        if($this->Multi_DividendOrder_Detail=="yes")
        {
            $table .='<th width="'.$tdWidth['operation'].'" title="'.getFixedLabel('OPERATING').'">'.getFixedLabel('OPERATING').'</th>';
        }
         
        $table .='</tr>';
    	$table .='</table>';
    	return $table;
    }
    
    
     /**
        * 保存
        * */
       public function save()
       {

            global $adb,$current_user;
            static $dividendorder_accountids;//利息重算
            /*$query='  delete from ld_dividendorderdetail  where dividendorderid 
                        in (select dividendorderid from   ld_dividendorder where accountid=? and product_id=? and status=?) ';
            $sql='delete from ld_dividendorder where accountid=? and product_id=? and status=? ';*/
            $this->Recalculate_delete_no_dividendorder();
            $float_income_type=$_REQUEST['float_income'];
            $formualcaptial=$this->dividend_rules['formulacapital'];
            
            switch($formualcaptial)
            {
                case "totalsubscription"://已购金额
                  
                   $salesorderid=0;
                   break;
                case "everycontract"://合同订单
                  $salesorderid=$_REQUEST['dividend_salesorderid'];
                   break;
            }
            
           
            $accountid=$_REQUEST['dividend_accountid'];
            $productid=$_REQUEST['dividend_productid'];
           
            
            if($this->account_focus_obj==null&&!array_key_exists($this->salesorder_focus->column_fields['account_id'],$dividendorder_accountids))
            {
                $account_focus_obj=CRMEntity::getInstance('Accounts');
                $account_focus_obj->retrieve_entity_info($this->salesorder_focus->column_fields['account_id'],'Accounts');
                $dividendorder_accountids[$this->salesorder_focus->column_fields['account_id']]=$account_focus_obj;
            }
            $account_focus_obj=$dividendorder_accountids[$this->salesorder_focus->column_fields['account_id']];
            
            $bank_account_name=$this->getColumn_DBValue($this->salesorder_focus,'bank_account_name');//账户名称
            $bank_account_number=getModuleHref("Contacts",$this->getColumn_DBValue($this->salesorder_focus,'contactid'));//银行账号
            $bank_name=$this->getColumn_DBValue($this->salesorder_focus,'bankname');//开户银行
             $bank_net_number=$this->getColumn_DBValue($this->salesorder_focus,'bank_number');//开户行网点号
            $license_no=$this->getColumn_DBValue($account_focus_obj,'license_no');//组织机构代码证
            $mobilephone=$this->getColumn_DBValue($account_focus_obj,"mobilephone");//移动电话
            $bill_street=$this->getColumn_DBValue($account_focus_obj,"bill_street");//地址
            $phone=$this->getColumn_DBValue($account_focus_obj,'phone');//固定电话
            $description=$this->getColumn_DBValue($account_focus_obj,'description');//备注
           // $adb->pquery($query,array($accountid,$productid,DIVIDEND_STATUS_NO));//
           // $adb->pquery($sql,array($accountid,$productid,DIVIDEND_STATUS_NO));//删除客户和产品所有未派息的单据
            $i=1;
            $j=1;
           
            while(true)
            {
             
                if($_REQUEST['startdate_'.$i])
                {
                     if($_REQUEST['hidden_dividend_status_'.$i]=='no')
                     {
                        $rate_sendday=$_REQUEST['rate_sendday_'.$i];//利息发放日
                        $startdate=$_REQUEST['startdate_'.$i];
                        $enddate=$_REQUEST['enddate_'.$i];
                        $dividend_money=$_REQUEST['dividend_money_'.$i];
                        
                        $rate_sendday=$_REQUEST['rate_sendday_'.$i];
                        $dividend_focus=new DividendOrder();
                        $this->setfieldValue_ByColumn($dividend_focus,'product_id',$productid);//
                        $this->setfieldValue_ByColumn($dividend_focus,'banknum',$bank_account_name);//银行账户
                        $this->setfieldValue_ByColumn($dividend_focus,'bankcard_no',$bank_account_number);//银行卡号
                        $this->setfieldValue_ByColumn($dividend_focus,'bankbranchnumber',$bank_net_number);//银行网点
                        $this->setfieldValue_ByColumn($dividend_focus,'license_no',$license_no);//组织机构代码证
                        $this->setfieldValue_ByColumn($dividend_focus,'bill_street',$bill_street);//地址
                        $this->setfieldValue_ByColumn($dividend_focus,'phone',$phone);//固定电话
                        $this->setfieldValue_ByColumn($dividend_focus,'mobilephone',$mobilephone);//移动电话
                        $this->setfieldValue_ByColumn($dividend_focus,'description',$description);//备注
                        $this->setfieldValue_ByColumn($dividend_focus,'bankname',$bank_name);//开户银行
                      
                        $this->setfieldValue_ByColumn($dividend_focus,'startdate',$startdate);//开始日期
                        $this->setfieldValue_ByColumn($dividend_focus,'enddate',$enddate);//结束日期
                        $this->setfieldValue_ByColumn($dividend_focus,'cashmoney',$dividend_money);//金额
                        $this->setfieldValue_ByColumn($dividend_focus,'plandividend_date',$rate_sendday);//计划派息日期
                        $this->setfieldValue_ByColumn($dividend_focus,'status',DIVIDEND_STATUS_NO);//状态
                        $this->setfieldValue_ByColumn($dividend_focus,'smownerid',$_REQUEST['sel_smownerid']);//负责人
                        $this->setfieldValue_ByColumn($dividend_focus,'smcreatorid',$current_user->id);//创建人
                        $this->setfieldValue_ByColumn($dividend_focus,'createdtime',date("Y-m-d H:i:s"));//创建时间
                        $this->setfieldValue_ByColumn($dividend_focus,'modifiedby',$current_user->id);//最新更新人
                        $this->setfieldValue_ByColumn($dividend_focus,'modifiedtime',date("Y-m-d H:i:s"));//最新更新时间
                        $this->setfieldValue_ByColumn($dividend_focus,'currency_id',$_REQUEST['hidden_currency_id']);//币种
                       
                        $dividend_focus->mode='create';
                        $dividend_focus->save("DividendOrder");
                        
                        //金额是不可编辑字段
                        $principal=$_REQUEST['investment_amount_'.$i];
                        $float_income=$_REQUEST['float_income_'.$i];
                        $adjustment=$_REQUEST['txt_row_'.$i];
                        $rate_money=$_REQUEST['rate_hidden_money_'.$i];
                        $sql="update ld_dividendorder set cashmoney=?,adjustment=?,principal=?, float_income=?, rate_money=? where dividendorderid=?";
                        $adb->pquery($sql,array($dividend_money,$adjustment,$principal,$float_income,$rate_money, $dividend_focus->id));
                        
                        $dividendorderids[]=$dividend_focus->id;
                        $this->saveDetail($dividend_focus,$i);//保存派息单明细
                        $i++;
                        
                     }
                     else 
                     {
                        $i++;
                     }
                   
                    
                }
                else
                {
                     $i++;
                    break;
                }
             
            }
           
          
            if(sizeof($dividendorderids)>0)
            {
                  $dividendorderids=implode(",",$dividendorderids);
                  $currency_obj=new Currency($adb,$_REQUEST['hidden_currency_id']);
                  $conversion_rate=$currency_obj->getCurrencyRate();
                  $currencySysbol=decode_html($currency_obj->getCurrencySymbol());
                
                 $sql='update ld_dividendorder set salesorderid=?, accountid=?,currency_id=?,conversion_rate=? ,currency_symbol=? where dividendorderid in( '.$dividendorderids.' )';//修改客户名称
              
                  $adb->pquery($sql,array($salesorderid,$accountid,$_REQUEST['hidden_currency_id'],$conversion_rate,$currencySysbol));
            }
          
       }
       
       /**
        * 明细保存
        * */
       private   function saveDetail($dividend_focus,$startrow_index)
       {
            global $adb,$current_user;
            $i=$startrow_index;
            $total_dividend_money=0;
            
            $rate_senddate=$dividend_focus->column_fields['plandividend_date'];//主表利息发放日
            $start_date=$dividend_focus->column_fields['startdate'];//开始日期
            $end_date=$dividend_focus->column_fields['enddate'];//截止日期
           $hide_detail=$this->hide_detail;
         
            while(true)
            {
               
                if($_REQUEST[$hide_detail.'startdate_'.$i])
                {
                  
                    $hide_start_date=$_REQUEST[$hide_detail.'startdate_'.$i];
                    $hide_end_date=$_REQUEST[$hide_detail.'enddate_'.$i];;
                     if($_REQUEST[$hide_detail.'hidden_dividend_status_'.$i]=='no')
                     {
                        
                        $rate_sendday=$_REQUEST[$hide_detail.'rate_sendday_'.$i];//利息发放日
                        
                        if($rate_sendday==$rate_senddate&&($start_date<=$hide_start_date&&$hide_end_date<=$end_date))
                        {   $startdate=$_REQUEST[$hide_detail.'startdate_'.$i];
                            $enddate=$_REQUEST[$hide_detail.'enddate_'.$i];
                            $rate_days=$_REQUEST[$hide_detail.'rate_days_'.$i];
                            $principal=$_REQUEST[$hide_detail.'investment_amount_'.$i];
                            $float_income=$_REQUEST[$hide_detail.'float_income_'.$i];
                            $adjustment=$_REQUEST[$hide_detail.'txt_row_'.$i];
                            $rate_money=$_REQUEST[$hide_detail.'rate_hidden_money_'.$i];
                            $dividend_money=$_REQUEST[$hide_detail.'dividend_money_'.$i];
                          
                            $sql="insert into ld_dividendorderdetail(startdate,enddate,dividendorderid,days,rate_senddate,float_income,adjustment,rate_money,princial,dividend_money)
                                        value(?,?,?,?,?,?,?,?,?,?)";
                                        
                          
                            $adb->pquery($sql,array($startdate,$enddate,$dividend_focus->id,$rate_days,$rate_senddate,$float_income,0,$rate_money,$principal,$dividend_money));
                        }
                        $i++;
                     
                        
                     }
                     else 
                     {
                        $i++;
                     }
                   
                    
                }
                else
                {
                    $i++;
                    break;
                }
               
            }
       }
       
       
       public static function getDetailByDividendorderId ($dividendorderid,$float_income_type)
    {
        global $adb;
        global $list_max_entries_per_page_new_more;
         $header = array(getFixedLabel('STARTDATE'),getFixedLabel('ENDDATE'),getFixedLabel('INTERESTSDAYS'),
                                getFixedLabel('INTERESTPAYMENTDATE'),getFixedLabel('PRINCIPAL'),getFixedLabel('INTEREST')
                            );
         if($float_income_type=='all')
            $header[]=getFixedLabel('FLOATINCOME');
        //$header[]=getFixedLabel('Adjustment');
        $header[]=getFixedLabel('AMOUNT');
        //$header[]=getFixedLabel('OPERATING');
        $sql='select dividendorderid from ld_dividendorderdetail where dividendorderid=?';
        $result=$adb->pquery($sql,array($dividendorderid));
        $noofrows=$adb->num_rows($result);
       	global $related_left_type;
		if($related_left_type == 3){//获取相关信息条数
			$related_entries = array();
			$related_entries['relcount'] = $noofrows;
			return $related_entries;
		}
       
        $sql='select * from ld_dividendorderdetail where dividendorderid=?';
		$sql .= ' order by  ld_dividendorderdetail.startdate asc     ';
      
        $result = $adb->pquery($sql,array($dividendorderid));
        $num_rows=$adb->num_rows($result);
        if($num_rows>0){
            for($i=0;$i<$num_rows;$i++)
            {
                $listview_entrie = array();
				$listview_entrie[] = $adb->query_result($result,$i,'startdate');
                $listview_entrie[] = $adb->query_result($result,$i,'enddate');
                $listview_entrie[] = $adb->query_result($result,$i,'days');
                $listview_entrie[] = $adb->query_result($result,$i,'rate_senddate');
                $listview_entrie[] = ' <div align="right">'.setNumberFormat($adb->query_result($result,$i,'princial')).'</div>';
                $listview_entrie[] = ' <div align="right">'.setNumberFormat($adb->query_result($result,$i,'rate_money')).'</div>';
               if($float_income_type=='all')
                    $listview_entrie[] =' <div align="right">'. setNumberFormat($adb->query_result($result,$i,'float_income')).'</div>';
                //$listview_entrie[] = ' <div align="right"><span id="dividorderdetail_adjustment_'.$i.'">'.setNumberFormat($adb->query_result($result,$i,'adjustment')).'</span>
                  //          <input type="hidden" id="hidden_adjstment_dividorderdetail_'.$i.'"  value="'.round($adb->query_result($result,$i,'adjustment')).'"</div>';
			   $listview_entrie[] = ' <div align="right" style="width:100%"><span id="dividorderdetail_span_'.$i.'">'.setNumberFormat($adb->query_result($result,$i,'dividend_money')).'</span>
                                            <div id="editarea_dividorderdetail_'.$i.'" class="modulecontrolldiv" style="display: none;">
                                                     <input id="txtbox_dividorderdetail_'.$i.'" onchange="dividendordertail_money('.$i.',this)" class="detailedViewTextBox" type="text" onfocus="this.className=\'commonDetailedTextBox gwidth70 bgcolordh\'" onblur="this.className=\'detailedViewTextBox\'" name="modulename"  value="'.round($adb->query_result($result,$i,'dividend_money')).'" style="width:60px;float:left;">
                                                        <div>
                                                        <a class="Anu3_a" onclick="dividendordertail_save('.$i.','.$adb->query_result($result,$i,'id').')" href="javascript:void(0);">'.getFixedLabel("SAVE").'</a>
                                                        <a class="Anu3_a" onclick="dividendordertail_cancel('.$i.');" href="javascript:void(0);">'.getFixedLabel("CANCEL").'</a>
                                                        </div>
                                            </div>
                                    </div>';
              // $listview_entrie[]='<a style="white-space:nowrap;"    onclick="divdendorderDetail_Adjustment('.$i.','.$adb->query_result($result,$i,'id').');" href="javascript:void(0);" class="Anu3_a">'.
				//			getFixedLabel('Adjustment').'</a>';
                $listview_entries[] = $listview_entrie; 
            }
        }
		$navigationOutput = Array();$url_qry = '';
		crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
		$navigation_array = VT_getSimpleNavigationValues($start, $list_max_entries_per_page_new_more,$noofrows);
		$navigationOutput[] =  getRecordRangeMessage($result, $limstart,$noofrows);
		$navigationOutput[] = getRelatedTableHeaderNavigation($navigation_array, $url_qry,$currentModule,'DividendOrders',$id);
        //print_r($listview_entries);
        
        $return_value = array('header'=>$header,'entries'=>$listview_entries,'navigation'=>$navigationOutput);
		return $return_value;
    }
}


?>