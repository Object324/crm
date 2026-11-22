{if $MODULE neq 'Calendar'&&$MODULE neq 'Attachment'}
	<table width="100%" border="0" cellpadding="5" cellspacing="0">
		 <tr><td align="left" class="genHeaderSmall">{'OPERATING'|@getFixedLabel}</td></tr>
		 
		 {if $MODULE eq 'PaymentPlan'&& $CAHSBILLCREATE eq 'yes'}
		 <tr>
			  <td align="left" style="padding-left:10px;">
			  <a class="webMnu" href="javascript:CreateCashBill(this,'{$ID}')" ><img onclick="CreateCashBill(this,'{$ID}')" src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0"/></a>
			  <a class="webMnu" href="javascript:CreateCashBill(this,'{$ID}')"  >{'LBL_Creates'|@getFixedLabel}{$CASHBILLMODULE|@getTranstab:$CASHBILLMODULE}</a>
			  </td>
		 </tr>
		 {/if}
		 {if $MODULE eq 'SendPayment'&& $SENDCAHSBILLCREATE eq 'yes'}
		 <tr>
			  <td align="left" style="padding-left:10px;">
			  <a class="webMnu" href="javascript:CreateSendCashBill(this,'{$ID}','{$VENDOR_ID}')" ><img onclick="CreateSendCashBill(this,'{$ID}')" src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0"/></a>
			  <a class="webMnu" href="javascript:CreateSendCashBill(this,'{$ID}','{$VENDOR_ID}')"  >{'LBL_Creates'|@getFixedLabel} {$SENDCASHBILLMODULE|@getTranstab:$SENDCASHBILLMODULE}</a>
			  </td>
		 </tr>
		 {/if}
		 {if $PROJECTTASKCREATE eq 'permitted'}
		 <tr>
			  <td align="left" style="padding-left:10px;">
			  <a href="index.php?module=ProjectTask&action=EditView&projectid={$ID}&return_module=ProjectTask&return_action=DetailView&project_id={$ID}&Create=yes&account_id={$ACCOUNTID}&contact_id={$CONTACTID}" target="_blank" class="webMnu"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
			  <a href="index.php?module=ProjectTask&action=EditView&projectid={$ID}&return_module=ProjectTask&return_action=DetailView&project_id={$ID}&Create=yes&account_id={$ACCOUNTID}&contact_id={$CONTACTID}" target="_blank" class="webMnu" onclick="">{'LBL_Creates'|@getFixedLabel} {'ProjectTask'|@getTranstab:'ProjectTask'}</a>
			  </td>
		 </tr>
		 {/if}
		 
		 {if $PROJECTMILESTONECREATE  eq 'permitted'}
		 <tr>
			  <td align="left" style="padding-left:10px;">
					<a href="index.php?module=ProjectMilestone&action=EditView&projectid={$ID}&return_module=ProjectMilestone&return_action=DetailView&Create=yes" target="_blank" class="webMnu"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
					<a href="index.php?module=ProjectMilestone&action=EditView&projectid={$ID}&return_module=ProjectMilestone&return_action=DetailView&Create=yes" target="_blank" class="webMnu" onclick="">{'LBL_Creates'|@getFixedLabel} {'ProjectMilestone'|@getTranstab:'ProjectMilestone'}</a>
			  </td>
		 </tr>
		 {/if}
		 {if $REMINDS  eq 'permitted' || ($MODULE  eq 'VendorContactRecords' && $REMINDS  eq 'permitted')}
		 <tr>
			  <td align="left" style="padding-left:10px;">
			  <a href="index.php?module=Reminds&action=EditView&projectid={$ID}&return_module=Reminds&return_action=DetailView&parent_id={$ID}&related_to={$ID}&Create=yes" target="_blank" class="webMnu"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
			  <a href="index.php?module=Reminds&action=EditView&projectid={$ID}&return_module=Reminds&return_action=DetailView&parent_id={$ID}&related_to={$ID}&Create=yes" target="_blank" class="webMnu" onclick="">{'LBL_Creates'|@getFixedLabel}  {'Reminds'|@getTranstab:'Reminds'}</a>
			  </td>
		 </tr>
		 {/if}
		 <!--
		   @reason 0008467 供应商联系人界面，添加新增联系记录和附件
		   @author Tujt 2014-04-21
		 -->
		 {if $MODULE  eq 'VendorContact' && $VendorContactRecords  eq 'permitted'}
		 <tr>
			  <td align="left" style="padding-left:10px;">
					<a class="webMnu" 
					href="index.php?module=VendorContactRecords&action=EditView&return_module=VendorContactRecords&return_action=DetailView&contact_id={$CONTACTID}&vendor_id={$VENDOR_ID}&Create=yes" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0"/></a>
					<a class="webMnu" href="index.php?module=VendorContactRecords&action=EditView&return_module=VendorContactRecords&return_action=DetailView&contact_id={$CONTACTID}&vendor_id={$VENDOR_ID}&Create=yes" target="_blank">{'LBL_Creates'|@getFixedLabel} {'VendorContactRecords'|@getTranstab:'VendorContactRecords'}</a>
			  </td>
		 </tr>
		 {/if}
		 {if $MODULE eq 'Potentials'}
			  {if $ConvertContactRecords eq 'permitted'}
					<tr>
					<td align="left" style="padding-left:10px;">
						<a class="webMnu" href="index.php?return_module=ContactRecords&return_action=DetailView&convertmode=potentialcontactrecords&module=ContactRecords&action=EditView&potential_id={$ID}&account_id={$ACCOUNTID}&contact_id={$CONTACTID}&Create=yes" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0"/></a>
						<a class="webMnu" href="index.php?return_module=ContactRecords&return_action=DetailView&convertmode=potentialcontactrecords&module=ContactRecords&action=EditView&potential_id={$ID}&account_id={$ACCOUNTID}&contact_id={$CONTACTID}&Create=yes" target="_blank">{'LBL_Creates'|@getFixedLabel} {'ContactRecords'|@getTranstab:'ContactRecords'}</a>
					</td>
				</tr>
			  {/if}
			  {if $CONVERTINVOICE eq 'permitted'}
				<tr>
					<td align="left" style="padding-left:10px;">
						<a class="webMnu" href="index.php?return_module=Invoice&return_action=DetailView&convertmode={$CONVERTMODE}&module=Invoice&action=EditView&potential_id={$ID}&Create=yes&account_id={$ACCOUNTID}&contact_id={$CONTACTID}" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0"/></a>
						<a class="webMnu" href="index.php?return_module=Invoice&return_action=DetailView&convertmode={$CONVERTMODE}&module=Invoice&action=EditView&potential_id={$ID}&Create=yes&account_id={$ACCOUNTID}&contact_id={$CONTACTID}" target="_blank">{'LBL_Creates'|@getFixedLabel} {'Invoice'|getTranstab:'Invoice'}</a>
					</td>
				</tr>
			  {/if}
			  {if $SalesOrderEditView eq 'permitted'}
				<tr>
					<td align="left" style="padding-left:10px;">
						<a class="webMnu" href="index.php?return_module=SalesOrder&return_action=DetailView&module=SalesOrder&action=EditView&potential_id={$ID}&Create=yes&account_id={$ACCOUNTID}&contact_id={$CONTACTID}" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0"/></a>
						<a class="webMnu" href="index.php?return_module=SalesOrder&return_action=DetailView&module=SalesOrder&action=EditView&potential_id={$ID}&Create=yes&account_id={$ACCOUNTID}&contact_id={$CONTACTID}" target="_blank">{'LBL_Creates'|@getFixedLabel} {'SalesOrder'|@getTranstab:'SalesOrder'}</a>
					</td>
				</tr>
			  {/if}
			  {if $QuotesEditView eq 'permitted'}
				<tr>
					<td align="left" style="padding-left:10px;">
						<a class="webMnu" href="index.php?return_module=Quotes&return_action=DetailView&module=Quotes&action=EditView&potential_id={$ID}&Create=yes&account_id={$ACCOUNTID}&contact_id={$CONTACTID}" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0"/></a>
						<a class="webMnu" href="index.php?return_module=Quotes&return_action=DetailView&module=Quotes&action=EditView&potential_id={$ID}&Create=yes&account_id={$ACCOUNTID}&contact_id={$CONTACTID}" target="_blank">{'LBL_Creates'|@getFixedLabel} {'Quotes'|@getTranstab:'Quotes'}</a>
					</td>
				</tr>
			  {/if}
			  {if $CalendarEditView eq 'permitted' }
					  <tr>
							<td align="left" style="padding-left:10px;">
							 <a class="webMnu" href="index.php?module=Calendar&action=EditView&return_module=Calendar&return_action=DetailView&parent_id={$ID}&Create=yes&potential_id={$ID}&account_id={$ACCOUNTID}&contact_id={$CONTACTID}" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0"/></a>
							 <a class="webMnu" href="index.php?module=Calendar&action=EditView&return_module=Calendar&return_action=DetailView&parent_id={$ID}&Create=yes&potential_id={$ID}&account_id={$ACCOUNTID}&contact_id={$CONTACTID}" target="_blank">{'LBL_Creates'|@getFixedLabel} {'Calendar'|@getTranstab:'Calendar'}</a>
							</td>
					  </tr>
			  {/if}
			  <tr>
				 <td align="left" style="padding-left:10px;">
				 <a class="webMnu" href="index.php?module=Reminds&action=EditView&return_module=Reminds&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0"/></a>
				 <a class="webMnu" href="index.php?module=Reminds&action=EditView&return_module=Reminds&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank">{'LBL_Creates'|@getFixedLabel}  {'Reminds'|@getTranstab:'Reminds'}</a>
				 </td>
			  </tr>                                                  
		{elseif $TODO_PERMISSION eq 'true' || $EVENT_PERMISSION eq 'true' || $CONTACT_PERMISSION eq 'true'|| $MODULE eq 'Contacts' || ($MODULE eq 'Documents')}
			  
			{if $MODULE eq 'Contacts'}
				{assign var=subst value="contact_id"}
				{assign var=acc value="&account_id=$accountid"}
			{else}
				{assign var=subst value="parent_id"}
				{assign var=acc value=""}
			{/if}
			  <!--end-->
			  
			  
			  <!-- by LD Can 20130118 客户明细界面增加发票，联系人，报价单新增按钮-->
			  {if $MODULE eq 'Accounts'}                                                           
				  {if $ContactEditView eq 'yes' }
					  <tr>
							<td align="left" style="padding-left:10px;">
								 <a class="webMnu" href="index.php?module=Contacts&action=EditView&return_module=Contacts&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
								 <a class="webMnu" href="index.php?module=Contacts&action=EditView&return_module=Contacts&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank">{'LBL_Creates'|@getFixedLabel} {'Contacts'|@getTranstab:'Contacts'}</a>
							 </td>
					  </tr>
				 {/if}
				 {if $ContactRecordEditView eq 'yes'}
					  <tr>
							<td align="left" style="padding-left:10px;">
								  <a class="webMnu" href="index.php?module=ContactRecords&action=EditView&return_module=ContactRecords&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
								  <a class="webMnu" href="index.php?module=ContactRecords&action=EditView&return_module=ContactRecords&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank">{'LBL_Creates'|@getFixedLabel} {'ContactRecords'|@getTranstab:'ContactRecords'}</a>
							</td>
					  </tr>
				  {/if}
				  {if $CalendarEditView eq 'yes' }
					  <tr>
							<td align="left" style="padding-left:10px;">
							<a class="webMnu" href="index.php?module=Calendar&action=EditView&return_module=Calendar&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
							<a class="webMnu" href="index.php?module=Calendar&action=EditView&return_module=Calendar&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank">{'LBL_Creates'|@getFixedLabel} {'Calendar'|@getTranstab:'Calendar'}</a>
							</td>
					  </tr>
					{/if}
				 <tr>
					  <td align="left" style="padding-left:10px;">
					  <a class="webMnu" href="index.php?module=Reminds&action=EditView&return_module=Reminds&return_action=DetailView&parent_id={$ID}&related_to={$ID}&Create=yes" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
					  <a class="webMnu" href="index.php?module=Reminds&action=EditView&return_module=Reminds&return_action=DetailView&parent_id={$ID}&related_to={$ID}&Create=yes" target="_blank">{'LBL_Creates'|@getFixedLabel}  {'Reminds'|@getTranstab:'Reminds'}</a>
					  </td>
				 </tr>
				 {if $QuoteEditView eq 'yes' }
						 <tr>
							  <td align="left" style="padding-left:10px;">
									<a class="webMnu" href="index.php?module=Quotes&action=EditView&return_module=Quotes&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
									<a class="webMnu" href="index.php?module=Quotes&action=EditView&return_module=Quotes&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank">{'LBL_Creates'|@getFixedLabel} {'Quotes'|@getTranstab}</a>
							  </td>
						 </tr>
				  {/if}                                                             
				  {if $PotentialEditView eq 'yes' }
						 <tr>
								 <td align="left" style="padding-left:10px;">
								 <a class="webMnu" href="index.php?module=Potentials&action=EditView&return_module=Potentials&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
								 <a class="webMnu" href="index.php?module=Potentials&action=EditView&return_module=Potentials&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank">{'LBL_Creates'|@getFixedLabel} {'Potentials'|@getTranstab:'Potentials'}</a>
								 </td>
						 </tr>
					{/if}                                                             
					{if $SaleOrderEditView eq 'yes' }
					  <tr>
							<td align="left" style="padding-left:10px;">                                                                            
							<a class="webMnu" href="index.php?module=SalesOrder&action=EditView&return_module=SalesOrder&return_action=DetailView&return_id=&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
							<a class="webMnu" href="index.php?module=SalesOrder&action=EditView&return_module=SalesOrder&return_action=DetailView&return_id=&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank">{'LBL_Creates'|@getFixedLabel} {'SalesOrder'|@getTranstab:'SalesOrder'}</a>
							</td>
					  </tr>
					 {/if}                                                          
					 {if $InvoiceEditView eq 'yes' }
							<tr>
								 <td align="left" style="padding-left:10px;">
								 <a class="webMnu" href="index.php?module=Invoice&action=EditView&return_module=Invoice&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
								 <a class="webMnu" href="index.php?module=Invoice&action=EditView&return_module=Invoice&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank">{'LBL_Creates'|@getFixedLabel} {'Invoice'|@getTranstab:'Invoice'}</a>
								 </td>
							</tr>
						{/if}
						{if $OutboundOrderEditView eq 'yes'}
							 <tr>
									<td align="left" style="padding-left:10px;">
										 <a class="webMnu" href="index.php?module=OutboundOrder&action=EditView&return_module=OutboundOrder&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
										 <a class="webMnu" href="index.php?module=OutboundOrder&action=EditView&return_module=OutboundOrder&return_action=DetailView&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank">{'LBL_Creates'|@getFixedLabel} {'OutboundOrder'|@getTranstab:'OutboundOrder'}</a>
									</td>
							 </tr>
						{/if}
						{if $CashBillEditView eq 'yes'}
							<tr>
								  <td align="left" style="padding-left:10px;">
										<a class="webMnu" href="index.php?module=CashBill&action=EditView&return_module=CashBill&return_action=DetailView&convertmode=update_so_val&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
										<a class="webMnu" href="index.php?module=CashBill&action=EditView&return_module=CashBill&return_action=DetailView&convertmode=update_so_val&parent_id={$ID}&account_id={$ID}&Create=yes" target="_blank">{'LBL_Creates'|@getFixedLabel} {'CashBill'|@getTranstab:'CashBill'}</a>
								  </td>
							</tr>
						{/if}
			  {/if}
			  {if  $ConvertContactRecords eq 'permitted'}                                                            
					<tr>
					<td align="left" style="padding-left:10px;">
						<a class="webMnu" href="index.php?return_module=ContactRecords&return_action=DetailView&convertmode=contactcontactrecords&module=ContactRecords&action=EditView&account_id={$ACCOUNTID}&Create=yes&contact_id={$ID}" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
						<a class="webMnu" href="index.php?return_module=ContactRecords&return_action=DetailView&convertmode=contactcontactrecords&module=ContactRecords&action=EditView&account_id={$ACCOUNTID}&Create=yes&contact_id={$ID}" target="_blank">{'LBL_Creates'|@getFixedLabel} {'ContactRecords'|@getTranstab:'ContactRecords'}</a>
					</td>
				</tr>                                                             
			  {/if}
			  <!--联系记录没有日程 by LD Can 20130205-->
			  {if $MODULE neq 'ContactRecords'}
				{if  $MODULE eq 'Contacts'}
						 {if $CREATECONTACT eq 'permitted' }                                                                
					<tr>
						<td align="left" style="padding-left:10px;">
							<a href="index.php?module=Contacts&action=EditView&return_action=DetailView&parenttab=Parent Accounts&Create=true&contact_id={$ID}&account_id={$ACCOUNTID}" class="webMnu" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
							<a href="index.php?module=Contacts&action=EditView&return_action=DetailView&parenttab=Parent Accounts&Create=true&contact_id={$ID}&account_id={$ACCOUNTID}" class="webMnu" target="_blank">{'LBL_Creates'|@getFixedLabel} {'THELOWCONTACT'|@getFixedLabel}</a>
						</td>
					</tr>                                                               
						 {/if} 
						 {if  $FORSHOW eq 'yes'}                                                                
					<tr>
						<td align="left" style="padding-left:10px;">
							<a href="index.php?module=Contacts&action=ContactsHierarchy&contact_id={$ID}" class="webMnu" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
							<a href="index.php?module=Contacts&action=ContactsHierarchy&contact_id={$ID}" class="webMnu" target="_blank">{'VIEW'|@getFixedLabel} {'THELOWLEVELCONTRACTS'|@getFixedLabel}</a>
						</td>
					</tr>                                                               
						 {/if}
						 {if $EVENT_PERMISSION eq 'true'}                                                                
					<tr>
						<td align="left" style="padding-left:10px;">
							<a href="index.php?module=Calendar&action=EditView&return_module={$MODULE}&return_action=DetailView&activity_mode=Events&return_id={$ID}&{$subst}={$ID}{$acc}&parenttab={$CATEGORY}&Create=yes" class="webMnu" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
							<a href="index.php?module=Calendar&action=EditView&return_module={$MODULE}&return_action=DetailView&activity_mode=Events&return_id={$ID}&{$subst}={$ID}{$acc}&parenttab={$CATEGORY}&Create=yes" class="webMnu" target="_blank">{'LBL_Creates'|@getFixedLabel} {'Calendar'|@getTranstab:'Calendar'}</a>
						</td>
					</tr>                                                               
						 {/if}                                                                
						 <tr>
							<td align="left" style="padding-left:10px;">
							<a class="webMnu" href="index.php?module=Reminds&action=EditView&return_module=Reminds&return_action=DetailView&parent_id={$ID}&contact_id={$CONTACTID}" target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
							<a class="webMnu" href="index.php?module=Reminds&action=EditView&return_module=Reminds&return_action=DetailView&parent_id={$ID}&contact_id={$CONTACTID}" target="_blank">{'LBL_Creates'|@getFixedLabel}  {'Reminds'|@getTranstab:'Reminds'}</a>
							</td>
							</tr>                                                               
				{/if}                                                            
			  {/if}
			  {if $MODULE eq 'Leads'}															
					{if $SENDMAILBUTTON eq 'permitted'}
					<tr>
						<td align="left" style="padding-left:10px;">
							{foreach key=index item=email from=$EMAILS}
								<input type="hidden" name="email_{$index}" value="{$email}"/>
							{/foreach}
							<a href="javascript:void(0);" class="webMnu" onclick="{$JS}"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/>1</a>
							<a href="javascript:void(0);" class="webMnu" onclick="{$JS}">{$APP.LBL_SENDMAIL_BUTTON_LABEL}</a>
						</td>
					</tr>
				{/if}
					{if $MODULE eq 'Contacts'} 
					{if $SENDSMSBUTTON eq 'permitted'}
					<tr>
						 <td align="left" style="padding-left:10px;">
						 <a href="javascript:void(0);" onclick="window.open('index.php?module=MassSMS&action=index&parenttab=Marketing&select_options={$ID}&return_module={$MODULE}&return_action=DetailView',null,'1024,768,menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes')" class="webMnu"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
						 <a href="javascript:void(0);" onclick="window.open('index.php?module=MassSMS&action=index&parenttab=Marketing&select_options={$ID}&return_module={$MODULE}&return_action=DetailView',null,'1024,768,menubar=no,toolbar=no,location=no,status=no,resizable=yes,scrollbars=yes')" class="webMnu" onclick="">{'Send_SMS'|@getFixedLabel}</a>
						 </td>
						 </tr>
					{/if}
					{/if}                                                            
			  {/if} 
			  <!-- Start: Actions for Documents Module -->
			  {if $MODULE eq 'Documents'}
				<tr>
					<td align="left" style="padding-left:10px;">
						{if $DLD_TYPE eq 'I' && $FILE_STATUS eq '1' && $FILE_EXIST eq 'yes'}
							<a href="index.php?module=uploads&action=downloadfile&fileid={$FILEID}&entityid={$NOTESID}"  onclick="javascript:dldCntIncrease({$NOTESID});" class="webMnu"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle" title="{'DOWNLOADFILE'|@getFixedLabel}" border="0"/></a>
							<a href="index.php?module=uploads&action=downloadfile&fileid={$FILEID}&entityid={$NOTESID}" onclick="javascript:dldCntIncrease({$NOTESID});">{'DOWNLOADFILE'|@getFixedLabel}</a>
						{elseif $DLD_TYPE eq 'E' && $FILE_STATUS eq '1'}
							<a target="_blank" href="{$DLD_PATH}" onclick="javascript:dldCntIncrease({$NOTESID});"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}"" align="absmiddle" title="{'DOWNLOADFILE'|@getFixedLabel}" border="0"></a>
							<a target="_blank" href="{$DLD_PATH}" onclick="javascript:dldCntIncrease({$NOTESID});">{'DOWNLOADFILE'|@getFixedLabel}</a>
						{/if}
				</td>
					</tr>
				{if $CHECK_INTEGRITY_PERMISSION eq 'yes'}
					<tr>
						 <td align="left" style="padding-left:10px;">
						<a href="javascript:;" onClick="checkFileIntegrityDetailView({$NOTESID});"><img id="CheckIntegrity_img_id" src="{'pointer.gif'|@lingdang_imageurl:$THEME}" alt="{'CHECKATTACHMENTINTEGRITY'|@getFixedLabel}" title="{'CHECKATTACHMENTINTEGRITY'|@getFixedLabel}" hspace="5" align="absmiddle" border="0"/></a>
						<a href="javascript:;" onClick="checkFileIntegrityDetailView({$NOTESID});">{'CHECKATTACHMENTINTEGRITY'|@getFixedLabel}</a>&nbsp;
						<input type="hidden" id="dldfilename" name="dldfilename" value="{$FILEID}-{$FILENAME}">
						<span id="vtbusy_integrity_info" style="display:none;">
							<img src="{'vtbusy.gif'|@lingdang_imageurl:$THEME}" border="0"></span>
						<span id="integrity_result" style="display:none"></span>
					</td></tr>
				{/if}
					{if $DLD_TYPE eq 'I' &&  $FILE_STATUS eq '1' && $FILE_EXIST eq 'yes'}
					<tr>
							  <td align="left" style="padding-left:10px;">
							<input type="hidden" id="dldfilename" name="dldfilename" value="{$FILEID}-{$FILENAME}"><!--attachment.gfi-->
							<a href="javascript: document.DetailView.return_module.value='Documents'; document.DetailView.return_action.value='DetailView'; document.DetailView.module.value='Documents'; document.DetailView.action.value='EmailFile'; document.DetailView.record.value={$NOTESID}; document.DetailView.return_id.value={$NOTESID}; sendfile_email();" class="webMnu"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle" border="0" style="margin-top:-5px;"/></a>
							<a href="javascript: document.DetailView.return_module.value='Documents'; document.DetailView.return_action.value='DetailView'; document.DetailView.module.value='Documents'; document.DetailView.action.value='EmailFile'; document.DetailView.record.value={$NOTESID}; document.DetailView.return_id.value={$NOTESID}; sendfile_email();">{'SENTEMAILATTACHMENTS'|@getFixedLabel}</a>
						</td>
						 </tr>
					{/if}
			  {/if}   
			  
		{/if}
	</table>
	
	
	{if $CUSTOM_LINKS && $CUSTOM_LINKS.DETAILVIEWBASIC}                                                
<table width="100%" border="0" cellpadding="5" cellspacing="0">
			  {if $SENDMAILBUTTON eq 'permitted'}
						 {if $ISMASSEMAIL neq 5}
		<tr>
			<td align="left" style="padding-left:10px;">
				{foreach key=index item=email from=$EMAILS}
					<input type="hidden" name="email_{$index}" value="{$email}"/>
				{/foreach}
				{if $MODULE eq 'Accounts'}
										 <a href="javascript:void(0);" onclick="detailview_email_account_show('Accounts')" class="webMnu"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
										 <a href="javascript:void(0);" onclick="detailview_email_account_show('Accounts')" class="webMnu">{'Send_mail'|@getFixedLabel}</a>
										 {else}
										 <a href="javascript:void(0);" onclick="detailview_email_contact_show()" class="webMnu"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
										 <a href="javascript:void(0);" onclick="detailview_email_contact_show()" class="webMnu">{'Send_mail'|@getFixedLabel}</a>
										 {/if}
									</td>
		</tr>
							  {/if}
	{/if}
						 {if $SENDSMSBUTTON eq 'permitted'}
							  {if $ISMASSSMS neq 5}
									<tr>
										 <td align="left" style="padding-left:10px;">
										 {if $MODULE eq 'Accounts'}
										 <a href="javascript:void(0);" onclick="detailview_SMS_account_show('SMS','Accounts')" class="webMnu"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
										 <a href="javascript:void(0);" onclick="detailview_SMS_account_show('SMS','Accounts')" class="webMnu">{'Send_SMS'|@getFixedLabel}</a>
										 {else}
										 <a href="javascript:void(0);" onclick="detailview_MassSMS_contact_show()" class="webMnu"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
										 <a href="javascript:void(0);" onclick="detailview_MassSMS_contact_show()" class="webMnu">{'Send_SMS'|@getFixedLabel}</a>
										 {/if}
										 </td>
									</tr>
							  {/if}
						 {/if}
						 {if $CREATEATTACHMENT eq 'permitted'}
							  <tr>
									<td align="left" style="padding-left:10px;">
									<a href="index.php?module=Attachment&action=EditView&return_module=Attachment&return_action=DetailView&parent_id={$ID}&Create=yes"  class="webMnu"  target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
									<a href="index.php?module=Attachment&action=EditView&return_module=Attachment&return_action=DetailView&parent_id={$ID}&Create=yes"  class="webMnu"  target="_blank">{'LBL_Creates'|@getFixedLabel} {'Attachment'|@getFixedLabel}</a>
									</td>
							  </tr>
						 {/if}
						 
						 {if $REMINDSACTION == 'permitted' && $MODULE eq 'ContactRecords'}
							  <tr>
									<td align="left" style="padding-left:10px;">
									<a href="index.php?module=Reminds&action=EditView&return_module=Reminds&return_action=DetailView&parent_id={$ID}&related_to={$ID}&Create=yes" target="_blank" class="webMnu"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
									<a href="index.php?module=Reminds&action=EditView&return_module=Reminds&return_action=DetailView&parent_id={$ID}&related_to={$ID}&Create=yes" target="_blank" class="webMnu" onclick="">{'LBL_Creates'|@getFixedLabel}  {'Reminds'|@getTranstab:'Reminds'}</a>
									</td>
							  </tr>
						 {/if}
						 {if $CREATECONTACTRECORDS == 'permitted' && $MODULE eq 'HelpDesk'}
						 <tr>
							  <td align="left" style="padding-left:10px;">
							  <a href="index.php?module=ContactRecords&action=EditView&return_module=ContactRecords&return_action=DetailView&Create=yes&troubleticketid={$ID}&account_id={$ACCOUNTID}&contact_id={$CONTACTID}&salesorder_id={$SALESORDERID}"  class="webMnu"  target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
							  <a href="index.php?module=ContactRecords&action=EditView&return_module=ContactRecords&return_action=DetailView&Create=yes&troubleticketid={$ID}&account_id={$ACCOUNTID}&contact_id={$CONTACTID}&salesorder_id={$SALESORDERID}"  class="webMnu"  target="_blank">{'LBL_Creates'|@getFixedLabel}  {'ContactRecords'|@getTranstab}</a>
							  </td>
						 </tr>
						 {/if}
						 {if $CREATECONTACTRECORDS == 'permitted' && $MODULE eq 'Project'}
							  <tr>
									<td align="left" style="padding-left:10px;">
									<a href="index.php?module=ContactRecords&action=EditView&return_module=ContactRecords&return_action=DetailView&Create=yes&account_id={$ACCOUNTID}&projectid={$ID}&contact_id={$CONTACTID}&potential_id={$POTENTIALID}&salesorder_id={$SALESORDERID}"  class="webMnu"  target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
									<a href="index.php?module=ContactRecords&action=EditView&return_module=ContactRecords&return_action=DetailView&Create=yes&account_id={$ACCOUNTID}&projectid={$ID}&contact_id={$CONTACTID}&potential_id={$POTENTIALID}&salesorder_id={$SALESORDERID}"  class="webMnu"  target="_blank">{'LBL_Creates'|@getFixedLabel}  {'ContactRecords'|@getTranstab:'ContactRecords'}</a>
									</td>
							  </tr>
						 {/if}
						 {if $CREATECONTACTRECORDS == 'permitted' && $MODULE eq 'ProjectTask'}
							  <tr>
									<td align="left" style="padding-left:10px;">
									<a href="index.php?module=ContactRecords&action=EditView&return_module=ContactRecords&return_action=DetailView&Create=yes&projecttaskid={$ID}&projectid={$PROJECTID}&account_id={$ACCOUNTID}&contact_id={$CONTACTID}"  class="webMnu"  target="_blank"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
									<a href="index.php?module=ContactRecords&action=EditView&return_module=ContactRecords&return_action=DetailView&Create=yes&projecttaskid={$ID}&projectid={$PROJECTID}&account_id={$ACCOUNTID}&contact_id={$CONTACTID}"  class="webMnu"  target="_blank">{'LBL_Creates'|@getFixedLabel}  {'ContactRecords'|@getTranstab}</a>
									</td>
							  </tr>
						 {/if}
						 {if $MODULE eq 'HelpDesk'}
							  <tr>
									<td align="left" style="padding-left:10px;">
									<a href="index.php?module=Reminds&action=EditView&return_module=Reminds&return_action=DetailView&parent_id={$ID}&related_to={$ID}&Create=yes" target="_blank" class="webMnu"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle"  border="0" style="margin-top:-5px;"/></a>
									<a href="index.php?module=Reminds&action=EditView&return_module=Reminds&return_action=DetailView&parent_id={$ID}&related_to={$ID}&Create=yes" target="_blank" class="webMnu" onclick="">{'LBL_Creates'|@getFixedLabel}  {'Reminds'|@getTranstab:'Reminds'}</a>
									</td>
							  </tr>
						 {/if}
						 {foreach item=CUSTOMLINK from=$CUSTOM_LINKS.DETAILVIEWBASIC}  
					<tr>
	<td align="left" style="padding-left:10px;">
		{assign var="customlink_href" value=$CUSTOMLINK->linkurl}
		{assign var="customlink_label" value=$CUSTOMLINK->linklabel}
		{if $customlink_label eq ''}
			{assign var="customlink_label" value=$customlink_href}
		{else}
			{* Pickup the translated label provided by the module *}
			{assign var="customlink_label" value=$customlink_label|@getTranslatedString:$CUSTOMLINK->module()}
		{/if}
		{if $CUSTOMLINK->linkicon}
			<a class="webMnu" href="{$customlink_href}"><img hspace=5 align="absmiddle" border=0 src="{$CUSTOMLINK->linkicon}"></a>
		{/if}
		<a class="webMnu" href="{$customlink_href}">{$customlink_label|@getFixedLabel}</a>
						 </td>                                                        
</tr>
			  {/foreach}
		 </table>
{/if}

{* vtlib customization: Custom links on the Detail view basic links *}

{* vtlib customization: Custom links on the Detail view *}
{if $CUSTOM_LINKS && $CUSTOM_LINKS.DETAILVIEW}
<br/>
{if !empty($CUSTOM_LINKS.DETAILVIEW)}
<table width="100%" border="0" cellpadding="5" cellspacing="0">
<tr>
						 <td align="left" class="dvtUnSelectedCell dvtCellLabel">
	  <a href="javascript:;" onmouseover="fnvshobj(this,'vtlib_customLinksLay');" onclick="fnvshobj(this,'vtlib_customLinksLay');"><b>{$APP.LBL_MORE} {$APP.LBL_ACTIONS} &#187;</b></a>
	</td>
					</tr>
</table>
<br/>
<div style="display: none; left: 193px; top: 106px;width:155px; position:absolute;" id="vtlib_customLinksLay"
 onmouseout="fninvshnew('vtlib_customLinksLay')" onmouseover="fnvshNrm('vtlib_customLinksLay')">
<table bgcolor="#ffffff" border="0" cellpadding="0" cellspacing="0" width="100%">
	<tr>
							  <td style="border-bottom: 1px solid rgb(204, 204, 204); padding: 5px;"><b>{$APP.LBL_MORE} {$APP.LBL_ACTIONS} &#187;</b>
							  </td>
						 </tr>
	<tr>
		<td>
			{foreach item=CUSTOMLINK from=$CUSTOM_LINKS.DETAILVIEW}
				{assign var="customlink_href" value=$CUSTOMLINK->linkurl}
				{assign var="customlink_label" value=$CUSTOMLINK->linklabel}
				{if $customlink_label eq ''}
					{assign var="customlink_label" value=$customlink_href}
				{else}
					{* Pickup the translated label provided by the module *}
					{assign var="customlink_label" value=$customlink_label|@getTranslatedString:$CUSTOMLINK->module()}
				{/if}
				<a href="{$customlink_href}" class="drop_down">{$customlink_label}</a>
			{/foreach}
		</td>
	</tr>
</table>
</div>
{/if}
{/if}
{* END *}
<!-- Action links END -->
	{/if}

</form>
<!--	TemplatesMarge start	 -->
<form action="index.php" method="post" name="TemplateMerge" id="form">
	<input type="hidden" name="module" value="{$MODULE}">
	<input type="hidden" name="parenttab" value="{$CATEGORY}">
	<input type="hidden" name="record" id="record" value="{$ID}">
	<input type="hidden" name="action">
				  
		 <!--工具-->
		 <!-- Following condition is added to avoid the Tools section in Products and Vendors because we are not providing the Print and Email Now links throughout all the modules. when we provide these links we will remove this if condition -->
		 {if $TEMPLATEPRINTS neq 'NOTEMPLATEPRINT'&& $MODULE neq 'Attachment'}
			
				<span class="genHeaderSmall" style="display:block;margin-bottom:10px;">{'TOOLS'|@getFixedLabel}</span> 
	
					<table class="listTable" width="103%" cellspacing="0" cellpadding="5" border="0">
						 <tbody>
							  <tr>
									<td class="colHeader">
										{'Please_select_a_template'|@getFixedLabel}
									</td>
							  </tr>
							  <tr>
									<td >
										 <select class="borderALL"  id="templateprinttype" name="templateprinttype" style="width:145px;">
											  {foreach item=templateinfo key=sequenceid from=$TEMPLATEPRINTS}
												  {assign var=printid value=$templateinfo.2}
													{if $templateinfo.1 eq 1}
														 <option value='{$printid}' selected="true">{$templateinfo.0}</option>
													{else}
													<option value='{$printid}'>{$templateinfo.0}</option>
													{/if}
											  {foreachelse}
													<option value="0">{'Please_select_print_templates'|@getFixedLabel}</option>
											  {/foreach}
										 </select>
									</td>
							  </tr>
						 <!-- To display the Export To PDF link for PO, SO, Quotes and Invoice - starts -->
						{if $TEMPLATEPRINTS neq 'NOTEMPLATEPRINT'}
					{assign var=export_pdf_action value="CreatePDF"}
							  <tr>
									<td class="listTableRow" style="border-bottom:0px;">
										 <a href="#" onclick="var printid=document.getElementById('templateprinttype').value;if(printid==0) {ldelim}
						                var confirm_str = arrJsPopLabel['PLEASESELECTPRINTTEMPLATES'];
						                 RemindsMsg('','LdPopWidth400px','','yes','',confirm_str);
										 return false;{rdelim} OpenNewWebTab('index.php?module=Settings&action=TemplatePrintHtml&tabname={$MODULE}&printid='+printid+'&record={$ID}')"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle" border="0"/></a>
										 <a href="#" class="webMnu" href="javascript:;" onclick=" var printid=document.getElementById('templateprinttype').value;if(printid==0) {ldelim}		
										var confirm_str = arrJsPopLabel['PLEASESELECTPRINTTEMPLATES'];
						                 RemindsMsg('','LdPopWidth400px','','yes','',confirm_str);return false;{rdelim} OpenNewWebTab('index.php?module=Settings&action=TemplatePrintHtml&tabname={$MODULE}&printid='+printid+'&record={$ID}')">{'PRINT'|@getFixedLabel}</a>
									</td>
							  </tr>
							  <tr>
								 <td class="listTableRow" style="border-bottom:0px;">
									<a onclick="ConvertToPDF(this,'{$MODULE}',{$ID})" href="#" class="webMnu"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle" border="0"/></a>
										 <a onclick="ConvertToPDF(this,'{$MODULE}',{$ID});" href="#" class="webMnu">{'ExporttoPDF'|@getFixedLabel}</a>
								</td>
							  </tr>
							  {if $TEMPLATEPRINTS neq 'NOTEMPLATEPRINT'}
							  <!-- Added to give link to  send Invoice PDF through mail -->
									<tr>
									<td class="listTableRow">
										 <a href="javascript:;" onclick="javascript:var printid=document.getElementById('templateprinttype').value;if(printid==0) {ldelim}
										var confirm_str = arrJsPopLabel['PLEASESELECTPRINTTEMPLATES'];
						                 RemindsMsg('','LdPopWidth400px','','yes','',confirm_str);
										 return false;{rdelim} window.open('index.php?module={$MODULE}&action=SendPDFMail&printid='+printid+'&record={$ID}')" class="webMnu"><img src="{'pointer.gif'|@lingdang_imageurl:$THEME}" hspace="5" align="absmiddle" border="0"/></a>
										<a href="javascript:;" onclick="javascript:var printid=document.getElementById('templateprinttype').value;if(printid==0) {ldelim}
										var confirm_str = arrJsPopLabel['PLEASESELECTPRINTTEMPLATES'];
						                 RemindsMsg('','LdPopWidth400px','','yes','',confirm_str);
										return false;{rdelim} window.open('index.php?module={$MODULE}&action=SendPDFMail&printid='+printid+'&record={$ID}')" class="webMnu">{'Send_Email_Add_PDF'|@getFixedLabel}</a> 
									</td>
									</tr>
							  {/if}
						 {/if}
						 <!-- Above if condition is added to avoid the Tools section in Products and Vendors because we are not providing the Print and Email Now links throughout all the modules. when we provide these links we will remove this if condition -->
						 </tbody>
					</table>
		 {/if}
</form>
<!--	TemplatesMarge Exit -->