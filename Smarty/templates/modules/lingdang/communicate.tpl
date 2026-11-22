{* editor:gyq_123 reason:显示服务小程序录入的沟通信息  2019/6/18 14:14 ID1000512 *}
<div>
  {if $COUNT >= 1}
  <!--分页-->
  <div class="PageDiv0" style="padding:3px 5px;margin-top:0px; ">
    <div class="ld-flex-start">
      <div class="ld-pagenum-div">{$recordListRange}</div>
        {$NAVIGATION}
    </div>
  </div>
  <!--分页  end-->
{/if}
  <table border="0" cellspacing="1" cellpadding="0" width="100%" class="listdata" name="communicatelist">
    <tr>
       <th width="5%" title="#">#</th>
       <th width="18%" title="日期">日期</th>
       <th title="内容">内容</th>
    </tr>
  </table>
</div>