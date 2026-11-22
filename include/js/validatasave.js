function validatasave(validatas,type)
{
    
   
    //type:php,js
    //php:后台判断
    //js:前台判断
    //目前只做前端
    this.comparators={"m":"<=",'e':"=",'l':"<","g":">",'h':">=",'notempty':"<>''"}
    this.validatas=validatas;
	this.validatasave_status = 'aaa';
   
    //编辑，新增界面，查看 (js)
    this.mainjsvalidata=function()
    {
        var popupobj=CrmPopup.getPopupObj("last");
      
        
        if(popupobj.validatasave==null || popupobj.validatasave==undefined)
        {
            return true;
        }
        if(popupobj.validatasave['maincols']==null || popupobj.validatasave['maincols']==undefined)
        {
            return true;
        }
        
        for(var i=0;i<popupobj.fields.length;i++)
        {
          
            if(!CrmPopup.isExistsObj(popupobj.divid,popupobj.fields[i].fieldname))
            {
                continue;
            }
            if(popupobj.validatasave['maincols'][popupobj.fields[i].fieldname]==undefined)
            {
                continue;
            }
            if(!this.maincommonvalidata(popupobj.fields[i].fieldname,popupobj.fields[i].uitype,popupobj.fields[i].fieldlabel,popupobj.fields[i]))
            {
                return false;
            }
        }
        return true;
    }
	this.mainphpvalidata=function(){
		if(this.validatas==null || this.validatas==undefined)
        {
            return true;
        }
		var popupobj=CrmPopup.getPopupObj("last");
		var record = popupobj.record;
		var module = popupobj.module;
		var surl = "index.php?record="+record+"&module="+module+"&file=validatasave&action="+module+"Ajax"
		ld.each(this.validatas,function(index,columnname){
			if(CrmPopup.findHtmlobj(popupobj.divid,columnname).val() != undefined){
				surl += '&'+columnname+'='+encodeURIComponent(CrmPopup.findHtmlobj(popupobj.divid,columnname).val());
			}
		});
		//alert(surl);
        /*
		http_reqfield=createfieldXMLHTTP();
		http_reqfield.open("POST",surl,false);
		http_reqfield.onreadystatechange=this.maincommonvalidata_result;
		http_reqfield.setRequestHeader("If-Modified-Since","0");
		http_reqfield.send(null);
		*/
        ldAjaxNoProgresssync(surl,'',function (data){
            if(data.code == -1){
                if(data.result.rule_result == 'NoSave'){
                    audioRemindsMsg("","LdPopWidth400px","","yes","",data.result.tips);
                    isDuplicate = false;
                }else if(data.result.rule_result == 'ConfirmSave'){
                    if(confirm(data.result.tips)){
                        isDuplicate = true;
                    }else{
                        isDuplicate = false;
                    }
                }else{
                    isDuplicate = true;
                }
            }else{
                isDuplicate = true;
            }
        });
		if(isDuplicate == true){

			return true;
		}
		return false;
	}
	this.maincommonvalidata_result = function(){
		if(http_reqfield.readyState ==4)
		{
			if(empty(http_reqfield.responseText)){
				isDuplicate = true;
			}else{
				var restobj = eval('('+ http_reqfield.responseText +')')?eval('('+ http_reqfield.responseText +')'):JSON.parse(http_reqfield.responseText);
				if(restobj.result.rule_result == 'NoSave'){
					audioRemindsMsg("","LdPopWidth400px","","yes","",restobj.result.tips);
					isDuplicate = false;
				}else if(restobj.result.rule_result == 'ConfirmSave'){
					if(confirm(restobj.result.tips)){
						isDuplicate = true;
					}else{
						isDuplicate = false;
					}
				}else{
					isDuplicate = true;
				}
			}
		}
	}
    this.maincommonvalidata=function(fieldname,uitype,fieldlabel,fieldinfo){
        
        var popupobj=CrmPopup.getPopupObj("last");
       
        if(ld("#"+popupobj.divid+" [name="+fieldname+"]").length<=0)
        {
            return true;
        }
       
        if(popupobj.type=='masseditpopup')
        {
            //批量编辑
            //edit:can 2020-11-16 43279: （61mis.com/kfbcrm）OA表单-佣金单-详情(需要补丁)；打开佣金单详情编辑报销日期，保存会提示“报销日期不能大于当前日期”；但操作批量编辑可以选择之后的日期并保存编辑成功
            if(!ld("#"+popupobj.divid+' [name='+fieldname+'_mass_edit_check]').prop("checked"))
            {
                return true;
            }
        }
        var curvalue=ld("#"+popupobj.divid+" [name="+fieldname+"]").val();
        if(fieldinfo != undefined && fieldinfo.havesensitivevalue != undefined && fieldinfo.havesensitivevalue == 'yes'){
            curvalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(fieldinfo.sensitiveencryptvalue,true,fieldinfo);
        }
       // console.log(popupobj.detailfields);
        for(var j=0;j<popupobj.validatasave['maincols'][fieldname].length;j++)
        {
           
            var tmpvalidata=popupobj.validatasave['maincols'][fieldname];
            var comparator=popupobj.validatasave['maincols'][fieldname][j].comparator;
            
            if(tmpvalidata[j].relateformulavalue!=""&&tmpvalidata[j].relateformulavalue!=undefined)
            {
                if(tmpvalidata[j].relateformulavalue.indexOf('_months_months')>=0)
                {
                    //相差月份判断
                    var relatefieldname=popupobj.validatasave['maincols'][fieldname][j]['relatefieldname'][0];
                    var months=tmpvalidata[j].relateformulavalue.split("_");
                    var month=parseInt(months[0]);//获取月份的数目要求
                    if(relatefieldname!=""&&relatefieldname!=undefined)
                    {
                        if(!CrmPopup.isExistsObj(popupobj.divid,relatefieldname))
                        {
                            continue;
                        }
                        var relatevalue=ld("#"+popupobj.divid+" [name="+relatefieldname+"]").val();
                        var relatefieldlabel=popupobj.validatasave['maincols']['fieldlabel'][relatefieldname];
                        for(var tmpi=0;tmpi<month;tmpi++)
                        {
                            var datetimeobj=new DateTime(relatevalue);
                            relatevalue=datetimeobj.getNextMonth()
                        }
                        
                          var datetimeobj=new DateTime(relatevalue);
                   
                        if(parseInt(datetimeobj.comparator(curvalue))>0)
                        {
                             audioRemindsMsg("","LdPopWidth400px","","yes","","要求"+fieldlabel+"比"+relatefieldlabel+"晚"+month+"个月");
                             return false;
                        }
                    }
                    
                   
                    continue;
                }
                else if(comparator=='regexp')
                {
                    //正则表达式
                    //var regex="/"+tmpvalidata[j].relateformulavalue+"/";
                    var tmprelateformulavalue=tmpvalidata[j].relateformulavalue;
                    //查看界面的处理
                    tmprelateformulavalue=tmprelateformulavalue.replace(/#####/g,"\\");
                  
                     var r = new RegExp(tmprelateformulavalue);
                    
                    if(ld.trim(curvalue)!=''&&!r.test(curvalue))
                    {
                        ld("#"+popupobj.divid+" [name="+fieldname+"]").focus();
                        audioRemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['PLEASEENTERTHECORRECT']+fieldlabel);
                        return false;
                    }
                        
                }
                else
                {
                       var relatevalue=this.getformuladatefieldvalue(tmpvalidata[j].relateformulavalue);
             
                        var relatefieldlabel=popupobj.validatasave['relateformulavalue'][tmpvalidata[j].relateformulavalue]['fieldlabel'];
                }
            }
        
            else
            {
                var relatevalue="";
                var relatefieldlabel="";         
              
                var relatefieldname=popupobj.validatasave['maincols'][fieldname][j]['relatefieldname'][0];
               
                if(relatefieldname!=""&&relatefieldname!=undefined)
                {
                    var isdetailfield='no';
                    if(relatefieldname.indexOf("detailfield:")>=0)
                    {
                        //edit:can 20210-03-05 044705: 费用报销单 ld_validatasavedetail 表添加规则，不生效
                        var tmp_arr=relatefieldname.split("detailfield:");
                        relatefieldname=tmp_arr[1];
                        isdetailfield='yes';
                    }
                    if(!CrmPopup.isExistsObj(popupobj.divid,relatefieldname))
                    {
                        continue;
                    }
                    var relatevalue=ld("#"+popupobj.divid+" [name="+relatefieldname+"]").val();
                    //zkt 202311162 XUQIU1002041 单据头字段增加敏感规则设置，实现对单个字段的加密与编辑的控制
                    var relatefieldinfo = [];
                    if(popupobj.type==DetailViewPage.type||popupobj.pagetype==CreatePagePopup.pagetype||popupobj.pagetype==ListEditPagePopup.pagetype)
                    {
                        if(popupobj.fieldname_fields != undefined && popupobj.fieldname_fields[relatefieldname]!=undefined){
                            relatefieldinfo = popupobj.fieldname_fields[relatefieldname];
                        }
                    }
                    if(relatefieldinfo != [] && relatefieldinfo.havesensitivevalue != undefined && relatefieldinfo.havesensitivevalue == 'yes'){
                        relatevalue = cls_AESencryptionbykey.Puyoung_Encryptyfieldvaluebyoperation(fieldinfo.sensitiveencryptvalue,true,relatefieldinfo);
                    }
                   
                   if(isdetailfield=='yes')
                    {
                        //edit:can 20210-03-05 044705: 费用报销单 ld_validatasavedetail 表添加规则，不生效
                            ld.each(popupobj.detailfields,function(tmpindex,tmpfieldinfo){
                               
                                if(tmpfieldinfo.columnname==relatefieldname)
                                {
                                    relatefieldlabel=tmpfieldinfo.fieldlabel;
                                    return false;
                                }
                            })
                    }
                    else
                    
                         var relatefieldlabel=popupobj.validatasave['maincols']['fieldlabel'][relatefieldname];
                }
            }
                       
            
            
            
            if(uitype==5||uitype==86)
            {
                if(!this.jsdatevalidate(comparator,curvalue,relatevalue,fieldlabel,relatefieldlabel,0))
                {
                    return false;
                }
            }
            else if(uitype==71 || uitype==72||uitype==7||uitype==9)
            {
                
                
                //金额
                if(!this.jsmoneyvalidata(comparator,curvalue,relatevalue,fieldlabel,relatefieldlabel,0))
                {
                    return false;
                }
            }
        }
        return true;
    }
    this.getformuladatefieldvalue=function(relateformulavalue){
        var popupobj=CrmPopup.getPopupObj('last');        
        if(relateformulavalue=='curdate'){
            return this.validatas.curdate;
        }
        else if(relateformulavalue=='curdatetime'){
            datetime=new DateTime(this.validatas.curdatetime);
            var tmpdatetime= datetime.addNumber(popupobj.timeCount,'second');
            return datetime.FormatDate(DateTime.FormatStr['DateTime']);
        }
        
        else{
            //具体字符
            return relateformulavalue;
        }
    }
    this.jsdatevalidate=function(comparator,curvalue,relatevalue,curfieldlabel,relatefieldlabel,row){
        
        if(comparator=='m'){	//小于等于
            if(trim(relatevalue)=='')
            {
                //36750: （1.6）项目立项新增界面>实际完成日期字段：当实际完成日期字段值为空时不判断，实际完成日期不能小于开始日期
                return true;
            }
            if(curvalue>relatevalue){
                var confirm_str = arrJsPopLabel['CANNOTTHAN'];
                if(row>0){
                    
                     if(language=='zh-cn')
                            audioRemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['LINE']+row+arrJsPopLabel['row']+curfieldlabel+confirm_str+relatefieldlabel);
                     else
                        audioRemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['LINE']+row+" "+curfieldlabel+confirm_str+relatefieldlabel);
                }
                else{
                    audioRemindsMsg("","LdPopWidth400px","","yes","",curfieldlabel+confirm_str+relatefieldlabel);
                }
                return false;
            }
        }else if(comparator == 'h'){	//大于等于
            if(trim(curvalue)=='')
            {
                //36750: （1.6）项目立项新增界面>实际完成日期字段：当实际完成日期字段值为空时不判断，实际完成日期不能小于开始日期
                return true;
            }
			if(curvalue<relatevalue){
                var confirm_str = arrJsPopLabel['cannotbelessthan1'];
                if(row>0){
                    
                     if(language=='zh-cn')
                            audioRemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['LINE']+row+arrJsPopLabel['row']+curfieldlabel+confirm_str+relatefieldlabel);
                     else
                        audioRemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['LINE']+row+" "+curfieldlabel+confirm_str+relatefieldlabel);
                }
                else{
                    audioRemindsMsg("","LdPopWidth400px","","yes","",curfieldlabel+confirm_str+relatefieldlabel);
                }
                return false;
            }
		}
        return true;
    }
    
    this.tabdetailvalidata=function()
    {
       
        var popupobj=CrmPopup.getPopupObj("last");
        if(popupobj.validatasave==null || popupobj.validatasave==undefined)
        {
            return true ;
        }
        if(popupobj.validatasave['detailcols']==null || popupobj.validatasave['detailcols']==undefined)
        {
            return true;
        }
        var divid=popupobj.divid;
       // var tableobj=ld("#"+popupobj.divid+" [name=proTab]").get(0);// document.getElementById("proTab");
       /*  if(popupobj.module=='CashBill'){
            var rowlength=ld("#"+popupobj.divid+" [tag=cashbillinfo]").length;
            
        }
        else
             var rowlength=ld("#"+popupobj.divid+" [name=rowcnt]").val();//document.getElementById('rowcnt').value;
            */
            
       var trobjs=popupobj.getTrObjsByDelType('no');
       
       var that=this;
       var ret=true;
       // for(var i=1;i<=rowlength;i++)//循环行
       ld.each(trobjs,function()
        {
            var rowobj=ld(this);
            var rowindex=ld(this).attr("rowindex");
			//if(CrmPopup.findHtmlobj(divid,'hidden_rowid_'+i).val() == 0){
				for(var j=0;j<popupobj.detailfields.length;j++)//循环列
				{           
					if(popupobj.validatasave['detailcols'][popupobj.detailfields[j].fieldname]==undefined)
					{
						continue;
					}
	  
					for(var k=0;k<popupobj.validatasave['detailcols'][popupobj.detailfields[j].fieldname].length;k++)
					{
						var tmpvalidata=popupobj.validatasave['detailcols'][popupobj.detailfields[j].fieldname];
							
						if(tmpvalidata[k].relateformulavalue!=""&&tmpvalidata[k].relateformulavalue!=undefined)
						{
						   var relatevalue=that.getformuladatefieldvalue(tmpvalidata[k].relateformulavalue);
                         
						   var relatefieldlabel=popupobj.validatasave['relateformulavalue'][tmpvalidata[0].relateformulavalue]['fieldlabel'];
						}
						else
						{
							var relatefieldlabel="";
							var relatevalue="0";
							var relatefieldname=popupobj.validatasave['detailcols'][popupobj.detailfields[j].fieldname][k].relatefieldname;
						   
							if(relatefieldname!=""&&relatefieldname!=undefined)
							{
								var tmprelatefieldname=relatefieldname;
							     if(ld(rowobj).find(" [name="+tmprelatefieldname+"]").length<=0)
                                    continue;
								var relatevalue=ld(rowobj).find(" [name="+tmprelatefieldname+"]").val();
								var relatefieldlabel=popupobj.validatasave['detailcols']['fieldlabel'][relatefieldname];
							}
						}
						var comparator=popupobj.validatasave['detailcols'][popupobj.detailfields[j].fieldname][k].comparator;
						var curvalue=ld(rowobj).find(" [name="+popupobj.detailfields[j].fieldname+"]").val();
						if(popupobj.detailfields[j].fieldtype=='Amount'||popupobj.detailfields[j].fieldtype=='Num')//金额/数字
						{
						  if(popupobj.module=='CashBill'&&popupobj.cashbilltype=='cashbill'&&popupobj.detailfields[j].columnname=='total'){
						      //41449: （61mis.com/kfbtest）收款单新建/编辑界面，关联核销预收单后，“实际收款金额”为0时，无法保存
                              if(ld("#"+popupobj.divid+" [tag=debuction][deleted=no]").length>0)
                              {
                                     ret=true;
                                     return false;
                              }
						  }
							if(!that.jsmoneyvalidata(comparator,curvalue,relatevalue,popupobj.detailfields[j].fieldlabel,relatefieldlabel,rowindex))
							{
							     ret=false;
							     	return false;
							}
						}
						else if(popupobj.detailfields[j].fieldtype=='Date_Ymd' || popupobj.detailfields[j].fieldtype=='Date_YmdHms')//日期
						{
						   
							if(!that.jsdatevalidate(comparator,curvalue,relatevalue,popupobj.detailfields[j].fieldlabel,relatefieldlabel,rowindex))
							{
						      	 ret=false;
								return false;
							}
						}
					}
				}
			//}
        });
       
        return ret;
    }
    
    
    this.producttoolvalidata=function()
    {
       var that=this;
       var ret=true;
        var popupobj=CrmPopup.getPopupObj("last");
        if(popupobj.validatasave==null || popupobj.validatasave==undefined)
        {
            return true ;
        }
        if(popupobj.validatasave['detailcols']==null || popupobj.validatasave['detailcols']==undefined)
        {
            return true;
        }
      
        var divid=popupobj.divid;
        var tableobj=ld("#"+popupobj.divid+" [name=proTab]").get(0);//document.getElementById("proTab");
        var rowlength=ld("#"+popupobj.divid+" [name=rowcnt]").val();//document.getElementById('rowcnt').value;
        var trobjs=popupobj.getTrObjsByDelType("no");
        
        //for(var i=1;i<=rowlength;i++)//循环行
        //{
        var validatadetailcols=[];
        if(popupobj.validatasave.detailcols!=undefined)
        {
            ld.each(popupobj.validatasave['detailcols'],function(tmpdetailcolname,tmptest){
                validatadetailcols.push(tmpdetailcolname);
                
            })
        }
        ld.each(trobjs,function(){
               var rowobj=ld(this);
	           var rowindex=ld(this).attr("rowindex");
               
				//for(var j=0;j<popupobj.detailfields.length;j++)//循环列
			//	{           
				//	if(popupobj.validatasave['detailcols'][popupobj.detailfields[j].fieldname]==undefined)
					//{
					//	continue;
					//}
	  
					for(var k=0;k<validatadetailcols.length;k++)
					{
					  
                        
                         var validatafieldname=validatadetailcols[k];
                        var detailfieldinfo=popupobj.detailfieldcolumninfo[validatafieldname];
                       
						var tmpvalidata=popupobj.validatasave['detailcols'][validatafieldname];
							
						if(tmpvalidata[k].relateformulavalue!=""&&tmpvalidata[k].relateformulavalue!=undefined)
						{
						   var relatevalue=that.getformuladatefieldvalue(tmpvalidata[k].relateformulavalue);
                         
						   var relatefieldlabel=popupobj.validatasave['relateformulavalue'][tmpvalidata[0].relateformulavalue]['fieldlabel'];
						}
						else
						{
							var relatefieldlabel="";
							var relatevalue="0";
							var relatefieldname=popupobj.validatasave['detailcols'][detailfieldinfo.fieldname][k].relatefieldname;
						   
							if(relatefieldname!=""&&relatefieldname!=undefined)
							{
								var tmprelatefieldname=relatefieldname;
								if(ld(rowobj).find(" [name="+relatefieldname+"]").length<=0)
								{
									continue;
								}
								var relatevalue=ld(rowobj).find(" [name="+relatefieldname+"]").val();
								var relatefieldlabel=popupobj.validatasave['detailcols']['fieldlabel'][relatefieldname];
							}
						}
						var comparator=popupobj.validatasave['detailcols'][detailfieldinfo.fieldname][k].comparator;
						var curvalue=ld(rowobj).find(" [name="+detailfieldinfo.fieldname+"]").val();
						if(detailfieldinfo.uitype=='28'||detailfieldinfo.uitype==10||detailfieldinfo.uitype=='163')//金额
						{
							if(!that.jsmoneyvalidata(comparator,curvalue,relatevalue,detailfieldinfo.fieldlabel,relatefieldlabel,rowindex))
							{
							     ret=false;
								return false;
							}
						}
						else if(popupobj.detailfields[j].uitype=='51' )//日期
						{
						   
							if(!that.jsdatevalidate(comparator,curvalue,relatevalue,detailfieldinfo.fieldlabel,relatefieldlabel,rowindex))
							{
							  ret=false;
								return false;
							}
						}
					}
				//}
			
        });
       
       
        return ret;
    }
    
    /*
    金额类型的字段判断
    */
    this.jsmoneyvalidata=function(comparator,curvalue,relatevalue,curfieldlabel,relatefieldlabel,row)
    {
        if(isNaN(curvalue))
        {
            return false;
        }
      
        if(comparator=='notempty')
        {   
            if(trim(curvalue)==''||parseFloat(curvalue).toFixed(2)=="0.00")
            {
                var confirm_str = arrJsPopLabel['CANNOTEMPTYORZERO'];
                
                if(row>0)
                {
                    if(language=='zh-cn')
                             audioRemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['LINE']+row+arrJsPopLabel['row']+curfieldlabel+confirm_str+relatefieldlabel);
                    else
                         audioRemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['LINE']+row+" "+curfieldlabel+confirm_str+relatefieldlabel);
                }
                else{
                    audioRemindsMsg("","LdPopWidth400px","","yes","",curfieldlabel+confirm_str+relatefieldlabel);
                }
                return false;
            }
        }
        else if(comparator =='m')
        {
            
            if(parseFloat(curvalue)>parseFloat(relatevalue))
            {
                var confirm_str = arrJsPopLabel['CANNOTTHAN'];
                if(row>0)
                {
                    if(language=='zh-cn')
                         audioRemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['LINE']+row+arrJsPopLabel['row']+curfieldlabel+confirm_str+relatefieldlabel);
                    else
                        audioRemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['LINE']+row+" "+curfieldlabel+confirm_str+relatefieldlabel);
                }
                else
                {
                    audioRemindsMsg("","LdPopWidth400px","","yes","",curfieldlabel+confirm_str+relatefieldlabel);
                    return false;
                }
                return false;
            }
        }
        else if(comparator =='h')
        {
            if(parseFloat(relatevalue)>parseFloat(curvalue))
            {
                var confirm_str = arrJsPopLabel['SHOULDGREATEROREQUAL'];
                
                if(row>0)
                {
                    if(language=='zh-cn')
                         audioRemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['LINE']+row+arrJsPopLabel['row']+curfieldlabel+confirm_str+relatefieldlabel);
                    else
                        audioRemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['LINE']+row+" "+curfieldlabel+confirm_str+relatefieldlabel);
                }
                else
                {
                    audioRemindsMsg("","LdPopWidth400px","","yes","",curfieldlabel+confirm_str+relatefieldlabel);
                    return false;
                }
                return false;
            }
        }
        else if(comparator =='g')
        {
            if(parseFloat(relatevalue)>=parseFloat(curvalue))
            {
                var confirm_str = arrJsPopLabel['SHOULDBEGREATER'];
                
                if(row>0)
                {
                    if(language=='zh-cn')
                         audioRemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['LINE']+row+arrJsPopLabel['row']+curfieldlabel+confirm_str+relatefieldlabel);
                    else
                        audioRemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['LINE']+row+" "+curfieldlabel+confirm_str+relatefieldlabel);
                }
                else
                {
                    audioRemindsMsg("","LdPopWidth400px","","yes","",curfieldlabel+confirm_str+relatefieldlabel);
                    return false;
                }
                return false;
            }
        }
        else if(comparator=='n')
        {
            if(parseFloat(relatevalue)!=parseFloat(curvalue))
            {
                var confirm_str = fLabels['n'];
                
                if(row>0)
                {
                    if(language=='zh-cn')
                         audioRemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['LINE']+row+arrJsPopLabel['row']+curfieldlabel+confirm_str+relatefieldlabel);
                    else
                        audioRemindsMsg("","LdPopWidth400px","","yes","",arrJsPopLabel['LINE']+row+" "+curfieldlabel+confirm_str+relatefieldlabel);
                }
                else
                {
                    audioRemindsMsg("","LdPopWidth400px","","yes","",curfieldlabel+confirm_str+relatefieldlabel);
                    return false;
                }
                return false;
            }
        }
        return true;
    }
}
// //duan 20230111 允许保存的验证规则通用方法
// validatasave.CheckAllowSavePhpRule = function(module,record,tmpurl){
//     var con=true; //zkt 0046269: 验证规则，允许保存的时候，弹出的提示信息界面有“是”、“否”（确定/取消）2个按钮 选择“是”（确定），保存;选择“否”（取消），返回新增或者编辑界面
//     //edit:can 20211015 048306: 这个账套-采购管理-采购申请单-下推生成采购合同，把验证规则关闭了，甚至删除了，但是还是提醒了
//     ldAjaxNoProgresssync("index.php?module=Users&action=UsersAjax&file=PageValidataSave&pagevalidatamodule="+module+"&record="+record,tmpurl,
//     function(ajaxdata){
//         if(ajaxdata.code=="-2")
//         {
            
//              con= confirm(ajaxdata.msg);
                          
//         }else if(ajaxdata.code=="-1"){
//             con = false;
//             RemindsMsg("", "LdPopWidth600px", "", "yes", "", ajaxdata.msg);
//         }
//     })
//     return con;
// }

//XUQIU1001216 xxy 2023-8-30 页面设置-验证规则，将验证提示不阻断操作的提示信息修改为验证提示阻断操作的弹出层样式
validatasave.CheckAllowSavePhpRule = function(module,record,tmpurl){
    // var con=true;
    return new Promise((resolve, reject) => {
        ldAjaxNoProgresssync("index.php?module=Users&action=UsersAjax&file=PageValidataSave&pagevalidatamodule="+module+"&record="+record,tmpurl,
        function(ajaxdata){
            if(ajaxdata.code=="-2")
            { 
                RemindsMsg("", "LdPopWidth400px", "", "yes", "yes", ajaxdata.msg);
                validatasave.confirmPopup().then(response => {
                    con = response;
                    resolve(response);
                });
            }else if(ajaxdata.code=="-1"){
                RemindsMsg("", "LdPopWidth400px", "", "yes", "", ajaxdata.msg);
                con = false;
                resolve(false);
            }
            else{
                resolve(true);
            }
        })
    })
    // return con;
}
validatasave.confirmPopup = function() {//弹窗需要异步执行
	// try {
        return new Promise((resolve, reject) => {
            var popupobj=CrmPopup.getPopupObj('last');
            ld('#'+popupobj.divid+' input[tagclick="msgConfirm"]').on('click', function () {
                resolve(true);
            });
            ld('#'+popupobj.divid+' [tagclick="msgConfirmCancel"]').on('click', function () {
                resolve(false);
            });
        })
        return true;
    // } catch {
        return false;
    // }          
}
// 20240611判断编辑之后是否需要重置审批状态
validatasave.checkResetApprove = function(popupobj,record,module,callback) {//弹窗需要异步执行
    var con = true;
    if(popupobj.editresetapprover != 'yes'){
        ldAjaxNoProgresssync("index.php?module=Approve&action=ApproveAjax&file=SaveResetApprovestatus&fld_module=" + module + "&record=" + record , '', function (ajaxdata) {
            if (ajaxdata.code == 1) {
                var confirm_str = arrJsPopLabel['ApprovedEditAgainSubmitMsg'];
                MessagePopup.TipTwo_warning(confirm_str);
                var remindpopupobj = CrmPopup.getPopupObj('last');
                ld('#'+remindpopupobj.divid+' [tagclick="msgConfirm"]').bind('click',function () {
                    popupobj.editresetapprover = 'yes';
                    callback();
                })
                con = false;
            }
        });
    }else{
        popupobj.editresetapprover = '';
    }
    return con;
}

//判断 用户超过授权数量 给出提示
validatasave.checkuserscountsave = function(popupobj,callback) {//弹窗需要异步执行
    var con = true;
    if(popupobj.checkuserscount != 'yes'){
        var url = "index.php?module=Users&action=UsersAjax&file=checkuserscountsave";
        var user_type = 'crm';
        if(popupobj.user_type && !empty(popupobj.user_type)){
            user_type = popupobj.user_type;
        }
        url += '&user_type='+user_type;
        ldAjaxNoProgresssync(url, '', function (ajaxdata) {
            if (ajaxdata.code == 1) {
                //var confirm_str = arrJsPopLabel['ApprovedEditAgainSubmitMsg'];
                var confirm_str = arrJsPopLabel['usercheckacountmsg'];
                MessagePopup.TipTwo_warning(confirm_str);
                var remindpopupobj = CrmPopup.getPopupObj('last');
                ld('#'+remindpopupobj.divid+' [tagclick="msgConfirm"]').bind('click',function () {
                    popupobj.checkuserscount = 'yes';
                    callback();
                })
                con = false;
            }
        });
    }else{
        popupobj.checkuserscount = '';
    }
    return con;
}
