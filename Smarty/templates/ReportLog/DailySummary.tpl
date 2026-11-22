<!--修改编码格式:统一编码：UTF-8-->
<link href="themes/softed/writeDaily.css" rel="stylesheet" type="text/css" />

<div class="DailySummary">
    <div class="totalTitle">{'Users_view_daily_summary'|@getFixedLabel}</div>
    
    <form action="index.php" method="post" name="DailySummary">
    <input type="hidden" name="module" value="ReportLog"/>
    <input type="hidden" name="action" value="ReportLogAjax"/>
	<input type="hidden" name="file" value=""/>
    <input type="hidden" name="SearchScope"/>
    <input type="hidden" name="type" value="{$TYPE}"/>
    {if $TYPE eq 0}
    {assign var=rbSummary value=checked}
    {assign var=divSummary value=block}
    {assign var=divReference value=none}
    {else}
    {assign var=rbReference value=checked}
    {assign var=divReference value=block}
    {assign var=divSummary value=none}
    {/if}
    
   <div class="classify">
        <input type="radio" id="rbSummary" {$rbSummary} style="margin:0px 5px 2px 0px;" onclick="SelectWay(rbSummary,rbReference);"/>{'Work_Summary'|@getFixedLabel}
        <input type="radio" id="rbReference" {$rbReference} style="margin:0px 5px 2px 5px;" onclick="SelectWay(rbReference,rbSummary);"/>{'Reference_Data_Summary'|@getFixedLabel}
      <div class="Date" id="reportlog_div">
            <span style="float:left;margin-top: 3px;">{'Person_in_charge'|@getFixedLabel}:</span>
            <select id="searchOwner" onchange="SelectScope(this)" name="searchOwner" style="display:none">
                 {foreach key=User_Key item=User_value from=$MERGESMOWNER}
                     {foreach key=User_id item=User_name from=$User_value}
                         {foreach key=User_name_key item=User_name_value from=$User_name}                                                      
                            {if ($User_id eq $SearchOwner) || ($User_id eq $SmOwner_Search_Me)}
                                {assign var='opttext' value=$User_name_key}
                                <option value="{$User_id}" selected="true">{$User_name_key}</option>
                            {else}
                                <option value="{$User_id}">{$User_name_key}</option>
                            {/if}                                                        
                         {/foreach}
                     {/foreach}
                 {/foreach}
            </select>
            <div name="dv_chzn_searchOwner" class="chzn-container chzn-container-single" style="margin:0px 8px;" onMouseLeave="cmb_mouseleave(event,'searchOwner','reportlog_div')">
             	<a style="width:115px;" class="chzn-single" onclick="com_img_change(event,'searchOwner','reportlog_div')" href="javascript:void(0)" tabindex="-1"
                 name="cmb_a_searchOwner">
					<input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 109px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_searchOwner' onclick="cmb_picklist_end_foucs(event,'searchOwner','reportlog_div')" onKeyUp="com_chosen(event,'searchOwner','reportlog_div')" value="{$opttext}">
                    <div>
                        <b></b>
                    </div>
                </a>
                <div style=" left:-9000px;width: 123px; top: 25px;" class="chzn-drop" name='dv_drop_searchOwner' >
            		 <ul class="chzn-results" name="cmb_ul_searchOwner">
            		    {*edit:diony time:20140918 *}
                        {*0011523: 快速创建下拉列表中，刘总建议把“快速创建”列表值给去掉-如图*}
                        {*<option value="none">{'Quickly_create'|@getFixedLabel}</option>
                        <li style="border-top:0px #ccc solid;" class="active-result" name="dv_chzn_1_searchOwner" onclick="cmb_liclick('none','searchOwner')" onmouseover="cmb_limouseover(event,'searchOwner')"> {'Quickly_create'|@getFixedLabel}</li>
                        {assign var="i" value=$i+1}*}
						{assign var="i" value=0} 
                       {foreach key=User_Key item=User_value from=$MERGESMOWNER}
                        {foreach key=User_id item=User_name from=$User_value}
                         {foreach key=User_name_key item=User_name_value from=$User_name}
                               
                              <li style="border-top:0px #ccc solid;" class="active-result" name="dv_chzn_{$i}_searchOwner" onclick="cmb_liclick('{$User_id}','searchOwner','reportlog_div')" onmouseover="cmb_limouseover(event,'searchOwner','reportlog_div')">{$User_name_key}</li>
                              {assign var="i" value=$i+1} 
                        {/foreach}
                       {/foreach}
                     {/foreach}
                           
                           <li style="border-top:0px #ccc solid;" class="" name="li_chzn_searchOwner" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
            		 </ul>
                </div>
            </div>
            {'Start_Date'|@getFixedLabel}:<input name="sdate" id="jscal_field_sdate"  style="border:1px solid #bababa;margin-left:5px;" size="15" maxlength="10" value="{$SDATE}" onClick="WdatePicker()" class="Wdate">
            <!--<img src="{'btnL3Calendar.gif'|@lingdang_imageurl:$THEME}" id="jscal_trigger_sdate" style="vertical-align:middle;">&nbsp;&nbsp;
             <script type="text/javascript" id='massedit_calendar_sdate'>
    			Calendar.setup ({ldelim}
    				inputField : "jscal_field_sdate", ifFormat : "%Y-%m-%d", showsTime : false, button : "jscal_trigger_sdate", singleClick : true, step : 1
    			{rdelim})
    
    		</script>-->
            {'End_Date'|@getFixedLabel}:
            <input name="edate" id="jscal_field_edate"  style="border:1px solid #bababa;margin-left:5px;" size="15" maxlength="10" value="{$EDATE}" onClick="WdatePicker()" class="Wdate">
            <!--<img src="{'btnL3Calendar.gif'|@lingdang_imageurl:$THEME}" id="jscal_trigger_edate" style="vertical-align:middle;">&nbsp;&nbsp;
             <script type="text/javascript" id='massedit_calendar_sdate'>
    			Calendar.setup ({ldelim}
    				inputField : "jscal_field_edate", ifFormat : "%Y-%m-%d", showsTime : false, button : "jscal_trigger_edate", singleClick : true, step : 1
    			{rdelim})
            </script>-->
            
          &nbsp;&nbsp;
          <input type="button" class="editauto" name="" value="{'VIEWSUMMARY'|@getFixedLabel}" onclick="this.form.file.value='DailySummary';CheckDate();"/>
        </div>
        
    </div>
    
    <div id="dailysummary_content" style="overflow-y:auto;max-height:800px;">
		{include file="ReportLog/DailySummary_entries.tpl"}
	</div>

</form>
</div>