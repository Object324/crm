<!-- quick create UI starts -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>工时个人月汇总表 </title>
<meta name="keywords" content="工时个人月汇总表 " />
<meta name="description" content="" />
<script type="text/javascript" src="../../include/jquery/jquery.min.js"></script>
<script type="text/javascript" src="../../include/jquery/jquery-ui.min.js"></script>
<script type="text/javascript" src="../../include/jquery/jquery.percentageloader.js"></script>
<script type="text/javascript" language="JavaScript">
	var ld = $;
</script>    
<script language="JavaScript" type="text/javascript" src="../../modules/OftenUseReport/OftenUseReport.js"></script>
<script language="JavaScript" type="text/javascript" src="../../include/js/picklist.js"></script>
<script language="JavaScript" type="text/javascript" src="../../include/js/general.js"></script>
<script language="JavaScript" type="text/javascript" src="../../include/js/popupselectfield.js"></script>
<script language="javascript" type="text/javascript" src="../../jsbase/My97DatePicker/WdatePicker.js"></script>

<link rel="stylesheet" type="text/css"  href="../../themes/softed/style.css"/>
<link rel="stylesheet" type="text/css"  href="../../themes/softed/selfstyle.css"/>
<link rel="stylesheet" type="text/css"  href="../../themes/softed/global.css"/>
<link rel="stylesheet" type="text/css"  href="../../themes/softed/popup.css"/>
<link rel="stylesheet" type="text/css"  href="../../themes/softed/liststyle.css"/>
<link rel="stylesheet" type="text/css"  href="../../themes/softed/PickList.css"/>
</head>
<body>
<div id="searchAcc" class="Find_box" style='width:{$PAGEWIDTHPERCENT}%;'>
	<div class="DivC" style="border:0px;">
		<h3 style="font-size:16px;padding:0;margin:0; height:45px; line-height:45px">工时个人月汇总表
			<span id="report_time_titme"></span>
		</h3>
	</div>
	<form class="Find_Form0" name="basicSearch" method="post" action="TimeSheetReport.php" >
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr><td>
			<table border="0" cellspacing="0" cellpadding="5">
				<tr>
					<td>
						<label class="Name"><span>开始日期:&nbsp;</span></label>
						<span>
							<input id="begin_createdate" maxlength="25" name="begin_createdate"  disabled="true" value="{$begin_createdate}" onClick="WdatePicker()" class="Wdate" />
							<input id="b_begin_createdate" type="hidden" name="b_begin_createdate"/>
						</span>
					</td>
					<td>
						<label class="Name"><span>结束日期:&nbsp;</span></label>
						<span>
							<input id="begin_end_date" maxlength="25" name="begin_end_date"  disabled="true" value="{$begin_end_date}" onClick="WdatePicker()" class="Wdate" />
							<input id="b_begin_end_date" type="hidden" name="b_begin_end_date"/>
						</span>
					</td>
				</tr>
				<!--The end-->
				<tr style="height:30px;">
					<td width="252">
						<label class="Name"> <span>员工姓名:&nbsp;</span> </label>
						<input type="hidden" id="module" name="module" value="{$MODULE}" />
						{include file='Comprehensivereport/SmownerSearchScope.tpl'}                                                                            
					</td>
					<td align="left">
						<!--生成报表按钮-->
						<input type="hidden" name="searchtype" value="BasicSearch"/>                                    
						<input type="hidden" id="receiverid" name="receiverid"/>
						<input type="hidden" name="search_cnt"/>
						<input  type="hidden" name="UseReport" value="{$USEREPORTID}"/>
						<input  type="hidden" name="datefindcolumn" value="{$DATEFINDCOLUMN}"/>
						<input  type="hidden" name="otherfindcolumn" value="{$OTHERFINDCOLUMN}"/>  
						<label class="Name"><input name="submit" id='BasicSearchreput' type="Submit" onclick="CallTimeSheet(this,'BasicSearch')" class="createauto b_radius3" value="生成报表"/></label>
						<!--生成报表按钮end-->
					</td>
				</tr>
			</table>
			</td></tr>
		</table>
	</form>
</div>
<input  type="hidden" id="printsearchType" value="{$SEARCHTYPE}"/>
<div id="AjaxTimeSheetTable">
    <table class="rptTable TableOften" width="{$PAGEWIDTHPERCENT}%" cellspacing="0" cellpadding="0" >
		 <!-- Table Headers -->
        {$REPORTFILTERHTML}
   </table>
</div>
<script type="text/javascript">
{literal}
//TimeSheet个人月汇总表 
function CallTimeSheet(obj,searchtype)
{
    var begin_createdate = document.forms['basicSearch'].begin_createdate.value;//开始时间
    var end_createdate = document.forms['basicSearch'].begin_end_date.value;//结束时间
    if(begin_createdate.length>0&&end_createdate.length>0)
    {
        if(begin_createdate>end_createdate) 
        {
            //请正确输入时间范围！
            alert(arrJsPopLabel['THESTARTTIME']);
            return false; 
        }
        
    }
    //开始日期为空警告
    if(begin_createdate.length == 0)
        {
            alert("开始日期不能为空！");
            return false;
        }
    //结束时间不能为空
    if(end_createdate.length == 0)
        {
            alert("结束日期不能为空！");
            return false;
        }
}
{/literal}
</script>
</body>
</html>