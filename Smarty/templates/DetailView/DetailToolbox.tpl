{if $isprint eq 1 && $TEMPLATEPRINTS neq 'NOTEMPLATEPRINT'&& $MODULE neq 'Attachment'}
  <div class="Title">
    <a href="javascript:void(0);" style="text-decoration:none;">
      {'TOOLS'|@getFixedLabel}
    </a>
  </div>
  <ul>
    <li>
      <select id="templateprinttype" class="borderALL"  name="templateprinttype">
        {foreach item=templateinfo key=sequenceid from=$TEMPLATEPRINTS}
            {assign var=printid value=$templateinfo.2}
          {if $templateinfo.1 eq 1}
             <option value='{$printid}' selected="true" title='{$templateinfo.0}'>{$templateinfo.0}</option>
          {else}
          <option value='{$printid}' title='{$templateinfo.0}'>{$templateinfo.0}</option>
          {/if}
        {foreachelse}
          <option value="0"title=' {'Please_select_print_templates'|@getFixedLabel}'>{'Please_select_print_templates'|@getFixedLabel}</option>
        {/foreach}
     </select>
    </li>
    {if $TEMPLATEPRINTS neq 'NOTEMPLATEPRINT'}
		{assign var=export_pdf_action value="CreatePDF"}
        <li>
        <div>
            <div style="float: left;width:88%;">
              <a href="javascript:void(0);" onclick="var printid=document.getElementById('templateprinttype').value;if(printid==0) {ldelim}
                 var confirm_str = arrJsPopLabel['PLEASESELECTPRINTTEMPLATES'];
                 RemindsMsg('','LdPopWidth400px','','yes','',confirm_str);
                 return false;
                 {rdelim} OpenNewWebTab('index.php?module=Settings&action=TemplatePrintHtml&tabname={$MODULE}&printid='+printid+'&record={$ID}')" style="margin-top: 10px;">
                <span class="Text">
                  {'PRINT'|@getFixedLabel}
                </span>
              </a>
            </div>
              <div style="float: right;width:12%;cursor: pointer;" onclick="getLinksUrl('','module','tools_export_pdf');">
                <b style="float: right;margin:20px 0 0 0;" title="{'HELP'|@getFixedLabel}" class="icon-homeimg icon-askgrey"></b>
              </div>
          </div>
        </li>
        <li>
          <a href="javascript:void(0);" onclick="ConvertToPDF(this,'{$MODULE}',{$ID});">
            <span class="Text">
              {'ExporttoPDF'|@getFixedLabel}
            </span>
          </a>
        </li>
        {if $TEMPLATEPRINTS neq 'NOTEMPLATEPRINT' &&  'Emails'|@isPermitted:'Create'   eq 'yes'}
            <li>
              <a href="javascript:void(0);" onclick="javascript:var printid=document.getElementById('templateprinttype').value;if(printid==0) {ldelim}
                 var confirm_str = arrJsPopLabel['PLEASESELECTPRINTTEMPLATES'];
                 RemindsMsg('','LdPopWidth400px','','yes','',confirm_str);
              return false;{rdelim} window.open('index.php?module={$MODULE}&action=SendPDFMail&printid='+printid+'&record={$ID}')">
                <span class="Text">
                  {'Send_Email_Add_PDF'|@getFixedLabel}
                </span>
              </a>
            </li>
        {/if}
    {/if}
  </ul>
{/if}