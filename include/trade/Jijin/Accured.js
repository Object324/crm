
function Fund_Accured(module,obj)
{
    this.module=module;
    this.obj=obj;
}
Fund_Accured.getInstance=function(module,obj)
{
    if(Fund_Accured.cur_obj==null)
    {
        
        Fund_Accured.cur_obj=new Fund_Accured(module,obj);
        
        
    }
    
    return Fund_Accured.cur_obj;
}
Fund_Accured.prototype.chooseProducts=function(){
    
    var crmPopupobj=CrmPopup.load("","","","",this.module,"",'none',"","");
	crmPopupobj.prevshow();
    crmPopupobj.type=selectSearchPopup.type;
    ldAjax("index.php?module=Products&action=Popup&popup=yes&html=Popup_picker&form=HelpDeskEditView&jsfile=Accured&frommodule="+this.module+"&jspath=include/trade/Jijin&popuptype=specific&fromlink=&page_popup=yes&fieldname=fund_product_id",{},function(ajaxdata){
        CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,ajaxdata.result.content);
       
    });
    
}
Fund_Accured.prototype.save=function()
{
    
    var  popupobj=CrmPopup.getPopupObj('last');
    
    if(document.getElementById("fund_product_id").value==''||document.getElementById("fund_product_id").value==0)
    {
        alert ("基金名称不能为空!");
        return false;
    }
    var productid=document.getElementById("fund_product_id").value;//产品ID
    var data={};
    data['productid']=productid;
    if(this.module=='Management'||this.module=='Mcommission')
    {
        if(document.getElementById("jscal_field_startdate").value=='')
        {
            alert("开始日期不能为空!");
            return false;
        }
        if(document.getElementById('jscal_field_enddate').value=='')
        {
             alert("结束日期不能为空!");
            return false;
        }

        if(document.getElementById("jscal_field_startdate").value>=document.getElementById('jscal_field_enddate').value)
        {
            alert("结束日期要大于开始日期!");
            return false;
        }
        data['prev_accured_date']=document.getElementById("prev_accured_date_hidden").value;
        data['startdate']=document.getElementById("jscal_field_startdate").value;
        data['enddate']=document.getElementById("jscal_field_enddate").value;
    }
    else if(this.module=='FundReward'||this.module=='FundRewardCommission')
    {
        
            if(ld('.span_fund_success_accured').css('display')=="none")
            {
                if(ld("#readonly_fund_accured_date").val()=='')
                {
                    alert('最早净值日期不能为空!');
                    return false;
                } 
            }
            else 
            {
                if(ld("#readonly_fund_accured_date").val()=='')
                {
                    alert('上次计提日期不能空!');
                    return false;
                } 
            }
            if(ld('#jscal_field_accured_base_date').val()=='')
            {
                alert('计提基准日期不能为空！');
                return false;
            }
          
            
           data['basedate']=ld('#jscal_field_accured_base_date').val();
           data['prev_basedate']=ld('#readonly_fund_accured_date').val();
           data['prev_nav']=ld('#readonly_fund_accured_nav').val();
          
           if(ld("#chk_fund_tmp_open_accured").attr("checked"))
           {
                data['chk_tmp_open']='yes';
           }
           else
           {
                data['chk_tmp_open']='no';
           }
           
          
    }
    
    data['reason']=document.getElementById("fund_accured_reason").value;
    data['module']=this.module;
    data['action']=this.module+"Ajax";//
    data['file']='Accured_Operator';
    data['operattype']='save';
    ld.ajax
        (
            {
                type:'POST',
                url:"index.php",
                data:data,
                success:function(data)
                {
                    if(data.indexOf("##error$##$")>=0)
                    {
                        var results=data.split("##error$##$");
                        alert(results[1]);
                    }
                    else
                    {
                       popupobj.CancelEvent();
                    }
                }
            }
        
        
        );
}
Fund_Accured.prototype.Pop=function()
{
    
    var url = 'module='+this.module+'&action='+this.module+'Ajax&file=Accured_Operator&operattype=pop';	
    var cur_this=this;
    var crmPopupobj=CrmPopup.load("","","","450",this.module,"",'none',"","");
	crmPopupobj.prevshow();
    ldAjax("index.php?"+url,{},function(ajaxdata){
        crmPopupobj.setParams(ajaxdata.result.title,cur_this.save,"","450",this.module,"",ajaxdata.result.oktext,"",ajaxdata.result.canceltext);
        CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,ajaxdata.result.content);
      ld("#"+crmPopupobj.divid+" [name=fund_product_id]").unbind("change",Fund_Accured.getInstance().setPrev_Accured_date);
      ld("#"+crmPopupobj.divid+" [name=fund_product_id]").bind("change",Fund_Accured.getInstance().setPrev_Accured_date);
      
       /* ld("#"+crmPopupobj.divid+" [name=fund_product_id]").unbind("change").bind("change",function(){
          
            Fund_Accured.getInstance().setPrev_Accured_date(ld(this).val());
        })*/
    })

    	
}
Fund_Accured.prototype.close_pop=function()
{
    fninvshnew('div_fund_accured_pop');//关闭弹出层
}
Fund_Accured.prototype.setPrev_Accured_date=function(productid)
{
    productid=ld(this).val();
    var that=Fund_Accured.getInstance();
   
        var url = 'module='+that.module+'&action='+that.module+'Ajax&file=Accured_Operator&operattype=prev_accured_date&productid='+productid;	
    //获取上次计提日期
    var cur_this=that;
   	new Ajax.Request(
		'index.php',
		{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody:url,
                async:false,
				onComplete: function(response) {
				   
				    var result=response.responseText;
                   if(cur_this.module=='Management'||cur_this.module=='Mcommission')
                   {
                     document.getElementById("prev_accured_date_hidden").value=result;
                     document.getElementById("prev_accured_date").value=result;
                   }
                   else if(cur_this.module=='FundReward'||cur_this.module=='FundRewardCommission')
                   {
                        var restobj = eval('('+ result +')')?eval('('+ result +')'):JSON.parse(result);
                        
                        if(restobj.code>0)
                        {
                            if(restobj.first_accured=='yes')
                            {
                                ld(".span_fund_success_accured").css("display","none");
                                ld(".span_earlist_fund_accured").css("display","");
                            }
                            else
                            {
                                ld(".span_fund_success_accured").css("display","");
                                ld(".span_earlist_fund_accured").css("display","none");
                            }
                            if(restobj.isopenshow=='yes')
                            {
                                ld("#fund_tr_tmp_open").css("display","");
                            }
                            else
                            {
                                 ld("#fund_tr_tmp_open").css("display","none");
                            }
                            ld("#readonly_fund_accured_date").val(restobj.accured_date);
                            ld("#readonly_fund_accured_nav").val(restobj.nav);
                        }
                        else
                        {
                            ld("#readonly_fund_accured_date").val("");
                            ld("#readonly_fund_accured_nav").val("");
                            ld("#fund_tr_tmp_open").css("display","none");
                        }
                   }
                  
				}
		}
	);	
  
}

function set_return_specific(productid,product_name)
{
    
    window.opener.document.getElementById("fund_product_id").value=productid;
    window.opener.document.getElementById("fund_product_id_name").value=product_name;
    window.opener.Fund_Accured.getInstance().setPrev_Accured_date(productid);

  
    return false;
    
}
