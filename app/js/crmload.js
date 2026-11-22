document.addEventListener('touchmove', function(e) {
	e.preventDefault();
}, false);
document.addEventListener('DOMContentLoaded', function() {
	ld(document).ready(function() {
		crmInit();
	});
}, false);
//节点加载事件，在onload之前
ld(function(){
	// 判断当前浏览器是否支持indexOf、remove事件，不支持则添加
	if(typeof Array.indexOf !== 'function'){//数组包含
		Array.prototype.indexOf = function(args){
			var index = -1;
			for(var i=0,l=this.length;i<l; i++){
				if(this[i] === args){
					index = i;
					break;
				}
			}
			return index;
		}
	}
	String.prototype.len = function(){// 给string增加个len ()方法，计算string的字节数
		return this.replace(/[^\x00-\xff]/g,"xx").length;
	}    
});
//CRM加载
function crmInit(){
    FastClick.attach(document.body); // 减少手机端 点击事件延迟
    SwiperObj.setSwiperSzie();       // 设置当前全局滚动适应屏幕大小
    category = 'crm';
    category_for = 'crm';
    ViewObj.switchView('crm-main-view','init');
}