{if $MODULE eq "SalesOrder"||$MODULE eq 'PurchaseOrder'||$MODULE eq 'ServiceContracts'||$MODULE eq 'ServiceReturn'}
<script type='text/javascript'>
{literal}
    // ld('body').css('overflow','hidden');
    function isRelatedListBlockLoadeds(id,urldata){
    	var elem = document.getElementById(id);
    	if(elem == null || typeof elem == 'undefined' || urldata.indexOf('order_by') != -1 ||
    		urldata.indexOf('start') != -1 || urldata.indexOf('withCount') != -1){
    		return false;
    	}
    	var tables = elem.getElementsByTagName('table');
    	return tables.length > 0;
    }
    
    function loadRelatedListBlocks(urldata,target,imagesuffix) {
    
    	var showdata = 'show_'+imagesuffix;
    	var showdata_element = $(showdata);
    
    	var hidedata = 'hide_'+imagesuffix;
    	var hidedata_element = $(hidedata);
    	if(isRelatedListBlockLoadeds(target,urldata) == true){
    		$(target).show();
    		showdata_element.hide();
          	hidedata_element.show();
    		$('delete_'+imagesuffix).show();
    		return;
    	}
    	var indicator = 'indicator_'+imagesuffix;
    	var indicator_element = $(indicator);
    	indicator_element.show();
    	$('delete_'+imagesuffix).show();
    	
    	var target_element = $(target);
    	new Ajax.Request(
    		'index.php',
            {queue: {position: 'end', scope: 'command'},
                    method: 'post',
                    postBody: urldata,
                    onComplete: function(response) {
    					var responseData = trim(response.responseText);
          				target_element.update(responseData);
    					target_element.show();
          				showdata_element.hide();
          				hidedata_element.show();
          				indicator_element.hide();
    					if($('return_module').value == 'Campaigns'){
    						var obj = document.getElementsByName(imagesuffix+'_selected_id');
    						var relatedModule = imagesuffix.replace('Campaigns_',"");
    						$(relatedModule+'_count').innerHTML = numofRows;
    						if(selectallActivation == 'true'){
    							$(imagesuffix+'_selectallActivate').value='true';
    							$(imagesuffix+'_linkForSelectAll').show();
    							$(imagesuffix+'_selectAllRec').style.display='none';
    							$(imagesuffix+'_deSelectAllRec').style.display='inline';
    							var exculdedArray=excludedRecords.split(';');
    							if (obj) {
    								var viewForSelectLink = showSelectAllLink(obj,exculdedArray);
    								$(imagesuffix+'_selectCurrentPageRec').checked = viewForSelectLink;
    								$(imagesuffix+'_excludedRecords').value = $(imagesuffix+'_excludedRecords').value+excludedRecords;
    							}
    						}else{
    							$(imagesuffix+'_linkForSelectAll').hide();
    							rel_toggleSelect(false,imagesuffix+'_selected_id',relatedModule);
    						}
    						updateParentCheckbox(obj,imagesuffix);
    					}
    				}
            }
    	);
    }
    
    function hideRelatedListBlocks(target, imagesuffix) {
    	
    	var showdata = 'show_'+imagesuffix;
    	var showdata_element = $(showdata);
    	
    	var hidedata = 'hide_'+imagesuffix;
    	var hidedata_element = $(hidedata);
    	
    	var target_element = $(target);
    	if(target_element){
    		target_element.hide();
    	}
    	hidedata_element.hide();
    	showdata_element.show();
    	$('delete_'+imagesuffix).hide();
    }
    
    function disableRelatedListBlocks(urldata,target,imagesuffix){
    	var showdata = 'show_'+imagesuffix;
    	var showdata_element = $(showdata);
    
    	var hidedata = 'hide_'+imagesuffix;
    	var hidedata_element = $(hidedata);
    
    	var indicator = 'indicator_'+imagesuffix;
    	var indicator_element = $(indicator);
    	indicator_element.show();
    	
    	var target_element = $(target);
    	new Ajax.Request(
    		'index.php',
            {queue: {position: 'end', scope: 'command'},
                    method: 'post',
                    postBody: urldata,
                    onComplete: function(response) {
    					var responseData = trim(response.responseText);
    					target_element.hide();
    					$('delete_'+imagesuffix).hide();
          				hidedata_element.hide();
    					showdata_element.show();
          				indicator_element.hide();
    				}
            }
    	);
    }
    
    {/literal}
    </script>

  
{/if}
{if $MODULE eq 'Products'}

<script type="text/javascript" src="{$JSURL}include/js/modules/Accounts/Accounts.js"></script>
{/if}
<link rel="stylesheet" type="text/css" media="all" href="{$CSSURL}themes/softed/Paymentplan.css">
<!---23457: 服务合同：新增服务合同选择合同订单“ adminSO-1400 ”，保存单据后产品图片不显示了-->
<script type="text/javascript" src="{$JSURL}include/js/Inventory.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/EditView.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/dtlviewajax.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/Settings/Settings.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/SystemPopup/PrintPopup.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/advancefilter.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/SystemPopup/ListHigherSearchPopup.js"></script>
<div id="convertleaddiv" style="display:block;position:absolute;left:225px;top:150px;"></div>
<span id="crmspanid" class="ld-detail-edit-small" style="display:none;" onmouseover="show('crmspanid');">
   <i class="ld-fonticon ld-fonticon-edit" title="{'EDIT'|@getFixedLabel}"></i>
</span>
<script>
var  hiddenlabel="{'HIDDEN'|@getFixedLabel}";
var showLabel="{'DISPLAY'|@getFixedLabel}";
{literal}

function showHideStatus(sId,anchorImgId)
{
	oObj = eval(document.getElementById(sId));
	if(oObj.style.display == 'block')
	{
		oObj.style.display = 'none';
		if(anchorImgId !=null){
			document.getElementById(anchorImgId).className = 'On';
			eval(document.getElementById(anchorImgId)).alt = showLabel;
			eval(document.getElementById(anchorImgId)).title = showLabel;
		}
	}
	else
	{
		oObj.style.display = 'block';
		if(anchorImgId !=null){
			document.getElementById(anchorImgId).className = '';
			eval(document.getElementById(anchorImgId)).alt = hiddenlabel;
			eval(document.getElementById(anchorImgId)).title = hiddenlabel;
		}
	}
}
function setCoOrdinate(elemId)
{
	oBtnObj = document.getElementById(elemId);
	var tagName = document.getElementById('lstRecordLayout');
	leftpos  = 0;
	toppos = 0;
	aTag = oBtnObj;
	do 
	{					  
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
                fnvshobj(obj,'lstRecordLayout');
			}
		}
	);
}
{/literal}
</script>

<div id="lstRecordLayout" class="LdPop_box LdPopWidth300px" style="display:none;"></div>
{*
<table width="100%" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td>{include file='Buttons_List1.tpl'}</td>
  </tr>
</table>
*}
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
    <td class="TdLeft" valign="top" style='padding-left:5px;'>
    {else}
    <td class="TdLeft" valign="top" style='padding-left:5px;display:none'>
    {/if}
    	<div class="DivL">
			{assign var='languagetype' value={''|@getLanguageType}} 
			<input type='hidden' id='currrelid' value='0'>
             <div class="Title" onclick='show_detail()' style="border-bottom: 1px #fff solid;">
                <a href="javascript:void(0);" style="white-space: normal;">
                  <b style="float:left;text-overflow:ellipsis;width:10em;white-space:nowrap;overflow:hidden;padding-left: 1px;">{$MODULE|@getTranstab}{'MODULERELSEVANT'|@getTranstab}</b>
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
                        {if $PhoneSteward == '' && $label == 'CallButler'}
                        {elseif $label eq 'Print'}
                            {assign var='isprint' value=1}
                        {else}        
        					<li>
                                <a href="#" tag="{$label}" id='rel-list-{$relid}' onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
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
                                        {elseif $label eq 'ViewHistory'}
                                             {'View History'|@getFixedLabel}
                                        {elseif $label eq 'ChangeView'}
                                             {'SmownerChangeView'|@getFixedLabel} 
                                        {elseif $label eq 'Redemption'  }
                                            {'REDEMPTION'|@getFixedLabel}
                                        {else}
            					           {$label|@getTranstab}
                                        {/if}
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
		</div>
    </td>
    <td class="Tdcenter" valign="top">
	    <input type="hidden" name="SearchScope" id="SearchScopeDetail" value="{$SEARCHSCOPE}"/>
		<div id="DetailContent" class="bbbb">
            <table width="100%" border="0" cellspacing="0" cellpadding="0" aling="left">
				<tr>
					<td class="left">
						<div class="DivC">
							<!--	button start	-->
							{include file="DetailView/InventoryDetailButton.tpl"}
                            <!--	button exit		-->								
							<!--	detail info start	-->
							{if $MODULE eq 'Checks'}
								<input type="hidden" id="checkproductinfo" name="checkproductinfo" value="{$CHECKSPRODUCTINFO}" />
							{/if}
							<div class="DivCTable">
								<form action="index.php" method="post" name="DetailView" id="form" onsubmit="puyoungJS_DialogBox.block();" style='margin:0px;padding:0px;'>
								{include file='DetailViewHidden.tpl'}
								<table class="bgwhite" border=0 cellspacing=0 cellpadding=0 width=100% class="linefeed">
                                   <tr>
    									<td width="80%">
    							        
										{if $BESTATUS eq 'yes' && $DISPLAY_POSITION eq 0}
                                            <table id="showAccountsContactsInfoTr"  width="100%" cellspacing="0" cellpadding="0" border="0">
                                            <tr><td colspan="4">
                                                <div id="showAccountsContactsInfo" name="showAccountsContactsInfo"></div>
                                            </td></tr>
                                            </table>
                                        {/if}
                                       <div name='displayfields' style="display:block;width:100%">
                                                    {include file='DetailView/ModuleDetailFields.tpl'}
                                      </div>
                                    {if $BESTATUS eq 'yes' && $DISPLAY_POSITION eq 1}
                                        <table id="showAccountsContactsInfoTr"  width="100%" cellspacing="0" cellpadding="0" border="0">
                                        <tr><td colspan="4">
                                            <div id="showAccountsContactsInfo" name="showAccountsContactsInfo"></div>
                                        </td></tr>
                                        </table>
                                    {/if}
                                    {*-- End of Blocks--*} 
                                    <!-- Entity information(blocks) display - ends -->
                                    
                                 
									

									<!-- Product Details informations -->
									<!--{*
									    做一个非空判断，如果显示内容为空就不显示
									    @reason 0012552 产品查看界面，多余一个【产品】区块，希望隐藏，如图。
									    @author tujt 2014-11-17
									*}-->
									{if $ASSOCIATED_PRODUCTS != ''}
									<table border=0 cellspacing=0 cellpadding=0 width=100%>
                						{$ASSOCIATED_PRODUCTS}
                					</table>
									{/if}
									{if $MODCOMMENTDISPLAYRIGHT neq 'yes'&& 'ModComments'|@isPermitted:'index' eq 'yes'}
                                    <table width="100%" cellspacing="0" cellpadding="0" border="0">
                                    <tr><td style="width:100%;">
                                        <div style="width:auto;" id="modcommentdiv">
                                            {if $COMMENTMODE neq 'concise'}
                                        {include file="modules/ModComments/widgets/DetailViewBlockCommentNew.tpl"}
                                    {else}
                                        {include file="modules/ModComments/widgets/DetailViewBlockCommentOld.tpl"}
                                    {/if}
                                        </div>
                                    </td></tr>
                                    </table>
									{/if}
									</form>
									
                                    <!-- The following table is used to display the buttons -->
    								<table id='approvelogtr' name="approvelogtr" style='display:none;' border=0 cellspacing=0 cellpadding=0 width=100%>
                                    <!-- {*if $APPROVE|@count neq 0*} -->
        			                	<tr>
        									<td style="padding:0px;" >
        										<table border=0 cellspacing=0 cellpadding=0 width=100%>
        											<tr><td>
        											{assign var='arrawcls' value=''}
        											<div class="DivCName DivCNamehover" onclick="showHideStatus('approveStaus','approvecol');">
        												<span class="{$arrawcls}" id="approvecol"></span>{'approvelog'|@getFixedLabel}
        											</div>
        											</td></tr>
        											<tr>
        												<td id="approveStaus" name="approveStaus" style='display:block;'>
        													<!-- {*include file= 'Approve/ApproveLogEntries.tpl'*} -->
        												</td>
        											</tr>
        										</table>
        									</td>
        								</tr>
                                    <!-- {*/if*} -->
    
                                    </table>
                                 </td>
								{if $labelinfo.tagdisplayright eq 'yes' || $MODCOMMENTDISPLAYRIGHT eq 'yes'}
									<td id="modcommentblock_paddingtd" class="modcommentblock_paddingtd ld-bg-color" style="width: 12px;min-width: 12px"></td>
									<td id="modcommentblock_parenttd" style="vertical-align: top;width: 60px;">
										<div id="modcommentblock_icon">
											<div data-status="no" id="modcommentblock_Expanddiv" data-frommodule="{$MODULE}" data-record="{$UIKEY}" class="DivCName DivCNamehover modcommenttag-changeicon-div">
												<i class="ld-fonticon ld-fonticon-toleft" tag="modcommentblock_icon" name="change_icon" data-tip="{'EXPANSION'|@getFixedLabel}" data-direction="top" data-type="position"></i>
											</div>
											<div id="modcommenttag_icon">
												{if $labelinfo.tagdisplayright eq 'yes'}
													<div class="modcommenttag-icon-div">
														<i class="ld-fonticon ld-fonticon-approve"></i>
														<div class="modcommenttag-icon-text">{'Tag'|@getFixedLabel}</div>
													</div>
												{/if}
												{if $MODCOMMENTDISPLAYRIGHT eq 'yes' && $HAVEMODCOMMENTS neq 'no'}
													<div class="modcommenttag-icon-div">
														<i class="ld-fonticon ld-fonticon-approve"></i>
														<div class="modcommenttag-icon-text">{'COMMENT1'|@getFixedLabel}</div>
													</div>
												{/if}
											</div>
										</div>
										<div style="max-width:400px;background-color: #fff;padding-bottom: 8px;display: none" id="modcommentdiv" name="modcommentdiv" >
											{if $labelinfo.tagdisplayright eq 'yes'}
												{include file="DetailView/DetailViewBlockTag.tpl"}
											{/if}
											{*wym 240123 BUG20240123-40 公告-页面设置-开启标签，不生效，单据详情还是不显示标签*}
											{*以前的代码不知道为什么要控制公告模块不显示右侧小按钮，目前改bug先把标签栏放出来，评论栏等待测试部讨论*}
											{if $MODCOMMENTDISPLAYRIGHT eq 'yes' }
												{include file="modules/ModComments/widgets/DetailViewBlockCommentNew.tpl"}
											{/if}
										</div>
									</td>


								{/if}
                              </tr>
                            </table>
				        </div>
						
					 </div>
					
					</td>
                    
				</tr>
			</table>
		
        </form>
        </div>
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


{if $MODULE eq 'Products'}
<script language="JavaScript" type="text/javascript" src="include/js/modules/Products/Productsslide.js"></script>
<script language="JavaScript" type="text/javascript">Carousel();</script>
{/if}


<script>
/**
 * 检查是否是iFrame嵌套页面
 * @project 天润呼叫中心集成
 * @author Tujt 2014-05-15
 */
IsFrameElement();

var relcount = "{$smarty.foreach.relatedfor.iteration}";
if(relcount > 0)
	set_rel_count();
set_rel_createbtn();
var modulename = '{$MODULE}';
var recordid = '{$ID}';
var isapprovemod = '{$APPROVEMOD}';//是否开启审批
window.ready = readylistBind();
{literal}
function readylistBind(){
	showModCommentsHtml(modulename,recordid);
}
{/literal}
</script>
<!-- added for validation -->
<script language="javascript">
	var fieldinfoobjs ='';
     var COLUMN_FIELDS_VALUE='{$COLUMN_FIELDS_VALUE}';//界面值
     COLUMN_FIELDS_VALUE=COLUMN_FIELDS_VALUE.replace(/(\r\n)|(\n)/g,'<br>');//备注等文本域换行
	var editviewinfojsonobj='{$FIELDINFOJSON}';
	var fieldname = new Array({$VALIDATION_DATA_FIELDNAME});
	var fieldlabel = new Array({$VALIDATION_DATA_FIELDLABEL});
	var fielddatatype = new Array({$VALIDATION_DATA_FIELDDATATYPE});
	var PageRecordPopupobj=PageRecordPopup.load('{$MODULE}');
    PageRecordPopupobj.pagetype='detailview';
	PageRecordPopupobj.fieldname="{$VALIDATION_DATA_FIELDNAME}";
	PageRecordPopupobj.fieldlabel="{$VALIDATION_DATA_FIELDLABEL}";
	PageRecordPopupobj.fielddatatype="{$VALIDATION_DATA_FIELDDATATYPE}";
    PageRecordPopupobj.record="{$ID}";
    PageRecordPopupobj.module='{$MODULE}';
    PageRecordPopupobj.list_link_field='{$MODULELINKFIELD}';
    PageRecordPopupobj.smownercolumnname='{$SMOWNERCOLUMNNAME}';
	PageRecordPopupobj.smownercolumnname_value = '';
	if(editviewinfojsonobj!=null&&editviewinfojsonobj!=undefined&&editviewinfojsonobj!='')
	{
		var fieldinfoobjs=  eval('('+ editviewinfojsonobj +')')?eval('('+ editviewinfojsonobj +')'):JSON.parse(editviewinfojsonobj);
		cur_PageInfo.fieldinfoobjs.push(fieldinfoobjs);
		
        var COLUMN_FIELDS_VALUEobj= eval('('+ COLUMN_FIELDS_VALUE +')')?eval('('+ COLUMN_FIELDS_VALUE +')'):JSON.parse(COLUMN_FIELDS_VALUE);
	}
    PageRecordPopupobj.fields=fieldinfoobjs;
    PageRecordPopupobj.column_fields_value=COLUMN_FIELDS_VALUEobj;
 
    var piclistdenpencyfields='{$PICKLISTDEPENCYFIELDS}';
   PageRecordPopupobj.picklistdepencyfields="";
  if(PageRecordPopupobj.picklistdepencyfields!=null&&piclistdenpencyfields!="")
        PageRecordPopupobj.picklistdepencyfields=eval('('+ piclistdenpencyfields +')')?eval('('+ piclistdenpencyfields+')'):JSON.parse(piclistdenpencyfields);
    
    PageRecordPopupobj.picklistdepency=eval('('+ '{$PICKIST_DEPENDENCY_DATASOURCE}' +')')?eval('('+ '{$PICKIST_DEPENDENCY_DATASOURCE}' +')'):JSON.parse('{$PICKIST_DEPENDENCY_DATASOURCE}');
    var jsonpicklistcontent='{$PICKLISTCONTENT}';
    var picklistcontent=eval('('+ jsonpicklistcontent +')')?eval('('+ jsonpicklistcontent +')'):JSON.parse(jsonpicklistcontent);
   if(picklistcontent!=""&&picklistcontent!=undefined)
    {ldelim}
       for(var k=0;k<picklistcontent.length;k++)
       {ldelim}
                        //下拉框
           var fieldname=picklistcontent[k].fieldname;
            PageRecordPopupobj.picklistobjarray[picklistcontent[k].fieldname]=new cls_picklist(picklistcontent[k].fieldname,picklistcontent[k].optionvalue);
            if(PageRecordPopupobj.picklistdepencyfields!=null&&PageRecordPopupobj.picklistdepencyfields!=""&&PageRecordPopupobj.picklistdepencyfields[fieldname]!=undefined)
            {ldelim}
               
                PageRecordPopupobj.picklistobjarray[picklistcontent[k].fieldname].setparentDependField(PageRecordPopupobj.picklistdepencyfields[fieldname]);
               // PageRecordPopupobj.picklistobjarray[PageRecordPopupobj.picklistdepencyfields[fieldname]].setchildDependField(picklistcontent[k].fieldname);              
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
     PageRecordPopupobj.type="detailviewpage";
     PageRecordPopupobj.divid="DetailContent";
     var jsonfieldrulenamefieldnames='{$jsonFieldRuleFieldNames}';
    if(jsonfieldrulenamefieldnames!=null&&jsonfieldrulenamefieldnames!=undefined)
    {ldelim}
        //布局规则的查询字段
        PageRecordPopupobj.fieldrulefieldnames=eval('('+jsonfieldrulenamefieldnames +')')?eval('('+ jsonfieldrulenamefieldnames +')'):JSON.parse(jsonfieldrulenamefieldnames);
    {rdelim}
  {literal}
  PageRecordPopupobj.uitypes=[];
     PageRecordPopupobj.InitPageValue=function()
     {
            this.fieldname_fields=[];
            this.column_fields=[];
            var that=this;
            ld.each(this.fields,function(index,fieldinfo){
                var fieldname=fieldinfo.fieldname;
                that.fieldname_fields[fieldname]=fieldinfo;
                that.column_fields[fieldinfo.columnname]=fieldinfo;
                PageRecordPopupobj.uitypes[fieldname]=fieldinfo.uitype;
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
             //   console.log(tmpvalues);
             fieldruleobj.setValues(tmpvalues);
        }
  {/literal}
     // PageRecordPopup.setDetailViewTitle(PageRecordPopupobj.divid);
</script>
</td>
	<td align=right valign=top>
{*		<img src="{'showPanelTopRight.gif'|@lingdang_imageurl:$THEME}">*}
	</td>
</tr>
</table>
<!--End Contents-->

<!--回款计划---->
<div id="CreatePaymentplan" class="D_pop_box LdPopWidth650px" style="display:none;">
<div id="Paymentplan_form_div"></div>
</div>
<!--合同订单 创建派息单-->
<div id="CreateDividendOrder" class="D_pop_box LdPopWidth1100px" style="display:none;">
<div id="DividendOrder_form_div"></div>
</div>

<div id="CreateSendPayment" class="D_pop_box LdPopWidth650px" style="display:none;">
<div id="SendPayment_form_div"></div>    
</div>

<div id="SubmitApprove" class="D_pop_box LdPopWidth400px" style="display:none;"></div>			 
<div id="ApproveBlocks" class="D_pop_box LdPopWidth650px" style="display:none;"></div>
<div id="approvelog" class="D_pop_box LdPopWidth800px" style="display:none;z-index:9999;"></div>
<div id="approvestepresult" class="D_pop_box LdPopWidth800px" style="display:none;z-index:9999;"></div>
<div id="cancelApproved" class="D_pop_box LdPopWidth400px" style="display:none;"></div>

<div id="dvChangePaymentPlan" class="D_pop_box LdPopWidth1100px" style="display:none;"></div>

<div id="SetPaymentplan" class="D_pop_box LdPopWidth450px" style="display:none;">
<div id="Set_form_div"></div>    
</div>
<!--相关信息设置div-->
<div id="SetRelatedlists_div" class="D_pop_box LdPopWidth600px" style="display:none; position: absolute; z-Index:9999"></div>
<div id="Quicksetactions_div" class="D_pop_box LdPopWidth600px" style="display:none; position: absolute; z-Index:9999"></div>
<!--出库单确认出库后短信提醒-->
{if ($MODULE eq "OutboundOrder" && $SENDINFORMDEPLOY eq 1 && $SMS_ISSET eq "YES" && $SENDTYPE eq "yes") || ($MODULE eq "SalesOrder" && $SENDTYPE eq "yes")}
 <script type="text/javascript">
  CreateSendInform('{$MODULE}',document.getElementById("sendInformid"),'divSendInform',DetailView.record.value);
 </script>
{/if}
<div id="divSendInform" class="D_pop_box LdPopWidth600px" style="display:none;">
    <div id="divSendInform_div" ></div>
</div>

<div id="divSendInform_content" class="D_pop_box LdPopWidth900px" style="display:none;z-index:100000;">
    <div id="divSendInform_content_div"></div>
</div>

<!--回款计划-->
<script type="text/javascript">
	var kiserror = "{$KISERROR}";
	if(kiserror != '')
	{ldelim}
        RemindsMsg("","LdPopWidth400px","","yes","",kiserror);
	{rdelim}
 </script>
{if $CREATE eq 'yes' && $MODULE eq "SalesOrder" && $PAYMENTPLANCREATE eq 'permitted' && $DEPLOYVALUE eq 0}
 <script type="text/javascript">
    NewPaymentPlan(document.getElementById("createPaymentid"),'CreatePaymentplan',DetailView.record.value,0,'yes','yes');
 </script>
{/if}
{if $CREATE eq 'yes' && $MODULE eq "ServiceContracts" && $PAYMENTPLANCREATE eq 'permitted' && $DEPLOYVALUE eq 0}
 <script type="text/javascript">
   /*
  andrew
  20141124
  合同关联创建回款计划  
  */
  NewPaymentPlan(document.getElementById("createPaymentid"),'CreatePaymentplan',DetailView.record.value,0,'yes');
 </script>
{/if}
{if $CREATE eq 'yes' && ($MODULE eq "Invoice") && $PAYMENTPLANCREATE eq 'permitted' && $DEPLOYVALUE eq 1}
 <script type="text/javascript">
  NewPaymentPlan(document.getElementById("createPaymentid"),'CreatePaymentplan',DetailView.record.value,0,'yes');
 </script>
{/if}
{if $CREATE eq 'yes' && $MODULE eq "PurchaseInvoice" && $PAYMENTPLANCREATE eq 'permitted' && $DEPLOYVALUE eq 1}
 <script type="text/javascript">
  NewSendPayment(document.getElementById("createPaymentid"),'CreateSendPayment',DetailView.record.value,0,'yes');
 </script>
{/if}

<!--付款计划-->
{if $CREATE eq 'yes' && $MODULE eq "PurchaseOrder" && $SENDPAYMENTCREATE eq 'permitted' && $DEPLOYVALUE eq 0}

     <script type="text/javascript">
      //CreateSendPayment(document.getElementById("createSendPaymentid"),'CreateSendPayment',DetailView.record.value);
      NewSendPayment(document.getElementById("createSendPaymentid"),'CreateSendPayment',DetailView.record.value,0,'yes');
     </script>
{/if}


<div id="printSalesOrderDiv" class="D_pop_box LdPopWidth400px" style="display:none;">
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'PRINT'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('printSalesOrderDiv');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">   
        <tr>
            <td align="right">
                {'Please_select_a_template'|@getFixedLabel}
            </td>
            <td>
                <select name="autotemplateprinttype" id="autotemplateprinttype">
                    {foreach item=autotemplateinfo key=sequenceid from=$TEMPLATEPRINTS}
						{assign var=autoprintid value=$templateinfo.2}
						{if $autotemplateinfo.1 eq 1}
							 <option value='{$autoprintid}' selected="true" title='{$autotemplateinfo.0}'>{$autotemplateinfo.0}</option>
						{else}
						<option value='{$autoprintid}' title='{$autotemplateinfo.0}'>{$autotemplateinfo.0}</option>
						{/if}
				    {foreachelse}
						<option value="0"title=' {'Please_select_print_templates'|@getFixedLabel}'>{'Please_select_print_templates'|@getFixedLabel}</option>
				    {/foreach}
                </select>
            </td>
        </tr>
    </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'CONFIRME'|@getFixedLabel}" onclick="var printid=document.getElementById('autotemplateprinttype').value;if(printid==0) {ldelim}
            var confirm_str = arrJsPopLabel['PLEASESELECTPRINTTEMPLATES'];
            RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
            return false;
            {rdelim} OpenNewWebTab('index.php?module=Settings&action=TemplatePrintHtml&tabname={$MODULE}&printid='+printid+'&record={$ID}');"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('printSalesOrderDiv')"/> 
    </div>
</div> 

<!--判断合同订单保存后是否需要弹出打印窗口-->
{if $ISPRINTSALESORDER eq 'yes' && $MODULE eq "SalesOrder"}
 <script type="text/javascript">
    NewPrintSalesOrder(this,'printSalesOrderDiv');
 </script>
{/if}


<div id="dvChangeSendPayment" class="layerPopup" style="display:none;width:80%"></div>

<div id="SetSendPayment" class="D_pop_box LdPopWidth500px" style="display:none;">
<div id="SetSendPayment_form_div"></div>
</div>

<!---合同订单--发送短信--->
<div id="divSendSMSSalesOrder" class="D_pop_box LdPopWidth600px" style="display:none;">
<div id="divSendSMSSalesOrder_Content"></div>
</div>

<!---合同订单--发送短信--设置接收人手机字段--->
<div id="divSendSMSSalesOrder_Phone" class="D_pop_box LdPopWidth300px" style="display:none;">
<div id="divSendSMSSalesOrder_Phone_Content"></div>
</div>

<!---合同订单--发送短信--设置定时规则--->
<div id="divSendSMSSalesOrder_Time" class="D_pop_box LdPopWidth500px" style="display:none;">
<div id="divSendSMSSalesOrder_Time_Content"></div>
</div>

<!---合同订单--发送短信--设置短信内容--->
<div id="divSendSMSSalesOrder_SMSContent" class="D_pop_box LdPopWidth900px" style="display:none;">
<div id="divSendSMSSalesOrder_SMSContent_Content"></div>
</div>

<!--判断合同订单明细界面是否需要弹出发送短信窗口
{if $SENDSMSSALESORDERDEPLOY eq 'yes' && $MODULE eq "SalesOrder"}
 <script type="text/javascript">
    sendSMSSalesOrder(this,'divSendSMSSalesOrder',{$ID},'{$SENDSMSPRODUCTIDS}');
 </script>
{/if}-->
<!---销售退货单--发送短信--->
<div id="divSendSMSSalesBack" class="D_pop_box LdPopWidth600px" style="display:none;">
<div id="divSendSMSSalesBack_Content"></div>
</div>
<!---销售退货单--发送短信--设置接收人手机字段--->
<div id="divSendSMSSalesBack_Phone" class="D_pop_box LdPopWidth300px" style="display:none;">
<div id="divSendSMSSalesBack_Phone_Content"></div>
</div>
<!---合同订单--发送短信--设置短信内容--->
<div id="divSendSMSSalesBack_SMSContent" class="D_pop_box LdPopWidth900px" style="display:none;">
<div id="divSendSMSSalesBack_SMSContent_Content"></div>
</div>
<!--判断合同订单明细界面是否需要弹出发送短信窗口-->
{if $SENDSMSSALESBACKDEPLOY eq 'yes' && $MODULE eq "SalesBack"}
 <script type="text/javascript">
	CreateSendInform('SalesBack',document.getElementById('sendInformid'),'divSendInform',{$ID});
 </script>
{/if}
<!--销售---结束退货——已入库-->
<div id="instockroomEndOperation_In" class="D_pop_box LdPopWidth400px" style="display:none;">
    
    <div class="D_pop_tit">
    	<strong class="D_ptita">{'teotro'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('instockroomEndOperation_In');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
    
	<table class="D_pop_bod" width="100%" border="0" cellspacing="1" cellpadding="1">
      <tr>
        <td>
    		<p>
            1.{'TCDSIW'|@getFixedLabel}<br>
            2.{'ATERASSISTE'|@getFixedLabel}<br>
            3.{'ATRINATRASEAD'|@getFixedLabel}</p>
            <div id="instockroomEndOperation_In_div"></div>
    
        </td>       
      </tr>
    </table>
     
    <div class="D_pbtn">
        <input type="button" class="D_pbtnok" onclick="instockroomEndOperationButton({$ID},'已入库');" value="{'ENDRETURNGOODS'|@getFixedLabel}"/> 
        <span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" onclick="fninvshnew('instockroomEndOperation_In');" value="{'CANCEL'|@getFixedLabel}"/> 
    </div>
</div>

<!--销售---结束退货——未入库--> 
<div id="instockroomEndOperation_NotIn" class="D_pop_box LdPopWidth300px" style="display:none;width:400px;">

    <div class="D_pop_tit">
    	<strong class="D_ptita">{'teotro'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('instockroomEndOperation_NotIn');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod" cellspacing="1" cellpadding="1" border="0">   
        <tr>
            <td>
                <p style="margin-left:10px;">
                1.{'TCDSINW'|@getFixedLabel}<br>
                2.{'ATERASSISTACBCVWCI'|@getFixedLabel}<br>
                3.{'ATRINATRASEAD'|@getFixedLabel}</p>
                <div id="instockroomEndOperation_NotIn_div"></div>
            </td>
        </tr>
    </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'ENDRETURNGOODS'|@getFixedLabel}" onclick="instockroomEndOperationButton({$ID},'未入库');"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('instockroomEndOperation_NotIn');"/> 
    </div>
</div>

<!--采购---结束退货——已出库-->
<div id="instockroomEndOperation_Out" class="D_pop_box LdPopWidth400px" style="display:none;">
    <div class="D_pop_tit">
        <strong class="D_ptita">{'teotro'|@getFixedLabel}</strong>
        <a class="D_ptitc" onclick="fninvshnew('instockroomEndOperation_Out');">
			<img src="themes/icon/pop_close.png" class="D_ptitcimg" />
		</a>
	</div>
    
	<table class="D_pop_bod" width="100%" border="0" cellspacing="1" cellpadding="1">
      <tr>
        <td>
    		<p>
            1.{'PURCHASEENDRETURN1'|@getFixedLabel}<br/>
            2.{'ATERASSISTE'|@getFixedLabel}<br/>
            3.{'ATRINATRASEAD'|@getFixedLabel}</p>
            <div id="instockroomEndOperation_Out_div"></div>
        </td>
      </tr>
    </table>
    
    <div class="D_pbtn">
        <input type="button" class="D_pbtnok" onclick="instockroomEndOperationButton({$ID},'已出库');" value="{'ENDRETURNGOODS'|@getFixedLabel}"/>
        <span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" onclick="fninvshnew('instockroomEndOperation_Out');" value="{'CANCEL'|@getFixedLabel}"/>
    </div>
</div>

<!--采购---结束退货——未出库--> 
<div id="instockroomEndOperation_NotOut" class="D_pop_box LdPopWidth300px" style="display:none;width:500px;">

    <div class="D_pop_tit">
    	<strong class="D_ptita">{'teotro'|@getFixedLabel}</strong>
        <a href="javascript:fninvshnew('instockroomEndOperation_NotOut');" class="D_ptitc">
            <img class="D_ptitcimg" src="themes/icon/pop_close.png" alt="{'CLOSE'|@getFixedLabel}" title="{'CLOSE'|@getFixedLabel}"/>
        </a>
    </div>
	<table class="D_pop_bod D_pop_bod_line" border="0" cellpadding="1" cellspacing="0">
      <tr>
        <td>
    		<table width="100%" border="0" cellspacing="0" cellpadding="5">    
            <p>
            1.{'PURCHASEENDRETURN2'|@getFixedLabel}<br>
            2.{'ATERASSISTACBCVWCI'|@getFixedLabel}<br>
            3.{'ATRINATRASEAD'|@getFixedLabel}</p>
            <div id="instockroomEndOperation_NotOut_div"></div>
            </table>
        </td>
      </tr>
    </table>
    <div class="D_pbtn">
    	<input type="button" class="D_pbtnok" value="{'ENDRETURNGOODS'|@getFixedLabel}" onclick="instockroomEndOperationButton({$ID},'未出库');"/><span>&nbsp;</span>
        <input type="button" class="D_pbtncancel" value="{'CANCEL'|@getFixedLabel}" onclick="fninvshnew('instockroomEndOperation_NotOut');"/>   
    </div>
</div>

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

<!--同步库存，弹出框-->
<div id="synchronousInventoryDiv" class="D_pop_box LdPopWidth400px" style="display:none;">
	<div class="D_pop_tit">
    	<strong class="D_ptita">{'DATAEXCHANGE'|@getFixedLabel}——{'SYNCHRONOUSINVENTORY'|@getFixedLabel}</strong>
        <a class="D_ptitc" href="javascript:hideOptions('synchronousInventoryDiv');puyoungJS_DialogBox.unblock();">
            <img title="关闭" alt="关闭" src="themes/icon/pop_close.png" class="D_ptitcimg">
        </a>
    </div>

	<table class="D_pop_bod" width="100%" cellspacing="1" cellpadding="2" border="0">
	  <tr><td class="Note">{'SYNCHRONOUSINVENTORYNOTE'|@getFixedLabel}</td></tr>
	  <tr><td><input type="radio" id="synchronousOne" name="Synchronous" checked="true">{'SYNCHRONOUSINVENTORYNOTEONE'|@getFixedLabel}</td></tr>
	  <tr><td><input type="radio" id="synchronousTwo" name="Synchronous">{'SYNCHRONOUSINVENTORYNOTETWO'|@getFixedLabel}</td></tr>
	</table>

    <div class="D_pbtn">
        <input class="D_pbtnok" type="button" value="{'SAVE'|@getFixedLabel}" onclick="disableStyle();synchronousInventory()"/><span>&nbsp;</span>
            <input type="button" onclick="fninvshnew('synchronousInventoryDiv');" value="{'CANCEL'|@getFixedLabel}" class="D_pbtncancel">   

    </div>
</div>

<!--分配 修改负责人-->
<div id="smowneredit" class="D_pop_box LdPopWidth350px" style="display:none;">
<div id="smowneredit_form_div"></div>
</div>
<!---基金->计提--->

<div id="div_fund_accured_pop" class="D_pop_box LdPopWidth350px" style="display:none;">
    <div id="fund_accured_pop_content"></div>
</div>

<script>
setProductDivWidth.pageMode='DetailView';

//单据详情页，显示负责人


var salesbackstatus = '{$SALESBACKSTATUS}';
ld(document).ready(function(){ldelim}setProductDivWidth();{rdelim});

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



</script>

	</td>
   </tr>
</table>
<div id="Createreceivablesforecast" class="D_pop_box LdPopWidth650px" style="display:none;">
<div id="potentialsid_form_div"></div>
</div>
<script language="javascript">
    
   
   
    var tmpstr='{$DATETIMESTR}';
     var datetimestr=  eval('('+ tmpstr +')')?eval('('+ tmpstr +')'):JSON.parse(tmpstr);
	var version_account = '{$VERSION_ACCOUNT}';
	var accountid = '{$ACCOUNTID}';
	var contactid = '{$CONTACTID}';
	var bestatus = '{$BESTATUS}';
	var modulename = '{$MODULE}';
	var recordid = '{$ID}';
	var SalesOrder_print='{$ISPRINT}';
	var createpopdividendorder='{$CREATEPOPDIVIDENDORDER}';
	var isadmin='{$keyadmin}';
    var modulebillduptip='{$MODULEBILLNOTIP}';
    
	var ordertype_onclick= "{$ordertype_onclick}";	//源美特殊控制
	//评论s
	if(modulename=='SalesOrder'||modulename=='Quotes')//edit:can reason:16195: 合同订单、报价单、服务合同查看界面：没有评论区块，手机端是有的应该统一
		showModCommentsHtml(modulename,recordid);
	if(ordertype_onclick == 'yes' && setProductToolFieldDisplay != undefined){
		setProductToolFieldDisplay('detail');
	}
	setBLockForLink();
</script>
{*<!--edit:kevin date:2013-10-21 reason:5350-->*}
{if $MODULE eq 'Vendors'}
	<form name="SendMail"><div id="sendmail_cont" style="z-index:100001;display:none;"></div></form>
{else if $MODULE eq 'PriceBooks'}
	<div id="editlistprice" style="width:300px;display:none;"></div>
    <!---选择产品的基本查询-->
    {include file="basicSearch.tpl"}
 {/if}
 
 
<script type="text/javascript">
 var haigersavetip='{$HaigeSaveTip}';
    {literal}
    //编号重复的提示
    
   if(haigersavetip!=''&&haigersavetip!=undefined)
          RemindsMsg("","LdPopWidth400px","",modulename,"","",haigersavetip);
          
    setdupBillNoTip(modulebillduptip,PageRecordPopupobj.fields);
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
                                                     CrmPopup.global_listPopupObj.pop();
    												if($('refresh-Products')){
    													$('refresh-Products').click();
    												}
                                    }
                            }
                    );
          
    }
    
    if(bestatus == 'YES')
        {
          
            getAccountsContactsInfo(accountid,contactid,modulename,'DetailView');
        }
        if(createpopdividendorder=='yes')
        {
            detailbutton_click(null,'SalesOrder','dividendcreate',recordid);
        }
    {/literal}
</script>



{if $AUTOEXEC eq 'yes'}
<script>


    createTemplateCalendars("index.php?module=Calendar&action=EditView&autoexec=yes&product_id={$ID}&parent_id={$ID}&frommodule={$MODULE}");
</script>
{/if}
<script>
ld(function(){ldelim}
  PageRecordPopupobj.InitPageValue();
  function setHeight(){
    var a = ld('.Header').outerHeight(),//头部高度
        b = ld('.DivC table:first-child').outerHeight(),//标签+按钮高度
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
</script>