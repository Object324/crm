<?php
/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/



/** Creates a file with all the user, user-role,user-profile, user-groups informations 
  * @param $userid -- user id:: Type integer
  * @returns user_privileges_userid file under the user_privileges directory
 */

function createUserPrivilegesfile($userid,$type='')
{


	global $root_directory,$adb,$current_user;


    //文件权限，can
    if(file_exists($root_directory.'user_privileges/user_privileges_'.$userid.'.php')&&filesize($root_directory.'user_privileges/user_privileges_'.$userid.'.php')>0)
    {
        chmod($root_directory.'user_privileges/user_privileges_'.$userid.'.php',0777);
    if($type=='authen')
           return ;//登陆时如果该用户的文件存在，则不在创建
    }
//@unlink($root_directory.'user_privileges/user_privileges_'.$userid.'.php');
      $global_crmredisobj=CRMRedis::getInstance();
        if($global_crmredisobj!='error')
        {
            $global_crmredisobj->del("loginuser".$userid);
            
        }
       
	$handle=fopen($root_directory.'user_privileges/user_privileges_'.$userid.'.php',"w+");

  $profile = new Profile();
	if($handle)
	{
		$newbuf='';
		$newbuf .="<?php\n\n";
		$newbuf .="\n";		
		$newbuf .= "//This is the access privilege file\n";
      
            $user_focus= new Users();


		$user_focus->retrieve_entity_info($userid,"Users");
		$userInfo=Array();
		$user_focus->column_fields["id"] = '';
		$user_focus->id = $userid; 
		foreach($user_focus->column_fields as $field=>$value_iter)
 	      {
        	       if($field=='imagename')
                   {
                    
                     $sql='select path,name,ld_attachments.attachmentsid from
                        ld_salesmanattachmentsrel INNER JOIN ld_attachments  
                        on ld_attachments.attachmentsid=ld_salesmanattachmentsrel.attachmentsid
                        where smid=? ';
         
                        $user_result=$adb->pquery($sql,array($user_focus->id))   ;
                        if($adb->num_rows($user_result)>0)
                        {
                            $attachmentsid=$adb->query_result($user_result,$i,'attachmentsid');
                            $path=$adb->query_result($user_result,$i,'path');
                            $userimagename=$adb->query_result($user_result,$i,'name');
                            $userimagetypes=explode('.',$userimagename);
                            $userimagetype=$userimagetypes[sizeof($userimagetypes)-1];//获取用户照片的后缀名
                            if(!empty($attachmentsid)&&!empty($path))
                             $filepath=$path.$attachmentsid.'_1.'.$userimagetype;
                            else
                              $filepath='';
                        }
                       $userInfo['imagename']=$filepath;
                     
                   }
                   else
               		$userInfo[$field]= $user_focus->$field;
                    
        	}
         
   
		if($user_focus->is_admin == 'on')
		{
			$newbuf .= "\$is_admin=true;\n";
			$newbuf .="\n";		
			$newbuf .= "\$user_info=".constructSingleStringKeyValueArray($userInfo).";\n";
           
			$newbuf .= "\n";
			$newbuf .= "?>";
			fputs($handle, $newbuf);
			fclose($handle);

          // $result= beast_encode_file($root_directory.'user_privileges/user_privileges_'.$userid.'.php', $root_directory.'user_privileges/user_privileges_'.$userid.'.php', 0, BEAST_ENCRYPT_TYPE_DES);

            if(function_exists("opcache_reset"))
                opcache_invalidate(globalStatic::$root_directory."user_privileges/user_privileges_$userid.php",true);

			return;	
		}
		else
		{
			$newbuf .= "\$is_admin=false;\n";
			$newbuf .= "\n";
			$user_role = $profile->getUserProfileId($userid);
			$user_role_info = $profile->getProfileinfo($user_role);
			$user_role_parent=$user_role_info['profilename'];

			//$def_org_share=getDefaultSharingAction();
			//$parentRoles=getParentRole($user_role);
			$newbuf .= "\$current_user_roles='".$user_role."';\n";
			$newbuf .= "\n";
			$newbuf .= "\$current_user_parent_role_seq='".$user_role_parent."';\n";
			$newbuf .= "\n";
		
			$newbuf .= "\$subordinate_roles='';\n";
			$newbuf .="\n";		
			$newbuf .= "\$parent_roles='';\n";
			$newbuf .="\n";		
			$newbuf .= "\$subordinate_roles_users='';\n";
			$newbuf .="\n";		
			$newbuf .= "\$user_info=".constructSingleStringKeyValueArray($userInfo).";\n";

			$newbuf .= "?>";
       
        
			fputs($handle, $newbuf);
			fclose($handle);
		}

        //beast_encode_file($root_directory.'user_privileges/user_privileges_'.$userid.'.php', $root_directory.'user_privileges/user_privileges_'.$userid.'.php', '2038-10-1', BEAST_ENCRYPT_TYPE_DES);
        if(function_exists("opcache_reset"))
                opcache_invalidate(globalStatic::$root_directory."user_privileges/user_privileges_$userid.php",true);
	}

}


/** Converts the input array  to a single string to facilitate the writing of the input array in a flat file 

  * @param $var -- input array:: Type array
  * @returns $code -- contains the whole array in a single string:: Type array 
 */
function constructArray($var)
{
	if (is_array($var))
	{
       		$code = 'array(';
       		foreach ($var as $key => $value)
		{ 
		  /*
          edit by LD can
          date:20130307
          reason: 0003405: 日程管理中点击 界面上的设置 ，选择用户之后点击保存，报错
          */
		       if($value=='')
               {
                $code .= "'".$key."'=>"."' '".' ,';
               }
               else 
               {
                $code .= "'".$key."'=>".$value.',';
               }
           		
       		}
       		$code .= ')';
       		return $code;
   	}
}

/** Converts the input array  to a single string to facilitate the writing of the input array in a flat file 

  * @param $var -- input array:: Type array
  * @returns $code -- contains the whole array in a single string:: Type array 
 */
function constructSingleStringValueArray($var)
{

        $size = sizeof($var);
        $i=1;
        if (is_array($var))
        {
                $code = 'array(';
                foreach ($var as $key => $value)
                {
                        if($i<$size)
                        {
                                $code .= $key."=>'".$value."',";
                        }
                        else
                        {
                                $code .= $key."=>'".$value."'";
                        }
                        $i++;
                }
                $code .= ')';
                return $code;
        }
}

/** Converts the input array  to a single string to facilitate the writing of the input array in a flat file 

  * @param $var -- input array:: Type array
  * @returns $code -- contains the whole array in a single string:: Type array 
 */
function constructSingleStringKeyAndValueArray($var)
{

        $size = sizeof($var);
        $i=1;
        if (is_array($var))
        {
                $code = 'array(';
                foreach ($var as $key => $value)
                {
                        if($i<$size)
                        {
                                $code .= "'".$key."'=>".$value.",";
                        }
                        else
                        {
                                $code .= "'".$key."'=>".$value;
                        }
                        $i++;
                }
                $code .= ')';
                return $code;
        }
}



/** Converts the input array  to a single string to facilitate the writing of the input array in a flat file 

  * @param $var -- input array:: Type array
  * @returns $code -- contains the whole array in a single string:: Type array 
 */
function constructSingleStringKeyValueArray($var) {
	global $adb;
    $size = sizeof($var);
    $i=1;
    if (is_array($var)) {
		$code = 'array(';
		foreach ($var as $key => $value) {
		    //fix for signatue quote(') issue
		   // $value=$adb->sql_escape_string($value);    //php5.4 下(“系统管理员"文字会产生乱码)
			if($i<$size) {
				$code .= "'".$key."'=>'".$value."',";
			} else {
				$code .= "'".$key."'=>'".$value."'";
			}
			$i++;
		}
	    $code .= ')';
	    return $code;
    }
}


/** Converts the input array  to a single string to facilitate the writing of the input array in a flat file 

  * @param $var -- input array:: Type array
  * @returns $code -- contains the whole array in a single string:: Type array 
 */
function constructSingleArray($var)
{
	if (is_array($var))
	{
       		$code = 'array(';
       		foreach ($var as $value)
		{
           		$code .= $value.',';
       		}
       		$code .= ')';
       		return $code;
   	}
}

/** Converts the input array  to a single string to facilitate the writing of the input array in a flat file 

  * @param $var -- input array:: Type array
  * @returns $code -- contains the whole array in a single string:: Type array 
 */
function constructSingleCharArray($var)
{
	if (is_array($var))
	{
       		$code = "array(";
       		foreach ($var as $value)
		{
           		$code .="'".$value."',";
       		}
       		$code .= ")";
       		return $code;
   	}
}


/** Converts the input array  to a single string to facilitate the writing of the input array in a flat file 

  * @param $var -- input array:: Type array
  * @returns $code -- contains the whole array in a single string:: Type array 
 */
function constructTwoDimensionalArray($var)
{
	if (is_array($var))
	{
       		$code = 'array(';
       		foreach ($var as $key => $secarr)
		{
           		$code .= $key.'=>array(';
			foreach($secarr as $seckey => $secvalue)
			{
				$code .= $seckey.'=>'.$secvalue.',';
			}
			$code .= '),';
       		}
       		$code .= ')';
       		return $code;
   	}
}

/** Converts the input array  to a single string to facilitate the writing of the input array in a flat file 

  * @param $var -- input array:: Type array
  * @returns $code -- contains the whole array in a single string:: Type array 
 */
function constructTwoDimensionalValueArray($var)
{
	if (is_array($var))
	{
       		$code = 'array(';
       		foreach ($var as $key => $secarr)
		{
           		$code .= $key.'=>array(';
			foreach($secarr as $seckey => $secvalue)
			{
				$code .= $secvalue.',';
			}
			$code .= '),';
       		}
       		$code .= ')';
       		return $code;
   	}
}

/** Converts the input array  to a single string to facilitate the writing of the input array in a flat file 

  * @param $var -- input array:: Type array
  * @returns $code -- contains the whole array in a single string:: Type array 
 */
function constructTwoDimensionalCharIntSingleArray($var)
{
	if (is_array($var))
	{
       		$code = "array(";
       		foreach ($var as $key => $secarr)
		{
           		$code .= "'".$key."'=>array(";
			foreach($secarr as $seckey => $secvalue)
			{
				$code .= $seckey.",";
			}
			$code .= "),";
       		}
       		$code .= ")";
       		return $code;
   	}
}

/** Converts the input array  to a single string to facilitate the writing of the input array in a flat file 

  * @param $var -- input array:: Type array
  * @returns $code -- contains the whole array in a single string:: Type array 
 */
function constructTwoDimensionalCharIntSingleValueArray($var)
{
	if (is_array($var))
	{
       		$code = "array(";
       		foreach ($var as $key => $secarr)
		{
           		$code .= "'".$key."'=>array(";
			foreach($secarr as $seckey => $secvalue)
			{
				$code .= $secvalue.",";
			}
			$code .= "),";
       		}
       		$code .= ")";
       		return $code;
   	}
}




?>