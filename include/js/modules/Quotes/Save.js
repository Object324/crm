var popupobj=CrmPopup.getPopupObj('last');
popupobj.after_validate=function()
{
  

    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;

    var record =CrmPopup.getHtmlobjval(divid,'record');
	var version_account =  '';
   
	if(CrmPopup.getHtmlobjval(divid,'version_account') != undefined){
		version_account = ld("#"+divid+" [name=version_account]").val();
	}
    var ret=true;
   
    if(account_version=='yiwen')
    {
         var rowobjs=popupobj.getTrObjsByDelType("no");
        var msgerror='';
    
        ld.each(rowobjs,function(){
			var sf19022obj=ld(this).find(" [name=sf19022]");//报价计量单位
			
            var cf_4943obj=ld(this).find("[name=span_cf_4943]");
            var rowindex=ld(this).attr("rowindex");
           
            if(ld(cf_4943obj).length>0)
            {
                //采购计量单位
                var value=ld(cf_4943obj).html();
				if(ld.trim(sf19022obj.val())==value)
				{
					return true;
				}
                var num=value.replace(/[^0-9]/ig,"");
              
                if(num=="undefined"||num==undefined||num==''||num==0)
                {
                    
                }
                else
                {
                   
                    var quantity=ld(this).find("[detailcolumnname=quantity]").val();
                   if(quantity%num!=0)
                    {
                        msgerror+="第"+rowindex+"行数量不是'"+num+"'的整数倍\n";
                        
                    }
                }
            }
        })
        if(msgerror!='')
        {
            alert(msgerror);
        }
        
    }
    
    
    if(account_version=='haige')
    {
        
        
        /*报价单（新建和复制）保存的特殊判断，
        报价单类型是“特价报价单”保存的时候需要判断状态必须依次有：准备投标、投标中、最终优化清单（根据特价申请单编号）
        */
        var quotetype=CrmPopup.getHtmlobjval(divid,'quotetype');//报价单类型
        var potentialid=CrmPopup.getHtmlobjval(divid,'potential_id');//特价申请单编号
        if(potentialid<=0||quotetype!='特价报价单')
        {
          //  haigetip();
            
            return ret;
        }
        var quotestage=CrmPopup.getHtmlobjval(divid,'quotestage');
        var dataurl="quotestage="+encodeURIComponent(quotestage)+"&module=Quotes&file=HaigeQuoteStage&action=QuotesAjax";
        dataurl+='&potentialid='+potentialid;//特价申请单编号
        if(record>0)
        {
            dataurl+="&record="+record;
            
        }
        ldAjaxNoProgresssync('index.php?',dataurl,function (ajaxdata){
            if (ajaxdata.code==1 ) {

                ret=true;
            } else {

                audioRemindsMsg("","",popupobj.module,"","",ajaxdata.msg);
                ret=false;
            }
        });
        
    }
//	haigetip();
  
   return ret;
}
function haigetip()
{
    var popupobj=CrmPopup.getPopupObj("last");
    var divid=popupobj.divid;
    var duplicateid=ld("#" + popupobj.divid + " [name=duplicateid]").val();
    var record =CrmPopup.getHtmlobjval(divid,'record');
     var potentialid=CrmPopup.getHtmlobjval(divid,'potential_id');//特价申请单编号
     var quotetype=CrmPopup.getHtmlobjval(divid,'quotetype');//报价单类型
     if(quotetype=='特价报价单'||quotetype=='备案报价单')
     {
        var rowcnt=ld("#"+popupobj.divid+" [name=rowcnt]").val();
      
      
        var produdctids=[];
        if(quotetype=='特价报价单')
       {
             for(var i=1;i<=rowcnt;i++)
            {
               // if(ld("#"+popupobj.divid+" [name=hidden_rowid_"+i+"]").val()==0)
               // {
                  
                  produdctids.push(ld("#"+popupobj.divid+" [name=hdnProductId"+i+"]").val());
                //}
            }
        }
            var dataurl = "action=QuotesAjax&file=HaigeSaveTip&module=Quotes&duplicateid="+duplicateid+"&record="+record;
            dataurl+='&quotetype='+encodeURIComponent(quotetype)+"&total="+ld(popupobj.divid+' [name=total]').val()+"&potentialid="+potentialid;
            dataurl+='&productids='+produdctids.join(',');
            ldAjaxNoProgresssync('index.php?',dataurl,function (ajaxdata){
                if (ajaxdata.code==1 ) {
                    audioRemindsMsg("","",popupobj.module,"","",ajaxdata.msg);

                }
            });
     }
    
        
       
}