
SaveDataRecord.after_validate=function()
{
     var popupobj=CrmPopup.getPopupObj("last");
     var divid=popupobj.divid;

    if(CrmPopup.isExistsObj(divid,'cmb_span_optiontext_servicetype'))
        {
            var servicetype=CrmPopup.getHtmlobjval(divid,"cmb_span_optiontext_servicetype") ;           
            if(servicetype.indexOf('иоце')>=0)
            {   
                var hopetime='';
                var hopetime_end='';
                var hope_address='';
               
                if(CrmPopup.isExistsObj(divid,'hopetime'))
                {
                   hopetime=CrmPopup.getHtmlobjval(divid,"hopetime");                   
                }
                if(CrmPopup.isExistsObj(divid,'hopetime_end'))
                {
                   
                   hopetime_end=CrmPopup.getHtmlobjval(divid,"hopetime_end");                 
                }
                if(CrmPopup.isExistsObj(divid,'hope_address'))
                {
                  
                    hope_address=ld("#"+divid+" [name=hope_address]").val();         
                            
                } 
               if(hopetime==''&&CrmPopup.isExistsObj(divid,'hopetime')) 
               {                 
                    for(var j=0;j<popupobj.fields.length;j++)
                    {
                        if("hopetime"==popupobj.fields[j].columnname)
                        {
                            alert(popupobj.fields[j].fieldlabel+arrJsPopLabel['CANOTEMPTY']);
                            break;
                        }
                    }
                   
               	   var currObj = CrmPopup.findHtmlobj(divid,'hopetime');
                   currObj.focus();
                 
                   return false; 
               }             
               else if(hopetime_end==''&&CrmPopup.isExistsObj(divid,'hopetime_end'))
                {               
                    for(var j=0;j<popupobj.fields.length;j++)
                    {
                        if("hopetime_end"==popupobj.fields[j].columnname)
                        {
                            alert(popupobj.fields[j].fieldlabel+arrJsPopLabel['CANOTEMPTY']);
                            break;
                        }
                    }
                   
               	   var currObj = CrmPopup.findHtmlobj(divid,'hopetime_end');
                   
               	    currObj.focus(); 
                   return false; 
                }
                else if(CrmPopup.isExistsObj(divid,'hope_address')&&trim(hope_address.replace(/[\n]/ig,''))==''||trim(hope_address.replace(/[\n]/ig,''))=='<br>')
                {                  
                   for(var j=0;j<popupobj.fields.length;j++)
                    {
                        if("hope_address"==popupobj.fields[j].columnname)
                        {
                            alert(popupobj.fields[j].fieldlabel+arrJsPopLabel['CANOTEMPTY']);
                            break;
                        }
                    }
                   
               	   var currObj = CrmPopup.findHtmlobj(divid,'hope_address');                 
                   currObj.focus(); 
                   return false;
                }                
                if(hopetime>hopetime_end&&CrmPopup.isExistsObj(divid,'hopetime')&&CrmPopup.isExistsObj(divid,'hopetime_end')  ) 
                {               
                    for(var j=0;j<popupobj.fields.length;j++)
                    {
                        if("hope_address"==popupobj.fields[j].columnname)
                        {
                            hopetime_fieldlabel=popupobj.fields[j].fieldlabel;
                            break;
                        }
                        if("hopetime_end"==popupobj.fields[j].columnname)
                        {
                            hopetime_end_fieldlabel=popupobj.fields[j].fieldlabel;
                            break;
                        }
                    }
                    
                    
                    alert(hopetime_fieldlabel+arrJsPopLabel['SHOULDLESSTHANOREQUAL']+hopetime_end_fieldlabel);      
                                  
                    return false;
                }                              
            }
            return true;                
         }
	 return true; 
}
