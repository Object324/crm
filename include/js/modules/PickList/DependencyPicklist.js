/*+********************************************************************************
 *{*修改编码格式:统一编码：UTF-8*}
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ********************************************************************************/

var modifiedMappingValues = new Array();
var DependencyPicklist=function()
{
    this.selectmodule="";
    this.BLOCKIDSETTING="";
    this.FIELDIDSETTING="";
    this.selectdepencyefieldsobj="";
    this.childnames="";
    this.selectparenttext="";
    this.sourcefieldnames="";
    
    this.mode='create';
    
    
}
var DepencyPickListObj=new DependencyPicklist();
function changeDependencyPicklistModule(BLOCKIDSETTING,FIELDIDSETTING){
	ld('#rptContentLoading').show();
	var oModulePick = $('pickmodule')
	var module=oModulePick.options[oModulePick.selectedIndex].value;
	
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'action=PickListAjax&module=PickList&directmode=ajax&file=PickListDependencySetup&moduleName='+encodeURIComponent(module)+'&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING,
			onComplete: function(response) {
				ld('#rptContentLoading').hide();
				$("picklist_datas").update(response.responseText);
			}
		}
		);
}
/*
新增级联
*/
function addNewDependencyPicklist(BLOCKIDSETTING,FIELDIDSETTING) {
	var selectedModule = $('pickmodule').value;
    DepencyPickListObj=new DependencyPicklist();
    DepencyPickListObj.mode='create';
    
    DepencyPickListObj.selectmodule=selectedModule;
	if(selectedModule == '') {
        var confirm_str = arrJsPopLabel['PLEASESELECTMODULEDEPE'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
		return false;
	}
    var Popupobj=CrmPopup.load("",DepencyEditSecond,"","LdPopWidth600px",selectedModule,"","","","");
    Popupobj.prevshow();
  
    var urlstring='index.php?action=PickListAjax&module=PickList&directmode=ajax&file=PickListDependencySetup&submode=editdependency&moduleName='+encodeURIComponent(selectedModule)+'&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING
	//ld('#rptContentLoading').show();
	  ld.ajax({
                url: urlstring,
                type: 'POST',
                data:'',
                dataType:'json',
                async: true,//
                timeout: 10000,
                               
                success: function(data)
                {
                    if(data.code==1)
                    {
                       //ld('#rptContentLoading').hide();
                       Popupobj.createScrollDiv();//创建滚动条
                       Popupobj.DepencyPickListObj=DepencyPickListObj;
                        Popupobj.setHeadTitle(data.result.title);
                        Popupobj.selectmodule=selectedModule;
                       Popupobj.module='Settings';
                       
                        Popupobj.setCancelText(data.result.canceltext);
                        Popupobj.setOkText(data.result.oktext); 	
                        Popupobj.show(data.result.content);	   
                        Popupobj.setScrollDivMaxHeight();       
                         DepencyPickListObj.BLOCKIDSETTING=BLOCKIDSETTING;
                        DepencyPickListObj.FIELDIDSETTING=FIELDIDSETTING;
                        Popupobj.DepencyPickListObj=DepencyPickListObj;
                    }
                    else
                    {
                        RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                                   Popupobj.CancelEvent();
                    }
                });

}
function gotoNewFirstStep()
{
    //var prevpopupobj=CrmPopup.getPopupObj("lastprev");
    //上一步
    var popupobj=CrmPopup.getPopupObj("last");
    
    popupobj.CancelEvent();
   
}
gotoNewFirstStep.funname="gotoNewFirstStep";
function DepencyEditSecond() {
    var BLOCKIDSETTING,FIELDIDSETTING,module;
    var prevpopupobj=CrmPopup.getPopupObj("last");


    if(DepencyPickListObj.mode=='create')
    {
                 //var prevpopupobj=CrmPopup.getPopupObj("last");
        //BUG20241029-53 //zxm @date:2024/10/29 @reason: 点编辑级联字段报错。新建才有上一步选上级字段的弹框
        if(ld('#sourcefield').length>0&&$('sourcefield').options.length == 0){
            var confirm_str = arrJsPopLabel['PLEASESELECTONEENTITY'];
            RemindsMsg("","LdPopWidth400px",module,"yes","yes",confirm_str);
            return false;
        }
                 module=prevpopupobj.DepencyPickListObj.selectmodule;
            	var sourcePick = $('sourcefield');
            	var sourceField = sourcePick.options[sourcePick.selectedIndex].value;
            
            	var targetPick = $('targetfield');
            	var targetField = targetPick.options[targetPick.selectedIndex].value;
            
            	if(sourceField == targetField) {
            		ld('#rptContentLoading').hide();
            		var confirm_str = arrJsPopLabel['SOURCETARGETFIELDSSHOULDNOTSAME'];
            		RemindsMsg("","LdPopWidth400px",module,"yes","yes",confirm_str);
            		return false;
            	}
    }
    else
    {
        	var sourceField = DepencyPickListObj.sourcefield;
            var targetField = DepencyPickListObj.targetfield;
            module=DepencyPickListObj.selectmodule;
    }
   
    if(DepencyPickListObj.mode=='create')
    {
         var Popupobj=CrmPopup.load("",gotoNewFirstStep,"","LdPopWidth800px",'Settings',"","","","");
         Popupobj.DepencyPickListObj=prevpopupobj.DepencyPickListObj;
         Popupobj.selectmodule=prevpopupobj.DepencyPickListObj.selectmodule;
         
             /*
        重写创建弹出层底部包括按钮
        */
        Popupobj.createBottomHtml=function()
        {
            
            this.popupbottomhtml='<div class="E_pbtn" id="'+this.divid+'_popupbottom"> ';
            this.popupbottomhtml+=' <input name="button" id="'+this.divid+'_btnok" class="ld-button" value="'+this.OkText+'" tagClick="'+this.Okfun.funname+'"  type="button">';
            this.popupbottomhtml+='<input name="button" onclick="saveDependency()" class="ld-button ld-button-primary" value="'+this.CancelText+'" id="'+this.divid+'_depencybtncancel" type="button">'
            this.popupbottomhtml+=' </div>';
            this.btnokid=this.divid+"_btnok";
            this.btncancelid=this.divid+"_depencybtncancel";
            
        }
    }
    else
    {
        var Popupobj=CrmPopup.load("",saveDependency,"","LdPopWidth800px",module,"","","","");
        Popupobj.module=prevpopupobj.module;//用于区分是控制面板的级联字段还是模块下拉编辑
        Popupobj.DepencyPickListObj=DepencyPickListObj;
        Popupobj.sourcefield=sourceField;
        Popupobj.targetfield=targetField;
    }
        
    if(Popupobj.DepencyPickListObj.selectdepencyefieldsobj!="")
    {
        Popupobj.selectDepencyFields=Popupobj.DepencyPickListObj.selectdepencyefieldsobj;
        Popupobj.childnames=Popupobj.DepencyPickListObj.childnames;
        Popupobj.selectparenttext=Popupobj.DepencyPickListObj.selectparenttext;
        Popupobj.sourcefieldnames=Popupobj.DepencyPickListObj.sourcefieldnames;
    }
    if(Popupobj.selectDepencyFields==undefined)
        Popupobj.selectDepencyFields=new Array();
    if(Popupobj.selectDepencyFields[sourceField]==undefined)
         Popupobj.selectDepencyFields[sourceField]=new Array();
    if(Popupobj.selectDepencyFields[sourceField][targetField]==undefined)
        Popupobj.selectDepencyFields[sourceField][targetField]=new Array();
    if(Popupobj.childnames==undefined){
        Popupobj.childnames=new Array();
        Popupobj.childnames[sourceField]=new Array();
    }
    if(Popupobj.sourcefieldnames==undefined){
        Popupobj.sourcefieldnames=new Array();
    }
    if(Popupobj.selectparenttext==undefined){
        Popupobj.selectparenttext=new Array();
        Popupobj.selectparenttext[sourceField]=new Array();
    }
    Popupobj.sourcefield=sourceField;
    Popupobj.targetfield=targetField;
    //BUG0066851 yujun kfbcrm 级联字段定制---编辑---页面加载出现两个加载图标
    //Popupobj.prevshow();
   
    var urlstring = 'moduleName='+encodeURIComponent(module)+'&sourcefield='+sourceField+'&targetfield='+targetField;
    urlstring='index.php?action=PickListAjax&module=PickList&file=DepencyEditSecond&'+urlstring+'&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING;

    urlstring+="&mode="+Popupobj.DepencyPickListObj.mode;
    if(prevpopupobj.module!='Settings')
    {
        //模块级联编辑
		//chj 2020/12/15 43655: （http://21yf.cn/ [^]）（远方咨询）销售管理-新建项目合同-合同所属城市和合同所属区/县下拉框字段点击旁边的小齿轮会报错无法对他们进行编辑。
        //@edit:liushuai,2021-07-15,reason: 0046907: (81mis.com/kfbcrm/)系统设置-级联字段-客户模块-编辑弹出页面BUG(上级字段列表框undefined)
        var sourcevalue = ld("#"+prevpopupobj.divid+" [name='"+sourceField+"']").val() != undefined?ld("#"+prevpopupobj.divid+" [name='"+sourceField+"']").val():"";
        urlstring+="&sourcevalue="+encodeURIComponent(sourcevalue);
    }
    
	ld('#rptContentLoading').show();
	  ld.ajax({
                url: urlstring,
                type: 'POST',
                data:'',
                dataType:'json',
                async: true,//
                timeout: 10000,
                               
                success: function(data)
                {
                    ld('#rptContentLoading').hide();
                    if(data.code==1){
			         	// Popupobj.createScrollDiv();//创建滚动条
                        Popupobj.setHeadTitle(data.result.title);
                        Popupobj.setCancelText(data.result.canceltext);
                        Popupobj.setOkText(data.result.oktext); 	
                        Popupobj.show(data.result.content);	   
                        Popupobj.setScrollDivMaxHeight();  
                        if(Popupobj.DepencyPickListObj.mode=='edit'){
                            changeModuleFieldOption();
                        }

                        // 需要去掉的给高度
                        Popupobj.reduceBodyHeight = 0;
                        if(ld('#'+Popupobj.divid + ' .ld-description').length > 0){
                            Popupobj.reduceBodyHeight += parseInt(ld('#'+Popupobj.divid + ' .ld-description').outerHeight());
                        }
                        // 设置内容最大高度
                        Popupobj.setPopBodyMaxHeight(".ld-pop-container");

                        tooltip(ld('#'+Popupobj.divid).find(".sort-tip-btn"), {transition: true, time: 200});
                    }
                    else
                    {
                            Popupobj.CancelEvent();
        					RemindsMsg("","LdPopWidth400px","","yes","yes",data.msg);
        					//确认事件
        					/*ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
        						var Index= response.responseText.indexOf("&");
        						var errorModule = response.responseText.substring(Index+1,response.responseText.length);
        						var blockidsetting = getUrlParam("blockidsetting");
        						var fieldidsetting = getUrlParam("fieldidsetting");
        						window.location.href="index.php?module=PickList&action=PickListDependencySetup&parenttab=Settings&blockidsetting="+blockidsetting+"&fieldidsetting="+fieldidsetting+"&moduleName="+errorModule;
                            });*/
                    }
                },
                error: function (XMLHttpRequest, textStatus, errorThrown) {
                                   popupobj.CancelEvent();
                    }
    });


}
DepencyEditSecond.funname='DepencyEditSecond';
/*
显示上下级字段下拉内容
*/
function showPickList(type,fieldname)
{
    var popupobj=CrmPopup.getPopupObj("last");
    popupobj.editfieldname=fieldname;
    popupobj.edittype="";
    var module=popupobj.DepencyPickListObj.selectmodule;
    var url='index.php?module=PickList&action=PickListAjax&file=ShowPickListSet&mode=combox&modulename='+module+'&fieldname='+fieldname;
    
    ComboxPopup.showLayer(url,module,fieldname,savePickList);
}
/**
显示最右边的级联字段
**/
function getDepencyPickList()
{
    //
      var popupobj=CrmPopup.getPopupObj("last");
    popupobj.editfieldname=popupobj.targetfield;
    popupobj.edittype="selectcols";//选择修改的级联字段
    var module=popupobj.DepencyPickListObj.selectmodule;
   var selectvalues= popupobj.selectDepencyFields[popupobj.sourcefield][popupobj.targetfield][ld("#"+popupobj.divid+" [name=parentdepecyfieldname]").val()];
    
    var url='index.php?module=PickList&action=PickListAjax&file=ShowPickListSet&mode=combox&modulename='+module+'&fieldname='+popupobj.targetfield+"&parentdependfieldname="+popupobj.sourcefield+"&parentfieldvalue="+encodeURIComponent(ld("#"+popupobj.divid+" [name=parentdepecyfieldname]").val());
    url+="&selectvalues="+JSON.stringify(selectvalues);
    
    ComboxPopup.showLayer(url,module,popupobj.targetfield,savePickList);
    
}
/*
下拉框编辑保存
*/
function savePickList()
{   
    ld('#rptContentLoading').show();
    var prevpopupobj=CrmPopup.getPopupObj("lastprev");
    var  sourcefield=prevpopupobj.sourcefield;
    var targetfield=prevpopupobj.targetfield;
   var fieldname=prevpopupobj.editfieldname;
     var popupobj=CrmPopup.getPopupObj("last");
     popupobj.edittype=prevpopupobj.edittype;
     var module=prevpopupobj.DepencyPickListObj.selectmodule;
     ld("#"+popupobj.divid+" .D_pbtnok").attr("disabled",true);
    var comboxarr = [];
    var newtextcomboxs=[];
    var changedcombox=[];
    var emptycheck = true;
    ld("#"+popupobj.divid+" input[tag='combox']").each(function(){
        var comboxname = ld(this).attr('name');
        var comboxval = encodeURIComponent(ld(this).val());//修改后的值
        var comboxoldval = encodeURIComponent(ld(this).attr('oldvalue'));//修改前的值
        //选中的颜色 zxm  2021-0617
        var pick_color = ld(this).attr('color');
        if(empty(comboxval)){
            emptycheck = false;
        }

        var comboxtext = {'type':''+comboxname+'','oldval':''+comboxoldval+'','value':''+comboxval+'','pick_color':pick_color};
        comboxarr.push(comboxtext);
        newtextcomboxs.push(comboxval);
        if(comboxoldval!=comboxval&&comboxname!='new')
        {
            changedcombox.push(comboxtext);
            
        }
       
    });
    
     if(!emptycheck){
        var confirm_str = arrJsPopLabel['DROPDOWNBOXOPTIONCANOTEMPTY'];
        RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
         ld("#"+popupobj.divid+" .D_pbtnok").attr("disabled",false);
        return false;
    }
    popupobj.changedcombox=changedcombox;
    popupobj.comboxarr=comboxarr;
    popupobj.newtextcomboxs=newtextcomboxs;
    popupobj.changedcombox=changedcombox;
    popupobj.emptycheck=emptycheck;
    if(changedcombox.length<=0)
    {
        afterOkSavePickList();
        
    }
    else
    {
        //下拉框有改变
        ld("#"+popupobj.divid+" .D_pbtnok").attr("disabled",false);
        ComboxPopup.showReplaceHistoryDataLayer(changedcombox,afterOkSavePickList);
        
    }
     ld('#rptContentLoading').hide();
   
}
savePickList.funname="savePickList";
function afterOkSavePickList()
{
    ld('#rptContentLoading').show();
    var prevpopupobj=CrmPopup.getPopupObj("lastprev");
    var  sourcefield=prevpopupobj.sourcefield;
    var targetfield=prevpopupobj.targetfield;
   var fieldname=prevpopupobj.editfieldname;
     var popupobj=CrmPopup.getPopupObj("last");
     var module=prevpopupobj.DepencyPickListObj.selectmodule;
     ld("#"+popupobj.divid+" .D_pbtnok").attr("disabled",true);
     
  // var changedcombox=[];
    var comboxarr = popupobj.comboxarr;
    var newtextcomboxs=popupobj.newtextcomboxs;
    var changedcombox=popupobj.changedcombox;
   
  
    var comboxjson = JSON.stringify(comboxarr);
    var url='index.php?module=PickList&action=PickListAjax&file=PickListActions&mode=save&savefrom=settings';
   
   
   if(prevpopupobj.edittype=='selectcols')
   {
            //级联字段保存
            url+="&sourcefield="+sourcefield+"&sourcevalue="+ld("#"+prevpopupobj.divid+" [name=parentdepecyfieldname]").val()+"&targetvalue="+(JSON.stringify(newtextcomboxs));
   }
   if(changedcombox.length>0)
   {
        url+="&changedcombox="+JSON.stringify(changedcombox);
        
   }
      
    var selectvalue = ld(":input[name='"+fieldname+"']").val();
    ld.ajax({
        url: url,
        type: 'POST',
        data:'fld_module='+module+'&fieldname='+fieldname+'&comboxjson='+encodeURIComponent(comboxjson)+'&selectvalue='+selectvalue,//wym 240103 BUG0078134 级联字段定制-编辑字段，添加“+”符号，保存后，没有显示这个符号。
        dataType:'json',
        async: true,//
        timeout: 20000,
        error: function(XMLHttpRequest, textStatus, errorThrown) {
        },
        success: function(data)
        {
            ld('#rptContentLoading').hide();
            if(data.code==1)
            {
            
                var tmps=[];
                tmps[fieldname]=[];
                
                 if(fieldname==sourcefield&&prevpopupobj.selectDepencyFields[fieldname]!=undefined){
                    //上级字段
                     var selectelementobj=ld("#"+prevpopupobj.divid+" [name=parentdepecyfieldname]");
                         /*
                    删除的元素
                    */
                    if(popupobj.delElements!=undefined&&popupobj.delElements.length>0)
                    {
                        
                        ld.each(popupobj.delElements,function(index,info){
                            var deloldtext=info['oldtext'];
                            var delreplacetext=info['replacevalue'];
                            
                            ld.each(prevpopupobj.childnames[sourcefield],function(index,tmptargetfield){
                                     if(ld.inArray(deloldtext,prevpopupobj.selectparenttext[sourcefield])>=0)
                                    {
                                             prevpopupobj.selectparenttext[sourcefield].splice(ld.inArray(deloldtext,prevpopupobj.selectparenttext[sourcefield]),1);
                                             
                                             prevpopupobj.selectDepencyFields[fieldname][tmptargetfield][deloldtext]=new Array();
                                        
                                    }
                            });
                            
                        });
                        
                    }
                 }
                 else
                 {
                   
                    if(popupobj.edittype=="selectcols")
                    {
                        //选择修改的级联字段
                        var selectelementobj=ld("#"+prevpopupobj.divid+" [name=selectfieldnames]");
                    }
                    else
                    {
                        var selectelementobj=ld("#"+prevpopupobj.divid+" [name=childdepecyfieldname]");
                    }
                    //获取删除的字段
                    if(popupobj.delElements!=undefined&&popupobj.delElements.length>0)
                    {
                            ld.each(popupobj.delElements,function(index,info){
                                var deloldtext=info['oldtext'];
                                var delreplacetext=info['replacevalue'];
                                
                                 ld.each(prevpopupobj.sourcefieldnames,function(tmpsourcefieldindex,tmpsourcefield){
                                                    
                                                   ld.each(prevpopupobj.selectparenttext[tmpsourcefield],function(tmpparentindex,tmpparentext)
                                                   { 
                                                            var targettextindex=ld.inArray(deloldtext,prevpopupobj.selectDepencyFields[tmpsourcefield][targetfield][tmpparentext]);
                                                            if(targettextindex>=0)
                                                                if(ld.inArray(delreplacetext,prevpopupobj.selectDepencyFields[tmpsourcefield][targetfield][tmpparentext])<0)
                                                                     prevpopupobj.selectDepencyFields[tmpsourcefield][targetfield][tmpparentext][targettextindex]=delreplacetext;
                                                                else
                                                                        prevpopupobj.selectDepencyFields[tmpsourcefield][targetfield][tmpparentext].splice(targettextindex,1);
                                                                        
                                                   });
                                           });
                                
                            });
                    }
                 }
                 popupobj.delElements=new Array();
                 selectelementobj.empty();
                 
                
                var len=data.result.list.length;
                var newtexts=new Array();
                var tmp_changedtext=[];
                for(var i=0;i<len;i++)
                {
                   var type=data.result.list[i].type;
                   
                    var newtext=data.result.list[i].value;
                  
                    var oldtext=data.result.list[i].oldval;
                    newtexts.push(newtext);
                    selectelementobj.append("<option value='"+newtext+"'>"+newtext+"</option>");
                    if(type=='new')
                        continue;
                    if(oldtext!=newtext)
                    {
                        tmp_changedtext.push({'oldvalue':oldtext,'value':newtext});
                    }
                    if(fieldname==sourcefield&&prevpopupobj.selectDepencyFields[fieldname]!=undefined){
                   
                        //修改了上级字段
                        //selectDepencyFields格式(三维数组)：[soucefieldname][targetfieldname][sourcetext]=array()
                       
                        ld.each(prevpopupobj.childnames[sourcefield],function(index,tmptargetfield){
                                if(ld.inArray(oldtext,prevpopupobj.selectparenttext[sourcefield])>=0)
                                {
                                        if(tmps[fieldname][tmptargetfield]==undefined)
                                             tmps[fieldname][tmptargetfield]=[];
                                        
                                        prevpopupobj.selectparenttext[sourcefield][ld.inArray(oldtext,prevpopupobj.selectparenttext[sourcefield])]=newtext;
                                       tmps[fieldname][tmptargetfield][newtext]=prevpopupobj.selectDepencyFields[fieldname][tmptargetfield][oldtext];
                               }
                        
                       });
                      
                     }
                     //修改下级字段,也可以认为修改了选择的字段值
                     if(newtext!=oldtext&&fieldname==targetfield
                         &&prevpopupobj.selectDepencyFields[sourcefield]!=undefined
                         &&prevpopupobj.selectDepencyFields[sourcefield][targetfield]!=undefined)
                         {
                                    if(prevpopupobj.edittype=='selectcols')
                                    {
                                           //修改的级联字段
                                    }
                                    else
                                    {
                                            ld.each(prevpopupobj.sourcefieldnames,function(tmpsourcefieldindex,tmpsourcefield){
                                                
                                               ld.each(prevpopupobj.selectparenttext[tmpsourcefield],function(tmpparentindex,tmpparentext)
                                               { 
                                                        var targettextindex=ld.inArray(oldtext,prevpopupobj.selectDepencyFields[tmpsourcefield][targetfield][tmpparentext]);
                                                        if(targettextindex>=0)
                                                            prevpopupobj.selectDepencyFields[tmpsourcefield][targetfield][tmpparentext][targettextindex]=newtext;
                                               });
                                       });
                                    }
                         }
                }
                // console.log(prevpopupobj.selectparenttext);
                // console.log(prevpopupobj.selectDepencyFields)
               if(fieldname==sourcefield)
               {
                //修改了上级字段
                prevpopupobj.selectDepencyFields[fieldname]=tmps[fieldname];
                
               }
                var parenttext=ld("#"+prevpopupobj.divid+" [name=parentdepecyfieldname]").val();
                if(fieldname==targetfield&&prevpopupobj.selectDepencyFields[sourcefield]!=undefined
                    &&prevpopupobj.selectDepencyFields[sourcefield][targetfield]!=undefined
                    &&prevpopupobj.selectDepencyFields[sourcefield][targetfield][parenttext]!=undefined){
                  // console.log(newtexts);
                   if(prevpopupobj.edittype=='selectcols')
                   {
                     //修改的是选择的下级字段值(最右边的框编辑)
                     prevpopupobj.selectDepencyFields[sourcefield][targetfield][parenttext]=newtexts;
                      var childobj=ld("#"+prevpopupobj.divid+" [name=childdepecyfieldname]").find("option");
                    
                        for(var i=0;i<tmp_changedtext.length;i++)
                        {
                            var oldvalue=tmp_changedtext[i]['oldvalue'];
                            var newvalue=tmp_changedtext[i]['value'];
                            ld.each(childobj,function(){
                                
                                if(ld(this).val()==oldvalue)
                                {
                                   
                                    ld(this).val(newvalue);
                                     ld(this).text(newvalue);
                                    return ;
                                }
                                
                            });
                        }
                   }
                   else
                    {
                         //修改了下级字段的值
                        var selectobj=ld("#"+prevpopupobj.divid+" [name=selectfieldnames]");
                        selectobj.empty();
                        for(var i=0;i< prevpopupobj.selectDepencyFields[sourcefield][targetfield][parenttext].length;i++)
                        {
                            var selectext=prevpopupobj.selectDepencyFields[sourcefield][targetfield][parenttext][i];
                            selectobj.append("<option value='"+selectext+"'>"+selectext+"</option>");
                            
                        }
                    }
                }
                popupobj.CancelEvent();
            }
            else
            {
                ld("#"+popupobj.divid+" .D_pbtnok").attr("disabled",false);
                var confirm_str = data.msg+arrJsPopLabel['ALREADYEXISTSREENTRY'];
                RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
            }
        }
    });
}
afterOkSavePickList.funname="afterOkSavePickList";

/*
级联字段重新排序
*/
function setselectFieldNameOrder()
{
     //修改了下级字段的值
     var popupobj=CrmPopup.getPopupObj("last");
     var sourcefield=popupobj.sourcefield;
     var targetfield=popupobj.targetfield;
     var parenttext=ld("#"+popupobj.divid+" [name=parentdepecyfieldname]").val();
     var selectobj=ld("#"+popupobj.divid+" [name=selectfieldnames]").find("option");
     popupobj.selectDepencyFields[sourcefield][targetfield][parenttext]=new Array();              
    ld.each(selectobj,function()
     {
           popupobj.selectDepencyFields[sourcefield][targetfield][parenttext].push(ld(this).val());
                            
     });
}
/*
级联字段编辑
*/
function DepencyEditFirst(module,sourcefield,targetfield,blocksetting,fieldsetting)
{
    
      
         DepencyPickListObj=new DependencyPicklist();
        DepencyPickListObj.mode='edit';
        DepencyPickListObj.selectmodule = module;
        DepencyPickListObj.sourcefield=sourcefield;
        DepencyPickListObj.targetfield=targetfield;
        DepencyPickListObj.blocksetting=blocksetting;
        DepencyPickListObj.fieldsetting=fieldsetting;
        DepencyEditSecond();
    
   
   
    
}
/**
改变上级字段的下拉选择内容
**/
function changeModuleFieldOption()
{

     var popupobj=CrmPopup.getPopupObj("last");
      var parenttext= ld("#"+popupobj.divid+" [name=parentdepecyfieldname]").val();
     var sourcefield=popupobj.sourcefield;
     var targetfield=popupobj.targetfield;
     var BLOCKIDSETTING,FIELDIDSETTING;
     ld("#"+popupobj.divid+" [name=selectfieldnames]").empty();
    // @edit:liushuai,2021-04-02,reason:45297: （http://crm.yuwangcn.com/crm [^] ） 在系统设置—>系统定制—>级联字段定制—>选择任意模块—>新增保点击存后没有记录
     if(sourcefield != undefined && targetfield != undefined && popupobj.selectDepencyFields[popupobj.sourcefield]!=undefined&&popupobj.selectDepencyFields[sourcefield][targetfield]!=undefined)
     {
       
        if(popupobj.selectDepencyFields[sourcefield][targetfield][parenttext]!=undefined)
        {
            
            var selectFieldsobj=document.getElementById("selectfieldnames");
            selectFieldsobj.options.length=0;
            var len=popupobj.selectDepencyFields[sourcefield][targetfield][parenttext].length;
            for(var i=0;i<len;i++)
            {
                var optiontext=popupobj.selectDepencyFields[sourcefield][targetfield][parenttext][i];
                var optionobj=new Option(optiontext,optiontext);
                selectFieldsobj.options.add(optionobj);
            }
            
        }
        else if(popupobj.DepencyPickListObj.mode=='edit')
        {
         
            //读取数据库
            BLOCKIDSETTING=popupobj.DepencyPickListObj.BLOCKIDSETTING;
            FIELDIDSETTING=popupobj.DepencyPickListObj.FIELDIDSETTING;
             var urlstring = 'moduleName='+popupobj.DepencyPickListObj.selectmodule+'&sourcefield='+sourcefield+'&targetfield='+targetfield+"&picktext="+encodeURIComponent(parenttext);
             urlstring='index.php?action=PickListAjax&module=PickList&file=getDepencyPickList&'+urlstring+'&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING;
              
             urlstring+="&mode=edit";
             ld('#rptContentLoading').show();
            	  ld.ajax({
                            url: urlstring,
                            type: 'POST',
                            data:'',
                            dataType:'json',
                            async: true,//
                            timeout: 10000,
                                           
                            success: function(data)
                            {
                                if(data.code==1)
                                {
                                    
                                   ld('#rptContentLoading').hide();
            			             popupobj.selectDepencyFields[sourcefield][targetfield][parenttext]=data.result.picklist;
            			              
                                      popupobj.selectparenttext[sourcefield].push(parenttext);
                                      if(ld.inArray(targetfield,popupobj.childnames[sourcefield])<0)
                                            popupobj.childnames[sourcefield].push(targetfield);
                                      if(ld.inArray(sourcefield,popupobj.sourcefieldnames)<0)
                                             popupobj.sourcefieldnames.push(sourcefield)
                                      ld("#"+popupobj.divid+" [name=selectfieldnames]").empty();
                                     for(var i=0;i<data.result.picklist.length;i++)
                                     {
                                        var  text=data.result.picklist[i];
                                        
                                        ld("#"+popupobj.divid+" [name=selectfieldnames]").append("<option value='"+text+"'>"+text+"</option>");
                                     }
                                     
                                }
                                else
                                {
                                    ld("#"+popupobj.divid+" [name=selectfieldnames]").empty();
                                }
                                
                            },
                            error: function (XMLHttpRequest, textStatus, errorThrown) {
                                               popupobj.CancelEvent();
                                }
                });
        }
     }
     
}
/**
设置上级字段选择的值（左右选择)
**/
function setDepencySelectFields()
{
    var popupobj=CrmPopup.getPopupObj("last");
   var parenttext= ld("#"+popupobj.divid+" [name=parentdepecyfieldname]").val();
    var sourcefield=popupobj.sourcefield;
    var targetfield=popupobj.targetfield;
   var selectFieldsobj=document.getElementById("selectfieldnames");
    if(popupobj.selectDepencyFields[sourcefield]==undefined){
        popupobj.selectDepencyFields[sourcefield]=[];//重新初始化
    }else{
        if(popupobj.selectDepencyFields[sourcefield][targetfield]==undefined){
            popupobj.selectDepencyFields[sourcefield][targetfield]=[];//重新初始化
        }
    }
    popupobj.selectDepencyFields[sourcefield][targetfield][parenttext]=[];//重新初始化
    if(popupobj.childnames==undefined)
    {
        popupobj.sourcefieldnames=new Array();
        popupobj.childnames=new Array();
        popupobj.childnames[sourcefield]=new Array();
        popupobj.selectparenttext=new  Array();
        popupobj.selectparenttext[sourcefield]=new Array();
    }
    
   
      
   for (i=0;i<selectFieldsobj.length;i++)
   {
    if(ld.inArray(selectFieldsobj.options[i].value,popupobj.selectDepencyFields[sourcefield][targetfield][parenttext])<0)
  	         popupobj.selectDepencyFields[sourcefield][targetfield][parenttext].push(selectFieldsobj.options[i].value);
            
   }
   if(popupobj.selectDepencyFields[sourcefield][targetfield][parenttext].length>0)
   {
        if(ld.inArray(targetfield,popupobj.childnames[sourcefield])<0)
            popupobj.childnames[sourcefield].push(targetfield);
        if(ld.inArray(parenttext,popupobj.selectparenttext[sourcefield])<0)
            popupobj.selectparenttext[sourcefield].push(parenttext);
        if(ld.inArray(sourcefield,popupobj.sourcefieldnames)<0)
        {
            popupobj.sourcefieldnames.push(sourcefield);
        }
   }
   else
   {
        popupobj.selectparenttext[sourcefield].splice(ld.inArray(parenttext,popupobj.selectparenttext[sourcefield]),1); 
        popupobj.childnames[sourcefield].splice(ld.inArray(targetfield,popupobj.childnames[sourcefield]),1); 
   }
        
   //记住选择级联字段。新增级联，上一步后，然后再点击下一步，
   popupobj.DepencyPickListObj.selectdepencyefieldsobj=popupobj.selectDepencyField;
   popupobj.DepencyPickListObj.childnames=popupobj.childnames;
   popupobj.DepencyPickListObj.selectparenttext=popupobj.selectparenttext;
   popupobj.DepencyPickListObj.sourcefieldnames=popupobj.sourcefieldnames;
   
}


function saveDependency() {
    var module;
    var popupobj=CrmPopup.getPopupObj("last");
    module=popupobj.DepencyPickListObj.selectmodule;
    var blocksetting=popupobj.DepencyPickListObj.BLOCKIDSETTING;
    var fieldsetting=popupobj.DepencyPickListObj.FIELDIDSETTING;
	ld('#rptContentLoading').show();
	
	var dependencyMapping = serializeData();

	if(dependencyMapping == false) {
		ld('#rptContentLoading').hide();
		return false;
	}
	
	var urlstring = 'moduleName='+encodeURIComponent(module)+'&dependencymapping='+encodeURIComponent(dependencyMapping);
	
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: 'action=PickListAjax&module=PickList&file=SaveDepencyPickList&'+urlstring,
			onComplete: function(response) {
				ld('#rptContentLoading').hide();
                var targetfieldname=popupobj.targetfield;
                if(popupobj.module!='Settings')
                {
                    popupobj.CancelEvent();//关闭级联界面
                    popupobj=CrmPopup.getPopupObj("last");
                    if(popupobj.picklistobjarray[targetfieldname].parentdependfieldname!="")
                        //重新给级联字段赋值(函数)
                        popupobj.picklistobjarray[targetfieldname].getpicklistDepencyByParentFieldname();
                }
                else
                {
                    
                    if(popupobj.DepencyPickListObj.mode=='create')
                    {
                        popupobj.CancelEvent();//关闭级联界面
                        popupobj=CrmPopup.getPopupObj("last");
                        popupobj.CancelEvent();//关闭选择级联字段界面
                        //hjz 如果是在页面设置中就刷新列表，在模块中新建级联字段不刷新列表
                        var firstpopobj=CrmPopup.getPopupObj("first");
                        if(firstpopobj.type == 'listpage'){
                            popupobj=CrmPopup.getPopupObj("last");
                            ld("#"+popupobj.divid+" [name=tree_fieldname]").change();
                        }else{
                            changeDependencyPicklistModule(blocksetting,fieldsetting);
                        }
                    }
                    else
                    {
                        popupobj.CancelEvent();//关闭级联界面
                    }
                }
               // changeDependencyPicklistModule(popupobj.DepencyPickListObj.BLOCKIDSETTING,popupobj.DepencyPickListObj.FIELDIDSETTING);
				//$("picklist_datas").update(response.responseText);
			}
		}
		);
}

saveDependency.funname="saveDependency";

function serializeData() {	
    
    var popupobj=CrmPopup.getPopupObj('last');
     var parenttext= ld("#"+popupobj.divid+" [name=parentdepecyfieldname]").val();
	var sourceField =popupobj.sourcefield;
	var targetField = popupobj.targetfield;
    
    var parentoptions=ld("#"+popupobj.divid+" [name=parentdepecyfieldname]").find("option");
   var tmps=[];
  //console.log(parentoptions);
    for(var i=0;i<parentoptions.length;i++)
    {
        var text=parentoptions[i].value;
        if(popupobj.selectDepencyFields[sourceField]==undefined){
            popupobj.selectDepencyFields[sourceField]=[];//重新初始化
        }else{
            if(popupobj.selectDepencyFields[sourceField][targetField]==undefined){
                popupobj.selectDepencyFields[sourceField][targetField]=[];//重新初始化
            }
        }
        if(popupobj.selectDepencyFields[sourceField][targetField][text]!=undefined)
        {
           
            
            tmps[i]={
                'sourcevalue':text,
                'targetvalue':popupobj.selectDepencyFields[sourceField][targetField][text]
            };
           // console.log(tmps);
            
        }
    }
    
    var formData = {
		"sourcefield": sourceField,
		"targetfield": targetField,
		"valuemapping": tmps
	};
	return JSON.stringify(formData);
    
	var maxMappingCount = modifiedMappingValues.length;
	var valueMapping = [];

	for(var i=0; i<maxMappingCount; ++i) {		
		var sourceValueId = modifiedMappingValues[i];
		var sourceValue = document.getElementById(sourceValueId).value;
		var mappingIndex = sourceValueId.replace(sourceField,'');
		var node = $('valueMapping'+mappingIndex);
		if (node != null && typeof(node) != 'undefined') {
			var targetValueNodes = document.getElementsByName('valueMapping'+mappingIndex);
			var targetValues = [];
			for (var j=0;j<targetValueNodes.length;++j) {
				var targetValueNode = targetValueNodes[j];
				if(targetValueNode != null && targetValueNode.parentNode != null
					&& jQuery(targetValueNode).parent().hasClass('selectedCell')) {
					targetValues.push(targetValueNode.value);
				}
			}

			if(targetValues.length == 0) {
				var confirm_str = arrJsPopLabel['NEEDSELECTLEASTONEVALUE'] + " " + sourceValue;
				RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
				return false;
			}

			valueMapping[i] = {
				"sourcevalue":sourceValue,
				"targetvalues":targetValues
			};
		}
	}
	
	var formData = {
		"sourcefield": sourceField,
		"targetfield": targetField,
		"valuemapping": valueMapping
	};
	return JSON.stringify(formData);
}
/*
删除级联
*/
function deleteDependencyPicklist(module, sourceField, targetField, msg,BLOCKIDSETTING,FIELDIDSETTING) {
	RemindsMsg("","LdPopWidth400px",module,"yes","yes",msg);
	//确定按钮
	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){		
		ld('#rptContentLoading').show();
	    var oModulePick = $('pickmodule');
        var pickmodule=oModulePick.options[oModulePick.selectedIndex].value;
		var urlstring = 'moduleName='+encodeURIComponent(module)+'&sourcefield='+sourceField+'&targetfield='+targetField+'&pickmodule='+pickmodule;
		new Ajax.Request(
			'index.php',
			{
				queue: {
					position: 'end',
					scope: 'command'
				},
				method: 'post',
				postBody: 'action=PickListAjax&module=PickList&directmode=ajax&file=PickListDependencySetup&submode=deletedependency&'+urlstring+'&blockidsetting='+BLOCKIDSETTING+'&fieldidsetting='+FIELDIDSETTING,
				onComplete: function(response) {
					ld('#rptContentLoading').hide();
					$("picklist_datas").update(response.responseText);
				}
			}
		);
	});
	return false;
}
function selectSourceValue(sourceValueIndex) {
	if(sourceValueIndex < 0) return;
	if($('sourceValue'+sourceValueIndex) == null) return;
	$('sourceValue'+sourceValueIndex).checked = true;
}

function selectTargetValue(sourceIndex, targetValue) {
	var targetElements = jQuery("input[name='valueMapping"+sourceIndex+"']");

	targetElements.each(function(){
		if(jQuery(this).val() == targetValue) {
			selectCell(jQuery(this).parent());
		}
	});
}

function unselectTargetValue(sourceIndex, targetValue) {
	
	var targetElements = jQuery(document.getElementsByName("valueMapping"+sourceIndex));
	
	targetElements.each(function(){
		if(jQuery(this).val() == targetValue) {
			unselectCell(jQuery(this).parent());
		}
	});
}

function selectCell(element) {
	if(element != null) {
		jQuery(element).removeClass('unselectedCell');
		jQuery(element).addClass('selectedCell');
	}
}

function unselectCell(element) {
	if(element != null) {
		jQuery(element).removeClass('selectedCell');
		jQuery(element).addClass('unselectedCell');
	}
}

function loadMappingForSelectedValues() {
	var sourceElements = jQuery('input[name="selectedSourceValues"]:checked');
	
	var classElements = jQuery(".picklistValueMapping");
	classElements.hide();

	sourceElements.each(function(){
		var selectedElementId = (((jQuery(this).val()).replace(/(\W)/gi,"\\$1")).replace(/\\\s/gi,'.'));
		var selectedElementCells = jQuery("."+selectedElementId);
		selectedElementCells.show();
	});

}

function handleCellClick(event, element) {
	
	if(element.tagName == 'TD') {
		if(jQuery(element).hasClass('selectedCell')) {
			unselectCell(element);
		} else {
			selectCell(element);
		}
		var selectedSourceId = (jQuery(element).attr('id')).slice(7);
		if(typeof selectedSourceId != 'undefined' && modifiedMappingValues.indexOf(selectedSourceId) == -1) {
			modifiedMappingValues.push(selectedSourceId);
		}
	}
}

var isMouseDown = false;

function handleCellMouseDown(event, element) {
	isMouseDown = true;
	handleCellClick(event, element);
	return false;
}

function handleCellMouseOver(event, element) {
	if(isMouseDown) {
		handleCellClick(event, element);
	}
}

function handleCellMouseUp(event, element) {
	isMouseDown = false;
}