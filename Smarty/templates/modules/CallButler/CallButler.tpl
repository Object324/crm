<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/resizetable.js"></script>
<link type="text/css" rel="stylesheet" href="themes/softed/leftmenu.css">
<link type="text/css" rel="stylesheet" href="themes/softed/common.css">
<link type="text/css" rel="stylesheet" href="themes/softed/Control.css">
<style type="text/css">@import url("themes/softed/style.css");</style>
<link rel="stylesheet" href="themes/softed/viewer.min.css" type="text/css" /><!--多选框-->
<link rel="stylesheet" href="themes/softed/select2.css" type="text/css" /><!--多选框-->
<link rel="stylesheet" href="themes/softed/select2-bootstrap.css" type="text/css" />
<link rel="stylesheet" type="text/css" href="crmcommon/css/treeview/jquery.treeview.css" /><!--选部门选用户-->
<link rel="stylesheet" href="crmcommon/css/webuploader/webuploader.css" type="text/css" /><!--附件上传-->
<link rel="stylesheet" href="crmcommon/css/webuploader/bootstrap.min.css" type="text/css" /><!--附件上传-->
<link rel="stylesheet" href="dataCache/tabdatas/skinset.css" type="text/css" /><!--菜单背景色自定义-->

<script type="text/javascript" src="include/jquery/jquery.min.js"></script>
<script type="text/javascript" language="JavaScript">
	var ld = $;
	var global_js_url = '';
	var language='zh';
	if(language=='zh'){
		language='zh-cn';
	}
</script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}crmcommon/js/My97DatePicker/WdatePicker.js"></script><!--时间选择器-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/Inventory.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/json.js"></script>
<script language="JavaScript" type="text/javascript" src="include/language/zh.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/multipingyin.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/picklist.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/FieldDependencies.js"></script>
<script type="text/javascript" src="{$JSURL}include/js/SystemPopup/ComboxPopup.js"></script>
<!-- vtlib customization: Javascript hook -->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/vtlib.js"></script>
<!-- END -->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/MassSMS.js"></script>
<script language="javascript" type="text/javascript" src="{$CRMCOMMONURL}crmcommon/js/scriptaculous/prototype.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/QuickCreate.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/EditView.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ldAjax.js"></script>
<script language="javascript" type="text/javascript" src="include/js/general.js"></script> 
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/MsgPopup.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CommonPagePopup.js?v={$GLOBALMINVERSION}"></script><!--拖拽效果-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupDrag.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CrmPopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/QcPopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/selectSearchPopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PageRecordPopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupLayer.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/MassEditPopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CreatePagePopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/CreatePagePopup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/PopupUserGroup.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/SaveDataRecord.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/selectSearchField.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/SystemPopup/ProgressPopup.js?v={$GLOBALMINVERSION}"></script>


<script type="text/javascript">
var CURRENT_USER_ID = {$CURRENT_USER_ID};
var iskehu001 = 'no';
{literal}
function callButlerSearch()
{
    var callDate = document.getElementById('startmonth').value;//时间   
    var center_type = document.getElementById('center_type').value;//呼叫中心类型
    if(center_type==='电话录音盒'){
        var action_link = 'CallButler';
    }else{
        var action_link = 'CallButler_MultiCenter';
    }
    var callType = document.forms['massdelete'].ddlCallType.value;//类型
    //var callStatus = document.forms['massdelete'].ddlStatus.value;//状态
    var callStatus = '';   
    var custName = document.forms['massdelete'].txtCustName.value;//客户名称  
    var phone = document.forms['massdelete'].txtPhone.value;//电话号码 
    var beginTime = document.forms['massdelete'].txtBeginTime.value;//通话时长，前  
    
    var endTime = document.forms['massdelete'].txtEndTime.value;//通话时长，后
    var searchscope=document.forms['massdelete'].SmOwnerSearchScope.value;//查询范围
   if(beginTime!=""&&endTime!="")
    {
        if(parseInt(beginTime)>parseInt(endTime))
        {
            alert('请正确录入通话时长区间！');
            return false;
        }
    }else if(beginTime!=""&&endTime=="")
    {
        alert('请正确录入通话时长区间！');
            return false;
    }
	//高级
	if(searchscope == 'smowner_search_senior'){
		if(ld('#scope_senioruserids') != undefined){
			searchscope = ld('#scope_senioruserids').val();
		}
	}
	//document.getElementById('status').style.display="inline";
	ld('#rptContentLoading').show();
    new Ajax.Request( 
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:'module=Users&action=UsersAjax&file='+action_link+'&paging=1&ajax=true&search=true&query=true&passCallType='+callType+'&passStatus='+callStatus+'&passCustName='+custName+'&passPhone='+phone+'&passBeginTime='+beginTime+'&passEndTime='+endTime
            +'&passCallDate='+callDate+'&searchscope='+searchscope,
			onComplete: function(response) {
				//document.getElementById('status').style.display="none";
				ld('#rptContentLoading').hide();
                document.getElementById('checksms').innerHTML= response.responseText.split("#########:#")[1];
			}
        }
   );
}

function get_CallButler_ListViewEntries_js(module,url)
{   
    var callDate = document.getElementById('startmonth').value;//时间   
    var callType = document.forms['massdelete'].ddlCallType.value;//类型

    var center_type = document.getElementById('center_type').value;//呼叫中心类型
    if(center_type==='电话录音盒'){
        var action_link = 'CallButler';
    }else{
        var action_link = 'CallButler_MultiCenter';
    }
    //var callStatus = document.forms['massdelete'].ddlStatus.value;//状态
    var callStatus = '';//状态  
    var custName = document.forms['massdelete'].txtCustName.value;//客户名称  
    var phone = document.forms['massdelete'].txtPhone.value;//电话号码   
    var beginTime = document.forms['massdelete'].txtBeginTime.value;//通话时长，前  
    var endTime = document.forms['massdelete'].txtEndTime.value;//通话时长，后
    var searchScope= '';
    if(document.getElementById("SmOwnerSearchScope")!=undefined)
        searchScope=encodeURIComponent(document.getElementById("SmOwnerSearchScope").options[document.getElementById("SmOwnerSearchScope").options.selectedIndex].value);
	//高级
	if(searchScope == 'smowner_search_senior'){
		if(ld('#scope_senioruserids') != undefined){
			searchScope = ld('#scope_senioruserids').val();
		}
	}
    ld('#rptContentLoading').show();
    new Ajax.Request(
            'index.php',
            {queue: {position: 'end', scope: 'command'},
                    method: 'post',
                    postBody: 'module=Users&action=UsersAjax&file='+action_link+'&paging=1&'+url+'&pagechange=true&passCallType='+callType+'&passStatus='+callStatus+'&passCustName='+custName+'&passPhone='+phone+'&passBeginTime='+beginTime+'&passEndTime='+endTime
            +'&passCallDate='+callDate+'&searchscope='+searchScope,
                    onComplete: function(response) {
                           ld('#rptContentLoading').hide();
                            document.getElementById('checksms').innerHTML= response.responseText.split("#########:#")[1];
                    }
            }
    );
}


 //关联单据按钮弹出层 editor:gyq_79 reason:系统右上角呼叫中心报表优化 2018/9/10 14:16 
var global_orign_id = '';
 function connect_record(obj,orign_id){
     global_orign_id = orign_id;
	  ld('#rptContentLoading').show();
     var surl = 'module=Users&action=UsersAjax&file=CallButler_MultiCenter&ajax_action=connect_record';
     ld.ajax({
         url: 'index.php?' + surl,
         type: 'POST',
         data: '',
         dataType: 'json',
         async: true,
         timeout: 5000,
         success: function (data) {
             if (data.code == 1) {
                 ld('#rptContentLoading').hide();
                 var crmPopupobj = CrmPopup.load(data.result.title, save_connect_record, "", "LdPopWidth600px", 'Accounts', '', data.result.oktext, "", data.result.canceltext);
                 crmPopupobj.Okfun.funname = 'merge_fields_direct_saveRecordMerge';
                 crmPopupobj.show(data.result.content);
             }
         }
     })
 }

 function selectRelatedTo_callbutler(fldtype,fldname,mod,id)
{
	var popupobj=CrmPopup.getPopupObj("last");
     var divid=popupobj.divid;
     fldtype = CrmPopup.findHtmlobj(popupobj.divid,fldtype).val()
     var surl = "module="+ fldtype+"&action=Popup&html=Popup_picker&form=vtlibPopupView&fieldname="+fldname+"&frommodule="+mod+"&srcmodule="+mod+"&forrecord="+id+"&popup=yes&page_popup=yes";
     surl+="&popuptype=related_to&select=enable&module_type=callbutler";
	 CrmPopupWindow(mod,surl,fldtype);
    
}
 //关联单据弹出层保存
 function save_connect_record(){
    var module = ld('#related_to_type').val();
    var record = ld('#related_to').val();
    var orign_id = global_orign_id;

     var surl = 'module=Users&action=UsersAjax&file=CallButler_MultiCenter&ajax_action=save_connect_record';
     ld.ajax({
         url: 'index.php?' + surl+'&r_module='+module+'&r_record='+record+'&r_id='+orign_id,
         type: 'POST',
         data: '',
         dataType: 'json',
         async: true,
         timeout: 5000,
         success: function (data) {
            if (data.code == 1) {
                window.location.reload();
            }
         }
     });
 }

function play_click(sef,url){
    new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
			method: 'post',
			postBody:'module=Users&action=FileCheck&passUrl='+url+'&type=callbutler',
			onComplete: function(response) {
			    if(response.responseText.split("#########:#")[1]=='no')
                {
                    alert('录音文件不存在！');
                    return false;
                }
                else
                {
                    var div = document.getElementById('divFileCallButlerlist');
                    if (!!window.ActiveXObject || "ActiveXObject" in window)
                    {

                         div.innerHTML='<object classid="clsid:22D6F312-B0F6-11D0-94AB-0080C74C7E95"> <param name="FileName" value="'+url+'"  /></object>';

                    }
                    else
                    {
                        sef.target="_blank";
                         div.innerHTML = '<embed src="'+url+'" loop="0" autostart="true" hidden="true"></embed>';
                        var emb = document.getElementsByTagName('EMBED')[0];
                        if (emb) {
                            window.location.href = emb.src;
                            setTimeout(function(){div.innerHTML='';},1000);
                        }
                    }

                }
			}
        }
   );
}

{/literal}
</script>
<!--修改编码格式:统一编码：UTF-8-->
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/CommunicationLog.js"></script>
<script language="JAVASCRIPT" type="text/javascript" src="{$JSURL}include/js/smoothscroll.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/general.js"></script>



<body>
<div class="phoneTab">
    <div class="phoneHeadRight">{$CENTERTYPE}{'CALLCENTERREPORT'|@getFixedLabel}</div>
    <span hidden > </span>
    <input type="text" hidden id="center_type" value="{$CENTERTYPE}">
</div>
<div class="clear"></div>
<div class="phoneDiv" id="callbutler_div">
    <form id="massdelete" name="massdelete" method="post" onsubmit="puyoungJS_DialogBox.block()" ENCTYPE="multipart/form-data" action="index.php" style="margin:0px">
    <input type="hidden" value="Users" name="module">
    <input type="hidden" value="CallButler" name="action">
    <div class="pFind_box">
    <table class="Total" border="0" cellspacing="0" cellpadding="3">
	  <tr>
        <td colspan="5">
            <div style="float: left;margin:5px 0;">
                <!--<span class="changeday" style="padding-left:0px;">统计时间:</span>-->
                <a id="today" class="onselected_A changeday changeday-ground" onclick="changeCallButlerSearch(this,'today','{$TODAY}','{$TODAY}')" href="javascript:void(0);">{'checktoday'|@getFixedLabel}</a>
                <a id="yesterday" class="changeday changeday-ground" onclick="changeCallButlerSearch(this,'yesterday','{$YESTERDAY}','{$YESTERDAY}')" href="javascript:void(0);">{'checkyesterday'|@getFixedLabel}</a>
                <a id="week" class="changeday changeday-ground" onclick="changeCallButlerSearch(this,'week','{$WEEKBEGIN}','{$WEEKEND}')" href="javascript:void(0);">{'thisweek'|@getFixedLabel}</a>
                <a id="month" class="changeday changeday-ground" onclick="changeCallButlerSearch(this,'month','{$MONTHBEGIN}','{$MONTHEND}')" href="javascript:void(0);">{'thismonth'|@getFixedLabel}</a>
                <a id="year" class="changeday changeday-ground" onclick="changeCallButlerSearch(this,'year','{$YEARBEGIN}','{$YEAREND}')" href="javascript:void(0);">{'THISYEAR'|@getFixedLabel}</a>
                <input id="startmonth" class="borderALL btn-radius-system" type="text" style="width:162px;margin-left: 12px;font-size: 12px;" findcolumn="ld_singin:createdtime:signedtime:Singin_CreatedTime:D" name="startmonth" value="{$TODAY} - {$TODAY}">
            </div>
            <div style="float: left;padding-left: 10px;padding-top: 0px;margin-top: -1px;">{include file='SearchScope.tpl'}</div>
            <div style="float: left;padding-left: 10px;padding-top: 5px;font-size: 14px;">
                {'SERVICECONTRACTSTYPE'|@getFixedLabel}&nbsp;
                <select class="input_text btn-radius-system" id="ddlCallType" name="ddlCallType" style="font-size: 12px;">
                    {if $typename eq '0'}
                    <option value="0" selected="true">{'ALL'|@getFixedLabel}</option>
                    <option value="1">{'CALLACTIONTYPE1'|@getFixedLabel}</option>
                    <option value="2">{'CALLACTIONTYPE2'|@getFixedLabel}</option>
                    {elseif $typename eq '1'}
                    <option value="0">{'ALL'|@getFixedLabel}</option>
                    <option value="1" selected="true">{'CALLACTIONTYPE1'|@getFixedLabel}</option>
                    <option value="2">{'CALLACTIONTYPE2'|@getFixedLabel}</option>
                    {elseif $typename eq '2'}
                    <option value="0">{'ALL'|@getFixedLabel}</option>
                    <option value="1">{'CALLACTIONTYPE1'|@getFixedLabel}</option>
                    <option value="2" selected="true">{'CALLACTIONTYPE2'|@getFixedLabel}</option>
                    {else}
                    <option value="0" selected="true">{'ALL'|@getFixedLabel}</option>
                    <option value="1">{'CALLACTIONTYPE1'|@getFixedLabel}</option>
                    <option value="2">{'CALLACTIONTYPE2'|@getFixedLabel}</option>
                    {/if}
                </select>
            </div>
        </td>
      </tr>
      <tr>
		<td style="font-size: 12px;">
            {'AccountName'|@getFixedLabel}&nbsp;
            <input type="text" id="txtCustName" name="txtCustName" class="btn-radius-system" />
        </td>
        <td style="font-size: 12px;">
            &nbsp;&nbsp;{'PhoneNumber'|@getFixedLabel}&nbsp;
            <input type="text" id="txtPhone" name="txtPhone" class="btn-radius-system"/>
        </td>
        <td style="font-size: 12px;">
            &nbsp;&nbsp;{'TalkTime'|@getFixedLabel}&nbsp;
            <input type="text" size="8" id="txtBeginTime" name="txtBeginTime" class="btn-radius-system"/>&nbsp;~&nbsp;
            <input type="text" size="8" id="txtEndTime" name="txtEndTime" class="btn-radius-system"/>
        </td>
        <td>
            &nbsp;&nbsp;<input class="createauto b_radius3" id="btnOK" onclick="callButlerSearch();" type="button" value="{'SEARCH'|@getFixedLabel}" />
        </td> 
        <td>
			<!--
            <a href="{$LINKSTRING}" target="_blank" style="text-decoration:underline;font-size:12px;">{'PHONESTEWARDCLIENTDOWNLOAD'|@getFixedLabel}</a> &nbsp;&nbsp;
			 -->
		</td>                                        
	  </tr>
	</table>
    </div>
    </form>	
    <div id="checksms">
        
        {include file="modules/CallButler/CallButlerlist.tpl"}            
    </div>
    <br />
    <br />
    <!--
    <div class="FunCha">
        <fieldset><legend>功能特色</legend>
            <ul>
            <li><span>1</span> 来电弹屏</li>
            <li><span>2</span> 通话录音</li>
            <li><span>3</span> 通话记录查询</li>
            </ul>
        </fieldset>
    </div>
    
    <div class="useEnvent">
        <fieldset><legend>使用环境</legend>
            <img width="334" height="217" src="themes/icon/phone_infoimg.png">
        </fieldset>
    
    </div>
    -->
    
</div>
<div id="rptContentLoading" class="ContentLoadingDiv">
    <img src="themes/icon/loading.gif">
</div>



</body>

<link rel="stylesheet" type="text/css" media="all" href="include/daterangepicker/daterangepicker-bs3.css" />
<script type="text/javascript" src="include/daterangepicker/moment.js"></script>
<script type="text/javascript" src="include/daterangepicker/daterangepicker.js"></script>
<script type="text/javascript" src="include/js/SystemPopup/CrmPopup.js"></script>

{literal}
<script>
 var Listpagepopupobj=new CrmPopup();
 Listpagepopupobj.type="listpage";
 Listpagepopupobj.divid='callbutler_div';
 Listpagepopupobj.searchtype="";//基本查询和高级查询，32156: 单据列表：设置高级查询后，切换查看范围时，不清空高级查询条件
 Listpagepopupobj.url='{$LISTPAGEURL}';
 Listpagepopupobj.module='Users';

 CrmPopup.global_listPopupObj.push(Listpagepopupobj);







function changeCallButlerSearch(obj,type,day1,day2)
{
    document.getElementById('startmonth').value=day1+' '+'-'+' '+day2;
    ld('#startmonth').daterangepicker(null, function(start, end, label) {
      });
    var p=obj.parentNode.children;
    for(var i=0;i<p.length-1;i++)
    {
        if(p[i] != obj){
            if(p[i].nodeName == 'A')
                p[i].className='changeday changeday-ground';
        }
    }
    obj.className='onselected_A changeday changeday-ground';
}

</script>

{/literal}

<script type="text/javascript">
{literal}
    ld(document).ready(function() {
      ld('#startmonth').daterangepicker(null, function(start, end, label) {
      });
   });
{/literal}
</script>
