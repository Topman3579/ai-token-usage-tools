import './App.css'
import { tools, filters, recommendations, securityChecks } from './data/tools'
import { useMemo, useState } from 'react'
import { ArrowUpRightIcon, CheckIcon, GitHubIcon } from './components/Icons'
import { HeroSignal } from './components/HeroSignal'
import { RepoTable } from './components/RepoTable'

function App() {
  const [activeFilter, setActiveFilter] = useState('all')

  const filteredTools = useMemo(() => {
    if (activeFilter === 'all') return tools
    return tools.filter((tool) => tool.tags.includes(activeFilter))
  }, [activeFilter])

  return (
    <div className="site-shell" id="top">
      <header className="site-header">
        <a className="brand" href="#top" aria-label="AI Token Usage Tools หน้าแรก">
          <span>AI</span> Token Usage Tools
        </a>
        <nav aria-label="เมนูหลัก">
          <a href="#compare">เปรียบเทียบ</a>
          <a href="#recommend">เลือกตามระบบ</a>
          <a href="#security">ความปลอดภัย</a>
        </nav>
      </header>

      <main>
        <section className="hero-section" aria-labelledby="hero-title">
          <div className="hero-copy">
            <h1 id="hero-title">เลือกเครื่องมือเช็ก Token ให้ตรงกับระบบของคุณ</h1>
            <p>
              เปรียบเทียบ 8 GitHub repo สำหรับติดตาม Usage, Quota และค่าใช้จ่ายของ AI Coding Tools
            </p>
            <div className="hero-actions">
              <a className="primary-action" href="#compare">
                ดูตารางเปรียบเทียบ <span aria-hidden="true">→</span>
              </a>
              <a
                className="text-action"
                href="https://github.com/topics/token-usage"
                target="_blank"
                rel="noreferrer"
              >
                เปิด GitHub ทั้งหมด <ArrowUpRightIcon />
              </a>
            </div>
          </div>
          <HeroSignal tools={tools} />
        </section>

        <section className="compare-section" id="compare" aria-labelledby="compare-title">
          <div className="section-heading">
            <h2 id="compare-title">เปรียบเทียบแบบเห็นภาพ</h2>
            <p>กรองตามแพลตฟอร์มและเครื่องมือ AI ที่ใช้งานจริง</p>
          </div>

          <div className="filters" role="group" aria-label="กรองรายการเครื่องมือ">
            {filters.map((filter) => (
              <button
                key={filter.id}
                type="button"
                className={activeFilter === filter.id ? 'is-active' : ''}
                aria-pressed={activeFilter === filter.id}
                onClick={() => setActiveFilter(filter.id)}
              >
                {filter.label}
              </button>
            ))}
          </div>

          <RepoTable tools={filteredTools} />
          <p className="result-count" aria-live="polite">
            แสดง {filteredTools.length} จาก {tools.length} เครื่องมือ
          </p>
        </section>

        <section className="recommend-section" id="recommend" aria-labelledby="recommend-title">
          <div className="section-heading">
            <h2 id="recommend-title">เลือกตามรูปแบบการทำงาน</h2>
            <p>เริ่มจากโจทย์ของระบบ แล้วค่อยเลือกเครื่องมือที่พอดี</p>
          </div>

          <div className="recommendation-list">
            {recommendations.map((item, index) => (
              <article className="recommendation-row" key={item.tool}>
                <span className="recommendation-index" aria-hidden="true">
                  {String(index + 1).padStart(2, '0')}
                </span>
                <div className="recommendation-copy">
                  <h3>{item.title}</h3>
                  <p>{item.description}</p>
                </div>
                <a href={item.url} target="_blank" rel="noreferrer">
                  <span>{item.tool}</span>
                  <span className="github-link"><GitHubIcon /> GitHub <ArrowUpRightIcon /></span>
                </a>
              </article>
            ))}
          </div>
        </section>

        <section className="security-section" id="security" aria-labelledby="security-title">
          <div className="security-content">
            <div className="section-heading">
              <h2 id="security-title">ตรวจความปลอดภัยก่อนติดตั้ง</h2>
              <p>เครื่องมือกลุ่มนี้อ่านไฟล์ usage หรือ session ในเครื่อง จึงควรตรวจเส้นทางข้อมูลก่อนใช้งานจริง</p>
            </div>
            <ul className="security-list">
              {securityChecks.map((check) => (
                <li key={check}>
                  <span className="check-box" aria-hidden="true"><CheckIcon /></span>
                  {check}
                </li>
              ))}
            </ul>
          </div>
          <div className="security-visual" aria-hidden="true">
            <svg viewBox="0 0 380 330" role="presentation">
              <path className="data-path" d="M40 74h76c28 0 34 24 34 46v34M340 74h-72c-31 0-36 24-36 48v32M39 263h74c26 0 37-18 37-43v-9M341 263h-72c-26 0-37-18-37-43v-9" />
              <circle cx="40" cy="74" r="5" />
              <circle cx="340" cy="74" r="5" />
              <circle cx="39" cy="263" r="5" />
              <circle cx="341" cy="263" r="5" />
              <path className="shield" d="M191 62c28 25 60 35 88 42v65c0 70-39 116-88 137-49-21-88-67-88-137v-65c28-7 60-17 88-42Z" />
              <path className="shield-inner" d="M191 86c21 18 44 26 65 32v52c0 49-26 85-65 105-39-20-65-56-65-105v-52c21-6 44-14 65-32Z" />
              <path className="check-mark" d="m162 175 20 21 42-50" />
            </svg>
          </div>
        </section>
      </main>

      <footer>
        <div>
          <strong>AI Token Usage Tools</strong>
          <p>ข้อมูลอ้างอิงจาก README ของแต่ละ GitHub repository · ตรวจล่าสุด 16 ก.ค. 2026</p>
        </div>
        <a href="#top">กลับขึ้นด้านบน <span aria-hidden="true">↑</span></a>
      </footer>
    </div>
  )
}

export default App
