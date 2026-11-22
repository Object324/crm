{*<!--
/*********************************************************************************
  ** The contents of this file are subject to the lingdang CRM Public License Version 1.0
   * ("License"); You may not use this file except in compliance with the License
   * The Original Code is:  lingdang CRM Open Source
   * The Initial Developer of the Original Code is lingdang.
   * Portions created by lingdang are Copyright (C) lingdang.
   * All Rights Reserved.
  *
 ********************************************************************************/
-->*}
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/ListView.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/smoothscroll.js?v={$GLOBALMINVERSION}"></script>
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/SmsPhrases/SmsPhrases.js?v={$GLOBALMINVERSION}"></script>
<script>
function ifselected(obj)
{ldelim}
var id=obj.value;
var box_checked=obj.checked;
var selected=document.smsdelete.allselectedboxes.value;
var select_global=new Array();
select_global=selected.split(";");
var duplicate = select_global.indexOf(id);
var size = select_global.length-1;
var result = "";
if(box_checked==true){ldelim}
if(duplicate == "-1"){ldelim}
				select_global[size] = id;
                size=select_global.length-1;
			for(i=0;i<=size;i++) {ldelim}
				if(trim(select_global[i])!='')
					result=select_global[i]+";"+result;
			{rdelim}
            document.smsdelete.allselectedboxes.value = result;{rdelim}
{rdelim}
else{ldelim}
if(duplicate != "-1")
			select_global.splice(duplicate,1);
			size = select_global.length-1;
			var i=0;
			for(i=size;i>=0;i--) {ldelim}
				if(trim(select_global[i])!='')
					result = select_global[i]+";"+result;
			{rdelim}
            document.smsdelete.allselectedboxes.value = result;
{rdelim}



 
      var sel =select_global.length;
      var returnval=false;

     
      if(sel>-1)
        {ldelim}
            returnval=true;
        {rdelim}

      
      
          if(returnval==true)
           {ldelim}
           /*
           edit:can
           date:20130409
           reason:0003305: 控制面板 Email模板里面开始进去的时候右边显示 新增模板，不选择任何信息直接点击 左边的删除时，会导致右边的 新增模板按钮不见了
           
           */
              // document.getElementById("myProfile").style.display="none";
           {rdelim}
          else
           {ldelim}
              document.getElementById("myProfile").style.display="block";
          {rdelim}
    	
{rdelim}


function smsDelete()
{ldelim}        
        var idstring =document.smsdelete.allselectedboxes.value;
var arr=new Array();
var xx=0;
        if ( idstring.length<0)
        {ldelim}
            var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
            RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            return false;
        {rdelim}
        else
        {ldelim}                
                if (idstring.length>0)
                {ldelim}
                        document.smsdelete.idlist.value=idstring;
                        arr=idstring.split(";");
                        xx=arr.length-1;
                {rdelim}
               else
                {ldelim}
                        var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
                        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
                        return false;
                {rdelim}
       {rdelim}
		if(confirm(arrJsPopLabel['SUREWANTDELETETHEDELECTED']+" "+xx+" "+arrJsPopLabel['RECORDS']))
		{ldelim}
	        return true;
		{rdelim}
		else
		{ldelim}
			return false;
		{rdelim}

{rdelim}


function createSMSTemplate(){ldelim}
    var submitform=document.getElementById("massSMSTemplate");
    document.getElementById("deletesmstemplate").value="CreateSMSTemplate";
    submitform.submit();
{rdelim}

</script>
<!--中间-->
<link href="themes/softed/Control.css?v={$GLOBALMINVERSION}" rel="stylesheet" type="text/css" />
<form name="smsdelete" id="massSMSTemplate" method="POST" onsubmit="puyoungJS_DialogBox.block();">
	<input name="idlist" type="hidden">
	<input name="module" type="hidden" value="SmsPhrases">
	<input name="action" id="deletesmstemplate" type="hidden" value="deletesmstemplate">
  <input name="allselectedboxes" type="hidden"/>
  <div class="DivCR">
    <div class="ListViewNavBarAndBtn">
      <div class="ld_listviewnavbar"></div>
      <div class="listview_toprightbox">
        <div class="E_pop_tit_Second_Right ld-listview-btnscontent">
            {if $PLATFORM eq 'aliyun'}
            <div class="ld-button" onclick="SyncSMSTemplate();">{'SyncSMSTemplate'|@getFixedLabel}
                <b name="Create" class="ListView_ButtonNum"></b>
            </div>
            {else}
          <div class="ld-button" title="{'CREATE'|@getFixedLabel}" onclick="EditSMSTemplate('');">{'CREATE'|@getFixedLabel}
            <b name="Create" class="ListView_ButtonNum"></b>
          </div>
            {/if}
        </div>
      </div>
    </div>
		<div id="listsms_entries">
			{include file='ListSMSTemplatesEntries.tpl'}
		</div>
  </div>
</form>
<!--中间 end-->