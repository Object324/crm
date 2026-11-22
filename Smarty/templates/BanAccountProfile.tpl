
<form action="index.php" method="post" name="frmPotentialstShare" class="bank_form">
    
    <input  type="hidden" name="module" value="BankAccountSet"/>
    <input  type="hidden" name="action" value="SaveAccountProfile"/>
  
    <div class="pad10">
        <div style="text-align: center;padding: 15px 0;">
            <input type="radio" name="aa" value="Y" {$ALLUSER} style="margin:-2px 2px 0;"/>{'Everyoneoperational'|@getFixedLabel} 
            <input type="radio" name="aa" value="N" {$SELECTUSER} onclick="docheck('{$MODULE}')"style="margin:-2px 2px 0 20px;"/>{'Somepeopleoperable'|@getFixedLabel}
            <input type="hidden" value="{$UIDS}" name="owners" id="owners"/> 
        </div>
        <div class="divPeople-Content">
            <B>{'Operating_Instructions'|@getFixedLabel}:</B>
        </div>
        <div class="divPeople-Content">
            {'Corporate_Account_Setup_Instructions_1'|@getFixedLabel}
        </div>
        <div class="divPeople-Content">
            {'Corporate_Account_Setup_Instructions_2'|@getFixedLabel}
        </div>
        <div class="divPeople-Content">
            {'Corporate_Account_Setup_Instructions_3'|@getFixedLabel}
        </div>
    </div>
   
</form>