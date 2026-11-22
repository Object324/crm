 
var popupobj=CrmPopup.getPopupObj("last");
popupobj.after_duplicate=function()
{
    
    var popupobj=CrmPopup.getPopupObj("last");
    
     var tex=CrmPopup.getHtmlobjval(popupobj.divid,"cpstatus")
  
    //RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['ifsendpaythestatehasebeenselectedaspartofthe']);
     // reutrn false;
      if(tex.indexOf('已付')!=-1)
      {

         if(confirm(arrJsPopLabel['ifsendpaythestatehasebeenselectedaspartofthe'])==false)
         {
            puyoungJS_DialogBox.unblock();
            return false;
         }
      }
    
   
    
     return true;
}