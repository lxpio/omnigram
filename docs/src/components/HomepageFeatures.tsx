import React from 'react';
import clsx from 'clsx';
import styles from './HomepageFeatures.module.css';
import Translate from '@docusaurus/Translate';
import { DownloadAppButton } from './DownloadButton';
import Lottie from 'react-lottie';
import * as crossPlatformData from './lotties/animation-cross-platform.json';
import * as audiobookData from './lotties/animation-audiobook.json';
import * as selfHostData from './lotties/animation-self-host.json';
import * as deploymentData from './lotties/animation-deployment.json';

const Principals = [
    {
        title: (<Translate description="Features cross-platform title">Cross platform</Translate>),
        animationData: crossPlatformData,
        description: (
            <Translate description="Features cross-platform description">
                You can use the app on your phone, tablet, laptop, or desktop.
                The app is available on Linux, Android, and Windows.
            </Translate>
        ),
    },
    {
        title: (<Translate description="Features customizable title">Customizable</Translate>),
        animationData: audiobookData,
        description: (
            <Translate description="Features customizable description">
                Audiobook functionality through TTS models and supports other AI models for assisted reading(like daily web browser summaries).
            </Translate>
        ),
    },
    {
        title: (<Translate description="Self-host">Self Host Manager</Translate>),
        animationData: selfHostData,
        description: (
            <Translate description="Features simple description">
                Your documents and media, made simple.
                autobackup files to in your favorite cloud(like google drive).
                including PDF, EPUB, audio, and video.
            </Translate>
        ),
    },
    {
        title: (<Translate description="Features local title">Simple deployment</Translate>),
        animationData: deploymentData,
        description: (
            <Translate description="Features local description">
                Omnigram-server is easy to install and set up on your NAS-Server(ARM or AMD64).
                It also available on Linux, Mac, and Windows.
            </Translate>
        ),
    },

];

const Features = [
    {
        description: (
            <Translate description="Features infinite-canvas">
                Using AI to convert text content into speech, allowing users to listen to books.
            </Translate>
        ),
    },
    {
        description: (
            <Translate description="Features elements">
                Provides browser extension that can summarize daily reading and output the summary as a document for knowledge retention.
            </Translate>
        ),
    },
    {
        Svg: require('../../static/img/undraw_progressive_app_m-9-ms.svg').default,
        description: (
            <Translate description="Features imports">
                Automatically manage documents stored on a NAS server and provide global content search.
            </Translate>
        ),
    },
    {
        Svg: require('../../static/img/undraw_progressive_app_m-9-ms.svg').default,
        description: (
            <Translate description="Features structure">
                Supports integration with popular media players such as Infuse and Kodi.
            </Translate>
        ),
    },
    {
        Svg: require('../../static/img/undraw_progressive_app_m-9-ms.svg').default,
        description: (
            <Translate description="Features structure">
                Encrypt and backup local files to major cloud storage services such as Google Drive, OneDrive.
            </Translate>
        ),
    },
];



function Principal({ animationData, title, description }) {

    // const importAnimationData = () => import(animation);

    const defaultOptions = {
        loop: true,
        autoplay: true,
        animationData: animationData,
        rendererSettings: {
            preserveAspectRatio: "xMidYMid slice"
        }
    };

    return (
        <div className={clsx('col col--3')}>
            <div className="text--center">
                <Lottie
                    options={defaultOptions}
                    height={200}
                    width={200}
                />
            </div>
            <div className="text--center padding-horiz--md">
                <h3>{title}</h3>
                <p>{description}</p>
            </div>
        </div>
    );
}

export default function HomepageFeatures() {
    return (
        <section data-aos="fade-up" className={styles.features}>
            <div className="container">
                <h2>
                    <Translate description="Principals title">
                        Principals
                    </Translate>
                </h2>
                <div className="row">
                    {Principals.map((props, idx) => (
                        <Principal key={idx} {...props} />
                    ))}
                </div>
                <h2>
                    <Translate description="Showcase title">
                        Features
                    </Translate>
                </h2>
                <div className="row">
                    <div className="col col--6">
                        <img
                            // src={require('/img/feature-illustration-one.svg').default}
                            src='/img/feature-one.svg'
                            style={{ width: '70%' }}
                            className={styles.showcaseImg}
                            alt="Screenshot"
                        />
                    </div>
                    <ul className="col col--6">
                        {Features.map((props, idx) => (
                            <li key={idx} className={`text-large vertical-center ${styles.showcaseText}`}>{props.description}</li>
                        ))}
                        <li className={`text-large ${styles.showcaseButton}`}>
                            <h2>
                                <Translate description="Download title">
                                    Try Omnigram now
                                </Translate>
                            </h2>
                            <DownloadAppButton />
                        </li>
                    </ul>
                </div>
            </div>
        </section>
    );
}
