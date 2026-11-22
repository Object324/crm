<!-- quick create UI starts -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<title>Indirect项目汇总表</title>
<meta name="keywords" content="Indirect项目汇总表" />
<meta name="description" content="" />
<script type="text/javascript" src="{$CRMCOMMONURL}/crmcommon/js/jquery/jquery.min.js"></script>
<script type="text/javascript" src="{$CRMCOMMONURL}/crmcommon/js/jquery/jquery-ui.min.js"></script>
<script type="text/javascript" src="{$CRMCOMMONURL}/crmcommon/js/jquery/jquery.percentageloader.js"></script>


<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/OftenUseReport/OftenUseReport.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/picklist.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/general.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/popupselectfield.js"></script>
<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}/crmcommon/js/My97DatePicker/WdatePicker.js"></script>

<link rel="stylesheet" type="text/css"  href="{$THEME_PATH}style.css"/>
<link rel="stylesheet" type="text/css"  href="{$THEME_PATH}selfstyle.css"/>
<link rel="stylesheet" type="text/css"  href="{$THEME_PATH}global.css"/>
<link rel="stylesheet" type="text/css"  href="{$THEME_PATH}popup.css"/>
<link rel="stylesheet" type="text/css"  href="{$THEME_PATH}liststyle.css"/>
<link rel="stylesheet" type="text/css"  href="{$THEME_PATH}PickList.css"/>
</head>
<body>
<div id="searchAcc" class="Find_box" style='width:{$PAGEWIDTHPERCENT}%;'>
	<div class="DivC" style="border:0px;">
		<h3 style="font-size:16px;padding:0;margin:0; height:45px; line-height:45px">Indirect项目汇总表
			<span id="report_time_titme"></span>
		</h3>
	</div>
	<form class="Find_Form0" name="basicSearch1"  action="index.php" method="POST" onsubmit="return CallTimeSheet(this,'BasicSearch')" >
    <input type="hidden" name="module" value="Customreport"/>
    <input type="hidden" name="action" value="IndirectProjectSummaryReport" />
	<input type="hidden" name="mer_type" id="mer_type" value="InDirect" />
	<input type="hidden" name="subjectcode" id="subjectcode" value="{$SUBJECTCODE}" />
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
		<tr><td>
			<table border="0" cellspacing="0" cellpadding="5">
				<tr>
					<td>
						<label class="Name"><span>StartDate:&nbsp;</span></label>
						<span>
							<input id="begin_createdate" maxlength="25" name="begin_createdate"  value="{$begin_createdate}" onClick="WdatePicker()" class="Wdate" />
							<input id="b_begin_createdate" type="hidden" name="b_begin_createdate"/>
						</span>
					</td>
					<td>
						<label class="Name"><span>EndDate:&nbsp;</span></label>
						<span>
							<input id="begin_end_date" maxlength="25" name="begin_end_date"  value="{$begin_end_date}" onClick="WdatePicker()" class="Wdate" />
							<input id="b_begin_end_date" type="hidden" name="b_begin_end_date"/>
						</span>
					</td>
                    <td>
                        <label class="Name"><input name="submit" id='BasicSearchreput' type="Submit"  class="createauto b_radius3" value="生成报表"/></label>
                    </td>
                    <td>
                        <li class="D_anu_a">
                            <a href="#" title="{'EXPORT'|@getFixedLabel}" onclick="ExportReport('{$REPORTNAME}');" name="editsubmit">
                            <b class="icon-homeimg icon-signout"></b><span>{'EXPORT'|@getFixedLabel}Excel</span></a>
                        </li>
                    </td>
				</tr>
				<!--The end-->
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
<div id="voucherheader" class="D_pop_box LdPopWidth350px" style="display:none;">	
    <div class="D_pop_tit">
    	<strong class="D_ptita" id="setting_mode_id">{'SimultaneousgenerationofKingdeecertificate'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('voucherheader');" class="D_ptitc">
            <img class="D_ptitcimg" src="{$IMAGEURL}themes/icon/pop_close.png?v={$GLOBALMINVERSION}" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>	
    <div id="voucherdiv"></div>
</div>
<div id="voucherconfig" class="D_pop_box LdPopWidth400px" style="display:none;">	
    <div class="D_pop_tit">
    	<strong class="D_ptita" id="setting_mode_id">{'SimultaneousgenerationofKingdeecertificate'|@getFixedLabel}</strong>
        <a href="javascript:CancelVoucher(this);" class="D_ptitc">
            <img class="D_ptitcimg" src="{$IMAGEURL}themes/icon/pop_close.png?v={$GLOBALMINVERSION}" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>	
    <div id="voucherconfigdiv"></div>
</div>
<script type="text/javascript">
{literal}

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
    //StartDate为空警告
    if(begin_createdate.length == 0)
        {
            alert("StartDate不能为空！");
            return false;
        }
    //EndDate不能为空
    if(end_createdate.length == 0)
        {
            alert("EndDate不能为空！");
            return false;
        }
    return true;
}
{/literal}
</script>
</body>
</html>