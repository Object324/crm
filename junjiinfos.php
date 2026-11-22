<?php
	error_reporting(E_ALL & ~E_NOTICE);
	//表单登录验证
	include('includefile.php');
	header("Content-type: text/html; charset=utf-8");
	global $theme;
	global $adb;
	@session_start();
	if(!empty($_SESSION['huawan_account_id'])){
	    if(!empty($_REQUEST['page'])){
	       $start = $_REQUEST['page'];
	    }else{
	       $start = 1;
	    }
     
        $size = 10; //每页条目数
		$query = "select notesid,attachmentsid,notes_title,filename from ld_notes
                inner join ld_seattachmentsrel on ld_seattachmentsrel.crmid=ld_notes.notesid";
		$count_result = $adb->query( mkCountQuery( $query));
        $noofrows = $adb->query_result($count_result,0,'count');

        $query .= ' limit '.($start-1)*$size .','.$size;

		$result = $adb->pquery($query,array());
		
		$num_rows=$adb->num_rows($result);
		for($i = 0; $i<$num_rows; $i++){
			$res[$i]['notesid'] = $adb->query_result($result,$i,'notesid');
			$res[$i]['attachmentsid'] = $adb->query_result($result,$i,'attachmentsid');
			$res[$i]['notes_title'] = $adb->query_result($result,$i,'notes_title');
			$res[$i]['filename'] = $adb->query_result($result,$i,'filename');
		}
		//分页按钮
        crm_load_function_file('VT_getSimpleNavigationValues','include/utils','ListViewUtils');
    	$navigation_array = VT_getSimpleNavigationValues($start,$size,$noofrows);

        $output = '';
    	if (($navigation_array['prev']) != 0) {
			$output .= '<li><span class="icon-firstpage" title="' .getFixedLabel('FIRSTPAGE'). '" onClick="gotoPage(1)"></span></li>';
			$output .= '<li><span class="icon-prevpage" title="' .getFixedLabel('PREVPAGE'). '"  onClick="gotoPage('.$navigation_array['prev'].')"></span></li>';
    	} else {
    		$output .= '<li><span class="icon-firstpagedis"></span></li>';
    		$output .= '<li><span class="icon-prevpagedis"></span></li>';
    	}
        $output .= "<li class='Input'><input name='pagenum' type='text' value='".$navigation_array['current']."' onkeypress='checkEnter(this,event)'></li>";
        if (($navigation_array['next']) != 0) {
			$output .= '<li><span class="icon-nextpage" title="' .getFixedLabel('NEXTPAGE'). '" onClick="gotoPage('.$navigation_array['next'].')"></span></li>';
			$output .= '<li><span class="icon-lastpage" title="' .getFixedLabel('LASTPAGE'). '" onClick="gotoPage('.$navigation_array['verylast'].')"></span></li>';
    	} else {
    		$output .= '<li><span class="icon-nextpagedis"></span></li>';
    		$output .= '<li><span class="icon-lastpagedis"></span></li>';
    	}
        if(($start-1)*$size+1 > $noofrows){
            $viewinfo = '';
        }else{
            $viewinfo = '显示 '. (($start-1)*$size+1) .' - '.($start*$size>=$noofrows?$noofrows:$start*$size).' 共 '.$noofrows.' 条记录';
        }
        

	}else{
		unset($_SESSION['huawan_account_id']);
		header("Location:junjilogin.php");
	}
?>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>君寄金融</title>
<meta name="keywords" content="上海君寄金融信息服务有限公司 君寄金融 上海君寄 君寄" />
<meta name="description" content="" />
<script src="junjigroup/js/jquery-1.11.2.min.js" type="text/javascript"></script>

<link rel="stylesheet" type="text/css"  href="junjigroup/css/style.css"/>
<link rel="stylesheet" type="text/css" href="themes/softed/liststyle.css"/>
</head>
<body>
<div class="huawan_log"></div>
<div class="huawan_con">
    <div class="list-title">资讯内容</div>
    <div class="PageDiv0" style="padding:6px 200px;">
    	<ul>
        	<li><?php echo $viewinfo;?></li>
            <?php echo $output; ?>
        </ul>
    </div>
	<div style="clear:both"></div>
	<div class="list-table">
		<table class="huwan-table" width="90%" border="0" cellspacing="1" cellpadding="0" align="left">
		<tr>
			<th>标题</th>
			<th>附件</th>
		</tr>
		<?php
			foreach($res as $res_info){
				echo '<tr>';
				echo '<td>' . $res_info['notes_title'] . '</td>';
				echo '<td><a href="index.php?module=uploads&action=downloadfile&entityid='.$res_info['notesid'].'&fileid='.$res_info['attachmentsid'].'">' . $res_info['filename'] . '</a></td>';
				echo '</tr>';
			}
		?>
		</table>
		
	</div>
</div>
<script>
    function gotoPage(page){
        window.location = "junjiinfos.php?page="+page;
    }
    function checkEnter(obj,event){
        var e = event || window.event || arguments.callee.caller.arguments[0];
        var keyCode = e.keyCode || e.which || e.charCode;
        
		if(keyCode==13){
			if(!isNaN(obj.value)){
                gotoPage(obj.value);
			}else{
                gotoPage(1);
			}
		}
    }
</script>
</body>
</html>