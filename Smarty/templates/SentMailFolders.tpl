<!--修改编码格式:统一编码：UTF-8-->
<script type="text/javascript" src="modules/Emails/Emails.js"></script>

<script language="javascript">
function ShowFolders(folderid)
{ldelim}

	if(document.getElementById('mail_fldrname')!=null){ldelim}
		var mail_folder=document.getElementById('mail_fldrname').innerHTML;
	{rdelim}
    else 
    {ldelim}
        return ;
    {rdelim}
	gselectedrowid = 0;
	$("status").style.display="inline";
	gFolderid = folderid;
	folder='';
//	getObj('search_text').value = '';
	switch(folderid)
	{ldelim}
		case 1:
			getObj('mail_fldrname').innerHTML = '<b>{'LBL_ALLMAILS'|@getFixedLabel}</b>';
			folder='<b>{'LBL_ALLMAILS'|@getTranslatedString:$MODULE}</b>';
			break;
		case 2:
			getObj('mail_fldrname').innerHTML = '<b>{'Mine'|@getFixedLabel}{'EMAIL'|@getFixedLabel}</b>';
			folder='<b>{'LBL_TO_CONTACTS'|@getTranslatedString:$MODULE}</b>';
			break;
		case 3:
			getObj('mail_fldrname').innerHTML = '<b>{'Myteam'|@getFixedLabel}{'EMAIL'|@getFixedLabel}</b>';
			folder='<b>{'LBL_TO_ACCOUNTS'|@getTranslatedString:$MODULE}</b>';
			break;
		//case 4:
			//getObj('mail_fldrname').innerHTML = '<b>{'LBL_TO_LEADS'|@getFixedLabel}</b>';
			//folder='<b>{'LBL_TO_LEADS'|@getTranslatedString:$MODULE}</b>';
			//break;
		//case 5:
			//getObj('mail_fldrname').innerHTML = '<b>{'LBL_TO_USERS'|@getFixedLabel}</b>';
			//folder='<b>{'LBL_TO_USERS'|@getTranslatedString:$MODULE}</b>';
			//break;
		//case 6:
			//getObj('mail_fldrname').innerHTML = '<b>{'LBL_QUAL_CONTACT'|@getFixedLabel}</b>';
			//folder='<b>{'LBL_QUAL_CONTACT'|@getTranslatedString:$MODULE}</b>';
            //break;
        case 7:
            getObj('mail_fldrname').innerHTML = '<b>{'LBL_ALLMAILS'|@getFixedLabel}</b>';
			folder='<b>{'LBL_DRAFTS'|@getTranslatedString:$MODULE}</b>';
	{rdelim}
	if(document.getElementById('folderid') != undefined)
	{ldelim}
		document.getElementById('folderid').value = folderid;
	{rdelim}
	new Ajax.Request(
                'index.php',
                {ldelim}queue: {ldelim}position: 'end', scope: 'command'{rdelim},
                method: 'post',
                postBody: 'module=Emails&ajax=true&action=EmailsAjax&file=ListView&folderid='+folderid,
                onComplete: function(response) {ldelim} 
                                        $("status").style.display="none";	
										if(document.getElementById('mail_fldrname')!=null){ldelim}
											if(document.getElementById('_mailfolder_'+mail_folder)!=null && document.getElementById('_mailfolder_'+mail_folder).className!='mm_folder'){ldelim}
												document.getElementById('_mailfolder_'+mail_folder).className='mm_folder';
												document.getElementById('_mailfolder_'+mail_folder).parentNode.className='';
											{rdelim}
										{rdelim}
										if(document.getElementById('_replydiv_')!=null){ldelim}
											if(document.getElementById('_replydiv_').style.display!='none')
											{ldelim}
											document.getElementById('_replydiv_').style.display='none';
											document.getElementById('_contentdiv_').style.display='block';
												document.getElementById('_mailfolder_mm_compose').parentNode.className='';
												document.getElementById('_mailfolder_mm_compose').className='';
											{rdelim}
										{rdelim}
										if(document.getElementById('_settingsdiv_')!=null){ldelim}
											if(document.getElementById('_settingsdiv_').style.display!='none')
											{ldelim}document.getElementById('_settingsdiv_').style.display='none';
											document.getElementById('_contentdiv_').style.display='block';
												document.getElementById('_mailfolder_mm_settings').parentNode.className='';
												document.getElementById('_mailfolder_mm_settings').className='';
											{rdelim}
										{rdelim}
										if(document.getElementById('_contentdiv2_')!=null){ldelim}
											if(document.getElementById('_contentdiv2_').style.display!='none')
											{ldelim}
											document.getElementById('_contentdiv2_').style.display='none';
											document.getElementById('_contentdiv_').style.display='block';
												document.getElementById('_mailfolder_mm_settings').parentNode.className='';                                                                                                
											{rdelim}
										{rdelim}
                                        if(gFolderid == folderid)
                                        {ldelim}
                                                gselectedrowid = 0;
                                                document.getElementById("email_con").innerHTML="";
                                               	document.getElementById("email_con").innerHTML=response.responseText;
												//$('EmailDetails').innerHTML = '<table valign="top" border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td ><table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td colspan="2">&nbsp;</td></tr></tbody></table></td></tr><tr><td style="padding-top:10px;" height="284" valign="top"></td></tr></tbody></table>';
                                                $('EmailDetails').innerHTML = '';
                                                execJS($('email_con'));
                                        {rdelim}
                                        else
                                        {ldelim}
                                                $("email_con").innerHTML=response.responseText;
                                                //$('EmailDetails').innerHTML = '<table valign="top" border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td ><table border="0" cellpadding="0" cellspacing="0" width="100%"><tbody><tr><td colspan="2">&nbsp;</td></tr></tbody></table></td></tr><tr><td style="padding-top:10px;" height="284" valign="top"></td></tr></tbody></table>';
                                                $('EmailDetails').innerHTML = '';
                                                execJS($('email_con'));
                                        {rdelim}
										if(document.getElementById('_contentdiv_')!=null){ldelim}                                        
											//if(document.getElementById('_mailfolder_mm_drafts').parentNode.className=='mm_folder_selected'){ldelim}
												document.getElementById('_mailfolder_mm_drafts').parentNode.className='';
											//	document.getElementById('mm_folder mm_folder_selected').className='';                                                            
											//{rdelim}
                                                
                                                document.getElementById('_mailfolder_mm_drafts').className='';                                            
                                            	document.getElementById('_mailfolder_mm_drafts').parentNode.className='';
											    document.getElementById('mm_folder mm_folder_selected').className='';                                              
										{rdelim}	
                                {rdelim}
                        {rdelim}
	);

{rdelim}
</script>


<!-- Sent mail -->
<span class="emailKind"><span class="icon-homeimg icon-emial01"></span><span class="span2">{'LBL_SENT_MAILS'|@getFixedLabel}</span></span>
<ul>
    <li id="mylimenu2" onclick="navCheck(2)">
        <span class="icon-homeimg icon-emial03"></span>&nbsp;
        <a href="javascript:;" onclick="ShowFolders(2)" class="webMnu">{'Mine'|@getFixedLabel}{'EMAIL'|@getFixedLabel}</a>
	</li>
	{if $IS_ADMIN eq 'on'}
    <li id="mylimenu1" onclick="navCheck(1)">
        <span class="icon-homeimg icon-emial02"></span>&nbsp;
        <a href="javascript:;" onclick="ShowFolders(1)" class="webMnu">{'LBL_ALLMAILS'|@getFixedLabel}</a>
	</li>
	{/if}
	<!--<li id="mylimenu3" onclick="navCheck(3)">
        <span class="icon-homeimg icon-emial04"></span>&nbsp;
    	<a href="javascript:;" onclick="ShowFolders(3)" class="webMnu">{'Myteam'|@getFixedLabel}{'EMAIL'|@getFixedLabel}</a>
	</li>-->
</ul>