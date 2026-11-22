{*<!-- module header -->*}
<!--修改编码格式:统一编码：UTF-8-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/EditView.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/Inventory.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/SystemPopup/ListHigherSearchPopup.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/advancefilter.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/cls_resetComboxHtml.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/FieldDependencies.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/modules/Products/Products.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/producttool/PriceStrategy.js?v={$GLOBALMINVERSION}"></script>
<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery.autosize.min.js"></script>
<script type="text/javascript">
	ld.noConflict();
  var fieldinfojson='{$PRODUCTFIELDSINFOJSON}';
  var basecolumn = '{$BASECOLUMN}';
  var PageRecordPopupobj=PageRecordPopup.load('{$MODULE}');
  
  var deployarrayjson='{$jsondeployarrays}';
  var deployarrayjson='{$jsondeployarrays}';
  if(deployarrayjson!=''&&deployarrayjson!=null&&deployarrayjson!=undefined){
    PageRecordPopupobj.deployarrays=eval('('+ deployarrayjson +')')?eval('('+ deployarrayjson +')'):JSON.parse(deployarrayjson);
  }
</script>

{if $PICKIST_DEPENDENCY_DATASOURCE neq ''}
<script type="text/javascript">
	  fielddepend=new FieldDependencies({$PICKIST_DEPENDENCY_DATASOURCE});
	jQuery(document).ready(function() {ldelim} (fielddepend.init()) {rdelim});
</script>
{/if}
<script type="text/javascript">
  productAddFieldLabels='{$PRODUCTFIELDLABEL}';
  calendarParentid="CalendarProductTool";
</script>
<script type="text/javascript">
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
			<input type="hidden" id="bemodulestatus" name="bemodulestatus" value="{$BESTATUS}" />
            <div class="Title" onclick='show_detail();' style="border-bottom: 1px #fff solid;">
                <a href="javascript:void(0);" style="white-space: normal;">
                  <b style="float:left;text-overflow:ellipsis;width:10em;white-space:nowrap;overflow:hidden;padding-left: 1px;">{$MODULE|@getTranstab}{'MODULERELSEVANT'|@getTranstab}</b>
                  {if ''|@checkCurrentUserIsAdmin eq 'on'}
                  <b onclick="SetRelatedlist(this,'{$MODULE}','','');event.stopPropagation();" style="float: right;margin:10px 20px 0 0;" class="icon-homeimg icon-set" title="{'SETTINGS'|@getFixedLabel}"></b>
                  {/if}
                </a>
            </div>
					{if $IS_REL_LIST && $IS_REL_LIST != ''}
						<ul>
                        <li>
                          <a href="javascript:void(0);" onclick='show_detail();'>
          									<span class="Text">
                                                <i class="ico-dot"></i>
          										{$MODULE|@getTranstab}{'details1'|@getFixedLabel}
          									</span>
        								  </a>
                        </li>
						{if $OP_MODE eq 'edit_view'}
							{foreach key=relid item=label from=$IS_REL_LIST name=relatedfor}
                                {if $label eq 'Print'}
                                {else}
								<li><a href="#" tag="{$label}" id='rel-list-{$relid}' 
								onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
									<span class="Text">
                                        <i class="ico-dot"></i>
										{if $label eq 'Products Package'}
                                            {'PRODUCTPACKAGE'|@getFixedLabel}
                                        {elseif $label eq 'SalesOrder' && $MODULE eq 'SalesOrder' }
                                            {if $TRADEJIJIN eq 'jijin'}
                                                {'SUPERADDTION'|@getFixedLabel} 
                                            {else}
                                                {'CHANGEORDER'|@getFixedLabel} 
                                            {/if}
                                        {elseif $label eq 'Redemption'}
                                             {'REDEMPTION'|@getFixedLabel}
                                        {elseif $label eq 'SharedUsers'  }
                                             {'ShareUsers'|@getFixedLabel}
                                        {elseif $label eq 'ViewHistory'  }
                                             {'View History'|@getFixedLabel}
                                        {elseif $label eq 'ChangeView'  }
                                            {'SmownerChangeView'|@getFixedLabel} 
                                        {else}
            					           {$label|@getTranstab}
                                        {/if}
									</span>
                                    <span id="rel-createbtn-{$relid}"></span>
									<span id="rel-coount-{$relid}"></span>
								</a></li>
                                {/if}
							{/foreach}
						{else}
							{foreach key=relid item=label from=$IS_REL_LIST name=relatedfor}
                                {if $label eq 'Print'}
                                {else}
								<li><a href="#" tag="{$label}" onclick='return false;' id='rel-list-{$relid}'>
									<span class="Text">
                                        <i class="ico-dot"></i>
                                    	{if $label eq 'SharedUsers'}
                                            {'ShareUsers'|@getFixedLabel} 
                                        {elseif $label eq 'SharedUsers'  }
                                             {'ShareUsers'|@getFixedLabel}
                                        {elseif $label eq 'ViewHistory'  }
                                             {'View History'|@getFixedLabel}
                                        {elseif $label eq 'ChangeView'  }
                                             {'SmownerChangeView'|@getFixedLabel}  
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
		<input type="hidden" name="productdeploy" id="productdeploy" value="{$PERODUCTDEPLOY}" />
		<input type="hidden" name="SearchScope" id="SearchScopeDetail" value="{$SEARCHSCOPE}"/>
		<input type="hidden" name="version_trade" id="version_trade" value="{$VERSIONTRADE}" />
		<div id="DetailContent">
      <table width="100%" border="0" cellspacing="0" cellpadding="0">
				<tr>
					<td class="left">
						<div class="DivC" id="div_pagerecord">
						<div class="Top">
							{include file='EditViewHidden.tpl'}
							<table border="0" cellspacing="0" cellpadding="0" width="100%" class="" id="blockTable">
								<tr style="border-top:none;">
									 <td  colspan="4" style="height: 45px;">
										  <div align="center">
    										  {if $MODULE eq 'PurchaseBack'||$MODULE eq 'PurchaseCashBack'||$MODULE eq 'SalesBack'||$MODULE eq 'CashBack'}
                                                <input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';  if(validateInventory('{$MODULE}')  && validatePurchaseTotal('{$MODULE}')) return FieldDuplicateValidate('{$MODULE}',ld('#div_pagerecord [name=EditView]'),this);else return false;" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
												{if $MODULE eq 'CCashBack'}
													<input type="hidden" name="salesorder_id" id="salesorder_id" value="{$ENTITYTYPEID}" />
												{elseif $MODULE eq 'PurchaseCashBack'}
													<input type="hidden" name="purchaseorder_id" id="purchaseorder_id" value="{$ENTITYTYPEID}" />
												{/if}
											 {elseif  $MODULE eq 'Checks'}
												<input type="hidden" id="checkproductinfo" name="checkproductinfo" value="{$CHECKSPRODUCTINFO}" />
												<input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save'; if(!ChecksProduct()) return false;displaydeleted();if(validateInventory('{$MODULE}'))  return FieldDuplicateValidate('{$MODULE}',ld('#div_pagerecord [name=EditView]'),this);else return false;" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
                                             {else}
                                                    <input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';  if(validateInventory('{$MODULE}'))  return FieldDuplicateValidate('{$MODULE}',ld('#div_pagerecord [name=EditView]'),this);else return false;" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
                                              {/if}
                                              <input title="{'CANCEL'|@getFixedLabel}" class="cancel" onclick="window.history.back()" type="button" name="button" value="{'CANCEL'|@getFixedLabel}" style="width:70px">
										  </div>
		 
									 </td>
								</tr>
								{include file='DetailView/EditViewForeach.tpl'}
								<tr>
									<td colspan="4" align="left" width="100%">
										{* 出入库单 *}
										{if $MODULE == 'Stock' || $MODULE == 'OutboundOrder'}
											<input type="hidden" value="{$DEPLOYVALUE}" id="delpoyvalue" name="delpoyvalue" />
										{/if}
										{$ASSOCIATEDPRODUCTS}
									</td>
								</tr>
								<tr style="border-bottom:none;">
									<td  colspan="4" style="height: 45px;">
									  <div align="center">
										{if $MODULE eq 'PurchaseBack'||$MODULE eq 'PurchaseCashBack'||$MODULE eq 'SalesBack'||$MODULE eq 'CashBack'}
                                              <input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';  if(validateInventory('{$MODULE}')  && validatePurchaseTotal('{$MODULE}')) return FieldDuplicateValidate('{$MODULE}',ld('#div_pagerecord [name=EditView]'));else return false;" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
										{elseif  $MODULE eq 'Checks'}
											<input type="hidden" id="checkproductinfo" name="checkproductinfo" value="{$CHECKSPRODUCTINFO}" />
											<input title="{'SAVE'|@getFixedLabel}" class="saveauto" onclick="this.form.action.value='Save'; if(!ChecksProduct()) return false;displaydeleted();if(validateInventory('{$MODULE}'))  return FieldDuplicateValidate('{$MODULE}',ld('#div_pagerecord [name=EditView]'),this);else return false;" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
                                          {else}
                                              <input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';  if(validateInventory('{$MODULE}'))  return FieldDuplicateValidate('{$MODULE}',ld('#div_pagerecord [name=EditView]'),this);else return false;" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
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
        </form>
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
{include file='EditViewBottom.tpl'}

<script type="text/javascript" src="{$JSURL}include/js/producttool/toolField.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/producttool/fieldFormula.js?v={$GLOBALMINVERSION}"></script>
<script type="text/javascript" src="{$JSURL}include/js/producttool/selectProduct.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript">
var opmode = "{$OP_MODE}";
var bestatus = "{$BESTATUS}";{* 客户和联系人关联字段信息 状态*}
var accountid = "{$ACCOUNTID}";
var contactid = '{$CONTACTID}';
var module = '{$MODULE}';
var current_date = '{$CURRENT_DATE}';//当前日期
var havebatchtextcolumnname='no';//是否批次字段
var tmpstr='{$DATETIMESTR}';
var datetimestr=  eval('('+ tmpstr +')')?eval('('+ tmpstr +')'):JSON.parse(tmpstr);
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
	if(opmode == 'edit_view'){
		set_rel_count();
        set_rel_createbtn();
	}
    //客户服务单、项目任务、销售机会显示 客户联系人关联字段
    if(bestatus == 'YES')
    {
        getAccountsContactsInfo(accountid,contactid,module,'EditView');
    }
    //带有搜索的下拉框，z-index赋值，解决低版本 下拉框覆盖问题
    dropDownBoxSearch(document.EditView);
    //textarea根据内容自动调整大小,去除产品信息“备注”框
    ld('textarea').not('.proName_note').autosize();
    /* editor:gyqX160708  reason:23406 销售发票：编辑销售发票单据，选择合同订单/服务合同单据后，产品信息栏的合计显示为0，没有带出对应的合计金额 */
   //23406: 销售发票：编辑销售发票单据，选择合同订单/服务合同单据后，产品信息栏的合计显示为0，没有带出对应的合计金额
   // calcTotal();

}
function onClickgetAccountsContactsInfo(accountid,contactid,module,mode)
{
    getAccountsContactsInfo(accountid,contactid,module,mode);
}
/**设置字段公式事件**/
fieldformulaobj.setAllRowEvent();
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
<!--相关信息设置div-->
<div id="SetRelatedlists_div" class="D_pop_box LdPopWidth600px" style="display:none; position: absolute; z-Index:9999"></div>

<script>	
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


        var fieldname = new Array({$VALIDATION_DATA_FIELDNAME});

        var fieldlabel = new Array({$VALIDATION_DATA_FIELDLABEL});
        var fielddatatype = new Array({$VALIDATION_DATA_FIELDDATATYPE});
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
				PERCENT_OF_PRICE:'{'Price'|@getFixedLabel}',
                ALLSINGLEDISCOUNT:'{'ALLSINGLEDISCOUNT'|@getFixedLabel}',
				DIRECT_PRICE_REDUCTION:'{'DIRECTPRICE'|@getFixedLabel}'{rdelim};

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
{if $MODULE eq 'Vendors'}
	<div id="sendmail_cont" style="z-index:100001;position:absolute;"></div>
{else if $MODULE eq 'PriceBooks'}
	<div id="editlistprice" style="position:absolute;width:300px;"></div>
{/if}
<script>
 var productstrategyjsonobj='{$PRODUCTSTRATEGY}';//价格策略
 var productstrategyobj=new Array();
 if(productstrategyjsonobj!=null&&productstrategyjsonobj!=undefined&&productstrategyjsonobj!='')
 {
    var productstrategyobj=  eval('('+ productstrategyjsonobj +')');
       
 }
 var pricestrategyobj=new PriceStrategy();
var trade='{$TRADEJIJIN}';
var version_account = '{$VERSION_ACCOUNT}';

var editviewinfojsonobj='{$FIELDINFOJSON}';
 if(editviewinfojsonobj!=null&&editviewinfojsonobj!=undefined&&editviewinfojsonobj!='')
{ldelim}
	var fieldinfoobjs=  eval('('+ editviewinfojsonobj +')')?eval('('+ editviewinfojsonobj +')'):JSON.parse(editviewinfojsonobj);
	cur_PageInfo.fieldinfoobjs.push(fieldinfoobjs);
    PageRecordPopupobj.fields=fieldinfoobjs;
    var COLUMN_FIELDS_VALUE='{$COLUMN_FIELDS_VALUE}';//界面值
   
     COLUMN_FIELDS_VALUE=COLUMN_FIELDS_VALUE.replace(/(\r\n)|(\n)/g,'<br>');//备注等文本域换行
     var COLUMN_FIELDS_VALUEobj= eval('('+ COLUMN_FIELDS_VALUE +')')?eval('('+ COLUMN_FIELDS_VALUE +')'):JSON.parse(COLUMN_FIELDS_VALUE);
{rdelim}

 var fieldinfoobjs='';
 var ordertype_onclick= "{$ordertype_onclick}";	//源美特殊控制
var validatasavejsonobj='{$VALIDATASAVE}';
 PageRecordPopupobj.type="moduledetailpage";
 PageRecordPopupobj.divid="div_pagerecord";
 PageRecordPopupobj.column_fields_value=COLUMN_FIELDS_VALUEobj;
 PageRecordPopupobj.setTimeCount();
   PageRecordPopupobj.record="{$ID}";
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
        PageRecordPopupobj.picklistdepencyfields=eval('('+ piclistdenpencyfields +')')?eval('('+ piclistdenpencyfields+')'):JSON.parse(piclistdenpencyfields);
    
  PageRecordPopupobj.picklistdepency=eval('('+ '{$PICKIST_DEPENDENCY_DATASOURCE}' +')')?eval('('+ '{$PICKIST_DEPENDENCY_DATASOURCE}' +')'):JSON.parse('{$PICKIST_DEPENDENCY_DATASOURCE}');
  var jsonpicklistcontent='{$PICKLISTCONTENT}';
  PageRecordPopupobj.picklistcontent=eval('('+ jsonpicklistcontent +')')?eval('('+ jsonpicklistcontent +')'):JSON.parse(jsonpicklistcontent);
  
PageRecordPopupobj.fieldname="{$VALIDATION_DATA_FIELDNAME}";
PageRecordPopupobj.fieldlabel="{$VALIDATION_DATA_FIELDLABEL}";
PageRecordPopupobj.fielddatatype="{$VALIDATION_DATA_FIELDDATATYPE}";
var jsonfieldrulenamefieldnames='{$jsonFieldRuleFieldNames}';
if(jsonfieldrulenamefieldnames!=null&&jsonfieldrulenamefieldnames!=undefined)
{ldelim}
    //布局规则的查询字段
    PageRecordPopupobj.fieldrulefieldnames=eval('('+jsonfieldrulenamefieldnames +')')?eval('('+ jsonfieldrulenamefieldnames +')'):JSON.parse(jsonfieldrulenamefieldnames);
{rdelim}

PageRecordPopupobj.fieldname_fields=[];

 PageRecordPopupobj.column_fields=[];


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
        for(var i=0;i<length;i++)
        {
            var fieldinfo=this.fields[i];
            that.fieldname_fields[fieldinfo.fieldname]=fieldinfo;
            that.column_fields[fieldinfo.columnname]=fieldinfo;
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
if(ordertype_onclick == 'yes' && setProductToolFieldDisplay != undefined){
	setProductToolFieldDisplay('edit');
}
ld(document).ready(function(){setProductDivWidth();});

function editProductListPrice(id,pbid,price)
{
        $("status").style.display="inline";
        new Ajax.Request(
                'index.php',
                {queue: {position: 'end', scope: 'command'},
                        method: 'post',
                        postBody: 'action=ProductsAjax&file=EditListPrice&return_action=CallRelatedList&return_module=PriceBooks&module=Products&record='+id+'&pricebook_id='+pbid+'&listprice='+price,
                        onComplete: function(response) {
                                        $("status").style.display="none";
                                        $("editlistprice").innerHTML= response.responseText;
                        }
                }
        );
}

function gotoUpdateListPrice(id,pbid,proid)
{
    
        $("status").style.display="inline";
        $("roleLay").style.display = "none";
        puyoungJS_DialogBox.unblock();
        var listprice=$("list_price").value;
                new Ajax.Request(
                        'index.php',
                        {queue: {position: 'end', scope: 'command'},
                                method: 'post',
                                postBody: 'module=Products&action=ProductsAjax&file=UpdateListPrice&ajax=true&return_action=CallRelatedList&return_module=PriceBooks&record='+id+'&pricebook_id='+pbid+'&product_id='+proid+'&list_price='+listprice,
                                onComplete: function(response) {
                                    $("status").style.display="none";
												//$("RLContents").update(response.responseText);
												if($('refresh-Products')){
													$('refresh-Products').click();
												}
                                }
                        }
                );
      
}

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
{/literal}
</script>
