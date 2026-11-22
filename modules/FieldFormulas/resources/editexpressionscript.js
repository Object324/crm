/*+*******************************************************************************
 *{*修改编码格式:统一编码：UTF-8*} 
 * The contents of this file are subject to the lingdang CRM Public License Version 1.0
 * ("License"); You may not use this file except in compliance with the License
 * The Original Code is:  lingdang CRM Open Source
 * The Initial Developer of the Original Code is lingdang.
 * Portions created by lingdang are Copyright (C) lingdang.
 * All Rights Reserved.
 ******************************************************************************/
jQuery.noConflict();
function editexpressionscript($){
	function errorDialog(message){
		alert(message);
	}

	function handleError(fn){
		return function(status, result){
			if(status){
				fn(result);
			}else{
				errorDialog('Failure:'+result);
			}
		};
	}


	var ep;//ep is defined in the document.ready block.

	function errorDialog(message){
		alert(message);
	}


	function jsonget(operation, params, callback){
		var obj = {
				module:'FieldFormulas',
				action:'FieldFormulasAjax',
				file:operation, ajax:'true'};
		$.each(params,function(key, value){
			obj[key] = value;
		});
		$.get('index.php', obj,
			function(result){
				var parsed = JSON.parse(result);
				callback(parsed);
		});
	}
	
	function getfieldlabel(fieldname) {
		var fieldlabel = false;
		if(typeof(meta_fieldnames) != 'undefined' && typeof(meta_fieldlabels) != 'undefined') {
			fieldlabel = meta_fieldlabels[meta_fieldnames.indexOf(fieldname)]; 
		}
		if(!fieldlabel) fieldlabel = fieldname;
		return fieldlabel;
	}

    /**
     *@edit:andy 
     *@date:20140910
     *@reason:	0010990: (建议)当字段公式无记录时给出提示信息
     *@version:
     */
     //function addFieldExpression(moduleName, fieldName, fieldLabel, expression){
	function addFieldExpression(moduleName, fieldName, fieldLabel, expression,type){
	   
	  	editLink = format('<a class="Anu3_a"\
								id="expressionlist_editlink_%s" \
								>'+arrJsPopLabel['EDIT']+'<a/>', fieldName);
		deleteLink = format('<a class="Anu3_a" \
		 					id="expressionlist_deletelink_%s">'+arrJsPopLabel['DELETE']+'<a/>', fieldName);
                            
		row = format('<tr class="Hoverbj expressionlistrow" id="expressionlistrow_%s"> \
					<td class="listTableRow small" valign="top" nowrap="">%s</td>\
					<td class="listTableRow small" valign="top" nowrap="">%s</td>\
					<td class="listTableRow small" valign="top" nowrap="">%s %s</td>\
				</tr>', fieldName, fieldLabel, expression.replace("\n","<BR/>"), editLink, deleteLink);

        /**
         *@edit:andy 
         *@date:20140910
         *@reason:	0010990: (建议)当字段公式无记录时给出提示信息
         *@version:
         */
		//$('#expressionlist').append(row);
        //row_Noresult='<tr id="row_Noresult" class="Hoverbj expressionlistrow"><td class="listTableRow small" colspan="3" align=center nowrap="">'+arrJsPopLabel['NORECORDSAREFOUND']+'</td></tr>';//'+arrJsPopLabel['NORECORDSAREFOUND']+'
        row_Noresult='<tr id="row_Noresult" class="Hoverbj expressionlistrow"><td align="center" colspan="12" style="background-color:#efefef;height:380px"><div class="noResultBG"><div class="noResultContent"><div class="divNoRecord">'+arrJsPopLabel['NORECORDSAREFOUND']+'</div></div></div></td></tr>';
        if(type == 'yes'){
            $('#expressionlist').append(row);
        }
        else if(type == 'yes_add')
        {
            $("#row_Noresult").remove();
            $('#expressionlist').append(row);
        }
        else
        {
             $('#expressionlist').append(row_Noresult);
        }
        
		$(format('#expressionlist_deletelink_%s', fieldName)).click(function(){
			if(confirm(arrJsPopLabel['SUREDELETEEXPRESSION'])) {
				$('#status').show();
				
				jsonget('deleteexpressionjson',
					{modulename:moduleName, fieldname:fieldName},
					function(result){
						$('#status').hide();
						if(result.status=='success'){
                            /**
                             *@edit:andy 
                             *@date:20140910
                             *@reason:	0010990: (建议)当字段公式无记录时给出提示信息
                             *@version:
                             */
							$(format('#expressionlistrow_%s', fieldName)).remove();
							if(!$('table.ControlTable1 tr.expressionlistrow').length || $('table.ControlTable1 tr.expressionlistrow').length < 1)
								$('#expressionlist').append(row_Noresult);
						}else{
							errorDialog(result.message);
						}
					}
				);
			}
		});
		$(format('#expressionlist_editlink_%s', fieldName)).click(function(){
			ep.edit(fieldName, expression);
		});
	}

	format = fn.format;
	var moduleName;
	function editpopup(){
			function close(){
				$('#editpopup').css('display', 'none');
				$('#editpopup_expression').text('');
                lingdangJS_DialogBox.unblock();
			}

			function show(module){
				$('#editpopup').css('display', 'block');
				center($('#editpopup'));
                lingdangJS_DialogBox.block();
			}
			
			function center(el){
				el.css({position: 'absolute'});
				fnvshobj('',el.get(0).id);
			}

			$('#editpopup_close').bind('click', close);
			$('#editpopup_save').bind('click', function(){
				var expression = $('#editpopup_expression').attr('value');
				var fieldName = $('#editpopup_field').attr('value');
				var fieldLabel = getfieldlabel(fieldName);
				var moduleName = $('#pick_module').attr('value');

				expression = expression.replace(/<script(.|\s)*?\/script>/g, "");
				expression = $.trim(expression);
				if(expression == '')
                {
					$('#editpopup_expression').focus();
                    alert(arrJsPopLabel['CONTENTCANOTEMPTY']);
                    return false;
                }
				if(expression.indexOf('if ') > -1){
					if(expression.indexOf('end') > -1){//对格式做判断
						
					}else{
						$('#editpopup_expression').focus();
						alert(arrJsPopLabel['FORMATERROR']);return false;
					}
				}else{
					//正则匹配，以 ( 开头 以 ) 结尾，中间可以是数字、字母或者,-符号，不允许包括空格的其他符号
					var re = /\([0-9a-zA-Z,_]+\)/;
					var expressionstr = '';var expressionarr = [];
					var funcarr = Array('concat','time_diffdays','time_diffdays');
					var isfunc = false;
					var funclen = funcarr.length;
					for(var i=0;i<funclen;i++){//匹配使用函数的公式格式
						if(expression.indexOf(funcarr[i]) > -1){
							if(expression.indexOf(',') < 0){//必须有 , 号
								isfunc = true;break;
							}
							//清除字段中间的空格
							$('#editpopup_expression').val(expression = expression.replace(/\s/g,""));
							expressionarr = expression.split(funcarr[i]);
							expressionstr = $.trim(expressionarr[1]);
							if(!re.test(expressionstr)){//不符合正则表达式指定格式
								isfunc = true;break;
							}
						}
					}
					if(isfunc){//不符合正则表达式指定格式
						$('#editpopup_expression').focus();
						alert(arrJsPopLabel['FORMATERROR']);return false;
					}
					var isfield = '';
					if(expressionstr != ''){//使用函数情况
						expressionstr = expressionstr.substring(1,expressionstr.length-1);
						var expressionstrarr = expressionstr.split(',');
						var expressionstrarrlen = expressionstrarr.length;
						for(var i=0;i<expressionstrarrlen;i++){//匹配所输入字段是否属于当前模块
							if(meta_fieldnames.indexOf(expressionstrarr[i]) < 0){
								isfield = expressionstrarr[i];break;
							}
						}
					}else{//未使用函数情况下
						var colarr = Array('+','-','*','/','>','<','>=','<=');
						var collen = colarr.length;var expressionarrlen = 0;
						var expressionarr = [];var iscol = false;
						for(var i=0;i<collen;i++){//使用特殊字符连接情况
							if(expression.indexOf(colarr[i]) > -1){
								iscol = true;//包含特殊字符
								expressionarr = expression.split(colarr[i]);
								expressionarrlen = expressionarr.length;
								for(var j=0;j<expressionarrlen;j++){
									expressionarr[j] = $.trim(expressionarr[j]);
									if(expressionarr[j] == ''){
										alert(arrJsPopLabel['FORMATERROR']);
										$('#editpopup_expression').focus();
										return false;
									}
									if(meta_fieldnames.indexOf(expressionarr[j]) < 0){
										isfield = expressionarr[j];break;
									}
								}
							}
							if(isfield != '') break;
						}
						if(!iscol){//未包含特殊字符，强制设定格式为单个字段情况
							if(meta_fieldnames.indexOf($.trim(expression)) < 0){
								isfield = expression;
							}
						}
					}
					if(isfield != ''){//有字段不属于当前模块，不允许提交
						alert(arrJsPopLabel['FORMATERROR']+': '+isfield);
						$('#editpopup_expression').focus();return false;
					}
				}

				

				lingdangJS_DialogBox.block();
				$.get('index.php', {
						module:'FieldFormulas',
						action:'FieldFormulasAjax',
						file:'saveexpressionjson', ajax:'true',
						modulename: moduleName, fieldname:fieldName,
						expression:expression
						},
					function(result){
						lingdangJS_DialogBox.unblock();
						try {
							var parsed = JSON.parse(result);
							if(parsed.status=='success'){
								$("#expressionlistrow_"+fieldName).remove();
                                /**
                                 *@edit:andy 
                                 *@date:20140910
                                 *@reason:	0010990: (建议)当字段公式无记录时给出提示信息
                                 *@version:
                                 */
                                type='yes_add';
								addFieldExpression(moduleName, fieldName, fieldLabel, expression,type);
								close();
							}else{
								errorDialog('save failed because '+parsed.message);
							}
						} catch(error) {
							alert(error);
						}
					});
				});

			$('#editpopup_cancel').bind('click', close);

			$('#editpopup_fieldnames').bind('change', function(){
				/**
				 * 判断表达式字段不可以等于字段公式字段本身
				 * @reason 0011299 客户中字段公式功能异常
				 * @author Tujt 2014-09-15
				 */
				if($(this).val() == $('#editpopup_field').val()){
					$(this).attr('selectedIndex',0);
					alert(arrJsPopLabel['CANOTCHOOSE']);return false;
				}
				var textarea = $('#editpopup_expression').get(0);
				var value = $(this).attr('value');
				if(value != '') value += ' ';
				//http://alexking.org/blog/2003/06/02/inserting-at-the-cursor-using-javascript
				if (document.selection) {
					textarea.focus();
					var sel = document.selection.createRange();
					sel.text = value;
					textarea.focus();
				}else if (textarea.selectionStart || textarea.selectionStart == '0') {
					var startPos = textarea.selectionStart;
					var endPos = textarea.selectionEnd;
					var scrollTop = textarea.scrollTop;
					textarea.value = textarea.value.substring(0, startPos)
										+ value
										+ textarea.value.substring(endPos,
											textarea.value.length);
					textarea.focus();
					textarea.selectionStart = startPos + value.length;
					textarea.selectionEnd = startPos + value.length;
					textarea.scrollTop = scrollTop;
				}	else {
					textarea.value += value;
					textarea.focus();
				}
				//textarea.value = textarea.value.replace(/\s/g,"");
				// Reset the selected option (to enable next selection)
				this.value = '';
				//默认选中第二个参数未知b
				var editcontent = $('#editpopup_expression').val();
				var startIndex = editcontent.indexOf(',');
				selectTextRange('editpopup_expression','b',startIndex);

			});
			/**
			 * 编辑状态下，下级字段下拉框切换时，不能切换为已经创建字段公式的字段
			 * @reason 0011305 字段公式编辑方式不合理
			 * @author Tujt 2014-09-12
			 */
			var selectthisindex = -1;//默认选中
			var ischange = 0;
			$('#editpopup_field').click(function(){
				if(ischange == 1) return false;
				var findex = $(this).attr('selectedIndex');//点击下拉框，记录当前下拉框index值
				$(this).change(function(){//给下拉框添加change变更事件
					////$('#popupfldtitle').html('');
					var ids = '';var cvalue = $(this).val();
					var checkb = true;
					$('table.ControlTable1 tr.expressionlistrow').each(function(jkey,jval){
						ids = $(jval).attr('id');
						ids = ids.split('expressionlistrow_');
						ids = ids[1];
						if(ismote != 'create' && ismote == ids){
							return true;//编辑状态下，判断是过滤掉自身
						}
						if(cvalue == ids){//所选字段已经添加过字段公式
							if(selectthisindex > -1){//如果已经切换下拉框项，则回复到切换的下拉框项
								$('#editpopup_field').attr('selectedIndex',selectthisindex);
							}else{
								$('#editpopup_field').attr('selectedIndex',findex);
							}
							$('#popupfldtitle').html(arrJsPopLabel['FIELDFORMULASTHISFIELDCRESTOR']);
							checkb = false;
							return false;
						}
					});
					selectthisindex = $(this).attr('selectedIndex');//判断通过，可以选择该字段
					if(checkb){
						$('#popupfldtitle').html('');
					}
					ischange = 1;
					return false;
				});
			});

			
			jsonget('getfunctionsjson',
				{modulename:moduleName},
				function(result){
					var functions = $('#editpopup_functions');
					$.each(result, function(label, template){
						functions.append(format('<option value="%s">%s</option>', template, label));
					});
					var notdatefieldval = [];
					var notdatefieldtxt = [];
					$('#editpopup_functions').bind('change', function(){
						var textarea = $('#editpopup_expression').get(0);
						var value = $(this).attr('value');
						//http://alexking.org/blog/2003/06/02/inserting-at-the-cursor-using-javascript
						if (document.selection) {
							textarea.focus();
							var sel = document.selection.createRange();
							sel.text = value;
							textarea.focus();
						}else if (textarea.selectionStart || textarea.selectionStart == '0') {
							var startPos = textarea.selectionStart;
							var endPos = textarea.selectionEnd;
							var scrollTop = textarea.scrollTop;
							textarea.value = textarea.value.substring(0, startPos)
												+ value
												+ textarea.value.substring(endPos,
													textarea.value.length);
							textarea.focus();
							textarea.selectionStart = startPos + value.length;
							textarea.selectionEnd = startPos + value.length;
							textarea.scrollTop = scrollTop;
						}else {
							textarea.value += value;
							textarea.focus();
						}
						// Reset the selected option (to enable next selection)
						//this.value = '';

						/**
						 * 切换使用函数下拉框时，清空表达式窗口
						 * 如果函数选择为相差天数、相差时间，将字段下拉框非时间字段删除
						 * 切换回连接后，恢复下拉框项
						 * @reason 0011078：字段公式中选取计算时间/日期差时左侧的字段名只显示时间日期类型字段
						 * @author Tujt 2014-09-11
						 */
						$('#editpopup_expression').val($(this).val());
						//相差天数、相差时间，设置字段选择框只能是时间字段
						if($(this).val() == 'time_diffdays(a,b)' || $(this).val() == 'time_diff(a,b)'){
							if(notdatefieldval == '') {
								var fieldi = 0;var datatypes = '';var ismetafield = false;
								if(typeof(meta_fieldnames) != 'undefined' && 
										typeof(meta_fielddatatypes) != 'undefined') {
									ismetafield = true;
								}
								var ii = 0;
								$('#editpopup_fieldnames option').each(function(){
									notdatefieldval[ii] = $(this).val();
									notdatefieldtxt[ii ++] = $(this).text();
									if($(this).val() == '') return true;
									if(ismetafield){
										datatypes = meta_fielddatatypes[meta_fieldnames.indexOf($(this).val())];
										if(datatypes.indexOf('D~') > -1){
											return true;
										}else{
											$(this).remove();
										}
									}
								});
							}
						}else{//切换回非相差天数等选项时，还原字段选择下拉框
							if(notdatefieldval != ''){
								$('#editpopup_fieldnames').empty();
								$.each(notdatefieldval, function(jkey,jval){
									$('#editpopup_fieldnames').append('<option value="'+jval+'">'+notdatefieldtxt[jkey]+'</option>');
								});
								notdatefieldval = [];
								notdatefieldtxt = [];
							}
						}
						//默认选中a
						var editcontent = $('#editpopup_expression').val();
						var startIndex = editcontent.indexOf('(');
						selectTextRange('editpopup_expression','a',startIndex);
					});

				}
			);

			var ismote = '';//状态，create or 所编辑的字段值
			return {
				create: function(){
					/**
					 * 创建字段公式时，选中未创建字段公式的第一个字段，清空字段文本域
					 * @reason 0011305 字段公式编辑方式不合理
					 * @author Tujt 2014-09-12
					 */
					ismote = 'create';//标记创建状态
					// 已经创建过字段公式的字段不可被选择，也不可设置为 默认值
					var fieldlist = [];
					$('table.ControlTable1 tr.expressionlistrow').each(function(jkey,jval){
						ids = $(jval).attr('id');
						ids = ids.split('expressionlistrow_');
						ids = ids[1];
						fieldlist[fieldlist.length] = ids;//已创建字段公式的字段，放入数组中，方便判断
					});
					var dindex = -1;
					$('#editpopup_field option').each(function(jkey,jval){//循环字段下拉框
						if(fieldlist.indexOf($(jval).val()) > -1) return true;//字段已经创建过字段公式，跳出当前循环
						dindex = jkey;return false;//未创建字段公式，记录seleceedIndex值
					});
					if(dindex == -1){
						alert(arrJsPopLabel['FIELDFORMULASFIELDCRESTOR']);
						return false;
					}
					selectthisindex = dindex;
					$('#popupfldtitle').html('');
					$('#editpopup_field').attr('selectedIndex',dindex);
					$('#editpopup_functions').attr('selectedIndex',0);
					$("#editpopup_expression").val('');
					show();
				},
				edit: function(field, expression){
					$("#editpopup_field").attr('value', field);
					selectthisindex = $('#editpopup_field').attr('selectedIndex');
					$("#editpopup_expression").attr('value', expression);
					ismote = field;
					$('#popupfldtitle').html('');
					show();
				},
				close:close,
				changeModule: function(moduleName, exprFields, moduleFields){
					var field = $('#editpopup_field');
					field.children().remove();
					$.each(exprFields, function(fieldName, fieldLabel){
						field.append(format('<option value="%s">%s</option>', fieldName, fieldLabel));
					});

					var fieldNames = $('#editpopup_fieldnames');
					fieldNames.children().remove();
					fieldNames.append(format('<option value="">%s</options>', arrJsPopLabel['USINGFIELD']));
					$.each(moduleFields, function(fieldName, fieldLabel){
						/**
						 * 规则选择字段，只显示编辑页面可以看到的字段
						 * @reason 0011076 字段公式无法计算自动生成的日期之间的运算
						 * @author Tujt 2014-09-12
						 */
						if(meta_fieldnames.indexOf(fieldName) > -1)
							fieldNames.append(format('<option value="%s">%s</option>', fieldName, fieldLabel));
					});                    
				}
			};
	}

	$(document).ready(
	    function(){
	    	//Drag.init(document.getElementById('editpopup_draghandle'), document.getElementById('editpopup'));
			toExec();
		}
    );

    function toExec(){
		ep = editpopup();
		function setModule(moduleName){
			$.get('index.php', {
					module:'FieldFormulas',
					action:'FieldFormulasAjax',
					file:'getfieldsjson', ajax:'true',
					modulename:moduleName},
				function(result){
					var parsed = JSON.parse(result);
					ep.changeModule($(this).attr("value"), parsed['exprFields'], parsed['moduleFields']);
					
					$('#new_field_expression_busyicon').hide();
					$('#new_field_expression').show();
					
					if(parsed['exprFields'].length!=0){
						$('#new_field_expression').attr('disabled', false);
						$('#new_field_expression').attr('class', 'createauto b_radius3');
						$('#new_field_expression').bind('click', function(){
							ep.create();
						});
						$('#status_message').html('');
						$('#status_message').hide();
					}else{
					    $('#new_field_expression').hide();
					    $('#status_message').show();
						$('#status_message').html(arrJsPopLabel['YOUNEEDADDSTRINTTYPE'] + ' <a href="index.php?module=Settings&action=LayoutBlockList&parenttab=Settings&formodule='+moduleName+'" target="_blank"> ' + arrJsPopLabel['CUSTOMFIELDS'] +'</a>');
					}

			jsonget('getexpressionlistjson',
				{modulename:moduleName},
				function(result){
				    
					$('#expressionlist_busyicon').hide();
					var exprFields = parsed['exprFields'];
					$('.expressionlistrow').remove();
                    if(result != '')
                    {
    					$.each(result, function(fieldName, expression){
    						var fieldLabel = getfieldlabel(fieldName);
    						if(exprFields[fieldName]){
				                /**
                                 *@edit:andy 
                                 *@date:20140910
                                 *@reason:	0010990: (建议)当字段公式无记录时给出提示信息
                                 *@version:
                                 */
				                type='yes';
    							addFieldExpression(moduleName, fieldName, fieldLabel, expression,type);
    						}else{
    						  	jsonget('deleteexpressionjson',
    						 			{modulename:moduleName, fieldname:fieldName},
    								function(){});
    						}
    
    					});
                    }
                    else
                    {
                        /**
                         *@edit:andy 
                         *@date:20140910
                         *@reason:	0010990: (建议)当字段公式无记录时给出提示信息
                         *@version:
                         */
                        type='none'
                        addFieldExpression('', '', '', '',type);
                    }
				}
			);
			});
			ep.close();


		}

		$('#pick_module').bind('change', function(){
			var moduleName =  $(this).attr("value");
			setModule(moduleName);
		});
		setModule($('#pick_module').attr('value'));



	};
}
editexpressionscript(jQuery);


/**
 * textarea 选中指定的值
 * @param String areaId textarea 的 id
 * @param String searchText textarea文本框中需要选中的内容
 * @author Tujt 2014-08-20
 */
var selectTextRange = function(areaId,searchText,started){
	var obj = document.getElementById(areaId);
	var endIndex = 0;
	if(started && started > 0){
		var startIndex = obj.value.indexOf(searchText,started);
	}else{
		var startIndex = obj.value.indexOf(searchText);
	}
	if(startIndex == -1) return false;//未找到
	endIndex = startIndex + searchText.length;
	if(typeof obj.createTextRange != 'undefined'){//狗血的IE浏览器
		var range = obj.createTextRange();
		//先将光标重合
		range.moveStart('character', 0);
		range.moveEnd('character', 0);
		range.collapse(true);
		range.moveEnd('character', endIndex);
		range.moveStart('character', startIndex);
		range.select();
	}else{//Firefox、Chrome、Opera
		obj.focus();
		obj.selectionStart = startIndex;
		obj.selectionEnd = endIndex;
	}
}
