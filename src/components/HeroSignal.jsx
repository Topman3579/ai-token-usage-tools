export function HeroSignal({ tools }) {
  return (
    <div className="hero-signal" aria-label="เครื่องมือแปดรายการรวมสู่สัญญาณการใช้งานเดียว">
      <div className="signal-list">
        {tools.map((tool) => (
          <div className="signal-row" key={tool.name}>
            <span>{tool.name}</span>
            <i aria-hidden="true" />
          </div>
        ))}
      </div>
      <svg className="signal-spokes" viewBox="0 0 100 470" preserveAspectRatio="none" aria-hidden="true">
        {tools.map((tool, index) => (
          <line key={tool.name} x1="0" y1={24 + index * 58} x2="100" y2="235" />
        ))}
      </svg>
      <div className="signal-node" aria-hidden="true"><span /></div>
      <div className="signal-output" aria-hidden="true">
        <div className="bars"><i /><i /><i /><i /></div>
        <span>USAGE<br />SIGNAL</span>
      </div>
    </div>
  )
}
