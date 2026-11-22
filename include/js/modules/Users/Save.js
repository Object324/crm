var popupobj=CrmPopup.getPopupObj("last");
popupobj.addOtherSaveUrl=function(){
    
    var tmpurl='';
    tmpurl+="&moduleRecord="+ld('#moduleRecord').val();
    tmpurl+="&modueltype="+ld('#modueltype').val();
    tmpurl+="&viewothers="+    ld("#viewothers").val();
    tmpurl+="&editothers="+    ld("#editothers").val();
    tmpurl+="&delothers="+    ld("#delothers").val();
    tmpurl+="&viewselfbills="+    ld("#viewselfbills").val();
    tmpurl+="&viewcreateme="+    ld("#viewcreateme").val();
    tmpurl+="&editcreateme="+     ld("#editcreateme").val();
    tmpurl+="&ODuplicateID=" + ld('#ODuplicateID').val();
   return tmpurl;
}
