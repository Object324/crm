/*function getInventoryProductKeyWords(obj,rowid,module)
{
    var urlstring = 'module=Products&action=ProductsAjax&file=GetSearchInfo&keywords='+obj.value;
    //alert(urlstring);
    new Ajax.Request('index.php',{
    	queue: {position: 'end',scope: 'command'},
    	method: 'post',
    	postBody: urlstring,
    	onComplete: function(response) {
    		var results = trim(response.responseText);
    		if(results != ''){
    			var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
                //显示列头信息
    			var len = restobj['header'].length;
                //显示列字段名称
                var columnnameLen = restobj['columnname'].length;
                if(restobj['columnname'].length == 0 || restobj['columnname'].length < 1)
                {
                    //无任何记录
                    info =arrJsPopLabel['NORECORDSAREFOUND'];
                }
                else
                {
                    //显示模糊查询内容
    				var info = '<table><tr>';
    				for(var i=0;i<len;i++){
    					info += '<th>'+restobj['header'][i]+'</th>';
    				}
    				info += '</tr>';
    				for(var i in restobj['entries']){
                        info += '<tr onclick="setInventoryProductInfo('+rowid+','+i+')">';
                        if(module ='Products')
                        {
                            info += '<input type="hidden" id="popup_product_'+i+'" vt_prod_arr='+restobj['entries'][i]['vt_prod_arr']+' />';
                        }
                        for(var j=0;j<columnnameLen;j++)
                        {
                            var columnname = restobj['columnname'][j];
                            info += '<td>'+restobj['entries'][i][columnname]+'</td>';
                        }
                        info += '</tr>';
    				}
    				info += '</table>';
                }
    			document.getElementById('search_'+obj.id).innerHTML = info;
    		}
            else
            {
                alert(1);
            }
    	}
    });
}

function setInventoryProductInfo(rowid,id)
{
    var prod_array = JSON.parse($('popup_product_'+id).attributes['vt_prod_arr'].nodeValue);
    var prod_id = prod_array['entityid'];;
    var span_name = prod_array['span_var'];
    var span_all = prod_array['span_all'];
    var qtyinstk = prod_array['qtyinstk'];
    var prod_name = prod_array['prodname'];
	var unit_price = prod_array['unitprice'];
    var costprice = prod_array['costprice'];
	var taxstring = prod_array['taxstring'];
	var desc = prod_array['desc'];
	var subprod_ids = prod_array['subprod_ids'];
    var row_id = rowid;
    set_return_inventory_products(prod_id,prod_name,unit_price,costprice,qtyinstk,taxstring,parseInt(row_id),desc,subprod_ids,span_all)
    alert(rowid);
}*/