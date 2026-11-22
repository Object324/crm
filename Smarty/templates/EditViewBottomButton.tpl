{if $MODULE eq 'Emails'}
    <input title="{'SAVE'|@getFixedLabel}" class="create" onclick="window.open('index.php?module=Users&action=lookupemailtemplates&entityid={$ENTITY_ID}&entity={$ENTITY_TYPE}','emailtemplate','top=100,left=200,height=400,width=300,menubar=no,addressbar=no,status=yes')" type="button" name="button" value="{'SAVE'|@getFixedLabel}">
    <input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';this.form.send_mail.value='true'; return formValidate()" type="button" name="button" value="{'SAVE'|@getFixedLabel}" >
{/if}
{if $MODULE eq 'Webmails'}
    <input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';this.form.module.value='Webmails';this.form.send_mail.value='true';this.form.record.value='{$ID}'" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
{elseif $MODULE eq 'Accounts'}
    {if $MODE eq 'edit'}
        <input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save'; displaydeleted(); if(AccontContactValidate()){ldelim} if(formValidate()) {ldelim} if(FieldDuplicateValidate('Accounts',ld('#frmeditview'),this) {ldelim} AddressSync(this.form,'{$ID}'); {rdelim} {rdelim} else return false;{rdelim} else return false;"  type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
    {else}
        <input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save'; if(AccontContactValidate()){ldelim} if(formValidate()) return FieldDuplicateValidate('Accounts',ld('#frmeditview'),this);else return false;{rdelim} else return false;" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
    {/if}
{elseif $MODULE eq 'Events'}
    <input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save';if(check_form()) {ldelim}return FieldDuplicateValidate('{$MODULE}',this.form) ; {rdelim}else{ldelim} return false;{rdelim}" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
{elseif $MODULE eq 'CashBill'}
    <input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save'; displaydeleted();if( verifyPaymentPlan()) {ldelim }if( formValidate())  return FieldDuplicateValidate('{$MODULE}',this.form,this) ;else return false;{rdelim} else {ldelim}return false;{rdelim}" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
{elseif $MODULE eq 'SendCashBill'}
    <input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save'; displaydeleted();if( verifySendPayment()) {ldelim }if( formValidate())  return FieldDuplicateValidate('{$MODULE}',this.form,this) ;else return false;{rdelim} else {ldelim}return false;{rdelim}" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
{elseif get_file_address($MODULE,$MODULE|cat:'DetailFieldsHtml')}
    <input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save'; displaydeleted();if( formValidate()) {ldelim }if(verifyTabDetailField() )  return FieldDuplicateValidate('{$MODULE}',this.form,this) ;else return false;{rdelim} else {ldelim}return false;{rdelim}" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >            
{elseif $MODULE eq 'LessionPlan'}
    <input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.form.action.value='Save'; displaydeleted();if( isformValidate(this)) {ldelim }{rdelim} else {ldelim}return false;{rdelim}" type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >

{else}
    <input title="{'SAVE'|@getFixedLabel}" class="save" onclick="this.disabled=true;this.form.action.value='Save';  displaydeleted();if( formValidate())  return FieldDuplicateValidate('{$MODULE}',this.form,this);else {ldelim} this.disabled=false; return false;{rdelim} " type="button" name="button" value="{'SAVE'|@getFixedLabel}" style="width:70px" >
{/if}                                      
{if $MODULE eq 'BankAccountSet'&& $CONFIRMEDST neq '1'}
    <input title="{'Save_and_confirm'|@getFixedLabel}" class="save" style="width:90px" onclick="if(confirm(arrJsPopLabel['UPDATEBANKCURRENCY'])){ldelim }document.getElementById('bankconfirmed').value=1;this.form.action.value='Save';  displaydeleted();if( formValidate())  return FieldDuplicateValidate('{$MODULE}',this.form,this) ;else return false;{rdelim} else {ldelim}return false;{rdelim}" type="button" name="button" value="{'Save_and_confirm'|@getFixedLabel}" >
{/if}
{if $CREATE neq 'true'}
    <input title="{'CANCEL'|@getFixedLabel}" class="cancel" onclick="window.history.back()" type="button" name="button" value="{'CANCEL'|@getFixedLabel}" style="width:70px">
{else}
    <input title="{'CANCEL'|@getFixedLabel}" class="cancel" onclick="window.history.back();" type="button" name="button" value="{'CANCEL'|@getFixedLabel}" style="width:70px">
{/if}