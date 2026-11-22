//选择弹出框
function selectSearchField(){
    
   
}
selectSearchField.type="selectsearchfield";
selectSearchField.load=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText,searchmodule)
{       
    
     selectSearchField.prototype=new CrmPopup();  
     selectSearchField.prototype.constructor=selectSearchField;  
     selectSearchField.prototype.type=selectSearchField.type;
     selectSearchField.prototype.curmodule=module;//弹出层所在的模块
     selectSearchField.prototype.reload_showrelationlistobj=undefined;
     var  selectSearchFieldobj=new selectSearchField();
     selectSearchFieldobj.setParams(headtitle,Okfun,Cancelfun,cssWidth,searchmodule,OkfunParamObj,OkText,CancelfunParamObj,CancelText);
    return selectSearchFieldobj;
    
}