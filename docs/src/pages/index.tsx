import React from 'react';
import clsx from 'clsx';
import Layout from '@theme/Layout';
import Link from '@docusaurus/Link';
import useDocusaurusContext from '@docusaurus/useDocusaurusContext';
import HomepageFeatures from "../components/HomepageFeatures";
import Translate from '@docusaurus/Translate';
import styles from './index.module.css';
import "animate.css/animate.min.css";
import UAParser from 'ua-parser-js';
// import { useDocsVersionCandidates } from '@docusaurus/theme-common/internal';
import { AnimationOnScroll } from 'react-animation-on-scroll';
import HomepageDescription from '../components/HomepageDescription';
import { DownloadAppButton } from '../components/DownloadButton';


function HomepageHeader({
  docsPluginId }) {
  const { siteConfig } = useDocusaurusContext();
  // const version = useDocsVersionCandidates(docsPluginId)[0];
  return (
    <header className={clsx('hero shadow--lw', styles.heroBanner)}>
      <div className="container">
        <div className="row">
          <div className={clsx("col col--6", styles.center)}>
            <h1 data-aos="fade-up" className="hero__title">
              {siteConfig.title}
            </h1>
            <p data-aos="fade-up" className="hero__subtitle">
              <Translate description="homepage getting started button">
                {siteConfig.tagline}
              </Translate>
            </p>
            <div className={styles.indexCtas}>
              <AnimationOnScroll animateIn="animate__fadeInLeft">
                <DownloadAppButton className={styles.button} />
              </AnimationOnScroll>
              <AnimationOnScroll animateIn="animate__fadeInUp">
                <Link className={clsx("button button--outline button--lg button--secondary", styles.button)}
                  to={`docs/intro`}>
                  <Translate description="homepage getting started button">
                    Getting started
                  </Translate>
                </Link>
              </AnimationOnScroll>
            </div>
          </div>
          <div className={clsx("col col--6", styles.center)}>
            <img
              src={require('../../static/img/hero.png').default}
              className={styles.screenshot}
              alt="hero screenshot"
            />
          </div>
        </div>
      </div>
    </header>
  );
}

function TopBanner() {

  return (
    <div className={styles.topBanner}>
      <div className={styles.topBannerTitle}>
        {'🎉\xa0'}
        <Link to="/blog/releases/3.0" className={styles.topBannerTitleText}>
          <Translate id="homepage.banner.launch.3.0">
            {'Docusaurus\xa03.0 is\xa0out!️'}
          </Translate>
        </Link>
        {'\xa0🥳'}
      </div>
      {/*
      <div style={{display: 'flex', alignItems: 'center', flexWrap: 'wrap'}}>
        <div style={{flex: 1, whiteSpace: 'nowrap'}}>
          <div className={styles.topBannerDescription}>
            We are on{' '}
            <b>
              <Link to="https://www.producthunt.com/posts/docusaurus-2-0">
                ProductHunt
              </Link>{' '}
              and{' '}
              <Link to="https://news.ycombinator.com/item?id=32303052">
                Hacker News
              </Link>{' '}
              today!
            </b>
          </div>
        </div>
        <div
          style={{
            flexGrow: 1,
            flexShrink: 0,
            padding: '0.5rem',
            display: 'flex',
            justifyContent: 'center',
          }}>
          <ProductHuntCard />
          <HackerNewsIcon />
        </div>
      </div>
      */}
    </div>
  );
}


export default function Home({ docsPluginId }) {
  const { siteConfig } = useDocusaurusContext();
  return (
    <Layout
      title={`${siteConfig.title}`}
      description="Change the world">
      {/* <TopBanner /> */}
      <HomepageHeader docsPluginId={docsPluginId} />
      <main>
        <HomepageDescription />
        <HomepageFeatures />
      </main>
    </Layout>
  );
}
