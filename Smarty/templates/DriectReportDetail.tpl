<!-- quick create UI starts -->
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
<title>Direct 项目明细表</title>
<meta name="keywords" content="Direct 项目明细表" />
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
<div id="searchAcc" class="Find_box" style='width:{$PAGEWIDTHPERCENT}%;'>
	<div class="DivC" style="border:0px;">
		<h3 style="font-size:16px;padding:0;margin:0; height:45px; line-height:45px">Direct 项目明细表
			<span id="report_time_titme"></span>
		</h3>
	</div>
	<form class="Find_Form0" name="basicSearch"  action="index.php" method="POST" onsubmit="return CallTimeSheet(this,'BasicSearch')" >
    <input type="hidden" name="module" value="Customreport"/>
    <input type="hidden" name="action" value="DriectReportDetail" />
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
    //开始日期为空警告
    if(begin_createdate.length == 0)
        {
            alert("StartDate不能为空！");
            return false;
        }
    //结束时间不能为空
    if(end_createdate.length == 0)
        {
            alert("EndDate不能为空！");
            return false;
        }
    return true;
}
function vtlib_direct_showeditinput(event,rowid){
	if(ld('#span_subjectcode_'+rowid) != undefined){
		ld('#span_subjectcode_'+rowid).hide();
	}
	if(ld('#div_subjectcode_'+rowid) != undefined){
		ld('#div_subjectcode_'+rowid).show();
	}
	if(ld('#span_subjectsummary_'+rowid) != undefined){
		ld('#span_subjectsummary_'+rowid).hide();
	}
	if(ld('#div_subjectsummary_'+rowid) != undefined){
		ld('#div_subjectsummary_'+rowid).show();
	}
	if(ld('#btn_edit_'+rowid) != undefined){
		ld('#btn_edit_'+rowid).hide();
	}
	if(ld('#btn_save_'+rowid) != undefined){
		ld('#btn_save_'+rowid).show();
	}
}

//取消
function vtlib_direct_cancelmodulename(rowid){
	if(ld('#span_subjectcode_'+rowid) != undefined){
		ld('#span_subjectcode_'+rowid).show();
	}
	if(ld('#div_subjectcode_'+rowid) != undefined){
		ld('#div_subjectcode_'+rowid).hide();
	}
	if(ld('#span_subjectsummary_'+rowid) != undefined){
		ld('#span_subjectsummary_'+rowid).show();
	}
	if(ld('#div_subjectsummary_'+rowid) != undefined){
		ld('#div_subjectsummary_'+rowid).hide();
	}
	if(ld('#btn_edit_'+rowid) != undefined){
		ld('#btn_edit_'+rowid).show();
	}
	if(ld('#btn_save_'+rowid) != undefined){
		ld('#btn_save_'+rowid).hide();
	}
}

//保存
function vtlib_direct_savemodulename(row){
	 var expensedetailid = document.getElementById("span_subjectcode_"+row).attributes["tag"].value; 

    var subjectcode=document.getElementById('subjectcode_'+row).value;
    var subjectsummary=document.getElementById('subjectsummary_'+row).value;
       
    var data = "module=Customreport&action=CustomreportAjax&file=SaveDirectReportDetail&subjectcode=" +subjectcode + "&subjectsummary="+subjectsummary+"&expensedetailid="+expensedetailid+"&ajax=true";
    vtlib_direct_cancelmodulename(row);
    new Ajax.Request(
	  'index.php',
        {queue: {position: 'end', scope: 'command'},
    	   method: 'post',
            postBody: data,
            onComplete: function(response) {
                if(response.responseText.indexOf('SUCCESS')>-1){
                   $('status').hide();
                    document.getElementById('span_subjectsummary_'+row).innerHTML = subjectsummary;
                    document.getElementById('span_subjectcode_'+row).innerHTML = subjectcode;
                }else if(response.responseText.indexOf('USEDEN')>-1)
               {
                   alert(arrJsPopLabel['Savefailed']);
                   $('status').hide();
                }
            }
	  }
   );
}
{/literal}
</script>
</body>
</html>