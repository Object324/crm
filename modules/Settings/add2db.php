<?php

/*********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
** The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
* 
 ********************************************************************************/

global $adb;
	$uploaddir = $root_directory ."/dataCache/test/logo/" ;
	$logo_type_array = array('big','small');
	foreach($logo_type_array as $logo_type){
		$file_name = from_html($_REQUEST['imgname_'.$logo_type]);
		$imgurl = from_html($_REQUEST['imgurl_'.$logo_type]);
		$prev_file = from_html($_REQUEST['prev_file_'.$logo_type]);
        //判断是否有修改图片
		if ($imgurl !=""){		
			if ($prev_file != "logo_big_white.png" && $prev_file != "logo_mini_1.png" ){
				unlink($uploaddir.$prev_file); // 删除之前的文件，但不能删除默认logo
			}			
			$pathInfo = pathinfo($file_name);
			$name = $pathInfo['filename'];
			$file_name = $name. '.png';
			$file_counter = 1;
			while(file_exists($uploaddir . '/' . $file_name)){
				//防止与已有文件冲突
				$file_name = $name . '('.$file_counter.').png';
				$file_counter++;
			}
			if($logo_type == 'big'){
				$organization_logoname = $file_name;
			}else{
				$organization_smalllogoname = $file_name;
			}
			$arr=array("ASCII","UTF-8","GB2312","GBK",'BIG-5');
			$encode=mb_detect_encoding($file_name, $arr); 
			if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix')
			{
			//获取系统类型，如果是非windows系统则不用修改编码格式
			}
			else if($encode!=='UTF-8')
			{
				$file_name=mb_convert_encoding($file_name,'UTF-8',$encode);
			}
			//将base64转为文件存入文件夹
			$Imgbase64 = str_replace('data:image/png;base64,', '', $imgurl);
			$file = fopen($uploaddir.$file_name,"wb");
			$decodeFile = base64_decode($Imgbase64);
			$bytes_written = fwrite($file, $decodeFile);
			fclose($file); 
		}else{
			if($logo_type == 'big'){
				$organization_logoname = $prev_file;
			}else{
				$organization_smalllogoname = $prev_file;
			}
		}
	}
	$saveflag="true";
	// $uploaddir = $root_directory ."/dataCache/test/logo/" ;// set this to wherever
	// $saveflag="true";
	// $nologo_specified="true";
	// $error_flag ="";
	// $nologo_specified="false";
	// $btn_file_name_array = array('binFile','smallbinFile');
	// $organization_logoname = '';
	// $organization_smalllogoname = '';
	// foreach($btn_file_name_array as $btn_file_name){
	// 	$binFile = $_FILES[$btn_file_name]['name'];
	// 	//echo $btn_file_name.'_hidden';echo '<br><br>';
	// 	if(isset($_REQUEST[$btn_file_name.'_hidden']) && $_REQUEST[$btn_file_name.'_hidden'] != '') {
	// 		$filename = $_REQUEST['binFile_hidden'];
	// 	} else {
	// 		$filename = ltrim(basename(" ".$binFile));
	// 	}
    //     FileSecurityCheck($filename);
    //      $fileParts = pathinfo($filename);
	// 	$filetype= $_FILES[$btn_file_name]['type'];
	// 	$ffilesize = $_FILES[$btn_file_name]['size'];
	// 	$filetype_array=explode("/",$filetype); 
	// 	$file_type_val=strtolower($filetype_array[1]);
	// 	if($ffilesize != 0)
	// 	{
	// 		if (($file_type_val == "jpeg" ) || ($file_type_val == "png") || ($file_type_val == "jpg" ) ||  ($file_type_val == "gif" ) || ($file_type_val == "bmp")|| ($file_type_val == "ico") ) //Checking whether the file is an image or not
	// 		{
	// 		  if(strtolower($fileParts['extension'])=='jpg'||strtolower($fileParts['extension'])=='jpeg'
    //           ||strtolower($fileParts['extension'])=='png'||strtolower($fileParts['extension'])=='ico')
	// 			$savelogo="true";
	// 		}
            
	// 		else
	// 		{
	// 			$savelogo="false";
	// 			$error_flag ="1";
	// 		}
			
	// 	}
	// 	else
	// 	{
	// 		$savelogo="false";
	// 		if($filename != "") 
	// 			$error_flag ="2";
	// 	}
      
	// 	$errorCode =  $_FILES[$btn_file_name]['error'];
	// 	if($errorCode == 4)
	// 	{
	// 		$savelogo="false";	    	
	// 		$errorcode="";
	// 		$error_flag="5";
	// 		$nologo_specified="true";
	// 	}
	// 	else if($errorCode == 2)
	// 	{
	// 		$error_flag ="3";
	// 		$savelogo="false";	    	
	// 		$nologo_specified="false";
	// 	}
	// 	else if($errorCode == 3 )
	// 	{
	// 		$error_flag ="4";
	// 		$savelogo="false";
	// 		$nologo_specified="false";
	// 	}
	// 	$file_name=$_FILES[$btn_file_name]["name"];
	// 	if($btn_file_name == 'binFile'){
	// 		$organization_logoname = $file_name;
	// 	}else{
	// 		$organization_smalllogoname = $file_name;
	// 	}
	// 	$arr=array("ASCII","UTF-8","GB2312","GBK",'BIG-5');
	// 	$encode=mb_detect_encoding($file_name, $arr); 
	// 	if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix')
	// 	{
	// 	//获取系统类型，如果是非windows系统则不用修改编码格式

	// 	}
	// 	else if($encode=='UTF-8')
	// 	{
	// 		$file_name=iconv('UTF-8','gb2312',$file_name);
	// 	}
	// 	if($savelogo=="true")
	// 	{	
	// 		move_uploaded_file($_FILES[$btn_file_name]["tmp_name"],$uploaddir.$file_name); 
	// 	}
	// 	elseif($savelogo=="false" && $error_flag=="")
	// 	{
	// 		$savelogo="true";
	// 		if($btn_file_name == 'binFile')
	// 			$organization_logoname=$_REQUEST['PREV_FILE'];
	// 		else
	// 			$organization_smalllogoname=$_REQUEST['SMALL_PREV_FILE'];
	// 	}
	// 	else
	// 	{
	// 		if($btn_file_name == 'binFile')
	// 			$organization_logoname=$_REQUEST['PREV_FILE'];
	// 		else
	// 			$organization_smalllogoname=$_REQUEST['SMALL_PREV_FILE'];
	// 	}
	// }
	if($saveflag=="true")
	{
		$organization_name=from_html($_REQUEST['organization_name']);
		$org_name=$_REQUEST['org_name'];
		$organization_address=from_html($_REQUEST['organization_address']);
		$organization_city=from_html($_REQUEST['organization_city']);
		$organization_state=from_html($_REQUEST['organization_state']);
		$organization_code=from_html($_REQUEST['organization_code']);
		$organization_country=from_html($_REQUEST['organization_country']);
		$organization_phone=from_html($_REQUEST['organization_phone']);
		$organization_fax=from_html($_REQUEST['organization_fax']);
		$organization_website=from_html($_REQUEST['organization_website']);
		$organization_logo=from_html($_REQUEST['organization_logo']);
		//230531 wym crm地址保存，并检查其是否为有效url
        $organization_crmaddress=from_html($_REQUEST['organization_crmaddress']);

        if($organization_logoname == 'logo_big_light_0721.png' || $organization_logoname == 'logo_big_dark_0721.png'){
            $organization_logoname = '';
        }
        if($organization_smalllogoname == 'logo_mini_light_0721.png' || $organization_smalllogoname == 'logo_mine_dark_0721.png'){
            $organization_smalllogoname = '';
        }
        if(!empty($organization_crmaddress)){
            $organization_crmaddress_checked=checkAuthLink($organization_crmaddress);
        }

		$sql="SELECT * FROM ld_organizationdetails";
		$result = $adb->query($sql);
        $num_rows=$adb->num_rows($result);
        $organization_id=$adb->query_result($result,0,'organization_id');
		$org_name = decode_html($adb->query_result($result,0,'organizationname'));
        /**
         * edit:kevin
         * date:2013-06-09
         * reason:4167
         * if($org_name=='') 改为if(!$num_rows)
         */ 
		if(!$num_rows)
		{		
			$organizationId = $adb->getUniqueID('ld_organizationdetails');         
			$sql="INSERT INTO ld_organizationdetails
				(organization_id,organizationname, address, city, state, code, country, phone, fax, website, logoname,small_logoname,crm_address) values (?,?,?,?,?,?,?,?,?,?,?,?,?)";
			$params = array($organizationId,$organization_name, $organization_address, $organization_city, $organization_state, $organization_code,
							$organization_country, $organization_phone, $organization_fax, $organization_website, $organization_logoname,$organization_smalllogoname,$organization_crmaddress_checked);
                            $savelogo='true';   
		}
		else
		{
			$sql = "UPDATE ld_organizationdetails
				SET organizationname = ?, address = ?, city = ?, state = ?, code = ?, country = ?, 
				phone = ?, fax = ?, website = ?, logoname = ?,small_logoname = ?,crm_address = ? WHERE organization_id = ?";
			$params = array($organization_name, $organization_address, $organization_city, $organization_state, $organization_code, 
					$organization_country, $organization_phone, $organization_fax, $organization_website, decode_html($organization_logoname),decode_html($organization_smalllogoname),$organization_crmaddress_checked,$organization_id);
			$savelogo='true';
		}

		$adb->pquery($sql, $params);
       
		clearSmartyFiles();
    
		if($savelogo=="true")
		{
            $sql="select logoname,small_logoname from ld_organizationdetails";
            $result = $adb->pquery($sql, array());
         //   $organization_logo = decode_html($adb->query_result($result,0,'logoname'));
          /* $filename='dataCache/logo.php';
            $handle = fopen($filename, 'w');
            $newbuf = '';
            $newbuf .="<?php\n\n";
            $newbuf .="\n";
            $newbuf .= "\$logoname='" .$organization_logo . "';\n";
            $newbuf .= "\n";
            $newbuf .= "?>";
            fputs($handle, $newbuf);
            fclose($handle);*/
			$_REQUEST['diony']='diony';
			$logoname = $adb->query_result($result,0,'logoname');
			$small_logoname = $adb->query_result($result,0,'small_logoname');
            //wym 原先存在ld_organizationdetails表中,现在修改成在ld_module_setting_byuser表里,如果新表没数据则取老表的数据
            $menustyle = getUsersettingByLabel('notbymodule',$current_user->id,'Menustyle');
            if($menustyle){
                if($menustyle=='custom')
                    $menufont=getUsersettingByLabel('notbymodule',$current_user->id,'Menufont_color');
            }else{
                $menustyle = decode_html($adb->query_result($result,0,'menustyle'));
            }
            if(empty($small_logoname)){
                //浅色菜单模式
                if($menustyle == 'lightcolour' || $menufont=='black'){
            	   $small_logoname = 'logo_mini_light_0721.png';
                }
                else{
                    $small_logoname = 'logo_mini_dark_0721.png';
                }
            }
            if(empty($logoname)){
                //浅色菜单模式
                if($menustyle == 'lightcolour' || $menufont=='black'){
            	   $logoname = 'logo_big_light_0721.png';
                }
                else{
                    $logoname = 'logo_big_dark_0721.png';
                }
            }
			$arr['logoname']=$logoname;
			$arr['small_logoname']=$small_logoname;
            ConvertTojsonString(1,$arr,"success");
			//header("Location: index.php?parenttab=Settings&module=Settings&a=1&action=OrganizationConfig&blockidsetting=".$_REQUEST['blockidsetting']."&fieldidsetting=".$_REQUEST['fieldidsetting']);
		}
		/*elseif($savelogo=="false")
		{
			switch($flag)
			{
				case 1:
					$ERRORFLAG = "<font color='red'><B>".$mod_strings['LOGO_ERROR']."</B></font>";
					break;
				case 2:
					$ERRORFLAG = "<font color='red'><B>".$mod_strings['Error_Message']."<ul><li><font color='red'>".$mod_strings['Invalid_file']."</font><li><font color='red'>".$mod_strings['File_has_no_data']."</font></ul></B></font>";
					break;
				case 3:
					$ERRORFLAG = "<B><font color='red'>".$mod_strings['Sorry'].",".$mod_strings['uploaded_file_exceeds_maximum_limit'].".".$mod_strings['try_file_smaller']."</font></B>";
					break;
				case 4:
					$ERRORFLAG = "<b>".$mod_strings['Problems_in_upload'].". ".$mod_strings['Please_try_again']." </b><br>";
					break;
				default:
					$ERRORFLAG = '';
				
			}
			$_REQUEST['diony']='diony';
    		ConvertTojsonString(-1,array(),$ERRORFLAG);
		}*/
	

	}	
?>