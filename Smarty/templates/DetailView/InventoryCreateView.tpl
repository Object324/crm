{*<!-- module header -->*}
<!--修改编码格式:统一编码：UTF-8-->
<script type="text/javascript" src="{$JSURL}include/js/EditView.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/Inventory.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/producttool/PriceStrategy.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/cls_resetComboxHtml.js?v={$GLOBALMINVERSION}"></script>

<script type="text/javascript" src="{$JSURL}include/js/modules/Products/Products.js?v={$GLOBALMINVERSION}"></script>
<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.autosize.min.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript">
	ld.noConflict();
	var fieldinfojson='{$PRODUCTFIELDSINFOJSON}';
    
	var basecolumn = '{$BASECOLUMN}';
    var PageRecordPopupobj=PageRecordPopup.load('{$MODULE}');
    var deployarrayjson='{$jsondeployarrays}';
    if(deployarrayjson!=''&&deployarrayjson!=null&&deployarrayjson!=undefined)
    {
       
        PageRecordPopupobj.deployarrays=eval('('+ deployarrayjson +')')?eval('('+ deployarrayjson +')'):JSON.parse(deployarrayjson);
    }
</script>
{if $PICKIST_DEPENDENCY_DATASOURCE neq ''}
<script type="text/javascript">
	  fielddepend=new FieldDependencies({$PICKIST_DEPENDENCY_DATASOURCE});
	jQuery(document).ready(function() {ldelim} 
        (fielddepend.init()) 
        //var searcht = new SearchText();
        //searcht.init();
    {rdelim});
</script>
{/if}

<script type="text/javascript">
 productAddFieldLabels='{$PRODUCTFIELDLABEL}';
 calendarParentid="CalendarProductTool";
 var productstrategyjsonobj='{$PRODUCTSTRATEGY}';
 var productstrategyobj=new Array();
 if(productstrategyjsonobj!=null&&productstrategyjsonobj!=undefined&&productstrategyjsonobj!='')
 {
    var productstrategyobj=  eval('('+ productstrategyjsonobj +')');
       
}
 var editviewinfojsonobj='{$FIELDINFOJSON}';
 var fieldinfoobjs='';
      if(editviewinfojsonobj!=null&&editviewinfojsonobj!=undefined&&editviewinfojsonobj!='')
     {
       var fieldinfoobjs=  eval('('+ editviewinfojsonobj +')');
        cur_PageInfo.fieldinfoobjs.push(fieldinfoobjs);
     }
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

{assign value='EditView' var='formname'}
{assign var='languagetype' value={''|@getLanguageType}}
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
    	<div class="DivL">				 
			<input type='hidden' id='currrelid' value='0'>
            <div class="Title" onclick='show_detail();'>
                <a href="javascript:void(0);" style="white-space: normal;">
                  {$MODULE|@getTranstab}{'MODULERELSEVANT'|@getTranstab}
                  {if ''|@checkCurrentUserIsAdmin eq 'on'}
                  <b onclick="SetRelatedlist(this,'{$MODULE}','','');event.stopPropagation();" style="float: right;margin:10px 20px 0 0;" class="icon-homeimg icon-set" title="{'SETTINGS'|@getFixedLabel}"></b>
                  {/if}
                </a>
            </div>
				{if $IS_REL_LIST && $IS_REL_LIST != ''}
					<ul id="detailrelatedinfo_ul">
					{if $OP_MODE eq 'edit_view' && $DUPLICATE neq 'true'}
						{foreach key=relid item=label from=$IS_REL_LIST name=relatedfor}
							<li><a href="#" tag="{$label}" id='rel-list-{$relid}' 
							onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
								<span class="Text">
                                    <i class="ico-dot"></i>
									{if $label eq 'Products Package'}
                                        {'PRODUCTPACKAGE'|@getFixedLabel}
                                    {elseif $label eq 'SalesOrder' && $MODULE eq 'SalesOrder' }
                                        {if $TRADEJIJIN eq 'jijin' }
                                            {'SUPERADDTION'|@getFixedLabel} 
                                        {else}
                                            {'CHANGEORDER'|@getFixedLabel} 
                                        {/if}
                                    {elseif $label eq 'SharedUsers'  }
                                        {'ShareUsers'|@getFixedLabel}
                                    {elseif $label eq 'ViewHistory'  }
                                        {'View History'|@getFixedLabel}
                                    {elseif $label eq 'ChangeView'  }
                                        {'SmownerChangeView'|@getFixedLabel}    
                                    {elseif $label eq 'Redemption'}
                                        {'REDEMPTION'|@getFixedLabel} 
                                    {else}
        					           {$label|@getTranstab}
                                    {/if}
								</span>
								<span id="rel-coount-{$relid}"></span>
							</a></li>
						{/foreach}
					{else}
						{foreach key=relid item=label from=$IS_REL_LIST name=relatedfor}
                            {if $label eq 'Print'}
                            {else}
							<li><a href="#" tag="{$label}" onclick='return false;' id='rel-list-{$relid}'>
								<span class="Text">
                                    <i class="ico-dot"></i>
									{if $label eq 'Products Package'}
                                        {'PRODUCTPACKAGE'|@getFixedLabel}
                                    {elseif $label eq 'SalesOrder' && $MODULE eq 'SalesOrder' }
                                        {if $TRADEJIJIN eq 'jijin' }
                                            {'SUPERADDTION'|@getFixedLabel} 
                                        {else}
                                            {'CHANGEORDER'|@getFixedLabel} 
                                        {/if}
                                    {elseif $label eq 'SharedUsers'  }
                                        {'ShareUsers'|@getFixedLabel}
                                    {elseif $label eq 'ViewHistory'  }
                                        {'View History'|@getFixedLabel}
                                    {elseif $label eq 'ChangeView'  }
                                        {'SmownerChangeView'|@getFixedLabel}    
                                    {elseif $label eq 'Redemption'}
                                        {'REDEMPTION'|@getFixedLabel} 
                                    {else}
        					           {$label|@getTranstab}
                                    {/if}
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
    {/if}
	<td class="Tdcenter" valign="top">
			<input type="hidden" id="bemodulestatus" name="bemodulestatus" value="{$BESTATUS}" />
			<input type="hidden" name="SearchScope" id="SearchScopeDetail" value="{$SEARCHSCOPE}"/>
			<input type="hidden" name="productdeploy" id="productdeploy" value="{$PERODUCTDEPLOY}" />
			<input type="hidden" name="version_trade" id="version_trade" value="{$VERSIONTRADE}" />
		<div id="DetailContent" class="ld-createedit-content">
            <table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="left">
						<div class="DivC" id="div_pagerecord">
						<div class="Top">
							{include file='EditViewHidden.tpl'}
							<table border="0" cellspacing="0" cellpadding="0" width="100%" class="">
								<tr style="border-top:none;">
									 <td  colspan=4 style="height: 45px;">
										  <div align="center">
                                              {if $MODULE eq 'SalesOrder' && $OUTBOUNDORDERCREATE eq 'yes'}
                                                  <input type="hidden" id="autowarehouseid" name="autowarehouseid" value="0">
                                              {/if}
    										  {if $MODULE eq 'PurchaseBack'||$MODULE eq 'PurchaseCashBack'||$MODULE eq 'SalesBack'||$MODULE eq 'CashBack'}
                                                 <input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';  if(validateInventory('{$MODULE}') && validatePurchaseTotal('{$MODULE}'))  return FieldDuplicateValidate('{$MODULE}',ld('#frmEditView'),this);else return false;" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
                                              {else}
                                                 <input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';  if(validateInventory('{$MODULE}'))  return FieldDuplicateValidate('{$MODULE}',ld('#frmEditView'),this);else return false;" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
                                              {/if}
            		                          <input title="{'CANCEL'|@getFixedLabel}" class="cancel" onclick="window.history.back()" type="button" name="button" value="{'CANCEL'|@getFixedLabel}" style="width:70px">
										  </div>
		 
									 </td>
								</tr>
								{include file='DetailView/EditViewForeach.tpl'}
								{if $MODULE eq 'PurchaseOrder' || $MODULE eq 'SalesOrder' || $MODULE eq 'Quotes' || $MODULE eq 'Invoice'|| $MODULE eq 'ServiceContracts' || $MODULE eq 'PurchaseBack'|| $MODULE eq 'PurchaseCashBack' || $MODULE eq 'PurchaseInvoice'||$MODULE eq 'WareHouseTransfer'||$MODULE eq 'Productbom'||$MODULE eq 'OutboundOrder'||$MODULE eq 'Stock'||$MODULE eq 'Checks' || $PERODUCTDEPLOY eq 1 || $MODULE|@get_file_address:'ProductDetails' == true}
								<tr>
									<td colspan="4" align="left">
										{* 出入库单 *}
										{if $MODULE == 'Stock' || $MODULE == 'OutboundOrder'}
											<input type="hidden" value="{$DEPLOYVALUE}" id="delpoyvalue" name="delpoyvalue" />
										{/if}
										{$ASSOCIATEDPRODUCTS}
									</td>
								</tr>
								{/if}
								<tr style="border-bottom:none;">
									<td colspan=4 style="height: 45px;">
										<div align="center">
                                            {if $MODULE eq 'PurchaseBack'||$MODULE eq 'PurchaseCashBack'||$MODULE eq 'SalesBack'||$MODULE eq 'CashBack'}
                                                <input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';  if(validateInventory('{$MODULE}') && validatePurchaseTotal('{$MODULE}'))  return FieldDuplicateValidate('{$MODULE}',ld('#frmEditView'),this);else return false;" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
                                            {else}
                                                <input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';  if(validateInventory('{$MODULE}'))  return FieldDuplicateValidate('{$MODULE}',ld('#frmEditView'),this);else return false;" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
                                            {/if}
        		                            <input title="{'CANCEL'|@getFixedLabel}" class="cancel" onclick="window.history.back()" type="button" name="button" value="{'CANCEL'|@getFixedLabel}" style="width:70px">
									    </div>
									</td>
								</tr>
						  </table>
						</div>
						</div>
					</td>
				</tr>
			</table>
		</div>
        
      <!--	related	-->
		<div class="paneldiv">
			<div id='RelatedContent'  style="display:none;">
			
			</div>
		</div>
	</td>

  </tr>
</table>
<input name='search_url' id="search_url" type='hidden' value='{$SEARCH}'>
</form>
{include file='EditViewBottom.tpl'}
<script language="JavaScript" type="text/javascript">
var opmode = "{$OP_MODE}";
var trade='{$TRADEJIJIN}';

{literal}
ld(function(){
    if(opmode == 'edit_view'){
		set_rel_count();
	}
  
});
{/literal}
</script>

<!-- This div is added to get the left and top values to show the tax details-->
<div id="tax_container" style="display:none; position:absolute; z-index:1px;"></div>
<!--同步库存，加载框-->
<div id="divId" class="veil_newnobg" style="position:absolute;width:100%;display:none;top:0px;left:0px;z-index:9999;">
<table border="0" cellpadding="0" cellspacing="0" align="center" style="vertical-align:middle;width:100%;height:100%;">
<tbody><tr>
		<td class="big" align="center">
		    <img src="themes/images/plsWaitAnimated.gif"/>
		</td>
	</tr>
</tbody>
</table>
</div>

<!--合同订单保存后自动创建出库单，如果仓库为禁用弹出框-->
<div id="outboundorderDiv" class="D_pop_box LdPopWidth400px" style="display:none;">
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'SELECTWAREHOUSE'|@getFixedLabel}</strong>
        <a href="javascript:saveOutboundorder(0)" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">   
        <tr>
            <td>
                {'AUTOCREATECHUKUCHAN'|@getFixedLabel}{$WAREHOUSE}{'DISABLEDPLEASECHOOSEWAREHOUSE'|@getFixedLabel}
            </td>
            <td>
                <select name="AfterCreateSalesOrder_CreateOutboundOrder" id="AfterCreateSalesOrder_CreateOutboundOrder">
                    {foreach  key=mainlabel item=maindata from=$WAREALL }
                        <option value="{$mainlabel}">{$maindata}</option>
                    {/foreach}
                </select>
            </td>
        </tr>
    </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'CONFIRME'|@getFixedLabel}" onclick="saveOutboundorder(1);"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="saveOutboundorder(0);"/> 
    </div>
</div> 
<!--相关信息设置div-->
<div id="SetRelatedlists_div" class="D_pop_box LdPopWidth600px" style="display:none; position: absolute; z-Index:9999"></div>

<script type="text/javascript" src="{$JSURL}include/js/producttool/toolField.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/producttool/fieldFormula.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/producttool/selectProduct.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript">
var bestatus = "{$BESTATUS}";{* 客户和联系人关联字段信息 状态*}
var module = '{$MODULE}';
var version_account = '{$VERSION_ACCOUNT}';
var accountid = "{$ACCOUNTID}";
var contactid = '{$CONTACTID}';
var from_module='{$FROM_MODULE}';
var current_date = '{$CURRENT_DATE}';//当前日期
var pricestrategyobj=new PriceStrategy();
var havebatchtextcolumnname='no';//是否批次字段
var COLUMN_FIELDS_VALUE='{$COLUMN_FIELDS_VALUE}';//界面值
COLUMN_FIELDS_VALUE=COLUMN_FIELDS_VALUE.replace(/(\r\n)|(\n)/g,'<br>');//备注等文本域换行
var COLUMN_FIELDS_VALUEobj= eval('('+ COLUMN_FIELDS_VALUE +')')?eval('('+ COLUMN_FIELDS_VALUE +')'):JSON.parse(COLUMN_FIELDS_VALUE);
PageRecordPopupobj.column_fields_value=COLUMN_FIELDS_VALUEobj;

//console.log(PageRecordPopupobj.column_fields_value);
{literal}
var tmpfieldinfo=eval('('+ fieldinfojson +')')?eval('('+ fieldinfojson +')'):JSON.parse(fieldinfojson);
 for(var i=0;i<tmpfieldinfo.fields.length;i++)
 { 
        if(tmpfieldinfo.fields[i].columnname=='batchtext')
        {
            havebatchtextcolumnname='yes';
           
            break;
        }
 }
window.onload = function(){
    if(module=='SalesOrder' || module=='PurchaseOrder'|| module == 'OutboundOrder'){
        new jsQualifyDate();
    }
    
	fnAddProductTdBtn();
	//客户服务单、项目任务、销售机会显示 客户联系人关联字段
    if(bestatus == 'YES')
    {
        getAccountsContactsInfo(accountid,contactid,module,'EditView');
    }
	if((module == 'SalesOrder' || module == 'Quotes') && accountid > 0 && from_module == 'Accounts'){
		getAccountForDiscountRate(accountid,0);
	}
    ld('textarea').not('.proName_note').autosize();//textarea根据内容自动调整大小,去除产品信息“备注”框
}
/**设置字段公式事件**/
fieldformulaobj.setAllRowEvent();

//服务合同新增开始日期和结束日期的计算
if(from_module=='Products')
{
    
    fieldformulaobj.changelistprice();
}
else
{
     fieldformulaobj.ismasscount='yes';
     fieldformulaobj.CountFormulaColumn();
     fieldformulaobj.ismasscount='no';
     fieldformulaobj.CountsubTotal();
    
}

//calcTotal();
{/literal}
</script>
<script>
function onClickShowServiewDetail(accountid,module)
{ldelim}
	showServiceContractsDetail(accountid,module);
{rdelim}
function onClickgetAccountsContactsInfo(accountid,contactid,module,mode)
{ldelim}
	getAccountsContactsInfo(accountid,contactid,module,mode);
{rdelim}
function disableStyle(id)
{ldelim}
	if(browser_ie && (gBrowserAgent.indexOf("msie 7.")!=-1))//for IE 7
        {ldelim}
                //document.body.removeChild($('freeze'));
        {rdelim}else if(browser_ie)
        {ldelim}
             var oDivfreeze = $('divId');
             oDivfreeze.style.height = document.documentElement['clientHeight'] + 'px';
        {rdelim}
        $('divId').style.display = 'block';
{rdelim}

    var validatasavejsonobj='{$VALIDATASAVE}';
    var fieldname = new Array({$VALIDATION_DATA_FIELDNAME});
    var fieldlabel = new Array({$VALIDATION_DATA_FIELDLABEL});

    var fielddatatype = new Array({$VALIDATION_DATA_FIELDDATATYPE});
    
    PageRecordPopupobj.fields=fieldinfoobjs;
     PageRecordPopupobj.fieldname="{$VALIDATION_DATA_FIELDNAME}";
     PageRecordPopupobj.fieldlabel="{$VALIDATION_DATA_FIELDLABEL}";
    PageRecordPopupobj.fielddatatype="{$VALIDATION_DATA_FIELDDATATYPE}";
     PageRecordPopupobj.type="moduledetailpage";
    PageRecordPopupobj.record="{$ID}";
    PageRecordPopupobj.divid="div_pagerecord";
    PageRecordPopupobj.setTimeCount();
  PageRecordPopupobj.list_link_field='{$MODULELINKFIELD}';
  PageRecordPopupobj.smownercolumnname='{$SMOWNERCOLUMNNAME}';
  PageRecordPopupobj.smownercolumnname_value = '';
  
   if(validatasavejsonobj!=null&&validatasavejsonobj!=undefined&&validatasavejsonobj!='')
 {ldelim}
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
  PageRecordPopupobj.picklistdepencyfields="";
  if(piclistdenpencyfields!="")
        PageRecordPopupobj.picklistdepencyfields=eval('('+ piclistdenpencyfields +')');
    
PageRecordPopupobj.picklistdepency=eval('('+ '{$PICKIST_DEPENDENCY_DATASOURCE}' +')');
var jsonpicklistcontent='{$PICKLISTCONTENT}';
PageRecordPopupobj.picklistcontent=eval('('+ jsonpicklistcontent +')')?eval('('+ jsonpicklistcontent +')'):JSON.parse(jsonpicklistcontent);
var jsonfieldrulenamefieldnames='{$jsonFieldRuleFieldNames}';
if(jsonfieldrulenamefieldnames!=null&&jsonfieldrulenamefieldnames!=undefined)
{ldelim}
    //布局规则的查询字段
    PageRecordPopupobj.fieldrulefieldnames=eval('('+jsonfieldrulenamefieldnames +')')?eval('('+ jsonfieldrulenamefieldnames +')'):JSON.parse(jsonfieldrulenamefieldnames);
{rdelim}

PageRecordPopupobj.fieldname_fields=[];


     var productNamelabel='{$PRODUCTNAMELABEL}';
     var quantityLabel='{'QUANTITY'|@getFixedLabel}';
      var ListPrice='{'LISTPRICE'|@getFixedLabel}';
var product_labelarr = {ldelim}CLEAR_COMMENT:'{$APP.LBL_CLEAR_COMMENT}',
                MOVEUP:'{'MOVEUP'|@getFixedLabel}',
                MOVEDOWN:'{'MOVEDOWN'|@getFixedLabel}',
                JSDELETE:'{'DELETE'|@getFixedLabel}',
				DISCOUNT:'{'DISCOUNT'|@getFixedLabel}',
                JSPRODUCT:'{'Products'|@getTranstab}',
                JSCLEAR:'{'CLEAR'|@getFixedLabel}',
				TOTAL_AFTER_DISCOUNT:'{'TOALAFTERDIS'|@getFixedLabel}',
				TAX:'{'TAX'|@getFixedLabel}',
				ZERO_DISCOUNT:'{'ZERODISCOUNT'|@getFixedLabel}',
                ALLSINGLEDISCOUNT:'{'ALLSINGLEDISCOUNT'|@getFixedLabel}',
				PERCENT_OF_PRICE:'{'Price'|@getFixedLabel}',
				DIRECT_PRICE_REDUCTION:'{'DIRECTPRICE'|@getFixedLabel}'{rdelim};

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
<!--{*
    @reason 0012243 合同订单创建采购订单，把货币币种带过来
    @author tujt 2014-11-05
*}-->
<script type="text/javascript">

var salescurrencyid = "{$SALESCURRENCYID}";
var ordertype_onclick= "{$ordertype_onclick}";	//源美特殊控制
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
         that.column_fields=[];
        for(var i=0;i<length;i++)
        {
            var fieldinfo=this.fields[i];
            that.column_fields[fieldinfo.columnname]=fieldinfo;
            that.fieldname_fields[fieldinfo.fieldname]=fieldinfo;
            if(this.fields[i].uitype==230)
                this.oCKeditors[this.fields[i].fieldname]=UE.getEditor(this.fields[i].fieldname);
            else if(this.fields[i]['uitype']==151)
            {
                var cls_resetComboxHtmlobj=new cls_resetComboxHtml(this.fields[i]['fieldname']);
                 if(this.module=="Checks")
                 {
                             cls_resetComboxHtmlobj.setComboxObjHtmlByWidth(170);
                 }
                 else
                cls_resetComboxHtmlobj.setComboxObjHtml();
               // break;
            }
        }
      
        var fieldruleobj=new cls_fieldrule(that.fieldrulefieldnames);
        that.fieldruleobj=fieldruleobj;
        fieldruleobj.setEvent();
        
          var tmpvalues={};
               ld.each(this.columnfields_value,function(fieldname,tmpvalue){
                   
                        tmpvalues[fieldname]=tmpvalue;
                       
              })
        fieldruleobj.setValues(tmpvalues);
    //InitPageValue:end 
}
var tmplen=PageRecordPopupobj.fields.length;
PageRecordPopupobj.column_fields=[];
PageRecordPopupobj.columnfields_value={};
 for(var i=0;i<tmplen;i++)
 {
            var fieldinfo=PageRecordPopupobj.fields[i];
            PageRecordPopupobj.column_fields[fieldinfo.columnname]=fieldinfo;
 }
 
ld.each(PageRecordPopupobj.column_fields_value,function(columnname,valueinfo){
                    if(PageRecordPopupobj.column_fields[columnname]!=undefined)
                    {
                       
                         var fieldname=PageRecordPopupobj.column_fields[columnname].fieldname;
                        PageRecordPopupobj.columnfields_value[fieldname]=valueinfo[0];
                    }
})
              
PageRecordPopupobj.InitPageValue();

if(salescurrencyid > 0 && document.getElementById('inventory_currency')){
	document.getElementById('inventory_currency').value = salescurrencyid;
}
if(ordertype_onclick == 'yes' && setProductToolFieldDisplay != undefined){
	setProductToolFieldDisplay('create');
}
ld(document).ready(function(){setProductDivWidth();});

var trlength=ld("#proTab").find('tr').length-3;
for(var i=0;i<PageRecordPopupobj.detailfields.length;i++)
{
    if(PageRecordPopupobj.detailfields[i]['uitype']==60&&PageRecordPopupobj.detailfields[i]['columnname']=='wareid')
    {
    
        for(var j=1;j<=trlength;j++)
        {
             var name=PageRecordPopupobj.detailfields[i]['columnname']+j;
            if( ld("#"+name).length<=0)
            {
                break;
            }
            var width=parseInt(ld("#"+name).parent().css("width"))-3;
             var cls_resetComboxHtmlobj=new cls_resetComboxHtml(name);
                cls_resetComboxHtmlobj.setComboxObjHtmlByWidth(width);
        }
        
        break;
    }
}


for(var i=0;i<PageRecordPopupobj.detailfields.length;i++)
{
    
    if(PageRecordPopupobj.detailfields[i].columnname=='productname'&&PageRecordPopupobj.detailfields[i].defaultvalue>0)
    {
       
        var rowcnt=document.getElementById("rowcnt").value;
        for(var j=1;j<=rowcnt;j++)
        {
            //默认新增多行，所有循环
             if(ld("#hidden_rowid_"+j).val()==0&&ld("#hdnProductId"+j).val()<=0)
             {
                fun_selectproduct.setProductDefaultValue(j,PageRecordPopupobj.detailfields[i].defaultvalue);
                
             }
             else
             {
                break;
             }
        }
       break;
    }
}
{/literal}
</script>