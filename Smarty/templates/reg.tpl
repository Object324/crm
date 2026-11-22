<!--修改编码格式:统一编码：UTF-8-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8" />
<title></title>
<link rel="stylesheet" type="text/css" href="themes/softed/reg.css" />
<script src="include/js/ajax.js"></script>
<script src="include/js/reg.js"></script>
<script>
var errorcontent="{$ERRORCONTENT}";
if(errorcontent!=undefined && errorcontent!='')
{ldelim}
    alert(errorcontent);
{rdelim}
</script>
</head>
<!--head end-->
<body>
<div class="reg">
	<div class="reg_t"></div>
    <div class="reg_sm" style="position:relative; ">
    	尊敬的用户<br />
        欢迎使用灵当软件<br />
        请联系供应商获取授权文件<br />
        <span style="color:red;">在使用前，希望您能按照以下帮助操作</span>
        <span id="registerspan">
        <form enctype='multipart/form-data' name='registerfilefile'  target='hd' action='register/InputRegister.php' method='post' >
             <input type='hidden'  name='MAX_FILE_SIZE' value='1024000'/>
             <input style="position:absolute; top:159px; left:12px;  display:none;" name='upload_test' id='upload_test'  accept='application/dat' type='file' size="16" onchange='btnFilesubmit(event)'/>     
            <input type="submit" style="display:none" id="registersubmit"/>
          </form>
          </span>
    </div>
    <div class="reg_lc">
    	<ul>
        	<li class="reg_lc1"><a href="register/SysCode.php">导出机器特征码</a></li>
            <li class="reg_lc2"><a style="color:#000;" href="#">获取授权文件</a></li>
            <li class="reg_lc3">
              
             <a href="#" onclick='return fileclick(event)'>引入授权文件</a>
           
            </li>
            <li class="reg_lc4"><a href="#" onclick="return ShowAbout(event)">查看授权信息</a></li>
            <li class="reg_lc5"><a href="index.php">转到登录页面</a></li>
        </ul>
    </div>
</div>
<iframe name="hd" id="hd" style="display:none;"></iframe>
</body>
</html>