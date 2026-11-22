function cls_validatacondition(){
    this.AdvanceTableParentDivid = 'valiadvance';
    this.popupobj=CrmPopup.getPopupObj('last');
    
    this.advft_column_index_count = -1;
    this.advft_group_index_count = 0;
    
    this.column_index_array = [];
    this.group_index_array = [];
    this.popupobj.advanceSearchDivid=this.popupobj.divid;
    this.field_arr = [];
    
    var that = this;
    
    var typeofdata = new Array();
    typeofdata['V'] = ['c','e','n','s','ew','k','isnull','isnotnull'];
    typeofdata['N'] = ['e','n','l','g','m','h','isnull','isnotnull'];
    typeofdata['T'] = ['e','n','l','g','m','h','isnull','isnotnull'];
    typeofdata['I'] = ['e','n','l','g','m','h','isnull','isnotnull'];
    typeofdata['C'] = ['e','n'];
    typeofdata['D'] = ['e','n','l','g','m','h','isnull','isnotnull'];
    typeofdata['DT'] = ['e','n','l','g','m','h','isnull','isnotnull'];
    typeofdata['NN'] = ['e','n','l','g','m','h','isnull','isnotnull'];
    typeofdata['E'] = ['c','e','n','s','ew','k','isnull','isnotnull'];
    typeofdata['sql'] = ['c','e','n','l','g','m','h','s','ew','k','isnull','isnotnull'];
    typeofdata['empty'] = [];
    
    this.New_updatefOptions=function(sel, opSelName) {
      
        var popupobj = this.popupobj;
        var selObj =ld("#"+popupobj.advanceSearchDivid+" [name="+opSelName+"]").get(0);// document.getElementById(opSelName);
        var fieldtype = null ;
        //获取字段信息
        var fieldsinfo = [];
        fieldsinfo = this.field_arr;
        if(selObj==undefined ||selObj==null ||sel==undefined || sel==null)
        {
            return;
        }
        
        var currOption = selObj.options[selObj.selectedIndex];
        var selectoption = ld(sel).find('option:selected');
        if(selectoption.length >0){
            var colinfo = selectoption.data('colinfo');
            if(empty(colinfo))colinfo = '';
        }else{
            var colinfo = '';
        }
        
        var tag = ld(sel).attr('tag');
        var fieldvalue = ld(sel).val();
        
        if(!empty(colinfo)||(!empty(tag) && tag == 'fieldtype')) {
            if(!empty(colinfo)){
                var string_array = colinfo.split(":");
                fieldtype = string_array[4];
            }else{
                switch(fieldvalue){
                    case 'fields':fieldtype = 'empty';break;
                    case 'text':fieldtype = 'V';break;
                    case 'number':fieldtype = 'N';break;
                    case 'date':fieldtype = 'D';break;
                    case 'datetime':fieldtype = 'DT';break;
                    case 'sql':fieldtype = 'sql';break;
                    default:fieldtype = 'V';break;
                }
            }
    		ops = typeofdata[fieldtype];
            
    		var off = 0;
    		if(ops != null) {
    			var nMaxVal = selObj.length;
    			for(nLoop = 0; nLoop < nMaxVal; nLoop++) {
    				selObj.remove(0);
    			}
    			selObj.options[0] = new Option (jsnone, 'none');
    			if (empty(colinfo)) {
    				selObj.options[0].selected = true;
    			}
    			off = 1;
                var k=0;
                
    			for (var i = 0; i < ops.length; i++) {
    				var label = fLabels[ops[i]];
                   
    				if (label == null) continue;
                   
                    if(colinfo.indexOf('publicaccount:publicaccount:Accounts')>0||colinfo.indexOf('currency_id')>0)//客户模块中是否公海字段
                    {
                         if(ops[i]!='e'&& ops[i]!='n')
                         {
                            continue;
                         }
                    }
                    if(colinfo.indexOf('content:content:PublicAnnouncement')>0)//客户模块中是否公海字段
                    {
                         if(ops[i]!='c')
                         {
                            continue;
                         }
                    }
                    if(colinfo.indexOf("conversion_rate")>0)
                    {
                         
                         if(ops[i]=='isnull'|| ops[i]=='isnotnull')
                         {
                            continue;
                         }
                    }
                    
    				var option = new Option (fLabels[ops[i]], ops[i]);
    				selObj.options[k + off] = option;
                    k++;
    				if (currOption != null && currOption.value == option.value) {
    					option.selected = true;
    				}
    			}
               
                //36087: 单据列表界面>高级查找弹出层>选择时间字段：区间字段默认放在第二。（所有的帐套都要更改）
                if(fieldtype=='D'||fieldtype=='DT')
                {
                    if(datetimestr!=undefined){
                        var resultobj=datetimestr;
                        ld.each(datetimestr,function(value,resultobj){
                            var option = new Option (resultobj[2], value);
                            selObj.options[k + off] = option;
                            k++;             
                        });
                    }
                }
                //zkt 20220519 【ID1002788】【管理分类设置条件，高级查找、平铺查找，查询字段选择“单选用户”字段时，选择条件增加“为当前用户”选项（徐煜轩）】
                if(fieldsinfo.length>0 && (empty(tag) || tag != 'fieldtype')){
                //判断字段类型，若为用户字段类型则条件下拉框增加当前用户
                    var string_array = colinfo.split(":");
                    var fieldname = string_array[2];
                    var tablename = string_array[0];
                    ld.each(fieldsinfo,function(index){
                        var fieldinfo = fieldsinfo[index];
                        if(fieldinfo['fieldName']==fieldname){
                            if(global_user_uitype_arr.indexOf(fieldinfo['uitype'])>-1){
                                if(global_multiuser_uitype_arr.indexOf(fieldinfo['uitype'])>-1){
                                    var option = new Option (fLabels['includeuser'], 'curuser');
                                    selObj.options[k + off] = option;
                                    k++;
                                }
                                else{
                                    var option = new Option (fLabels['curuser'], 'curuser');
                                    selObj.options[k + off] = option;
                                    k++;
                                }

                            }
                        }
                    })
                }
                //edit:can 57183  在服务合同的产品分录，点击产品的+号，在查找的界面的高级查找的条件默认改为包含 
                if(selObj.selectedIndex==0 && selObj.options.length>1)
                    selObj.selectedIndex=1;
    		}
        } else {
    		if (colinfo == '') {
    			selObj.options[0].selected = true;
    		}
        }
        ld(selObj).change();
    }
    
    this.New_showHideDivs=function(showdiv, hidediv){
        var popupobj = this.popupobj;
        
    	if(ld("#"+popupobj.advanceSearchDivid+" [name="+showdiv+"]").length>0) 
    		ld("#"+popupobj.advanceSearchDivid+" [name="+showdiv+"]").get(0).style.display = "block";
    	
    	if(ld("#"+popupobj.advanceSearchDivid+" [name="+hidediv+"]").length>0) 
    		ld("#"+popupobj.advanceSearchDivid+" [name="+hidediv+"]").get(0).style.display = "none";
    }
    this.New_hideAllElementsByName=function(name){
         var popupobj = this.popupobj;
    	var allElements = document.getElementsByTagName('div');
    	for(var i=0; i<allElements.length; ++i) {
    		var element = allElements[i];
    		if (element.getAttribute('name') == name)
    			element.style.display='none';
    	}
        puyoungJS_DialogBox.unblock();
    	return true;
    }
    this.New_removeElement=function(elementId){
        var popupobj = this.popupobj;
    
    	var element = ld("#"+popupobj.advanceSearchDivid+" [name="+elementId+"]");
        
    	if(element!=undefined&&element.length>0) {
    	   //element=element.get(0);
    		var parent = element.parent().get(0);
    		if(parent) {
    			parent.removeChild(element.get(0));
    		} else {
    			element.get(0).remove();
    		}
    	}
    }
    this.New_deleteGroup=function(groupIndex){
        var popupobj = this.popupobj;
        
    	that.New_removeElement('conditiongroup_'+groupIndex);
    	
    	var keyOfTheGroup = that.group_index_array.indexOf(groupIndex);
    	var isLastElement = true;
    	//var popupobj=CrmPopup.getPopupObj('last');
    	for(var i=keyOfTheGroup; i<that.group_index_array.length; ++i) {
    		var nextGroupIndex = that.group_index_array[i];
    		var nextGroupBlockId = "conditiongroup_"+nextGroupIndex;
            var tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name="+nextGroupBlockId+"]");//ls 20220812 BUG0054697客户详情页，相关信息-联系人，点击高级查找，添加组合条件再删除后，对应的且或没有删除
            
    		if(tmpobj!=undefined&&tmpobj.length>0) {
    			isLastElement = false;
    			break;
    		}
    	}
    	
    	
    	if(isLastElement) {
    		for(var i=keyOfTheGroup-1; i>=0; --i) {
    			var prevGroupIndex = that.group_index_array[i];
    			var prevGroupGlueId = "gpcon"+prevGroupIndex;
                var tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name="+prevGroupGlueId+"]");
    			if(tmpobj!=undefined&&tmpobj.length>0) {
    				that.New_removeElement(prevGroupGlueId);
    				break;
    			}
    		}
    	}	
    }
    this.New_addNewConditionGroup = function(){
       
        var popupobj = this.popupobj;
    	that.New_addConditionGroup();	
    	that.New_addConditionRow(that.advft_group_index_count,'create');
    }
    this.New_deleteColumnRow=function(groupIndex, columnIndex) {
        var popupobj = that.popupobj;
    	removeElement('conditioncolumn_'+groupIndex+'_'+columnIndex);
    	var groupColumns = that.column_index_array[groupIndex];
    	var keyOfTheColumn = groupColumns.indexOf(columnIndex);
    	var isLastElement = true;
    	
    	for(var i=keyOfTheColumn; i<groupColumns.length; ++i) {
    		var nextColumnIndex = groupColumns[i];
    		var nextColumnRowId = 'conditioncolumn_'+groupIndex+'_'+nextColumnIndex;
            var tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name="+nextColumnRowId+"]");
            
    		if(tmpobj!=undefined&&tmpobj.length>0) {
    			isLastElement = false;
    			if(ld("#"+popupobj.advanceSearchDivid+" select[name^='fcon']").length < 1){
    				ld('#advfiltershow').css('display','none');
    			}
    			break;
    		}
    	}
    	if(isLastElement) {
    		for(var i=keyOfTheColumn-1; i>=0; --i) {
    			var prevColumnIndex = groupColumns[i];
    			var prevColumnGlueId = "fcon"+prevColumnIndex;
                 var tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name="+prevColumnGlueId+"]");
    			if(tmpobj!=undefined&&tmpobj.length>0) {
    				that.New_removeElement(prevColumnGlueId);
    				if(ld("#"+popupobj.advanceSearchDivid+" select[name^='fcon']").length < 1){
    					ld('#advfiltershow').css('display','none');
    				}
    				break;
    			}
    		}
    	}
        //ld("#conditiongrouptable_"+groupIndex+" .deleteauto").click();
       // alert(ld("#conditiongrouptable_"+groupIndex+" tr").length);
       //高级查询>添加新组合：填写数据，当第一行的内容删除时第一行下面的下拉框中的内容也清除。
       
       if(ld("#"+popupobj.advanceSearchDivid+" [name=conditiongrouptable_"+groupIndex+"] tr").length<=2)
            that.New_deleteGroup(groupIndex);
    }
    this.New_addRequiredElements=function(columnindex){
        var popupobj = this.popupobj;
        
    	var colObj =ld("#"+popupobj.advanceSearchDivid+" [name=fcol"+columnindex+"]").get(0);// document.getElementById('fcol'+columnindex);
    	var opObj = ld("#"+popupobj.advanceSearchDivid+" [name=fop"+columnindex+"]").get(0);// document.getElementById('fop'+columnindex);
        var valObj =ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").get(0);// document.getElementById('fval'+columnindex);
        if(colObj==undefined ||colObj==null ||opObj==undefined || opObj==null)
         {
             return;
         }
      if(colObj.selectedIndex<0 ||opObj.selectedIndex<0 )
      {
        return ;
      }
    	var currField = colObj.options[colObj.selectedIndex];
        var currOp = opObj.options[opObj.selectedIndex];
       
        var fieldtype = null ;
        if(currField.value != null && currField.value.length != 0) {
    		var fieldInfo = currField.value.split(":");
    		var tableName = fieldInfo[0];
    		var fieldName = fieldInfo[2];
    		fieldtype = fieldInfo[4];
    		//如果选择的是不日期和时间移除日期显示格式
            if(fieldtype!='D'&&fieldtype!='DT'&&fieldtype!='T'){
                
                var parentObj = valObj.parentNode;
                //edit:can 14275: 所有模块-列表：高级查询，错误。;
                var childs=parentObj.childNodes;    
                for(var i=childs.length-1;i>=0;i--)
                {    
                        parentObj.removeChild(childs.item(i));    
                }  
               
               	var node5 = document.createElement('input');
            	node5.setAttribute('type', 'text');
            	node5.setAttribute('class', 'width150 commonTextBoxPop');
            	node5.setAttribute('style', 'width:138px');
            	node5.setAttribute('id','fval'+columnindex);
            	node5.setAttribute('name','fval'+columnindex);
                //18763: 常用报表>销售预测分析表：转到高级查询，录入查找关键字后，按键盘上的Enter键，结果：页面跳转到了首页。
                node5.onkeypress=function(event){
                    var e=event||window.event;
                  var prevpopupobj=CrmPopup.getPopupObj('lastprev');
                    if(e.keyCode==13)
                    {
                        
                         if(prevpopupobj.type==RelateListPage.type)
                            {
                                //相关信息查询
                                DetailViewRelation.callSearch();
                            }
                            
                        if(prevpopupobj.module=='OftenUseReport')
                                generateReport(node5);
                        return false;
                    }
                }
                parentObj.appendChild(node5);
    
            }else{
                //直接删除onclick事件，时间和日期切换的时候，控件无法自动切换，先删除橡皮擦，新增个时间或日期输入框，再删除老的输入框
                var tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name=fval_ext"+columnindex+"]");
                if(tmpobj!=undefined&&tmpobj.length>0) 
                    that.New_removeElement('fval_ext'+columnindex);
                tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name=clear_text_ext"+columnindex+"]");
                if(tmpobj!=undefined&&tmpobj.length>0) removeElement('clear_text_ext'+columnindex);
                var timeformat = " %H:%M:%S";
                var showtime = ' HH:mm:ss';
                if(fieldtype == 'D' || (tableName == 'ld_activity' && fieldName == 'date_start')) {
    							timeformat = '';
    							showtime = '';
                }		
            	var node5 = document.createElement('input');
                node5.setAttribute('onClick','WdatePicker({startDate:"%y-%M-%d'+timeformat+'",dateFmt:"yyyy-MM-dd'+showtime+'",alwaysUseStartDate:true})');
            	node5.setAttribute('class', 'Wdate btn-radius-system WdateImage');
            	node5.setAttribute('type', 'text');
            	node5.setAttribute('id','fval'+columnindex);
            	node5.setAttribute('name','fval'+columnindex);
    			node5.setAttribute('style','width:138px;');
                
    			var parentObj = valObj.parentNode;
    			parentObj.appendChild(node5);
                tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]");
                if(tmpobj!=undefined&&tmpobj.length>0)  removeElement('fval'+columnindex);
                     valObj = tmpobj.get(0);
                tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name=clearfval_"+columnindex+"]");
    			 if(tmpobj!=undefined&&tmpobj.length>0) removeElement('clearfval_'+columnindex);
    			
                     
            }     	
    		switch(fieldtype) {
    			case 'D':
    			case 'DT':
    			case 'T':
    				if(fieldtype=='T' && tableName.indexOf('ld_crmentity')<0){
    					that.New_defaultRequiredElements(columnindex);
    					break;
    				}
    				var dateformat = $('jscal_dateformat').value;
    						var timeformat = " %H:%M:%S";
    						var showtime = ' HH:mm:ss';
    						if(fieldtype == 'D' || (tableName == 'ld_activity' && (fieldName == 'date_start' || fieldName == 'due_date'))) {
    							timeformat = '';
    							showtime = '';
    						}						
    						tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name=jscal_trigger_fval"+columnindex+"]");
    						if(tmpobj==undefined||tmpobj.length<=0) { 
    						      
    							var node = ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").get(0);//
    							node.setAttribute('onClick','WdatePicker({startDate:"%y-%M-%d'+timeformat+'",dateFmt:"yyyy-MM-dd'+showtime+'",alwaysUseStartDate:true})');
    							node.setAttribute('class','Wdate btn-radius-system WdateImage');
    							node.setAttribute('style','width:138px;');
    						
    						}
    						
    				      var isexistsdatestr=isExistsDateTimeStr(currOp.value);
                                             
                            if(currOp.value == 'bw'||isexistsdatestr=='yes') {
                            	if(!document.getElementById('fval_ext'+columnindex+"]")) { 
    	                        	//var fillernode = document.createElement('br');
    	                        	
    	                        	var node1 = document.createElement('input');
                                    node1.setAttribute('onClick','WdatePicker({startDate:"%y-%M-%d'+timeformat+'",dateFmt:"yyyy-MM-dd'+showtime+'",alwaysUseStartDate:true})');
    	                        	node1.setAttribute('class', 'Wdate btn-radius-system WdateImage');
    	                        	node1.setAttribute('type', 'text');
    	                        	node1.setAttribute('id','fval_ext'+columnindex);
    	                        	node1.setAttribute('name','fval_ext'+columnindex);
    								node1.setAttribute('style','width:138px;');
    	                        	
    	    					//	var parentObj = valObj.parentNode;
                                    var parentObj=ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").parent().get(0);
                                   
    								//parentObj.appendChild(fillernode);
    								parentObj.appendChild(node1);
    							}
                                var resultobj=datetimestr;
    							 for(var timekey in  datetimestr)
                                {          
                                            
                                            if(timekey==currOp.value){  
                                                    if(fieldtype=='DT')
                                                    {
                                                      
                                                       ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").val(resultobj[timekey][0]+" 00:00:00");
                                                        ld("#"+popupobj.advanceSearchDivid+" [name=fval_ext"+columnindex+"]").val(resultobj[timekey][1]+" 23:59:59");
                                                         
                                                    }
                                                    else
                                                    {
                                                       
                                                         ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").val(resultobj[timekey][0]);
                                                        ld("#"+popupobj.advanceSearchDivid+" [name=fval_ext"+columnindex+"]").val(resultobj[timekey][1]);
                                                    }
                                                      ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").get(0).disabled=true;
                                                     ld("#"+popupobj.advanceSearchDivid+" [name=fval_ext"+columnindex+"]").get(0).disabled=true;
                            					   break;
                                                }                       
                                    }   
                                     
    							if(ld("#"+popupobj.advanceSearchDivid+" [name=jscal_trigger_fval_ext"+columnindex+"]").length>0) {
    								var node =  ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").get(0);//document.getElementById('fval'+columnindex);
    								node.setAttribute('onClick','WdatePicker({startDate:"%y-%M-%d'+timeformat+'",dateFmt:"yyyy-MM-dd'+showtime+'",alwaysUseStartDate:true})');
    								node.setAttribute('class','Wdate btn-radius-system WdateImage');
    								node.setAttribute('style','width:108px;margin-right: 8px;');
    								
    							 }
                                
                           	} else {
                           	    
    							that.New_defaultRequiredElements(columnindex) ;
                           	}              
                            
                            break;
    			default	:that.New_defaultRequiredElements(columnindex); 
    		}
    
    	  if(isexistsdatestr!='yes')
    	  {    
    	     
        	   	var node6 = document.createElement('input');
        		node6.setAttribute('type','button');
        		node6.setAttribute('id','clear_text_ext'+columnindex);
                node6.setAttribute('name','clear_text_ext'+columnindex);
        		node6.setAttribute('class','icon-homeimg icon-clear inpb-advSearchreset marL5');
        		node6.setAttribute('style','display:none;');
        		node6.style.cursor = "pointer";
        		node6.onclick = function() {
        		          var popupobj = that.popupobj;
                          
        			     ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").val('');
                        ld("#"+popupobj.advanceSearchDivid+" [name=fval_ext"+columnindex+"]").val('');            
        			return false;
        		}
        	
        		parentObj.appendChild(node6);
                
    	  }
    	  ld('#'+popupobj.divid+" [name=clear_text_ext"+columnindex+"]").css("display",'');
            if(currOp.value == 'isnull'||currOp.value == 'isnotnull'||currOp.value == 'curuser'){
                ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").val('');
                ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").get(0).setAttribute("readonly",true,0);
            } else{
                ld("#"+popupobj.advanceSearchDivid+" [name=fval"+columnindex+"]").get(0).removeAttribute("readonly");
            }
    	}
    }
    this.New_defaultRequiredElements=function(columnindex){
        var popupobj = that.popupobj;
        
        if(ld("#"+popupobj.advanceSearchDivid+" [name=jscal_trigger_fval"+columnindex+"]").length>0) removeElement('jscal_trigger_fval'+columnindex);
        if(ld("#"+popupobj.advanceSearchDivid+" [name=fval_ext"+columnindex+"]").length>0) removeElement('fval_ext'+columnindex);
        if(ld("#"+popupobj.advanceSearchDivid+" [name=jscal_trigger_fval_ext"+columnindex+"]").length>0) removeElement('jscal_trigger_fval_ext'+columnindex);
        if(ld("#"+popupobj.advanceSearchDivid+" [name=clear_text_ext"+columnindex+"]").length>0) removeElement('clear_text_ext'+columnindex);
                                    
        
    }
    this.New_checkAdvancedFilter=function(){
    	var escapedOptions = new Array('account_id','contactid','contact_id','product_id','parent_id','campaignid','potential_id','assigned_user_id','quote_id','accountname','salesorder_id','vendor_id','time_start','time_end','lastname','accountid');
    	var popupobj = that.popupobj;
    	var conditionColumns = that.New_vt_getElementsByName('tr', "conditionColumn");
    	var criteriaConditions = [];
      
    	for(var i=0;i < conditionColumns.length ; i++) {
    		
    		var columnRowId = conditionColumns[i].getAttribute("id");
    		var columnRowInfo = columnRowId.split("_");
    		var columnGroupId = columnRowInfo[1];
    		var columnIndex = columnRowInfo[2];
            
    		//选择字段类型
            var SelectTypeId = "selecttype"+columnIndex;
            var SelectTypeobj =ld("#"+popupobj.advanceSearchDivid+" #"+SelectTypeId);
    		var SelectTypeValue = trim(SelectTypeobj.val());	
    		var SelectTypeLabel = SelectTypeobj.text();
            
            //选择字段
            var SelectFieldId = "selectfield"+columnIndex;
            var SelectFieldobj =ld("#"+popupobj.advanceSearchDivid+" #"+SelectFieldId);
    		var SelectFieldvalue = trim(SelectFieldobj.val());	
    		var SelectFieldLabel = SelectFieldobj.text();
            
            //比较关系
            var ComparatorTypeId = "comparatortype"+columnIndex;
            var ComparatorTypeobj =ld("#"+popupobj.advanceSearchDivid+" #"+ComparatorTypeId);
    		var ComparatorTypevalue = trim(ComparatorTypeobj.val());	
    		var ComparatorTypeLabel = ComparatorTypeobj.text();
            
            //比较字段类型
            var CompareTypeId = "comparetype"+columnIndex;
            var CompareTypeobj =ld("#"+popupobj.advanceSearchDivid+" #"+CompareTypeId);
    		var CompareTypeValue = trim(CompareTypeobj.val());	
    		var CompareTypeLabel = CompareTypeobj.text();
            
            //比较字段
            var CompareFieldId = "comparefield"+columnIndex;
            var CompareFieldobj =ld("#"+popupobj.advanceSearchDivid+" #"+CompareFieldId);
    		var CompareFieldvalue = trim(CompareFieldobj.val());	
    		var CompareFieldLabel = CompareFieldobj.text();
            
            var extValueId = "fval_ext"+columnIndex;
            if(ld("#"+popupobj.advanceSearchDivid+" #"+extValueId).length >0){
                var extValueObject = ld("#"+popupobj.advanceSearchDivid+" #"+extValueId).get(0);
            }
            
            //组内关系
            var glueConditionId = "fcon"+columnIndex;
    		var glueConditionObj =ld("#"+popupobj.advanceSearchDivid+" [name="+glueConditionId+"]");// getObj(glueConditionId);
    		var glueCondition = '';
    		if(glueConditionObj.length>0) {
    			glueCondition = trim(glueConditionObj.val());
    		}
            
            if(SelectFieldvalue=='' && (CompareFieldvalue =="" || (ComparatorTypevalue != 'isnull' && ComparatorTypevalue != 'isnotnull'&& ComparatorTypevalue != 'curuser')) )
            {
                var confirm_str = arrJsPopLabel['PLEASEENTERKEYWORDTOSEARCH'];
                RemindsMsg("","LdPopWidth400px","","yes","",confirm_str);
                return false;
            }
    		var specifiedValue = SelectFieldvalue;
    		// If only the default row for the condition exists without user selecting any advanced criteria, then skip the validation and return.
    		if(conditionColumns.length == 1 && SelectFieldvalue == '' && ComparatorTypevalue == '' && specifiedValue == '')
    			return true;
            //判断所选字段类型和字段值是否符合
            if(this.checkfieldvalue(SelectFieldId,SelectTypeValue,SelectFieldvalue)){
                return false;
            }
            if(this.checkfieldvalue(CompareFieldId,CompareTypeValue,CompareFieldvalue)){
                return false;
            }
            
            var col = new Array();
            if(SelectFieldobj.find('option:selected').length > 0){
                col = SelectFieldobj.find('option:selected').data('colinfo').split(':');
            }
            /*
            if(col.length > 0){
                if(escapedOptions.indexOf(col[3]) == -1 ) {
    				if(col[4] == 'T' || col[4] == 'DT') {
    					var datime = specifiedValue.split(" ");
    					if (specifiedValue.charAt(0) != "$" && specifiedValue.charAt(specifiedValue.length-1) != "$"){
    						if(datime.length > 1) {
    							if(!re_dateValidate(datime[0],SelectFieldLabel,"OTH")) {
    								return false
    							}
    							if(!re_patternValidate(datime[1],SelectFieldLabel,"TIMESECONDS")) {
    								return false
    							}
    						} else if(col[0] == 'ld_activity' && col[2] == 'date_start') {
    							if(ld('#'+ComparatorTypeId).val() != 'isnull' && ld('#'+ComparatorTypeId).val() != 'isnotnull'){
    								if(!dateValidate(valueId,SelectFieldLabel,"OTH"))
    									return false;
    							}
    						}else if(col[0] == 'ld_activity' && col[2] == 'due_date') {
    							if(ld('#'+ComparatorTypeId).val() != 'isnull' && ld('#'+ComparatorTypeId).val() != 'isnotnull'){
    
    								if(!dateValidate(valueId,SelectFieldLabel,"OTH"))
    									return false;
    							}
    						}else if(ld('#'+ComparatorTypeId).val() != 'isnull' && ld('#'+ComparatorTypeId).val() != 'isnotnull'){
    						
    							if(!re_patternValidate(datime[0],SelectFieldLabel,"TIMESECONDS")) {
    								return false
    							}
    						}
    					}
    
    					if(extValueObject) {
    						var datime = extendedValue.split(" ");
    						if (extendedValue.charAt(0) != "$" && extendedValue.charAt(extendedValue.length-1) != "$"){
    							if(datime.length > 1) {
    								if(!re_dateValidate(datime[0],SelectFieldLabel,"OTH")) {
    									return false
    								}
    								if(!re_patternValidate(datime[1],SelectFieldLabel,"TIMESECONDS")) {
    									return false
    								}
    							} else if(col[0] == 'ld_activity' && col[2] == 'date_start') {
    								if(!dateValidate(extValueId,SelectFieldLabel,"OTH"))
    									return false
    							} else if(col[0] == 'ld_activity' && col[2] == 'due_date') {
    								if(!dateValidate(extValueId,SelectFieldLabel,"OTH"))
    									return false
    							}else {
    								if(ComparatorTypevalue!='isnull'&&!re_patternValidate(datime[0],SelectFieldLabel,"TIMESECONDS")) {
    									return false
    								}
    							}
    						}
    					}
    				}
    				else if(col[4] == 'D')
    				{
    					if (specifiedValue.charAt(0) != "$" && specifiedValue.charAt(specifiedValue.length-1) != "$"&& ld('#'+ComparatorTypeId).val() != 'isnull' && ld('#'+ComparatorTypeId).val() != 'isnotnull'){
    						if(!dateValidate(valueId,SelectFieldLabel,"OTH"))
    							return false
    					}
    					if(extValueObject) {
    						if(!dateValidate(extValueId,SelectFieldLabel,"OTH"))
    							return false
    					}
    				}else if(col[4] == 'I')
    				{
    					if(!intValidate(valueId,SelectFieldLabel+i))
    						return false
    				}else if(col[4] == 'N')
    				{
    					if (!numValidate(valueId,SelectFieldLabel,"any",true))
    						return false
    				}
    			}
                
        		//Added to handle yes or no for checkbox fields in reports advance filters. 
        		if(col[4] == "C") {
        			if(specifiedValue == "1")
        				specifiedValue = getObj(valueId).value = 'yes';
        			else if(specifiedValue =="0")
        				specifiedValue = getObj(valueId).value = 'no';
        		}
            }
			*/
            
    		criteriaConditions[columnIndex] = {"groupid":columnGroupId, 
    											"selecttype":SelectTypeValue,
    											"selectfield":SelectFieldvalue,
    											"comparatortype":ComparatorTypevalue,
    											"comparetype":CompareTypeValue,
                                                "comparefield":CompareFieldvalue,
                                                "columncondition":glueCondition
    										};
    	}
       var prevpopupobj=CrmPopup.getPopupObj('lastprev');
       
        ld("#"+prevpopupobj.divd+" [name=advft_criteria]").val(JSON.stringify(criteriaConditions));
      //  document.getElementById('advft_criteria').value = JSON.stringify(criteriaConditions);
    	//$('advft_criteria').value = JSON.stringify(criteriaConditions);
    	
    	var conditionGroups = that.New_vt_getElementsByName('div', "conditionGroup");
    	var criteriaGroups = [];
       //var popupobj=CrmPopup.getPopupObj('last');
    	for(var i=0;i < conditionGroups.length ; i++) {
    		var groupTableId = conditionGroups[i].getAttribute("id");
    		var groupTableInfo = groupTableId.split("_");
    		var groupIndex = groupTableInfo[1];
    		
    		var groupConditionId = "gpcon"+groupIndex;
    		var groupConditionObject = ld("#"+popupobj.advanceSearchDivid+" [name="+groupConditionId+"]").get(0);
    		var groupCondition = '';
    		if(groupConditionObject) {
    			groupCondition = trim(groupConditionObject.value);
    		}
    		criteriaGroups[groupIndex] = {"groupcondition":groupCondition};
    		
    	}
        popupobj.advft_criteria_groups=JSON.stringify(criteriaGroups);
        popupobj.advft_criteria=JSON.stringify(criteriaConditions);
    	return true;
    }
    
    /**
     * IE has a bug where document.getElementsByName doesnt include result of dynamically created 
     * elements
     */
    this.New_vt_getElementsByName=function(tagName, elementName){
        var popupobj = that.popupobj;
    	var inputs = ld("#"+popupobj.advanceSearchDivid+" "+tagName);
        
    	var selectedElements = [];
       
        ld.each(inputs,function(){
            if(ld(this).attr("tag")==elementName)
            {
                selectedElements.push( ld(this).get(0) );
            }
        });
    
    	return selectedElements;
    }
    this.New_addConditionGroup = function() {
        var parentNodeId = this.AdvanceTableParentDivid
        var popupobj = that.popupobj;
        if(popupobj==undefined)
        {
            return false;
        }
    	for(var i=that.group_index_array.length - 1; i>=0; --i) {
    		var prevGroupIndex = that.group_index_array[i];
            var name='conditiongroup_'+prevGroupIndex;
            var tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name="+name+"]");
    		if(tmpobj.length>0) {
    			that.New_addGroupConditionGlue(prevGroupIndex);
    			break;
    		}
    	}
        
    	var groupIndex = that.advft_group_index_count+1;
        var hidegroup='{$HideGroup}';
        
    	var parentNode =ld("#"+popupobj.advanceSearchDivid+" [name="+parentNodeId+"]").get(0);
        
            if(parentNode==undefined)
            {
                return;
            }
    	var newNode = document.createElement('div');
    	newNodeId = 'conditiongroup_'+groupIndex;
      	newNode.setAttribute('id',newNodeId);
        newNode.setAttribute('name',newNodeId);
      	newNode.setAttribute('tag','conditionGroup');
    
      	//newNode.innerHTML = "<table class='crmTable' border='0' cellpadding='5' cellspacing='1' width='100%' valign='top' id='conditiongrouptable_"+groupIndex+"'>"+
        newNode.innerHTML = "<table class='settingPopTable lasttdbordernon' border='0' cellpadding='0' cellspacing='0' width='100%' name='conditiongrouptable_"+groupIndex+"'>"+
    							"<tr name='groupheader_"+groupIndex+"'>"+
    							"<td colspan='7' style='height:18px;' align='right'>"+
    							"<a class='icon-homeimg icon-close' href='javascript:void(0);' title='删除组合' onclick='cls_validatacondition.getInstance().New_deleteGroup(\""+groupIndex+"\");'></a>"+			
    							"</td>"+			
    							"</tr>"+
    							"<tr name='groupfooter_"+groupIndex+"'>"+
                                    "<td colspan='7' align='left' class='padTB5'>"+
                                    "<a style='margin-left: 10px;' href='javascript:void(0);' onclick='cls_validatacondition.getInstance().New_addConditionRow(\""+groupIndex+"\",\"create\")'>新条件</a>"+
    								"</td>"+
    							"</tr>"+
    						"<table class='settingPopTable lasttdbordernon' border='0' cellpadding='0' cellspacing='0' width='100%'"+
    							"<tr><td align='center' name='groupconditionglue_"+groupIndex+"'>"+
    							"</td></tr>"+
    						"</table>";
    					
    
    	parentNode.appendChild(newNode);
        if(hidegroup=='yes')
        {
            ld("#"+popupobj.divid+" [name='groupheader_"+groupIndex+"']").css("display",'none');
        }
    	that.group_index_array.push(groupIndex);
    	that.advft_group_index_count++;
    }
    this.New_addGroupConditionGlue = function(groupIndex) {
        var popupobj = that.popupobj;
        if(popupobj==undefined)
        {
            return false;
        }
        var groupConditionGlueElement=ld("#"+popupobj.advanceSearchDivid+" [name=groupconditionglue_"+groupIndex+"]");
    	if(groupConditionGlueElement.length>0) {
    		groupConditionGlueElement.html( "<select name='gpcon"+groupIndex+"' id='gpcon"+groupIndex+"' class='commonSelectPop'>"+
    												"<option value='and'>"+arrJsPopLabel['SEARCHAND']+"</option>"+
    												"<option value='or'>"+arrJsPopLabel['OR']+"</option>"+
    											"</select>");
    	}
    }
    this.New_addConditionRow = function(groupIndex,action) {
        var popupobj = that.popupobj;
        if(popupobj==undefined)
        {
            return false;
        }
        var selecttype_arr = popupobj.selecttype_arr;
        var comparatortype_arr = popupobj.comparatortype_arr;
        var field_arr = that.field_arr;
        var tmp_html = '';
        var tmp_index = 0;
        var tmp_field = {};
        
    	var groupColumns = that.column_index_array[groupIndex];
    	if(typeof(groupColumns) != 'undefined') {
    		for(var i=groupColumns.length - 1; i>=0; --i) {
    			var prevColumnIndex = groupColumns[i];
                var tmpobj=ld("#"+popupobj.advanceSearchDivid+" [name=columnconditionglue_"+prevColumnIndex+"]");
    			if(tmpobj!=undefined&&tmpobj.length>0) {
    				that.New_addColumnConditionGlue(prevColumnIndex);
    				break;
    			}
    		}
    	}
        
    	var columnIndex = that.advft_column_index_count+1;
    
    	var nextNode = ld("#"+popupobj.advanceSearchDivid+" [name=groupfooter_"+groupIndex+"]").get(0);
       
    
    	var newNode = document.createElement('tr');
        
    	newNodeId = 'conditioncolumn_'+groupIndex+'_'+columnIndex;
      	newNode.setAttribute('id',newNodeId);
      	newNode.setAttribute('name',newNodeId);
        newNode.setAttribute("tag",'conditionColumn');
        
    	nextNode.parentNode.insertBefore(newNode, nextNode);
    
    	node1 = document.createElement('td');
        node1.setAttribute('align', 'left');
        node1.setAttribute('width', '13%');
    	newNode.appendChild(node1);
        tmp_html = '<select onchange="cls_validatacondition.getInstance().changefieldtype(this)" tag="fieldtype" class="commonSelectPop" id="selecttype'+columnIndex+'" name="selecttype'+columnIndex+'" related_tag="selectfield" columnindex="'+columnIndex+'" style="width:100%" >';
	    for(tmp_type in selecttype_arr){
            tmp_html+= '<option value="'+tmp_type+'">'+selecttype_arr[tmp_type]+'</option>';
        }
	    tmp_html+= "</select>";
        node1.innerHTML = tmp_html;
        
    	
    	node2 = document.createElement('td');
        node2.setAttribute('align', 'left');
    	node2.setAttribute('width', '25%');
    	newNode.appendChild(node2);
        var colinfo = '';
        var typeofdata_arr = '';
        tmp_html = '<select class="commonSelectPop" id="selectfield'+columnIndex+'" name="selectfield'+columnIndex+'" columnindex="'+columnIndex+'" style="width:100%">';
        tmp_html+= '<option value="none" data-colinfo="" >'+'--'+arrJsPopLabel['NONE']+'--'+'</option>';
        for(tmp_index =0;tmp_index<field_arr.length;tmp_index++){
            tmp_field = field_arr[tmp_index];
            var fieldtype = 'V';
            if(!empty(tmp_field.typeofData)){
                typeofdata_arr = tmp_field.typeofData.split('~');
                fieldtype = typeofdata_arr[0];
            }
            colinfo = tmp_field.tableName+":"+tmp_field.columnName+":"+tmp_field.fieldName+":"+popupobj.frommodule+"_"+tmp_field.fieldLableKey+":"+fieldtype;
            tmp_html+= '<option value="'+tmp_field.fieldName+'" data-colinfo="'+colinfo+'" >'+tmp_field.fieldLableKey+'</option>';
        }
	    tmp_html+= "</select>";
    	node2.innerHTML = tmp_html;

        node3 = document.createElement('td');
        node3.setAttribute('align', 'left');
        node3.setAttribute('width', '15%');
    	newNode.appendChild(node3);
    	tmp_html = '<select onchange="cls_validatacondition.getInstance().ChangeComparatorType(this,'+columnIndex+')" class="commonSelectPop" id="comparatortype'+columnIndex+'" name="comparatortype'+columnIndex+'" style="width:100%">';
        for(tmp_key in comparatortype_arr){
            tmp_html += '<option value="'+tmp_key+'">'+comparatortype_arr[tmp_key]+'</option>';
        }
	    tmp_html += "</select>";
        node3.innerHTML = tmp_html;
        
        
        node4 = document.createElement('td');
        node4.setAttribute('align', 'left');
        node4.setAttribute('width', '13%');
    	newNode.appendChild(node4);
		tmp_html = '<select onchange="cls_validatacondition.getInstance().changefieldtype(this)" tag="fieldtype" class="commonSelectPop" id="comparetype'+columnIndex+'" name="comparetype'+columnIndex+'" related_tag="comparefield" columnindex="'+columnIndex+'" style="width:100%" >';
        for(tmp_type in selecttype_arr){
            tmp_html += '<option value="'+tmp_type+'">'+selecttype_arr[tmp_type]+'</option>';
        }
	    tmp_html += "</select>";
    	node4.innerHTML = tmp_html;
        
        
    	node5 = document.createElement('td');
        node5.setAttribute('align', 'left');
        node5.setAttribute('width', '25%');
    	newNode.appendChild(node5);
        tmp_html = '<select class="commonSelectPop" id="comparefield'+columnIndex+'" name="comparefield'+columnIndex+'" columnindex="'+columnIndex+'" style="width:100%">';
        tmp_html+= '<option value="none" data-colinfo="" >'+'--'+arrJsPopLabel['NONE']+'--'+'</option>';
        for(tmp_index =0;tmp_index<field_arr.length;tmp_index++){
            tmp_field = field_arr[tmp_index];
            var fieldtype = 'V';
            if(!empty(tmp_field.typeofData)){
                typeofdata_arr = tmp_field.typeofData.split('~');
                fieldtype = typeofdata_arr[0];
            }
            colinfo = tmp_field.tableName+":"+tmp_field.columnName+":"+tmp_field.fieldName+":"+popupobj.frommodule+"_"+tmp_field.fieldLableKey+":"+fieldtype;
            tmp_html+= '<option value="'+tmp_field.fieldName+'" data-colinfo="'+colinfo+'" >'+tmp_field.fieldLableKey+'</option>';
        }
	    tmp_html+= "</select>";
    	node5.innerHTML = tmp_html;
        
        
    	node6 = document.createElement('td');
        node6.setAttribute('align', 'left');
        node6.setAttribute('width', '6%');
    	node6.setAttribute('id', 'columnconditionglue_'+columnIndex);
        node6.setAttribute('name', 'columnconditionglue_'+columnIndex);
    	newNode.appendChild(node6);
        
    
    	node7 = document.createElement('td');
        node7.setAttribute('align', 'left');
        node7.setAttribute('width', '3%');
    	newNode.appendChild(node7);
    	node7.innerHTML = '<a  onclick="cls_validatacondition.getInstance().New_deleteColumnRow('+groupIndex+','+columnIndex+');" href="javascript:;" title="'+arrJsPopLabel['DELETE']+'">'+arrJsPopLabel['DELETE']+
    						'</a>';
    
        var selectfieldobj = ld("#"+popupobj.divid+" [name='selectfield"+columnIndex+"']");

    	if(selectfieldobj.length>0){   
            selectfieldobj.unbind('change').bind('change',function(){
                that.New_updatefOptions(this, 'comparatortype'+columnIndex);
            });
    	}
    	if(action == 'create'){
            this.setSearchPicklist('selectfield'+columnIndex);
            this.setSearchPicklist('comparefield'+columnIndex);
        }


        if(typeof(that.column_index_array[groupIndex]) == 'undefined') that.column_index_array[groupIndex] = [];
    	that.column_index_array[groupIndex].push(columnIndex);
    	that.advft_column_index_count++;
        popupobj.center();
    }

    this.checksqlwildcardshow = function () {
        var sql_wild_card = ld("#"+this.popupobj.divid).find("div[name=showsqlwildcard]");
        if(sql_wild_card.length == 0)return '';


        var popupobj = that.popupobj;
        var conditionColumns = that.New_vt_getElementsByName('tr', "conditionColumn");
        var has_sql = 'no';

        var tipzhtype=ld.trim(ld("#"+popupobj.divid+' [name=tipzhtype]').val());
        var tipentype=ld.trim(ld("#"+popupobj.divid+' [name=tipentype]').val());

        if(tipentype == 'sql'  || tipzhtype == 'sql'){
            has_sql = 'yes';
        }
        if(has_sql == 'no'){
            for(var i=0;i < conditionColumns.length ; i++) {

                var columnRowId = conditionColumns[i].getAttribute("id");
                var columnRowInfo = columnRowId.split("_");
                var columnGroupId = columnRowInfo[1];
                var columnIndex = columnRowInfo[2];

                //选择字段类型
                var SelectTypeId = "selecttype" + columnIndex;
                var SelectTypeobj = ld("#" + popupobj.advanceSearchDivid + " #" + SelectTypeId);
                var SelectTypeValue = trim(SelectTypeobj.val());

                //比较字段类型
                var CompareTypeId = "comparetype" + columnIndex;
                var CompareTypeobj = ld("#" + popupobj.advanceSearchDivid + " #" + CompareTypeId);
                var CompareTypeValue = trim(CompareTypeobj.val());

                if(SelectTypeValue == 'sql'  || CompareTypeValue == 'sql'){
                    has_sql = 'yes';
                    break;
                }
            }
        }
        if(has_sql == 'yes'){
            sql_wild_card.show();
        }else {
            sql_wild_card.hide();
        }
    }
    this.New_addColumnConditionGlue = function(columnIndex){
    
        if(popupobj==undefined)
        {
            return false;
        }
        
    	var columnConditionGlueElement = ld("#"+popupobj.advanceSearchDivid+" [name=columnconditionglue_"+columnIndex+"]");;
    
    	if(columnConditionGlueElement&&columnConditionGlueElement.length>0){
    		ld('#advfiltershow').css('display','block');
    		columnConditionGlueElement.html("<select name='fcon"+columnIndex+"' id='fcon"+columnIndex+"' class='commonSelectPop'>"+
    													"<option value='and'>"+arrJsPopLabel['SEARCHAND']+"</option>"+
    												"<option value='or'>"+arrJsPopLabel['OR']+"</option>"+
    												"</select>");
    	}
    }
    
    this.changefieldtype = function(obj){
        var popupobj = that.popupobj;
        var related_tag = ld(obj).attr('related_tag');
        var columnindex = ld(obj).attr('columnindex');
        var fieldtype = ld(obj).val();
        var tmp_html = '';
        var relatedname = related_tag+columnindex;
        
        switch(fieldtype){
            case 'date':
                tmp_html = '<input onclick="WdatePicker({startDate:\'%y-%M-%d\',dateFmt:\'yyyy-MM-dd\',alwaysUseStartDate:true})" '+
                        ' class="Wdate width150 WdateImage" type="text" id="'+relatedname+'" name="'+relatedname+'" columnindex="'+columnindex+'" autocomplete="off" style="width:100%;height: 30px;">';
                break;
            case 'datetime':
                tmp_html = '<input onclick="WdatePicker({startDate:\'%y-%M-%d %H:%M:%S\',dateFmt:\'yyyy-MM-dd HH:mm:ss\',alwaysUseStartDate:true})" '+
                        ' class="Wdate width150 WdateImage" type="text" id="'+relatedname+'" name="'+relatedname+'" columnindex="'+columnindex+'" autocomplete="off" style="width:100%;height: 30px;">';
                break;
            case 'text':
                tmp_html = '<input type="text" class="commonTextBoxPop" id="'+relatedname+'" name="'+relatedname+'" columnindex="'+columnindex+'" style="width:100%;" >';
                break;
            case 'number':
                tmp_html = '<input type="text" class="commonTextBoxPop" id="'+relatedname+'" name="'+relatedname+'" columnindex="'+columnindex+'" style="width:100%;" >';
                break;
            case 'fields':
                var field_arr = that.field_arr;
                var tmp_index = 0;
                var colinfo = '';
                var typeofdata_arr = '';
                tmp_html = '<select class="commonSelectPop" id="'+relatedname+'" name="'+relatedname+'" columnindex="'+columnindex+'" style="width:100%">';
                tmp_html+= '<option value="none" data-colinfo="" >'+'--'+arrJsPopLabel['NONE']+'--'+'</option>';
                for(tmp_index =0;tmp_index<field_arr.length;tmp_index++){
                    tmp_field = field_arr[tmp_index];
                    var tmp_fieldtype = 'V';
                    if(!empty(tmp_field.typeofData)){
                        typeofdata_arr = tmp_field.typeofData.split('~');
                        tmp_fieldtype = typeofdata_arr[0];
                    }
                    colinfo = tmp_field.tableName+":"+tmp_field.columnName+":"+tmp_field.fieldName+":"+popupobj.frommodule+"_"+tmp_field.fieldLableKey+":"+tmp_fieldtype;
                    tmp_html+= '<option value="'+tmp_field.fieldName+'" data-colinfo="'+colinfo+'" >'+tmp_field.fieldLableKey+'</option>';
                }
        	    tmp_html+= "</select>";
                break;
            case 'sql':
            case 'sum':
                tmp_html = '<textarea id="'+relatedname+'" name="'+relatedname+'" style="width:100%;height: 50px;"></textarea>';
                break;
            default:
            break;
        }
        if(!empty(tmp_html)){
            var relatedobj = ld("#"+popupobj.divid+" #"+relatedname);
            var parentObj = relatedobj.parent();
            parentObj.html(tmp_html);
            // ld('textarea').autosize();//BUG0076559 ls 30231206 通过SQL查询，文本区域框无法向下拉
            if(related_tag == 'selectfield'){
                if(fieldtype == 'fields'){
                    ld("#"+popupobj.divid+" #"+relatedname).unbind('change').bind('change',function(){
                        that.New_updatefOptions(this, 'comparatortype'+columnindex);
                    })
                }
                that.New_updatefOptions(ld(obj).get(0),'comparatortype'+columnindex);
            }
            if(fieldtype == 'fields'){
                this.setSearchPicklist(relatedname);
            }
        }
        this.checksqlwildcardshow();
    }
    
    this.InitAdvftValue = function(advft_criteria,advft_criteria_groups){
        var popupobj = that.popupobj;
        var criteria_groups = advft_criteria; //所有查询条件
        var groupid; //查询组编号
        var groups_criteria; //查询组信息
        var group_columns; //组内查询字段信息
        var column_index; //每行的编号
        var column_criteria; //每行查询条件信息
        var columnvalue; //查询内容
        var fori = 0; //'且'、'或'条件编号
        var conditionColumnRowElement; //每行对象
        //清空原有条件
        this.clear();
        
        var i = 0;
        var advft_len = advft_criteria.length;
        var tmp_groupid;
        var tmp_groupindex;
        var groupidtoindex = {};
        var columntoindex = {};
        var tmpdivid = that.popupobj.divid;
        var selecttype;
        var selecttypeobj;
        var selectfield;
        var selectfieldobj;
        var comparetype;
        var comparetypeobj;
        for(i=0;i<advft_len;i++){
            column_criteria = advft_criteria[i];
            if(empty(column_criteria)){
                continue;
            }
            tmp_groupid = column_criteria['groupid'];
            if(empty(groupidtoindex[tmp_groupid])){
                that.New_addConditionGroup();	
                tmp_groupindex = that.advft_group_index_count;
                groupidtoindex[tmp_groupid] = tmp_groupindex;
            }else{
                tmp_groupindex = groupidtoindex[tmp_groupid];
            }
            that.New_addConditionRow(tmp_groupindex,'edit');
            column_index = that.advft_column_index_count;
            columntoindex[i] = column_index;
            //选择字段类型
            selecttype = column_criteria['selecttype'];
            selecttypeobj = ld('#'+tmpdivid+' #selecttype'+column_index);
            if(selecttype == 'sum'){
                selecttypeobj.append('<option value="sum" >sum</option>')
            }
            selecttypeobj.val(selecttype);
            that.changefieldtype(selecttypeobj);
            //选择字段
            selectfield = column_criteria['selectfield'];
            selectfieldobj = ld('#'+tmpdivid+' #selectfield'+column_index);
            selectfieldobj.val(selectfield);
            if(selecttype == 'fields'){
                var cur_text = selectfieldobj.find('option:selected').text();
                ld('#'+tmpdivid+' #cmb_span_optiontext_selectfield'+column_index).val(cur_text);
                that.New_updatefOptions(selectfieldobj.get(0), 'comparatortype'+column_index);
            }
            //比较关系
            comparatortype = column_criteria['comparatortype'];
            comparatortypeobj = ld('#'+tmpdivid+' #comparatortype'+column_index);
            comparatortypeobj.val(comparatortype);
            
            //比较字段类型
            comparetype = column_criteria['comparetype'];
            comparetypeobj = ld('#'+tmpdivid+' #comparetype'+column_index);
            if(comparetype == 'sum'){
                comparetypeobj.append('<option value="sum" >'+arrJsPopLabel['TOTALOTHER']+'</option>')
            }
            comparetypeobj.val(comparetype);
            that.changefieldtype(comparetypeobj);
            //比较字段
            comparefield = column_criteria['comparefield'];
            comparefieldobj = ld('#'+tmpdivid+' #comparefield'+column_index);
            comparefieldobj.val(comparefield)
            if(comparetype == 'fields'){
                var cur_text = comparefieldobj.find('option:selected').text();
                ld('#'+tmpdivid+' #cmb_span_optiontext_comparefield'+column_index).val(cur_text);
            }
            //that.changefieldtype(comparetypeobj);
            
            that.ChangeComparatorType(comparatortypeobj.get(0),column_index);
        }
        //设置组内关系
        ld.each(columntoindex ,function(i,column_index){
            if(!empty(advft_criteria[i])){
                column_criteria = advft_criteria[i];
                if(ld("#"+tmpdivid+" #fcon"+column_index).length>0){
                    ld("#"+tmpdivid+" #fcon"+column_index).val(column_criteria['columncondition']);
                }
            }
        })
        
        //设置组间关系
        if(!empty(advft_criteria_groups)){
            ld.each(groupidtoindex ,function(tmp_groupid,tmp_groupindex){
                if(!empty(advft_criteria_groups[tmp_groupid])){
                    group_columns = advft_criteria_groups[tmp_groupid];
                    if(ld("#"+tmpdivid+" #gpcon"+tmp_groupindex).length>0){
                        ld("#"+tmpdivid+" #gpcon"+tmp_groupindex).val(group_columns['groupcondition']);
                    }
                }
            })
        }
    }
    
    this.clear = function(){
        //清空原有条件
        ld('#'+that.popupobj.divid+' [tag=conditionGroup]').remove();
        //重置已有查询条件数量
        that.advft_column_index_count = -1;
        that.advft_group_index_count = 0;
        that.column_index_array = [];
        that.group_index_array = [];
    }
    //比较条件选择为空值，不为空值，当前用户等选项时，隐藏比较字段
    this.ChangeComparatorType = function(obj,column_index){
        var popupobj = that.popupobj;
        var comparatortype = ld(obj).val();
        var comparetypeobj = ld('#'+popupobj.divid+' #comparetype'+column_index);
        if(comparetypeobj.val() == 'fields'){
            var comparefieldobj = ld('#'+popupobj.divid+' [name=dv_cmb_comparefield'+column_index+']');
        }else{
            var comparefieldobj = ld('#'+popupobj.divid+' #comparefield'+column_index);
        }

        if(comparatortype == 'isnull' || comparatortype == 'isnotnull' || comparatortype == 'curuser'){
            comparetypeobj.hide();
            comparefieldobj.hide();
        }else{
            comparetypeobj.show();
            comparefieldobj.show();
        }
        
    }
    
    //判断字段类型和字段值是否匹配
    this.checkfieldvalue = function(valuedivid,type,value){
        var popupobj = that.popupobj;
        var invalid = false;
        if(type == 'number'){
            if(isNaN(value)){
                invalid=true;
            }else{
                invalid=false;
            }
            if(invalid){
                var confirm_str = arrJsPopLabel['ENTERCORRECTNUMBER'];
                audioRemindsMsg("","","","","",confirm_str);
            }
        }
        
        if(invalid){
            ld("#"+popupobj.divid+' #'+valuedivid).addClass('border_red1');
            ld("#"+popupobj.divid+' #'+valuedivid).bind('mouseover',function(){
                ld(this).removeClass('border_red1');
            });
        }
        return invalid;
    }

    this.setSearchPicklist = function (selectname){
        if(document.getElementById(selectname).length>0){
            var selObj = document.getElementById(selectname);
            var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectname);
            cls_resetComboxHtmlobj.setPopupObj(popupobj);
            cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selObj,180);
        }
    }

    this.setAdvanceTableParentDivid = function (divid){
        that.AdvanceTableParentDivid = divid;
    }
}
//获取当前类对象
cls_validatacondition.getInstance=function(){
    var popupobj = CrmPopup.getPopupObj('last');
    if(!empty(popupobj)){
        if(!empty(popupobj.valiadvancefilterobj)){
            return popupobj.valiadvancefilterobj;
        }else{
            popupobj.valiadvancefilterobj=new cls_validatacondition();
            return popupobj.valiadvancefilterobj;
        }
    }else{
        var valiadvancefilterobj=new cls_validatacondition();
        return valiadvancefilterobj;
    }
}