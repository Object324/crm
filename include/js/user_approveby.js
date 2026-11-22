function set_value_approveby(idvalue,usernamevalue,action_name)
{
    var idvalue = idvalue;
    var usernamevalue = usernamevalue;
    var action_name = action_name;
    //alert(idvalue);
    //alert(usernamevalue);
    //alert(action_name);
    if(action_name == "EditView")
    {
        window.opener.document.getElementById('approveby').value = idvalue;
        window.opener.document.getElementById('approveby_name').value = usernamevalue;
    }
    else
    {
        window.opener.document.getElementById('approve_show').value = idvalue;
        window.opener.document.getElementById('dtlview_Approveby').value = usernamevalue;
        window.opener.document.getElementById('txtbox_Approveby').value = usernamevalue;
    }

    
}
function search_user()
{
    var search_txt = document.getElementById('search_txt').value;
    var search_field = document.getElementById('search_field').value;
    //alert(search_txt);
    //alert(search_field);
    new Ajax.Request(
				'index.php',
				{
					queue: {
						position: 'end',
						scope: 'command'
					},
					method: 'post',
					postBody:"action=approvebyusers&module=Users&search_txt="+search_txt+"&search_field="+search_field,
					onComplete: function(response) {
                    //alert(response.responseText[1]);
				    if(response.responseText.indexOf('#SUCCESS#')>-1){
				    var result=response.responseText.split('#SUCCESS#');
                    $('ListViewContents').innerHTML=result[1];   
					      
                           }
					  }
				}
				);
    
}