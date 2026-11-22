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
<script language="JavaScript" type="text/javascript" src="{$JSURL}include/js/modules/EmailListtmp/EmailListtmp.js?v={$GLOBALMINVERSION}"></script>
<script>
function ifselected(obj)
{ldelim}
var id=obj.value;
var box_checked=obj.checked;
var selected=document.massdelete.allselectedboxes.value;
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
            document.massdelete.allselectedboxes.value = result;{rdelim}
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
            document.massdelete.allselectedboxes.value = result;
{rdelim}
      var sel =select_global.length;
      var returnval=false;
      if(sel>-1)
        {ldelim}
            returnval=true;
        {rdelim}
      
          if(returnval==true)
           {ldelim}
           
           {rdelim}
          else
           {ldelim}
              document.getElementById("myProfile").style.display="block";
          {rdelim}
    	
{rdelim}


function massDelete()
{ldelim}        
        var idstring =document.massdelete.allselectedboxes.value;
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
                        document.massdelete.idlist.value=idstring;
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

</script>
<!--中间-->
<link href="themes/softed/Control.css?v={$GLOBALMINVERSION}" rel="stylesheet" type="text/css" />
<form name="massdelete" id="massEmailTemplate" method="POST" onsubmit="puyoungJS_DialogBox.block();">
  <input name="idlist" type="hidden"/>
  <input name="module" type="hidden" value="EmailListtmp"/>
  <input name="action" id="deleteemailtemplate" type="hidden" value="deleteemailtemplate"/>
  <input name="allselectedboxes" type="hidden"/>
    <div class="DivCR">
      <div class="ListViewNavBarAndBtn">
        <div class="ld_listviewnavbar"></div>
        <div class="listview_toprightbox">
          <div class="E_pop_tit_Second_Right ld-listview-btnscontent">
            <div class="ld-button" title="{'CREATE'|@getFixedLabel}" tag="" onclick="EmailTemplate.create();">{'CREATE'|@getFixedLabel}<b name="Create" class="ListView_ButtonNum"></b></div>
          </div>
        </div>
      </div>
      <div>
      	<table class="listEntries fir-center" border="0" cellspacing="1" cellpadding="0" width="100%">
			    <tr>
				    <th>#</th>
  					<th>{'TEMPLATENAME'|@getFixedLabel}</th>
  					<th>{'DESCRIPTION'|@getFixedLabel}</th>
            <th width="100">{'OPERATING'|@getFixedLabel}</th>  
			    </tr>
          {assign var="i" value=0}
			    {foreach name=emailtemplate item=template from=$TEMPLATES}
            {assign var="j" value=$i++}
			      {if $smarty.foreach.emailtemplate.iteration mod 2 eq '1'}
              <tr id="row_{$j}" class="lvtColData" onmouseout="listOnMouseOut(ld(this),'on');" onmouseover="listOnMouseOver(ld(this));">
            {else}
              <tr id="row_{$j}" class="lvtColDataBj" onmouseout="listOnMouseOut(ld(this),'On');" onmouseover="listOnMouseOver(ld(this));">
            {/if}
				      <td>{$smarty.foreach.emailtemplate.iteration}</td>
				      <td>
					      <a href="javascript:;" onclick="EmailTemplate.view({$template.templateid})" ><span title="{$template.templatename}" >{$template.templatename}</span></a>
				      </td>
				      <td title="{$template.description}" >{$template.description}&nbsp;</td>
			        <td class="lastChild">
                <a class="Anu3_a" href="javascript:'" onclick="EmailTemplate.edit({$template.templateid})">{'EDIT'|@getFixedLabel}</a>
                <a class="Anu3_a" href="javascript:void(0);" onclick="EmailTemplate.del({$template.templateid})">{'DELETE'|@getFixedLabel}</a>
              </td>
			      </tr>
			    {/foreach}
		    </table>
      </div>
    </div>
</form>
<!--中间 end-->