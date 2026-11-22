//批量编辑弹出层
function MassEditPopup()
{
    var that=this;
    this.picklistobjarray=[];//下拉框对象(cls_picklist
    var parentshow=this.show;//调用父类show()函数
    this.show=function(htmlcontent)
    {
        var that=this;
        parentshow.apply(this,[htmlcontent]);  //调用父类show()函数
        massedit_initOnChangeHandlers();
        fielddepend=new FieldDependencies(this.picklistdepency);
       	fielddepend.setup();
        that.fieldname_fields=[];
        that.uitypes = [];
        that.fieldname_fields = [];
         for(var i=0;i<this.fields.length;i++)
        {
             if(this.fields[i].uitype==33){
                        var tmpfieldname=that.fields[i].fieldname; 
                        ld('#'+tmpfieldname).select2({closeOnSelect: true,
                        dropdownParent: ld("#" + that.divid)});
                  }
                  var fieldname=that.fields[i].fieldname;
                var columnname=that.fields[i].columnname;
                that.uitypes[fieldname]=that.fields[i].uitype;
                that.fieldname_fields[fieldname]=that.fields[i];
        }
        // 0047467: 批量操作的时候，下拉框的设置按钮位置错误，增加弹出层的宽度
        ld("#"+that.divid).css("width",that.getWidth());
        that.center();
    }
    this.picklist_arrow_click=function(event,fieldname)
   {
   
      cmb_fldname=fieldname;//用于picklist.js中document.onclick调用
     cmb_parentdivid=this.divid;//用于picklist.js中document.onclick调用
     
      that.picklistobjarray[fieldname].arrow_click(fieldname);
      
   }
   this.picklist_end_foucs=function(event,fieldname)
    {
		ld("#"+this.divid+" [name=cmb_span_optiontext_"+fieldname+"]").select();

    }
    
    this.getWidth=function(){
       return  parseInt(CrmPopup.getClientWidth()*0.8);
    }
}
MassEditPopup.type="masseditpopup";
MassEditPopup.pagetype='create_edit_modulepage';
MassEditPopup.load=function(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText)
{
     MassEditPopup.prototype=new CrmPopup();  
     MassEditPopup.prototype.constructor=MassEditPopup;  
     MassEditPopup.prototype.picklistdepency=[];
     
     MassEditPopup.prototype.type=MassEditPopup.type;
  
     MassEditPopup.prototype.fields="";
     MassEditPopup.prototype.fieldname="";
     MassEditPopup.prototype.fieldlabel="";
     MassEditPopup.prototype.fielddatatype="";

     var  MassEditPopupobj=new MassEditPopup();
     MassEditPopupobj.pagetype=MassEditPopup.pagetype;
     MassEditPopupobj.setParams(headtitle,Okfun,Cancelfun,cssWidth,module,OkfunParamObj,OkText,CancelfunParamObj,CancelText);
    return MassEditPopupobj;
    
}
function massEditSave()
{
     var popupobj=CrmPopup.getPopupObj("last");
     
     var btnOkObj=popupobj.getbtnOkobj();
     //zkt 20230921 批量编辑防止多次点击 BUG0073071  贺桃：批量编辑，保存按钮可以多次点击
     btnOkObj.disabled=true;
    
    if(!massEditFormValidate())
        btnOkObj.disabled=false;
    else
        massEditSubmit();
}
massEditSave.funname="massEditSave";

