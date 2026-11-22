<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.autosize.min.js"></script>

<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/dtlviewajax.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/OA.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/advancefilter.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/SystemPopup/ListHigherSearchPopup.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/SystemPopup/PrintPopup.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="{$CSSURL}themes/softed/Paymentplan.css">
{*editor:gyqX161108 gyq_11CH*}

{if $MODULE eq 'Contacts' ||$MODULE eq 'Accounts'}
	<script language="javascript" type="text/javascript" src="uploaddify/jquery.uploadify.min.js"></script>
	<link rel="stylesheet" type="text/css" href="uploaddify/uploadify.css">
{/if}
<span id="crmspanid" name="crmspanid" class="ld-detail-edit-small" style="display:none;" onmouseover="show('crmspanid');">
	<i class="ld-fonticon ld-fonticon-edit" title="{'EDIT'|@getFixedLabel}"></i>
</span>
<div id="convertleaddiv" style="display:block;position:absolute;left:225px;top:150px;"></div>
<script>
// ld('body').css('overflow','hidden');
var gVTModule = '{$smarty.request.module|@vtlib_purify}';
{*var  hiddenlabel="{'HIDDEN'|@getFixedLabel}";*}
{*var showLabel="{'DISPLAY'|@getFixedLabel}";*}

    var tmpstr='{$DATETIMESTR}';
     var datetimestr=  eval('('+ tmpstr +')')?eval('('+ tmpstr +')'):JSON.parse(tmpstr);
{literal}
function showHideStatus(sId,anchorImgId)
{
   
	var popupobj=CrmPopup.getPopupObj("last");
    oObj = ld("#"+popupobj.divid+" [name="+sId+"]").get(0);
    //edit: xll 2023/03/30 BUG0062614 kfbcrm 采购订单---产品分录---查看界面无法收起
    if(sId == 'productsStaus'){
        Obj = ld("#"+popupobj.divid+" [name='"+sname+"']");
        if(Obj.length < 1)
            Obj = ld("#"+popupobj.divid+" #"+sname);
        oObj = Obj.get(0);
    }
	if(oObj.style.display == 'block')
	{
		oObj.style.display = 'none';
		if(anchorImgId !=null){
			document.getElementById(anchorImgId).className = 'On';
			//@edit:ljj,2023-08-10,reason:BUG0070737 kfbtest-销售线索-单据详情页面，区块展开提示浮显信息改成展开，且改成黑色的tip
			document.getElementById(anchorImgId).closest('.DivCName').addClass('tip-items-list');
			document.getElementById(anchorImgId).closest('.DivCName').attr('data-direction', 'left');
			document.getElementById(anchorImgId).closest('.DivCName').attr('data-type', 'position');
			document.getElementById(anchorImgId).closest('.DivCName').attr('data-tip', arrJsPopLabel['EXPANSION']);
			tooltip("#"+popupobj.divid+" .tip-items-list", {transition: true, time: 200});

			var modcomment_highselectobj = anchorobj.closest('.DivCName').find('#modcomment_highselect');
			if (modcomment_highselectobj.length > 0){
				anchorobj.closest('.DivCName').css('padding-right','10px');
				modcomment_highselectobj.css('padding-right','0px');
			}
		}
	}
	else
	{
		oObj.style.display = 'block';
		if(anchorImgId !=null){
			document.getElementById(anchorImgId).className = '';
			//wym BUG0071812 单据查看详情界面，鼠标放在区块名称上，没有浮显“展开”和“收起”提示字样 
			document.getElementById(anchorImgId).closest('.DivCName').attr('data-tip', arrJsPopLabel['COLLAPSE']);

			var modcomment_highselectobj = anchorobj.closest('.DivCName').find('#modcomment_highselect');
			if (modcomment_highselectobj.length > 0){
				modcomment_highselectobj.css('padding-right','0px');
				anchorobj.closest('.DivCName').css('padding-right','10px');
			}
		}
	}
}
<!-- End Of Code modified by SAKTI on 10th Apr, 2008 -->

<!-- Start of code added by SAKTI on 16th Jun, 2008 -->
function setCoOrdinate(elemId){
	oBtnObj = document.getElementById(elemId);
	var tagName = document.getElementById('lstRecordLayout');
	leftpos  = 0;
	toppos = 0;
	aTag = oBtnObj;
	do{
	  leftpos  += aTag.offsetLeft;
	  toppos += aTag.offsetTop;
	} while(aTag = aTag.offsetParent);

	tagName.style.top= toppos + 20 + 'px';
	tagName.style.left= leftpos - 276 + 'px';
}

function getListOfRecords(obj, sModule, iId,sParentTab)
{
		new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody: 'module=Users&action=getListOfRecords&ajax=true&CurModule='+sModule+'&CurRecordId='+iId+'&CurParentTab='+sParentTab,
			onComplete: function(response) {
				var results = response.responseText.split('###SUCCESS###');
				$("lstRecordLayout").innerHTML = trim(results[1]);
                
				Lay = 'lstRecordLayout';
                fnvshobj(obj,'lstRecordLayout');
			}
		}
	);
}
{/literal}

//Added to send a file, in Documents module, as an attachment in an email
function sendfile_email()
{ldelim}
	filename = $('dldfilename').value;
	document.DetailView.submit();
	OpenCompose(filename,'Documents');
{rdelim}

window.onload = function()
{ldelim}
    //textarea根据内容自动调整大小
    ld('textarea').not('.proName_note').autosize();
{rdelim}
</script>

{if $MODULE eq 'Leads' or $MODULE eq 'Contacts' or $MODULE eq 'Accounts' or $MODULE eq 'ServiceCharge' or $MODULE eq 'Campaigns' or $MODULE eq 'Vendors'}
	<form name="SendMail" style="float:left;"><div id="sendmail_cont" style="z-Index:9999999999999;position:absolute;"></div></form>
{/if}
<div id="lstRecordLayout" class="LdPop_box LdPopWidth300px" style="display:none;"></div>
<!-- andy 新增单据弹出层 -->
<div id="CreateNewBill" class="D_pop_box LdPopWidth800px" style="display:none;z-Index:9999;position:absolute;">
<div id="CreateNewBill_form_div" ></div>

</div>
<div id="divAccountShare" class="D_pop_box LdPopWidth500px" style="display:none;width:500px;position:absolute;z-index: 9999;"></div>
<div id="divPotentialsShare" class="D_pop_box LdPopWidth500px" style="display:none;width:500px;position:absolute;z-index: 9999;"></div>
<div id="SetRelatedlists_div" class="D_pop_box LdPopWidth600px" style="display:none; position: absolute; z-Index:9999"></div>
<div id="Quicksetactions_div" class="D_pop_box LdPopWidth600px" style="display:none; position: absolute; z-Index:9999"></div>
{if $MODULE eq 'Accounts' || $MODULE eq 'Contacts' }
	{if $MODULE eq 'Accounts'}
		{assign var=address1 value='$MOD.LBL_BILLING_ADDRESS'}
		{assign var=address2 value='$MOD.LBL_SHIPPING_ADDRESS'}
	{/if}
	{if $MODULE eq 'Contacts'}
		{assign var=address1 value='$MOD.LBL_PRIMARY_ADDRESS'}
		{assign var=address2 value='$MOD.LBL_ALTERNATE_ADDRESS'}
	{/if}
	<div id="locateMap" onMouseOut="fninvshnew('locateMap')" onMouseOver="fnvshNrm('locateMap')">
		<table bgcolor="#ffffff" border="0" cellpadding="0" cellspacing="0" width="100%">
			<tr>
				<td>
					{if $MODULE eq 'Accounts'}
						<a href="javascript:;" onClick="fninvshnew('locateMap'); searchMapLocation( 'Main' );" class="calMnu">{$MOD.LBL_BILLING_ADDRESS}</a>
						<a href="javascript:;" onClick="fninvshnew('locateMap'); searchMapLocation( 'Other' );" class="calMnu">{$MOD.LBL_SHIPPING_ADDRESS}</a>
					{/if}
					{if $MODULE eq 'Contacts'}
						<a href="javascript:;" onClick="fninvshnew('locateMap'); searchMapLocation( 'Main' );" class="calMnu">{$MOD.LBL_PRIMARY_ADDRESS}</a>
						<a href="javascript:;" onClick="fninvshnew('locateMap'); searchMapLocation( 'Other' );" class="calMnu">{$MOD.LBL_ALTERNATE_ADDRESS}</a>
					{/if}

				</td>
			</tr>
		</table>
	</div>
{/if}
{assign var='languagetype' value={''|@getLanguageType}}
<div class="List3Box">
	<table width="100%" border="0" cellspacing="0" cellpadding="0" class="List3Cols">
  <tr>
  {*
    by andy
    相关信息都不显示，隐藏此TD
    date 20140623
    *}
	<input type="hidden" name="rel_list_count" id="rel_list_count" value="{$IS_REL_LIST|@count}">
    {if $IS_REL_LIST|@count > 0}
    <td class="TdLeft" valign="top">
    {else}
    <td class="TdLeft" style="display:none;" valign="top">
    {/if} 
    	<div class="DivL">
			<input type='hidden' id='currrelid' value='0'>
      <div class="Title" style="border-bottom: 1px #fff solid;height:37px;line-height: 100%;">
        <a href="javascript:void(0);" style="white-space: normal;">
          <b style="float:left;text-overflow:ellipsis;width:10em;white-space:nowrap;overflow:hidden;padding-left:1px;">{$MODULE|@getTranstab}{'MODULERELSEVANT'|@getTranstab}</b>
          {if ''|@checkCurrentUserIsAdmin eq 'on'}
          <b onclick="SetRelatedlist(this,'{$MODULE}','','');event.stopPropagation();" style="float: right;margin:10px 20px 0 0;" class="icon-homeimg icon-set" title="{'SETTINGS'|@getFixedLabel}"></b>
          {/if}
        </a>
      </div>
				{if $IS_REL_LIST && $IS_REL_LIST != ''}
                    {assign var='isprint' value=0}                
					<ul id="detailrelatedinfo_ul">
                       <li>
                          <a href="javascript:void(0);" onclick='show_detail();'>
          									<span class="Text">
                                                <i class="ico-dot"></i>
          										{$MODULE|@getTranstab}{'details1'|@getFixedLabel}
          									</span>
        								  </a>
                        </li>
					{foreach key=relid item=label from=$IS_REL_LIST name=relatedfor}
						{if  $label == 'BalanceOfAccount'}
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
                          
					    <li>
                        <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' onclick='show_workreport(this,"{$MODULE}","{$ID}","{$relid}");'>
        									<span class="Text">
                                                <i class="ico-dot"></i>
        										{'CooperativeWork'|@getTranstab}
        										<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
        									</span>
        									<span id="rel-coount-{$relid}"></span>
        								</a>
                      </li>
                    {elseif $label == 'SharedUsers'} 
                      <li>
                        <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
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
                        <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
          								<span class="Text">
                                            <i class="ico-dot"></i>
          									{'REDEMPTION'|@getFixedLabel}
          									<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
          								</span>
                          <span class="TextRight">
                            {'LBL_Creates'|@getFixedLabel}
                          </span>
          								<span id="rel-coount-{$relid}"></span>
          							</a>
                      </li> 
                    {elseif $label == 'Jijin_Log_Detail'} 
                      <li>
                        <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
          								<span class="Text">
                                            <i class="ico-dot"></i>
          								  重算日志
          									<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
          								</span>
          								<span id="rel-coount-{$relid}"></span>
          							</a>
                      </li> 
                    {elseif $label == 'ProjectAbstract'}
                      <li>
                        <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
          								<span class="Text">
                                            <i class="ico-dot"></i>
          									{$label|@getFixedLabel}
          									<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
          								</span>
                          <span class="TextRight">
                            {'LBL_Creates'|@getFixedLabel}
                          </span>
          								<span id="rel-coount-{$relid}"></span>
          							</a>
                      </li> 
                    {elseif $label == 'BoughtProduct'}
                      <li>
                        <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
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
                        <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
          								<span class="Text">
                                            <i class="ico-dot"></i>
          									{'BUYPRODUCTQUANTITY'|@getFixedLabel}
          									<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
          								</span>
          								<span id="rel-coount-{$relid}"></span>
          							</a>
                      </li> 
                    {elseif $MODULE eq "DividendOrder" && $label eq "DividendOrder"}
                      <li>
                        <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
          								<span class="Text">
                                            <i class="ico-dot"></i>
          									{'DividendOrder'|@getTranstab}{"DETAIL"|@getFixedLabel}
          									<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
          								</span>
          								<span id="rel-coount-{$relid}"></span>
          							</a>
                      </li> 
                    {elseif $label == 'Kingdeeorders'}
                      <li>
                        <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
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
                    <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
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
                    <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
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
                    <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
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
        								{'LBL_SHOW_ACCOUNT_HIERARCHY'|@getFixedLabel}
        								<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
        							</span>
        							<span id="rel-coount-{$relid}"></span>
      					   	</a>
                  </li>
                 {/if}
                {elseif $label == 'Singin'}
                <!---38007: 客户详情界面，在“相关信息”和“相关信息设置”中“签到记录”显示的标签名称不一致-->
                  <li>
                    <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
        							<span class="Text">
                                        <i class="ico-dot"></i>
        								{'Singin'|@getFixedLabel}
        								<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
        							</span>
        							<span id="rel-coount-{$relid}"></span>
      					   	</a>
                  </li>
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
              {elseif $label == 'Print'}
                    {assign var='isprint' value=1}
			   {else}
							<li>
                            <a href="javascript:void(0);" tag="{$label}" id='rel-list-{$relid}' onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
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
          </ul>
          {/if}
          {include file="DetailView/DetailToolbox.tpl"}
          
		{if $MODULE == 'Accounts' || $MODULE == 'ServiceCharge'}
			<input type="hidden" id="modbalancestr" value="{$MODBALANCESTR}"/>
		{/if}
	</div>
    </td>   
  	<td class="Tdcenter" valign="top">
  		<div id="DetailContent" class="aaaa">
        <table width="100%" border="0" cellspacing="0" cellpadding="0" aling="left">
  				<tr>
  					<td class="left">
        			<div class="DivC" id="div_pagerecord">
        				{include file="DetailView/DetailButtons.tpl"}
      					<div class="DivCTable">
                            {include file="DetailView/DetailTable.tpl"}
      					</div>
        				<!--	detail info exit	-->
        			</div>
              </form>
            </td>
            {*
              by andy
              快捷操作都不显示，隐藏此TD
              date 20140623
            
            
            {if $ACTION_SHOW_NO eq 'yes'}
            <td class="right">
            {else}
            <td class="right" style="display:none;">
            {/if}
          	  <div class="DivR">
                {include file="DetailView/DetailOperation_another.tpl"}
              </div>
  					</td>
            *}
  				</tr>
  			</table>
  		</div>      
        <!--	related	-->
  		<div class="paneldiv">
  			{include file="RelatedListsHidden.tpl"}
  			<div id='RelatedContent' class="detail-coor" style="display:none;">
  			
  			</div>
  			</form>
  		</div>
  	</td>
  </tr> 
</table>
</div>
{if 'yes' eq $DETAILBUTTON.submit.permit}
	 <div id="SubmitApprove" class="D_pop_box LdPopWidth400px" style="display:none;"></div>			 
{/if}
<div id="Createreceivablesforecast" class="D_pop_box LdPopWidth650px" style="display:none;">
<div id="potentialsid_form_div"></div>
</div>
{if 'yes' eq $DETAILBUTTON.approve.permit}
    <div id="ApproveBlocks" class="D_pop_box LdPopWidth650px" style="display:none;"></div>
    <div id="approvelog" class="D_pop_box LdPopWidth800px" style="display:none;z-index:9999;"></div>
    <div id="approvestepresult" class="D_pop_box LdPopWidth800px" style="display:none;z-index:9999;"></div>
{/if}
<div id="cancelApproved" class="D_pop_box LdPopWidth400px" style="display:none;"></div><!-- 反审批 -->
<div id="dingjieSalesdiv" class="D_pop_box LdPopWidth900px" style="display:none;"></div><!-- 鼎捷订单 -->
<!-- DIV Start -->
{if $MODULE eq 'Products'}
<script language="JavaScript" type="text/javascript" src="include/js/modules/Products/Productsslide.js"></script>
<script language="JavaScript" type="text/javascript">Carousel();</script>
{/if}
{if $MODULE eq 'ServiceCharge'}
<div id="SMSedit" class="D_pop_box  LdPopWidth300px" style="position: absolute;  z-index: 9999999; left: 575px; top: 250px;display:none;">
<input type="hidden" name="num_rows_account_detail_sms" id="num_rows_account_detail_sms" value="{$num_rows_account_detail_sms}"/>
<input type="hidden" name="num_rows_contact_detail_sms" id="num_rows_contact_detail_sms" value="{$num_rows_contact_detail_sms}"/>
</div>
<div id="Emailedit" class="D_pop_box LdPopWidth300px" style="position: absolute;  z-index: 9999999; width: 300px; left: 575px; top: 350px;display:none;">
<input type="hidden" name="num_rows_account_detail_email" id="num_rows_account_detail_email" value="{$num_rows_account_detail_email}"/>
<input type="hidden" name="num_rows_contact_detail_email" id="num_rows_contact_detail_email" value="{$num_rows_contact_detail_email}"/>
</div>
{/if}
{if $MODULE eq 'Accounts' || $MODULE eq 'Contacts'}
<input type="hidden" name="num_rows_account_detail_sms" id="num_rows_account_detail_sms" value="{$num_rows_account_detail_sms}"/>
<input type="hidden" name="num_rows_contact_detail_sms" id="num_rows_contact_detail_sms" value="{$num_rows_contact_detail_sms}"/>
    {if $MODULE eq 'Accounts'}
	<input name="buttontype" id="buttontype" type="hidden" value="{$BUTTONTYPE}">
    <div id="SMSedit" class="D_pop_box  LdPopWidth300px" style="position: absolute;  z-index: 9999999; left: 40%; top: 250px;display:none;">
    {elseif $MODULE eq 'Contacts'}
    <div id="SMSedit" class="D_pop_box  LdPopWidth300px" style="position: absolute;  z-index: 9999999; left: 40%; top: 250px;display:none;">
    {/if}
    
    <div class="Title"><img src="themes/softed/tier/icon_loto.png" class="Logo" />
    <span class="Name">{'PLEASESELECTPHONE'|@getFixedLabel}</span>
		<a href="javascript:fninvshnew('SMSedit');">
			<img src="themes/softed/tier/icon_close.png" class="Close" />
		</a>
	</div>	
    <div class="Content_div">
    	<table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td class="Note">
        		<div style="padding:0 10px;">                   
                    <table>
                    <tr>
                    <td>
                    <p>{'PCWYWTSTMTMP'|@getFixedLabel}</p>
                    </td>
                    </tr>
                    {if $MODULE eq 'Accounts'}
                        {$html_account_SMS}
                    {elseif $MODULE eq 'Contacts'}   
                        {$html_contact_SMS}
                    {/if}
                    </table>
                </div>
            </td>
          </tr>
        </table>
    </div>
    <div class="Bottom">
        <div class="Bottom_div width145">
            {if $MODULE eq 'Accounts'}
                <a class="Button_saveGreen width60" id="chose_checkbox_sms_detail_account" onclick="detailview_MassSMS_account();">{'SELECT'|@getFixedLabel}</a><span>&nbsp;</span>
            {else}
                <a class="Button_saveGreen width60" id="chose_checkbox_sms_detail_contact" onclick="detailview_MassSMS_contact();">{'SELECT'|@getFixedLabel}</a><span>&nbsp;</span>
            {/if}
            <a class="Button_backOrg width60" onclick="fninvshnew('SMSedit');puyoungJS_DialogBox.unblock();">{'CANCEL'|@getFixedLabel}</a>
        </div>
    </div>
    </div>
    </div>
{/if}
<div id="createprojecttaskdiv" class="D_pop_box LdPopWidth800px" style="display:none; z-index:10000;"></div>
{if $MODULE eq 'Accounts' || $MODULE eq 'Contacts'}
<input type="hidden" name="num_rows_account_detail_email" id="num_rows_account_detail_email" value="{$num_rows_account_detail_email}"/>
<input type="hidden" name="num_rows_contact_detail_email" id="num_rows_contact_detail_email" value="{$num_rows_contact_detail_email}"/>
    {if $MODULE eq 'Accounts'}
    <div id="Emailedit" class="D_pop_box LdPopWidth300px" style="position: absolute;  z-index: 9999999; width: 300px; left: 40%; top: 250px;display:none;">
    {elseif $MODULE eq 'Contacts'}
    <div id="Emailedit" class="D_pop_box LdPopWidth300px" style="position: absolute;  z-index: 9999999; width: 300px; left: 40%; top: 250px;display:none;">
    {/if}  
    
    
    <div class="Title"><img src="themes/softed/tier/icon_loto.png" class="Logo" />
    <span class="Name">{'PLEASESELECTEMAIL'|@getFixedLabel}</span>
		<a href="javascript:fninvshnew('Emailedit');">
			<img src="themes/softed/tier/icon_close.png" class="Close" />
		</a>
	</div>	
    <div class="Content_div">
    	<table width="100%" border="0" cellspacing="0" cellpadding="0">
          <tr>
            <td class="Note">
        		<div style="padding:0 10px;">
                    <table>
                    <tr>
                        <td>
                            <p>{'PCWYWTSETE'|@getFixedLabel}</p>    
                        </td>
                    </tr>
                    {if $MODULE eq 'Accounts'}
                        {$html_account_email}
                    {elseif $MODULE eq 'Contacts'}   
                        {$html_contact_email}
                    {/if}
                    </table>
                </div>
            </td>
          </tr>
        </table>
    </div>
    <div class="Bottom">
        <div class="Bottom_div width145">
        {if $MODULE eq 'Accounts'}
            <a class="Button_saveGreen width60" id="chose_checkbox_detail_account_email" onclick="detailview_email_account();" >{'SELECT'|@getFixedLabel}</a><span>&nbsp;</span>
        {else}
            <a class="Button_saveGreen width60" id="chose_checkbox_detail_contact_email" onclick="detailview_email_contact();" >{'SELECT'|@getFixedLabel}</a><span>&nbsp;</span>
        {/if}
        <a class="Button_backOrg width60" onclick="fninvshnew('Emailedit');puyoungJS_DialogBox.unblock();">{'CANCEL'|@getFixedLabel}</a>
        </div>
    </div>
    </div>
    </div>
{/if}
{if $MODULE eq 'HelpDesk'}
	<input type="hidden" name="accountid" id="accountid" value="{$ACCOUNTID}"/>
{/if}




</div>

{if $CREATE eq 'yes' && $MODULE eq "Potentials" && $POTENTIALSCREATE eq 'permitted' && $DEPLOYVALUE eq 0}
 <script type="text/javascript">

   /*
  andrew
  20141031
    机会创建回款预测
  */
  NewReceivablesforecast(document.getElementById("createPaymentid"),'Createreceivablesforecast',DetailView.record.value,{$DeployType},2);
 </script>
{/if}
<!-- DIV Edit -->

<!--修改负责人-->
<div id="smowneredit" class="D_pop_box LdPopWidth350px" style="display:none;">
<div id="smowneredit_form_div"></div>
</div>
<!--批量分配-->
<div id="massallocate" class="D_pop_box LdPopWidth350px" style="display:none;">
<div id="massallocate_form_div"></div>
</div>
<!--销售线索推进-->
<div id="leads_mappingfields" class="D_pop_box LdPopWidth350px " style="display:none;">
	<div class="E_pop_tit">
        <strong id="titlename" class="E_ptita">{'ADVANCE'|@getFixedLabel} </strong>
        <a class="E_ptitc" href="javascript:fninvshnew('leads_mappingfields');">
            <img title="{'CLOSE'|@getFixedLabel}" alt="{'CLOSE'|@getFixedLabel}" src="themes/icon/pop_close.png" class="E_ptitcimg">
        </a>
    </div>
    <div id="leads_mappingfields_div" class="D_pop_content" style="max-height:200px;overflow-y:auto;"></div>
	<div class="D_pbtn">
        <input type="button" value="{'CONFIRMED'|@getFixedLabel}" class="D_pbtnok" onclick="">
        <span>&nbsp;</span>
        <input type="button" onclick="fninvshnew('leads_mappingfields');" value="{'CANCEL'|@getFixedLabel}" class="D_pbtncancel">
    </div>
</div>

<div id="actiondiv" class="D_pop_box LdPopWidth900px" style="display:none;">

</div>

<div id="oashowAttendance" class="D_pop_box LdPopWidth350px" style="display:none;z-Index:2147483647;position:absolute;">
   
<div id="oashowAttendance_div" >
    <div class="D_pop_tit">
        <strong class="D_ptita">{'VIEWADDJOBBILLHISTORY'|@getFixedLabel}</strong>
        <a class="D_ptitc" href="javascript:fninvshnew('oashowAttendance');">
        <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"></a>
    </div>
    <div style="margin: 12px 0 0 6px;">
      <input  type="checkbox" checked="" onclick="objoa.showAttencePop(this)" id='oachkAttendance'/>
      {'OASTATISTICSAPPROVE'|@getFixedLabel}
    </div>
    <table class="listEntries D_pop_bod" cellspacing="1" cellpadding="1" border="0">
        <tr class="lvtColData">
          <td style="width:60%;">{'OATOTALOVERTIME'|@getFixedLabel}</td>
          <td style="width:40%;" align="center" id='oatotalovertimetd'></td>
        </tr>
        <tr class="lvtColDataBj">
          <td>{'OATOTALDAYSOFF'|@getFixedLabel}</td>
          <td align="center" id='oatotaldaysofftd'></td>
        </tr>
        <tr class="lvtColData">
          <td>{'OAREMAININGOVERTIME'|@getFixedLabel}</td>
          <td align="center" id='oaremainingovertimetd'></td>
        </tr>
        <tr class="lvtColDataBj">
          <td>{'OATOTALANNUALLEAVE'|@getFixedLabel}</td>
          <td align="center" id="oatotalannualleavetd"></td>
        </tr>
        <tr class="lvtColData">
          <td>{'OAUSEDANNUALLEAVE'|@getFixedLabel}</td>
          <td align="center" id="oausedannualleavetd"></td>
        </tr>
        <tr class="lvtColDataBj">
          <td>{'OAREMAININGANNUALLEAVE'|@getFixedLabel}</td>
          <td align="center" id='oaremainingannualleavetd'></td>
        </tr>
    </table>
    <div style="margin: 10px 0 9px 10px;">
      <a id='oaviewdetailattendance' target="_blank" href="CustomReport/index.php?stimulsoft_client_key=ViewerFx&stimulsoft_report_key=oa_attendance_statistics.mrt&default_report=1">{'VIEWATTENDANCEDETAILINFO'|@getFixedlabel}</a>
    </div>
</div>

</div>
<div id="divSendInform" class="D_pop_box LdPopWidth600px" style="display:none;">
    <div id="divSendInform_div" ></div>
</div>

<div id="divSendInform_content" class="D_pop_box LdPopWidth900px" style="display:none;z-index:100000;">
    <div id="divSendInform_content_div"></div>
</div>
<div id="camaigns_account_status" class="D_pop_box LdPopWidth450px" style="display:none;z-index:100000;">
</div>
<!--中间 end-->
<div id="ShowSetUeryScopdiv" class="D_pop_box" style="display:none;position:absolute;left:33%;top:35%;width:1100px" ></div>
<div id="tempdiv" style="display:block;top:200px;"></div>
<div id="changepw" class="D_pop_box LdPopWidth350px" style="display:none;position:absolute;left:350px;top:200px;z-index:1102;"></div>
{if $MODULE eq 'HelpDesk' && $SENDTYPE eq 'yes' && ($IS_SEND eq 1 || $IS_SEND eq 2)}
	<script type="text/javascript">
		CreateSendForm('{$MODULE}',{$ID});
	</script>
{/if}
<script type="text/javascript">
	var kiserror = "{$KISERROR}";
	if(kiserror != '')
	{ldelim}
  RemindsMsg("","LdPopWidth400px","","yes","",kiserror);
	{rdelim}
 </script>
<script>
    var validatasavejsonobj='{$VALIDATASAVE}';
	var version_account = '{$VERSION_ACCOUNT}';
    var detailviewinfojsonobj='{$FIELDINFOJSON}';
    var COLUMN_FIELDS_VALUE='{$COLUMN_FIELDS_VALUE}';//界面值
    COLUMN_FIELDS_VALUE=COLUMN_FIELDS_VALUE.replace(/(\r\n)|(\n)/g,'<br>');//备注等文本域换行
  var fieldname = new Array({$VALIDATION_DATA_FIELDNAME});
  var fieldlabel = new Array({$VALIDATION_DATA_FIELDLABEL});
  var fielddatatype = new Array({$VALIDATION_DATA_FIELDDATATYPE});
  var PageRecordPopupobj=PageRecordPopup.load(modulename);
    PageRecordPopupobj.module='{$MODULE}';
  PageRecordPopupobj.fieldname="{$VALIDATION_DATA_FIELDNAME}";
  PageRecordPopupobj.fieldlabel="{$VALIDATION_DATA_FIELDLABEL}";
  PageRecordPopupobj.fielddatatype="{$VALIDATION_DATA_FIELDDATATYPE};"
  PageRecordPopupobj.helpdesk_log=helpdesk_log;
  PageRecordPopupobj.divid='div_pagerecord';
  PageRecordPopupobj.setTimeCount();
  PageRecordPopupobj.type="detailviewpage";
  PageRecordPopupobj.record="{$ID}";
  var PICKIST_DEPENDENCY_DATASOURCE='{$PICKIST_DEPENDENCY_DATASOURCE}';
  PICKIST_DEPENDENCY_DATASOURCE=PICKIST_DEPENDENCY_DATASOURCE.replace(/\'/g, "\\'") ;
 
     try{
         PageRecordPopupobj.picklistdepency=eval('('+ PICKIST_DEPENDENCY_DATASOURCE +')')?eval('('+ PICKIST_DEPENDENCY_DATASOURCE +')'):JSON.parse(PICKIST_DEPENDENCY_DATASOURCE);
     }
     catch(ex)
     {
        
     }
  PageRecordPopupobj.list_link_field='{$MODULELINKFIELD}';
  PageRecordPopupobj.smownercolumnname='{$SMOWNERCOLUMNNAME}';
  PageRecordPopupobj.smownercolumnname_value = '';
  if(validatasavejsonobj!=null&&validatasavejsonobj!=undefined&&validatasavejsonobj!='')
 {ldelim}

 validatasavejsonobj=validatasavejsonobj.replace(/\\/g,"#####");
  
   var validatasaveobjs=  eval('('+ validatasavejsonobj +')')?eval('('+ validatasavejsonobj +')'):JSON.parse(validatasavejsonobj);
   
    PageRecordPopupobj.validatasave=validatasaveobjs;
    
   
 {rdelim}
   var detailfieldjson='{$TABDETAILFIELDS}';
 if(detailfieldjson!=null&&detailfieldjson!=undefined&&detailfieldjson!='')
 {ldelim}
   var detailfieldinfoobjs=  eval('('+ detailfieldjson +')')?eval('('+ detailfieldjson +')'):JSON.parse(detailfieldjson);
   
    PageRecordPopupobj.detailfields=detailfieldinfoobjs;
 {rdelim}
  var piclistdenpencyfields='{$PICKLISTDEPENCYFIELDS}';
   if(detailviewinfojsonobj!=null&&detailviewinfojsonobj!=undefined&&detailviewinfojsonobj!='')
  {
       var fieldinfoobjs=  eval('('+ detailviewinfojsonobj +')')?eval('('+ detailviewinfojsonobj +')'):JSON.parse(detailviewinfojsonobj);
       var COLUMN_FIELDS_VALUEobj= eval('('+ COLUMN_FIELDS_VALUE +')')?eval('('+ COLUMN_FIELDS_VALUE +')'):JSON.parse(COLUMN_FIELDS_VALUE);
  }
  PageRecordPopupobj.fields=fieldinfoobjs;
  PageRecordPopupobj.column_fields_value=COLUMN_FIELDS_VALUEobj;
  PageRecordPopupobj.picklistdepencyfields="";
  if(piclistdenpencyfields!="")
        PageRecordPopupobj.picklistdepencyfields=eval('('+ piclistdenpencyfields +')')?eval('('+ piclistdenpencyfields+')'):JSON.parse(piclistdenpencyfields);
          

  var jsonpicklistcontent='{$PICKLISTCONTENT}';
   
    var picklistcontent=eval('('+ jsonpicklistcontent +')')?eval('('+ jsonpicklistcontent +')'):JSON.parse(jsonpicklistcontent);
        
    if(picklistcontent!=null&&picklistcontent!=undefined&&picklistcontent!="")
    {ldelim}
        for(var k=0;k<picklistcontent.length;k++)
        {ldelim}
                            //下拉框
             var fieldname=picklistcontent[k].fieldname;
            PageRecordPopupobj.picklistobjarray[picklistcontent[k].fieldname]=new cls_picklist(picklistcontent[k].fieldname,picklistcontent[k].optionvalue);
            if(PageRecordPopupobj.picklistdepencyfields!=null&&PageRecordPopupobj.picklistdepencyfields!=""&&PageRecordPopupobj.picklistdepencyfields[fieldname]!=undefined)
            {ldelim}
               
                PageRecordPopupobj.picklistobjarray[picklistcontent[k].fieldname].setparentDependField(PageRecordPopupobj.picklistdepencyfields[fieldname]);
                //PageRecordPopupobj.picklistobjarray[PageRecordPopupobj.picklistdepencyfields[fieldname]].setchildDependField(picklistcontent[k].fieldname);            
            {rdelim}    
			  
        {rdelim}
    {rdelim}
    if(PageRecordPopupobj.picklistdepencyfields!=null&&PageRecordPopupobj.picklistdepencyfields[fieldname]!=undefined)
    {ldelim}
				ld.each(PageRecordPopupobj.picklistdepencyfields,function(childfieldname,parentfieldname){ldelim}
						 if(PageRecordPopupobj.picklistobjarray[parentfieldname] != undefined){ldelim}
							PageRecordPopupobj.picklistobjarray[parentfieldname].setchildDependField(childfieldname);
						 {rdelim}
                     {rdelim});         
    {rdelim}  
var jsonfieldrulenamefieldnames='{$jsonFieldRuleFieldNames}';

if(jsonfieldrulenamefieldnames!=null&&jsonfieldrulenamefieldnames!=undefined&&jsonfieldrulenamefieldnames!='')
{ldelim}
    //布局规则的查询字段
    PageRecordPopupobj.fieldrulefieldnames=eval('('+jsonfieldrulenamefieldnames +')')?eval('('+ jsonfieldrulenamefieldnames +')'):JSON.parse(jsonfieldrulenamefieldnames);
{rdelim}

var relcount = "{$smarty.foreach.relatedfor.iteration}";
if(relcount > 0)
	set_rel_count();
set_rel_createbtn();
/**
 * 检查是否是iFrame嵌套页面
 * @project 天润呼叫中心集成
 * @author Tujt 2014-05-15
 */
IsFrameElement();




var modulename = '{$MODULE}';
var helpdesk_log = '{$HELPDESKLOG}';
//reason:服务小程序增加评价  2019/6/18 13:52 ID1000512
var communicate = '{$COMMUNICATE}';
var evaluate = '{$EVALUATE}';
var recordid = '{$ID}';
var accountset = '{$ACCOUNTSET}';//公海操作日志
var isapprovemod = '{$APPROVEMOD}';//是否开启审批
var accountid = '{$ACCOUNTID}';
var contactid = '{$CONTACTID}';
var bestatus = '{$BESTATUS}';
var fieldinfoobjs ='';
var version_account = '{$VERSION_ACCOUNT}';
var utrc_type = '{$UTRC_TYPE}';
var select_servicedetail = '{$SELECTSERVICEDETAIL}';//客户和服务单是否显示服务信息 1显示 0不显示
fromcalendar='{$FROMCALENDAR}';

window.ready = readylistBind();
//编号重复的提示
setdupBillNoTip('{$MODULEBILLNOTIP}',PageRecordPopupobj.fields);
{literal}
PageRecordPopupobj.InitPageValue=function()
{
    this.fieldname_fields=[];
    this.column_fields=[];
    var that=this;
    ld.each(this.fields,function(index,fieldinfo){
        var fieldname=fieldinfo.fieldname;
    
        that.fieldname_fields[fieldname]=fieldinfo;
        
        that.column_fields[fieldinfo.columnname]=fieldinfo;
        if(fieldinfo.uitype==251)
        {
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml(fieldinfo.fieldname);
            cls_resetComboxHtmlobj.setComboxObjHtml();
        }
        
    })

     var fieldruleobj=new cls_fieldrule(this.fieldrulefieldnames);
     this.fieldruleobj=fieldruleobj;
     fieldruleobj.setEvent();
     var tmpvalues={};
   ld.each(this.column_fields_value,function(columnname,valueinfo){
        if(that.column_fields[columnname]!=undefined)
           {
             var fieldname=that.column_fields[columnname].fieldname;
            tmpvalues[fieldname]=valueinfo[0];
            }
   })
    //console.log(tmpvalues);
     fieldruleobj.setValues(tmpvalues);
}
ld('.detail-img img').on('click',function(){
	 if(document.getElementById("workimgbgDiv") != undefined){
				var my = document.getElementById("workimgbgDiv");
				if (my != null)
					my.parentNode.removeChild(my);
			 }
			var bgObj = document.createElement("div");
			bgObj.setAttribute('id','workimgbgDiv');
			bgObj.style.position="fixed";
			bgObj.style.top="0";
			bgObj.style.background="#000000";
			bgObj.style.color="#FFF";
			//bgObj.style.filter="progid:DXImageTransform.Microsoft.Alpha(style=3,opacity=25,finishOpacity=75";
			//bgObj.style.opacity="0.3";
			bgObj.style.left="0";
			bgObj.style.width='100%';
			bgObj.style.height='100%';
			bgObj.style.zIndex = "10000";
			document.body.appendChild(bgObj);
			//
			var imgbg = '<div style="height: inherit;"><div class="imgbg-header"><span class="panel-visible-h" style="display: block;">×</span></div>';//顶层
			imgbg += '<div class="imgbg-content">';
			imgbg += '<div class="imgbg-left"><a href="javascript:;">‹</a></div>';
			imgbg += '<div class="imgbg-right"><a href="javascript:;">›</a></div>';
			imgbg += '<div class="imgbg-view"></div>';
			imgbg += '</div></div>';
			ld(bgObj).html(imgbg);
		//}
		var img = '<div><img src="'+ld(this).attr('src')+'"></div>';
		ld('#workimgbgDiv .imgbg-content div:eq(2)').html(img);
		var imgobj = ld(this);//记录当前点击的图片对象
		var idx = 0;var imglen = 1;
		//关闭图片显示浮层
		ld('#workimgbgDiv div.imgbg-header span.panel-visible-h').on('click',function(){
			ld('#workimgbgDiv').css('display','none');
		});
		ld('#workimgbgDiv .imgbg-content div:eq(0)').addClass('ui-visibhide');
		ld('#workimgbgDiv .imgbg-content div:eq(1)').addClass('ui-visibhide');
		return false;
})

 setBLockForLink();//附件区块帮助按钮
//联合技术MER特殊控制:根据费用类别控制显示隐藏列
if(modulename == 'Expense' && version_account == 'utrc'){
	changeDetailColumn(utrc_type);

}
function readylistBind(){
    //客户服务单、项目任务、销售机会显示 客户联系人关联字段
    if(bestatus == 'YES')
    {
        getAccountsContactsInfo(accountid,contactid,modulename,'DetailView');
    }
	// 服务信息
    if((modulename == 'Accounts' || modulename == 'HelpDesk') && select_servicedetail == 1){
        showServiceContractsDetail(accountid,modulename);   
    }
     var def=ld.Deferred();
	//评论
    if(modulename!='Reminds'&&modulename!='PublicAnnouncement'&&modulename!='Rate'&&modulename!='PorjectProgress')//edit:can reason:16195: 提醒界面，多了评论区块。
	showModCommentsHtml(modulename,recordid);

    //服务单历史记录
    if(modulename=='HelpDesk' && helpdesk_log == 1){
        getAccountByHelpDeskHistory(accountid,'');
    }
    //editor:gyq_123 reason:显示服务小程序录入的沟通信息  2019/6/18 14:14 ID1000512
    if(communicate === '1'){
        get_communicate_detail(recordid,modulename);
    }
    //editor:gyq_127 reason:服务小程序增加评价  2019/6/26 11:47 ID1000419
    if(modulename=='HelpDesk' && evaluate === '1'){
        get_evaluate_detail(recordid,modulename);
    }
	if(modulename == 'Accounts' || modulename == 'HelpDesk'){
		//getLocationAddress('locationaddress','detail');
	}
}

{/literal}
</script>
<!-- added for validation -->

</td>
</tr>
</table>
<script>
ld(function(){ldelim}
  // setHeight();
  function setHeight(){
    var a = ld('.Header').outerHeight(),//头部高度
        b = ld('#div_pagerecord table:first-child').outerHeight(),//标签+按钮高度
        c = ld('#detailviewtitle_tr').outerHeight(),//标签高度
        s_height = ld(window).height();

    if(a==null) a=0;
    if(b==null) b=0;
    if(c==null) c=0;

    ld('.TdLeft div.DivL').css('height',s_height-a-15);
    ld('#detailrelatedinfo_ul').css('height',s_height-a-c-15);
    ld('#detailrelatedinfo_ul').css('overflow-y','auto');

    ld('#DetailContent').css('height',s_height-a-15);
    ld('.Tdcenter div.DivCTable').css('height',s_height-a-b-15);
    ld('.Tdcenter div.DivCTable').css('overflow-y','auto');
    ld('.Tdcenter div.DivCTable').css('overflow-x','hidden');
  }
{rdelim});
var ViewallCooperativeWork='no';
PageRecordPopupobj.InitPageValue();
PageRecordPopupobj.pagetype='detailview';
</script>