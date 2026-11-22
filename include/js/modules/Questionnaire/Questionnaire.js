// @edit:liushuai,2021-04-28,reason:【ID1001572】增加【调查问卷】模块-第一版
function Questionnaire(topics,status,duplicate) {
	// h5pageurl的uitype类型不能选择网址 否则系统会自动去去掉http或https  general.js:1313  validateUrl()
	var that = this;
	var popupobj = CrmPopup.getPopupObj("last");
	module = popupobj.module;
	step = parseInt(CrmPopup.findHtmlobj(popupobj.divid, 'step').val());
	divs = ld('#' + popupobj.divid + ' .stepContent');
	multi_step = ld('#' + popupobj.divid + ' .multi-step .step');
	record = ld('#' + popupobj.divid + ' [name=record]').val();

	this.swithStep = function () {
		switch (step) { //step不是当前步骤，而是前一步骤
			case 0:
				step++;
				ld('#' + popupobj.divid + ' [name=step]').val(step);
				//事件 - 第二步 - 结束语设置
				that.bindChangeEvent();
				that.hiddenDiv(step);
				that.changStep(step);
				// 重置窗口位置
				popupobj.center();
				break;
			case 1:  //第一步
				if (!emptyCheck('name', arrJsPopLabel['QuestionnaireName'], 'text')) {
					return false;
				}
				if (ld('#'+popupobj.divid+' #step1 [name=recovery_settings]').is(":checked")) {
					var recovery_endtime = ld('#'+popupobj.divid+' #step1 [name=recovery_endtime]').val();
					// if (new Date(recovery_endtime) < new Date()) { //这样也可以，不过时间戳比较直观
					if (new Date(recovery_endtime).getTime() < new Date().getTime()) {
						audioRemindsMsg("", "", "", "", "", arrJsPopLabel['CannotLessCurrentTime']);
						return false;
					}
				}
				that.savequestionnaire();

				step++;


				// 显示上一步
				ld('#' + popupobj.divid + '_btnBack').show();
				ld('#' + popupobj.divid + ' [name=step]').val(step);

				// 事件 - 第一步 - 问卷标题、描述
				that.bindChangeEvent();

				that.hiddenDiv(step);
				that.changStep(step);
				// 重置窗口位置
				popupobj.center();

				break;
			case 2: //第二步
				var topic_row_cnt = 0;
				ld.each(CrmPopup.findHtmlobj(popupobj.divid,'topic_row_cnt'),function(index,row_cnt_obj){
					topic_row_cnt = topic_row_cnt + parseInt(row_cnt_obj.value);
				});
				if (topic_row_cnt < 1) {
					audioRemindsMsg("", "", "", "", "", arrJsPopLabel['AddTopicReminder']);
					return false;
				}

				// 生成外部访问静态单据页面
				that.createHtml(popupobj.record);

				//最后生成二维码等
				that.lastStepFunction(popupobj.record);

				step++;
				ld('#' + popupobj.divid + ' [name=step]').val(step);

				// 显示上一步
				ld('#' + popupobj.divid + '_btnBack').show();
				//问卷结束语的富文本编辑框
				if (that.ue == undefined){
					that.ue = UE.getEditor('recovery_endremarks');
					// that.ue.focus();
					that.ue.ready(function() {
						var id = ld('#recovery_endremarks').children("div:first-child").attr("id");
						ld('#'+id).css('z-index','99999');
						popupobj.center();
					},2);
					// UE.getEditor('recovery_endremarks').getContent();
					// UE.getEditor('recovery_endremarks').focus();
				}

				//事件 - 第二步 - 结束语设置
				that.bindChangeEvent();
				that.hiddenDiv(step);
				that.changStep(step);
				// 重置窗口位置
				popupobj.center();

				break;
			case 3:
				//结束语不能为空
				var formValues = ld('#' + popupobj.divid + ' [name=EditView]');
				var recovery_endremarks_test = formValues.find('[name=recovery_endremarks]').get(0).value;
				if(empty(recovery_endremarks_test)){
					MessagePopup.TipZero_warning(arrJsPopLabel['recoveryendremarksnoempty']);
					break;
				}
				step++;
				ld('#' + popupobj.divid + ' [name=step]').val(step);


				//事件 - 第三步- 完成（生成二维码等）
				that.bindChangeEvent();

				//保存数据 关闭弹窗
				that.save();
				// SaveDataRecord.save();

				that.hiddenDiv(step);
				that.changStep(step);
				popupobj.center();
				break;
			default:
				break;
		}
	}

	//上一步
	this.CreateBackStep = function() {
		// console.log('CreateBackStep:'+step);
		step--;
		if(step==1){
			ld('#'+popupobj.divid+ '_btnBack').hide();
		}
		ld('#'+popupobj.divid+' [name=step]').val(step);
		that.hiddenDiv(step);
		that.changStep(step);
		popupobj.center();
	}
	this.hiddenDiv = function () {
		for (var i = 0; i < divs.length; i++) {
			if (step == i + 1) {
				divs.eq(i).show()
			} else {
				divs.eq(i).hide()
			}
		}
	}
	this.changStep = function () {
		for (var i = 0; i < multi_step.length; i++) {
			if (step == i + 1) {
				multi_step.eq(i).addClass('current')
			} else if (i + 1 < step) {
				multi_step.eq(i).addClass('completed')
			}else if(i+1>step){
				//所有步骤大于当前步骤的去除class
				multi_step.eq(i).removeClass('completed').removeClass('current')
			}
		}
	}

	//绑定事件
	this.bindChangeEvent = function () {
		//上一步
		ld('#'+popupobj.divid+'_btnBack').unbind('click').bind('click',function () {
			that.CreateBackStep();
		})

		if(step == 1) { // 预览
			//问卷名称
			ld('#' + popupobj.divid + ' #step1 [name=name]').unbind('keyup').bind('keyup', function () {
				ld('#' + popupobj.divid + ' .preview #show_title').text(ld(this).val());
			});
			//问卷描述
			ld('#' + popupobj.divid + ' #step1  [name=description]').unbind('keyup').bind('keyup', function () {
				ld('#' + popupobj.divid + ' #show_introduction').text(ld(this).val());
			});
			//回收时间设置
			ld('#' + popupobj.divid + ' #step1  [name=recovery_settings]').unbind('click').bind('click', function () {
				that.showdate(this);
			});
		}
		if(step == 2){
			Sortable.create(ld("#"+popupobj.divid+" #LayoutBlockContent").get(0), {
				draggable:".blocks",
				handle: '.drag-handle',
				onUpdate: function (evt){
					var sequence_array = [];
					ld.each(evt.target.children,function(index,blocksobj){
						if(index > 0){
							sequence_array.push(blocksobj.getAttribute('blockid'));
						}
					})
					var ajaxurl = 'index.php?module=Questionnaire&action=QuestionnaireAjax&file=Quesnaire_LayoutBlock&sub_mode=moveBlockOrder&record='+popupobj.record+'&sequence='+sequence_array;
					ldAjax(ajaxurl, '', function (data) {
						that.getLayoutBlock();
					})
				}
			})
		}
		if(step == 3){

		}
		if(step == 4){
			//隐藏上一步 和取消按钮按钮 并绑定关闭事件
			ld('#'+popupobj.divid+'_btnok').unbind('click').bind('click',function () {
				popupobj.CancelEvent();
			});
			ld('#'+popupobj.divid+ '_btnBack').hide();
			ld('#'+popupobj.divid+ '_btncancel').hide();
			ld('#'+popupobj.divid+ '_btnok').val(arrJsPopLabel['FINISHED']);  //完成
		}
	}

	//新建区块
	this.addquestionnaireblock = function (blockid) {
		var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=Create_LayoutBlockTopic&record='+popupobj.record+'&blockid='+blockid;

		var crmPopupobj=CrmPopup.load("","","","LdPopWidth600px",'Settings',"","","","");
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,'',function(data){
			if(data.code==1){
				crmPopupobj.setParams(data.result.title,that.saveBlock,"","LdPopWidth600px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
				crmPopupobj.createScrollDiv();
				crmPopupobj.show(data.result.content);
				that.Bindaddquestionnaireblock();
			}
		})
	}

	//新建区块绑定事件
	this.Bindaddquestionnaireblock = function (){
		var addblock_popupobj = CrmPopup.getPopupObj("last");
		ld('#'+addblock_popupobj.divid+' #automatic_number').unbind('click').on('click',function(){
			if(ld(this).get(0).checked){
				ld('#'+addblock_popupobj.divid+' #automatic_number_style_tr').show();
				ld('#'+addblock_popupobj.divid+' #automatic_number_postfix_tr').show();
			}else{
				ld('#'+addblock_popupobj.divid+' #automatic_number_style_tr').hide();
				ld('#'+addblock_popupobj.divid+' #automatic_number_postfix_tr').hide();
			}
		});
	}

	//保存区块
	this.saveBlock = function () {
		var addblock_popupobj = CrmPopup.getPopupObj("last");
		var block_name = ld('#'+addblock_popupobj.divid+' #block_name').get(0).value;
		var block_type = ld('#'+addblock_popupobj.divid+' #blocktype').get(0).value;
		if(block_type == 'virtual'){
			block_name = 'virtual';
		}
		if(block_name.replace(/^\s+/g, '').replace(/\s+$/g, '').length==0)
		{
			//alert('区块中文名称不能为空');
			var confirm_str = arrJsPopLabel['BLOCKCHINESENAMECANNOTBEEMPTY']+'!';
			RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
			return false;
		}
		var tem_blockid = ld('#'+addblock_popupobj.divid+' #blockid').get(0).value;
		if(block_type != 'virtual'){
			var after_blockid = ld('#'+addblock_popupobj.divid+' #after_blockid').get(0).value;
		}else{
			var after_blockid = 0;
		}

		var ajaxurl = 'index.php?module=Questionnaire&action=QuestionnaireAjax&file=Quesnaire_LayoutBlock&sub_mode=addBlock&record='+popupobj.record+'&blockid='+tem_blockid+'&blockname='+block_name+'&afterblockid='+after_blockid;

		if(ld('#'+addblock_popupobj.divid+' #automatic_number').get(0).checked){
			var automatic_number_style = ld('#'+addblock_popupobj.divid+' #automatic_number_style').get(0).value;
			var automatic_number_postfix = ld('#'+addblock_popupobj.divid+' #automatic_number_postfix').get(0).value;

			ajaxurl += '&automatic_number=yes&automatic_number_style='+automatic_number_style+'&automatic_number_postfix='+automatic_number_postfix;
		}else{
			ajaxurl += '&automatic_number=no';
		}

		ldAjax(ajaxurl, '', function (data) {
			addblock_popupobj.CancelEvent();
			that.getLayoutBlock();
		})
	}

	//删除区块
	this.deletequestionnaireblock = function (blockid){
		var delete_str = arrJsPopLabel['DELETEQUESTIONNAIREBLOCK'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",delete_str);
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){

			var ajaxurl = 'index.php?module=Questionnaire&action=QuestionnaireAjax&file=Quesnaire_LayoutBlock&sub_mode=deleteBlock&blockid='+blockid;
			ldAjax(ajaxurl, '', function (data) {
				if(data.code == 2){
					var msg_str = arrJsPopLabel['CANTDELETEBLOCK'];
					RemindsMsg("","LdPopWidth400px","","yes","",msg_str);
				}else if(data.code == 1){
					that.getLayoutBlock();
				}
			})
		})
	}

	//获取区块、题目信息
	this.getLayoutBlock = function () {
		var ajaxurl = 'index.php?module=Questionnaire&action=QuestionnaireAjax&file=Quesnaire_LayoutBlock&sub_mode=getlayoutblock&record='+popupobj.record;
		ldAjax(ajaxurl, '', function (data) {
			ld('#'+popupobj.divid+' #LayoutBlockContent').html(data.result.content);
			ld('#rptContentLoading').hide();
		})
	}
	this.change_Block_Order = function(movetype,blockid){
		ld('#rptContentLoading').show();
		var selfobj = ld("#"+popupobj.divid+" #block_"+blockid);
		var ajaxurl = '';
		if(movetype == 'moveUp'){
			var prevobj = ld("#"+popupobj.divid+" #block_"+blockid).prev();
			var previd = prevobj.get(0).getAttribute('blockid');
			ajaxurl = 'index.php?module=Questionnaire&action=QuestionnaireAjax&file=Quesnaire_LayoutBlock&sub_mode=changeBlockOrder&blockid='+blockid+'&changeid='+previd;
		}else if(movetype == 'moveDown'){
			var nextobj = ld("#"+popupobj.divid+" #block_"+blockid).next();
			var nextid = nextobj.get(0).getAttribute('blockid');
			ajaxurl = 'index.php?module=Questionnaire&action=QuestionnaireAjax&file=Quesnaire_LayoutBlock&sub_mode=changeBlockOrder&blockid='+blockid+'&changeid='+nextid;
		}
		ldAjax(ajaxurl,'',function(data){
			that.getLayoutBlock();
		})
	}
	//题目 上移、下移
	this.change_Topic_Order = function(movetype,blockid,topicid){
		var selfobj = ld("#"+popupobj.divid+" #block_"+blockid+" #topicid_"+topicid);
		var rowindex = selfobj.get(0).getAttribute('rowindex');
		if(movetype == 'moveUp'){
			var prevobj = ld("#"+popupobj.divid+" #block_"+blockid+" #topicid_"+topicid).prev();
			var previd = prevobj.get(0).getAttribute('topicid');
			var ajaxurl = 'index.php?module=Questionnaire&action=QuestionnaireAjax&file=Quesnaire_LayoutBlock&sub_mode=changeTopicOrder&blockid='+blockid+'&topicid='+topicid+'&changeid='+previd;
			ldAjaxNoProgress(ajaxurl,'',function(data){
				prevobj.before(selfobj.prop('outerHTML'));
				selfobj.remove();
				var old_rowindex = prevobj.get(0).getAttribute('rowindex');
				prevobj.attr('rowindex',rowindex);
				ld("#"+popupobj.divid+" #block_"+blockid+" #topicid_"+topicid).attr('rowindex',old_rowindex);
				that.QuestionTopicSort(blockid);
			})
		}else if(movetype == 'moveDown'){
			var nextobj = ld("#"+popupobj.divid+" #block_"+blockid+" #topicid_"+topicid).next();
			var nextid = nextobj.get(0).getAttribute('topicid');
			var ajaxurl = 'index.php?module=Questionnaire&action=QuestionnaireAjax&file=Quesnaire_LayoutBlock&sub_mode=changeTopicOrder&blockid='+blockid+'&topicid='+topicid+'&changeid='+nextid;
			ldAjaxNoProgress(ajaxurl,'',function(data){
				nextobj.after(selfobj.prop('outerHTML'));
				selfobj.remove();
				var old_rowindex = nextobj.get(0).getAttribute('rowindex');
				nextobj.attr('rowindex',rowindex);
				ld("#"+popupobj.divid+" #block_"+blockid+" #topicid_"+topicid).attr('rowindex',old_rowindex);
				that.QuestionTopicSort(blockid);
			})
		}
	}

	//添加题目 
	this.addQuestionTopic = function(blockid,topicid){
		var surl = 'index.php?module='+module+'&action='+module+'Ajax&file=addQuestionTopic&blockid='+blockid+'&topicid='+topicid;

		var mode = 'create';
		var topic_json_array = [];

		if(topicid>0) {
			mode = 'edit';
			topic_json_array = ld('#'+popupobj.divid+' #block_'+blockid+' #topic_json_'+topicid).get(0).value;
		}

		var rel_surl = 'topic_json='+topic_json_array;

		var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Settings',"","","","");
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,rel_surl,function(data){
			if(data.code==1){
				crmPopupobj.setParams(data.result.title,that.saveQuestionTopic,"","LdPopWidth800px",'Settings',"",data.result.oktext,"",data.result.canceltext,"");
				crmPopupobj.createScrollDiv();
				crmPopupobj.show(data.result.content);
				crmPopupobj.setPopBodyMaxHeight("#"+crmPopupobj.divid+"_scroll");
				that.BindAddQuestionTopic();
				that.BindDeleteQuestionTopicTr();

				var selectobj=ld("#topic_referencemodule");
				if(selectobj.length>0&&selectobj!=undefined){
					var cls_resetComboxHtmlobj=new cls_resetComboxHtml(selectobj.attr("name"));
					var popupobj=CrmPopup.getPopupObj('last');
					cls_resetComboxHtmlobj.setPopupObj(popupobj);
					cls_resetComboxHtmlobj.setSearchComboxWidthByhtml(selectobj,460);
				}
			}

		})
	}

	//删除题目
	this.deletedTopic = function(blockid,topicid){
		var rowindex = ld("#"+popupobj.divid+" #block_"+blockid+" #topicid_"+topicid).get(0).getAttribute('rowindex');
		var delete_str = arrJsPopLabel['DELETEDTOPICEDIT'];
		RemindsMsg("","LdPopWidth400px","","yes","yes",delete_str);
		ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){

			var ajaxurl = 'index.php?module=Questionnaire&action=QuestionnaireAjax&file=Quesnaire_LayoutBlock&sub_mode=deleteTopic&topicid='+topicid;
			ldAjax(ajaxurl, '', function (data) {
				ld("#"+popupobj.divid+" #block_"+blockid+" #topicid_"+topicid).remove();//hide()
				//1 表示表头行
				var topic_row_cnt = ld("#"+popupobj.divid+" #block_"+blockid+" [name=topic_row_cnt]").get(0).value;
				if(topic_row_cnt == 1){
					ld("#"+popupobj.divid+" #block_"+blockid+" [name=topic_table]").find("[rowindex=1]").show();
					ld("#"+popupobj.divid+" #block_"+blockid+" [name=topic_table]").find("[rowindex=2]").show();
				}

				//删除行数-1
				ld("#"+popupobj.divid+" #block_"+blockid+" [name=topic_row_cnt]").val(topic_row_cnt-1);//topic_row_cnt--
				that.QuestionTopicSort(blockid);//重新排序
			})
		})
	}

	this.htmlspecialchars = function(str) {
		str = str.replace(/&/g, '&amp;');
		str = str.replace(/</g, '&lt;');
		str = str.replace(/>/g, '&gt;');
		str = str.replace(/"/g, '&quot;');
		str = str.replace(/'/g, '&#039;');
		// return encodeURIComponent(str);
		return str;
	}
	//保存题目
	this.saveQuestionTopic = function(){
		//console.log(add_popupobj.divid);
		var add_popupobj = CrmPopup.getPopupObj("last");
		var topic_type = ld("#"+add_popupobj.divid+" [name=topic_type]").val();	//题目类型
		var topic_id = ld("#"+add_popupobj.divid+" [name=topic_id]").val();
		var mode = 'create';
		if(topic_id>0){
			mode = 'edit';
		}
		var topic_json = ld("#"+add_popupobj.divid+" [name=topic_json]").val();
		var topic_type_label = ld("#"+add_popupobj.divid+" [name=topic_type]").find("option:selected").text();
		if(mode == 'edit'){
			topic_type_label = ld("#"+add_popupobj.divid+" [name=topic_type_label]").text();
		}
		var cur_rowindex = ld("#"+add_popupobj.divid+" [name=rowindex]").val();

		var topic_description = '';	//备注
		var required = 'no'
		var required_label = arrJsPopLabel['NO'];
		var topic_option_array = [];
		var _type = 0;
		var topic_other_info = {};
		if(topic_type == 'text'){
			//描述
			var topic_name = ld("#"+add_popupobj.divid+" [name=text_textarea]").val();
			if(topic_name == ''){
				var str = ld("#"+add_popupobj.divid+" [name=text_textarea]").attr('label') + arrJsPopLabel['CANOTEMPTYGTH'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",str);
				return false;
			}
			required = 'no';
			required_label = arrJsPopLabel['NO'];
			_type = 1;
		}else if(topic_type == 'one' || topic_type == 'more'){
			//题目名称

			_type =  1;
			var topic_name = ld("#"+add_popupobj.divid+" [name=topic_name]").val();
			if(topic_name == ''){
				var str = ld("#"+add_popupobj.divid+" [name=topic_name]").attr('label') + arrJsPopLabel['CANOTEMPTYGTH'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",str);
				return false;
			}
			topic_description = that.htmlspecialchars(ld("#"+add_popupobj.divid+" [name=topic_description]").val());
			if(ld("#"+add_popupobj.divid+" [name=required]").prop("checked")){
				required = 'yes';
				required_label = arrJsPopLabel['YES'];
			}
			var trobjs =ld("#"+add_popupobj.divid+" [name=sortable]").find("tr");
			ld.each(trobjs,function(tmpindex,tmprowobj){
				var dispaly_type = ld(tmprowobj).css('display');
				if(dispaly_type != 'none'){
					var topic_optionid = ld(tmprowobj).find('[name=topic_content]').attr('optionid');

					var topic_content = ld(tmprowobj).find('[name=topic_content]').val();
					if(topic_content == ''){
						RemindsMsg("","LdPopWidth400px","","yes","yes",arrJsPopLabel['Optioncannotbeempty']);
						_type = 0;
						return false;

					}
					topic_content = that.htmlspecialchars(topic_content);

					if (empty(topic_optionid)){
						topic_optionid=0;
					}
					topic_option_array.push({'optionid':topic_optionid,'value':topic_content});
				}
			});

		}else if(topic_type == 'Singleline' || topic_type == 'Multiline'){
			//题目名称

			_type =  1;
			var topic_name = ld("#"+add_popupobj.divid+" [name=topic_name]").val();
			if(topic_name == ''){
				var str = ld("#"+add_popupobj.divid+" [name=topic_name]").attr('label') + arrJsPopLabel['CANOTEMPTYGTH'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",str);
				return false;
			}
			topic_description = that.htmlspecialchars(ld("#"+add_popupobj.divid+" [name=topic_description]").val());
			if(ld("#"+add_popupobj.divid+" [name=required]").prop("checked")){
				required = 'yes';
				required_label = arrJsPopLabel['YES'];
			}
		}else if(topic_type == 'tel'){
			//题目名称

			_type =  1;
			var topic_name = ld("#"+add_popupobj.divid+" [name=topic_name]").val();
			if(topic_name == ''){
				var str = ld("#"+add_popupobj.divid+" [name=topic_name]").attr('label') + arrJsPopLabel['CANOTEMPTYGTH'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",str);
				return false;
			}
			topic_description = that.htmlspecialchars(ld("#"+add_popupobj.divid+" [name=topic_description]").val());
			if(ld("#"+add_popupobj.divid+" [name=required]").prop("checked")){
				required = 'yes';
				required_label = arrJsPopLabel['YES'];
			}
			if(ld("#"+add_popupobj.divid+" [name=topic_fieldonly]").prop("checked")){
				topic_fieldonly = 1;
			}
			var telregexp = 'no';
			if(ld("#"+add_popupobj.divid+" [name=telregexp]").prop("checked")){
				telregexp = 'yes';
			}
			topic_other_info['fieldonly'] = topic_fieldonly;
			topic_other_info['telregexp'] = telregexp;
		}else if(topic_type == 'SelectBill'){
			_type =  1;
			var topic_name = ld("#"+add_popupobj.divid+" [name=topic_name]").val();
			if(topic_name == ''){
				var str = ld("#"+add_popupobj.divid+" [name=topic_name]").attr('label') + arrJsPopLabel['CANOTEMPTYGTH'];
				RemindsMsg("","LdPopWidth400px","","yes","yes",str);
				return false;
			}
			topic_description = that.htmlspecialchars(ld("#"+add_popupobj.divid+" [name=topic_description]").val());
			if(ld("#"+add_popupobj.divid+" [name=required]").prop("checked")){
				required = 'yes';
				required_label = arrJsPopLabel['YES'];
			}
			//关联选择单据 问题属性
			var topic_referencemodule = ld("#"+add_popupobj.divid+" [name=topic_referencemodule]").val();
			var topic_APPROVEDEMAND = ld("#"+add_popupobj.divid+" [name=topic_APPROVEDEMAND]").val();
			var topic_MaxRowsShow = ld("#"+add_popupobj.divid+" [name=topic_MaxRowsShow]").val();
			var topic_fieldonly = 0;
			if(ld("#"+add_popupobj.divid+" [name=topic_fieldonly]").prop("checked")){
				topic_fieldonly = 1;
			}
			var topic_advance_demand = ld("#"+add_popupobj.divid+" [name=topic_advance_demand]").val();
			var topic_advance_demand_groups = ld("#"+add_popupobj.divid+" [name=topic_advance_demand_groups]").val();

			topic_other_info['referencemodule'] = topic_referencemodule;
			topic_other_info['approvedemand'] = topic_APPROVEDEMAND;
			topic_other_info['maxrowsshow'] = topic_MaxRowsShow;
			topic_other_info['fieldonly'] = topic_fieldonly;
			if(topic_advance_demand==''){
				topic_other_info['advance_demand'] = [];
			}else{
				topic_other_info['advance_demand'] = JSON.parse(topic_advance_demand);
			}
			if(topic_advance_demand_groups == ''){
				topic_other_info['advance_demand_groups'] = [];
			}else {
				topic_other_info['advance_demand_groups'] = JSON.parse(topic_advance_demand_groups);
			}
		}

		var topic_content_array = {
			'topic_id' : topic_id,
			'topic_type' : topic_type,
			'topic_name' : that.htmlspecialchars(topic_name),
			'topic_description' : topic_description,
			'required' : required,
			'topic_option_array' : topic_option_array,
			'topic_other_info' : topic_other_info
		}
		if(_type == 1){
			var topic_content_json = JSON.stringify(topic_content_array);

			var tem_blockid = ld('#'+add_popupobj.divid+' #blockid').get(0).value;
			var ajaxurl = 'index.php?module=Questionnaire&action=QuestionnaireAjax&file=Quesnaire_LayoutBlock&sub_mode=addTopic&record='+popupobj.record+'&blockid='+tem_blockid;
			var rel_ajaxurl = 'topic_json='+encodeURIComponent(topic_content_json);
			ldAjax(ajaxurl, rel_ajaxurl, function (data) {
				topic_content_json = data.result.topic_array;
				topic_id = data.result.topicid
				if(mode == 'create'){
					var rownum = ld("#"+popupobj.divid+" #block_"+tem_blockid+" [name=topic_table]").find("tr").length;
					ld("#"+popupobj.divid+" #block_"+tem_blockid+" [name=topic_row_cnt]").val(parseInt(rownum) - 1);
					var rowindex = parseInt(rownum) + 1;
				}else{
					var rowindex = ld("#"+popupobj.divid+" #block_"+tem_blockid+" #topicid_"+topic_id).get(0).getAttribute('rowindex');
				}

				var question_topic_tr = '';
				if(mode == 'create'){
					question_topic_tr = '<tr rowindex="'+rowindex+'" id="topicid_'+topic_id+'" topicid="'+topic_id+'">';
				}
				question_topic_tr += '<input type="hidden" name="topic_json_'+topic_id+'" id="topic_json_'+topic_id+'" value=\''+topic_content_json+'\'>';
				question_topic_tr += '<td width="50%" align="center">'+topic_name+'</td>';
				question_topic_tr += '<td width="20%" align="center">'+topic_type_label+'</td>';
				question_topic_tr += '<td width="10%" align="center">'+required_label+'</td>';
				question_topic_tr += '<td width="20%" align="center">';
				question_topic_tr += '<b class="icon-homeimg icon-pen" name="edit_topic" topicid="'+topic_id+'" onclick="cls_questionnaire.addQuestionTopic('+tem_blockid+','+topic_id+')" style="cursor: pointer;margin-bottom: 4px;margin-right: 6px;"></b> ';
				question_topic_tr += '<b class="icon-up" name="moveUp" onclick="cls_questionnaire.change_Topic_Order(\'moveUp\','+tem_blockid+','+topic_id+')" style="display: none"></b> ';
				question_topic_tr += '<b class="icon-down" name="moveDown" onclick="cls_questionnaire.change_Topic_Order(\'moveDown\','+tem_blockid+','+topic_id+')" style="display: none"></b> ';
				question_topic_tr += '<b class="icon-delete" name="delete_topic" onclick="cls_questionnaire.deletedTopic('+tem_blockid+','+topic_id+')"></b>';
				question_topic_tr += '</td>';
				if(mode == 'create'){
					question_topic_tr += '</tr>';
				}
				ld("#"+popupobj.divid+" #block_"+tem_blockid+" [name=topic_table] > tbody > tr:eq(1)").hide();

				if(mode == 'edit'){	//修改题目
					ld("#"+popupobj.divid+" #block_"+tem_blockid+" #topicid_"+topic_id).html(question_topic_tr);
				}else{	//新增题目
					ld("#"+popupobj.divid+" #block_"+tem_blockid+" [name=topic_table]").find("tr:last").after(question_topic_tr);
				}

				add_popupobj.CancelEvent();
				that.QuestionTopicSort(tem_blockid);//重新排序
				ld('#rptContentLoading').hide();
			})
		}
	}
	this.saveQuestionTopic.funname = "this.saveQuestionTopic";

	//题目重新序列化上下移动按钮
	this.QuestionTopicSort = function(blockid){
		var trobjs =ld("#"+popupobj.divid+" #block_"+blockid+" [name=topic_table]").find("tr");
		var row_array = [];
		ld.each(trobjs,function(tmpindex,tmprowobj){
			var dispaly_type = ld(tmprowobj).css('display');
			var rowindex = ld(tmprowobj).attr('rowindex');
			var topicid = ld(tmprowobj).attr('topicid');
			if(rowindex > 2){
				if(dispaly_type != 'none'){
					row_array.push(topicid);
				}
			}
		});
		if(!empty(row_array)){
			if(row_array.length == 1){
				ld.each(row_array,function(tmpindex,topicid){
					ld("#"+popupobj.divid+" #block_"+blockid+" [name=topic_table] #topicid_"+topicid).find('[name=moveUp]').hide();
					ld("#"+popupobj.divid+" #block_"+blockid+" [name=topic_table] #topicid_"+topicid).find('[name=moveDown]').hide();
				});
			}else{
				var _sort = 1;
				ld.each(row_array,function(tmpindex,topicid){
					if(_sort == 1){
						ld("#"+popupobj.divid+" #block_"+blockid+" [name=topic_table] #topicid_"+topicid).find('[name=moveUp]').hide();
						ld("#"+popupobj.divid+" #block_"+blockid+" [name=topic_table] #topicid_"+topicid).find('[name=moveDown]').show();
					}else{
						if(_sort == row_array.length){
							ld("#"+popupobj.divid+" #block_"+blockid+" [name=topic_table] #topicid_"+topicid).find('[name=moveUp]').show();
							ld("#"+popupobj.divid+" #block_"+blockid+" [name=topic_table] #topicid_"+topicid).find('[name=moveDown]').hide();
						}else{
							ld("#"+popupobj.divid+" #block_"+blockid+" [name=topic_table] #topicid_"+topicid).find('[name=moveUp]').show();
							ld("#"+popupobj.divid+" #block_"+blockid+" [name=topic_table] #topicid_"+topicid).find('[name=moveDown]').show();
						}
					}
					_sort++;
				});
			}
			// alert(row_array.length);
		}
	}

	//添加题目界面事件绑定
	this.BindAddQuestionTopic = function(){
		var add_popupobj = CrmPopup.getPopupObj("last");

		var text_textareaobj = ld("#"+add_popupobj.divid+" #text_textarea");
		if(text_textareaobj.length>0){
			add_popupobj.oCKeditor = '';
			var tmpokeditor = UE.getEditor('text_textarea');
			add_popupobj.oCKeditor = tmpokeditor;
			add_popupobj.oCKeditor.ready(function() {
				var id=ld('#text_textarea').children("div:first-child").attr("id");
				ld('#'+id).css('z-index','99999');
				add_popupobj.center();
			},2);
		}
		var tableobj = ld("#"+add_popupobj.divid+" [name=sortable]");
		var tbody=ld(tableobj).find("tbody").get(0);
		Sortable.create(tbody,{
			//	animation: 500,
			handle: '.drag-handle',
			draggable: ".dragtrrow",  //  // 允许拖拽的项目类名,否则会拖拽到小计行
			onEnd: function (evt) {	//移动行
				//拖动后的执行操作
			}
		});
		//添加行
		ld("#"+add_popupobj.divid+" [name=add_question_tr]").unbind('click').on('click',function(){
			var rowcnt =ld("#"+add_popupobj.divid+" [name=sortable]").find("tr").length;
			var drag_handle_label = ld("#"+add_popupobj.divid+" [name=drag_handle_label]").val();
			var rowid = eval(rowcnt) + 1;
			var addrowid = eval(rowcnt) - 1;
			var rowhtml = '<tr class="ld-form-item dragtrrow" rowindex="'+rowid+'">';
			rowhtml += '<td class="ld-form-item-label" align="right">';
			rowhtml += '<span class="drag-handle icon-layout2 icon-layout2-move" title="'+drag_handle_label+'" style="cursor:move;"></span>';
			rowhtml += '</td>';
			rowhtml += '<td class="ld-form-item-content" ">';
			rowhtml += '<input name="topic_content" type="text" value="" class="ld-input-inner" style="width: 430px"/>&nbsp;<a class="icon-homeimg icon-sdel" style="cursor: pointer;" name="del_question_tr" tag="'+rowid+'" title="'+arrJsPopLabel['DELETE']+'"></a>';
			rowhtml += '</td></tr>';
			if(ld("#"+add_popupobj.divid+" [name=sortable] > tbody > tr").length > 0){
				ld("#"+add_popupobj.divid+" [name=sortable] > tbody > tr:eq("+eval(addrowid)+")").after(rowhtml);
			}else{
				ld("#"+add_popupobj.divid+" [name=sortable] > tbody").html(rowhtml);
			}
			var popupobj = CrmPopup.getPopupObj('last');
			popupobj.setPopBodyMaxHeight("#"+popupobj.divid+"_scroll");
			that.BindDeleteQuestionTopicTr();
		});
		//选择题目类型
		ld("#"+add_popupobj.divid+" [name=topic_type]").unbind('change').on('change',function(){
			if(ld(this).val() == 'text'){
				ld("#"+add_popupobj.divid+" [name=tr_topic_text]").show();
				ld("#"+add_popupobj.divid+" [name=tr_topic_name]").hide();
				ld("#"+add_popupobj.divid+" [name=tr_topic_description]").hide();
				ld("#"+add_popupobj.divid+" [name=tr_required]").hide();
				ld("#"+add_popupobj.divid+" [name=sortable]").hide();
				ld("#"+add_popupobj.divid+" [name=add_question_table]").hide();
				ld("#"+add_popupobj.divid+" [name=tr_topic_referencemodule]").hide();
				ld("#"+add_popupobj.divid+" [name=tr_topic_fieldonly]").hide();
				ld("#"+add_popupobj.divid+" [name=tr_telregexp]").hide();
			}else if(ld(this).val() == 'Singleline' || ld(this).val() == 'Multiline'){
				ld("#"+add_popupobj.divid+" [name=tr_topic_text]").hide();
				ld("#"+add_popupobj.divid+" [name=tr_topic_name]").show();
				ld("#"+add_popupobj.divid+" [name=tr_topic_description]").show();
				ld("#"+add_popupobj.divid+" [name=tr_required]").show();
				ld("#"+add_popupobj.divid+" [name=sortable]").hide();
				ld("#"+add_popupobj.divid+" [name=add_question_table]").hide();
				ld("#"+add_popupobj.divid+" [name=tr_topic_referencemodule]").hide();
				ld("#"+add_popupobj.divid+" [name=tr_topic_fieldonly]").hide();
				ld("#"+add_popupobj.divid+" [name=tr_telregexp]").hide();
			}else if(ld(this).val() == 'SelectBill'){
				ld("#"+add_popupobj.divid+" [name=tr_topic_text]").hide();
				ld("#"+add_popupobj.divid+" [name=tr_topic_name]").show();
				ld("#"+add_popupobj.divid+" [name=tr_topic_referencemodule]").show();
				ld("#"+add_popupobj.divid+" [name=tr_topic_fieldonly]").show();
				ld("#"+add_popupobj.divid+" [name=tr_topic_description]").show();
				ld("#"+add_popupobj.divid+" [name=tr_required]").show();
				ld("#"+add_popupobj.divid+" [name=sortable]").hide();
				ld("#"+add_popupobj.divid+" [name=add_question_table]").hide();
				ld("#"+add_popupobj.divid+" [name=tr_telregexp]").hide();
			}else if(ld(this).val() == 'tel'){
				ld("#"+add_popupobj.divid+" [name=tr_topic_text]").hide();
				ld("#"+add_popupobj.divid+" [name=tr_topic_name]").show();
				ld("#"+add_popupobj.divid+" [name=tr_topic_referencemodule]").hide();
				ld("#"+add_popupobj.divid+" [name=tr_topic_fieldonly]").show();
				ld("#"+add_popupobj.divid+" [name=tr_topic_description]").show();
				ld("#"+add_popupobj.divid+" [name=tr_required]").show();
				ld("#"+add_popupobj.divid+" [name=sortable]").hide();
				ld("#"+add_popupobj.divid+" [name=add_question_table]").hide();
				ld("#"+add_popupobj.divid+" [name=tr_telregexp]").show();
			}else{
				ld("#"+add_popupobj.divid+" [name=tr_topic_text]").hide();
				ld("#"+add_popupobj.divid+" [name=tr_topic_name]").show();
				ld("#"+add_popupobj.divid+" [name=tr_topic_description]").show();
				ld("#"+add_popupobj.divid+" [name=tr_required]").show();
				ld("#"+add_popupobj.divid+" [name=sortable]").show();
				ld("#"+add_popupobj.divid+" [name=add_question_table]").show();
				ld("#"+add_popupobj.divid+" [name=tr_topic_referencemodule]").hide();
				ld("#"+add_popupobj.divid+" [name=tr_topic_fieldonly]").hide();
				ld("#"+add_popupobj.divid+" [name=tr_telregexp]").hide();
			}
		});
	}

	//删除行事件绑定
	this.BindDeleteQuestionTopicTr = function(){
		var add_popupobj = CrmPopup.getPopupObj("last");
		ld("#"+add_popupobj.divid+" [name=del_question_tr]").unbind('click').on('click',function(){
			var rowindex = ld(this).attr('tag');
			var tableobj = ld("#"+add_popupobj.divid+" [name=sortable]");
			var delrowobj=ld(tableobj).find("tr[rowindex="+rowindex+"]");

			// ld(delrowobj).hide();
			ld(delrowobj).remove();

			ld('#'+popupobj.divid+' #step1  [name=topic_table]').change();
			popupobj.setPopBodyMaxHeight("#"+popupobj.divid+"_scroll");
			// alert('删除行事件绑定');
		});

	}

	//显示回收时间框
	this.showdate = function(obj){
		ld(obj).next('input').val(appointedDayByMonth());
		if (ld(obj).is(':checked')){ //.prop('checked')
			ld(obj).next('input').show();
		}else{
			ld(obj).next('input').hide();
		}

		function appointedDayByMonth(num = 1){
			var today=new Date();
			var h=today.getFullYear();
			var m=today.getMonth() + 1 + num;
			if(m > 12){
				m -= 12;
			}
			var d=today.getDate();
			var hh=today.getHours();
			var mm=today.getMinutes();
			var ss=today.getSeconds();
			m= m<10?"0"+m:m;
			d= d<10?"0"+d:d;
			hh = hh < 10 ? "0" + hh:hh;
			mm = mm < 10 ? "0" +  mm:mm;
			ss = ss < 10 ? "0" + ss:ss;
			return h+"-"+m+"-"+d+" "+hh+":"+mm+":"+ss;
		}
	}

	//最后保存
	this.save = function () {
		var record = CrmPopup.getHtmlobjval(popupobj.divid, 'record');
		var formValues = ld('#' + popupobj.divid + ' [name=EditView]').serialize();
		formValues = formValues.slice(formValues.indexOf('questionnaire_no'));

		// var formValues = '&name='+encodeURIComponent(ld('#'+popupobj.divid+' #step1 [name=name]').val());
		// formValues += '&description='+encodeURIComponent(ld('#'+popupobj.divid+' #step1 [name=description]').val());
		// formValues += '&recovery_endtime='+encodeURIComponent(ld('#'+popupobj.divid+' #step1 [name=recovery_endtime]').val());
		// formValues += '&recovery_endremarks='+encodeURIComponent(that.ue.getContent());

		var ajaxurl = 'index.php?module=Questionnaire&action=QuestionnaireAjax&file=Save&refreshpage=no';
		if (record != undefined && record != '') {
			ajaxurl += '&record=' + record;
		}
		if(popupobj.record != undefined && popupobj.record != ''){
			ajaxurl += '&record=' + popupobj.record;
		}
		// console.log(formValues);
		ldAjax(ajaxurl, formValues, function (data) {
			// console.log(data);
			//返回数据 刷新列表页和详细页
			popupobj.record = data.result.fieldvalue.maintable_id;//保存的单据ID

			var tmparra = new Array();
			tmparra.push(popupobj.record);
			var tmpobj = new AfterUpdatePrevPopupObjContent(popupobj.module, data, tmparra);
			var refreshlistmodules = data.result.refreshlistmodules;
			refreshlistmodules.push(popupobj.module);
			tmpobj.eachrefreshlistbyModules(refreshlistmodules);
			tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);
			var questionnaire_status = data.result.fieldvalue.status;
			if(questionnaire_status == '暂停'){
				ld('#'+popupobj.divid+' [name=startquestionnaire]').show();
				ld('#'+popupobj.divid+' [name=startquestionnaire]').find('[name=set_questionnaire_status]').off('click').on('click',function () {
					set_status(popupobj.record,'暂停');
					ld(this).hide();
					ld('#'+popupobj.divid+' [name=sharequestionnairetable]').show();
				});
			}
			else{
				ld('#'+popupobj.divid+' [name=sharequestionnairetable]').show();
			}
		})

	}

	//保存问卷
	this.savequestionnaire = function () {
		var record = CrmPopup.getHtmlobjval(popupobj.divid, 'record');
		var formValues = ld('#' + popupobj.divid + ' [name=EditView]').serialize();
		formValues = formValues.slice(formValues.indexOf('questionnaire_no'));
		//BUG0076397 lius 20231130 serialize()会将2023-10-30 10:10:10 获取为  2023-10-30+10:10:10 多了个加号
		formValues = formValues.replace(/recovery_endtime=([^&]+)/, function(match, captureGroup) {
			// 在捕获组中进行进一步的替换，将加号替换为空格
			return 'recovery_endtime=' + captureGroup.replace(/\+/g, ' ');
		});
		var ajaxurl = 'index.php?module=Questionnaire&action=QuestionnaireAjax&file=Save&refreshpage=no';
		if (record != undefined && record != '') {
			ajaxurl += '&record=' + record;
		}
		if(popupobj.record != undefined && popupobj.record != ''){
			ajaxurl += '&record=' + popupobj.record;
		}
		if(popupobj.paramsobj && popupobj.paramsobj.params && popupobj.paramsobj.params.copyid && popupobj.paramsobj.params.copyid > 0){
			ajaxurl += '&copyid='+popupobj.paramsobj.params.copyid;
		}
		// console.log(formValues);
		ldAjax(ajaxurl, formValues, function (data) {
			popupobj.record = data.result.fieldvalue.maintable_id;//保存的单据ID
			that.getLayoutBlock();
			var tmparra = new Array();
			tmparra.push(popupobj.record);
			var tmpobj = new AfterUpdatePrevPopupObjContent(popupobj.module, data, tmparra);
			var refreshlistmodules = new Array();
			refreshlistmodules.push(popupobj.module);
			tmpobj.eachrefreshlistbyModules(refreshlistmodules);
		})

	}

	//预览问卷
	this.previewQuestionnaire = function (){
		var surl = 'index.php?module=Questionnaire&action=QuestionnaireAjax&file=Quesnaire_LayoutBlock&sub_mode=getChartsaveDetail&questionnaireid='+popupobj.record;
		var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Questionnaire',"","","","");
		crmPopupobj.prevshow();
		ldAjaxNoProgress(surl,'',function(data){
			if(data.code==1){
				crmPopupobj.setParams("","","",'LdPopWidth800px',"Questionnaire","","","","");
				CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
				ld('#'+crmPopupobj.divid+" #"+crmPopupobj.divid+"_scroll").css('max-height','560px');
				crmPopupobj.center();
			}
		})
	}

	// 生成html，保存本地
	this.createHtml=function(record){
		var url='index.php?module=Questionnaire&action=QuestionnaireAjax&file=QuestionnaireCreateHtml&record='+record;
		ld.ajax({
			url: url,
			type: 'POST',
			data:'',
			dataType:'json',
			async: true,//
			timeout: 5000,
			success: function(data)
			{
				// console.log(data)
			}
		})
	}

	this.lastStepFunction=function(record) {
		var ajaxurl = 'index.php?module=Questionnaire&action=QuestionnaireAjax&file=EditViewLastStep&record='+record;
		ld.ajax({
			url:ajaxurl,
			timeout:10000,
			type: 'POST',
			data:'',
			dataType:'json',
			success:function(data) {
				// console.log(data);
				ld("#"+popupobj.divid+" [name=lastname]").text(data.result.Qrcode.lastname);
				ld("#"+popupobj.divid+" [name=Qrcode]").attr('src', data.result.Qrcode.qrcode);
				ld("#"+popupobj.divid+" [name=Qrcode_url]").attr('href', data.result.Qrcode.downQrcode_URL);
				ld("#"+popupobj.divid+" [name=share_url]").attr('data-clipboard-text', data.result.Qrcode.shareUrl);
				ld("#"+popupobj.divid+" [name=questionnaire_url]").attr('href', data.result.Qrcode.shareUrl);
				DelProgressObjs();//全部加载完毕再关闭加载图标
			}
		})
	}

	this.swithStep();
}
Questionnaire.funname = 'Questionnaire';

// 回收设置  问卷结束时间
/*Questionnaire.prototype.showdate=function(obj){
	ld(obj).next('input').val(appointedDayByMonth());
	if (ld(obj).is(':checked')){ //.prop('checked')
		ld(obj).next('input').show();
	}else{
		ld(obj).next('input').hide();
	}

	function appointedDayByMonth(num = 1){
		var today=new Date();
		var h=today.getFullYear();
		var m=today.getMonth() + 1 + num;
		var d=today.getDate();
		var hh=today.getHours();
		var mm=today.getMinutes();
		var ss=today.getSeconds();
		m= m<10?"0"+m:m;
		d= d<10?"0"+d:d;
		hh = hh < 10 ? "0" + hh:hh;
		mm = mm < 10 ? "0" +  mm:mm;
		ss = ss < 10 ? "0" + ss:ss;
		return h+"-"+m+"-"+d+" "+hh+":"+mm+":"+ss;
	}

}*/

Questionnaire.prototype.questionnaireCreateBtnHtml = function(popupobj,data) {
	var html = '';
	html='<div class="E_pbtn" id="'+popupobj.divid+'_popupbottom"> ';
	html+='<span>&nbsp;</span><input name="button" id="'+popupobj.divid+'_btnBack" class="E_pbtnok ld-button ld-button-primary" value="'+data.result.backStep+'" tagClick=""  type="button" style="display: none">';
	html+='<span>&nbsp;</span><input name="button" id="'+popupobj.divid+'_btnok" class="E_pbtnok ld-button ld-button-primary" value="'+popupobj.OkText+'" tagClick=""  type="button">';
	html+='<span>&nbsp;</span><input name="button" class="E_pbtncancel ld-button ld-button-cancel" value="'+popupobj.CancelText+'" id="'+popupobj.divid+'_btncancel" type="button">'
	html+=' </div>';
	return html;
}

//序时簿列表更改状态  - 点击开始回收
function set_questionnaire_status(record,status) {  //status  当前状态
	//确定开始回收吗？
	if (status == '暂停') {
		// var confirm_str = arrJsPopLabel['DETERMINEINVENTORY'];
		var confirm_str = arrJsPopLabel['StartRecyclingReminder'];//'要开始回收该问卷吗？';
	}else if (status == '正在回收') {
		var confirm_str = arrJsPopLabel['SuspendRecyclingReminder'];//'暂停回收期间，问卷链接关闭，问卷不回收数据。确定要暂停回收该问卷吗？';
	}
	RemindsMsg("","LdPopWidth400px","","yes","yes",confirm_str);
	//点击确认
	ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
		set_status(record,status);
	});
	return false;


}

function set_status(record,status) {
	var surl = 'index.php?module=Questionnaire&action=QuestionnaireAjax&file=DetailView&parenttab=Questionnaire&record='+record+'&curstatus='+status;
	ldAjax(surl,{},function(data){
		if(data.code==1){
			var tmparra=new Array();
			tmparra.push(record);
			var tmpobj= new AfterUpdatePrevPopupObjContent('Questionnaire',"",tmparra);
			var refreshlistmodules = new Array('Questionnaire');

			var popupobj=CrmPopup.getPopupObj('last');
			if ('listpage' == popupobj.type)
			{
				tmpobj.eachrefreshlistbyModules(refreshlistmodules);
			}
			else
			{
				tmpobj.eachrefreshlistbyModules(refreshlistmodules);
				//服务单保存后刷新服务单的历史记录(查看界面)
				tmpobj.eachrefreshDetailViewByModules(refreshlistmodules);

			}

			tmpobj.update();//更新界面字段
			delete tmpobj;

			DelProgressObjs();
		}
	})
}

function questionnairechangedaytime(obj,type,day1,day2){
	document.getElementById('startmonth').value=day1+' '+'-'+' '+day2;
	ld('#startmonth').daterangepicker(null, function(start, end, label) {
	});

	ld('#OftenUseReport_search_date a').each(function(){
		if(ld(this).attr('id') == type){
			ld(this).attr('class','onselected_A changeday');
		}else{
			ld(this).attr('class','changeday');
		}
	});
	if(ld('#daterangepicker_search') != undefined){
		ld('#daterangepicker_search').attr('class','changeday colorLink')
	}
}

// 获取当前查询条件的统计报表的html
function getReportContentHtml(obj,formname) {
	var popupobj = CrmPopup.getPopupObj('last');
	var record = ld('#'+popupobj.divid+' [name=return_id]').val();
	var param = ld('#'+popupobj.divid+' form[name='+formname+']').serialize();
	var url = 'index.php?module='+popupobj.headermodule+'&action='+popupobj.headermodule+'Ajax&file=getReportContentHtml';

	ldAjax(url,param+'&record='+record,function (data) {
		if(data.code ==1){
			//获取内容 替换div html
			ld('#'+popupobj.divid+' #UseReportList').html(data.result.content)
			ld('#rptContentLoading').hide();
		}
	})

}

//关联选择单据（单选） 类型问题 其他条件
var fun_other_conditions = function(jqueryobj){
	var referencemodule= ld("#topic_referencemodule").val();
	var triggercolumnname='';
	var tmprange=ld(jqueryobj).attr('tmprange');

	//新增时  更改关联选择对象 时，要清除 其他条件 的值, 一旦选择栏更改 其他条件值就置空， 编辑无需判断  属于未定义


	if(empty(ld("#topic_advance_demand").val())){
		var advancedemand = {"groupid":1, "columnname":"",'comparator':'',"value":'',"basicsearchid":0,'columncondition':''};
		var  groupcondition={"groupcondition":""};
	}else{
		var advancedemand=trim(ld("#topic_advance_demand").val());
		var groupcondition=trim(ld("#topic_advance_demand_groups").val());
	}
	var Popupobj=CrmPopup.load("","","","LdPopWidth800px",referencemodule,"","","","");
	Popupobj.prevshow();
	Popupobj.advanceSearchDivid=Popupobj.divid;
	// var advancesearchstr=JSON.stringify(advancesearch);

	//zkt 20231013 XUQIU1001341 SQL注入
	var urlstring = 'index.php?module=Settings&action=SettingsAjax&file=LayoutBlockRuleAdvancePop&frommodule=' + referencemodule + "&triggercolumnname=" + triggercolumnname + "&advancesearch=" + encodeURIComponent(advancedemand)+"&groupcondition="+groupcondition+"&tmprange="+tmprange;
	ldAjaxNoProgress(urlstring,'',function (data) {
		if (data.code == 1) {
			Popupobj.setParams(data.result.title, set_advancedemand, "", "LdPopWidth800px", referencemodule, '', data.result.oktext, "", data.result.canceltext);
			Popupobj.setInnerHtml = function () {
				//jquery执行脚本
				if (Popupobj.scrolldiv != "") {
					ld("#" + Popupobj.divid).html(Popupobj.popupheadhtml + Popupobj.scrolldiv + Popupobj.htmlcontent + "</div>" + Popupobj.popupbottomhtml);
				} else
					ld("#" + Popupobj.divid).html(Popupobj.popupheadhtml + Popupobj.htmlcontent + Popupobj.popupbottomhtml);
				document.getElementById(Popupobj.divid).style.display = "block";
			}
			CrmPopup.setPopupobjHtmlContent_scroll(Popupobj, data.result.content);
			var advancefilterobj = new cls_advanceFilter();
			var params = {};
			params.columnOptionHtml = data.result.FIELDNAMES;
			params.fLabels = data.result.fLabels;
			params.datetimestr = data.result.datetimestr;
			params.advfilterhtml = data.result.advfilterhtml;
			params.fieldsinfo = data.result.fieldinfo;
			params.criteria_groups_arr = data.result.criteria_groups_arr;
			params.module = referencemodule;
			// edit: xll 2024/11/8  XUQIU1001239  高级查找部分字段优化
			params.advanceFields = data.result.advanceFields;
			advancefilterobj.showAdvanceFilter(Popupobj,params);
		}
	})
}

//
function set_advancedemand(){
	var popupobj=CrmPopup.getPopupObj('last');
	if(!popupobj.advanceFilterObj.checkAdvancedFilter()) return false;
	var advft_criteria = popupobj.advanceFilterObj.advft_criteria;//$('advft_criteria').value;
	var advft_criteria_groups = popupobj.advanceFilterObj.advft_criteria_groups;//$('advft_criteria_groups').value;
	ld("#topic_advance_demand").val(advft_criteria);
	ld("#topic_advance_demand_groups").val(advft_criteria_groups);
	popupobj.CancelEvent();
}

//问卷填写详情
function get_Chartsave_detail(chartsaveid,questionnaireid) {
	var surl = 'index.php?module=Questionnaire&action=QuestionnaireAjax&file=Quesnaire_LayoutBlock&sub_mode=getChartsaveDetail&chartsaveid='+chartsaveid+'&questionnaireid='+questionnaireid;
	var crmPopupobj=CrmPopup.load("","","","LdPopWidth800px",'Questionnaire',"","","","");
	crmPopupobj.prevshow();
	ldAjaxNoProgress(surl,'',function(data){
		if(data.code==1){
			crmPopupobj.setParams("","","",'LdPopWidth800px',"Questionnaire","","","","");
			CrmPopup.setPopupobjHtmlContent_scroll(crmPopupobj,data.result.content);
			ld('#'+crmPopupobj.divid+" #"+crmPopupobj.divid+"_scroll").css('max-height','560px');
			crmPopupobj.center();
		}
	})
}




