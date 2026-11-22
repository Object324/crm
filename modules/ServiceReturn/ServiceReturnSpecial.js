if(typeof(changeUser)!='undefined')
{
    changeUser.afterOperation=function (type,userid,username,module)
    {
        var isadmin=document.getElementById('hdtxt_IsAdmin').value;
      
		if(type=='Allocate')
		{
			if(isadmin==1)
			{
				//dtlview_assigned_user_id_NormalApprove
				ld('#dtlview_assigned_user_id_'+module).html('<a href="index.php?module=Users&action=DetailView&record='+userid+'&blockidsetting=2&fieldidsetting=1">'+username+'</a>');
			}
			else
			{
				ld('#dtlview_assigned_user_id_'+module).text(username);
			}
		}else  if(type=='ChangeCreator'){
			ld('#dtlview_smcreatorid').text(username);
		}
             
    }
}