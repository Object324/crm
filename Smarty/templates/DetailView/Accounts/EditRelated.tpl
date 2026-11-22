<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}/crmcommon/js/jquery/jquery.autosize.min.js"></script>
<script language="javascript" type="text/javascript" src="uploaddify/jquery.uploadify.min.js"></script>
{include file='EditViewHeader.tpl'}
{*{include file='Buttons_List1.tpl'}*}
<div class="List3Box">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
    {*
    by andy
    相关信息都不显示，隐藏此TD
    date 20140623
    *}
     {if $IS_REL_LIST neq ''}
        <td class="TdLeft" valign="top">
    {else}
        <td class="TdLeft" style="display:none;" valign="top">
    {/if} 
    	<div class="DivL">
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
						
							<h3 title="{'NEW'|@getFixedLabel} {$MODULE|@getTranstab}" 
								onclick='show_detail();'>
					  {'NEW'|@getFixedLabel} {$MODULE|@getTranstab}
				{else}
					<h3 title="{'COPY'|@getFixedLabel} '{$NAME}'" 
								onclick='show_detail();'>
						{'COPY'|@getFixedLabel} - {$NAME}
				{/if}
			{/if}
				</h3>
			<input type='hidden' id='currrelid' value='0'>
            <input type="hidden" id="bemodulestatus" name="bemodulestatus" value="{$BESTATUS}" />
           <div class="Title" onclick='show_related();'>
               <a href="#"><font class="colorLink">{$MODULE|@getTranstab}</font>&nbsp;&gt;&nbsp;{'MOREINFORMATION'|@getFixedLabel}</a>
           </div>
				{if $IS_REL_LIST && $IS_REL_LIST != ''}
					<ul>
					{if $OP_MODE eq 'edit_view'}
						{foreach key=relid item=label from=$IS_REL_LIST name=relatedfor}
							{if  $label == 'BalanceOfAccount'}
								{if $MODBALANCESTR != ''}
									<li><a href="#" id='rel-list-{$relid}' onclick='rel_balance_list(this,"{$MODULE}","{$ID}","{$relid}");'>
										<span class="Text">
											{'BALANCEOFACCOUNT'|@getFixedLabel}
											<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
										</span>
										<span id="rel-coount-{$relid}"></span>
									</a></li>
								{/if}
                            {elseif  $label == 'Home'}
                            <script language="javascript" type="text/javascript">var homecontrol=1;</script>
                            <script language="javascript" type="text/javascript" src="modules/Home/Coordination.js"></script>
            						      <li><a href="#" id='rel-list-{$relid}' onclick='show_workreport(this,"{$MODULE}","{$ID}","{$relid}");'>
            									<span class="Text">
            										{'LBL_COOPERATIVEWORK'|@getFixedLabel}
            										<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
            									</span>
            									<span id="rel-coount-{$relid}"></span>
            								</a></li>
                            {elseif $PhoneSteward == '' && $label == 'CallButler'}
                        
							{else}
								<li><a href="#" id='rel-list-{$relid}' tag="{$label}" 
								onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
									<span class="Text">
										{$label|@getTranstab}
										<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
									</span>
									<span id="rel-coount-{$relid}"></span>
								</a></li>
							{/if}
						{/foreach}
						
							<input type="hidden" id="modbalancestr" value="{$MODBALANCESTR}"/>
						
					{else}
						{foreach key=relid item=label from=$IS_REL_LIST name=relatedfor}
							{if  $label == 'BalanceOfAccount'}
								{if $MODBALANCESTR != ''}
									<li><a href="#" onclick='return false;' id='rel-list-{$relid}'>
										<span class="Text">
											{'BALANCEOFACCOUNT'|@getFixedLabel}
										</span>
										<span id="rel-coount-{$relid}"></span>
									</a></li>
								{/if}
                            {elseif  $label == 'Home'}
                            <script language="javascript" type="text/javascript">var homecontrol=1;</script>
                            <script language="javascript" type="text/javascript" src="modules/Home/Coordination.js"></script>
            						      <li><a href="#" id='rel-list-{$relid}' onclick='return false;' >
            									<span class="Text">
            										{'LBL_COOPERATIVEWORK'|@getFixedLabel}
            										<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
            									</span>
            									<span id="rel-coount-{$relid}"></span>
            								</a></li>    
							{else}
								<li><a href="#" onclick='return false;' id='rel-list-{$relid}'>
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
		<div id="DetailContent">
            <table width="100%" border="0" cellspacing="0" cellpadding="0" aling="left">
				<tr>
					<td class="left">
						<div class="DivC">
							{include file='EditViewHidden.tpl'}
							<table border=0 cellspacing="0" cellpadding=0 width=100% class="DetailContentTable">
								<tr style="border-top:none;">
									 <td  colspan=4 style="height: 45px;line-height: 45px;">
										  <div align="center">
										  {include file='EditViewTopButton.tpl'}
										  </div>
		 
									 </td>
								</tr>
                                {*录音文件信息*}
                                {if  $CALLDISPLAY eq 'yes'}
                                    {include file="DetailView/CallButlerEditView.tpl"}
                                {/if}                               
							
                                {foreach key=header item=data from=$BLOCKS name=blocknames}
                                <!-- This is added to display the existing comments -->
                               
                                   
                                      <tr>
                                        {assign var=addressinfo value='ADDRESSINFO'|@getFixedLabel}
                                    	{if $header eq $addressinfo && ($MODULE eq 'Accounts' )}
                                    		<td colspan=4 class="editrelhead">
                                    			<b>{$header}</b></td>
                                    
                                    	{else}
                                    		<td colspan=4 class="editrelhead">
                                    			<b>{$header}</b>
                                                            
                                            </td>
                                    	{/if}
                                      </tr>
                                    
                                    		{include file="DetailView/DisplayFields.tpl"}
                                    	
                                {/foreach}
                               
                              
								<!-- Added to display the Product Details in Inventory-->
								 
								<tr style="border-bottom:none;">
									 <td  colspan="4" style="padding:5px;">
										  <div align="center">
												{include file='EditViewBottomButton.tpl'}
										  </div>
									 </td>
								</tr>
						  </table>
						</div>
					</td>
				</tr>
			</table>
		</div></form>
      <!--	related	-->
		<div class="paneldiv">
			{include file="RelatedListsHidden.tpl"}
			<div id='RelatedContent'  style="display: none;">
			</div>
			</form>
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
</form>
	<form name="SendMail" style="float:left;"><div id="sendmail_cont" style="z-Index:9999999999999;position:absolute;"></div></form>

{include file='EditViewBottom.tpl'}
<script language="JavaScript" type="text/javascript">
var opmode = "{$OP_MODE}";
var boolmode = "{$MODULE|@get_file_address:'ShowServiceContractsDetail'}";
var module = '{$MODULE}';
var accountid = "{$ACCOUNTID}";
var contactid = '{$CONTACTID}';
var mode = "{$MODE}";
var bestatus = "{$BESTATUS}";{* 客户和联系人关联字段信息 状态*}
var befields = '{$BEMODULEFIELDS}';{* 当前编辑页  客户、联系人的模块ID和数据ID *}
var currency_id = "{$CURRENCYID}";
{literal}
window.onload = function(){
	if(mode != 'edit')
	{
		//新增、编辑，根据币种ID，默认币种类型和银行账户
		if(currency_id > 1)
		{
			ChangeBankAccount(currency_id,module);
		}
	}
	if(opmode == 'edit_view'){
		set_rel_count();
	}
    //客户服务单、项目任务、销售机会显示 客户联系人关联字段
    if(bestatus == 'YES')
    {
        getAccountsContactsInfo(accountid,contactid,module,'EditView');
    }
    if(boolmode == true && module == 'HelpDesk'){
		showServiceContractsDetail(accountid,module);
	}
    //带有搜索的下拉框，z-index赋值，解决低版本 下拉框覆盖问题
    dropDownBoxSearch(document.EditView);
    //textarea根据内容自动调整大小
    ld('textarea').autosize();
}
function onClickShowServiewDetail(accountid,module)
{
    showServiceContractsDetail(accountid,module);
}
function onClickgetAccountsContactsInfo(accountid,contactid,module,mode)
{
    var popupobj=CrmPopup.getPopupObj("last");
    getAccountsContactsInfo(accountid,contactid,module,popupobj);
}
{/literal}
                  
</script>
