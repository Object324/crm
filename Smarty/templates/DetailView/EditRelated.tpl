<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.autosize.min.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/modules/Products/multifile.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/Inventory.js"></script>
<script language="javascript" type="text/javascript" src="{$JSURL}include/js/popupselectfield.js"></script>
<script language="javascript" type="text/javascript" src="{$JSURL}include/js/fieldinfo.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js"></script>

{include file='EditViewHeader.tpl'}
{assign var='formname' value='EditView'}
<script>
var module = '{$MODULE}';
{literal}
dynamicJsScript['include/js/popupselectfield.js']=1;
dynamicJsScript['include/js/fieldinfo.js']=1;
 var PageRecordPopupobj=PageRecordPopup.load(module);
{/literal}
</script>
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
			{assign var='languagetype' value={''|@getLanguageType}}
			  <input type='hidden' id='currrelid' value='0'>
        <input type="hidden" id="bemodulestatus" name="bemodulestatus" value="{$BESTATUS}" />
        <div class="Title" onclick='show_detail();' style="border-bottom: 1px #fff solid;">
          <a  href="javascript:void(0);" style="white-space: normal;">
            <b style="float:left;text-overflow:ellipsis;width:10em;white-space:nowrap;overflow:hidden;padding-left: 1px;">{$MODULE|@getTranstab}{'MODULERELSEVANT'|@getTranstab}</b>
            {if ''|@checkCurrentUserIsAdmin eq 'on'}
            <b onclick="SetRelatedlist(this,'{$MODULE}','','');event.stopPropagation();" style="float: right;margin:10px 20px 0 0;" class="icon-homeimg icon-set" title="{'SETTINGS'|@getFixedLabel}"></b>
            {/if}
          </a>
        </div>
				{if $IS_REL_LIST && $IS_REL_LIST != ''}
					<ul>
					{if $OP_MODE eq 'edit_view'}
                      <li>
                          <a href="javascript:void(0);" onclick='show_detail();'>
          									<span class="Text">
                                                <i class="ico-dot"></i>
          										{$MODULE|@getTranstab}{'details1'|@getFixedLabel}
          									</span>
        								  </a>
                        </li>
						{foreach key=relid item=label from=$IS_REL_LIST name=relatedfor}
							{if ($MODULE == 'Accounts' || $MODULE == 'ServiceCharge') && $label == 'BalanceOfAccount'}
								{if $MODBALANCESTR != ''}
									<li>
                    <a href="javascript:void(0);" id='rel-list-{$relid}' onclick='rel_balance_list(this,"{$MODULE}","{$ID}","{$relid}");'>
  										<span class="Text">
  											   <i class="ico-dot"></i>
                                              {'BALANCEOFACCOUNT'|@getFixedLabel}
  											<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
  										</span>
  										<span id="rel-coount-{$relid}"></span>
  									</a>
                  </li>
								{/if}
              {elseif $label == 'Home'}
                <script language="javascript" type="text/javascript">var homecontrol=1;</script>
                <script language="javascript" type="text/javascript" src="{$JSURL}include/js/modules/Home/Coordination.js"></script>
                
                <script language="javascript" type="text/javascript" src="uploaddify/jquery.uploadify.min.js"></script>
					      <li>
                  <a href="javascript:void(0);" id='rel-list-{$relid}' onclick='show_workreport(this,"{$MODULE}","{$ID}","{$relid}");'>
  									<span class="Text">
							              <i class="ico-dot"></i>
                                          {'LBL_COOPERATIVEWORK'|@getFixedLabel}
  										<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
  									</span>
  									<span id="rel-coount-{$relid}"></span>
  								</a>
                </li>
              {elseif $PhoneSteward == '' && $label == 'CallButler'}
                            
              {elseif $label == 'BoughtProduct'}
                <li>
                  <a href="javascript:void(0);" id='rel-list-{$relid}' tag="{$label}" onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
  									<span class="Text">
  									     <i class="ico-dot"></i>
                                        {'BOUGHTPRODUCT'|@getFixedLabel}
  										<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
  									</span>
  									<span id="rel-coount-{$relid}"></span>
  								</a>
                </li>
              {elseif $label == 'buyProductQuantity'}
                <li>
                  <a href="javascript:void(0);" id='rel-list-{$relid}' tag="{$label}" onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
  									<span class="Text">
		                                <i class="ico-dot"></i>
                                        {'BUYPRODUCTQUANTITY'|@getFixedLabel}
  										<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
  									</span>
  									<span id="rel-coount-{$relid}"></span>
  								</a>
                </li>
              {elseif $label == 'SharedUsers'}
                <li>
                  <a href="javascript:void(0);" id='rel-list-{$relid}' tag="{$label}" onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
  									<span class="Text">
  									     <i class="ico-dot"></i>
                                        {'ShareUsers'|@getFixedLabel}
  										<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
  									</span>
  									<span id="rel-coount-{$relid}"></span>
  								</a>
                </li>
              {elseif $label == 'Redemption'}
                <li>
                  <a href="javascript:void(0);" id='rel-list-{$relid}' tag="{$label}" onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
                    <span class="Text">
                      <i class="ico-dot"></i>
                      {'REDEMPTION'|@getFixedLabel}
                      <input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
                    </span>
                    <span id="rel-coount-{$relid}"></span>
                  </a>
                </li>
              {elseif $label == 'Jijin_Log_Detail'}
                <li>
                  <a href="javascript:void(0);" id='rel-list-{$relid}' tag="{$label}" onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
    								<span class="Text">
    								  <i class="ico-dot"></i>
                                      重算日志
    									<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
    								</span>
    								<span id="rel-coount-{$relid}"></span>
    							</a>
                </li> 
              {elseif $label == 'Kingdeeorders'}
                <li>
                  <a href="javascript:void(0);" id='rel-list-{$relid}' tag="{$label}" onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
  									<span class="Text">
  									  <i class="ico-dot"></i>
                                      {'KINGDEEORDERS'|@getFixedLabel}
  										<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
  									</span>
  									<span id="rel-coount-{$relid}"></span>
  								</a>
                </li>
              {elseif $label == 'Kingdeequotes'}
                <li>
                  <a href="javascript:void(0);" id='rel-list-{$relid}' tag="{$label}" onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
    								<span class="Text">
    								  <i class="ico-dot"></i>
                                      {'KINGDEEQUOTES'|@getFixedLabel}
    									<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
    								</span>
    								<span id="rel-coount-{$relid}"></span>
    							</a>
                </li>
              {elseif $label == 'Digiwinorders'}
                <li>
                  <a href="javascript:void(0);" id='rel-list-{$relid}' tag="{$label}" onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
    								<span class="Text">
                                      <i class="ico-dot"></i>
    								  {'DIGIWINORDERS'|@getFixedLabel}
    									<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
    								</span>
    								<span id="rel-coount-{$relid}"></span>
    							</a>
                </li>
              {elseif $label == 'Digiwintickets'}
                <li>
                  <a href="javascript:void(0);" id='rel-list-{$relid}' tag="{$label}" onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
    								<span class="Text">
                                    <i class="ico-dot"></i>
    						  		{'DIGIWINTICKETS'|@getFixedLabel}
    									<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
    								</span>
    								<span id="rel-coount-{$relid}"></span>
    							</a>
                </li>
              {elseif $label == 'ViewHistory'}
              <li>
                <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
    							<span class="Text">
                                    <i class="ico-dot"></i>
    								{'View History'|@getFixedLabel}
    								<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
    							</span>
    							<span id="rel-coount-{$relid}"></span>
  					   	</a>
              </li>
             {elseif $label == 'Print'}
            {elseif $label == 'ChangeView'}
              <li>
                <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
    							<span class="Text">
                                    <i class="ico-dot"></i>
    								{'SmownerChangeView'|@getFixedLabel}
    								<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
    							</span>
    							<span id="rel-coount-{$relid}"></span>
  					   	</a>
              </li>
            {elseif $label == 'ContactsHierarchy'}
              {if  $FORSHOW eq 'yes'}
              <li>
                <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' onclick="getContactHierarchy('{$ID}')">
    							<span class="Text">
                                    <i class="ico-dot"></i>
    								{'VIEW'|@getFixedLabel}{'THELOWLEVELCONTRACTS'|@getFixedLabel}
    								<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
    							</span>
    							<span id="rel-coount-{$relid}"></span>
  					   	</a>
              </li>
              {/if}
            {elseif $label == 'AccountHierarchy'}
              <li>
                <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' onclick="getAccountHierarchy('{$ID}','{$CONTACTSSTATUS}')">
    							<span class="Text">
                                    <i class="ico-dot"></i>
    								{'LBL_SHOW_ACCOUNT_HIERARCHY'|@getFixedLabel}
    								<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
    							</span>
    							<span id="rel-coount-{$relid}"></span>
  					   	</a>
              </li>                
							{else}
								<li>
                  <a href="javascript:void(0);" id='rel-list-{$relid}' tag="{$label}" onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
  									<span class="Text">
                                        <i class="ico-dot"></i>
  										{$label|@getTranstab}
  										<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
  									</span>
                                    <span id="rel-createbtn-{$relid}"></span>
  									<span id="rel-coount-{$relid}"></span>
  								</a>
                </li>
							{/if}
						{/foreach}
						{if $MODULE == 'Accounts' || $MODULE == 'ServiceCharge'}
							<input type="hidden" id="modbalancestr" value="{$MODBALANCESTR}"/>
						{/if}
					{else}
						{foreach key=relid item=label from=$IS_REL_LIST name=relatedfor}
							{if ($MODULE == 'Accounts' || $MODULE == 'ServiceCharge') && $label == 'BalanceOfAccount'}
								{if $MODBALANCESTR != ''}
									<li><a href="javascript:void(0);" onclick='return false;' id='rel-list-{$relid}'>
										<span class="Text">
                                            <i class="ico-dot"></i>
											{'BALANCEOFACCOUNT'|@getFixedLabel}
										</span>
										<span id="rel-coount-{$relid}"></span>
									</a></li>
								{/if}
                            {elseif  $label == 'Home'}
                           <script language="javascript" type="text/javascript">var homecontrol=1;</script>
                        <script language="javascript" type="text/javascript" src="modules/Home/Coordination.js"></script>
                        <script language="javascript" type="text/javascript" src="include/jquery/jquery.autosize.min.js"></script>
                        <script language="javascript" type="text/javascript" src="uploaddify/jquery.uploadify.min.js"></script>
            						      <li><a href="javascript:void(0);" id='rel-list-{$relid}' onclick='return false;' >
            									<span class="Text">
                                                    <i class="ico-dot"></i>
            										{'LBL_COOPERATIVEWORK'|@getFixedLabel}
            										<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
            									</span>
            									<span id="rel-coount-{$relid}"></span>
            								</a></li>
                            {elseif  $label == 'SharedUsers'}
                               <li><a href="javascript:void(0);" id='rel-list-{$relid}'>
									<span class="Text">
                                    <i class="ico-dot"></i>
									{'ShareUsers'|@getFixedLabel}
										<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
									</span>
									<span id="rel-coount-{$relid}"></span>
								</a></li>
                            {elseif  $label == 'ViewHistory'}
                               <li><a href="javascript:void(0);" id='rel-list-{$relid}'>
									<span class="Text">
                                    <i class="ico-dot"></i>
									{'View History'|@getFixedLabel}
									</span>
								</a></li>
                            {elseif  $label == 'ChangeView'}
                               <li><a href="javascript:void(0);" id='rel-list-{$relid}'>
									<span class="Text">
                                    <i class="ico-dot"></i>
									{'SmownerChangeView'|@getFixedLabel}
									</span>
								</a></li>
                            {elseif  $label == 'ContactsHierarchy'}
                               <li><a href="javascript:void(0);" id='rel-list-{$relid}'>
									<span class="Text">
                                    <i class="ico-dot"></i>
									{'VIEW'|@getFixedLabel}{'THELOWLEVELCONTRACTS'|@getFixedLabel}
									</span>
								</a></li>
                            {elseif  $label == 'AccountHierarchy'}
                               <li><a href="javascript:void(0);" id='rel-list-{$relid}'>
									<span class="Text">
                                    <i class="ico-dot"></i>
									{'LBL_SHOW_ACCOUNT_HIERARCHY'|@getFixedLabel}
									</span>
								</a></li>
                            {elseif $PhoneSteward == '' && $label == 'CallButler'}
                            {elseif  $label == 'Print'}
							{else}
								<li><a href="javascript:void(0);" tag="{$label}" onclick='return false;' id='rel-list-{$relid}'>
									<span class="Text">
                                        <i class="ico-dot"></i>
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
		<div id="DetailContent" class="ld-createedit-content">
            <table width="100%" border="0" cellspacing="0" cellpadding="0" aling="left">
				<tr>
					<td class="left">
						<div class="DivC" id="div_pagerecord">
							{include file='EditViewHidden.tpl'}
							<table class="" border=0 cellspacing="0" cellpadding=0 width=100%>
								<tr style="border-top:none;">
									 <td  colspan=4 style="height: 45px;">
										  <div align="center">
										  {include file='EditViewTopButton.tpl'}
										  </div>
		 
									 </td>
								</tr>
                                {*录音文件信息*}
                                {if ($MODULE eq 'Accounts' || $MODULE eq 'Contacts' || $MODULE eq 'HelpDesk' || $MODULE eq 'ContactRecords'
                                    || $MODULE eq 'Vendors' || $MODULE eq 'VendorContact' || $MODULE eq 'VendorContactRecords') && $CALLDISPLAY eq 'yes'}
                                    {include file="DetailView/CallButlerEditView.tpl"}
                                {/if}                               
								{include file='DetailView/EditViewForeach.tpl'}
								<!-- Added to display the Product Details in Inventory-->
								{if $MODULE eq 'SalesBack'}
									 <tr>
										  <td colspan=4>
												{include file="Inventory/ProductDetailsEditView.tpl"}
										  </td>
									 </tr>
								{/if}
								{if $MODULE eq 'CashBill' }
									<tr>
									  <td colspan=4 class="editrelhead">
                      <b class="DivCName" tag="headblock-title">
                        <span id="CashBillrelatemessagespan"></span>{'GATHERINGINFORMATION'|@getFixedLabel}
                      </b>
									  </td>
									</tr>
                  <tr>
                    <td colspan=4>
                      <div id="cashbillsource">{$THHTML}</div>
                    </td>
                  </tr>
								{/if}
								{if $MODULE eq 'SendCashBill' }
									 <tr>
										  <td colspan=4>
												{include file="modules/SendCashBill/SendPaymentList.tpl"}
										  </td>
									 </tr>
								{/if}
                                {if $MODULE eq 'Commission' }
									 <tr>
										  <td colspan=4>
                                                <div id="cashbillsource">{$THHTML}</div>
												{*include file="modules/Commission/CommissionList.tpl"*}
										  </td>
									 </tr>
								{/if}
								{if get_file_address($MODULE,$MODULE|cat:'DetailFieldsHtml')}
									 <tr>
										  <td colspan=4>
                                          		<div id="mainTablenrth" style="overflow-x:auto;">
                                                    {include file="modules/TabDetail/EditList.tpl"}
                                                </div>
												
										  </td>
									 </tr>
								{/if}
                                {if $MODULE eq 'LessionPlan' }
									 <tr>
										  <td colspan=4>
												{include file="modules/LessionPlan/LessionPlanList.tpl"}
										  </td>
									 </tr>
								{/if}
        						 {if $MODULE eq 'Events'}                                   
        								{include file="ActivityEditView.tpl"}                                            
        						 {/if}   
								<tr style="border-bottom:none;">
									 <td align="center" colspan="4" style="height: 45px;">
                                        {if $MODULE neq 'Users'}
										      {include file='EditViewBottomButton.tpl'}
                                         {/if}
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
<!--公告选择用户,提醒选择接收人div-->
<div id="recipient_namediv" class="D_pop_box LdPopWidth600px" style="display:none; position: absolute; z-Index:9999"></div>
<div id="actiondiv" class="D_pop_box LdPopWidth900px" style="display:none; z-index:3;"></div>
<!--相关信息设置div-->
<div id="SetRelatedlists_div" class="D_pop_box LdPopWidth600px" style="display:none; position: absolute; z-Index:9999"></div>
<input name='search_url' id="search_url" type='hidden' value='{$SEARCH}'/>
</form>
{if  $MODULE eq 'Contacts' or $MODULE eq 'Accounts' or $MODULE eq 'Campaigns' or $MODULE eq 'Vendors'}
	<form name="SendMail" style="float:left;"><div id="sendmail_cont" style="z-Index:9999999999999;position:absolute;"></div></form>
{/if}
{include file='EditViewBottom.tpl'}

<div id="ShowSetUeryScopdiv" class="D_pop_box" style="display:none;position:absolute;left:33%;top:35%;width:1200px" ></div>
<div id="tempdiv" style="display:block;top:200px;"></div>
<div id="changepw" class="D_pop_box LdPopWidth350px" style="display:none;position:absolute;left:350px;top:200px;z-index:1102;"></div>
<script language="JavaScript" type="text/javascript">
//ld('#mainTablenrth').css('width',document.body.clientWidth-235);{*出差申请单、费用报销单页面计算产品div宽度*}
var opmode = "{$OP_MODE}";
var boolmode = "{$MODULE|@get_file_address:'ShowServiceContractsDetail'}";
var module = '{$MODULE}';
var accountid = "{$ACCOUNTID}";
var contactid = '{$CONTACTID}';
var mode = "{$MODE}";
var bestatus = "{$BESTATUS}";{* 客户和联系人关联字段信息 状态*}
var befields = '{$BEMODULEFIELDS}';{* 当前编辑页  客户、联系人的模块ID和数据ID *}
var currency_id = "{$CURRENCYID}";
var editviewinfojsonobj='{$FIELDINFOJSON}';
var validatasavejsonobj='{$VALIDATASAVE}';
var validatasaverulejsonobj='{$VALIDATASAVERULE}';
var version_account = '{$VERSION_ACCOUNT}';
var utrc_type = '{$UTRC_TYPE}';
var ALLSETROLEDATAPROFILE="{$ALLSETROLEDATAPROFILE}";
var USER_MODE="{$USER_MODE}";
cur_PageInfo.pagetype.push('editview');
cur_PageInfo.modulenames.push(module);
cur_PageInfo.pagemode.push("wholepage");
PageRecordPopupobj.fieldname="{$VALIDATION_DATA_FIELDNAME}";
PageRecordPopupobj.fieldlabel="{$VALIDATION_DATA_FIELDLABEL}";
PageRecordPopupobj.fielddatatype="{$VALIDATION_DATA_FIELDDATATYPE}";
var COLUMN_FIELDS_VALUEobj='';
if(editviewinfojsonobj!=null&&editviewinfojsonobj!=undefined&&editviewinfojsonobj!='')
 {ldelim}
   var fieldinfoobjs=  eval('('+ editviewinfojsonobj +')')?eval('('+ editviewinfojsonobj +')'):JSON.parse(editviewinfojsonobj);
   
    PageRecordPopupobj.fields=fieldinfoobjs;
    
     var COLUMN_FIELDS_VALUE='{$COLUMN_FIELDS_VALUE}';//界面值
     
   if(COLUMN_FIELDS_VALUE!=null&&COLUMN_FIELDS_VALUE!=undefined&&COLUMN_FIELDS_VALUE!='')
   {ldelim}
         COLUMN_FIELDS_VALUE=COLUMN_FIELDS_VALUE.replace(/(\r\n)|(\n)/g,'<br>');//备注等文本域换行
         var COLUMN_FIELDS_VALUEobj= eval('('+ COLUMN_FIELDS_VALUE +')')?eval('('+ COLUMN_FIELDS_VALUE +')'):JSON.parse(COLUMN_FIELDS_VALUE);
    {rdelim}
 {rdelim}
 var detailfieldjson='{$TABDETAILFIELDS}';
 if(detailfieldjson!=null&&detailfieldjson!=undefined&&detailfieldjson!='')
 {ldelim}
   var detailfieldinfoobjs=  eval('('+ detailfieldjson +')')?eval('('+ detailfieldjson +')'):JSON.parse(detailfieldjson);
   
    PageRecordPopupobj.detailfields=detailfieldinfoobjs;
 {rdelim}
 
 
 if(validatasavejsonobj!=null&&validatasavejsonobj!=undefined&&validatasavejsonobj!='')
 {ldelim}
   var validatasaveobjs=  eval('('+ validatasavejsonobj +')')?eval('('+ validatasavejsonobj +')'):JSON.parse(validatasavejsonobj);
   
    PageRecordPopupobj.validatasave=validatasaveobjs;
 {rdelim}

  if(validatasaverulejsonobj!=null&&validatasaverulejsonobj!=undefined&&validatasaverulejsonobj!='')
 {ldelim}
   var validatasaveruleobjs=  eval('('+ validatasaverulejsonobj +')')?eval('('+ validatasaverulejsonobj +')'):JSON.parse(validatasaverulejsonobj);
   
    PageRecordPopupobj.validatasaverule=validatasaveruleobjs;
 {rdelim}
 PageRecordPopupobj.column_fields_value=COLUMN_FIELDS_VALUEobj;
PageRecordPopupobj.type='moduledetailpage';
PageRecordPopupobj.record="{$ID}";
PageRecordPopupobj.list_link_field='{$MODULELINKFIELD}';
PageRecordPopupobj.smownercolumnname='{$SMOWNERCOLUMNNAME}';
PageRecordPopupobj.smownercolumnname_value = '';
PageRecordPopupobj.timeCount=0;
PageRecordPopupobj.divid='DetailContent';
PageRecordPopupobj.setTimeCount();
var helpdesk_log = '{$HELPDESKLOG}';
var piclistdenpencyfields='{$PICKLISTDEPENCYFIELDS}';

PageRecordPopupobj.picklistdepencyfields="";
if(piclistdenpencyfields!="")
    PageRecordPopupobj.picklistdepencyfields=eval('('+ piclistdenpencyfields +')');

PageRecordPopupobj.picklistdepency=eval('('+ '{$PICKIST_DEPENDENCY_DATASOURCE}' +')')?eval('('+ '{$PICKIST_DEPENDENCY_DATASOURCE}' +')'):JSON.parse('{$PICKIST_DEPENDENCY_DATASOURCE}');
var jsonpicklistcontent='{$PICKLISTCONTENT}';

PageRecordPopupobj.picklistcontent=eval('('+ jsonpicklistcontent +')')?eval('('+ jsonpicklistcontent +')'):JSON.parse(jsonpicklistcontent);
PageRecordPopupobj.isDuplicate='{$isDuplicate}';

{literal}
PageRecordPopupobj.setTimeCount=function(){
    
    setInterval(function(){ PageRecordPopupobj.timeCount+=3;},3000);
}
var fieldinfoobjs=undefined;


//联合技术MER特殊控制:根据费用类别控制显示隐藏列
if(module == 'Expense' && version_account == 'utrc'){
	changeDetailColumn(utrc_type);

}
window.onload = function(){
        PageRecordPopupobj.setTimeCount();
    /*editor:gyq_06 reason:修改保存按钮，实例化调用Accounts.js的jsAccountsDesk类*/
	if(module=='Accounts'){
		new jsAccountsDesk();
	}
  
	fnAddProductTdBtn();
	if(mode != 'edit')
	{
		//新增、编辑，根据币种ID，默认币种类型和银行账户
		if(currency_id >=1&&PageRecordPopupobj.isDuplicate!='yes')
		{
		  //复制不需要重新初始化
          //bug:38109
			ChangeBankAccount(currency_id,module);
		}
	}
    if(module=='HelpDesk'){
        getAccountByHelpDeskHistory(accountid,'');
        var jshelpdeskobj=new jsHelpDesk();
    }

	if(opmode == 'edit_view'){
		set_rel_count();
        set_rel_createbtn();
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
    //dropDownBoxSearch(document.EditView);
    //textarea根据内容自动调整大小
    ld('textarea').not('.proName_note').autosize();
}
function onClickShowServiewDetail(accountid,module)
{
    showServiceContractsDetail(accountid,module);
}
function onClickgetAccountsContactsInfo(accountid,contactid,module,mode)
{
    getAccountsContactsInfo(accountid,contactid,module,mode);
}
{/literal}

/*公告选择用户,提醒选择接收人*/
function recipient_name_id_toistr()
{ldelim}
    var selectedColStr = new Array();
    var selectedColStrName = new Array();
    selectedColumnsObj=getObj("selectedAssmablyColumns");
    for (i=0;i<selectedColumnsObj.options.length;i++) 
   {ldelim}
        selectedColStr[i] = selectedColumnsObj.options[i].value;
        selectedColStrName[i] = selectedColumnsObj.options[i].text;
    {rdelim}
    if(document.forms['EditView'].recipient != undefined && document.forms['EditView'].recipient_name != undefined)
    {ldelim}
        document.forms['EditView'].recipient.value = selectedColStr.join(',');
        document.forms['EditView'].recipient_name.value = selectedColStrName.join(',');
    {rdelim}
    if(document.forms['EditView'].recieverid != undefined && document.forms['EditView'].txt_select_user != undefined)
    {ldelim}
        document.forms['EditView'].recieverid.value = selectedColStr.join(',');
        document.forms['EditView'].txt_select_user.value = selectedColStrName.join(',');
    {rdelim}
    fninvshnew('recipient_namediv');
{rdelim}    
var ProductImages=new Array();
var count=0;
function delRowEmt(imagename)
{ldelim}
    
		ProductImages[count++]=imagename;
		multi_selector.current_element.disabled = false;
		multi_selector.count--;
{rdelim}
function displaydeleted()
{ldelim}
if(ProductImages.length > 0)
			document.EditView.del_file_list.value=ProductImages.join('###');
{rdelim}  

var jsonfieldrulenamefieldnames='{$jsonFieldRuleFieldNames}';
if(jsonfieldrulenamefieldnames!=null&&jsonfieldrulenamefieldnames!=undefined)
{ldelim}
    //布局规则的查询字段
    PageRecordPopupobj.fieldrulefieldnames=eval('('+jsonfieldrulenamefieldnames +')')?eval('('+ jsonfieldrulenamefieldnames +')'):JSON.parse(jsonfieldrulenamefieldnames);
{rdelim}

PageRecordPopupobj.fieldname_fields=[];

 
{literal}

PageRecordPopupobj.InitPageValue=function(){
    //InitPageValue:start
        var that=this;
           
          
           if(this.picklistcontent!=""&&this.picklistcontent!=undefined)
            {
               for(var k=0;k<this.picklistcontent.length;k++)
               {
                    if(this.picklistcontent[k].productdetail == undefined || this.picklistcontent[k].productdetail == '')
        			{
        				//下拉框
        				var fieldname=this.picklistcontent[k].fieldname;
        				this.picklistobjarray[this.picklistcontent[k].fieldname]=new cls_picklist(this.picklistcontent[k].fieldname,this.picklistcontent[k].optionvalue);
        				if(this.picklistdepencyfields!=null&&this.picklistdepencyfields!=""&&this.picklistdepencyfields[fieldname]!=undefined)
        				{
        				   
        					this.picklistobjarray[this.picklistcontent[k].fieldname].setparentDependField(this.picklistdepencyfields[fieldname]);
        					//PageRecordPopupobj.picklistobjarray[PageRecordPopupobj.picklistdepencyfields[fieldname]].setchildDependField(picklistcontent[k].fieldname);              
        			     }
        			}
               }
        	   setInventoryPickListContent(jsonpicklistcontent);
            }
            if(this.picklistdepencyfields!=null&&this.picklistdepencyfields!=undefined)
            {
        				ld.each(this.picklistdepencyfields,function(childfieldname,parentfieldname){
        						 if(that.picklistobjarray[parentfieldname] != undefined){
        							that.picklistobjarray[parentfieldname].setchildDependField(childfieldname);
        						}
                             });         
            }
            
                    
        setFileUploadObj();//附件，图片控件初始化
        var length=this.fields.length;
       
         this.oCKeditors=[];
         this.column_fields=[];
        for(var i=0;i<length;i++)
        {
            var fieldinfo=this.fields[i];
            that.fieldname_fields[fieldinfo.fieldname]=fieldinfo;
            that.column_fields[fieldinfo.columnname]=fieldinfo;
            if(this.fields[i].uitype==230)
                this.oCKeditors[this.fields[i].fieldname]=UE.getEditor(this.fields[i].fieldname);
            else if(this.fields[i]['uitype']==251)
            {
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(this.fields[i]['fieldname']);
                
                cls_resetComboxHtmlobj.setComboxObjHtml();
               // break;
            }
        }
      
        var fieldruleobj=new cls_fieldrule(that.fieldrulefieldnames);
        that.fieldruleobj=fieldruleobj;
        fieldruleobj.setEvent();
         var tmpvalues={};
         if(this.column_fields_value!=undefined&&this.column_fields_value!=null)
               ld.each(this.column_fields_value,function(columnname,valueinfo){
                    if(that.column_fields[columnname]!=undefined)
                       {
                         var fieldname=that.column_fields[columnname].fieldname;
                        tmpvalues[fieldname]=valueinfo[0];
                       }
              })
       
      fieldruleobj.setValues(tmpvalues);
        //fieldruleobj.setValues(that.column_fields_value);
    //InitPageValue:end 
}
PageRecordPopupobj.InitPageValue();
function set_password(form) {
/**
 * @by andy
 * @reason 0008213: 非管理员：个人设置界面，修改密码，当用户的旧密码为空时，无法修改密码系统提示：请输入您的旧密码!
 * @date 20140527
 * @others NONE
*/
    /*
	if (form.is_admin.value == 1 && trim(form.old_password.value) == "") {
		alert(arrJsPopLabel['ENTEROLDPASSWORD']);
		return false;
	}*/
	if (trim(form.new_password.value) == "") {
    var confirm_str = arrJsPopLabel['ENTERNEWPASSWORD'];
    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
	if (trim(form.confirm_new_password.value) == "") {
    var confirm_str = arrJsPopLabel['ENTERNEWPASSWORDAGAIN'];
    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
    var formname=document.forms['ChangePassword'];
	if (trim(form.new_password.value) == trim(form.confirm_new_password.value)) {
        var old_pwd=document.getElementById("old_password").value;
        var new_pwd=document.getElementById("new_password").value;
        var confirm_new_password=document.getElementById("confirm_new_password").value;
        var recordid=document.EditView.record.value;
		var tmpurlstring = 'module=Users&action=UsersAjax&file=SavePwd&oldpwd='+encodeURIComponent(old_pwd)+'&newpwd='+encodeURIComponent(new_pwd)+'&confirmpwd='+encodeURIComponent(confirm_new_password)+'&userid='+recordid;
		ldAjaxHtml('index.php',tmpurlstring,function (ajaxhtml){
			if(ajaxhtml.indexOf('SUCCESS') > -1)
			{
				window.location.reload();
				return true;
			}
			else {
				puyoungJS_DialogBox.unblock();
				var results=ajaxhtml.split('$$error$$');
				RemindsMsg("","LdPopWidth400px","","yes","",results[1]);
				return false;
			}
		});
		return false;
       
	}
	else {
    var confirm_str = arrJsPopLabel['PASSWORDINCONSISTENT'];
    RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	}
}

{/literal}          
</script>   