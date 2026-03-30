import React from 'react'
import { useState, type ReactNode } from 'react'

void React

export type PageKey = 'overview' | 'features' | 'security' | 'architecture' | 'install' | 'faq'

type NavItem = {
  key: PageKey
  label: string
  href: string
}

type HeroMetric = {
  value: string
  label: string
}

type HeroContent = {
  eyebrow: string
  title: string
  body: string
  primaryCta: { label: string; href: string }
  secondaryCta: { label: string; href: string }
  metrics: HeroMetric[]
}

type InsightCard = {
  title: string
  body: string
}

type SectionIntro = {
  eyebrow: string
  title: string
  body: string
}

type FeatureCard = {
  title: string
  body: string
  points: string[]
}

type TimelineStep = {
  step: string
  title: string
  body: string
}

type FaqItem = {
  question: string
  answer: string
}

type InstallCommand = {
  label: string
  title: string
  command: string
  note: string
}

const githubRepoUrl = 'https://github.com/NyxCloudRO/NyxGate'
const supportUrl = 'https://buymeacoffee.com/nyxmael'

const navItems: NavItem[] = [
  { key: 'overview', label: 'Overview', href: '/NyxGate/' },
  { key: 'features', label: 'Features', href: '/NyxGate/features/' },
  { key: 'security', label: 'Security', href: '/NyxGate/security/' },
  { key: 'architecture', label: 'Architecture', href: '/NyxGate/architecture/' },
  { key: 'install', label: 'Install', href: '/NyxGate/install/' },
  { key: 'faq', label: 'FAQ', href: '/NyxGate/faq/' },
]

const heroByPage: Record<PageKey, HeroContent> = {
  overview: {
    eyebrow: 'Unified Security & Endpoint Management',
    title: 'A sharper control plane for endpoint security, visibility, and response.',
    body:
      'NyxGate brings host inventory, telemetry, investigations, prevention controls, patch operations, and response workflows into one cohesive operating platform for modern security teams.',
    primaryCta: { label: 'View Installation', href: '/NyxGate/install/' },
    secondaryCta: { label: 'Explore Features', href: '/NyxGate/features/' },
    metrics: [
      { value: 'Single Surface', label: 'Inventory, detections, response, and posture in one product.' },
      { value: 'Operator Ready', label: 'Built for real investigations rather than cosmetic dashboards.' },
      { value: 'Deployment Aware', label: 'Installation, enrollment, and live control are part of the platform.' },
    ],
  },
  features: {
    eyebrow: 'Product Capabilities',
    title: 'A complete operating surface for daily security work.',
    body:
      'NyxGate is designed so operators can move from fleet posture to a single host, from a suspicious signal to evidence, and from analysis to action without switching tools or losing context.',
    primaryCta: { label: 'Read Security Model', href: '/NyxGate/security/' },
    secondaryCta: { label: 'Read Architecture', href: '/NyxGate/architecture/' },
    metrics: [
      { value: 'Fleet View', label: 'See what is deployed, healthy, exposed, and drifting.' },
      { value: 'Threat View', label: 'Understand suspicious behavior with context that stays connected.' },
      { value: 'Response View', label: 'Contain, patch, or review posture from the same workflow.' },
    ],
  },
  security: {
    eyebrow: 'Security Model',
    title: 'Security fundamentals built into the product, not added around it.',
    body:
      'NyxGate is structured around secure administration, controlled enrollment, protected transport, and auditable operator actions so the management plane remains trustworthy as the platform evolves.',
    primaryCta: { label: 'Review Install Flow', href: '/NyxGate/install/' },
    secondaryCta: { label: 'Read FAQ', href: '/NyxGate/faq/' },
    metrics: [
      { value: 'Protected Setup', label: 'Secure first-run bootstrap with recovery flow and MFA support.' },
      { value: 'Controlled Enrollment', label: 'Token-based host onboarding keeps trust establishment explicit.' },
      { value: 'Auditable Operations', label: 'Operator actions are designed for review and accountability.' },
    ],
  },
  architecture: {
    eyebrow: 'System Architecture',
    title: 'A clean platform layout for control, telemetry, and host enforcement.',
    body:
      'NyxGate separates the operator console, controller services, and host-side agent responsibilities so deployment remains understandable and future scaling stays practical.',
    primaryCta: { label: 'Explore Features', href: '/NyxGate/features/' },
    secondaryCta: { label: 'Start Installation', href: '/NyxGate/install/' },
    metrics: [
      { value: 'Controller Plane', label: 'Central APIs, enrollment, policy distribution, and audit handling.' },
      { value: 'Host Agent', label: 'Local telemetry, control actions, and posture reporting on enrolled systems.' },
      { value: 'Operator Console', label: 'A focused interface for security operations and day-to-day decisions.' },
    ],
  },
  install: {
    eyebrow: 'Deployment',
    title: 'Install NyxGate from the official project workflow.',
    body:
      'The install page follows the official NyxGate repository workflow: deploy the Docker-based controller, preserve data under `/opt/nyxgate/data`, open the panel on port 8443, and continue onboarding hosts from the platform itself.',
    primaryCta: { label: 'Open GitHub', href: githubRepoUrl },
    secondaryCta: { label: 'Read FAQ', href: '/NyxGate/faq/' },
    metrics: [
      { value: 'Guided Bootstrap', label: 'Administrative setup is part of the product experience.' },
      { value: 'Agent Enrollment', label: 'Hosts register through a dedicated install and trust flow.' },
      { value: 'Immediate Utility', label: 'Operators can inspect posture and act as soon as hosts appear.' },
    ],
  },
  faq: {
    eyebrow: 'Frequently Asked Questions',
    title: 'Clear answers to the questions teams ask before they deploy.',
    body:
      'The FAQ focuses on scope, deployment model, product fit, and operating assumptions so evaluators can understand what NyxGate is built for without digging through internal implementation notes.',
    primaryCta: { label: 'Review Architecture', href: '/NyxGate/architecture/' },
    secondaryCta: { label: 'Installation Guide', href: '/NyxGate/install/' },
    metrics: [
      { value: 'Product Scope', label: 'Understand what NyxGate covers and what it is designed to replace.' },
      { value: 'Deployment Basics', label: 'See how the controller and agents fit together.' },
      { value: 'Operational Fit', label: 'Know where NyxGate is strongest for security teams today.' },
    ],
  },
}

const overviewIntro: SectionIntro = {
  eyebrow: 'Why NyxGate',
  title: 'Built for operators who need one system that can actually carry the work.',
  body:
    'NyxGate is not a thin dashboard layered over scattered tools. It is a unified product surface where investigation, posture management, policy work, and response live within the same operational model.',
}

const platformPillars: FeatureCard[] = [
  {
    title: 'Unified host visibility',
    body: 'Bring inventory, health, patch posture, and host context into a single operational view.',
    points: ['Fleet inventory and lifecycle awareness', 'Live host context and posture signals', 'Faster pivots from overview into investigation'],
  },
  {
    title: 'Detection with context',
    body: 'Review suspicious behavior with the surrounding evidence instead of working from isolated alerts.',
    points: ['Behavior-oriented event review', 'Process and network context where it matters', 'Designed for investigation rather than raw alert counting'],
  },
  {
    title: 'Response in the same lane',
    body: 'Move from identifying a problem to acting on it without switching products.',
    points: ['Host isolation and response controls', 'Patch and posture actions close to the evidence', 'Operator workflows that reduce context switching'],
  },
]

const overviewWorkflow: TimelineStep[] = [
  {
    step: '01',
    title: 'See the fleet clearly',
    body: 'Start with platform-wide posture, current priorities, and the hosts that need attention first.',
  },
  {
    step: '02',
    title: 'Drill into the exact system',
    body: 'Open a host to inspect context, recent behavior, exposure, patch state, and operational history.',
  },
  {
    step: '03',
    title: 'Review the evidence',
    body: 'Move from a suspicious event into related traffic, processes, services, or detections without losing context.',
  },
  {
    step: '04',
    title: 'Take the next action',
    body: 'Contain, patch, investigate further, or adjust posture from the same operating surface.',
  },
]

const operatorCards: InsightCard[] = [
  {
    title: 'Purpose-built navigation',
    body: 'The product is organized around how teams work: fleet posture, threats, traffic, firewall posture, patching, and host access.',
  },
  {
    title: 'Actionable depth',
    body: 'NyxGate aims to present enough context to support decisions without burying teams in decorative charts or disconnected metrics.',
  },
  {
    title: 'Professional operating model',
    body: 'Installation, enrollment, authentication, and daily administration are treated as core product experiences, not afterthoughts.',
  },
]

const featuresIntro: SectionIntro = {
  eyebrow: 'Feature Map',
  title: 'The major product areas NyxGate brings together.',
  body:
    'Each area is part of the same platform, so operators can move naturally across posture, detections, and response instead of maintaining a fragmented toolchain.',
}

const featureAreas: FeatureCard[] = [
  {
    title: 'Fleet and asset awareness',
    body: 'Track enrolled systems, understand current posture, and know which hosts deserve attention first.',
    points: ['Inventory and lifecycle controls', 'Health and availability awareness', 'Host context that supports triage'],
  },
  {
    title: 'Threat investigation',
    body: 'Review suspicious activity through a workflow built for correlation, context, and operator judgment.',
    points: ['Threat review surfaces', 'Evidence-driven host pivots', 'Narrative context for investigations'],
  },
  {
    title: 'Traffic and exposure insight',
    body: 'Understand how hosts communicate and where network exposure or drift may exist.',
    points: ['Traffic exploration', 'Service and exposure visibility', 'Destination and process-oriented review'],
  },
  {
    title: 'Firewall and prevention controls',
    body: 'Manage security posture and preventive controls from within the same system you use to investigate.',
    points: ['Policy and posture workflows', 'Rule management paths', 'Operational review of host exposure'],
  },
  {
    title: 'Patch operations',
    body: 'Move patch visibility and execution closer to the systems and risks that require action.',
    points: ['Patch posture summaries', 'Package drift awareness', 'Execution-oriented remediation flow'],
  },
  {
    title: 'Audited host access',
    body: 'Open terminal access as part of an investigation or operational workflow without leaving the platform.',
    points: ['Remote operator access workflow', 'Designed for accountability', 'Fits incident and maintenance use cases'],
  },
]

const securityIntro: SectionIntro = {
  eyebrow: 'Security Priorities',
  title: 'The management plane should be trustworthy before it is convenient.',
  body:
    'NyxGate’s security model starts with controlled setup and enrollment, then extends through authenticated administration, protected control traffic, and deliberate operator workflows.',
}

const securityPrinciples: FeatureCard[] = [
  {
    title: 'Secure first-run setup',
    body: 'Initial administrative setup is handled through an explicit bootstrap flow instead of hidden defaults.',
    points: ['Protected admin initialization', 'Recovery workflow support', 'MFA-first operational posture'],
  },
  {
    title: 'Controlled host enrollment',
    body: 'Trust is established through enrollment mechanisms rather than anonymous host registration.',
    points: ['Enrollment token workflow', 'Purpose-built install helpers', 'Host onboarding aligned to controller trust'],
  },
  {
    title: 'Protected control traffic',
    body: 'Controller communication is designed around encrypted transport and authenticated endpoints.',
    points: ['TLS-secured control plane', 'Authenticated API access', 'Separated admin and agent credentials'],
  },
  {
    title: 'Accountable operations',
    body: 'Security tools are strongest when operator actions can be reviewed and understood later.',
    points: ['Audit-minded workflows', 'Operator authentication model', 'Designed for security team accountability'],
  },
]

const securityNotes: InsightCard[] = [
  {
    title: 'Designed for operational security',
    body: 'NyxGate treats administration and host trust as core product concerns, not just infrastructure assumptions.',
  },
  {
    title: 'Security and usability together',
    body: 'The platform aims to stay deployable and approachable without weakening the boundaries around access and enrollment.',
  },
  {
    title: 'Ready for stronger phases',
    body: 'The architecture leaves room for stronger policy signing, more mature RBAC, and deeper trust guarantees over time.',
  },
]

const architectureIntro: SectionIntro = {
  eyebrow: 'Platform Layout',
  title: 'A structure that keeps responsibilities clear.',
  body:
    'NyxGate is organized so the operator experience, controller services, and host-side execution each have a distinct role. That separation makes the system easier to understand, deploy, and extend.',
}

const architectureLayers: FeatureCard[] = [
  {
    title: 'Operator console',
    body: 'The web interface is the control surface for posture review, investigation, policy work, and host actions.',
    points: ['Focused SOC-style navigation', 'Administrative and operational workflows', 'Designed for day-to-day security use'],
  },
  {
    title: 'Controller plane',
    body: 'The controller coordinates enrollment, APIs, policy distribution, and event ingestion for the platform.',
    points: ['REST and live-update interfaces', 'Enrollment and install distribution', 'Centralized operational control'],
  },
  {
    title: 'Host-side agent',
    body: 'Enrolled systems report telemetry, posture, and execution context while receiving managed control instructions.',
    points: ['Local data collection', 'Operational reporting from the host', 'Action path for response and management'],
  },
  {
    title: 'Data and event flow',
    body: 'The platform is structured to support normalized event ingestion, durable storage, and future scaling phases.',
    points: ['Security event ingestion', 'Operational storage model', 'Path toward broader streaming and correlation'],
  },
]

const architectureFlow: TimelineStep[] = [
  {
    step: 'A',
    title: 'Deploy the controller',
    body: 'Stand up the web and API control plane that will handle setup, enrollment, and daily operations.',
  },
  {
    step: 'B',
    title: 'Enroll endpoints',
    body: 'Generate controlled enrollment and register real systems into the platform with installation helpers.',
  },
  {
    step: 'C',
    title: 'Collect and normalize',
    body: 'Telemetry, posture, and host context are brought back into the central platform for operator review.',
  },
  {
    step: 'D',
    title: 'Operate and enforce',
    body: 'Use the console for visibility, policy work, investigations, and controlled response actions.',
  },
]

const installIntro: SectionIntro = {
  eyebrow: 'Official Install Flow',
  title: 'Deploy NyxGate using the same workflow published in the official repository.',
  body:
    'NyxGate is delivered as a Docker-based deployment with persistent data under `/opt/nyxgate/data`. The commands below follow the official GitHub workflow so teams can install, access, and upgrade the platform consistently.',
}

const installSteps: TimelineStep[] = [
  {
    step: '01',
    title: 'Run the official installer as root',
    body: 'Use the published install script from the NyxGate GitHub repository. The installer validates the environment, installs Docker if required, prepares storage, and launches the NyxGate services.',
  },
  {
    step: '02',
    title: 'Access the controller on port 8443',
    body: 'After deployment, open the NyxGate panel at `https://<server-ip>:8443` and complete the secure first-run setup from the product itself.',
  },
  {
    step: '03',
    title: 'Preserve persistent platform data',
    body: 'NyxGate stores users, recovery data, rules, audit history, patch state, and related platform data under `/opt/nyxgate/data` so upgrades and rebuilds preserve the platform state.',
  },
  {
    step: '04',
    title: 'Upgrade with the published upgrade script',
    body: 'Use the published upgrade command to check Docker Hub for a newer NyxGate release, fetch the matching official release bundle, and upgrade while keeping the persistent data path in place.',
  },
]

const installChecklist: FeatureCard[] = [
  {
    title: 'Supported deployment baseline',
    body: 'The published install flow is designed around Linux systems with Docker available or installable by the script.',
    points: ['Ubuntu and Debian install support', 'Docker-based runtime model', 'HTTPS service exposed on port 8443'],
  },
  {
    title: 'Minimum practical requirements',
    body: 'The official repository guidance keeps the baseline requirements straightforward for an initial deployment.',
    points: ['2 CPU minimum', '4 GB RAM recommended', 'Persistent data stored under /opt/nyxgate/data'],
  },
  {
    title: 'What happens after the controller is live',
    body: 'Once the panel is available, teams move into secure setup, enrollment generation, and day-to-day platform operations from the web console.',
    points: ['Complete first-run bootstrap', 'Generate enrollment and install commands', 'Begin fleet visibility and response workflows'],
  },
]

const installCommands: InstallCommand[] = [
  {
    label: 'First Install',
    title: 'Install NyxGate',
    command: 'curl -sSL https://raw.githubusercontent.com/NyxCloudRO/NyxGate/main/install/install.sh | bash',
    note: 'Run as root on a supported Linux host. The script installs Docker when needed, prepares `/opt/nyxgate/data`, and starts the published NyxGate deployment flow.',
  },
  {
    label: 'Upgrade',
    title: 'Upgrade NyxGate',
    command: 'curl -sSL https://raw.githubusercontent.com/NyxCloudRO/NyxGate/main/install/upgrade.sh | bash',
    note: 'Run as root to check for a newer published release automatically and apply it only when one is available, while preserving the persistent data directory.',
  },
]

const faqItems: FaqItem[] = [
  {
    question: 'What is NyxGate?',
    answer:
      'NyxGate is a unified security and endpoint management platform that combines host visibility, threat investigation, prevention controls, patch operations, and response workflows in one product.',
  },
  {
    question: 'Who is it built for?',
    answer:
      'It is built for security operators, infrastructure teams, and administrators who want one management plane for day-to-day host security operations instead of a loose collection of separate tools.',
  },
  {
    question: 'Is NyxGate only a firewall product?',
    answer:
      'No. Firewall posture is one part of the platform, but NyxGate is broader than that. It is designed around visibility, investigation, host operations, and controlled response as a unified experience.',
  },
  {
    question: 'How is NyxGate deployed?',
    answer:
      'The platform is centered on a controller that exposes the UI and APIs, plus agents installed on enrolled hosts so the controller can receive telemetry and manage operations.',
  },
  {
    question: 'How do hosts join the platform?',
    answer:
      'Hosts join through a dedicated enrollment workflow. The controller provides install and registration helpers so onboarding remains explicit and manageable.',
  },
  {
    question: 'What kind of workflows does it support?',
    answer:
      'NyxGate supports posture review, threat investigation, traffic review, prevention and firewall operations, patch-related workflows, and audited host access for operational follow-through.',
  },
  {
    question: 'Does the product include a secure setup process?',
    answer:
      'Yes. The current product foundation includes a secure first-run bootstrap path with administrative setup and recovery-oriented workflow support.',
  },
  {
    question: 'Where does NyxGate fit best today?',
    answer:
      'NyxGate fits best where teams want one platform for host visibility, investigation, patch operations, and response without stitching together several disconnected tools. It is especially strong for operators who value clarity, control, and a tighter day-to-day workflow.',
  },
]

function getPageKey(): PageKey {
  if (typeof document === 'undefined') {
    return 'overview'
  }

  const value = document.body.dataset.page

  if (
    value === 'overview' ||
    value === 'features' ||
    value === 'security' ||
    value === 'architecture' ||
    value === 'install' ||
    value === 'faq'
  ) {
    return value
  }

  return 'overview'
}

function SectionHeader({ intro }: { intro: SectionIntro }) {
  return (
    <div className="section-header">
      <span className="section-eyebrow">{intro.eyebrow}</span>
      <h2>{intro.title}</h2>
      <p>{intro.body}</p>
    </div>
  )
}

function FeatureGrid({ items }: { items: FeatureCard[] }) {
  return (
    <div className="feature-grid">
      {items.map((item) => (
        <article key={item.title} className="feature-card">
          <div className="feature-card-mark" aria-hidden="true" />
          <h3>{item.title}</h3>
          <p>{item.body}</p>
          <ul className="feature-points">
            {item.points.map((point) => (
              <li key={point}>{point}</li>
            ))}
          </ul>
        </article>
      ))}
    </div>
  )
}

function InsightGrid({ items }: { items: InsightCard[] }) {
  return (
    <div className="insight-grid">
      {items.map((item) => (
        <article key={item.title} className="insight-card">
          <h3>{item.title}</h3>
          <p>{item.body}</p>
        </article>
      ))}
    </div>
  )
}

function Timeline({ items }: { items: TimelineStep[] }) {
  return (
    <div className="timeline">
      {items.map((item) => (
        <article key={item.step + item.title} className="timeline-card">
          <span className="timeline-step">{item.step}</span>
          <h3>{item.title}</h3>
          <p>{item.body}</p>
        </article>
      ))}
    </div>
  )
}

function FaqList({ items }: { items: FaqItem[] }) {
  return (
    <div className="faq-list">
      {items.map((item) => (
        <details key={item.question} className="faq-item">
          <summary>{item.question}</summary>
          <p>{item.answer}</p>
        </details>
      ))}
    </div>
  )
}

function HeroVisual({ currentPage }: { currentPage: PageKey }) {
  const pageAccent: Record<PageKey, string> = {
    overview: 'Visibility',
    features: 'Capabilities',
    security: 'Trust Model',
    architecture: 'Platform Design',
    install: 'Deployment',
    faq: 'Guidance',
  }
  return (
    <div className="hero-visual" aria-hidden="true">
      <div className="hero-panel hero-panel-main">
        <div className="hero-panel-top">
          <div>
            <small>NyxGate Platform</small>
            <strong>{pageAccent[currentPage]}</strong>
          </div>
          <div className="hero-status-pill">Unified</div>
        </div>
        <div className="hero-visual-grid">
          <article className="hero-visual-card hero-visual-card-large">
            <span>Fleet Visibility</span>
            <strong>Inventory, posture, and live host context</strong>
          </article>
          <article className="hero-visual-card">
            <span>Threat Detection</span>
            <strong>Signals with operator context</strong>
          </article>
          <article className="hero-visual-card">
            <span>Response Control</span>
            <strong>Containment, patching, and follow-through</strong>
          </article>
        </div>
        <div className="hero-diagram">
          <div className="hero-diagram-node">Visibility</div>
          <div className="hero-diagram-node">Detection</div>
          <div className="hero-diagram-node">Policy</div>
          <div className="hero-diagram-node">Access</div>
        </div>
        <div className="hero-summary">
          <div className="hero-summary-row">
            <span className="hero-summary-dot" />
            <p>One product surface for visibility, controls, and endpoint operations.</p>
          </div>
          <div className="hero-summary-row">
            <span className="hero-summary-dot" />
            <p>Clear, restrained presentation designed to reflect a credible platform brand.</p>
          </div>
        </div>
      </div>
    </div>
  )
}

function SiteShell({
  currentPage,
  children,
}: {
  currentPage: PageKey
  children: ReactNode
}) {
  const [menuOpen, setMenuOpen] = useState(false)

  return (
    <div className="site-shell">
      <div className="page-background" aria-hidden="true">
        <div className="page-background-grid" />
        <div className="page-background-orb page-background-orb-a" />
        <div className="page-background-orb page-background-orb-b" />
      </div>
      <header className="site-header">
        <div className="container header-shell">
          <div className="header-top">
            <a className="brand" href="/NyxGate/">
              <span className="brand-badge">N</span>
              <span className="brand-copy">
                <strong>NyxGate</strong>
                <small>Unified Security &amp; Endpoint Management</small>
              </span>
            </a>
            <button
              type="button"
              className={`menu-toggle${menuOpen ? ' is-open' : ''}`}
              aria-label="Toggle navigation"
              aria-expanded={menuOpen}
              aria-controls="site-navigation-panel"
              onClick={() => setMenuOpen((open) => !open)}
            >
              <span />
              <span />
              <span />
            </button>
          </div>
          <div id="site-navigation-panel" className={`header-panel${menuOpen ? ' is-open' : ''}`}>
            <nav className="site-nav" aria-label="Primary">
              {navItems.map((item) => (
                <a
                  key={item.key}
                  href={item.href}
                  className={item.key === currentPage ? 'active' : undefined}
                  onClick={() => setMenuOpen(false)}
                >
                  {item.label}
                </a>
              ))}
            </nav>
            <div className="header-actions">
              <a
                className="button button-ghost button-compact"
                href={supportUrl}
                target="_blank"
                rel="noreferrer"
                onClick={() => setMenuOpen(false)}
              >
                Buy Me a Coffee
              </a>
              <a
                className="button button-primary button-compact"
                href={githubRepoUrl}
                target="_blank"
                rel="noreferrer"
                onClick={() => setMenuOpen(false)}
              >
                GitHub
              </a>
            </div>
          </div>
        </div>
      </header>
      {children}
      <footer className="site-footer">
        <div className="container footer-shell">
          <div>
            <strong>NyxGate</strong>
            <p>
              Unified visibility, detection, host operations, and response for teams that want a more coherent
              security operating model.
            </p>
          </div>
          <div className="footer-links" aria-label="Footer">
            {navItems.map((item) => (
              <a key={item.key} href={item.href}>
                {item.label}
              </a>
            ))}
          </div>
        </div>
      </footer>
    </div>
  )
}

function Hero({ currentPage }: { currentPage: PageKey }) {
  const hero = heroByPage[currentPage]

  return (
    <section className="hero">
      <div className="container hero-shell">
        <div className="hero-copy">
          <span className="section-eyebrow">{hero.eyebrow}</span>
          <h1>{hero.title}</h1>
          <p>{hero.body}</p>
          <div className="hero-actions">
            <a className="button button-primary" href={hero.primaryCta.href}>
              {hero.primaryCta.label}
            </a>
            <a className="button button-ghost" href={hero.secondaryCta.href}>
              {hero.secondaryCta.label}
            </a>
          </div>
          <div className="hero-metrics">
            {hero.metrics.map((metric) => (
              <article key={metric.value} className="metric-card">
                <strong>{metric.value}</strong>
                <span>{metric.label}</span>
              </article>
            ))}
          </div>
        </div>
        <HeroVisual currentPage={currentPage} />
      </div>
    </section>
  )
}

function OverviewPage() {
  return (
    <>
      <section className="section">
        <div className="container">
          <SectionHeader intro={overviewIntro} />
          <FeatureGrid items={platformPillars} />
        </div>
      </section>

      <section className="section section-alt">
        <div className="container split-shell">
          <div>
            <SectionHeader
              intro={{
                eyebrow: 'Operating Flow',
                title: 'From visibility to action without leaving the product.',
                body:
                  'The experience is shaped around how operators work when something matters: understand the environment, focus the host, inspect the evidence, and decide the next move.',
              }}
            />
          </div>
          <Timeline items={overviewWorkflow} />
        </div>
      </section>

      <section className="section">
        <div className="container">
          <SectionHeader
            intro={{
              eyebrow: 'Professional Product Direction',
              title: 'A sharper website should reflect a sharper product.',
              body:
                'NyxGate is a serious security platform. The public experience should feel clear, credible, and deliberate, with language that explains the product confidently without oversharing internals.',
            }}
          />
          <InsightGrid items={operatorCards} />
        </div>
      </section>
    </>
  )
}

function FeaturesPage() {
  return (
    <>
      <section className="section">
        <div className="container">
          <SectionHeader intro={featuresIntro} />
          <FeatureGrid items={featureAreas} />
        </div>
      </section>
      <section className="section section-alt">
        <div className="container">
          <SectionHeader
            intro={{
              eyebrow: 'Operator Value',
              title: 'Less fragmentation, better decisions.',
              body:
                'NyxGate is strongest when teams want one place to understand hosts, review suspicious activity, and carry the next operational step forward without rebuilding context in another system.',
            }}
          />
          <InsightGrid
            items={[
              {
                title: 'Faster orientation',
                body: 'Operators spend less time translating between separate products and more time understanding what actually matters.',
              },
              {
                title: 'Clearer ownership',
                body: 'Visibility, policy, patching, and host response remain attached to the same operational surface.',
              },
              {
                title: 'Stronger consistency',
                body: 'Teams get one product language and one working model instead of a stack of mismatched interfaces.',
              },
            ]}
          />
        </div>
      </section>
    </>
  )
}

function SecurityPage() {
  return (
    <>
      <section className="section">
        <div className="container">
          <SectionHeader intro={securityIntro} />
          <FeatureGrid items={securityPrinciples} />
        </div>
      </section>
      <section className="section section-alt">
        <div className="container">
          <SectionHeader
            intro={{
              eyebrow: 'Security Positioning',
              title: 'High-level clarity for buyers, deeper detail for operators.',
              body:
                'The website explains security in a way that is credible, accurate, and professional while keeping lower-level implementation specifics in technical documentation where they belong.',
            }}
          />
          <InsightGrid items={securityNotes} />
        </div>
      </section>
    </>
  )
}

function ArchitecturePage() {
  return (
    <>
      <section className="section">
        <div className="container">
          <SectionHeader intro={architectureIntro} />
          <FeatureGrid items={architectureLayers} />
        </div>
      </section>
      <section className="section section-alt">
        <div className="container split-shell">
          <div>
            <SectionHeader
              intro={{
                eyebrow: 'System Flow',
                title: 'A straightforward path from deployment to operations.',
                body:
                  'This high-level model keeps the public architecture page useful without diving into internal engineering detail that is better suited to implementation documentation.',
              }}
            />
          </div>
          <Timeline items={architectureFlow} />
        </div>
      </section>
    </>
  )
}

function InstallPage() {
  return (
    <>
      <section className="section">
        <div className="container split-shell">
          <div>
            <SectionHeader intro={installIntro} />
          </div>
          <Timeline items={installSteps} />
        </div>
      </section>
      <section className="section section-alt">
        <div className="container">
          <SectionHeader
            intro={{
              eyebrow: 'Install Commands',
              title: 'Use the official commands from the NyxGate repository.',
              body:
                'These are the public install and upgrade commands published for NyxGate. They provide the right starting point for a clean deployment and maintenance workflow.',
            }}
          />
          <div className="command-grid">
            {installCommands.map((item) => (
              <article key={item.label} className="command-card">
                <span className="section-eyebrow">{item.label}</span>
                <h3>{item.title}</h3>
                <pre>
                  <code>{item.command}</code>
                </pre>
                <p>{item.note}</p>
              </article>
            ))}
          </div>
        </div>
      </section>
      <section className="section">
        <div className="container">
          <SectionHeader
            intro={{
              eyebrow: 'Deployment Facts',
              title: 'The key platform expectations before you roll it out.',
              body:
                'The install workflow is straightforward, but the page should still explain what NyxGate expects from the host and what happens after the panel comes online.',
            }}
          />
          <FeatureGrid items={installChecklist} />
        </div>
      </section>
    </>
  )
}

function FaqPage() {
  return (
    <section className="section">
      <div className="container">
        <SectionHeader
          intro={{
            eyebrow: 'Foundational Answers',
            title: 'FAQ that explains the product like a real platform.',
            body:
              'These are the core questions a customer or evaluator should be able to answer after reading the site.',
          }}
        />
        <FaqList items={faqItems} />
      </div>
    </section>
  )
}

function FinalCallToAction() {
  return (
    <section className="section">
      <div className="container">
        <div className="final-cta">
          <div>
            <span className="section-eyebrow">Next Step</span>
            <h2>Start with the official NyxGate install and continue from the live console.</h2>
            <p>
              Use the installation page for the published deployment commands, then use the official GitHub repository
              for source, release updates, and technical detail.
            </p>
          </div>
          <div className="final-cta-actions">
            <a className="button button-primary" href="/NyxGate/install/">
              Installation Guide
            </a>
            <a className="button button-ghost" href={githubRepoUrl} target="_blank" rel="noreferrer">
              GitHub Repository
            </a>
          </div>
        </div>
      </div>
    </section>
  )
}

export default function App({ initialPage }: { initialPage?: PageKey }) {
  const currentPage = initialPage ?? getPageKey()

  return (
    <SiteShell currentPage={currentPage}>
      <main>
        <Hero currentPage={currentPage} />
        {currentPage === 'overview' && <OverviewPage />}
        {currentPage === 'features' && <FeaturesPage />}
        {currentPage === 'security' && <SecurityPage />}
        {currentPage === 'architecture' && <ArchitecturePage />}
        {currentPage === 'install' && <InstallPage />}
        {currentPage === 'faq' && <FaqPage />}
        <FinalCallToAction />
      </main>
    </SiteShell>
  )
}
