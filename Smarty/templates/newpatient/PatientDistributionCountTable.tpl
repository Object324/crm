
{foreach key=last_name item=count from=$countinfo}
    <tr>
        <td>{$last_name}</td>
        <td>{$count.current.New}</td>
        <td>{$count.current.Active}</td>
        <td>{$count.current.Unreachable}</td>
        <td>{$count.unvisited.New}</td>
        <td>{$count.unvisited.Active}</td>
        <td>{$count.unvisited.Unreachable}</td>
    </tr>
{/foreach}