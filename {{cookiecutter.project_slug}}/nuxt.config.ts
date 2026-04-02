import { fileURLToPath } from "node:url";
import { varlockVitePlugin } from "@varlock/vite-integration";

// https://nuxt.com/docs/api/configuration/nuxt-config
export default defineNuxtConfig({
    compatibilityDate: "2024-11-01",
    devtools: { enabled: true },
    extends: [
        ["github:DCC-BS/nuxt-layers/auth"],
        ["github:DCC-BS/nuxt-layers/backend_communication"],
        ["github:DCC-BS/nuxt-layers/health_check"],
        ["github:DCC-BS/nuxt-layers/logger"],
        process.env.USE_FEEDBACK === "true"
            ? ["github:DCC-BS/nuxt-layers/feedback-control"]
            : undefined,
    ],
    routeRules: {
        "/api/ping": {
            cors: true,
            headers: {
                "Cache-Control": "no-store",
                "Access-Control-Allow-Origin": "*",
                "Access-Control-Allow-Methods": "GET",
                "Access-Control-Allow-Headers":
                    "Origin, Content-Type, Accept, Authorization, X-Requested-With",
                "Access-Control-Allow-Credentials": "true",
            },
        },
    },
    alias: {
        "#shared": fileURLToPath(new URL("./shared", import.meta.url)),
    },
    app: {
        head: {
            titleTemplate: "{{ cookiecutter.app_title }}",
            htmlAttrs: {
                lang: "de",
            },
            meta: [
                { charset: "utf-8" },
                {
                    name: "viewport",
                    content: "width=device-width, initial-scale=1",
                },
                {
                    name: "apple-mobile-web-app-title",
                    content: "{{ cookiecutter.app_title }}",
                },
                { name: "application-name", content: "{{ cookiecutter.app_title }}" },
                { name: "msapplication-config", content: "/browserconfig.xml" },
            ],
        },
    },
    ui: {
        colorMode: false,
    },
    modules: [
        "@nuxt/ui",
        "@nuxtjs/i18n",
        "@dcc-bs/common-ui.bs.js",
        "@dcc-bs/event-system.bs.js",
        "@dcc-bs/dependency-injection.bs.js",
    ],
    typescript: {
        typeCheck: true,
        strict: true,
    },
    css: ["~/assets/css/main.css"],
    vite: {
        plugins: [varlockVitePlugin({ ssrInjectMode: "resolved-env" })],
        build: {
            sourcemap: process.env.NODE_ENV !== "production",
            cssMinify: "lightningcss",
            chunkSizeWarningLimit: 800,
            rollupOptions: {
                output: {
                    manualChunks: {
                        "vue-vendor": ["vue", "vue-router"],
                    },
                },
            },
        },
    },
    runtimeConfig: {
        apiUrl: process.env.API_URL,
        feedback: {
            githubToken: process.env.FEEDBACK_GITHUB_TOKEN,
            project: "{{ cookiecutter.project_slug }}",
            repoOwner: "DCC-BS",
            repo: "Feedback",
        },
        public: {
            useFeedback: process.env.USE_FEEDBACK ?? true,
            useDummyData: process.env.DUMMY,
            logger: {
                loglevel: process.env.LOG_LEVEL || "debug",
            },
        },
    },
    fonts: {
        providers: {
            bunny: false,
        },
    },
    i18n: {
        locales: [
            {
                code: "en",
                name: "English",
                file: "en.json",
            },
            {
                code: "de",
                name: "Deutsch",
                file: "de.json",
            },
        ],
        defaultLocale: "de",
        strategy: "no_prefix",
    },
});
