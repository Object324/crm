<?php
/**
 * can 20200805
 * 应付费用单获取供应商报价单明细信息
 * */
class cls_getLangJiePurchaseOrderInfo
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
            case "CustomForm28"://配送任务单
                $this->totalweightcolumname='sf390';//配送订单分录计费重量，是配送订单
                break;
            case "CustomForm02"://运输单
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
        $purchaseorderfocus=CRMEntity::getInstance("PurchaseOrder");
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
            /* $detailfieldinfo=$selectmodule_focus->detailfieldobj->getFieldInfoobjBykey("columnname",$columnname);
            if(!$detailfieldinfo||$detailfieldinfo->getColumnName()=='')
             {
                    ConvertTojsonString("-1",array(),'给数量字段赋值的字段不存在！');
                    
             }*/
              
             $decimallen=2;
             $deploy_value=getSys_deploy(49);//单据明细中数量小数位数
            $decimallen=$deploy_value['deploy_value'];
            $totalweigtsql=" select sum(ifnull($columnname,0)) as  totalweight,$detailtable.id as mainid  from $detailtable
            inner join $detailtablescf on $detailtablescf.lineitem_id=$detailtable.lineitem_id
            where $detailtable.id=? ";
            if($this->selectmodule=='CustomForm28')
             {
                //配送任务单分录计费重量
                $totalweigtsql="select sum(ifnull(ld_customform27detailscf.sf390,0))as  totalweight,$detailtable.id as mainid from 
                                ld_customform27 INNER JOIN
                                ld_customform27detail on ld_customform27.customform27id=ld_customform27detail.id
                                
                                INNER JOIN  $detailtable on 
                                $detailtable.entitytypeid=ld_customform27detail.id
                                INNER JOIN ld_customform27detailscf on ld_customform27detailscf.lineitem_id=ld_customform27detail.lineitem_id
                                where ld_customform27.deleted=0 and $detailtable.id=? ";
                                
             }
             
      }
       
        //获取运输单的客户报价单的id,编号。客户报价单合计,客户报价单明细
      
        if(!empty($totalweigtsql))
        {
             $sql=" select ld_purchaseorder.purchaseorderid,ld_purchaseorder.purchaseorder_no,totalweight
                    ,ld_purchaseorder.currency_id as source_currency_id
                    ,ld_purchaseorderdetail.*,ld_purchaseorderdetailscf.*,ld_products.*,ld_productcf.*  from $tablename 
                     inner join ($totalweigtsql) as tmp_totalweight on tmp_totalweight.mainid =$tablename.$table_index 
                     inner join ld_purchaseorder  on ld_purchaseorder.purchaseorderid=$tablename.purchaseorder_id
                     inner join ld_purchaseorderdetail on  ld_purchaseorderdetail.id=ld_purchaseorder.purchaseorderid 
                     inner join ld_purchaseorderdetailscf on ld_purchaseorderdetail.lineitem_id=ld_purchaseorderdetailscf.lineitem_id
                     inner join ld_products on ld_products.productid=ld_purchaseorderdetail.productid
                     inner join ld_productcf on ld_productcf.productid=ld_products.productid
                     
                    ";
           
            
            
             if($this->selectmodule=='Commission')
             {
                //出入库
                $totalweigtsql=" select sum(ifnull($columnname,0)) as  totalweight,$detailtable.commission_id as mainid  from $detailtable
            inner join $detailtablescf on $detailtablescf.commission2payment_id=$detailtable.commission2payment_id
            where $detailtable.commission_id=? ";
            
                //出入库
                $port=$_REQUEST['port'];
                //c.服务项目=出入库：则根据选定的业务单据和“Port”，自动带报价单中对应“Port”的单据分录
                $sql=" select ld_purchaseorder.purchaseorderid,ld_purchaseorder.purchaseorder_no,totalweight
                ,ld_purchaseorder.currency_id as source_currency_id
                    ,ld_purchaseorderdetail.*,ld_purchaseorderdetailscf.*,ld_products.*,ld_productcf.*  from $tablename 
                     inner join ($totalweigtsql) as tmp_totalweight on tmp_totalweight.mainid =$tablename.$table_index 
                     inner join ld_purchaseorder  on ld_purchaseorder.purchaseorderid=$tablename.purchaseorder_id
                     inner join ld_purchaseorderdetail on  ld_purchaseorderdetail.id=ld_purchaseorder.purchaseorderid 
                     inner join ld_purchaseorderdetailscf on ld_purchaseorderdetail.lineitem_id=ld_purchaseorderdetailscf.lineitem_id
                     inner join ld_products on ld_products.productid=ld_purchaseorderdetail.productid
                     inner join ld_productcf on ld_productcf.productid=ld_products.productid
                     where ld_purchaseorderdetailscf.sf8499='$port' 
                    ";
             }
              
            $sql.=' order by ld_purchaseorderdetail.lineitem_id asc ';
            //dump($sql);
             $result=$adb->pquery($sql,array($this->selectid));
        }
        else{
            //海运，空运的服务项目默认值为1
           /* $sql=" select ld_purchaseorder.purchaseorderid,ld_purchaseorder.purchaseorder_no,'1' as totalweight
            ,ld_purchaseorder.currency_id as source_currency_id
            ,ld_purchaseorderdetail.*,ld_purchaseorderdetailscf.*,ld_products.*,ld_productcf.*  from $tablename 
             
             inner join ld_purchaseorder  on ld_purchaseorder.purchaseorderid=$tablename.purchaseorder_id
             inner join ld_purchaseorderdetail on  ld_purchaseorderdetail.id=ld_purchaseorder.purchaseorderid 
             inner join ld_purchaseorderdetailscf on ld_purchaseorderdetail.lineitem_id=ld_purchaseorderdetailscf.lineitem_id
             inner join ld_products on ld_products.productid=ld_purchaseorderdetail.productid
             inner join ld_productcf on ld_productcf.productid=ld_products.productid
             where $tablename.$table_index=?
             order by ld_purchaseorderdetail.lineitem_id asc  ";*/
             
              if($this->selectmodule=='CustomForm22')
             {
                //报关单
                //a.服务项目=报关：获取选定的“报关单”的“申报口岸”，自动带出客户报价单中“出口口岸”或者“进口口岸”（因进出口类型而异）=“申报口岸”的记录
                
               /*  $sql=" select ld_purchaseorder.purchaseorderid,ld_purchaseorder.purchaseorder_no,'1' as totalweight,$tablename.port_no 
                    ,ld_purchaseorderdetail.*,ld_purchaseorderdetailscf.*,ld_products.*,ld_productcf.*  from $tablename 
                    
                     inner join ld_purchaseorder  on ld_purchaseorder.purchaseorderid=$tablename.purchaseorder_id
                     inner join ld_purchaseorderdetail on  ld_purchaseorderdetail.id=ld_purchaseorder.purchaseorderid 
                     inner join ld_purchaseorderdetailscf on ld_purchaseorderdetail.lineitem_id=ld_purchaseorderdetailscf.lineitem_id
                     and ($tablename.port_no=ld_purchaseorderdetailscf.sf1291 or $tablename.port_no=ld_purchaseorderdetailscf.sf1427)
                     inner join ld_products on ld_products.productid=ld_purchaseorderdetail.productid
                     inner join ld_productcf on ld_productcf.productid=ld_products.productid
                      where $tablename.$table_index=?
                      order by ld_purchaseorderdetail.lineitem_id asc 
                    ";*/
                
                  /**
                 * CustomForm22 declare_type：报关类型 ,entry_customs:入境关别,exit_customs:出境关别
                 * edit:can 20200811
                
                 费用单->服务项目=报关：
                    进口类型的报关单，根据报关单的“进境关别”带出报价单中“进口口岸”相匹配的数据
                    出口类型的报关单，根据报关单的“出境关别”带出报价单中“出口口岸”相匹配的数据
                
                **/
                //SalesOrder ：sf1427（进口口岸） ，sf1291（出口口岸）
                
                $sql=" select ld_purchaseorder.purchaseorderid,ld_purchaseorder.purchaseorder_no,'1' as totalweight
                ,ld_purchaseorder.currency_id as source_currency_id
                    ,ld_purchaseorderdetail.*,ld_purchaseorderdetailscf.*,ld_products.*,ld_productcf.*  from $tablename 
                    
                     inner join ld_purchaseorder  on ld_purchaseorder.purchaseorderid=$tablename.purchaseorder_id
                     inner join ld_purchaseorderdetail on  ld_purchaseorderdetail.id=ld_purchaseorder.purchaseorderid 
                     inner join ld_purchaseorderdetailscf on ld_purchaseorderdetail.lineitem_id=ld_purchaseorderdetailscf.lineitem_id
                     and  case when ($tablename.declare_type='进口')  then $tablename.entry_customs=ld_purchaseorderdetailscf.sf1427
                            when ($tablename.declare_type='出口')  then $tablename.exit_customs=ld_purchaseorderdetailscf.sf1291
                            end 
                     inner join ld_products on ld_products.productid=ld_purchaseorderdetail.productid
                     inner join ld_productcf on ld_productcf.productid=ld_products.productid
                     where $tablename.$table_index=?
                     order by ld_purchaseorderdetail.lineitem_id asc
                    ";
                     
             }
             else if($this->selectmodule=='CustomForm21')
             {
                //海运
                //xiangxing： 柜型(customform21)
                //sf31940:柜型（供应商报价单）
                $sql=" select ld_purchaseorder.purchaseorderid,ld_purchaseorder.purchaseorder_no,'1' as totalweight
                  ,ld_purchaseorder.currency_id as source_currency_id
                    ,ld_purchaseorderdetail.*,ld_purchaseorderdetailscf.*,ld_products.*,ld_productcf.*  from $tablename 
                     inner join ld_purchaseorder  on ld_purchaseorder.purchaseorderid=$tablename.purchaseorder_id
                     inner join ld_purchaseorderdetail on  ld_purchaseorderdetail.id=ld_purchaseorder.purchaseorderid 
                     inner join ld_purchaseorderdetailscf on ld_purchaseorderdetail.lineitem_id=ld_purchaseorderdetailscf.lineitem_id
                      and ($tablename.xiangxing=ld_purchaseorderdetailscf.sf31940 or ifnull(ld_purchaseorderdetailscf.sf31940,'')='')
                      inner join ld_products on ld_products.productid=ld_purchaseorderdetail.productid
                     inner join ld_productcf on ld_productcf.productid=ld_products.productid
                      where $tablename.$table_index=?
                     order by ld_purchaseorderdetail.lineitem_id asc ";
                     
                
             }
             $result=$adb->pquery($sql,array($this->selectid));
        }
        //echo $this->selectid;
       //dump($sql);
         $rows=$adb->num_rows($result);
        
        
         
        
         $purchaseorderdetailfieldobj=$purchaseorderfocus->detailfieldobj;
         $modulefields=$purchaseorderdetailfieldobj->getModuleFields();
         crm_load_class_file('showProductDetailFieldValue','include/fields');
         
         $arr=array();
         for($i=0;$i<$rows;$i++)
         {
            $purchaseorderid=$adb->query_result($result,$i,'purchaseorderid');
            $purchaseorder_no=$adb->query_result($result,$i,'purchaseorder_no');//local配送单客户报价单编号
            $currency_id=$adb->query_result($result,$i,'source_currency_id');
            $totalweight=$adb->query_result($result,$i,'totalweight');//local配送单计费总重量的合计
            $lineitem_id=$adb->query_result($result,$i,'lineitem_id');
            $productid=$adb->query_result($result,$i,'productid');
            $totalweight=number_format($totalweight, $decimallen, '.', '');
            
            foreach($modulefields as $tmpcolumnname=>$purchaseorderdetailfieldinfo)
            {
              
                    
                $value=$adb->query_result($result,$i,$tmpcolumnname);
                      
      
                $rawValue=$value;
                $tablename=$purchaseorderdetailfieldinfo->getTableName();
                if($tablename=='ld_products'||$tablename=='ld_productcf')
                {
                      $showfieldvalueobj=new ShowFieldValue($purchaseorderfocus->fieldobj,"PurchaseOrder",SHOW_POPUP);
                }
                else
                {
                    $showfieldvalueobj=new showProductDetailFieldValue($purchaseorderfocus->fieldobj,"PurchaseOrder",SHOW_DETAILVIEW);
                    $showfieldvalueobj->setLine_index($i);
                    $showfieldvalueobj->setModuleFields($modulefields);
                }
                $showfieldvalueobj->setRecorId($purchaseorderid);
                $showfieldvalueobj->setadbResult($result);
               
                $showvalue=$showfieldvalueobj->getFieldValueByField($purchaseorderdetailfieldinfo,$rawValue,$value);
                  
                $arr['detailfieldvalue'][$lineitem_id][$tmpcolumnname]=$showvalue['value'];
                
                
            }
          
        //    $detailfieldinfo=$selectmodule_focus->fieldobj->getFieldInfoobjBykey("columnname","port_no");//服务项目是报关，分录出口口岸字段
          //  if($detailfieldinfo)
          //  {
                //$arr['detailfieldvalue'][$lineitem_id]['sf1291']=$adb->query_result($result,$i,'port_no');
          //  }
            $arr['detailfieldvalue'][$lineitem_id]['fendan_charging']=$adb->query_result($result,$i,'fendan_charging');
            $arr['detailfieldvalue'][$lineitem_id]['quantity']=$totalweight;
            $arr['detailfieldvalue'][$lineitem_id]['hdnProductId']=$productid;
            
            $arr['detailfieldvalue'][$lineitem_id]['lineitem_id']=$lineitem_id;
            $arr['detailfieldvalue'][$lineitem_id]['batchmanagement']=0;
            $arr['detailfieldvalue'][$lineitem_id]['pricestrategyobj']=array();
            
         }
         
         if($rows<=0)
         {
            $sql="select ld_purchaseorder.purchaseorderid,ld_purchaseorder.purchaseorder_no,ld_purchaseorder.currency_id as source_currency_id from $tablename 
                  inner join ld_purchaseorder  on ld_purchaseorder.purchaseorderid=$tablename.purchaseorder_id
                   where  $tablename.$table_index=? ";
                  
            $result=$adb->pquery($sql,array($this->selectid));
            $purchaseorderid=$adb->query_result($result,0,'purchaseorderid');
            $purchaseorder_no=$adb->query_result($result,0,'purchaseorder_no');
            $currency_id=$adb->query_result($result,0,'source_currency_id');
         }
         $arr['purchaseorderid']=$purchaseorderid;
         $arr['purchaseorder_no']=$purchaseorder_no;
         $arr['currency_id']=$currency_id;
         return $arr;
    }
}


?>