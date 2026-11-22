/*
jQuery.ganttView v.0.8.8
Copyright (c) 2010 JC Grubbs - jc.grubbs@devmynd.com
MIT License Applies
*/

/*
Options
-----------------
showWeekends: boolean
data: object
cellWidth: number
cellHeight: number
slideWidth: number
dataUrl: string
behavior: {
	clickable: boolean,
	draggable: boolean,
	resizable: boolean,
	onClick: function,
	onDrag: function,
	onResize: function
}
*/

(function (jQuery) {
	
    jQuery.fn.ganttView = function () {
    	
    	var args = Array.prototype.slice.call(arguments);
    	
    	if (args.length == 1 && typeof(args[0]) == "object") {
        	build.call(this, args[0]);
    	}
    	
    	if (args.length == 2 && typeof(args[0]) == "string") {
    		handleMethod.call(this, args[0], args[1]);
    	}
    };
    
    function build(options) {
    	
    	var els = this;
        var defaults = {
            showWeekends: true,
            cellWidth: 20,
            cellHeight: 31,
            slideWidth: 400,
            vHeaderWidth: 100,
			hearderdata:'',
            behavior: {
            	clickable: true,
            	draggable: false,
            	resizable: true
            }
        };
        
        var opts = jQuery.extend(true, defaults, options);

		if (opts.data) {
			build();
		} else if (opts.dataUrl) {
			jQuery.getJSON(opts.dataUrl, function (data) { opts.data = data; build(); });
		}

		function build() {
			
			var minDays = Math.floor((opts.slideWidth / opts.cellWidth)  + 5);
			var startEnd = DateUtils.getBoundaryDatesFromData(opts.data, minDays);
			opts.start = startEnd[0];
			opts.end = startEnd[1];
			
	        els.each(function () {

	            var container = jQuery(this);
	            var div = jQuery("<div>", { "class": "ganttview" });
	            new Chart(div, opts).render();
				container.append(div);
				
				var w = jQuery("div.ganttview-vtheaders", container).outerWidth() +
					jQuery("div.ganttview-slide-container", container).outerWidth();
	            container.css("width", (w + 2) + "px");
	            
	            new Behavior(container, opts).apply();
	        });
		}
    }

	function handleMethod(method, value) {
		
		if (method == "setSlideWidth") {
			var div = $("div.ganttview", this);
			div.each(function () {
				var vtWidth = $("div.ganttview-vtheader", div).outerWidth();
				$(div).width(vtWidth + value + 1);
				$("div.ganttview-slide-container", this).width(value);
			});
		}
	}

	var Chart = function(div, opts) {
		
		function render() {
			addVtHeader(div, opts.data, opts.cellHeight,opts.vHeaderWidth,opts.hearderdata);

            var slideDiv = jQuery("<div>", {
                "class": "ganttview-slide-container",
                "css": { "width": opts.slideWidth + "px" }
            });
			
            dates = getDates(opts.start, opts.end);
            addHzHeader(slideDiv, dates, opts.cellWidth);
            addGrid(slideDiv, opts.data, dates, opts.cellWidth, opts.showWeekends);
            addBlockContainers(slideDiv, opts.data);
            addBlocks(slideDiv, opts.data, opts.cellWidth, opts.start);
            div.append(slideDiv);
            applyLastClass(div.parent());
		}
		
		//var monthNames = ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"];
        var monthNames = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"];

		// Creates a 3 dimensional array [year][month][day] of every day 
		// between the given start and end dates
        function getDates(start, end) {
            var dates = [];
			dates[start.getFullYear()] = [];
			dates[start.getFullYear()][start.getMonth()] = [start]
			var last = start;
			while (last.compareTo(end) == -1) {
				var next = last.clone().addDays(1);
				if (!dates[next.getFullYear()]) { dates[next.getFullYear()] = []; }
				if (!dates[next.getFullYear()][next.getMonth()]) { 
					dates[next.getFullYear()][next.getMonth()] = []; 
				}
				dates[next.getFullYear()][next.getMonth()].push(next);
				last = next;
			}
			return dates;
        }
		
		function addVtHeader(div, data, cellHeight,vHeaderWidth,hearderdata) {
            // var heardtitle = "<div style="height: 41px;"><div style="width: 100px;height: 41px;font-size: 35px;text-align: center;">任务</div></div>";
			var headerDiv = jQuery("<div>", { "class": "ganttview-vtheaders" ,"css":{"width":vHeaderWidth+"px","overflow":"hidden","float":"left"},"id":"vHeaderhavetable"});
			var htmltable = jQuery("<table>", { "class": "" });
			var html ="<table border=\"0\" cellspacing=\"0\" cellpadding=\"0\" style = \"border-collapse: collapse;border-spacing: 0;\" width=\"100%\"><tr style = \"height:40px;\">";
			for(var index in hearderdata.rowlable){
				if(index == 'startstr' || index == 'endstr'){
					html += "<th width=\"10%\" title=\""+hearderdata.rowlable[index]+"\" style=\"text-align: center;vertical-align: middle;background-color: #F9F9F9;\">"+hearderdata.rowlable[index]+"</th>";
				}
                else if(index == 'sjprogress'){
					html += "<th width=\"5%\" title=\""+hearderdata.rowlable[index]+"\" style=\"text-align: center;vertical-align: middle;background-color: #F9F9F9;\"><div style=\"width:120px\">"+hearderdata.rowlable[index]+"</div></th>";
				}
				else {
					html += "<th width=\"5%\" title=\""+hearderdata.rowlable[index]+"\" style=\"text-align: center;vertical-align: middle;background-color: #F9F9F9;\">"+hearderdata.rowlable[index]+"</th>";
				}
			}
			html +="</tr>";
			
			
            for (var i = 0; i < data.length; i++) {
                var itemTr = "<tr style = \"height:"+cellHeight+"px;\">";
				//for(var j = 0; j < data[i].name.length; j++){
					for (var index in data[i].name){
					   if(hearderdata.rowlable[index]==undefined){
					       continue;
					   }
					   if(index == 'taskname'){
					       itemTr += "<td title=\""+data[i].name[index]+"\"  style=\"text-align: left;vertical-align: middle;\" rowspan=\""+data[i].series.length+"\"><span class=\"ganttView-vtheader-span\" >"+data[i].name[index]+"</span ></td>";
					   }
                       else if(index == 'taskstatus'){
					       itemTr += "<td title=\""+data[i].name[index]+"\"  style=\"text-align: left;vertical-align: middle;color:#ffffff;background-color:"+data[i].series[1].color+"\" rowspan=\""+data[i].series.length+"\"><span class=\"ganttView-vtheader-span\" >"+data[i].name[index]+"</span ></td>";
					   }
                       else if(index == 'sjprogress'){
                            var tmpwidth = parseFloat(data[i].name[index])/100*120;
					       itemTr += "<td title=\""+data[i].name[index]+"\"  style=\"text-align: left;vertical-align: middle;\" rowspan=\""+data[i].series.length+"\"><div style=\"width:120px;height:24px;text-align: left;line-height: 31px;border:1px solid #c0c0c0;-webkit-border-radius:5px;\"><div style=\"width:"+tmpwidth+"px;background-color:"+data[i].series[1].color+";height:100%;text-align: left;line-height: 24px;\">&nbsp;&nbsp;"+data[i].name[index]+"</div></div></td>";
					   }
                       else{
                            itemTr += "<td title=\""+data[i].name[index]+"\"  style=\"text-align: left;vertical-align: middle;\" rowspan=\""+data[i].series.length+"\"><span class=\"ganttView-vtheader-span\" >"+data[i].name[index]+"</span ></td>";
                       }
							
					}
				//}
                for (var j = 0; j < data[i].series.length; j++) {
					var itemTrend = "";
					//for(var k = 0; k < data[i].series[j].name.length; k++){
						for(var index in data[i].series[j].name){
								itemTrend += "<td title=\""+data[i].series[j].name[index]+"\" style=\"text-align: left;vertical-align: middle;\" width=\"20%\">"+data[i].series[j].name[index]+"</td>";
						}
					//}
					if(j==0){
						html += itemTr+itemTrend;
					}
					else{
						html += "<tr style = \"height:"+cellHeight+"px;\">"+itemTrend;
					}
					
                }
                
            }
			headerDiv.append(html);
            div.append(headerDiv);
        }

        function addVtHeader1(div, data, cellHeight) {
            // var heardtitle = "<div style="height: 41px;"><div style="width: 100px;height: 41px;font-size: 35px;text-align: center;">任务</div></div>";
			var headerDiv = jQuery("<div>", { "class": "ganttview-vtheader" });
			
            for (var i = 0; i < data.length; i++) {
                var itemDiv = jQuery("<div>", { "class": "ganttview-vtheader-item" });
                itemDiv.append(jQuery("<div>", {
                    "class": "ganttview-vtheader-item-name",
                    "css": { "height": (data[i].series.length * cellHeight) + "px" }
                }).append(data[i].name));
                var seriesDiv = jQuery("<div>", { "class": "ganttview-vtheader-series" });
                for (var j = 0; j < data[i].series.length; j++) {
                    seriesDiv.append(jQuery("<div>", { "class": "ganttview-vtheader-series-name" })
						.append(data[i].series[j].name));
                }
                itemDiv.append(seriesDiv);
                headerDiv.append(itemDiv);
            }
            div.append(headerDiv);
        }

        function addHzHeader(div, dates, cellWidth) {
            var headerDiv = jQuery("<div>", { "class": "ganttview-hzheader" });
            var monthsDiv = jQuery("<div>", { "class": "ganttview-hzheader-months" });
            var daysDiv = jQuery("<div>", { "class": "ganttview-hzheader-days" });
            var totalW = 0;
            //获取当前日期
            var myDate = new Date();
			for (var y in dates) {
				for (var m in dates[y]) {
					var w = dates[y][m].length * cellWidth;
					totalW = totalW + w;
					monthsDiv.append(jQuery("<div>", {
						"class": "ganttview-hzheader-month",
						"css": { "width": (w - 1) + "px","overflow":"hidden" },
                        "title":y+'年'+monthNames[m]
					}).append(y+'年'+monthNames[m]));
					for (var d in dates[y][m]) {
                        //设置颜色
                        if((myDate - dates[y][m][d]) / (1000 * 60 * 60 * 24)>0&&(myDate - dates[y][m][d]) / (1000 * 60 * 60 * 24)<=1){
                            daysDiv.append(jQuery("<div>", { "class": "ganttview-hzheader-day","css":{"background-color":"rgb(192, 207, 251)","border-top":"1px solid rgb(192, 207, 251)" }})
							.append(dates[y][m][d].getDate()));
                        }
                        else{
                            daysDiv.append(jQuery("<div>", { "class": "ganttview-hzheader-day" })
							.append(dates[y][m][d].getDate()));
                        }
					}
				}
			}
            monthsDiv.css("width", totalW + "px");
            daysDiv.css("width", totalW + "px");
            headerDiv.append(monthsDiv).append(daysDiv);
            div.append(headerDiv);
        }

        function addGrid(div, data, dates, cellWidth, showWeekends) {
            var gridDiv = jQuery("<div>", { "class": "ganttview-grid" });
            var rowDiv = jQuery("<div>", { "class": "ganttview-grid-row" });
            //获取当前日期
            var myDate = new Date();
			for (var y in dates) {
				for (var m in dates[y]) {
					for (var d in dates[y][m]) {
						var cellDiv = jQuery("<div>", { "class": "ganttview-grid-row-cell" });
						if (DateUtils.isWeekend(dates[y][m][d]) && showWeekends) { 
							//cellDiv.addClass("ganttview-weekend"); 
						}
                        //设置颜色
                        if((myDate - dates[y][m][d]) / (1000 * 60 * 60 * 24)>0&&(myDate - dates[y][m][d]) / (1000 * 60 * 60 * 24)<=1){
                            cellDiv.css('background-color','rgb(192, 207, 251)');
                            cellDiv.css('border-top','1px solid rgb(192, 207, 251)');
                        }
                        
						rowDiv.append(cellDiv);
					}
				}
			}
            var w = jQuery("div.ganttview-grid-row-cell", rowDiv).length * cellWidth;
            rowDiv.css("width", w + "px");
            gridDiv.css("width", w + "px");
            for (var i = 0; i < data.length; i++) {
                for (var j = 0; j < data[i].series.length; j++) {
                    gridDiv.append(rowDiv.clone());
                }
            }
            div.append(gridDiv);
        }

        function addBlockContainers(div, data) {
            var blocksDiv = jQuery("<div>", { "class": "ganttview-blocks" });
            for (var i = 0; i < data.length; i++) {
                for (var j = 0; j < data[i].series.length; j++) {
                    blocksDiv.append(jQuery("<div>", { "class": "ganttview-block-container" }));
                }
            }
            div.append(blocksDiv);
        }

        function addBlocks(div, data, cellWidth, start) {
            var rows = jQuery("div.ganttview-blocks div.ganttview-block-container", div);
            var rowIdx = 0;
            var projectname = document.getElementById('gantprojectname').value;
            for (var i = 0; i < data.length; i++) {
                for (var j = 0; j < data[i].series.length; j++) {
                    var series = data[i].series[j];
                    var size = DateUtils.daysBetween(series.start, series.end) + 1;
					var title = "任务名称："+data[i].name.taskname.replace('&nbsp;','')+'\n';
					for(var index  in series.name)
					{
					   if(index == 'contrast'){
					       continue; 
					   }
                       if(index == 'startstr'){
                            title += "开始日期："+series.name[index]+"\n";
                       }
                       if(index == 'endstr'){
                            title += "结束日期："+series.name[index];
                       }
					}
					var offset = DateUtils.daysBetween(start, series.start);
					var block = jQuery("<div>", {
                        "class": "ganttview-block",
                        "title": title,
                        "css": {
                            "width": ((size * cellWidth) - 9) + "px",
                            "margin-left": ((offset * cellWidth) + 3) + "px"
                        }
                    });
                    addBlockData(block, data[i], series);
                    if (data[i].series[j].color) {
                        block.css("background-color", data[i].series[j].color);
						if(data[i].series[j].color == 'rgb(197, 206, 252)' || data[i].series[j].color == 'rgb(157, 107, 204)'){
							block.css("display", "none");
						}
                    }
                    //block.append(jQuery("<div>", { "class": "ganttview-block-text" }).text(size));
                    jQuery(rows[rowIdx]).append(block);
                    rowIdx = rowIdx + 1;
                }
            }
        }
        
        function addBlockData(block, data, series) {
        	// This allows custom attributes to be added to the series data objects
        	// and makes them available to the 'data' argument of click, resize, and drag handlers
        	var blockData = { id: data.id, name: data.name };
        	jQuery.extend(blockData, series);
        	block.data("block-data", blockData);
        }

        function applyLastClass(div) {
            jQuery("div.ganttview-grid-row div.ganttview-grid-row-cell:last-child", div).addClass("last");
            jQuery("div.ganttview-hzheader-days div.ganttview-hzheader-day:last-child", div).addClass("last");
            jQuery("div.ganttview-hzheader-months div.ganttview-hzheader-month:last-child", div).addClass("last");
        }
		
		return {
			render: render
		};
	}

	var Behavior = function (div, opts) {
		
		function apply() {
			
			if (opts.behavior.clickable) { 
            	bindBlockClick(div, opts.behavior.onClick); 
        	}
        	
            if (opts.behavior.resizable) { 
            	bindBlockResize(div, opts.cellWidth, opts.start, opts.behavior.onResize); 
        	}
            
            if (opts.behavior.draggable) { 
            	bindBlockDrag(div, opts.cellWidth, opts.start, opts.behavior.onDrag); 
        	}
		}

        function bindBlockClick(div, callback) {
            jQuery("div.ganttview-block", div).live("click", function () {
                if (callback) { callback(jQuery(this).data("block-data")); }
            });
        }
        
        function bindBlockResize(div, cellWidth, startDate, callback) {
        	jQuery("div.ganttview-block", div).resizable({
        		grid: cellWidth, 
        		handles: "e,w",
        		stop: function () {
        			var block = jQuery(this);
        			updateDataAndPosition(div, block, cellWidth, startDate);
        			if (callback) { callback(block.data("block-data")); }
        		}
        	});
        }
        
        function bindBlockDrag(div, cellWidth, startDate, callback) {
        	jQuery("div.ganttview-block", div).draggable({
        		axis: "x", 
        		grid: [cellWidth, cellWidth],
        		stop: function () {
        			var block = jQuery(this);
        			updateDataAndPosition(div, block, cellWidth, startDate);
        			if (callback) { callback(block.data("block-data")); }
        		}
        	});
        }
        
        function updateDataAndPosition(div, block, cellWidth, startDate) {
        	var container = jQuery("div.ganttview-slide-container", div);
        	var scroll = container.scrollLeft();
			var offset = block.offset().left - container.offset().left - 1 + scroll;
			
			// Set new start date
			var daysFromStart = Math.round(offset / cellWidth);
			var newStart = startDate.clone().addDays(daysFromStart);
			block.data("block-data").start = newStart;

			// Set new end date
        	var width = block.outerWidth();
			var numberOfDays = Math.round(width / cellWidth) - 1;
			block.data("block-data").end = newStart.clone().addDays(numberOfDays);
			jQuery("div.ganttview-block-text", block).text(numberOfDays + 1);
			
			// Remove top and left properties to avoid incorrect block positioning,
        	// set position to relative to keep blocks relative to scrollbar when scrolling
			block.css("top", "").css("left", "")
				.css("position", "relative").css("margin-left", offset + "px");
        }
        
        return {
        	apply: apply	
        };
	}

    var ArrayUtils = {
	
        contains: function (arr, obj) {
            var has = false;
            for (var i = 0; i < arr.length; i++) { if (arr[i] == obj) { has = true; } }
            return has;
        }
    };

    var DateUtils = {
    	
        daysBetween: function (start, end) {
            if (!start || !end) { return 0; }
            start = Date.parse(start); end = Date.parse(end);
            if (start.getYear() == 1901 || end.getYear() == 8099) { return 0; }
            var count = 0, date = start.clone();
            while (date.compareTo(end) == -1) { count = count + 1; date.addDays(1); }
            return count;
        },
        
        isWeekend: function (date) {
            return date.getDay() % 6 == 0;
        },

		getBoundaryDatesFromData: function (data, minDays) {
			var minStart = new Date(); maxEnd = new Date();
			for (var i = 0; i < data.length; i++) {
				for (var j = 0; j < data[i].series.length; j++) {
					var start = Date.parse(data[i].series[j].start);
					var end = Date.parse(data[i].series[j].end)
					if (i == 0 && j == 0) { minStart = start; maxEnd = end; }
					if (minStart.compareTo(start) == 1) { minStart = start; }
					if (maxEnd.compareTo(end) == -1) { maxEnd = end; }
				}
			}
			
			// Insure that the width of the chart is at least the slide width to avoid empty
			// whitespace to the right of the grid
			if (DateUtils.daysBetween(minStart, maxEnd) < minDays) {
				maxEnd = minStart.clone().addDays(minDays);
			}
			
			return [minStart, maxEnd];
		}
    };

})(jQuery);