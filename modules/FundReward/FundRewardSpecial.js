if(typeof(changeUser)!='undefined')
{
    changeUser.afterOperation=function (type,userid,username)
    {
         if(type=='Allocate')
         {
            if(isadmin==1)
            {
                //
                ld('#dtlview_smownerid_FundReward').html('<a href="index.php?module=Users&action=DetailView&record='+userid+'&blockidsetting=2&fieldidsetting=1">'+username+'</a>');
                
            }
            else
            {
                ld('#dtlview_smownerid_FundReward').text(username);
            }
         }
             
    }
}