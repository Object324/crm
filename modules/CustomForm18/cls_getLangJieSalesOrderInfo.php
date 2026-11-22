<?php
/**
 * 应收费用单获取客户报价单明细信息
 * 
 * */
class cls_getLangJieSalesOrderInfo
{
    /**
     * selectmodule:选择的单据
     * */
     public $totalweightcolumname='';//获取合计列
     public $selectid;//选择的单据ID
     public $selectmodule;
    public function __construct($selectmodule,$selectid)
    {
        $this->selectid=$selectid;
        $this->selectmodule=$selectmodule;
        switch($selectmodule)
        {
            case "CustomForm27"://配送单
                $this->totalweightcolumname='sf389';//配送单分录计费重量
                break;
            case "CustomForm23"://运输单
                $this->totalweightcolumname="sf204";//运输单分录毛重
                break;
            case "CustomForm24"://空运
                $this->totalweightcolumname='sf174';//空运分录计费重量
                break;
            case "CustomForm21"://海运
                $this->totalweightcolumname="'1'" ;
                break;
            case 'CustomForm22'://报关
                 $this->totalweightcolumname="'1'" ;
                 break;
            case "Commission"://出入库
                $this->totalweightcolumname='sf215';//毛重
                break;
            
        }
    }
    public function getData()
    {
        global $adb;
        $salesorder_focus=CRMEntity::getInstance("SalesOrder");
        $selectmodule_focus=CRMEntity::getInstance($this->selectmodule);
       
        //获取合计
        $columnname=$this->totalweightcolumname;
        $focus=CRMEntity::getInstance($this->selectmodule);
        $tablename=$focus->table_name;
        $tablescf=$focus->customFieldTable[0];
        $table_index=$focus->table_index;
        $detailtable=$focus->Detail_table;
        $detailtablescf=$focus->Detail_table_scf;
        
        if($columnname=="'1'")
        {
            $decimallen=0;
        }
        else
        {
             $detailfieldinfo=$selectmodule_focus->detailfieldobj->getFieldInfoobjBykey("columnname",$columnname);
            if(!$detailfieldinfo||$detailfieldinfo->getColumnName()=='')
             {
                    ConvertTojsonString("-1",array(),'给数量字段赋值的字段不存在！');
                    
             }
              
             $decimallen=2;
             $deploy_value=getSys_deploy(49);//单据明细中数量小数位数
             $decimallen=$deploy_value['deploy_value'];
            $totalweigtsql=" select sum(ifnull($columnname,0)) as  totalweight,$detailtable.id as mainid  from $detailtable
            inner join $detailtablescf on $detailtablescf.lineitem_id=$detailtable.lineitem_id
            where $detailtable.id=? ";
      }
        
        //获取运输单的客户报价单的id,编号。客户报价单合计,客户报价单明细
     
        if(!empty($totalweigtsql))
        {
             $sql=" select ld_salesorder.salesorderid,ld_salesorder.salesorder_no,totalweight,ld_salesorder.currency_id as source_currencyid
                    ,ld_salesorderdetail.*,ld_salesorderdetailscf.*,ld_products.*,ld_productcf.*  from $tablename 
                     inner join ($totalweigtsql) as tmp_totalweight on tmp_totalweight.mainid =$tablename.$table_index 
                     inner join ld_salesorder  on ld_salesorder.salesorderid=$tablename.salesorderid
                     inner join ld_salesorderdetail on  ld_salesorderdetail.id=ld_salesorder.salesorderid 
                     inner join ld_salesorderdetailscf on ld_salesorderdetail.lineitem_id=ld_salesorderdetailscf.lineitem_id
                     inner join ld_products on ld_products.productid=ld_salesorderdetail.productid
                     inner join ld_productcf on ld_productcf.productid=ld_products.productid
                     
                    ";
           
            
             if($this->selectmodule=='CustomForm23')
             {
                //运输订单b.服务项目=运输：自动带出报价单中“启运地”、“目的地”和运输订单“装货地点”、“送货地点”一致，并且“车型”和运输订单一致的分录信息
                //运输订单：sf158:启运地，sf161:送货地点，carriage_type：车型
                //客户报价单 sf5099:起运地,sf5235:目的地，_sf5371：车型
                
                // @edit:luyx @date:2020-08-19 @reason: 运输的应收、应付费用单“数量（计费数值）”计算
                //原算法:
                    //1、“数量”是带出运输订单分录的毛重“合计”。增加判断：如果	运输订单“零担”为“是”，则取单据头的“计费重量”，不是才取单据分录毛重合计
                    //2、 CustomForm23 零担 ：cf_3052,计费重量：cf_3076
                //新算法:
                    //1、不管是不是零担，都从单据头抓取
                    //2、如果费用项目是“客户端装/卸货费”取单据头字段“计费数值” cf_3825；其他费用项目取单据头字段“计费重量” cf_3076

                /*
                $totalweigtsql=" select case when ld_customform23scf.cf_3052='是' then cf_3076 else sum(ifnull($columnname,0)) end as  totalweight,$detailtable.id as mainid
                  from $detailtable  inner join ld_customform23scf on ld_customform23scf.customform23id=$detailtable.id
                    inner join $detailtablescf on $detailtablescf.lineitem_id=$detailtable.lineitem_id
                      where $detailtable.id=? ";
                */
                $totalweigtsql="
                    SELECT
                    	ld_customform23scf.cf_3076 AS total_zhongliang,
                    	ld_customform23scf.cf_3825 AS total_shuzi,
                    	ld_customform23scf.customform23id AS mainid
                    FROM ld_customform23scf
                    WHERE ld_customform23scf.customform23id =?";
                     
                $sql="
                    SELECT 
                        ld_salesorder.salesorderid,
                        ld_salesorder.salesorder_no,
                    	CASE 
                    		WHEN ld_products.productname IN ('客户端装/卸货费','Kitting费') THEN tmp_totalweight.total_shuzi
                    		ELSE tmp_totalweight.total_zhongliang
                    	END AS totalweight,
                        ld_salesorder.currency_id as source_currencyid,
                        ld_salesorderdetail.*,
                        ld_salesorderdetailscf.*,
                        ld_products.*,
                        ld_productcf.*  
                    FROM $tablename 
                    INNER JOIN $detailtable on $detailtable.id=$tablename.$table_index
                    INNER JOIN $detailtablescf on $detailtablescf.lineitem_id=$detailtable.lineitem_id
                    INNER JOIN ($totalweigtsql) as tmp_totalweight on tmp_totalweight.mainid =$tablename.$table_index 
                    INNER JOIN ld_salesorder  on ld_salesorder.salesorderid=$tablename.salesorderid
                    INNER JOIN ld_salesorderdetail on  ld_salesorderdetail.id=ld_salesorder.salesorderid 
                    INNER JOIN ld_salesorderdetailscf on ld_salesorderdetail.lineitem_id=ld_salesorderdetailscf.lineitem_id
                        AND (
                            ( $tablename.carriage_type=ld_salesorderdetailscf.sf5371 AND $detailtablescf.sf158=ld_salesorderdetailscf.sf5099 AND $detailtablescf.sf161=ld_salesorderdetailscf.sf5235)
                             OR ( ifnull(ld_salesorderdetailscf.sf5099,'')='' AND ifnull(ld_salesorderdetailscf.sf5235,'')='' AND ifnull(ld_salesorderdetailscf.sf5371,'')='')
                        )
                    INNER JOIN ld_products on ld_products.productid=ld_salesorderdetail.productid
                    INNER JOIN ld_productcf on ld_productcf.productid=ld_products.productid
                    ";
             }
            
             else if($this->selectmodule=='Commission')
             {
                $totalweigtsql=" select sum(ifnull($columnname,0)) as  totalweight,$detailtable.commission_id as mainid  from $detailtable
            inner join $detailtablescf on $detailtablescf.commission2payment_id=$detailtable.commission2payment_id
            where $detailtable.commission_id=? ";
            
                //出入库
                $port=$_REQUEST['port'];
                //c.服务项目=出入库：则根据选定的业务单据和“Port”，自动带报价单中对应“Port”的单据分录
                $sql=" select ld_salesorder.salesorderid,ld_salesorder.salesorder_no,totalweight,ld_salesorder.currency_id as source_currencyid
                    ,ld_salesorderdetail.*,ld_salesorderdetailscf.*,ld_products.*,ld_productcf.*  from $tablename 
                     inner join ($totalweigtsql) as tmp_totalweight on tmp_totalweight.mainid =$tablename.$table_index 
                     inner join ld_salesorder  on ld_salesorder.salesorderid=$tablename.salesorderid
                     inner join ld_salesorderdetail on  ld_salesorderdetail.id=ld_salesorder.salesorderid 
                     inner join ld_salesorderdetailscf on ld_salesorderdetail.lineitem_id=ld_salesorderdetailscf.lineitem_id
                     inner join ld_products on ld_products.productid=ld_salesorderdetail.productid
                     inner join ld_productcf on ld_productcf.productid=ld_products.productid
                     where ld_salesorderdetailscf.sf8499='$port' 
                    ";
             }
			 
			 //local配送 添加车型
			 else if($this->selectmodule=='CustomForm27') {
				 
				 $sql=" select ld_salesorder.salesorderid,ld_salesorder.salesorder_no,totalweight,ld_salesorder.currency_id as source_currencyid
                    ,ld_salesorderdetail.*,ld_salesorderdetailscf.*,ld_products.*,ld_productcf.*  from $tablename 
                     inner join ($totalweigtsql) as tmp_totalweight on tmp_totalweight.mainid =$tablename.$table_index 
                     inner join ld_salesorder  on ld_salesorder.salesorderid=$tablename.salesorderid
                     inner join ld_salesorderdetail on  ld_salesorderdetail.id=ld_salesorder.salesorderid 
                     inner join ld_salesorderdetailscf on ld_salesorderdetail.lineitem_id=ld_salesorderdetailscf.lineitem_id
					   and ($tablename.carriage_type=ld_salesorderdetailscf.sf5371 or ifnull(ld_salesorderdetailscf.sf5371,'')='')
                     inner join ld_products on ld_products.productid=ld_salesorderdetail.productid
                     inner join ld_productcf on ld_productcf.productid=ld_products.productid
                    "; 
			 }
			 
			 //空运 添加启运港 目的港
			 // else if($this->selectmodule=='CustomForm24') {
				 
				 // $sql=" select ld_salesorder.salesorderid,ld_salesorder.salesorder_no,totalweight,ld_salesorder.currency_id as source_currencyid
                    // ,ld_salesorderdetail.*,ld_salesorderdetailscf.*,ld_products.*,ld_productcf.*  from $tablename 
                     // inner join ($totalweigtsql) as tmp_totalweight on tmp_totalweight.mainid =$tablename.$table_index 
                     // inner join ld_salesorder  on ld_salesorder.salesorderid=$tablename.salesorderid
                     // inner join ld_salesorderdetail on  ld_salesorderdetail.id=ld_salesorder.salesorderid 
                     // inner join ld_salesorderdetailscf on ld_salesorderdetail.lineitem_id=ld_salesorderdetailscf.lineitem_id
					   // and ( ($tablename.start_port=ld_salesorderdetailscf.sf11083 and $tablename.end_port=ld_salesorderdetailscf.sf11219) 
					          // or (ifnull(ld_salesorderdetailscf.sf11083,'')='' and ifnull(ld_salesorderdetailscf.sf11219,'')='') )
                     // inner join ld_products on ld_products.productid=ld_salesorderdetail.productid
                     // inner join ld_productcf on ld_productcf.productid=ld_products.productid
					 // where ld_products.productid = ''
                    // "; 
			 // }
			 
            $sql.=' order by ld_salesorderdetail.lineitem_id asc ';
            //dump($sql);
             $result=$adb->pquery($sql,array($this->selectid));
        }
        else{
            //海运，空运的服务项目默认值为1
            /*$sql=" select ld_salesorder.salesorderid,ld_salesorder.salesorder_no,'1' as totalweight
             ,ld_salesorder.currency_id as source_currencyid
            ,ld_salesorderdetail.*,ld_salesorderdetailscf.*,ld_products.*,ld_productcf.*  from $tablename 
             
             inner join ld_salesorder  on ld_salesorder.salesorderid=$tablename.salesorderid
             inner join ld_salesorderdetail on  ld_salesorderdetail.id=ld_salesorder.salesorderid 
             inner join ld_salesorderdetailscf on ld_salesorderdetail.lineitem_id=ld_salesorderdetailscf.lineitem_id
             inner join ld_products on ld_products.productid=ld_salesorderdetail.productid
             inner join ld_productcf on ld_productcf.productid=ld_products.productid
             where $tablename.$table_index=?
             order by ld_salesorderdetail.lineitem_id asc  ";*/
              if($this->selectmodule=='CustomForm22')
             {
                //报关单
                //a.服务项目=报关：获取选定的“报关单”的“申报口岸”，自动带出客户报价单中“出口口岸”或者“进口口岸”（因进出口类型而异）=“申报口岸”的记录
                
                /* $sql=" select ld_salesorder.salesorderid,ld_salesorder.salesorder_no,'1' as totalweight,$tablename.port_no 
                    ,ld_salesorderdetail.*,ld_salesorderdetailscf.*,ld_products.*,ld_productcf.*  from $tablename 
                    
                     inner join ld_salesorder  on ld_salesorder.salesorderid=$tablename.salesorderid
                     inner join ld_salesorderdetail on  ld_salesorderdetail.id=ld_salesorder.salesorderid 
                     inner join ld_salesorderdetailscf on ld_salesorderdetail.lineitem_id=ld_salesorderdetailscf.lineitem_id
                     and ($tablename.port_no=ld_salesorderdetailscf.sf1291 or $tablename.port_no=ld_salesorderdetailscf.sf1427)
                     inner join ld_products on ld_products.productid=ld_salesorderdetail.productid
                     inner join ld_productcf on ld_productcf.productid=ld_products.productid
                      where $tablename.$table_index=?
                      order by ld_salesorderdetail.lineitem_id asc  ";*/
                      
                    
                  /**
                 * CustomForm22 declare_type：报关类型 ,entry_customs:入境关别,exit_customs:出境关别
                 * edit:can 20200811
                
                 费用单->服务项目=报关：
                    进口类型的报关单，根据报关单的“进境关别”带出报价单中“进口口岸”相匹配的数据
                    出口类型的报关单，根据报关单的“出境关别”带出报价单中“出口口岸”相匹配的数据
                
                **/
                //SalesOrder ：sf1427（进口口岸） ，sf1291（出口口岸）
                
                $sql=" select ld_salesorder.salesorderid,ld_salesorder.salesorder_no,'1' as totalweight
                    ,ld_salesorder.currency_id as source_currencyid
                    ,ld_salesorderdetail.*,ld_salesorderdetailscf.*,ld_products.*,ld_productcf.*  from $tablename 
                     
                     inner join ld_salesorder  on ld_salesorder.salesorderid=$tablename.salesorderid
                     inner join ld_salesorderdetail on  ld_salesorderdetail.id=ld_salesorder.salesorderid 
                     inner join ld_salesorderdetailscf on ld_salesorderdetail.lineitem_id=ld_salesorderdetailscf.lineitem_id
                     and  case when ($tablename.declare_type='进口')  then $tablename.entry_customs=ld_salesorderdetailscf.sf1427
                            when ($tablename.declare_type='出口')  then $tablename.exit_customs=ld_salesorderdetailscf.sf1291
                            end 
                     inner join ld_products on ld_products.productid=ld_salesorderdetail.productid
                     inner join ld_productcf on ld_productcf.productid=ld_products.productid
                     where $tablename.$table_index=?
                     order by ld_salesorderdetail.lineitem_id asc
                    ";
                
                     
             }
             else if($this->selectmodule=='CustomForm21')
             {
                //海运
                //xiangxing： 柜型(customform21)
                //sf31940:柜型（客户报价单）
                $sql=" select ld_salesorder.salesorderid,ld_salesorder.salesorder_no,'1' as totalweight
                    ,ld_salesorder.currency_id as source_currencyid
                    ,ld_salesorderdetail.*,ld_salesorderdetailscf.*,ld_products.*,ld_productcf.*  from $tablename 
                     inner join ld_salesorder  on ld_salesorder.salesorderid=$tablename.salesorderid
                     inner join ld_salesorderdetail on  ld_salesorderdetail.id=ld_salesorder.salesorderid 
                     inner join ld_salesorderdetailscf on ld_salesorderdetail.lineitem_id=ld_salesorderdetailscf.lineitem_id
                      and ($tablename.xiangxing=ld_salesorderdetailscf.sf31940 or ifnull(ld_salesorderdetailscf.sf31940,'')='')
                      inner join ld_products on ld_products.productid=ld_salesorderdetail.productid
                     inner join ld_productcf on ld_productcf.productid=ld_products.productid
                      where $tablename.$table_index=?
                     order by ld_salesorderdetail.lineitem_id asc ";
                     
                
             }
			 
			 
            
             $result=$adb->pquery($sql,array($this->selectid));
        }
    // echo $this->selectid;
    //  dump($sql);
         $rows=$adb->num_rows($result);
      
        
         $salesorderdetailfieldobj=$salesorder_focus->detailfieldobj;
         $modulefields=$salesorderdetailfieldobj->getModuleFields();
         crm_load_class_file('showProductDetailFieldValue','include/fields');
         
         $arr=array();
         for($i=0;$i<$rows;$i++)
         {
            $salesorderid=$adb->query_result($result,$i,'salesorderid');
            $saleorder_no=$adb->query_result($result,$i,'salesorder_no');//local配送单客户报价单编号
            $totalweight=$adb->query_result($result,$i,'totalweight');//local配送单计费总重量的合计
            $currency_id=$adb->query_result($result,$i,'source_currencyid');
            $lineitem_id=$adb->query_result($result,$i,'lineitem_id');
            $productid=$adb->query_result($result,$i,'productid');
            $totalweight=number_format($totalweight, $decimallen, '.', '');//setNumberFormat($totalweight,$decimallen);
          
            foreach($modulefields as $tmpcolumnname=>$salesorder_detailfieldinfo)
            {
              
                    
                $value=$adb->query_result($result,$i,$tmpcolumnname);
                      
                $rawValue=$value;
                $tablename=$salesorder_detailfieldinfo->getTableName();
                if($tablename=='ld_products'||$tablename=='ld_productcf')
                {
                      $showfieldvalueobj=new ShowFieldValue($salesorder_focus->fieldobj,"SalesOrder",SHOW_POPUP);
                }
                else
                {
                    $showfieldvalueobj=new showProductDetailFieldValue($salesorder_focus->fieldobj,"SalesOrder",SHOW_DETAILVIEW);
                    $showfieldvalueobj->setLine_index($i);
                    $showfieldvalueobj->setModuleFields($modulefields);
                }
                $showfieldvalueobj->setRecorId($salesorderid);
                $showfieldvalueobj->setadbResult($result);
               
                $showvalue=$showfieldvalueobj->getFieldValueByField($salesorder_detailfieldinfo,$rawValue,$value);
                
                $arr['detailfieldvalue'][$lineitem_id][$tmpcolumnname]=$showvalue['value'];
                 
                
            }
          
            //$detailfieldinfo=$selectmodule_focus->fieldobj->getFieldInfoobjBykey("columnname","port_no");//服务项目是报关，分录出口口岸字段
            //if($detailfieldinfo)
           // {
               // $arr['detailfieldvalue'][$lineitem_id]['sf1291']=$adb->query_result($result,$i,'port_no');
           // }
            
            $arr['detailfieldvalue'][$lineitem_id]['fendan_charging']=$adb->query_result($result,$i,'fendan_charging');
            $arr['detailfieldvalue'][$lineitem_id]['quantity']=$totalweight;
            //$arr['detailfieldvalue'][$lineitem_id]['productid']=$productid;
            $arr['detailfieldvalue'][$lineitem_id]['hdnProductId']=$productid;
            
            $arr['detailfieldvalue'][$lineitem_id]['lineitem_id']=$lineitem_id;
            $arr['detailfieldvalue'][$lineitem_id]['batchmanagement']=0;
            $arr['detailfieldvalue'][$lineitem_id]['pricestrategyobj']=array();
            
         }
         
         if($rows<=0)
         {
            $sql="select ld_salesorder.salesorderid,ld_salesorder.salesorder_no,ld_salesorder.currency_id as source_currencyid from $tablename 
                  inner join ld_salesorder  on ld_salesorder.salesorderid=$tablename.salesorderid
                   where  $tablename.$table_index=? ";
                  
            $result=$adb->pquery($sql,array($this->selectid));
            $salesorderid=$adb->query_result($result,0,'salesorderid');
            $saleorder_no=$adb->query_result($result,0,'salesorder_no');
            $currency_id=$adb->query_result($result,0,'source_currencyid');
         }
         //$arr['totalweight']=$totalweight;
         $arr['salesorderid']=$salesorderid;
         $arr['salesorder_no']=$saleorder_no;
         $arr['currency_id']=$currency_id;
        
        
         return $arr;
    }
}


?>