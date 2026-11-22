<!-- quick create UI starts -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<title>Mid-Year Rate Adjustment</title>
<meta name="keywords" content="Mid-Year Rate Adjustment" />
<meta name="description" content="" />
<script type="text/javascript" src="include/jquery/jquery.min.js"></script>
<script type="text/javascript" src="include/jquery/jquery-ui.min.js"></script>
<script type="text/javascript" src="include/jquery/jquery.percentageloader.js"></script>
<script language="JavaScript" type="text/javascript" src="modules/OftenUseReport/OftenUseReport.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/picklist.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/general.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/popupselectfield.js"></script>
<script language="javascript" type="text/javascript" src="jsbase/My97DatePicker/WdatePicker.js"></script>

<link rel="stylesheet" type="text/css"  href="{$THEME_PATH}style.css"/>
<link rel="stylesheet" type="text/css"  href="{$THEME_PATH}selfstyle.css"/>
<link rel="stylesheet" type="text/css"  href="{$THEME_PATH}global.css"/>
<link rel="stylesheet" type="text/css"  href="{$THEME_PATH}popup.css"/>
<link rel="stylesheet" type="text/css"  href="{$THEME_PATH}liststyle.css"/>
<link rel="stylesheet" type="text/css"  href="{$THEME_PATH}PickList.css"/>
</head>
<body>
<div  id="searchAcc" class="Find_box" style='width:{$PAGEWIDTHPERCENT}%;'>
	<div class="DivC" style="border:0px;">
		<h3 style="font-size:16px;padding:0;margin:0; height:45px; line-height:45px">{$OFMONTH} Mid-Year Rate Adjustment 
			<span id="report_time_titme"></span>
		</h3>
	</div>
    <div {if $SHOWHEADER eq 'yes'}style="display:block"{else}style="display:none"{/if}>
	<form class="Find_Form0" name="basicSearch"  action="index.php" method="POST" onsubmit="return CallMidYearRate(this,'BasicSearch')" >
    <input type="hidden" name="module" value="Customreport"/>
    <input type="hidden" name="action" value="MidYearRate" />
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr><td>
			<table border="0" cellspacing="0" cellpadding="5">
				<tr>
					<td valign="middle">
						<label class="Name"><span>Date &nbsp;</span></label>
						<span><input style="width:100px" id="search_date" maxlength="25" name="search_date" value="{$SEARCHDATE}" onclick="WdatePicker()" class="Wdate"/></span>
					</td>
					<td valign="middle">
						<label class="Name"><span>Labor OH Rate1(%) &nbsp;</span></label>
						<span><input style="width:100px" type="text" value="{$LABORRATE1}" name="LaborRate1" id="LaborRate1"/></span>
					</td>
					<td valign="middle">
						<label class="Name"><span>G&A rate1(%) &nbsp;</span></label>
						<span><input style="width:100px" type="text" value="{$GARATE1}" name="GARate1" id="GARate1"/></span>
					</td>
					<td valign="middle">
                        <label class="Name"><span>Labor OH Rate2(%)&nbsp;</span></label>
                        <span><input style="width:100px" type="text" value="{$LABORRATE2}" name="LaborRate2" id="LaborRate2"/></span>
					</td>
					<td valign="middle">
						<label class="Name"><span>G&A rate2(%) &nbsp;</span></label>
						<span><input style="width:100px" type="text" value="{$GARATE2}" name="GARate2" id="GARate2"/></span>
					</td>
				</tr>
				<!--The end-->
				<tr style="height:30px;">
					<td align="left">
						<!--生成报表按钮-->
						<input type="hidden" name="searchtype" value="BasicSearch"/>
                        <label class="Name"><input type="reset"  class="createauto b_radius3" value="重置"/></label>  
						<label class="Name"><input name="submit" id='BasicSearchreput' type="Submit"  class="createauto b_radius3" value="查询"/></label>
						<!--生成报表按钮end-->
					</td>
				</tr>
			</table>
			</td></tr>
		</table>
	</form>
    </div>
</div>
<input  type="hidden" id="printsearchType" value="{$SEARCHTYPE}"/>
<div id="AjaxMidYearRate">
    <table class="rptTable TableOften" width="{$PAGEWIDTHPERCENT}%" cellspacing="0" cellpadding="0" >
		 <!-- Table Headers -->
        {$REPORTFILTERHTML}
   </table>
</div>
<script type="text/javascript">
{literal}
function CallMidYearRate(obj,searchtype)
{
    var search_date = document.forms['basicSearch'].search_date.value;//日期
  
    //日期为空警告
    if(search_date.length == 0)
    {
        alert("日期不能为空！");
        return false;
    }
    
    return true;
}
function view_month(month){
    var LaborRate1 = ld('#LaborRate1').val();
    var LaborRate2 = ld('#LaborRate2').val();
    var GARate1 = ld('#GARate1').val();
    var GARate2 = ld('#GARate2').val();
    var search_date = ld('#search_date').val();
    var url = '';
    url = '&month='+month+'&LaborRate1='+LaborRate1+'&LaborRate2='+LaborRate2+'&GARate1='+GARate1+'&GARate2='+GARate2+'&search_date='+search_date;
    window.open("index.php?module=Customreport&action=MidYearRate"+url);
}
{/literal}
</script>
</body>
</html>