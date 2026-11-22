function LessionDeleteRow(iCount)
{
    document.getElementById("row"+iCount).style.display = "none";
    document.getElementById('deleterow'+iCount).value = 1;
    document.getElementById("deleterow"+iCount).setAttribute('deleted','yes');
}
function saveLessionPlan(obj)
{
   
    //var rowCount = document.getElementById('rowcount').value;
    var info = document.getElementById('listjsinfo').value;//列头

    var sub_cnt = info.split("|");
    var popupobj=CrmPopup.getPopupObj('last');
    var trobjs=ld("#"+popupobj.divid+" tr[deleted=no]");
   
    var objs=[];
    ld.each(trobjs,function(){
            var tmps={};
            var rowindex=ld(this).attr('rowindex');
            
            for(var j = 0; j<sub_cnt.length; j++)
            {
                var fieldinfo = sub_cnt[j].split(',');
                var columnname=fieldinfo[0];
                tmps[columnname]=ld("#"+popupobj.divid+" [name="+columnname+rowindex+"]").val();
                if(fieldinfo[2] == 'M')
                {
                    if(fieldinfo[0] == 'lessiondate')
                    {
                        fieldinfo[0] = 'jscal_field_date_start';
                    }
                    if(ld("#"+popupobj.divid+" [name="+columnname+rowindex+"]").val()== '')
                    {
                        alert(fieldinfo[3]+arrJsPopLabel['CANOTEMPTY']);
                        document.getElementById(fieldinfo[0]+i).focus();
                        return false;
                    }
                }
            }
            objs.push(tmps);
        
    })
    var url="index.php?module=LessionPlan&action=LessionPlanAjax&file=Save&lessionplaninfo="+JSON.stringify(objs);
    if(popupobj.type==PageRecordPopup.type){
        url+="&recordid="+popupobj.record+"&record="+popupobj.record;
    }
    ldAjax(url,{},function(data){
                    popupobj.CancelEvent();
                       var tmparra=new Array();
                        
                       var tmpobj= new AfterUpdatePrevPopupObjContent(popupobj.module,data,tmparra);
                       tmpobj.eachrefreshlistbyModules(data.result.refreshlistmodules);
                     
                       tmpobj.eachrefreshDetailViewByModules(data.result.refreshdetailmodules);
                       DelProgressObjs();
                       delete tmpobj;
    })
    return false;
}
function LessionAddRow()
{
    if(document.getElementById('listjsinfo') != undefined)
    {
        var info = document.getElementById('listjsinfo').value;
        var sub_cnt = info.split("|");
        var tableobj=document.getElementById("tab_1");
        var rowobj=tableobj.insertRow(tableobj.rows.length);
        var rowCount = document.getElementById('rowcount').value;
       
        rowCount++;
        rowobj.id = "row"+rowCount;
        rowobj.name = "row"+rowCount;
        rowobj.setAttribute('deleted','no');
        rowobj.setAttribute('rowindex',rowCount);
        rowobj.style.verticalAlign = "top";
        var deletetd = rowobj.insertCell(rowobj.cells.length);
        deletetd.innerHTML = "<a class='icon-homeimg icon-sdel' href='javascript:;' title='"+arrJsPopLabel['DELETE']+"' onclick='LessionDeleteRow("+rowCount+");' ></a><input type='hidden' value='0' name='deleterow"+rowCount+"' id='deleterow"+rowCount+"' />";
        //deletetd.align = 'center';
        for(var i = 0; i<sub_cnt.length; i++)
        {
            var fieldinfo = sub_cnt[i].split(',');
            var fieldname = fieldinfo[0];
            fieldinfo[0]=rowobj.insertCell(rowobj.cells.length);
            //fieldinfo[0].align = 'center';
            if(fieldinfo[1] == 15 && fieldname == 'projectid')
            {
                fieldinfo[0].innerHTML="<select name='projectid"+rowCount+"' id='projectid"+rowCount+"' style='width: 100%;height:25px;line-height:25px;'>"+getLessionPlanInfo('projectid','')+"</select>";
            }
            else if(fieldinfo[1] == 15 && fieldname == 'servicecontractsid')
            {
                fieldinfo[0].innerHTML="<select name='servicecontractsid"+rowCount+"' id='servicecontractsid"+rowCount+"' style='width: 100%;height:25px;line-height:25px;'>"+getLessionPlanInfo('servicecontractsid','')+"</select>";
            }
            else if(fieldinfo[1] == 15 && fieldname == 'projectmilestoneid')
            {
                fieldinfo[0].innerHTML="<select name='projectmilestoneid"+rowCount+"' id='projectmilestoneid"+rowCount+"' style='width: 100%;height:25px;line-height:25px;'>"+getLessionPlanInfo('projectmilestoneid','')+"</select>";
            }
            else if(fieldinfo[1] == 15 && fieldname == 'projecttaskid')
            {
                fieldinfo[0].innerHTML="<select name='projecttaskid"+rowCount+"' id='projecttaskid"+rowCount+"' style='width: 100%;height:25px;line-height:25px;'>"+getLessionPlanInfo('projecttaskid','')+"</select>";
            }
            else if(fieldinfo[1] == 1)
            {
                fieldinfo[0].innerHTML='<input type="text" id="'+fieldname+''+rowCount+'" name="'+fieldname+''+rowCount+'" value = "" size="12" />';
            }
            else if(fieldinfo[1] == 2)
            {
                fieldinfo[0].innerHTML='<input name="lessiondate'+rowCount+'" id="jscal_field_date_start'+rowCount+'" style="min-width:90px;width:100%;height:25px;line-height:25px;" size="15" maxlength="10" value="" onClick="WdatePicker()" class="Wdate">';
                fieldinfo[0].innerHTML.evalScripts();
            }
            else if(fieldinfo[1] == 19)
            {
                fieldinfo[0].width = '20%';
                fieldinfo[0].innerHTML='<textarea style="width:100%;height: 25px;line-height: 20px;margin-top:5px;margin-bottom:-8px;" name="'+fieldname+''+rowCount+'" id="'+fieldname+''+rowCount+'" ></textarea>';
            }
            else
            {
                fieldinfo[0].innerHTML='<input id="'+fieldname+''+rowCount+'" name="'+fieldname+''+rowCount+'" value = "" />';
            }
        }
        document.getElementById('rowcount').value = rowCount;
    }
}
function getLessionPlanInfo(fieldlabel,id){
        var popupobj=CrmPopup.getPopupObj('last');
        if(popupobj.lessionplaninfo==undefined){
            popupobj.lessionplaninfo={};
        }
        if(popupobj.lessionplaninfo[fieldlabel]!=undefined)
        {
            return popupobj.lessionplaninfo[fieldlabel];
        }
        var content='';
    ldAjaxNoProgresssync("index.php?module=LessionPlan&action=LessionPlanAjax&file=getSelectContent&fieldlabel="+fieldlabel+"&id="+id,{},function(data){
        popupobj.lessionplaninfo[fieldlabel]=data.result.content;
       
        content= popupobj.lessionplaninfo[fieldlabel];
    })
    
    return content;
    
}