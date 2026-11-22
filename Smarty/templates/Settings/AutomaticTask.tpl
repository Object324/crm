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
<script language="JAVASCRIPT" type="text/javascript" src="include/js/smoothscroll.js"></script>
<script language="JavaScript" type="text/javascript" src="include/js/menu.js"></script>
<script language="javascript" type="text/javascript">
var fLabels = new Array();
fLabels['e'] = '{'EQ'|@getFixedLabel}';
fLabels['n'] = '{'NEQ'|@getFixedLabel}';
fLabels['s'] = '{'Begins'|@getFixedLabel}';
fLabels['ew'] = '{'Ends'|@getFixedLabel}';
fLabels['c'] = '{'IN'|@getFixedLabel}';
fLabels['k'] = '{'NOT_IN'|@getFixedLabel}';
fLabels['l'] = '{'LT'|@getFixedLabel}';
fLabels['g'] = '{'GT'|@getFixedLabel}';
fLabels['m'] = '{'LE'|@getFixedLabel}';;
fLabels['h'] = '{'GE'|@getFixedLabel}';
fLabels['bw'] = '{'Interval'|@getFixedLabel}';
fLabels['b'] = '{'Before'|@getFixedLabel}';
fLabels['a'] = '{'After'|@getFixedLabel}';
fLabels['isnull'] = '{'ISNULL'|@getFixedLabel}';
fLabels['isnotnull'] = '{'ISNOTNULL'|@getFixedLabel}';
</script>

<!--中间-->
<div class="List3Box">
<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    <td class="TdLeft" valign="top" style="width:200px;">
    	{include file='SetMenuNew.tpl'}
    </td>
    <td class="Tdcenter" valign="top" style="padding: 0 15px;">
	<form action="index.php" method="post" name="autotaskform" onsubmit="puyoungJS_DialogBox.block();">
	   <input type="hidden" name="module" value="Settings"/>
	   <input type="hidden" name="parenttab" value="Settings"/>
	   <input type="hidden" name="action"/>
	   <input type="hidden" name="setype"/>
	   <input type="hidden" name="record" value="{$RECORD}"/>
	   <input type="hidden" name="maxindex"/>
	   <input type="hidden" name="groupcond"/>
	   <input type="hidden" name="fld_tabid" value="{$Fld_TABID}"/>
       <input type="hidden" name="blockidsetting" value="{$BLOCKIDSETTING}"/>
       <input type="hidden" name="fieldidsetting" value="{$FIELDIDSETTING}"/>
      <div class="DivCR">       
         <div class="ControlDiv1">
            <span class="Url fontbold">
					{'CONTROLPANEL'|@getFixedLabel} &gt; {'LBL_AUTOMATIC_TASK'|@getFixedLabel}
                <font>（{'LBL_AUTOMATIC_TASK_DESCRIPTION'|@getFixedLabel}）</font>
            </span>
        </div>
		
		{if $SETYPE eq 'list'}<!-- 列表 -->
			<div id="cfList">
				{include file='Settings/AutomaticTaskContents.tpl'}
			</div>
		{else $SETYPE eq 'edit'}<!-- 新增、编辑 -->
			<div class="ControlDiv2">
				<!-- <span class="F_l"><font>{'LBL_AUTOMATIC_TASK'|@getFixedLabel}: {$FLD_MODULE|@getTranstab}</font></span> -->
					<input class="saveauto" onclick="autotasksave_click();" type="button" name="New" value="{'SAVE'|@getFixedLabel}"/>
				<input class="cancelauto" onclick="location.href='index.php?module=Settings&action=AutomaticTask&&fld_tabid={$FLD_TABID}&blockidsetting={$BLOCKIDSETTING}&fieldidsetting={$FIELDIDSETTING}';" type="button" name="New" value="{'CANCEL'|@getFixedLabel}"/>
			</div>
			<div class="pad10" >
				<table class="single-tab" width="100%" cellspacing="0" cellpadding="0" border="0">
          <tr>
          <th align="left" colspan="2">{'BASICINFO'|@getFixedLabel}</th>
          </tr>
					<tbody><tr>
						<td width="20%"> <font color="red">*</font> {'LBL_AUTOMATICTASK_NAME'|@getFixedLabel} </td>
						<td width="80%">
							<input type="text" value="{$AUTOTASK.autotaskname}" style="width:30%" name="autotaskname">
						</td>
					</tr><tr>
						<td width="20%"> <font color="red">*</font> {'LBL_AUTOMATICTASK_TYPE'|@getFixedLabel} </td>
						<td width="80%">
							<select name="autotaskmode">
								{foreach key=key item=item from=$AUTOTASKMODEARR}
									<option value="{$key}" {if $AUTOTASK.autotaskmode eq $key}selected{/if}>{$item}</option>
								{/foreach}
							</select>
						</td>
					</tr><tr id='eachbackoptstr'>
						<td width="20%"> <font color="red">*</font> {'LBL_AUTOMATICTASK_FREQUENCY'|@getFixedLabel} </td>
						<td width="80%">
                {'EACH'|@getFixedLabel}
								<select name="eachbackopts" id="eachbackopts">
									{foreach key=eachback item=eachbackv from=$EACHBACKARR}
										<option value="{$eachback}" {if $EACHBACKED == $eachback}selected{/if}>{$eachbackv}</option>
									{/foreach}
								</select>
                <select name="weekopts" id="weekopts" style='{if $EACHBACKED != "week"}display:none;{/if}'>
									{foreach key=weekk item=weekv from=$WEEKOPTS}
										<option value="{$weekk}" {if $WEEKOPTSED == $weekk}selected{/if}>{$weekv}</option>
									{/foreach}
								</select>
								<select name="eachday" id="eachday" style='{if $EACHBACKED != "month"}display:none;{/if}'>
									{foreach item=eachday from=$EACHDAYOPTS}
										<option value="{$eachday}" {if $MONTHOPTSED == $eachday}selected{/if}>{$eachday}{'Day'|@getFixedLabel}</option>
									{/foreach}
								</select>
						</td>
					</tr></tbody>
				</table>
        <div class="TitleHeading" style='margin-top:10px;'>
            <font color="red">*</font> {'LBL_AUTOMATICTASK_CONTENT'|@getFixedLabel}
						<input type="radio" name='autotasktype' value='0' style='margin-left:30px;margin-top: -3px;' checked/>{'LBL_AUTOMATICTASK_CUSTOMIZED'|@getFixedLabel}
						<input type="radio" name='autotasktype' value='1' style='margin-left:30px;margin-top: -3px;' />{'LBL_AUTOMATICTASK_SQL'|@getFixedLabel}
        </div>
			<div id='autotasktype0' class="borderLBR">
        <ul id='celltable' class="switch-tab" style='margin-top:10px;'>
          {foreach key=key item=item from=$CELLSELECT name=cellforeach}
          <li id="{$key}" onclick='cellclick("{$key}");'{if $smarty.foreach.cellforeach.first}class="curr"{/if}>{$item}</li>
          {/foreach}
        </ul>
        <div id="piDiv" style="padding:10px 0;">
					<table class="single-tab" width="97%" cellspacing="1" cellpadding="0" border="0" style="margin:0 auto;">
						<tbody>
            <tr>
							<th align="left" colspan='2'>	{'EASYTIMEFILTER'|@getFixedLabel}</th>
						</tr>
						<tr>
							<td width="40%" align='right' >{'Select_field'|@getFixedLabel}</td>
							<td>
								<select id="stdDateFilterField" name="stdDateFilterField" class="select" onchange="standardFilterDisplay();" style="display:none;">
								{foreach item=stdfilter name=stdfil from=$STDFILTERCOLUMNS}
                    {if $AUTOSTDFILTER.columnname == $stdfilter.value}
                        {assign var='opttext' value=$stdfilter.text}
                        <option selected="selected" value="{$stdfilter.value}">{$stdfilter.text}</option>
                    {else}
                        {if $smarty.foreach.stdfil.first}
                            {assign var='optDefault' value=$stdfilter.text}
                        {/if}
                        <option value="{$stdfilter.value}">{$stdfilter.text}</option>
                    {/if}
								{/foreach}
								</select>
                <div name="dv_chzn_stdDateFilterField" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'stdDateFilterField','piDiv')" style="z-index:999;">
									<a class="chzn-single" onclick="com_img_change(event,'stdDateFilterField','piDiv')" href="javascript:void(0)" tabindex="-1"
									 name="cmb_a_stdDateFilterField" style="width:190px;">
									 <input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 190px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_stdDateFilterField' onclick="cmb_picklist_end_foucs(event,'stdDateFilterField','piDiv')" onKeyUp="com_chosen(event,'stdDateFilterField','piDiv')" value="{if $opttext neq ''}{$opttext}{else}{$optDefault}{/if}">
										<div><b></b></div>
									</a>
									<div style="left:-9000px; top: 25px;width:198px;" class="chzn-drop" name='dv_drop_stdDateFilterField' >
										 <ul class="chzn-results" name="cmb_ul_stdDateFilterField">
											{assign var="i" value=0}
										   {foreach item=stdfilter from=$STDFILTERCOLUMNS }
											   <li class="active-result" name="dv_chzn_{$i}_stdDateFilterField" onclick="cmb_liclick('{$stdfilter.value}','stdDateFilterField','piDiv')" onmouseover="cmb_limouseover(event,'stdDateFilterField','piDiv')">{$stdfilter.text}</li>
											   {assign var="i" value=$i+1}
											{/foreach}
											   <li name="li_chzn_stdDateFilterField" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
										 </ul>
									</div>
								</div>
							</td>
						</tr>
						<tr>
						 <td align="right">{'SELECT_TIME'|@getFixedLabel} </td>
						 <td>
							<select name="stdDateFilter" id="stdDateFilter" class="select" onchange='showDateRange(this.options[this.selectedIndex].value )' style="display:none;">
                				{assign var=special value='/\d+/'}
            					{assign var=normal_last value='/last/'}
            					{assign var=normal_before value='/before/'}
            					{assign var=normal_next value='/next/'} 
            					{assign var=day value='Days'|@getFixedLabel}
            					{assign var=last value='LAST'|@getFixedLabel}
            					{assign var=before value='DAYSAGO'|@getFixedLabel }
            					{assign var=future value='FUTURE'|@getFixedLabel }
            					{assign var=after value='AFTERDAY'|@getFixedLabel }       
                				{foreach item=duration from=$STDFILTERCRITERIA}                                             
                                        {if $special|preg_match:$duration.text:$matches eq 1}                                   
                                           {assign var=normal_number value=$matches[0]}
                                           {if $normal_last|preg_match:$duration.text eq 1}                                   
                                               {if $duration.selected eq 'selected'}
                                                 {assign var=optText value=$last|cat:$normal_number|cat:$day}
                                               {/if}
                                               <option {$duration.selected} value="{$duration.value}">{$last}{$normal_number}{$day}</option>
                                           {elseif $normal_before|preg_match:$duration.text eq 1} 
                                               {if $duration.selected eq 'selected'}
                                                 {assign var=optText value=$normal_number|cat:$before}
                                               {/if}                                  
                                              <option {$duration.selected} value="{$duration.value}">{$normal_number}{$before}</option>
                                           {elseif $normal_next|preg_match:$duration.text eq 1} 
                                               {if $duration.selected eq 'selected'}
                                                 {assign var=optText value=$future|cat:$normal_number|cat:$day}
                                               {/if}                                   
                                               <option {$duration.selected} value="{$duration.value}">{$future}{$normal_number}{$day}</option>
                                           {else} 
                                                {if $duration.selected eq 'selected'}
                                                  {assign var=optText value=$normal_number|cat:$after}
                                                {/if}                                       
                                               <option {$duration.selected} value="{$duration.value}">{$normal_number}{$after}</option>
                                           {/if}  
                                        {else}
                                               {if $duration.selected eq 'selected'}
                                                  {assign var=optText value=$duration.text|@getFixedLabel}
                                                {/if} 
                                                <option {$duration.selected} value="{$duration.value}">{$duration.text|@getFixedLabel}</option>
                                        {/if} 		                                     
                				{/foreach}   
                    		  </select>
							  <div name="dv_chzn_stdDateFilter" class="chzn-container chzn-container-single" onMouseLeave="cmb_mouseleave(event,'stdDateFilter','piDiv')" style="z-index:990;">
									<a style="width:110px;" class="chzn-single" onclick="com_img_change(event,'stdDateFilter','piDiv')" href="javascript:void(0)" tabindex="-1"
									 name="cmb_a_stdDateFilter">
									 <input class="commonDetailedTextBox bgwhite" type="text" autocomplete="off" style="width: 106px;margin-left: -10px;border-style:none;" tabindex="0"  name='cmb_span_optiontext_stdDateFilter' onclick="cmb_picklist_end_foucs(event,'stdDateFilter','piDiv')" onKeyUp="com_chosen(event,'stdDateFilter','piDiv')" value="{if $AUTOSTDFILTER.stdfilter != ''}{$AUTOSTDFILTER.stdfilter|@getFixedLabel}{else}{'custom'|@getFixedLabel}{/if}">
										<div><b></b></div>
									</a>
									<div style=" left:-9000px;width: 118px; top: 20px;" class="chzn-drop" name='dv_drop_stdDateFilter' >
										 <ul class="chzn-results" name="cmb_ul_stdDateFilter">								      
        								 {assign var=special value='/\d+/'}
        								 {assign var=normal_last value='/last/'}
        								 {assign var=normal_before value='/before/'}
        								 {assign var=normal_next value='/next/'}
										 {assign var="j" value=0}
                                    	 {foreach key=User_Key item=duration from=$STDFILTERCRITERIA }                                                                             
                                             {if $special|preg_match:$duration.text:$matches eq 1}                                       
                                               {assign var=normal_number value=$matches[0]}
                                               {if $normal_last|preg_match:$duration.text eq 1} 
                                                    <li style="" class="active-result" name="dv_chzn_{$j}_stdDateFilter" onclick="cmb_liclick('{$duration.value}','stdDateFilter','piDiv')" onmouseover="cmb_limouseover(event,'stdDateFilter','piDiv')">{'LAST'|@getFixedLabel}{$normal_number}{'Days'|@getFixedLabel}</li>
                                               {elseif $normal_before|preg_match:$duration.text eq 1}                                     
                                                   <li style="" class="active-result" name="dv_chzn_{$j}_stdDateFilter" onclick="cmb_liclick('{$duration.value}','stdDateFilter','piDiv')" onmouseover="cmb_limouseover(event,'stdDateFilter','piDiv')">{$normal_number}{'DAYSAGO'|@getFixedLabel}</li>
                                               {elseif $normal_next|preg_match:$duration.text eq 1}                                   
                                                    <li style="" class="active-result" name="dv_chzn_{$j}_stdDateFilter" onclick="cmb_liclick('{$duration.value}','stdDateFilter','piDiv')" onmouseover="cmb_limouseover(event,'stdDateFilter','piDiv')">{'FUTURE'|@getFixedLabel}{$normal_number}{'Days'|@getFixedLabel}</li>
                                               {else}                                      
                                                    <li style="" class="active-result" name="dv_chzn_{$j}_stdDateFilter" onclick="cmb_liclick('{$duration.value}','stdDateFilter','piDiv')" onmouseover="cmb_limouseover(event,'stdDateFilter','piDiv')">{$normal_number}{'AFTERDAY'|@getFixedLabel}</li>
                                               {/if}  
                                            {else}
                                                <li style="" class="active-result" name="dv_chzn_{$j}_stdDateFilter" onclick="cmb_liclick('{$duration.value}','stdDateFilter','piDiv')" onmouseover="cmb_limouseover(event,'stdDateFilter','piDiv')">{$duration.text|@getFixedLabel}</li>
                                            {/if} 
											{assign var="j" value=$j+1}
                                        {/foreach}                                           
                                                <li style="" class="" name="li_chzn_stdDateFil    ter" >{'NOMATCHINGITEMS'|@getFixedLabel}</li>
                        			     </ul>
									</div>
								</div>
						 </td>
					  </tr>
           <tr>
			     <td align="right">{'Start_Date'|@getFixedLabel} </td>
			     <td align="left">
			     {if $STDFILTERCRITERIA.0.selected eq "selected" || $CUSTOMVIEWID eq ""}
    				{assign var=img_style value="visibility:visible"}
    				{assign var=msg_style value=""}
			     {else}
    				{assign var=img_style value="visibility:hidden"}
    				{assign var=msg_style value="readonly"}
			     {/if}	
			     <input name="startdate" id="jscal_field_date_start" type="text" size="15" readonly="readonly" class="Wdate" value="{$STARTDATE}" {$msg_style} onClick="WdatePicker()">
			     <font size=1><em old="(yyyy-mm-dd)">({$DATEFORMAT})</em></font>
           </td>
	        </tr>
			  <tr >
			     <td align="right">{'End_Date'|@getFixedLabel} </td> 
  			     <td align="left">
			     <input name="enddate" {$msg_style} id="jscal_field_date_end" type="text" size="15" readonly="readonly" class="Wdate" value="{$ENDDATE}" onClick="WdatePicker()">
			     <font size=1><em old="(yyyy-mm-dd)">({$DATEFORMAT})</em></font>
			     </td>
			  </tr>
						</tbody>
					</table>
				</div>

				<div id="miDiv" style="width:97%;margin:0 auto;padding:10px 0;display:none;">
					{include file='AdvanceFilterCustView.tpl' SOURCE='customview'}
				</div>

				<div id="uiDiv" style="padding:10px 0;display:none;">
					<table class="ControlTable1 listEntries" id='uiaotutab' width="97%" cellspacing="1" cellpadding="0" border="0" align="center">
						<tbody><tr>
							<th align="left" style='padding-left:10px;' colspan='4'>
								{'LBL_AUTOMATICTASK_CUSTOMIZED'|@getFixedLabel}
							</th>
						</tr><tr bgcolor="white" id='uiaotutab0'>
							<td>
								<select name="updatefield[]" id='updatefield0'>
									{$AUTOTASKFIELD}
								</select>
							</td>
							<td>
								<select name="updatefor[]" id='updatefor0'>
									<option value="0">{'LBL_UPDATE_FOR'|@getFixedlabel}</option>
								</select>
							</td>
							<td>
								<input type="text" name="update_text[]" id='update_text0'/>
							</td>
							<td>
								<a class="icon-homeimg icon-sdel" href="javascript:;" onclick='deleteTableTr(this);' title="{'DELETE'|@getFixedlabel}">
								</a>
							</td>
						</tr></tbody>
					</table>

					<table class="ControlTable1 listEntries" width="97%" cellspacing="0" cellpadding="0" border="0" align="center">
						<tbody><tr>
							<th align="left" style='padding-left:10px;border:1px solid #ddd;border-top:0px;'>
								<input class="editauto" type="button" onclick='addaotutask_click();' value="{'LBL_THENEWTASK'|@getFixedlabel}"/>
							</th>
						</tr></tbody>
					</table>
				</div>
			</div>
			<div id='autotasktype1' style='disylay:none;padding-right:4px;margin-top:0px;'>
				<textarea name="sqlfilter" id="sqlfilter" cols="35" rows="15" style='width:100%;'>{$SQLFILTER}</textarea>
			</div>
		</div>
		{/if}
      </div>
      </form>		
    </td>
  </tr>
</table>
</div>
<!--中间 end-->
{$STDFILTER_JAVASCRIPT}
<script type="text/javascript">
var updatefor = "{'LBL_UPDATE_FOR'|@getFixedlabel}";//更新为 翻译
var updatefield = "{$COLUMNS_BLOCK}";//当前模块可见字段
var autotaskfield = '{$AUTOTASKFIELD}';//定制任务可见字段
var lbl_delete = "{'DELETE'|@getFixedlabel}";//删除 翻译
var lbl_automatictask_name = "{'LBL_AUTOMATICTASK_NAME'|@getFixedlabel}";//任务名称
var sqlfiltertitle = "{'LBL_AUTOTASKSQLFILTER'|@getFixedlabel}";//sql脚本
var lbl_automatictask_sql = "{'LBL_AUTOMATICTASK_SQL'|@getFixedLabel}";//sql语句
var lbl_automatictask_customized = "{'LBL_AUTOMATICTASK_CUSTOMIZED'|@getFixedLabel}";//定制任务
var lbl_query = "{'QUERY'|@getFixedLabel}";//查询条件
var issubmit = 1;var setype = "{$SETYPE}";
var autotask_type = "{$AUTOTASK.autotasktype}";//任务内容：定制、sql
var autoadvfilter = '{$AUTOADVFILTER}';//高级条件
var autoadvfiltercount = "{$AUTOADVFILTERCOUNT}";//高级条件数量
var filtergroup = "{$AUTOTASK.filtergroup}";//高级条件 分组组合条件（and、or）
var autotackfilter = '{$AUTOTACKFILTER}';//定制任务条件
var lbl_autotaskclose = "{'LBL_AUTOTASKCLOSE'|@getFixedLabel}";//自动任务已关闭，不能执行
var blockidsetting = '{$BLOCKIDSETTING}';
var fieldidsetting = '{$FIELDIDSETTING}';
var lbl_autotask_checkquery = '{"LBL_AUTOTASK_CHECKQUERY"|@getFixedLabel}';
{literal}

var getElementsByName = function(name,tag){
    var returns = document.getElementsByName(name);  
    if(returns.length > 0) return returns;  
    returns = new Array();
	tag = tag || '*';
    var e = document.getElementsByTagName(tag);  
    for(var i = 0; i < e.length; i++){  
        if(e[i].getAttribute("name") == name){  
            returns[returns.length] = e[i];  
        }  
    }  
    return returns;  
}

window.ready = aotubackready();
function aotubackready(){
	if('edit' != setype) return false;
	//切换定职任务、SQL脚本
	var autotasktype = getElementsByName('autotasktype');
	var autotasktypelen = autotasktype.length;
	if(autotasktypelen > 0){
		for(var i=0; i<autotasktypelen; i++){
			autotasktype[i].onclick = function(event){
				var e = event||window.event;
				var obj = e.srcElement||e.target;
				for(var i=0; i<autotasktypelen; i++){
					if(obj.value == i){
						document.getElementById('autotasktype'+i).style.display = '';
					}else{
						document.getElementById('autotasktype'+i).style.display = 'none';
					}
				}
			}
			if(autotasktype[i].checked){
				document.getElementById('autotasktype'+i).style.display = '';
			}else{
				document.getElementById('autotasktype'+i).style.display = 'none';
			}
		}
	}
	if(autotask_type > 0){//任务内容，切换到sql样式
		autotasktype[1].click();
	}
	//SQL框，光标移入移出事件，提醒用户非专业人士不建议使用此功能
	var sqlfilter = document.getElementById('sqlfilter');
	//sqlfilter.style.fontSize = '14px';
	if(sqlfilter.value == ''){
		//sqlfilter.style.backgroundColor = '#D4D0C8';
		sqlfilter.style.color = '#999';
		sqlfilter.value = sqlfiltertitle;
	}
	sqlfilter.onfocus = function(event){
		var e = event||window.event;
		var obj = e.srcElement||e.target;
		if(sqlfiltertitle == trim(obj.value)){
			sqlfilter.style.backgroundColor = '#FFF';
			sqlfilter.style.color = '#666';
			sqlfilter.value = '';
		}
	}
	sqlfilter.onblur = function(event){
		var e = event||window.event;
		var obj = e.srcElement||e.target;
		if('' == trim(obj.value)){
			//sqlfilter.style.backgroundColor = '#D4D0C8';
			sqlfilter.style.color = '#999';
			sqlfilter.value = sqlfiltertitle;
		}
	}
	//每周、每月、每日切换不同界面，目前只有每日，暂不需要此功能，未来可能激活
	if(document.getElementById('eachbackopts') == null) return false;
	document.getElementById('eachbackopts').onchange = function(){
		var eachbackopts = document.getElementById('eachbackopts').value;
		if(eachbackopts == 'week'){//每周
			document.getElementById('weekopts').style.display = 'inline';
			document.getElementById('eachday').style.display = 'none';
		}else if(eachbackopts == 'month'){//每月
			document.getElementById('eachday').style.display = 'inline';
			document.getElementById('weekopts').style.display = 'none';
		}else{
			document.getElementById('eachday').style.display = 'none';
			document.getElementById('weekopts').style.display = 'none';
		}
	}
	var autotaskmode = document.autotaskform.autotaskmode;
	autotaskmode.onchange = function(){
		if(1 == autotaskmode.value){
			document.getElementById('eachbackoptstr').style.display = 'none';
		}else{
			document.getElementById('eachbackoptstr').style.display = '';
		}
	}
	//编辑时，初始化
	if(document.autotaskform.record.value == '') return false;//非编辑状态，不走下面的代码
	if('custom' != document.getElementById('stdDateFilter').value)
		document.getElementById('stdDateFilter').onchange();//执行一下时间下拉框变更
	autotaskmode.onchange();
	//编辑时，初始化高级查询
	if(undefined != autoadvfilter && '' != autoadvfilter){
		var advobj = eval('('+ autoadvfilter +')')?eval('('+ autoadvfilter +')'):JSON.parse(autoadvfilter);
		if(autoadvfiltercount > 1){//如果高级条件分组大于1
			var advlen = 0;
			for(var i=1; i<=autoadvfiltercount; i++){//循环添加新组合
				advlen = advobj[i].length;
				if(advlen > 1){//获取分组下条件个数，如果大于一个，需要添加一列
					for(var j=1; j<advlen; j++){
						addConditionRow(i);//添加一列
					}
				}
				if(i == autoadvfiltercount) continue;//因为默认有一组，所以如果有三组，则只需要再添加两组
				addNewConditionGroup('adv_filter_div');//添加一个分组合
			}
		}else{
			var advlen = advobj[1].length;
			if(advlen > 1){//获取分组下条件个数，如果大于一个，需要添加一列
				for(var j=1; j<advlen; j++){
					addConditionRow(1);//添加一列
				}
			}
		}
		var idx = 0;var filtergrouparr = [];var filtergrouplen = 0;
		if('' != filtergroup){//group 组合条件（or、and）
			filtergrouparr = filtergroup.split(',');
			filtergrouplen = filtergrouparr.length;
			var filtergroupidx = 0;
		}
		var fval = '';var fvalarr = [];
		for (var groupid in advobj) {//循环保存的组合条件
			advlen = advobj[groupid].length;
			for(var i=0; i<advlen; i++){//循环组合下的条件
				document.getElementById('fcol'+idx).value = advobj[groupid][i]['columnname'];
				document.getElementById('fcol'+idx).onchange();//执行字段下拉框变更事件，加载fop下拉框
				document.getElementById('fop'+idx).value = advobj[groupid][i]['comparator'];
				document.getElementById('fop'+idx).onchange();
				fval = advobj[groupid][i]['value'];
				if('dw' != document.getElementById('fop'+idx).value && fval.indexOf(',') > 0){
					fvalarr = fval.split(',');//时间区间情况
					document.getElementById('fval'+idx).value = fvalarr[0];
					document.getElementById('fval_ext'+idx).value = fvalarr[1];//第二个时间
				}else{
					document.getElementById('fval'+idx).value = fval;
				}
				//判断当前条件是否有and、or下拉框，如果有， 则赋值
				if(undefined != document.getElementById('fcon'+idx) && '' != advobj[groupid][i]['column_condition']){
					document.getElementById('fcon'+idx).value = advobj[groupid][i]['column_condition'];
				}
				//判断属于分组的and、or下拉框是否存在，如果存在，则取组合条件赋值
				if(undefined != document.getElementById('gpcon'+idx) && filtergrouplen > 0){
					document.getElementById('gpcon'+idx).value = filtergrouparr[filtergroupidx];
					++ filtergroupidx;
				}
				++ idx;
			}
		}
	}
}
window.onload = function(){
	//初始化定制任务信息
	if(undefined != autotackfilter && '' != autotackfilter){
		var autotackobj = eval('('+ autotackfilter +')')?eval('('+ autotackfilter +')'):JSON.parse(autotackfilter);
		var idx = 0;var autotacklen = autotackobj.length;
		for(var i=0; i<autotacklen; i++){
			if(i > 0){
				addaotutask_click();
			}
			document.getElementById('updatefield'+i).value = autotackobj[i].fld;
			document.getElementById('update_text'+i).value = autotackobj[i].val;
		}
	}
}

/**
 * 基本查询、高级查询、定职任务标签切换事件
 * @author Tujt 2015-01-12
 */
function cellclick(cellid){
 	var celltable = document.getElementById('celltable');
	var cellspan = celltable.getElementsByTagName('li');
	var celllen = cellspan.length;var cellobj;
  if(celllen > 0){
		for(var i=0; i<celllen; i++){
			cellobj = cellspan[i];
  		if(cellid == cellobj.id){
				cellobj.className = 'curr';
				document.getElementById(cellid+'Div').style.display = '';
			}else{
				cellobj.className = '';
				document.getElementById(cellobj.id+'Div').style.display = 'none';
			}
		}
	}
}
function createauto_click(){//创建自动任务
	var fld_module = document.getElementById('reminds_module').value;
	location.href= 'index.php?module=Settings&action=AutomaticTask&setype=edit&blockidsetting='+blockidsetting+'&fieldidsetting='+fieldidsetting+'&fld_tabid='+fld_module;
}
/**
 * 添加定制任务
 * @author Tujt 2015-01-12
 */
var updatefield_idx = 1;
function addaotutask_click(){
	var tableName = document.getElementById('uiaotutab');
	var prev = tableName.rows.length;
	var count = prev - 2 + 1;
	var row = tableName.insertRow(prev);
	row.id = "uiaotutab"+count;
	row.style.verticalAlign = "middle";
	row.setAttribute('bgcolor','white');
	var i = 0;
	var colone = row.insertCell(i);
	colone.innerHTML = '<select name="updatefield[]" id="updatefield'+updatefield_idx+'">'+autotaskfield+'</select>';
	++ i;
	colone = row.insertCell(i);
	colone.innerHTML = '<select name="updatefor[]" id="updatefor'+updatefield_idx+'">'+
						'<option value="0">'+updatefor+'</option></select>';
	++ i;
	colone = row.insertCell(i);
	colone.innerHTML = '<input type="text" name="update_text[]"  id="update_text'+updatefield_idx+'"/>';
	++ i;
	colone = row.insertCell(i);
	colone.innerHTML = '<a class="icon-homeimg icon-sdel" href="javascript:;" title="'+lbl_delete+'" onclick="deleteTableTr(this);"></a>';
	++ updatefield_idx;
}
/**
 * 删除table中的tr标签
 * @author Tujt 2015-01-12
 */
function deleteTableTr(obj){
    var tr = obj.parentNode.parentNode;//img > td > tr，获取tr对象
    var tbody = tr.parentNode;//再往上， 就是tbody对象
    tbody.removeChild(tr);//tbody对象中，删除tr对象
}
/**
 * 自动任务保存方法
 * @author Tujt 2015-01-12
 */
function autotasksave_click(){
	var inputs = document.autotaskform;
	if('' == trim(inputs.autotaskname.value)){//判断自动任务名称非空
		var confirm_str = lbl_automatictask_name+' '+arrJsPopLabel.CANOTEMPTY;
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		inputs.autotaskname.focus();
		return false;
	}
	var autotasktype = getElementsByName('autotasktype');
	var autotasktypelen = autotasktype.length;
	var autotasktype_i = -1;
	for(var i=0; i<autotasktypelen; i++){//获取任务内容：定制任务或SQL格式
		if(autotasktype[i].checked){
			autotasktype_i = autotasktype[i].value;
			break;
		}
	}
	if(-1 == autotasktype_i) return false;
	if(1 == autotasktype_i){//SQL 脚本
		if(sqlfiltertitle == inputs.sqlfilter.value){
			var confirm_str = lbl_automatictask_sql+' '+arrJsPopLabel.CANOTEMPTY;
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			inputs.sqlfilter.focus();
			return false;
		}
		var urlstring = 'module=Settings&action=SettingsAjax&file=AutomaticTask&ajax=true';
		urlstring += '&sqlfilter='+inputs.sqlfilter.value+'&setype=checksql';
		RequestAjax(urlstring,function(rest){
			if('1' == rest){//判断通过，提交保存
				DelProgressObjs();
				if(1 != issubmit) return false;//提交按钮重复提交判断
				issubmit = 2;
				inputs.action.value = 'AutomaticTask';
				inputs.setype.value = 'save';
				inputs.submit();//提交保存
			}else{
				RemindsMsg("","LdPopWidth400px","","yes","",lbl_autotask_checkquery);
				DelProgressObjs();
				return false;
			}
		});
		//可添加更多SQL格式判断...
	}else{
		var isdate = 1;//选了时间
		if('custom' == inputs.stdDateFilter.value){//自定义，未选择事件
			if('' == inputs.startdate.value && '' == inputs.enddate.value)
				isdate = 0;//未选择时间
		}
		var iscond = 0;//未选择条件
		var conditionGroup = getElementsByName('conditionGroup');
		var condlength = conditionGroup.length;
		var condinput = '';var condinputlen = 0;var condindex = 0;
		var condinputtxt;var condinputtxtobj;var groupcond = '';
		var maxindex = 0;
		for(var i=0; i<condlength; i++){
			condinput = conditionGroup[i].getElementsByTagName('input');
			condinputlen = condinput.length;
			if(condinputlen > 0){
				for(var j=0; j<condinputlen; j++){
					if('text' == condinput[j].type){
						condinputtxt = condinput[j].id;//获取text对应的ID
						condinputtxtobj = condinputtxt.split('fval');//获取text对应的index值
						groupcond += condinputtxtobj[1]+'='+(i+1)+',';//条件index值以及与之对应的groupid值
						if(0 == maxindex){
							maxindex = condinputtxtobj[1];
						}else if(maxindex < condinputtxtobj[1]){//index值未必最大的就在最后一列
							maxindex = condinputtxtobj[1];//获取最大的index值
						}
						/**
						 * 添加isnull、isnotnull后，选择了isnull、isnotnull
						 * 后也算选择了查询条件
						 * @author Tujt 2015-03-28
						 */
						if(0 == iscond){
							if('' != trim(condinput[j].value)){//下拉框不为空
								iscond = 1;//break;
							}else if('isnull' == document.getElementById('fop'+maxindex).value || 
								'isnotnull' == document.getElementById('fop'+maxindex).value){
								iscond = 1;
							}
						}
					}
				}
			}
		}
		inputs.groupcond.value = groupcond;//获取高级条件列以及对应的分组信息
		inputs.maxindex.value = maxindex;//获取高级条件最大的index值
		if(0 == isdate && 0 == iscond){//即未选择时间也未选择条件
			var confirm_str = lbl_query+' '+arrJsPopLabel.CANOTEMPTY;
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			if('dvtSelectedCellCommon dvtSelectedCell' == document.getElementById('ui').className){
				document.getElementById('pi').click();//如果是定职任务界面，切换到基本查询界面
			}
			return false;
		}
		var isauto = 0;//未选择任务
		var uiaotutab = document.getElementById('uiaotutab').getElementsByTagName('input');
		var uiaotutablen = uiaotutab.length;
		if(uiaotutablen > 0){
			for(var i=0; i<uiaotutablen; i++){
				if('text' == uiaotutab[i].type){
					if('' != trim(uiaotutab[i].value)){
						isauto = 1;break;
					}
				}
			}
		}
		if(0 == isauto){
			var confirm_str = lbl_automatictask_customized+' '+arrJsPopLabel.CANOTEMPTY;
			RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
			document.getElementById('ui').click();//未选择任务，切换到定制任务界面
			return false;
		}
		//var condmaxinput = conditionGroup[condlength-1].getElementsByTagName('input');
		//var condmaxinputlen = condmaxinput.length;
		//var maxinputid = condmaxinput[condmaxinputlen-3].id;
		//var maxarr = maxinputid.split('fval');
		//var maxindex = maxarr[1];
		//inputs.maxindex.value = maxindex;
		if(1 != issubmit) return false;//提交按钮重复提交判断
		issubmit = 2;
		inputs.action.value = 'AutomaticTask';
		inputs.setype.value = 'save';
		inputs.submit();//提交保存
	}
}
/**
 * 编辑自动任务
 * @author Tujt 2015-01-13
 */
function editautotask_click(record,tabid){
	location.href = 'index.php?module=Settings&action=AutomaticTask&setype=edit&record='+record+'&fld_tabid='+tabid+'&blockidsetting='+blockidsetting+'&fieldidsetting='+fieldidsetting+'';
}
/**
 * 删除自动任务
 * @author Tujt 2015-01-14
 */
function delautotask_click (record){
	var confirm_str = arrJsPopLabel.CANOTRESTOREDAFTERDELETIONDELETEOK;
	RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
	//点击确认
	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){	
    	var urlstring = 'module=Settings&action=SettingsAjax&file=AutomaticTask&ajax=true';
		urlstring += '&record='+record+'&setype=delete';
		RequestAjax(urlstring,function(rest){
			if(rest.indexOf('###EXECUTION###') > -1){//正在执行中
				RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel.RUNNINGPLEASEWAIT);
				return false;
			}
			document.getElementById('reminds_module').onchange();//删除成功，刷新列表
		});
	});
}
/**
 * 执行自动任务
 * @author Tujt 2015-01-14
 */
function execautotask_click (record,tabid){
	var urlstring = 'module=Settings&action=SettingsAjax&file=AutomaticTask&ajax=true';
	urlstring += '&record='+record+'&setype=execution&fld_tabid='+tabid;
	RequestAjax(urlstring,function(rest){
		if(rest.indexOf('PRESENCE') > -1){//已关闭
			DelProgressObjs();
			RemindsMsg("","LdPopWidth400px","","yes","",lbl_autotaskclose);return false;
		}else if(rest.indexOf('###EXECUTION###') > -1){//正在执行中
			RemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel.RUNNINGPLEASEWAIT);
			DelProgressObjs();
			return false;
		}
		DelProgressObjs();
		document.getElementById('reminds_module').onchange();//删除成功，刷新列表
	});
}
/**
 * 开启或关闭自动任务
 * @author Tujt 2015-01-14
 */
function startautotask_click (record,presence){
	var urlstring = 'module=Settings&action=SettingsAjax&file=AutomaticTask&ajax=true';
	urlstring += '&record='+record+'&setype=start&presence='+presence;
	RequestAjax(urlstring,function(rest){
		DelProgressObjs();
		document.getElementById('reminds_module').onchange();//删除成功，刷新列表
	});
}
/**
 * 切换模块下拉框，获取当前模块对应的数据
 * @author Tujt 2015-01-13
 */
function autotaskModule_change (obj){
	var urlstring = 'module=Settings&action=SettingsAjax&file=AutomaticTask&ajax=true';
	urlstring += '&fld_tabid='+obj.value;
	RequestAjax(urlstring,function(rest){
		if('' != rest){
			var list = document.getElementById('cfList');
			sethtml(list,rest);
		}
		DelProgressObjs();
	});
}
function standardFilterDisplay()
{
	if(getObj("stdDateFilterField"))
	{
		if(document.autotaskform.stdDateFilterField.selectedIndex > -1 && document.autotaskform.stdDateFilterField.options[document.autotaskform.stdDateFilterField.selectedIndex].value == "not_accessible")
		{
			getObj('stdDateFilter').disabled = true;
			getObj('startdate').disabled = true;																getObj('enddate').disabled = true;
			//getObj('jscal_trigger_date_start').style.visibility="hidden";
			//getObj('jscal_trigger_date_end').style.visibility="hidden";
		}
		else
		{
			getObj('stdDateFilter').disabled = false;
			getObj('startdate').disabled = false;
			getObj('enddate').disabled = false;
			//getObj('jscal_trigger_date_start').style.visibility="visible";
			//getObj('jscal_trigger_date_end').style.visibility="visible";
		}
	}
}
{/literal}
</script>