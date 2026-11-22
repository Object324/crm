<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/EditView.js"></script>
<link rel="stylesheet" type="text/css" media="all" href="themes/softed/Paymentplan.css">
<script type='text/javascript' src='{$JSURL}include/js/user_approveby.js'></script>
<script type='text/javascript' src='{$JSURL}include/js/Mail.js'></script>
{if $MODULE eq 'CashBill'||$MODULE eq 'SendCashBill'}
    <link rel="stylesheet" type="text/css" media="all" href="themes/softed/Paymentplan.css">
{/if}

<script type="text/javascript" src="{$JSURL}include/js/modules/ModTracker/ModTrackerCommon.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/modules/ModComments/ModCommentsCommon.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/reflection.js"></script>
<script src="{$CRMCOMMONURL}/crmcommon/js/scriptaculous/scriptaculous.js" type="text/javascript"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/dtlviewajax.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<span id="crmspanid" name="crmspanid" class="ld-detail-edit-small" style="display:none;" onmouseover="New_show('crmspanid');">
	<i class="ld-fonticon ld-fonticon-edit" title="{'EDIT'|@getFixedLabel}"></i>
</span>

<!--分配-->
<div id="smowneredit" class="D_pop_box LdPopWidth350px" style="display:none;">
<div id="smowneredit_form_div"></div>
</div>

<div id="convertleaddiv" style="display:block;position:absolute;left:225px;top:150px;"></div>
<script>
var gVTModule = '{$smarty.request.module|@vtlib_purify}';
{literal}

function showHideStatus(sId,anchorImgId)
{
	oObj = eval(document.getElementById(sId));
	if(oObj.style.display == 'block')
	{
		oObj.style.display = 'none';
		if(anchorImgId !=null){
				document.getElementById(anchorImgId).className = 'On';
//			eval(document.getElementById(anchorImgId)).src =  'icon-homeimg icon-inactivate';
//			eval(document.getElementById(anchorImgId)).alt = '显示';
//			eval(document.getElementById(anchorImgId)).title = '显示';
		}
	}
	else
	{
		oObj.style.display = 'block';
		if(anchorImgId !=null){
			document.getElementById(anchorImgId).className = '';
//			eval(document.getElementById(anchorImgId)).src = 'icon-homeimg icon-activate';
//			eval(document.getElementById(anchorImgId)).alt = '隐藏';
//			eval(document.getElementById(anchorImgId)).title = '隐藏';
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
                /*
				var tagName = document.getElementById(Lay);
				var leftSide = findPosX(obj);
				var topSide = findPosY(obj);
				var maxW = tagName.style.width;
				var widthM = maxW.substring(0,maxW.length-2);
				var getVal = parseInt(leftSide) + parseInt(widthM);
				if(getVal  > document.body.clientWidth ){
					leftSide = parseInt(leftSide) - parseInt(widthM);
					tagName.style.left = leftSide + 230 + 'px';
					tagName.style.top = topSide + 20 + 'px';
				}else{
					tagName.style.left = leftSide + 230 + 'px';
				}
                
				setCoOrdinate(obj.id);
                
				tagName.style.display = 'block';
				tagName.style.visibility = "visible";
                */
                fnvshobj(obj,'lstRecordLayout');
			}
		}
	);
}
{/literal}
function tagvalidate()
{ldelim}
	if(trim(document.getElementById('txtbox_tagfields').value) != '')
		SaveTag('txtbox_tagfields','{$ID}','{$MODULE}');
	else
	{ldelim}
		var confirm_str = "{$APP.PLEASE_ENTER_TAG}";
		RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
		return false;
	{rdelim}
{rdelim}
function DeleteTag(id,recordid)
{ldelim}
	$("vtbusy_info").style.display="inline";
	Effect.Fade('tag_'+id);
	new Ajax.Request(
		'index.php',
                {ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
                        method: 'post',
                        postBody: "file=TagCloud&module={$MODULE}&action={$MODULE}Ajax&ajxaction=DELETETAG&recordid="+recordid+"&tagid=" +id,
                        onComplete: function(response) {ldelim}
						getTagCloud();
						$("vtbusy_info").style.display="none";
                        {rdelim}
                {rdelim}
        );
{rdelim}

//Added to send a file, in Documents module, as an attachment in an email
function sendfile_email()
{ldelim}
	filename = $('dldfilename').value;
	document.DetailView.submit();
	OpenCompose(filename,'Documents');
{rdelim}

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
    {if $IS_REL_LIST neq ''}
    <td class="TdLeft" valign="top">
    {else}
    <td class="TdLeft" style="display:none;" valign="top">
    {/if} 
    	<div class="DivL">
        	<h3 title="{$NAME} -  {$MODULE|@getTranstab} {'INFORMATION'|@getFixedLabel}&#10;{$UPDATEINFO}" 
				onclick='show_detail();'>
				<span id="vtbusy_info" style="display:none;position: absolute;z-index:10;" valign="bottom">
					<img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0">
				</span>
				{$NAME}
			</h3>
			<input type='hidden' id='currrelid' value='0'>
           <div class="Title" onclick='show_related();'>
             <a href="#"><font class="colorLink">{$MODULE|@getTranstab}</font>&nbsp;&gt;&nbsp;{'MOREINFORMATION'|@getFixedLabel}</a>
           </div>
				{if $IS_REL_LIST && $IS_REL_LIST != ''}
					<ul>
					{foreach key=relid item=label from=$IS_REL_LIST name=relatedfor}
						{if  $label == 'BalanceOfAccount'}
							{if $MODBALANCESTR != ''}
								<li><a href="#" id='rel-list-{$relid}' tag="{$label}" onclick='rel_balance_list(this,"{$MODULE}","{$ID}","{$relid}");'>
									<span class="Text">
										{'BALANCEOFACCOUNT'|@getFixedLabel}
										<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
									</span>
									<span id="rel-coount-{$relid}"></span>
								</a></li>
							{/if}
                        {elseif $label == 'SharedUsers'} 
                            <li><a href="javascript:void(0);" id='rel-list-{$relid}' tag="{$label}" onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
								<span class="Text">
									{'ShareUsers'|@getFixedLabel}
									<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
								</span>
								<span id="rel-coount-{$relid}"></span>
							</a></li> 
                        {elseif  $label == 'Home'}
						
                        <script language="javascript" type="text/javascript">var homecontrol=1;</script>
                        <script language="javascript" type="text/javascript" src="modules/Home/Coordination.js"></script>
                        <script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/jquery/jquery.autosize.min.js"></script>
                        <script language="javascript" type="text/javascript" src="uploaddify/jquery.uploadify.min.js"></script>
						      <li><a href="#" id='rel-list-{$relid}' tag="{$label}" onclick='show_workreport(this,"{$MODULE}","{$ID}","{$relid}");'>
									<span class="Text">
										{'LBL_COOPERATIVEWORK'|@getFixedLabel}
										<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
									</span>
									<span id="rel-coount-{$relid}"></span>
								</a></li>
						{else}
							<li><a href="#" id='rel-list-{$relid}' tag="{$label}" onclick='show_rel_list(this,"{$MODULE}","{$ID}","{$relid}");'>
								<span class="Text">
									{if $label == $label|@getTranstab}
										{$label|@getFixedLabel}
									{else}
										{$label|@getTranstab}
									{/if}
									<input type="hidden" id="rel-list-mod-{$label}" value="{$relid}"/>
								</span>
								<span id="rel-coount-{$relid}"></span>
							</a></li>
						{/if}
					{/foreach}
					</ul>
				{else}
					<ul>
						<li>&nbsp;</li>
					</ul>
				{/if}
				{if $MODULE == 'Accounts' || $MODULE == 'ServiceCharge'}
					<input type="hidden" id="modbalancestr" value="{$MODBALANCESTR}"/>
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
							<!--	button start	-->
                            {if !isset($user_id) }<!--	zyh 用户详情附件页不显示	-->
                                {include file="DetailView/DetailButtons.tpl"}
							{/if}
                            <!--	button exit		-->
            				<!--	detail info start	-->
							<div>
								{include file="DetailView/AttachmentDetailTable.tpl"}
							</div>
            				<!--	detail info exit	-->
            				</div>
            			</div>
                        {*
                        by andy
                        快捷操作都不显示，隐藏此TD
                        date 20140623
                        *}
                        {if $ACTION_SHOW_NO eq 'yes'}
                        <td class="right">
                        {else}
                        <td class="right">
                        {/if}
						<!--	Operation	-->
                       
						<div class="DivR">
						{include file="DetailView/DetailOperation_another.tpl"}
						</div>
					</td>
				</tr>
			</table>
		</div>
        </form>
      <!--	related	-->
		<div class="paneldiv">
			{include file="RelatedListsHidden.tpl"}
			<div id='RelatedContent'  style="display:none;">
			
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

{if $MODULE eq 'Products'}
<script language="JavaScript" type="text/javascript" src="include/js/modules/Products/Productsslide.js"></script>
<script language="JavaScript" type="text/javascript">Carousel();</script>
{/if}


<script>

function getTagCloud()
{ldelim}

	var obj = $("tagfields");
	if(obj != null && typeof(obj) != undefined) {ldelim}
		new Ajax.Request(
		    'index.php',
			{ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
			method: 'post',
			postBody: 'module={$MODULE}&action={$MODULE}Ajax&file=TagCloud&ajxaction=GETTAGCLOUD&recordid={$ID}',
			onComplete: function(response) {ldelim}
                                $("tagfields").innerHTML=response.responseText;
                                $("txtbox_tagfields").value ='';
                        {rdelim}
			{rdelim}
		);
	{rdelim}
{rdelim}
getTagCloud();
var relcount = "{$smarty.foreach.relatedfor.iteration}";
if(relcount > 0)
	set_rel_count();
/**
 * 检查是否是iFrame嵌套页面
 * @project 天润呼叫中心集成
 * @author Tujt 2014-05-15
 */
IsFrameElement();
</script>
<!-- added for validation -->
<script language="javascript">
  var fieldname = new Array({$VALIDATION_DATA_FIELDNAME});
  var fieldlabel = new Array({$VALIDATION_DATA_FIELDLABEL});
  var fielddatatype = new Array({$VALIDATION_DATA_FIELDDATATYPE});
</script>
</td>
	<td align=right valign=top><img src="{'showPanelTopRight.gif'|@lingdang_imageurl:$THEME}"></td>
</tr>
</table>
<!--End Contents-->