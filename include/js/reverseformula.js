//将来可以和字段公式代码合并，做成公共代码
/**
设置反算公式
**/
function setreverseformula(obj)
{
    
   
    var parentid=ld(obj).attr('parentid');
    var reversefieldid=ld(obj).attr('tag');
    var module=ld(obj).attr('module');
   common_setreverseformulapop(parentid,reversefieldid,module);
}
function common_setreverseformulapop(parentid,reversefieldid,module)
{
     var Popupobj=CrmPopup.load("","","","LdPopWidth450px",module,"","","","");
    Popupobj.prevshow();
    var url ='index.php?module=Settings&action=SettingsAjax&file=AddReverseFormulaPop&frommodule='+module+'&selectsourcetype='+ld("#selectmoduletype").val();
    url+="&reversefieldid="+reversefieldid;
    url+="&reverseparentid="+parentid+"&reversetable=ld_producttoolfield";
    url+="&reversefieldtype="+ld("#reversefieldtype").val();
     ld.ajax({
        url: url,
        
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 20000,
        error: function(XMLHttpRequest, textStatus, errorThrown) {
        },
        success: function(data)
        {
            $("status").style.display="none";
            if(data.code==1)
            {
                Popupobj.setParams(data.result.title,savereverseformula,"","LdPopWidth450px",module,"",data.result.oktext,"",data.result.canceltext);         
                Popupobj.objFields=data.result.objfields;
                Popupobj.reverseparentid=data.result.reverseparentid;
                Popupobj.reversefieldid=data.result.reversefieldid;
                Popupobj.reversetable='ld_producttoolfield';
               
                Popupobj.reversemodule=module;
               
                CrmPopup.setPopupobjHtmlContent_scroll(Popupobj,data.result.content);
            }
            
        }
    });
}
/**
新增反写变量
**/
function addReverseFormulavar(tablename)
{
    var popupobj=CrmPopup.getPopupObj('last');
   
     var tableobj=ld("#"+popupobj.divid+ " [name="+tablename+"]");
    
     var  rows=tableobj.find("tr").length;
    var nameindex=rows;
    
    if(tableobj.find(" tr[deleted=no]").length>10)
    {
        alert('最多只能新增10个变量！');
        return false;
    }
     var formulahtml="<tr name='formual_row_"+nameindex+"' deleted='no'>";
     var name="formualcombox_"+nameindex;
      formulahtml+='<td>'+addrevernameFormulaCombox(name)+"</td>" ;
     name="formualtext_"+nameindex;
     var lettervar=letters[tableobj.find(" tr[deleted=no]").length];
     
    formulahtml+='<td><input type="text" name="'+name+'" value="'+lettervar+'"></td>';
   formulahtml+="</tr>";
   tableobj.append(formulahtml);
   
     
     
}
function addrevernameFormulaCombox(name)
{
    var popupobj=CrmPopup.getPopupObj('last');
    var combox="<select  name='"+name+"'>";
    for(var i=0;i<popupobj.objFields.length;i++)
    {
        combox+=" <option value='"+popupobj.objFields[i].columnname+"'>"+popupobj.objFields[i].fieldlabel+"</option> ";
    }
    combox+='</select>';
    
    return combox;
}
/**
新增反算字段
**/
function addreversefield(obj)
{
    var parentid=ld(obj).attr('parentid');
    
    var module=ld(obj).attr('module');
    var Popupobj=CrmPopup.load("","","","LdPopWidth350px",module,"","","","");
    Popupobj.prevshow();
    var url ='index.php?module=Settings&action=SettingsAjax&file=AddReverseFieldPop&frommodule='+module+'&selectsourcetype='+ld("#selectmoduletype").val();
   
    url+="&reverseparentid="+parentid+"&reversetable=ld_producttoolfield";
    url+="&reversefieldtype="+ld("#reversefieldtype").val();
     ld.ajax({
        url: url,
        
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 20000,
        error: function(XMLHttpRequest, textStatus, errorThrown) {
        },
        success: function(data)
        {
            $("status").style.display="none";
            if(data.code==1)
            {
                Popupobj.setParams(data.result.title,"","","LdPopWidth350px",module,"",data.result.oktext,"",data.result.canceltext);         
                
                Popupobj.reverseparentid=parentid;
               
                Popupobj.reversetable='ld_producttoolfield';
                Popupobj.reversemodule=module;
                Popupobj.show(data.result.content);
                ld("#"+Popupobj.divid+"_btnok").unbind("click").bind("click",function(){
                    var reversefieldid=ld("#"+Popupobj.divid+" [name=reversefield]").val();
                   // Popupobj.CancelEvent();
                    common_setreverseformulapop(parentid,reversefieldid,module)
                })
                //CrmPopup.setPopupobjHtmlContent_scroll(Popupobj,data.result.content);
            }
            
        }
    });
}
/**
保存反写公式
**/
function savereverseformula()
{
    var popupobj=CrmPopup.getPopupObj('last');
   
    var reverseparentid=popupobj.reverseparentid;
    var reversetable=popupobj.reversetable;
   
    var reversemodule=popupobj.reversemodule;
    var reversefieldid=popupobj.reversefieldid;
    
    var url ='index.php?module=Settings&action=SettingsAjax&file=savereverseformula&frommodule='+reversemodule;
    url+="&reversefieldid="+reversefieldid;
    url+="&reverseparentid="+reverseparentid+"&reversetable="+reversetable;
    url+="&reversefieldtype="+ld("#reversefieldtype").val();
    var columnstrings=[];
    var savecolumnstrings=[];
     var formulacontent=ld("#"+popupobj.divid+" [name=definitionformula]").val();
    
    var tableobj=ld("#"+popupobj.divid+" [name=reversetoolfieldFormula]");
    var trlength=tableobj.find("tr").length;
    //循环字段公式
    ld.each(tableobj.find("tr"),function(index,trobj){
        var lettervar=ld("#"+popupobj.divid+" [name=formualtext_"+index+"]").val();
        var columnname=ld("#"+popupobj.divid+" [name=formualcombox_"+index+"]").val();
        var deleted=ld(trobj).attr('deleted');
       
        if(deleted=='no'&&columnname!=''&&columnname!='none'&&ld.trim(lettervar)!='')
        {
            columnstrings[lettervar]=columnname;
            var tmps={'lettervar':lettervar,'column':columnname};
              savecolumnstrings.push(tmps);
        }
        
        
    })
    if(ld.trim(formulacontent)=='')
    {
        audioRemindsMsg("","","","","","定义公式不能为空!");
        ld("#"+popupobj.divid+" [name=definitionformula]").focus();
        return false;
    }
   
   //edit:can 20210201 44527: （https://61mis.com/kfbcrm [^]）（上海立凯电控科技有限公司）系统设置-单据分录定制-合同订单-价税合计，设置反算规则公式的时候点击保存没有反应
   var msg=formualValidata(formulacontent,columnstrings);
    if(msg!=''){
        audioRemindsMsg("","","","","",msg);
        return false;
    }
    
    url+="&formulastring="+encodeURIComponent(formulacontent);
    url+="&columnstring="+JSON.stringify(savecolumnstrings);
  
      
     ld.ajax({
        url: url,
        
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 20000,
        error: function(XMLHttpRequest, textStatus, errorThrown) {
        },
        success: function(data)
        {
            $("status").style.display="none";
            if(data.code==1)
            {
                  var popupobj=CrmPopup.getPopupObj('last');
                 var reverseparentid=popupobj.reverseparentid;
                 var reversetable=popupobj.reversetable;
                 var reversemodule=popupobj.reversemodule;
                 var reversefieldid=popupobj.reversefieldid;
                getReverseFormulaList(reverseparentid,reversetable,reversemodule);
                 popupobj.CancelEvent();
            }
            
        }
    });
    
}
savereverseformula.funname='savereverseformula';
/**
删除反算公式
**/
function deletereverseformula(obj)
{
    var reverseparentid=ld(obj).attr('parentid');
    var reversefieldid=ld(obj).attr('tag');
    var reversemodule=ld(obj).attr('module');
    var reversetable='ld_producttoolfield';
     var url ='index.php?module=Settings&action=SettingsAjax&file=Deletereverseformula&frommodule='+reversemodule;
   url+="&reversefieldid="+reversefieldid;
    url+="&reverseparentid="+reverseparentid+"&reversetable="+reversetable;
    url+="&reversefieldtype="+ld("#reversefieldtype").val();
  
    ld.ajax({
        url: url,
        
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 20000,
        error: function(XMLHttpRequest, textStatus, errorThrown) {
        },
        success: function(data)
        {
            $("status").style.display="none";
            if(data.code==1)
            {
                
               getReverseFormulaList(reverseparentid,reversetable,reversemodule);
                
            }
            
        }
    });
}
function getReverseFormulaList(reverseparentid,reversetable,reversemodule)
{
  
    var url ='index.php?module=Settings&action=SettingsAjax&file=getReverseFormulaList&frommodule='+reversemodule;
    url+="&reverseparentid="+reverseparentid+"&reversetable="+reversetable;
    url+="&reversefieldtype="+ld("#reversefieldtype").val();
    url+="&getlistajax=yes";
    
    ld.ajax({
        url: url,
        
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 20000,
        error: function(XMLHttpRequest, textStatus, errorThrown) {
        },
        success: function(data)
        {
            $("status").style.display="none";
            if(data.code==1)
            {
                ld("#reverseformulalist").html(data.result.content);
               
                
            }
            
        }
    });
}
/**
反算内容修改
**/
function changereverfieldtype(obj)
{
    var tabid=ld("#selectmodule").val();//选择模块（列表界面）
    var popupobj=CrmPopup.getPopupObj('last');
    var reverseparentid=popupobj.producttoolfieldid;
    
    
    var url ='index.php?module=Settings&action=SettingsAjax&file=ChangeReverseFieldType&reversetabid='+tabid;

    url+="&reverseparentid="+reverseparentid+"&reversetable=ld_producttoolfield";
    url+="&reversefieldtype="+ld("#reversefieldtype").val();
    
    
    ld.ajax({
        url: url,
        
        type: 'POST',
        data:'',
        dataType:'json',
        async: true,//
        timeout: 20000,
        error: function(XMLHttpRequest, textStatus, errorThrown) {
        },
        success: function(data)
        {
            $("status").style.display="none";
            if(data.code==1)
            {
                var popupobj=CrmPopup.getPopupObj('last');
                var reversemodule=ld("#"+popupobj.divid+" [name=frommodule]").val();
               getReverseFormulaList(reverseparentid,'ld_producttoolfield',reversemodule);
                
            }
            
        }
    });
}