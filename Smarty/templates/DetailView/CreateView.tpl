{*<!-- module header -->*}
<!--修改编码格式:统一编码：UTF-8-->


<script type="text/javascript" src="{$JSURL}include/js/EditView.js"></script>
<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.autosize.min.js"></script>
<script src="uploaddify/jquery.uploadify.min.js" type="text/javascript"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js"></script>
<link rel="stylesheet" type="text/css" href="uploaddify/uploadify.css">
<script type="text/javascript">
	ld.noConflict();
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

{literal}
window.onload = function(){
ld('textarea').not('.proName_note').autosize();//textarea根据内容自动调整大小
}
{/literal}
</script>
{*{include file='Buttons_List1.tpl'}*}
{assign var='languagetype' value={''|@getLanguageType}}
<div class="List3Box">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    {*
    by andy
    相关信息都不显示，隐藏此TD
    date 20140623
    *}
     {if $IS_REL_LIST|@count > 0}
        <td class="TdLeft" valign="top">
    {else}
       <td class="TdLeft" style="display:none;" valign="top">
    {/if} 
    	<div class="DivL">
    		{*
			{if $OP_MODE eq 'edit_view'}
        		<h3 title="{$NAME} -  {$MODULE|@getTranstab} {'INFORMATION'|@getFixedLabel}&#10;{$UPDATEINFO}" 
				onclick='show_detail();'>
					<span id="vtbusy_info" style="display:none;position:absolute;" valign="bottom">
						<img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0">
					</span>
					{$NAME}
			{elseif $OP_MODE eq 'create_view'}
				<span id="vtbusy_info" style="display:none;position:absolute;" valign="bottom">
					<img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0">
				</span>
				{if $DUPLICATE neq 'true'}
					  {if $MODULE eq 'Events'}
							<h3 title="{'NEW'|@getFixedLabel} {'Calendar'|@getTranstab}" 
								onclick='show_detail();'>
					  {else}	
							<h3 title="{'NEW'|@getFixedLabel} {$MODULE|@getTranstab}" 
								onclick='show_detail();'>
					  {/if}
					  {if $languagetype eq 'zh'}
						{$MODULE|@getTranstab} {'NEW'|@getFixedLabel}
					  {else}
                        {'NEW'|@getFixedLabel} {$MODULE|@getTranstab}
					  {/if}
				{else}
					<h3 title="{'COPY'|@getFixedLabel} '{$NAME}'" 
								onclick='show_detail();'>
						{'COPY'|@getFixedLabel} - {$NAME}
				{/if}
			{/if}
				</h3>
				*}
			<input type='hidden' id='currrelid' value='0'>
           <div class="Title" onclick='show_detail();' >
            <a href="javascript:void(0);" style="white-space: normal;">
              {$MODULE|@getTranstab}{'MODULERELSEVANT'|@getTranstab}
              {if ''|@checkCurrentUserIsAdmin eq 'on'}
              <b onclick="SetRelatedlist(this,'{$MODULE}','','');event.stopPropagation();" style="float: right;margin:10px 20px 0 0;" class="icon-homeimg icon-set" title="{'SETTINGS'|@getFixedLabel}"></b>
              {/if}
            </a>
           </div>
				{if $IS_REL_LIST && $IS_REL_LIST != ''}
					<ul>
					{if $OP_MODE eq 'edit_view'}
						{foreach key=relid item=label from=$IS_REL_LIST name=relatedfor}
                               {if $label == 'SharedUsers'}                              
                            <li><a href="javascript:void(0);" id='rel-list-{$relid}'onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
								<span class="Text">
									{'ShareUsers'|@getFixedLabel}
									<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
								</span>
								<span id="rel-coount-{$relid}"></span>
							</a></li> 
                            {elseif $label == 'ViewHistory'}
                            <li><a href="javascript:void(0);" id='rel-list-{$relid}'onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
								<span class="Text">
									{'View History'|@getFixedLabel}
									<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
								</span>
								<span id="rel-coount-{$relid}"></span>
							</a></li> 
                            {elseif $label == 'ChangeView'}
                            <li><a href="javascript:void(0);" id='rel-list-{$relid}'onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
								<span class="Text">
									{'SmownerChangeView'|@getFixedLabel}
									<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
								</span>
								<span id="rel-coount-{$relid}"></span>
							</a></li>                                                                                                                 
                            {/if}                                                                                              
						{/foreach}
					{else}
						{foreach key=relid item=label from=$IS_REL_LIST name=relatedfor}
                        
                           {if $label == 'SharedUsers'} 
                            <li><a href="javascript:void(0);" id='rel-list-{$relid}'>
								<span class="Text">
									{'ShareUsers'|@getFixedLabel}
									<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
								</span>
								<span id="rel-coount-{$relid}"></span>
							</a></li> 
                            {elseif $label == 'ViewHistory'}
                              <li>
                                <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' >
                    							<span class="Text">
                    								{'View History'|@getFixedLabel}
                    								<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
                    							</span>
                  					   	</a>
                              </li>
                            {elseif $label == 'ChangeView'}
                              <li>
                                <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' >
                    							<span class="Text">
                    								{'SmownerChangeView'|@getFixedLabel}
                    								<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
                    							</span>
                  					   	</a>
                              </li>
                            {elseif $label == 'Print'}
							{else}
							 <li><a href="javascript:void(0);" id='rel-list-{$relid}'>
								<span class="Text">
									{$label|@getTranstab}
								</span>
								<span id="rel-coount-{$relid}"></span>
							</a></li>
                            {/if}                                                
						{/foreach}
					{/if}
					</ul>
				{else}
					<ul>
						<li>&nbsp;</li>
					</ul>
				{/if}
			</div>
    </td>
	<td class="Tdcenter" valign="top">
			<input type="hidden" name="SearchScope" id="SearchScopeDetail" value="{$SEARCHSCOPE}"/>
		<div id="DetailContent"  class="ld-createedit-content">
            <table width="100%" border="0" cellspacing="0" cellpadding="0" aling="left">
				<tr>
					<td class="left">
						<div class="DivC">
						<div class="Top">
							{include file='EditViewHidden.tpl'}
		{*<!-- Account details tabs -->*}
		<table border=0 cellspacing=0 cellpadding=0 width=100% align=center>
		   <tr>
			<td valign=top align=left >
			    <!-- Basic Information Tab Opened -->
			    <div id="">
				<table border=0 cellspacing=0 cellpadding=0 width=100%>
				   <tr>
					<td>
					<!-- content cache -->					
						<table border="0" cellspacing=0 cellpadding=0 width=100%>
						   <tr>
							<td id ="autocom"></td>
						   </tr>
						   <tr>
							<td style="padding:0px">
							<!-- General details -->
								<table border="0" cellspacing="1" cellpadding="0" width="100%" class="DetailContentTable">
								   <tr style="border:none;">
									<td  colspan=4 style="padding:5px">
									   <div align="center">
										{if $MODULE eq 'Accounts'}
											<input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';  if(formValidate())AjaxDuplicateValidate('Accounts','accountname',this.form);" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
										{else}
											<input title="{'SAVE'|@getFixedLabel}" class="save" onclick=" this.disabled=true;this.form.action.value='Save';  if( formValidate()) return FieldDuplicateValidate('{$MODULE}',ld('#div_pagerecord [name=EditView]'),this);else {ldelim} this.disabled=false; return  false;{rdelim} " type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
										{/if}
										<input title="{'CANCEL'|@getFixedLabel}" class="cancel" onclick="window.history.back()" type="button" name="button" value="{'CANCEL'|@getFixedLabel}" style="width:70px">
									   </div>
									</td>
								   </tr>
								   {foreach key=header item=data from=$BASBLOCKS}
								   <tr>
									{if $header== $MOD.LBL_ADDRESS_INFORMATION && ($MODULE == 'Accounts' || $MODULE == 'Quotes' || $MODULE == 'PurchaseOrder' || $MODULE == 'SalesOrder'|| $MODULE == 'Invoice')}
                                        <td colspan=4 class="editrelhead">
                                        <b>{$header}</b></td>                                                                 
									{elseif $header== $MOD.LBL_ADDRESS_INFORMATION && $MODULE == 'Contacts'}
									   <td colspan=4 class="editrelhead">
                                        <b>{$header}</b></td>
                                   {else}
						         		<td colspan=4 class="editrelhead">
                    	        		<b>{$header}</b>{$header|@getBlockInfoForLinks}
                                     
									{/if}
							 		</td>
     	                          </tr>
                                    
								   <!-- Here we should include the uitype handlings-->
								    <!-- 
                                    *更新操作
                                    *edit:diony
                                    *time:2013-12-05
                                    *reson:附件特殊处理
                                    -->
                                    	{include file="DetailView/DisplayFields.tpl"}
                                   	{*{if $MODULE eq 'Attachment'} 
                                        {include file="DetailView/CreateAttachmentView.tpl"}
                                    {else}
										{include file="DetailView/DisplayFields.tpl"}	
									{/if} *}                                  
                                   {/foreach}
								   <tr style="border-bottom:none;">
									<td  colspan=4 style="padding:5px">
									   <div align="center">
										{include file='EditViewBottomButton.tpl'}
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
						</div>
					</td>
				</tr>
			</table>
		</div>
	</td>
	<!--<td class="TdRight" valign="top">
		<div class="DivR">
    {*include file="DetailView/DetailOperation.tpl"*}
		</div>
	</td>-->
  </tr>
</table>
<input name='search_url' id="search_url" type='hidden' value='{$SEARCH}'>
</div></form>
     <!--	related	-->
		<div class="paneldiv">
			{include file="RelatedListsHidden.tpl"}
			<div id='RelatedContent'  style="display: none;">
			</div>
			</form>
		</div>
	</td>
      </tr>
</table>
<div id="SetRelatedlists_div" class="D_pop_box LdPopWidth600px" style="display:none; position: absolute; z-Index:9999"></div>
{include file='EditViewBottom.tpl'}

<!--
*新增操作，条件附件上传插件 UPLOADIFY
*by andy 20131227
-->
<script type="text/javascript">
    var cur_moudleName = "{$MODULE}";
    var cur_moudleName_ajax="{$MODULE}"+'Ajax';
    var fieldinfoobjs='';
    var opmode = "{$OP_MODE}";
    if(opmode == 'edit_view'){
		set_rel_count();
        set_rel_createbtn();
	}
</script>    