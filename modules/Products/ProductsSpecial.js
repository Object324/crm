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
                ld('#dtlview_prosmownerid_Products').html('<a href="index.php?module=Users&action=DetailView&record='+userid+'&blockidsetting=2&fieldidsetting=1">'+username+'</a>');
                
            }
            else
            {
                ld('#dtlview_prosmownerid_Products').text(username);
            }
         }
             
    }
}