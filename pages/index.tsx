import Head from 'next/head'
import Layout, { siteTitle } from '../components/layout'
import { GetStaticProps } from 'next'

export default function Survey() {
  return (
    <Layout>
      <Head>
        <title>Survey | {siteTitle}</title>
      </Head>
      <section className="hero">
        <div className="hero-body">
          <div className="container">
            <h1 className="title">
              VJ's Test PR
            </h1>
          </div>
        </div>
        </section> 
    </Layout>
  )
}

export const getStaticProps: GetStaticProps = async () => {
  // const allPostsData = getSortedPostsData()
  return {
    props: {
      // allPostsData
    }
  }
}
