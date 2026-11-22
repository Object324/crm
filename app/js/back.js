var divStack = Array();//记录返回事件的div
//存储当前返回操作事件的divid
function setStack(divname){
	if(divStack.length == 0){
		divStack[0] = divname;
	}else{
		if(divStack.length - 1 >= 0){
			if(divStack[divStack.length - 1] != divname){
				divStack[divStack.length] = divname;
			}
		}
	}
}
//清空当前返回所有操作
function clearStack(){
	if(divStack.length > 0){
		divStack.length = 0;
	}
}
//删除当前返回操作事件的divid
function delStack(cnt){
	//单据编辑、保存完，返回到详情页时，会重新加载JS。所以在这处理保存返回时，多删除一次
	if(divStack.length > 0){
		for(var i = 1; i<=cnt; i++){
			divStack.pop();	
		}
	}
}
//获取当前页的返回事件divid
function getStack(){
	var StackNum = divStack.length
	if(divStack.length > 0){
		var cnt = divStack.length;
		if(divStack[cnt - 1] == '.popup-remind [tag=cancel]'){
			ld(divStack[cnt - 1]).trigger("click");	

		}else if(divStack[cnt - 1] == 'closePhone'){//打电话、发短信弹出层
			delStack(1);
			parent.window.ld('#CallMsgMain').addClass('ui-hide');
			parent.window.ld('#layerMask').css('display','none'); 
		
		}else if(ld('#'+divStack[cnt - 1]) != undefined){
			ld('#'+divStack[cnt - 1]).trigger("click");	
		}
		//提示框，直接返回
		if(ld('#layerMask,.popup-remind') != undefined && ld('#layerMask,.popup-remind').attr('style') == 'display: block;'){
			ld('#layerMask,.popup-remind').css('display','none');
		}
		//登录界面提示框
		if(ld('#poplayerMask') != undefined && ld('#poplayerMask').attr('style') == 'display: block;'){
			ld('#poplayerMask').css('display','none');
		}
	}
	return StackNum;
}