//chj 东贸 优惠券设置批量发放
function dongmao_saveCustomform96Data(record){
	var urlstring = 'index.php?module=CustomForm97&action=CustomForm97Ajax&file=dongmao_saveCustomform96Data&getNum=yes&record='+record;
	ldAjax(urlstring,{},function(data){
		if(data.code == 1){
			if(data.result.num_rows > 0){
				DelProgressObjs();
				var popupobj=CrmPopup.getPopupObj("last");//相关信息的obj
				popupobj.record = record;
				ld('#rptContentLoading').show();
				RemindsMsg("","LdPopWidth400px","","yes","yes",'是否确认发送优惠券！');
				//点击确认
				ld('input[tagclick="msgConfirm"]').unbind('click').on('click',function(){
					start_saveCustomform96Data(record,0,popupobj);
				});
			}
		}else{
			RemindsMsg("","LdPopWidth400px","","","",data.msg);
			return false;
		}
	})
}

function start_saveCustomform96Data(record,startrow,popupobj){
	var intervalrow=4;
	var related_id=popupobj.relateid;
	var urlstring = 'module=CustomForm97&action=CustomForm97Ajax&file=dongmao_saveCustomform96Data&send=yes&record='+record;
	urlstring+="&startrow="+startrow+"&endrow="+(startrow+intervalrow);
	new Ajax.Request(
		'index.php',
		{
			queue: {
				position: 'end',
				scope: 'command'
			},
			method: 'post',
			postBody: urlstring,
			onComplete: function (response) {
				ld('#rptContentLoading').hide();
				var restobj = eval('(' + response.responseText + ')') ? eval('(' + response.responseText + ')') : JSON.parse(response.responseText);
				var tmppopupobjobj;

				if(startrow==0){
					 tmppopupobjobj=ProgressPopup.load(restobj.progresstitle,"","",500,'CustomForm96',"","","","");
					 tmppopupobjobj.show();
				}else{
					tmppopupobjobj=CrmPopup.getPopupObj('last');
				}

				var maxrows=parseInt(restobj.maxrows);
				var percent=parseInt(((startrow+intervalrow)/maxrows*100));
				tmppopupobjobj.setPercentWidth(percent);
				tmppopupobjobj.setTotalNum(restobj.selectrows);
				tmppopupobjobj.setCurNum(startrow);

				if(maxrows!=restobj.selectrows){
					tmppopupobjobj.setValidataNum(maxrows);
				}
				if(parseInt(startrow+intervalrow)<parseInt(restobj.maxrows)){
					start_saveCustomform96Data(record,startrow+4,popupobj);
					return false;
				}else{
					tmppopupobjobj.CancelEvent();
					RemindsMsg("","LdPopWidth400px","","","",'优惠券发放完成！');
					var _start = 1;
					var urldata = "&header=CustomForm97&record="+record+"";
					urldata += "&relatedid="+related_id+"&currpage=1&related_left_type=1";
					urldata += "&SearchScope=";
					urldata += '&related_module='+encodeURIComponent('CustomForm96');
					//分页
					urldata+="&start="+popupobj.pagenum;
					//数据分类
					var url = 'index.php?module=Users&action=UsersAjax&file=setRelatedModList'+urldata;
					ldAjax(url,"",function(data){
						if(data.code==1){
							DelProgressObjs();
							ld('#'+popupobj.divid+' .DivCTable').html(data.result.content);
							ld("#"+popupobj.divid+" [relateidtag="+related_id+"]").css('display','');
							ld("#"+popupobj.divid+" [relateidtag="+related_id+"]").html('['+data.result.noofrows+']'); 
						}
					});
				}
			}
		})
}