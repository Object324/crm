<!--修改编码格式:统一编码：UTF-8-->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<META HTTP-EQUIV="Content-Type" CONTENT="text/html; charset=utf-8" />
<meta http-equiv="X-UA-Compatible" content="IE=edge" />

<title>用户产品注册</title>
<style type="text/css">@import url("{$CSSURL}themes/softed/style.css?v={$GLOBALMINVERSION}");</style>
<style type="text/css">@import url("{$CSSURL}themes/softed/leftmenu.css?v={$GLOBALMINVERSION}");</style>
<style type="text/css">@import url("{$CSSURL}themes/softed/common.css?v={$GLOBALMINVERSION}");</style>
<style type="text/css">@import url("{$CSSURL}themes/softed/popup.css?v={$GLOBALMINVERSION}");</style>

{literal}
<style type="text/css">
* { margin:0px; padding:0px; border:0px;box-sizing: content-box;}
body { background:#fff;font-family:"Microsoft YaHei",Tahoma,Arial,"Helvetica Neue","Hiragino Sans GB",Simsun,sans-self;height: 100%;}
html {width: 100%;height: 100%;}
button{
        outline:none;
    }
.padding1{padding: 0px 20px !important;}
.LdRegbox {
    width:100%;
    height:100%;
    background-position: center !important;
    background-size: 100% 100% !important;
}
.suttitle{
    position: absolute;
    top: 15%;
    left: 50%;
    transform: translate(-50%, -50%);
    -webkit-transform: translate(-50%, -50%);
    -ms-transform: translate(-50%, -50%);
}
.suttitle h2{
    font-size:45px;
    font-weight:normal;
    color: #FFFFFF;
}
.guide{
    width:1100px;
    height:320px;
    position: absolute;
    top:50%;/* 定位父级的50% */
    left: 50%;
    margin-left: -550px;
    margin-top: -160px;
}
.guide .column{float:left;width:241px;padding-right: 27.2px; }
.guide .column:first-child{padding-left: 27.2px;}
.guide dl{
    height: 320px;
    background-color: #BFBFBF;
    background:url(themes/softed/images/black.png);
}
.guide dl dt{text-align: center;padding: 40px 0 0px;}
.guide dl dd{text-align: center;padding: 28px 0 23px;}
.guide dl dd a{font-size:18px;font-style:normal;color:#FFFFFF;cursor: pointer;text-decoration: none;outline: none; }
.guide dl dd.des{
    overflow: hidden;
    text-overflow: ellipsis;
    word-break: break-all;
    color:#FFFFFF;
    cursor:unset;
    padding: 0px 20px;
}
.guide dl dd.des ul li{
    list-style:none;
    text-align: center;
}
.guide dl dd.des ul li p{
    font-size:12px;
    display: inline-block;
    text-align: left;
    line-height: 30px;
}
.guide dl dd.des ul li p a{
    font-size:14px;
    text-decoration:underline;
}
.guide dl img{width:25%;}
.guide dl i{ color:#d3d3d3; font-size:18px;font-style:normal;margin-left:7px;}
/*关于*/
.about ul li{
    padding: 0 24px;
    height: 40px;
    line-height: 40px;
    border-bottom: 1px solid #F1F1F1;
}
.about ul li.about-li-second{
    padding-left: 42px;
}
.about ul li:before{
	content: "";
	background-color: #74d86a;
	display: inline-block;
	width: 9px;
	height: 9px;
	margin-right: 10px;
}
.parentdiv {
    cursor: pointer;
    position: relative;
}
.sondiv {
    cursor: pointer;
    width: 105px;
    height: 15px;
    background: transparent !important;
    text-decoration: underline;
    color: #fff;
    font-size: 14px;
    text-align: center;
}
.sondivTitle{text-decoration: none !important;font-size: 18px;line-height: 15px;width: 100%;}
.file_input {
    width: 130px;/*因为file-input在部分浏览器中会自带一个输入框，需要双击才可以点击上传,放大后将其定位到div外面就好啦*/
    height: 15px;
    position: absolute;
    left: -10px;
    top: 10px;
    z-index:1;
    -moz-opacity: 0;
    -ms-opacity: 0;
    -webkit-opacity: 0;
    opacity: 0; /*css属性&mdash;&mdash;opcity不透明度，取值0-1*/
    filter: alpha(opacity=0); /*兼容IE8及以下--filter属性是IE特有的，它还有很多其它滤镜效果，而filter: alpha(opacity=0); 兼容IE8及以下的IE浏览器(如果你的电脑IE是8以下的版本，使用某些效果是可能会有一个允许ActiveX的提示,注意点一下就ok啦)*/
    cursor: pointer;
}
</style>
{/literal}
<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.min.js"></script>
<script type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery-ui.min.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupDrag.js?v={$GLOBALMINVERSION}"></script>
<script src="{$JSURL}include/js/ajax.js"></script>
<script src="{$JSURL}include/js/reg.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupLayer.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ldAjax.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
<script>
var ld = $;
var browser_ie=false;
var browser_nn4=false;
var browser_nn6=false;
if (document.all)
	var browser_ie=true
 else if (document.layers)
	var browser_nn4=true
else if (document.layers || (!document.all && document.getElementById))
	var browser_nn6=true
var gBrowserAgent = navigator.userAgent.toLowerCase();

var errorcontent="{$ERRORCONTENT}";
if(errorcontent!=undefined && errorcontent!='')
{ldelim}
    alert(errorcontent);
{rdelim}
</script>
</head>
<!--head end-->
<body>
<div class="LdRegbox" style="background:url({$LOGININFO.backgroundbg.content});">
    <form enctype='multipart/form-data' name='registerfilefile'  target='hd' action='Register/RegLogin.php?action=inputregister&a={$RAND}' method='post' >
        <div class="suttitle"><h2>软件注册</h2></div>
    <div class="guide">
        <div class="column">
            <dl>
                <dt><img src="themes/softed/images/rig_reg_ico1.png" alt="导出机器特征码"/></dt>
                <dd><a href="javascript:void(0);" onclick="return CreateSysCode(this)">导出机器特征码</a><i>&raquo;</i></dd>
                <dd class="des">
                    <ul>
                        <li><p>点击导出<a href="javascript:void(0);" onclick="return CreateSysCode(this)">机器特征码</a>，提交给销售负责人！</p></li>
                    </ul>    
                </dd>
            </dl>
        </div>
        <div class="column">
            <dl>
                <dt><img src="themes/softed/images/rig_reg_ico3.png" alt="引入授权文件"/></dt>
                <dd class="mart">
                            <div style="font-size: 12px;display: inline-block;text-align: left;line-height: 30px;">
                                <div class="parentdiv" id='upload_test'>
                                <div class="sondiv sondivTitle">引入授权文件</div>
                                    <input class="file_input" name='upload_test'  accept='application/dat' type='file' size="10" onchange='btnFilesubmit(event)' title="点击引入授权文件" style="top:0px !important;"/>
                                </div>
                            </div><i>&raquo;</i>
                    
                </dd>
                <dd class="des">
                    <ul>
                        <li>
                            <div style="font-size: 12px;display: inline-block;text-align: left;line-height: 30px;">
                                <span style="float:left;">点击引入</span><div class="parentdiv" id='upload_test'>
                                <div class="sondiv">授权文件</div>
                                    <input class="file_input" name='upload_test1'  accept='application/dat' type='file' size="10" onchange='btnFilesubmit(event)' title="点击引入授权文件"/>
                                </div>
                            </div>      
                        </li>
                    </ul>
                </dd>
            </dl>
        </div>
        <div class="column">
            <dl>
                <dt><img src="themes/softed/images/rig_reg_ico4.png" alt="显示授权信息"/></dt>
                <dd class="mart"><a href="javascript:void(0);" onclick="return ShowAbout(event)">显示授权信息</a><i>&raquo;</i></dd>
                <dd class="des">
                    <ul>
                        <li>
                            <p style="display:none">
                                点击显示<a href="javascript:void(0);" onclick="return ShowAbout(event)">授权信息</a>（包括产品全称、序列号、许可证等）
                            </p>
                            <p>
                            为确保贵司权益，敬请核对<a href="javascript:void(0);" onclick="return ShowAbout(event)">授权信息</a>中的公司名称是否与贵司工商注册名称一致，正版验证：021-63201212
                            </p>
                        </li>
                    </ul>
                </dd>
            </dl>
        </div>
        <div class="column">
            <dl>
                <dt><img src="themes/softed/images/rig_reg_ico5.png" alt="转到登录界面"/></dt>
                <dd class="mart"><a href="index.php">转到登录界面</a><i>&raquo;</i></dd>
                <dd class="des">
                    <ul>
                        <li>
                            <p>
                                点击进入<a href="index.php">登录界面</a>
                            </p>
                        </li>
                    </ul>
                </dd>
            </dl>
        </div>
    </div>
        
    <input type='hidden'  name='MAX_FILE_SIZE' value='1024000'/>
    <input type="submit" style="display:none" id="registersubmit"/>
  
  </form>
   
</div>
<iframe name="hd" id="hd" style="display:none;"></iframe>
</body>
</html>
