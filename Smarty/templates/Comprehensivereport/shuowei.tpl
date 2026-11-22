{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<!--修改编码格式:统一编码：UTF-8-->

<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<script language="JavaScript" type="text/javascript" src="include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/Comprehensivereport.js"></script>
<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/global.css"/>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/popup.css"/>

<link rel="stylesheet" type="text/css" media="all" href="include/daterangepicker/daterangepicker-bs3.css" />

<script type="text/javascript" src="include/daterangepicker/moment.js"></script>
<script type="text/javascript" src="include/daterangepicker/daterangepicker.js"></script>
<div class="clear"></div>

<body>
<!--修改编码格式:统一编码：UTF-8-->
<form id="smsworkLog" name="smsworkLog" method="post" onsubmit="puyoungJS_DialogBox.block()" ENCTYPE="multipart/form-data" action="index.php" style="margin:0px;background-color:#ededed;padding:6px 0px;">
<input type='hidden' name="module" value="Comprehensivereport"/>
<input type='hidden' name="action" value="shuowei"/>
<input type='hidden' name="prioritysms" value="0"/>
<input type='hidden' name="type" value="smswork"/>
<input type="hidden" name="BatchIdAll" id="BatchIdAll" value=""/>
<table width="90%" cellspacing="0" cellpadding="5" border="0" id="CL_Detial">
    <tbody>
        <tr>
          <td colspan="2">{$basicfilterHtml}
                	<label class="Name" style="margin:4px 0px 0px 10px;display:inline-block;"><span>选择到期日期:</span>&nbsp;
                        <input id="begin_date" readonly="readonly" type="text" class="date" name="begin_date" value="{$begin_end_date}" style="padding: 0 0 0 5px;width:150px;"/>
                        <input id="b_begin_date" type="hidden" name="b_begin_date"/>
                        <!--<img id="b_jscal_trigger_date_start" src="themes/softed/images/btnL3Calendar_forMarkrt.gif" />                                                       
                        <script id="massedit_calendar_date_begin" type="text/javascript">
                            Calendar.setup ({ldelim}
                            inputField : "begin_date", ifFormat : "%Y-%m-%d", showsTime : true, button : "b_jscal_trigger_date_start", singleClick : true, step : 1
                           	{rdelim})
                        </script>
                        -->                        
                    </label>
          </td>
        </tr>
        <tr>
          <td colspan="2">{$basicfilterHtml2}
                	<label class="Name" style="margin:4px 0px 0px 10px;display:inline-block;"><span>选择派息日期:</span>&nbsp;
                        <input id="begin_date2" readonly="readonly" type="text" class="date" name="begin_date" value="{$begin_end_date2}" style="padding: 0 0 0 5px;width:150px;"/>
                        <input id="b_begin_date" type="hidden" name="b_begin_date"/>
                        <!--<img id="b_jscal_trigger_date_start" src="themes/softed/images/btnL3Calendar_forMarkrt.gif" />                                                       
                        <script id="massedit_calendar_date_begin" type="text/javascript">
                            Calendar.setup ({ldelim}
                            inputField : "begin_date", ifFormat : "%Y-%m-%d", showsTime : true, button : "b_jscal_trigger_date_start", singleClick : true, step : 1
                           	{rdelim})
                        </script>
                        -->                        
                    </label>
          </td>
        </tr>
        <tr>
            <td>
            <span>投资人姓名:</span>
            <span>
                <input class="input_text" id="accountname" name="accountname" style="width:322px;" value="" type="text" />
            </span>    
            </td> 
            <td>
            <span>电话:</span>
            <span>
                <input class="input_text" id="phone" name="phone" style="width:322px;" value="" type="text" />
            </span>    
            </td> 
        </tr> 
        <tr>
            <td>
            <span>身份证号:</span>
            <span>
                <input class="input_text" id="cf_1483" name="cf_1483" style="width:322px;" value="" type="text" />
            </span>    
            </td> 
            <td>
                <input class="createauto b_radius3" id="btnOK_E" onclick="search_paixi();" type="button" value="{'SEARCH'|@getFixedLabel}" />
            </td>
        </tr> 
    </tbody>
</table>
</form>	

	
<div id="checksms">
{include file="Comprehensivereport/shuoweicontent.tpl"}
</div>
<div id="divSendInform" class="D_pop_box LdPopWidth600px" style="display:none;">
    <div id="divSendInform_div" ></div>
</div>

<div id="tempdiv" style="display:block;position:absolute;left:350px;top:200px;"></div>
</body>
<script type="text/javascript">
{literal}
   ld(document).ready(function() {
      ld('#begin_date2').daterangepicker(null, function(start, end, label) {
      });
      ld('#begin_date').daterangepicker(null, function(start, end, label) {
      });
   });
 var tolabel = "{'TO'|@getFixedLabel}";
    ld(document).ready(function() {
      ld('#begin_date').daterangepicker(null, function(start, end, label) {
        
      });
		setReportTime(ld('#begin_date').val());
   });
    ld(document).ready(function() {
      ld('#begin_date2').daterangepicker(null, function(start, end, label) {
        
      });
		setReportTime(ld('#begin_date2').val());
   });
   function daterangeBackEvent(idstr){
		setReportTime(ld('#'+idstr).val());
   }
   function setReportTime(datetime){
	   var dt = datetime.split(' ');
	   var dtv = "( "+dt[0]+' '+tolabel+' '+dt[2]+" )";
	   ld('#report_time_titme').html(dtv);
   }
{/literal}
</script>
 