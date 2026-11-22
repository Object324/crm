(function(window) {
	/**
	 * 悬浮出现提示
	 * @param ele Dom元素列表的获取依据，可以为 document.querySelectorAll支持的选择器、Dom对象、Dom对象列表、Jquery对象
	 * @param transitionObj 配置项
	 * @param enterCallback 鼠标移入回调
	 * @param outCallback 鼠标移出回调
	 */
	function tooltip(ele, transitionObj, enterCallback, outCallback) {
		var els;
		if(!ele){
			//console.error(new Error('The "tooltip" method requires the "class" of at least one parameter'));
			return
		}
		else if(typeof ele === "string"){
			els = document.querySelectorAll(ele);
		}
		else if(typeof ele === "object"){
			//Dom对象
			if(ele instanceof HTMLElement) {
				els = [ele];
			}
			//Dom列表 对象
			else if(ele instanceof NodeList){
				els = ele;
			}
			//Jquey 对象
			else if(ele instanceof ld){
				els = ele.not('.bindtip');
			}
			else
				return
		}
		else
			return
		if (els.length <= 0) {
			//console.log('The "tooltip" method requires the HTMLElement of at least one \n the first param is '+ele);
			return
		}
		if(empty(transitionObj)){
			transitionObj = {transition: true, time: 200};
		}
		if (transitionObj && ({}).constructor.name === "Object") {
			var transition = transitionObj.transition || false,
				time = transitionObj.time || 200,
				timer = null
		}
		var tipContent = document.createElement("div");
		// edit: xll 2024/04/28 tooltip产生的标签不触发事件
		tipContent.style.setProperty('pointer-events','none');		
		Array.prototype.slice.call(els).forEach(function(el) {
			if(el.classList.contains('bindtip')){
				return;
			}
			el.addEventListener("mouseenter", function() {
				var context,direction;
				//ljj 20231229 XUQIU1002228 联系人图谱增加锁定功能
				if (typeof ele === "string" && ele[0] == '.'){//判断是否是class类 .classname
					var classname=ele.replace('.','');
					if (!ld(ele).hasClass(classname)){//无类名不悬浮
						return false;
					}
				}
				context = el.getAttribute("data-tip");
				direction = el.getAttribute("data-direction") || "top";
				// wyt_XUQIU1000492【单据新建/编辑/复制界面，单据表体字段内容加title】_220728
				if(ld(el).is("input"))
				{
					context = ld(el).val();
					if (ld(el).attr('id') == 'map_edit'){//联系人图谱 编辑被锁的悬浮
						context = el.getAttribute("data-tip");
					}
				}
				if (ld(el).is("textarea"))
				{
					context = ld(el).val();
				}
				if (ld(el).is("span"))
				{
					context = ld(el).text();
				}
                if(context==undefined||ld.trim(context+"")=="")
				{
					 return ;
				}
				tipContentSetter(tipContent, context, direction);
				set_tipContent_position(tipContent,direction,el);
			}, false);
			deleteTipContent(el);
		});
		function deleteTipContent(el) {
			if(el.classList.contains('bindtip')){
				return;
			}
			el.addEventListener("click", function() {
				var oldTipContent = document.querySelector(".tool_tip");
				if (oldTipContent) {
					if(el.getAttribute("data-tiptype") === 'remain'){
						//edit: xll 2023/07/20 BUG0069755 kfbcrm-可视化分析-点击“收藏”图标- 图标变亮，鼠标此时应浮显“取消收藏”字样
						if (transition === true) {
							return opacityTransition_click(oldTipContent, "click", el);
						}
					}
					else{
						if (transition === true) {
							return opacityTransition(oldTipContent, "leave");
						}
						document.body.removeChild(oldTipContent);
					}

					typeof outCallback === "function" ? outCallback() : null
				}
			}, false)
			el.addEventListener("mouseleave", function() {
				var oldTipContent = document.querySelector(".tool_tip");
				if (oldTipContent) {
					if (transition === true) {
						return opacityTransition(oldTipContent, "leave")
					}
					document.body.removeChild(oldTipContent);
					typeof outCallback === "function" ? outCallback() : null
				}
			}, false)
			el.classList.add('bindtip');
		}
		function tipContentSetter(tipContent, context, direction) {
			ld('div.tool_tip').remove();
			tipContent.innerHTML = context;
			tipContent.className = "tool_tip tool_tip_" + direction;
            
			document.body.appendChild(tipContent);
             if(typeof cls_wxOpenDataobj!=undefined&&typeof cls_wxOpenDataobj!="undefined")
             {
                    //pc����ҵ΢��
                    cls_wxOpenDataobj.bindAllTipData();
                    
             }
                 
			if (transition === true) {
				opacityTransition(tipContent, "enter");
				return
			}
			typeof enterCallback === "function" ? enterCallback() : null
		}
		function opacityTransition(ele, state) {
			timer && clearTimeout(timer);
			ele.style.setProperty("transition", "opacity " + time / 1000 + "s");
			ele.style.setProperty("-webkit-transition", "opacity " + time / 1000 + "s");

			if (state === "enter") {
				ele.style.opacity = 0;
				timer = setTimeout(function() {
					ele.style.opacity = 1;
					typeof enterCallback === "function" ? enterCallback() : null
				}, 0)
			} else {
				if (state === "leave") {
					ele.style.opacity = 0;
					typeof outCallback === "function" ? outCallback() : null;
					timer = setTimeout(function() {
						try {
							document.body.removeChild(ele);
							ld('div.tool_tip').remove();
						} catch (e) {}
					}, time)
				}
			}
		}
		//增加点击更新标签内容
		function opacityTransition_click(ele, state, dir_obj) {
			timer && clearTimeout(timer);
			ele.style.setProperty("transition", "opacity " + time / 1000 + "s");
			ele.style.setProperty("-webkit-transition", "opacity " + time / 1000 + "s");

			if (state === "click") {
				ele.style.opacity = 1;
				typeof outCallback === "function" ? outCallback() : null;
				timer = setTimeout(function() {
					try {
						let context = dir_obj.getAttribute("data-tip");
						let direction = dir_obj.getAttribute("data-direction") || "top";
						ele.innerHTML = context;
						set_tipContent_position(ele,direction,dir_obj);

					} catch (e) {
					}
				}, time)
			}
		}
		function set_tipContent_position(tipContent,direction,dir_obj){
			var currenLeft,currenTop,currenWidth,currenHeight;
			if(dir_obj.getAttribute("data-type") == 'noposition'){
				currenLeft = dir_obj.offsetLeft;
				currenTop = dir_obj.offsetTop;
				// console.log('1#####'+currenLeft+'#####'+currenTop);
			}
			else{
				currenLeft = dir_obj.getBoundingClientRect().left;
				currenTop = dir_obj.getBoundingClientRect().top;
				// console.log('2#####'+currenLeft+'#####'+currenTop);
			}

			currenWidth = dir_obj.offsetWidth;
			if(dir_obj.offsetWidth > ld(dir_obj).parent().get(0).offsetWidth){
				currenWidth = ld(dir_obj).parent().get(0).offsetWidth;
			}
			currenHeight = dir_obj.offsetHeight;
			var tipContentWidth = tipContent.offsetWidth;
			var tipContentHeight = tipContent.offsetHeight;
			switch (direction) {
				case "top":
					tipContent.style.left = currenLeft + currenWidth / 2 - tipContentWidth / 2 + "px";
					tipContent.style.top = currenTop - tipContentHeight - 7 + "px";
					break;
				case "left":
					tipContent.style.left = currenLeft - tipContentWidth - 7 + "px";
					tipContent.style.top = currenTop + currenHeight / 2 - tipContentHeight / 2 + "px";
					break;
				case "right":
					tipContent.style.left = currenLeft + currenWidth + 7 + "px";
					tipContent.style.top = currenTop + currenHeight / 2 - tipContentHeight / 2 + "px";
					break;
				case "bottom":
					tipContent.style.left = currenLeft + currenWidth / 2 - tipContentWidth / 2 + "px";
					tipContent.style.top = currenTop + currenHeight + 7 + "px"
			}
		}
		// 静态方法，可直接onmouseenter=tooltip.bind(this)来调取
		tooltip.bind = function(el){
			var context,direction;
			//ljj 20231229 XUQIU1002228 联系人图谱增加锁定功能
			if (typeof ele === "string" && ele[0] == '.'){//判断是否是class类 .classname
				var classname=ele.replace('.','');
				if (!ld(ele).hasClass(classname)){//无类名不悬浮
					return false;
				}
			}
			context = el.getAttribute("data-tip");
			direction = el.getAttribute("data-direction") || "top";
			// wyt_XUQIU1000492【单据新建/编辑/复制界面，单据表体字段内容加title】_220728
			if(ld(el).is("input"))
			{
				context = ld(el).val();
				if (ld(el).attr('id') == 'map_edit'){//联系人图谱 编辑被锁的悬浮
					context = el.getAttribute("data-tip");
				}
			}

			if (!!ld(el).data('tiptype') && ld(el).data('tiptype') === 'selftip'){
				context = el.getAttribute("data-tip");
			}else{
				if (ld(el).is("textarea"))
				{
					context = ld(el).val();
				}
				if (ld(el).is("span"))
				{
					context = ld(el).text();

				}
			}

			if(context==undefined||ld.trim(context+"")=="")
			{
					return ;
			}
			tipContentSetter(tipContent, context, direction);
			set_tipContent_position(tipContent,direction,el);
			deleteTipContent(el);
		}

	}
	window.tooltip = tooltip
})(window);