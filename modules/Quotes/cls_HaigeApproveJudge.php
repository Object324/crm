<?php

 crm_load_class_file("cls_HaigeConst",'modules/Quotes');
class cls_HaigeApproveJudge{
    
    public $potentialid;
    public $quotetype;
    public $cur_total;
    public $record;
    public function  __construct($potentialid,$quotetype,$cur_total)
    {
        $this->potentialid=$potentialid;
        $this->quotetype=$quotetype;
        $this->cur_total=$cur_total;
    }
  
  public function setRecord($record)
  {
    $this->record=$record;
  }
   public function isChange()
   {
     if($this->quotetype==cls_HaigeConst::$QuoteType_Specical  &&$this->IsSpecialPrice()=='yes')
     {
        return  'yes';
     }
     else if($this->quotetype==cls_HaigeConst::$QuoteType_BackUp &&$this->isBackupPrice()=='yes')
     {
        return 'yes';
     }
     return 'no';
   }
    public function IsSpecialPrice()
    {
        //特价报价单
        /*1、报价单保存时，满足以下2种情况时，quick_approval 字段保存为 yes
                1）如果“报价单类型” = 特价报价单；
                   并且是“特价变更单”（即版本大于1.0）；
                   并且与最近1个相同 “特价申请编号” 的走完整审批流程（quick_approval 不等于 yes）的特价报价单比较，变更小于10%
                   并且最近这个走完整审批流程的特价报价单有下单记录
                
                例如：
                
                20220304改为
                    某个报价单金额为x，最近一次完整审批的报价单金额为 a, 则计算 (x-a)/a 是否小于 0.1
                
                date:2021-9-24 edit:duan 
                新加：如果报价单中产品被删除、数量减少以及新加的产品不在原有的产品组中，也需要走完整审批流程
                且走完整审批流程的特价报价单不需要有下单记录
                    date:20230509 edit:zkt 
                    修改：减少数量或者删除产品检查是否超过减量的10%，超过则走完整审批流程
                date:20230906 edit:zkt
                    修改：减少数量或者删除产品检查是否超过减量的20%，超过则走完整审批流程
            */
        global $adb;
		$cur_version=9999990;
        if($this->record>0)
        {
           $sql='select quote_version,copyid from ld_quotes where quoteid=?';
           $result=$adb->pquery($sql,array($this->record));
           $cur_version=$adb->query_result($result,0,'quote_version');
           $copyid = $adb->query_result($result,0,'copyid');
        }
        
        
        //edit:duan 新加：如果报价单中产品被删除、数量减少以及新加的产品不在原有的产品组中，也需要走完整审批流程
        //zkt 20230509 规则变化为：(减少数量或者删除产品检查是否超过减量的10%(10%的变更差异以系列为基准)，超过则走完整审批流程)
        if($cur_version >1&&$this->record>0){
            $sql = 'SELECT  ld_quotesdetail.id,ld_products.productgroup_name,ld_quotesdetail.productid,ld_quotesdetail.quantity,ld_quotesdetail.tax_amount
                    from ld_quotesdetail INNER JOIN ld_products on ld_quotesdetail.productid = ld_products.productid
                    where id in (SELECT quoteid from ld_quotes where quoteid = ? or copyid = ?)';
            $result = $adb->pquery($sql,array($copyid,$copyid));
            
            $num_row = $adb->num_rows($result);
            //判断产品分录是否进行了删除、增加、修改数量等操作
            if($num_row>0){
                $productgroup_namearr = array();
                $product_quantityarr = array();
                //zkt 20230509 减少数量或者删除产品检查是否超过减量的10%(10%的变更差异以系列为基准)，超过则走完整审批流程
                $reducecount_amount_groupname_arr = array();//减少数量对应减少金额
                $deleteproducts_amount_groupname_arr = array();//删除产品对应金额
                $product_tax_amountarr = array();
                $product_changeamount_arr = array();
                //获取此版本与上一个版本的产品信息
                for($i=0;$i<$num_row;$i++){
                    $quoteid = $adb->query_result($result,$i,'id');
                    $productgroup_name = $adb->query_result($result,$i,'productgroup_name');
                    $productid = $adb->query_result($result,$i,'productid');
                    $quantity = $adb->query_result($result,$i,'quantity');
                    $tax_amount = $adb->query_result($result,$i,'tax_amount');
                    if(array_key_exists($productgroup_name,$quote_groupnametotal_arr[$quoteid])){
                        $quote_groupnametotal_arr[$quoteid][$productgroup_name] +=  $tax_amount;
                    }
                    else{
                        $quote_groupnametotal_arr[$quoteid][$productgroup_name] =  $tax_amount;
                    }
                    $productgroup_namearr[$quoteid][$productid] = $productgroup_name;
                    $product_quantityarr[$quoteid][$productid] = $quantity;
                    $product_tax_amountarr[$quoteid][$productid] = $tax_amount;
                }
                
                foreach($product_quantityarr[$this->record] as $productid => $quantity){
                    $before_quantity = $product_quantityarr[$copyid][$productid];
                    //判断产品是否存在
                    if(!empty($before_quantity)&&$before_quantity>0){
                        //上一个版本已有产品，判断数量
                        unset( $product_quantityarr[$copyid][$productid]);
                        if($before_quantity > $quantity){
                            //统计减少数量的产品的减少金额(按产品组)
                            $tmpproductgroup_name = $productgroup_namearr[$copyid][$productid];
                            $reducecount_amount =  $product_tax_amountarr[$copyid][$productid] - $product_tax_amountarr[$this->record][$productid];
                            $product_changeamount_arr[$tmpproductgroup_name][$productid] = $reducecount_amount;
                        }
                    }else{
                        //新加产品，判断是否在原有的产品组中
                        $productgroup_name = $productgroup_namearr[$this->record][$productid];
                        if(!in_array($productgroup_name,$productgroup_namearr[$copyid])){
                            //不存在现有产品组中时，走完整审批流程
                            return 'no';
                        }
                    }
                }
                if(sizeof($product_quantityarr[$copyid])>0){
                    foreach($product_quantityarr[$copyid] as $productid){
                        //统计被删除的产品的对应金额（按产品组）
                        $tmpproductgroup_name = $productgroup_namearr[$copyid][$productid];
                        $deleteproducts_amount = $product_tax_amountarr[$copyid][$productid];
                        $product_changeamount_arr[$tmpproductgroup_name][$productid] = $deleteproducts_amount;
                    }
                    //新版本删除了原有的产品，走完整审批流程
                    //return 'no';
                }
                //判断减少数量或者删除产品检查是否超过减量的10%，超过则走完整审批流程
                if(!empty($product_changeamount_arr)){
                   foreach($product_changeamount_arr as $tmpproductgroup_name=>$tmp_changeproducts){
                       foreach($tmp_changeproducts as $tmpproductid=>$tmp_changeamount){
                            $tmpreducetotal = $quote_groupnametotal_arr[$copyid][$tmpproductgroup_name] - $quote_groupnametotal_arr[$this->record][$tmpproductgroup_name];
                            if($tmpreducetotal>0 && ($tmp_changeamount/$tmpreducetotal>0.1)){
                               // return 'no';
                            }
                       }
                   }
                }
            }
        }
        else{
            //1.0版本的报价单都走完整审批流程
            return 'no';
        }
        
        //判断金额变化量是否大于10% (20230510 10%的变更差异以系列为基准 即判断每个产品组是否变化量超过了10%)
         $sql="select tmp.quote_version,tmp.quoteid,ld_products.productgroup_name,sum(ld_quotesdetail.tax_amount) as tax_amount
             from (select ld_quotes.quote_version,ld_quotes.total,ld_quotes.quoteid from ld_quotes
                where ld_quotes.deleted=0 and 
                IFNULL(quick_approval,'no')<>'yes'
                and ld_quotes.quotestage=?
                and ld_quotes.potentialid =?
                and cast(quote_version as SIGNED INTEGER)<?
                 order by  ld_quotes.createdtime desc limit 1) as tmp 
                 LEFT JOIN ld_quotesdetail on ld_quotesdetail.id=tmp.quoteid
                INNER JOIN ld_products on ld_quotesdetail.productid = ld_products.productid
                GROUP BY tmp.quote_version,ld_products.productgroup_name";
        $result=$adb->pquery($sql,array(cls_HaigeConst::$QuoteStage_Qingdang,  $this->potentialid,$cur_version));
        $rows = $adb->num_rows($result);
         if($rows>0)
         {
            for($i=0;$i<$rows;$i++){
                $quote_tax_amount=$adb->query_result($result,$i,'tax_amount');
                $quote_version=$adb->query_result($result,$i,'quote_version');
                $quoteid=$adb->query_result($result,$i,'quoteid');
                $quote_productgroup_name=$adb->query_result($result,$i,'productgroup_name');
                
                if(!empty($quote_tax_amount))
               {
                    //$i==0保证之进入一次 
                    if($quote_version>1 && $i == 0){
                        if($_REQUEST['file']=='HaigeSaveTip'){
                            //productgroup_name
                            $produdctids=trim($_REQUEST['produdctids'],',');
                            $sql='select * from (select DISTINCT ld_products.productgroup_name from ld_quotesdetail inner join ld_products
                                 on ld_quotesdetail.productid=ld_products.productid
                                and ld_quotesdetail.id=?
                                right join (select DISTINCT productgroup_name,ld_products.productid from ld_products in( '.$produdctids.')) as tmp
                                    on tmp.productgroup_name=ld_products.productgroup_name ) as tmp_two where
                                    tmp_two.productgroup_name is null  ';
                           $tmp_result= $adb->pquery($sql,array($quoteid));
                                    
                        }
                        else{
                            $sql="select * from (select DISTINCT ld_products.productgroup_name from ld_quotesdetail inner join ld_products
                                on  ld_quotesdetail.productid=ld_products.productid
                                and ld_quotesdetail.id=?) as tmp 
                                right join (select DISTINCT ld_products.productgroup_name from ld_quotesdetail inner join ld_products
                                 on ld_quotesdetail.productid=ld_products.productid
                                and ld_quotesdetail.id=?) as tmp_one 
                                on tmp_one.productgroup_name=tmp.productgroup_name 
                                    where tmp.productgroup_name is null";
								
                                $tmp_result=$adb->pquery($sql,array($quoteid,$this->record));
                        }
                        if($adb->num_rows($tmp_result)>0){
                            return 'no';
                        }
                    }
                    
                    if(isset($quote_groupnametotal_arr[$this->record][$quote_productgroup_name])){
                        $cur_grouptax_amount = $quote_groupnametotal_arr[$this->record][$quote_productgroup_name];
                        $tmppercent = ($cur_grouptax_amount - $quote_tax_amount)/$quote_tax_amount;
                        if(abs($tmppercent)>0.2)//不需要考虑四舍五入
                        {
                            return 'no';
                        }
                    }
                    else{
                        return 'no';
                    }
                }
            }
            return 'yes';
        }
        return 'no';
    }
    public function  isBackupPrice()
    {
        //备案报价单
        /*如果“报价单类型” = 备案报价单
       并且是“备案变更单”（即版本大于1.0）；
       并且与最近1个相同 “特价申请编号” 的走完整审批流程（quick_approval 不等于 yes）的备案报价单比较，变更小于10%（不用计算累计变更）；
       并且最近这个走完整审批流程的备案报价单有下单记录
       */
          global $adb;
		  $cur_version=9999990;
	   if($this->record>0)
	   {
		   $sql='select quote_version from ld_quotes where quoteid=?';
		   $result=$adb->pquery($sql,array($this->record));
		   $cur_version=$adb->query_result($result,0,0);
	   }
         $sql="select tmp.* from (select ld_quotes.quote_version,ld_quotes.total,ld_quotes.quoteid from ld_quotes
                where ld_quotes.deleted=0 and 
                IFNULL(quick_approval,'no')<>'yes'
                and ld_quotes.potentialid =?
                and cast(quote_version as SIGNED INTEGER)<?
                order by  ld_quotes.createdtime desc limit 1) 
                as tmp  INNER JOIN ld_salesorder on ld_salesorder.quoteid=tmp.quoteid
				 and  ld_salesorder.deleted=0 ";
           $result=$adb->pquery($sql,array($this->potentialid,$cur_version));
		 
         if($adb->num_rows($result)>0)
         {
               
                $quotetotal=$adb->query_result($result,0,'total');
                $quote_version=$adb->query_result($result,0,'quote_version');
			
                if(!empty($quotetotal))
               {
                        $cur_total=$this->cur_total;
                   
                        $tmppercent=($cur_total-$quotetotal)/$quotetotal;
                        if($tmppercent<0.1)//不需要考虑四舍五入
                        {
                            return 'yes';
                            
                        
                        }
                   
               }
                
            }
            return 'no';
    }
}

?>