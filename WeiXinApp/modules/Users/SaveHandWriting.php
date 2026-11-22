<?php
//手写签名 - 保存图片
global $adb,$root_directory,$current_user;
$base64_image_content = $_REQUEST['base64_image_content'];
$module = $_REQUEST['frommodule'];
$reocrd = $_REQUEST['recordid'];
$fieldname = $_REQUEST['fieldname'];
$data = array();
if(!empty($base64_image_content) && !empty($module) && !empty($reocrd) && !empty($fieldname)){
	if (preg_match('/^(data:\s*image\/(\w+);base64,)/', $base64_image_content, $result)){
		$type = $result[2];
		$fyear=date("Y");
		$fmonth=date('F');
		$fday=date('j');//获取当前月份第几天

		if(!file_exists($root_directory.'storage/'.$fyear)){
			 mkdir($root_directory.'storage/'.$fyear,0777);
		}
		if(!file_exists($root_directory.'storage/'.$fyear.'/'.$fmonth)){
			 mkdir($root_directory.'storage/'.$fyear.'/'.$fmonth,0777);
		}
		if(!file_exists($root_directory.'storage/'.$fyear.'/'.$fmonth.'/'.$fday)){
			 mkdir($root_directory.'storage/'.$fyear.'/'.$fmonth.'/'.$fday,0777);
		}
		$uploadDir=$root_directory.'storage/'.$fyear.'/'.$fmonth.'/'.$fday.'/';
		$targetFolder = 'storage/'.$fyear.'/'.$fmonth.'/'.$fday.'/';
		$filename = $module . '_' . $current_user->id . '_'.time().".{$type}";
        $filename= FileFileterString($filename);
        $new_file = $uploadDir.$filename;
		if (file_put_contents($new_file, base64_decode(str_replace($result[1], '', $base64_image_content)))){
			/* 
			*edit:chj
			*date:2020-07-13
			*reason:审批意见增加手写签名功能：因为手写签名的图片路径直接存储ld_approve表，所以这里不进行存储保存
			*/
			if(!empty($_REQUEST['approve']) && $_REQUEST['approve'] == 'yes'){
				$data['list'] = array('filename' => $filename,'filepath' => $targetFolder);
				ConvertTojsonString(1,$data,'success');
			}else{
				$tabid = getTabid($module);
				$query = 'select 1 from ld_field_signature where tabid = ? and recordid = ? and fieldname = ?';
				$result = $adb->pquery($query,array($tabid,$reocrd,$fieldname));
				$num_rows = $adb->num_rows($result);
				if($num_rows >= 1){
					$query = 'update ld_field_signature set path = ?,name = ?,datetime = ? where tabid = ? and recordid = ? and fieldname = ?';
					$adb->pquery($query,array($targetFolder,$filename,date('Y-m-d H:i:s'),$tabid,$reocrd,$fieldname));
				}else{
					$query = 'insert into ld_field_signature(tabid,recordid,fieldname,path,name,datetime) value (?,?,?,?,?,?)';
					$adb->pquery($query,array($tabid,$reocrd,$fieldname,$targetFolder,$filename,date('Y-m-d H:i:s')));
				}
				$data['list'] = array('filename' => $filename,'filepath' => $targetFolder,'handwriting_datetime'=>date('Y-m-d H:i:s'));
				ConvertTojsonString(1,$data,'success');
			}
		}
	}
}else{
	if(!empty($_REQUEST['filename']) && !empty($_REQUEST['filepath'])){
		$tabid = getTabid($module);
		$filename = $_REQUEST['filename'];
        $filename= FileFileterString($filename); 
		$targetFolder = $_REQUEST['filepath'];
		$query = 'select 1 from ld_field_signature where tabid = ? and recordid = ? and fieldname = ?';
		$result = $adb->pquery($query,array($tabid,$reocrd,$fieldname));
		$num_rows = $adb->num_rows($result);
		if($num_rows >= 1){
				$query = 'update ld_field_signature set path = ?,name = ?,datetime = ? where tabid = ? and recordid = ? and fieldname = ?';
				$adb->pquery($query,array($targetFolder,$filename,date('Y-m-d H:i:s'),$tabid,$reocrd,$fieldname));
			}else{
				$query = 'insert into ld_field_signature(tabid,recordid,fieldname,path,name,datetime) value (?,?,?,?,?,?)';
				$adb->pquery($query,array($tabid,$reocrd,$fieldname,$targetFolder,$filename,date('Y-m-d H:i:s')));
			}
		
		$data['list'] = array('filename' => $filename,'filepath' => $targetFolder,'handwriting_datetime'=>date('Y-m-d H:i:s'));
		ConvertTojsonString(1,$data,'success');	
	}
}
ConvertTojsonString(-1,array(),'success');
?>