<link  rel="stylesheet" type="text/css" href="themes/softed/ReportDetail.css"/> 
<div id="all">
<b id="title">查看{$NAME}:</b>{$STARTDATE}——{$ENDDATE}
<table class="table" cellspacing="0" cellpadding="3" border="1" width="100%"
 bordercolordark="#FFFFFF" bordercolorlight="#D6CDBE">
    <tr>
        <td>
            <b><span class="blueword">{$TITLE1}{$TITLE2}总结:</span></b><br />
            <span>{$WORKSUMMARY_W}{$WORKSUMMARY_M}</span>
        </td>
    </tr>
    
    <tr>
        <td>
            <b><span class="blueword">{$TITLE1}{$TITLE2}计划:</span></b><br />
            <span>{$NEXTWEEKPLAN}{$NEXTMONTHPLAN}</span>
        </td>
    </tr>
     
    <tr>
        <td>
        
            <b><span class="blueword">回复:</span></b><br />
            
            {foreach key=k item=imvalue from=$ROW_ARR}
            <span>回复人：</span>
            {$imvalue.username}<br />
                
                    <span>回复内容：{$imvalue.commentcontent}<br /></span>
                    <span>回复时间：{$imvalue.commentdate}</span><br /><br />
         
            {/foreach}
        </td>
    </tr>   
</table>
</div>