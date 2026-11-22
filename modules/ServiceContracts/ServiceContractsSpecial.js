 clearModuleProduct.other_clear=function()
    {
        
        document.forms['EditView'].salesorder_name.value='';
        
    }
   
    
if(typeof(changeUser)!='undefined')
{
    changeUser.afterOperation=function (type,userid,username)
    {
        var isadmin=document.getElementById('hdtxt_IsAdmin').value;
         if(type=='Allocate')
         {
            if(isadmin==1)
            {
                //
                ld('#dtlview_ServiceContractsassigned_user_id_ServiceContracts').html('<a href="index.php?module=Users&action=DetailView&record='+userid+'&blockidsetting=2&fieldidsetting=1">'+username+'</a>');
                
            }
            else
            {
                ld('#dtlview_ServiceContractsassigned_user_id_ServiceContracts').text(username);
            }
         }
          else  if(type=='ChangeCreator')
         {
            ld('#dtlview_ServiceContractscreator').text(username);
         }
             
    }
}

