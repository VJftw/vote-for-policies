import Head from 'next/head'
import Layout, { siteTitle } from '../components/layout'
import { GetStaticProps } from 'next'

export default function Survey() {
  return (
    <Layout>
      <Head>
        <title>Survey | {siteTitle}</title>
      </Head>

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
