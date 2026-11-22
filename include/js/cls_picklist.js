function cls_picklist(fieldname,picklistcontentarray)
{
   // this.isappendlihtml='no';//是否已经添加下拉框内容
   this.parentdependfieldname="";
   this.parentdependfieldlabel="";
   this.fieldlabel="";
    this.fieldname=fieldname;
    this.picklistcontentarray=picklistcontentarray;//下拉框内容
    
    this.childdependfieldname=[];
    this.prev_chooseliobj=null;
    this.cmb_fldname="";
    var that=this;
    this.popupobj=undefined;

    this.setPopupobj=function(popupobj)
    {
        this.popupobj=popupobj;
    }

    this.getpicklistDepencyByParentFieldname=function(){


        var popupobj=CrmPopup.getPopupObj('last');
         var parentdependfieldvalue=CrmPopup.getHtmlobjval(popupobj.divid,this.parentdependfieldname);
        var url='index.php?module='+popupobj.module+"&parentfieldname="+this.parentdependfieldname+"&action="+popupobj.module+"Ajax&file=getPickListDepencyDatasource&parentdependfieldvalue="+encodeURIComponent(parentdependfieldvalue)+"&targetfield="+this.fieldname;
        
             ld.ajax({
            url: url,
            type: 'POST',
            data:{"namename": "uname", "namenameage": 18},
           dataType:'json',
            async: false,//
            timeout: 10000,
           
            success: function(data)
            {
                if(data.code==1)
                {
                     
                             
                     $("status").style.display="none";
                     if(popupobj.picklistdepency==null)
                     {
                        popupobj.picklistdepency=[];
                     }
                     popupobj.picklistdepency[that.parentdependfieldname]=data.result.picklistDependencyDataSource;
                   } 
            
            },
            error:function(data)
            {
             
            }
            
        });
        
    }
    this.arrow_click=function(event){
    
        var fldname=this.fieldname;
        this.prev_chooseliobj=null;
        var e=event||window.event;
       //edit:can 2021-03-01  043660: (61mis.com/kfbcrm)客户管理-客户-新增（需要补丁）；新增客户界面点开销售负责人下拉框后，再点击其他下拉框字段，销售负责人下拉框不会自动收起
          ld(" .chzn-drop").css("display",'none');
		window.event? window.event.cancelBubble = true : e.stopPropagation();
        var popupobj=CrmPopup.getPopupObj("last");
        var divid=popupobj.divid;
        
        if(that.parentdependfieldname!=""&&CrmPopup.isExistsObj(divid,that.parentdependfieldname)
                &&CrmPopup.getHtmlobjval(divid,that.parentdependfieldname)=="")
        {
            if(that.fieldlabel=="")
            {
                for(var k=0;k<popupobj.fields.length;k++)
                {
                    if(popupobj.fields[k].fieldname==that.fieldname)
                    {
                        that.fieldlabel=popupobj.fields[k].fieldlabel;
                        break;
                    }
                }
            }
          
            if(language=='en')
                audioRemindsMsg("","",popupobj.module,"","",arrJsPopLabel['PLEASESLECTFIRST']+'"'+that.parentdependfieldlabel+'"'+arrJsPopLabel['THNECHOOSE']+'"'+that.fieldlabel+'"');
            else
                audioRemindsMsg("","",popupobj.module,"","",arrJsPopLabel['PLEASESLECTFIRST']+'“'+that.parentdependfieldlabel+'”'+arrJsPopLabel['THNECHOOSE']+'“'+that.fieldlabel+'”');
            return false;
        }
      
        picklist=true;
        if(popupobj.cmb_fldname!=''&&fldname!=popupobj.cmb_fldname&&CrmPopup.isExistsObj(divid,"dv_drop_"+popupobj.cmb_fldname)){
            //关闭上次点击的下拉框

            CrmPopup.findHtmlobj(divid,"dv_drop_"+popupobj.cmb_fldname).css("left","-9000px");
            CrmPopup.findHtmlobj(divid,"cmb_a_"+popupobj.cmb_fldname).attr("class","");
            CrmPopup.findHtmlobj(divid,"cmb_a_"+popupobj.cmb_fldname).addClass('chzn-single');
            CrmPopup.findHtmlobj(divid,'dv_chzn_'+popupobj.cmb_fldname).attr("class","");

            CrmPopup.findHtmlobj(divid,'dv_chzn_'+popupobj.cmb_fldname).removeClass().addClass('chzn-container');
            CrmPopup.findHtmlobj(divid,'dv_chzn_'+popupobj.cmb_fldname).addClass('chzn-container-single');
            ld("#"+divid+" [name=dv_chzn_"+popupobj.cmb_fldname+"]").find(" .chzn-drop").css("display",'');
            popupobj.cmb_fldname='';
            is_leave=false;
        }
          
        popupobj.cmb_fldname=fldname;
     
        var fromobj=CrmPopup.findHtmlobj(divid,"cmb_a_"+popupobj.cmb_fldname);//获取点击按钮元素
        var dvdrop= CrmPopup.findHtmlobj(divid,"dv_drop_"+popupobj.cmb_fldname);//获取下拉框内内容
        var j=1;
        var obj= CrmPopup.findHtmlobj(divid,this.fieldname);
        var objul=CrmPopup.findHtmlobj(divid,"cmb_ul_"+this.fieldname);
		CrmPopup.findHtmlobj(divid,"cmb_span_optiontext_"+this.fieldname).attr('cur_input_select',"yes");
        CrmPopup.findHtmlobj(divid,"txt_search_"+popupobj.cmb_fldname).focus();//34384: （1.6登录）点击下拉框字段时光标应停留在搜索框内
        CrmPopup.findHtmlobj(divid,"cmb_span_optiontext_"+this.fieldname).select();
        objul.html("");//每次都重新添加，不然每次展开和收缩界面要重新初始化或者还有其他依赖项问题
        //下拉框收起展开
        // diony 2021-06-22 方法更改，增加红色边框提醒，所以这里需要更改
        // if(fromobj.attr("class")=='chzn-single')
        if(!fromobj.hasClass('chzn-single-with-drop'))
        {
            fromobj.addClass('chzn-single-with-drop') ;
            CrmPopup.findHtmlobj(divid,'dv_chzn_'+this.fldname).attr("class","");
             CrmPopup.findHtmlobj(divid,'dv_chzn_'+this.fldname).addClass("chzn-container");
             CrmPopup.findHtmlobj(divid,'dv_chzn_'+this.fldname).addClass("chzn-container-single");
             CrmPopup.findHtmlobj(divid,'dv_chzn_'+this.fldname).addClass("chzn-container-active");
            
             dvdrop.css("left","0");
             dvdrop.css("display","");
             CrmPopup.findHtmlobj(divid,'txt_search_'+this.fldname).val('');
             CrmPopup.findHtmlobj(divid,'txt_search_'+this.fldname).focus();
        }
        else
        {
            CrmPopup.findHtmlobj(divid,'dv_chzn_'+this.fldname).attr("class","");
            
            CrmPopup.findHtmlobj(divid,'dv_chzn_'+this.fldname).addClass("chzn-container");
             CrmPopup.findHtmlobj(divid,'dv_chzn_'+this.fldname).addClass("chzn-container-single");
             fromobj.attr("class","");
             fromobj.addClass('chzn-single');
           // dvdrop.style.left='-9000px';
            dvdrop.css("left","-9000px");
        }
        var picklistobj=CrmPopup.getPopupObj('last').picklistobjarray[this.fieldname];
        var dependpicklist="";
        //级联字段
        if(this.parentdependfieldname!="")
        {
            var parentdependfieldvalue=CrmPopup.getHtmlobjval(popupobj.divid,this.parentdependfieldname);

            //edit:duan date:2024/10/14 reason:处理小编辑时，上级字段不在界面上的问题
            if(empty(parentdependfieldvalue)){
                if(!empty(popupobj.columnfields_value) && !empty(popupobj.columnfields_value[this.parentdependfieldname])){
                    parentdependfieldvalue = popupobj.columnfields_value[this.parentdependfieldname];
                }
            }

            if(popupobj.picklistdepency==null|| popupobj.picklistdepency[this.parentdependfieldname]==undefined||popupobj.picklistdepency[this.parentdependfieldname][parentdependfieldvalue]==undefined)
            {
                this.getpicklistDepencyByParentFieldname();
            }
            if(popupobj.picklistdepency[this.parentdependfieldname][parentdependfieldvalue]!=undefined)
                dependpicklist=  popupobj.picklistdepency[this.parentdependfieldname][parentdependfieldvalue][that.fieldname];
             
        }
        if(this.childdependfieldname!="")
        {
            
        }
        //console.log(picklistcontentarray);
		//chj 2021/8/11 级联字段设置时，PC端设置为空显示全部，移动端设置为空就是显示空选项。预期结果：应该参考移动端效果，若不设置则显示为空
        if((dependpicklist==""||dependpicklist==undefined) && this.parentdependfieldname == "")
        {
            for(var i=0;i<this.picklistcontentarray.length;i++)
            {
                var text = typeof this.picklistcontentarray[i]['label'] !== "undefined" ? this.picklistcontentarray[i]['label'] : this.picklistcontentarray[i][1];
              
                if(text=='&radic;')
                {
                    text='√';
                }
                else if(text=='&times;')
                {
                    text="×";
                }
                else if(text=="&#039;")
                {
                    text="'";
                }
                else if(text=="&quot;")
                {
                    text='"';
                }
                else if(text=="&lt;")
                {
                    text="<";
                }
                else if(text=="&gt;")
                {
                    text=">"
                }
                let color = typeof this.picklistcontentarray[i]['color'] !== "undefined" ? this.picklistcontentarray[i]['color'] : this.picklistcontentarray[i][3],
                    value = typeof this.picklistcontentarray[i]['value'] !== "undefined" ? this.picklistcontentarray[i]['value'] : this.picklistcontentarray[i][0],
                    label = typeof this.picklistcontentarray[i]['label'] !== "undefined" ? this.picklistcontentarray[i]['label'] : this.picklistcontentarray[i][1];

                objul.append('<li style="color:'+color+'" class="active-result" name="dv_chzn_'+i+"_"+this.fieldname+'"> '+label+'</li>');
				//  alert(this.picklistcontentarray[i][0]);
				CrmPopup.findHtmlobj(divid,"dv_chzn_"+i+"_"+this.fieldname).unbind("click").bind("click", {index: i,selectedText:label,selectedValue:value,selectedColor:color}, that.liclick);
				CrmPopup.findHtmlobj(divid,"dv_chzn_"+i+"_"+this.fieldname).unbind("mouseover").bind("mouseover", function(event){
					that.mouseover(event);
                
				});
            }
			objul.append('<li style="" class="" name="li_chzn_'+this.fieldname+'"> '+arrJsPopLabel['NOMATCHINGITEMS']+'</li>');
        }
        else
        {
            for(var i=0;i<dependpicklist.length;i++)
            {
                var value = dependpicklist[i];
                var color = "#666";
                var label = dependpicklist[i];

                for(var j=0;j<this.picklistcontentarray.length;j++){
                    let tmpColor = typeof this.picklistcontentarray[j]['color'] !== "undefined" ? this.picklistcontentarray[j]['color'] : this.picklistcontentarray[j][3],
                        tmpValue = typeof this.picklistcontentarray[j]['value'] !== "undefined" ? this.picklistcontentarray[j]['value'] : this.picklistcontentarray[j][0],
                        tmpLabel = typeof this.picklistcontentarray[j]['label'] !== "undefined" ? this.picklistcontentarray[j]['label'] : this.picklistcontentarray[j][1];
                    if(value === tmpValue){
                        color = tmpColor;
                        label = tmpLabel;
                    }
                }
				objul.append('<li style="color:'+color+'" class="active-result" name="dv_chzn_'+i+"_"+this.fieldname+'"> '+label+'</li>');
				CrmPopup.findHtmlobj(divid,"dv_chzn_"+i+"_"+this.fieldname).unbind("click").bind("click", {index: i,selectedText:label,selectedValue:value,selectedColor:color}, that.liclick);
				CrmPopup.findHtmlobj(divid,"dv_chzn_"+i+"_"+this.fieldname).unbind("mouseover").bind("mouseover", function(event){
					that.mouseover(event);
				});
            }
			objul.append('<li style="" class="" name="li_chzn_'+this.fieldname+'"> '+arrJsPopLabel['NOMATCHINGITEMS']+'</li>');
        }

        //20191226 diony 下拉框向上弹出
        var popupobj=CrmPopup.getPopupObj('last');
        if(popupobj!= undefined){// && MassEditPopup.type != popupobj.type
            var popHeight =ld("#"+popupobj.divid).outerHeight(true);//弹出层高度
            var popTop =ld("#"+popupobj.divid).offset().top;//弹出层距离屏幕顶部高度
            var popheadheight =ld("#"+popupobj.divid+'_head').outerHeight(true);//弹出层距离屏幕顶部高度
            var fieldHeight =ld("#"+popupobj.divid+" [name=cmb_a_"+this.fieldname+"]").offset().top;//搜索框距离屏幕顶部高度
            var cmb_aHeight = ld("#"+popupobj.divid+" [name=cmb_a_"+this.fieldname+"]").outerHeight(true);//搜索框高度
            var cmb_ulHeight = ld("#"+popupobj.divid+" [name=cmb_ul_"+this.fieldname+"]").outerHeight(true);//弹出层高度
           //edit:can 2020-01-08 43242: （本地php54，8.3.0版本）客户管理-客户-新增；以客户模块为例，当下拉选项在字段上方显示时，选项和下拉框字段出现间隔；
            var topHeight = 0 - parseInt(cmb_ulHeight)+5;

            var tmptop=popTop;
            /*//duan 2022-2-7 判断弹出层是否可以显示在下方时，需要考虑到搜索框自身的高度
            //hzx 2023-06-05 进度追踪 任务 下拉框如果显示在上方被相关信息挡住，则显示在下方
            if(parseInt(popHeight)-(parseInt(fieldHeight) - parseInt(popTop)) > parseInt(cmb_ulHeight)+parseInt(cmb_aHeight) + parseInt(55) || (parseInt(fieldHeight) - 55 -8-49) < parseInt(cmb_ulHeight)+5){
                //duan 2022-2-7 如果弹出层内容变化后的高度小于搜索框到底部的距离，则可显示在下方，
                ld("#"+popupobj.divid+" [name=dv_drop_"+this.fieldname+"]").css('top','');
            }else if(parseInt(fieldHeight) - parseInt(popTop) - parseInt(50) > parseInt(cmb_ulHeight)){
                ld("#"+popupobj.divid+" [name=dv_drop_"+this.fieldname+"]").css('top', topHeight+'px').css('border-top', '1px solid #dbdbdb').css('border-radius', '4px');
            }*/
            var cur_Height = ld("#"+popupobj.divid+" [name=cmb_span_optiontext_"+this.fieldname+"]").outerHeight(true);
            //hzx 20240801 BUG20240731-39  当下拉框位置靠下的时候，下拉框选项在上方，搜索内容搜索结果会出现在很上方
            if(parseInt(cmb_ulHeight) < 280){}else{
                if(parseInt(popHeight)-parseInt(popTop)-parseInt(fieldHeight)-parseInt(cmb_ulHeight)-parseInt(cur_Height) < 0){
                    if(parseInt(fieldHeight)-parseInt(popTop)-parseInt(popheadheight) < parseInt(cmb_ulHeight)){
                        ld("#"+popupobj.divid+" [name=cmb_ul_"+this.fieldname+"]").css('height','100%').css('margin','0');
                        ld("#"+popupobj.divid+" [name=dv_drop_"+this.fieldname+"]").css('top','-'+(parseInt(fieldHeight)-parseInt(popTop)-parseInt(popheadheight))+'px').css('bottom',parseInt(cur_Height)+1+'px').css('border-top', '1px solid #dbdbdb').css('border-radius', '4px');
                    }else{
                        ld("#"+popupobj.divid+" [name=dv_drop_"+this.fieldname+"]").css('top','unset').css('bottom',parseInt(cur_Height)+1+'px').css('border-top', '1px solid #dbdbdb').css('border-radius', '4px');
                    }
                }else {
                    ld("#"+popupobj.divid+" [name=dv_drop_"+this.fieldname+"]").css('top',parseInt(cur_Height)+1+'px').css('bottom','unset').css('border-top', '1px solid #dbdbdb').css('border-radius', '4px');
                }
            }


            ld("#"+popupobj.divid+" [name=dv_drop_"+this.fieldname+"]").css('width',ld("#"+popupobj.divid+" [name=dv_drop_"+this.fieldname+"]").prev().get(0).offsetWidth+'px');
            //if(parseInt(popHeight)-(parseInt(fieldHeight) - parseInt(popTop)) <= parseInt(cmb_ulHeight) + parseInt(55) &&
//                parseInt(fieldHeight) - parseInt(popTop) - parseInt(50) > parseInt(cmb_ulHeight)){                
//                ld("#"+popupobj.divid+" [name=dv_drop_"+this.fieldname+"]").css('top', topHeight+'px').css('border-top', '1px solid #dbdbdb').css('border-radius', '4px');
//            }
        }
        return false;
    };
    this.mouseover=function(event){
     
             var popupobj=CrmPopup.getPopupObj("last");
            var divid=popupobj.divid;

            var e=event||window.event;
            var cur_liobj=e.srcElement||e.target;
          if(that.prev_chooseliobj!=null)
          {
            that.prev_chooseliobj.className="active-result";
          }
        
           cur_liobj.className="active-result highlighted";
          that.prev_chooseliobj=cur_liobj;
    };
   
     this.com_chosen=function(event)
    {  
        window.event? window.event.cancelBubble = true : e.stopPropagation();
		getJsScript('include/js/multipingyin.js',function(){
			that.makepys(event);
		});
    }
   
    //拼音查询
    this.makepys=function(event){
        var popupobj=CrmPopup.getPopupObj("last");
        var divid=popupobj.divid;
        var e=event||window.event;
        var searchobj=e.srcElement||e.target;//查询文本框
        if(searchobj==undefined)
        {
            return false;
        }
        var searchtext=searchobj.value;
      
        var uppersearch=searchtext.toLowerCase();
        
        var objsel=CrmPopup.findHtmlobj(divid,this.fieldname);
       
        var b=false;
        var j=0;
        var pingyin=false;
        
        var dependpicklist="";
        if(this.parentdependfieldname!="")
        {
            var parentdependfieldvalue=CrmPopup.getHtmlobjval(popupobj.divid,this.parentdependfieldname);
            if(!empty(popupobj.picklistdepency[this.parentdependfieldname]) && popupobj.picklistdepency[this.parentdependfieldname][parentdependfieldvalue]!=undefined)
                 dependpicklist=  popupobj.picklistdepency[this.parentdependfieldname][parentdependfieldvalue][that.fieldname];
             
        }
        //拼音查询有待改进，级联字段的查询会有问题，等客户发现再修改
        
        if(dependpicklist!=""&&dependpicklist!=undefined)
        {
            //有级联字段的拼音查询
            
            for(var i=0;i<dependpicklist.length;i++)
            {
                var text=dependpicklist[i];
                 pingyin=false;
              
                var arrRslt = makePy(text);
        	    
                if(arrRslt != undefined){
                    for(var k=0;k<arrRslt.length;k++)
                    {
                        
                        if(arrRslt[k].toLowerCase().indexOf(uppersearch)>=0||uppersearch=='')
                        {
                          
                            CrmPopup.findHtmlobj(divid,'dv_chzn_'+j+"_"+that.fieldname).attr("class","");
                            CrmPopup.findHtmlobj(divid,'dv_chzn_'+j+"_"+that.fieldname).addClass('active-result');
                           
                             pingyin=true;
                             b=true;
                            break;
                        }
                    }
                   
                    if(dependpicklist[i].toLowerCase().indexOf(searchtext)>=0||pingyin==true)
                    {
                    	 b=true;
                         
                    	 CrmPopup.findHtmlobj(divid,'dv_chzn_'+j+"_"+that.fieldname).attr("class","");
                         CrmPopup.findHtmlobj(divid,'dv_chzn_'+j+"_"+that.fieldname).addClass('active-result');
                    }
                      
                    else
                    {
                          
                    	  CrmPopup.findHtmlobj(divid,'dv_chzn_'+j+"_"+that.fieldname).attr("class","");
                           
                    }
                    j++;
                }
            }
        }
        else
        {
            
            for(var i=0;i<this.picklistcontentarray.length;i++)
            {
                pingyin=false;
                let label = typeof this.picklistcontentarray[i]['label'] !== "undefined" ? this.picklistcontentarray[i]['label'] : this.picklistcontentarray[i][1];
                var arrRslt = makePy(label.toLowerCase());
        	
                if(arrRslt != undefined){
                    for(var k=0;k<arrRslt.length;k++)
                    {
                      
                        
                        if(arrRslt[k].toLowerCase().indexOf(uppersearch)>=0||uppersearch=='')
                        {
                            CrmPopup.findHtmlobj(divid,'dv_chzn_'+j+"_"+that.fieldname).attr("class","");
                            CrmPopup.findHtmlobj(divid,'dv_chzn_'+j+"_"+that.fieldname).addClass('active-result');
                           
                             pingyin=true;
                             b=true;
                            break;
                        }
                    }
                   
                    if(label.toLowerCase().indexOf(uppersearch)>=0||pingyin==true)
                    {
                    	 b=true;
                         
                    	 CrmPopup.findHtmlobj(divid,'dv_chzn_'+j+"_"+that.fieldname).attr("class","");
                         CrmPopup.findHtmlobj(divid,'dv_chzn_'+j+"_"+that.fieldname).addClass('active-result');
                    }
                      
                    else
                    {
                          
                    	  CrmPopup.findHtmlobj(divid,'dv_chzn_'+j+"_"+that.fieldname).attr("class","");
                           
                    }
                    j++;
                }
            }
        }
       
        if(b==false)
       	{
       	    CrmPopup.findHtmlobj(divid,'li_chzn_'+that.fieldname).attr("class","");
            CrmPopup.findHtmlobj(divid,'li_chzn_'+that.fieldname).addClass("active-result");
       	}
        else
        {
            CrmPopup.findHtmlobj(divid,'li_chzn_'+that.fieldname).attr("class","");
        }
		//objsel.val('');
        //20191226 diony 下拉框向上弹出，搜索后        
        // var popupobj=CrmPopup.getPopupObj('last');
        if(popupobj!= undefined){// && MassEditPopup.type != popupobj.type
            var popHeight =ld("#"+popupobj.divid).outerHeight(true);
            var popTop =ld("#"+popupobj.divid).offset().top;
            var popheadheight =ld("#"+popupobj.divid+'_head').outerHeight(true);//弹出层距离屏幕顶部高度
            var fieldHeight =ld("#"+popupobj.divid+" [name=cmb_a_"+this.fieldname+"]").offset().top;
            var cmb_ulHeight = ld("#"+popupobj.divid+" [name=cmb_ul_"+this.fieldname+"]").outerHeight(true);
            var cur_Height = ld("#"+popupobj.divid+" [name=cmb_span_optiontext_"+this.fieldname+"]").outerHeight(true);
            //hzx 20240801 BUG20240731-39  当下拉框位置靠下的时候，下拉框选项在上方，搜索内容搜索结果会出现在很上方
            if(parseInt(cmb_ulHeight) < 280){}else {
                if (parseInt(popHeight) - parseInt(popTop) - parseInt(fieldHeight) - parseInt(cmb_ulHeight) - parseInt(cur_Height) < 0) {
                    if (parseInt(fieldHeight) - parseInt(popTop) - parseInt(popheadheight) < parseInt(cmb_ulHeight)) {
                        ld("#" + popupobj.divid + " [name=cmb_ul_" + this.fieldname + "]").css('height', '100%').css('margin', '0');
                        ld("#" + popupobj.divid + " [name=dv_drop_" + this.fieldname + "]").css('top', '-' + (parseInt(fieldHeight) - parseInt(popTop) - parseInt(popheadheight)) + 'px').css('bottom', parseInt(cur_Height) + 1 + 'px').css('border-top', '1px solid #dbdbdb').css('border-radius', '4px');
                    } else {
                        ld("#" + popupobj.divid + " [name=dv_drop_" + this.fieldname + "]").css('top', 'unset').css('bottom', parseInt(cur_Height) + 1 + 'px').css('border-top', '1px solid #dbdbdb').css('border-radius', '4px');
                    }
                } else {
                    ld("#" + popupobj.divid + " [name=dv_drop_" + this.fieldname + "]").css('top', parseInt(cur_Height) + 1 + 'px').css('bottom', 'unset').css('border-top', '1px solid #dbdbdb').css('border-radius', '4px');
                }
            }

            /*var topHeight = 0 - 26 - parseInt(cmb_ulHeight);
            if(parseInt(popHeight)-(parseInt(fieldHeight) - parseInt(popTop)) <= parseInt(cmb_ulHeight) + parseInt(55) &&
                parseInt(fieldHeight) - parseInt(popTop) - parseInt(40) > parseInt(cmb_ulHeight) && parseInt(fieldHeight) - 55 -8-49 > parseInt(cmb_ulHeight)+5){
                ld("#"+popupobj.divid+" [name=dv_drop_"+this.fieldname+"]").css('top', topHeight+'px').css('border-top', '1px solid #dbdbdb').css('border-radius', '4px');
            }
            else{
                //ld("#"+popupobj.divid+" [name=dv_drop_"+this.fieldname+"]").css('top', '').css('border-top', 'none').css('border-radius', '0 0 4px 4px');
            }*/
        }
    };
   this.clearchilddependfieldcontent=function(childependfield,i)
   {    //34144: PC端->级联字段->重新选择上级字段之后应该清空下级字段
        var popupobj=CrmPopup.getPopupObj("last");

       //ls 2022-03-03 0050227: 【苏州灵当】V8.4.5.6（https://kh.xiaoshou360.com/suzhould [^]）工作台-CRM学习资料-新建无法保存，提示"附件小类不能为空"
       // 级联下级字段为数据分类的链接模块的条件时，选择上级字段时，下级字段不能被清除，即链接模块等于条件不可修改
       if((popupobj.linkmoduleviewname != "undefined"&&!empty(popupobj.linkmoduleviewname)) && ld("#"+popupobj.divid+" [name=span_"+childependfield+"]").val() != undefined){
           if(ld("#"+popupobj.divid+" [name="+childependfield+"]").val() == ld("#showCustomlist [name=cmb_span_optiontext_selectcustomview_" + popupobj.module + "]").val()){
               return;
           }
       }
         //while(childependfield!="")
        // {

            if(CrmPopup.isExistsObj(popupobj.divid,childependfield))
            {
                CrmPopup.findHtmlobj(popupobj.divid,childependfield).val("");
                //zkt 20240530 BUG20240530-01  中智：项目立项，修改项目类型后保存不了
                CrmPopup.findHtmlobj(popupobj.divid,"span_"+childependfield).html("");
                CrmPopup.findHtmlobj(popupobj.divid,"cmb_span_optiontext_"+childependfield).val("");
                if(popupobj.type=='detailviewpage')
                {
                    //查看界面
                    ld("#dtlview_"+childependfield).html("");
                    
                }
            }
            if(popupobj.picklistobjarray[childependfield]!=undefined)
            {

                var tmpchildependfield=childependfield;
               for(var j=i;j<popupobj.picklistobjarray[tmpchildependfield].childdependfieldname.length;j++)
               {
                   childependfield=popupobj.picklistobjarray[tmpchildependfield].childdependfieldname[j];
                   //duan 20230625 判断级联字段修改后，下级字段的值是否在可选下拉框中，如果有则不需要清空下级字段
                   if(that.NecessarytoClearChildfield(popupobj,tmpchildependfield,'',childependfield) == 'yes'){
                       that.clearchilddependfieldcontent(childependfield,j)
                   }
               }
            }
           
          //  }
           // else
               // break;
           
         //} 
   }
    this.liclick=function(event){
        var popupobj=undefined;
    	var selectedText=event.data.selectedText;
        var selectedValue=event.data.selectedValue;
        var selectedColor=event.data.selectedColor;

        popupobj=CrmPopup.getPopupObj("last");
        var divid=popupobj.divid;
        that.beforevalue=CrmPopup.getHtmlobjval(divid,that.fieldname);//获取修改前的值，回款计划：先用小编辑按钮编辑“状态”字段然后关闭弹出框，再用小编辑按钮编辑其他的字段时仍会弹出该提示信息 
        //产品分录不为空时，改变报价单类型需提示用户改变报价单类型会清空产品分录信息
        if(account_version=='haige' && that.fieldname=='quotetype' && popupobj.module == 'Quotes'){
            if(that.beforevalue!=selectedText){
                var tmptrobjs=popupobj.getTrObjsByDelType("no");
                if(ld(tmptrobjs).length>1||ld(tmptrobjs).eq(0).find(' input[name=hdnProductId]').val()!=''){
                    var HaigechangeQuotetype= confirm(arrJsPopLabel['CHANGEQUOTECLEARPRODUCTINFOCONTINUE']);
                    if(HaigechangeQuotetype==true){
                        //点击确定时清空产品分录
                        popupobj.changequotetype = 'yes';   //改变报价单类型时清空全部分录，调用原清空方法不使用海格清空方法。
                        fun_selectproduct.emptyproductrow();
                        popupobj.changequotetype = 'no'; 
                    }
                    else{
                        return false;
                    }
                }
                
            }
            
        }
        if(selectedText!=CrmPopup.getHtmlobjval(divid,that.fieldname)&&that.childdependfieldname!="")
        {
        
          
			for(var i = 0; i< that.childdependfieldname.length; i++){
			 
				if(CrmPopup.isExistsObj(divid,that.childdependfieldname[i]))
				{
				    //duan 20230625 判断级联字段修改后，下级字段的值是否在可选下拉框中，如果有则不需要清空下级字段
				    if(that.NecessarytoClearChildfield(popupobj,that.fieldname,selectedText,that.childdependfieldname[i])  == 'yes'){
                        that.clearchilddependfieldcontent(that.childdependfieldname[i],0);
                    }
				}
			}
            
        }
        var objoption=CrmPopup.findHtmlobj(divid,that.fieldname);
		objoption.val(selectedValue);//保存 用到的隐藏域
        objoption.trigger('change');



        //this.setSelectOptionText(objoption,selectedText);
        var usersApprovestatus=ld("#approvestatus").attr("key");//Liver 20161223，bug0024252: 控制面板>用户管理：审批委托选择启用，增加提示信息【审批委托启用时，审批单据将不会流转到该用户，直接流转到审批委托人，是否继续？】
            //029246: 用户管理：审批委托选择“停用”时，不应该弹出提示信息。
        if(usersApprovestatus != undefined && usersApprovestatus=='users' && objoption[objoption.selectedIndex].text=='启用'){
            if(!confirm(arrJsPopLabel['USERAPPROVESREMINDS'])){
				CrmPopup.findHtmlobj(divid,"cmb_a_"+that.fieldname).attr("class","");
				CrmPopup.findHtmlobj(divid,"cmb_a_"+that.fieldname).attr("class",'chzn-single');

				CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_'+that.fieldname).val(objoption.val());
				CrmPopup.findHtmlobj(divid,'dv_drop_'+that.fieldname).css("left","-9000px");//隐藏下拉框
                    
                return false;
            }
        }
         
         if( popupobj!=undefined&&popupobj.type!=MassEditPopup.type)
         {
             setCodeNumPrefix(that.fieldname,objoption.val(),'actions');//设置编号
         }
       
        CrmPopup.findHtmlobj(divid,"cmb_a_"+that.fieldname).attr("class","");
        CrmPopup.findHtmlobj(divid,"cmb_a_"+that.fieldname).attr("class",'chzn-single');
		CrmPopup.findHtmlobj(divid,"cmb_span_optiontext_"+that.fieldname).attr('cur_input_select',"no");
        CrmPopup.findHtmlobj(divid,'cmb_span_optiontext_'+that.fieldname).val(selectedText).css('color',selectedColor);
        CrmPopup.findHtmlobj(divid,'dv_drop_'+that.fieldname).css("left","-9000px");//隐藏下拉框
        //布局规则，是否重新加载界面
        if(popupobj.fieldruleobj!=undefined)
        {
              popupobj.fieldruleobj.reloadfieldname=that.fieldname;
      
            popupobj.fieldruleobj.CheckReLoadPopup();//布局规则

        }
        //edit:can 20231120 BUG0075779 省销售目标模块中，业绩目标字段设置的sql查询，但在该模块中，不生效。详见重现步骤。
        if(popupobj.mainfieldformulaobj!=undefined){
            popupobj.mainfieldformulaobj.setvaluebyformula(that.fieldname);
            popupobj.mainfieldformulaobj.hadcomputerfieldnames=[];
        }
        //小编辑布局规则
        if(popupobj.minifieldruleobj != undefined){
            popupobj.minifieldruleobj.reloadfieldname = that.fieldname;
            popupobj.minifieldruleobj.CheckReLoadPopup();//布局规则
        }

        if(account_version=='langjie'&&popupobj.module=='CustomForm23'&&that.fieldname=='carriage_type')
        {
            //客服下单->运输订单->选择车型之后表体根据“车型”自动带出“报价单”中单据分录是对应车型的“分录信息”
            //客服下单--运输订单中，不管新增，还是复制功能里面，选择“车型”或“形态”时，分录不带数据
            //getlangjieSalesOrderInfoByCarType();
        }
       
       if(popupobj.type=='masseditpopup')
       {
        //edit:can 049721: （https://81mis.com/kfbcrm [^]）（刘总所提问题） 在批量编辑单据时（以产品模块为例），选择了需要批量编辑的下拉框值，前方的复选框不会自动勾选，容易导致误操作
            var checkbox = document.getElementById(that.fieldname + '_mass_edit_check');
         
			if(checkbox) checkbox.checked = true;
       }
        if(account_version=='langjie'&&that.fieldname=='storage_port'&&(popupobj.module=='CustomForm18'||popupobj.module=='CustomForm19')){
            //应收费用单，选择port下拉框
          
            var tableobj=ld("#"+divid+" [name="+popupobj.js_detailtablename+"]");
            var trobjs=ld(tableobj).find("[detaildeleted=no]");
            ld.each(ld(trobjs),function(){
                
                var rowindex=ld(this).attr("rowindex");
               
                 deleteRow(rowindex);
            })
            if(popupobj.module=='CustomForm19')
                setLangJieRelateFieldValueCustomForm19('commission_id','Commission');
            else
                setLangJieRelateFieldValue('commission_id','Commission');
        }

        //@edit:liushuai,2020-8-12,reason:【ID1001000】（王耀文的客户）个性化开发
        if(account_version == 'haochen' && popupobj.module == 'Accounts'&&that.fieldname=='cf_2738'){
            var accountname = CrmPopup.getHtmlobjval(popupobj.divid,'accountname');
            var account_product_line = CrmPopup.getHtmlobjval(popupobj.divid,'cf_2738');//客户产品线
            ld("#"+popupobj.divid+" [name=cf_2787]").val(trim(accountname)+trim(account_product_line));//客户全称(产品)
            if(ld("#"+popupobj.divid+" [name=span_cf_2787]").length>0)
                ld("#"+popupobj.divid+" [name=span_cf_2787]").html(trim(accountname)+trim(account_product_line));
        }
		//chj 2022/9/20 中德信用额度控制下单(2)_1663310360000_576
		if(account_version == 'zhongde' && popupobj.module == 'SalesOrder'&&that.fieldname=='cf_5152'){
			 var account_id = CrmPopup.getHtmlobjval(popupobj.divid,'account_id');
			 var cf_5153 = CrmPopup.getHtmlobjval(popupobj.divid,'cf_5153');
			 var assigned_user_id = CrmPopup.getHtmlobjval(popupobj.divid,'assigned_user_id');
			 if(empty(selectedValue)){
				ld("#"+popupobj.divid+" [name=cf_5150]").val('');
				ld("#"+popupobj.divid+" [name=span_cf_5150]").html('');
				ld("#"+popupobj.divid+" [name=cf_5154]").val('');
				ld("#"+popupobj.divid+" [name=span_cf_5154]").html('');
			 }else{
				getZhongDe_AccountOrgForKis(selectedValue,account_id,cf_5153,assigned_user_id);	
			 }
		}
		


    };
   /*this.setSelectOptionText=function(obj,selectedText)
   {
       obj.val(selectedText);//保存 用到的隐藏域
   }*/
    this.setparentDependField=function(parentdependfieldname){
        if(that.popupobj!=undefined)
        {
            //edit:can 20210728 047151: （https://81mis.com/kfbcrm [^]）启用服务合同新增保存后立即创建收款计划参数，进入客户单据查看详情保持不动，点击相关信息->服务合同下方浮显的新建按钮保存后，取消收款计划新建弹窗，再点击客户相关信息其他模块时点不动
            var popupobj=that.popupobj;
        }
        else
        var popupobj=CrmPopup.getPopupObj("last");
       
        for(var k=0;k<popupobj.fields.length;k++)
        {
             if(popupobj.fields[k].fieldname==parentdependfieldname)
             {
                that.parentdependfieldlabel=popupobj.fields[k].fieldlabel;
                break;
             }        
        }
        
        that.parentdependfieldname=parentdependfieldname;
    }
    this.setchildDependField=function(childdependfieldname)
    {
       
        that.childdependfieldname.push(childdependfieldname);
    }
    /*
    * duan 20230625 判断上级字段发生变化后，下级字段的值是否在新的下拉框选项中
    * parent_fieldname:上级字段fieldname
    * parent_field_value:上级字段值
    * child_fieldname：下级字段fieldname
    * */
    this.NecessarytoClearChildfield = function(popupobj,parent_fieldname,parent_field_value,child_fieldname){
        var picklistdepency = popupobj.picklistdepency;
        var divid = popupobj.divid;
        if(empty(parent_field_value)){
            var parent_value = CrmPopup.getHtmlobjval(divid,parent_fieldname);
        }else{
            var parent_value = parent_field_value;
        }
        var child_value = CrmPopup.getHtmlobjval(divid,child_fieldname);
        var Necessary = 'yes';
        if(!empty(parent_value) && !empty(child_value)){
            //判断上级字段发生变化后，下级字段的值是否在新的下拉框中
            if(!empty(picklistdepency[parent_fieldname]) && !empty(picklistdepency[parent_fieldname][parent_value])){
                var tmp_value_arr = picklistdepency[parent_fieldname][parent_value][child_fieldname];
                if(!empty(tmp_value_arr) && tmp_value_arr.includes(child_value)){
                    Necessary = 'no';
                }
            }
        }
        return Necessary;
    }

}


//edit:duan date:2024/10/24 reason:职位级别对应部门特殊下拉框
//fieldname:当前字段
function show_related_picklist(fieldname) {
    event.stopPropagation();
    var popupobj = CrmPopup.getPopupObj('last');
    var divid = popupobj.divid;
    var from_valueinfo = [];
    //from_fieldname:被关联字段
    var field_obj = ld('#'+divid+' #jsonvalue_'+fieldname);
    if(field_obj.length <= 0)return '';

    var from_fieldname = field_obj.attr('from_fieldname');
    if(from_fieldname == 'groupid'){
        if(popupobj.cur_groupinfo != undefined){
            from_valueinfo = popupobj.cur_groupinfo;
        }else{
            //异常处理,从页面上读值,正常都是从后台返回的,这样做不太好
            var groupid_str = ld('#'+divid+' #'+from_fieldname).val();
            var groupname_str = ld('#'+divid+' #'+from_fieldname).val();
            if(!empty(groupid_str)){
                var groupid_arr = groupid_str.split(',');
                var groupname_arr = groupname_str.split(',');
                for (var i = 0;i < groupid_arr.length; i++){
                    from_valueinfo.push({'id':groupid_arr[i],'name':groupname_arr[i]});
                }
                popupobj.cur_groupinfo = from_valueinfo;
            }
        }
    }
    if(empty(from_valueinfo) || from_valueinfo.length == '0'){
        MessagePopup.TipOne_warning(arrJsPopLabel['Pleaseselectatleastonedepartment']);
        return false;
    }
    var show_dvobj = ld('#'+divid+' #dv_'+fieldname);
    if(show_dvobj.css('display') != 'none'){
        show_dvobj.hide();
        show_related_picklist_content(fieldname,'yes');
        return false;
    }
    var field_value = ld('#'+divid+' #jsonvalue_'+fieldname).val();
    var valuebyid_arr = {};
    if(!empty(field_value)){
        var value_arr = JSON.parse(field_value);
        for(var j = 0;j < value_arr.length;j++){
            valuebyid_arr[value_arr[j]['id']] = value_arr[j]['value'];
        }
    }

    var optionvalue = [];
    for(var k=0;k<popupobj.picklistcontent.length;k++)
    {
        if(popupobj.picklistcontent[k].fieldname==fieldname)
        {
            optionvalue=popupobj.picklistcontent[k].optionvalue;
            break;
        }
    }
    var defualt_value = '';
    var fields = popupobj.fields;
    if(!empty(fields) && fields.length >0){
        for(var k = 0;k < fields.length ; k++){
            if(fields[k]['fieldname'] == fieldname && !empty(fields[k]['defaultvalue'])){
                defualt_value = fields[k]['defaultvalue'];
            }
        }
    }

    var select_content = '';
    var show_content = '';
    var select_name = 'select_'+fieldname;
    show_content += '<table class="userlevel-showtable" >';
    var tmp_arr = {};
    var tmp_content = '';
    var tmp_class = '';
    var tmp_id = 0;
    var tmp_value = '';

    for(var i = 0;i < from_valueinfo.length;i++){
        tmp_content = '';
        tmp_arr = from_valueinfo[i];
        tmp_id = tmp_arr['id'];


        if(valuebyid_arr[tmp_id] != undefined){
            tmp_value = valuebyid_arr[tmp_id];
        }else{
            tmp_value = defualt_value;
        }

        if(i%2 == 1){
            tmp_class = 'lvtColDataBj';
        }else{
            tmp_class = 'lvtColData';
        }
        tmp_content += '<tr  from_id="'+tmp_id+'" class="'+tmp_class+'" >';
        //部门名称
        tmp_content += '<td style="width: 50%;" class="bgnone" ><span name="span_zhlabel" >'+tmp_arr['name']+'</span></td>';
        //职位级别
        tmp_content += '<td class="bgnone"  >';

        select_content = '';
        for(var k=0;k<optionvalue.length;k++)
        {
            select_content += '<option value="'+optionvalue[k][0]+'" '+(tmp_value==optionvalue[k][1]?'selected':'')+'  >'+optionvalue[k][1]+'</option>';
        }

        tmp_content += '<select onchange="related_picklist_changefun(\''+fieldname+'\')" name="'+select_name+'_'+i+'" >'+select_content+'</select>';


        tmp_content += '</td>';
        tmp_content += '</tr>';

        show_content += tmp_content;
    }
    show_content += '</table>';

    show_dvobj.html(show_content);


    if(popupobj.pagetype == 'ListEditPagePopup'){
        var show_contentobj = ld('#'+divid+' #cmb_a_'+fieldname);
        var offset_left = show_contentobj.offset().left;
        show_dvobj.css('width',show_contentobj.innerWidth());
        show_dvobj.css('position','fixed');
        show_dvobj.css('left',offset_left);
    }
    show_dvobj.show();
    //show_dvobj.focus();


    var width = show_dvobj.width();
    var trobjs = show_dvobj.find('tr');
    ld.each(trobjs,function (tmp_index,tmp_trobj) {
        var entityobj = ld(tmp_trobj).find('[name='+select_name+'_'+tmp_index+']')
        var cls_resetComboxHtmlobj=new cls_resetComboxHtml(select_name+'_'+tmp_index);
        cls_resetComboxHtmlobj.setPopupObj(popupobj);
        cls_resetComboxHtmlobj.setHaveRelated('no');
        cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(entityobj,width/2+10);
    })

}
//选择职位级别后更新字段值
function related_picklist_changefun(fieldname) {
    var popupobj = CrmPopup.getPopupObj('last');
    var divid = popupobj.divid;
    var show_dvobj = ld('#'+divid+' #dv_'+fieldname);
    var from_fieldname = ld('#'+divid+' #jsonvalue_'+fieldname).attr('from_fieldname');
    var trobjs = show_dvobj.find('tr');
    var select_name = 'select_'+fieldname;
    var value_arr = [];
    ld.each(trobjs,function (tmp_index,tmp_trobj) {
        var tmp_value = ld(tmp_trobj).find('[name='+select_name+'_'+tmp_index+']').val();

        var tmp_arr = {'id':ld(tmp_trobj).attr('from_id'),'value':tmp_value};
        value_arr.push(tmp_arr);
    })
    var value_str = JSON.stringify(value_arr);
    ld('#'+divid+' #jsonvalue_'+fieldname).val(value_str);
    //显示选择的职位级别内容
    show_related_picklist_content(fieldname,'no');
}
//edit:duan date:2024/12/9 reason:check_rule 判断是否需要执行关联带出和布局规则
function show_related_picklist_content(fieldname,check_rule) {
    var popupobj = CrmPopup.getPopupObj('last');
    var divid = popupobj.divid;
    var field_value = ld('#'+divid+' #jsonvalue_'+fieldname).val();
    if(!empty(field_value)){
        var value_arr = JSON.parse(field_value);
    }else{
        var value_arr = [];
    }
    var from_fieldname = ld('#'+divid+' #jsonvalue_'+fieldname).attr('from_fieldname');
    var from_valueinfo = [];
    if(from_fieldname == 'groupid'){
        from_valueinfo = popupobj.cur_groupinfo;
    }
    var defualt_value = '';
    var fields = popupobj.fields;
    if(!empty(fields) && fields.length >0){
        for(var k = 0;k < fields.length ; k++){
            if(fields[k]['fieldname'] == fieldname && !empty(fields[k]['defaultvalue'])){
                defualt_value = fields[k]['defaultvalue'];
            }
        }
    }
    var valuebyid_arr = {};
    if(!empty(field_value)){
        for(var j = 0;j < value_arr.length;j++){
            valuebyid_arr[value_arr[j]['id']] = value_arr[j]['value'];
        }
    }

    var optionvalue = [];
    if(!empty(popupobj.picklistcontent)){
        for(var k=0;k<popupobj.picklistcontent.length;k++)
        {
            if(popupobj.picklistcontent[k].fieldname==fieldname)
            {
                optionvalue=popupobj.picklistcontent[k].optionvalue;
                break;
            }
        }
    }
    var picklist_value_arr = [];
    for(var k=0;k<optionvalue.length;k++)
    {
        picklist_value_arr.push(optionvalue[k][0]);
    }

    var html_content = '';
    var all_value = '';
    var tmp_value = '';
    var tmp_id = 0;
    for(var i = 0;i < from_valueinfo.length;i++){
        tmp_id = from_valueinfo[i]['id'];
        if(valuebyid_arr[tmp_id] != undefined){
            tmp_value = valuebyid_arr[tmp_id];
            if(!picklist_value_arr.includes(tmp_value)){
                tmp_value = '';
            }
        }else{
            tmp_value = defualt_value;
            if(!picklist_value_arr.includes(tmp_value)){
                tmp_value = '';
            }
            value_arr.push({'id':tmp_id,'value':tmp_value});
        }
        if(empty(tmp_value))continue;
        if(!empty(all_value)){
            all_value += ','+tmp_value;
        }else{
            all_value = tmp_value;
        }

        html_content += '<li class="ld-input-inner-div-item userlevel-fontstyle" >\n' +
            '<span class="item-name">'+from_valueinfo[i]['name']+'</span><span class="item-name">:'+tmp_value+'</span>' +
            '<span class="remove-h" onclick="cancel_related_picklist(\''+fieldname+'\',\''+from_valueinfo[i]['id']+'\')">×</span>\n' +
            '</li>';
    }
    var value_str = JSON.stringify(value_arr);
    ld('#'+divid+' #jsonvalue_'+fieldname).val(value_str);
    ld('#'+divid+' #'+fieldname).val(all_value);
    ld('#'+divid+' #cmb_ul_'+fieldname).html(html_content);
    //edit:duan date:2024/12/9 reason:check_rule 判断是否需要执行关联带出和布局规则
    if(check_rule == 'yes'){
        setTimeout(function () {
            getJsScript('include/js/relatedfield.js',function(){
                getRelatedFieldData(popupobj.module,all_value,'',fieldname,popupobj.module,'select');
            });
        },50);
    }
}
//删除按钮
function cancel_related_picklist(fieldname,from_id) {
    event.stopPropagation();
    var popupobj = CrmPopup.getPopupObj('last');
    var divid = popupobj.divid;
    var field_value = ld('#'+divid+' #jsonvalue_'+fieldname).val();
    var show_dvobj = ld('#'+divid+' #dv_'+fieldname);
    var value_arr = JSON.parse(field_value);
    var trobj = show_dvobj.find('tr[from_id='+from_id+']');

    for(var j = 0;j < value_arr.length;j++){
        if(from_id == value_arr[j]['id'] ){
            value_arr[j]['value'] = '';
            trobj.find('[name=select_'+fieldname+'_'+j+']').val('');
            trobj.find('#cmb_span_optiontext_select_'+fieldname+'_'+j).val('');
        }
    }

    var value_str = JSON.stringify(value_arr);
    ld('#'+divid+' #jsonvalue_'+fieldname).val(value_str);
    //显示选择的职位级别内容
    show_related_picklist_content(fieldname,'yes');
}
//修改下拉框选项
function changed_related_picklist(fieldname,changedcombox){
    var popupobj = CrmPopup.getPopupObj('last');
    var divid = popupobj.divid;
    var show_dvobj = ld('#'+divid+' #dv_'+fieldname);
    if(show_dvobj.css('display') != 'none'){
        show_dvobj.hide();
    }
    var field_value = ld('#'+divid+' #jsonvalue_'+fieldname).val();
    var value_arr = JSON.parse(field_value);
    for(var i = 0;i<changedcombox.length; i++){
        for(var j = 0;j<value_arr.length; j++){
            if(value_arr[j]['value'] == changedcombox[i]['oldval']){
                value_arr[j]['value'] = changedcombox[i]['value'];
            }
        }
    }
    var value_str = JSON.stringify(value_arr);
    ld('#'+divid+' #jsonvalue_'+fieldname).val(value_str);
    //显示选择的职位级别内容
    show_related_picklist_content(fieldname,'yes');
}

