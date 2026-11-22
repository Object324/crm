<?php
/*+**********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.1
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ************************************************************************************/

include_once dirname(__FILE__) . '/../models/Folder.php';
include_once dirname(__FILE__) . '/../models/Message.php';

class MailManager_Connector {

	/*
	 * Cache interval time
	 */
	static $DB_CACHE_CLEAR_INTERVAL = "-1 day"; // strtotime

	/*
	 * Mail Box URL
	 */
	protected $mBoxUrl;

	/*
	 * Mail Box connection instance
	 */
	protected $mBox;

	/*
	 * Last imap error
	 */
	protected $mError;

	/*
	 * Mail Box folders
	 */
	protected $mFolders = false;

	/**
	 * Modified Time of the mail
	 */
	protected $mModified = false;

	/*
	 * Base URL of the Mail Box excluding folder name
	 */
	protected $mBoxBaseUrl;

	
	/**
	 * Connects to the Imap server with the given parameters
	 * @param $model MailManager_Model_Mailbox Instance
	 * $param $folder String optional - mail box folder name
	 * @returns MailManager_Connector Object
	 */
	static function connectorWithModel($model, $folder='') {
		
		$port = 143; // IMAP
       
		if (strcasecmp($model->protocol(), 'pop') === 0) $port = 110; // NOT IMPLEMENTED
		else if (strcasecmp($model->ssltype(), 'ssl') === 0) $port = 993; // IMAP SSL
           
		$url = sprintf('{%s:%s/%s/%s/%s}%s', $model->server(), $port, $model->protocol(), 
			$model->ssltype(), $model->certvalidate(), $folder);
		$baseUrl = sprintf('{%s:%s/%s/%s/%s}', $model->server(), $port, $model->protocol(),
			$model->ssltype(), $model->certvalidate());
      //$port=110;
       $url="{".$model->server().":995/pop3/ssl/novalidate-cert}".$folder;
    //   $url="{".$model->server()."::143/imap}".$folder;
         // $url="{".$model->server().":143}".$folder;
     
		return new self($url, $model->username(), $model->password(), $baseUrl);
	}

	
	/**
	 * Opens up imap connection to the specified url
	 * @param $url String - mail server url
	 * @param $username String  - user name of the mail box
	 * @param $password String  - pass word of the mail box
	 * @param $baseUrl Optional - url of the mailserver excluding folder name.
	 *	This is used to fetch the folders of the mail box
	 */
	function __construct($url, $username, $password, $baseUrl=false) {
		$boxUrl = $this->convertCharacterEncoding(html_entity_decode($url),'UTF7-IMAP','UTF-8'); //handle both utf8 characters and html entities
		$this->mBoxUrl = $boxUrl;
		$this->mBoxBaseUrl = $baseUrl; // Used for folder List
		/**
		 * imap_open 服务未开启
		 * @author Tujt 2014-09-25
		 */
		if(function_exists('imap_open')){
		 
         //$url="{imap.qq.com/pop3:110}INBOX";
         
			$this->mBox = @imap_open($url, $username, $password);
          
			$this->isError();
		}else{
			echo 'IMAPOPENERROR|'.getFixedLabel('LBL_Mail_Server').getFixedLabel('error');exit();
		}
	}


	/**
	 * Closes the connection
	 */
	function __destruct() {
		$this->close();
	}


	/**
	 * Closes the imap connection
	 */
	function close() {
		if (!empty($this->mBox)) {
			
			if ($this->mModified) imap_close($this->mBox, CL_EXPUNGE);
			else imap_close($this->mBox);
			
			$this->mBox = null;
		}
	}


	/**
	 * Checks for the connection
	 */
	function isConnected() {
		return !empty($this->mBox);
	}


	/**
	 * Returns the last imap error 
	 */
	function isError() {
		$this->mError = imap_last_error();
       
		return $this->hasError();
	}


	/**
	 * Checks if the error exists
	 */
	function hasError() {
		return !empty($this->mError);
	}


	/**
	 * Returns the error
	 */
	function lastError() {
		return $this->mError;
	}


	/**
	 * Reads mail box folders
	 * @param string $ref Optional - 
	 */
	function folders($ref="{folder}") {
		if ($this->mFolders) return $this->mFolders;
		global $current_user;
        require($root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
        
		$result = imap_getmailboxes($this->mBox, $ref, "*");
		if ($this->isError()) return false;
		//$result[0]=array("name"=>"INBOX");
        $findResult=array("INBOX"=>'',"Sent Messages"=>'','Drafts'=>'',"Deleted Messages"=>'');
        $chfindResult=array("INBOX"=>'收件箱',"Sent Messages"=>'发件箱','Drafts'=>'草稿',"Deleted Messages"=>'已删除邮件');
		$folders = array();
        
        foreach($findResult as $folderName=> $row) {
		 // echo $row->name."<br>";
          
		//	$folderName = str_replace($ref, "", $row->name);
           
			$folder = $this->convertCharacterEncoding( $folderName, "ISO_8859-1", "UTF7-IMAP" ); //Decode folder name
			if(array_key_exists($folderName,$findResult))
            {
                if($languageType=='zddh')
                {
                    $folders[] = $this->folderInstance($chfindResult[$foldName]);
                }
                else
                    $folders[] = $this->folderInstance($folder);
            }
            
		}
        
        /*
		foreach($result as $row) {
		  echo $row->name."<br>";
          
			$folderName = str_replace($ref, "", $row->name);
           
			$folder = $this->convertCharacterEncoding( $folderName, "ISO_8859-1", "UTF7-IMAP" ); //Decode folder name
			if(array_key_exists($folderName,$findResult))
            {
                if($languageType=='zddh')
                {
                    $folders[] = $this->folderInstance($chfindResult[$foldName]);
                }
                else
                    $folders[] = $this->folderInstance($folder);
            }
            
		}*/
		$this->mFolders = $folders;
		return $folders;
	}


	/**
	 * Used to update the folders optionus
	 * @param imap_stats flag $options
	 */
	function updateFolders($options=SA_UNSEEN) {
		$this->folders(); // Initializes the folder Instance 
		foreach($this->mFolders as $folder) {
			$this->updateFolder($folder, $options);
		}
	}


	/**
	 * Updates the mail box's folder
	 * @param MailManager_Model_Folder $folder - folder instance
	 * @param $options imap_status flags like SA_UNSEEN, SA_MESSAGES etc
	 */
	function updateFolder($folder, $options) {
		$mailbox = $this->convertCharacterEncoding($folder->name($this->mBoxUrl), "UTF7-IMAP","ISO_8859-1"); //Encode folder name
		$result = @imap_status($this->mBox, $mailbox, $options);
		if ($result) {
			if (isset($result->unseen)) $folder->setUnreadCount($result->unseen);
			if (isset($result->messages)) $folder->setCount($result->messages);
		}
	}


	/**
	 * Returns MailManager_Model_Folder Instance
	 * @param String $name - folder name
	 */
	function folderInstance($name) {
		return new MailManager_Model_Folder($name);
	}


	/**
	 * Sets a list of mails with paging
	 * @param String $folder - MailManager_Model_Folder Instance
	 * @param Integer $start  - Page number
	 * @param Integer $maxLimit - Number of mails
	 */
	function folderMails($folder, $start, $maxLimit) {
	   
              global $adb,$current_user;
               require_once("modules/MailManager/ListHeadMessage.php");
   	            $folderCheck = @imap_check($this->mBox);
                $step=$maxLimit ;
                $limitstart=$start*$maxLimit;
                $muids=array();
                $sql='select group_concat(muid) from ld_mailmanager_mailrecord where userid=? order by muid asc limit 0,'.$maxLimit*2;
                $result=$adb->pquery($sql,array($current_user->id));
                if($adb->num_rows($result)>0)
               {
                        $muids=explode(",",$adb->query_result($result,0,0));
                        
                         $sql='select mailrecordid,msubject,mto,mdate,mfrom,muid,seen  from ld_mailmanager_mailrecord  where userid=? 
                                        order by muid desc limit  '."$limitstart,$step ";
                        $result=$adb->pquery($sql,array($current_user->id));
                        $rows=$adb->num_rows($result);
                        
                        for($i=0;$i<$rows;$i++)
                        {
                                    $subject=$adb->query_result($result,$i,'msubject');
                                    $from=$adb->query_result($result,$i,'mfrom');
                                    
                                    $to=$adb->query_result($result,$i,'to');
                                    $date=$adb->query_result($result,$i,'mdate');
                                    $seen=$adb->query_result($result,$i,'seen');
                                    $muid=$adb->query_result($result,$i,'muid');
                                    $mmsgno=$adb->query_result($result,$i,'muid');
                                    $mailrecordid=$adb->query_result($result,$i,'mailrecordid');
                                    
                                    if(empty($mmsgno))
                                    {
                                       $mmsgno= imap_msgno($this->mBox,$muid);
                                    }
                                    $tmpobj=new ListHeadMessage();
                                    $tmpobj->mailrecordid=$mailrecordid;
                                    $tmpobj->seen=$seen;
                                    $tmpobj->subject=$subject;
                                    $tmpobj->from=$from;
                                    $tmpobj->date=$date;
                                    $tmpobj->uid=$muid;
                                    $tmpobj->msgno=$mmsgno;
                                   
                                    $records[]=$tmpobj;
                                    
                     }
               }
            $tmprecords=$records;        
            $reverse_start = $folderCheck->Nmsgs - ($start*$maxLimit);   
           
            $reverse_end = $reverse_start - $maxLimit + 1;
         
         if ($folderCheck->Nmsgs&&sizeof($records)<$maxLimit) {
    		
    			if ($reverse_start < 1) $reverse_start = 1;
    			if ($reverse_end < 1) $reverse_end = 1;
                if(sizeof($records)>0)
                    $dbmaxnmailsequence=imap_msgno($this->mBox,$records[0]->uid)+1;
                else
                    $dbmaxnmailsequence=$folderCheck->Nmsgs+1;
                    
                  
                 if($dbmaxnmailsequence<=$folderCheck->Nmsgs&&$reverse_start==$folderCheck->Nmsgs)
                 {
                    //获取新邮件
                    $sequence = sprintf("%s:%s", $folderCheck->Nmsgs, $dbmaxnmailsequence);
                    if(is_array($records))
        		          	$tmprecords = array_merge(imap_fetch_overview($this->mBox, $sequence),$records);
                     else   
                            $tmprecords = imap_fetch_overview($this->mBox, $sequence);
                            
                 }
       
    		    if(sizeof($tmprecords)<$maxLimit)
        		{
                  //  $sequence = sprintf("%s:%s", $reverse_end+$maxLimit-sizeof($tmprecords)-1, $reverse_end);
                  $maxsequence=$reverse_end+$maxLimit-sizeof($tmprecords)-1;
                 
                 
                   if($maxsequence>$reverse_start)
                   {
                    //最后一页，没有需要的总记录数据
                    $maxsequence=$reverse_start;
                   }
               
                   for($tmpreverse_end=$reverse_end;$tmpreverse_end<=$maxsequence;$tmpreverse_end++)
                   {
                        $tmpmuid= imap_uid($this->mBox,$tmpreverse_end);
                       
                         if(!in_array($tmpmuid,$muids))
                         {
                            $emailsequence[]=$tmpreverse_end;
                         }
                   }
        	      
                    if(is_array($emailsequence)&&$emailsequence[0]>0)
                    {
                        $adb=null;
                        $adb=PearDatabase::getInstance();
                        $tmpmailarr=  imap_fetch_overview($this->mBox, implode($emailsequence, ','));
                    }
                    
                }
              
                if(is_array($tmpmailarr)&&is_array($tmprecords))
                {
                        $tmprecords=array_merge($tmprecords,$tmpmailarr);
                }
                else if(is_array($tmpmailarr))
                {
                        $tmprecords=$tmpmailarr;
                }
        			
    		}
           $records=$tmprecords;
           $mails=array();
            
    //	echo '<pre>';
        //print_r($adb);
        //echo '</pre>';
       // exit();
       
        foreach($records as $result) {
            
            $Obj=MailManager_Model_Message::parseOverview($result);
               if(empty($result->mailrecordid))
               {
                $sql='insert into ld_mailmanager_mailrecord(userid,mfrom,mto,mdate,msubject,muid,mmsgno,seen)
                    value(?,?,?,?,?,?,?,?)';
                $adb->pquery($sql,array($current_user->id,$Obj->from(),$Obj->to(),$Obj->date(),$Obj->subject(),$Obj->muid(),$Obj->msgNo(),0));
             
                
               }
                $mails[]=$Obj;
                //array_unshift($mails, $Obj);
        }
      
	   	$folder->setMails($mails);
           
		$folder->setPaging($reverse_end, $reverse_start, $maxLimit, $folderCheck->Nmsgs, $start);
	}
        
	


	/**
	 * Return the cache interval
	 */
	function clearDBCacheInterval() {
		// TODO Provide configuration option.
		if (self::$DB_CACHE_CLEAR_INTERVAL) {
		 
			return strtotime(self::$DB_CACHE_CLEAR_INTERVAL);
		}
		return false;
	}


	/**
	 * Clears the cache data
	 */
	function clearDBCache() {
	   return false;
		// Trigger purne any older mail saved in DB first
		$interval = $this->clearDBCacheInterval();
		
		$timenow = strtotime("now");
		
		// Optimization to avoid trigger for ever mail open (with interval specified)
		$lastClearTimeFromSession = false;
		if ($interval && isset($_SESSION) && isset($_SESSION['mailmanager_clearDBCacheIntervalLast'])) {
			$lastClearTimeFromSession = intval($_SESSION['mailmanager_clearDBCacheIntervalLast']);
			if (($timenow - $lastClearTimeFromSession) < ($timenow - $interval)) {
				$interval = false;
			}
		}
		if ($interval) {
			MailManager_Model_Message::pruneOlderInDB($interval);
			$_SESSION['mailmanager_clearDBCacheIntervalLast'] = $timenow;
		}
	}


	/**
	 * Function which deletes the mails
	 * @param String $msgno - List of message number seperated by commas.
	 */
	function deleteMail($msgno){
		$msgno = trim($msgno,',');
		$msgno = explode(',',$msgno);
		for($i = 0;$i<count($msgno);$i++){
			@imap_delete($this->mBox, $msgno[$i]);
		}	
	}


	/**
	 * Function which moves mail to another folder
	 * @param String $msgno - List of message number separated by commas
	 * @param String $folderName - folder name
	 */
	function moveMail($msgno, $folderName){
		$msgno = trim($msgno,',');
		$msgno = explode(',',$msgno);
		$folder = $this->convertCharacterEncoding(html_entity_decode($folderName),'UTF7-IMAP','UTF-8'); //handle both utf8 characters and html entities
		for($i = 0;$i<count($msgno);$i++){
			@imap_mail_move($this->mBox, $msgno[$i], $folder);
		}
		@imap_expunge($this->mBox);
	}


	/**
	 * Creates an instance of Message
	 * @param String $msgno - Message number
	 * @return MailManager_Model_Message
	 */
	function openMail($msgno) {
		$this->clearDBCache();
		return new MailManager_Model_Message($this->mBox, $msgno, true);
	}


	/**
	 * Marks the mail as Unread
	 * @param <String> $msgno - Message Number
	 */
	function markMailUnread($msgno) {
		imap_clearflag_full( $this->mBox, $msgno, '\\Seen');
		$this->mModified = true;
	}


	/**
	 * Marks the mail as Read
	 * @param String $msgno - Message Number
	 */
	function markMailRead($msgno) {
		imap_setflag_full($this->mBox, $msgno, '\\Seen');
		$this->mModified = true;
	}


	/**
	 * Searches the Mail Box with the query
	 * @param String $query - imap search format
	 * @param MailManager_Model_Folder $folder - folder instance
	 * @param Integer $start - Page number
	 * @param Integer $maxLimit - Number of mails
	 */
	function searchMails($query, $folder, $start, $maxLimit) {
		$nos =imap_search($this->mBox, $query, SE_FREE, "UTF-8");

		if (!empty($nos)) {
			$nmsgs = count($nos);
			
			$reverse_start = $nmsgs - ($start*$maxLimit);
			$reverse_end   = $reverse_start - $maxLimit;
			
			if ($reverse_start < 1) $reverse_start = 1;
			if ($reverse_end < 1) $reverse_end = 0;

			if($nmsgs > 1)
				$nos = array_slice($nos, $reverse_end, ($reverse_start-$reverse_end));
			
			// Reverse order the messages
			rsort($nos, SORT_NUMERIC);
			
			$mails = array();
			$records = imap_fetch_overview($this->mBox, implode(',', $nos));
			foreach($records as $result) {
				array_unshift($mails, MailManager_Model_Message::parseOverview($result));
			}
			$folder->setMails($mails);
			$folder->setPaging($reverse_end, $reverse_start, $maxLimit, $nmsgs, $start);  //-1 as it starts from 0
		}
	}

	
	/**
	 * Returns list of Folder for the Mail Box
	 * @return Array folder list
	 */
	function getFolderList() {
		if(!empty($this->mBoxBaseUrl)) {
			$list = @imap_list($this->mBox, $this->mBoxBaseUrl, '*');
			if (is_array($list)) {
				foreach ($list as $val) {
					$folder = $this->convertCharacterEncoding( $val, 'ISO_8859-1', 'UTF7-IMAP' ); //Decode folder name
					$folderList[] =  preg_replace("/{(.*?)}/", "", $folder);
				}
			}
		}
		return $folderList;
	}

	 function convertCharacterEncoding($value, $toCharset, $fromCharset) {
		if (function_exists('mb_convert_encoding')) {
			$value = mb_convert_encoding($value, $toCharset, $fromCharset);
		} else {
			$value = iconv($toCharset, $fromCharset, $value);
		}
		return $value;
	}
}
?>