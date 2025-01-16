/*! For license information please see f31a8352.ca86f171.js.LICENSE.txt */
"use strict";(self.webpackChunkomnigram_docs=self.webpackChunkomnigram_docs||[]).push([[170],{2370:(e,n,s)=>{s.r(n),s.d(n,{assets:()=>a,contentTitle:()=>c,default:()=>p,frontMatter:()=>l,metadata:()=>i,toc:()=>d});const i=JSON.parse('{"id":"overviews/getting_start","title":"\u5feb\u901f\u5165\u95e8","description":"\u672c\u6587\u65e8\u5728\u5feb\u901f\u5b8c\u6210\u540e\u7aef\u90e8\u7f72\u548c\u4f7f\u7528\uff0c\u5982\u679c\u9700\u8981\u81ea\u5b9a\u4e49\u7684\u4e00\u4e9b\u914d\u7f6e\u8bf7\u53c2\u9605\u90e8\u7f72\u6587\u6863","source":"@site/i18n/zh/docusaurus-plugin-content-docs/current/overviews/getting_start.md","sourceDirName":"overviews","slug":"/overviews/getting_start","permalink":"/zh/docs/overviews/getting_start","draft":false,"unlisted":false,"editUrl":"https://translate.lxpio.com/omnigram/zh","tags":[],"version":"current","sidebarPosition":10,"frontMatter":{"title":"\u5feb\u901f\u5165\u95e8","sidebar_position":10},"sidebar":"sidebar","previous":{"title":"Architecture","permalink":"/zh/docs/overviews/architecture"},"next":{"title":"\u9879\u76ee\u652f\u6301","permalink":"/zh/docs/overviews/support"}}');var t=s(5105),r=s(6755);const l={title:"\u5feb\u901f\u5165\u95e8",sidebar_position:10},c=void 0,a={},d=[{value:"\u73af\u5883\u4f9d\u8d56",id:"\u73af\u5883\u4f9d\u8d56",level:2},{value:"Docker \u542f\u52a8",id:"docker-\u542f\u52a8",level:2},{value:"\u5c1d\u8bd5\u624b\u673a\u7aef\u8bbf\u95ee",id:"\u5c1d\u8bd5\u624b\u673a\u7aef\u8bbf\u95ee",level:2},{value:"\u4e0b\u8f7d App",id:"\u4e0b\u8f7d-app",level:3},{value:"\u767b\u9646 App",id:"\u767b\u9646-app",level:3},{value:"\u626b\u63cf\u672c\u5730\u6587\u4ef6\u76ee\u5f55",id:"\u626b\u63cf\u672c\u5730\u6587\u4ef6\u76ee\u5f55",level:3},{value:"\u5f00\u59cb\u9605\u8bfb",id:"\u5f00\u59cb\u9605\u8bfb",level:3},{value:"\u63a5\u4e0b\u6765\u53ef\u4ee5\u505a\u4ec0\u4e48",id:"\u63a5\u4e0b\u6765\u53ef\u4ee5\u505a\u4ec0\u4e48",level:2}];function o(e){const n={a:"a",code:"code",h2:"h2",h3:"h3",input:"input",li:"li",p:"p",pre:"pre",ul:"ul",...(0,r.R)(),...e.components};return(0,t.jsxs)(t.Fragment,{children:[(0,t.jsx)(n.p,{children:"\u672c\u6587\u65e8\u5728\u5feb\u901f\u5b8c\u6210\u540e\u7aef\u90e8\u7f72\u548c\u4f7f\u7528\uff0c\u5982\u679c\u9700\u8981\u81ea\u5b9a\u4e49\u7684\u4e00\u4e9b\u914d\u7f6e\u8bf7\u53c2\u9605\u90e8\u7f72\u6587\u6863"}),"\n",(0,t.jsx)(n.h2,{id:"\u73af\u5883\u4f9d\u8d56",children:"\u73af\u5883\u4f9d\u8d56"}),"\n",(0,t.jsxs)(n.p,{children:["\u8bf7\u67e5\u9605",(0,t.jsx)(n.a,{href:"../install/requirements",children:"\u73af\u5883\u8981\u6c42"})]}),"\n",(0,t.jsx)(n.h2,{id:"docker-\u542f\u52a8",children:"Docker \u542f\u52a8"}),"\n",(0,t.jsxs)(n.p,{children:["\u9ed8\u8ba4\u60c5\u51b5\u4e0b docker \u542f\u52a8\u4ee5\u540e\u5c06\u521b\u5efa\u9ed8\u8ba4\u7ba1\u7406\u5458\u8d26\u53f7",(0,t.jsx)(n.code,{children:"admin"}),"\uff0c\u5bc6\u7801\u9ed8\u8ba4\u4e3a",(0,t.jsx)(n.code,{children:"123456"}),"\u3002"]}),"\n",(0,t.jsxs)(n.ul,{children:["\n",(0,t.jsxs)(n.li,{children:["\u9ed8\u8ba4\u5bc6\u7801\u4e3a",(0,t.jsx)(n.code,{children:"123456"}),"\uff0c\u53ef\u4ee5\u540e\u7eed\u767b\u5f55\u540e\u66f4\u6539\uff0c\u6216\u8005\u901a\u8fc7\u8bbe\u7f6e",(0,t.jsx)(n.code,{children:"OMNI_PASSWORD"}),"\u53d8\u91cf\u8fdb\u884c\u66f4\u6539\u3002"]}),"\n",(0,t.jsxs)(n.li,{children:[(0,t.jsx)(n.code,{children:"my_local_docs_path"}),"\u5e94\u8be5\u4fee\u6539\u672a\u81ea\u5df1\u5b9e\u9645\u5b58\u6709 Epub\uff0cPDF \u76ee\u5f55\uff0c\u767b\u9646\u540e\u53ef\u4ee5\u8bbe\u7f6e\u626b\u63cf\u7b56\u7565\u4ece\u800c\u5efa\u7acb\u6587\u4ef6\u7d22\u5f15\uff1b"]}),"\n",(0,t.jsxs)(n.li,{children:["\u5982\u679c\u9700\u8981\u6301\u4e45\u8fd0\u884c\u8bf7\u53c2\u9605",(0,t.jsx)(n.a,{href:"../install/best_practice",children:"\u6700\u4f73\u90e8\u7f72\u5b9e\u8df5"})]}),"\n"]}),"\n",(0,t.jsx)(n.pre,{children:(0,t.jsx)(n.code,{className:"language-bash",children:"# \u66ff\u6362\u5982\u4e0b\u540d\u5b57\u4e2d my_local_docs_path \u672a\u81ea\u5df1\u5b9e\u9645\u7684\u6587\u6863\u76ee\u5f55\ndocker run -v <my_local_docs_path>:/docs -p 8080:80 lxpio/omnigram-server:latest\n"})}),"\n",(0,t.jsx)(n.h2,{id:"\u5c1d\u8bd5\u624b\u673a\u7aef\u8bbf\u95ee",children:"\u5c1d\u8bd5\u624b\u673a\u7aef\u8bbf\u95ee"}),"\n",(0,t.jsx)(n.h3,{id:"\u4e0b\u8f7d-app",children:"\u4e0b\u8f7d App"}),"\n",(0,t.jsx)(n.p,{children:"\u624b\u673a\u7aef\u5e94\u7528\u53ef\u4ee5\u4ece\u5982\u4e0b\u5730\u5740\u4e0b\u8f7d\uff1a"}),"\n",(0,t.jsxs)(n.ul,{className:"contains-task-list",children:["\n",(0,t.jsxs)(n.li,{className:"task-list-item",children:[(0,t.jsx)(n.input,{type:"checkbox",disabled:!0})," ","\u8c37\u6b4c\u5546\u57ce"]}),"\n",(0,t.jsxs)(n.li,{className:"task-list-item",children:[(0,t.jsx)(n.input,{type:"checkbox",disabled:!0})," ","\u82f9\u679c\u5546\u57ce"]}),"\n",(0,t.jsxs)(n.li,{className:"task-list-item",children:[(0,t.jsx)(n.input,{type:"checkbox",checked:!0,disabled:!0})," ",(0,t.jsx)(n.a,{href:"https://github.com/lxpio/omnigram",children:"Github(apk)"})]}),"\n"]}),"\n",(0,t.jsx)(n.h3,{id:"\u767b\u9646-app",children:"\u767b\u9646 App"}),"\n",(0,t.jsx)(n.p,{children:"//TODO add login page"}),"\n",(0,t.jsx)(n.h3,{id:"\u626b\u63cf\u672c\u5730\u6587\u4ef6\u76ee\u5f55",children:"\u626b\u63cf\u672c\u5730\u6587\u4ef6\u76ee\u5f55"}),"\n",(0,t.jsx)(n.p,{children:"//TODO add scan page"}),"\n",(0,t.jsx)(n.h3,{id:"\u5f00\u59cb\u9605\u8bfb",children:"\u5f00\u59cb\u9605\u8bfb"}),"\n",(0,t.jsx)(n.p,{children:"//TODO add reading page"}),"\n",(0,t.jsx)(n.h2,{id:"\u63a5\u4e0b\u6765\u53ef\u4ee5\u505a\u4ec0\u4e48",children:"\u63a5\u4e0b\u6765\u53ef\u4ee5\u505a\u4ec0\u4e48"}),"\n",(0,t.jsxs)(n.p,{children:["\u4e0a\u8ff0\u6587\u6863\u53ea\u662f\u4e3a\u4e86\u5feb\u901f\u5165\u95e8\u7ea7\u7684\u90e8\u7f72\u548c\u4f53\u9a8c\uff0c\u5982\u679c\u671f\u5f85\u300c\u8bfb\u4eab\u300d\u7684\u5b8c\u6574\u7684\u670d\u52a1\u529f\u80fd\u548c\u4f53\u9a8c\u3002\u8bf7\u524d\u5f80 ",(0,t.jsx)(n.a,{href:"../install/best_practice",children:"\u6700\u4f73\u90e8\u7f72\u5b9e\u8df5"})]})]})}function p(e={}){const{wrapper:n}={...(0,r.R)(),...e.components};return n?(0,t.jsx)(n,{...e,children:(0,t.jsx)(o,{...e})}):o(e)}},5649:(e,n)=>{var s=Symbol.for("react.transitional.element"),i=Symbol.for("react.fragment");function t(e,n,i){var t=null;if(void 0!==i&&(t=""+i),void 0!==n.key&&(t=""+n.key),"key"in n)for(var r in i={},n)"key"!==r&&(i[r]=n[r]);else i=n;return n=i.ref,{$$typeof:s,type:e,key:t,ref:void 0!==n?n:null,props:i}}n.Fragment=i,n.jsx=t,n.jsxs=t},5105:(e,n,s)=>{e.exports=s(5649)},6755:(e,n,s)=>{s.d(n,{R:()=>l,x:()=>c});var i=s(8101);const t={},r=i.createContext(t);function l(e){const n=i.useContext(r);return i.useMemo((function(){return"function"==typeof e?e(n):{...n,...e}}),[n,e])}function c(e){let n;return n=e.disableParentContext?"function"==typeof e.components?e.components(t):e.components||t:l(e.components),i.createElement(r.Provider,{value:n},e.children)}}}]);