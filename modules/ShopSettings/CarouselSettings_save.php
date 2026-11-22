<?php

global $adb,$current_user,$currentModule,$root_directory;

if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='save'){
    require(globalStatic::$root_directory.'user_privileges/user_language_'.$current_user->id.'.php');
    
    if(isset($_REQUEST['recordid'])&&!empty($_REQUEST['recordid'])){
        crm_load_class_file('cls_CarouselSettings',"modules/ShopSettings");
        $carouselobj = new cls_CarouselSettings();
        $carouselid = $_REQUEST['recordid'];
        $carouselinfo = $carouselobj->getCarouselinfoById($carouselid);
        $carousellinkinfo = $carouselobj->getCarousellinkinfoById($carouselid);
        $filePathid = $carouselid;
    }
    else{
        $query="select MAX(carouselid) as filepathid from ld_shop_carousels";
        $result = $adb->pquery($query,array());
        $filePathid= 0;
        if($adb->num_rows($result)>0){
            $filePathid = $adb->query_result($result,0,'filepathid');
        }
        $filePathid = $filePathid+1;
    }
    $saveimage="false";
    if(isset($_FILES['file'])&&!empty($_FILES['file'])){
        $uploadDir = $root_directory.'storage/ShopSettins/Carousel/';
        if(!file_exists($root_directory.'storage/ShopSettins')){
            mkdir($root_directory.'storage/ShopSettins',0777);
        } 
		if(!file_exists($uploadDir)){
			mkdir($uploadDir,0777);
		}
        
        $uploadfilename = $_FILES['file']['name'];
		$filename = ltrim(basename(" ".$uploadfilename));
        FileSecurityCheck($filename);//上传文件安全性检测
        $fileParts = pathinfo($filename);
        $filetype= $_FILES['file']['type'];
		$ffilesize = $_FILES['file']['size'];
		$filetype_array=explode("/",$filetype); 
		$file_type_val=strtolower($filetype_array[1]);
        if($ffilesize != 0)
		{
		    $filesize = $ffilesize;
		    if(!strpos($filesize,'B')){//新增的附件，需要计算附件大小并加上單位
                if ($filesize < 1024){
                    $filesize = $filesize . ' B';
                }
                elseif ($filesize > 1024 && $filesize < 1048576){
                    $filesize = round($filesize / 1024, 2) . ' KB';
                }
                else if ($filesize > 1048576){
                    $filesize = round($filesize / (1024 * 1024), 2) . ' MB';
                }
            }
            $ffilesize = $filesize;
            //判断上传文件类型
			if (($file_type_val == "jpeg" ) || ($file_type_val == "png") || ($file_type_val == "jpg" ) ||  ($file_type_val == "gif" ) || ($file_type_val == "bmp")|| ($file_type_val == "ico") ) //Checking whether the file is an image or not
			{
			  if(strtolower($fileParts['extension'])=='jpg'||strtolower($fileParts['extension'])=='jpeg'
              ||strtolower($fileParts['extension'])=='png'||strtolower($fileParts['extension'])=='ico'){
                
              }
			}
			else
            {
				ConvertTojsonString(-1,array(),getFixedLabel('GIVENFILEJPG'));
			}
            $errorCode =  $_FILES['file']['error'];
            if($errorCode != 0)
    		{
    			ConvertTojsonString(-1,array(),getFixedLabel('FILEUPLOADPROBLEMS'));//上传失败，请重试！
    		}
            $date = date('ymdHis',time());
            $file_name = 'CarouselSettins_'.$filePathid.'_'.$date.'.'.$fileParts['extension'];
            $arr=array("ASCII","UTF-8","GB2312","GBK",'BIG-5');
    		$encode=mb_detect_encoding($file_name, $arr); 
    		if(strtolower(PHP_OS)=='freebsd'||strtolower(PHP_OS)=='linux'||strtolower(PHP_OS)=='unix')
    		{
    		//获取系统类型，如果是非windows系统则不用修改编码格式
    
    		}
    		else if($encode=='UTF-8')
    		{
    			$file_name=iconv('UTF-8','gb2312',$file_name);
    		}
            if(!move_uploaded_file($_FILES['file']["tmp_name"],$uploadDir.$file_name)){
                ConvertTojsonString(-1,array(),getFixedLabel('FILEUPLOADPROBLEMS'));//上传失败，请重试！
            }
            if(isset($_REQUEST['oldfilename']) && $_REQUEST['oldfilename'] != ''&&$file_name!=$_REQUEST['oldfilename']){
                $oldfilename = $_REQUEST['oldfilename'];
                @unlink($uploadDir.$oldfilename);
            }
            $saveimage="true";
            
		}
		else
        {
			ConvertTojsonString(-1,array(),getFixedLabel('DOCNOINVALID'));//选择的文件没有数据或者不是有效的文件
		}
        
        
    }
    $linktype = $_REQUEST['linktype'];
    $linkid = $_REQUEST['linkid'];
    $status = $_REQUEST['carousel_status'];
    
    //更新或插入轮播图
    if(isset($_REQUEST['recordid'])&&!empty($_REQUEST['recordid']))
    {
        $carouselid = $_REQUEST['recordid'];
        if($saveimage == "true"){
            $sql = "update ld_shop_carousels set linktype = ?, linkid = ?,status = ?,uploadfile_name=?,file_type=?,file_path=?,file_size=?,newfile_name=? where carouselid = ?";
            $adb->pquery($sql,array($linktype,$linkid,$status,$filename,$filetype,'storage/ShopSettins/Carousel/',$ffilesize,$file_name,$carouselid));
        }
        else{
            $sql = "update ld_shop_carousels set linktype = ?, linkid = ?,status = ? where carouselid = ?";
            $adb->pquery($sql,array($linktype,$linkid,$status,$carouselid));
            
        }
    }
    else
    {
        $query = "select MAX(carouselseq) as carouselseq from ld_shop_carousels";
        $queryresult = $adb->pquery($query,array());
        if($adb->num_rows($queryresult)){
            $carouselseq = $adb->query_result($queryresult,0,'carouselseq');
            $carouselseq = $carouselseq+1;
        }
        else{
            $carouselseq = 1;
        }
        $sql = "insert into ld_shop_carousels(linktype,linkid,status,carouselseq,uploadfile_name,file_type,file_path,file_size,newfile_name) values(?,?,?,?,?,?,?,?,?)";
        $adb->pquery($sql,array($linktype,$linkid,$status,$carouselseq,$filename,$filetype,'storage/ShopSettins/Carousel/',$ffilesize,$file_name));
    }
    ConvertTojsonString(1,array(),'success');
    exit();
}
//wym BUG0072603 kfbcrm-商城设置-邱：改成拖动 原先的上移下移代码注释了
else if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='drag'){
    if(isset($_REQUEST['sequence_arr'])&&!empty($_REQUEST['sequence_arr'])){
        $sequence_arr = explode(',',$_REQUEST['sequence_arr']);
        foreach ($sequence_arr as $index => $carouselid){
            $carouselseq=$index+1;
            $adb->pquery("update ld_shop_carousels set carouselseq = ? where carouselid = ? ",array($carouselseq,$carouselid));
        }
        ConvertTojsonString(1,array(),'success');
        exit();
    }
}
/*else if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='moveup'){
    crm_load_class_file('cls_CarouselSettings',"modules/ShopSettings");
    $carouselobj = new cls_CarouselSettings();
    if(isset($_REQUEST['recordid'])&&!empty($_REQUEST['recordid'])){
        $carouselid = $_REQUEST['recordid'];
        $carouselinfo = $carouselobj->getCarouselinfoById($carouselid);
        $carouselseq = $carouselinfo['carouselseq'];
        if($carouselseq<=1){
            ConvertTojsonString(-1,array(),getFixedLabel('MOVEUP').getFixedLabel('CALLACTIONRESULTFAILED'));
            exit();
        }
        $carouselseqprev = $carouselseq-1;
        $sql = "select * from ld_shop_carousels where carouselseq = ? limit 1;";
        $result = $adb->pquery($sql,array($carouselseqprev));
        $num = $adb->num_rows($result);
        if($num >0){
            $carouselidprev = $adb->query_result($result,0,'carouselid');
            $adb->pquery("update ld_shop_carousels set carouselseq = ? where carouselid = ?",array($carouselseq,$carouselidprev));
        }
        $adb->pquery("update ld_shop_carousels set carouselseq = ? where carouselid = ?",array($carouselseqprev,$carouselid));
        ConvertTojsonString(1,array(),'success');
        exit();
    }
}
else if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='movedown'){
    crm_load_class_file('cls_CarouselSettings',"modules/ShopSettings");
    $carouselobj = new cls_CarouselSettings();
    if(isset($_REQUEST['recordid'])&&!empty($_REQUEST['recordid'])){
        $carouselid = $_REQUEST['recordid'];
        $carouselinfo = $carouselobj->getCarouselinfoById($carouselid);
        $carouselseq = $carouselinfo['carouselseq'];
        $sql = "select MAX(carouselseq) as maxseq from ld_shop_carousels;";
        $result = $adb->pquery($sql,array());
        if($adb->num_rows($result)<=0){
            exit();
        }
        $maxseq = $adb->query_result($result,0,'maxseq');
        if($carouselseq>=$maxseq){
            ConvertTojsonString(-1,array(),getFixedLabel('MOVEDOWN').' '.getFixedLabel('CALLACTIONRESULTFAILED'));
            exit();
        }
        $carouselseqnext = $carouselseq+1;
        $sql = "select * from ld_shop_carousels where carouselseq = ? limit 1;";
        $result = $adb->pquery($sql,array($carouselseqnext));
        $num = $adb->num_rows($result);
        if($num >0){
            $carouselidprev = $adb->query_result($result,0,'carouselid');
            $adb->pquery("update ld_shop_carousels set carouselseq = ? where carouselid = ?",array($carouselseq,$carouselseqnext));
        }
        $adb->pquery("update ld_shop_carousels set carouselseq = ? where carouselid = ?",array($carouselseqnext,$carouselid));
        ConvertTojsonString(1,array(),'success');
        exit();
    }
}*/
else if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='activate'){
    crm_load_class_file('cls_CarouselSettings',"modules/ShopSettings");
    $carouselobj = new cls_CarouselSettings();
    if(isset($_REQUEST['recordid'])&&!empty($_REQUEST['recordid'])){
        $carouselid = $_REQUEST['recordid'];
        $carouselinfo = $carouselobj->getCarouselinfoById($carouselid);
        $status = $carouselinfo['status'];
        if($status=='yes'){
            ConvertTojsonString(1,array(),'success');
            exit();
        }
        $adb->pquery("update ld_shop_carousels set status = ? where carouselid = ?",array('yes',$carouselid));
        ConvertTojsonString(1,array(),'success');
        exit();
    }
}
else if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='inactivate'){
    crm_load_class_file('cls_CarouselSettings',"modules/ShopSettings");
    $carouselobj = new cls_CarouselSettings();
    if(isset($_REQUEST['recordid'])&&!empty($_REQUEST['recordid'])){
        $carouselid = $_REQUEST['recordid'];
        $carouselinfo = $carouselobj->getCarouselinfoById($carouselid);
        $status = $carouselinfo['status'];
        if($statu=='no'){
            ConvertTojsonString(1,array(),'success');
            exit();
        }
        $adb->pquery("update ld_shop_carousels set status = ? where carouselid = ?",array('no',$carouselid));
        ConvertTojsonString(1,array(),'success');
        exit();
    }
}
else if(isset($_REQUEST['mode'])&&$_REQUEST['mode']=='delete'){
    crm_load_class_file('cls_CarouselSettings',"modules/ShopSettings");
    $carouselobj = new cls_CarouselSettings();
    if(isset($_REQUEST['recordid'])&&!empty($_REQUEST['recordid'])){
        $carouselid = $_REQUEST['recordid'];
        $carouselinfo = $carouselobj->getCarouselinfoById($carouselid);
        if(empty($carouselinfo)){
            ConvertTojsonString(-1,array(),getFixedLabel('RECORDDELETED'));
            exit();
        }
        //删除图片
        $uploadDir = $root_directory.'storage/ShopSettins/Carousel/';
        $oldfilename = $carouselinfo['newfile_name'];
        @unlink($uploadDir.$oldfilename);
        //删除记录
        $adb->pquery("delete from ld_shop_carousels where carouselid = ?",array($carouselid));
        
        //carouselseq重新排序
        $carousels_arr = $carouselobj->getAllCarouselinfos();
        foreach($carousels_arr as $index=>$carousel){
            $adb->pquery("update ld_shop_carousels set carouselseq = ? where carouselid = ?",array($index+1,$carousel['carouselid']));
        }
        ConvertTojsonString(1,array(),'success');
        exit();
    }
}
exit();
?>