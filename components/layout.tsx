import Head from 'next/head'
import Link from 'next/link'

export const siteTitle = 'Vote for Policies'

export default function Layout({children}) {
  return (
    <div>
      <Head>
        <link rel="icon" href="/favicon.ico" />
        <meta
          name="description"
          content=""
        />
        <meta name="og:title" content={siteTitle} />
      </Head>
      <nav className="navbar is-dark" role="navigation" aria-label="main navigation">
        <div className="navbar-brand">
          <a className="navbar-item" href="/">{siteTitle}</a>
          <a
            role="button"
            className="navbar-burger burger"
            aria-label="menu"
            aria-expanded="false"
            data-target="mainNavBar"
          >
            <span aria-hidden="true"></span>
            <span aria-hidden="true"></span>
            <span aria-hidden="true"></span>
          </a>
        </div>
        <div id="mainNavBar" className="navbar-menu">
          <div className="navbar-start"></div>

          <div className="navbar-end">
            <Link href="/"><a className="navbar-item has-text-weight-bold">Survey</a></Link>
          </div>
        </div>
      </nav>
      <div className="container">
      {children}
      </div>
    </div>
  )
}
