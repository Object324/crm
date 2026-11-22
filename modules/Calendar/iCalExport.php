<?php
    require_once('config.php');
    global $adb;
	 include('PHPExcel/PHPExcel.php');
	 $objPHPExcel = new PHPExcel();
	 $objPHPExcel->setActiveSheetIndex(0);
	 $activesheet=$objPHPExcel->getActiveSheet();
    //$EXCEL_OUT = iconv('UTF-8','GB2312',"事件类型,状态,主题,客户名称,开始时间,结束时间,负责人\n");
	 $header = array('事件类型','状态','主题','客户名称','开始时间','结束时间','负责人');
	 $lang = count($header);
	 for($i=0;$i<$lang;$i++) {
		 $activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex($i).'1',$header[$i]);
	 }
    //$filename = $_REQUEST['filename'];
    $modulelabel = "日程";
    $query = 'select activityid,accountid,activitytype,eventstatus,subject,
					date_start,due_date,last_name 
				from ld_activity 
					left join ld_users 
						on ld_users.id = ld_activity.smownerid 
				where ld_activity.deleted = 0 and activityid > 0 AND activitytype != "Emails";';
    $result=$adb->pquery($query);
    $num_prod_rows = $adb->num_rows($result);
    if($num_prod_rows > 0)
    {
		  $j = 2;
        for($i = 0; $i<$num_prod_rows; $i++)
        {
            $activitytype=$adb->query_result($result,$i,"activitytype");
            $eventstatus=$adb->query_result($result,$i,"eventstatus");
            $subject=$adb->query_result($result,$i,"subject");
            $accountid=selAcount($adb->query_result($result,$i,"accountid"));
            $date_start=$adb->query_result($result,$i,"date_start");
            $due_date=$adb->query_result($result,$i,"due_date");
            $activityid=$adb->query_result($result,$i,"last_name");
            //$EXCEL_OUT.=iconv('UTF-8','GB2312',"$activitytype,$eventstatus,$subject,$accountid,$date_start,$due_date,$activityid\n");

				$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(0).$j,$activitytype);
				$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(1).$j,$eventstatus);
				$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(2).$j,$subject);
				$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(3).$j,$accountid);
				$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(4).$j,$date_start);
				$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(5).$j,$due_date);
				$activesheet->setCellValue(PHPExcel_Cell::stringFromColumnIndex(6).$j,$activityid);
				++ $j;
        }
    }
    //header("Content-type:text/csv");   
    //header("Content-Disposition:attachment;filename={$filename}.csv");
    //header('Cache-Control:must-revalidate,post-check=0,pre-check=0');   
    //header('Expires:0');   
    //header('Pragma:public');   
    //echo $EXCEL_OUT; 

	 $objPHPExcel->getActiveSheet()->setTitle('Calendar');
	 $objWriter = PHPExcel_IOFactory::createWriter($objPHPExcel, 'Excel5');

	 $objWriter->save('storage/Calendar.xls');   

	 //下载文件
	 $file_name = 'Calendar.xls';
	 $file_dir="storage/";

	 $file = fopen($file_dir.$file_name,"r"); 
	 Header("Content-type: application/octet-stream");
	 Header("Accept-Ranges: bytes");
	 Header("Accept-Length: ".filesize($file_dir . $file_name));
	 $modulelabel = iconv('UTF-8','gbk',$modulelabel);
	 Header("Content-Disposition: attachment; filename=".$modulelabel.".xls" );
	 ob_clean();
	 flush();
	 echo fread($file, filesize($file_dir.$file_name));
	 fclose($file);
	 exit();
    
    function selUser($actId)
    {
        global $adb;
        $Sql = "select last_name from ld_users a,ld_activity b where a.id = b.smownerid and activityid = " . $actId;
        $result = $adb->pquery($Sql, array());
        return $adb->query_result($result,0,"last_name");
    }
    
    function selAcount($idAct)
    {
        global $adb;
        if($idAct == '')
        {
            return null;
        }
        else
        {
            $Sql = "select accountname from ld_account where accountid = " . $idAct;
            $result = $adb->pquery($Sql, array());
            return $adb->query_result($result,0,"accountname");
        }
    }
/*require_once( "./iCalcreator.class.php" );
$tz     = "Europe/Stockholm";
$config = array( "unique_id" => "kigkonsult.se"
  // set a (site) unique id
               , "TZID"      => $tz );
  // opt. "calendar" timezone
$v      = new vcalendar( $config );
  // create a new calendar instance
$v->setProperty( "method", "PUBLISH" );
  // required of some calendar software
$v->setProperty( "x-wr-calname", "Calendar Sample" );
  // required of some calendar software
$v->setProperty( "X-WR-CALDESC", "Calendar Description" );
  // required of some calendar software
$v->setProperty( "X-WR-TIMEZONE", $tz );
  // required of some calendar software
$xprops = array( "X-LIC-LOCATION" => $tz );
  // required of some calendar software
iCalUtilityFunctions::createTimezone( $v, $tz, $xprops );
  // create timezone component(-s) opt. 1
  // based on present date
$vevent = & $v->newComponent( "vevent" );
  // create an event calendar component
$start = array( "year"  => 2007
              , "month" => 4
              , "day"   => 1
              , "hour"  => 19
              , "min"   => 0
              , "sec"   => 0 );
$vevent->setProperty( "dtstart", $start );
$end   = array( "year"  => 2007
              , "month" => 4
              , "day"   => 1
              , "hour"  => 22
              , "min"   => 30
              , "sec"   => 0 );
$vevent->setProperty( "dtend",   $end );
$vevent->setProperty( "LOCATION", "Central Placa" );
  // property name - case independent
$vevent->setProperty( "summary", "PHP summit" );
$vevent->setProperty( "description", "This is a description" );
$vevent->setProperty( "comment", "This is a comment" );
$vevent->setProperty( "attendee", "attendee1@icaldomain.net" );
$valarm = & $vevent->newComponent( "valarm" );
  // create an event alarm
$valarm->setProperty("action", "DISPLAY" ); 
$valarm->setProperty("description", $vevent->getProperty( "description" ));
  // reuse the event description 
$d = sprintf( "%04d%02d%02d %02d%02d%02d", 2007, 3, 31, 15, 0, 0 );
iCalUtilityFunctions::transformDateTime( $d, $tz, "UTC", "Ymd\THis\Z");
$valarm->setProperty( "trigger", $d );
  // create alarm trigger (in UTC datetime)
$vevent = & $v->newComponent( "vevent" );
  // create next event calendar component
$vevent->setProperty( "dtstart", "20070401", array("VALUE" => "DATE"));
  // alt. date format, now for an all-day event
$vevent->setProperty( "organizer" , "boss@icaldomain.com" );
$vevent->setProperty( "summary", "ALL-DAY event" );
$vevent->setProperty( "description", "A description for an all-day event" );
$vevent->setProperty( "resources", "COMPUTER PROJECTOR" );
$vevent->setProperty( "rrule", array( "FREQ" => "WEEKLY"
                                          , "count" => 4 ));
  // weekly, four occasions
$vevent->parse( "LOCATION:1CP Conference Room 4350" );
  // support parse of strict rfc2445/rfc5545 text
  // all calendar components are described in rfc5545
  // a complete method list in iCalcreator manual
iCalUtilityFunctions::createTimezone( $v, $tz, $xprops);
  // create timezone component(-s) opt. 2
  // based on all start dates in events (i.e. dtstart)*/
?> 
