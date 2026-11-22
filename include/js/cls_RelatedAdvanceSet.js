//相关信息栏-高级设置
function cls_RelatedAdvanceSet(){
	var that=this;
	this.advft_column_index_count=-1;
	this.module='';
	this.related_module='';
	this.relatedid='';
	this.advancesetlabel='';
	//新增
	this.create = function(module,obj){
		var popupobj=CrmPopup.getPopupObj("last");//明细界面的相关信息弹出层
		var related_module=ld(obj).attr('relatetag');
		that.module=module;
		that.related_module=related_module;
		that.relatedid=ld(obj).attr('relatedid');
		var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=RelatedAdvanceSet&relatedmodule='+related_module+'&relationid='+that.relatedid;
		var crmPopupobj = CrmPopup.load("",that.save,"","LdPopWidth900px",module,"","","","");
		crmPopupobj.prevshow();
		crmPopupobj.type='related_advanceset';
		ld('#rptContentLoading').hide();
		ldAjaxNoProgress(surl,'',function(data){
			if(data.code==1){
				that.fields=data.result.related_fields;
				that.keywords=data.result.keywords;
				that.advancesetlabel=data.result.title;
				crmPopupobj.setParams(data.result.title,that.save,"","800",module,"",data.result.oktext,"",data.result.canceltext);
				crmPopupobj.show(data.result.content);
				ld("#"+crmPopupobj.divid+" #addbtn").unbind("click").on("click",function(){
					that.addConditionRow('');
				});
				if(popupobj.advanceset){
					if(popupobj.module=='BalanceOfAccount' ||  popupobj.module == 'GuanJiaPoReport'){//客户-相关信息栏-往来对账有多个模块
						var advanceset_arr=JSON.parse(popupobj.advanceset[related_module]);
					}else{
						var advanceset_arr=JSON.parse(popupobj.advanceset);
					}
					if(advanceset_arr.length>0){
						ld.each(advanceset_arr,function (columnIndex,advancesetobj){
							that.addConditionRow(advancesetobj);
						});
					}
				}else{
					that.addConditionRow('');
				}
			}
		})
	}
	//新增条件
	this.addConditionRow = function(advancesetobj){
		var popupobj=CrmPopup.getlastPopupObjByType('related_advanceset');
		if(popupobj==undefined)
		{
			return false;
		}
		var columnIndex = that.advft_column_index_count+1;
		var nextNode = ld("#"+popupobj.divid+" [name=groupfooter]").get(0);
		var newNode = document.createElement('tr');
		var newNodeId = 'conditioncolumn_'+columnIndex;
		newNode.setAttribute('id',newNodeId);
		newNode.setAttribute('name',newNodeId);
		newNode.setAttribute("tag",'conditionColumn');
		newNode.setAttribute("index",columnIndex);
		nextNode.parentNode.insertBefore(newNode, nextNode);

		var node1 = document.createElement('td');
		node1.setAttribute('align', 'left');
		node1.setAttribute('width', '25%');
		newNode.appendChild(node1);
		var option='';
		ld.each(that.fields,function (table_field,fieldinfo){
			option +="<option value='"+table_field+"'>"+fieldinfo.fieldlabel+"</option>";
		});
		node1.innerHTML = "<select name='fcol"+columnIndex+"' id='fcol"+columnIndex+"' style='max-width:400px;' class='commonSelectPop'>"+ option + "</select>";

		var node2 = document.createElement('td');
		node2.setAttribute('align', 'left');
		node2.setAttribute('width', '20%');
		newNode.appendChild(node2);
		node2.innerHTML = "<div type='text' name='fop"+columnIndex+"' id='fop"+columnIndex+"'></div>";

		var node3 = document.createElement('td');
		node3.setAttribute('align', 'left');
		node3.setAttribute('id', 'keyword_'+columnIndex);
		newNode.appendChild(node3);
		node3.innerHTML = that.keywords;

		var node4 = document.createElement('td');
		node4.setAttribute('align', 'left');
		node4.setAttribute('id', 'columnconditionglue_'+columnIndex);
		node4.setAttribute('name', 'columnconditionglue_'+columnIndex);
		node4.setAttribute('width', '60px');
		newNode.appendChild(node4);
		//wym 240221 BUG20240221-07 客户--高级设置--条件默认值应该是或，现在是且
		node4.innerHTML="<select name='fcon"+columnIndex+"' id='fcon"+columnIndex+"' class='commonSelectPop' style='display: none'>" +
			"<option value='or'>"+arrJsPopLabel['OR']+"</option>" +
			"<option value='and'>"+arrJsPopLabel['SEARCHAND']+"</option>" +
			"</select>";
		if(columnIndex!=0){
			var previousRow = ld("#"+popupobj.divid+" #conditioncolumn_"+columnIndex).prev(); // 获取上一个行
			if(previousRow.length>0){
				var prevcolumnIndex = ld(previousRow.get(0)).attr('index'); // 获取上一个行的行号
				var prevcolumnconditionglue = ld("#"+popupobj.divid+" #fcon"+prevcolumnIndex).get(0);
				ld(prevcolumnconditionglue).show();
			}
		}

		var node5 = document.createElement('td');
		node5.setAttribute('width', '30px');
		node5.setAttribute('align', 'left');
		newNode.appendChild(node5);
		node5.innerHTML = '<a id="deletebtn_'+columnIndex+'" href="javascript:;" title="'+arrJsPopLabel['DELETE']+'">'+arrJsPopLabel['DELETE']+'</a>';
		if(advancesetobj.columnname){ //根据advanceset的值 修改select选中值
			ld("#"+popupobj.divid+" #fcol"+columnIndex).val(advancesetobj.columnname);
		}
		if(advancesetobj.columncondition){ //根据advanceset的值 修改select选中值
			ld("#"+popupobj.divid+" #fcon"+columnIndex).val(advancesetobj.columncondition);
		}
		that.updatefOptions(columnIndex);
		that.setevent(columnIndex);
		that.advft_column_index_count++;
	}
	//绑定事件
	this.setevent = function(columnIndex){
		var popupobj=CrmPopup.getlastPopupObjByType('related_advanceset');
		var selectname = 'fcol'+columnIndex;
		if(ld("#"+popupobj.divid+" #"+selectname).length>0){
			var selObj = ld("#"+popupobj.divid+" #"+selectname);
			var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectname);
			cls_resetComboxHtmlobj.setPopupObj(popupobj);
			cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selObj,180);
		}
		ld("#"+popupobj.divid+" #"+selectname).unbind("change").on("change",function(event){
			that.updatefOptions(columnIndex);
		});
		ld("#"+popupobj.divid+" #deletebtn_"+columnIndex).unbind("click").on("click",function(event){
			that.deleteColumnRow(columnIndex);
		});
	}
	//字段切换时，选择条件也要同时更新
	this.updatefOptions = function(columnIndex) {
		var popupobj=CrmPopup.getlastPopupObjByType('related_advanceset');
		var selectname = 'fcol'+columnIndex;
		if(ld("#"+popupobj.divid+" #"+selectname).length>0){
			var selfield=ld("#"+popupobj.divid+" #"+selectname).val();
			ld.each(that.fields,function (table_field,fieldinfo){
				if(table_field==selfield){
					if(fieldinfo.bigtype=='multireference'){
						ld("#"+popupobj.divid+" #fop"+columnIndex).text(arrJsPopLabel['Include']);
						ld("#"+popupobj.divid+" #fop"+columnIndex).attr('comparator','c');
					}else{
						ld("#"+popupobj.divid+" #fop"+columnIndex).text(arrJsPopLabel['Equal']);
						ld("#"+popupobj.divid+" #fop"+columnIndex).attr('comparator','e');
					}
					if(fieldinfo.special_keywords){ //某些字段有对应的特殊Keywords（费用预算单-相关信息栏-费用报销单）
						ld("#"+popupobj.divid+" #keyword_"+columnIndex).text(fieldinfo.special_keywords);
					}
					return false;
				}
			});
		}
	}
	//删除单条规则
	this.deleteColumnRow = function(columnIndex){
		var popupobj=CrmPopup.getlastPopupObjByType('related_advanceset');
		if(ld("#"+popupobj.divid+" #conditioncolumn_"+columnIndex).length>0){
			ld("#"+popupobj.divid+" #conditioncolumn_"+columnIndex).remove();
		}
		if(columnIndex!=0){
			var column_trobjs = ld("#"+popupobj.divid+" [tag=conditionColumn]"); //获取每一行对象
			if(column_trobjs.length>0){
				ld.each(column_trobjs,function(index,column_trobj){
					var columnIndex = ld(column_trobj).attr('index');
					if(index==column_trobjs.length-1){
						ld("#"+popupobj.divid+" #fcon"+columnIndex).hide(''); //删除完后，隐藏最后一行的condition
					}
				});
			}
		}
	}
	//保存设置
	this.save = function(){
		var popupobj=CrmPopup.getPopupObj("last");//高级设置
		var column_trobjs = ld("#"+popupobj.divid+" [tag=conditionColumn]"); //获取每一行对象
		if(column_trobjs.length>0){
			var advanceset= [];
			ld.each(column_trobjs,function(index,column_trobj){
				var tmpdata= {};
				var columnIndex = ld(column_trobj).attr('index');
				var selfield = ld(column_trobj).find('#fcol'+columnIndex).val();
				var seloption = ld(column_trobj).find('#fop'+columnIndex).attr('comparator');
				var conditionglue = '';
				if(ld(column_trobj).find('#fcon'+columnIndex).length>0){
					conditionglue = ld(column_trobj).find('#fcon'+columnIndex).val();
				}
				tmpdata['columnname']=selfield;
				tmpdata['comparator']=seloption;
				if(index==column_trobjs.length-1){
					tmpdata['columncondition']='';
				}else{
					tmpdata['columncondition']=conditionglue;
				}
				advanceset.push(tmpdata);
			});
		}else{
			var confirm_str = that.advancesetlabel + arrJsPopLabel['CANOTEMPTY'];
			MessagePopup.TipZero_warning(confirm_str);
			return false;
		}
		var surl = 'index.php?module='+that.module+'&action='+that.module+'Ajax&mode=save&file=RelatedAdvanceSet&relationid='+that.relatedid+'&advanceset='+JSON.stringify(advanceset);
		ldAjaxNoProgress(surl,'',function(data){
            if(data.code == 1){
                popupobj.CancelEvent();
				var detailpopupobj=CrmPopup.getPopupObj("last");//明细界面popobj
				if(detailpopupobj.module=='BalanceOfAccount' || detailpopupobj.module == 'GuanJiaPoReport')//客户-往来对账
				{
					detailpopupobj.balanceaccountobj.callsearch(that.related_module);
					return false;
				}else{
					DetailViewRelation.refresh_relatedlist(that.related_module);//刷新明细界面
				}
            }
        })
	}
}

cls_RelatedAdvanceSet.getInstance=function(){
	//不要获取单例,否则反复打开弹窗时,columnindex会不断累加
	cls_RelatedAdvanceSet.curobj=new cls_RelatedAdvanceSet();
    return cls_RelatedAdvanceSet.curobj;
}
