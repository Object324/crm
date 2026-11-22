function ajax_mass_edit() {
	// alert();
	$("status").style.display = "inline";

	var masseditform = $("massedit_form");
	var module = masseditform["massedit_module"].value;

	var viewid = document.getElementById("viewname").value;
	var idstring = masseditform["massedit_recordids"].value;
	var searchurl = document.getElementById("search_url").value;
	var tplstart = "&";
	if (gstart != "") {tplstart = tplstart + gstart;}

	var masseditfield = masseditform['massedit_field'].value;
	var masseditvalue = masseditform['massedit_value_'+masseditfield].value;

	var urlstring = 
		"module="+encodeURIComponent(module)+"&action="+encodeURIComponent(module+'Ajax')+
		"&return_module="+encodeURIComponent(module)+
		"&mode=ajax&file=MassEditSave&viewname=" + viewid + 
		"&massedit_field=" + encodeURIComponent(masseditfield) +
		"&massedit_value=" + encodeURIComponent(masseditvalue) +
	   	"&idlist=" + idstring + searchurl;

	fninvshnew("massedit");

	new Ajax.Request(
		"index.php", 
		{queue:{position:"end", scope:"command"}, 
			method:"post", 
			postBody:urlstring, 
			onComplete:function (response) {
				$("status").style.display = "none";
				var result = response.responseText.split("&#&#&#");
				$("ListViewContents").innerHTML = result[2];
				if (result[1] != "") {
					alert(result[1]);
				}
				$("basicsearchcolumns").innerHTML = "";
			}
		}
	); 
}
	
function moveDown()
{
    if(document.getElementById('selectedColumns2')!=undefined)
    selectedColumnsObj=document.getElementById('selectedColumns2');
    else
    return;
	var currpos=selectedColumnsObj.options.selectedIndex
	var tempdisabled= false;
	for (i=0;i<selectedColumnsObj.length;i++)
	{
		if(i != currpos)
			selectedColumnsObj.options[i].selected=false
	}
    if(currpos>=0)
    {
        if (currpos<selectedColumnsObj.options.length-1)
	{
		var nextpos=selectedColumnsObj.options.selectedIndex+1

		if (browser_ie)
		{
			temp=selectedColumnsObj.options[nextpos].innerText
			tempdisabled = selectedColumnsObj.options[nextpos].disabled;
			selectedColumnsObj.options[nextpos].innerText=selectedColumnsObj.options[currpos].innerText
			selectedColumnsObj.options[nextpos].disabled = false;
			selectedColumnsObj.options[nextpos];

			selectedColumnsObj.options[currpos].innerText=temp
			selectedColumnsObj.options[currpos].disabled = tempdisabled;
		}
		else if (browser_nn4 || browser_nn6)
		{
			temp=selectedColumnsObj.options[nextpos].text
			tempdisabled = selectedColumnsObj.options[nextpos].disabled;
			selectedColumnsObj.options[nextpos].text=selectedColumnsObj.options[currpos].text
			selectedColumnsObj.options[nextpos].disabled = false;
			selectedColumnsObj.options[nextpos];
			selectedColumnsObj.options[currpos].text=temp
			selectedColumnsObj.options[currpos].disabled = tempdisabled;
		}
		temp=selectedColumnsObj.options[nextpos].value
		selectedColumnsObj.options[nextpos].value=selectedColumnsObj.options[currpos].value
		selectedColumnsObj.options[currpos].value=temp

		selectedColumnsObj.options[nextpos].selected=true
		selectedColumnsObj.options[currpos].selected=false
	}
        
    }
	
}

function sss(){
    $( "ul" ).sortable({         
        update:function(){                
            var array = [];               
            $("ul").children("li").each(function() {                  
                array.push(this.id);               
            }); //array确定顺序的字符串             
            newid = array.join(','); //转化为字符串数组传给后台            
            $.get("ajx.php",{name:newid}) //ajax             
        }         
    });
}


function loadCvList(type,id) {
	var element = type+"_cv_list";
	var value = document.getElementById(element).value;        

	var filter = $(element)[$(element).selectedIndex].value	;
	if(filter=='None')return false;
	if(value != '') {
		$("status").style.display="inline";
		new Ajax.Request(
			'index.php',
			{queue: {position: 'end', scope: 'command'},
				method: 'post',
				postBody: 'module=Campaigns&action=CampaignsAjax&file=LoadList&ajax=true&return_action=DetailView&return_id='+id+'&list_type='+type+'&cvid='+value,
				onComplete: function(response) {
					$("status").style.display="none";
					$("RLContents").update(response.responseText);
				}
			}
		);
	}
}

function markSign(module,val){
	var searchurl = $('search_url').value;
	var viewid = getviewId();
	var idstring = "";  
	var obj = document.getElementsByName('folderidVal');
		var select_options = $('allselectedboxes').value;
		var excludedRecords = $('excludedRecords').value;
		var numOfRows = $('numOfRows').value;
		if(select_options == 'all'){
			document.getElementById('idlist').value = select_options;
			idstring = select_options;
			var skiprecords = excludedRecords.split(";");
			var count = skiprecords.length;
			if(count > 1){
				count = numOfRows - count + 1;
			} else {
				count = numOfRows;
			}
		} else {
			var x = select_options.split(";");
			count = x.length;
			if (count > 1) {
				document.getElementById('idlist').value = select_options;
				idstring = select_options;
			} else {
				alert(arrJsPopLabel['PLEASESELECTONEENTITY']);
				return false;
			}
			//we have to decrese the count value by 1 because when we split with semicolon we will get one extra count
			count = count - 1;
		} 
	if(count > getMaxMassOperationLimit()) {
		var confirm_str = arrJsPopLabel['YOUCHOOSEMORETHAN500RECORDS'];
		if(confirm(confirm_str)) var confirm_status = true;
		else return false;
	}
	else confirm_status = true;
	if(confirm_status){

			$("status").style.display="inline";
			var url = "&excludedRecords="+excludedRecords;

			new Ajax.Request(
				'index.php',
				{
					queue: {
						position: 'end',
						scope: 'command'
					},
					method: 'post',
					postBody:"module=Reminds&action=SignMark&return_module="+module+"&"+gstart+"&viewname="+viewid+"&idlist="+idstring+searchurl+url+'&sign_value='+val,
					onComplete: function(response) {
						$("status").style.display="none";
						result = response.responseText.split('&#&#&#');
						$("ListViewContents").innerHTML= result[2];
						if(result[1] != '')
							alert(result[1]);
						$('basicsearchcolumns').innerHTML = '';
						$('allselectedboxes').value='';
						$('excludedRecords').value='';
                        ActivityReminderCallback();
					}
				}
				);
	}    
}
function toggleSelectDocumentRecords(module,state,relCheckName,parentEleId) {

	toggleSelect_ListView(state,relCheckName,parentEleId);
	if(state == true) {
		$('selectedboxes_'+parentEleId).value = 'all';
		$('selectAllRec_'+parentEleId).style.display = 'none';
		$('deSelectAllRec_'+parentEleId).style.display = 'inline';
	} else {
		$('selectedboxes_'+parentEleId).value = '';
		$('excludedRecords_'+parentEleId).value = '';
		$('currentPageRec_'+parentEleId).checked = false;
		$('selectAllRec_'+parentEleId).style.display = 'inline';
		$('deSelectAllRec_'+parentEleId).style.display = 'none';
		$('linkForSelectAll_'+parentEleId).hide();
	}
}