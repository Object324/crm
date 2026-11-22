<?php
class CommonView

{
       /**
        * edit:cyb
        * date:2016-04-18
        * ���������ĸ����飬���ڱ��������ѯ��ѡ��ʱ��Ρ��ֶ�������Ĭ����ʾֵ
       **/        
       //��ȥѡ��     
       static $lastdays=Array(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,30,60,90,120,180); 
       //֮ǰѡ��
       static $beforedays=Array(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,30,60,90,120,180);
       //δ��ѡ��
       static $nextdays=Array(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,30,60,90,120,180);
       //֮��ѡ��
       static $afterdays=Array(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,30,60,90,120,180);
   
       static function ChangeTypeOfData_Filter($table_name, $column_name, $type_of_data) 
       {
        	global $adb;
        	
        	$field = $table_name . ":" . $column_name;
        	//Add the field details in this array if you want to change the advance filter field details
        	$new_field_details = Array(
        		//Contacts Related Fields
        		"ld_contactdetails:accountid" => "V",
        		"ld_contactsubdetails:birthday" => "D",
        		"LDcontactdetails:email" => "V",
        		"ld_contactdetails:secondaryemail" => "V",
        		//Potential Related Fields
        		"ld_potential:campaignid" => "V",
        		//Account Related Fields
        		"ld_account:parentid" => "V",
        		"ld_account:email1" => "V",
        		"ld_account:email2" => "V",
        		//Lead Related Fields
        		"ld_leaddetails:email" => "V",
        		"ld_leaddetails:secondaryemail" => "V",
        		//Documents Related Fields
        		"ld_senotesrel:crmid" => "V",
        		//Calendar Related Fields
        		"ld_seactivityrel:crmid" => "V",
        		"ld_seactivityrel:contactid" => "V",
        		"ld_recurringevents:recurringtype" => "V",
        		//HelpDesk Related Fields
        		"ld_troubletickets:parent_id" => "V",
        		"ld_troubletickets:product_id" => "V",
        		//Product Related Fields
        		"ld_products:discontinued" => "C",
        		"ld_products:vendor_id" => "V",
        		"ld_products:parentid" => "V",
        		//Faq Related Fields
        		"ld_faq:product_id" => "V",
        		//Vendor Related Fields
        		"ld_vendor:email" => "V",
        		//Quotes Related Fields
        		"ld_quotes:potentialid" => "V",
        		"ld_quotes:inventorymanager" => "V",
        		"ld_quotes:accountid" => "V",
        		//Purchase Order Related Fields
        		"ld_purchaseorder:vendorid" => "V",
        		"ld_purchaseorder:contactid" => "V",
        		//SalesOrder Related Fields
        		"ld_salesorder:potentialid" => "V",
        		"ld_salesorder:quoteid" => "V",
        		"ld_salesorder:contactid" => "V",
        		"ld_salesorder:accountid" => "V",
        		//Invoice Related Fields
        		"ld_invoice:salesorderid" => "V",
        		"ld_invoice:contactid" => "V",
        		"ld_invoice:accountid" => "V",
        		//Campaign Related Fields
        		"ld_campaign:product_id" => "V",
        		//Related List Entries(For Report Module)
        		"ld_activityproductrel:activityid" => "V",
        		"ld_activityproductrel:productid" => "V",
        		"ld_campaigncontrel:campaignid" => "V",
        		"ld_campaigncontrel:contactid" => "V",
        		"ld_campaignleadrel:campaignid" => "V",
        		"ld_campaignleadrel:leadid" => "V",
        		"ld_cntactivityrel:contactid" => "V",
        		"ld_cntactivityrel:activityid" => "V",
        		"ld_contpotentialrel:contactid" => "V",
        		"ld_contpotentialrel:potentialid" => "V",
        		"ld_crmentitynotesrel:crmid" => "V",
        		"ld_crmentitynotesrel:notesid" => "V",
        		"ld_leadacctrel:leadid" => "V",
        		"ld_leadacctrel:accountid" => "V",
        		"ld_leadcontrel:leadid" => "V",
        		"ld_leadcontrel:contactid" => "V",
        		"ld_leadpotrel:leadid" => "V",
        		"ld_leadpotrel:potentialid" => "V",
        		"ld_pricebookproductrel:pricebookid" => "V",
        		"ld_pricebookproductrel:productid" => "V",
        		"ld_seactivityrel:crmid" => "V",
        		"ld_seactivityrel:activityid" => "V",
        		"ld_senotesrel:crmid" => "V",
        		"ld_senotesrel:notesid" => "V",
        		"ld_seproductsrel:crmid" => "V",
        		"ld_seproductsrel:productid" => "V",
        		"ld_seticketsrel:crmid" => "V",
        		"ld_seticketsrel:ticketid" => "V",
        		"ld_vendorcontactrel:vendorid" => "V",
        		"ld_vendorcontactrel:contactid" => "V",
        		"ld_pricebook:currency_id" => "V",
                "ld_cashbill:accountid" => "V",
                "ld_sendcashbill:vendorid" => "V",
        	);
        
        	//If the Fields details does not match with the array, then we return the same typeofdata
        	if (isset($new_field_details[$field])) {
        		$type_of_data = $new_field_details[$field];
        	}
        	return $type_of_data;
        }
     /**
      * ִ�б༭���߸������ݷ������ʱ��������ѯ�¡���ʼ���ڡ��͡��������ڡ�ȡֵ
      **/
     static function getDateforStdFilterBytype($type) {	

        $thisyear = date("Y");
		$today = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d"), date("Y")));
		$tomorrow = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 1, date("Y")));
		$syesterday = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 1, date("Y")));

		$currentmonth0 = date("Y-m-d", mktime(0, 0, 0, date("m"), "01", date("Y")));
		$currentmonth1 = date("Y-m-t");
		$lastmonth0 = date("Y-m-d", mktime(0, 0, 0, date("m") - 1, "01", date("Y")));
		$lastmonth1 = date('Y-m-d', strtotime("$lastmonth0 +1 month -1 day"));
        $thismonth0 = $currentmonth0;
        $thismonth1 = $currentmonth1;
		$nextmonth0 = date("Y-m-d", mktime(0, 0, 0, date("m") + 1, "01", date("Y")));
		$nextmonth1 = date('Y-m-d', strtotime("$nextmonth0 +1 month -1 day"));

		$lastweek0 = date("Y-m-d",mktime(0, 0, 0,date("m"),date("d")-date("w")-6,date("Y")));
		$lastweek1 = date("Y-m-d",mktime(23,59,59,date("m"),date("d")-date("w"),date("Y")));

		$thisweek0 = date("Y-m-d",mktime(0, 0, 0,date("m"),date("d")-date("w")+1,date("Y")));
		$thisweek1 = date("Y-m-d",mktime(23,59,59,date("m"),date("d")-date("w")+7,date("Y")));

		$nextweek0 = date("Y-m-d",mktime(0, 0, 0,date("m"),date("d")-date("w")+8,date("Y")));
		$nextweek1 = date("Y-m-d",mktime(23,59,59,date("m"),date("d")-date("w")+14,date("Y")));     
  
        $defaultStartDate='1960-01-01';
        $defaultEndDate='2037-12-31';  
    
		$currentFY0 = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
		$currentFY1 = date("Y-m-t", mktime(0, 0, 0, "12", date("d"), date("Y")));
		$lastFY0 = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y") - 1));
		$lastFY1 = date("Y-m-t", mktime(0, 0, 0, "12", date("d"), date("Y") - 1));
		$nextFY0 = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y") + 1));
		$nextFY1 = date("Y-m-t", mktime(0, 0, 0, "12", date("d"), date("Y") + 1));   
		
		if (date("m") <= 3) {
			//pFq 上财季
			$pFq = date("Y-m-d", mktime(0, 0, 0, "10", "01", date("Y") - 1));
			$pFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y") - 1));
			//cFq 本财季
			$cFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
			$cFq1 = date("Y-m-d", mktime(0, 0, 0, "03", "30", date("Y")));
			//nFq 下财季
			$nFq = date("Y-m-d", mktime(0, 0, 0, "04", "01", date("Y")));
			$nFq1 = date("Y-m-d", mktime(0, 0, 0, "06", "31", date("Y")));
		} else if (date("m") >= 4 and date("m") <= 6) {
			$pFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
			$pFq1 = date("Y-m-d", mktime(0, 0, 0, "03", "30", date("Y")));
			$cFq = date("Y-m-d", mktime(0, 0, 0, "04", "01", date("Y")));
			$cFq1 = date("Y-m-d", mktime(0, 0, 0, "06", "31", date("Y")));
			$nFq = date("Y-m-d", mktime(0, 0, 0, "07", "01", date("Y")));
			$nFq1 = date("Y-m-d", mktime(0, 0, 0, "09", "30", date("Y")));
		} else if (date("m") >= 7 and date("m") <= 9) {
			$pFq = date("Y-m-d", mktime(0, 0, 0, "04", "01", date("Y")));
			$pFq1 = date("Y-m-d", mktime(0, 0, 0, "06", "31", date("Y")));
			$cFq = date("Y-m-d", mktime(0, 0, 0, "07", "01", date("Y")));
			$cFq1 = date("Y-m-d", mktime(0, 0, 0, "09", "30", date("Y")));
			$nFq = date("Y-m-d", mktime(0, 0, 0, "10", "01", date("Y")));
			$nFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y")));
		}else {
			$pFq = date("Y-m-d", mktime(0, 0, 0, "07", "01", date("Y")));
			$pFq1 = date("Y-m-d", mktime(0, 0, 0, "09", "30", date("Y")));
			$cFq = date("Y-m-d", mktime(0, 0, 0, "10", "01", date("Y")));
			$cFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y")));
			$nFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y") + 1));
			$nFq1 = date("Y-m-d", mktime(0, 0, 0, "03", "30", date("Y") + 1));
		}
       
		// prevfq 上财季
         $stddateEntries=array
         (
                          "prevfy"=>Array($lastFY0,$lastFY1),
                          "thisfy"=>Array($currentFY0,$currentFY1),
                          "nextfy"=>Array($nextFY0,$nextFY1),
                          "prevfq"=>Array($pFq,$pFq1),
                          "thisfq"=>Array($cFq,$cFq1),
                          "nextfq"=>Array($nFq,$nFq1),
                          "syesterday"=>Array($syesterday,$syesterday),
                          "today"=>Array($today,$today),
                          "tomorrow"=>Array($tomorrow,$tomorrow),
                          "lastweek"=>Array($lastweek0,$lastweek1),
                          "thisweek"=>Array($thisweek0,$thisweek1),
                          "nextweek"=>Array($nextweek0,$nextweek1),
                          "lastmonth"=>Array($lastmonth0,$lastmonth1),
                          "thismonth"=>Array($thismonth0,$thismonth1),
                          "nextmonth"=>Array($nextmonth0,$nextmonth1)                     
                
         ); 
         /**
          * bug50201
         **/                   
        if(file_exists(globalStatic::$root_directory. 'include/CustomView_date_Config.php'))
        {
           require_once(globalStatic::$root_directory.'include/CustomView_date_Config.php');           
           $lastdays= CustomView_date_Config::$lastdays; 
           $beforedays= CustomView_date_Config::$beforedays;
           $nextdays= CustomView_date_Config::$nextdays; 
           $afterdays= CustomView_date_Config::$afterdays;                                            
        }
        else//���ļ������ڣ���������ȡֵȡĬ�ϸ���������Ϣ
        {            
           $lastdays= CommonView::$lastdays; 
           $beforedays= CommonView::$beforedays;
           $nextdays= CommonView::$nextdays; 
           $afterdays= CommonView::$afterdays;                                  
        }
        foreach($beforedays as $key_beforedays=>$value_beforedays){
            $stddateEntries['before'.$value_beforedays.'days']=Array($defaultStartDate,date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - $value_beforedays+1, date("Y"))));
        }         
        foreach($lastdays as $key_lastdays=>$value_lastdays){
            $stddateEntries['last'.$value_lastdays.'days']=Array(date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - $value_lastdays+1, date("Y"))),$today);
        }         
        foreach($nextdays as $key_nextdays=>$value_nextdays){
            $stddateEntries['next'.$value_nextdays.'days']=Array($today,date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") +$value_nextdays-1 , date("Y"))));
        }
        foreach($afterdays as $key_afterdays=>$value_afterdays){
            $stddateEntries['after'.$value_afterdays.'days']=Array(date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") +$value_afterdays-1 , date("Y"))),$defaultEndDate);
        }              
        if(array_key_exists($type,$stddateEntries)) 
        {           
            $datevalue=$stddateEntries[$type];    
	
		}else {		    
			$datevalue[0] = "";
			$datevalue[1] = "";
		}        
		return $datevalue;
	} 
    /**
     * ���ݷ����»�����ѯ�С�ѡ��ʱ��Ρ��ֶ�������ȡֵ
    **/   
    static function 	 getStdFilterCriteria($selcriteria = "") {
	
		$filter = array();
        $stdfilter =Array
                       (
                        "custom", "prevfy", "thisfy","nextfy",
                        "prevfq","thisfq","nextfq","syesterday",
                        "today","tomorrow","lastweek","thisweek",
                        "nextweek","lastmonth","thismonth","nextmonth"
                       ) ;
         /**
          * ���ݷ����»�����ѯ��ѡ��ʱ��Ρ��ֶ�������ȡֵ���������ļ����ڣ���ȡ�ļ�������(��ǰ�����δ������ȥ)
         **/        
        if(file_exists('include/CustomView_date_Config.php'))
        {
           require_once('include/CustomView_date_Config.php');           
           $lastdays= CustomView_date_Config::$lastdays; 
           $beforedays= CustomView_date_Config::$beforedays;
           $nextdays= CustomView_date_Config::$nextdays; 
           $afterdays= CustomView_date_Config::$afterdays;                                                
         }
         else//���ļ������ڣ���������ȡֵȡĬ�ϸ���������Ϣ  
         {           
            $lastdays= CommonView::$lastdays; 
            $beforedays= CommonView::$beforedays;
            $nextdays= CommonView::$nextdays; 
            $afterdays= CommonView::$afterdays;                
         } 
         foreach($beforedays as $key_beforedays=>$value_beforedays){
            $stdfilter[]='before'.$value_beforedays.'days';
         }         
         foreach($lastdays as $key_lastdays=>$value_lastdays){
            $stdfilter[]='last'.$value_lastdays.'days';
         }           
         foreach($nextdays as $key_nextdays=>$value_nextdays){
            $stdfilter[]='next'.$value_nextdays.'days';
         }
         foreach($afterdays as $key_afterdays=>$value_afterdays){
            $stdfilter[]='after'.$value_afterdays.'days';
         }             
         foreach ($stdfilter as $FilterKey => $FilterValue) {
			if ($FilterValue == $selcriteria) {
				$shtml['value'] = $FilterValue;
				$shtml['text'] = $FilterValue;               
				$shtml['selected'] = "selected";
			} else {
				$shtml['value'] = $FilterValue;
				$shtml['text'] = $FilterValue;
				$shtml['selected'] = "";
			}
			$filter[] = $shtml;
		}
        //echo '<pre>';        
        //print_r($filter);        
		return $filter;
	}
    
    static function MysqlFilterDateTimeStr()
    {
        
        static $mysqldatetimestr;
        if(!empty($mysqldatetimestr))
        {
            return $mysqldatetimestr;
        }
        $todayDateTime =" curdate() ";

		$tomorrow = " DATE_SUB(curdate(),INTERVAL -1 DAY)";
		$tomorrowDateTime = $tomorrow ;

		$syesterday = ' DATE_SUB(curdate(),INTERVAL 1 DAY)';
		$syesterdayDateTime = $syesterday ;

		$currentmonth0 = ' DATE_FORMAT( CURDATE( ) , "%Y-%m-01") ';
		$currentMonthStartDateTime = $currentmonth0 ;
		$currentmonth1 =' last_day(curdate())';
		$currentMonthEndDateTime = $currentmonth1 ;

		$lastmonth0 = ' DATE_FORMAT(last_day(DATE_SUB(curdate(), INTERVAL 1 MONTH)),"%Y-%m-01") ';
		$lastMonthStartDateTime = $lastmonth0;
		//$lastmonth1 = date("Y-m-t", strtotime("-1 Month"));
		$lastmonth1 = ' last_day(DATE_SUB(curdate(), INTERVAL 1 MONTH))';
		$lastMonthEndDateTime = $lastmonth1 ;

		$nextmonth0 =' DATE_FORMAT(last_day(DATE_SUB(curdate(), INTERVAL -1 MONTH)),"%Y-%m-01") ';
		$nextMonthStartDateTime = $nextmonth0 ;
		//$nextmonth1 = date("Y-m-t", strtotime("+1 Month"));
		$nextmonth1 = ' last_day(DATE_SUB(curdate(), INTERVAL -1 MONTH))';;
		$nextMonthEndDateTime = $nextmonth1 ;
      //  $lastweeks=" subdate(DATE_SUB(curdate(),INTERVAL 1 week),date_format(DATE_SUB(curdate(),INTERVAL 1 week),'%w')-1) ";
            
		//$lastweek0 = date("Y-m-d",mktime(0, 0, 0,date("m"),date("d")-date("w")-6,date("Y")));
		$lastWeekStartDateTime = ' subdate(DATE_SUB(curdate(),INTERVAL 1 week),date_format(DATE_SUB(curdate(),INTERVAL 1 week),"%w")-1) ' ;
	//	$lastweek1 = date("Y-m-d",mktime(23,59,59,date("m"),date("d")-date("w"),date("Y")));
		$lastWeekEndDateTime =' subdate(DATE_SUB(curdate(),INTERVAL 1 week),date_format(DATE_SUB(curdate(),INTERVAL 1 week),"%w")-7) ' ; ;
        
        
         $thisweek0=' DATE_SUB(curdate(),INTERVAL WEEKDAY(curdate()) DAY) ';
		$thisWeekStartDateTime =$thisweek0;
		//$thisweek1 = date("Y-m-d", strtotime("this sunday"));
       // $thisweek1 = date("Y-m-d",mktime(23,59,59,date("m"),date("d")-date("w")+7,date("Y")));
         $thisweek1= ' DATE_SUB(curdate(),INTERVAL WEEKDAY(curdate())-7 DAY) '; 
	  	$thisWeekEndDateTime = $thisweek1 ;
  
        
        $nextweek0=' subdate(DATE_SUB(curdate(),INTERVAL 1 week),date_format(DATE_SUB(curdate(),INTERVAL -1 week),"%w")-1) ' ;;
		$nextWeekStartDateTime = $nextweek0 ;
		//$nextweek1 = date("Y-m-d",mktime(23,59,59,date("m"),date("d")-date("w")+14,date("Y")));
        $nextweek1=' subdate(DATE_SUB(curdate(),INTERVAL 1 week),date_format(DATE_SUB(curdate(),INTERVAL -1 week),"%w")-7) ' ;
		$nextWeekEndDateTime = $nextweek1 ;	     
            
        $defaultStartDate= "1600-01-01";
        $defaultStartDateTime=$defaultStartDate ;
        $defaultEndDate="3099-12-31";
        $defaultEndDateTime=$defaultEndDate ;     
   
		$currentFY0 = ' DATE_FORMAT(curdate(),"%Y-01-01") ';
		$currentFYStartDateTime = $currentFY0 ;
		$currentFY1 = ' date_format(curdate(),"%Y-12-31") ';
		$currentFYEndDateTime = $currentFY1 ;

		$lastFY0 = ' date_format(DATE_SUB(curdate(),INTERVAL 1 year),"%Y-01-01") ';
		$lastFYStartDateTime = $lastFY0 ;
		$lastFY1 = ' date_format(DATE_SUB(curdate(),INTERVAL 1 year),"%Y-12-31") ';
		$lastFYEndDateTime =$lastFY1 ;

		$nextFY0 = ' date_format(DATE_SUB(curdate(),INTERVAL -1 year),"%Y-01-01") ';
		$nextFYStartDateTime = $nextFY0 ;
		$nextFY1 =' date_format(DATE_SUB(curdate(),INTERVAL -1 year),"%Y-12-31") ';
		$nextFYEndDateTime =$nextFY1 ;
		
        //本季度
		$cFq =' CONCAT(DATE_FORMAT(LAST_DAY(MAKEDATE(EXTRACT(YEAR FROM CURDATE()),1) + INTERVAL QUARTER(CURDATE())*3-3 MONTH),"%Y-%m-"),"01") ';
		$cFqStartDateTime = $cFq ;
		$cFq1 = ' LAST_DAY(MAKEDATE(EXTRACT(YEAR FROM CURDATE()),1) + INTERVAL QUARTER(CURDATE())*3-1 MONTH) ';
		$cFqEndDateTime = $cFq1 ;
            
            //下季度
		$nFq = ' DATE_FORMAT((MAKEDATE(EXTRACT(YEAR FROM CURDATE()),1) + INTERVAL QUARTER(CURDATE())*3 MONTH),"%Y-%m-01") ';
		$nFqStartDateTime = $nFq ;
		$nFq1 =' LAST_DAY((MAKEDATE(EXTRACT(YEAR FROM CURDATE()),1) + INTERVAL QUARTER(CURDATE())*3+2 MONTH)) ';
		$nFqEndDateTime =$nFq1;
            
        //上季度
		$pFq =' CONCAT(DATE_FORMAT(LAST_DAY(MAKEDATE(EXTRACT(YEAR FROM CURDATE()),1) + INTERVAL QUARTER(CURDATE())*3-6 MONTH),"%Y-%m-"),"01") ';//上季度
		$pFqStartDateTime =$pFq ;
		$pFq1 =' LAST_DAY(MAKEDATE(EXTRACT(YEAR FROM CURDATE()),1) + INTERVAL QUARTER(CURDATE())*3-4 MONTH) ';//上季度
		$pFqEndDateTime = $pFq1 ;
		
        
        $DateTime=array
              (
                      "prevfy"=>Array($lastFYStartDateTime,$lastFYEndDateTime,getFixedLabel('prevfy')),
                      "thisfy"=>Array($currentFYStartDateTime,$currentFYEndDateTime,getFixedLabel('thisfy')),
                      "nextfy"=>Array($nextFYStartDateTime,$nextFYEndDateTime,getFixedLabel('nextfy')),
                      "prevfq"=>Array($pFqStartDateTime,$pFqEndDateTime,getFixedLabel('prevfq')),
                      "thisfq"=>Array($cFqStartDateTime,$cFqEndDateTime,getFixedLabel('thisfq')),
                      "nextfq"=>Array($nFqStartDateTime,$nFqEndDateTime,getFixedLabel('nextfq')),
                      "syesterday"=>Array($syesterdayDateTime,$syesterdayDateTime,getFixedLabel('syesterday')),
                      "today"=>Array($todayDateTime,$todayDateTime,getFixedLabel('today')),
                      "tomorrow"=>Array($tomorrowDateTime,$tomorrowDateTime,getFixedLabel('tomorrow')),
                      "lastweek"=>Array($lastWeekStartDateTime,$lastWeekEndDateTime,getFixedLabel('lastweek')),
                      "thisweek"=>Array($thisWeekStartDateTime,$thisWeekEndDateTime,getFixedLabel('thisweek')),
                      "nextweek"=>Array($nextWeekStartDateTime,$nextWeekEndDateTime,getFixedLabel('nextweek')),
                      "lastmonth"=>Array($lastMonthStartDateTime,$lastMonthEndDateTime,getFixedLabel('lastmonth')),
                      "thismonth"=>Array($currentMonthStartDateTime,$currentMonthEndDateTime,getFixedLabel('thismonth')),
                      "nextmonth"=>Array($nextMonthStartDateTime,$nextMonthEndDateTime,getFixedLabel('nextmonth'))

             );
        
        if(file_exists('include/CustomView_date_Config.php'))
        {
           require_once('include/CustomView_date_Config.php');           
           $lastdays= CustomView_date_Config::$lastdays; 
           $beforedays= CustomView_date_Config::$beforedays;
           $nextdays= CustomView_date_Config::$nextdays; 
           $afterdays= CustomView_date_Config::$afterdays;                                                
         }
         else//���ļ������ڣ���������ȡֵȡĬ�ϸ���������Ϣ
         {            
           $lastdays= CommonView::$lastdays; 
           $beforedays= CommonView::$beforedays;
           $nextdays= CommonView::$nextdays; 
           $afterdays= CommonView::$afterdays;                          
        } 
        
        foreach($beforedays as $key_beforedays=>$value_beforedays){                 
            $DateTime['before'.$value_beforedays.'days']=Array('"'.$defaultStartDate.'"',' date_sub(curdate(),interval '.$value_beforedays.' day) ',$value_beforedays.getFixedLabel('DAYSAGO'));
        }         
        foreach($lastdays as $key_lastdays=>$value_lastdays){
            $DateTime['last'.$value_lastdays.'days']=Array(' date_sub(curdate(),interval '.$value_lastdays.' day) ',$syesterdayDateTime,getFixedLabel('LAST').$value_lastdays.getFixedLabel("Days"));
        }         
        foreach($nextdays as $key_nextdays=>$value_nextdays){
            $DateTime['next'.$value_nextdays.'days']=Array($tomorrowDateTime,' date_add(curdate(),interval '.$value_nextdays.' day) ',getFixedLabel("FUTURE").$value_nextdays.getFixedLabel("Days"));
        }
        foreach($afterdays as $key_afterdays=>$value_afterdays){
            $tmpdays=$value_afterdays-1;
            $DateTime['after'.$value_afterdays.'days']=Array(' date_add(curdate(),interval '.$tmpdays.' day) ','"'.$defaultEndDate.'"',$value_afterdays.getFixedLabel("AFTERDAY"));
        }
        $datetimestr=$DateTime;
	//	if($output_type == 'lastmodified'){
			return $DateTime;
	//	}
    }
    /**
     * 查询条件的下拉框翻译
     * 
     * */
    static function getComparatorLabel()
    {
         $fLabels['e']=getFixedLabel('EQ');
         $fLabels['n']=getFixedLabel('NEQ');
        $fLabels['c']=getFixedLabel('IN');
        $fLabels['k'] =getFixedLabel('NOT_IN');
        $fLabels['l'] =getFixedLabel('LT');
        $fLabels['g'] =getFixedLabel('GT');
        $fLabels['m'] = getFixedLabel('LE');
        $fLabels['h'] =getFixedLabel('GE');
        $fLabels['bw']=getFixedLabel('Interval');
        $fLabels['b'] =getFixedLabel('Before');
        $fLabels['a']= getFixedLabel('After');
        $fLabels['isnull']=getFixedLabel('ISNULL');
        $fLabels['isnotnull'] =getFixedLabel('ISNOTNULL');
        $fLabels['curuser'] =getFixedLabel('CURUSER');
        return $fLabels;
        

    }

    static function getAdvCriteriaHTML($adv_filter_options="",$selected="")
    {
        if ($adv_filter_options == ""){
            $adv_filter_options = self::getComparatorLabel();
        }
        $shtml = '';
        foreach($adv_filter_options as $key=>$value)
        {
            if($selected == $key)
            {
                $shtml .= "<option selected value=\"".$key."\">".$value."</option>";
            }else
            {
                $shtml .= "<option value=\"".$key."\">".$value."</option>";
            }
        }
        return $shtml;
    }

    static function stdFilterDateTimeStr()
    {
        static $datetimestr;
        if(!empty($datetimestr))
        {
            return $datetimestr;
        }
        $todayDateTime =date('Y-m-d');

		$tomorrow = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 1, date("Y")));
		$tomorrowDateTime = $tomorrow ;

		$syesterday = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 1, date("Y")));
		$syesterdayDateTime = $syesterday ;

		$currentmonth0 = date("Y-m-d", mktime(0, 0, 0, date("m"), "01", date("Y")));
		$currentMonthStartDateTime = $currentmonth0 ;
		$currentmonth1 = date("Y-m-t");
		$currentMonthEndDateTime = $currentmonth1 ;

		$lastmonth0 = date("Y-m-d", mktime(0, 0, 0, date("m") - 1, "01", date("Y")));
		$lastMonthStartDateTime = $lastmonth0;
		//$lastmonth1 = date("Y-m-t", strtotime("-1 Month"));
		$lastmonth1 = date('Y-m-d', strtotime("$lastmonth0 +1 month -1 day"));
		$lastMonthEndDateTime = $lastmonth1 ;

		$nextmonth0 = date("Y-m-d", mktime(0, 0, 0, date("m") + 1, "01", date("Y")));
		$nextMonthStartDateTime = $nextmonth0 ;
		//$nextmonth1 = date("Y-m-t", strtotime("+1 Month"));
		$nextmonth1 = date('Y-m-d', strtotime("$nextmonth0 +1 month -1 day"));
		$nextMonthEndDateTime = $nextmonth1 ;
        $lastweeks=DateOperation::getlastweekrange(date("Y-m-d"));
            
		//$lastweek0 = date("Y-m-d",mktime(0, 0, 0,date("m"),date("d")-date("w")-6,date("Y")));
		$lastWeekStartDateTime = $lastweeks[0] ;
	//	$lastweek1 = date("Y-m-d",mktime(23,59,59,date("m"),date("d")-date("w"),date("Y")));
		$lastWeekEndDateTime = $lastweeks[6] ;
        
        $thisweeks=DateOperation::get_weekrange_by_date(date("Y-m-d"));
        //$thisweek0 = date("Y-m-d", strtotime("this monday"));
       // $thisweek0 = date("Y-m-d",mktime(0, 0, 0,date("m"),date("d")-date("w")+1,date("Y")));
         $thisweek0=$thisweeks[0];
		$thisWeekStartDateTime = $thisweek0 ;
		//$thisweek1 = date("Y-m-d", strtotime("this sunday"));
       // $thisweek1 = date("Y-m-d",mktime(23,59,59,date("m"),date("d")-date("w")+7,date("Y")));
       $thisweek1=$thisweeks[6];
		$thisWeekEndDateTime = $thisweek1 ;
  
         $nextweeks=DateOperation::getnextweekrange(date("Y-m-d"));
      
	//	$nextweek0 = date("Y-m-d",mktime(0, 0, 0,date("m"),date("d")-date("w")+8,date("Y")));
        $nextweek0=$nextweeks[0];
		$nextWeekStartDateTime = $nextweek0 ;
		//$nextweek1 = date("Y-m-d",mktime(23,59,59,date("m"),date("d")-date("w")+14,date("Y")));
        $nextweek1=$nextweeks[6];
		$nextWeekEndDateTime = $nextweek1 ;	     
            
        $defaultStartDate= "1600-01-01";
        $defaultStartDateTime=$defaultStartDate ;
        $defaultEndDate="2037-12-31";
        $defaultEndDateTime=$defaultEndDate ;     
   
		$currentFY0 = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
		$currentFYStartDateTime = $currentFY0 ;
		$currentFY1 = date("Y-m-t", mktime(0, 0, 0, "12", date("d"), date("Y")));
		$currentFYEndDateTime = $currentFY1 ;

		$lastFY0 = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y") - 1));
		$lastFYStartDateTime = $lastFY0 ;
		$lastFY1 = date("Y-m-t", mktime(0, 0, 0, "12", date("d"), date("Y") - 1));
		$lastFYEndDateTime =$lastFY1 ;

		$nextFY0 = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y") + 1));
		$nextFYStartDateTime = $nextFY0 ;
		$nextFY1 = date("Y-m-t", mktime(0, 0, 0, "12", date("d"), date("Y") + 1));
		$nextFYEndDateTime =$nextFY1 ;
		if (date("m") <= 3) {
			$cFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
			$cFqStartDateTime = $cFq ;
			$cFq1 = date("Y-m-d", mktime(0, 0, 0, "03", "31", date("Y")));
			$cFqEndDateTime = $cFq1 ;

			$nFq = date("Y-m-d", mktime(0, 0, 0, "04", "01", date("Y")));
			$nFqStartDateTime = $nFq ;
			$nFq1 = date("Y-m-d", mktime(0, 0, 0, "06", "30", date("Y")));
			$nFqEndDateTime =$nFq1;

			$pFq = date("Y-m-d", mktime(0, 0, 0, "10", "01", date("Y") - 1));
			$pFqStartDateTime =$pFq ;
			$pFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y") - 1));
			$pFqEndDateTime = $pFq1 ;
		} else if (date("m") > 3 and date("m") <= 6) {

			$pFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
			$pFqStartDateTime = $pFq ;
			$pFq1 = date("Y-m-d", mktime(0, 0, 0, "03", "31", date("Y")));
			$pFqEndDateTime = $pFq1 ;

			$cFq = date("Y-m-d", mktime(0, 0, 0, "04", "01", date("Y")));
			$cFqStartDateTime = $cFq ;
			$cFq1 = date("Y-m-d", mktime(0, 0, 0, "06", "30", date("Y")));
			$cFqEndDateTime = $cFq1 ;

			$nFq = date("Y-m-d", mktime(0, 0, 0, "07", "01", date("Y")));
			$nFqStartDateTime = $nFq ;
			$nFq1 = date("Y-m-d", mktime(0, 0, 0, "09", "30", date("Y")));
			$nFqEndDateTime = $nFq1 ;
		} else if (date("m") > 6 and date("m") <= 9) {

			$nFq = date("Y-m-d", mktime(0, 0, 0, "10", "01", date("Y")));
			$nFqStartDateTime = $nFq ;
			$nFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y")));
			$nFqEndDateTime = $nFq1 ;

			$pFq = date("Y-m-d", mktime(0, 0, 0, "04", "01", date("Y")));
			$pFqStartDateTime = $pFq ;
			$pFq1 = date("Y-m-d", mktime(0, 0, 0, "06", "30", date("Y")));
			$pFqEndDateTime = $pFq1 ;

			$cFq = date("Y-m-d", mktime(0, 0, 0, "07", "01", date("Y")));
			$cFqStartDateTime = $cFq ;
			$cFq1 = date("Y-m-d", mktime(0, 0, 0, "09", "30", date("Y")));
			$cFqEndDateTime = $cFq1 ;
		} else if (date("m") > 9 and date("m") <= 12) {
			$nFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y") + 1));
			$nFqStartDateTime = $nFq ;
			$nFq1 = date("Y-m-d", mktime(0, 0, 0, "03", "31", date("Y") + 1));
			$nFqEndDateTime = $nFq1 ;

			$pFq = date("Y-m-d", mktime(0, 0, 0, "07", "01", date("Y")));
			$pFqStartDateTime = $pFq ;
			$pFq1 = date("Y-m-d", mktime(0, 0, 0, "09", "30", date("Y")));
			$pFqEndDateTime = $pFq1 ;

			$cFq = date("Y-m-d", mktime(0, 0, 0, "10", "01", date("Y")));
			$cFqStartDateTime = $cFq ;
			$cFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y")));
			$cFqEndDateTime =$cFq1 ;
		}
        
        $DateTime=array
              (
                      "prevfy"=>Array($lastFYStartDateTime,$lastFYEndDateTime,getFixedLabel('prevfy')),
                      "thisfy"=>Array($currentFYStartDateTime,$currentFYEndDateTime,getFixedLabel('thisfy')),
                      "nextfy"=>Array($nextFYStartDateTime,$nextFYEndDateTime,getFixedLabel('nextfy')),
                      "prevfq"=>Array($pFqStartDateTime,$pFqEndDateTime,getFixedLabel('prevfq')),
                      "thisfq"=>Array($cFqStartDateTime,$cFqEndDateTime,getFixedLabel('thisfq')),
                      "nextfq"=>Array($nFqStartDateTime,$nFqEndDateTime,getFixedLabel('nextfq')),
                      "syesterday"=>Array($syesterdayDateTime,$syesterdayDateTime,getFixedLabel('syesterday')),
                      "today"=>Array($todayDateTime,$todayDateTime,getFixedLabel('today')),
                      "tomorrow"=>Array($tomorrowDateTime,$tomorrowDateTime,getFixedLabel('tomorrow')),
                      "lastweek"=>Array($lastWeekStartDateTime,$lastWeekEndDateTime,getFixedLabel('lastweek')),
                      "thisweek"=>Array($thisWeekStartDateTime,$thisWeekEndDateTime,getFixedLabel('thisweek')),
                      "nextweek"=>Array($nextWeekStartDateTime,$nextWeekEndDateTime,getFixedLabel('nextweek')),
                      "lastmonth"=>Array($lastMonthStartDateTime,$lastMonthEndDateTime,getFixedLabel('lastmonth')),
                      "thismonth"=>Array($currentMonthStartDateTime,$currentMonthEndDateTime,getFixedLabel('thismonth')),
                      "nextmonth"=>Array($nextMonthStartDateTime,$nextMonthEndDateTime,getFixedLabel('nextmonth'))

             );

        if(file_exists(globalStatic::$root_directory.'include/CustomView_date_Config.php'))
        {
           require_once(globalStatic::$root_directory.'include/CustomView_date_Config.php');           
           $lastdays= CustomView_date_Config::$lastdays; 
           $beforedays= CustomView_date_Config::$beforedays;
           $nextdays= CustomView_date_Config::$nextdays; 
           $afterdays= CustomView_date_Config::$afterdays;                                                
         }
         else//���ļ������ڣ���������ȡֵȡĬ�ϸ���������Ϣ
         {            
           $lastdays= CommonView::$lastdays; 
           $beforedays= CommonView::$beforedays;
           $nextdays= CommonView::$nextdays; 
           $afterdays= CommonView::$afterdays;                          
        } 
        
        foreach($beforedays as $key_beforedays=>$value_beforedays){                 
            $DateTime['before'.$value_beforedays.'days']=Array($defaultStartDate,date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - $value_beforedays, date("Y"))),$value_beforedays.getFixedLabel('DAYSAGO'));
        }         
        foreach($lastdays as $key_lastdays=>$value_lastdays){
            $DateTime['last'.$value_lastdays.'days']=Array(date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - $value_lastdays, date("Y"))),$syesterdayDateTime,getFixedLabel('LAST').$value_lastdays.getFixedLabel("Days"));
        }         
        foreach($nextdays as $key_nextdays=>$value_nextdays){
            $DateTime['next'.$value_nextdays.'days']=Array($tomorrowDateTime,date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") +$value_nextdays , date("Y"))),getFixedLabel("FUTURE").$value_nextdays.getFixedLabel("Days"));
        }
        foreach($afterdays as $key_afterdays=>$value_afterdays){
            $DateTime['after'.$value_afterdays.'days']=Array(date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") +$value_afterdays , date("Y"))),$defaultEndDate,$value_afterdays.getFixedLabel("AFTERDAY"));
        }
        $datetimestr=$DateTime;
	//	if($output_type == 'lastmodified'){
			return $DateTime;
	//	}
    }
    /**
     * ���ݷ����»�����ѯ��ѡ��ʱ��Ρ��ֶ��л�������ȡֵʱonchange�¼����ú���
    **/
    static function getCriteriaJs($output_type='')
    {
        $DateTime = CommonView::stdFilterDateTimeStr($output_type);
        $datetimestr=json_encode($DateTime);//���������json���룬������js����ʹ��
		$sjsStr = '<script language="JavaScript" type="text/javaScript">
			function showDateRange( type ) {
				if (type!="custom") {
					document.CustomView.startdate.readOnly=true
					document.CustomView.enddate.readOnly=true				
				} else {
					document.CustomView.startdate.readOnly=false
					document.CustomView.enddate.readOnly=false
                    document.CustomView.startdate.value="";
                    document.CustomView.enddate.value = ""; 
	
				}                
                var resultobj=eval('.$datetimestr.');  
                for(var i in resultobj)
                {                   
                    if(type==i){                        
                           document.CustomView.startdate.value = resultobj[i][0];
    					   document.CustomView.enddate.value = resultobj[i][1];  
                        }                       
                }              
 			}
		</script>';

        return $sjsStr;        
    }      
}

?>