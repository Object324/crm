<table border=0 cellspacing=0 cellpadding=0 width=100%>
	<tr valign=top>
       <td style="padding:0px" >
			<!-- Command Buttons -->
			<table border=0 cellspacing=0 cellpadding=0 width=100%>
			<!-- NOTE: We should avoid form-inside-form condition, which could happen when
			Singlepane view is enabled. -->
            {if $PUBLICACCOUNT >0 }
            {assign var=count value=1}
            <div style="position:absolute;z-index:1000;right:40%;"><img src='themes/softed/images/publicaccount.png' /></div>
            {/if}      
            {if $APPROVESTATUS neq ''}
				{assign var=count value=1}
				<div style="position:absolute;right:30%;"><img src="{$APPROVESTATUS}"/></div>
            {/if}
			<form action="index.php" method="post" name="DetailView" id="form">																
        	    <input type="hidden"  name="allselectedboxes" id="allselectedboxes">
                <input type="hidden" name="module" value="{$MODULE}">
                <input type="hidden" name="record" value="{$RECORD}">
                <input type="hidden" name="isDuplicate" value=false>
                <input type="hidden" name="action">
                <input type="hidden" name="return_module">
                <input type="hidden" name="return_action">
                <input type="hidden" name="return_id">
                <input  type="hidden" id="hdtxt_IsAdmin" value="{$ISADMIN}"/>
                <input type="hidden" name="SearchScope" id="SearchScopeDetail" value="{$SEARCHSCOPE}"/>
                <!--{*	查看页面返回列表，启用搜索session参数		*}-->
					 <input type="hidden" name="query_session" id="query_session" value="0"/>
    	        <tr><td style="padding:0px;width:100%;">
                        <div class="DivCName DivCNamehover" onclick="showHideStatus('tbl{$ARRBLOCKLABELS.0}','aid{$ARRBLOCKLABELS.0}');">
                            <span id="aid{$ARRBLOCKLABELS.0}"></span>{$ARRBLOCKLABELS.0.0}
                        </div>
            			<div style="width:auto;display:block;" id="tbl{$ARRBLOCKLABELS.0}" >
            				<table border="0" cellspacing="1" cellpadding="0" width="100%" class="DetailContentTable">
            				    <tr style="height:25px">
									<td class="DetailedTd1Label" width="25%" align="right">
                                        {$ARRFIELDLABEL.assigned_user_id}
                                    </td>
                                    <td class="DetailedTd2Info" align="left" width=25%">
                                        <span id='dtlview_smownerid'>{$smownerid}</span>
                                    </td>
									<td class="DetailedTd1Label" width="25%" align="right">
                                        {$ARRFIELDLABEL.isenabled}
                                    </td>
                                    <td class="DetailedTd2Info" align="left" width=25%" id="mouseArea_{$ARRFIELDLABEL.isenabled}" {if $alloweditpage eq 'yes'}  onmouseout="fnhide('crmspanid');" onmouseover="hndMouseOver(15,'{$ARRFIELDLABEL.isenabled}');"{/if}>
                                        <span id="dtlview_{$ARRFIELDLABEL.isenabled}">{$ISENABLED}</span>
                                        <div id="editarea_{$ARRFIELDLABEL.isenabled}" style="display: none;">
                                                    <select id="isenabled" name="att_isenabled">
                                                     {if $ISENABLED eq 1}
                                                            <option id="att_isenabled_on" selected="">{'YES'|@getFixedLabel}</option>
                                                     {else}
                                                            <option id="att_isenabled_on" selected="">{'YES'|@getFixedLabel}</option>
                                                      {/if}
                                                       {if $ISENABLED eq 0}
                                                            <option id="att_isenabled_off" selected="">{'NO'|@getFixedLabel}</option>
                                                        {else}
                                                            <option id="att_isenabled_off" >{'NO'|@getFixedLabel}</option>
                                                        {/if}
                                                    </select>
                                              		  <br><a href="javascript:;" name="button_{$ARRFIELDLABEL.isenabled}" onclick="dtlViewAjaxSave('{$ARRFIELDLABEL.isenabled}','Attachment',15,'ld_attachmentsforbills','isenabled',{$RECORD});fnhide('crmspanid');">{"SAVE"|@getFixedLabel}</a> {"OR"|@getFixedLabel}
                                              		  <a href="javascript:;" onclick="hndCancel('dtlview_{$ARRFIELDLABEL.isenabled}','editarea_{$ARRFIELDLABEL.isenabled}','{$ARRFIELDLABEL.isenabled}')">{"CANCEL"|@getFixedLabel}</a>
                                                       
                                        </div>
                                    </td>
            				    </tr>
								<tr style="height:25px">
									<td class="DetailedTd1Label" width="20%" align="right">
                                        {$ARRFIELDLABEL.reltab}
                                    </td>
                                	<td class="DetailedTd2Info" width="30%" align="left">
                                        {$RELTAB}
                                    </td>
                                    <td class="DetailedTd1Label" width="20%" align="right">
                                        {$ARRFIELDLABEL.related_to}
                                    </td>
                                	<td class="DetailedTd2Info" width="30%" align="left">
                                        {$RELATEDTO}
                                    </td>
                                </tr> 
                                <tr style="height:25px">
									<td class="DetailedTd1Label" width="25%" align="right">
                                        {$ARRFIELDLABEL.filename}
                                    </td>
                                    <td class="DetailedTd2Info" width="25%" align="left" {if $alloweditpage eq 'yes' &&  ($ISADMIN || $ISSELF || $ISENABLED eq 1 || $ISLAST)} onmouseover="hndMouseOver_show({$NOTESID},'{$NOTESID}');" onmouseout="hndMouseOver_showno({$NOTESID},'{$NOTESID}');" {/if}>
                                        {if $ISADMIN || $ISSELF || $ISENABLED eq '1' || $ISLAST}
                                            <a  title="{'DOWNLOADFILE'|@getFixedLabel}" href="javascript:DownLoad({$ATTACHMENTSID})">{$FILENAME}</a>
                                        {else}
                                            {$FILENAME}
                                        {/if}
										
                                        <span id="dtlview_{$NOTESID}_show" style="display:none;float:right;">
                                            <span style="float:left">
                                            <a href="javascript:void(0);" onclick="open_Attachment({$NOTESID},{$NOTESID},2,'{$FILENAME}')">{'PREVIEW'|@getFixedLabel}</a></span>
                                        </span>
                                     
                                    </td>
                                	<td class="DetailedTd1Label" width="20%" align="right">
                                         {$ARRFIELDLABEL.size}
                                    </td>
                                	<td class="DetailedTd2Info" width="30%" align="left">
                                        {$SIZE}
                                    </td>
									
            				    </tr>
								<tr style="height:25px">
                                	<td class="DetailedTd1Label" width="20%" align="right">
                                         {$ARRFIELDLABEL.uuid}
                                    </td>
                                	<td class="DetailedTd2Info" width="30%" align="left">
                                        {$UUID}
                                    </td>
                                    <td class="DetailedTd1Label" width="20%" align="right">
                                        {$ARRFIELDLABEL.imagefromtype}
                                    </td>
                                	<td class="DetailedTd2Info" width="30%" align="left">
                                        {$IMAGEFROMTYPE}
                                    </td>
                                </tr> 
                                <tr style="height:25px">
                                	<td class="DetailedTd1Label" width="20%" align="right">
                                         {$ARRFIELDLABEL.creator}
                                    </td>
                                	<td class="DetailedTd2Info" width="30%" align="left">
                                        {$LASTNAME}
                                    </td>
                                    <td class="DetailedTd1Label" width="20%" align="right">
                                        {$ARRFIELDLABEL.createdtime}
                                    </td>
                                	<td class="DetailedTd2Info" width="30%" align="left">
                                        {$CREATEDTIME}
                                    </td>
                                </tr> 
								<tr style="height:25px">
                                	<td class="DetailedTd1Label" width="20%" align="right">
                                         {$ARRFIELDLABEL.modifiedtime}
                                    </td>
                                	<td class="DetailedTd2Info" width="30%" align="left"  colspan='3'>
                                        {$MODIFIEDTIME}
                                    </td>
                                    
                                </tr>
								<tr style="height:25px">
									<td class="DetailedTd1Label" width="25%" align="right">
										 {$ARRFIELDLABEL.description}
									</td>
									<td class="DetailedTd2Info" colspan="30" align="left" colspan='3' id="mouseArea_{$ARRFIELDLABEL.description}" {if $alloweditpage eq 'yes'}   onmouseout="fnhide('crmspanid');" onmouseover="hndMouseOver(21,'{$ARRFIELDLABEL.description}');" {/if}>
									
                                        <span id="dtlview_{$ARRFIELDLABEL.description}">{$DESCRIPTION}</span>
                                            <div id="editarea_{$ARRFIELDLABEL.description}" style="display: none;">
              	                            
                                              		  <textarea id="txtbox_{$ARRFIELDLABEL.description}" name="description" class="detailedViewTextBox" onfocus="this.className='commonDetailedTextBox gwidth70 bgcolordh'" onblur="this.className='detailedViewTextBox'" rows="2">{$DESCRIPTION}</textarea>
                                              		  <br/><a href="javascript:;" name="button_{$ARRFIELDLABEL.description}" onclick="dtlViewAjaxSave('{$ARRFIELDLABEL.description}','Attachment',21,'ld_attachmentsforbills','description',{$RECORD});fnhide('crmspanid');">{"SAVE"|getFixedLabel}</a> {"OR"|getFixedLabel}
                                              		  <a href="javascript:;" onclick="hndCancel('dtlview_{$ARRFIELDLABEL.description}','editarea_{$ARRFIELDLABEL.description}','{$ARRFIELDLABEL.description}')">{"CANCEL"|getFixedLabel}</a>
                                                       
                                            </div>
									</td>
								</tr> 
            				</table>
            			</div>
            	   </td>
            	</tr>
               {* END *}
				<!-- Inventory - Product Details informations -->
			</form>
			<!-- End the form related to detail view -->            
		  </table>
		</td>
      </tr>
  </table>