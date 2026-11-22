</form>
<form action="index.php" method="post" name="TemplateMerge" id="form">
	<input type="hidden" name="module" value="{$MODULE}">
	<input type="hidden" name="parenttab" value="{$CATEGORY}">
	<input type="hidden" name="record" id="record" value="{$ID}">
	<input type="hidden" name="action">
				  
	
	 <!--工具-->
	 <!-- Following condition is added to avoid the Tools section in Products and Vendors because we are not providing the Print and Email Now links throughout all the modules. when we provide these links we will remove this if condition -->
	 {if $TEMPLATEPRINTS neq 'NOTEMPLATEPRINT'&& $MODULE neq 'Attachment'}
		  <table class="listTable" width="100%" cellspacing="0" cellpadding="5" border="0">
				 <tbody>
					  <tr>
							<td class="TitleHeading" style="border:none;">
								{'Please_select_a_template'|@getFixedLabel}{if 'oem_crm'|@getCommonVersion eq 'no'}<a class="icon-mediumimg_1 rfloat" href="javascript:;" style="" onclick="getLinksUrl('','module','tools_export_pdf');"></a>{/if}
							</td>
					  </tr>
					  <tr>
							<td>
								 <select id="templateprinttype" class="borderALL"  name="templateprinttype" style="width:145px;">
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
							</td>
					  </tr>
				 <!-- To display the Export To PDF link for PO, SO, Quotes and Invoice - starts -->
				{if $TEMPLATEPRINTS neq 'NOTEMPLATEPRINT'}
			{assign var=export_pdf_action value="CreatePDF"}
					  <tr>
							<td>
								 <a href="javascript:;" onclick="var printid=document.getElementById('templateprinttype').value;if(printid==0) {ldelim}
								  var confirm_str = arrJsPopLabel['PLEASESELECTPRINTTEMPLATES'];
								  RemindsMsg('','LdPopWidth400px','','yes','',confirm_str);
								  return false;
								  {rdelim} OpenNewWebTab('index.php?module=Settings&action=TemplatePrintHtml&tabname={$MODULE}&printid='+printid+'&record={$ID}')"><span class="icon-homeimg icon-pointer"></span>{'PRINT'|@getFixedLabel}</a>
							</td>
					  </tr>
					  <tr>
						 <td>
							<a  href="javascript:;" onclick="ConvertToPDF(this,'{$MODULE}',{$ID});"><span class="icon-homeimg icon-pointer"></span>{'ExporttoPDF'|@getFixedLabel}</a>
						</td>
					  </tr>
					  {if $TEMPLATEPRINTS neq 'NOTEMPLATEPRINT' &&  'Emails'|@isPermitted:'Create'   eq 'yes'}
					  <!-- Added to give link to  send Invoice PDF through mail -->
							<tr>
							<td>
								<a href="javascript:;" onclick="javascript:var printid=document.getElementById('templateprinttype').value;if(printid==0) {ldelim}
								  var confirm_str = arrJsPopLabel['PLEASESELECTPRINTTEMPLATES'];
								  RemindsMsg('','LdPopWidth400px','','yes','',confirm_str);
								return false;{rdelim} window.open('index.php?module={$MODULE}&action=SendPDFMail&printid='+printid+'&record={$ID}')" ><span class="icon-homeimg icon-pointer"></span>{'Send_Email_Add_PDF'|@getFixedLabel}</a> 
							</td>
							</tr>
					  {/if}
				 {/if}
				 <!-- Above if condition is added to avoid the Tools section in Products and Vendors because we are not providing the Print and Email Now links throughout all the modules. when we provide these links we will remove this if condition -->
				 </tbody>
			</table>
	 {/if}                                                            
</form>