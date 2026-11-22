<script type="text/javascript">
    AjaxJSPage("DetailViewTab_js",'include/js/DetailViewTab.js');
    AjaxJSPage("dtlviewajax_js",'include/js/dtlviewajax.js');
    var modulejsfile="include/js/modules/{$MODULE}/{$MODULE}.js";
    getJsScript(modulejsfile,function(){
    })
    getJsScript('include/js/modules/ModComments/ModCommentsCommon.js',function(){
    })
    getJsScript('include/js/SystemPopup/PrintPopup.js',function(){
    })
    getJsScript('include/js/modules/XlsImportNew/XlsImportRelatedNew_HaiGe.js',function(){
    })
</script>
<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.autosize.min.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/OA.js?version={$GLOBALMINVERSION}"></script>
 
{if $MODULE == "SocialPromotion"}
    {*@edit:dong @date:2020/7/10 @reason: 社交推广 一键复制插件*}
    {*<script language="javascript" type="text/javascript" src="{$JSURL}include/js/clipboard.min.js?v={$GLOBALMINVERSION}"></script>*}
    {*@edit:dong @date:2020/11/03 @reason: bug 0043104 用下面加载*}
    <script type="text/javascript">
        AjaxJSPage("clipboard_min",'include/js/clipboard.min.js');
    </script>
    <script language="javascript" type="text/javascript" src="{$JSURL}include/js/viewer.min.js?v={$GLOBALMINVERSION}"></script>
{elseif $MODULE == 'Users'}
    {* //zkt 0046431: （https://81mis.com/kfbcrm/index.php?pageto_module=Accounts&pageto_action=index [^]）问题：客户模块 客户模块-客户名称-销售负责人-角色权限有超链接的点不了*}
    <script type="text/javascript">AjaxJSPage("ProfileDetailClick",'include/js/modules/Settings/Roles.js');</script>
{/if}
 
<link rel="stylesheet" type="text/css" media="all" href="{$CSSURL}themes/softed/Paymentplan.css">
{*editor:gyqX161108 gyq_11CH*}
{if $MODULE eq 'Contacts' ||$MODULE eq 'Accounts'}
	<script language="javascript" type="text/javascript" src="uploaddify/jquery.uploadify.min.js"></script>
	<link rel="stylesheet" type="text/css" href="uploaddify/uploadify.css">
{elseif $MODULE eq 'Users'}
    <script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Users/Users.js?version={$GLOBALMINVERSION}"></script>
{/if}
<span id="crmspanid" name="crmspanid" class="ld-detail-edit-small" style="display:none;" onmouseover="New_show('crmspanid');">
    <i class="ld-fonticon ld-fonticon-edit" title="{'EDIT'|@getFixedLabel}"></i>
</span>
<div id="convertleaddiv" style="display:block;position:absolute;left:225px;top:150px;"></div>
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
    	<input type="hidden" name="rel_list_count" id="rel_list_count" value="{if $IS_REL_LIST|@is_array}{$IS_REL_LIST|@count}{else}0{/if}">
      	<td class="Tdcenter" valign="top">
      		<div id="DetailContent" name="DetailContent" class="ld-detail-content {if $detailviewuitype eq '2'}ld-detail-content-bgcolor{elseif $detailviewuitype eq '1'}ld-detail-content-line{else}ld-detail-content-bgcolor{/if}">
                <table width="100%" border="0" cellspacing="0" cellpadding="0">
      				<tr>
      					<td class="left">
                			<div class="DivC" id="div_pagerecord" name="div_pagerecord">
                                {if $IS_REL_LIST|@is_array && $IS_REL_LIST|@count > 0}
           				            {include file="DetailView/DetailButtons.tpl"}
                                    {*wyt 230116 BUG0060734 kfbcrm 裂变文章--开启关键信息栏不生效 230223 BUG0061695*}
                                    {*XUQIU20240223-01 增加预制模块：人事档案 人事档案没有预制相关信息栏，但需要显示关键字区域*}
                                {elseif $MODULE eq 'Articles' || $MODULE eq 'Reminds' || $MODULE eq 'Personnelfile'}
                                    <div id="related_keywords_field" {if $VIEWKEYWORDS eq 0 && $KEYWORDSHTML neq ''} style="padding-bottom: 8px;background: rgb(230, 233, 240);"{/if}>
                                        {if $VIEWKEYWORDS eq 0 && $KEYWORDSHTML neq ''}
                                            {$KEYWORDSHTML}
                                        {/if}
                                    </div>
                                {/if}
              					<div class="DivCTable">
                                    {*{include file="DetailView/PopupDetailButton.tpl"}*}
        							{if $MODULEADVANCE['is_enable'] eq 'yes'}
        								<div name="advance_stage_div" class="advance_stage_div">{include file="DetailView/PopupAdvance.tpl"}</div>
        							{/if}
        								{include file="DetailView/DetailTable.tpl"}
              					</div>
                				<!-- detail info exit -->
                			</div>
                            </form>
                        </td>
          			</tr>
          		</table>
      		</div>      
            <!-- related -->
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
<div id="SMSedit" class="D_pop_box LdPopWidth300px" style="position: absolute;  z-index: 9999999; left: 575px; top: 250px;display:none;">
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
        <div id="SMSedit" class="D_pop_box LdPopWidth300px" style="position: absolute;  z-index: 9999999; left: 40%; top: 250px;display:none;">
    {elseif $MODULE eq 'Contacts'}
        <div id="SMSedit" class="D_pop_box LdPopWidth300px" style="position: absolute;  z-index: 9999999; left: 40%; top: 250px;display:none;">
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
<input type="hidden" name="balanceaccountinout" value="{$MODBALANCESTR}"/>
<!-- DIV Edit -->

<!--修改负责人-->
<div id="smowneredit" class="D_pop_box LdPopWidth350px" style="display:none;">
    <div id="smowneredit_form_div"></div>
</div>
<!--批量分配-->
<div id="massallocate" class="D_pop_box LdPopWidth350px" style="display:none;">
    <div id="massallocate_form_div"></div>
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
<div id="ShowSetUeryScopdiv" class="D_pop_box" style="display:none;position:absolute;left:33%;top:35%;width:1200px" ></div>
<div id="tempdiv" style="display:block;top:200px;"></div>
<div id="changepw" class="D_pop_box LdPopWidth350px" style="display:none;position:absolute;left:350px;top:200px;z-index:1102;"></div>
{if $MODULE eq 'HelpDesk' && $SENDTYPE eq 'yes' && ($IS_SEND eq 1 || $IS_SEND eq 2)}
	<script type="text/javascript">
		CreateSendForm('{$MODULE}',{$ID});
	</script>
{/if}

<script>
    var version_account = '{$VERSION_ACCOUNT}';
    var relcount = "{$smarty.foreach.relatedfor.iteration}";
    //if(relcount > 0)
    //	set_rel_count();
    //set_rel_createbtn();//获取相关信息数量
    var accountset = '{$ACCOUNTSET}';//公海操作日志
    var utrc_type = '{$UTRC_TYPE}';
    var select_servicedetail = '{$SELECTSERVICEDETAIL}';//客户和服务单是否显示服务信息 1显示 0不显示
    fromcalendar='{$FROMCALENDAR}';
    var helpdesk_log = '{$HELPDESKLOG}';
    //reason:服务小程序增加评价  2019/6/18 13:52 ID1000512
    var communicate = '{$COMMUNICATE}';
    var evaluate = '{$EVALUATE}';
    //var isapprovemod = '{$APPROVEMOD}';//是否开启审批
</script>
<!-- added for validation -->
</td>
</tr>
</table>

<script>
var ViewallCooperativeWork='no';
var gVTModule = '{$smarty.request.module|@vtlib_purify}';

{literal}
//编辑价格表中选择的产品价格弹出层
function editProductListPrice(id,pbid,price){
    ldAjax("index.php?action=ProductsAjax&file=EditListPrice&module=Products&return_module=PriceBooks&listprice="+price,{},function(data){
        
        var popupobj=  CrmPopup.load(data.result.title,gotoUpdateListPrice,"","400","Products","",data.result.oktext,"",data.result.canceltext);
        popupobj.id=id;
        popupobj.pbid=pbid;
        popupobj.price=price;
        popupobj.show(data.result.content);
        
        DelProgressObjs();
    })
}

//产品价格弹出层保存
function gotoUpdateListPrice(){
    var popupobj=CrmPopup.getPopupObj('last');
    var lastprevpopupobj=CrmPopup.getPopupObj('lastprev');
    var id=popupobj.id;//选择产品id
    var proid=popupobj.id;//选择产品id
    var pbid=popupobj.pbid;//价格表ID
    // $("status").style.display="inline";
    // $("roleLay").style.display = "none";
    puyoungJS_DialogBox.unblock();
    var listprice=$("list_price").value;
    var url = 'index.php?module=Products&action=ProductsAjax&file=UpdateListPrice&ajax=true&return_action=CallRelatedList&return_module=PriceBooks&record='+id+'&pricebook_id='+pbid+'&product_id='+proid+'&list_price='+listprice;
    ldAjaxNoProgress(url,'',function (data) {
        popupobj.CancelEvent();
        DetailViewRelation.searchByPopupobj(lastprevpopupobj);
    });
}
gotoUpdateListPrice.funname='gotoUpdateListPrice';
{/literal}
</script>