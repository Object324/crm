<?php
//18644: 财务发票>列表：查找，基本查询或高级查询后，点击”查找“按钮，关闭基本查询和高级查询的筛选条件，刷新界面。结果：又显示了基本查询的筛选工具栏。
$fld_module=$_REQUEST['fld_module'];
 unset($_SESSION['LiveViewSearch'][$fld_module]);

?>