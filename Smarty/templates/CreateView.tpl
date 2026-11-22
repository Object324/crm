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

<script type="text/javascript" src="{$JSURL}include/js/EditView.js"></script>
<script type="text/javascript">
	jQuery.noConflict();
</script>
{if $PICKIST_DEPENDENCY_DATASOURCE neq ''}
<script type="text/javascript">
	  fielddepend=new FieldDependencies({$PICKIST_DEPENDENCY_DATASOURCE});
	jQuery(document).ready(function() {ldelim} (fielddepend.init()) {rdelim});
</script>
{/if}

<!-- overriding the pre-defined #company to avoid clash with lingdang_field in the view -->
{literal}
<style type='text/css'>
#company {
	width: 90%;
	height: auto;
}
</style>
{/literal}

<script type="text/javascript">
var gVTModule = '{$smarty.request.module|@vtlib_purify}';
function sensex_info()
{ldelim}
        var Ticker = $('tickersymbol').value;
        if(Ticker!='')
        {ldelim}
                $("vtbusy_info").style.display="inline";
                new Ajax.Request(
                      'index.php',
                      {ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
                                method: 'post',
                                postBody: 'module={$MODULE}&action=Tickerdetail&tickersymbol='+Ticker,
                                onComplete: function(response) {ldelim}
                                        $('autocom').innerHTML = response.responseText;
                                        $('autocom').style.display="block";
                                        $("vtbusy_info").style.display="none";
                                {rdelim}
                        {rdelim}
                );
        {rdelim}
{rdelim}
</script>

{*{include file='Buttons_List1.tpl'}*}

{*<!-- Contents -->*}
<table border=0 cellspacing=0 cellpadding=0 width=98% align=center>
   <tr>
	<td valign=top>
		<img src="{'showPanelTopLeft.gif'|@lingdang_imageurl:$THEME}">
	</td>

	<td class="showPanelBg" valign=top width=100%>
	     {*<!-- PUBLIC CONTENTS STARTS-->*}
	     <div class="small" style="padding:20px">
		
		{* vtlib customization: use translation only if present *}
	
		 {if $OP_MODE eq 'edit_view'}   
			 <span class="font14 fontbold"><font color="purple">[ {$ID} ] </font>{$NAME} -  {'EDIT'|@getFixedLabel} {$MODULE|@getTranstab} {'INFORMATION'|@getFixedLabel}</span> <br>
			{$UPDATEINFO}	 
		 {/if}

		 {if $OP_MODE eq 'create_view'}
			{if $DUPLICATE neq 'true'}
			{assign var=create_new value="LBL_CREATING_NEW_"|cat:$SINGLE_MOD}
				{* vtlib customization: use translation only if present *}
				{assign var="create_newlabel" value=$APP.$create_new}
				{if $create_newlabel neq ''}
					<span class="font14 fontbold">{$create_newlabel}</span> <br>
				{else}
					<span class="font14 fontbold">{'NEW'|@getFixedLabel} {$MODULE|@getTranstab}</span> <br>
				{/if}
		        
			{else}
			<span class="font14 fontbold">{'COPY'|@getFixedLabel} "{$NAME}" </span> <br>
			{/if}
		 {/if}

		 <hr noshade size=1>
		 <br> 
		
		{include file='EditViewHidden.tpl'}

		{*<!-- Account details tabs -->*}
		<table border=0 cellspacing=0 cellpadding=0 width=95% align=center>
		   <tr>
			<td>
				<table border=0 cellspacing=0 cellpadding=3 width=100% class="small">
				   <tr>
					<td class="dvtTabCache" style="width:10px" nowrap>&nbsp;</td>

					{if $ADVBLOCKS neq ''}	
						<td style="width:15%" align="center" nowrap class="dvtSelectedCellCommon dvtSelectedCell" id="bi" onclick="fnLoadValues('bi','mi','basicTab','moreTab','normal','{$MODULE}')"><b>{'BASIC'|@getFixedLabel} {'INFORMATION'|@getFixedLabel}</b></td>
                    	<td class="dvtTabCache" style="width:10px" nowrap>&nbsp;</td>
						<td class="dvtUnSelectedCell" style="width: 100px;" align="center" nowrap id="mi" onclick="fnLoadValues('mi','bi','moreTab','basicTab','normal','{$MODULE}')"><b>{'MORE'|@getFixedLabel} {'INFORMATION'|@getFixedLabel} </b></td>
						<td class="dvtTabCache" style="width:65%" nowrap>&nbsp;</td>
					{else}
						<td class="dvtSelectedCellCommon dvtSelectedCell" align=center nowrap>{'BASIC'|@getFixedLabel} {'INFORMATION'|@getFixedLabel}</td>
	                    <!--
                        chang:kara width:65% with 100%
                        date:2013-06-03
                        reason:bug：4026
                        -->
                        <td class="dvtTabCache" style="width:100%">&nbsp;</td>
                                            
					{/if}
				   <tr>
				</table>
			</td>
		   </tr>
		   <tr>
			<td valign=top align=left >

			    <!-- Basic Information Tab Opened -->
			    <div id="basicTab" class="moreTabclass displayblock">

				<table border=0 cellspacing=0 cellpadding=3 width=100% class="dvtContentSpace">
				   <tr>
					<td align=left>
					<!-- content cache -->
					
						<table border=0 cellspacing=0 cellpadding=0 width=100%>
						   <tr>
							<td id ="autocom"></td>
						   </tr>
						   <tr>
							<td style="padding:10px">
							<!-- General details -->
								<table border=0 cellspacing=0 cellpadding=0 width="100%" class="small">
								   <tr>
									<td  colspan=4 style="padding:5px">
									   <div align="center">
										{if $MODULE eq 'Accounts'}
											<input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';  if(formValidate())AjaxDuplicateValidate('Accounts','accountname',this.form);" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
										{else}
											<input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';  if( formValidate()) return FieldDuplicateValidate('{$MODULE}',ld('#div_pagerecord [name=EditView]'));else return false; " type="submit" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
										{/if}
										<input title="{'CANCEL'|@getFixedLabel}" class="cancel" onclick="window.history.back()" type="button" name="button" value="{'CANCEL'|@getFixedLabel}" style="width:70px">
									   </div>
									</td>
								   </tr>

								   {foreach key=header item=data from=$BASBLOCKS}
								   <tr>
									{if $header== $MOD.LBL_ADDRESS_INFORMATION && ($MODULE == 'Accounts' || $MODULE == 'Quotes' || $MODULE == 'PurchaseOrder' || $MODULE == 'SalesOrder'|| $MODULE == 'Invoice')}
                                                                        <td colspan=4 class="detailedViewHeader">
                                                                        <b>{$header}</b></td>
                                                                   
									{elseif $header== $MOD.LBL_ADDRESS_INFORMATION && $MODULE == 'Contacts'}
									<td colspan=4 class="detailedViewHeader">
                                                                        <b>{$header}</b></td>
                                                                     
                                                                        {else}
						         		<td colspan=4 class="detailedViewHeader">
                                                	        		<b>{$header}</b>
                                                                    <!-- 
                                                                    *新增操作
                                                                    *edit:andy
                                                                    *time:2013-12-11
                                                                    *reson:新增文档 调用模板功能，增加判断显示 '选择文档模板' 按钮
                                                                    -->
                                                                    {if $MODULE eq 'Documents' && $header =='详细信息'}
                                                                        <input title="{$APP.LBL_SELECTDOCUMENTSTEMPLATE_BUTTON_LABEL}" accessKey="{$APP.LBL_SELECTDOCUMENTSTEMPLATE_BUTTON_LABEL}" class="edit" style="margin-left:10px;*margin-left:15px;" onclick="window.open('index.php?module=Users&action=lookupDocumentstemplates','Documentstemplate','top=100,left=200,height=400,width=500,resizable=yes,scrollbars=yes,menubar=no,addressbar=no,status=yes')" type="button" name="button" value=" {$APP.LBL_SELECTDOCUMENTSTEMPLATE_BUTTON_LABEL}  ">
                                                                    {/if}
									{/if}
							 		</td>
     	                          </tr>
                                    <!--{if $MODULE eq 'Documents'}
                                    <tr><td></td><td>{$smarty.foreach.second}<input type="button" value="选择模板"></td></tr>
                                    {/if}-->
								   <!-- Here we should include the uitype handlings-->
								    <!-- 
                                    *更新操作
                                    *edit:diony
                                    *time:2013-12-05
                                    *reson:附件特殊处理
                                    -->
                                   	{if $MODULE eq 'Attachment'} 
                                        {include file="CreateAttachmentView.tpl"}
                                    {else}
										{include file="DisplayFields.tpl"}	
									{/if}                                   
                                   						
								   <tr style="height:25px"><td>&nbsp;</td></tr>
								   {/foreach}

								   <tr>
									<td  colspan=4 style="padding:5px">
									   <div align="center">
										{if $MODULE eq 'Emails'}
                                                                			<input title="{$APP.LBL_SELECTEMAILTEMPLATE_BUTTON_TITLE}" accessKey="{$APP.LBL_SELECTEMAILTEMPLATE_BUTTON_KEY}" class="create" onclick="window.open('index.php?module=Users&action=lookupemailtemplates&entityid={$ENTITY_ID}&entity={$ENTITY_TYPE}','emailtemplate','top=100,left=200,height=400,width=300,menubar=no,addressbar=no,status=yes')" type="button" name="button" value="{$APP.LBL_SELECTEMAILTEMPLATE_BUTTON_LABEL}">
                                                                			<input title="{$MOD.LBL_SEND}" accessKey="{$MOD.LBL_SEND}" class="save" onclick="this.form.action.value='Save';this.form.send_mail.value='true'; return formValidate()" type="submit" name="button" value="  {$MOD.LBL_SEND}  " >
                                                                		{/if}
										{if $MODULE eq 'Accounts'}
											<input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';  if(formValidate())AjaxDuplicateValidate('Accounts','accountname',this.form);" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
										{else}
                                                                		<input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';  return formValidate()" type="submit" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
										{/if}
                                                                		<input title="{'CANCEL'|@getFixedLabel}" class="cancel" onclick="window.history.back()" type="button" name="button" value="{'CANCEL'|@getFixedLabel}" style="width:70px">
									   </div>
									</td>
								   </tr>
								</table>
							</td>
						   </tr>
						</table>
					</td>
				   </tr>
				</table>
					
			    </div>
			    <!-- Basic Information Tab Closed -->

			    <!-- More Information Tab Opened -->
			    <div id="moreTab" class="moreTabclass displaynone">
				<table border=0 cellspacing=0 cellpadding=3 width=100% class="dvtContentSpace">
				   <tr>
					<td align=left>
					{*<!-- content cache -->*}
					
						<table border=0 cellspacing=0 cellpadding=0 width=100%>
						   <tr>
							<td id ="autocom"></td>
						   </tr>
						   <tr>
							<td style="padding:10px">
							<!-- General details -->
								<table border=0 cellspacing=0 cellpadding=0 width=100% class="small">
								   <tr>
									<td  colspan=4 style="padding:5px">
									   <div align="center">
										{if $MODULE eq 'Accounts'}
								<input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';  if(formValidate())AjaxDuplicateValidate('Accounts','accountname',this.form);" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
										{else}
										<input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';  return formValidate()" type="submit" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
										{/if}
                                                                 		<input title="{'CANCEL'|@getFixedLabel}" class="cancel" onclick="window.history.back()" type="button" name="button" value="{'CANCEL'|@getFixedLabel}" style="width:70px">
									   </div>
									</td>
								   </tr>

								   {foreach key=header item=data from=$ADVBLOCKS}
								   <tr>
						         		<td colspan=4 class="detailedViewHeader">
                                                	        		<b>{$header}</b>
                                                         		</td>
                                                         	   </tr>

								   <!-- Here we should include the uitype handlings-->
                                                        	   {include file="DisplayFields.tpl"}

							 	   <tr style="height:25px"><td>&nbsp;</td></tr>
								   {/foreach}

								   <tr>
									<td  colspan=4 style="padding:5px">
									   <div align="center">
										{if $MODULE eq 'Emails'}
                                                                			<input title="{$APP.LBL_SELECTEMAILTEMPLATE_BUTTON_TITLE}" accessKey="{$APP.LBL_SELECTEMAILTEMPLATE_BUTTON_KEY}" class="create" onclick="window.open('index.php?module=Users&action=lookupemailtemplates&entityid={$ENTITY_ID}&entity={$ENTITY_TYPE}','emailtemplate','top=100,left=200,height=400,width=300,menubar=no,addressbar=no,status=yes')" type="button" name="button" value="{$APP.LBL_SELECTEMAILTEMPLATE_BUTTON_LABEL}">
                                                                			<input title="{$MOD.LBL_SEND}" accessKey="{$MOD.LBL_SEND}" class="save" onclick="this.form.action.value='Save';this.form.send_mail.value='true'; return formValidate()" type="submit" name="button" value="  {$MOD.LBL_SEND}  " >
                                                                		{/if}
							{if $MODULE eq 'Accounts'}
											<input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';  if(formValidate())AjaxDuplicateValidate('Accounts','accountname',this.form);" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
										{else}
											<input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';  if( formValidate()) return FieldDuplicateValidate('{$MODULE}',this.form);else return false;" type="submit" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
										{/if}
										<input title="{'CANCEL'|@getFixedLabel}" class="cancel" onclick="window.history.back()" type="button" name="button" value="{'CANCEL'|@getFixedLabel}" style="width:70px">
									   </div>
									</td>
								   </tr>
								</table>
							</td>
						   </tr>
						</table>
					</td>
				   </tr>
				</table>
			    </div>

			</td>
		   </tr>
		</table>
	     </div>
	</td>
	<td align=right valign=top><img src="{'showPanelTopRight.gif'|@lingdang_imageurl:$THEME}"></td>
   </tr>
</table>
</form>

{if ($MODULE eq 'Emails' || $MODULE eq 'Documents') and ($USE_RTE eq 'true')}
    <script type="text/javascript" src="include/ckeditor/ckeditor.js"></script>
    <script type="text/javascript" defer="1">
    	var textAreaName = null;
    	{if $MODULE eq 'Documents'}
    		textAreaName = "notecontent";
    	{else}
    		textAreaName = 'description';
    	{/if}
    
    	CKEDITOR.replace( textAreaName,
    	{ldelim}
    		extraPlugins : 'uicolor',
    		uiColor: '#dfdff1',
            height: 300,
    			on : {ldelim}
    				instanceReady : function( ev ) {ldelim}
    					 this.dataProcessor.writer.setRules( 'p',  {ldelim}
    						indent : false,
    						breakBeforeOpen : false,
    						breakAfterOpen : false,
    						breakBeforeClose : false,
    						breakAfterClose : false
    				{rdelim});
    			{rdelim}
    		{rdelim}
    	{rdelim});
    
    	 var oCKeditor =CKEDITOR.instances[textAreaName];
    </script>
{/if}
{if $MODULE eq 'Accounts'}
<script>
	ScrollEffect.limit = 201;
	ScrollEffect.closelimit= 200;
</script>
{/if}
<script>
        var fieldname = new Array({$VALIDATION_DATA_FIELDNAME})
        var fieldlabel = new Array({$VALIDATION_DATA_FIELDLABEL})
        var fielddatatype = new Array({$VALIDATION_DATA_FIELDDATATYPE})
</script>

<!-- vtlib customization: Help information assocaited with the fields -->
{if $FIELDHELPINFO}
<script type='text/javascript'>
{literal}var fieldhelpinfo = {}; {/literal}
{foreach item=FIELDHELPVAL key=FIELDHELPKEY from=$FIELDHELPINFO}
	fieldhelpinfo["{$FIELDHELPKEY}"] = "{$FIELDHELPVAL}";
{/foreach}
</script>
{/if}
<!-- END -->