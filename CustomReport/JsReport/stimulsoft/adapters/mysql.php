<?php
#[AllowDynamicProperties]
class StiMySqlAdapter {
	private $connectionString = null;
	private $connectionInfo = null;
	private $link = null;
	
	private function getLastErrorResult() {
		if ($this->link->errno == 0) return StiResult::error("Unknown");
		return StiResult::error("[".$this->link->errno."] ".$this->link->error);
	}
	
	private function connect() {
		//$this->link = new mysqli($this->connectionInfo->host, $this->connectionInfo->userId, $this->connectionInfo->password, $this->connectionInfo->database, $this->connectionInfo->port);
        
        global $dbconfig;
		require_once('../../config.inc.php');

        //$this->link = new mysqli('192.168.3.42', 'luyx', '123', $this->connectionInfo->database, $this->connectionInfo->port);
       if($_GET['default_report']==1)
        {
            $port=$dbconfig['db_port'] ;
    		$strdigit="0123456789";
    		$myport="";
    		for($i=0;$i<strlen($port);$i++)
    		{
    				$digit=substr($port,$i,1);
    				if(strpos($port,$digit)!=false)
    				{
    					$myport.=$digit;
    				}
    		}
            //ls 2022-03-20 【XUQIU1001127】数据库连接放置，支持使用 SSL 链接(报表)
            if (isset($dbconfig['mode']) && strtolower($dbconfig['mode']) == 'ssl'){
                $this->link = @mysqli_init();
                $this->link->real_connect($dbconfig['db_server'], $dbconfig['db_username'], $dbconfig['db_password'], $dbconfig['db_name'], $myport,null, MYSQLI_CLIENT_SSL);//不需要指定证书路径的SSL的连接方式
            } elseif (isset($dbconfig['mode']) && strtolower($dbconfig['mode']) == 'ssl_ca') {
                $this->link = mysqli_init();
                mysqli_ssl_set($this->link, $dbconfig['ssl_key'], $dbconfig['ssl_cert'], $dbconfig['ssl_ca'], NULL, NULL);
                $this->link =mysqli_real_connect($this->link,$dbconfig['db_server'], $dbconfig['db_username'], $dbconfig['db_password'], $dbconfig['db_name'], $myport,null, MYSQLI_CLIENT_SSL);

            }else{
                $this->link = new mysqli($dbconfig['db_server'], $dbconfig['db_username'], $dbconfig['db_password'], $dbconfig['db_name'], $myport);
            }
        }
        else
            $this->link = new mysqli($this->connectionInfo->host, $this->connectionInfo->userId, $this->connectionInfo->password, $this->connectionInfo->database, $this->connectionInfo->port);
		 
        if ($this->link->connect_error) return StiResult::error("[".$this->link->connect_errno."] ".$this->link->connect_error);
		if (!$this->link->set_charset($this->connectionInfo->charset)) return $this->getLastErrorResult();
       
		return StiResult::success();
	}
	
	private function disconnect() {
		if (!$this->link) return;
		$this->link->close();
	}
	
	public function parse($connectionString) {
		$info = new stdClass();
		$info->host = "";
		$info->port = 3306;
		$info->database = "";
		$info->userId = "";
		$info->password = "";
		$info->charset = "utf8";
		
		$parameters = explode(";", $connectionString);
		foreach($parameters as $parameter)
		{
			if (strpos($parameter, "=") < 1) continue;
			
			$spos = strpos($parameter, "=");
			$name = strtolower(trim(substr($parameter, 0, $spos)));
			$value = trim(substr($parameter, $spos + 1));
			
			switch ($name)
			{
				case "server":
				case "host":
				case "location":
					$info->host = $value;
					break;
						
				case "port":
					$info->port = $value;
					break;
						
				case "database":
				case "data source":
					$info->database = $value;
					break;
						
				case "uid":
				case "user":
				case "username":
				case "userid":
				case "user id":
					$info->userId = $value;
					break;
						
				case "pwd":
				case "password":
					$info->password = $value;
					break;
						
				case "charset":
					$info->charset = $value;
					break;
			}
		}
		
		$this->connectionString = $connectionString;
		$this->connectionInfo = $info;
	}
	
	private function parseType($meta) {
		switch ($meta->type) {
			// integer
			case 1:
			case 2:
			case 3:
			case 8:
			case 9:
				return 'int';
			
			// number (decimal)
			case 4:
			case 5:
			case 16:
			case 246:
				return 'number';
			
			// datetime
			case 7:
			case 10:
			case 11:
			case 12:
			case 13:
				return 'datetime';
			
			// array, string
			case 249:
			case 250:
			case 251:
			case 252:
			case 253:
			case 254:
				if ($meta->flags & 128) return 'array';
				return 'string';
		}
		
		// base64 array for unknown
		return 'array';
	}
	
	public function test() {
		$result = $this->connect();
		if ($result->success) $this->disconnect();
		return $result;
	}
	
	public function execute($queryString) {
		$result = $this->connect();
       
		//if ($result->success) {   
		//$VersionInfo=getVersionInfo();
		//file_put_contents("testj1s.txt",$_SESSION['authenticated_user_id']);
		if(isset($_GET['crm_report_userid'])&&$_GET['crm_report_userid']>0)
		{

		$query=str_replace('[uuid]',$_GET['crm_report_userid'],$queryString);
		if(isset($_GET['record']))
		{
			$record=$_GET['record'];
			/*  require_once("../cls_reportRecord.php");
				$record=cls_reportRecord::dencrypt($_GET['record']);*/
			   
			$query=str_replace('[related_ldcrmid]',$record,$query);
		}

		}
		else
		{
			if(!isset($_SESSION['authenticated_user_id'])||$_SESSION['authenticated_user_id']<=0)
			{
				exit('请登录');
			}
			$userid=$_SESSION['authenticated_user_id'];
			$query=str_replace('[uuid]',$_SESSION['authenticated_user_id'],$queryString);
				 
			if(isset($_GET['record']))
			{
				   require_once("../cls_reportRecord.php");
				   $record=cls_reportRecord::dencrypt($_GET['record']);
				  // file_put_contents("d.txt",$record.'annn');
				   
					if($record>0)
					{
						$query=str_replace('[related_ldcrmid]',$record,$query);
					}
				   
				   
			}
		}
            //file_put_contents("querysql.txt",$query."\r\n\r\n",FILE_APPEND);
			$query = $this->link->query($query);
			if (!$query) return $this->getLastErrorResult();
			
			$result->types = array();
			$result->columns = array();
			$result->rows = array();
			
			while ($meta = $query->fetch_field()) {
				$result->columns[] = $meta->name;
				$result->types[] = $this->parseType($meta);
			}
			
			if ($query->num_rows > 0) {
				$isColumnsEmpty = count($result->columns) == 0;
				while ($rowItem = $query->fetch_assoc()) {
					$row = array();
					foreach ($rowItem as $key => $value) {
						if ($isColumnsEmpty && count($result->columns) < count($rowItem)) $result->columns[] = $key;
						$type = $result->types[count($row)];
						$row[] = ($type == 'array') ? base64_encode($value) : $value;
					}
					$result->rows[] = $row;
				}
			}
			
			$this->disconnect();
	//	}
		
		return $result;
	}
}