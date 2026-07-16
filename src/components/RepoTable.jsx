import { ArrowUpRightIcon } from './Icons'

export function RepoTable({ tools }) {
  return (
    <div className="repo-table-wrap">
      <table className="repo-table">
        <thead>
          <tr>
            <th>เครื่องมือ</th>
            <th>แพลตฟอร์ม</th>
            <th>รองรับ</th>
            <th>จุดเด่น</th>
            <th>เหมาะกับ</th>
            <th><span className="visually-hidden">GitHub</span></th>
          </tr>
        </thead>
        <tbody>
          {tools.map((tool) => (
            <tr key={tool.name}>
              <th scope="row">{tool.name}</th>
              <td data-label="แพลตฟอร์ม">{tool.platform}</td>
              <td data-label="รองรับ">{tool.supports}</td>
              <td data-label="จุดเด่น">{tool.highlight}</td>
              <td data-label="เหมาะกับ">{tool.bestFor}</td>
              <td className="repo-link-cell">
                <a href={tool.url} target="_blank" rel="noreferrer" aria-label={`เปิด ${tool.name} บน GitHub`}>
                  <ArrowUpRightIcon />
                </a>
              </td>
            </tr>
          ))}
        </tbody>
      </table>
    </div>
  )
}
