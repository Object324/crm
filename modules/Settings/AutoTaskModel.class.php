<?php
/**
 * 修改编码格式:统一编码：UTF-8
 * @project PROT145 自动任务
 * @author Tujt 2015-01-14
 */
//数据层，获取计划任务数据
class AutoTaskModel{
	private $autoid;
	public  function __construct($autoid = 0){
		$this->autoid = $autoid;
	}
	/**
	 * 提供一个修改autoid的方法，方便批量操作时不需要重复初始化本类
	 * @author Tujt 2015-01-15
	 */
	public function setAutoId($autoid) {
	    $this->autoid = $autoid;
	}
	/**
	 * 获取基本查询的query语句
	 * @author Tujt 2015-01-15
	 */
	public function getStdQuery() {
		$query = 'SELECT ld_autostdfilter.* FROM ld_autostdfilter
				 INNER JOIN ld_autotask 
					ON ld_autotask.`autotaskid` = ld_autostdfilter.`autotaskid`
			  WHERE ld_autotask.`autotaskid` = '.$this->autoid.' ';
		return $query;
	}
	/**
	 * 获取高级查询的query语句
	 * @author Tujt 2015-01-15
	 */
	public function getAdvQuery() {
		$query = 'SELECT ld_autoadvfilter.* FROM ld_autoadvfilter 
				INNER JOIN ld_autotask 
						ON ld_autotask.`autotaskid` = ld_autoadvfilter.`autotaskid`
				WHERE ld_autotask.`autotaskid` = '.$this->autoid.' order by ld_autoadvfilter.columnindex ';
		return $query;
	}
	/**
	 * 获取高级条件group条件，并组装成((0 or 1) or (2))的
	 * 字符串类型，方便逻辑层处理
	 * @author Tujt 2015-01-15
	 */
	public function getFilterGroup() {
		global $adb;
		$query = 'SELECT ld_autoadvfilter.columnindex,ld_autoadvfilter.groupid,
					ld_autoadvfilter.column_condition,ld_autotask.filtergroup 
				  FROM ld_autoadvfilter 
					  INNER JOIN ld_autotask 
						  ON ld_autotask.`autotaskid` = ld_autoadvfilter.`autotaskid`
				  WHERE ld_autotask.`autotaskid` = ? ORDER BY ld_autoadvfilter.columnindex ';
		$result = $adb->pquery($query,array($this->autoid));
		$rows = $adb->num_rows($result);
		if($rows > 0){
			$autoadvfilter = array();
			for($i=0;$i<$rows;++ $i){
				$groupid = $adb->query_result($result,$i,'groupid');
				$columnindex = $adb->query_result($result,$i,'columnindex');
				$filtergroup = $adb->query_result($result,$i,'filtergroup');
				$column_condition = $adb->query_result($result,$i,'column_condition');
			    $autoadvfilter[$groupid][$columnindex] = $column_condition;
			}
		}
		$groupsql = '';
		if(!empty($autoadvfilter)){
			if(!empty($filtergroup)){
				$filtergrouparr = explode(',',$filtergroup);
				$filtergroupidx = 0;
			}
			$groupsql = '( ';$fori = 0;
			foreach($autoadvfilter as $groupkey=>$grouparr){
				if(!empty($filtergrouparr) && $fori > 0){
					$groupsql .= ' '.$filtergrouparr[$filtergroupidx].' ';
					++ $filtergroupidx;
				}
				$groupsql .= '( ';
				foreach($grouparr as $index=>$filter){
					$groupsql .= $index.' ';
					if(!empty($filter)) $groupsql.= $filter.' ';
				}
				$groupsql .= ' )';
				++ $fori;
			}
			$groupsql .= ')';
		}
		return $groupsql;
	}
     /**
      * 获取自动提醒基本查询条件
	  * @project PROT145 自动任务
	  * @author Tujt 2015-01-14
      */
    function getStdFilterByautoid() {
		global $adb;
		$query = $this->getStdQuery();
		$result = $adb->pquery($query, array());
		$stdfilterrow = $adb->fetch_array($result);
		$stdfilterlist = array();
		$stdfilterlist["columnname"] = $stdfilterrow["columnname"];
		$stdfilterlist["stdfilter"] = $stdfilterrow["stdfilter"];
		$date = date('H:i:s',time());
		if ($stdfilterrow["stdfilter"] == "custom" || $stdfilterrow["stdfilter"] == "") {
			if ($stdfilterrow["startdate"] != "0000-00-00" && $stdfilterrow["startdate"] != "") {
				$stdfilterlist["startdate"] = $stdfilterrow["startdate"] . ' ' . $date;
			}
			if ($stdfilterrow["enddate"] != "0000-00-00" && $stdfilterrow["enddate"] != "") {
				$stdfilterlist["enddate"] = $stdfilterrow["enddate"] . ' ' . $date;
			}
		} else { //if it is not custom get the date according to the selected duration
			$datefilter = $this->getDateforautoStdFilterBytype($stdfilterrow["stdfilter"]);
			$stdfilterlist["startdate"] = $datefilter[0] . ' ' . $date;
			$stdfilterlist["enddate"] = $datefilter[1] . ' ' . $date;
		}
		return $stdfilterlist;
	}
    /**
     * 获取自动提醒高级查询条件
	 * @project PROT145 自动任务
	 * @author Tujt 2015-01-14
     */
	function getAdvFilterByautoid() {
		global $adb, $default_charset;
		$advft_criteria = array();$i = 1;$j = 0;
		$query = $this->getAdvQuery();
		$result = $adb->pquery($query, array());
		$noOfColumns = $adb->num_rows($result);
		if ($noOfColumns <= 0) return array();
		while ($relcriteriarow = $adb->fetch_array($result)) {
			$columnIndex = $relcriteriarow["columnindex"];
			$criteria = array();
			$criteria['columnname'] = html_entity_decode($relcriteriarow["columnname"], ENT_QUOTES, $default_charset);
			$criteria['comparator'] = $relcriteriarow["comparator"];
			$advfilterval = html_entity_decode($relcriteriarow["value"], ENT_QUOTES, $default_charset);
			$col = explode(":", $relcriteriarow["columnname"]);
			$temp_val = explode(",", $relcriteriarow["value"]);
			if ($col[4] == 'D' || ($col[4] == 'T' && $col[1] != 'time_start' && $col[1] != 'time_end') || ($col[4] == 'DT')) {
				$val = Array();
				for ($x = 0; $x < count($temp_val); $x++) {
					if ($col[4] == 'D') {
						$date = new DateTimeField(trim($temp_val[$x]));
						$val[$x] = $date->getDisplayDate();
					} elseif ($col[4] == 'DT') {
						$date = new DateTimeField(trim($temp_val[$x]));
						$val[$x] = $date->getDisplayDateTimeValue();
					} else {
						$date = new DateTimeField(trim($temp_val[$x]));
						$val[$x] = $date->getDisplayTime();
					}
				}
				$advfilterval = implode(",", $val);
			}
			$criteria['value'] = $advfilterval;
			$criteria['column_condition'] = $relcriteriarow["column_condition"];
			$advft_criteria[$i]['columns'][$j] = $criteria;
			$advft_criteria[$i]['condition'] = $groupCondition;
			$j++;
		}
		if (!empty($advft_criteria[$i]['columns'][$j - 1]['column_condition'])) {
			$advft_criteria[$i]['columns'][$j - 1]['column_condition'] = '';
		}
		// Clear the condition (and/or) for last group, if any.
		if (!empty($advft_criteria[$i - 1]['condition']))
			$advft_criteria[$i - 1]['condition'] = '';
		return $advft_criteria;
	}
	/**
     * 获取基本查询自定义条件信息
     * */
    function getDateforautoStdFilterBytype($type) {
		$thisyear = date("Y");
		$today = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d"), date("Y")));
		$tomorrow = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 1, date("Y")));
		$syesterday = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 1, date("Y")));

		$currentmonth0 = date("Y-m-d", mktime(0, 0, 0, date("m"), "01", date("Y")));
		$currentmonth1 = date("Y-m-t");
		$lastmonth0 = date("Y-m-d", mktime(0, 0, 0, date("m") - 1, "01", date("Y")));
		$lastmonth1 = date("Y-m-t", strtotime("-1 Month"));
		$nextmonth0 = date("Y-m-d", mktime(0, 0, 0, date("m") + 1, "01", date("Y")));
		$nextmonth1 = date("Y-m-t", strtotime("+1 Month"));

		$lastweek0 = date("Y-m-d", strtotime("-2 week Sunday"));
		$lastweek1 = date("Y-m-d", strtotime("-1 week Saturday"));

		$thisweek0 = date("Y-m-d", strtotime("-1 week Sunday"));
		$thisweek1 = date("Y-m-d", strtotime("this Saturday"));

		$nextweek0 = date("Y-m-d", strtotime("this Sunday"));
		$nextweek1 = date("Y-m-d", strtotime("+1 week Saturday"));
        $next3days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 2, date("Y")));
		$next7days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 6, date("Y")));
		$next15days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 14, date("Y")));
        $next30days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 29, date("Y")));
		$next60days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 59, date("Y")));
		$next90days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 89, date("Y")));
		$next120days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 119, date("Y")));
		$next180days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 179, date("Y")));
        $last3days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 2, date("Y")));
		$last7days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 6, date("Y")));
		$last15days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 14, date("Y")));
        $last30days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 29, date("Y")));
		$last60days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 59, date("Y")));
		$last90days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 89, date("Y")));
		$last120days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 119, date("Y")));
		$last180days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 179, date("Y")));
        
        $defaultStartDate='1960-01-01';
        $defaultEndDate='9999-12-31';
        $after3days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 2, date("Y")));
        $after7days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 6, date("Y")));
		$after15days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 14, date("Y")));
        $after30days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 29, date("Y")));
		$after60days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 59, date("Y")));
		$after90days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 89, date("Y")));
		$after120days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 119, date("Y")));
        $after180days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") + 179, date("Y")));
      
        $before0days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 0, date("Y")));
        $before3days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 2, date("Y")));
		$before7days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 6, date("Y")));
		$before15days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 14, date("Y")));
        $before30days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 29, date("Y")));
		$before60days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 59, date("Y")));
		$before90days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 89, date("Y")));
		$before120days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 119, date("Y")));
        $before120days = date("Y-m-d", mktime(0, 0, 0, date("m"), date("d") - 179, date("Y")));

		$currentFY0 = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
		$currentFY1 = date("Y-m-t", mktime(0, 0, 0, "12", date("d"), date("Y")));
		$lastFY0 = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y") - 1));
		$lastFY1 = date("Y-m-t", mktime(0, 0, 0, "12", date("d"), date("Y") - 1));
		$nextFY0 = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y") + 1));
		$nextFY1 = date("Y-m-t", mktime(0, 0, 0, "12", date("d"), date("Y") + 1));

		if (date("m") <= 4) {
			$cFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
			$cFq1 = date("Y-m-d", mktime(0, 0, 0, "04", "30", date("Y")));
			$nFq = date("Y-m-d", mktime(0, 0, 0, "05", "01", date("Y")));
			$nFq1 = date("Y-m-d", mktime(0, 0, 0, "08", "31", date("Y")));
			$pFq = date("Y-m-d", mktime(0, 0, 0, "09", "01", date("Y") - 1));
			$pFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y") - 1));
		} else if (date("m") > 4 and date("m") <= 8) {
			$pFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y")));
			$pFq1 = date("Y-m-d", mktime(0, 0, 0, "04", "30", date("Y")));
			$cFq = date("Y-m-d", mktime(0, 0, 0, "05", "01", date("Y")));
			$cFq1 = date("Y-m-d", mktime(0, 0, 0, "08", "31", date("Y")));
			$nFq = date("Y-m-d", mktime(0, 0, 0, "09", "01", date("Y")));
			$nFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y")));
		} else {
			$nFq = date("Y-m-d", mktime(0, 0, 0, "01", "01", date("Y") + 1));
			$nFq1 = date("Y-m-d", mktime(0, 0, 0, "04", "30", date("Y") + 1));
			$pFq = date("Y-m-d", mktime(0, 0, 0, "05", "01", date("Y")));
			$pFq1 = date("Y-m-d", mktime(0, 0, 0, "08", "31", date("Y")));
			$cFq = date("Y-m-d", mktime(0, 0, 0, "09", "01", date("Y")));
			$cFq1 = date("Y-m-d", mktime(0, 0, 0, "12", "31", date("Y")));
		}

		if ($type == "today") {

			$datevalue[0] = $today;
			$datevalue[1] = $today;
		} elseif ($type == "syesterday") {

			$datevalue[0] = $syesterday;
			$datevalue[1] = $syesterday;
		} elseif ($type == "tomorrow") {

			$datevalue[0] = $tomorrow;
			$datevalue[1] = $tomorrow;
		} elseif ($type == "thisweek") {

			$datevalue[0] = $thisweek0;
			$datevalue[1] = $thisweek1;
		} elseif ($type == "lastweek") {

			$datevalue[0] = $lastweek0;
			$datevalue[1] = $lastweek1;
		} elseif ($type == "nextweek") {

			$datevalue[0] = $nextweek0;
			$datevalue[1] = $nextweek1;
		} elseif ($type == "thismonth") {

			$datevalue[0] = $currentmonth0;
			$datevalue[1] = $currentmonth1;
		} elseif ($type == "lastmonth") {

			$datevalue[0] = $lastmonth0;
			$datevalue[1] = $lastmonth1;
		} elseif ($type == "nextmonth") {

			$datevalue[0] = $nextmonth0;
			$datevalue[1] = $nextmonth1;
		} elseif ($type == "next7days") {

			$datevalue[0] = $today;
			$datevalue[1] = $next7days;
		} elseif ($type == "next30days") {

			$datevalue[0] = $today;
			$datevalue[1] = $next30days;
		} elseif ($type == "next60days") {

			$datevalue[0] = $today;
			$datevalue[1] = $next60days;
		} elseif ($type == "next90days") {

			$datevalue[0] = $today;
			$datevalue[1] = $next90days;
		} elseif ($type == "next120days") {

			$datevalue[0] = $today;
			$datevalue[1] = $next120days;
		}elseif ($type == "next180days") {

			$datevalue[0] = $today;
			$datevalue[1] = $next180days;
		}
        elseif($type=='last3days')
        {
            $datevalue[0] = $last3days;
			$datevalue[1] = $today;
        } 
        elseif ($type == "last7days") {

			$datevalue[0] = $last7days;
			$datevalue[1] = $today;
		}
        else if($type=='last15days')
        {
            $datevalue[0] = $last15days;
			$datevalue[1] = $today;
        } 
        elseif ($type == "last30days") {

			$datevalue[0] = $last30days;
			$datevalue[1] = $today;
		} elseif ($type == "last60days") {

			$datevalue[0] = $last60days;
			$datevalue[1] = $today;
		} else if ($type == "last90days") {

			$datevalue[0] = $last90days;
			$datevalue[1] = $today;
		} elseif ($type == "last120days") {

			$datevalue[0] = $last120days;
			$datevalue[1] = $today;
		}elseif ($type == "last180days") {

			$datevalue[0] = $last180days;
			$datevalue[1] = $today;
		} elseif ($type == "thisfy") {

			$datevalue[0] = $currentFY0;
			$datevalue[1] = $currentFY1;
		} elseif ($type == "prevfy") {

			$datevalue[0] = $lastFY0;
			$datevalue[1] = $lastFY1;
		} elseif ($type == "nextfy") {

			$datevalue[0] = $nextFY0;
			$datevalue[1] = $nextFY1;
		} elseif ($type == "nextfq") {

			$datevalue[0] = $nFq;
			$datevalue[1] = $nFq1;
		} elseif ($type == "prevfq") {

			$datevalue[0] = $pFq;
			$datevalue[1] = $pFq1;
		} elseif ($type == "thisfq") {
			$datevalue[0] = $cFq;
			$datevalue[1] = $cFq1;
		} 
        else if($type=='before0days')
        {
      		$datevalue[0] = $defaultStartDate;
			$datevalue[1] = $before0days;
        }
        else if($type=='before3days')
        {
      		$datevalue[0] = $defaultStartDate;
			$datevalue[1] = $before3days;
        }
        else if ($type == "before7days") {

			$datevalue[0] = $defaultStartDate;
			$datevalue[1] = $before7days;
		}
        else if($type == 'before15days')
        {
            $datevalue[0] = $defaultStartDate;
			$datevalue[1] = $before15days;
        }
        else if ($type == "before30days") {

			$datevalue[0] = $defaultStartDate;
			$datevalue[1] = $before30days;
		}else if ($type == "before60days") {

			$datevalue[0] = $defaultStartDate;
			$datevalue[1] = $before60days;
		}else if ($type == "before90days") {

			$datevalue[0] = $defaultStartDate;
			$datevalue[1] = $before90days;
		}else if ($type == "before120days") {

			$datevalue[0] = $defaultStartDate;
			$datevalue[1] = $before120days;
		}else if ($type == "before180days") {

			$datevalue[0] = $defaultStartDate;
			$datevalue[1] = $before180days;
		}
        else if($type=='after3days')
        {
            $datevalue[0] = $after3days;
			$datevalue[1] = $defaultEndDate;
        }
        else if ($type == "after7days") {

			$datevalue[0] = $after7days;
			$datevalue[1] = $defaultEndDate;
		}
        else if($type=='after15days')
        {
            $datevalue[0] = $after15days;
			$datevalue[1] = $defaultEndDate;
        }
        else if ($type == "after30days") {

			$datevalue[0] = $after30days;
			$datevalue[1] = $defaultEndDate;
		}else if ($type == "after60days") {

			$datevalue[0] = $after60days;
			$datevalue[1] = $defaultEndDate;
		}else if ($type == "after90days") {

			$datevalue[0] = $after90days;
			$datevalue[1] = $defaultEndDate;
		}else if ($type == "after120days") {

			$datevalue[0] = $after120days;
			$datevalue[1] = $defaultEndDate;
		}else if ($type == "after180days") {

			$datevalue[0] = $after180days;
			$datevalue[1] = $defaultEndDate;
		}else {
			$datevalue[0] = "";
			$datevalue[1] = "";
		}

		return $datevalue;
	}

	/**
	 * 获取自动任务定制任务对象结果集
	 * @author Tujt 2015-01-15
	 */
	public function getAutoTackFilterInfo() {
	    global $adb;
		$query = 'SELECT columnname,value FROM ld_autotaskfilter 
					WHERE autotaskid = ? order by columnindex;';
		$result = $adb->pquery($query,array($this->autoid));
		$rows = $adb->num_rows($result);
		$autotaskupdate = array();
		if($rows > 0){
			$tablearr = array();
			for($i=0;$i<$rows;++ $i){
			    $columnname = $adb->query_result($result,$i,'columnname');
				$value = $adb->query_result($result,$i,'value');
				$tablearr = explode(':',$columnname);
				$autotaskupdate[$i]['tablename'] = $tablearr[0];
				$autotaskupdate[$i]['columnname'] = $tablearr[1];
				$autotaskupdate[$i]['fieldname'] = $tablearr[2];
				$autotaskupdate[$i]['uitype'] = $tablearr[3];
				$autotaskupdate[$i]['value'] = $value;
			}
		}
		return $autotaskupdate;
	}

	/**
	 * 获取自动任务的SQL脚本
	 * @author Tujt 2015-01-16
	 */
	public function getAutoTackQuery() {
	    global $adb;
		$select = 'SELECT query FROM `ld_autotaskquery` where autotaskid = ?;';
		$result = $adb->pquery($select,array($this->autoid));
		$rows = $adb->num_rows($result);
		if($rows > 0){
			$query = $adb->query_result($result,0,'query');
			$query = decode_html($query);
			return trim($query);
		}
		return '';
	}
	/**
	 * 自动执行自动任务，获取自动任务结果集
	 * @author Tujt 2015-01-16
	 */
	public function getAutoTaskInfo() {
	    global $adb;
		$query = 'SELECT autotaskid,autotasktype,tabid FROM ld_autotask 
					  WHERE presence = 0 AND execution = 0 AND autotaskmode = 0 ';
		//获取开启状态、非执行中状态、自动执行状态的Query
		/**
			//每日、每周、每月执行，处理逻辑
			$time = time();$day = date('d',$time);
			$week = date('w',$time);if(0 == $week) $week = 7;
			$query .= 'AND (autotaskdate = "day" or autotaskdate = 
						"week:'.$week.'" or autotaskdate="month:'.$day.'") ';
		*/
		$query .= ' ORDER BY autotaskid;';
		$result = $adb->pquery($query,array());
		$rows = $adb->num_rows($result);
		if($rows > 0){
			$typearray = array('0'=>'filter','1'=>'query');
			$autotaskinfo = array();
			for($i=0;$i<$rows;++ $i){
				$tabid = $adb->query_result($result,$i,'tabid');
				$module = getTabname($tabid);
			    $autotaskid = $adb->query_result($result,$i,'autotaskid');
				$autotasktype = $adb->query_result($result,$i,'autotasktype');
				$autotaskinfo[$typearray[$autotasktype]][$autotaskid] = $module;
			}
			return $autotaskinfo;
		}
		return '';
	}
}

?>