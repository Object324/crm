/**
 * 中能特殊处理：选择负责人带出负责人的门店信息
 * @param
 * @returns
 * @author Chj 
 */
function getSmownerStore(obj){
	var wareid = 0;
	if(ld('#wareid') != undefined){
		wareid = ld('#wareid').val();
	}
   var urlstring = 'module=Users&action=UsersAjax&file=GetSmownerStore&wareid='+wareid+'&smownerid='+obj.value;
    new Ajax.Request("index.php",
		{
			queue:{
				position:"end",
				scope:"command"
			},
			method:"post",
			postBody:urlstring,
			onComplete:function (response) {
                var res = response.responseText;
				if(ld('#wareid') != undefined){
					ld('#wareid').val(res);
					ld('#wareid').change();
				}
			}
		}
	);
}

//根据门店 带出产品的库存数量
function getWareProductQty(obj){
	var wareid = obj.value;
	var prd_id = [];
	var max_row_count = document.getElementById('rowcnt').value;
	for (var i=1;i<=max_row_count;i++) 
    {
		if(document.getElementById('hidden_rowid_'+i).value == 0 && document.getElementById('hdnProductId'+i).value > 0){
			prd_id[i] = document.getElementById('hdnProductId'+i).value;
		}
	}
	if(prd_id.length > 0 && wareid > 0){
		var urlstring = 'module=Users&action=UsersAjax&file=GetSmownerStore&wareid='+wareid+'&prdid='+prd_id.join(',');
		new Ajax.Request("index.php",
			{
				queue:{
					position:"end",
					scope:"command"
				},
				method:"post",
				postBody:urlstring,
				onComplete:function (response) {
					var results = response.responseText;
					var restobj = eval('('+ results +')')?eval('('+ results +')'):JSON.parse(results);
					for(productid in restobj){
						for (var i=1;i<=max_row_count;i++) {
							if(document.getElementById('hidden_rowid_'+i).value == 0 && document.getElementById('hdnProductId'+i).value > 0){
								if(document.getElementById('hdnProductId'+i).value == productid && ld('#productdetails_input_zhongneng_ware_qty'+i) != undefined){
									ld('#productdetails_input_zhongneng_ware_qty'+i).html(restobj[productid]);
								}
							}
						}
					}
				}
			}
		);
	}
}