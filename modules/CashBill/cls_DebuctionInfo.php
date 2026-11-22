<?php
/**
 * 收款界面处理预收单
 * */
class cls_DebuctionInfo{
    
    public $record;//收款单/预收款单id
    public $cashtype;
    public $accountid;//客户id
    public $bankaccountsetid;
    public $focus;
    public $arr_keywordsfieldinfo;//收款单主表关键字（用于显示预收单的超链接字段）
    public $arr_keywordscolumns;
    public $arr_keyworkdstables;
    public $currency_id;
    public $system_deploy_351;//单据分录明细金额字段和单据头货币字段小数位数
    public function __construct($record,$focus){
        $this->record=$record;//单据id(收款单或预收单)
        $this->focus=$focus;
        
        $this->accountid=$this->focus->column_fields['account_id'];
        //bankaccountsetid
        $this->bankaccountsetid=$this->focus->column_fields['bankaccountsetid'];//收款单账户
        $this->currency_id=$this->getreqCurrencyId($this->bankaccountsetid);
        
        $this->cashtype=$this->focus->column_fields['cashtype'];//收款单类型(预收单，收款单)
        $modulefields=$this->focus->fieldobj->getModuleFields();//获取收款单界面所有显示字段
        $this->arr_keywordsfieldinfo=array();
        $this->arr_keywordscolumns=array();
        $this->arr_keyworkdstables=array();
        foreach($modulefields as $fieldname=>$fieldinfo){
            //获取收款单界面所有关键字字段（用于预收单显示)
            if($fieldinfo->getKeywords()=='yes'){
                
                $this->arr_keywordsfieldinfo[]=$fieldinfo;
                $tmp_tablename=$fieldinfo->getTableName();
                $columname=$fieldinfo->getColumnName();
                //$this->arr_keywordscolumns[]=$tmp_tablename.'.'.$columname;
                $this->arr_keyworkdstables[]=$tmp_tablename;
            }
        }
        $system_351 = getSys_deploy(351);//单据分录明细金额字段和单据头货币字段小数位数
        $system_deploy_351 = 2;
        if(is_numeric($system_351['deploy_value'])){
            $system_deploy_351 = $system_351['deploy_value'];    
        }
        $this->system_deploy_351 = $system_deploy_351;
    }
    /**
     *收款单新增/编辑/查看界面 获取的客户的预收款单
     * */
    public function getDebuctionListByAccountid(){
        global $adb;
        if(file_exists(globalStatic::$root_directory.'modules/CashBill/DebuctionInfoColumn.php'))
        {
            global $arr_keywordscolumns;
            global $arr_keyworkdstables;
            require_once globalStatic::$root_directory.'modules/CashBill/DebuctionInfoColumn.php';
            $this->arr_keywordscolumns=$arr_keywordscolumns;
            $this->arr_keyworkdstables=$arr_keyworkdstables;
            
            
        }
        else
            $this->arr_keywordscolumns=['ld_cashbill.cashbill_no'];
        
        $columns=implode(",",$this->arr_keywordscolumns);
		$versioninfo=getVersionInfo();
        
        if(!in_array('ld_cashbill.cashbilldate',$this->arr_keywordscolumns)){
            $columns.=' ,ld_cashbill.cashbilldate';
        }
        $zhongde_columnname='';
        $zhongdewhere='';
		if($versioninfo['account']=='zhongde')
        {
             $zhongde_columnname='zhongde_backmoneny';  
             $columns.=' ,zhongde_backmoneny'; 
             $leftjoin=' left join ld_cashbillscf on ld_cashbillscf.cashbillid=ld_cashbill.cashbillid ';
             $zhongdewhere= ' and ifnull(ld_cashbillscf.cf_5896,"") ="审核" and ld_cashbill.approvestatus = "已批准" and  ld_cashbill.exchmsg = "同步成功" ';
        }
     else{
        
           $leftjoin='';
     }
         $sql='select ld_cashbill.cashbillid,ld_cashbill.debuctionbalanceamount,ld_cashbill.debuctionamount
                ,'.$columns.' ,0 as detailid,
                        0 as debuctionid ,"new" as type
             from ld_cashbill ';
     
         if(in_array('ld_cashbillscf',$this->arr_keyworkdstables)){
            //关键字字段有自定义字段
             $leftjoin=' left join ld_cashbillscf on ld_cashbillscf.cashbillid=ld_cashbill.cashbillid ';
              
         }    
        
        $sys_465 = getSys_deploy(465);//系统参数，设置预收单金额和可抵扣金额录入负数时是否允许保存
        $AllowSaveNegativenum = $sys_465['deploy_value'];
        $debuctionamount_where = '';
        if($AllowSaveNegativenum == 'no'){
            $debuctionamount_where = 'and ld_cashbill.debuctionbalanceamount>0';
        }
        else if($AllowSaveNegativenum == 'yes'){
            //zkt 20240117 BUG20240111-55 收款单选择客户后，不需要显示预收单可抵扣金额为0的预收单数据
            $debuctionamount_where = 'and (ld_cashbill.debuctionbalanceamount>0 or ld_cashbill.debuctionbalanceamount<0)';
        }
        //@edit:zkt @date:2024/12/19 @reason: XUQIU20240821-02   --- 系统参数，设置计算预收单金额时是否统计未审批通过的预收单
        $sys_492 = getSys_deploy(492);//系统参数，设置计算预收单金额时是否统计未审批通过的预收单
        $IsCalculateunapproved = $sys_492['deploy_value'];
        if($IsCalculateunapproved == 'no'){
            $debuctionamount_where = " and ld_cashbill.approvestatus = '".D_A_S_APPROVED."' ";
        }
        unset($sys_492,$IsCalculateunapproved);
      
        //edit:can 2020-08-31 收款单关联预收单做核销的时，无需控制“银行账户”一致，控制币种一致即可
        $params=array('debuction',$this->accountid,$this->currency_id);
        global $current_user;
         crm_load_class_file("DebuctionCustomView",'modules/CashBill');
            
        $customView=new DebuctionCustomView('CashBill');
        $viewid = $customView->getViewId('CashBill');
        $queryGeneratoryobj = QueryGenerator::getInstance('CashBill', $current_user,$customView);
        ///得到对应视图的查询字段
        if ($viewid != "0") {
           $queryGeneratoryobj->initForCustomViewById($viewid);
        } else {
        	$queryGeneratoryobj->initForDefaultCustomView();
        }
        $page_list_query=$queryGeneratoryobj->getQuery('','1'); 
      
        if($this->record>0){
            $accountid=$this->accountid;
            //单是查看或者编辑界面需要获取收款的预收历史记录
        $sql="select * from (SELECT
                        0 as detailid,
                        0 as debuctionid ,
                        $columns,
                    	ld_cashbill.cashbillid,
                    	ld_cashbill.debuctionbalanceamount,
                    	ld_cashbill.debuctionamount,
                        
                    'new' as type
                    FROM
                    	ld_cashbill $leftjoin  inner join ($page_list_query  and  ld_cashbill.cashtype='debuction' and ld_cashbill.accountid=$accountid) as tmp on tmp.cashbillid=ld_cashbill.cashbillid 
                    WHERE
                    	cashtype = ?
                    AND ld_cashbill.accountid = ?
                    AND ifnull(ld_cashbill.currency_id,1) = ?
                    ".$debuctionamount_where.
                    $zhongdewhere."
                    union ALL
                    select ld_cashbilldebuctiondetail.id as detailid, ld_cashbilldebuctiondetail.debuctionid, $columns, ld_cashbilldebuctiondetail.debuctionid as casbillid,0,amount
                    ,'edit' as type from ld_cashbilldebuctiondetail
                    INNER JOIN ld_cashbill on ld_cashbill.cashbillid=ld_cashbilldebuctiondetail.debuctionid
                    $leftjoin
                    where ld_cashbilldebuctiondetail.cashbillid=?) as tmpone  order by cashbilldate asc ,detailid  asc ";
        
              $params=array( 'debuction',$this->accountid,$this->currency_id,$this->record);
        }
        else{
            
            $params=[];  
            $params[]='debuction';
            $params[]=$this->accountid;
            
            $params[]='debuction';
            $params[]=$this->accountid;
            $params[]=$this->currency_id;
            
            $sql.=' inner join ('.$page_list_query.' and  ld_cashbill.cashtype=? and ld_cashbill.accountid=?) as tmp on tmp.cashbillid=ld_cashbill.cashbillid ';
            
            $sql.=$leftjoin.'   where ld_cashbill.cashtype=? and ld_cashbill.accountid=? and ld_cashbill.deleted=0
             '.$debuctionamount_where.'
             and ifnull(ld_cashbill.currency_id,1)=? '.$zhongdewhere.'
              order by ld_cashbill.cashbilldate asc';
            
        }
        
        
        $currecy_symbol='¥';
        if($this->currency_id>0){
          
            $tmpsql='select currency_symbol from ld_currency_info where id=?';
            $tmpresult=$adb->pquery($tmpsql,array($this->currency_id));
            
            $currecy_symbol=$adb->query_result($tmpresult,0,'currency_symbol');
            
        }

      //dump($sql);
        $result=$adb->pquery($sql,$params);

        $rows=$adb->num_rows($result);
        $tmpDebucation_arr=[];
         /*if($this->record>0&&$rows>0)
         {
            for($i=0;$i<$rows);$i++)
            {
                $debuctionid=$adb->query_result($result,$i,'debuctionid');
                $tmpDebucation_arr[]=$debuctionid;
                
            }
            $tmpsql=$page_list_query.' and  ld_cashbill.cashtype=? and ld_cashbill.accountid=?  and ld_cashbill.cashbillid in( '.implode(",",$tmpDebucation_arr).') '  ;
            $tmpresult =$adb->pquery($tmpsql,array('debuction',$this->accountid));
            $tmpDebucation_arr=[];
            for($i=0;$i<$adb->num_rows($tmpresult);$i++)
            {
                //获取当前用户能够看到的预收单
                $tmpDebucation_arr[]=$adb->query_result($tmpresult,$i,'cashbillid');
                
            }
         }*/
        $field_obj=Field::getInstance('CashBill',$adb);
        
        $arr=array();
        for($i=0;$i<$adb->num_rows($result);$i++)
        {
            $type=$adb->query_result($result,$i,'type');
            $debuctionbalanceamount=$adb->query_result($result,$i,'debuctionbalanceamount');
            $debuctionamount=$adb->query_result($result,$i,'debuctionamount');
            $debuctionid=$adb->query_result($result,$i,'debuctionid');
            
            $cashbillno='';
            $cashbillid=$adb->query_result($result,$i,'cashbillid');
            $cashbillinfo=array();
            foreach($this->arr_keywordscolumns as $tmpcolumnname){
               $tmp_columns= explode(".",$tmpcolumnname);
               $tmpvalue=$adb->query_result($result,$i,$tmp_columns[1]);
            
              
	           	$showfieldvalue=new ShowFieldValue($field_obj,'CashBill',constant('SHOW_EDITVIEW'));
                $showfieldvalue->setRecorId($cashbillid);
                $field=$field_obj->getFieldInfoobjBykey("columnname",$tmp_columns[1]);
                $showvalue=$showfieldvalue->getFieldValueByField($field,$tmpvalue,$tmpvalue);
                
               if($showvalue['value']!='')
                $cashbillinfo[]=$showvalue['value'];//获取预收单信息
            }
            $cashbillno=implode(",",$cashbillinfo);
            
            $detailid=$adb->query_result($result,$i,'detailid');
            
            $debuctionbalanceamount=number_format($debuctionbalanceamount,$this->system_deploy_351,".","");
            $debuctionamount=number_format($debuctionamount,$this->system_deploy_351,".","");
            if($debuctionid==null||$debuctionid==NULL){
                $debuctionid=0;
            }
            if($versioninfo['account']=='zhongde'&&$type=='new')
            {
                $zhongde_backmoneny=$adb->query_result($result,$i,'zhongde_backmoneny');
                $zhongde_backmoneny=number_format($zhongde_backmoneny,$this->system_deploy_351,".","");
                $debuctionbalanceamount=$debuctionbalanceamount-$zhongde_backmoneny;
                
                if($debuctionbalanceamount<=0)
                {
                    continue;
                }
            }
            $arr[]=array('rawbalanceamount'=>$debuctionbalanceamount,'balanceamount'=>$currecy_symbol.setNumberFormat($debuctionbalanceamount,$this->system_deploy_351)
                       , 'rawdebuctionamount'=>$debuctionamount,'debuctionamount'=>$currecy_symbol.setNumberFormat($debuctionamount,$this->system_deploy_351)
                ,'debuctionid'=>$debuctionid,'cashbillno'=>$cashbillno,'cashbillid'=>$cashbillid,
                'readonly'=>'yes','currency_symbol'=>$currecy_symbol,'detailid'=>$detailid);
            
        }
        
        return $arr;
    }
    /**
     * 预收款查看界面获取预收款的核销记录（收款单历史）
     * */
    public function getDebuctionListByDebuctionId(){
        global $adb;
       $currecy_symbol='¥';
       
        $currency_id=$this->focus->column_fields['currency_id'];
        if(!empty($currency_id))
        {
            $sql='select currency_symbol from ld_currency_info where id=? ';
            $result=$adb->pquery($sql,array($currency_id));
            if($adb->num_rows($result)>0){
                $currecy_symbol=$adb->query_result($result,0,0);
                
            }
        }
        
        $sql='SELECT ld_cashbill.cashbill_no,ld_cashbilldebuctiondetail.amount
                ,ld_cashbill.cashbilldate,ld_cashbill.cashbillid,ld_cashbill.source_list 
                FROM ld_cashbilldebuctiondetail
                INNER JOIN ld_cashbill ON ld_cashbill.cashbillid = ld_cashbilldebuctiondetail.cashbillid
                WHERE debuctionid =? and ld_cashbill.deleted=0
                ORDER BY ld_cashbill.cashbilldate ASC, ld_cashbilldebuctiondetail.id ASC  ';
        $result=$adb->pquery($sql,array($this->record));
         $rows=$adb->num_rows($result);
         $arr=array();
         for($i=0;$i<$rows;$i++){
            $cashbill_no=$adb->query_result($result,$i,'cashbill_no');
            $amount=$adb->query_result($result,$i,'amount');
            $cashbilldate=$adb->query_result($result,$i,'cashbilldate');
            $cashbillid=$adb->query_result($result,$i,'cashbillid');
			$source_list=$adb->query_result($result,$i,'source_list');
			$entitytype_no= [];
			if(!empty($source_list)){
				$values = explode(',', $source_list);
				foreach ($values as $value) {
					$value = trim($value, ',');
					if (!empty($value)) {
						//if (empty($tmpmodulename))
						$tmpmodulename = getSalesEntityType($value);
						$sourcedatavalue = getModuleHref($tmpmodulename, $value);
						if ($sourcedatavalue != '') {
							 $entitytype_no[] = "<a href='".CreateDetailViewHref($tmpmodulename,$value)."' onclick='ListReferenceLinkClick(ld(this),event)' referencemodule='" . $tmpmodulename . "' referencerecord='" . $value . "' >" . getModuleHref($tmpmodulename, $value) . "</a>";
						}
					}
				}
			}
            $arr[]=array("cashbill_no"=>$cashbill_no,'amount'=>$amount,'cashbilldate'=>$cashbilldate
                ,'currecy_symbol'=>$currecy_symbol,'cashbillid'=>$cashbillid,"entitytype_no"=>implode(',',$entitytype_no));
            
         }
        
         return $arr;
        
    }
    public function getDebuctionListHtml($debuctiontotal){
        
        $cashbill_nolabel=$this->focus->fieldobj->getFieldInfoBykeyValue("columnname",'cashbill_no','fieldlabel');
        $cashbill_datelabel=$this->focus->fieldobj->getFieldInfoBykeyValue("columnname",'cashbilldate','fieldlabel');
        $arr=$this->getDebuctionListByDebuctionId();
		
        if(!is_array($arr)||sizeof($arr)<=0||!is_array($arr[0])){
            return '';
        }
        $tablehtml='<div name="showUsedAmountDetail" style="">
        <div class="DivCName DivCNamehover" onclick="showHideStatus(\'tbldebuctioninfo\',\'aidtbldebuctioninfo\');"><span class="" id="aidtbldebuctioninfo"></span>';
        
        $tablehtml.=getFixedLabel('UsedAmountHistory').'
            </div>
            <div id="tbldebuctioninfo" class="DivCNotice" style="width: auto; display: block;">
            <table class="" width="100%" cellspacing="0" cellpadding="0" border="0">
        <tbody><tr>';
        
    $tablehtml.='<td class="ld-form-item-content-entrytitle" width="5%" align="center">#</td>';
    
    $tablehtml.='<td class="ld-form-item-content-entrytitle" width="15%">'.$cashbill_datelabel.'</td>';
    
    $tablehtml.='<td class="ld-form-item-content-entrytitle" width="15%">'.$cashbill_nolabel.'</td>';
    
    $tablehtml.='<td class="ld-form-item-content-entrytitle" width="15%">'.getFixedLabel('SOURCEMODULE').'</td>';
	$tablehtml.='<td class="ld-form-item-content-entrytitle" width="15%">'.getFixedLabel('UsedAmount').'</td>';
	
    $tablehtml.='<td class="ld-form-item-content-entrytitle" width="15%">'.getFixedLabel('AvailableAmount').'</td>';
    $tablehtml.='</tr>';
        $totalamount=0;
        foreach($arr as $index=>$info){
            $cashbillid=$info['cashbillid'];
            
            $totalamount+=$info['amount'];
            $tablehtml.='<tr>';
            $tablehtml.="<td class='ld-form-item-content-entry' align='center'>".($index+1).'</td>';
            $tablehtml.="<td class='ld-form-item-content-entry'>".$info['cashbilldate'].'</td>';
            $tablehtml.="<td class='ld-form-item-content-entry'><a title='".$info['cashbill_no']."' fieldname='' module='CashBill' referencemodule='CashBill' referencerecord='".$cashbillid."' record='' lasturl='' href='index.php?module=CashBill&action=DetailView&record=".$cashbillid."' onclick='ListReferenceLinkClick(ld(this),event)'>".$info['cashbill_no']."</a></td>";
            $tablehtml.="<td class='ld-form-item-content-entry'>".$info['entitytype_no'].'</td>';
            $tablehtml.="<td class='ld-form-item-content-entry'  align='right'>".$info['currecy_symbol']. setNumberFormat($info['amount'],$this->system_deploy_351).'</td>';
            $tablehtml.="<td class='ld-form-item-content-entry'  align='right'>".$info['currecy_symbol'].setNumberFormat($debuctiontotal-$totalamount,$this->system_deploy_351).'</td>';
            $tablehtml.='</tr>';
        }
        
        $tablehtml.='</table>';
        return $tablehtml;
        
    }
   
    /**
     * $debuctionid：预收款id
     * */
    public static function updateDebuctionInfo($arr_debuctionid){
        global $adb;
        //41530: （61mis.com/kfbcrm）编辑有核销金额的收款单单据时，删除已核销的预收单信息后，预收单据可抵扣金额显示错误
            $tmp_arr=array();
           $arr_debuctionid= array_filter($arr_debuctionid);
            foreach($arr_debuctionid as $tmpvalue){
                $tmp_arr[]=$tmpvalue;
            }
            $arr_debuctionid=$tmp_arr;
            unset($tmp_arr);
            
        if(!is_array($arr_debuctionid)||empty($arr_debuctionid)||trim($arr_debuctionid[0],',')=='')
        {
            return false;
        }
      $sql="update ld_cashbill 
                LEFT JOIN (select sum(amount) as sumamount,debuctionid  from 
                                ld_cashbilldebuctiondetail inner join ld_cashbill on ld_cashbill.cashbillid=ld_cashbilldebuctiondetail.cashbillid
                                where ld_cashbill.deleted=0 and debuctionid in (".implode(',',$arr_debuctionid).")
                                     group by debuctionid) as tmp
                on tmp.debuctionid=ld_cashbill.cashbillid
                set ld_cashbill.debuctionamount=ifnull(sumamount,0) 
                ,ld_cashbill.debuctionbalanceamount=ld_cashbill.total-ifnull(sumamount,0)
                ,ld_cashbill.cashtype=?
                where ld_cashbill.cashbillid in (".implode(',',$arr_debuctionid).")  ";
  // dump($sql);
            $adb->pquery($sql,array('debuction'));
            // echo $sql;
//    exit();
        /*if($this->cashtype=='cashbill')
        {
            //收款单反写预收款单的剩余抵扣金额
            $sql="update ld_cashbill inner JOIN (
                select sum(total) as totaldebuction,ld_cashbilldebuction.debuctionid from ld_cashbilldebuction
                INNER JOIN 
                (select debuctionid from ld_cashbilldebuction where cashbillid=?) as tmp 
                on ld_cashbilldebuction.debuctionid=tmp.debuctionid
                INNER JOIN ld_cashbill on ld_cashbill.cashbillid=ld_cashbilldebuction.cashbillid
                and ld_cashbill.deleted=0 and cashtype='cashbill'
                GROUP BY ld_cashbilldebuction.debuctionid ) as tmpone 
                on tmpone.debuctionid=ld_cashbill.cashbillid and ld_cashbill.cashtype='debuction'
                set ld_cashbill.debucationamount=ifnull(tmpone.totaldebuction,0)
                ,ld_cashbill.debuctionbalanceamount=ld_cashbill.total-ld_cashbill.debucationamount ";
                 $adb->pquery($sql,array($this->record));
        }
        else{
            //预收款单保存反写
            $sql="update ld_cashbill 
                LEFT JOIN (select sum(amount) as sumamount,debuctionid from ld_cashbilldebuction
                INNER JOIN ld_cashbill on ld_cashbill.cashbillid=ld_cashbilldebuction.cashbillid
                and ld_cashbill.deleted=0
                where debuctionid=?) as tmp
                on tmp.debuctionid=ld_cashbill.cashbillid
                set ld_cashbill.debucationamount=ifnull(sumamount,0) 
                ,ld_cashbill.debuctionbalanceamount=ld_cashbill.total-debucationamount
                ,ld_cashbill.cashtype=?
                where ld_cashbill.cashbillid=? ";
            
            $adb->pquery($sql,array($this->record,'debuction',$this->record));
        }*/
        
        
    }
    
      /**
     * edit:can 2020-08-31 收款单关联预收单做核销的时，无需控制“银行账户”一致，控制币种一致即可
     * 获取界面选择的币种
     * */
    public function getreqCurrencyId($req_bankaccountid)
    {
        global $adb;
        $req_currency_id = (string)$_REQUEST['currency_id'];
        if(stripos($req_currency_id,',')!==false)
        {
            $req_currency_id=substr($req_currency_id,0,stripos($req_currency_id,','));
        }
        if(empty($req_currency_id)&&!empty($req_bankaccountid))
        {
            $sql='select currency_id from ld_bankaccountset where bankaccountsetid=?';
            $result=$adb->pquery($sql,array($req_bankaccountid));
            return $adb->query_result($result,0,0);
            
        }
        else if(empty($req_currency_id)&&empty($req_bankaccountid))
        {
            return 1;
        }
        
        return $req_currency_id;
    }
}


?>