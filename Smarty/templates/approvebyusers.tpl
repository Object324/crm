<script type='text/javascript' src='include/js/user_approveby.js'></script>
<table class="mailClient mailClientBg" width="100%" cellspacing="0" cellpadding="0" border="0">
    <tbody>
        <tr>
            <td>
                <table width="100%" cellspacing="0" cellpadding="0" border="0">
                    <tbody>
                        <tr>
                            <td class="moduleName" width="80%" >用户</td>
                            <td class="componentName" width="30%" nowrap="" align="right"></td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
    </tbody>
</table>

<table width="99%" cellspacing="0" cellpadding="0" align="center">
    <tbody>
        <tr height="45">
            <td class="dvtCellLabel" width="20%">
                <img src="themes/softed/images/{'BASICSEARCHLENS'|@getFixedLabel}">
            </td>
            <td class="dvtCellLabel" width="30%">
                <input id="search_txt" class="txtBox" type="text" name="search_text"/>
            </td>
            <td class="dvtCellLabel" width="30%">
                <b>在</b>
                <select id="search_field" name="search_field">
                    <option value="1">账号</option>
                    <option value="2">姓名</option>
                    <option value="3">角色</option>
                </select>
            </td>
            <td class="dvtCellLabel" width="20%">
                <input class="create" type="button" onclick="search_user()" value="立即查找" name="search">
            </td>
        </tr>
        <tr>
            <td align="center" colspan="4" style="padding-top:5px;">
                <table class="small" width="100%">
                    <tbody>
                        <tr>
                        <td class="searchAlph" align="center">A</td>
                        <td class="searchAlph" align="center">B</td>
                        <td class="searchAlph" align="center">C</td>
                        <td class="searchAlph" align="center">D</td>
                        <td class="searchAlph" align="center">E</td>
                        <td class="searchAlph" align="center">F</td>
                        <td class="searchAlph" align="center">G</td>
                        <td class="searchAlph" align="center">H</td>
                        <td class="searchAlph" align="center">I</td>
                        <td class="searchAlph" align="center">J</td>
                        <td class="searchAlph" align="center">K</td>
                        <td class="searchAlph" align="center">L</td>
                        <td class="searchAlph" align="center">M</td>
                        <td class="searchAlph" align="center">N</td>
                        <td class="searchAlph" align="center">O</td>
                        <td class="searchAlph" align="center">P</td>
                        <td class="searchAlph" align="center">Q</td>
                        <td class="searchAlph" align="center">R</td>
                        <td class="searchAlph" align="center">S</td>
                        <td class="searchAlph" align="center">T</td>
                        <td class="searchAlph" align="center">U</td>
                        <td class="searchAlph" align="center">V</td>
                        <td class="searchAlph" align="center">W</td>
                        <td class="searchAlph" align="center">X</td>
                        <td class="searchAlph" align="center">Y</td>
                        <td class="searchAlph" align="center">Z</td>
                        </tr>
                    </tbody>
                </table>
            </td>
        </tr>
    </tbody>
</table>

<div id="ListViewContents">
<table class="small" align="center" width="99%" cellspacing="1" cellpadding="5" border="0" style="background-color: rgb(204, 204, 204);">
    <tbody>
        <tr>
            <td class="lvtCol commonCol">账号</td>
            <td class="lvtCol commonCol">姓名</td>
            <td class="lvtCol commonCol">角色</td>
        </tr>
        {foreach item=value from=$all_users}
        <tr>
            <td class="lvtColData" bgcolor="white" onmouseout="this.className='lvtColData'" onmouseover="this.className='lvtColDataHover'">
            <a href="javascript:window.close();" onclick="set_value_approveby('{$value.id}','{$value.last_name}','{$action_name}')">{$value.user_name}</a>
            <input type="hidden" id="{$value.id}" value="{$value.id}"/>
            </td>
            <td class="lvtColData" bgcolor="white" onmouseout="this.className='lvtColData'" onmouseover="this.className='lvtColDataHover'">{$value.last_name}</td>
            <td class="lvtColData" bgcolor="white" onmouseout="this.className='lvtColData'" onmouseover="this.className='lvtColDataHover'">{$value.rolename}</td>
        </tr>
        {/foreach}
    </tbody>
</table>
</div>