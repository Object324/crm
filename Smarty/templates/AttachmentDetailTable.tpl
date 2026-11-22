<table border=0 cellspacing=0 cellpadding=0 width=100%>
	<tr valign=top>
       <td style="padding:5px" >
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
				<div style="position:absolute;right:30%;"><img src="{$APPROVESTATUS}"/> </div>
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
                <input type="hidden" name="SearchScope" id="SearchScopeDetail" value="{$SEARCHSCOPE}"/>
                
    	        <tr><td style="padding:5px;width:100%;">
               
            			<!-- Detailed View Code starts here-->
            			<table border=0 cellspacing=0 cellpadding=0 width=100% class="small">
            				<tr>
            					<td>&nbsp;</td>
            					<td>&nbsp;</td>
            					<td>&nbsp;</td>
            					<td align=right></td>
            				</tr>
                            <tr>
                                <td colspan=4 class="dvInnerHeader">
                                    <div style="float:left;font-weight:bold;"><div style="float:left;"><a href="javascript:showHideStatus('tbl基本信息','aid基本信息','themes/softed/images/');"><span class="icon-homeimg icon-activate" id="aid基本信息" title="隐藏"></span></a></div><b>&nbsp;{$ARRBLOCKLABELS.0}</b></div>
                                </td>
            				</tr>
            			</table>
            			<div style="width:auto;display:block;" id="tbl基本信息" >
            				<table border=0 cellspacing=0 cellpadding=0 width="100%" class="small">
            				    <tr style="height:25px">
            						<td class="dvtCellLabel" width="25%" align="right">
                                        {$ARRFIELDLABEL.filename}
                                    </td>
                                    <td class="dvtCellInfo" width="25%" align="left">
                                        {if $ISADMIN || $ISSELF || $ISENABLED eq 1 || $ISLAST}
                                            <a title="{'DOWNLOADFILE'|@getFixedLabel}" href="index.php?module=uploads&action=downloadfileself&fileid={$ATTACHMENTSID}">{$FILENAME}</a>
                                        {else}
                                            {$FILENAME}
                                        {/if}
                                    </td>
                                    <td class="dvtCellLabel" width="25%" align="right">
                                        {$ARRFIELDLABEL.isenabled}
                                    </td>
                                    <td class="dvtCellInfo" align="left" width="25%">
                                        {$ISENABLED}
                                    </td>
            				    </tr>
                                <tr style="height:25px">
                                	<td class="dvtCellLabel" width="20%" align="right">
                                         {$ARRFIELDLABEL.size}
                                    </td>
                                	<td class="dvtCellInfo" width="30%" align="left" colspan="3">
                                        {$SIZE}
                                    </td>
                                    <!--
                                    <td class="dvtCellLabel" width="20%" align="right">
                                        
                                    </td>
                                	<td class="dvtCellInfo" width="30%" align="left">
                                        
                                    </td>
                                    -->
                                </tr> 
                                <tr style="height:25px">
            						<td class="dvtCellLabel" width="25%" align="right">
                                         {$ARRFIELDLABEL.description}
                                    </td>
                                    <td class="dvtCellInfo" colspan="3" align="left">
                                        {$DESCRIPTION}
                                    </td>
            				    </tr>
                                <tr style="height:25px">
                                	<td class="dvtCellLabel" width="20%" align="right">
                                         {$ARRFIELDLABEL.creator}
                                    </td>
                                	<td class="dvtCellInfo" width="30%" align="left">
                                        {$LASTNAME}
                                    </td>
                                    <td class="dvtCellLabel" width="20%" align="right">
                                        {$ARRFIELDLABEL.createdtime}
                                    </td>
                                	<td class="dvtCellInfo" width="30%" align="left">
                                        {$CREATEDTIME}
                                    </td>
                                </tr> 
                                
                                  <tr style="height:25px">
                                	<td class="dvtCellLabel" width="20%" align="right">
                                        {$ARRFIELDLABEL.reltab}
                                    </td>
                                	<td class="dvtCellInfo" width="30%" align="left">
                                        {$RELTAB}
                                    </td>
                                    <td class="dvtCellLabel" width="20%" align="right">
                                        {$ARRFIELDLABEL.related_to}
                                    </td>
                                	<td class="dvtCellInfo" width="30%" align="left">
                                        {$RELATEDTO}
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